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
    python scripts/campaign_guard.py delete-check --session S --cron-id J
    python scripts/campaign_guard.py quarantine --session S | recover --session S --run-file F
    python scripts/campaign_guard.py health --session S --jobs J1,J2
    python scripts/campaign_guard.py expiry --session S [--now ISO]
    python scripts/campaign_guard.py repair attempt --red SHA --commit SHA --workflow W --run-file F
    python scripts/campaign_guard.py repair close --green SHA --workflow W --run-file F --evidence LINE
    python scripts/campaign_guard.py repair pushed --commit SHA --run-file F | abandon --commit SHA --reason TEXT --run-file F [--remote R]
    python scripts/campaign_guard.py repair retire --workflow W --run-file F --evidence "<the NOT GREEN line>"
    python scripts/campaign_guard.py repair status|restore --run-file F [--workflow W] | ceiling --run-id ID [--attempt N] --run-file F
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


def _fail(label: str) -> None:
    """An injected failure (D00 T04 §40): the self-test fails a write, a
    replace, or a delete here, through `CAMPAIGN_FAIL_AT`, to prove a failed
    operation leaves a consistent lifecycle, not only an interrupted one."""
    if os.environ.get("CAMPAIGN_FAIL_AT") == label:
        raise OSError(f"injected failure at {label}")


def _publish(path: str, data: bytes) -> None:
    """Replace `path` atomically: a reader sees the old bytes or the new
    ones, never a torn file (D00 T04 §38). A failed write or replace
    leaves the old bytes and removes its temporary (D00 T04 §40)."""
    tmp = f"{path}.{os.getpid()}.tmp"
    try:
        _fail(f"write:{os.path.basename(path)}")
        with open(tmp, "wb") as fh:
            fh.write(data)
        _fail(f"replace:{os.path.basename(path)}")
        os.replace(tmp, path)
    except OSError:
        try:
            os.unlink(tmp)
        except OSError:
            pass
        raise


def _unlink(path: str, missing_ok: bool = False) -> None:
    """Delete `path`, failing on demand for the self-test (D00 T04 §40)."""
    _fail(f"unlink:{os.path.basename(path)}")
    try:
        os.unlink(path)
    except FileNotFoundError:
        if not missing_ok:
            raise


def repo_name(root: str) -> str:
    """The repository name a heartbeat prompt carries (the workspace folder)."""
    return os.path.basename(os.path.normpath(root))


def run_stem(run_file: str) -> str:
    return os.path.splitext(os.path.basename(run_file.replace("\\", "/")))[0]


def workspace_digest(root: str, run_file: str) -> str:
    """Twelve hex characters naming one workspace and one run file: the
    sha256 of the canonical workspace path and the run file, so two
    checkouts sharing a folder name, or a long path, never collide or
    overflow (D00 T04 §40)."""
    import hashlib
    canon = os.path.normcase(os.path.realpath(root))
    return hashlib.sha256(f"{canon}\n{run_file.replace(os.sep, '/')}".encode("utf-8")).hexdigest()[:12]


HEARTBEAT_TAG_LENGTH = 52


def heartbeat_tag(root: str, generation: str, run_file: str) -> str:
    """The canonical prompt's opening words, always HEARTBEAT_TAG_LENGTH
    characters. `CronList` shows only a prompt's first 80 or so
    characters, so the identity a job is scoped by (its generation and the
    workspace digest) leads the prompt (D00 T04 §38, §40)."""
    return f"Claude run-guard heartbeat {generation} {workspace_digest(root, run_file)}"


_HEARTBEAT = re.compile(r"Claude run-guard heartbeat ([0-9a-f]{12}) ([0-9a-f]{12})(?=[:\s]|$)")
_CRONLIST_LINE = re.compile(r"^\s*([0-9A-Za-z_-]+)\s.*?[\])]:\s?(.*)$")


def parse_cronlist(text: str) -> list[tuple[str, str]]:
    """(job id, visible prompt) for every job line `CronList` printed."""
    out = []
    for line in text.splitlines():
        m = _CRONLIST_LINE.match(line)
        if m:
            out.append((m.group(1), m.group(2)))
    return out


def classify_job(root: str, prompt: str) -> tuple[str, str] | None:
    """(generation, workspace digest) for a scoped heartbeat prompt; ("", "")
    for a legacy heartbeat (before D00 T04 §40's digest) whose scope cannot
    be proven; None for a job that is not a heartbeat."""
    m = _HEARTBEAT.search(prompt)
    if m:
        return m.group(1), m.group(2)
    if "run-guard heartbeat" in prompt:
        return "", ""
    return None


def listing_state(text: str | None) -> str:
    """How a `CronList` printout reads (D00 T04 §40): "empty" for the tool's
    own `No scheduled jobs.`, "ok" when every non-blank line is a job line,
    else "unknown": a failed, truncated, or garbled listing is never read
    as "no jobs"."""
    if text is None:
        return "unknown"
    stripped = text.strip()
    if stripped == "No scheduled jobs.":
        return "empty"
    lines = [ln for ln in stripped.splitlines() if ln.strip()]
    if not lines or not all(_CRONLIST_LINE.match(ln) for ln in lines):
        return "unknown"
    return "ok"


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
    # The same run's state is tagged after the guard publishes; until then
    # the hook honors an untagged state beside a guard migrated in place
    # (`migrated_at`), so no step loses the run's breaker or its legacy
    # error (D00 T04 §40 independent review).
    state_path = _paths(root)[1]
    try:
        with open(state_path, encoding="utf-8-sig") as fh:
            old = json.load(fh)
        if isinstance(old, dict) and not old.get("run_id"):
            _publish(state_path, json.dumps(dict(old, run_id=guard["run_id"])).encode("utf-8"))
    except (OSError, ValueError):
        pass
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
            handover: str | None = None, generation: str | None = None,
            expect_generation: str | None = None, expect_run: str | None = None) -> str:
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
        if expect_generation or expect_run:
            # A rotation re-points only the guard it was named for: an end, a
            # handover, or a phase move since then refuses, and the caller
            # deletes the job it just made (D00 T04 §40 independent review).
            try:
                live = read_guard(root)
            except GuardError:
                live = None
            if (live is None or str(live.get("session_id", "")) != session
                    or (expect_generation and str(live.get("generation", "")) != expect_generation)
                    or (expect_run and str(live.get("run_id", "")) != expect_run)
                    or str(live.get("run_file", "")) != run_file):
                raise GuardError("the guard is no longer the one this rotation was named for (it ended, moved, or "
                                 "changed hands): nothing changed; delete the job just created, after delete-check, "
                                 "and stop")
        return _acquire_locked(root, session, phase, run_file, cron_id, handover, generation)


def _clear_state_if_new_run(root: str, run_id: str, previous_run_id: str | None = None) -> None:
    """The breaker state belongs to one run: a handover or a re-point that
    keeps the run id keeps its blocks, stall trips, and coverage, and a new
    run starts clean (D00 T04 §38). The hook ignores a state carrying
    another run id, so a crash before this delete is harmless. A state
    written before states carried a run id belongs to the guard that was
    live: when the run id is unchanged it is migrated (stamped with the run
    id), never deleted, so its trips and a legacy `hook_error` survive the
    first re-point after the upgrade (panel round 3)."""
    _, state_path = _paths(root)
    try:
        with open(state_path, encoding="utf-8-sig") as fh:
            old = json.load(fh)
        if isinstance(old, dict) and old.get("run_id") == run_id:
            return
        if isinstance(old, dict) and not old.get("run_id") and previous_run_id and previous_run_id == run_id:
            _publish(state_path, json.dumps(dict(old, run_id=run_id)).encode("utf-8"))
            return
    except (OSError, ValueError):
        pass
    try:
        _unlink(state_path, missing_ok=True)
    except OSError:
        # A failed delete leaves a state tagged with another run's id,
        # which every reader treats as foreign (D00 T04 §40).
        pass


def _tag_legacy_state(root: str, outgoing_run: str | None) -> None:
    """Before a new guard publishes, a state written without a run id is
    tagged with the outgoing guard's run, or deleted when no guard owned
    it, so no crash point leaves an untagged state for a new run to adopt
    (D00 T04 §40, panel round 5 of the D00 T04 §38 review, F16)."""
    _, state_path = _paths(root)
    try:
        with open(state_path, encoding="utf-8-sig") as fh:
            old = json.load(fh)
    except FileNotFoundError:
        return
    except (OSError, ValueError):
        return
    if not isinstance(old, dict) or old.get("run_id"):
        return
    if outgoing_run:
        _publish(state_path, json.dumps(dict(old, run_id=outgoing_run)).encode("utf-8"))
    else:
        _unlink(state_path, missing_ok=True)
    _crash("acquire:state-tagged")


def _acquire_locked(root: str, session: str, phase: int, run_file: str, cron_id: str,
                    handover: str | None, generation: str | None = None) -> str:
    guard, state_path = _paths(root)
    if cron_id in _cleared_jobs(root):
        raise GuardError(f"job {cron_id} was cleared for deletion by delete-check; a guard never points at it again: "
                         f"CronCreate a new heartbeat")
    os.makedirs(os.path.dirname(guard), exist_ok=True)
    try:
        # A legacy guard is migrated first, so a same-run acquisition keeps
        # its run id and its legacy state migrates with it (panel round 4).
        previous = _migrate_locked(root, read_guard(root)) or {}
    except GuardError:
        previous = {}
    _tag_legacy_state(root, previous.get("run_id"))
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
        try:
            _fail("replace:claude-campaign-guard.json")
            os.replace(tmp, guard)
        except OSError:
            os.unlink(tmp)
            raise
        _crash("acquire:repoint-published")
        what = "handed over" if owner != session else "re-pointed"
        _clear_state_if_new_run(root, doc["run_id"], current.get("run_id"))
        return (f"acquire: guard {what} for session {session} (phase {phase}, {run_file}, job {cron_id}, "
                f"generation {doc['generation']}, run {doc['run_id']})")
    tmp = guard + f".{os.getpid()}.tmp"
    with open(tmp, "wb") as fh:
        fh.write(json.dumps(doc, indent=2).encode("utf-8"))
    _crash("acquire:create-tmp")
    try:
        # An exclusive publish: the link fails if a guard appeared, and a
        # reader never sees a half-written one (D00 T04 §38).
        _fail("link:claude-campaign-guard.json")
        os.link(tmp, guard)
    except OSError as exc:
        os.unlink(tmp)
        if not isinstance(exc, FileExistsError):
            raise
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
    _unlink(guard_path)
    _crash("end:guard-deleted")
    _unlink(state_path, missing_ok=True)
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
            out.append(f"pending-cancel: end incomplete for job {cron} (reason {j.get('reason')}): the guard "
                       f"still names it; finish it with end --reason {j.get('reason')} before anything else, and "
                       f"do not CronDelete a live run's heartbeat")
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
            # Without the CronList text there is no evidence of a live
            # carrier, so the job is withheld (panel round 1 of the D00 T04
            # §40 review).
            return (f"OWNER run={guard.get('run_id')} (job withheld: no CronList text given)\n"
                    f"UNKNOWN LISTING: run whoami with --generation and --cronlist - to release the job")
        if listing_state(cronlist) == "unknown":
            return (f"OWNER run={guard.get('run_id')} (job withheld: the CronList text did not read as a listing)\n"
                    f"UNKNOWN LISTING: pass the CronList printout exactly as the tool printed it, then run whoami again")
        digest = workspace_digest(root, str(guard.get("run_file", "")))
        carriers = [jid for jid, prompt in parse_cronlist(cronlist)
                    if classify_job(root, prompt) == (generation, digest)]
        # A firing cannot learn its own job id (CronList shows none, and two
        # jobs from one prompt are byte-identical), so the fence instead
        # guarantees one live carrier: while a duplicate or a stale job id
        # exists, the answer withholds `job=`, and no fenced step can run
        # until the extras are gone and `whoami` is asked again (panel
        # round 1 of the D00 T04 §38 review).
        if not carriers:
            # No verified live carrier: an empty or unparsed listing never
            # releases an identity (panel round 2).
            return (f"OWNER run={guard.get('run_id')} (job withheld: no live CronList job carries generation "
                    f"{generation})\nNO LIVE CARRIER: the guard's job {job} is not in the CronList text given: "
                    f"CronCreate a heartbeat and re-point with acquire --cron-id, then run whoami again")
        keep = job
        repoint = job not in carriers
        if repoint:
            keep = carriers[0]
        extras = [c for c in carriers if c != keep]
        if not repoint and not extras:
            return line
        # Two jobs carrying one generation cannot be told apart, and a
        # firing already running cannot be recalled, so neither is kept:
        # the generation rotates, and every old carrier (this firing's own
        # job among them) then reads NOT THE CURRENT JOB (D00 T04 §40).
        stale = ", ".join(carriers)
        return (f"OWNER run={guard.get('run_id')} (job withheld until the generation rotates)\n"
                f"DUPLICATE GENERATION: {stale} carry generation {generation}"
                + (f" and the guard's job {job} is not live" if repoint else "")
                + f": rotate it: python scripts/campaign_guard.py mint-generation, CronCreate a heartbeat from the "
                  f"canonical prompt with the new generation, acquire --session {session} --phase {guard.get('phase')} "
                  f"--run-file {guard.get('run_file')} --cron-id <new job> --generation <new generation> "
                  f"--expect-generation {generation} --expect-run {guard.get('run_id')} (if it refuses, delete the "
                  f"new job after delete-check and stop), then CronDelete {stale}, each after delete-check; this "
                  f"firing then stops")


def reset_state(root: str, session: str | None = None, expect_no_guard: bool = False,
                generation: str | None = None, cron_id: str | None = None, run: str | None = None) -> str:
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
            _fence(guard, session, generation, cron_id, run)
        try:
            os.unlink(state_path)
            return "reset-state: state deleted"
        except FileNotFoundError:
            return "reset-state: no state"


def reconcile(root: str, session: str, cronlist: str, run_file: str | None = None) -> list[str]:
    """Startup reconciliation between the guard, the live heartbeat jobs,
    and the run record (D00 T04 §36, §38). The jobs come from the
    `CronList` text, never from a list of ids the caller vouches for: a job
    counts as this workspace's only when its prompt carries this
    workspace's digest for the run file (the guard's, or `run_file` when no
    guard lives)."""
    with _Lock(root):
        try:
            guard = _read_locked(root)
        except GuardError:
            return ["reconcile: the guard is unreadable: report it to the operator and start nothing"]
    out: list[str] = []
    if listing_state(cronlist) == "unknown":
        # Nothing is named for deletion without a readable listing, not even
        # a pending cancellation (panel round 2 of the D00 T04 §40 review).
        try:
            waiting = [str(j.get("cron_id")) for j in _pending_jobs(root)]
        except GuardError:
            waiting = []
        return (["reconcile: UNKNOWN: the CronList text did not read as a listing; nothing is named for "
                 "deletion: pass the printout exactly as the tool printed it"]
                + ([f"reconcile: pending cancellation(s) of {', '.join(waiting)} wait for a readable listing"]
                   if waiting else []))
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
    # Hook errors the last run left behind are drained here, at every start
    # (D00 T04 §40): with no guard, the starting session acknowledges them
    # under its own identity after the run file records each line.
    for e in _hook_errors(root):
        if guard is None:
            out.append(f"reconcile: an orphan hook error: {_error_line(e)}: append that line to the run file, then "
                       f"hook-error --session {session} --startup yes --ack {e.get('id')}")
        else:
            out.append(f"reconcile: a hook error awaits its acknowledgement through the guard: {_error_line(e)}")
    target = str(guard.get("run_file", "")) if guard is not None else (run_file or "")
    if not target:
        return out + ["reconcile: no guard lives, so name the run file this start is for (--run-file)"]
    if listing_state(cronlist) == "unknown":
        # A listing that did not parse names nothing for deletion (D00 T04
        # §40): missing evidence is not evidence that jobs are absent.
        return out + ["reconcile: UNKNOWN: the CronList text did not read as a listing; nothing is named for "
                      "deletion: pass the printout exactly as the tool printed it"]
    digest = workspace_digest(root, target)
    # Jobs left alone are notes; they never hide this run's verdict.
    notes: list[str] = []
    ours: list[str] = []
    gens: dict = {}
    for jid, prompt in parse_cronlist(cronlist):
        kind = classify_job(root, prompt)
        if kind is None:
            continue
        gen, dig = kind
        if not gen:
            notes.append(f"reconcile: job {jid} is a legacy heartbeat whose prompt carries no workspace digest, so "
                         f"it cannot be scoped: CronDelete it if it is this workspace's, else leave it")
        elif dig != digest:
            notes.append(f"reconcile: job {jid} is a heartbeat for another workspace or run (digest {dig}): left alone")
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
        # A survivor carrying the guard's generation is not adopted: a
        # firing of the lost job may still be in flight with the same
        # identity, so startup rotates exactly as the heartbeat does (panel
        # round 3 of the D00 T04 §40 review).
        out.append(f"reconcile: the guard names job {job}, which is not live, and {keep} carries its generation: "
                   f"rotate it: mint a generation, CronCreate a heartbeat, acquire --cron-id <new job> --generation "
                   f"<new generation> --expect-generation {gen} --expect-run {guard.get('run_id')}, then CronDelete "
                   f"{keep} after delete-check")
    twins = [j for j in ours if j != keep and gens[j] == gen]
    if keep is not None and keep == job and twins:
        # A second job with the guard's own generation cannot be told from
        # it, and one of them may be firing: rotate, never delete one and
        # keep the other (panel round 4 of the D00 T04 §40 review).
        out.append(f"reconcile: {', '.join([job] + twins)} carry the guard's generation {gen}: rotate it: mint a "
                   f"generation, CronCreate a heartbeat, acquire --cron-id <new job> --generation <new generation> "
                   f"--expect-generation {gen} --expect-run {guard.get('run_id')}, then CronDelete "
                   f"{', '.join([job] + twins)}, each after delete-check")
    out += [f"reconcile: stale job {j} is not the guard's: CronDelete it" for j in ours
            if j != keep and gens[j] != gen]
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


def delete_check(root: str, session: str, cron_id: str) -> tuple[int, str]:
    """The fence before every `CronDelete` (D00 T04 §40): a session never
    deletes the live guard's current job while it owns the guard; any
    other job of its own scheduler (a stale, duplicate, obsolete, or
    finished heartbeat) may go. Read under the lock, just before the
    delete, so a re-point between listing and deletion is seen."""
    with _Lock(root):
        try:
            guard = read_guard(root)
        except GuardError:
            return 1, f"KEEP: the guard is unreadable, so {cron_id} cannot be proven obsolete: repair the guard first"
        if guard is not None and str(guard.get("session_id", "")) == session and str(guard.get("cron_id", "")) == cron_id:
            return 1, (f"KEEP: {cron_id} is the live guard's current job; end the run or re-point the guard before "
                       f"deleting it")
        # The clearance is recorded under the same lock, and `acquire`
        # refuses to make a cleared job current, so nothing can re-point to
        # it between this answer and the CronDelete (panel round 1).
        cleared = _cleared_jobs(root)
        if cron_id not in cleared and (guard is None or str(guard.get("cron_id", "")) != cron_id):
            # Never truncated: a clearance must not expire because other
            # jobs were checked since (panel round 2); job ids are few per run.
            _publish(_cleared_path(root), json.dumps(cleared + [cron_id]).encode("utf-8"))
    return 0, f"DELETE OK: {cron_id} is not the live guard's current job"


def _cleared_path(root: str) -> str:
    return os.path.join(root, "build", "claude-campaign-cleared.json")


def _cleared_jobs(root: str) -> list[str]:
    """The jobs `delete-check` cleared. A missing ledger is empty; an
    unreadable one refuses, because reading it as empty would let a cleared
    job be made current again (panel round 3 of the D00 T04 §40 review)."""
    try:
        with open(_cleared_path(root), encoding="utf-8") as fh:
            doc = json.load(fh)
    except FileNotFoundError:
        return []
    except (OSError, ValueError) as exc:
        raise GuardError(f"the clearance ledger {_cleared_path(root)} is unreadable ({exc}): quarantine it before "
                         f"any guard change")
    if not isinstance(doc, list):
        raise GuardError(f"the clearance ledger {_cleared_path(root)} is not a list: quarantine it before any "
                         f"guard change")
    return [str(x) for x in doc]


_QUARANTINE = "claude-campaign-quarantine"


def quarantine(root: str, session: str) -> list[str]:
    """Move every guard file that does not parse (the guard, the state, the
    pending-cancellation record) into build/claude-campaign-quarantine/,
    bytes kept, so a malformed file has a bounded end instead of blocking
    every command (D00 T04 §40). Readable files are never touched."""
    out = []
    guard_path, state_path = _paths(root)
    with _Lock(root):
        for path, want in ((guard_path, dict), (state_path, dict), (_pending_path(root), (list, dict)),
                           (_cleared_path(root), list)):
            if not os.path.exists(path):
                continue
            try:
                with open(path, encoding="utf-8-sig") as fh:
                    doc = json.load(fh)
                if isinstance(doc, want):
                    continue
            except (OSError, ValueError):
                pass
            folder = os.path.join(root, "build", _QUARANTINE)
            os.makedirs(folder, exist_ok=True)
            import uuid
            while True:
                dest = os.path.join(folder, f"{_utc_now().replace(':', '')}-{session[:8]}-{uuid.uuid4().hex[:8]}-"
                                            f"{os.path.basename(path)}")
                if not os.path.exists(dest):
                    break
            # Held under the guard lock, so no second quarantine races this
            # name; the unique suffix keeps two in one second apart.
            salvaged: list[str] = []
            if path == _cleared_path(root):
                # The ledger is a set of prohibitions, and more of them is
                # harmless: every job-id-shaped token in the corrupt bytes is
                # kept, so quarantine never lifts a clearance (panel round 4,
                # rethought after three rounds on the clearance unit).
                try:
                    with open(path, "rb") as fh:
                        raw = fh.read().decode("utf-8", "replace")
                    salvaged = sorted(set(re.findall(r"(?<![0-9A-Za-z])[0-9a-f]{8}(?![0-9A-Za-z])", raw)))
                except OSError:
                    salvaged = []
            os.replace(path, dest)
            if path == _cleared_path(root):
                _publish(path, json.dumps(salvaged).encode("utf-8"))
                out.append(f"quarantine: the clearance ledger was rebuilt from the {len(salvaged)} job id(s) its bytes "
                           f"still carry; a ledger with none left is a total loss this cannot undo")
            out.append(f"quarantine: {os.path.basename(path)} did not parse; moved, bytes kept, to "
                       f"build/{_QUARANTINE}/{os.path.basename(dest)}")
    return out or ["quarantine: every guard file parses; nothing moved"]


_ACQUIRE_RECORD = re.compile(r"acquire: guard (?:created|re-pointed|handed over) for session (\S+) \(phase (\d+), "
                             r"(\S+), job (\S+), generation ([0-9a-f]{6,}), run ([0-9a-f]{6,})\)")


def recover(root: str, session: str, run_file: str) -> str:
    """Restore a quarantined guard from the run file's own record: the last
    `acquire: guard ...` line the run file carries, which names the
    session, phase, run file, job, generation, and run id (D00 T04 §40).
    Only the recorded session may recover it, only when no guard lives,
    and the restored guard is read back before the call succeeds."""
    if not session or not run_file:
        raise GuardError("recover needs --session and --run-file")
    hits = list(_ACQUIRE_RECORD.finditer(_journal_text(root, run_file)))
    if not hits:
        raise GuardError(f"{run_file} records no acquire line to recover the guard from; start the run afresh")
    m = hits[-1]
    rec_session, phase, rec_file, job, gen, run = m.groups()
    if rec_session != session:
        raise GuardError(f"{run_file} records the guard for session {rec_session}, not {session}; a handover "
                         f"goes through acquire --handover, never recover")
    if rec_file.rstrip(",") != run_file:
        raise GuardError(f"the recorded guard names run file {rec_file}, not {run_file}")
    guard_path, _ = _paths(root)
    doc = {"runner": "claude", "workspace": root.replace("\\", "/"), "phase": int(phase), "run_file": run_file,
           "session_id": session, "cron_id": job, "generation": gen, "run_id": run, "recovered_at": _utc_now()}
    with _Lock(root):
        if os.path.exists(guard_path):
            raise GuardError("a guard file exists: quarantine it first if it does not parse")
        if job in _cleared_jobs(root):
            # The recorded job was cleared for deletion: restoring it would
            # hand a deleted heartbeat the guard (panel round 2).
            raise GuardError(f"the recorded job {job} was cleared for deletion by delete-check; recover refuses it: "
                             f"CronCreate a new heartbeat and start the guard with acquire")
        _publish(guard_path, json.dumps(doc, indent=2).encode("utf-8"))
        back = read_guard(root)
    if not back or any(back.get(k) != doc[k] for k in ("session_id", "cron_id", "generation", "run_id", "run_file")):
        raise GuardError("the restored guard did not read back as written")
    return (f"recover: guard restored from {run_file}: session {session}, job {job}, generation {gen}, run {run} "
            f"(read back); its job's creation time is unknown, so expiry asks for a replacement")


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
               generation: str | None = None, cron_id: str | None = None, run: str | None = None,
               startup: bool = False) -> str:
    """Print every error the hook recorded, one line each, or clear the one
    `ack` names by its id. Printing clears nothing (D00 T04 §36). Each line
    carries its error's identity, so an identical error twice is two
    records and a delivery from before a handover reads as its session's,
    never this one's (D00 T04 §38). An owner's ack is fenced by
    generation and job; the CLI requires them."""
    with _Lock(root):
        return _hook_error_locked(root, session, ack, generation, cron_id, run, startup)


def _hook_error_locked(root: str, session: str | None, ack: str | None = None,
                       generation: str | None = None, cron_id: str | None = None, run: str | None = None,
                       startup: bool = False) -> str:
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
        # No guard means no owner to fence against: a fenced ack refuses
        # rather than trusting identity values that may be obsolete (panel
        # round 2 of the D00 T04 §38 review). At startup, before any guard
        # is acquired, the starting session acknowledges an orphan error
        # under its own identity; the error's origin rides the line the run
        # file records (D00 T04 §40).
        if startup:
            if guard is not None:
                raise GuardError("a startup acknowledgement needs no live guard: acquire first, then acknowledge "
                                 "through the guard's fence")
        else:
            _fence(guard, session, generation, cron_id, run)
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


def _ceiling_path(root: str) -> str:
    return os.path.join(root, "build", "claude-campaign-ceiling.json")


def _git(root: str, *args: str) -> tuple[int, str]:
    proc = subprocess.run(["git", *args], cwd=root, capture_output=True, text=True, encoding="utf-8",
                          errors="replace")
    return proc.returncode, proc.stdout.strip()


def _repo_identity(root: str) -> dict:
    """The repository and branch an episode belongs to, read from git. The
    URL loses any userinfo (`https://user:token@host/...`), because attempt
    lines carrying it land in tracked run files, and serialization and
    comparison use the same credential-free form (D00 T04 §38 independent
    review; AGENTS.md: credentials never enter tracked files)."""
    _rc, url = _git(root, "remote", "get-url", "origin")
    _rc, branch = _git(root, "rev-parse", "--abbrev-ref", "HEAD")
    return {"repo": credential_free(url), "branch": branch}


def credential_free(url: str) -> str:
    """A remote URL with every place a credential can ride removed: the
    userinfo (`user:token@`), the query (`?access_token=...`), and the
    fragment (D00 T04 §40)."""
    url = re.sub(r"^([A-Za-z][A-Za-z0-9+.-]*://)[^/@]*@", r"\1", url or "")
    return re.split(r"[?#]", url, maxsplit=1)[0]


def _repo_slug(url: str) -> str:
    """`owner/name` of a GitHub remote, https or ssh, without `.git`."""
    m = re.search(r"github\.com[:/]+([^/\s]+/[^/\s]+?)(?:\.git)?/?$", url or "")
    return m.group(1) if m else ""


# The journal is the run file's own record, written by these commands
# before the state file (write-ahead: D00 T04 §39). D00 T04 §41 makes its
# replay strict:
#
# - A journal line is a column-0 line the commands wrote: `repair: ...`
#   prose and the `repair-receipt: {json}` line written with it in the same
#   append. A quoted copy (in backticks, in a list item) is a record of a
#   line, never a journal line, so quoting one never double-counts.
# - Every episode line carries the episode's identity and campaign run
#   (`repo= branch= workflow= run=`), and every line of an episode must
#   carry its opening line's identity.
# - Replay is a state machine: an episode opens once, each attempt goes
#   reserved, then pushed or abandoned, and an abandoned attempt may be
#   reserved again (which replays as its latest transition); an episode
#   ends closed or retired with nothing reserved. Any other history (an
#   attempt with no open episode, a transition out of order, a duplicate,
#   a renumbered attempt, a reopened closed episode) refuses.
# - A journal line that does not parse, the file's final line without its
#   newline (a write cut short), or a receipt that disagrees with its prose
#   refuses: the bound cannot be counted, so the caller escalates.
# - Writes are serial: every journal write happens under the guard lock, in
#   one append per transition.
# - The journal is append-only: every journal line committed at HEAD must
#   still open the working file's journal, so a truncated or edited journal
#   refuses rather than renewing a budget or an allowance.
_IDENT_STRICT = r" repo=(\S+) branch=(\S+) workflow=(\S+) run=([0-9a-f]{12})"
_PROSE = (
    ("opened", re.compile(r"repair: episode ([0-9a-f]{12}) opened on red ([0-9a-f]{12})" + _IDENT_STRICT + r"\Z")),
    ("attempt", re.compile(r"repair: episode ([0-9a-f]{12}) attempt (\d+) of \d+ (reserved|pushed) "
                           r"\(([0-9a-f]{12})(?: repairs ([0-9a-f]{12}))?\)" + _IDENT_STRICT + r"\Z")),
    ("attempt", re.compile(r"repair: episode ([0-9a-f]{12}) attempt (\d+) of \d+ (abandoned) \(([0-9a-f]{12})()\)"
                           + _IDENT_STRICT + r": \S.*\Z")),
    ("closed", re.compile(r"repair: episode ([0-9a-f]{12}) closed green at [0-9a-f]{12} \(run \d+ attempt \d+ "
                          r"workflow-id \d+\) after \d+ attempt\(s\)" + _IDENT_STRICT + r"\Z")),
    ("retired", re.compile(r"repair: episode ([0-9a-f]{12}) retired" + _IDENT_STRICT + r": \S.*\Z")),
)
_CEILING_LINE = re.compile(r"repair: ceiling allowance used for (\S+) run=([0-9a-f]{12})\Z")
RECEIPT_VERSION = 1
_RECEIPT_EVENTS = ("opened", "reserved", "pushed", "abandoned", "closed", "retired", "ceiling")


def _ident_suffix(ep: dict) -> str:
    """The identity every journal line carries, so a restore recovers it
    from the journal rather than from the caller (D00 T04 §38), with the
    campaign run it belongs to (D00 T04 §39, required from D00 T04 §41)."""
    tail = f" run={ep['run']}" if ep.get("run") else ""
    return (f" repo={ep.get('repo') or '-'} branch={ep.get('branch') or '-'} "
            f"workflow={ep.get('workflow') or '-'}{tail}")


def _receipt(event: str, state: dict | None, **fields) -> str:
    """The structured receipt (D00 T04 §41): one versioned JSON object per
    command, journalled with its transition and printed with its line, so
    a reader never parses the prose. `remaining` is the budget left after
    the transition."""
    st = state or {}
    body = {"v": RECEIPT_VERSION, "event": event, "campaign": st.get("run"), "repository": st.get("repo") or "-",
            "branch": st.get("branch") or "-", "workflow": st.get("workflow") or "-",
            "episode": st.get("episode"), "attempt": None, "sha": None, "red": None, "run": None,
            "run_attempt": None, "outcome": event,
            "remaining": (REPAIR_BOUND - len(_active(st))) if state else None}
    body.update(fields)
    return "repair-receipt: " + json.dumps(body, sort_keys=True, separators=(",", ":"))


def _canon(root: str, rev: str) -> str:
    """A commit's full sha when git resolves it, else the text as given:
    attempts compare by canonical identity, never by printed prefix
    (D00 T04 §37 independent review)."""
    rc, out = _git(root, "rev-parse", "--verify", "--quiet", f"{rev}^{{commit}}")
    return out if rc == 0 and out else rev


def _journal_text(root: str, run_file: str) -> str:
    try:
        with open(os.path.join(root, run_file), encoding="utf-8", errors="replace") as fh:
            return fh.read()
    except OSError:
        return ""


def _journal_lines(text: str) -> list[str]:
    """The column-0 journal lines of a run file, in order."""
    return [ln.rstrip("\r") for ln in text.split("\n") if ln.startswith(("repair: ", "repair-receipt: "))]


def _check_append_only(root: str, run_file: str) -> None:
    """Refuse a journal that lost or changed a line committed at HEAD
    (D00 T04 §41): the journal only grows, so the committed journal lines
    must still open the working file's journal."""
    if _git(root, "cat-file", "-e", f"HEAD:{run_file}")[0] != 0:
        return
    proc = subprocess.run(["git", "show", f"HEAD:{run_file}"], cwd=root, capture_output=True)
    if proc.returncode != 0:
        raise GuardError(f"git could not read {run_file} at HEAD, so the journal cannot be checked: escalate")
    committed = _journal_lines(proc.stdout.decode("utf-8", errors="replace"))
    now = _journal_lines(_journal_text(root, run_file))
    if now[:len(committed)] != committed:
        raise GuardError(f"{run_file} has lost or changed journal lines committed at HEAD (a truncated or edited "
                         f"journal): the bound cannot be counted, so escalate rather than renew it")


def _parse_prose(line: str) -> dict | None:
    for kind, pat in _PROSE:
        m = pat.match(line)
        if not m:
            continue
        if kind == "attempt":
            return {"episode": m.group(1), "event": m.group(3), "attempt": int(m.group(2)), "commit": m.group(4),
                    "red": m.group(5) or "", "full": "", "ident": m.group(6, 7, 8, 9)}
        if kind == "opened":
            return {"episode": m.group(1), "event": "opened", "attempt": None, "commit": "", "red": m.group(2),
                    "full": "", "ident": m.group(3, 4, 5, 6)}
        return {"episode": m.group(1), "event": kind, "attempt": None, "commit": "", "red": "", "full": "",
                "ident": m.group(2, 3, 4, 5)}
    return None


def _parse_receipt(line: str) -> dict | None:
    try:
        body = json.loads(line[len("repair-receipt: "):])
    except ValueError:
        return None
    if not isinstance(body, dict) or body.get("v") != RECEIPT_VERSION or body.get("event") not in _RECEIPT_EVENTS:
        return None
    if body["event"] == "ceiling":
        return {"event": "ceiling", "key": body.get("key"), "campaign": body.get("campaign")}
    ep, sha = body.get("episode"), body.get("sha")
    if not (isinstance(ep, str) and re.fullmatch(r"[0-9a-f]{12,40}", ep)):
        return None
    attempt = body.get("attempt")
    if body["event"] in ("reserved", "pushed", "abandoned") and not (
            isinstance(attempt, int) and isinstance(sha, str) and re.fullmatch(r"[0-9a-f]{12,40}", sha)):
        return None
    commit = sha[:12] if body["event"] in ("reserved", "pushed", "abandoned") else ""
    red = body.get("red") if isinstance(body.get("red"), str) else ""
    return {"episode": ep[:12], "event": body["event"], "attempt": attempt, "commit": commit,
            "red": red[:12] if body["event"] == "opened" else red,
            "full": sha if commit and len(sha) == 40 else "", "episode_full": ep if len(ep) == 40 else "",
            "ident": (body.get("repository"), body.get("branch"), body.get("workflow"), body.get("campaign"))}


def _journal(root: str, run_file: str) -> tuple[dict | None, list[tuple], set[str]]:
    """(the open episode, its identity, the episodes the journal closed or
    retired) by strict replay of the run file's journal (D00 T04 §41). A
    receipt is read in preference to its prose, whose agreement it must
    keep. Raises GuardError on any history the state machine refuses."""
    text = _journal_text(root, run_file)
    rows = text.split("\n")
    events: list[tuple[int, dict]] = []
    i = 0
    while i < len(rows):
        ln = rows[i].rstrip("\r")
        if not ln.startswith(("repair: episode ", "repair-receipt: ")):
            i += 1
            continue
        where = f"{run_file} line {i + 1}"
        if i == len(rows) - 1:
            raise GuardError(f"{where} is a journal line without its newline (a write cut short): the bound "
                             f"cannot be counted, so escalate")
        if ln.startswith("repair-receipt: "):
            rc = _parse_receipt(ln)
            if rc is None:
                raise GuardError(f"{where} is not a well-formed repair receipt (truncated or edited): escalate")
            if rc["event"] != "ceiling":
                events.append((i + 1, rc))
            i += 1
            continue
        ev = _parse_prose(ln)
        if ev is None:
            raise GuardError(f"{where} is not a complete journal line (truncated, edited, or a legacy line "
                             f"without its identity and campaign run; a legacy journal): the bound cannot be "
                             f"counted, so escalate")
        nxt = rows[i + 1].rstrip("\r")
        if nxt.startswith("repair-receipt: "):
            if i + 1 == len(rows) - 1:
                raise GuardError(f"{run_file} line {i + 2} is a receipt without its newline (a write cut short): "
                                 f"escalate")
            rc = _parse_receipt(nxt)
            if rc is None or rc["event"] == "ceiling":
                raise GuardError(f"{run_file} line {i + 2} is not a well-formed receipt for line {i + 1}: escalate")
            if (rc["episode"], rc["event"], rc["attempt"], rc["commit"], rc["ident"]) != (
                    ev["episode"], ev["event"], ev["attempt"], ev["commit"], ev["ident"]):
                raise GuardError(f"{where} and its receipt disagree (an edited journal): escalate")
            events.append((i + 1, rc))
            i += 2
            continue
        events.append((i + 1, ev))
        i += 1
    ep: dict | None = None
    ended: set[str] = set()
    for lineno, ev in events:
        where = f"{run_file} line {lineno} ({ev['event']} of episode {ev['episode']})"
        if ev["event"] == "opened":
            if ep is not None:
                raise GuardError(f"{where}: an episode opens while episode {ep['episode']} is open (an impossible "
                                 f"history): escalate")
            if ev["episode"] in ended:
                raise GuardError(f"{where}: episode {ev['episode']} was already closed; it never reopens: escalate")
            ep = {"episode": ev["episode"], "attempts": [], "ident": ev["ident"], "opened": True,
                  "full": ev.get("episode_full", "")}
            continue
        if ep is None or ev["episode"] != ep["episode"]:
            raise GuardError(f"{where}: no open episode {ev['episode']} to apply it to (an impossible history): "
                             f"escalate")
        if ev["ident"] != ep["ident"]:
            r, b, w, c = ev["ident"]
            raise GuardError(f"{run_file} records the episode under repository {r}, branch {b}, workflow {w}, "
                             f"campaign run {c}, not its opening line's: escalate rather than reconcile")
        if ev["event"] in ("reserved", "pushed", "abandoned"):
            hit = [a for a in ep["attempts"] if a["commit"] == ev["commit"]]
            idx = ep["attempts"].index(hit[0]) + 1 if hit else len(ep["attempts"]) + 1
            if ev["attempt"] != idx:
                raise GuardError(f"{where}: numbered attempt {ev['attempt']}, but replay places it at {idx} "
                                 f"(an edited or reordered journal): escalate")
            if ev["event"] == "reserved":
                if not hit:
                    ep["attempts"].append({"commit": ev["commit"], "full": ev["full"], "red": ev["red"],
                                           "state": "reserved"})
                elif hit[0]["state"] == "abandoned":
                    hit[0]["state"] = "reserved"
                else:
                    raise GuardError(f"{where}: {ev['commit']} is already {hit[0]['state']} (a duplicate "
                                     f"reservation): escalate")
            else:
                if not hit or hit[0]["state"] != "reserved":
                    raise GuardError(f"{where}: {ev['commit']} is not reserved (a duplicate or out-of-order "
                                     f"line): escalate")
                hit[0]["state"] = ev["event"]
                hit[0]["full"] = hit[0]["full"] or ev["full"]
            continue
        if any(a["state"] == "reserved" for a in ep["attempts"]):
            raise GuardError(f"{where}: the episode ends with an attempt still reserved (an impossible history): "
                             f"escalate")
        ended.add(ep["episode"])
        ep = None
    return ep, ([ep["ident"]] if ep else []), ended


def _journal_append(root: str, run_file: str, *lines: str) -> None:
    """One append per transition, so a prose line and its receipt land
    together or the cut shows as a line without its newline."""
    path = os.path.join(root, run_file)
    text = _journal_text(root, run_file)
    with open(path, "a", encoding="utf-8", newline="\n") as fh:
        fh.write(("" if not text or text.endswith("\n") else "\n") + "".join(ln + "\n" for ln in lines))
        fh.flush()
        os.fsync(fh.fileno())


def _active(ep: dict) -> list[dict]:
    """The attempts that count against the bound: every one not
    abandoned. A reservation whose push is unknown counts, conservatively,
    until it is marked pushed or abandoned (D00 T04 §39)."""
    return [a for a in ep.get("attempts", []) if a.get("state") != "abandoned"]


def _gh_argv() -> list[str]:
    """The GitHub CLI: `GH` when set (a `.py` path runs under this
    interpreter, which is how the self-test fakes it), else `gh`."""
    env = os.environ.get("GH")
    if env:
        return [sys.executable, env] if env.endswith(".py") else [env]
    return [shutil.which("gh") or "gh"]


def _green_run(root: str, green: str, workflow: str) -> tuple[dict | None, str]:
    """GitHub's own record of `workflow`'s latest run on `green`, re-read
    rather than trusted from a pasted line (D00 T04 §39), with its latest
    attempt and immutable workflow id (D00 T04 §41)."""
    try:
        proc = subprocess.run([*_gh_argv(), "run", "list", "--commit", green, "--workflow", workflow, "--json",
                               "databaseId,headSha,headBranch,conclusion,status,url,attempt,workflowName,"
                               "workflowDatabaseId"],
                              cwd=root, capture_output=True, text=True, encoding="utf-8", errors="replace",
                              timeout=120)
    except (OSError, subprocess.TimeoutExpired) as exc:
        return None, f"gh unavailable: {exc}"
    if proc.returncode != 0:
        return None, f"gh exited {proc.returncode}: {' '.join(proc.stderr.split())[:160]}"
    try:
        runs = json.loads(proc.stdout or "[]")
    except ValueError:
        return None, "gh output is not JSON"
    runs = [r for r in runs if isinstance(r, dict)] if isinstance(runs, list) else []
    if not runs:
        return None, f"GitHub lists no {workflow} run on {green[:12]}"
    return max(runs, key=lambda r: r.get("databaseId") or 0), ""


def _review_prompt():
    """review_prompt.py, the one reader of workflow triggers, imported so
    retirement re-derives exclusion with the same code ci-wait used."""
    if HERE not in sys.path:
        sys.path.insert(0, HERE)
    import review_prompt  # a sibling script, imported on demand
    return review_prompt


def _delivered(root: str, remote: str, branch: str, commit: str) -> tuple[bool | None, str]:
    """(delivered, detail): whether `commit` is on `remote`'s `branch`
    (D00 T04 §41). None when the remote cannot be read."""
    try:
        proc = subprocess.run(["git", "ls-remote", "--exit-code", remote, f"refs/heads/{branch}"], cwd=root,
                              capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=120)
    except (OSError, subprocess.TimeoutExpired) as exc:
        return None, f"git ls-remote {remote} failed ({exc})"
    if proc.returncode == 2:
        return False, f"{remote} has no branch {branch}"
    if proc.returncode != 0 or not proc.stdout.split():
        return None, f"git ls-remote {remote} exited {proc.returncode}"
    head = proc.stdout.split()[0]
    if _git(root, "cat-file", "-e", f"{head}^{{commit}}")[0] != 0:
        if _git(root, "fetch", "--quiet", "--no-tags", remote, f"refs/heads/{branch}")[0] != 0:
            return None, f"git could not fetch {remote} {branch}"
    rc = _git(root, "merge-base", "--is-ancestor", commit, head)[0]
    if rc not in (0, 1):
        return None, f"git could not compare {commit[:12]} with {remote}'s {head[:12]}"
    return rc == 0, f"{remote}/{branch} is at {head[:12]}"


def repair(root: str, action: str, red: str = "", commit: str = "", green: str = "",
           workflow: str = "", run_file: str = "", evidence: str = "", run_id: str = "",
           reason: str = "", attempt_no: str = "", remote: str = "") -> tuple[int, str]:
    """The CI repair episode (D00 T04 §35, §37, §39, §41), with its
    structured receipt: every command's output ends with one
    `repair-receipt: {json}` line (D00 T04 §41)."""
    try:
        code, line = _repair(root, action, red, commit, green, workflow, run_file, evidence, run_id, reason,
                             attempt_no, remote)
    except GuardError as exc:
        # A refusal carries its receipt too, so a reader never falls back to
        # the prose on an escalation path (independent review of D00 T04 §41).
        code, line = 1, f"campaign_guard: {exc}"
        try:
            with open(_repair_path(root), encoding="utf-8") as fh:
                st = json.load(fh)
            st = st if isinstance(st, dict) and isinstance(st.get("attempts"), list) else None
        except (OSError, ValueError):
            st = None
        return code, line + "\n" + _receipt(action, st, outcome="refused", reason=str(exc)[:300])
    if "\nrepair-receipt: " not in "\n" + line:
        try:
            with open(_repair_path(root), encoding="utf-8") as fh:
                st = json.load(fh)
            st = st if isinstance(st, dict) and isinstance(st.get("attempts"), list) else None
        except (OSError, ValueError):
            st = None
        line += "\n" + _receipt(action, st, outcome="escalate" if code else "ok")
    return code, line


def _repair(root: str, action: str, red: str, commit: str, green: str, workflow: str, run_file: str,
            evidence: str, run_id: str, reason: str, attempt_no: str, remote: str) -> tuple[int, str]:
    """An episode opens at its first red and ends green (closed) or by an
    authorized retirement (retired); at most REPAIR_BOUND attempts count
    against it. The run file's journal is the source of truth: every
    command writes its line and receipt there first and the state file
    after, so a crash between the two is recovered from the journal, and a
    journal line the state lacks is adopted, never lost (write-ahead). An
    attempt is reserved before its push and then marked pushed or
    abandoned; abandoning first checks the remote, and a commit that
    landed is marked pushed instead (D00 T04 §41). The episode carries the
    repository, branch, workflow, and the campaign's run id, and refuses a
    caller or journal from elsewhere. `close` re-reads the green run from
    GitHub and binds its latest attempt and workflow id; `retire`
    re-derives the trigger exclusion from the committed workflow (D00 T04
    §41). `ceiling` allows one re-run per GitHub run attempt, keyed by
    repository, run id, and attempt, journalled with the campaign run.
    Returns (exit, line); exit 1 is the escalation."""
    path = _repair_path(root)
    with _Lock(root):
        if not run_file:
            raise GuardError(f"repair {action} needs --run-file: the run file's journal is the episode's record")
        # The campaign an episode belongs to is established or the call
        # refuses: an unreadable guard never reads as "no campaign" (panel
        # round 2 of the D00 T04 §39 review).
        try:
            guard = read_guard(root)
        except GuardError:
            raise GuardError("the guard is unreadable, so the campaign this episode belongs to cannot be "
                             "established: repair the guard, then retry")
        campaign = str((guard or {}).get("run_id") or "")
        _check_append_only(root, run_file)
        if action == "ceiling":
            return _ceiling(root, run_id, attempt_no or "1", run_file, campaign)
        try:
            with open(path, encoding="utf-8") as fh:
                state = json.load(fh)
            exists = True
        except FileNotFoundError:
            state, exists = None, False
        except (OSError, ValueError) as exc:
            # An unreadable episode must never reset the bound (panel round 1).
            raise GuardError(f"the repair episode {path} is unreadable ({exc}); the bound cannot be "
                             f"counted, so escalate rather than repair")
        # Only a missing file means no episode: a file holding anything but
        # a well-formed episode (a JSON null included) refuses (panel round 2).
        if exists and not (isinstance(state, dict) and isinstance(state.get("episode"), str)
                           and isinstance(state.get("attempts"), list)):
            raise GuardError(f"the repair episode {path} is malformed; the bound cannot be counted, "
                             f"so escalate rather than repair")
        if action in ("attempt", "pushed", "abandon", "close", "retire", "restore") and not campaign:
            raise GuardError(f"repair {action} needs a live campaign guard with a run id: the episode is bound to "
                             f"its campaign")
        # A persisted episode of another campaign is refused before its
        # journal is read or anything returns (panel round 3).
        if state and state.get("run") and campaign and state["run"] != campaign:
            raise GuardError(f"the open episode belongs to campaign run {state['run']}, not {campaign}; "
                             f"a journal from another campaign is not this one's")
        if state:
            # Episode files from before D00 T04 §39 carry no attempt state:
            # they were recorded after their push.
            for a in state["attempts"]:
                a.setdefault("state", "pushed")
            # The caller's run file must be the episode's before its journal
            # is read at all (D00 T04 §39 independent review, P1).
            if state.get("run_file") and state["run_file"] != run_file:
                raise GuardError(f"the open episode belongs to run file {state['run_file']!r}, not {run_file!r}; "
                                 f"refusing to read another journal")
        jep, _idents, ended = _journal(root, run_file)
        note = ""
        # The journal is trusted only when its identity is the persisted
        # episode's: a foreign journal never rewrites this episode's
        # attempts (panel round 4 of the D00 T04 §39 review).
        if state and jep and jep["episode"] == state["episode"][:12]:
            repo_i, branch_i, wf_i, run_i = jep["ident"]
            if (repo_i, branch_i, wf_i) != (state.get("repo") or "-", state.get("branch") or "-",
                                            state.get("workflow") or "-"):
                raise GuardError(f"{run_file} records the episode under repository {repo_i}, branch {branch_i}, "
                                 f"workflow {wf_i}, not the episode file's: escalate rather than reconcile")
            if state.get("run") and run_i != state["run"]:
                raise GuardError(f"{run_file} records the episode under campaign run {run_i}, not "
                                 f"{state['run']}: escalate rather than reconcile")
        if state and (jep is None or jep["episode"] != state["episode"][:12]):
            # Only a terminal line for this very episode drops its file: a
            # crash after the closing line, before the state delete. A
            # missing or silent journal is no evidence, and never resets
            # the bound (D00 T04 §39 independent review, P1).
            if state["episode"][:12] not in ended:
                raise GuardError(f"the episode file holds episode {state['episode'][:12]} but {run_file} records "
                                 f"no open or ended episode for it: the bound cannot be counted, so escalate")
            os.unlink(path)
            state, note = None, " (a stale episode file the journal had closed was dropped)"
        elif state and jep:
            want = [(a["commit"], a["state"]) for a in jep["attempts"]]
            have = [(a["commit"][:12], a.get("state", "pushed")) for a in state["attempts"]]
            if want != have:
                # The journal is written first, so it can only be ahead. A
                # state attempt the journal lacks means the journal was
                # edited: the bound cannot be trusted.
                if {c for c, _s in have} - {c for c, _s in want}:
                    raise GuardError("the episode file records an attempt the journal does not: the journal was "
                                     "edited, so the bound cannot be counted; escalate")
                # Write-ahead recovery: the journal wins (D00 T04 §39).
                by_short = {a["commit"][:12]: a for a in state["attempts"]}
                state["attempts"] = [dict(by_short.get(a["commit"], {"commit": a["full"] or _canon(root, a["commit"]),
                                                                     "red": a["red"]}), state=a["state"])
                                     for a in jep["attempts"]]
                _publish(path, json.dumps(state, indent=1).encode("utf-8"))
                note = " (recovered from the journal)"
        if action == "restore":
            if state:
                return 0, f"repair: episode {state['episode'][:12]} is present; nothing to restore{note}"
            if not workflow:
                raise GuardError("repair restore needs --workflow and --run-file: the restored episode is bound to both")
            if jep is None or not jep["attempts"]:
                return 0, "repair: the run file shows no open episode; nothing to restore"
            repo, branch, wf, run = jep["ident"]
            here = _repo_identity(root)
            for key, was, now in (("repository", repo, here["repo"] or "-"),
                                  ("branch", branch, here["branch"] or "-"), ("workflow", wf, workflow)):
                if was != now:
                    raise GuardError(f"the journal's episode belongs to {key} {was!r}, not {now!r}: "
                                     f"restore refuses to rebind it")
            if run != campaign:
                raise GuardError(f"the journal's episode belongs to campaign run {run}, not {campaign}: "
                                 f"restore refuses a journal from another campaign")
            # The receipts carry full shas, read in preference to the
            # prose's printed prefixes (D00 T04 §41).
            state = {"episode": jep["full"] or _canon(root, jep["episode"]),
                     "attempts": [{"red": _canon(root, a["red"]) if a["red"] else "",
                                   "commit": a["full"] or _canon(root, a["commit"]), "state": a["state"]}
                                  for a in jep["attempts"]],
                     "repo": here["repo"], "branch": here["branch"], "workflow": workflow, "run_file": run_file,
                     "run": run, "restored": True}
            _publish(path, json.dumps(state, indent=1).encode("utf-8"))
            return 0, (f"repair: episode {state['episode'][:12]} restored from {run_file} at "
                       f"{len(_active(state))} of {REPAIR_BOUND} attempts")
        if action == "status":
            if not state:
                if jep and jep["attempts"]:
                    return 1, (f"repair: the episode file is lost but {run_file} shows episode {jep['episode']} at "
                               f"{len(_active(jep))} of {REPAIR_BOUND} attempts: run repair restore before any repair")
                return 0, f"repair: no open episode{note}"
            pending = [a["commit"][:12] for a in state["attempts"] if a.get("state") == "reserved"]
            return 0, (f"repair: episode {state['episode'][:12]} open, {len(_active(state))} of {REPAIR_BOUND} "
                       f"attempts used" + (f"; reserved, push unconfirmed: {', '.join(pending)}" if pending else "")
                       + note)
        identity = {**_repo_identity(root), "workflow": workflow, "run_file": run_file}
        if state and action in ("attempt", "pushed", "abandon", "close", "retire"):
            for key in ("repo", "branch", "workflow", "run_file"):
                if workflow or key != "workflow":
                    if state.get(key, identity[key]) != identity[key]:
                        raise GuardError(f"the open episode belongs to {key} {state.get(key)!r}, not {identity[key]!r}; "
                                         f"refusing to mix episodes")
            if not state.get("run"):
                raise GuardError("the open episode records no campaign run (an episode file from before D00 T04 "
                                 "§39): its journal lines cannot carry their identity, so escalate")
        if action == "attempt":
            if not red or not commit or not workflow:
                raise GuardError("repair attempt needs --red, --commit, --workflow, and --run-file")
            if not state and jep and jep["attempts"]:
                raise GuardError(f"the run file shows open episode {jep['episode']} but its file is lost: "
                                 f"run repair restore first")
            red, commit = _canon(root, red), _canon(root, commit)
            opening = state is None
            state = state or {"episode": red, "attempts": [], **identity, "run": campaign}
            done = [a for a in state["attempts"] if _canon(root, a.get("commit", "")) == commit]
            if done and done[0].get("state") == "abandoned":
                # A retried push of an abandoned commit is reserved again and
                # counts again, under the bound (independent review, P2).
                if len(_active(state)) >= REPAIR_BOUND:
                    return 1, (f"repair: episode {state['episode'][:12]} has used all {REPAIR_BOUND} attempts: "
                               f"the bound is exhausted, escalate (PARKED ... escalation:, then end --reason escalation)")
                n = state["attempts"].index(done[0]) + 1
                done[0]["state"] = "reserved"
                line = (f"repair: episode {state['episode'][:12]} attempt {n} of {REPAIR_BOUND} reserved "
                        f"({commit[:12]} repairs {done[0]['red'][:12]}){_ident_suffix(state)}")
                receipt = _receipt("reserved", state, attempt=n, sha=commit, red=done[0]["red"])
                _journal_append(root, run_file, line, receipt)
                _crash("repair:journal-written")
                _publish(path, json.dumps(state, indent=1).encode("utf-8"))
                return 0, line + " (reserved again after it was abandoned)\n" + receipt
            if done:
                n = state["attempts"].index(done[0]) + 1
                return 0, (f"repair: episode {state['episode'][:12]} attempt {n} of {REPAIR_BOUND} reserved "
                           f"({commit[:12]} repairs {done[0]['red'][:12]}){_ident_suffix(state)} already counted{note}")
            if len(_active(state)) >= REPAIR_BOUND:
                return 1, (f"repair: episode {state['episode'][:12]} has used all {REPAIR_BOUND} attempts: "
                           f"the bound is exhausted, escalate (PARKED ... escalation:, then end --reason escalation)")
            state["attempts"].append({"red": red, "commit": commit, "state": "reserved"})
            n = len(state["attempts"])
            line = (f"repair: episode {state['episode'][:12]} attempt {n} of {REPAIR_BOUND} reserved "
                    f"({commit[:12]} repairs {red[:12]}){_ident_suffix(state)}")
            receipt = _receipt("reserved", state, attempt=n, sha=commit, red=red)
            lines = [line, receipt]
            if opening:
                lines = [f"repair: episode {state['episode'][:12]} opened on red {red[:12]}{_ident_suffix(state)}",
                         _receipt("opened", state, red=red, remaining=REPAIR_BOUND), *lines]
            _journal_append(root, run_file, *lines)
            _crash("repair:journal-written")
            _publish(path, json.dumps(state, indent=1).encode("utf-8"))
            return 0, line + " (then push it, and mark it pushed or abandoned)\n" + receipt
        if action in ("pushed", "abandon"):
            if not commit:
                raise GuardError(f"repair {action} needs --commit and --run-file")
            if not state:
                raise GuardError("there is no open episode to mark")
            commit = _canon(root, commit)
            hit = [a for a in state["attempts"] if _canon(root, a.get("commit", "")) == commit]
            if not hit:
                raise GuardError(f"no reserved attempt names {commit[:12]}")
            if hit[0].get("state") != "reserved":
                return 0, f"repair: attempt {commit[:12]} is already {hit[0].get('state')}{note}"
            n = state["attempts"].index(hit[0]) + 1
            new = "pushed" if action == "pushed" else "abandoned"
            tail = ""
            if new == "abandoned":
                if not reason:
                    raise GuardError("repair abandon needs --reason (why the push did not land)")
                # A push can land after its client failed: the remote is
                # asked before the place is freed (D00 T04 §41).
                delivered, detail = _delivered(root, remote or "origin", state.get("branch") or "", commit)
                if delivered is None:
                    raise GuardError(f"repair abandon could not read the remote ({detail}), so whether "
                                     f"{commit[:12]} landed is unknown: it stays reserved; retry when the remote "
                                     f"answers")
                if delivered:
                    new, tail = "pushed", f" (it reached the remote before its client failed: {detail})"
            hit[0]["state"] = new
            line = (f"repair: episode {state['episode'][:12]} attempt {n} of {REPAIR_BOUND} {new} ({commit[:12]})"
                    f"{_ident_suffix(state)}" + (f": {reason}" if new == "abandoned" else ""))
            receipt = _receipt(new, state, attempt=n, sha=commit)
            _journal_append(root, run_file, line, receipt)
            _crash("repair:journal-written")
            _publish(path, json.dumps(state, indent=1).encode("utf-8"))
            return 0, line + tail + "\n" + receipt
        if action == "close":
            if not green:
                raise GuardError("repair close needs --green <sha>")
            if not state:
                return 0, f"repair: no open episode to close{note}"
            wf = workflow or state.get("workflow", "")
            want = re.compile(rf"\Aci-wait: {re.escape(green[:12])}[0-9a-f]* {re.escape(wf)} success\b")
            if not want.match(evidence or ""):
                raise GuardError("repair close needs --evidence with the green ci-wait line for this sha and "
                                 "workflow (an authorized no-run is not green)")
            # D00 T04 §41: the line names the attempt it read and the
            # workflow's immutable id, and both must be GitHub's latest.
            ev_bind = re.search(r" attempt=(\d+) workflow-id=(\d+)\b", evidence)
            if not ev_bind:
                raise GuardError("repair close needs the ci-wait line that names its run attempt and workflow id "
                                 "(`attempt=N workflow-id=W`): re-run ci-wait")
            if any(a.get("state") == "reserved" for a in state["attempts"]):
                raise GuardError("an attempt is still reserved with its push unconfirmed: mark it pushed or "
                                 "abandoned before closing")
            last = next((a["commit"] for a in reversed(state["attempts"]) if a.get("state") == "pushed"),
                        state["episode"])
            rc, _ = _git(root, "merge-base", "--is-ancestor", last, green)
            if rc != 0:
                raise GuardError(f"the green {green[:12]} does not descend from the last attempt {last[:12]}; "
                                 f"it cannot close this episode")
            # D00 T04 §39: GitHub's record, not the pasted line, proves green.
            run, why = _green_run(root, _canon(root, green), wf)
            if run is None:
                raise GuardError(f"repair close could not re-read the green run: {why}")
            checks = (("head sha", run.get("headSha") == _canon(root, green)),
                      ("conclusion", run.get("status") == "completed" and run.get("conclusion") == "success"),
                      ("workflow", run.get("workflowName") in (wf, None)),
                      ("branch", run.get("headBranch") == state.get("branch")),
                      ("repository", bool(_repo_slug(state.get("repo", "")))
                       and f"/{_repo_slug(state.get('repo', ''))}/actions/" in str(run.get("url", ""))),
                      ("run id", re.search(rf"/runs/{run.get('databaseId')}\b", evidence or "") is not None),
                      ("attempt", str(run.get("attempt") or "") == ev_bind.group(1)),
                      ("workflow id", str(run.get("workflowDatabaseId") or "") == ev_bind.group(2)))
            bad = [name for name, ok in checks if not ok]
            if bad:
                raise GuardError(f"GitHub's record of run {run.get('databaseId')} disagrees on {', '.join(bad)}: "
                                 f"it cannot close this episode")
            line = (f"repair: episode {state['episode'][:12]} closed green at {green[:12]} (run "
                    f"{run.get('databaseId')} attempt {run.get('attempt')} workflow-id {run.get('workflowDatabaseId')}) "
                    f"after {len(_active(state))} attempt(s){_ident_suffix(state)}")
            receipt = _receipt("closed", state, sha=_canon(root, green), run=run.get("databaseId"),
                               run_attempt=run.get("attempt"), workflow_id=run.get("workflowDatabaseId"))
            _journal_append(root, run_file, line, receipt)
            _crash("repair:journal-written")
            os.unlink(path)
            return 0, line + "\n" + receipt
        if action == "retire":
            if not state:
                return 0, f"repair: no open episode to retire{note}"
            wf = workflow or state.get("workflow", "")
            m = re.match(rf"\Aci-wait: ([0-9a-f]{{7,}}) {re.escape(wf)} NOT GREEN: no run within \d+s, as authorized "
                         rf"by (\S+) at (\d{{4}}-\d{{2}}-\d{{2}}T\d{{2}}:\d{{2}}(?::\d{{2}})?Z) for ([0-9a-f]{{7,}})\.\."
                         rf"([0-9a-f]{{7,}}) branch=(\S+) workflow-path=(\S+) \(", evidence or "")
            if not m:
                raise GuardError("repair retire needs --evidence with the authorized NOT GREEN line for this "
                                 "episode's workflow (naming its authorization, approved range, branch, and "
                                 "workflow path): only an authorized retirement ends an episode without green")
            # The evidence binds the episode's repair head: no reservation is
            # open, the silent push descends from the last pushed attempt,
            # and it is the approved range's head (independent review, P2).
            if any(a.get("state") == "reserved" for a in state["attempts"]):
                raise GuardError("an attempt is still reserved with its push unconfirmed: mark it pushed or "
                                 "abandoned before retiring")
            silent, who, when = _canon(root, m.group(1)), m.group(2), m.group(3)
            base, head, branch, wf_path = _canon(root, m.group(4)), _canon(root, m.group(5)), m.group(6), m.group(7)
            if head != silent:
                raise GuardError("the NOT GREEN line's approved range must end at the silent push it names")
            if branch != state.get("branch"):
                raise GuardError(f"the NOT GREEN line names branch {branch}, not the episode's {state.get('branch')}")
            last = next((a["commit"] for a in reversed(state["attempts"]) if a.get("state") == "pushed"),
                        state["episode"])
            if _git(root, "merge-base", "--is-ancestor", last, silent)[0] != 0:
                raise GuardError(f"the silent push {silent[:12]} does not descend from the last attempt {last[:12]}; "
                                 f"it cannot retire this episode")
            # Panel round 1 of the D00 T04 §41 review: the path must name
            # the episode's workflow, proven at the range's base (where it
            # still ran), so a made-up path never reads as "no workflow".
            shown_base = subprocess.run(["git", "show", f"{base}:{wf_path}"], cwd=root, capture_output=True)
            base_text = shown_base.stdout.decode("utf-8", errors="replace") if shown_base.returncode == 0 else ""
            base_name = re.search(r"(?m)^name:[ \t]*['\"]?([^'\"#\n]+?)['\"]?[ \t]*(?:#.*)?$", base_text)
            stem = os.path.splitext(os.path.basename(wf_path))[0]
            if not base_text or not ((base_name and base_name.group(1).strip() == wf) or stem == wf):
                raise GuardError(f"{wf_path} at {base[:12]} is not the episode's workflow {wf}: the NOT GREEN line "
                                 f"cannot retire the episode")
            # D00 T04 §41: the line is not trusted for exclusion; the
            # committed workflow at the silent push is re-read with the same
            # reader ci-wait uses.
            rp = _review_prompt()
            shown = subprocess.run(["git", "show", f"{silent}:{wf_path}"], cwd=root, capture_output=True)
            wf_text = shown.stdout.decode("utf-8", errors="replace") if shown.returncode == 0 else None
            paths, why_paths = rp.changed_paths_for_push(base, silent, cwd=root)
            if paths is None:
                raise GuardError(f"the pushed paths of {base[:12]}..{silent[:12]} cannot be derived ({why_paths}), "
                                 f"so the exclusion cannot be re-derived: escalate")
            excluded, why = rp.push_excluded(rp.push_trigger_filter(wf_text), branch, paths)
            if not excluded:
                raise GuardError(f"the committed {wf_path} at {silent[:12]} does not exclude this push ({why}): the "
                                 f"NOT GREEN line cannot retire the episode")
            line = (f"repair: episode {state['episode'][:12]} retired{_ident_suffix(state)}: {wf} no longer runs "
                    f"this push (authorized by {who} at {when} for {base[:12]}..{silent[:12]}; re-derived: {why})")
            receipt = _receipt("retired", state, sha=silent, authorized_by=who, authorized_at=when,
                               approved_range=f"{base}..{silent}", exclusion=why)
            _journal_append(root, run_file, line, receipt)
            _crash("repair:journal-written")
            os.unlink(path)
            return 0, line + "\n" + receipt
        raise GuardError(f"repair action {action!r} is not attempt, pushed, abandon, close, retire, status, "
                         f"restore, or ceiling")


def _ceiling(root: str, run_id: str, attempt: str, run_file: str, campaign: str) -> tuple[int, str]:
    """One re-run of `ci-wait` past its ceiling per GitHub run attempt,
    keyed by repository, run id, and attempt, journalled in the run file
    with the campaign run (D00 T04 §39, §41). The file under build/ is a
    cache the journal rebuilds; a corrupt cache escalates, and a cache
    entry for this run file its journal lacks means the journal was changed
    or truncated, which refuses rather than renewing the allowance."""
    if not run_id:
        raise GuardError("repair ceiling needs --run-id <GitHub run id>")
    if not campaign:
        raise GuardError("repair ceiling needs a live campaign guard with a run id: the allowance is journalled "
                         "with its campaign")
    key = f"{_repo_slug(_repo_identity(root)['repo']) or 'unknown-repo'}#{run_id}@{attempt}"
    cpath = _ceiling_path(root)
    try:
        with open(cpath, encoding="utf-8") as fh:
            seen = json.load(fh)
        if not isinstance(seen, dict):
            raise ValueError("not an object")
        note = ""
    except FileNotFoundError:
        seen, note = {}, ""
    except (OSError, ValueError):
        raise GuardError("the ceiling record is unreadable; escalate rather than wait again")
    # Panel round 1 of the D00 T04 §41 review: ceiling lines replay as
    # strictly as the episode's. A prose line and the receipt written with
    # it must agree, a key is used once, every use belongs to this campaign,
    # and a cached campaign must be the journal's.
    journalled: dict[str, str] = {}
    rows = _journal_lines(_journal_text(root, run_file))
    k = 0
    while k < len(rows):
        ln = rows[k]
        use = None
        if ln.startswith("repair: ceiling "):
            m = _CEILING_LINE.match(ln)
            if not m:
                raise GuardError(f"{run_file} holds a ceiling line that does not parse ({ln[:80]!r}): escalate")
            use = (m.group(1), m.group(2))
            if k + 1 < len(rows) and rows[k + 1].startswith("repair-receipt: "):
                rc = _parse_receipt(rows[k + 1])
                if rc is not None and rc["event"] == "ceiling":
                    if (rc["key"], rc["campaign"]) != use:
                        raise GuardError(f"{run_file}: a ceiling line and its receipt disagree (an edited journal): "
                                         f"escalate")
                    k += 1
        elif ln.startswith("repair-receipt: "):
            rc = _parse_receipt(ln)
            if rc is not None and rc["event"] == "ceiling":
                use = (rc["key"], rc["campaign"])
        k += 1
        if use is None:
            continue
        if use[0] in journalled:
            raise GuardError(f"{run_file} records the ceiling allowance for {use[0]} twice (a duplicate line): "
                             f"escalate")
        if use[1] != campaign:
            raise GuardError(f"{run_file} records a ceiling allowance under campaign run {use[1]}, not {campaign}: "
                             f"a journal from another campaign; escalate")
        journalled[use[0]] = use[1]
    for key_s, v in seen.items():
        if isinstance(v, dict) and key_s in journalled and v.get("campaign") != journalled[key_s]:
            raise GuardError(f"the ceiling record binds {key_s} to campaign run {v.get('campaign')}, but the journal "
                             f"to {journalled[key_s]}: escalate")
    gone = sorted(k for k, v in seen.items() if isinstance(v, dict) and v.get("run_file") == run_file
                  and k not in journalled)
    if gone:
        raise GuardError(f"the ceiling record holds {', '.join(gone)} for {run_file}, but its journal does not (a "
                         f"changed or truncated journal): escalate rather than renew an allowance")
    lost = sorted(k for k in journalled if k not in seen)
    if lost:
        seen.update({k: {"campaign": journalled[k], "run_file": run_file} for k in lost})
        _publish(cpath, json.dumps(seen).encode("utf-8"))
        note = f" (restored {len(lost)} lost allowance record(s) from the journal)"
    if key in seen:
        return 1, (f"repair: run {key} already had its one re-run past the ceiling: escalate "
                   f"(a queue that never drains is outside the tree){note}")
    receipt = "repair-receipt: " + json.dumps({"v": RECEIPT_VERSION, "event": "ceiling", "campaign": campaign,
                                               "key": key, "run": run_id, "run_attempt": attempt,
                                               "outcome": "ceiling", "remaining": 0},
                                              sort_keys=True, separators=(",", ":"))
    _journal_append(root, run_file, f"repair: ceiling allowance used for {key} run={campaign}", receipt)
    _crash("repair:journal-written")
    seen[key] = {"campaign": campaign, "run_file": run_file}
    _publish(cpath, json.dumps(seen).encode("utf-8"))
    return 0, f"repair: run {key} may re-run ci-wait once more past the ceiling{note}\n{receipt}"


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
    # An empty listing prints the tool's own sentinel, as CronList does.
    return "\n".join(lines) if lines else "No scheduled jobs."


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
        # Panel round 1 of the D00 T04 §40 review: the job is released only
        # with a listing that shows its carrier.
        cl_a = _cl(("job-a", heartbeat_tag(lroot, g1, RUN_FILE)))
        check("whoami-owner-names-the-run",
              whoami(lroot, SESSION, g1, cl_a) == f"OWNER run={read_guard(lroot)['run_id']} job=job-a"
              and "job withheld: no CronList text given" in whoami(lroot, SESSION, g1),
              whoami(lroot, SESSION, g1, cl_a))
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
                  for r in reconcile(lroot, SESSION, "No scheduled jobs.", RUN_FILE)))
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
        rc = reconcile(iroot, OTHER, "No scheduled jobs.", RUN_FILE)
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
        # D00 T04 §40: duplicates rotate the generation; no carrier is kept.
        check("whoami-names-a-duplicate-generation",
              out.splitlines()[0] == f"OWNER run={read_guard(iroot)['run_id']} (job withheld until the generation "
                                     f"rotates)"
              and f"DUPLICATE GENERATION: job-1, job-2 carry generation {g}: rotate it" in out and "job-9" not in out
              and "job=" not in out and "CronDelete job-1, job-2, each after delete-check" in out, out)
        # Panel round 1: the job id is released only once one carrier lives.
        out = whoami(iroot, SESSION, g, _cl(("job-1", tag), ("job-9", "an unrelated reminder")))
        check("whoami-releases-the-job-once-one-carrier-lives",
              out == f"OWNER run={read_guard(iroot)['run_id']} job=job-1", out)
        # Panel round 2: no carrier at all releases nothing either.
        out = whoami(iroot, SESSION, g, _cl(("job-9", "an unrelated reminder")))
        check("whoami-withholds-the-job-without-a-live-carrier",
              "job=" not in out and "NO LIVE CARRIER: the guard's job job-1 is not in the CronList text" in out, out)
        _eg = read_guard(iroot)
        os.makedirs(_errors_dir(iroot), exist_ok=True)
        with open(os.path.join(_errors_dir(iroot), "00000000000000000009-1-e00000000009.json"), "w",
                  encoding="utf-8") as fh:
            json.dump({"id": "e00000000009", "at": "2099-01-01T00:00:00Z", "reason": "r"}, fh)
        os.remove(_paths(iroot)[0])
        try:
            hook_error(iroot, SESSION, "e00000000009", _eg["generation"], "job-1")
            check("hook-error-refuses-a-fenced-ack-without-a-guard", False)
        except GuardError as exc:
            check("hook-error-refuses-a-fenced-ack-without-a-guard",
                  "no guard file" in str(exc) and len(_hook_errors(iroot)) == 1, str(exc))
        shutil.rmtree(_errors_dir(iroot))
        with open(_paths(iroot)[0], "w", encoding="utf-8") as fh:
            json.dump(_eg, fh)
        out = whoami(iroot, SESSION, g, _cl(("job-2", tag), ("job-3", tag)))
        check("whoami-rotates-when-the-guards-job-is-lost",
              f"DUPLICATE GENERATION: job-2, job-3 carry generation {g} and the guard's job job-1 is not live: "
              f"rotate it" in out and "CronDelete job-2, job-3" in out, out)
        # The rotation leaves every old carrier obsolete, an in-flight firing
        # of a deleted duplicate included, and the fence before CronDelete
        # refuses only the live guard's current job (D00 T04 §40).
        g_new = mint_generation()
        acquire(iroot, SESSION, 0, RUN_FILE, "job-4", generation=g_new)
        check("a-rotated-generation-makes-every-old-carrier-obsolete",
              whoami(iroot, SESSION, g, _cl(("job-4", heartbeat_tag(iroot, g_new, RUN_FILE))))
              == "NOT THE CURRENT JOB", whoami(iroot, SESSION, g))
        code_k, keep_k = delete_check(iroot, SESSION, "job-4")
        code_d, keep_d = delete_check(iroot, SESSION, "job-2")
        code_o, keep_o = delete_check(iroot, OTHER, "job-4")
        check("delete-check-keeps-only-the-live-guards-job",
              code_k == 1 and keep_k.startswith("KEEP: job-4 is the live guard's current job")
              and code_d == 0 and keep_d.startswith("DELETE OK") and code_o == 0, f"{keep_k} {keep_d} {keep_o}")
        # A re-point between listing and deletion is seen at the delete.
        listed = "job-5"
        acquire(iroot, SESSION, 0, RUN_FILE, listed, generation=mint_generation())
        code_l, line_l = delete_check(iroot, SESSION, listed)
        check("delete-check-sees-a-re-point-between-listing-and-deletion", code_l == 1 and "KEEP" in line_l, line_l)
        acquire(iroot, SESSION, 0, RUN_FILE, "job-1", generation=g)
        r = _cli("whoami", "--session", SESSION, "--generation", g, "--cronlist", "-",
                 stdin=_cl(("job-1", tag), ("job-2", tag)))
        check("whoami-reads-the-cronlist-from-stdin", "CronDelete job-1, job-2" in r.stdout, r.stdout + r.stderr)
        r_u = _cli("whoami", "--session", SESSION, "--generation", g, "--cronlist", "-", stdin="HTTP 502")
        check("whoami-withholds-the-job-on-an-unreadable-listing",
              "UNKNOWN LISTING" in r_u.stdout and "job=" not in r_u.stdout, r_u.stdout + r_u.stderr)
        check("heartbeat-tag-fits-the-cronlist-cut",
              len(heartbeat_tag(REPO, g, "docs/phase-runs/2026-12-31-phase-10.md")) < 79
              and parse_cronlist(_cl(("abc123", heartbeat_tag(REPO, g, "docs/phase-runs/2026-12-31-phase-10.md")
                                      + ": the campaign for Resolute Phase 10, run file ...")))[0][0] == "abc123",
              heartbeat_tag(REPO, g, "docs/phase-runs/2026-12-31-phase-10.md"))

        # Scoped reconciliation, and each startup interruption recovering to
        # exactly one current heartbeat and a consistent run record.
        other_run = "docs/phase-runs/2099-02-02-phase-1.md"
        # D00 T04 §40: a checkout sharing this one's folder name, and a long
        # path, scope by digest; the header keeps its stated length.
        twin = os.path.join(itmp, "elsewhere", os.path.basename(iroot))
        deep = os.path.join(itmp, *(["a-long-directory-name"] * 12), os.path.basename(iroot))
        noise = _cl(("x-repo", heartbeat_tag(twin, g, RUN_FILE) + ": ..."),
                    ("x-run", heartbeat_tag(iroot, g, other_run) + ": ..."),
                    ("x-v38", f"Claude run-guard heartbeat {g} {repo_name(iroot)} {run_stem(RUN_FILE)}: ..."),
                    ("x-legacy", "Claude run-guard heartbeat for Resolute Phase 0 (run file docs/phase-runs/20"),
                    ("x-plain", "remind me at 3pm"))
        _reset()
        rc = reconcile(iroot, SESSION, noise, RUN_FILE)
        check("reconcile-scopes-by-workspace-digest",
              "reconcile: job x-repo is a heartbeat for another workspace or run" in "\n".join(rc)
              and "reconcile: job x-run is a heartbeat for another workspace or run" in "\n".join(rc)
              and "job x-v38 is a legacy heartbeat" in "\n".join(rc) and "job x-legacy is a legacy heartbeat" in "\n".join(rc)
              and not any("x-plain" in r or "orphan" in r for r in rc), str(rc))
        check("heartbeat-tag-has-a-fixed-length-and-no-collision",
              {len(heartbeat_tag(p_, g, RUN_FILE)) for p_ in (iroot, twin, deep)} == {HEARTBEAT_TAG_LENGTH}
              and len({workspace_digest(p_, RUN_FILE) for p_ in (iroot, twin, deep)}) == 3,
              str([heartbeat_tag(p_, g, RUN_FILE) for p_ in (iroot, twin, deep)]))
        # An unreadable listing names nothing for deletion (D00 T04 §40).
        for label, text in (("garbled", "HTTP 502 while listing jobs"), ("truncated", _cl(("job-1", "x"))[:5]),
                            ("missing", "")):
            rc_u = reconcile(iroot, SESSION, text, RUN_FILE)
            check(f"reconcile-an-unreadable-listing-names-nothing: {label}",
                  any("UNKNOWN" in r for r in rc_u) and not any("CronDelete" in r for r in rc_u), str(rc_u))
        # (1) CronCreate landed, acquire never ran: the job is an orphan.
        g1 = mint_generation()
        live = [("job-c1", heartbeat_tag(iroot, g1, RUN_FILE) + ": ...")]
        rc = reconcile(iroot, SESSION, _cl(*live), RUN_FILE)
        live = []  # the runner deletes it
        rc2 = reconcile(iroot, SESSION, _cl(*live), RUN_FILE)
        # ...and the start then completes (panel round 1: recovery ends at
        # one current heartbeat and a consistent record, not at none).
        g1b = mint_generation()
        live = [("job-c1b", heartbeat_tag(iroot, g1b, RUN_FILE) + ": ...")]
        acquire(iroot, SESSION, 0, RUN_FILE, "job-c1b", generation=g1b)
        with open(irun, "a", encoding="utf-8") as fh:
            fh.write(f"\n- run guard: heartbeat job-c1b generation {g1b}\n")
        rc3 = reconcile(iroot, SESSION, _cl(*live))
        check("interrupted-after-croncreate-recovers",
              rc == ["reconcile: orphan job job-c1 has no guard: CronDelete it"]
              and rc2 == ["reconcile: consistent (no guard, no job)"]
              and rc3 == ["reconcile: consistent (guard and job job-c1b)"], f"{rc} {rc2} {rc3}")
        end(iroot, SESSION, "operator-stop", g1b, "job-c1b")
        cancel_confirmed(iroot, "job-c1b", SESSION, g1b)
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
                    "--cron-id", "job-k", "--run", rid)
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
              and pend.startswith("pending-cancel: end incomplete for job job-k (reason park)")
              and "finish it with end --reason park before anything else" in pend
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
        mig = whoami(iroot, SESSION, g_l["generation"], _cl(("job-1", heartbeat_tag(iroot, g_l["generation"], RUN_FILE))))
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
        # Panel round 3: a state written before states carried a run id is
        # migrated at a same-run handover, never deleted.
        with open(_paths(iroot)[1], "w", encoding="utf-8") as fh:
            json.dump({"fingerprint": "f", "blocks": 1, "trips": 1, "stalled": False,
                       "hook_error": "legacy boom", "hook_error_at": "2099-01-01T00:00:00Z"}, fh)
        acquire(iroot, SESSION, 0, RUN_FILE, "job-h2", handover="drill back", generation=mint_generation())
        st = _state(iroot)
        check("a-handover-migrates-a-legacy-state",
              st.get("run_id") == rid and st.get("trips") == 1 and st.get("hook_error") == "legacy boom"
              and "legacy boom" in hook_error(iroot, SESSION), str(st))
        # Panel round 4: a legacy guard (no run id) re-pointed by its owner on
        # the same run file keeps its legacy state, migrated with it.
        _guard(iroot, run_file=RUN_FILE)
        with open(_paths(iroot)[1], "w", encoding="utf-8") as fh:
            json.dump({"fingerprint": "f", "blocks": 1, "trips": 1, "stalled": False}, fh)
        acquire(iroot, SESSION, 0, RUN_FILE, "job-1", generation=mint_generation())
        st = _state(iroot)
        check("a-legacy-guard-re-point-keeps-its-legacy-state",
              st.get("trips") == 1 and st.get("run_id") == read_guard(iroot)["run_id"] and bool(st.get("run_id")),
              f"{st} {read_guard(iroot)}")
        acquire(iroot, OTHER, 1, other_run, "job-n", handover="drill new run", generation=mint_generation())
        check("a-new-run-starts-a-clean-breaker", _state(iroot) == {} and read_guard(iroot)["run_id"] != rid,
              str(_state(iroot)))

    # D00 T04 §40: the whole identity on every owner mutation, a legacy
    # state tagged before an acquisition can orphan it, orphan errors and
    # pending records drained at startup, malformed files quarantined and
    # the guard recovered from the run record, injected failures, and a
    # credential-free repository identity.
    with tempfile.TemporaryDirectory(prefix="campaign-fence-") as ftmp:
        froot = _workspace(ftmp)
        frun = os.path.join(froot, RUN_FILE)

        def _fcli(*args: str, env: dict | None = None) -> subprocess.CompletedProcess:
            return subprocess.run([sys.executable, os.path.join(HERE, "campaign_guard.py"), *args, "--root", froot],
                                  capture_output=True, text=True, encoding="utf-8",
                                  env=dict(os.environ, PYTHONIOENCODING="utf-8", **(env or {})))

        def _fresh_f(body: str = "# run\n") -> None:
            for f in (*_paths(froot), _pending_path(froot)):
                if os.path.exists(f):
                    os.remove(f)
            for d in (_errors_dir(froot), os.path.join(froot, "build", _QUARANTINE)):
                if os.path.isdir(d):
                    shutil.rmtree(d)
            with open(frun, "w", encoding="utf-8") as fh:
                fh.write(body)

        # Item 2: `--run` is required and re-checked.
        _fresh_f()
        g = mint_generation()
        acquire(froot, SESSION, 0, RUN_FILE, "job-f", generation=g)
        rid = read_guard(froot)["run_id"]
        for cmd in (["end", "--session", SESSION, "--reason", "operator-stop", "--generation", g, "--cron-id", "job-f"],
                    ["reset-state", "--session", SESSION, "--generation", g, "--cron-id", "job-f"],
                    ["hook-error", "--session", SESSION, "--generation", g, "--cron-id", "job-f", "--ack", "x"]):
            r = _fcli(*cmd)
            check(f"cli-{cmd[0]}-requires-the-run", r.returncode == 1 and "--run" in r.stderr, r.stderr)
        stale_run = _fcli("end", "--session", SESSION, "--reason", "operator-stop", "--generation", g,
                          "--cron-id", "job-f", "--run", "0000deadbeef")
        check("fence-refuses-a-stale-run",
              stale_run.returncode == 1 and "the guard's run is" in stale_run.stderr and read_guard(froot) is not None,
              stale_run.stderr)
        # Item 1: a legacy two-trip state is tagged with the outgoing run
        # before a new guard publishes; a crash at each step reads either
        # the old run's breaker (the old guard still lives) or a fresh one.
        for label in ("acquire:state-tagged", "acquire:repoint-tmp", "acquire:repoint-published"):
            _fresh_f()
            acquire(froot, SESSION, 0, RUN_FILE, "job-f", generation=g)
            old_run = read_guard(froot)["run_id"]
            with open(_paths(froot)[1], "w", encoding="utf-8") as fh:
                json.dump({"fingerprint": "f", "blocks": 2, "trips": 2, "stalled": True}, fh)
            r = _fcli("acquire", "--session", SESSION, "--phase", "1", "--run-file", "docs/phase-runs/2099-05-05-phase-1.md",
                      "--cron-id", "job-n", "--generation", mint_generation(), env={"CAMPAIGN_CRASH_AT": label})
            new_guard = read_guard(froot)
            moved = new_guard["run_id"] != old_run
            tagged = _state(froot)
            with open(os.path.join(froot, "docs/phase-runs/2099-05-05-phase-1.md"), "w", encoding="utf-8") as fh:
                fh.write("# run\n")
            code, out, _ = run_hook(froot, SESSION)
            st = _state(froot)
            check(f"a-legacy-state-survives-a-crash-at-{label.split(':')[1]}",
                  r.returncode == 97 and tagged.get("run_id") == old_run and tagged.get("trips") == 2
                  and (not moved or (st.get("run_id") == new_guard["run_id"] and st.get("trips") == 0
                                     and st.get("blocks") == 1)),
                  f"{moved} {tagged} {st} {out}")
        # Item 5: after a terminated campaign, startup drains this session's
        # pending record and acknowledges the orphan error under its own
        # identity, keeping the error's origin in the line it records.
        _fresh_f()
        acquire(froot, SESSION, 0, RUN_FILE, "job-t", generation=g)
        rid_t = read_guard(froot)["run_id"]
        os.makedirs(_errors_dir(froot), exist_ok=True)
        with open(os.path.join(_errors_dir(froot), "00000000000000000001-1-eaaaaaaaaaaa.json"), "w", encoding="utf-8") as fh:
            json.dump({"id": "eaaaaaaaaaaa", "at": "2099-01-01T00:00:00Z", "reason": "late failure",
                       "session": SESSION, "run_id": rid_t, "generation": g}, fh)
        end(froot, SESSION, "operator-stop", g, "job-t", rid_t)
        rc = reconcile(froot, SESSION, "No scheduled jobs.", RUN_FILE)
        joined = "\n".join(rc)
        check("startup-drains-a-terminated-campaigns-records",
              "pending cancellation is unconfirmed: CronDelete job-t" in joined
              and f"an orphan hook error: campaign-stop hook failed at 2099-01-01T00:00:00Z [id=eaaaaaaaaaaa session={SESSION} "
                  f"run={rid_t}" in joined and "--startup yes --ack eaaaaaaaaaaa" in joined, joined)
        acked = _fcli("hook-error", "--session", SESSION, "--startup", "yes", "--ack", "eaaaaaaaaaaa")
        check("a-startup-ack-clears-an-orphan-error",
              acked.returncode == 0 and f"session={SESSION} run={rid_t}" in acked.stdout and _hook_errors(froot) == [],
              acked.stdout + acked.stderr)
        acquire(froot, SESSION, 0, RUN_FILE, "job-u", generation=g)
        with open(os.path.join(_errors_dir(froot), "00000000000000000002-1-ebbbbbbbbbbb.json"), "w", encoding="utf-8") as fh:
            json.dump({"id": "ebbbbbbbbbbb", "at": "2099-01-01T00:00:00Z", "reason": "r"}, fh)
        live_ack = _fcli("hook-error", "--session", SESSION, "--startup", "yes", "--ack", "ebbbbbbbbbbb")
        check("a-startup-ack-refuses-while-a-guard-lives",
              live_ack.returncode == 1 and "needs no live guard" in live_ack.stderr, live_ack.stderr)
        # Item 7: malformed files are quarantined, bytes kept, and the guard
        # is recovered from the run file's own acquire record.
        _fresh_f()
        rec_line = acquire(froot, SESSION, 0, RUN_FILE, "job-r", generation=g)
        rid_r = read_guard(froot)["run_id"]
        with open(frun, "a", encoding="utf-8") as fh:
            fh.write(f"\n- run guard: `{rec_line}`\n")
        for name in ("claude-campaign-guard.json", "claude-campaign-state.json", "claude-campaign-pending-cancel.json"):
            with open(os.path.join(froot, "build", name), "w", encoding="utf-8") as fh:
                fh.write("{broken " + name)
        malformed = whoami(froot, SESSION, g)
        moved_q = quarantine(froot, SESSION)
        qdir = os.path.join(froot, "build", _QUARANTINE)
        kept = sorted(open(os.path.join(qdir, n), encoding="utf-8").read() for n in os.listdir(qdir))
        check("quarantine-moves-each-malformed-file-with-its-bytes",
              malformed == "MALFORMED GUARD" and len(moved_q) == 3 and len(kept) == 3
              and all(k.startswith("{broken claude-campaign-") for k in kept)
              and not any(os.path.exists(p_) for p_ in (*_paths(froot), _pending_path(froot))), f"{moved_q} {kept}")
        try:
            recover(froot, OTHER, RUN_FILE)
            check("recover-refuses-another-session", False)
        except GuardError as exc:
            check("recover-refuses-another-session", "not " + OTHER in str(exc), str(exc))
        back = recover(froot, SESSION, RUN_FILE)
        check("recover-restores-the-guard-from-the-run-record",
              "(read back)" in back
              and whoami(froot, SESSION, g, _cl(("job-r", heartbeat_tag(froot, g, RUN_FILE)))) == f"OWNER run={rid_r} job=job-r",
              back)
        # Panel round 1: a job cleared for deletion is never made current.
        code_c, line_c = delete_check(froot, SESSION, "job-old-r")
        try:
            acquire(froot, SESSION, 0, RUN_FILE, "job-old-r", generation=mint_generation())
            check("a-cleared-job-is-never-made-current", False)
        except GuardError as exc:
            check("a-cleared-job-is-never-made-current",
                  code_c == 0 and "was cleared for deletion by delete-check" in str(exc)
                  and read_guard(froot)["cron_id"] == "job-r", str(exc))
        check("quarantine-leaves-readable-files-alone",
              quarantine(froot, SESSION) == ["quarantine: every guard file parses; nothing moved"])
        # Item 8: an injected failure at each write, replace, and delete
        # leaves a lifecycle every reader handles.
        _fresh_f()
        acquire(froot, SESSION, 0, RUN_FILE, "job-w", generation=g)
        rid_w = read_guard(froot)["run_id"]
        with open(frun, "a", encoding="utf-8") as fh:
            fh.write(f"\nPARKED 2099-01-01T00:00:00Z run={rid_w} drill\n")
        run_hook(froot, SESSION)
        end_w = ("end", "--session", SESSION, "--reason", "park", "--generation", g, "--cron-id", "job-w", "--run", rid_w)
        for label, expect in (("write:claude-campaign-pending-cancel.json", "live"),
                              ("replace:claude-campaign-pending-cancel.json", "live"),
                              ("unlink:claude-campaign-guard.json", "incomplete"),
                              ("unlink:claude-campaign-state.json", "ended")):
            r = _fcli(*end_w, env={"CAMPAIGN_FAIL_AT": label})
            pend = pending_cancel(froot, SESSION)
            state_now = read_guard(froot)
            ok = (r.returncode == 1 and "injected failure" in r.stderr
                  and not [n for n in os.listdir(os.path.join(froot, "build")) if n.endswith(".tmp")])
            if expect == "live":
                ok = ok and state_now is not None and pend == ""
            elif expect == "incomplete":
                ok = ok and state_now is not None and pend.startswith("pending-cancel: end incomplete for job job-w")
            else:
                ok = ok and state_now is None and os.path.exists(_paths(froot)[1]) \
                    and pend.startswith("pending-cancel: CronDelete job-w")
            check(f"an-injected-failure-leaves-a-consistent-lifecycle: {label}", ok,
                  f"{r.returncode} {r.stderr[-160:]} {pend} {state_now}")
            if expect == "incomplete":
                done = _fcli(*end_w)
                check("an-end-left-incomplete-by-a-failed-delete-finishes-on-retry",
                      done.returncode == 0 and read_guard(froot) is None, done.stdout + done.stderr)
                acquire(froot, SESSION, 0, RUN_FILE, "job-w", generation=g)
                rid_w = read_guard(froot)["run_id"]
                run_hook(froot, SESSION)  # writes this run's state before its marker ends the run
                with open(frun, "a", encoding="utf-8") as fh:
                    fh.write(f"\nPARKED 2099-01-01T00:00:00Z run={rid_w} drill again\n")
                end_w = end_w[:-1] + (rid_w,)
        r_a = _fcli("acquire", "--session", OTHER, "--phase", "0", "--run-file", RUN_FILE, "--cron-id", "job-x",
                    env={"CAMPAIGN_FAIL_AT": "link:claude-campaign-guard.json"})
        check("an-injected-failure-at-the-guard-publish-leaves-no-guard",
              r_a.returncode == 1 and read_guard(froot) is None
              and not [n for n in os.listdir(os.path.join(froot, "build")) if n.endswith(".tmp")], r_a.stderr)
        # Panel round 2: recover never restores a cleared job, a clearance
        # never expires because other jobs were checked, and an unreadable
        # listing names nothing for deletion, pending records included.
        _fresh_f()
        rec2 = acquire(froot, SESSION, 0, RUN_FILE, "job-rc", generation=mint_generation())
        with open(frun, "a", encoding="utf-8") as fh:
            fh.write(f"\n- run guard: `{rec2}`\n")
        acquire(froot, SESSION, 0, RUN_FILE, "job-rc2", generation=mint_generation())
        delete_check(froot, SESSION, "job-rc")
        os.remove(_paths(froot)[0])
        try:
            recover(froot, SESSION, RUN_FILE)
            check("recover-refuses-a-cleared-job", False)
        except GuardError as exc:
            check("recover-refuses-a-cleared-job",
                  "was cleared for deletion by delete-check; recover refuses it" in str(exc) and read_guard(froot) is None,
                  str(exc))
        for n in range(250):
            delete_check(froot, SESSION, f"filler-{n}")
        check("a-clearance-never-expires", "job-rc" in _cleared_jobs(froot), str(len(_cleared_jobs(froot))))
        acquire(froot, SESSION, 0, RUN_FILE, "job-pc", generation=mint_generation())
        g_pc, r_pc = read_guard(froot)["generation"], read_guard(froot)["run_id"]
        end(froot, SESSION, "operator-stop", g_pc, "job-pc", r_pc)
        rc_pu = reconcile(froot, SESSION, "HTTP 502", RUN_FILE)
        check("an-unreadable-listing-names-no-pending-job-for-deletion",
              any("UNKNOWN" in r for r in rc_pu) and not any("CronDelete" in r for r in rc_pu)
              and any("pending cancellation(s) of job-pc wait for a readable listing" in r for r in rc_pu), str(rc_pu))
        # Panel round 3: an unreadable clearance ledger refuses guard changes
        # until quarantined, and startup rotates instead of adopting a
        # survivor of the guard's generation.
        _fresh_f()
        acquire(froot, SESSION, 0, RUN_FILE, "job-lg", generation=mint_generation())
        with open(_cleared_path(froot), "w", encoding="utf-8") as fh:
            fh.write("{broken ledger")
        try:
            acquire(froot, SESSION, 0, RUN_FILE, "job-lg2", generation=mint_generation())
            ledger_refused = False
        except GuardError as exc:
            ledger_refused = "clearance ledger" in str(exc) and "quarantine it" in str(exc)
        moved_l = quarantine(froot, SESSION)
        check("an-unreadable-clearance-ledger-refuses-until-quarantined",
              ledger_refused and any("claude-campaign-cleared.json" in m for m in moved_l)
              and acquire(froot, SESSION, 0, RUN_FILE, "job-lg2", generation=mint_generation()).startswith("acquire:"),
              str(moved_l))
        g_sv = mint_generation()
        acquire(froot, SESSION, 0, RUN_FILE, "job-lost", generation=g_sv)
        rid_sv = read_guard(froot)["run_id"]
        with open(frun, "a", encoding="utf-8") as fh:
            fh.write(f"\n- run guard: job job-survivor generation {g_sv}\n")
        rc_sv = reconcile(froot, SESSION, _cl(("job-survivor", heartbeat_tag(froot, g_sv, RUN_FILE))))
        check("startup-rotates-rather-than-adopting-a-survivor",
              any(f"job-survivor carries its generation: rotate it" in r and f"--expect-generation {g_sv} --expect-run {rid_sv}" in r
                  for r in rc_sv) and not any("re-point with acquire --cron-id job-survivor" in r for r in rc_sv), str(rc_sv))
        # Panel round 4: quarantine salvages the ledger's prohibitions, and a
        # same-generation twin rotates at startup instead of being deleted.
        _fresh_f()
        acquire(froot, SESSION, 0, RUN_FILE, "c0c0c0c0", generation=mint_generation())
        with open(_cleared_path(froot), "w", encoding="utf-8") as fh:
            fh.write('["a1b2c3d4", "deadbeef", ')
        salv = quarantine(froot, SESSION)
        try:
            acquire(froot, SESSION, 0, RUN_FILE, "deadbeef", generation=mint_generation())
            salvage_holds = False
        except GuardError as exc:
            salvage_holds = "was cleared for deletion" in str(exc)
        check("quarantine-salvages-the-clearance-ledger",
              salvage_holds and _cleared_jobs(froot) == ["a1b2c3d4", "deadbeef"]
              and any("rebuilt from the 2 job id(s)" in m for m in salv), str(salv))
        g_tw = mint_generation()
        acquire(froot, SESSION, 0, RUN_FILE, "job-tw1", generation=g_tw)
        rid_tw = read_guard(froot)["run_id"]
        with open(frun, "a", encoding="utf-8") as fh:
            fh.write(f"\n- run guard: job job-tw1 generation {g_tw}\n")
        rc_tw = reconcile(froot, SESSION, _cl(("job-tw1", heartbeat_tag(froot, g_tw, RUN_FILE)),
                                              ("job-tw2", heartbeat_tag(froot, g_tw, RUN_FILE))))
        check("startup-rotates-a-same-generation-twin",
              any(f"job-tw1, job-tw2 carry the guard's generation {g_tw}: rotate it" in r
                  and f"--expect-run {rid_tw}" in r for r in rc_tw)
              and not any("stale job job-tw2" in r for r in rc_tw), str(rc_tw))
        # Independent review (P1): a rotation re-points only the guard it was
        # named for; an ended run or a moved phase refuses.
        _fresh_f()
        g_rot = mint_generation()
        acquire(froot, SESSION, 0, RUN_FILE, "job-r1", generation=g_rot)
        rid_rot = read_guard(froot)["run_id"]
        ok_rot = acquire(froot, SESSION, 0, RUN_FILE, "job-r2", generation=mint_generation(),
                         expect_generation=g_rot, expect_run=rid_rot)
        refusals = []
        for label, setup in (("an obsolete generation", lambda: None),
                             ("a moved phase", lambda: acquire(froot, SESSION, 1, "docs/phase-runs/2099-06-06-phase-1.md",
                                                               "job-p", generation=mint_generation())),
                             ("an ended run", lambda: os.remove(_paths(froot)[0]))):
            setup()
            try:
                acquire(froot, SESSION, 0, RUN_FILE, "job-late", generation=mint_generation(),
                        expect_generation=g_rot, expect_run=rid_rot)
                refusals.append(f"{label}: accepted")
            except GuardError as exc:
                if "no longer the one this rotation was named for" not in str(exc):
                    refusals.append(f"{label}: {exc}")
        check("a-rotation-re-points-only-the-guard-it-was-named-for",
              ok_rot.startswith("acquire: guard re-pointed") and not refusals and read_guard(froot) is None, str(refusals))
        # Independent review (P2): migrating a legacy guard in place keeps its
        # state, trips and legacy error included.
        _fresh_f()
        _guard(froot)
        with open(_paths(froot)[1], "w", encoding="utf-8") as fh:
            json.dump({"fingerprint": "f", "blocks": 1, "trips": 2, "stalled": False,
                       "hook_error": "legacy boom", "hook_error_at": "2099-01-01T00:00:00Z"}, fh)
        whoami(froot, SESSION)
        tagged_m = _state(froot)
        run_hook(froot, SESSION)
        after_m = _state(froot)
        check("migrating-a-legacy-guard-keeps-its-state",
              tagged_m.get("run_id") == read_guard(froot)["run_id"] and tagged_m.get("trips") == 2
              and after_m.get("run_id") == read_guard(froot)["run_id"] and after_m.get("hook_error") == "legacy boom",
              f"{tagged_m} {after_m}")
        # Independent review (P2): two quarantines in one second keep both.
        _fresh_f()
        for _n in range(2):
            with open(_paths(froot)[1], "w", encoding="utf-8") as fh:
                fh.write("{broken state " + str(_n))
            quarantine(froot, SESSION)
        qfiles = sorted(os.listdir(os.path.join(froot, "build", _QUARANTINE)))
        qbodies = sorted(open(os.path.join(froot, "build", _QUARANTINE, n), encoding="utf-8").read() for n in qfiles)
        check("two-quarantines-keep-both-records",
              qbodies == ["{broken state 0", "{broken state 1"], str(qfiles))
        # Item 9: every place a credential can ride leaves the identity.
        for label, url in (("userinfo", "https://bot:s3cr3t@github.com/o/r.git"),
                           ("query", "https://github.com/o/r.git?access_token=s3cr3t"),
                           ("fragment", "https://github.com/o/r.git#s3cr3t")):
            check(f"credential-free-drops-the-{label}",
                  credential_free(url) == "https://github.com/o/r.git", credential_free(url))

    # D00 T04 §35, §37, §39, §41: the repair episode survives a restart,
    # refuses a fourth attempt, binds its identity and campaign, counts a
    # repeat once, journals before it writes state, replays its journal
    # strictly, closes only on a green GitHub re-read of the latest attempt,
    # retires only on a re-derived exclusion, asks the remote before it
    # abandons, and is restored only from the journal's open episode.
    with tempfile.TemporaryDirectory(prefix="campaign-repair-") as rtmp:
        os.makedirs(os.path.join(rtmp, "build"))
        os.makedirs(os.path.join(rtmp, "docs"))
        os.makedirs(os.path.join(rtmp, ".github", "workflows"))
        for args in (["init", "-q", "-b", "master"], ["config", "user.email", "t@t"], ["config", "user.name", "t"],
                     ["config", "commit.gpgsign", "false"],
                     ["remote", "add", "origin", "https://github.com/example/here.git"]):
            subprocess.run(["git", *args], cwd=rtmp, capture_output=True, check=True)
        with open(os.path.join(rtmp, ".gitignore"), "w", encoding="utf-8") as fh:
            fh.write("build/\n")
        wf_file = os.path.join(rtmp, ".github", "workflows", "plan.yml")
        with open(wf_file, "w", encoding="utf-8") as fh:
            fh.write("name: plan-gates\non: push\njobs: {}\n")
        shas = []
        for n in range(10):
            with open(os.path.join(rtmp, "f.txt"), "w", encoding="utf-8") as fh:
                fh.write(f"{n}\n")
            if n == 9:
                # The retirement commit: the workflow stops triggering on push.
                with open(wf_file, "w", encoding="utf-8") as fh:
                    fh.write("name: plan-gates\non: [workflow_dispatch]\njobs: {}\n")
            subprocess.run(["git", "add", "-A"], cwd=rtmp, capture_output=True, check=True)
            subprocess.run(["git", "commit", "-qm", f"c{n}"], cwd=rtmp, capture_output=True, check=True)
            shas.append(subprocess.run(["git", "rev-parse", "HEAD"], cwd=rtmp, capture_output=True,
                                       text=True).stdout.strip())
        # D00 T04 §41: local bare remotes stand in for the push target.
        for name in ("bare", "empty"):
            bare = os.path.join(rtmp, "build", f"{name}.git")
            subprocess.run(["git", "init", "-q", "--bare", bare], capture_output=True, check=True)
            subprocess.run(["git", "remote", "add", name, bare], cwd=rtmp, capture_output=True, check=True)
        subprocess.run(["git", "push", "-q", "bare", f"{shas[5]}:refs/heads/master"], cwd=rtmp,
                       capture_output=True, check=True)
        runf = "docs/run.md"
        with open(os.path.join(rtmp, runf), "w", encoding="utf-8") as fh:
            fh.write("# run\n")
        # A fake gh answers `run list` from a JSON file the legs write.
        gh_json = os.path.join(rtmp, "gh-run.json")
        fake_gh = os.path.join(rtmp, "fake_gh.py")
        with open(fake_gh, "w", encoding="utf-8") as fh:
            fh.write("import sys\nprint(open(sys.argv[0][:-len('fake_gh.py')] + 'gh-run.json').read())\n")
        EP = os.path.join(rtmp, "build", "claude-campaign-repair.json")
        GUARD_R = os.path.join(rtmp, "build", "claude-campaign-guard.json")

        def _campaign(run_id: str) -> None:
            with open(GUARD_R, "w", encoding="utf-8") as fh:
                json.dump({"session_id": SESSION, "run_file": "docs/run.md", "cron_id": "j", "generation": "g",
                           "run_id": run_id}, fh)
        _campaign("aaaaaaaaaaaa")

        def _repair_cli(*args: str, env: dict | None = None) -> subprocess.CompletedProcess:
            return subprocess.run([sys.executable, os.path.join(HERE, "campaign_guard.py"), "repair", *args,
                                   "--root", rtmp], capture_output=True, text=True, encoding="utf-8",
                                  env=dict(os.environ, GH=fake_gh, PYTHONIOENCODING="utf-8", **(env or {})))

        def _receipt_of(out: str) -> dict:
            got_r = [ln for ln in out.splitlines() if ln.startswith("repair-receipt: ")]
            return json.loads(got_r[-1][len("repair-receipt: "):]) if got_r else {}
        W = ("--workflow", "plan-gates", "--run-file", runf)
        R = ("--run-file", runf)
        RB = ("--remote", "bare")
        CRASH = {"CAMPAIGN_CRASH_AT": "repair:journal-written"}

        def _reserve_push(red: str, fix: str) -> subprocess.CompletedProcess:
            got = _repair_cli("attempt", "--red", red, "--commit", fix, *W)
            _repair_cli("pushed", "--commit", fix, *R)
            return got
        outs = [_reserve_push(shas[n - 1], shas[n]) for n in (1, 2, 3)]
        check("repair-attempts-count-across-processes",
              [o.returncode for o in outs] == [0, 0, 0] and "attempt 3 of 3 reserved" in outs[2].stdout
              and f"episode {shas[0][:12]}" in outs[2].stdout, str([o.stdout + o.stderr for o in outs]))
        journal = open(os.path.join(rtmp, runf), encoding="utf-8").read()
        check("repair-journals-each-transition-itself",
              f"repair: episode {shas[0][:12]} opened on red {shas[0][:12]}" in journal
              and journal.count(" reserved (") == 3 and journal.count(" pushed (") == 3, journal[-600:])
        # D00 T04 §41: every transition journals its receipt beside its
        # line, the printed receipt is the journalled one, and it round-trips.
        rc3 = _receipt_of(outs[2].stdout)
        check("repair-receipt-round-trips",
              journal.count("\nrepair-receipt: ") == 7 and rc3.get("v") == 1 and rc3.get("event") == "reserved"
              and rc3.get("attempt") == 3 and rc3.get("sha") == shas[3] and rc3.get("remaining") == 0
              and rc3.get("campaign") == "aaaaaaaaaaaa" and rc3.get("workflow") == "plan-gates"
              and ("repair-receipt: " + json.dumps(rc3, sort_keys=True, separators=(",", ":"))) in journal,
              f"{rc3} {journal[-400:]}")
        again = _repair_cli("attempt", "--red", shas[1], "--commit", shas[2], *W)
        check("repair-counts-a-repeated-attempt-once",
              again.returncode == 0 and "already counted" in again.stdout, again.stdout + again.stderr)
        st = _repair_cli("status", *R)
        check("repair-status-reads-the-persisted-episode",
              "3 of 3 attempts used" in st.stdout and _receipt_of(st.stdout).get("event") == "status"
              and _receipt_of(st.stdout).get("remaining") == 0, st.stdout)
        fourth = _repair_cli("attempt", "--red", shas[3], "--commit", shas[4], *W)
        check("repair-refuses-a-fourth-attempt-after-a-restart",
              fourth.returncode == 1 and "bound is exhausted, escalate" in fourth.stderr
              and _receipt_of(fourth.stderr).get("outcome") == "escalate", fourth.stderr)
        other = _repair_cli("attempt", "--red", shas[3], "--commit", shas[4], "--workflow", "release", *R)
        check("repair-refuses-a-mismatched-episode",
              other.returncode == 1 and "belongs to workflow 'plan-gates'" in other.stderr, other.stderr)
        with open(EP, encoding="utf-8") as fh:
            saved = fh.read()
        for label, body in (("corrupt", "{not json"), ("malformed", '{"episode": 3}'), ("null", "null")):
            with open(EP, "w", encoding="utf-8") as fh:
                fh.write(body)
            bad = _repair_cli("attempt", "--red", shas[3], "--commit", shas[5], *W)
            check(f"repair-refuses-{label}-state-rather-than-resetting",
                  bad.returncode == 1 and "escalate rather than repair" in bad.stderr, bad.stderr)
        with open(EP, "w", encoding="utf-8") as fh:
            fh.write(saved)
        # Close proves green on GitHub's own record (D00 T04 §39), bound to
        # the latest attempt and the workflow's id (D00 T04 §41).
        good = {"databaseId": 555, "headSha": shas[5], "headBranch": "master", "conclusion": "success",
                "status": "completed", "url": "https://github.com/example/here/actions/runs/555", "attempt": 1,
                "workflowName": "plan-gates", "workflowDatabaseId": 42}
        ev = (f"ci-wait: {shas[5][:12]} plan-gates success https://github.com/example/here/actions/runs/555 "
              f"attempt=1 workflow-id=42")
        no_ev = _repair_cli("close", "--green", shas[5], *W, "--evidence", f"ci-wait: {shas[5][:12]} plan-gates started no run")
        check("repair-close-refuses-without-green-evidence",
              no_ev.returncode == 1 and "needs --evidence with the green ci-wait line" in no_ev.stderr, no_ev.stderr)
        unbound = _repair_cli("close", "--green", shas[5], *W, "--evidence",
                              f"ci-wait: {shas[5][:12]} plan-gates success https://github.com/example/here/actions/runs/555")
        check("repair-close-refuses-a-line-without-its-attempt",
              unbound.returncode == 1 and "names its run attempt and workflow id" in unbound.stderr, unbound.stderr)
        not_desc = _repair_cli("close", "--green", shas[1], *W, "--evidence",
                               f"ci-wait: {shas[1][:12]} plan-gates success x attempt=1 workflow-id=42")
        check("repair-close-refuses-a-green-that-is-not-a-descendant",
              not_desc.returncode == 1 and "does not descend from the last attempt" in not_desc.stderr, not_desc.stderr)
        for label, patch, evid in (("head sha", {"headSha": shas[6]}, ev),
                                   ("conclusion", {"conclusion": "failure"}, ev),
                                   ("branch", {"headBranch": "release/9"}, ev),
                                   ("repository", {"url": "https://github.com/other/fork/actions/runs/555"}, ev),
                                   ("run id", {}, ev.replace("/runs/555", "/runs/554")),
                                   ("attempt", {"attempt": 2}, ev),
                                   ("workflow id", {"workflowDatabaseId": 43}, ev)):
            with open(gh_json, "w", encoding="utf-8") as fh:
                json.dump([dict(good, **patch)], fh)
            got_c = _repair_cli("close", "--green", shas[5], *W, "--evidence", evid)
            check(f"repair-close-refuses-when-github-disagrees-on-{label.replace(' ', '-')}",
                  got_c.returncode == 1 and f"disagrees on {label}" in got_c.stderr and os.path.exists(EP),
                  got_c.stderr)
        with open(gh_json, "w", encoding="utf-8") as fh:
            json.dump([good], fh)
        closed = _repair_cli("close", "--green", shas[5], *W, "--evidence", ev)
        check("repair-close-proves-green-on-githubs-record",
              closed.returncode == 0 and "closed green at" in closed.stdout
              and "(run 555 attempt 1 workflow-id 42)" in closed.stdout
              and _receipt_of(closed.stdout).get("workflow_id") == 42 and not os.path.exists(EP),
              closed.stdout + closed.stderr)
        resurrect = _repair_cli("restore", *W)
        check("repair-restore-never-resurrects-a-closed-episode",
              resurrect.returncode == 0 and "no open episode" in resurrect.stdout, resurrect.stdout + resurrect.stderr)
        # A reservation counts until it is marked; an abandoned one frees
        # its place, and close waits for no reservation (D00 T04 §39).
        a1 = _repair_cli("attempt", "--red", shas[5], "--commit", shas[6], *W)
        blocked_close = _repair_cli("close", "--green", shas[6], *W, "--evidence",
                                    f"ci-wait: {shas[6][:12]} plan-gates success "
                                    f"https://github.com/example/here/actions/runs/556 attempt=1 workflow-id=42")
        ab = _repair_cli("abandon", "--commit", shas[6], "--reason", "the push was rejected", *R, *RB)
        # A retried push of the abandoned commit counts again (independent
        # review), then is abandoned once more for the legs below.
        again_ab = _repair_cli("attempt", "--red", shas[5], "--commit", shas[6], *W)
        st_again = _repair_cli("status", *R)
        check("repair-an-abandoned-commit-reserved-again-counts-again",
              "reserved again after it was abandoned" in again_ab.stdout and "1 of 3 attempts used" in st_again.stdout
              and "reserved, push unconfirmed" in st_again.stdout, again_ab.stdout + st_again.stdout)
        _repair_cli("abandon", "--commit", shas[6], "--reason", "the push was rejected again", *R, *RB)
        st2 = _repair_cli("status", *R)
        check("repair-an-abandoned-attempt-frees-its-place",
              a1.returncode == 0 and blocked_close.returncode == 1 and "still reserved" in blocked_close.stderr
              and "abandoned" in ab.stdout and "0 of 3 attempts used" in st2.stdout, st2.stdout + ab.stderr)
        # Write-ahead: a crash after the journal line, before the state,
        # loses nothing; the next call adopts the journal.
        crash = _repair_cli("attempt", "--red", shas[5], "--commit", shas[7], *W, env=CRASH)
        st3 = _repair_cli("status", *R)
        check("repair-a-crash-after-the-journal-recovers-the-attempt",
              crash.returncode == 97 and "1 of 3 attempts used" in st3.stdout and "recovered from the journal" in st3.stdout
              and "reserved, push unconfirmed" in st3.stdout, st3.stdout + st3.stderr)
        # D00 T04 §41: abandon asks the remote first. An unreadable remote
        # leaves the attempt reserved; a commit that landed is marked pushed.
        dark = _repair_cli("abandon", "--commit", shas[7], "--reason", "timed out", *R, "--remote", "nowhere")
        subprocess.run(["git", "push", "-q", "bare", f"{shas[7]}:refs/heads/master"], cwd=rtmp,
                       capture_output=True, check=True)
        landed = _repair_cli("abandon", "--commit", shas[7], "--reason", "the client timed out", *R, *RB)
        st_landed = _repair_cli("status", *R)
        check("repair-abandon-marks-a-delivered-push-pushed",
              dark.returncode == 1 and "could not read the remote" in dark.stderr
              and landed.returncode == 0 and "pushed (" in landed.stdout
              and "reached the remote before its client failed" in landed.stdout
              and _receipt_of(landed.stdout).get("event") == "pushed"
              and "1 of 3 attempts used" in st_landed.stdout and "reserved" not in st_landed.stdout,
              dark.stderr + landed.stdout + landed.stderr + st_landed.stdout)
        # Panel round 4 of the D00 T04 §39 review: a journal line naming the
        # episode under another identity is never reconciled into it.
        ep_now = json.load(open(EP, encoding="utf-8"))["episode"][:12]
        with open(os.path.join(rtmp, runf), encoding="utf-8") as fh:
            before_foreign = fh.read()
        with open(os.path.join(rtmp, runf), "a", encoding="utf-8") as fh:
            fh.write(f"repair: episode {ep_now} attempt 3 of 3 reserved ({shas[8][:12]} repairs {shas[5][:12]}) "
                     f"repo=https://github.com/other/fork.git branch=master workflow=plan-gates run=aaaaaaaaaaaa\n")
        mixed_j = _repair_cli("status", *R)
        with open(os.path.join(rtmp, runf), "w", encoding="utf-8") as fh:
            fh.write(before_foreign)
        check("repair-never-reconciles-a-foreign-journal-line",
              mixed_j.returncode == 1 and "escalate rather than reconcile" in mixed_j.stderr, mixed_j.stdout + mixed_j.stderr)
        # Another run file, or a journal silent about the episode, never
        # resets the bound (independent review, P1).
        other_rf = _repair_cli("status", "--run-file", "docs/other.md")
        with open(os.path.join(rtmp, runf), encoding="utf-8") as fh:
            kept_journal = fh.read()
        with open(os.path.join(rtmp, runf), "w", encoding="utf-8") as fh:
            fh.write("# run, its journal lost\n")
        silent = _repair_cli("status", *R)
        with open(os.path.join(rtmp, runf), "w", encoding="utf-8") as fh:
            fh.write(kept_journal)
        check("repair-never-drops-an-episode-without-its-terminal-line",
              other_rf.returncode == 1 and "belongs to run file 'docs/run.md'" in other_rf.stderr
              and silent.returncode == 1 and "records no open or ended episode" in silent.stderr and os.path.exists(EP),
              other_rf.stderr + silent.stderr)
        # A lost episode file is detected from the journal and restored.
        os.remove(EP)
        lost = _repair_cli("status", *R)
        check("repair-status-detects-a-lost-episode-file",
              lost.returncode == 1 and "the episode file is lost" in lost.stderr, lost.stdout + lost.stderr)
        blocked = _repair_cli("attempt", "--red", shas[7], "--commit", shas[8], *W)
        check("repair-attempt-refuses-until-restored",
              blocked.returncode == 1 and "run repair restore first" in blocked.stderr, blocked.stderr)
        no_wf = _repair_cli("restore", *R)
        check("repair-restore-refuses-without-a-workflow",
              no_wf.returncode == 1 and "needs --workflow and --run-file" in no_wf.stderr, no_wf.stderr)
        restored = _repair_cli("restore", *W)
        check("repair-restore-rebuilds-from-the-run-file",
              restored.returncode == 0 and "restored from docs/run.md at 1 of 3 attempts" in restored.stdout,
              restored.stdout + restored.stderr)
        full_retry = _repair_cli("attempt", "--red", shas[5], "--commit", shas[7], *W)
        check("repair-restored-attempts-compare-by-full-sha",
              full_retry.returncode == 0 and "already counted" in full_retry.stdout,
              full_retry.stdout + full_retry.stderr)
        check("repair-attempt-lines-carry-the-identity",
              " repo=https://github.com/example/here.git branch=master workflow=plan-gates run=aaaaaaaaaaaa"
              in full_retry.stdout, full_retry.stdout)
        # An authorized retirement ends the episode without green, only on
        # evidence bound to the episode's head (independent review), and
        # only when the committed workflow at that head excludes the push
        # (D00 T04 §41).
        def _nogreen(silent_sha: str, base_sha: str, head_sha: str, branch: str = "master") -> str:
            return (f"ci-wait: {silent_sha[:12]} plan-gates NOT GREEN: no run within 900s, as authorized by operator "
                    f"at 2026-09-26T03:00Z for {base_sha[:12]}..{head_sha[:12]} branch={branch} "
                    f"workflow-path=.github/workflows/plan.yml (retired; the workflow no longer triggers on push)")
        unrelated = _repair_cli("retire", *W, "--evidence", _nogreen(shas[2], shas[1], shas[2]))
        off_range = _repair_cli("retire", *W, "--evidence", _nogreen(shas[8], shas[1], shas[2]))
        off_branch = _repair_cli("retire", *W, "--evidence", _nogreen(shas[9], shas[7], shas[9], "release/9"))
        check("repair-retire-binds-the-episodes-head",
              unrelated.returncode == 1 and "does not descend from the last attempt" in unrelated.stderr
              and off_range.returncode == 1 and "approved range must end at the silent push" in off_range.stderr
              and off_branch.returncode == 1 and "names branch release/9" in off_branch.stderr
              and os.path.exists(EP), unrelated.stderr + off_range.stderr + off_branch.stderr)
        fabricated = _repair_cli("retire", *W, "--evidence", _nogreen(shas[8], shas[7], shas[8]))
        made_up = _repair_cli("retire", *W, "--evidence", _nogreen(shas[9], shas[7], shas[9]).replace(
            "workflow-path=.github/workflows/plan.yml", "workflow-path=.github/workflows/nowhere.yml"))
        check("repair-retire-re-derives-the-exclusion",
              fabricated.returncode == 1 and "does not exclude this push" in fabricated.stderr
              and made_up.returncode == 1 and "is not the episode's workflow plan-gates" in made_up.stderr
              and os.path.exists(EP), fabricated.stderr + made_up.stderr)
        wrong = _repair_cli("retire", *W, "--evidence", ev)
        retired = _repair_cli("retire", *W, "--evidence", _nogreen(shas[9], shas[7], shas[9]))
        check("repair-retire-ends-an-episode-only-on-an-authorized-no-run",
              wrong.returncode == 1 and "authorized NOT GREEN line" in wrong.stderr
              and retired.returncode == 0 and ": plan-gates no longer runs this push (authorized by operator at "
              "2026-09-26T03:00Z" in retired.stdout and "re-derived: the workflow no longer triggers on push" in retired.stdout
              and _receipt_of(retired.stdout).get("authorized_by") == "operator"
              and not os.path.exists(EP), wrong.stderr + retired.stdout + retired.stderr)
        # The episode binds the campaign's run id (D00 T04 §39).
        bound = _repair_cli("attempt", "--red", shas[6], "--commit", shas[7], *W)
        _campaign("bbbbbbbbbbbb")
        foreign = _repair_cli("attempt", "--red", shas[6], "--commit", shas[8], *W)
        # Panel round 3: restore with the foreign episode file present
        # refuses too, before any early return.
        foreign_present = _repair_cli("restore", *W)
        check("repair-restore-refuses-a-present-foreign-episode",
              foreign_present.returncode == 1 and "belongs to campaign run aaaaaaaaaaaa" in foreign_present.stderr,
              foreign_present.stdout + foreign_present.stderr)
        os.remove(EP)
        foreign_restore = _repair_cli("restore", *W)
        check("repair-binds-the-episode-to-its-campaign",
              bound.returncode == 0 and " run=aaaaaaaaaaaa" in bound.stdout
              and foreign.returncode == 1 and "belongs to campaign run aaaaaaaaaaaa, not bbbbbbbbbbbb" in foreign.stderr
              and foreign_restore.returncode == 1 and "a journal from another campaign" in foreign_restore.stderr,
              bound.stdout + foreign.stderr + foreign_restore.stderr)
        # Panel round 2: no campaign, or an unreadable guard, refuses.
        os.remove(GUARD_R)
        no_campaign = _repair_cli("attempt", "--red", shas[6], "--commit", shas[8], *W)
        with open(GUARD_R, "w", encoding="utf-8") as fh:
            fh.write("{broken")
        broken_guard = _repair_cli("attempt", "--red", shas[6], "--commit", shas[8], *W)
        check("repair-refuses-without-an-established-campaign",
              no_campaign.returncode == 1 and "needs a live campaign guard with a run id" in no_campaign.stderr
              and broken_guard.returncode == 1 and "the guard is unreadable" in broken_guard.stderr,
              no_campaign.stderr + broken_guard.stderr)
        _campaign("aaaaaaaaaaaa")
        # An episode file from before D00 T04 §39 with a legacy journal:
        # strict replay refuses it rather than closing past its repairs.
        legacy_rf = "docs/legacy.md"
        ident_l = " repo=https://github.com/example/here.git branch=master workflow=plan-gates"
        with open(os.path.join(rtmp, legacy_rf), "w", encoding="utf-8") as fh:
            fh.write(f"repair: episode {shas[3][:12]} attempt 1 of 3 ({shas[4][:12]} repairs {shas[3][:12]}){ident_l}\n")
        with open(EP, "w", encoding="utf-8") as fh:
            json.dump({"episode": shas[3], "attempts": [{"red": shas[3], "commit": shas[4]}],
                       "repo": "https://github.com/example/here.git", "branch": "master", "workflow": "plan-gates",
                       "run_file": legacy_rf}, fh)
        leg_close = _repair_cli("close", "--green", shas[3], "--workflow", "plan-gates", "--run-file", legacy_rf,
                                "--evidence", f"ci-wait: {shas[3][:12]} plan-gates success "
                                              f"https://github.com/example/here/actions/runs/1 attempt=1 workflow-id=42")
        check("repair-a-legacy-episode-refuses-rather-than-closing",
              leg_close.returncode == 1 and "a legacy journal" in leg_close.stderr and os.path.exists(EP),
              leg_close.stderr)
        os.remove(EP)
        # D00 T04 §38: the journal carries the episode's identity, and a
        # restore refuses any caller or journal that would rebind it.
        here_branch = _repo_identity(rtmp)["branch"]
        subprocess.run(["git", "remote", "set-url", "origin", "https://example.invalid/here.git"], cwd=rtmp,
                       capture_output=True, check=True)

        def _jline(ident: tuple | None, body: str, ep: str | None = None) -> str:
            tail = "" if ident is None else (f" repo={ident[0]} branch={ident[1]} workflow={ident[2]} "
                                             f"run={ident[3] if len(ident) > 3 else 'aaaaaaaaaaaa'}")
            return f"repair: episode {(ep or shas[3])[:12]} {body}{tail}\n"

        def _jfile(name: str, *idents: tuple | None, text: str | None = None) -> str:
            rel = f"docs/{name}.md"
            with open(os.path.join(rtmp, rel), "w", encoding="utf-8") as fh:
                if text is not None:
                    fh.write(text)
                else:
                    if idents and idents[0] is not None:
                        fh.write(_jline(idents[0], f"opened on red {shas[3][:12]}"))
                    for n, ident in enumerate(idents):
                        fh.write(_jline(ident, f"attempt {n + 1} of 3 pushed ({shas[4 + n][:12]} repairs "
                                               f"{shas[3 + n][:12]})".replace(" pushed ", " reserved ")))
                        fh.write(_jline(ident, f"attempt {n + 1} of 3 pushed ({shas[4 + n][:12]})"))
            return rel
        here = ("https://example.invalid/here.git", here_branch, "plan-gates")
        for label, rel, wf, want in (
                ("cross-repository", _jfile("j-repo", ("https://example.invalid/other.git", here_branch,
                                                       "plan-gates")), "plan-gates", "belongs to repository"),
                ("cross-branch", _jfile("j-branch", ("https://example.invalid/here.git", "release/9",
                                                     "plan-gates")), "plan-gates", "belongs to branch 'release/9'"),
                ("cross-workflow", _jfile("j-wf", here), "release", "belongs to workflow 'plan-gates'"),
                ("mixed", _jfile("j-mixed", here, ("https://example.invalid/here.git", "release/9", "plan-gates")),
                 "plan-gates", "not its opening line's"),
                ("legacy", _jfile("j-legacy", None), "plan-gates", "a legacy journal")):
            res = _repair_cli("restore", "--workflow", wf, "--run-file", rel)
            check(f"repair-restore-refuses-a-{label}-journal",
                  res.returncode == 1 and want in res.stderr and not os.path.exists(EP), res.stdout + res.stderr)
        # D00 T04 §41: strict replay. Each history the state machine does not
        # allow refuses, and each refusal leaves no episode behind.
        op = _jline(here, f"opened on red {shas[3][:12]}")
        r1 = _jline(here, f"attempt 1 of 3 reserved ({shas[4][:12]} repairs {shas[3][:12]})")
        p1 = _jline(here, f"attempt 1 of 3 pushed ({shas[4][:12]})")
        a1l = _jline(here, f"attempt 1 of 3 abandoned ({shas[4][:12]})").rstrip("\n") + ": rejected\n"
        cl = _jline(here, f"closed green at {shas[5][:12]} (run 9 attempt 1 workflow-id 42) after 1 attempt(s)")
        for label, text, want in (
                ("a final line without its newline", op + r1.rstrip("\n"), "without its newline"),
                ("a truncated line", op + r1[:-12] + "\n" + p1, "not a complete journal line"),
                ("a duplicate push", op + r1 + p1 + p1, "is not reserved (a duplicate"),
                ("a duplicate reservation", op + r1 + r1, "(a duplicate reservation)"),
                ("an attempt with no episode", r1, "no open episode"),
                ("a renumbered attempt", op + r1.replace("attempt 1 of 3", "attempt 2 of 3"), "replay places it at 1"),
                ("a reopened closed episode", op + r1 + p1 + cl + op, "it never reopens"),
                ("a close over a reservation", op + r1 + cl, "still reserved"),
                ("a malformed receipt", op + 'repair-receipt: {"v":1,"event":"reserved"\n', "not a well-formed"),
                ("a receipt that disagrees", op + r1 + "repair-receipt: " + json.dumps(
                    {"v": 1, "event": "reserved", "episode": shas[3], "attempt": 2, "sha": shas[4],
                     "repository": here[0], "branch": here[1], "workflow": here[2], "campaign": "aaaaaaaaaaaa"}) + "\n",
                 "and its receipt disagree")):
            res = _repair_cli("restore", "--workflow", "plan-gates", "--run-file", _jfile("j-strict", text=text))
            check(f"repair-strict-replay-refuses: {label}",
                  res.returncode == 1 and want in res.stderr and not os.path.exists(EP), res.stdout + res.stderr)
        rere = _repair_cli("restore", "--workflow", "plan-gates", "--run-file",
                           _jfile("j-rereserve", text=op + r1 + a1l + r1))
        st_rere = _repair_cli("status", "--run-file", "docs/j-rereserve.md")
        check("repair-strict-replay-takes-a-re-reservation-as-latest",
              rere.returncode == 0 and "at 1 of 3 attempts" in rere.stdout
              and f"reserved, push unconfirmed: {shas[4][:12]}" in st_rere.stdout, rere.stdout + rere.stderr + st_rere.stdout)
        os.remove(EP)
        # A quoted copy is a record, never a journal line: it neither
        # restores an episode nor double-counts one.
        quoted = _repair_cli("restore", "--workflow", "plan-gates", "--run-file",
                             _jfile("j-tick", text=f"- attempt 1: `{r1.strip()}`\n"))
        both = _repair_cli("restore", "--workflow", "plan-gates", "--run-file",
                           _jfile("j-tick2", text=op + r1 + p1 + f"- attempt 1: `{p1.strip()}`\n"))
        check("repair-strict-replay-ignores-a-quoted-copy",
              quoted.returncode == 0 and "no open episode; nothing to restore" in quoted.stdout
              and both.returncode == 0 and "at 1 of 3 attempts" in both.stdout,
              quoted.stdout + quoted.stderr + both.stdout + both.stderr)
        os.remove(EP)
        # The receipt is read in preference to the prose: its full sha
        # restores a commit the prose names only by prefix.
        ghost = "ab" * 20
        rc_only = op + "repair-receipt: " + json.dumps(
            {"v": 1, "event": "opened", "episode": shas[3], "red": shas[3], "repository": here[0], "branch": here[1],
             "workflow": here[2], "campaign": "aaaaaaaaaaaa"}) + "\n" + "repair-receipt: " + json.dumps(
            {"v": 1, "event": "reserved", "episode": shas[3], "attempt": 1, "sha": ghost, "red": shas[3],
             "repository": here[0], "branch": here[1], "workflow": here[2], "campaign": "aaaaaaaaaaaa"}) + "\n"
        pref = _repair_cli("restore", "--workflow", "plan-gates", "--run-file", _jfile("j-receipt", text=rc_only))
        restored_ep = json.load(open(EP, encoding="utf-8")) if os.path.exists(EP) else {}
        check("repair-restore-reads-the-receipt-before-the-prose",
              pref.returncode == 0 and [a.get("commit") for a in restored_ep.get("attempts", [])] == [ghost]
              and restored_ep.get("episode") == shas[3], pref.stdout + pref.stderr + str(restored_ep))
        os.remove(EP)
        ok = _repair_cli("restore", "--workflow", "plan-gates", "--run-file", _jfile("j-ok", here, here))
        check("repair-restore-recovers-a-matching-journal",
              ok.returncode == 0 and "at 2 of 3 attempts" in ok.stdout, ok.stdout + ok.stderr)
        # Independent review: credentials in the remote URL never reach an
        # attempt line, and the credential-free form still matches.
        subprocess.run(["git", "remote", "set-url", "origin", "https://ci-bot:s3cr3t-t0ken@example.invalid/here.git"],
                       cwd=rtmp, capture_output=True, check=True)
        cred = _repair_cli("attempt", "--red", shas[4], "--commit", shas[5], "--workflow", "plan-gates",
                           "--run-file", "docs/j-ok.md")
        check("repair-attempt-lines-carry-no-credentials",
              cred.returncode == 0 and "s3cr3t" not in cred.stdout + cred.stderr
              and " repo=https://example.invalid/here.git " in cred.stdout, cred.stdout + cred.stderr)
        os.remove(EP)
        # The ceiling allowance: one per repository, run, and attempt,
        # journalled with its campaign, its cache rebuilt when lost and
        # refused when corrupt or ahead of its journal.
        subprocess.run(["git", "remote", "set-url", "origin", "https://github.com/example/here.git"], cwd=rtmp,
                       capture_output=True, check=True)
        c1 = _repair_cli("ceiling", "--run-id", "777", *R)
        c2 = _repair_cli("ceiling", "--run-id", "777", *R)
        c3 = _repair_cli("ceiling", "--run-id", "777", "--attempt", "2", *R)
        check("repair-ceiling-allows-one-re-run-per-run-attempt",
              c1.returncode == 0 and "example/here#777@1" in c1.stdout and c2.returncode == 1
              and "already had its one re-run" in c2.stderr and c3.returncode == 0 and "#777@2" in c3.stdout
              and "repair: ceiling allowance used for example/here#777@1 run=aaaaaaaaaaaa\n"
              in open(os.path.join(rtmp, runf), encoding="utf-8").read(),
              c1.stdout + c2.stderr + c3.stdout + c3.stderr)
        os.remove(os.path.join(rtmp, "build", "claude-campaign-ceiling.json"))
        c4 = _repair_cli("ceiling", "--run-id", "777", *R)
        check("repair-ceiling-rebuilds-a-lost-record-from-the-journal",
              c4.returncode == 1 and "restored 2 lost allowance record(s) from the journal" in c4.stderr, c4.stderr)
        with open(os.path.join(rtmp, runf), encoding="utf-8") as fh:
            with_ceiling = fh.read()
        with open(os.path.join(rtmp, runf), "w", encoding="utf-8") as fh:
            fh.write("".join(ln for ln in with_ceiling.splitlines(True) if "#777@1" not in ln))
        c_trunc = _repair_cli("ceiling", "--run-id", "777", *R)
        with open(os.path.join(rtmp, runf), "w", encoding="utf-8") as fh:
            fh.write(with_ceiling)
        check("repair-ceiling-refuses-a-truncated-journal",
              c_trunc.returncode == 1 and "a changed or truncated journal" in c_trunc.stderr, c_trunc.stderr)
        # Panel round 1: ceiling lines replay strictly.
        for label, extra, want in (
                ("a duplicate use", "repair: ceiling allowance used for example/here#777@1 run=aaaaaaaaaaaa\n",
                 "twice (a duplicate line)"),
                ("another campaign's use", "repair: ceiling allowance used for example/here#780@1 run=cccccccccccc\n",
                 "a journal from another campaign"),
                ("a receipt that disagrees", "repair: ceiling allowance used for example/here#781@1 run=aaaaaaaaaaaa\n"
                 'repair-receipt: {"v":1,"event":"ceiling","campaign":"aaaaaaaaaaaa","key":"example/here#782@1"}\n',
                 "its receipt disagree")):
            with open(os.path.join(rtmp, runf), "a", encoding="utf-8") as fh:
                fh.write(extra)
            c_bad = _repair_cli("ceiling", "--run-id", "799", *R)
            with open(os.path.join(rtmp, runf), "w", encoding="utf-8") as fh:
                fh.write(with_ceiling)
            check(f"repair-ceiling-replays-strictly: {label}", c_bad.returncode == 1 and want in c_bad.stderr,
                  c_bad.stderr)
        _campaign("")
        c_nocamp = _repair_cli("ceiling", "--run-id", "779", *R)
        _campaign("aaaaaaaaaaaa")
        check("repair-ceiling-needs-its-campaign",
              c_nocamp.returncode == 1 and "journalled with its campaign" in c_nocamp.stderr, c_nocamp.stderr)
        with open(os.path.join(rtmp, "build", "claude-campaign-ceiling.json"), "w", encoding="utf-8") as fh:
            fh.write("{broken")
        c5 = _repair_cli("ceiling", "--run-id", "778", *R)
        check("repair-ceiling-escalates-a-corrupt-record",
              c5.returncode == 1 and "ceiling record is unreadable; escalate" in c5.stderr, c5.stderr)
        os.remove(os.path.join(rtmp, "build", "claude-campaign-ceiling.json"))
        # D00 T04 §41: every transition's interruption. A crash between the
        # journal and the state loses no budget and resurrects nothing.
        CR = ("--run-file", "docs/crash.md")
        CW = ("--workflow", "plan-gates", *CR)
        with open(os.path.join(rtmp, "docs", "crash.md"), "w", encoding="utf-8") as fh:
            fh.write("# crash drills\n")
        _repair_cli("attempt", "--red", shas[1], "--commit", shas[2], *CW)
        k_push = _repair_cli("pushed", "--commit", shas[2], *CR, env=CRASH)
        s_push = _repair_cli("status", *CR)
        _repair_cli("attempt", "--red", shas[2], "--commit", shas[3], *CW)
        k_ab = _repair_cli("abandon", "--commit", shas[3], "--reason", "rejected", *CR, "--remote", "empty", env=CRASH)
        s_ab = _repair_cli("status", *CR)
        check("repair-interruption: pushed and abandoned",
              k_push.returncode == 97 and "1 of 3 attempts used" in s_push.stdout
              and "recovered from the journal" in s_push.stdout and "reserved" not in s_push.stdout
              and k_ab.returncode == 97 and "1 of 3 attempts used" in s_ab.stdout
              and "recovered from the journal" in s_ab.stdout and "reserved" not in s_ab.stdout,
              s_push.stdout + s_ab.stdout + k_ab.stderr)
        with open(gh_json, "w", encoding="utf-8") as fh:
            json.dump([dict(good, headSha=shas[4])], fh)
        k_close = _repair_cli("close", "--green", shas[4], *CW, "--evidence",
                              ev.replace(shas[5][:12], shas[4][:12]), env=CRASH)
        kept_ep = os.path.exists(EP)
        s_close = _repair_cli("status", *CR)
        r_close = _repair_cli("restore", *CW)
        check("repair-interruption: closed",
              k_close.returncode == 97 and kept_ep and "no open episode" in s_close.stdout
              and "stale episode file the journal had closed was dropped" in s_close.stdout
              and not os.path.exists(EP) and "nothing to restore" in r_close.stdout,
              k_close.stderr + s_close.stdout + s_close.stderr + r_close.stdout)
        _repair_cli("attempt", "--red", shas[5], "--commit", shas[6], *CW)
        _repair_cli("pushed", "--commit", shas[6], *CR)
        k_ret = _repair_cli("retire", *CW, "--evidence", _nogreen(shas[9], shas[6], shas[9]), env=CRASH)
        s_ret = _repair_cli("status", *CR)
        check("repair-interruption: retired",
              k_ret.returncode == 97 and "stale episode file the journal had closed was dropped" in s_ret.stdout
              and not os.path.exists(EP), k_ret.stderr + s_ret.stdout + s_ret.stderr)
        k_ceil = _repair_cli("ceiling", "--run-id", "999", *CR, env=CRASH)
        again_ceil = _repair_cli("ceiling", "--run-id", "999", *CR)
        check("repair-interruption: a ceiling use",
              k_ceil.returncode == 97 and again_ceil.returncode == 1
              and "restored 1 lost allowance record(s) from the journal" in again_ceil.stderr,
              k_ceil.stderr + again_ceil.stderr)
        # The journal is append-only: once committed, a lost or changed line
        # refuses every command rather than renewing the budget.
        subprocess.run(["git", "add", "-f", "docs/crash.md"], cwd=rtmp, capture_output=True, check=True)
        subprocess.run(["git", "commit", "-qm", "journal"], cwd=rtmp, capture_output=True, check=True)
        with open(os.path.join(rtmp, "docs", "crash.md"), encoding="utf-8") as fh:
            crash_text = fh.read()
        with open(os.path.join(rtmp, "docs", "crash.md"), "w", encoding="utf-8") as fh:
            fh.write("".join(crash_text.splitlines(True)[:-2]))
        cut_ceil = _repair_cli("ceiling", "--run-id", "1000", *CR)
        cut_status = _repair_cli("status", *CR)
        with open(os.path.join(rtmp, "docs", "crash.md"), "w", encoding="utf-8") as fh:
            fh.write(crash_text + "- a later note\n")
        grown = _repair_cli("status", *CR)
        check("repair-refuses-a-journal-cut-below-its-commit",
              cut_ceil.returncode == 1 and "lost or changed journal lines committed at HEAD" in cut_ceil.stderr
              and cut_status.returncode == 1 and "committed at HEAD" in cut_status.stderr
              and _receipt_of(cut_status.stderr).get("outcome") == "refused"
              and "committed at HEAD" in _receipt_of(cut_status.stderr).get("reason", "")
              and grown.returncode == 0, cut_ceil.stderr + cut_status.stderr + grown.stdout + grown.stderr)

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
                         "--reason plan-done --generation G --cron-id <job id> --run <run id>`. Only after `end` succeeds for plan-done"),
                        # D00 T04 §38: the heartbeat drains its own pending
                        # cancellations first, then asks who it is with the
                        # CronList text, and fences every later mutation.
                        ("skill-heartbeat-drains-its-own-cancellations-first",
                         "1. Run `python scripts/campaign_guard.py pending-cancel --session S`"),
                        ("skill-heartbeat-owner-first",
                         "2. Run CronList, then `python scripts/campaign_guard.py whoami --session S --generation G "
                         "--cronlist -`"),
                        ("skill-heartbeat-stalls-only-its-own-run",
                         "carries `run_id` equal to the run id step 2 printed and trips of 2 or more"),
                        ("skill-heartbeat-deletes-only-after-end-succeeds",
                         "Only after `end` succeeds (a refusal follows the rule above: step 2 runs again"),
                        ("skill-heartbeat-finishes-an-incomplete-end",
                         "Never resume under step 6 while such a line prints"),
                        ("skill-heartbeat-one-refusal-rule",
                         "a refusal means the guard moved since step 2 read it, so run nothing else this firing has "
                         "planned, append the refusal as a `- bookkeeping:` line, and start again at step 2"),
                        ("skill-heartbeat-plan-done-only-after-end-succeeds",
                         "Only after `end` succeeds for plan-done (a refusal follows the rule above), CronDelete this job"),
                        ("skill-heartbeat-no-live-carrier-runs-no-fenced-step",
                         "If it prints NO LIVE CARRIER or UNKNOWN LISTING, or otherwise withholds the job, run no fenced step this firing"),
                        ("skill-heartbeat-reports-are-bookkeeping",
                         "Critical events as a `- bookkeeping: ` line (it repeats on every firing"),
                        ("skill-heartbeat-rotates-a-duplicate-generation",
                         "rotate the generation as that line says (a new job from this prompt with a fresh generation"),
                        ("skill-phase-advance-creates-before-it-deletes",
                         "then `delete-check` and `CronDelete` the old job (in that order: the old job stays the guard's"),
                        ("skill-rotation-is-a-compare-and-swap",
                         "re-pointed to it with `--expect-generation` and `--expect-run` (a compare-and-swap"),
                        ("skill-every-crondelete-follows-delete-check",
                         "every CronDelete of any job follows `python scripts/campaign_guard.py delete-check --session S"),
                        ("skill-states-the-fsync-default",
                         "Files are not fsynced and directory changes carry no ordering barrier, so after a power loss any "
                         "subset of the last changes may survive"),
                        ("skill-startup-rotates-never-adopts",
                         "rotate the generation when only a surviving job carries the guard's generation (never adopt it"),
                        ("skill-quarantine-then-recover",
                         "`python scripts/campaign_guard.py recover --session $CLAUDE_CODE_SESSION_ID --run-file <run file>`"),
                        ("skill-startup-drains-orphan-errors", "--startup yes --ack <id>`"),
                        ("skill-heartbeat-acks-by-id-fenced",
                         "hook-error --session S --generation G --cron-id <job id> --run <run id> --ack <the id inside"),
                        ("skill-heartbeat-prompt-leads-with-its-identity",
                         "Claude run-guard heartbeat <generation> <workspace digest>: the campaign"),
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
    dig = workspace_digest(REPO, "docs/phase-runs/2026-12-31-phase-10.md")
    shown = (first.group(1).replace("<generation>", "0" * 12).replace("<workspace digest>", dig) if first else "")
    check("skill-prompt-identity-survives-the-cronlist-cut",
          classify_job(REPO, _cl(("j", shown)).split(": ", 1)[1]) == ("0" * 12, dig), shown[:100])
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
                                ropts.get("evidence", ""), ropts.get("run_id", ""), ropts.get("reason", ""),
                                ropts.get("attempt", ""), ropts.get("remote", ""))
            print(line, file=sys.stdout if code == 0 else sys.stderr)
            return code
        opts = _opts(argv[1:])
        root = opts.pop("root", REPO)
        if argv[0] == "acquire":
            print(acquire(root, opts.get("session", ""), int(opts.get("phase", "0")),
                          opts.get("run_file", ""), opts.get("cron_id", ""), opts.get("handover"),
                          opts.get("generation"), opts.get("expect_generation"), opts.get("expect_run")))
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
            need("session", "reason", "generation", "cron_id", "run")
            print(end(root, opts["session"], opts["reason"], opts["generation"], opts["cron_id"], opts["run"]))
            return 0
        if argv[0] == "hook-error" and set(opts) <= {"session", "ack", "generation", "cron_id", "run", "startup"}:
            if "ack" in opts:
                need("session", *(() if opts.get("startup") == "yes" else ("generation", "cron_id", "run")))
            line = hook_error(root, opts.get("session"), opts.get("ack"), opts.get("generation"), opts.get("cron_id"),
                              opts.get("run"), opts.get("startup") == "yes")
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
                need("session", "generation", "cron_id", "run")
            print(reset_state(root, opts.get("session"), opts.get("expect_no_guard") == "yes",
                              opts.get("generation"), opts.get("cron_id"), opts.get("run")))
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
        if argv[0] == "delete-check":
            need("session", "cron_id")
            code, line = delete_check(root, opts["session"], opts["cron_id"])
            print(line, file=sys.stdout if code == 0 else sys.stderr)
            return code
        if argv[0] == "quarantine":
            need("session")
            print("\n".join(quarantine(root, opts["session"])))
            return 0
        if argv[0] == "recover":
            need("session", "run_file")
            print(recover(root, opts["session"], opts["run_file"]))
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
    except (GuardError, ValueError, OSError) as exc:
        print(f"campaign_guard: {exc}", file=sys.stderr)
        return 1
    print(f"campaign_guard: unknown command {' '.join(argv)!r}; see the module docstring", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
