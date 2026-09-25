"""The campaign run guard: its lifecycle commands and the driven
self-test for the Stop hook (D00 T04 §32, §34).

`.claude/hooks/campaign-stop.ps1` blocks the campaign session's end of
turn while its run is open. The guard file it reads is written and
deleted only through this module (D00 T04 §34):

    python scripts/campaign_guard.py acquire --session S --phase N --run-file F --cron-id J [--handover REASON]
    python scripts/campaign_guard.py end --session S --reason closeout|park|plan-done|operator-stop|escalation|stall
    python scripts/campaign_guard.py hook-error [--session S] [--ack LINE]
    python scripts/campaign_guard.py mint-generation
    python scripts/campaign_guard.py whoami --session S --generation G
    python scripts/campaign_guard.py reset-state --session S | --expect-no-guard yes
    python scripts/campaign_guard.py pending-cancel | cancel-confirmed --cron-id J
    python scripts/campaign_guard.py reconcile --session S --jobs J1,J2
    python scripts/campaign_guard.py health --session S --jobs J1,J2
    python scripts/campaign_guard.py expiry --session S [--now ISO]
    python scripts/campaign_guard.py repair attempt --red SHA --commit SHA | close --green SHA | status
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
END_REASONS = ("closeout", "park", "plan-done", "operator-stop", "escalation", "stall")


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


def mint_generation() -> str:
    """A fresh acquisition generation: the heartbeat prompt carries it, so
    a replaced job in the same session knows it is obsolete (D00 T04 §36)."""
    import uuid
    return uuid.uuid4().hex[:12]


def _utc_now() -> str:
    import datetime
    return datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _run_length(root: str, run_file: str) -> int:
    try:
        return os.path.getsize(os.path.join(root, run_file))
    except OSError:
        return 0


def acquire(root: str, session: str, phase: int, run_file: str, cron_id: str,
            handover: str | None = None, generation: str | None = None) -> str:
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
        return _acquire_locked(root, session, phase, run_file, cron_id, handover, generation)


def _acquire_locked(root: str, session: str, phase: int, run_file: str, cron_id: str,
                    handover: str | None, generation: str | None = None) -> str:
    guard, state_path = _paths(root)
    os.makedirs(os.path.dirname(guard), exist_ok=True)
    try:
        previous = read_guard(root) or {}
    except GuardError:
        previous = {}
    same_run = previous.get("run_file") == run_file and previous.get("session_id") == session
    doc = {"runner": "claude", "workspace": root.replace("\\", "/"), "phase": phase,
           "run_file": run_file, "session_id": session, "cron_id": cron_id,
           # D00 T04 §36: the generation the heartbeat prompt carries, when
           # its job was created (the 7-day expiry counts from it), and the
           # run file's length at acquisition, so a reused run file's old
           # markers never end this run.
           "generation": generation or (previous.get("generation") if same_run and
                                        previous.get("cron_id") == cron_id else None) or mint_generation(),
           "job_created_at": (previous.get("job_created_at") if previous.get("cron_id") == cron_id
                              and previous.get("job_created_at") else _utc_now()),
           # A stable run identity every terminal marker must carry, so a
           # reused run file's old markers never end this run however the
           # file is edited (D00 T04 §36 independent review: a byte offset
           # breaks when a park record is inserted mid-file).
           "run_id": (previous.get("run_id") if (same_run or (handover and previous.get("run_file") == run_file))
                      and previous.get("run_id") else mint_generation())}
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
        if owner != session or not same_run:
            try:
                os.unlink(state_path)
            except FileNotFoundError:
                pass
        return (f"acquire: guard {what} for session {session} (phase {phase}, {run_file}, job {cron_id}, "
                f"generation {doc['generation']}, run {doc['run_id']})")
    with os.fdopen(fd, "wb") as fh:
        fh.write(data)
    # A fresh guard starts a fresh breaker, under the same lock (D00 T04 §36).
    try:
        os.unlink(state_path)
    except FileNotFoundError:
        pass
    return (f"acquire: guard created for session {session} (phase {phase}, {run_file}, job {cron_id}, "
            f"generation {doc['generation']}, run {doc['run_id']})")


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
    text = _run_markers_text(root, run_rel, guard)
    rid = guard.get("run_id")
    tag = f" run={rid}" if rid else ""
    if reason == "closeout" and not re.search(r"(?m)^## Closeout\b", text):
        raise GuardError(f"closeout needs a '## Closeout{tag}' heading in {run_rel}")
    if reason == "park" and not re.search(r"(?m)^PARKED\b", text):
        raise GuardError(f"park needs a column-0 'PARKED <UTC>{tag} <reason>' line in {run_rel}")
    if reason == "escalation" and not re.search(r"(?m)^PARKED\b.*\bescalation:", text):
        raise GuardError(f"escalation needs a column-0 'PARKED <UTC>{tag} escalation: <cause>' line in {run_rel}")
    if reason == "plan-done" and ready != 0:
        raise GuardError(f"plan-done needs '0 runnable now'; query ready reads {ready}")
    if reason == "stall":
        try:
            with open(state_path, encoding="utf-8-sig") as fh:
                trips = int(json.load(fh).get("trips", 0))
        except (OSError, ValueError, TypeError, AttributeError):
            trips = 0
        if trips < 2:
            raise GuardError(f"stall needs a state file with trips of 2 or more; it reads {trips}")
    # The job id outlives the guard until CronDelete is confirmed: a failed
    # delete stays recoverable (D00 T04 §36).
    pending = _pending_path(root)
    with open(pending + ".tmp", "w", encoding="utf-8") as fh:
        json.dump({"cron_id": guard.get("cron_id"), "reason": reason, "at": _utc_now()}, fh)
    os.replace(pending + ".tmp", pending)
    for path in (guard_path, state_path):
        try:
            os.unlink(path)
        except FileNotFoundError:
            pass
    left = [p for p in (guard_path, state_path) if os.path.exists(p)]
    if left:
        raise GuardError(f"could not delete {', '.join(left)}")
    return (f"end: {reason}: guard and state deleted; CronDelete {guard.get('cron_id')} now "
            f"(the heartbeat job), confirm it is gone with CronList, then run "
            f"cancel-confirmed --cron-id {guard.get('cron_id')}")


def marker_run(line: str) -> str | None:
    m = re.search(r"\brun=([0-9a-f]{6,})\b", line)
    return m.group(1) if m else None


def _run_markers_text(root: str, run_rel: str, guard: dict) -> str:
    """The run file's lines that count as this run's markers: every line
    when the guard predates run ids, else only `## Closeout` and `PARKED`
    lines carrying `run=<this run's id>`, wherever they sit in the file
    (D00 T04 §36)."""
    try:
        with open(os.path.join(root, run_rel), encoding="utf-8", errors="replace") as fh:
            text = fh.read()
    except OSError:
        return ""
    run_id = guard.get("run_id")
    if not run_id:
        return text
    keep = [ln for ln in text.splitlines()
            if not re.match(r"\A(## Closeout\b|PARKED\b)", ln) or marker_run(ln) == run_id]
    return "\n".join(keep)


def _pending_path(root: str) -> str:
    return os.path.join(root, "build", "claude-campaign-pending-cancel.json")


def pending_cancel(root: str) -> str:
    try:
        with open(_pending_path(root), encoding="utf-8") as fh:
            doc = json.load(fh)
    except FileNotFoundError:
        return ""
    except (OSError, ValueError):
        return "pending-cancel: the record is unreadable: list the jobs and delete any Resolute heartbeat"
    return f"pending-cancel: CronDelete {doc.get('cron_id')} (ended by {doc.get('reason')} at {doc.get('at')})"


def cancel_confirmed(root: str, cron_id: str) -> str:
    with _Lock(root):
        try:
            with open(_pending_path(root), encoding="utf-8") as fh:
                doc = json.load(fh)
        except FileNotFoundError:
            return "cancel-confirmed: nothing pending"
        except (OSError, ValueError):
            doc = {}
        if doc and str(doc.get("cron_id")) != cron_id:
            raise GuardError(f"the pending cancellation names job {doc.get('cron_id')}, not {cron_id}")
        os.unlink(_pending_path(root))
        return f"cancel-confirmed: job {cron_id} is gone; nothing pending"


def whoami(root: str, session: str, generation: str | None = None) -> str:
    """What this heartbeat is to the run: OWNER, NOT THE OWNER, NOT THE
    CURRENT JOB (a replaced job in the owning session), NO GUARD, or
    MALFORMED GUARD (D00 T04 §36)."""
    with _Lock(root):
        try:
            guard = read_guard(root)
        except GuardError:
            return "MALFORMED GUARD"
        if guard is None:
            return "NO GUARD"
        if str(guard.get("session_id", "")) != session:
            return "NOT THE OWNER"
        if generation and str(guard.get("generation", "")) != generation:
            return "NOT THE CURRENT JOB"
        # The run id rides the answer, so the heartbeat reads which markers
        # are this run's without carrying the id in its prompt.
        return f"OWNER run={guard.get('run_id')}" if guard.get("run_id") else "OWNER"


def reset_state(root: str, session: str | None = None, expect_no_guard: bool = False) -> str:
    """Delete the breaker state under the lock, re-checking ownership or
    absence first: never a direct delete (D00 T04 §36)."""
    _, state_path = _paths(root)
    with _Lock(root):
        try:
            guard = read_guard(root)
        except GuardError:
            raise GuardError("the guard is unreadable; refusing to reset its state")
        if expect_no_guard and guard is not None:
            raise GuardError("a guard exists: a new run started; its state is not this heartbeat's to delete")
        if not expect_no_guard and (guard is None or str(guard.get("session_id", "")) != session):
            raise GuardError("reset-state needs the owning --session of a live guard")
        try:
            os.unlink(state_path)
            return "reset-state: state deleted"
        except FileNotFoundError:
            return "reset-state: no state"


def reconcile(root: str, session: str, jobs: list[str]) -> list[str]:
    """Startup reconciliation between the guard and the live heartbeat jobs
    (D00 T04 §36): what to delete or recreate before a run starts."""
    with _Lock(root):
        try:
            guard = read_guard(root)
        except GuardError:
            return ["reconcile: the guard is unreadable: report it to the operator and start nothing"]
    out: list[str] = []
    if guard is None:
        out += [f"reconcile: orphan job {j} has no guard: CronDelete it" for j in jobs]
        return out or ["reconcile: consistent (no guard, no job)"]
    owner, job = str(guard.get("session_id", "")), str(guard.get("cron_id", ""))
    if owner != session:
        return [f"reconcile: the guard belongs to session {owner}: start nothing and report the owner"]
    if job not in jobs:
        out.append(f"reconcile: the guard names job {job}, which is not live: CronCreate a heartbeat "
                   f"and re-point with acquire --cron-id")
    out += [f"reconcile: stale job {j} is not the guard's: CronDelete it" for j in jobs if j != job]
    return out or [f"reconcile: consistent (guard and job {job})"]


def health(root: str, session: str, jobs: list[str]) -> tuple[int, str]:
    with _Lock(root):
        try:
            guard = read_guard(root)
        except GuardError:
            return 1, "health: the guard is unreadable"
    if guard is None or str(guard.get("session_id", "")) != session:
        return 1, "health: this session holds no live guard"
    job = str(guard.get("cron_id", ""))
    if job not in jobs:
        return 1, f"health: job {job} is missing: CronCreate a heartbeat and re-point with acquire --cron-id"
    return 0, f"health: ok, job {job} is live"


def expiry(root: str, session: str, now: str | None = None, days: float = 7.0,
           margin_hours: float = 12.0) -> tuple[int, str]:
    """Whether the heartbeat job nears its 7-day expiry (D00 T04 §36):
    exit 1 `replace due` inside the margin, else how long is left."""
    import datetime
    with _Lock(root):
        try:
            guard = read_guard(root)
        except GuardError:
            return 1, "expiry: the guard is unreadable"
    if guard is None or str(guard.get("session_id", "")) != session:
        return 1, "expiry: this session holds no live guard"
    fmt = "%Y-%m-%dT%H:%M:%SZ"
    try:
        created = datetime.datetime.strptime(str(guard.get("job_created_at")), fmt)
    except ValueError:
        return 1, "expiry: the job's creation time is unknown: replace the job"
    current = datetime.datetime.strptime(now, fmt) if now else datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0, tzinfo=None)
    left = datetime.timedelta(days=days) - (current - created)
    if left <= datetime.timedelta(hours=margin_hours):
        return 1, (f"expiry: replace due, job {guard.get('cron_id')} created {guard.get('job_created_at')} "
                   f"expires in {max(left.total_seconds(), 0) / 3600:.1f}h: CronCreate a replacement and re-point")
    return 0, f"expiry: ok, job {guard.get('cron_id')} expires in {left.total_seconds() / 3600:.1f}h"


def hook_error(root: str, session: str | None = None, ack: str | None = None) -> str:
    """Print and clear the error the hook recorded, if any. With a
    session, a guard owned by another session is refused before anything
    is read or cleared (panel round 1: a former owner's heartbeat must
    not consume the current owner's failure record)."""
    with _Lock(root):
        return _hook_error_locked(root, session, ack)


def _hook_error_log(root: str, ack: str | None) -> str:
    """The oldest line of the append-only log the hook writes when it
    cannot get the guard lock (D00 T04 §36 independent review): printed
    like a state error, removed only on its exact --ack. Runs under the
    caller's lock."""
    log = os.path.join(root, "build", "claude-campaign-hook-errors.log")
    try:
        with open(log, encoding="utf-8", errors="replace") as fh:
            lines = [ln for ln in fh.read().splitlines() if ln.strip()]
    except OSError:
        return ""
    if not lines:
        return ""
    at, _, reason = lines[0].partition(" ")
    line = f"campaign-stop hook failed at {at}: {reason} (recorded without the lock)"
    if ack is None:
        return line
    if ack != line:
        raise GuardError("the acknowledgement does not match the recorded error; nothing cleared")
    rest = lines[1:]
    tmp = log + ".tmp"
    with open(tmp, "w", encoding="utf-8") as fh:
        fh.write("".join(ln + "\n" for ln in rest))
    os.replace(tmp, log)
    return f"hook-error: acknowledged and cleared: {line}"


def _hook_error_locked(root: str, session: str | None, ack: str | None = None) -> str:
    # Under the lock, so no handover lands between the ownership check
    # and the clear (panel round 2). An unreadable guard cannot name an
    # owner, and the error it caused is exactly what must be reported,
    # so it reports rather than refuses (panel round 2).
    unreadable = False
    if session:
        try:
            guard = read_guard(root)
        except GuardError:
            guard, unreadable = None, True
        if guard is not None and str(guard.get("session_id", "")) != session:
            raise GuardError(f"the guard belongs to session {guard.get('session_id')}, not {session}")
    _, state_path = _paths(root)
    try:
        with open(state_path, encoding="utf-8-sig") as fh:
            state = json.load(fh)
    except (OSError, ValueError):
        return _hook_error_log(root, ack)
    err = state.get("hook_error")
    at = state.get("hook_error_at")
    if not err:
        return _hook_error_log(root, ack)
    note = " (the guard file is unreadable: repair it before resuming)" if unreadable else ""
    line = f"campaign-stop hook failed at {at}: {err}{note}"
    if ack is None:
        # Print only: the record clears after the run file holds it and
        # the heartbeat acknowledges that exact line (D00 T04 §36).
        return line
    if ack != line:
        raise GuardError("the acknowledgement does not match the recorded error; nothing cleared")
    state.pop("hook_error", None)
    state.pop("hook_error_at", None)
    tmp = state_path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as fh:
        json.dump(state, fh)
    os.replace(tmp, state_path)
    return f"hook-error: acknowledged and cleared: {line}"


REPAIR_BOUND = 3


def _repair_path(root: str) -> str:
    return os.path.join(root, "build", "claude-campaign-repair.json")


def repair(root: str, action: str, red: str = "", commit: str = "", green: str = "") -> tuple[int, str]:
    """The CI repair episode, persisted beside the guard state so a
    resumed or restarted runner cannot recount from zero (D00 T04 §35).
    An episode opens at its first red and closes at the next green; at
    most REPAIR_BOUND repair attempts ride one episode, across however
    many reds it sees. Returns (exit, line): `attempt` exits 1 when the
    bound is exhausted, which is the escalation."""
    path = _repair_path(root)
    with _Lock(root):
        exists = True
        try:
            with open(path, encoding="utf-8") as fh:
                ep = json.load(fh)
        except FileNotFoundError:
            ep, exists = None, False
        except (OSError, ValueError) as exc:
            # An unreadable episode must never reset the bound (panel round 1).
            raise GuardError(f"the repair episode {path} is unreadable ({exc}); the bound cannot be "
                             f"counted, so escalate rather than repair")
        # Only a missing file means no episode: a file holding anything but
        # a well-formed episode (a JSON null included) refuses (panel round 2).
        if exists and not (isinstance(ep, dict) and isinstance(ep.get("episode"), str)
                           and isinstance(ep.get("attempts"), list)):
            raise GuardError(f"the repair episode {path} is malformed; the bound cannot be counted, "
                             f"so escalate rather than repair")
        if action == "status":
            if not ep:
                return 0, "repair: no open episode"
            return 0, (f"repair: episode {ep['episode'][:12]} open, {len(ep['attempts'])} of "
                       f"{REPAIR_BOUND} attempts used")
        if action == "close":
            if not green:
                raise GuardError("repair close needs --green <sha>")
            if not ep:
                return 0, "repair: no open episode to close"
            os.unlink(path)
            return 0, (f"repair: episode {ep['episode'][:12]} closed green at {green[:12]} after "
                       f"{len(ep['attempts'])} attempt(s)")
        if action == "attempt":
            if not red or not commit:
                raise GuardError("repair attempt needs --red <sha> and --commit <sha>")
            ep = ep or {"episode": red, "attempts": []}
            if len(ep["attempts"]) >= REPAIR_BOUND:
                return 1, (f"repair: episode {ep['episode'][:12]} has used all {REPAIR_BOUND} attempts: "
                           f"the bound is exhausted, escalate (PARKED ... escalation:, then end --reason escalation)")
            ep["attempts"].append({"red": red, "commit": commit})
            tmp = path + ".tmp"
            with open(tmp, "w", encoding="utf-8") as fh:
                json.dump(ep, fh, indent=1)
            os.replace(tmp, path)
            return 0, (f"repair: episode {ep['episode'][:12]} attempt {len(ep['attempts'])} of "
                       f"{REPAIR_BOUND} ({commit[:12]} repairs {red[:12]})")
        raise GuardError(f"repair action {action!r} is not attempt, close, or status")


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
        # D00 T04 §34: the failure is recorded for the heartbeat, then
        # reported through the still-malformed guard, then cleared.
        st = _state(root)
        check("a-thrown-error-is-recorded", bool(st.get("hook_error")) and bool(st.get("hook_error_at")), str(st))
        with open(os.path.join(root, "build", "claude-campaign-state.json"), encoding="utf-8-sig") as fh:
            saved_state = fh.read()
        line = hook_error(root, SESSION)
        check("hook-error-reports-through-a-malformed-guard",
              line.startswith("campaign-stop hook failed at ") and "guard file is unreadable" in line
              and bool(_state(root).get("hook_error")), line)
        # D00 T04 §36: printing clears nothing; only the exact acknowledged
        # line clears the record, so an interrupted heartbeat loses nothing.
        try:
            hook_error(root, SESSION, ack="some other line")
            check("hook-error-refuses-a-mismatched-ack", False)
        except GuardError as exc:
            check("hook-error-refuses-a-mismatched-ack",
                  "does not match" in str(exc) and bool(_state(root).get("hook_error")), str(exc))
        cleared = hook_error(root, SESSION, ack=line)
        check("hook-error-clears-on-the-exact-ack",
              cleared.startswith("hook-error: acknowledged and cleared") and "hook_error" not in _state(root),
              cleared)
        with open(os.path.join(root, "build", "claude-campaign-state.json"), "w", encoding="utf-8") as fh:
            fh.write(saved_state)
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
        hook_error(root, ack=line)
        check("hook-error-reports-then-clears-on-ack",
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
            "- started\n", "- started\n- bookkeeping: heartbeat fired, resumed\n")
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

        # D00 T04 §36: a substantive Critical events line is progress; only
        # a marked bookkeeping line is not.
        for _ in range(3):
            run_hook(root, SESSION)
        text = open(run_path, encoding="utf-8").read().replace(
            "- started\n", "- started\n- 2099-01-01: repaired the red CI by hand, see the run page\n")
        with open(run_path, "w", encoding="utf-8") as fh:
            fh.write(text)
        code, out, _ = run_hook(root, SESSION)
        check("a-substantive-critical-events-line-is-progress",
              isinstance(out, dict) and out.get("decision") == "block" and _state(root).get("trips") == 0,
              f"{out} {_state(root)}")

        # D00 T04 §36: the hook's state write waits for the guard lock.
        holder = subprocess.Popen(
            [sys.executable, "-c",
             "import sys, time; sys.path.insert(0, sys.argv[1]); import campaign_guard as cg\n"
             "with cg._Lock(sys.argv[2]):\n"
             "    print('held', flush=True); time.sleep(2)",
             HERE, root], stdout=subprocess.PIPE, text=True)
        holder.stdout.readline()
        import time as _time
        began = _time.monotonic()
        code, out, err = run_hook(root, SESSION)
        waited = _time.monotonic() - began
        holder.wait()
        check("the-hook-waits-for-the-guard-lock",
              isinstance(out, dict) and out.get("decision") == "block" and waited >= 1.0, f"{waited:.2f}s {out} {err}")
        holder = subprocess.Popen(
            [sys.executable, "-c",
             "import sys, time; sys.path.insert(0, sys.argv[1]); import campaign_guard as cg\n"
             "with cg._Lock(sys.argv[2]):\n"
             "    print('held', flush=True); time.sleep(4)",
             HERE, root], stdout=subprocess.PIPE, text=True)
        holder.stdout.readline()
        os.environ["CAMPAIGN_LOCK_WAIT_MS"] = "300"
        try:
            code, out, err = run_hook(root, SESSION)
        finally:
            del os.environ["CAMPAIGN_LOCK_WAIT_MS"]
        holder.wait()
        log = os.path.join(root, "build", "claude-campaign-hook-errors.log")
        logged = open(log, encoding="utf-8").read() if os.path.exists(log) else ""
        check("a-lock-timeout-fails-open-into-the-error-log",
              code == 0 and out is None and "guard lock stayed held" in logged, f"{out} {err} {logged!r}")
        os.remove(log)

        # D00 T04 §36 independent review: an error written to the fallback
        # log (the lock was unavailable) reaches the heartbeat too.
        with open(os.path.join(root, "build", "claude-campaign-hook-errors.log"), "w", encoding="utf-8") as fh:
            fh.write("2099-01-01T00:00:00Z the guard lock stayed held for 300ms\n")
        st_path = os.path.join(root, "build", "claude-campaign-state.json")
        if os.path.exists(st_path):
            st_now = _state(root)
            st_now.pop("hook_error", None)
            with open(st_path, "w", encoding="utf-8") as fh:
                json.dump(st_now, fh)
        line = hook_error(root)
        check("hook-error-reads-the-fallback-log",
              line == "campaign-stop hook failed at 2099-01-01T00:00:00Z: the guard lock stayed held for 300ms "
                      "(recorded without the lock)", line)
        hook_error(root, ack=line)
        check("hook-error-ack-drains-the-fallback-log", hook_error(root) == "", hook_error(root))

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
            # D00 T04 §36: markers count only after acquisition, so the run
            # file gains its body after the guard is acquired.
            with open(run_path, "w", encoding="utf-8") as fh:
                fh.write("# run\n")
            _set_ready(root, ready)
            acquire(root, SESSION, 0, RUN_FILE, "job-9")
            run_hook(root, SESSION)  # leaves a state file behind
            rid = read_guard(root)["run_id"]
            body = body.replace("## Closeout", f"## Closeout run={rid}").replace(
                "PARKED 2099-01-01T00:00:00Z", f"PARKED 2099-01-01T00:00:00Z run={rid}")
            with open(run_path, "a", encoding="utf-8") as fh:
                fh.write(body)

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
            end(root, SESSION, "stall")
            check("end-refuses-a-stall-without-two-trips", False)
        except GuardError as exc:
            check("end-refuses-a-stall-without-two-trips", "trips of 2 or more" in str(exc), str(exc))
        with open(_paths(root)[1], "w", encoding="utf-8") as fh:
            json.dump({"trips": 2, "stalled": True}, fh)
        msg = end(root, SESSION, "stall")
        check("end-stall-leaves-nothing-behind",
              not any(os.path.exists(f) for f in _paths(root)) and "CronDelete job-9" in msg, msg)
        _fresh("# r\n", 3)
        try:
            end(root, SESSION, "closeout")
            check("end-refuses-a-closeout-without-its-heading", False)
        except GuardError as exc:
            check("end-refuses-a-closeout-without-its-heading",
                  "needs a '## Closeout run=" in str(exc) and read_guard(root) is not None, str(exc))
        try:
            end(root, "33333333-0000-0000-0000-000000000000", "operator-stop")
            check("end-refuses-another-session", False)
        except GuardError as exc:
            check("end-refuses-another-session", "belongs to session" in str(exc), str(exc))

    # D00 T04 §36: the lifecycle commands, in a fixture of their own.
    with tempfile.TemporaryDirectory(prefix="campaign-life-") as ltmp:
        lroot = _workspace(ltmp)
        run = os.path.join(lroot, RUN_FILE)
        with open(run, "w", encoding="utf-8") as fh:
            fh.write("# old run\n\nPARKED 2098-01-01T00:00:00Z an earlier run parked here\n")
        g1 = mint_generation()
        acquire(lroot, SESSION, 0, RUN_FILE, "job-a", generation=g1)
        code, out, _ = run_hook(lroot, SESSION)
        check("a-reused-run-files-old-marker-keeps-blocking",
              isinstance(out, dict) and out.get("decision") == "block", str(out))
        rid = read_guard(lroot)["run_id"]
        # D00 T04 §36 independent review: the park record may sit mid-file
        # (process-phase puts it under Gap audit); the run id, not its
        # position, makes it this run's.
        with open(run, "w", encoding="utf-8") as fh:
            fh.write(f"# run\n\n## Gap audit\n\nPARKED 2099-01-01T00:00:00Z run={rid} leftovers blocked\n\n"
                     "## Sections\n\nPARKED 2098-01-01T00:00:00Z an earlier run parked here\n")
        code, out, _ = run_hook(lroot, SESSION)
        check("a-mid-file-marker-carrying-the-run-id-ends-the-run", code == 0 and out is None, str(out))
        with open(run, "w", encoding="utf-8") as fh:
            fh.write("# run\n\n## Critical events\n\n- a new line above the old marker\n\n"
                     "PARKED 2098-01-01T00:00:00Z run=0000deadbeef an earlier run parked here\n")
        code, out, _ = run_hook(lroot, SESSION)
        check("an-old-marker-pushed-down-the-file-keeps-blocking",
              isinstance(out, dict) and out.get("decision") == "block", str(out))
        with open(run, "a", encoding="utf-8") as fh:
            fh.write(f"\nPARKED 2099-01-01T00:00:00Z run={rid} this run parked\n")
        check("whoami-owner-names-the-run", whoami(lroot, SESSION, g1) == f"OWNER run={read_guard(lroot)['run_id']}",
              whoami(lroot, SESSION, g1))
        check("whoami-not-the-current-job", whoami(lroot, SESSION, "stale0000000") == "NOT THE CURRENT JOB")
        check("whoami-not-the-owner", whoami(lroot, "99999999-0000-0000-0000-000000000000", g1) == "NOT THE OWNER")
        g2 = mint_generation()
        acquire(lroot, SESSION, 0, RUN_FILE, "job-b", generation=g2)
        check("a-replaced-job-is-not-current", whoami(lroot, SESSION, g1) == "NOT THE CURRENT JOB"
              and whoami(lroot, SESSION, g2).startswith("OWNER"))
        check("health-ok", health(lroot, SESSION, ["job-b"])[0] == 0)
        code_h, line_h = health(lroot, SESSION, ["job-a"])
        check("health-names-a-missing-job", code_h == 1 and "job-b is missing" in line_h, line_h)
        check("reconcile-consistent", reconcile(lroot, SESSION, ["job-b"]) == ["reconcile: consistent (guard and job job-b)"])
        rc = reconcile(lroot, SESSION, ["job-a"])
        check("reconcile-guard-without-job-and-stale-job",
              any("job-b, which is not live" in r for r in rc) and any("stale job job-a" in r for r in rc), str(rc))
        g = read_guard(lroot)
        code_e, line_e = expiry(lroot, SESSION, now=g["job_created_at"])
        check("expiry-ok-when-fresh", code_e == 0 and "expires in 168.0h" in line_e, line_e)
        import datetime as _dt
        later = (_dt.datetime.strptime(g["job_created_at"], "%Y-%m-%dT%H:%M:%SZ")
                 + _dt.timedelta(days=6, hours=13)).strftime("%Y-%m-%dT%H:%M:%SZ")
        code_e, line_e = expiry(lroot, SESSION, now=later)
        check("expiry-replace-due-near-seven-days", code_e == 1 and "replace due" in line_e, line_e)
        try:
            reset_state(lroot, "99999999-0000-0000-0000-000000000000")
            check("reset-state-refuses-another-session", False)
        except GuardError as exc:
            check("reset-state-refuses-another-session", "owning --session" in str(exc), str(exc))
        try:
            reset_state(lroot, expect_no_guard=True)
            check("reset-state-refuses-while-a-guard-lives", False)
        except GuardError as exc:
            check("reset-state-refuses-while-a-guard-lives", "a guard exists" in str(exc), str(exc))
        msg = end(lroot, SESSION, "park")
        check("end-leaves-a-pending-cancellation",
              pending_cancel(lroot).startswith("pending-cancel: CronDelete job-b") and "cancel-confirmed" in msg,
              pending_cancel(lroot))
        try:
            cancel_confirmed(lroot, "job-zzz")
            check("cancel-confirmed-refuses-another-job", False)
        except GuardError as exc:
            check("cancel-confirmed-refuses-another-job", "names job job-b" in str(exc), str(exc))
        check("cancel-confirmed-clears-the-pending-record",
              cancel_confirmed(lroot, "job-b").startswith("cancel-confirmed: job job-b is gone")
              and pending_cancel(lroot) == "")
        check("reconcile-orphan-job", reconcile(lroot, SESSION, ["job-x"])
              == ["reconcile: orphan job job-x has no guard: CronDelete it"])
        check("reset-state-with-no-guard", reset_state(lroot, expect_no_guard=True).startswith("reset-state:"))
        check("whoami-no-guard", whoami(lroot, SESSION, g2) == "NO GUARD")

        # D00 T04 §36: the fingerprint's degraded coverage, pinned at small
        # bounds: content past the hash bound counts only through size and
        # write time, and past the stat bound only through the name.
        with open(run, "w", encoding="utf-8") as fh:
            fh.write("# run\n")
        acquire(lroot, SESSION, 0, RUN_FILE, "job-c")
        cov = os.path.join(lroot, "cov")
        os.makedirs(cov)
        for n in range(6):
            with open(os.path.join(cov, f"f{n}.txt"), "w", encoding="utf-8") as fh:
                fh.write("aaaa\n")
        env_bounds = {"CAMPAIGN_HASH_FILES": "2", "CAMPAIGN_STAT_FILES": "2"}
        os.environ.update(env_bounds)
        try:
            def _tripped_then(path: str, keep_time: bool) -> dict:
                for _ in range(4):
                    run_hook(lroot, SESSION)
                st_before = os.stat(path)
                with open(path, "w", encoding="utf-8") as fh:
                    fh.write("bbbb\n")
                if keep_time:
                    os.utime(path, ns=(st_before.st_atime_ns, st_before.st_mtime_ns))
                run_hook(lroot, SESSION)
                return _state(lroot)
            st = _tripped_then(os.path.join(cov, "f0.txt"), keep_time=True)
            check("coverage-a-hashed-file-edit-counts-even-with-its-time-kept", st.get("trips") == 0, str(st))
            st = _tripped_then(os.path.join(cov, "f2.txt"), keep_time=True)
            check("coverage-past-the-hash-bound-a-same-size-same-time-edit-is-invisible", st.get("trips") == 1, str(st))
            st = _tripped_then(os.path.join(cov, "f3.txt"), keep_time=False)
            check("coverage-past-the-hash-bound-a-time-change-counts", st.get("trips") == 0, str(st))
            st = _tripped_then(os.path.join(cov, "f5.txt"), keep_time=False)
            check("coverage-past-the-stat-bound-only-the-name-counts", st.get("trips") == 1, str(st))
        finally:
            for k in env_bounds:
                del os.environ[k]

    # D00 T04 §35: the repair episode survives a restart and refuses a fourth attempt.
    with tempfile.TemporaryDirectory(prefix="campaign-repair-") as rtmp:
        os.makedirs(os.path.join(rtmp, "build"))

        def _repair_cli(*args: str) -> subprocess.CompletedProcess:
            return subprocess.run([sys.executable, os.path.join(HERE, "campaign_guard.py"), "repair", *args,
                                   "--root", rtmp], capture_output=True, text=True, encoding="utf-8")
        outs = [_repair_cli("attempt", "--red", f"red{n}aaaaaaaaaaaa", "--commit", f"fix{n}aaaaaaaaaaaa")
                for n in (1, 2, 3)]
        check("repair-attempts-count-across-processes",
              [o.returncode for o in outs] == [0, 0, 0] and "attempt 3 of 3" in outs[2].stdout
              and "episode red1aaaaaaaa" in outs[2].stdout, str([o.stdout for o in outs]))
        st = _repair_cli("status")
        check("repair-status-reads-the-persisted-episode", "3 of 3 attempts used" in st.stdout, st.stdout)
        fourth = _repair_cli("attempt", "--red", "red4aaaaaaaaaaaa", "--commit", "fix4aaaaaaaaaaaa")
        check("repair-refuses-a-fourth-attempt-after-a-restart",
              fourth.returncode == 1 and "bound is exhausted, escalate" in fourth.stderr, fourth.stderr)
        with open(os.path.join(rtmp, "build", "claude-campaign-repair.json"), encoding="utf-8") as fh:
            saved = fh.read()
        for label, body in (("corrupt", "{not json"), ("malformed", '{"episode": 3}'), ("null", "null")):
            with open(os.path.join(rtmp, "build", "claude-campaign-repair.json"), "w", encoding="utf-8") as fh:
                fh.write(body)
            bad = _repair_cli("attempt", "--red", "red9aaaaaaaaaaaa", "--commit", "fix9aaaaaaaaaaaa")
            check(f"repair-refuses-{label}-state-rather-than-resetting",
                  bad.returncode == 1 and "escalate rather than repair" in bad.stderr, bad.stderr)
        with open(os.path.join(rtmp, "build", "claude-campaign-repair.json"), "w", encoding="utf-8") as fh:
            fh.write(saved)
        closed = _repair_cli("close", "--green", "green1aaaaaaaaaa")
        again = _repair_cli("attempt", "--red", "red5aaaaaaaaaaaa", "--commit", "fix5aaaaaaaaaaaa")
        check("repair-close-opens-a-fresh-episode",
              "closed green" in closed.stdout and again.returncode == 0 and "attempt 1 of 3" in again.stdout,
              f"{closed.stdout} {again.stdout}")

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
                        ("skill-heartbeat-checks-ownership", "NOT THE OWNER or NOT THE CURRENT JOB"),
                        ("skill-heartbeat-ends-through-end", "--reason plan-done`, CronDelete this job"),
                        ("skill-heartbeat-owner-first",
                         "1. Run `python scripts/campaign_guard.py whoami --session"),
                        ("skill-reconciles-before-starting", "python scripts/campaign_guard.py reconcile --session"),
                        ("skill-checks-health-at-each-boundary", "python scripts/campaign_guard.py health --session"),
                        ("skill-confirms-the-cancel", "python scripts/campaign_guard.py cancel-confirmed --cron-id"),
                        ("skill-marks-bookkeeping", "- bookkeeping: heartbeat resumed"),
                        ("skill-markers-carry-the-run-id", "a closeout is a line `## Closeout run=<run id>`")):
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
        if argv[0] == "repair" and len(argv) >= 2:
            ropts = _opts(argv[2:])
            rroot = ropts.pop("root", REPO)
            code, line = repair(rroot, argv[1], ropts.get("red", ""), ropts.get("commit", ""),
                                ropts.get("green", ""))
            print(line, file=sys.stdout if code == 0 else sys.stderr)
            return code
        opts = _opts(argv[1:])
        root = opts.pop("root", REPO)
        if argv[0] == "acquire":
            print(acquire(root, opts.get("session", ""), int(opts.get("phase", "0")),
                          opts.get("run_file", ""), opts.get("cron_id", ""), opts.get("handover"),
                          opts.get("generation")))
            return 0
        if argv[0] == "end":
            print(end(root, opts.get("session", ""), opts.get("reason", "")))
            return 0
        if argv[0] == "hook-error" and set(opts) <= {"session", "ack"}:
            line = hook_error(root, opts.get("session"), opts.get("ack"))
            if line:
                print(line)
            return 0
        if argv[0] == "mint-generation" and not opts:
            print(mint_generation())
            return 0
        if argv[0] == "whoami":
            print(whoami(root, opts.get("session", ""), opts.get("generation")))
            return 0
        if argv[0] == "reset-state":
            print(reset_state(root, opts.get("session"), opts.get("expect_no_guard") == "yes"))
            return 0
        if argv[0] == "pending-cancel" and not opts:
            line = pending_cancel(root)
            if line:
                print(line)
            return 0
        if argv[0] == "cancel-confirmed":
            print(cancel_confirmed(root, opts.get("cron_id", "")))
            return 0
        if argv[0] in ("reconcile", "health"):
            jobs = [j for j in opts.get("jobs", "").split(",") if j]
            if argv[0] == "reconcile":
                print("\n".join(reconcile(root, opts.get("session", ""), jobs)))
                return 0
            code, line = health(root, opts.get("session", ""), jobs)
            print(line, file=sys.stdout if code == 0 else sys.stderr)
            return code
        if argv[0] == "expiry":
            code, line = expiry(root, opts.get("session", ""), opts.get("now"))
            print(line, file=sys.stdout if code == 0 else sys.stderr)
            return code
    except (GuardError, ValueError) as exc:
        print(f"campaign_guard: {exc}", file=sys.stderr)
        return 1
    print(f"campaign_guard: unknown command {' '.join(argv)!r}; see the module docstring", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
