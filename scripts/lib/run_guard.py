"""Keeps an unattended `process plan` run going until the plan says it is done.

A run can end three ways, and each has its own catch:

- The session ends its turn: the Stop hook sends it back while runnable rows remain.
- The session sits idle (an API error, a yield): a CronCreate tick in that session wakes it.
- The session dies (a crash, a reboot): the scheduled `watch` resumes it, never beside a live session.

Two things are waited for, never fought. While a review is in flight (scripts/review-dispatch.py leaves a marker
under build/review-in-flight/ for as long as its reviewer runs) the Stop hook lets the turn end and `watch` starts
nothing: a review runs alone, and its end wakes the session that started it. While the launcher that started the
run (scripts/start-unattended-run.ps1) is alive, it restarts a dead session itself, so `watch` leaves the run to it.

The prompt switches the run on, so no one has to remember to. Only the operator or the plan ends it: an
operator stop, a normal exit, no runnable rows left, or a recorded halt. Stalling (no commit and no change to
the tree across many attempts) also ends it, so a stuck run cannot spend without limit. Fails open: a broken
guard must never wedge a session.
"""

from __future__ import annotations

import calendar
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import time
from contextlib import contextmanager
from dataclasses import dataclass, replace
from pathlib import Path
from typing import Callable, Iterator

ROOT = Path(__file__).resolve().parents[2]
STATE = Path(os.environ.get("RUN_GUARD_STATE") or ROOT / ".git" / "run-guard" / "state.json")
IN_FLIGHT = ROOT / "build" / "review-in-flight"  # one marker per running review, written by scripts/review-dispatch.py
TASK_NAME = f"{ROOT.name} run watchdog"
WATCH_MINUTES = 10
CRON = "7,22,37,52 * * * *"

MAX_IDLE_BLOCKS = 5  # sends back in a row with nothing changed, before the turn may end
MAX_YIELDS = 3  # those yields in a row with nothing changed, before the run is called stalled
MAX_RESTARTS = 3  # resumes of a dead session with nothing changed, before the run is called stalled
MAX_QUIET_HOURS = 72  # a run this long without a change has been walked away from; it never resumes itself
CHILD_HANG_HOURS = 3  # a resumed session this long without a change is reported, not replaced
HEARTBEAT_RENEW_DAYS = 6  # CronCreate jobs expire after 7 days
LOCK_WAIT = 5  # seconds, well under every hook's timeout: slow reads happen before the lock, see snapshot

DRAINED = "no runnable rows left; that is not the plan being done, `todo-graph.py query stats` shows what is blocked or unstamped"
GROUNDS = ("data-loss", "credentials", "shared-infrastructure", "wrong-calculation", "operator")
HOST_NEEDS = {
    "arm64-host",
    "display-session",
    "office",
    "attended",
    "Optical drive (drive test)",
    "USB device (drive test)",
    "Signing certificate (release)",
    "Clean Windows machine (no Visual Studio)",
}  # leftovers here, as process-plan says

START = re.compile(r"^\s*(please\s+)?/?process[- ](the\s+)?plan\s*[.!]?\s*$", re.IGNORECASE)
STOP = re.compile(
    r"^\s*(please\s+)?(stop|pause|halt)((\s+(the|this|that|it|run|plan|process|work|working|now|everything|cleanly|safely|and|here))*)\s*[.!]?\s*$",
    re.IGNORECASE,
)
MENTIONS_STOP = re.compile(r"\b(stop|pause|halt|cancel|abort|quit)\b", re.IGNORECASE)
USER_EXITS = {"prompt_input_exit", "logout", "clear"}  # a crash or a killed process reports none of these


@dataclass
class Env:
    """What the guard reads from the world, so tests can stand in for it."""

    rows: Callable[[], list[str] | None]
    signature: Callable[[], str]
    alive: Callable[[str], bool]
    live_here: Callable[[], list[str]]
    child_alive: Callable[[dict], bool]
    spawn: Callable[[dict], dict]
    task_installed: Callable[[], bool] = lambda: True
    reviewing: Callable[[], bool] = lambda: False


def stamp(now: float | None = None) -> str:
    return time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime(now if now is not None else time.time()))


def load(path: Path = STATE) -> dict:
    """The run's state. A file that cannot be read raises: unreadable is not the same as no run."""
    try:
        text = path.read_text(encoding="utf-8")
    except FileNotFoundError:
        return {}
    state = json.loads(text)
    if not isinstance(state, dict):
        raise ValueError(f"{path} does not hold a run state")
    return state


@contextmanager
def locked(path: Path = STATE, wait: float = LOCK_WAIT) -> Iterator[None]:
    """Every change to the state goes through here, held across load to save, so a tick cannot undo a stop."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.with_name(path.name + ".lock").open("a+b") as handle:
        deadline = time.monotonic() + wait
        while True:
            try:
                if os.name == "nt":
                    import msvcrt

                    handle.seek(0)
                    msvcrt.locking(handle.fileno(), msvcrt.LK_NBLCK, 1)
                else:
                    import fcntl

                    fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
                break
            except OSError:
                if time.monotonic() >= deadline:
                    raise TimeoutError(f"{path.name} stayed locked for {wait} seconds") from None
                time.sleep(0.1)
        try:
            yield
        finally:
            if os.name == "nt":
                handle.seek(0)
                msvcrt.locking(handle.fileno(), msvcrt.LK_UNLCK, 1)


def save(state: dict, path: Path = STATE) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(f"{path.name}.{os.getpid()}.tmp")
    tmp.write_text(json.dumps(state, indent=2), encoding="utf-8")
    os.replace(tmp, path)


def log(line: str, path: Path = STATE) -> None:
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.with_name("run-guard.log").open("a", encoding="utf-8") as out:
            out.write(f"{stamp()} {line}\n")
    except OSError:
        pass


def end_run(state: dict, status: str, why: str) -> None:
    state.update(active=False, status=status, why=why, ended=stamp())


def is_stop(prompt: str) -> bool:
    """A plain order to stop the run. Anything less plain goes to the model to judge: see on_prompt."""
    return bool(STOP.match(prompt))


def heartbeat_note() -> str:
    return (
        "Unattended run guard is active. If this session is interactive and CronList shows no heartbeat, create one "
        f"now with CronCreate, cron \"{CRON}\", prompt: \"Run heartbeat: run `python scripts/run-guard.py status`. If it "
        "prints active and no turn is in progress, continue process-plan at the next ready row. If it prints anything "
        "else, CronDelete this job and end the turn.\" Never ask the operator; record decisions in the run file. If the "
        "operator asks to stop or pause, run `python scripts/run-guard.py halt --ground operator --reason <their words>`."
    )


def snapshot(env: Env) -> Env:
    """Takes the slow reads now, so the lock is never held across them and a stop can always get in."""
    rows, signature = env.rows(), env.signature()
    return replace(env, rows=lambda: rows, signature=lambda: signature)


def on_prompt(state: dict, data: dict, env: Env) -> str | None:
    prompt = str(data.get("prompt") or "")
    session = data.get("session_id")
    if state.get("active") and is_stop(prompt):
        end_run(state, "stopped", f"operator: {prompt.strip()}")
        return "The run guard stopped holding this run because the operator said to stop. `process plan` starts it again."
    if not START.match(prompt):
        # Background-task notifications and the heartbeat arrive as prompts too; neither is the operator speaking.
        machine = "<task-notification>" in prompt or prompt.startswith("Run heartbeat:")
        if state.get("active") and state.get("session_id") == session and not machine and MENTIONS_STOP.search(prompt):
            return (
                "The unattended run guard is active and this message mentions stopping. If the operator is asking to stop or "
                "pause the run, now or after the current section, run `python scripts/run-guard.py halt --ground operator "
                "--reason <their words>` when that point comes, or the Stop hook keeps sending the turn back. If it is about "
                "something else, carry on."
            )
        return None
    if state.get("active") and state.get("session_id") not in (None, session) and env.alive(state["session_id"]):
        return f"Another session ({state['session_id']}) owns the active run. Never run two writers on one tree: stop and say so."
    if not state.get("active"):
        state.clear()
        state.update(active=True, status="active", started=stamp(), changed_at=time.time())
    state.update(session_id=session, permission_mode=data.get("permission_mode"))
    if not env.task_installed():
        return heartbeat_note() + " The watchdog task is not installed, so a crash would end this run: run `python scripts/run-guard.py install` first."
    return heartbeat_note()


def heartbeat_current(state: dict, now: float | None = None) -> bool:
    age = (time.time() if now is None else now) - state.get("heartbeat_epoch", 0)
    return age < HEARTBEAT_RENEW_DAYS * 86400


def send_back(left: list[str] | None, state: dict) -> str:
    rows = "the next ready row" if not left else f"{len(left)} runnable rows, first {left[0]}"
    heartbeat = "" if heartbeat_current(state) else "The heartbeat is not armed or is about to expire: create it again with CronCreate if this session is interactive, deleting any old one. "
    return heartbeat + (
        f"Unattended run is active: {rows}. Do not stop or report: continue process-plan now. A section that cannot be "
        "stamped is recorded and passed over, not a reason to end the run. Halting needs data loss, credentials, shared "
        "infrastructure or a calculation that looks wrong: `python scripts/run-guard.py halt --ground <ground> --reason <why>`."
    )


def on_stop(state: dict, data: dict, env: Env) -> str | None:
    if not state.get("active") or state.get("session_id") != data.get("session_id"):
        return None
    if env.reviewing():
        # A review runs alone and its end wakes this session, so the turn may end here. It is not an idle attempt:
        # counting it would stall a run for doing exactly what a review requires.
        return None
    left = env.rows()
    if left == []:
        end_run(state, "drained", DRAINED)
        return None
    signature = env.signature()
    if signature != state.get("signature"):
        state.update(signature=signature, idle=0, yields=0, changed_at=time.time())
    else:
        state["idle"] = state.get("idle", 0) + 1
    if state.get("idle", 0) >= MAX_IDLE_BLOCKS:
        state["idle"] = 0
        state["yields"] = state.get("yields", 0) + 1
        if state["yields"] >= MAX_YIELDS:
            end_run(state, "stalled", "no commit or change to the tree across repeated attempts")
        return None
    state["last_block"] = stamp()
    return send_back(left, state)


def on_session_start(state: dict, data: dict) -> str | None:
    """Only the run's own session continues it: a new session opened in this repository is unrelated work."""
    if not state.get("active") or state.get("session_id") != data.get("session_id"):
        return None
    return heartbeat_note() + " Continue process-plan now."


def on_cron_created(state: dict, data: dict) -> None:
    if state.get("active") and state.get("session_id") == data.get("session_id"):
        state.update(heartbeat_at=stamp(), heartbeat_epoch=time.time())


def on_stop_failure(state: dict, data: dict) -> None:
    """An API error ends the turn with no Stop to send back, so only the heartbeat wakes the session: `status` shows it."""
    if state.get("active") and state.get("session_id") == data.get("session_id"):
        state["last_api_failure"] = f"{stamp()} {data.get('error') or 'unknown'}"


def start(state: dict, session: str, mode: str | None, env: Env, launcher: dict | None = None) -> None:
    """Switch the run on for `session`. `launcher` is the process that will restart it, as {"pid", "started"}."""
    owner = state.get("session_id")
    if state.get("active") and owner not in (None, session) and env.alive(owner):
        raise ValueError(f"session {owner} owns the active run and is alive; never run two writers on one tree")
    if state.get("active") and state.get("child") and env.child_alive(state["child"]):
        raise ValueError(f"the watchdog's resumed session {state['child'].get('pid')} is working on this run; never run two writers on one tree")
    if not state.get("active"):
        state.clear()
        state.update(active=True, status="active", started=stamp(), changed_at=time.time())
    state.update(session_id=session, permission_mode=mode)
    if launcher:
        state["launcher"] = launcher
    else:
        state.pop("launcher", None)


def on_session_end(state: dict, data: dict) -> None:
    if state.get("active") and state.get("session_id") == data.get("session_id") and data.get("reason") in USER_EXITS:
        end_run(state, "stopped", f"operator ended the session ({data.get('reason')})")


def watch(state: dict, env: Env, now: float | None = None) -> str:
    """One scheduled tick. A live session in this repository always wins: two writers on one tree is the worse failure."""
    if not state.get("active"):
        return "inactive"
    now = time.time() if now is None else now
    signature = env.signature()
    if signature != state.get("restart_signature"):
        state.update(restart_signature=signature, restarts=0, changed_at=now)
    quiet = (now - state.get("changed_at", now)) / 3600
    if state.get("child") and env.child_alive(state["child"]):
        if (now - max(state.get("changed_at", now), state.get("launched_at", 0))) / 3600 >= CHILD_HANG_HOURS:
            end_run(state, "stalled", f"resumed session {state['child'].get('pid')} changed nothing for {CHILD_HANG_HOURS} hours; it was left running")
            return "stalled"
        return "resumed session still running"
    live = env.live_here()
    if live:
        return f"session live here: {live[0]}"
    if state.get("launcher") and env.child_alive(state["launcher"]):
        return "the launcher is alive and restarts the session itself"
    if env.reviewing():
        return "review in flight"
    if quiet >= MAX_QUIET_HOURS:
        end_run(state, "expired", f"nothing changed for {MAX_QUIET_HOURS} hours, so it was not resumed; `process plan` starts it again")
        return "expired"
    left = env.rows()
    if left == []:
        end_run(state, "drained", DRAINED)
        return "drained"
    if state.get("restarts", 0) >= MAX_RESTARTS:
        end_run(state, "stalled", f"{MAX_RESTARTS} resumes changed nothing")
        return "stalled"
    child = env.spawn(state)  # a launch that fails raises and uses no attempt: nothing ran, so nothing was tried
    state.update(child=child, restarts=state.get("restarts", 0) + 1, launched_at=now, last_restart=stamp())
    return f"resumed, attempt {state['restarts']}"


def halt(state: dict, ground: str, reason: str) -> None:
    if ground not in GROUNDS:
        raise ValueError(f"ground must be one of: {', '.join(GROUNDS)}")
    if not reason.strip():
        raise ValueError("a halt needs a reason")
    end_run(state, "halted", f"{ground}: {reason.strip()}")


# The world, on this machine.


def hidden() -> dict:
    return {"creationflags": subprocess.CREATE_NO_WINDOW} if os.name == "nt" else {}


def run(*args: str, cwd: Path = ROOT) -> subprocess.CompletedProcess:
    env = {**os.environ, "PYTHONIOENCODING": "utf-8"}
    return subprocess.run(args, cwd=cwd, capture_output=True, env=env, timeout=20, stdin=subprocess.DEVNULL, **hidden())


def stranded(ref: str, reviews: Path) -> bool:
    """A section whose last completion review returned gaps has no route to a stamp, so the run passes over it."""
    match = re.fullmatch(r"D(\d+) T(\d+) §(\d+)", ref)
    if not match:
        return False
    stem = f"D{match[1]}-T{match[2]}-s{match[3]}"
    cycles = [p for p in reviews.glob(f"*/{stem}*.md") if p.stem == stem or p.stem.startswith(f"{stem}-")]
    def cycle(path: Path) -> list:  # so cycle10 comes after cycle9
        return [int(part) if part.isdigit() else part for part in re.split(r"(\d+)", path.stem[len(stem):])]

    for findings in sorted(cycles, key=cycle, reverse=True):  # the latest cycle decides
        verdicts = re.findall(r"^COMPLETION:\s*(\w+)", findings.read_text(encoding="utf-8", errors="replace"), re.MULTILINE)
        if verdicts:
            return verdicts[-1] != "complete"
    return False


def runnable(rows: list[dict], reviews: Path) -> list[str]:
    return [r["ref"] for r in rows if not (HOST_NEEDS & set(r.get("needs") or [])) and not stranded(r["ref"], reviews)]


def real_rows() -> list[str] | None:
    """The rows this run can still take. None when that cannot be told, which never ends a run."""
    try:
        out = run(sys.executable, str(ROOT / "scripts" / "todo-graph.py"), "query", "ready", "--json")
        if out.returncode != 0:
            return None
        return runnable(json.loads(out.stdout.decode("utf-8", "replace")), ROOT / "docs" / "reviews")
    except (OSError, ValueError, subprocess.SubprocessError):
        return None


def real_signature(root: Path = ROOT) -> str:
    head = run("git", "rev-parse", "HEAD", cwd=root).stdout
    tree = run("git", "status", "--porcelain", cwd=root).stdout + run("git", "diff", "HEAD", cwd=root).stdout
    # The diff leaves out untracked files, and status can collapse a new folder to one line: edits there are work too.
    for name in run("git", "ls-files", "--others", "--exclude-standard", "-z", cwd=root).stdout.decode("utf-8", "replace").split("\0"):
        try:
            seen = (root / name).stat() if name else None
        except OSError:
            continue  # removed while this looked; the next signature differs anyway
        if seen:
            tree += f"{name}:{seen.st_size}:{seen.st_mtime_ns}\n".encode()
    return f"{head.decode().strip()}:{hashlib.sha256(tree).hexdigest()}"


def process_started(pid: int) -> int | None:
    """When a process started, as a FILETIME, so a reused process id is not taken for the session. None when it is gone."""
    if os.name != "nt":
        try:
            os.kill(pid, 0)
            return 0
        except OSError:
            return None
    import ctypes
    from ctypes import wintypes

    kernel = ctypes.WinDLL("kernel32", use_last_error=True)
    kernel.OpenProcess.restype = wintypes.HANDLE
    kernel.OpenProcess.argtypes = (wintypes.DWORD, wintypes.BOOL, wintypes.DWORD)
    kernel.GetProcessTimes.argtypes = (wintypes.HANDLE, *[ctypes.POINTER(wintypes.FILETIME)] * 4)
    kernel.GetExitCodeProcess.argtypes = (wintypes.HANDLE, ctypes.POINTER(wintypes.DWORD))
    kernel.CloseHandle.argtypes = (wintypes.HANDLE,)
    handle = kernel.OpenProcess(0x1000, False, pid)  # PROCESS_QUERY_LIMITED_INFORMATION
    if not handle:
        if ctypes.get_last_error() == 87:  # ERROR_INVALID_PARAMETER: no such process
            return None
        raise OSError(f"cannot tell whether process {pid} is running")
    try:
        code = wintypes.DWORD()
        if not kernel.GetExitCodeProcess(handle, ctypes.byref(code)) or code.value != 259:  # STILL_ACTIVE
            return None
        times = [wintypes.FILETIME() for _ in range(4)]
        if not kernel.GetProcessTimes(handle, *[ctypes.byref(t) for t in times]):
            return None
        return (times[0].dwHighDateTime << 32) | times[0].dwLowDateTime
    finally:
        kernel.CloseHandle(handle)


def session_records() -> list[dict]:
    """Claude Code's own record of each session it runs; one left by a crash names a process that has gone.

    A record that cannot be judged raises, so `watch` starts nothing: not knowing is not the same as dead.
    """
    records = []
    for path in (Path.home() / ".claude" / "sessions").glob("*.json"):
        try:
            record = json.loads(path.read_text(encoding="utf-8"))
        except FileNotFoundError:
            continue  # the session exited while this looked
        started = process_started(int(record["pid"]))
        if started is not None and (os.name != "nt" or str(started) == str(record.get("procStart"))):
            records.append(record)
    return records


def same_folder(a: str | None, b: Path) -> bool:
    return bool(a) and os.path.normcase(os.path.realpath(a)) == os.path.normcase(os.path.realpath(str(b)))


def real_alive(session: str) -> bool:
    return any(r.get("sessionId") == session for r in session_records())


def real_live_here() -> list[str]:
    return [str(r.get("sessionId")) for r in session_records() if same_folder(r.get("cwd"), ROOT)]


def real_child_alive(child: dict) -> bool:
    started = process_started(int(child.get("pid", 0)))
    return started is not None and started == child.get("started")


def resume_command(state: dict, claude: str) -> list[str]:
    """The first attempt resumes the dead session with its context. An attempt after one that changed nothing starts
    a fresh session instead, which the `process plan` prompt hands the run to: a session that cannot be resumed (no
    transcript, or one another tool wrote) would otherwise fail the same way until the run stalled, as the run of
    2026-11-09 did on a session id Claude Code had never seen."""
    command = [claude, "-p", "process plan"]
    if state.get("session_id") and not state.get("restarts"):
        command += ["--resume", state["session_id"]]
    # The operator's own mode for this run and no wider, or a headless run has no one to answer its prompts.
    if state.get("permission_mode"):
        command += ["--permission-mode", state["permission_mode"]]
    return command


# The one-year sign-in (claude setup-token) kept in 1Password; scripts/start-unattended-run.ps1 reads the same item.
TOKEN_ITEM = ("Claude Code OAuth token (1 year, setup-token)", "Conclave")
TOKEN_SHAPE = re.compile(r"sk-ant-oat[0-9]{2}-[A-Za-z0-9_-]{40,}")
TOKEN_WAIT = 60  # seconds for 1Password to answer; with it locked and nobody there, the stored login is used


def read_token() -> str | None:
    """The token from 1Password, or None when it cannot be had. Never logged, printed or written: it only ever goes
    into the resumed session's environment."""
    op = shutil.which("op")
    if not op:
        return None
    item, vault = TOKEN_ITEM
    try:
        out = subprocess.run([op, "item", "get", item, "--vault", vault, "--fields", "label=credential", "--reveal"],
                             capture_output=True, timeout=TOKEN_WAIT, stdin=subprocess.DEVNULL, **hidden())
    except (OSError, subprocess.SubprocessError):
        return None
    return out.stdout.decode("utf-8", "replace").strip() if out.returncode == 0 else None


# 1Password is locked after a reboot with nobody there, which is exactly when the watchdog resumes a run. So the
# launcher leaves a copy only this Windows account on this machine can read (operator decision 2026-11-10): DPAPI
# encrypts it with a key Windows derives from the account, and 1Password stays the source of truth, asked first.
TOKEN_CACHE = Path(os.environ.get("LOCALAPPDATA") or Path.home()) / "Resolute" / "claude-token.dpapi"


def dpapi(data: bytes, protect: bool) -> bytes:
    """Encrypt or decrypt for the current Windows account. Raises OSError when Windows refuses or this is not Windows."""
    if os.name != "nt":
        raise OSError("DPAPI is a Windows facility")
    import ctypes
    from ctypes import wintypes

    class Blob(ctypes.Structure):
        _fields_ = [("cbData", wintypes.DWORD), ("pbData", ctypes.POINTER(ctypes.c_char))]

    crypt = ctypes.WinDLL("crypt32", use_last_error=True)
    kernel = ctypes.WinDLL("kernel32", use_last_error=True)
    kernel.LocalFree.argtypes = (ctypes.c_void_p,)
    call = crypt.CryptProtectData if protect else crypt.CryptUnprotectData
    call.argtypes = (ctypes.POINTER(Blob), ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p, wintypes.DWORD, ctypes.POINTER(Blob))
    source = Blob(len(data), ctypes.cast(ctypes.create_string_buffer(data, len(data)), ctypes.POINTER(ctypes.c_char)))
    result = Blob()
    if not call(ctypes.byref(source), None, None, None, None, 0x1, ctypes.byref(result)):  # CRYPTPROTECT_UI_FORBIDDEN
        raise OSError(f"DPAPI refused (error {ctypes.get_last_error()})")
    try:
        return ctypes.string_at(result.pbData, result.cbData)
    finally:
        kernel.LocalFree(result.pbData)


def cache_token(token: str, path: Path = TOKEN_CACHE) -> None:
    """Keep the token for a resume, encrypted for this account. A value not shaped like the token is refused."""
    token = token.strip()
    if not TOKEN_SHAPE.fullmatch(token):
        raise ValueError("the value does not have the shape of a Claude Code OAuth token; nothing was cached")
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(f"{path.name}.{os.getpid()}.tmp")
    tmp.write_bytes(dpapi(token.encode("utf-8"), protect=True))
    os.replace(tmp, path)


def cached_token(path: Path = TOKEN_CACHE) -> str | None:
    """The cached token, or None when there is no cache or this account cannot read it."""
    try:
        return dpapi(path.read_bytes(), protect=False).decode("utf-8", "replace")
    except OSError:
        return None  # no cache, another account's cache, or not Windows: sign_in then says the stored login is used


def sign_in(environ: dict, read: Callable[[], str | None] = read_token, cached: Callable[[], str | None] = cached_token) -> tuple[dict, str]:
    """The resumed session's environment, and how it signs in. The stored Claude Code login ends within weeks and a
    resumed session cannot renew it, so the one-year token is used whenever it can be had: from 1Password first, then
    from this account's encrypted cache. A value that is not shaped like that token (an error page, another field) is
    never handed over as a credential."""
    for source, get in (("1Password", read), ("this account's encrypted cache", cached)):
        token = get()
        if token and TOKEN_SHAPE.fullmatch(token):
            return {**environ, "CLAUDE_CODE_OAUTH_TOKEN": token}, f"the one-year token from {source}"
    return dict(environ), "the stored login (neither 1Password nor the cache gave the token)"


def real_spawn(state: dict) -> dict:
    claude = shutil.which("claude")
    if not claude:
        raise OSError("claude is not on PATH")
    output = STATE.with_name("resumed-session.log")
    flags = subprocess.CREATE_NO_WINDOW | subprocess.CREATE_NEW_PROCESS_GROUP if os.name == "nt" else 0
    env, how = sign_in(dict(os.environ))
    with output.open("ab") as out:
        child = subprocess.Popen(resume_command(state, claude), cwd=ROOT, env=env, stdin=subprocess.DEVNULL, stdout=out, stderr=out, creationflags=flags)
    return {"pid": child.pid, "started": process_started(child.pid), "sign_in": how}


def real_task_installed() -> bool:
    if os.name != "nt":
        return True
    return run("schtasks", "/Query", "/TN", TASK_NAME).returncode == 0


REVIEW_LOCK_AT = 1 << 30  # where a running dispatcher holds its lock: review-dispatch.py LOCK_AT, past the content


def review_running(marker: Path) -> bool:
    """A running dispatcher holds a lock on its marker and the operating system drops it when that process ends, so
    a lock this can take means nobody is running that review. A marker that has gone is a review that ended."""
    try:
        with marker.open("r+b") as handle:
            handle.seek(REVIEW_LOCK_AT)
            try:
                if os.name == "nt":
                    import msvcrt

                    msvcrt.locking(handle.fileno(), msvcrt.LK_NBLCK, 1)
                    handle.seek(REVIEW_LOCK_AT)
                    msvcrt.locking(handle.fileno(), msvcrt.LK_UNLCK, 1)
                else:
                    import fcntl

                    fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except OSError:
                return True  # held: this is the answer, not an error
    except FileNotFoundError:
        return False
    return False


def reviews_in_flight(folder: Path = IN_FLIGHT) -> list[str]:
    """The reviews running now. A marker whose dispatcher has gone (killed before it could remove it) is removed."""
    found = []
    for marker in sorted(folder.glob("*.json")) if folder.is_dir() else []:
        if review_running(marker):
            found.append(marker.name)
        else:
            try:
                marker.unlink(missing_ok=True)
            except OSError:
                continue  # a dispatcher opened it between the two lines above: the next look sees its lock
    return found


def real_reviewing() -> bool:
    return bool(reviews_in_flight())


REAL = Env(real_rows, real_signature, real_alive, real_live_here, real_child_alive, real_spawn, real_task_installed, real_reviewing)


def record_tick(result: str, ok: bool, path: Path = STATE) -> None:
    """Kept apart from the state, so a tick that could not read or lock the state still says so."""
    tick = path.with_name("last-tick.json")
    tmp = tick.with_name(f"{tick.name}.{os.getpid()}.tmp")
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp.write_text(json.dumps({"at": stamp(), "ok": ok, "result": result}), encoding="utf-8")
    os.replace(tmp, tick)


def health(state: dict, path: Path = STATE, env: Env = REAL, now: float | None = None) -> dict:
    """What `status` adds to the state: can each catch actually catch?"""
    now = time.time() if now is None else now
    try:
        tick = json.loads(path.with_name("last-tick.json").read_text(encoding="utf-8"))
    except (OSError, ValueError):
        tick = None
    return {
        "watchdog_installed": env.task_installed(),
        "last_tick": tick,
        "last_tick_stale": tick is None or not tick.get("ok") or now - calendar.timegm(time.strptime(tick["at"], "%Y-%m-%dT%H:%M:%SZ")) > (WATCH_MINUTES * 3) * 60,
        "heartbeat_current": heartbeat_current(state, now),
        "review_in_flight": env.reviewing(),
        "live_here": env.live_here(),  # every Claude Code session open in this clone, so a launcher can say who is writing
        "launcher_alive": bool(state.get("launcher")) and env.child_alive(state["launcher"]),
    }


def watch_tick(env: Env = REAL, path: Path = STATE, now: float | None = None) -> str:
    """One scheduled tick, with its result kept: slow reads first, then the lock, then the state as it now stands."""
    if not load(path).get("active"):
        return "inactive"
    env = snapshot(env)
    with locked(path):
        state = load(path)
        try:
            result = watch(state, env, now)
        except Exception as error:  # kept where `status` shows it; nothing started and the next tick tries again
            state["last_error"] = f"{stamp()} {error!r}"
            save(state, path)
            raise
        if result.startswith("resumed,"):
            state.pop("last_error", None)
        save(state, path)
    return result


def hook(raw: str, env: Env = REAL, path: Path = STATE) -> str:
    """One hook event. Returns what the hook prints."""
    data = json.loads(raw or "{}")
    event = data.get("hook_event_name")
    peek = load(path)
    if event == "Stop" and peek.get("active") and peek.get("session_id") == data.get("session_id"):
        env = snapshot(env)
    elif event == "UserPromptSubmit" and START.match(str(data.get("prompt") or "")):
        installed = env.task_installed()
        env = replace(env, task_installed=lambda: installed)
    with locked(path):
        return handle_event(event, data, env, path)


def handle_event(event: str | None, data: dict, env: Env, path: Path) -> str:
    state = load(path)
    before = json.dumps(state, sort_keys=True)
    output = ""
    if event == "UserPromptSubmit":
        note = on_prompt(state, data, env)
        if note:
            output = json.dumps({"hookSpecificOutput": {"hookEventName": event, "additionalContext": note}})
    elif event == "SessionStart":
        note = on_session_start(state, data)
        if note:
            output = json.dumps({"hookSpecificOutput": {"hookEventName": event, "additionalContext": note}})
    elif event == "Stop":
        reason = on_stop(state, data, env)
        if reason:
            output = json.dumps({"decision": "block", "reason": reason})
        elif state.get("status") in ("drained", "stalled") and json.dumps(state, sort_keys=True) != before:
            output = json.dumps({"systemMessage": f"Run guard: run {state['status']}, {state.get('why')}."})
    elif event == "SessionEnd":
        on_session_end(state, data)
    elif event == "PostToolUse":
        on_cron_created(state, data)
    elif event == "StopFailure":
        on_stop_failure(state, data)
    if json.dumps(state, sort_keys=True) != before:
        save(state, path)
        log(f"{event}: {state.get('status')} {state.get('why', '')}".rstrip(), path)
    return output
