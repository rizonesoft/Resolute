#!/usr/bin/env python3
"""Run the repository's single independent reviewer through its committed policy.

New cycles require --writer-model and --record: medium plan, medium adversarial,
up to max_low_rounds low passes (default 8), stopping clean, then medium completion.
Historical cycles retain their initiating committed policy and sealed findings.
--check-pin and --list-rounds are read-only inspections. Exit 1 means no review;
exit 2 means refusal; exit 0 means a returned review, not necessarily approval.
"""
import argparse
from contextlib import contextmanager
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys
import tempfile
import threading
import time
import tomllib

ROOT = Path(__file__).resolve().parents[1]
PIN = ROOT / ".conclave" / "reviewers.toml"
# One marker per running review. The unattended run (scripts/lib/run_guard.py) reads this folder and waits for a
# review instead of working beside it. LOCK_AT is past any marker's content, so the lock never blocks reading it.
IN_FLIGHT = ROOT / "build" / "review-in-flight"
LOCK_AT = 1 << 30
WRITERS = ("claude", "codex", "gemini", "muse", "meta")
CLIS = ("codex", "agy", "claude")
# Operator rule 2026-11-06: Claude writes and never reviews. Past pins naming it stay readable so their receipts replay,
# but the live pin may not name it and no review ever launches it.
NEVER_REVIEWS = frozenset({"claude"})
# A reviewer is never of the writer's own model family: its CLI names the family, and so does the writer.
FAMILY = {"codex": "openai", "agy": "google", "claude": "anthropic"}
WRITER_FAMILY = {"claude": "anthropic", "codex": "openai", "gemini": "google", "muse": "meta", "meta": "meta"}
# Antigravity carries effort in its model name; models_by_effort selects the scheduled variant.
# Operator constraint: reviewers never go past medium effort.
EFFORTS = {"codex": ("low", "medium"), "claude": ("low", "medium")}
MODEL = re.compile(r"^[a-z0-9][a-z0-9.-]*$")
NAME = re.compile(r"^[a-z0-9][a-z0-9-]*$")
# Antigravity takes the prompt only as the -p value. Past this size it gets a pointer to the prompt file instead.
# Windows caps a whole command line at 32,767 characters; Linux caps one argument at 128 KiB.
ARGV_PROMPT_LIMIT = 24_000 if os.name == "nt" else 100_000
# A review is prose. Output past this size is a runaway reviewer, not a review.
MAX_OUTPUT_BYTES = 2_000_000
# The prompt's reply format ends with an OVERALL line; `blocked` means the reviewer never saw the work.
BLOCKED = re.compile(r"^\s*(?:OVERALL|COMPLETION):\s*blocked\b", re.IGNORECASE)
POLL_SECONDS = 0.2
CLEANUP_SECONDS = 10


class Refused(Exception):
    """The pin or the arguments are wrong; nothing ran."""


@contextmanager
def in_flight(record, kind, folder=None):
    """Holds a marker for exactly as long as a reviewer runs. This process keeps a lock on it, which the operating
    system drops when the process ends however it ends, so a marker left by a killed dispatcher is told from a live
    one by trying the lock (run_guard.reviews_in_flight), with no process id to be reused."""
    folder = IN_FLIGHT if folder is None else folder
    folder.mkdir(parents=True, exist_ok=True)
    marker = folder / f"{os.getpid()}.json"
    with marker.open("w+b") as handle:
        handle.seek(LOCK_AT)
        if os.name == "nt":
            import msvcrt
            msvcrt.locking(handle.fileno(), msvcrt.LK_NBLCK, 1)
        else:
            import fcntl
            fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
        handle.seek(0)
        handle.write(json.dumps({"pid": os.getpid(), "record": record, "kind": kind,
                                 "at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")}).encode("utf-8"))
        handle.flush()
        try:
            yield
        finally:
            handle.close()  # the lock goes with the handle, and Windows removes no file that is still open
            marker.unlink(missing_ok=True)


def load_pin(path=PIN, data=None):
    """The checked pin at `path`, or, given `data`, the pin in those bytes (a committed pin read with `git show`), so
    a read-only caller needs no temporary file."""
    live = data is None
    try:
        if data is None:
            with open(path, "rb") as handle:
                data = handle.read()
        pin = tomllib.loads(data.decode("utf-8"))
    except FileNotFoundError:
        raise Refused(f"no reviewer pin at {path}") from None
    except tomllib.TOMLDecodeError as exc:
        raise Refused(f"unreadable reviewer pin: {exc}") from None
    # A directory, a file it may not read, bytes that are not UTF-8, an integer past Python's digit limit, or nesting
    # deep enough to exhaust the parser's recursion: each is a pin that cannot be read, so it is a refusal (exit 2,
    # one JSON object), never a traceback. ValueError comes after its subclasses TOMLDecodeError and UnicodeDecodeError.
    except OSError as exc:
        raise Refused(f"unreadable reviewer pin: {exc.strerror or exc}: {path}") from None
    except UnicodeDecodeError:
        raise Refused("unreadable reviewer pin: not UTF-8 text") from None
    except ValueError as exc:
        raise Refused(f"unreadable reviewer pin: {exc}") from None
    except RecursionError:
        raise Refused("unreadable reviewer pin: nested too deeply to read") from None
    # `type(...) is int`: TOML true is Python True (an int subclass) and 1.0 == 1, so `!= 1` alone let both load.
    # The optional [schedule] is checked below; the refusal text stays the one the VS Code extension matches.
    if not {"schema_version", "reviewers", "routes"} <= set(pin) <= {"schema_version", "reviewers", "routes",
                                                                     "schedule"} \
            or type(pin["schema_version"]) is not int or pin["schema_version"] != 1:
        raise Refused("the reviewer pin needs exactly schema_version = 1, [reviewers.*] and [routes]")
    reviewers = pin["reviewers"]
    if not isinstance(reviewers, dict) or not reviewers:
        raise Refused("the reviewer pin defines no reviewers")
    for name, entry in reviewers.items():
        # fullmatch: `$` alone also matches before a trailing newline, which would then break the round heading.
        if not NAME.fullmatch(name) or not isinstance(entry, dict):
            raise Refused(f"invalid reviewer {name!r}")
        unknown = set(entry) - {"cli", "model", "effort", "models_by_effort"}
        if unknown:
            raise Refused(f"reviewer {name!r} has unknown keys: {', '.join(sorted(unknown))}")
        cli, model, effort = entry.get("cli"), entry.get("model"), entry.get("effort")
        if cli not in CLIS:
            raise Refused(f"reviewer {name!r} needs cli = one of {', '.join(CLIS)}")
        if not isinstance(model, str) or not MODEL.fullmatch(model):
            raise Refused(f"reviewer {name!r} has a malformed model")
        if cli == "agy":
            if effort is not None:
                raise Refused(f"reviewer {name!r}: Antigravity carries the effort in the model name, so set no effort")
            variants = entry.get("models_by_effort")
            if variants is not None and (not isinstance(variants, dict) or set(variants) != {"low", "medium"}
                    or any(not isinstance(v, str) or not MODEL.fullmatch(v) for v in variants.values())):
                raise Refused("Antigravity models_by_effort needs exact low and medium model IDs")
        elif effort not in EFFORTS[cli]:
            raise Refused(f"reviewer {name!r} needs effort = one of {', '.join(EFFORTS[cli])}")
        elif "models_by_effort" in entry:
            raise Refused("models_by_effort is only supported for Antigravity")
    if live:
        for name, entry in reviewers.items():
            if entry["cli"] in NEVER_REVIEWS:
                raise Refused(f"reviewer {name!r} uses the {entry['cli']} CLI; Claude is never a reviewer")
    routes = pin["routes"]
    if not isinstance(routes, dict) or set(routes) - set(WRITERS):
        raise Refused(f"[routes] may only name the writers {', '.join(WRITERS)}")
    for writer, chain in routes.items():
        if not isinstance(chain, list) or len(chain) != 1 or not isinstance(chain[0], str):
            raise Refused(f"route {writer!r} must list exactly one reviewer")
        if chain[0] not in reviewers:
            raise Refused(f"route {writer!r} must list a defined reviewer")
        if FAMILY[reviewers[chain[0]]["cli"]] == WRITER_FAMILY[writer]:
            raise Refused(f"route {writer!r} names {chain[0]}, of the writer's own family; "
                          f"a review comes from a different family")
    if "schedule" in pin:
        check_schedule(pin["schedule"], {reviewers[chain[0]]["cli"] for chain in routes.values()})
        if pin["schedule"].get("completion_order") == "last":
            for chain in routes.values():
                entry = reviewers[chain[0]]
                if entry["cli"] == "agy" and "models_by_effort" not in entry:
                    raise Refused("current-policy Antigravity requires low and medium model variants")
    return pin


# The lenses a schedule may name, each with the question the reviewer is given for it. `plan` and `plan-delivery`
# read the section's plan: before the build (is it a complete feature?) and after it (did the build deliver it?).
LENSES = {
    "plan": "Will this section, built exactly as written, produce a 100% complete feature? Name every missing "
            "control, state, setting consumer, error or refusal path, undo or reverse path, Ctrl+K reach, persistence "
            "read-back and test, and every `Done when:` that cannot fail.",
    "plan-delivery": "Did the build deliver every checklist item and `Done when:` of the section, with nothing "
                     "partial, stubbed or quietly narrowed?",
    "adversarial": "How does this fail on hostile input, races, aborts, cancellation, automation or links?",
    "integration": "Do callers and consumers still hold, with every contract (threads, ownership, errors) kept?",
    "source-defect": "Is the upstream specification or design/SPEC.md read accurately, with deviations noted?",
    "consistency": "Does it match the module rules, naming, shared components, settings and sibling code?",
    "quality": "Is the code clear, minimal and maintainable: dead code, duplication, misleading names or comments, "
               "tests that pass without exercising the behaviour?",
    "design": "Does the rendered UI match design/SPEC.md and its tokens: roles, radii, icons, states, accessibility?",
    "optimization": "Where does it waste time, memory, allocations, I/O or redraws on the paths users hit, and what "
                    "measured target does it miss?",
    "record": "Does the evidence match what ran, with owned deferrals and an earned flip of every item?",
}
STEP_KEYS = {"effort", "lenses"}


def check_step(where, step, efforts, lenses=True):
    if not isinstance(step, dict) or set(step) - STEP_KEYS or "effort" not in step \
            or (lenses and "lenses" not in step) or (not lenses and "lenses" in step):
        need = "effort and lenses" if lenses else "only effort"
        raise Refused(f"[schedule] {where} needs {need}")
    if step["effort"] not in efforts:
        raise Refused(f"[schedule] {where} needs effort = one of {', '.join(efforts)}")
    if lenses:
        names = step["lenses"]
        if not isinstance(names, list) or not names or not all(isinstance(n, str) and n in LENSES for n in names) \
                or len(set(names)) != len(names):
            raise Refused(f"[schedule] {where} needs lenses = a list of distinct lenses from "
                          f"{', '.join(LENSES)}")


def check_schedule(schedule, clis):
    """The review schedule, as strictly as the reviewers: every effort valid for every routed CLI that takes one (an
    Antigravity reviewer keeps the effort its model name carries), every lens known."""
    efforts = [e for e in EFFORTS["claude"] if all(e in EFFORTS[cli] for cli in clis if cli in EFFORTS)]
    keys = {"plan", "completion", "rounds", "rotation", "escalation", "severity_stop_after"}
    if not isinstance(schedule, dict) or not keys <= set(schedule) <= keys | {"completion_order", "max_low_rounds"}:
        raise Refused(f"[schedule] needs exactly {', '.join(sorted(keys))}")
    if "completion_order" in schedule or "max_low_rounds" in schedule:
        if schedule.get("completion_order") != "last":
            raise Refused("completion_order must be last")
        cap = schedule.get("max_low_rounds", 8)
        if type(cap) is not int or not 0 <= cap <= 32:
            raise Refused("max_low_rounds must be an integer from 0 to 32")
        if (schedule["plan"] != {"effort": "medium", "lenses": ["plan"]}
                or schedule["completion"] != {"effort": "medium"}
                or schedule["rounds"] != [{"effort": "medium", "lenses": ["adversarial"]}]
                or not isinstance(schedule["rotation"], dict) or schedule["rotation"].get("effort") != "low"
                or schedule["escalation"] != {"effort": "low", "lenses": ["adversarial"]}
                or schedule["severity_stop_after"] != 0):
            raise Refused("completion-last requires medium plan/adversarial/completion and low follow-ups")
    check_step("plan", schedule["plan"], efforts)
    check_step("completion", schedule["completion"], efforts, lenses=False)
    check_step("escalation", schedule["escalation"], efforts)
    check_step("rotation", schedule["rotation"], efforts)
    rounds = schedule["rounds"]
    if not isinstance(rounds, list) or not rounds:
        raise Refused("[schedule] rounds needs at least one round")
    for n, step in enumerate(rounds, 1):
        check_step(f"round {n}", step, efforts)
    stop = schedule["severity_stop_after"]
    if type(stop) is not int or not 0 <= stop <= 33:
        raise Refused("[schedule] severity_stop_after needs a whole number of rounds from 0 to 33")


HIGHEST = re.compile(r"^\s*HIGHEST:\s*(P[123])\b", re.IGNORECASE | re.MULTILINE)


def highest(review):
    """The `HIGHEST:` severity a review declares (`P1`, `P2`, `P3`), or None."""
    found = HIGHEST.findall(review or "")
    return found[-1].upper() if found else None


def clean(review):
    """An explicit severity verdict; contradictory declarations never earn a stop."""
    declarations = re.findall(r"^\s*HIGHEST:\s*(P[123]|none)\s*$", review or "", re.M | re.I)
    return len(declarations) == 1 and declarations[0].lower() in ("p3", "none")


def schedule_cap(schedule):
    return 1 + schedule.get("max_low_rounds", 8) if schedule.get("completion_order") == "last" else 33


def check_sequence(schedule, kind, found, writer, writer_model):
    if schedule.get("completion_order") != "last":
        return
    if not isinstance(writer_model, str) or not MODEL.fullmatch(writer_model):
        raise Refused("current policy requires --writer-model with the exact model version")
    entries = [*found["plans"], *found["rounds"], *found["completions"]]
    if any(e.get("writer") != writer or e.get("writer_model") != writer_model for e in entries):
        raise Refused("preserve the existing writer and exact writer model")
    plans = [e for e in found["plans"] if returned_pass("plan", e)]
    rounds = [e for e in found["rounds"] if returned_review(e)]
    completions = [e for e in found["completions"] if returned_pass("completion", e)]
    if kind == "plan" and (plans or found["rounds"] or found["completions"]):
        raise Refused("the plan pass is already consumed; preserve review lineage")
    if kind != "plan" and len(plans) != 1:
        raise Refused("exactly one returned plan review is required before rounds")
    if completions:
        raise Refused("completion already returned; preserve its findings and require a new reviewed repair cycle")
    if kind == "round":
        if found["completions"]:
            raise Refused("completion is last; retry its failed execution without reopening rounds")
        if rounds and clean(rounds[-1]["review"]):
            raise Refused("rounds are clean; completion is next")
        if len(rounds) >= schedule_cap(schedule):
            raise Refused("review budget exhausted with unresolved findings; operator recovery required")
    if kind == "completion" and (not rounds or not clean(rounds[-1]["review"])
            or not returned_review(found["rounds"][-1])):
        raise Refused("completion requires a clean terminal round; exhaustion is not approval")


def record_policy(pin, found, root=ROOT):
    """Bind a cycle to a committed pin, using the original plan candidate for old records."""
    if found is None:
        raise Refused("malformed findings cannot establish review lineage")
    entries = [*found["plans"], *found["rounds"], *found["completions"]]
    if not entries:
        return pin, None
    policies = {e.get("policy") for e in entries if e.get("policy")}
    if len(policies) > 1:
        raise Refused("review record mixes policy commits")
    legacy = not policies
    if legacy:
        plans = found["plans"]
        if not plans or not plans[0].get("candidate"):
            raise Refused("existing lineage has no verifiable initiating plan candidate")
        sha = plans[0]["candidate"]
    else:
        sha = policies.pop()
    if not CANDIDATE.fullmatch(sha):
        raise Refused("invalid review policy commit")
    result = subprocess.run(["git", "-C", str(root), "show", f"{sha}:.conclave/reviewers.toml"],
                            capture_output=True, timeout=30)
    if result.returncode:
        raise Refused("cannot read the initiating committed reviewer policy")
    original = load_pin(data=result.stdout)
    if legacy and original.get("schedule", {}).get("completion_order") == "last":
        raise Refused("current-policy lineage lacks its policy metadata")
    for e in entries:
        route = original["routes"].get(e.get("writer"), [])
        reviewer = e.get("reviewer") or e.get("attempt_reviewer")
        if reviewer and route != [reviewer]:
            raise Refused("record reviewer does not match its initiating policy")
    return original, sha


def validate_current_record(pin, found):
    """Replay admission in file order, including failed executions, without spending a review."""
    if pin.get("schedule", {}).get("completion_order") != "last":
        return
    prior = {"plans": [], "rounds": [], "completions": []}
    events = [(e.get("_line", -1), kind, e) for kind, key in
              (("plan", "plans"), ("round", "rounds"), ("completion", "completions")) for e in found[key]]
    for _, kind, e in sorted(events, key=lambda x: x[0]):
        check_sequence(pin["schedule"], kind, prior, e["writer"], e.get("writer_model"))
        route = pin["routes"].get(e["writer"])
        if not route or e.get("attempt_reviewer") != route[0] or not e.get("policy"):
            raise Refused("current review lacks its pinned attempt identity")
        reviewer = pin["reviewers"][route[0]]
        step = scheduled(pin["schedule"], kind, prior["rounds"], "design" in (e.get("lenses") or []))
        model = reviewer.get("models_by_effort", {}).get(step["effort"], reviewer["model"])
        if e.get("attempt_model") != model or e.get("attempt_cli") != reviewer["cli"]:
            raise Refused("attempt model or CLI differs from the pinned policy")
        if e.get("execution") not in ("returned", "timeout", "missing", "empty", "failed", "invalid"):
            raise Refused("review execution outcome is missing or invalid")
        if e.get("reviewer") and (e["reviewer"] != route[0] or e.get("model") != model
                or e.get("cli") != reviewer["cli"] or e["execution"] != "returned"):
            raise Refused("returned review differs from its recorded execution")
        prior["plans" if kind == "plan" else "completions" if kind == "completion" else "rounds"].append(e)


def returned_review(entry):
    """A recorded round that is a review: a reviewer of another model family than the writer ran and replied with the
    prompt's final `OVERALL: approve` or `OVERALL: needs-attention` line. An outage, a self-review (a reviewer of the
    writer's own family, or of no known family) and a reply without that line are recorded rounds, not reviews.
    scripts/lib/todo_graph.py `stamp` uses this same predicate, so the schedule and the receipt count the same rounds."""
    lines = [x.strip() for x in (entry.get("review") or "").splitlines() if x.strip()]
    return bool(entry.get("reviewer")) and entry.get("writer") in WRITER_FAMILY \
        and FAMILY.get(entry.get("cli")) not in (None, WRITER_FAMILY[entry["writer"]]) \
        and bool(lines) and lines[-1] in ("OVERALL: approve", "OVERALL: needs-attention")


def scheduled(schedule, kind, rounds, surface):
    """The effort and lenses for the next pass, from the pin's schedule and the rounds already recorded.

    The position counts returned reviews only (`returned_review`): an outage, a self-review and a reply without the
    final OVERALL line do not move it. Rounds past the fixed list rotate through `rotation`'s lenses, one per round,
    skipping `design` when the section has no surface. After a low-effort round that declared `HIGHEST: P1`, the next
    round is the `escalation` step instead. scripts/lib/todo_graph.py `stamp` replays this to check every recorded
    pass, so it is the one copy of the schedule rule."""
    if kind in ("plan", "completion"):
        step = schedule[kind]
        return {"position": None, "effort": step["effort"], "lenses": list(step.get("lenses", [])),
                "escalated": False}
    returned = [r for r in rounds if returned_review(r)]
    position = len(returned) + 1
    last = returned[-1] if returned else None
    if last is not None and last.get("effort") == "low" and highest(last.get("review")) == "P1":
        step, escalated = schedule["escalation"], True
    elif position <= len(schedule["rounds"]):
        step, escalated = schedule["rounds"][position - 1], False
    else:
        rotation = [n for n in schedule["rotation"]["lenses"] if surface or n != "design"] \
            or schedule["rotation"]["lenses"]
        step = {"effort": schedule["rotation"]["effort"],
                "lenses": [rotation[(position - len(schedule["rounds"]) - 1) % len(rotation)]]}
        escalated = False
    return {"position": position, "effort": step["effort"], "lenses": list(step["lenses"]), "escalated": escalated}


def lens_block(plan):
    """The prompt section naming this pass's scheduled lenses and effort, appended after the writer's prompt."""
    where = f"Round {plan['position']}" if plan["position"] else "This pass"
    lines = ["", "", "## Lenses for this pass (scheduled by scripts/review-dispatch.py)", "",
             f"{where} runs at {plan['effort']} reasoning effort"
             + (", escalated after a low-effort round found a P1" if plan["escalated"] else "")
             + ". Review through these lenses only, each as its own verdict, and ignore any other lens list above:",
             ""]
    lines += [f"- `{name}`: {LENSES[name]}" for name in plan["lenses"]]
    return "\n".join(lines) + "\n"


EXTENSION = re.compile(r"\.[A-Za-z0-9]+")


def find_cli(name):
    """A reviewer CLI's path, from the absolute directories on PATH only, or None.

    Reviews run from the reviewed repository's root, and Windows `shutil.which` looks in the working directory first
    (always on Python 3.11, and on later ones unless NoDefaultCurrentDirectoryInExePath is set), so a `codex.cmd`
    committed to that repository would be reported as installed and run as the reviewer. Relative PATH entries are
    dropped for the same reason. On Windows the search is done here, by PATHEXT, so no Python version adds the directory.
    """
    directories = [d for d in os.environ.get("PATH", "").split(os.pathsep) if fully_qualified(d)]
    if os.name != "nt":
        return shutil.which(name, path=os.pathsep.join(directories))
    # An empty PATHEXT gets the defaults too, as shutil.which does. The bare name is the last candidate in each
    # directory: npm puts an extensionless shell script beside codex.cmd, and Windows can run only the .cmd.
    # Only entries shaped like an extension: one that holds a separator or ".." would lead out of the PATH directory.
    extensions = [e for e in os.environ.get("PATHEXT", "").split(os.pathsep) if EXTENSION.fullmatch(e)] \
        or [".COM", ".EXE", ".BAT", ".CMD"]
    for directory in directories:
        for candidate in [os.path.join(directory, name + e) for e in extensions] + [os.path.join(directory, name)]:
            if os.path.isfile(candidate):
                return candidate
    return None


def fully_qualified(directory):
    """True for a PATH entry that names one place whatever the working directory: on Windows a drive and a root
    (`C:\\x`) or a UNC share, never `\\x` (the current drive's) or `C:x` (that drive's current directory), which
    os.path.isabs accepts on Python 3.11 and 3.12."""
    if os.name != "nt":
        return os.path.isabs(directory)
    drive, rest = os.path.splitdrive(directory)
    return drive.startswith(("\\\\", "//")) or (len(drive) == 2 and rest[:1] in ("\\", "/"))


def command(reviewer, executable, prompt, prompt_path, output_path, timeout, effort=None):
    """The argv and stdin for one read-only review. The model comes only from the pin, and the effort from the pin's
    reviewer or, when the pin has a [schedule], from the step it schedules for this pass (Antigravity takes none)."""
    cli, model, effort = reviewer["cli"], reviewer["model"], effort or reviewer.get("effort")
    if cli == "codex":
        return [executable, "exec", "-m", model, "-c", f"model_reasoning_effort={effort}", "--sandbox", "read-only",
                "--ephemeral", "--skip-git-repo-check", "-o", str(output_path), "-"], prompt
    text = prompt
    # A Windows .cmd or .bat shim re-parses its arguments through cmd.exe, so prose there could become commands:
    # it only ever gets a pointer to the prompt file. So does a prompt too long for a command line.
    shim = Path(executable).suffix.lower() in (".cmd", ".bat")
    if shim or len(prompt.encode()) > ARGV_PROMPT_LIMIT or len(prompt) > ARGV_PROMPT_LIMIT:
        text = f"Follow the review instructions in the file {prompt_path} exactly. Do not modify any file."
    return [executable, "--model", model, "--mode", "plan", "--sandbox", "--print-timeout", f"{timeout}s",
            f"-p={text}"], None


def kill_tree(process):
    """End a reviewer and everything it started, whether it is still running or has already exited."""
    if os.name == "nt":
        # WORKAROUND: Windows offers no process-group kill without job objects, so taskkill /T reaches the reviewer's
        # children only while the reviewer itself is alive. A child that outlives a reviewer which exited by itself
        # is not reached on Windows; on Linux and WSL the whole session is killed below.
        subprocess.run(["taskkill", "/T", "/F", "/PID", str(process.pid)], capture_output=True)
    else:
        try:
            os.killpg(process.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass  # nothing in the group is left to kill


def remove_scratch(path):
    """Remove a reviewer's scratch directory. On Windows a file stays locked until every process holding it has
    exited, and a reviewer's helper can outlive the reviewer (see kill_tree) and keep writing into it, so a failed
    removal is retried for a bounded time. A directory that still cannot be removed is left behind with a note: the
    round's outcome is already decided."""
    deadline = time.monotonic() + CLEANUP_SECONDS
    while True:
        try:
            shutil.rmtree(path)
            return
        except FileNotFoundError:
            return
        except OSError as exc:
            if time.monotonic() > deadline:
                print(f"review-dispatch: left {path} behind ({exc.strerror or type(exc).__name__})", file=sys.stderr)
                return
            time.sleep(POLL_SECONDS)


def feed(pipe, text):
    try:
        pipe.write(text.encode("utf-8"))
        pipe.close()
    except (BrokenPipeError, OSError):
        pass  # the reviewer stopped reading or exited; its exit code and output decide the round


def run(argv, stdin_text, timeout, watched):
    """Run one reviewer in its own process group, watching the size of every file it writes while it runs, so neither
    a hang nor a flood of output can take the dispatcher or the disk down. The group is ended afterwards whatever
    happened. Returns (exit code, None) or (None, the reason it returned no review)."""
    group = {"creationflags": subprocess.CREATE_NEW_PROCESS_GROUP} if os.name == "nt" else {"start_new_session": True}
    stdout_path = watched[0]
    with open(stdout_path, "wb") as output:
        try:
            process = subprocess.Popen(argv, cwd=ROOT,
                                       stdin=subprocess.PIPE if stdin_text is not None else subprocess.DEVNULL,
                                       stdout=output, stderr=subprocess.DEVNULL, **group)
        except (OSError, ValueError) as exc:
            return None, f"could not start: {getattr(exc, 'strerror', None) or type(exc).__name__}"
        try:
            if stdin_text is not None:
                # Fed from a thread: a reviewer that never reads would otherwise block this write past any timeout.
                threading.Thread(target=feed, args=(process.stdin, stdin_text), daemon=True).start()
            deadline = time.monotonic() + timeout
            while process.poll() is None:
                if any(path.is_file() and path.stat().st_size > MAX_OUTPUT_BYTES for path in watched):
                    return None, f"returned more than {MAX_OUTPUT_BYTES} bytes"
                if time.monotonic() > deadline:
                    return None, "timed out"
                time.sleep(POLL_SECONDS)
        finally:
            kill_tree(process)
            process.wait()
    if process.returncode != 0:
        return None, f"exited {process.returncode}"
    if any(path.is_file() and path.stat().st_size > MAX_OUTPUT_BYTES for path in watched):
        return None, f"returned more than {MAX_OUTPUT_BYTES} bytes"
    return process.returncode, None


def review(pin, writer, prompt_path, timeout, plan=None):
    """Run the writer's one reviewer. Returns the summary dict: `reviewer` is None when no review came back, and
    `failover` then names the reviewer and why (there is no fallback). `plan` is the scheduled step (see `scheduled`):
    its effort replaces the reviewer's, and its lenses are appended to the prompt and recorded."""
    if writer not in pin["routes"]:
        raise Refused(f"the reviewer pin has no route for writer {writer!r}")
    prompt = Path(prompt_path).read_text(encoding="utf-8")
    if not prompt.strip():
        raise Refused("the review prompt is empty")
    if "\0" in prompt:
        raise Refused("the review prompt contains a NUL byte; no reviewer can be given it")
    (name,) = pin["routes"][writer]
    reviewer = pin["reviewers"][name]
    # A replayed lineage hands back its original pin, which load_pin lets through, so this gate covers it too.
    if reviewer["cli"] in NEVER_REVIEWS:
        raise Refused(f"reviewer {name!r} uses the {reviewer['cli']} CLI; Claude is never a reviewer")
    effort = plan["effort"] if plan else reviewer.get("effort")
    if reviewer["cli"] == "agy":
        variants = reviewer.get("models_by_effort")
        if variants and effort:
            if effort not in variants:
                raise Refused(f"no pinned Argon model for effort {effort}")
            reviewer = {**reviewer, "model": variants[effort]}
        else:
            effort = None
    lenses = plan["lenses"] if plan else []
    if lenses:
        prompt = prompt.rstrip("\n") + lens_block(plan)
    scheduled_fields = {"effort": effort, "lenses": lenses} if plan else {}

    def none(reason):
        return {"writer": writer, "reviewer": None, "failover": [{"reviewer": name, "reason": reason}], "review": None,
                "attempt_reviewer": name, "attempt_model": reviewer["model"], "attempt_cli": reviewer["cli"],
                "execution": ("timeout" if "timed out" in reason else "missing" if "not installed" in reason
                              else "empty" if "returned no review" in reason else "failed"),
                **scheduled_fields}

    # The resolved path, not the bare name: on Windows a CLI is often a .cmd shim that Popen cannot find by name.
    executable = find_cli(reviewer["cli"])
    if executable is None:
        return none(f"{reviewer['cli']} is not installed")
    text = None
    tmp = Path(tempfile.mkdtemp())
    try:
        stdout_path, message_path = tmp / "stdout.txt", tmp / "last-message.md"
        prompt_file = Path(prompt_path).resolve()
        if lenses:
            # The pointer an Antigravity shim gets must name the prompt with its scheduled lenses.
            prompt_file = tmp / "prompt.md"
            prompt_file.write_text(prompt, encoding="utf-8", newline="\n")
        argv, stdin_text = command(reviewer, executable, prompt, prompt_file, message_path, timeout, effort)
        _, problem = run(argv, stdin_text, timeout, [stdout_path, message_path])
        if problem is None:
            # Codex writes its final message to the -o file; stdout carries its progress, not the review.
            source = message_path if reviewer["cli"] == "codex" else stdout_path
            text = source.read_text(encoding="utf-8", errors="replace") if source.is_file() else ""
    finally:
        remove_scratch(tmp)
    if problem is None and not (text or "").strip():
        problem = "returned no review"
    if problem is None:
        problem = blocked(text)
    if problem:
        return none(problem)
    return {"writer": writer, "reviewer": name, "cli": reviewer["cli"], "model": reviewer["model"],
            "execution": "returned", "attempt_reviewer": name, "attempt_model": reviewer["model"],
            "attempt_cli": reviewer["cli"],
            "effort": effort, "failover": [], "review": text.strip(), **({"lenses": lenses} if plan else {})}


def blocked(text):
    """Why a reply is not a review, when its last line is `OVERALL: blocked` (or `COMPLETION: blocked`); None for a
    review."""
    lines = [line for line in text.strip().splitlines() if line.strip()]
    if not lines or not BLOCKED.match(lines[-1]):
        return None
    reason = next((line.strip() for line in lines[:-1] if not line.lstrip().startswith("#")), "no reason given")
    return f"could not review: {reason[:300]}"


def atomic_write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(dir=path.parent)
    try:
        # newline="": the text is written as given, so a review's own "\r" bytes are stored and nothing is translated.
        with os.fdopen(fd, "w", encoding="utf-8", newline="") as handle:
            handle.write(text)
        os.chmod(temporary, 0o644)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


# A findings file is read back by `list_rounds`, so the envelope `record` writes around each review is unambiguous:
# the metadata states how many lines the review has (`- Lines: N`, lines split on "\n" only) and a digest of them
# (`- Digest:`, the first 16 hex digits of the SHA-256 of the canonical lines joined with "\n"). The reader skips
# exactly N lines and checks the digest, so neither a quoted heading nor an edit of the same length passes for a round.
# The review is stored byte for byte; a line's trailing "\r" is dropped only to compare, so a CRLF checkout reads the
# same. Rounds recorded before the count have no Lines field and run to the next round heading; rounds recorded
# before the digest have Lines without Digest and are read by their count alone.
# Numbers are ASCII digits of bounded length, so the reader's int() can never raise (`\d` also takes "²", and a number
# past Python's digit limit raises). A review is at most MAX_OUTPUT_BYTES, so it has at most MAX_OUTPUT_BYTES + 1 lines,
# and the count's width follows from that: whatever `record` writes, the reader reads.
ROUND_HEADING = re.compile(r"^## Round ([0-9]{1,6}): (none|([a-z0-9][a-z0-9-]*) \(`([^`]+)` via `([a-z]+)`\))$")
ROUND_LINE = re.compile(r"^- (Writer|Writer model|Policy|Execution|Attempt reviewer|Attempt model|Attempt cli|Run|Effort|Lenses|Lines|Digest|Skipped): (\S.*)$")
# The one-pass completion review, recorded beside the rounds and never counted as one. It always carries Lines, Digest
# and the Candidate commit it reviewed; the writer's notes after it (its `- Filed:` lines) run to the next `## ` line.
COMPLETION_HEADING = re.compile(r"^## Completion review: (none|([a-z0-9][a-z0-9-]*) \(`([^`]+)` via `([a-z]+)`\))$")
PLAN_HEADING = re.compile(r"^## Plan review: (none|([a-z0-9][a-z0-9-]*) \(`([^`]+)` via `([a-z]+)`\))$")
COMPLETION_LINE = re.compile(r"^- (Writer|Writer model|Policy|Execution|Attempt reviewer|Attempt model|Attempt cli|Run|Candidate|Effort|Lenses|Lines|Digest|Skipped): (\S.*)$")
# The one-pass reviews, by --kind: the heading each is recorded under and the key read_findings lists them under.
PASSES = {"completion": ("## Completion review", COMPLETION_HEADING, "completions"),
          "plan": ("## Plan review", PLAN_HEADING, "plans")}
RESERVED = ("## Round", *(prefix for prefix, _, _ in PASSES.values()))
RESERVED_NAMES = "headings starting `## Round`, `## Completion review` or `## Plan review` are reserved for --record"
CANDIDATE = re.compile(r"[0-9a-f]{40}")
SKIPPED = re.compile(r"^([a-z0-9][a-z0-9-]*) \((.*)\)$")
COUNT = re.compile(r"[0-9]{1,%d}" % len(str(MAX_OUTPUT_BYTES + 1)))
DIGEST = re.compile(r"[0-9a-f]{16}")


def raw_lines(text):
    """Lines split on "\n" alone, the one boundary `record` and the reader share, every other byte kept. `str.splitlines`
    also splits on "\r", U+2028, U+0085 and others, which a review may contain."""
    return text.split("\n")


def canonical(line):
    """A line as compared and digested: a CRLF checkout's trailing "\r" dropped."""
    return line[:-1] if line.endswith("\r") else line


def digest(lines):
    return hashlib.sha256("\n".join(canonical(line) for line in lines).encode("utf-8")).hexdigest()[:16]


def _read_findings(text):
    """The rounds and completion reviews `record` and `record_completion` wrote in one findings file, as
    `{"rounds": [...], "completions": [...]}`, or None when anything they write is not as they write it.

    A round is a `## Round` heading, a blank line, and a metadata block to the next blank line in which every line is
    one of `record`'s fields (Writer and Run exactly once, Effort, Lines and Digest at most once, any number of Skipped;
    Digest only with Lines). With Lines, the next N lines are the review, skipped unread, and a blank line or the end of
    the file must follow them; with Digest, they must also hash to it, so a hand edit inside a review shows as
    unreadable even when it keeps the count. Without Lines (a round recorded before the count), the round runs to the
    next reserved heading. A completion review, and a plan review (`## Plan review`), is read the same way, with
    Writer, Run, Candidate, Lines and Digest required; the lines after it up to the next `## ` line are its `notes`,
    the writer's own record of what was done with each gap. Lenses, when present, is the comma-separated list the
    schedule gave the pass. Anything else makes the file unreadable rather than losing a field."""
    found = {"rounds": [], "completions": [], "plans": []}
    raw = raw_lines(text)
    lines = [canonical(line) for line in raw]
    i = 0
    while i < len(lines):
        kind = next((k for k, (prefix, _, _) in PASSES.items() if lines[i].startswith(prefix)), None)
        completion = kind is not None
        if not lines[i].startswith("## Round") and not completion:
            i += 1
            continue
        head = i
        heading = (PASSES[kind][1] if completion else ROUND_HEADING).match(lines[i])
        if not heading or i + 1 >= len(lines) or lines[i + 1] != "":
            return None, head
        if completion:
            entry = {"reviewer": heading.group(2), "model": heading.group(3), "cli": heading.group(4), "writer": None,
                     "run": None, "candidate": None, "effort": None, "lenses": None, "skipped": []}
        else:
            entry = {"number": int(heading.group(1)), "reviewer": heading.group(3), "model": heading.group(4),
                     "cli": heading.group(5), "writer": None, "run": None, "effort": None, "lenses": None,
                     "skipped": []}
        count = sealed = None
        i += 2
        while i < len(lines) and lines[i] != "":
            field = (COMPLETION_LINE if completion else ROUND_LINE).match(lines[i])
            if not field:
                return None, head
            key, value = field.group(1).lower().replace(" ", "_"), field.group(2)
            if key == "skipped":
                skipped = SKIPPED.match(value)
                if not skipped:
                    return None, head
                entry["skipped"].append({"reviewer": skipped.group(1), "reason": skipped.group(2)})
            elif key == "lines":
                # ASCII digits only: "²" passes str.isdigit and int() raises on it.
                if count is not None or not COUNT.fullmatch(value):
                    return None, head
                count = int(value)
            elif key == "digest":
                if sealed is not None or not DIGEST.fullmatch(value):
                    return None, head
                sealed = value
            elif entry.get(key) is not None or (key in ("candidate", "policy") and not CANDIDATE.fullmatch(value)):
                return None, head
            elif key in ("writer_model", "attempt_model", "attempt_reviewer", "attempt_cli", "execution", "policy"):
                if not MODEL.fullmatch(value):
                    return None, head
                entry[key] = value
            elif key == "lenses":
                names = value.split(", ")
                if not all(name in LENSES for name in names) or len(set(names)) != len(names):
                    return None, head
                entry[key] = names
            else:
                entry[key] = value
            i += 1
        if entry["writer"] is None or entry["run"] is None or (sealed is not None and count is None):
            return None, head
        if "policy" in entry:
            entry["_line"] = head
        if completion and (entry["candidate"] is None or sealed is None):
            return None, head
        if count is not None:
            start = i + 1  # the blank line after the metadata, then the review, unread
            i = start + count
            if i > len(lines) or (i < len(lines) and lines[i] != ""):
                return None, head
            if sealed is not None and digest(raw[start:i]) != sealed:
                return None, head
            entry["review"] = "\n".join(lines[start:i])
        else:
            end = next((j for j in range(i, len(lines)) if lines[j].startswith(RESERVED)), len(lines))
            entry["review"] = "\n".join(lines[i:end])
            i = end
        if completion:
            end = next((j for j in range(i, len(lines)) if lines[j].startswith("## ")), len(lines))
            entry["notes"] = [line for line in lines[i:end] if line.strip()]
            i = end
            found[PASSES[kind][2]].append(entry)
        else:
            found["rounds"].append(entry)
    return found, None


def read_findings(text):
    """See `_read_findings`: the parsed rounds, completion and plan reviews, or None when the file cannot be read."""
    return _read_findings(text)[0]


def unreadable_heading(text):
    """The line where a findings file stops being readable, as `line N: <text>`, so a refusal can name it. A writer's
    own note under a heading that starts `## Round`, `## Completion review` or `## Plan review` is the usual cause:
    those prefixes are reserved for what `--record` writes."""
    found, head = _read_findings(text)
    if found is not None or head is None:
        return ""
    lines = raw_lines(text)
    return f"; the first unreadable record starts at line {head + 1}: {canonical(lines[head])!r}" if head < len(lines) else ""


def returned_pass(kind, entry):
    """A recorded plan or completion review (kind "plan" or "completion") that is the one pass: a reviewer of another
    model family than the writer ran and its reply ends with the prompt's verdict lines, `PLAN: complete` or `gaps`
    then the `OVERALL:` line for a plan review, `COMPLETION: complete` or `gaps` for a completion review. An outage, a
    self-review or a reply cut short is a recorded attempt that leaves the pass open. scripts/lib/todo_graph.py
    `stamp` counts with this same predicate, so a pass the stamp would refuse never blocks the retry."""
    lines = [x.strip() for x in (entry.get("review") or "").splitlines() if x.strip()]
    family = bool(entry.get("reviewer")) and entry.get("writer") in WRITER_FAMILY \
        and FAMILY.get(entry.get("cli")) not in (None, WRITER_FAMILY[entry["writer"]])
    if kind == "plan":
        return family and len(lines) >= 2 and lines[-2] in ("PLAN: complete", "PLAN: gaps") \
            and lines[-1] in ("OVERALL: approve", "OVERALL: needs-attention")
    return family and bool(lines) and lines[-1] in ("COMPLETION: complete", "COMPLETION: gaps")


def read_rounds(text):
    """The rounds `record` wrote in one findings file (completion reviews are not rounds), or None when the file is not
    as `record` and `record_completion` write it (see read_findings)."""
    found = read_findings(text)
    return None if found is None else found["rounds"]


def read_completions(text):
    """The completion reviews `record_completion` wrote in one findings file, or None when it cannot be read back."""
    found = read_findings(text)
    return None if found is None else found["completions"]


def read_plans(text):
    """The plan reviews `--kind plan` recorded in one findings file, or None when it cannot be read back."""
    found = read_findings(text)
    return None if found is None else found["plans"]


class Unrecorded(Exception):
    """The findings file cannot be read back, so a round is not appended to it."""


def existing_findings(path, what):
    """A findings file's text as stored, or `Unrecorded` when it cannot be read."""
    try:
        # Bytes, not read_text: universal newlines would turn a stored lone "\r" into a line break and move the
        # line count of an earlier round.
        return path.read_bytes().decode("utf-8") if path.exists() else ""
    except (OSError, UnicodeDecodeError) as exc:
        raise Unrecorded(f"{path} cannot be read back ({exc}), so the {what} was not recorded") from None


def append_findings(path, existing, lines):
    # Always one blank line before the heading, even when the file already ends in one: a review whose last line is
    # empty also ends the file in "\n\n", and the reader needs a blank line after the review's own lines.
    separator = "" if not existing else ("\n" if existing.endswith("\n") else "\n\n")
    atomic_write(path, existing + separator + "\n".join(lines))


def record(path, result, when):
    """Append one round and return its number. A findings file the reader cannot read back gets nothing appended:
    numbering it would have to guess (counting headings counts quoted ones), so `Unrecorded` is raised instead."""
    existing = existing_findings(path, "round")
    known = read_rounds(existing)
    if known is None:
        raise Unrecorded(f"{path} cannot be read back (a round heading or line is not in the format --record writes"
                         f"{unreadable_heading(existing)}; {RESERVED_NAMES}), so the round was not recorded")
    number = len(known) + 1
    who = f"{result['reviewer']} (`{result['model']}` via `{result['cli']}`)" if result["reviewer"] else "none"
    review = raw_lines(result["review"] or "No reviewer returned a review. This round is not an approval.")
    if not COUNT.fullmatch(str(len(review))) or not ROUND_HEADING.match(f"## Round {number}: none"):
        raise Unrecorded(f"the review or the round number is past what {path} can be read back with, "
                         f"so the round was not recorded")
    lines = [f"## Round {number}: {who}", "", f"- Writer: {result['writer']}", f"- Run: {when}"]
    lines += metadata(result)
    lines += [f"- Lines: {len(review)}", f"- Digest: {digest(review)}", "", *review, ""]
    append_findings(path, existing, lines)
    return number


def metadata(result):
    lines = [f"- Effort: {result['effort']}"] if result.get("effort") else []
    for key in ("writer_model", "policy", "execution", "attempt_reviewer", "attempt_model", "attempt_cli"):
        if result.get(key):
            lines.append(f"- {key.replace('_', ' ').capitalize()}: {result[key]}")
    if result.get("lenses"):
        lines.append(f"- Lenses: {', '.join(result['lenses'])}")
    return lines + [f"- Skipped: {f['reviewer']} ({f['reason']})" for f in result["failover"]]


def record_completion(path, result, when, candidate, kind="completion"):
    """Append the completion review (or, with kind "plan", the plan review). Each is one pass: a findings file that
    already holds a returned one gets nothing appended (`Unrecorded`), and neither does one the reader cannot read."""
    prefix, _, key = PASSES[kind]
    what = f"{kind} review"
    existing = existing_findings(path, what)
    found = read_findings(existing)
    if found is None:
        raise Unrecorded(f"{path} cannot be read back (a heading or line is not in the format --record writes"
                         f"{unreadable_heading(existing)}; {RESERVED_NAMES}), so the {what} was not recorded")
    if any(returned_pass(kind, entry) for entry in found[key]):
        raise Unrecorded(f"{path} already holds a {what}; it is one pass, so this one was not recorded")
    who = f"{result['reviewer']} (`{result['model']}` via `{result['cli']}`)" if result["reviewer"] else "none"
    review = raw_lines(result["review"] or f"No reviewer returned a {what}. This pass is not an approval.")
    if not COUNT.fullmatch(str(len(review))):
        raise Unrecorded(f"the review is past what {path} can be read back with, so it was not recorded")
    lines = [f"{prefix}: {who}", "", f"- Writer: {result['writer']}", f"- Run: {when}", f"- Candidate: {candidate}"]
    lines += metadata(result)
    lines += [f"- Lines: {len(review)}", f"- Digest: {digest(review)}", "", *review, ""]
    append_findings(path, existing, lines)


def list_rounds(records_dir):
    """Every findings file under records_dir that holds rounds, with each round as `record` wrote it. A file
    whose round headings or lines are not `record`'s is named in `unreadable`, never dropped."""
    records_dir = Path(records_dir)
    records, unreadable = [], []

    def shown(path):
        # Never resolve: a path being reported as unreadable may be a symlink loop, which resolve() raises on.
        path = Path(os.path.abspath(path))
        return path.relative_to(ROOT).as_posix() if path.is_relative_to(ROOT) else path.as_posix()

    try:
        paths = sorted(records_dir.rglob("*.md")) if records_dir.is_dir() else []
    except OSError:  # a folder that cannot be walked is reported, like a file that cannot be read
        return {"records": [], "unreadable": [shown(records_dir)]}
    for path in paths:
        # One file that cannot be read, or is not UTF-8, is named in `unreadable`; the others are still listed.
        try:
            found = read_findings(path.read_bytes().decode("utf-8"))
        # RuntimeError: a symlink loop on older Pythons. ValueError: anything read_findings meets that int() or the
        # digest cannot take, so one bad file never aborts the listing.
        except (OSError, UnicodeDecodeError, RuntimeError, ValueError):
            found = None
        if found is None:
            unreadable.append(shown(path))
        elif found["rounds"] or found["completions"] or found["plans"]:
            records.append({"path": shown(path), "rounds": found["rounds"],
                            **({"completions": found["completions"]} if found["completions"] else {}),
                            **({"plans": found["plans"]} if found["plans"] else {})})
    return {"records": records, **({"unreadable": unreadable} if unreadable else {})}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--writer", choices=WRITERS, help="The agent whose work is under review")
    parser.add_argument("--writer-model", help="Exact authoring model version, required for new-policy cycles")
    parser.add_argument("--prompt", help="File holding the review prompt")
    parser.add_argument("--record", help="Findings file to append this round (or completion review) to")
    parser.add_argument("--kind", choices=("round", "completion", "plan"), default="round",
                        help="round (default): one review round; completion: the one-pass completion and excellence "
                             "review, recorded as a ## Completion review section and not counted as a round; plan: "
                             "the one-pass plan review before the build, recorded as a ## Plan review section")
    parser.add_argument("--candidate", help="With --kind completion or plan: the full 40-character commit under "
                                            "review (for a plan review, the commit holding the section as reviewed)")
    parser.add_argument("--surface", action="store_true",
                        help="The section has Surface: yes, so the schedule's rotation includes the design lens")
    parser.add_argument("--timeout", type=int, default=1800,
                        help="Seconds before the reviewer is stopped and the round records no review")
    parser.add_argument("--pin", default=str(PIN), help=argparse.SUPPRESS)
    parser.add_argument("--check-pin", action="store_true",
                        help="Report whether the pin loads, and each CLI's presence, instead of running a review; "
                             "no reviewer runs (exit 0 loads, 2 refused)")
    parser.add_argument("--list-rounds", action="store_true",
                        help="List the recorded review rounds instead of running one; no reviewer runs")
    parser.add_argument("--json", action="store_true", help="With --list-rounds, print the listing as JSON")
    parser.add_argument("--records", default=str(ROOT / "docs" / "reviews"),
                        help="With --list-rounds, the folder of findings files (default docs/reviews)")
    args = parser.parse_args(argv)
    if args.check_pin:
        # load_pin stays the only place the rules live: this reports its verdict and runs nothing.
        try:
            pin = load_pin(args.pin)
        except Refused as exc:
            print(json.dumps({"ok": False, "error": str(exc)}) if args.json else f"refused: {exc}")
            return 2
        clis = {cli: find_cli(cli) is not None for cli in CLIS}
        report = {"ok": True, "schema_version": pin["schema_version"], "reviewers": pin["reviewers"],
                  "routes": pin["routes"], **({"schedule": pin["schedule"]} if "schedule" in pin else {}), "clis": clis}
        print(json.dumps(report) if args.json else "ok")
        return 0
    if args.list_rounds:
        listing = list_rounds(args.records)
        if args.json:
            print(json.dumps(listing, indent=2))
        else:
            for entry in listing["records"]:
                for p in entry.get("plans", []):
                    who = f"{p['reviewer']} ({p['model']} via {p['cli']})" if p["reviewer"] else "no review"
                    print(f"{entry['path']}  Plan review: {who}, candidate {p['candidate']}, {p['run']}")
                for c in entry.get("completions", []):
                    who = f"{c['reviewer']} ({c['model']} via {c['cli']})" if c["reviewer"] else "no review"
                    print(f"{entry['path']}  Completion review: {who}, candidate {c['candidate']}, {c['run']}")
                for r in entry["rounds"]:
                    who = f"{r['reviewer']} ({r['model']} via {r['cli']})" if r["reviewer"] else "no review"
                    print(f"{entry['path']}  Round {r['number']}: {who}, writer {r['writer']}, {r['run']}")
            for path in listing.get("unreadable", []):
                print(f"{path}  unreadable: a round heading or line is not in the record format")
        return 0
    if not args.writer or not args.prompt:
        parser.error("--writer and --prompt are required unless --check-pin or --list-rounds is given")
    one_pass = args.kind in PASSES
    if one_pass and not (args.candidate and CANDIDATE.fullmatch(args.candidate)):
        parser.error(f"--kind {args.kind} needs --candidate, the full 40-character commit under review")
    if args.kind == "round" and args.candidate:
        parser.error("--candidate goes with --kind completion or plan; a round names its candidate in its prompt")
    try:
        pin = load_pin(args.pin)
        policy_sha = None
        if pin.get("schedule", {}).get("completion_order") == "last":
            if not args.record:
                raise Refused("current policy requires a durable --record")
            found = read_findings(existing_findings(Path(args.record), args.kind))
            if found is None:
                raise Refused("cannot read the existing review lineage; so no round was run")
            pin, policy_sha = record_policy(pin, found)
            validate_current_record(pin, found)
            if policy_sha is None:
                result = subprocess.run(["git", "-C", str(ROOT), "rev-parse", "HEAD"], capture_output=True,
                                        text=True, timeout=30)
                policy_sha = result.stdout.strip()
                shown = subprocess.run(["git", "-C", str(ROOT), "show", f"{policy_sha}:.conclave/reviewers.toml"],
                                       capture_output=True, timeout=30)
                if result.returncode or shown.returncode or load_pin(data=shown.stdout) != pin:
                    raise Refused("commit the current reviewer pin before beginning a review cycle")
            check_sequence(pin["schedule"], args.kind, found, args.writer, args.writer_model)
        plan = None
        if "schedule" in pin:
            rounds = []
            if args.record and args.kind == "round":
                # The position in the schedule comes from the rounds already recorded; a file that cannot be read
                # back is refused here, before a review is spent that could not be recorded.
                existing = existing_findings(Path(args.record), "round")
                rounds = read_rounds(existing)
                if rounds is None:
                    raise Unrecorded(f"{args.record} cannot be read back (a round heading or line is not in the "
                                     f"format --record writes{unreadable_heading(existing)}; {RESERVED_NAMES}), so "
                                     f"no round was run")
            plan = scheduled(pin["schedule"], args.kind, rounds, args.surface)
        if args.writer_model:
            if not MODEL.fullmatch(args.writer_model):
                raise Refused("invalid exact writer model")
        with in_flight(args.record, args.kind):
            result = review(pin, args.writer, args.prompt, args.timeout, plan)
        if args.writer_model:
            result["writer_model"] = args.writer_model
        if policy_sha:
            result["policy"] = policy_sha
        if pin.get("schedule", {}).get("completion_order") == "last" and result["reviewer"]:
            returned = returned_pass(args.kind, result) if one_pass else returned_review(result)
            if not returned:
                result.update(reviewer=None, execution="invalid", review=None,
                              failover=[{"reviewer": result["attempt_reviewer"], "reason": "invalid terminal verdict"}])
    except (Refused, Unrecorded, OSError) as exc:
        print("review-dispatch refused: " + str(exc), file=sys.stderr)
        return 2
    when = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    if one_pass:
        result.update(kind=args.kind, candidate=args.candidate)
    if plan and plan["position"]:
        result.update(position=plan["position"], escalated=plan["escalated"])
        stop_after = pin["schedule"]["severity_stop_after"]
        # The severity stop: a returned round past `severity_stop_after` whose worst finding is P3 ends the loop (0:
        # from round 1; todo_graph.SEVERITY_CUTOFF_ROUND is the same number, and `stamp`
        # re-checks it).
        result["severity_stop"] = bool(result["reviewer"]) and plan["position"] > stop_after \
            and clean(result["review"])
    if args.record:
        try:
            if one_pass:
                record_completion(Path(args.record), result, when, args.candidate, args.kind)
                result["recorded"] = True
            else:
                result["round"] = record(Path(args.record), result, when)
        except Unrecorded as exc:
            # The review still reaches stdout; only the findings file is left as it was.
            unrecorded = {"recorded": False} if one_pass else {"round": None}
            print(json.dumps({**result, **unrecorded, "run": when}, indent=2))
            print("review-dispatch refused: " + str(exc), file=sys.stderr)
            return 2
    print(json.dumps({**result, "run": when}, indent=2))
    return 0 if result["reviewer"] else 1


if __name__ == "__main__":
    sys.exit(main())
