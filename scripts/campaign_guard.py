"""The campaign run guard: its lifecycle commands and the driven
self-test for the Stop hook (D00 T04 §32, §34).

`.claude/hooks/campaign-stop.ps1` blocks the campaign session's end of
turn while its run is open. The guard file it reads is written and
deleted only through this module (D00 T04 §34):

    python scripts/campaign_guard.py acquire --session S --phase N --run-file F --cron-id J [--handover REASON]
    python scripts/campaign_guard.py end --session S --reason closeout|park|plan-done|operator-stop|escalation|stall --generation G --cron-id J [--run R]
    python scripts/campaign_guard.py hook-error [--session S] | --session S --generation G --cron-id J --ack ID
    python scripts/campaign_guard.py mint-generation | heartbeat-tag --generation G --run-file F
    python scripts/campaign_guard.py whoami --session S --generation G [--cronlist FILE|-]
    python scripts/campaign_guard.py reset-state --session S --generation G --cron-id J | --expect-no-guard yes
    python scripts/campaign_guard.py pending-cancel [--session S]
    python scripts/campaign_guard.py cancel-confirmed --session S --cron-id J --generation G|none
    python scripts/campaign_guard.py reconcile --session S --cronlist FILE|- [--run-file F]
    python scripts/campaign_guard.py health --session S --jobs J1,J2
    python scripts/campaign_guard.py expiry --session S [--now ISO]
    python scripts/campaign_guard.py repair attempt --red SHA --commit SHA --workflow W --run-file F
    python scripts/campaign_guard.py repair close --green SHA --workflow W --run-file F --evidence LINE
    python scripts/campaign_guard.py repair status|restore --run-file F [--workflow W] | ceiling --run-id ID
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


def _crash(label: str) -> None:
    """An interruption point (D00 T04 §38): the self-test kills a change
    here, through `CAMPAIGN_CRASH_AT`, to prove every partial state reads
    back as a consistent lifecycle."""
    if os.environ.get("CAMPAIGN_CRASH_AT") == label:
        os._exit(97)


def _publish(path: str, data: bytes) -> None:
    """Replace `path` atomically: a reader sees the old bytes or the new
    ones, never a torn file (D00 T04 §38)."""
    tmp = f"{path}.{os.getpid()}.tmp"
    with open(tmp, "wb") as fh:
        fh.write(data)
    os.replace(tmp, path)


def repo_name(root: str) -> str:
    """The repository name a heartbeat prompt carries (the workspace folder)."""
    return os.path.basename(os.path.normpath(root))


def run_stem(run_file: str) -> str:
    return os.path.splitext(os.path.basename(run_file.replace("\\", "/")))[0]


def heartbeat_tag(root: str, generation: str, run_file: str) -> str:
    """The canonical prompt's opening words. `CronList` shows only a
    prompt's first 80 or so characters, so the identity a job is scoped by
    (generation, repository, run file) leads the prompt (D00 T04 §38)."""
    return f"Claude run-guard heartbeat {generation} {repo_name(root)} {run_stem(run_file)}"


_HEARTBEAT = re.compile(r"Claude run-guard heartbeat ([0-9a-f]{12}) (\S+) ([^\s:\u2026]+)(?=[:\s]|$)")
_CRONLIST_LINE = re.compile(r"^\s*([0-9A-Za-z_-]+)\s.*?[\])]:\s?(.*)$")


def parse_cronlist(text: str) -> list[tuple[str, str]]:
    """(job id, visible prompt) for every job line `CronList` printed."""
    out = []
    for line in text.splitlines():
        m = _CRONLIST_LINE.match(line)
        if m:
            out.append((m.group(1), m.group(2)))
    return out


def classify_job(root: str, prompt: str) -> tuple[str, str, str] | None:
    """(generation, repository, run stem) for a scoped heartbeat prompt;
    ("", "", "") for a legacy heartbeat whose prompt carries no identity;
    None for a job that is not a heartbeat."""
    m = _HEARTBEAT.search(prompt)
    if m:
        return m.group(1), m.group(2), m.group(3)
    if "run-guard heartbeat" in prompt:
        return "", "", ""
    return None


def _fence(guard: dict | None, session: str | None, generation: str | None = None,
           cron_id: str | None = None, run: str | None = None) -> None:
    """Re-check the caller's identity under the lock before a mutation
    (D00 T04 §38): the owning session, the acquisition generation, the
    job, and the run id. A caller whose identity went stale since it last
    looked changes nothing."""
    if guard is None:
        raise GuardError("no guard file: the run is already over")
    if session is not None and str(guard.get("session_id", "")) != session:
        raise GuardError(f"the guard belongs to session {guard.get('session_id')}, not {session}")
    if generation is not None and str(guard.get("generation", "")) != generation:
        raise GuardError(f"the guard's generation is {guard.get('generation')}, not {generation}: "
                         f"this caller is obsolete; nothing changed")
    if cron_id is not None and str(guard.get("cron_id", "")) != cron_id:
        raise GuardError(f"the guard's job is {guard.get('cron_id')}, not {cron_id}: "
                         f"this caller is obsolete; nothing changed")
    if run is not None and str(guard.get("run_id", "")) != run:
        raise GuardError(f"the guard's run is {guard.get('run_id')}, not {run}; nothing changed")


def _migrate_locked(root: str, guard: dict | None) -> dict | None:
    """Give a legacy guard (written before run ids) its run id at its first
    locked access, so from then on only markers carrying it end the run
    (D00 T04 §38). The caller holds the lock."""
    if guard is None or (guard.get("run_id") and guard.get("generation")):
        return guard
    # A guard with no generation cannot fence its callers either, so it
    # gains one too.
    guard = dict(guard, run_id=guard.get("run_id") or mint_generation(),
                 generation=guard.get("generation") or mint_generation(), migrated_at=_utc_now())
    _publish(_paths(root)[0], json.dumps(guard, indent=2).encode("utf-8"))
    return guard


def _read_locked(root: str) -> dict | None:
    """The guard, migrated, under the caller's lock."""
    return _migrate_locked(root, read_guard(root))


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


def _clear_state_if_new_run(root: str, run_id: str) -> None:
    """The breaker state belongs to one run: a handover or a re-point that
    keeps the run id keeps its blocks, stall trips, and coverage, and a new
    run starts clean (D00 T04 §38). The hook ignores a state carrying
    another run id, so a crash before this delete is harmless."""
    _, state_path = _paths(root)
    try:
        with open(state_path, encoding="utf-8-sig") as fh:
            old = json.load(fh)
        if isinstance(old, dict) and old.get("run_id") == run_id:
            return
    except (OSError, ValueError):
        pass
    try:
        os.unlink(state_path)
    except FileNotFoundError:
        pass


def _acquire_locked(root: str, session: str, phase: int, run_file: str, cron_id: str,
                    handover: str | None, generation: str | None = None) -> str:
    guard, state_path = _paths(root)
    os.makedirs(os.path.dirname(guard), exist_ok=True)
    try:
        previous = read_guard(root) or {}
    except GuardError:
        previous = {}
    # Leftovers of a publish a crash interrupted (D00 T04 §38).
    folder = os.path.dirname(guard)
    for name in os.listdir(folder):
        if name.startswith("claude-campaign-guard.json.") and name.endswith(".tmp"):
            try:
                os.unlink(os.path.join(folder, name))
            except OSError:
                pass
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
    # Publication order (D00 T04 §38): the guard first, by atomic replace
    # (or an atomic exclusive link for a new one), then the state reset.
    # A crash between the two leaves a guard beside another run's state,
    # which the hook reads as a fresh breaker because the run ids differ.
    if os.path.exists(guard):
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
        _crash("acquire:repoint-tmp")
        os.replace(tmp, guard)
        _crash("acquire:repoint-published")
        what = "handed over" if owner != session else "re-pointed"
        _clear_state_if_new_run(root, doc["run_id"])
        return (f"acquire: guard {what} for session {session} (phase {phase}, {run_file}, job {cron_id}, "
                f"generation {doc['generation']}, run {doc['run_id']})")
    tmp = guard + f".{os.getpid()}.tmp"
    with open(tmp, "wb") as fh:
        fh.write(json.dumps(doc, indent=2).encode("utf-8"))
    _crash("acquire:create-tmp")
    try:
        # An exclusive publish: the link fails if a guard appeared, and a
        # reader never sees a half-written one (D00 T04 §38).
        os.link(tmp, guard)
    except FileExistsError:
        os.unlink(tmp)
        raise GuardError("a guard appeared while this acquire ran; retry")
    os.unlink(tmp)
    _crash("acquire:create-published")
    # A fresh guard starts a fresh breaker, under the same lock (D00 T04 §36).
    _clear_state_if_new_run(root, doc["run_id"])
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


def end(root: str, session: str, reason: str, generation: str | None = None,
        cron_id: str | None = None, run: str | None = None) -> str:
    """End the run on one of its end paths: check the path's marker, then
    delete the guard file and the state file. The heartbeat job lives in
    the session, not on disk, so the caller deletes it (`CronDelete`) and
    the returned line names it. The CLI requires `--generation` and
    `--cron-id`, re-checked under the lock (D00 T04 §38)."""
    if reason not in END_REASONS:
        raise GuardError(f"reason {reason!r} is not one of {', '.join(END_REASONS)}")
    if not session:
        raise GuardError("end needs --session (the session that owns the guard)")
    # The plan query runs before the lock, so no subprocess is ever held
    # under it (panel round 1).
    ready = _ready_count(root) if reason == "plan-done" else None
    with _Lock(root):
        return _end_locked(root, session, reason, ready, generation, cron_id, run)


def _end_locked(root: str, session: str, reason: str, ready: int | None, generation: str | None = None,
                cron_id: str | None = None, run: str | None = None) -> str:
    guard_path, state_path = _paths(root)
    guard = _read_locked(root)
    _fence(guard, session, generation, cron_id, run)
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
                st = json.load(fh)
            # Another run's state is not this run's stall (D00 T04 §38).
            trips = int(st.get("trips", 0)) if st.get("run_id") in (None, guard.get("run_id")) else 0
        except (OSError, ValueError, TypeError, AttributeError):
            trips = 0
        if trips < 2:
            raise GuardError(f"stall needs a state file with trips of 2 or more; it reads {trips}")
    # The job id outlives the guard until CronDelete is confirmed: a failed
    # delete stays recoverable (D00 T04 §36). The record names the session
    # whose scheduler holds the job and its generation (D00 T04 §38).
    pending = _pending_path(root)
    jobs = _pending_jobs(root)
    # Every unconfirmed job is kept: a later end never overwrites an
    # earlier failed cancellation (D00 T04 §36 panel round 1).
    jobs = [j for j in jobs if j.get("cron_id") != guard.get("cron_id")]
    jobs.append({"cron_id": guard.get("cron_id"), "reason": reason, "at": _utc_now(),
                 "session": guard.get("session_id"), "generation": guard.get("generation"),
                 "run_id": guard.get("run_id")})
    # Publication order (D00 T04 §38): the pending record, then the guard,
    # then the state. A crash after the record leaves a live guard whose
    # job the record names, which `pending-cancel` reads as an unfinished
    # end (re-run it), never as a job to delete; a crash after the guard
    # leaves an orphan state that no hook reads and `reset-state` clears.
    _crash("end:pending-tmp")
    _publish(pending, json.dumps(jobs).encode("utf-8"))
    _crash("end:pending-published")
    os.unlink(guard_path)
    _crash("end:guard-deleted")
    try:
        os.unlink(state_path)
    except FileNotFoundError:
        pass
    left = [p for p in (guard_path, state_path) if os.path.exists(p)]
    if left:
        raise GuardError(f"could not delete {', '.join(left)}")
    return (f"end: {reason}: guard and state deleted; CronDelete {guard.get('cron_id')} now "
            f"(the heartbeat job), confirm it is gone with CronList, then run "
            f"cancel-confirmed --session {guard.get('session_id')} --cron-id {guard.get('cron_id')} "
            f"--generation {guard.get('generation') or 'none'}")


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


def _pending_jobs(root: str) -> list[dict]:
    try:
        with open(_pending_path(root), encoding="utf-8") as fh:
            doc = json.load(fh)
    except FileNotFoundError:
        return []
    except (OSError, ValueError):
        raise GuardError("the pending-cancellation record is unreadable: list the jobs and delete any "
                         "Resolute heartbeat by hand")
    if isinstance(doc, dict):
        doc = [doc]
    return [j for j in doc if isinstance(j, dict)] if isinstance(doc, list) else []


def pending_cancel(root: str, session: str | None = None) -> str:
    """The unconfirmed cancellations, each as an instruction (D00 T04 §38):
    `CronDelete` for a job this session's scheduler holds, `report` for one
    another session scheduled (only its scheduler can cancel it), and
    `end incomplete` for a job the live guard still names (a crash between
    the record and the guard delete: re-run `end`, never delete a live
    run's heartbeat)."""
    with _Lock(root):
        try:
            guard = read_guard(root)
        except GuardError:
            guard = None
        try:
            jobs = _pending_jobs(root)
        except GuardError as exc:
            return f"pending-cancel: {exc}"
    out = []
    for j in jobs:
        cron, gen = str(j.get("cron_id")), j.get("generation") or "none"
        if guard is not None and cron == str(guard.get("cron_id")) \
                and gen == (guard.get("generation") or "none"):
            out.append(f"pending-cancel: end incomplete for job {cron}: the guard still names it; "
                       f"re-run end, do not CronDelete a live run's heartbeat")
        elif session and j.get("session") and j.get("session") != session:
            out.append(f"pending-cancel: report job {cron} generation={gen}: session {j.get('session')} "
                       f"scheduled it and only that session's scheduler can cancel it; do not cancel it here")
        else:
            out.append(f"pending-cancel: CronDelete {cron} generation={gen} "
                       f"(ended by {j.get('reason')} at {j.get('at')})")
    return "\n".join(out)


def cancel_confirmed(root: str, cron_id: str, session: str | None = None,
                     generation: str | None = None) -> str:
    """Clear one pending cancellation after `CronList` confirmed the job
    gone, re-checking under the lock that the record names this job, this
    generation, and a job this session scheduled (D00 T04 §38)."""
    with _Lock(root):
        jobs = _pending_jobs(root)
        if not jobs:
            return "cancel-confirmed: nothing pending"
        match = [j for j in jobs if str(j.get("cron_id")) == cron_id]
        if not match:
            raise GuardError(f"no pending cancellation names job {cron_id} "
                             f"(pending: {', '.join(str(j.get('cron_id')) for j in jobs)})")
        entry = match[0]
        if session is not None and entry.get("session") and entry.get("session") != session:
            raise GuardError(f"job {cron_id} was scheduled by session {entry.get('session')}, not {session}: "
                             f"report it rather than confirm it")
        if generation is not None and (entry.get("generation") or "none") != generation:
            raise GuardError(f"the pending record for job {cron_id} carries generation "
                             f"{entry.get('generation') or 'none'}, not {generation}; nothing cleared")
        try:
            guard = read_guard(root)
        except GuardError:
            guard = None
        if guard is not None and str(guard.get("cron_id")) == cron_id:
            raise GuardError(f"the live guard still names job {cron_id}: the end did not finish; re-run end")
        rest = [j for j in jobs if str(j.get("cron_id")) != cron_id]
        if rest:
            _publish(_pending_path(root), json.dumps(rest).encode("utf-8"))
            return (f"cancel-confirmed: job {cron_id} is gone; still pending: "
                    f"{', '.join(str(j.get('cron_id')) for j in rest)}")
        os.unlink(_pending_path(root))
        return f"cancel-confirmed: job {cron_id} is gone; nothing pending"


def whoami(root: str, session: str, generation: str | None = None, cronlist: str | None = None) -> str:
    """What this heartbeat is to the run: OWNER, NOT THE OWNER, NOT THE
    CURRENT JOB (a replaced job in the owning session), NO GUARD, or
    MALFORMED GUARD (D00 T04 §36). With the `CronList` text, jobs carrying
    this generation under another id are named for deletion (D00 T04 §38):
    two jobs with one generation are otherwise indistinguishable."""
    with _Lock(root):
        try:
            guard = _read_locked(root)
        except GuardError:
            return "MALFORMED GUARD"
        if guard is None:
            return "NO GUARD"
        if str(guard.get("session_id", "")) != session:
            return "NOT THE OWNER"
        if generation and str(guard.get("generation", "")) != generation:
            return "NOT THE CURRENT JOB"
        # The run id and job ride the answer, so the heartbeat reads which
        # markers are this run's and fences its later steps with them.
        job = str(guard.get("cron_id", ""))
        line = f"OWNER run={guard.get('run_id')} job={job}"
        if cronlist is None or not generation:
            return line
        stem = run_stem(str(guard.get("run_file", "")))
        carriers = [jid for jid, prompt in parse_cronlist(cronlist)
                    if classify_job(root, prompt) == (generation, repo_name(root), stem)]
        keep = job
        if job not in carriers and carriers:
            keep = carriers[0]
            line += (f"\nDUPLICATE GENERATION: the guard's job {job} is not live and {keep} carries its "
                     f"generation: re-point first with acquire --session {session} --phase {guard.get('phase')} "
                     f"--run-file {guard.get('run_file')} --cron-id {keep} --generation {generation}")
        extras = [c for c in carriers if c != keep]
        if extras:
            line += (f"\nDUPLICATE GENERATION: CronDelete {', '.join(extras)} (they carry generation "
                     f"{generation}; the job to keep is {keep})")
        return line


def reset_state(root: str, session: str | None = None, expect_no_guard: bool = False,
                generation: str | None = None, cron_id: str | None = None) -> str:
    """Delete the breaker state under the lock, re-checking ownership or
    absence first: never a direct delete (D00 T04 §36). An owner's reset
    is fenced by generation and job (D00 T04 §38)."""
    _, state_path = _paths(root)
    with _Lock(root):
        try:
            guard = _read_locked(root)
        except GuardError:
            raise GuardError("the guard is unreadable; refusing to reset its state")
        if expect_no_guard and guard is not None:
            raise GuardError("a guard exists: a new run started; its state is not this heartbeat's to delete")
        if not expect_no_guard:
            if guard is None or str(guard.get("session_id", "")) != session:
                raise GuardError("reset-state needs the owning --session of a live guard")
            _fence(guard, session, generation, cron_id)
        try:
            os.unlink(state_path)
            return "reset-state: state deleted"
        except FileNotFoundError:
            return "reset-state: no state"


def reconcile(root: str, session: str, cronlist: str, run_file: str | None = None) -> list[str]:
    """Startup reconciliation between the guard, the live heartbeat jobs,
    and the run record (D00 T04 §36, §38). The jobs come from the
    `CronList` text, never from a list of ids the caller vouches for: a job
    counts as this workspace's only when its prompt names this repository
    and the run file (the guard's, or `run_file` when no guard lives)."""
    with _Lock(root):
        try:
            guard = _read_locked(root)
        except GuardError:
            return ["reconcile: the guard is unreadable: report it to the operator and start nothing"]
    out: list[str] = []
    try:
        for j in _pending_jobs(root):
            if j.get("session") and j.get("session") != session:
                out.append(f"reconcile: a pending cancellation names job {j.get('cron_id')}, scheduled by "
                           f"session {j.get('session')}: report it, do not cancel it")
            elif guard is not None and str(j.get("cron_id")) == str(guard.get("cron_id")):
                out.append(f"reconcile: the end of job {j.get('cron_id')} is incomplete: re-run end")
            else:
                out.append(f"reconcile: a pending cancellation is unconfirmed: CronDelete {j.get('cron_id')}, "
                           f"then cancel-confirmed")
    except GuardError as exc:
        out.append(f"reconcile: {exc}")
    target = str(guard.get("run_file", "")) if guard is not None else (run_file or "")
    if not target:
        return out + ["reconcile: no guard lives, so name the run file this start is for (--run-file)"]
    # Jobs left alone are notes; they never hide this run's verdict.
    notes: list[str] = []
    ours: list[str] = []
    gens: dict = {}
    for jid, prompt in parse_cronlist(cronlist):
        kind = classify_job(root, prompt)
        if kind is None:
            continue
        gen, repo, stem = kind
        if not gen:
            notes.append(f"reconcile: job {jid} is a legacy heartbeat whose prompt names no generation, so it "
                       f"cannot be scoped: CronDelete it if it is this workspace's, else leave it")
        elif repo != repo_name(root) or stem != run_stem(target):
            notes.append(f"reconcile: job {jid} is a heartbeat for {repo} {stem}, not this run: left alone")
        else:
            ours.append(jid)
            gens[jid] = gen
    if guard is None:
        out += [f"reconcile: orphan job {j} has no guard: CronDelete it" for j in ours]
        return notes + (out or ["reconcile: consistent (no guard, no job)"])
    owner, job = str(guard.get("session_id", "")), str(guard.get("cron_id", ""))
    gen = str(guard.get("generation", ""))
    if owner != session:
        return notes + [f"reconcile: the guard belongs to session {owner}: start nothing and report the owner"]
    current = [j for j in ours if gens[j] == gen]
    keep = job if job in current else (current[0] if current else None)
    if keep is None:
        out.append(f"reconcile: the guard names job {job}, which is not live: CronCreate a heartbeat "
                   f"and re-point with acquire --cron-id")
    elif keep != job:
        out.append(f"reconcile: the guard names job {job}, which is not live, and {keep} carries its generation: "
                   f"re-point with acquire --cron-id {keep} --generation {gen}")
    out += [f"reconcile: stale job {j} is not the guard's: CronDelete it" for j in ours if j != keep]
    if keep is not None:
        try:
            with open(os.path.join(root, target), encoding="utf-8", errors="replace") as fh:
                text = fh.read()
        except OSError:
            text = ""
        if keep not in text or gen not in text:
            out.append(f"reconcile: {target} does not record job {keep} generation {gen}: append the "
                       f"Critical events line before starting")
    return notes + (out or [f"reconcile: consistent (guard and job {job})"])


def health(root: str, session: str, jobs: list[str]) -> tuple[int, str]:
    with _Lock(root):
        try:
            guard = _read_locked(root)
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
            guard = _read_locked(root)
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


def _errors_dir(root: str) -> str:
    return os.path.join(root, "build", "claude-campaign-hook-errors")


def _hook_errors(root: str) -> list[dict]:
    """Every error the hook recorded, oldest first (D00 T04 §38): one file
    per error, each carrying a unique id and the session, run id, and
    generation it was raised under (empty when the hook failed before it
    read them). Legacy records (a `.txt` file, or the state's single
    `hook_error`) read with an id derived from where they sit."""
    out: list[dict] = []
    folder = _errors_dir(root)
    try:
        names = sorted(n for n in os.listdir(folder) if n.endswith((".json", ".txt")))
    except OSError:
        names = []
    for name in names:
        path = os.path.join(folder, name)
        try:
            with open(path, encoding="utf-8-sig", errors="replace") as fh:
                body = fh.read().strip()
        except OSError:
            continue
        if name.endswith(".json"):
            try:
                doc = json.loads(body)
            except ValueError:
                doc = None
            if not isinstance(doc, dict):
                doc = {"reason": f"an unreadable error record: {body[:120]}"}
        else:
            at, _, reason = body.partition(" ")
            doc = {"at": at, "reason": reason, "legacy": True}
        doc.setdefault("id", os.path.splitext(name)[0].rsplit("-", 1)[-1])
        doc["path"] = path
        out.append(doc)
    _, state_path = _paths(root)
    try:
        with open(state_path, encoding="utf-8-sig") as fh:
            state = json.load(fh)
        if isinstance(state, dict) and state.get("hook_error"):
            out.insert(0, {"id": "state", "at": state.get("hook_error_at"), "reason": state.get("hook_error"),
                           "legacy": True, "path": None})
    except (OSError, ValueError):
        pass
    return out


def _error_line(e: dict, note: str = "") -> str:
    ident = (f"id={e.get('id')} session={e.get('session') or 'unknown'} run={e.get('run_id') or 'unknown'} "
             f"generation={e.get('generation') or 'unknown'}")
    return f"campaign-stop hook failed at {e.get('at')} [{ident}]: {e.get('reason')}{note}"


def hook_error(root: str, session: str | None = None, ack: str | None = None,
               generation: str | None = None, cron_id: str | None = None) -> str:
    """Print every error the hook recorded, one line each, or clear the one
    `ack` names by its id. Printing clears nothing (D00 T04 §36). Each line
    carries its error's identity, so an identical error twice is two
    records and a delivery from before a handover reads as its session's,
    never this one's (D00 T04 §38). An owner's ack is fenced by
    generation and job; the CLI requires them."""
    with _Lock(root):
        return _hook_error_locked(root, session, ack, generation, cron_id)


def _hook_error_locked(root: str, session: str | None, ack: str | None = None,
                       generation: str | None = None, cron_id: str | None = None) -> str:
    # Under the lock, so no handover lands between the ownership check
    # and the clear (panel round 2). An unreadable guard cannot name an
    # owner, and the error it caused is exactly what must be reported,
    # so it reports rather than refuses (panel round 2).
    unreadable = False
    guard = None
    try:
        guard = _read_locked(root)
    except GuardError:
        unreadable = True
    if session and guard is not None and str(guard.get("session_id", "")) != session:
        raise GuardError(f"the guard belongs to session {guard.get('session_id')}, not {session}")
    note = " (the guard file is unreadable: repair it before resuming)" if unreadable else ""
    errors = _hook_errors(root)
    if ack is None:
        return "\n".join(_error_line(e, note) for e in errors)
    if session is not None or generation is not None or cron_id is not None:
        if unreadable:
            raise GuardError("the guard is unreadable, so the acknowledgement cannot be fenced: repair the "
                             "guard, then acknowledge")
        if guard is not None:
            _fence(guard, session, generation, cron_id)
    hit = [e for e in errors if str(e.get("id")) == ack]
    if not hit:
        raise GuardError(f"no recorded error has id {ack}; nothing cleared")
    e = hit[0]
    if e.get("path"):
        os.unlink(e["path"])
    else:
        _, state_path = _paths(root)
        with open(state_path, encoding="utf-8-sig") as fh:
            state = json.load(fh)
        state.pop("hook_error", None)
        state.pop("hook_error_at", None)
        _publish(state_path, json.dumps(state).encode("utf-8"))
    return f"hook-error: acknowledged and cleared: {_error_line(e)}"


REPAIR_BOUND = 3


def _repair_path(root: str) -> str:
    return os.path.join(root, "build", "claude-campaign-repair.json")


def _git(root: str, *args: str) -> tuple[int, str]:
    proc = subprocess.run(["git", *args], cwd=root, capture_output=True, text=True, encoding="utf-8",
                          errors="replace")
    return proc.returncode, proc.stdout.strip()


def _repo_identity(root: str) -> dict:
    """The repository and branch an episode belongs to, read from git."""
    _rc, url = _git(root, "remote", "get-url", "origin")
    _rc, branch = _git(root, "rev-parse", "--abbrev-ref", "HEAD")
    return {"repo": url, "branch": branch}


_ATTEMPT_LINE = re.compile(r"repair: episode ([0-9a-f]{12}) attempt (\d+) of \d+ \(([0-9a-f]{12}) repairs ([0-9a-f]{12})\)"
                           r"(?: repo=(\S+) branch=(\S+) workflow=(\S+))?")


def _ident_suffix(ep: dict) -> str:
    """The identity every attempt line carries, so a restore recovers it
    from the journal rather than from the caller (D00 T04 §38)."""
    return f" repo={ep.get('repo') or '-'} branch={ep.get('branch') or '-'} workflow={ep.get('workflow') or '-'}"
_CLOSED_LINE = re.compile(r"repair: episode ([0-9a-f]{12}) closed green")


def _canon(root: str, rev: str) -> str:
    """A commit's full sha when git resolves it, else the text as given:
    attempts compare by canonical identity, never by printed prefix
    (D00 T04 §37 independent review)."""
    rc, out = _git(root, "rev-parse", "--verify", "--quiet", f"{rev}^{{commit}}")
    return out if rc == 0 and out else rev


def _episode_from_run_file(root: str, run_file: str) -> list[tuple]:
    """(episode, commit, red, repo, branch, workflow) for every distinct
    attempt the run file records after its last closed episode: what a
    lost episode file held. An `already counted` line repeats an attempt
    and is not a new one. A legacy line carries no identity (None)."""
    try:
        with open(os.path.join(root, run_file), encoding="utf-8", errors="replace") as fh:
            text = fh.read()
    except OSError:
        return []
    last_close = max((m.end() for m in _CLOSED_LINE.finditer(text)), default=0)
    out: list[tuple[str, str, str]] = []
    seen: set[str] = set()
    for m in _ATTEMPT_LINE.finditer(text, last_close):
        if m.group(3) in seen:
            continue
        seen.add(m.group(3))
        out.append((m.group(1), m.group(3), m.group(4), m.group(5), m.group(6), m.group(7)))
    return out


def repair(root: str, action: str, red: str = "", commit: str = "", green: str = "",
           workflow: str = "", run_file: str = "", evidence: str = "", run_id: str = "") -> tuple[int, str]:
    """The CI repair episode, persisted beside the guard state so a
    resumed or restarted runner cannot recount from zero (D00 T04 §35).
    An episode opens at its first red and closes at the next green; at
    most REPAIR_BOUND repair attempts ride one episode, across however
    many reds it sees. D00 T04 §37 binds it: the episode records its
    repository, branch, workflow, and run file and refuses a mismatched
    call; an attempt is keyed to its repair commit, so a repeat after a
    crash or a failed push counts once; `close` needs a green read-back
    line for that workflow on a descendant of the last attempt; a lost
    episode file is detected from the run file's attempt lines and
    restored; and `ceiling` allows one re-run per GitHub run that stayed
    pending past the ceiling. Returns (exit, line); exit 1 is the
    escalation."""
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
        if action == "ceiling":
            cpath = os.path.join(root, "build", "claude-campaign-ceiling.json")
            try:
                with open(cpath, encoding="utf-8") as fh:
                    seen = json.load(fh)
            except FileNotFoundError:
                seen = {}
            except (OSError, ValueError):
                raise GuardError("the ceiling record is unreadable; escalate rather than wait again")
            if not run_id:
                raise GuardError("repair ceiling needs --run-id <GitHub run id>")
            if seen.get(run_id, 0) >= 1:
                return 1, (f"repair: run {run_id} already had its one re-run past the ceiling: escalate "
                           f"(a queue that never drains is outside the tree)")
            seen[run_id] = seen.get(run_id, 0) + 1
            with open(cpath + ".tmp", "w", encoding="utf-8") as fh:
                json.dump(seen, fh)
            os.replace(cpath + ".tmp", cpath)
            return 0, f"repair: run {run_id} may re-run ci-wait once more past the ceiling"
        # Only a missing file means no episode: a file holding anything but
        # a well-formed episode (a JSON null included) refuses (panel round 2).
        if exists and not (isinstance(ep, dict) and isinstance(ep.get("episode"), str)
                           and isinstance(ep.get("attempts"), list)):
            raise GuardError(f"the repair episode {path} is malformed; the bound cannot be counted, "
                             f"so escalate rather than repair")
        if action == "restore":
            if ep:
                return 0, f"repair: episode {ep['episode'][:12]} is present; nothing to restore"
            if not workflow or not run_file:
                raise GuardError("repair restore needs --workflow and --run-file: the restored episode is bound to both")
            found = _episode_from_run_file(root, run_file)
            if not found:
                return 0, "repair: the run file shows no open episode; nothing to restore"
            # D00 T04 §38: the journal carries the episode's identity, and a
            # restore recovers it from there, refusing a caller elsewhere.
            if any(f[3] is None for f in found):
                raise GuardError(f"{run_file} records attempts without their repository, branch, and workflow "
                                 f"(a legacy journal): the identity cannot be recovered, so restore refuses; "
                                 f"escalate rather than rebind the episode")
            idents = {(f[3], f[4], f[5]) for f in found}
            if len(idents) > 1:
                raise GuardError(f"{run_file} mixes attempts from {len(idents)} identities (a mixed journal): "
                                 f"restore refuses; escalate")
            repo, branch, wf = next(iter(idents))
            here = _repo_identity(root)
            for key, was, now in (("repository", repo, here["repo"] or "-"),
                                  ("branch", branch, here["branch"] or "-"), ("workflow", wf, workflow)):
                if was != now:
                    raise GuardError(f"the journal's episode belongs to {key} {was!r}, not {now!r}: "
                                     f"restore refuses to rebind it")
            ep = {"episode": _canon(root, found[0][2]),
                  "attempts": [{"red": _canon(root, f[2]), "commit": _canon(root, f[1])} for f in found],
                  "repo": here["repo"], "branch": here["branch"], "workflow": workflow, "run_file": run_file,
                  "restored": True}
            with open(path + ".tmp", "w", encoding="utf-8") as fh:
                json.dump(ep, fh, indent=1)
            os.replace(path + ".tmp", path)
            return 0, (f"repair: episode {ep['episode'][:12]} restored from {run_file} at "
                       f"{len(ep['attempts'])} of {REPAIR_BOUND} attempts")
        if action == "status":
            if not ep:
                lost = _episode_from_run_file(root, run_file) if run_file else []
                if lost:
                    return 1, (f"repair: the episode file is lost but {run_file} shows episode {lost[0][0]} at "
                               f"{len(lost)} of {REPAIR_BOUND} attempts: run repair restore before any repair")
                return 0, "repair: no open episode"
            return 0, (f"repair: episode {ep['episode'][:12]} open, {len(ep['attempts'])} of "
                       f"{REPAIR_BOUND} attempts used")
        identity = {**_repo_identity(root), "workflow": workflow, "run_file": run_file}
        if ep and action in ("attempt", "close"):
            for key in ("repo", "branch", "workflow", "run_file"):
                if ep.get(key, identity[key]) != identity[key]:
                    raise GuardError(f"the open episode belongs to {key} {ep.get(key)!r}, not {identity[key]!r}; "
                                     f"refusing to mix episodes")
        if action == "close":
            if not green:
                raise GuardError("repair close needs --green <sha>")
            if not ep:
                return 0, "repair: no open episode to close"
            want = re.compile(rf"\Aci-wait: {re.escape(green[:12])}[0-9a-f]* {re.escape(workflow or ep.get('workflow', ''))} success\b")
            if not want.match(evidence or ""):
                raise GuardError("repair close needs --evidence with the green ci-wait line for this sha and "
                                 "workflow (an authorized no-run is not green)")
            last = ep["attempts"][-1]["commit"] if ep["attempts"] else ep["episode"]
            rc, _ = _git(root, "merge-base", "--is-ancestor", last, green)
            if rc != 0:
                raise GuardError(f"the green {green[:12]} does not descend from the last attempt {last[:12]}; "
                                 f"it cannot close this episode")
            os.unlink(path)
            return 0, (f"repair: episode {ep['episode'][:12]} closed green at {green[:12]} after "
                       f"{len(ep['attempts'])} attempt(s)")
        if action == "attempt":
            if not red or not commit or not workflow or not run_file:
                raise GuardError("repair attempt needs --red, --commit, --workflow, and --run-file")
            if not ep:
                lost = _episode_from_run_file(root, run_file)
                if lost:
                    raise GuardError(f"the run file shows open episode {lost[0][0]} but its file is lost: "
                                     f"run repair restore first")
            red, commit = _canon(root, red), _canon(root, commit)
            ep = ep or {"episode": red, "attempts": [], **identity}
            done = [a for a in ep["attempts"] if _canon(root, a.get("commit", "")) == commit]
            if done:
                n = ep["attempts"].index(done[0]) + 1
                return 0, (f"repair: episode {ep['episode'][:12]} attempt {n} of {REPAIR_BOUND} "
                           f"({commit[:12]} repairs {done[0]['red'][:12]}){_ident_suffix(ep)} already counted")
            if len(ep["attempts"]) >= REPAIR_BOUND:
                return 1, (f"repair: episode {ep['episode'][:12]} has used all {REPAIR_BOUND} attempts: "
                           f"the bound is exhausted, escalate (PARKED ... escalation:, then end --reason escalation)")
            ep["attempts"].append({"red": red, "commit": commit})
            tmp = path + ".tmp"
            with open(tmp, "w", encoding="utf-8") as fh:
                json.dump(ep, fh, indent=1)
            os.replace(tmp, path)
            return 0, (f"repair: episode {ep['episode'][:12]} attempt {len(ep['attempts'])} of "
                       f"{REPAIR_BOUND} ({commit[:12]} repairs {red[:12]}){_ident_suffix(ep)}")
        raise GuardError(f"repair action {action!r} is not attempt, close, status, restore, or ceiling")


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


def _cl(*jobs: tuple[str, str]) -> str:
    """A `CronList` printout naming `jobs` as (id, prompt), in the shape
    the tool prints (the prompt cut near 80 characters)."""
    lines = []
    for jid, prompt in jobs:
        shown = prompt if len(prompt) <= 79 else prompt[:79] + "\u2026"
        lines.append(f"{jid} \u2014 3-59/5 * * * * (recurring) [session-only]: {shown}")
    return "\n".join(lines)


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
        # D00 T04 §34, §38: the failure is recorded for the heartbeat in a
        # file of its own, never in the state: the hook failed before it
        # read an owner, so the record names none. It is reported through
        # the still-malformed guard, then cleared by its id.
        st = _state(root)
        errs = _hook_errors(root)
        check("a-thrown-error-is-recorded",
              "hook_error" not in st and len(errs) == 1 and bool(errs[0].get("id")) and bool(errs[0].get("at"))
              and errs[0].get("session") == "" and errs[0].get("run_id") == "", f"{st} {errs}")
        line = hook_error(root, SESSION)
        eid = errs[0]["id"] if errs else ""
        check("hook-error-reports-through-a-malformed-guard",
              line.startswith("campaign-stop hook failed at ") and "guard file is unreadable" in line
              and f"[id={eid} session=unknown run=unknown generation=unknown]" in line, line)
        # D00 T04 §36, §38: printing clears nothing; only an ack naming the
        # recorded id clears it, and a fenced ack waits for a readable guard.
        try:
            hook_error(root, SESSION, ack="000000000000", generation="g", cron_id="job-1")
            check("hook-error-refuses-an-unfenceable-ack", False)
        except GuardError as exc:
            check("hook-error-refuses-an-unfenceable-ack",
                  "cannot be fenced" in str(exc) and len(_hook_errors(root)) == 1, str(exc))
        _guard(root)
        hook_error(root, SESSION)  # a locked read: the legacy guard gains its run id and generation
        gfix = str(read_guard(root).get("generation"))
        try:
            hook_error(root, SESSION, ack="000000000000", generation=gfix, cron_id="job-1")
            check("hook-error-refuses-a-mismatched-ack", False)
        except GuardError as exc:
            check("hook-error-refuses-a-mismatched-ack",
                  "no recorded error has id 000000000000" in str(exc) and len(_hook_errors(root)) == 1, str(exc))
        cleared = hook_error(root, SESSION, ack=eid, generation=gfix, cron_id="job-1")
        check("hook-error-clears-on-the-exact-ack",
              cleared.startswith("hook-error: acknowledged and cleared") and _hook_errors(root) == [], cleared)
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
        hook_error(root, ack="state")
        check("hook-error-reports-then-clears-on-ack",
              line.startswith("campaign-stop hook failed at 2099-01-01T00:00:00Z [id=state ")
              and "hook_error" not in _state(root) and hook_error(root) == "", f"{line!r} {_state(root)}")

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
        folder = os.path.join(root, "build", "claude-campaign-hook-errors")
        files = sorted(os.listdir(folder)) if os.path.isdir(folder) else []
        logged = "".join(open(os.path.join(folder, n), encoding="utf-8").read() for n in files)
        check("a-lock-timeout-fails-open-into-an-error-file",
              code == 0 and out is None and len(files) == 1 and "guard lock stayed held" in logged,
              f"{out} {err} {files} {logged!r}")
        shutil.rmtree(folder)

        # D00 T04 §36 independent review: an error written to the fallback
        # log (the lock was unavailable) reaches the heartbeat too.
        os.makedirs(os.path.join(root, "build", "claude-campaign-hook-errors"), exist_ok=True)
        with open(os.path.join(root, "build", "claude-campaign-hook-errors", "00000000000000000001-1.txt"), "w",
                  encoding="utf-8") as fh:
            fh.write("2099-01-01T00:00:00Z the guard lock stayed held for 300ms")
        st_path = os.path.join(root, "build", "claude-campaign-state.json")
        if os.path.exists(st_path):
            st_now = _state(root)
            st_now.pop("hook_error", None)
            with open(st_path, "w", encoding="utf-8") as fh:
                json.dump(st_now, fh)
        line = hook_error(root)
        check("hook-error-reads-the-fallback-log",
              line == "campaign-stop hook failed at 2099-01-01T00:00:00Z [id=1 session=unknown run=unknown "
                      "generation=unknown]: the guard lock stayed held for 300ms", line)
        hook_error(root, ack="1")
        check("hook-error-ack-drains-the-fallback-log", hook_error(root) == "", hook_error(root))

        # D00 T04 §34: an escalation parks and ends the run before its report.
        with open(run_path, "a", encoding="utf-8") as fh:
            # The guard was migrated by the locked reads above, so only a
            # marker carrying its run id counts (D00 T04 §38).
            fh.write(f"\nPARKED 2099-01-01T00:00:00Z run={read_guard(root)['run_id']} escalation: "
                     f"repair bound exhausted on D90 T01 §1\n")
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
        check("whoami-owner-names-the-run",
              whoami(lroot, SESSION, g1) == f"OWNER run={read_guard(lroot)['run_id']} job=job-a",
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
        with open(run, "a", encoding="utf-8") as fh:
            fh.write(f"\n- run guard: job job-b generation {g2}\n")
        rc = reconcile(lroot, SESSION, _cl(("job-b", heartbeat_tag(lroot, g2, RUN_FILE))))
        check("reconcile-consistent", rc == ["reconcile: consistent (guard and job job-b)"], str(rc))
        rc = reconcile(lroot, SESSION, _cl(("job-a", heartbeat_tag(lroot, g1, RUN_FILE))))
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
            check("cancel-confirmed-refuses-another-job", "no pending cancellation names job job-zzz" in str(exc), str(exc))
        check("cancel-confirmed-clears-the-pending-record",
              cancel_confirmed(lroot, "job-b").startswith("cancel-confirmed: job job-b is gone")
              and pending_cancel(lroot) == "")
        check("reconcile-orphan-job",
              reconcile(lroot, SESSION, _cl(("job-x", heartbeat_tag(lroot, g2, RUN_FILE))), RUN_FILE)
              == ["reconcile: orphan job job-x has no guard: CronDelete it"])
        # Two unconfirmed cancellations are both kept (panel round 1).
        with open(run, "w", encoding="utf-8") as fh:
            fh.write("# run\n")
        acquire(lroot, SESSION, 0, RUN_FILE, "job-p1")
        end(lroot, SESSION, "operator-stop")
        acquire(lroot, SESSION, 0, RUN_FILE, "job-p2")
        end(lroot, SESSION, "operator-stop")
        pend = pending_cancel(lroot)
        check("pending-cancellations-accumulate", "CronDelete job-p1" in pend and "CronDelete job-p2" in pend, pend)
        check("reconcile-surfaces-a-pending-cancellation",
              any("pending cancellation is unconfirmed: CronDelete job-p1" in r
                  for r in reconcile(lroot, SESSION, "", RUN_FILE)))
        cancel_confirmed(lroot, "job-p1")
        cancel_confirmed(lroot, "job-p2")
        check("pending-cancellations-drain-one-by-one", pending_cancel(lroot) == "", pending_cancel(lroot))

        def _interleave(change: str) -> tuple:
            """Hold the guard lock in another process, start the hook (it
            reads the guard, then waits on the lock), apply `change` under
            the held lock, release, and return what the hook did."""
            for f in _paths(lroot):
                if os.path.exists(f):
                    os.remove(f)
            with open(run, "w", encoding="utf-8") as fh:
                fh.write("# run\n")
            acquire(lroot, SESSION, 0, RUN_FILE, "job-i")
            go = os.path.join(ltmp, "go.flag")
            if os.path.exists(go):
                os.remove(go)
            holder = subprocess.Popen(
                [sys.executable, "-c",
                 "import os, sys, time; sys.path.insert(0, sys.argv[1]); import campaign_guard as cg\n"
                 "root, change, go = sys.argv[2], sys.argv[3], sys.argv[4]\n"
                 "with cg._Lock(root):\n"
                 "    print('held', flush=True)\n"
                 "    while not os.path.exists(go): time.sleep(0.05)\n"
                 "    if change == 'handover':\n"
                 "        cg._acquire_locked(root, 'cccccccc-0000-0000-0000-000000000000', 0, cg.RUN_FILE, 'job-h', 'drill')\n"
                 "    else:\n"
                 "        g = cg.read_guard(root)\n"
                 "        cg._end_locked(root, g['session_id'], 'operator-stop', None)\n"
                 "    time.sleep(0.5)",
                 HERE, lroot, change, go], stdout=subprocess.PIPE, text=True)
            holder.stdout.readline()
            # The payload rides a file, so communicate() never touches a pipe
            # this test closed (panel round 2).
            payload_file = os.path.join(ltmp, "payload.json")
            with open(payload_file, "w", encoding="utf-8") as fh:
                json.dump({"session_id": SESSION, "cwd": lroot, "hook_event_name": "Stop"}, fh)
            payload_in = open(payload_file, "rb")
            hook = subprocess.Popen([_powershell(), "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", HOOK],
                                    stdin=payload_in, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                    text=True, encoding="utf-8", errors="replace",
                                    env=dict(os.environ, CLAUDE_PROJECT_DIR=lroot))
            import time as _t
            _t.sleep(3)  # the hook has read the guard and now waits on the lock
            open(go, "w").close()
            out_h, err_h = hook.communicate(timeout=60)
            payload_in.close()
            holder.wait()
            return out_h.strip(), err_h, _state(lroot), read_guard(lroot)

        out_h, err_h, st_h, g_h = _interleave("handover")
        check("a-handover-while-the-hook-waits-writes-no-state",
              out_h == "" and "guard changed while this hook waited" in err_h and st_h == {}
              and g_h["session_id"].startswith("cccccccc"), f"{out_h!r} {err_h!r} {st_h} {g_h}")
        out_h, err_h, st_h, g_h = _interleave("end")
        check("an-end-while-the-hook-waits-writes-no-state",
              out_h == "" and "guard changed while this hook waited" in err_h and st_h == {} and g_h is None,
              f"{out_h!r} {err_h!r} {st_h} {g_h}")
        for j in ("job-i",):
            try:
                cancel_confirmed(lroot, j)
            except GuardError:
                pass
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
            os.environ["CAMPAIGN_HASH_BYTES"] = "3"
            try:
                st = _tripped_then(os.path.join(cov, "f1.txt"), keep_time=True)
                check("coverage-a-file-past-the-size-bound-counts-by-size-and-time", st.get("trips") == 1, str(st))
                # D00 T04 §38: the summary shows how the paths counted.
                with open(os.path.join(cov, "f6.txt"), "w", encoding="utf-8") as fh:
                    fh.write("new\n")
                code, out, _ = run_hook(lroot, SESSION)
                check("coverage-summary-past-the-size-bound",
                      isinstance(out, dict) and "Fingerprint coverage: 0 untracked path(s) hashed, 4 by size and "
                      "write time, 3 by name only." in out.get("reason", "")
                      and _state(lroot).get("coverage") == {"hashed": 0, "statted": 4, "named": 3},
                      f"{out} {_state(lroot)}")
            finally:
                del os.environ["CAMPAIGN_HASH_BYTES"]
            with open(os.path.join(cov, "f7.txt"), "w", encoding="utf-8") as fh:
                fh.write("new\n")
            code, out, _ = run_hook(lroot, SESSION)
            check("coverage-summary-past-the-hash-and-stat-bounds",
                  isinstance(out, dict) and "Fingerprint coverage: 2 untracked path(s) hashed, 2 by size and "
                  "write time, 4 by name only." in out.get("reason", "")
                  and _state(lroot).get("coverage") == {"hashed": 2, "statted": 2, "named": 4},
                  f"{out} {_state(lroot)}")
        finally:
            for k in env_bounds:
                del os.environ[k]

    # D00 T04 §38: identity fencing, cancellation ownership, scoped
    # reconciliation, crash-consistent publication, legacy migration,
    # error identity, and what a handover keeps, in a fixture of their own.
    with tempfile.TemporaryDirectory(prefix="campaign-ident-") as itmp:
        iroot = _workspace(itmp)
        irun = os.path.join(iroot, RUN_FILE)
        OTHER = "88888888-0000-0000-0000-000000000000"

        def _cli(*args: str, env: dict | None = None, stdin: str | None = None) -> subprocess.CompletedProcess:
            return subprocess.run([sys.executable, os.path.join(HERE, "campaign_guard.py"), *args, "--root", iroot],
                                  capture_output=True, text=True, encoding="utf-8", input=stdin,
                                  env=dict(os.environ, PYTHONIOENCODING="utf-8", **(env or {})))

        def _reset(body: str = "# run\n") -> None:
            for f in (*_paths(iroot), _pending_path(iroot)):
                if os.path.exists(f):
                    os.remove(f)
            if os.path.isdir(_errors_dir(iroot)):
                shutil.rmtree(_errors_dir(iroot))
            with open(irun, "w", encoding="utf-8") as fh:
                fh.write(body)

        # Every mutation re-checks generation and job under the lock: an
        # obsolete heartbeat (the generation or job the guard replaced) is
        # refused at each one, and nothing changes.
        _reset()
        g_old, g_new = mint_generation(), mint_generation()
        acquire(iroot, SESSION, 0, RUN_FILE, "job-old", generation=g_old)
        acquire(iroot, SESSION, 0, RUN_FILE, "job-new", generation=g_new)
        rid = read_guard(iroot)["run_id"]
        with open(irun, "a", encoding="utf-8") as fh:
            fh.write(f"\nPARKED 2099-01-01T00:00:00Z run={rid} drill\n")
        for label, call in (
                ("end", lambda g, j: end(iroot, SESSION, "park", g, j)),
                ("reset-state", lambda g, j: reset_state(iroot, SESSION, False, g, j)),
                ("hook-error-ack", lambda g, j: hook_error(iroot, SESSION, "x", g, j))):
            for what, g, j in (("generation", g_old, "job-new"), ("job", g_new, "job-old")):
                try:
                    call(g, j)
                    check(f"fence-{label}-refuses-an-obsolete-{what}", False, "changed")
                except GuardError as exc:
                    check(f"fence-{label}-refuses-an-obsolete-{what}",
                          "obsolete; nothing changed" in str(exc) and read_guard(iroot)["cron_id"] == "job-new",
                          str(exc))
        for cmd in (["end", "--session", SESSION, "--reason", "park"],
                    ["reset-state", "--session", SESSION],
                    ["hook-error", "--session", SESSION, "--ack", "x"],
                    ["cancel-confirmed", "--cron-id", "job-new"]):
            r = _cli(*cmd)
            check(f"cli-{cmd[0]}-requires-its-fence", r.returncode == 1 and "D00 T04 §38" in r.stderr
                  and read_guard(iroot) is not None, r.stderr)
        r = _cli("end", "--session", SESSION, "--reason", "park", "--generation", g_new, "--cron-id", "job-new",
                 "--run", rid)
        check("fence-end-passes-the-current-identity",
              r.returncode == 0 and read_guard(iroot) is None
              and f"cancel-confirmed --session {SESSION} --cron-id job-new --generation {g_new}" in r.stdout,
              r.stdout + r.stderr)
        # The cancellation record names its scheduling session: an obsolete
        # generation or another session's confirmation is refused.
        try:
            cancel_confirmed(iroot, "job-new", SESSION, g_old)
            check("fence-cancel-confirmed-refuses-an-obsolete-generation", False)
        except GuardError as exc:
            check("fence-cancel-confirmed-refuses-an-obsolete-generation",
                  f"carries generation {g_new}" in str(exc) and "job-new" in pending_cancel(iroot), str(exc))
        pend_other = pending_cancel(iroot, OTHER)
        check("pending-cancel-reports-another-sessions-job",
              pend_other.startswith(f"pending-cancel: report job job-new generation={g_new}: session {SESSION}")
              and "do not cancel it here" in pend_other, pend_other)
        try:
            cancel_confirmed(iroot, "job-new", OTHER, g_new)
            check("cancel-confirmed-refuses-another-sessions-job", False)
        except GuardError as exc:
            check("cancel-confirmed-refuses-another-sessions-job", "report it rather than confirm it" in str(exc),
                  str(exc))
        rc = reconcile(iroot, OTHER, "", RUN_FILE)
        check("reconcile-reports-a-predecessors-pending-job",
              any("scheduled by session" in r and "report it, do not cancel it" in r for r in rc), str(rc))
        # The NO GUARD branch drains this session's own record first.
        own = pending_cancel(iroot, SESSION)
        check("no-guard-branch-lists-its-own-job-to-delete",
              whoami(iroot, SESSION, g_new) == "NO GUARD"
              and own.startswith(f"pending-cancel: CronDelete job-new generation={g_new}"), own)
        r = _cli("cancel-confirmed", "--session", SESSION, "--cron-id", "job-new", "--generation", g_new)
        check("no-guard-branch-drains-its-own-job", r.returncode == 0 and pending_cancel(iroot) == "",
              r.stdout + r.stderr)

        # Two jobs carrying one generation: whoami names the one to delete,
        # and names the re-point when the guard's own job is the lost one.
        _reset()
        g = mint_generation()
        acquire(iroot, SESSION, 0, RUN_FILE, "job-1", generation=g)
        tag = heartbeat_tag(iroot, g, RUN_FILE)
        out = whoami(iroot, SESSION, g, _cl(("job-1", tag), ("job-2", tag), ("job-9", "an unrelated reminder")))
        check("whoami-names-a-duplicate-generation",
              out.splitlines()[0] == f"OWNER run={read_guard(iroot)['run_id']} job=job-1"
              and "DUPLICATE GENERATION: CronDelete job-2 (they carry generation" in out and "job-9" not in out, out)
        out = whoami(iroot, SESSION, g, _cl(("job-2", tag), ("job-3", tag)))
        check("whoami-re-points-to-a-live-duplicate",
              "the guard's job job-1 is not live and job-2 carries its generation: re-point first" in out
              and "CronDelete job-3" in out, out)
        r = _cli("whoami", "--session", SESSION, "--generation", g, "--cronlist", "-",
                 stdin=_cl(("job-1", tag), ("job-2", tag)))
        check("whoami-reads-the-cronlist-from-stdin", "CronDelete job-2" in r.stdout, r.stdout + r.stderr)
        check("heartbeat-tag-fits-the-cronlist-cut",
              len(heartbeat_tag(REPO, g, "docs/phase-runs/2026-12-31-phase-10.md")) < 79
              and parse_cronlist(_cl(("abc123", heartbeat_tag(REPO, g, "docs/phase-runs/2026-12-31-phase-10.md")
                                      + ": the campaign for Resolute Phase 10, run file ...")))[0][0] == "abc123",
              heartbeat_tag(REPO, g, "docs/phase-runs/2026-12-31-phase-10.md"))

        # Scoped reconciliation, and each startup interruption recovering to
        # exactly one current heartbeat and a consistent run record.
        other_run = "docs/phase-runs/2099-02-02-phase-1.md"
        noise = _cl(("x-repo", f"Claude run-guard heartbeat {g} OtherRepo {run_stem(RUN_FILE)}: ..."),
                    ("x-run", heartbeat_tag(iroot, g, other_run) + ": ..."),
                    ("x-legacy", "Claude run-guard heartbeat for Resolute Phase 0 (run file docs/phase-runs/20"),
                    ("x-plain", "remind me at 3pm"))
        _reset()
        rc = reconcile(iroot, SESSION, noise, RUN_FILE)
        check("reconcile-scopes-by-repository-and-run-file",
              "reconcile: job x-repo is a heartbeat for OtherRepo" in "\n".join(rc)
              and f"job x-run is a heartbeat for {repo_name(iroot)} {run_stem(other_run)}, not this run" in "\n".join(rc)
              and "job x-legacy is a legacy heartbeat" in "\n".join(rc)
              and not any("x-plain" in r or "orphan" in r for r in rc), str(rc))
        # (1) CronCreate landed, acquire never ran: the job is an orphan.
        g1 = mint_generation()
        live = [("job-c1", heartbeat_tag(iroot, g1, RUN_FILE) + ": ...")]
        rc = reconcile(iroot, SESSION, _cl(*live), RUN_FILE)
        live = []  # the runner deletes it
        rc2 = reconcile(iroot, SESSION, _cl(*live), RUN_FILE)
        check("interrupted-after-croncreate-recovers",
              rc == ["reconcile: orphan job job-c1 has no guard: CronDelete it"]
              and rc2 == ["reconcile: consistent (no guard, no job)"], f"{rc} {rc2}")
        # (2) acquire landed, the run file never recorded it.
        g2 = mint_generation()
        live = [("job-c2", heartbeat_tag(iroot, g2, RUN_FILE) + ": ...")]
        acquire(iroot, SESSION, 0, RUN_FILE, "job-c2", generation=g2)
        rc = reconcile(iroot, SESSION, _cl(*live))
        with open(irun, "a", encoding="utf-8") as fh:
            fh.write(f"\n- run guard: heartbeat job-c2 generation {g2}\n")
        rc2 = reconcile(iroot, SESSION, _cl(*live))
        check("interrupted-before-the-run-record-recovers",
              rc == [f"reconcile: {RUN_FILE} does not record job job-c2 generation {g2}: append the Critical "
                     f"events line before starting"]
              and rc2 == ["reconcile: consistent (guard and job job-c2)"], f"{rc} {rc2}")
        # (3) a re-point's CronCreate landed, its acquire did not: the old
        # job and the new one both live, the guard still names the old.
        g3 = mint_generation()
        live = [("job-c2", heartbeat_tag(iroot, g2, RUN_FILE)), ("job-c3", heartbeat_tag(iroot, g3, RUN_FILE))]
        rc = reconcile(iroot, SESSION, _cl(*live))
        check("interrupted-mid-re-point-keeps-exactly-one",
              rc == ["reconcile: stale job job-c3 is not the guard's: CronDelete it"], str(rc))

        # Crash-consistent publication: a change killed at each step reads
        # back as one consistent lifecycle.
        def _crashed(label: str, *args: str) -> subprocess.CompletedProcess:
            return _cli(*args, env={"CAMPAIGN_CRASH_AT": label})

        _reset()
        r = _crashed("acquire:create-tmp", "acquire", "--session", SESSION, "--run-file", RUN_FILE,
                     "--cron-id", "job-k", "--generation", "aaaaaaaaaaaa")
        after = acquire(iroot, SESSION, 0, RUN_FILE, "job-k2", generation="bbbbbbbbbbbb")
        check("crash-before-the-guard-publishes-leaves-no-guard",
              r.returncode == 97 and after.startswith("acquire: guard created")
              and not [n for n in os.listdir(os.path.join(iroot, "build")) if n.endswith(".tmp")], after)
        _reset()
        with open(_paths(iroot)[1], "w", encoding="utf-8") as fh:
            json.dump({"fingerprint": "x", "blocks": 2, "trips": 1, "run_id": "0ld0ld0ld0ld"}, fh)
        r = _crashed("acquire:create-published", "acquire", "--session", SESSION, "--run-file", RUN_FILE,
                     "--cron-id", "job-k", "--generation", "cccccccccccc")
        code, out, _ = run_hook(iroot, SESSION)
        st = _state(iroot)
        check("crash-before-the-state-reset-reads-a-fresh-breaker",
              r.returncode == 97 and isinstance(out, dict) and out.get("decision") == "block"
              and st.get("blocks") == 1 and st.get("trips") == 0 and st.get("run_id") == read_guard(iroot)["run_id"],
              f"{r.returncode} {out} {st}")
        r = _crashed("acquire:repoint-tmp", "acquire", "--session", SESSION, "--run-file", RUN_FILE,
                     "--cron-id", "job-r", "--generation", "dddddddddddd")
        check("crash-before-a-re-point-publishes-keeps-the-old-guard",
              r.returncode == 97 and read_guard(iroot)["cron_id"] == "job-k"
              and whoami(iroot, SESSION, "cccccccccccc").startswith("OWNER"), str(read_guard(iroot)))
        rid = read_guard(iroot)["run_id"]
        with open(irun, "a", encoding="utf-8") as fh:
            fh.write(f"\nPARKED 2099-01-01T00:00:00Z run={rid} drill\n")
        end_args = ("end", "--session", SESSION, "--reason", "park", "--generation", "cccccccccccc",
                    "--cron-id", "job-k")
        r = _crashed("end:pending-tmp", *end_args)
        check("crash-before-the-pending-record-leaves-the-run-live",
              r.returncode == 97 and read_guard(iroot) is not None and pending_cancel(iroot) == "",
              pending_cancel(iroot))
        r = _crashed("end:pending-published", *end_args)
        pend = pending_cancel(iroot, SESSION)
        try:
            cancel_confirmed(iroot, "job-k", SESSION, "cccccccccccc")
            refused = False
        except GuardError as exc:
            refused = "the end did not finish" in str(exc)
        check("crash-after-the-pending-record-reads-as-an-unfinished-end",
              r.returncode == 97 and read_guard(iroot) is not None and refused
              and pend.startswith("pending-cancel: end incomplete for job job-k")
              and "pending-cancel: CronDelete" not in pend, pend)
        r = _crashed("end:guard-deleted", *end_args)
        code, out, _ = run_hook(iroot, SESSION)
        check("crash-after-the-guard-delete-leaves-an-orphan-state-no-hook-reads",
              r.returncode == 97 and read_guard(iroot) is None and os.path.exists(_paths(iroot)[1])
              and out is None and whoami(iroot, SESSION, "cccccccccccc") == "NO GUARD"
              and reset_state(iroot, expect_no_guard=True) == "reset-state: state deleted"
              and pending_cancel(iroot, SESSION).startswith("pending-cancel: CronDelete job-k"), str(out))
        cancel_confirmed(iroot, "job-k", SESSION, "cccccccccccc")

        # A legacy guard gains a run id at its first locked access; after
        # that a reused run file's untagged marker no longer ends the run.
        _reset("# old run\n\nPARKED 2098-01-01T00:00:00Z an earlier run parked here\n")
        _guard(iroot)
        code, out, _ = run_hook(iroot, SESSION)
        before = out is None
        mig = whoami(iroot, SESSION)
        g_l = read_guard(iroot)
        code, out, _ = run_hook(iroot, SESSION)
        check("a-legacy-guard-migrates-at-its-first-locked-access",
              before and mig == f"OWNER run={g_l.get('run_id')} job=job-1" and bool(g_l.get("generation"))
              and isinstance(out, dict) and out.get("decision") == "block", f"{before} {mig} {out}")
        try:
            end(iroot, SESSION, "park", g_l["generation"], "job-1")
            check("a-migrated-guard-refuses-the-untagged-marker", False)
        except GuardError as exc:
            check("a-migrated-guard-refuses-the-untagged-marker", "PARKED <UTC> run=" in str(exc), str(exc))
        with open(irun, "a", encoding="utf-8") as fh:
            fh.write(f"\nPARKED 2099-01-01T00:00:00Z run={g_l['run_id']} this run parked\n")
        check("a-migrated-guard-ends-on-its-tagged-marker",
              end(iroot, SESSION, "park", g_l["generation"], "job-1").startswith("end: park"))
        cancel_confirmed(iroot, "job-1", SESSION, g_l["generation"])

        # Hook errors carry an id and their origin: two identical errors
        # are two records, and a delivery from before a handover reads as
        # the old session's.
        _reset()
        g = mint_generation()
        acquire(iroot, SESSION, 0, RUN_FILE, "job-e", generation=g)
        rid = read_guard(iroot)["run_id"]
        os.makedirs(_errors_dir(iroot), exist_ok=True)
        for n in (1, 2):
            with open(os.path.join(_errors_dir(iroot), f"0000000000000000000{n}-1-e{n:011d}.json"), "w",
                      encoding="utf-8") as fh:
                json.dump({"id": f"e{n:011d}", "at": "2099-01-01T00:00:00Z", "reason": "the same failure",
                           "session": SESSION, "run_id": rid, "generation": g}, fh)
        lines = hook_error(iroot, SESSION).splitlines()
        hook_error(iroot, SESSION, "e00000000001", g, "job-e")
        rest = hook_error(iroot, SESSION).splitlines()
        check("two-identical-errors-are-two-records",
              len(lines) == 2 and lines[0] != lines[1] and len(rest) == 1 and "id=e00000000002" in rest[0]
              and f"session={SESSION} run={rid} generation={g}" in rest[0], f"{lines} {rest}")
        # A real hook failure after the owner was read carries its identity.
        with open(_paths(iroot)[1], "w", encoding="utf-8") as fh:
            fh.write("{broken state")
        run_hook(iroot, SESSION)
        rec = [e for e in _hook_errors(iroot) if e.get("id") != "e00000000002"]
        check("a-hook-error-after-the-owner-read-carries-its-identity",
              len(rec) == 1 and rec[0].get("session") == SESSION and rec[0].get("run_id") == rid
              and rec[0].get("generation") == g, str(rec))
        for e in rec:
            hook_error(iroot, SESSION, e["id"], g, "job-e")
        os.remove(_paths(iroot)[1])
        # What a handover keeps: the breaker's blocks and trips, and every
        # unacknowledged error, attributed to the session that raised it.
        with open(_paths(iroot)[1], "w", encoding="utf-8") as fh:
            json.dump({"fingerprint": "f", "blocks": 2, "trips": 1, "stalled": False, "run_id": rid,
                       "session": SESSION}, fh)
        g_h = mint_generation()
        acquire(iroot, OTHER, 0, RUN_FILE, "job-h", handover="drill", generation=g_h)
        st = _state(iroot)
        delivered = hook_error(iroot, OTHER)
        check("a-handover-keeps-the-breaker-and-the-errors",
              st.get("trips") == 1 and st.get("blocks") == 2 and read_guard(iroot)["run_id"] == rid
              and f"id=e00000000002 session={SESSION} run={rid}" in delivered, f"{st} {delivered}")
        check("a-post-handover-delivery-reads-as-the-old-sessions",
              f"session={OTHER}" not in delivered and hook_error(iroot, OTHER, "e00000000002", g_h, "job-h")
              .startswith("hook-error: acknowledged and cleared"), delivered)
        acquire(iroot, OTHER, 1, other_run, "job-n", generation=mint_generation())
        check("a-new-run-starts-a-clean-breaker", _state(iroot) == {} and read_guard(iroot)["run_id"] != rid,
              str(_state(iroot)))

    # D00 T04 §35, §37: the repair episode survives a restart, refuses a
    # fourth attempt, binds its identity, counts a repeat once, closes only
    # on proven green, and is restored from the run file when lost.
    with tempfile.TemporaryDirectory(prefix="campaign-repair-") as rtmp:
        os.makedirs(os.path.join(rtmp, "build"))
        os.makedirs(os.path.join(rtmp, "docs"))
        for args in (["init", "-q"], ["config", "user.email", "t@t"], ["config", "user.name", "t"],
                     ["config", "commit.gpgsign", "false"]):
            subprocess.run(["git", *args], cwd=rtmp, capture_output=True, check=True)
        with open(os.path.join(rtmp, ".gitignore"), "w", encoding="utf-8") as fh:
            fh.write("build/\n")
        shas = []
        for n in range(6):
            with open(os.path.join(rtmp, "f.txt"), "w", encoding="utf-8") as fh:
                fh.write(f"{n}\n")
            subprocess.run(["git", "add", "-A"], cwd=rtmp, capture_output=True, check=True)
            subprocess.run(["git", "commit", "-qm", f"c{n}"], cwd=rtmp, capture_output=True, check=True)
            shas.append(subprocess.run(["git", "rev-parse", "HEAD"], cwd=rtmp, capture_output=True,
                                       text=True).stdout.strip())
        runf = "docs/run.md"
        with open(os.path.join(rtmp, runf), "w", encoding="utf-8") as fh:
            fh.write("# run\n")

        def _repair_cli(*args: str) -> subprocess.CompletedProcess:
            return subprocess.run([sys.executable, os.path.join(HERE, "campaign_guard.py"), "repair", *args,
                                   "--root", rtmp], capture_output=True, text=True, encoding="utf-8")
        W = ("--workflow", "plan-gates", "--run-file", runf)
        outs = [_repair_cli("attempt", "--red", shas[n - 1], "--commit", shas[n], *W) for n in (1, 2, 3)]
        check("repair-attempts-count-across-processes",
              [o.returncode for o in outs] == [0, 0, 0] and "attempt 3 of 3" in outs[2].stdout
              and f"episode {shas[0][:12]}" in outs[2].stdout, str([o.stdout + o.stderr for o in outs]))
        again = _repair_cli("attempt", "--red", shas[1], "--commit", shas[2], *W)
        check("repair-counts-a-repeated-attempt-once",
              again.returncode == 0 and "already counted" in again.stdout, again.stdout + again.stderr)
        st = _repair_cli("status", "--run-file", runf)
        check("repair-status-reads-the-persisted-episode", "3 of 3 attempts used" in st.stdout, st.stdout)
        fourth = _repair_cli("attempt", "--red", shas[3], "--commit", shas[4], *W)
        check("repair-refuses-a-fourth-attempt-after-a-restart",
              fourth.returncode == 1 and "bound is exhausted, escalate" in fourth.stderr, fourth.stderr)
        other = _repair_cli("attempt", "--red", shas[3], "--commit", shas[4], "--workflow", "release",
                            "--run-file", runf)
        check("repair-refuses-a-mismatched-episode",
              other.returncode == 1 and "belongs to workflow 'plan-gates'" in other.stderr, other.stderr)
        with open(os.path.join(rtmp, "build", "claude-campaign-repair.json"), encoding="utf-8") as fh:
            saved = fh.read()
        for label, body in (("corrupt", "{not json"), ("malformed", '{"episode": 3}'), ("null", "null")):
            with open(os.path.join(rtmp, "build", "claude-campaign-repair.json"), "w", encoding="utf-8") as fh:
                fh.write(body)
            bad = _repair_cli("attempt", "--red", shas[3], "--commit", shas[5], *W)
            check(f"repair-refuses-{label}-state-rather-than-resetting",
                  bad.returncode == 1 and "escalate rather than repair" in bad.stderr, bad.stderr)
        with open(os.path.join(rtmp, "build", "claude-campaign-repair.json"), "w", encoding="utf-8") as fh:
            fh.write(saved)
        no_ev = _repair_cli("close", "--green", shas[5], *W, "--evidence", f"ci-wait: {shas[5][:12]} plan-gates started no run")
        check("repair-close-refuses-without-green-evidence",
              no_ev.returncode == 1 and "needs --evidence with the green ci-wait line" in no_ev.stderr, no_ev.stderr)
        not_desc = _repair_cli("close", "--green", shas[1], *W, "--evidence", f"ci-wait: {shas[1][:12]} plan-gates success x")
        check("repair-close-refuses-a-green-that-is-not-a-descendant",
              not_desc.returncode == 1 and "does not descend from the last attempt" in not_desc.stderr, not_desc.stderr)
        closed = _repair_cli("close", "--green", shas[5], *W, "--evidence", f"ci-wait: {shas[5][:12]} plan-gates success https://x")
        again2 = _repair_cli("attempt", "--red", shas[4], "--commit", shas[5], *W)
        check("repair-close-opens-a-fresh-episode",
              "closed green" in closed.stdout and again2.returncode == 0 and "attempt 1 of 3" in again2.stdout,
              f"{closed.stdout}{closed.stderr} {again2.stdout}{again2.stderr}")
        # A lost episode file is detected from the run file and restored.
        with open(os.path.join(rtmp, runf), "a", encoding="utf-8") as fh:
            fh.write(again2.stdout)
        os.remove(os.path.join(rtmp, "build", "claude-campaign-repair.json"))
        lost = _repair_cli("status", "--run-file", runf)
        check("repair-status-detects-a-lost-episode-file",
              lost.returncode == 1 and "the episode file is lost" in lost.stderr, lost.stdout + lost.stderr)
        blocked = _repair_cli("attempt", "--red", shas[5], "--commit", shas[3], *W)
        check("repair-attempt-refuses-until-restored",
              blocked.returncode == 1 and "run repair restore first" in blocked.stderr, blocked.stderr)
        no_wf = _repair_cli("restore", "--run-file", runf)
        check("repair-restore-refuses-without-a-workflow",
              no_wf.returncode == 1 and "needs --workflow and --run-file" in no_wf.stderr, no_wf.stderr)
        # An `already counted` line in the run file is not a second attempt.
        with open(os.path.join(rtmp, runf), "a", encoding="utf-8") as fh:
            fh.write(again2.stdout.strip() + " already counted\n")
        restored = _repair_cli("restore", *W)
        check("repair-restore-rebuilds-from-the-run-file",
              restored.returncode == 0 and "restored from docs/run.md at 1 of 3 attempts" in restored.stdout,
              restored.stdout + restored.stderr)
        full_retry = _repair_cli("attempt", "--red", shas[4], "--commit", shas[5], *W)
        check("repair-restored-attempts-compare-by-full-sha",
              full_retry.returncode == 0 and "already counted" in full_retry.stdout,
              full_retry.stdout + full_retry.stderr)
        # D00 T04 §38: the journal carries the episode's identity, and a
        # restore refuses any caller or journal that would rebind it.
        check("repair-attempt-lines-carry-the-identity",
              f" repo=- branch={_repo_identity(rtmp)['branch']} workflow=plan-gates" in again2.stdout, again2.stdout)
        here_branch = _repo_identity(rtmp)["branch"]
        subprocess.run(["git", "remote", "add", "origin", "https://example.invalid/here.git"], cwd=rtmp,
                       capture_output=True, check=True)

        def _journal(name: str, *idents: tuple | None) -> str:
            rel = f"docs/{name}.md"
            with open(os.path.join(rtmp, rel), "w", encoding="utf-8") as fh:
                for n, ident in enumerate(idents):
                    tail = "" if ident is None else f" repo={ident[0]} branch={ident[1]} workflow={ident[2]}"
                    fh.write(f"repair: episode {shas[3][:12]} attempt {n + 1} of 3 ({shas[4 + n][:12]} repairs "
                             f"{shas[3 + n][:12]}){tail}\n")
            return rel
        here = ("https://example.invalid/here.git", here_branch, "plan-gates")
        os.remove(os.path.join(rtmp, "build", "claude-campaign-repair.json"))
        for label, rel, wf, want in (
                ("cross-repository", _journal("j-repo", ("https://example.invalid/other.git", here_branch,
                                                          "plan-gates")), "plan-gates", "belongs to repository"),
                ("cross-branch", _journal("j-branch", ("https://example.invalid/here.git", "release/9",
                                                       "plan-gates")), "plan-gates", "belongs to branch 'release/9'"),
                ("cross-workflow", _journal("j-wf", here), "release", "belongs to workflow 'plan-gates'"),
                ("mixed", _journal("j-mixed", here, ("https://example.invalid/here.git", "release/9", "plan-gates")),
                 "plan-gates", "(a mixed journal)"),
                ("legacy", _journal("j-legacy", None), "plan-gates", "(a legacy journal)")):
            res = _repair_cli("restore", "--workflow", wf, "--run-file", rel)
            check(f"repair-restore-refuses-a-{label}-journal",
                  res.returncode == 1 and want in res.stderr
                  and not os.path.exists(os.path.join(rtmp, "build", "claude-campaign-repair.json")),
                  res.stdout + res.stderr)
        ok = _repair_cli("restore", "--workflow", "plan-gates", "--run-file", _journal("j-ok", here, here))
        check("repair-restore-recovers-a-matching-journal",
              ok.returncode == 0 and "at 2 of 3 attempts" in ok.stdout, ok.stdout + ok.stderr)
        c1 = _repair_cli("ceiling", "--run-id", "777")
        c2 = _repair_cli("ceiling", "--run-id", "777")
        check("repair-ceiling-allows-one-re-run-per-run",
              c1.returncode == 0 and c2.returncode == 1 and "already had its one re-run" in c2.stderr,
              c1.stdout + c2.stderr)

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
                        ("skill-heartbeat-ends-through-end",
                         "--reason plan-done --generation G --cron-id <job id>`, CronDelete this job"),
                        # D00 T04 §38: the heartbeat drains its own pending
                        # cancellations first, then asks who it is with the
                        # CronList text, and fences every later mutation.
                        ("skill-heartbeat-drains-its-own-cancellations-first",
                         "1. Run `python scripts/campaign_guard.py pending-cancel --session S`"),
                        ("skill-heartbeat-owner-first",
                         "2. Run CronList, then `python scripts/campaign_guard.py whoami --session S --generation G "
                         "--cronlist -`"),
                        ("skill-heartbeat-acks-by-id-fenced",
                         "hook-error --session S --generation G --cron-id <job id> --ack <the id inside"),
                        ("skill-heartbeat-prompt-leads-with-its-identity",
                         "Claude run-guard heartbeat <generation> <repository> <run file stem>: the campaign"),
                        ("skill-reconciles-before-starting",
                         "python scripts/campaign_guard.py reconcile --session $CLAUDE_CODE_SESSION_ID --run-file "
                         "<run file> --cronlist -"),
                        ("skill-checks-health-at-each-boundary", "python scripts/campaign_guard.py health --session"),
                        ("skill-checks-health-inside-long-sections", "at least every 60 minutes of wall time"),
                        ("skill-states-what-a-handover-keeps",
                         "a stalled campaign never gets a fresh allowance by changing hands"),
                        ("skill-states-the-publication-order",
                         "`end` publishes the pending-cancellation record, then deletes the guard, then the state"),
                        ("skill-confirms-the-cancel",
                         "python scripts/campaign_guard.py cancel-confirmed --session $CLAUDE_CODE_SESSION_ID --cron-id"),
                        ("skill-ends-fenced",
                         "--reason <closeout|park|plan-done|operator-stop|escalation> --generation <generation> "
                         "--cron-id <job id>"),
                        ("skill-marks-bookkeeping", "- bookkeeping: heartbeat resumed"),
                        ("skill-heartbeat-confirms-before-clearing",
                         "CronDelete this job, confirm it gone with CronList, then run `cancel-confirmed`"),
                        ("skill-markers-carry-the-run-id", "a closeout is a line `## Closeout run=<run id>`")):
        check(pin, needle in skill, plan_skill)
    # The canonical prompt's identity fits what CronList shows (D00 T04 §38).
    first = re.search(r"```text\n(Claude run-guard heartbeat [^\n]*)", skill)
    shown = (first.group(1).replace("<generation>", "0" * 12).replace("<repository>", "Resolute")
             .replace("<run file stem>", "2026-12-31-phase-10") if first else "")
    check("skill-prompt-identity-survives-the-cronlist-cut",
          classify_job(REPO, _cl(("j", shown)).split(": ", 1)[1]) == ("0" * 12, "Resolute", "2026-12-31-phase-10"),
          shown[:100])
    for other, needle in ((".claude/skills/process-phase/SKILL.md", "--reason escalation --generation <generation>"),
                          (".claude/skills/process-phase/SKILL.md", "at least every 60 minutes of wall time"),
                          (".claude/skills/review-todo-section/SKILL.md",
                           "--reason escalation --generation <generation>")):
        try:
            with open(os.path.join(REPO, other), encoding="utf-8") as fh:
                text = fh.read()
        except OSError:
            text = ""
        check(f"pin-{os.path.basename(os.path.dirname(other))}-{needle.split()[0].strip('-')}", needle in text, other)

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
                                ropts.get("green", ""), ropts.get("workflow", ""), ropts.get("run_file", ""),
                                ropts.get("evidence", ""), ropts.get("run_id", ""))
            print(line, file=sys.stdout if code == 0 else sys.stderr)
            return code
        opts = _opts(argv[1:])
        root = opts.pop("root", REPO)
        if argv[0] == "acquire":
            print(acquire(root, opts.get("session", ""), int(opts.get("phase", "0")),
                          opts.get("run_file", ""), opts.get("cron_id", ""), opts.get("handover"),
                          opts.get("generation")))
            return 0
        def need(*keys: str) -> None:
            missing = [k for k in keys if not opts.get(k)]
            if missing:
                raise GuardError(f"{argv[0]} needs " + ", ".join("--" + k.replace("_", "-") for k in missing)
                                 + " (D00 T04 §38: every mutation re-checks its caller's identity)")

        def cronlist(required: bool) -> str | None:
            src = opts.get("cronlist")
            if src is None:
                if required:
                    raise GuardError(f"{argv[0]} needs --cronlist (a file holding the CronList output, or - "
                                     f"for stdin): job ids are read from it, never vouched for")
                return None
            if src == "-":
                return sys.stdin.read()
            with open(src, encoding="utf-8-sig") as fh:
                return fh.read()
        if argv[0] == "end":
            need("session", "reason", "generation", "cron_id")
            print(end(root, opts["session"], opts["reason"], opts["generation"], opts["cron_id"], opts.get("run")))
            return 0
        if argv[0] == "hook-error" and set(opts) <= {"session", "ack", "generation", "cron_id"}:
            if "ack" in opts:
                need("session", "generation", "cron_id")
            line = hook_error(root, opts.get("session"), opts.get("ack"), opts.get("generation"), opts.get("cron_id"))
            if line:
                print(line)
            return 0
        if argv[0] == "mint-generation" and not opts:
            print(mint_generation())
            return 0
        if argv[0] == "heartbeat-tag":
            need("generation", "run_file")
            print(heartbeat_tag(root, opts["generation"], opts["run_file"]))
            return 0
        if argv[0] == "whoami":
            print(whoami(root, opts.get("session", ""), opts.get("generation"), cronlist(False)))
            return 0
        if argv[0] == "reset-state":
            if opts.get("expect_no_guard") != "yes":
                need("session", "generation", "cron_id")
            print(reset_state(root, opts.get("session"), opts.get("expect_no_guard") == "yes",
                              opts.get("generation"), opts.get("cron_id")))
            return 0
        if argv[0] == "pending-cancel" and set(opts) <= {"session"}:
            line = pending_cancel(root, opts.get("session"))
            if line:
                print(line)
            return 0
        if argv[0] == "cancel-confirmed":
            need("session", "cron_id", "generation")
            print(cancel_confirmed(root, opts["cron_id"], opts["session"], opts["generation"]))
            return 0
        if argv[0] == "reconcile":
            need("session")
            print("\n".join(reconcile(root, opts["session"], cronlist(True) or "", opts.get("run_file"))))
            return 0
        if argv[0] == "health":
            jobs = [j for j in opts.get("jobs", "").split(",") if j]
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
