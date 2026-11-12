"""Keeps an unattended `process plan` run going until the plan says it is done.

A run starts only when the operator starts it (operator decision 2026-11-12): the `process plan` prompt, or the
launcher (scripts/start-unattended-run.ps1). While its session lives in its open window, two things keep it working:

- The session ends its turn: the Stop hook sends it back while runnable rows remain.
- The session sits idle (an API error, a usage limit, a yield): a CronCreate tick in that session wakes it.

A session that dies ends the run: a crash, a closed window and a reboot are all the end of it. Nothing starts or
resumes a session, here or anywhere: there is no scheduled task, no watchdog and no restart loop. A run whose
session is gone is recorded as ended the next time anything looks (`record_gone`), and `status` says so.

A review is waited for, never fought. While one is in flight (scripts/review-dispatch.py leaves a marker under
build/review-in-flight/ for as long as its reviewer runs) the Stop hook lets the turn end: a review runs alone, and
its end wakes the session that started it.

Only the operator, the plan or the session's death ends a run: an operator stop, a normal exit, no runnable rows
left, a recorded halt, or the session gone. Stalling (no commit and no change to the tree across many attempts)
also ends it, so a stuck run cannot spend without limit. Fails open: a broken guard must never wedge a session.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
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
CRON = "7,22,37,52 * * * *"

MAX_IDLE_BLOCKS = 5  # sends back in a row with nothing changed, before the turn may end
MAX_YIELDS = 3  # those yields in a row with nothing changed, before the run is called stalled
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
    process_alive: Callable[[dict], bool]  # a recorded {"pid", "started"} is still that process
    reviewing: Callable[[], bool] = lambda: False
    end: Callable[[int], None] = lambda pid: None  # end a session's process tree
    contain: Callable[[str], str | None] = lambda session: None  # tie what a session starts to its life; why not, or None


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
    """Every change to the state goes through here, held across load to save, so one event cannot undo another's stop."""
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
    # The same admission a launcher's session passes (`start`), so a prompt typed in another session cannot take a
    # run a launcher has reserved or a review is reading. The operator typed this in an open session, so other open
    # sessions are theirs to judge.
    refused = admission_refusal(state, session, env, launcher=None, open_ok=True, own_ok=True)
    if refused:
        return f"The run was not taken: {refused}. Stop and say so."
    if not state.get("active"):
        state.clear()
        state.update(active=True, status="active", started=stamp(), changed_at=time.time())
    state["session_id"] = session
    note = heartbeat_note()
    # Closing a run's window ends everything the run started. A launcher's session is already inside the launcher's
    # job object (run_session); a session the operator typed this into is put in one of its own here, once.
    held = state.get("launcher")
    if session and state.get("contained") != session and not (held and env.process_alive(held)):
        failed = env.contain(session)
        if failed:
            note += f" Say this to the operator once: what this session starts could not be tied to its window ({failed}), so closing the window may leave a build or a review running."
        else:
            state["contained"] = session
    return note


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


def start(state: dict, session: str, env: Env, launcher: dict | None = None, *, open_ok: bool = False) -> None:
    """Switch the run on for `session`, or refuse with the reason. This is the one admission for a session that is
    about to write, taken under the state lock, so two starts cannot both pass it.

    `launcher` is the operator's launcher that is about to start the session, as {"pid", "started"}: it holds the
    run from here until the session exists, and says so itself when the session ends (`session_ended`). `open_ok`
    is the operator, at the keyboard, accepting the other sessions open in this clone."""
    refused = admission_refusal(state, session, env, launcher, open_ok)
    if refused:
        raise ValueError(refused)
    if not state.get("active"):
        state.clear()
        state.update(active=True, status="active", started=stamp(), changed_at=time.time())
    state["session_id"] = session
    if launcher:
        state["launcher"] = launcher
    else:
        state.pop("launcher", None)


def admission_refusal(state: dict, session: str | None, env: Env, launcher: dict | None, open_ok: bool, own_ok: bool = False) -> str | None:
    """Why `session` may not take the run, or None. The one statement of who may write, used by `start` (a launcher's
    session) and by the `process plan` prompt. `own_ok` lets the run's own session say `process plan` again."""
    owner = state.get("session_id")
    if own_ok and state.get("active") and owner == session:
        return None
    if state.get("active") and owner not in (None, session) and env.alive(owner):
        return f"session {owner} owns the active run and is alive; never run two writers on one tree"
    held = state.get("launcher")
    if state.get("active") and held and held != launcher and env.process_alive(held):
        return f"a launcher (process {held.get('pid')}) holds this run for session {owner}; never run two writers on one tree"
    if env.reviewing():
        return "a review is in flight and a review runs alone; start again when it has returned"
    others = [s for s in env.live_here() if s != session]
    if others and not open_ok:
        return f"Claude Code session(s) already open in this clone: {', '.join(others)}; never run two writers on one tree"
    return None


def on_session_end(state: dict, data: dict) -> None:
    if state.get("active") and state.get("session_id") == data.get("session_id") and data.get("reason") in USER_EXITS:
        end_run(state, "stopped", f"operator ended the session ({data.get('reason')})")


GONE = "its session is gone (a crash, a closed window or a reboot); nothing resumes it: start the run again yourself"


def record_gone(state: dict, env: Env) -> bool:
    """A run whose session is gone is over, and is recorded as ended: nothing starts another session for it. Left
    alone while its launcher lives, which is either still starting the session (it is not in Claude Code's records
    yet) or about to say itself how it ended. Not knowing who is alive raises, and ends nothing."""
    if not state.get("active"):
        return False
    owner, held = state.get("session_id"), state.get("launcher")
    if (owner and env.alive(owner)) or (held and env.process_alive(held)):
        return False
    end_run(state, "ended", GONE)
    return True


def session_ended(state: dict, session: str, why: str) -> None:
    """The launcher's own word that the session it started has ended. A run the session, the plan or the operator
    already ended keeps that ending; one still active ends here, and the launcher starts no other session."""
    if state.get("active") and state.get("session_id") == session:
        end_run(state, "ended", why)


def end_sessions(state: dict, env: Env, process: Callable[[str | None], int | None] | None = None) -> list[int]:
    """End the session writing for this run. For a stop given from outside the session, which has no other way to
    reach it: a halted guard stops sending the session back, but a session with a goal set goes on working by
    itself. A session that is not in Claude Code's records (another runner's) is ended through the launcher that
    holds it, window and all. Returns the processes ended."""
    pid = (process or owner_process)(state.get("session_id"))
    held = state.get("launcher")
    if pid is None and held and env.process_alive(held):
        pid = int(held["pid"])
    if pid is None:
        return []
    env.end(pid)
    return [pid]


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

    A record that cannot be judged raises, so no run is called ended on it: not knowing is not the same as dead.
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


def real_process_alive(record: dict) -> bool:
    started = process_started(int(record.get("pid", 0)))
    return started is not None and started == record.get("started")


# The launcher signs its session in with the one-year token (claude setup-token) from 1Password, and leaves a copy
# only this Windows account on this machine can read (operator decision 2026-11-10), for a start at which 1Password
# cannot be read: DPAPI encrypts it with a key Windows derives from the account, and 1Password stays the source of
# truth, asked first. scripts/start-unattended-run.ps1 reads the cache back through .NET's ProtectedData.
TOKEN_SHAPE = re.compile(r"sk-ant-oat[0-9]{2}-[A-Za-z0-9_-]{40,}")
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
    """Keep the token for a later start, encrypted for this account. A value not shaped like the token is refused."""
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
        return None  # no cache, another account's cache, or not Windows


REVIEW_LOCK_AT = 1 << 30  # where a running dispatcher holds its lock: review-dispatch.py LOCK_AT, past the content


REVIEW_SETTLE = 5  # seconds a new marker is taken as running unprobed, while its dispatcher takes its lock


def review_running(marker: Path) -> bool:
    """A running dispatcher holds a lock on its marker and the operating system drops it when that process ends, so
    a lock this can take means nobody is running that review. A marker that has gone is a review that ended. One
    just made is not probed: its dispatcher is between creating it and locking it, and a probe there would take the
    lock from under it. One that cannot be opened is taken as running: waiting on a review that is not there costs a
    little time, working beside one that is there costs the review."""
    try:
        if time.time() - marker.stat().st_mtime < REVIEW_SETTLE:
            return True
    except FileNotFoundError:
        return False
    except OSError:
        return True
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
    except OSError:
        return True  # it exists and cannot be opened: see above
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


def owner_quiet_minutes(state: dict, now: float | None = None, projects: Path | None = None) -> float | None:
    """Minutes since the run's session last wrote to its transcript, which Claude Code appends to on every message and
    tool call. `status` shows it, so the operator can tell a working session from one waiting (on a usage limit, a
    review, its heartbeat); nothing acts on it. None when the session has no transcript yet."""
    if not state.get("session_id"):
        return None
    projects = projects or Path(os.environ.get("CLAUDE_CONFIG_DIR") or Path.home() / ".claude") / "projects"
    written = [p.stat().st_mtime for p in projects.glob(f"*/{state['session_id']}.jsonl")]
    if not written:
        return None
    return round(((time.time() if now is None else now) - max(written)) / 60, 1)


def owner_process(session: str | None) -> int | None:
    for record in session_records():
        if session and record.get("sessionId") == session:
            return int(record["pid"])
    return None


def end_tree(pid: int) -> None:
    if os.name == "nt":
        subprocess.run(["taskkill", "/T", "/F", "/PID", str(pid)], capture_output=True, **hidden())
    else:
        os.kill(pid, 9)


def real_contain(session: str) -> str | None:
    """Put the session's process in a job object that ends what it starts with it (scripts/lib/win_job.py). Returns
    why that could not be done, or None."""
    import win_job

    try:
        pid = owner_process(session)
        if pid is None:
            return "its process is not in Claude Code's records"
        win_job.end_children_with(pid)
    except (OSError, ValueError, KeyError) as error:
        return str(error)
    return None


def real_reviewing() -> bool:
    return bool(reviews_in_flight())


def run_session(command: list[str]) -> int:
    """Run the session's CLI to its end in this console, and return its exit code. This process joins a job object
    first (scripts/lib/win_job.py), so everything the session starts is inside it: when the session ends, or the
    window is closed and takes this process with it, Windows ends whatever is left of that tree. Nothing a run
    started outlives its window."""
    import signal

    import win_job

    win_job.end_children_with_this_process()
    signal.signal(signal.SIGINT, signal.SIG_IGN)  # Ctrl+C is the session's to read, never this wrapper's to die of
    return subprocess.call(command)


REAL = Env(real_rows, real_signature, real_alive, real_live_here, real_process_alive, real_reviewing, end_tree, real_contain)


def health(state: dict, env: Env = REAL, now: float | None = None) -> dict:
    """What `status` adds to the state: what keeps a live session working, and who is in the tree."""
    now = time.time() if now is None else now
    return {
        "heartbeat_current": heartbeat_current(state, now),
        "review_in_flight": env.reviewing(),
        "live_here": env.live_here(),  # every Claude Code session open in this clone, so a launcher can say who is writing
        "owner_quiet_minutes": owner_quiet_minutes(state, now),
        "launcher_alive": bool(state.get("launcher")) and env.process_alive(state["launcher"]),
    }


def look(env: Env = REAL, path: Path = STATE) -> dict:
    """The run's state for `status`, with a session that is gone recorded as ended first. Fails open: when the lock
    or the liveness of the session cannot be had, the state is returned as it stands and nothing is ended."""
    state = load(path)
    if not state.get("active"):
        return state
    try:
        with locked(path):
            state = load(path)
            if record_gone(state, env):
                save(state, path)
                log(f"status: {state.get('status')} {state.get('why', '')}".rstrip(), path)
    except (OSError, ValueError, KeyError):
        pass
    return state


def hook(raw: str, env: Env = REAL, path: Path = STATE) -> str:
    """One hook event. Returns what the hook prints."""
    data = json.loads(raw or "{}")
    event = data.get("hook_event_name")
    peek = load(path)
    if event == "Stop" and peek.get("active") and peek.get("session_id") == data.get("session_id"):
        env = snapshot(env)
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
