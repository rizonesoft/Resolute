"""The campaign run guard: its lifecycle commands and the driven
self-test for the Stop hook (D00 T04 §32, §34).

`.claude/hooks/campaign-stop.ps1` blocks the campaign session's end of
turn while its run is open. The guard file it reads is written and
deleted only through this module (D00 T04 §34):

    python scripts/campaign_guard.py acquire --session S --phase N --run-file F --cron-id J [--handover REASON]
    python scripts/campaign_guard.py end --session S --reason closeout|park|plan-done|operator-stop|escalation
    python scripts/campaign_guard.py hook-error [--session S]
    python scripts/campaign_guard.py --self-test

`acquire` creates the guard exclusively; the owning session may re-point
it (a new phase or job) by compare-and-swap on `session_id`, and another
session is refused a live guard unless the operator hands it over.
`end` checks the end path's marker in the run file (a `## Closeout`
heading, a column-0 `PARKED` line, `0 runnable now`, or nothing for an
operator stop), then deletes the guard file and the state file and
names the heartbeat job still to `CronDelete`. `hook-error` prints and
clears an error the hook recorded, for the heartbeat to report. Every
command takes `--root` to act on a fixture workspace instead of this
repository.

The self-test drives the real hook with Stop payloads against a
throwaway workspace (a git repository, a guard file, a run file, and a
fake `scripts/todo-graph.py` whose runnable count the test controls) and
asserts every allow and block case, the stall breaker, and the
lifecycle commands.
"""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
HOOK = os.path.normpath(os.path.join(HERE, "..", ".claude", "hooks", "campaign-stop.ps1"))
SETTINGS = os.path.normpath(os.path.join(HERE, "..", ".claude", "settings.json"))
SESSION = "11111111-2222-3333-4444-555555555555"
RUN_FILE = "docs/phase-runs/2099-01-01-phase-0.md"


REPO = os.path.normpath(os.path.join(HERE, ".."))
END_REASONS = ("closeout", "park", "plan-done", "operator-stop", "escalation")


class GuardError(ValueError):
    """A refusal naming why the guard was not changed."""


def _paths(root: str) -> tuple[str, str]:
    return (os.path.join(root, "build", "claude-campaign-guard.json"),
            os.path.join(root, "build", "claude-campaign-state.json"))


LOCK_WAIT = 10.0


class _Lock:
    """An interprocess lock on the guard: every change (acquire,
    re-point, handover, end) holds it, so a read-then-replace can never
    interleave with another session's change (D00 T04 §34 independent
    review). It is an operating-system lock on an open handle
    (`msvcrt.locking` on Windows, `flock` elsewhere): it never expires
    while its holder lives, and the OS releases it when the holder
    closes the handle or dies, so no age test can break a live holder's
    lock (panel round 1). The lock file itself is never deleted."""

    def __init__(self, root: str, wait: float = LOCK_WAIT):
        self.path = os.path.join(root, "build", "claude-campaign-guard.lock")
        self.wait = wait
        self.fd = None

    def _try(self) -> bool:
        if os.name == "nt":
            import msvcrt
            try:
                os.lseek(self.fd, 0, os.SEEK_SET)
                msvcrt.locking(self.fd, msvcrt.LK_NBLCK, 1)
                return True
            except OSError:
                return False
        import fcntl
        try:
            fcntl.flock(self.fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
            return True
        except OSError:
            return False

    def __enter__(self):
        import time
        os.makedirs(os.path.dirname(self.path), exist_ok=True)
        self.fd = os.open(self.path, os.O_RDWR | os.O_CREAT, 0o644)
        deadline = time.monotonic() + self.wait
        while not self._try():
            if time.monotonic() >= deadline:
                os.close(self.fd)
                self.fd = None
                raise GuardError(f"the guard is locked by another change ({self.path}); retry")
            time.sleep(0.05)
        return self

    def __exit__(self, *exc):
        if self.fd is not None:
            try:
                if os.name == "nt":
                    import msvcrt
                    os.lseek(self.fd, 0, os.SEEK_SET)
                    msvcrt.locking(self.fd, msvcrt.LK_UNLCK, 1)
                else:
                    import fcntl
                    fcntl.flock(self.fd, fcntl.LOCK_UN)
            finally:
                os.close(self.fd)
                self.fd = None
        return False


def read_guard(root: str) -> dict | None:
    guard, _ = _paths(root)
    try:
        with open(guard, encoding="utf-8-sig") as fh:
            doc = json.load(fh)
    except FileNotFoundError:
        return None
    except (OSError, ValueError) as exc:
        raise GuardError(f"the guard file {guard} does not parse: {exc}")
    if not isinstance(doc, dict):
        raise GuardError(f"the guard file {guard} is not an object")
    return doc


def acquire(root: str, session: str, phase: int, run_file: str, cron_id: str,
            handover: str | None = None) -> str:
    """Write the guard for `session`. A new guard is created exclusively
    (O_EXCL), so two sessions racing to start a run cannot both win; the
    owner re-points its own guard by compare-and-swap on `session_id`; a
    live guard owned by another session is refused unless the operator
    hands it over, and the handover is recorded in the guard."""
    if not session or not run_file or not cron_id:
        raise GuardError("acquire needs --session, --run-file, and --cron-id")
    if os.path.isabs(run_file) or ".." in run_file.replace("\\", "/").split("/"):
        raise GuardError(f"run file {run_file!r} must be a repo-relative path inside the workspace")
    with _Lock(root):
        return _acquire_locked(root, session, phase, run_file, cron_id, handover)


def _acquire_locked(root: str, session: str, phase: int, run_file: str, cron_id: str,
                    handover: str | None) -> str:
    guard, _ = _paths(root)
    os.makedirs(os.path.dirname(guard), exist_ok=True)
    doc = {"runner": "claude", "workspace": root.replace("\\", "/"), "phase": phase,
           "run_file": run_file, "session_id": session, "cron_id": cron_id}
    data = json.dumps(doc, indent=2).encode("utf-8")
    try:
        fd = os.open(guard, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o644)
    except FileExistsError:
        current = read_guard(root) or {}
        owner = str(current.get("session_id", ""))
        if owner != session:
            if not handover:
                raise GuardError(f"the guard is live for session {owner or '<none>'}; "
                                 f"refusing to take it without an operator handover (--handover REASON)")
            doc["handover_from"] = owner
            doc["handover_reason"] = handover
        # The lock is held from the read above through this replace, so no
        # other change can land in between.
        tmp = guard + f".{os.getpid()}.tmp"
        with open(tmp, "wb") as fh:
            fh.write(json.dumps(doc, indent=2).encode("utf-8"))
        os.replace(tmp, guard)
        what = "handed over" if owner != session else "re-pointed"
        return f"acquire: guard {what} for session {session} (phase {phase}, {run_file}, job {cron_id})"
    with os.fdopen(fd, "wb") as fh:
        fh.write(data)
    return f"acquire: guard created for session {session} (phase {phase}, {run_file}, job {cron_id})"


def _ready_count(root: str) -> int | None:
    try:
        proc = subprocess.run([sys.executable, os.path.join(root, "scripts", "todo-graph.py"), "query", "ready"],
                              capture_output=True, text=True, encoding="utf-8", errors="replace", cwd=root,
                              timeout=300)
    except (OSError, subprocess.TimeoutExpired):
        return None
    m = re.findall(r"(\d+) runnable now", proc.stdout)
    return int(m[-1]) if m else None


def end(root: str, session: str, reason: str) -> str:
    """End the run on one of its end paths: check the path's marker, then
    delete the guard file and the state file. The heartbeat job lives in
    the session, not on disk, so the caller deletes it (`CronDelete`) and
    the returned line names it."""
    if reason not in END_REASONS:
        raise GuardError(f"reason {reason!r} is not one of {', '.join(END_REASONS)}")
    if not session:
        raise GuardError("end needs --session (the session that owns the guard)")
    # The plan query runs before the lock, so no subprocess is ever held
    # under it (panel round 1).
    ready = _ready_count(root) if reason == "plan-done" else None
    with _Lock(root):
        return _end_locked(root, session, reason, ready)


def _end_locked(root: str, session: str, reason: str, ready: int | None) -> str:
    guard_path, state_path = _paths(root)
    guard = read_guard(root)
    if guard is None:
        raise GuardError("no guard file: the run is already over")
    if str(guard.get("session_id", "")) != session:
        raise GuardError(f"the guard belongs to session {guard.get('session_id')}, not {session}")
    run_rel = str(guard.get("run_file", ""))
    try:
        with open(os.path.join(root, run_rel), encoding="utf-8") as fh:
            text = fh.read()
    except OSError:
        text = ""
    if reason == "closeout" and not re.search(r"(?m)^## Closeout\b", text):
        raise GuardError(f"closeout needs a '## Closeout' heading in {run_rel}")
    if reason == "park" and not re.search(r"(?m)^PARKED\b", text):
        raise GuardError(f"park needs a column-0 PARKED line in {run_rel}")
    if reason == "escalation" and not re.search(r"(?m)^PARKED\b.*\bescalation:", text):
        raise GuardError(f"escalation needs a column-0 'PARKED <UTC> escalation: <cause>' line in {run_rel}")
    if reason == "plan-done" and ready != 0:
        raise GuardError(f"plan-done needs '0 runnable now'; query ready reads {ready}")
    for path in (guard_path, state_path):
        try:
            os.unlink(path)
        except FileNotFoundError:
            pass
    left = [p for p in (guard_path, state_path) if os.path.exists(p)]
    if left:
        raise GuardError(f"could not delete {', '.join(left)}")
    return (f"end: {reason}: guard and state deleted; CronDelete {guard.get('cron_id')} now "
            f"(the heartbeat job), then confirm it is gone with CronList")


def hook_error(root: str, session: str | None = None) -> str:
    """Print and clear the error the hook recorded, if any. With a
    session, a guard owned by another session is refused before anything
    is read or cleared (panel round 1: a former owner's heartbeat must
    not consume the current owner's failure record)."""
    if session:
        guard = read_guard(root)
        if guard is not None and str(guard.get("session_id", "")) != session:
            raise GuardError(f"the guard belongs to session {guard.get('session_id')}, not {session}")
    _, state_path = _paths(root)
    try:
        with open(state_path, encoding="utf-8-sig") as fh:
            state = json.load(fh)
    except (OSError, ValueError):
        return ""
    err = state.pop("hook_error", None)
    at = state.pop("hook_error_at", None)
    if not err:
        return ""
    tmp = state_path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as fh:
        json.dump(state, fh)
    os.replace(tmp, state_path)
    return f"campaign-stop hook failed at {at}: {err}"


def _powershell() -> str | None:
    for name in ("powershell.exe", "powershell", "pwsh"):
        found = shutil.which(name)
        if found:
            return found
    return None


def run_hook(root: str, session: str) -> tuple[int, dict | None, str]:
    """Feed the hook one Stop payload; return (exit, parsed stdout JSON or
    None when it allowed silently, stderr)."""
    shell = _powershell()
    env = dict(os.environ, CLAUDE_PROJECT_DIR=root)
    payload = json.dumps({"session_id": session, "cwd": root, "hook_event_name": "Stop"})
    proc = subprocess.run([shell, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", HOOK],
                          input=payload, capture_output=True, text=True, encoding="utf-8",
                          errors="replace", env=env, timeout=120)
    out = proc.stdout.strip()
    try:
        parsed = json.loads(out) if out else None
    except ValueError:
        parsed = {"unparsed": out}
    return proc.returncode, parsed, proc.stderr


def configured_command() -> str | None:
    """The Stop hook command exactly as `.claude/settings.json` wires it."""
    try:
        with open(SETTINGS, encoding="utf-8") as fh:
            doc = json.load(fh)
        return doc["hooks"]["Stop"][0]["hooks"][0]["command"]
    except (OSError, ValueError, KeyError, IndexError, TypeError):
        return None


def run_configured(root: str, session: str, shell: list[str]) -> tuple[int, dict | None, str]:
    """Run the configured command the way Claude Code would, through
    `shell` (Git Bash or PowerShell), with CLAUDE_PROJECT_DIR pointing at
    the fixture (§32 independent review: a `$VAR` path that one shell
    does not expand never launches the hook)."""
    env = dict(os.environ, CLAUDE_PROJECT_DIR=root)
    payload = json.dumps({"session_id": session, "cwd": root, "hook_event_name": "Stop"})
    proc = subprocess.run([*shell, configured_command()], input=payload, capture_output=True,
                          text=True, encoding="utf-8", errors="replace", env=env, cwd=root, timeout=120)
    out = proc.stdout.strip()
    try:
        parsed = json.loads(out) if out else None
    except ValueError:
        parsed = {"unparsed": out}
    return proc.returncode, parsed, proc.stderr


def _workspace(tmpd: str) -> str:
    root = os.path.join(tmpd, "ws")
    os.makedirs(os.path.join(root, "scripts"))
    os.makedirs(os.path.join(root, "build"))
    os.makedirs(os.path.join(root, "docs", "phase-runs"))
    os.makedirs(os.path.join(root, ".claude", "hooks"))
    shutil.copyfile(HOOK, os.path.join(root, ".claude", "hooks", "campaign-stop.ps1"))
    with open(os.path.join(root, ".gitignore"), "w", encoding="utf-8") as fh:
        fh.write("build/\n")
    # The fake graph prints the runnable count the test writes to ready.txt.
    with open(os.path.join(root, "scripts", "todo-graph.py"), "w", encoding="utf-8") as fh:
        fh.write("import os\n"
                 "n = open(os.path.join(os.path.dirname(__file__), 'ready.txt')).read().strip()\n"
                 "if n != '0':\n"
                 "    print('00-workspace/TODO-04-self-correction.md §31  Red CI repaired, not waited on')\n"
                 "print()\n"
                 "print(f'{n} runnable now, 0 runnable elsewhere')\n")
    _set_ready(root, 3)
    with open(os.path.join(root, RUN_FILE), "w", encoding="utf-8") as fh:
        fh.write("# Phase run: Phase 0\n\n## Sections log\n")
    for args in (["init", "-q"], ["config", "user.email", "t@t"], ["config", "user.name", "t"],
                 ["config", "commit.gpgsign", "false"], ["add", "-A"], ["commit", "-qm", "seed"]):
        subprocess.run(["git", *args], cwd=root, capture_output=True, check=True)
    return root


def _set_ready(root: str, n: int) -> None:
    with open(os.path.join(root, "scripts", "ready.txt"), "w", encoding="utf-8") as fh:
        fh.write(str(n))


def _guard(root: str, session: str = SESSION, run_file: str = RUN_FILE) -> None:
    with open(os.path.join(root, "build", "claude-campaign-guard.json"), "w", encoding="utf-8") as fh:
        json.dump({"runner": "claude", "workspace": root, "phase": 0, "run_file": run_file,
                   "session_id": session, "cron_id": "job-1"}, fh)


def _state(root: str) -> dict:
    path = os.path.join(root, "build", "claude-campaign-state.json")
    if not os.path.exists(path):
        return {}
    with open(path, encoding="utf-8-sig") as fh:
        return json.load(fh)


def _self_test() -> int:
    passed = failed = 0

    def check(name: str, ok: bool, detail: str = "") -> None:
        nonlocal passed, failed
        if ok:
            passed += 1
        else:
            failed += 1
            print(f"FAIL {name} {detail}")

    if _powershell() is None:
        print("campaign_guard self-test: SKIP (no PowerShell on this host)")
        return 0
    if not os.path.isfile(HOOK):
        print(f"FAIL hook-present {HOOK}")
        return 1
    with tempfile.TemporaryDirectory(prefix="campaign-guard-") as tmpd:
        root = _workspace(tmpd)

        code, out, err = run_hook(root, SESSION)
        check("allow-without-guard", code == 0 and out is None, f"{code} {out} {err}")

        _guard(root)
        code, out, err = run_hook(root, "99999999-0000-0000-0000-000000000000")
        check("allow-another-session", code == 0 and out is None, f"{code} {out} {err}")

        # The configured command, not just the script: through PowerShell
        # (a Windows host without Git Bash) and through Git Bash.
        shells = [("powershell", [_powershell(), "-NoProfile", "-Command"])]
        # Git Bash by path: the `bash` on PATH can be WSL's, which runs a
        # different interpreter against the wrong tree.
        bash = os.path.join(os.environ.get("ProgramFiles", "C:/Program Files"), "Git", "bin", "bash.exe")
        if os.path.isfile(bash):
            shells.append(("bash", [bash, "-c"]))
        check("settings-wire-the-stop-hook", configured_command() is not None
              and "campaign-stop.ps1" in (configured_command() or ""), str(configured_command()))
        for label, shell in shells:
            state_path = os.path.join(root, "build", "claude-campaign-state.json")
            if os.path.exists(state_path):
                os.remove(state_path)
            code, out, err = run_configured(root, SESSION, shell)
            check(f"configured-command-launches-through-{label}",
                  isinstance(out, dict) and out.get("decision") == "block", f"{code} {out} {err[:300]}")
        state_path = os.path.join(root, "build", "claude-campaign-state.json")
        if os.path.exists(state_path):
            os.remove(state_path)

        code, out, err = run_hook(root, SESSION)
        check("block-open-run-naming-next-row",
              code == 0 and isinstance(out, dict) and out.get("decision") == "block"
              and "Next ready row: 00-workspace/TODO-04-self-correction.md §31" in out.get("reason", "")
              and "repair it: D00 T04 section 31" in out.get("reason", ""), f"{code} {out} {err}")
        check("the-escalation-instruction-names-the-session",
              isinstance(out, dict) and f"end --session {SESSION} --reason escalation" in out.get("reason", ""),
              str(out))

        # Stall breaker: blocks 2 and 3 with no tree change, then the trip.
        run_hook(root, SESSION)
        code, out, _ = run_hook(root, SESSION)
        check("third-block-still-blocks", isinstance(out, dict) and out.get("decision") == "block", str(out))
        code, out, err = run_hook(root, SESSION)
        st = _state(root)
        check("breaker-trips-after-three-unchanged-blocks",
              code == 0 and out is None and st.get("trips") == 1 and st.get("stalled") is True
              and "stall breaker tripped (1)" in err, f"{code} {out} {st} {err}")
        with open(os.path.join(root, "progress.txt"), "w", encoding="utf-8") as fh:
            fh.write("moved\n")
        code, out, _ = run_hook(root, SESSION)
        st = _state(root)
        check("progress-resets-the-breaker",
              isinstance(out, dict) and out.get("decision") == "block"
              and st.get("blocks") == 1 and st.get("trips") == 0, f"{out} {st}")

        _set_ready(root, 0)
        code, out, _ = run_hook(root, SESSION)
        check("allow-when-nothing-is-runnable", code == 0 and out is None, str(out))
        _set_ready(root, 3)

        run_path = os.path.join(root, RUN_FILE)
        with open(run_path, "a", encoding="utf-8") as fh:
            fh.write("\nPARKED 2099-01-01T00:00:00Z every leftover row is blocked\n")
        code, out, _ = run_hook(root, SESSION)
        check("allow-when-parked", code == 0 and out is None, str(out))
        with open(run_path, "w", encoding="utf-8") as fh:
            fh.write("# Phase run: Phase 0\n\n## Closeout\n\nshipped\n")
        code, out, _ = run_hook(root, SESSION)
        check("allow-after-closeout", code == 0 and out is None, str(out))

        with open(run_path, "w", encoding="utf-8") as fh:
            fh.write("# Phase run: Phase 0\n\nThe word PARKED mid-line is not a marker\n")
        code, out, _ = run_hook(root, SESSION)
        check("mid-line-parked-still-blocks", isinstance(out, dict) and out.get("decision") == "block", str(out))

        _guard(root, run_file="../outside.md")
        code, out, _ = run_hook(root, SESSION)
        check("allow-when-run-file-escapes-the-workspace", code == 0 and out is None, str(out))

        with open(os.path.join(root, "build", "claude-campaign-guard.json"), "w", encoding="utf-8") as fh:
            fh.write("{not json")
        code, out, err = run_hook(root, SESSION)
        check("fail-open-on-a-bad-guard", code == 0 and out is None and "campaign-stop:" in err, f"{code} {out} {err}")
        # D00 T04 §34: the failure is recorded for the heartbeat, then cleared.
        st = _state(root)
        check("a-thrown-error-is-recorded", bool(st.get("hook_error")) and bool(st.get("hook_error_at")), str(st))
        _guard(root, session="77777777-0000-0000-0000-000000000000")
        with open(os.path.join(root, "build", "claude-campaign-state.json"), "w", encoding="utf-8") as fh:
            json.dump({"hook_error": "boom", "hook_error_at": "2099-01-01T00:00:00Z"}, fh)
        try:
            hook_error(root, SESSION)
            check("hook-error-refuses-another-sessions-state", False)
        except GuardError as exc:
            check("hook-error-refuses-another-sessions-state",
                  "belongs to session" in str(exc) and _state(root).get("hook_error") == "boom", str(exc))
        line = hook_error(root)
        check("hook-error-reports-then-clears",
              line.startswith("campaign-stop hook failed at ") and "hook_error" not in _state(root)
              and hook_error(root) == "", f"{line!r} {_state(root)}")

        # D00 T04 §34: the fingerprint sees untracked content and ignores
        # the run file's bookkeeping.
        os.remove(os.path.join(root, "build", "claude-campaign-guard.json"))
        os.remove(os.path.join(root, "build", "claude-campaign-state.json"))
        with open(run_path, "w", encoding="utf-8") as fh:
            fh.write("# Phase run: Phase 0\n\n## Critical events\n\n- started\n\n## Sections\n")
        _guard(root)
        for _ in range(3):
            run_hook(root, SESSION)
        with open(os.path.join(root, "progress.txt"), "a", encoding="utf-8") as fh:
            fh.write("an edit to an untracked file\n")
        code, out, _ = run_hook(root, SESSION)
        st = _state(root)
        check("untracked-content-edit-resets-the-breaker",
              isinstance(out, dict) and out.get("decision") == "block" and st.get("blocks") == 1, f"{out} {st}")
        with open(os.path.join(root, "caf\u00e9.txt"), "w", encoding="utf-8") as fh:
            fh.write("work under a non-ASCII name\n")
        for _ in range(4):
            run_hook(root, SESSION)
        with open(os.path.join(root, "caf\u00e9.txt"), "a", encoding="utf-8") as fh:
            fh.write("an edit only its content hash can see\n")
        code, out, _ = run_hook(root, SESSION)
        check("a-non-ascii-untracked-edit-is-progress",
              isinstance(out, dict) and out.get("decision") == "block" and _state(root).get("blocks") == 1
              and _state(root).get("trips") == 0,
              f"{out} {_state(root)}")
        # Past the content-hash bound every path still counts: a new file
        # beyond the 500th is progress (D00 T04 §34 independent review).
        many = os.path.join(root, "many")
        os.makedirs(many)
        for i in range(505):
            with open(os.path.join(many, f"f{i:04d}.txt"), "w", encoding="utf-8") as fh:
                fh.write("x\n")
        for _ in range(4):
            run_hook(root, SESSION)
        with open(os.path.join(many, "zzzz-new.txt"), "w", encoding="utf-8") as fh:
            fh.write("new work past the bound\n")
        code, out, _ = run_hook(root, SESSION)
        check("a-file-past-the-hash-bound-is-progress",
              isinstance(out, dict) and out.get("decision") == "block" and _state(root).get("trips") == 0,
              f"{out} {_state(root)}")
        shutil.rmtree(many)
        run_hook(root, SESSION)
        for _ in range(2):
            run_hook(root, SESSION)
        text = open(run_path, encoding="utf-8").read().replace(
            "- started\n", "- started\n- heartbeat fired, resumed\n")
        with open(run_path, "w", encoding="utf-8") as fh:
            fh.write(text)
        code, out, err = run_hook(root, SESSION)
        st = _state(root)
        check("a-bookkeeping-line-alone-still-trips-the-breaker",
              code == 0 and out is None and st.get("trips") == 1 and "stall breaker tripped" in err,
              f"{code} {out} {st} {err}")
        with open(run_path, "a", encoding="utf-8") as fh:
            fh.write("\n### D90 T01 §1 -- shipped\n")
        code, out, _ = run_hook(root, SESSION)
        check("a-sections-entry-is-progress", isinstance(out, dict) and out.get("decision") == "block", str(out))

        # D00 T04 §34: an escalation parks and ends the run before its report.
        with open(run_path, "a", encoding="utf-8") as fh:
            fh.write("\nPARKED 2099-01-01T00:00:00Z escalation: repair bound exhausted on D90 T01 §1\n")
        code, out, _ = run_hook(root, SESSION)
        check("the-escalation-report-turn-ends", code == 0 and out is None, str(out))

        # D00 T04 §34: exclusive acquisition and every end path.
        os.remove(os.path.join(root, "build", "claude-campaign-guard.json"))
        msg = acquire(root, SESSION, 0, RUN_FILE, "job-1")
        check("acquire-creates-the-guard", msg.startswith("acquire: guard created"), msg)
        try:
            acquire(root, "22222222-0000-0000-0000-000000000000", 0, RUN_FILE, "job-2")
            check("acquire-refuses-a-second-session", False, "took a live guard")
        except GuardError as exc:
            check("acquire-refuses-a-second-session", "without an operator handover" in str(exc)
                  and read_guard(root)["session_id"] == SESSION, str(exc))
        msg = acquire(root, SESSION, 1, "docs/phase-runs/2099-01-01-phase-1.md", "job-3")
        check("acquire-re-points-its-own-guard", "re-pointed" in msg and read_guard(root)["cron_id"] == "job-3", msg)
        msg = acquire(root, "22222222-0000-0000-0000-000000000000", 1, RUN_FILE, "job-4",
                      handover="operator resumed the run in a new session")
        g = read_guard(root)
        check("acquire-hands-over-with-a-reason", "handed over" in msg and g["handover_from"] == SESSION
              and g["session_id"].startswith("22222222"), f"{msg} {g}")
        # A live holder in another process: the change waits, then refuses.
        holder = subprocess.Popen(
            [sys.executable, "-c",
             "import sys, time; sys.path.insert(0, sys.argv[1]); import campaign_guard as cg\n"
             "with cg._Lock(sys.argv[2]):\n"
             "    print('held', flush=True); time.sleep(float(sys.argv[3]))",
             HERE, root, "3"], stdout=subprocess.PIPE, text=True)
        holder.stdout.readline()
        try:
            with _Lock(root, wait=0.3):
                pass
            check("a-held-lock-refuses-a-change", False, "entered a held lock")
        except GuardError as exc:
            check("a-held-lock-refuses-a-change", "locked by another change" in str(exc), str(exc))
        holder.wait()
        entered = False
        with _Lock(root, wait=2):
            entered = True
        check("the-lock-is-released-after-a-change", entered)
        # A holder that dies without releasing: the OS frees the lock, and
        # no age test was needed to break it.
        dead = subprocess.Popen(
            [sys.executable, "-c",
             "import os, sys; sys.path.insert(0, sys.argv[1]); import campaign_guard as cg\n"
             "lock = cg._Lock(sys.argv[2]); lock.__enter__(); print('held', flush=True); os._exit(0)",
             HERE, root], stdout=subprocess.PIPE, text=True)
        dead.stdout.readline()
        dead.wait()
        entered = False
        with _Lock(root, wait=2):
            entered = True
        check("a-dead-holder-releases-the-lock", entered)
        # Two sessions changing the guard at once: the lock serializes them,
        # and the guard ends owned by exactly the session that changed it last.
        import threading
        results: list = []

        def _take(sess: str) -> None:
            try:
                results.append(acquire(root, sess, 2, RUN_FILE, "job-7", handover="race drill"))
            except GuardError as exc:
                results.append(str(exc))
        threads = [threading.Thread(target=_take, args=(s,)) for s in
                   ("22222222-0000-0000-0000-000000000000", "55555555-0000-0000-0000-000000000000")]
        for th in threads:
            th.start()
        for th in threads:
            th.join()
        final = read_guard(root)
        check("concurrent-changes-serialize", len(results) == 2 and final is not None
              and final["session_id"] in ("22222222-0000-0000-0000-000000000000",
                                          "55555555-0000-0000-0000-000000000000")
              and all(r.startswith("acquire: guard") for r in results), f"{results} {final}")
        try:
            end(root, "", "operator-stop")
            check("end-refuses-without-a-session", False)
        except GuardError as exc:
            check("end-refuses-without-a-session", "needs --session" in str(exc), str(exc))
        try:
            acquire(root, SESSION, 0, "../outside.md", "job-5", handover="x")
            check("acquire-refuses-an-escaping-run-file", False)
        except GuardError as exc:
            check("acquire-refuses-an-escaping-run-file", "inside the workspace" in str(exc), str(exc))

        def _fresh(body: str, ready: int = 3) -> None:
            for f in _paths(root):
                if os.path.exists(f):
                    os.remove(f)
            with open(run_path, "w", encoding="utf-8") as fh:
                fh.write(body)
            _set_ready(root, ready)
            acquire(root, SESSION, 0, RUN_FILE, "job-9")
            run_hook(root, SESSION)  # leaves a state file behind

        for reason, body, ready in (("closeout", "# r\n\n## Closeout\n\nshipped\n", 3),
                                    ("park", "# r\n\nPARKED 2099-01-01T00:00:00Z leftovers blocked\n", 3),
                                    ("plan-done", "# r\n", 0),
                                    ("operator-stop", "# r\n", 3),
                                    ("escalation", "# r\n\nPARKED 2099-01-01T00:00:00Z escalation: gh down\n", 3)):
            _fresh(body, ready)
            msg = end(root, SESSION, reason)
            gone = not any(os.path.exists(f) for f in _paths(root))
            code, out, _ = run_hook(root, SESSION)
            check(f"end-{reason}-leaves-nothing-behind",
                  gone and "CronDelete job-9" in msg and code == 0 and out is None, f"{msg} {gone} {out}")
        _fresh("# r\n", 3)
        try:
            end(root, SESSION, "closeout")
            check("end-refuses-a-closeout-without-its-heading", False)
        except GuardError as exc:
            check("end-refuses-a-closeout-without-its-heading",
                  "needs a '## Closeout' heading" in str(exc) and read_guard(root) is not None, str(exc))
        try:
            end(root, "33333333-0000-0000-0000-000000000000", "operator-stop")
            check("end-refuses-another-session", False)
        except GuardError as exc:
            check("end-refuses-another-session", "belongs to session" in str(exc), str(exc))

    # D00 T04 §34: the runner's contract routes through these commands.
    plan_skill = os.path.normpath(os.path.join(HERE, "..", ".claude", "skills", "process-plan", "SKILL.md"))
    try:
        with open(plan_skill, encoding="utf-8") as fh:
            skill = fh.read()
    except OSError:
        skill = ""
    for pin, needle in (("skill-acquires-the-guard", "python scripts/campaign_guard.py acquire --session"),
                        ("skill-ends-through-end", "python scripts/campaign_guard.py end --session"),
                        ("skill-heartbeat-reports-hook-errors", "python scripts/campaign_guard.py hook-error"),
                        ("skill-refused-acquire-cancels-its-job", "A refused `acquire` means another session owns the run"),
                        ("skill-heartbeat-checks-ownership", "reply NOT THE OWNER"),
                        ("skill-heartbeat-owner-first",
                         "1. If build/claude-campaign-guard.json exists but its `session_id`")):
        check(pin, needle in skill, plan_skill)

    print(f"campaign_guard self-test: {passed + failed} cases, {failed} failed")
    return 1 if failed else 0


def _opts(argv: list[str]) -> dict:
    out: dict = {}
    i = 0
    while i < len(argv):
        if not argv[i].startswith("--") or i + 1 >= len(argv):
            raise GuardError(f"bad argument {argv[i]!r}")
        out[argv[i][2:].replace("-", "_")] = argv[i + 1]
        i += 2
    return out


def main(argv: list[str]) -> int:
    if argv == ["--self-test"]:
        return _self_test()
    if not argv:
        print(__doc__.split("\n\n")[1], file=sys.stderr)
        return 2
    try:
        opts = _opts(argv[1:])
        root = opts.pop("root", REPO)
        if argv[0] == "acquire":
            print(acquire(root, opts.get("session", ""), int(opts.get("phase", "0")),
                          opts.get("run_file", ""), opts.get("cron_id", ""), opts.get("handover")))
            return 0
        if argv[0] == "end":
            print(end(root, opts.get("session", ""), opts.get("reason", "")))
            return 0
        if argv[0] == "hook-error" and set(opts) <= {"session"}:
            line = hook_error(root, opts.get("session"))
            if line:
                print(line)
            return 0
    except (GuardError, ValueError) as exc:
        print(f"campaign_guard: {exc}", file=sys.stderr)
        return 1
    print(f"campaign_guard: unknown command {' '.join(argv)!r}; see the module docstring", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
