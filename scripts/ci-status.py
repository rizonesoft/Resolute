#!/usr/bin/env python3
"""Read CI for a pushed commit: which workflows it owes, the run that speaks for each, and one verdict.

    python scripts/ci-status.py                 # HEAD
    python scripts/ci-status.py <commit>
    python scripts/ci-status.py --wait 1800     # poll until the runs finish, or the bound passes
    python scripts/ci-status.py --self-test

Exit codes
    0  every owed workflow's deciding run concluded success
    1  a deciding run concluded otherwise (failure, cancelled, timed_out, ...); its failed log's tail is printed
    2  an owed run is queued, in progress, or has not appeared
    3  the question could not be asked: no gh, not signed in, an API error, or a call that timed out

What a commit owes (D00 T01 section 10). `gates` has no path filter, so every pushed head owes it. `plan-gates`
is filtered by the `paths` list in .github/workflows/plan.yml as the commit has it, and GitHub applies that
filter to the whole push, base to head: so the reader asks GitHub which push ended at the commit and lists what
that push changed. Any other workflow that did run for the commit is read as well. GitHub attaches runs to the
head of a push, so ask about a commit that was pushed as a head; for any other commit the reader says it cannot
establish what is owed (exit 3).

Which run speaks. A run whose name ends " (red proof)" is the deliberate failure that proves the workflow can
go red: it never counts, red or green. Among the rest, the newest run of a workflow for the commit decides, at
its latest attempt, so a re-run replaces the attempt before it.

Stdlib only, like the rest of scripts/.
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import re
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PLAN_WORKFLOW = ".github/workflows/plan.yml"
ALWAYS_OWED = ("gates",)
FILTERED = {"plan-gates": PLAN_WORKFLOW}
PROOF_SUFFIX = " (red proof)"
CALL_TIMEOUT = 30  # seconds for one gh call
POLL = 20  # seconds between reads under --wait
LOG_TAIL = 40
FIELDS = "databaseId,workflowName,status,conclusion,event,displayTitle,attempt,url,createdAt"


class CannotAsk(Exception):
    """gh could not answer; the message names why and what to do."""


class TimedOut(CannotAsk):
    """One gh call ran out of the time it was given."""


class BudgetSpent(Exception):
    """The --wait interval is over: nothing more is asked."""


def run_gh(args: list[str], timeout: float) -> str:
    try:
        done = subprocess.run(["gh", *args], capture_output=True, text=True, encoding="utf-8", errors="replace",
                              timeout=timeout, cwd=ROOT)
    except FileNotFoundError:
        raise CannotAsk("gh is not installed or not on PATH: install the GitHub CLI (https://cli.github.com)") from None
    except subprocess.TimeoutExpired:
        raise TimedOut(f"gh {args[0]} {args[1]} did not answer within {timeout:.0f}s: check the network and run this again") from None
    except OSError as e:
        raise CannotAsk(f"gh could not be started ({e}): check that this account is allowed to run it") from None
    if done.returncode != 0:
        said = (done.stderr or done.stdout).strip().splitlines()
        first = said[0] if said else f"exit {done.returncode}"
        if re.search(r"auth login|not logged in|authentication", " ".join(said), re.I):
            raise CannotAsk(f"gh is not signed in ({first}): run `gh auth login`")
        raise CannotAsk(f"gh {args[0]} {args[1]} failed ({first})")
    return done.stdout


def run_git(args: list[str], timeout: float) -> subprocess.CompletedProcess:
    """One git read, bounded. A git that cannot run or does not answer is said, never read as empty output."""
    try:
        return subprocess.run(["git", *args], capture_output=True, text=True, encoding="utf-8", errors="replace",
                              cwd=ROOT, timeout=timeout)
    except FileNotFoundError:
        raise CannotAsk("git is not installed or not on PATH") from None
    except subprocess.TimeoutExpired:
        raise TimedOut(f"git {args[0]} did not answer within {timeout:.0f}s") from None
    except OSError as e:
        raise CannotAsk(f"git {args[0]} could not run ({e})") from None


def first_line(text: str) -> str:
    return (text.strip().splitlines() or ["no message"])[0]


def resolve_commit(name: str, timeout: float = CALL_TIMEOUT) -> str:
    done = run_git(["rev-parse", "--verify", name + "^{commit}"], timeout)
    if done.returncode != 0:
        raise CannotAsk(f"{name} is not a commit here")
    return done.stdout.strip()


def committed_text(commit: str, rel: str, timeout: float = CALL_TIMEOUT) -> str | None:
    """A file as the commit has it, or None when the commit has no such file.

    What a commit owes is decided by the workflow file in that commit: the working tree may have moved on, and a
    later edit to a path filter must not change the verdict on an earlier candidate."""
    done = run_git(["show", f"{commit}:{rel}"], timeout)
    if done.returncode == 0:
        return done.stdout
    if re.search(r"does not exist|exists on disk, but not in", done.stderr):
        return None
    raise CannotAsk(f"git could not read {rel} at {commit[:12]} ({first_line(done.stderr)})")


def push_base(commit: str, gh, timeout: float = CALL_TIMEOUT) -> str:
    """The commit `main` pointed at before the push that ended at `commit`.

    GitHub applies a workflow's path filter to the whole push, base to head, not to the head commit alone: a push
    of a TODO edit followed by a C++ commit owes `plan-gates`, and a change reverted inside one push does not. So
    what a commit owes is read from the push GitHub recorded, and when GitHub records none ending at this commit
    the answer is that it cannot be established, never a guess."""
    query = ["api", "repos/{owner}/{repo}/activity?activity_type=push&per_page=100",
             "--jq", f'.[] | select(.after == "{commit}") | .before']
    # The newest hundred pushes answer almost every question in one request; an older head is looked for through
    # every page GitHub has. A search that is cut short raises (exit 3); only a finished one may say "none".
    found = gh(query, timeout).split() or gh([*query, "--paginate"], timeout).split()
    if not found:
        raise CannotAsk(f"GitHub lists no push ending at {commit[:12]}: it was not pushed as a head, "
                        "so what it owes cannot be established (ask about the head of the push that carried it)")
    return found[0]


def changed_paths(commit: str, base: str, timeout: float = CALL_TIMEOUT) -> list[str]:
    """The paths the push changed, base to head. A failed listing is an error: an empty list would say the push
    owes no path-filtered workflow, and a green verdict must never rest on that."""
    if set(base) == {"0"}:  # the push created the branch: everything the commit holds is new
        done = run_git(["diff-tree", "--no-commit-id", "--name-only", "-r", "-m", "--root", commit], timeout)
    else:
        done = run_git(["diff", "--name-only", base, commit], timeout)
    if done.returncode != 0:
        raise CannotAsk(f"git could not list what the push {base[:12]}..{commit[:12]} changed ({first_line(done.stderr)})")
    return sorted({line for line in done.stdout.splitlines() if line})


def workflow_paths(text: str) -> list[str]:
    """The `paths:` list of a workflow's push trigger, read without a YAML parser (the tree has none)."""
    out: list[str] = []
    inside = False
    for line in text.splitlines():
        if re.match(r"^\s*paths:\s*$", line):
            inside = True
        elif inside:
            item = re.match(r"^\s*-\s*['\"]?([^'\"]+)['\"]?\s*$", line)
            if not item:
                break
            out.append(item.group(1))
    return out


def touches(paths: list[str], patterns: list[str]) -> bool:
    for pattern in patterns:
        prefix = pattern[:-2] if pattern.endswith("/**") else None  # `scripts/**` is everything under scripts/
        for path in paths:
            if (prefix and path.startswith(prefix)) or fnmatch.fnmatchcase(path, pattern):
                return True
    return False


def owed(paths: list[str], filtered: dict[str, list[str]]) -> list[str]:
    return list(ALWAYS_OWED) + [name for name, patterns in filtered.items() if touches(paths, patterns)]


def deciding(runs: list[dict]) -> dict[str, dict]:
    """The newest run of each workflow that is not a red proof."""
    out: dict[str, dict] = {}
    for run in runs:
        if str(run.get("displayTitle", "")).endswith(PROOF_SUFFIX):
            continue
        name = run["workflowName"]
        if name not in out or run["createdAt"] > out[name]["createdAt"]:
            out[name] = run
    return out


def read(commit: str, gh, paths: list[str], filtered: dict[str, list[str]], say) -> int:
    runs = json.loads(gh(["run", "list", "--commit", commit, "--limit", "50", "--json", FIELDS], CALL_TIMEOUT) or "[]")
    speaks = deciding(runs)
    red = pending = False  # a known failure outranks a run still to come: red is fixed first
    for name in sorted(set(owed(paths, filtered)) | set(speaks)):
        run = speaks.get(name)
        if run is None:
            say(f"{name}: no run yet for {commit[:12]}")
            pending = True
            continue
        where = f"attempt {run.get('attempt', 1)}, {run['url']}"
        if run["status"] != "completed":
            say(f"{name}: {run['status']} ({where})")
            pending = True
        elif run["conclusion"] == "success":
            say(f"{name}: success ({where})")
        else:
            say(f"{name}: {run['conclusion'] or 'no conclusion'} ({where})")
            red = True
            try:
                tail = gh(["run", "view", str(run["databaseId"]), "--log-failed"], CALL_TIMEOUT).splitlines()[-LOG_TAIL:]
                for line in tail:
                    say("    " + line)
                if not tail:
                    say("    (the failed log is empty: open the run)")
            except BudgetSpent:
                say("    the failed log was not read (the wait interval is over): open the run")  # the failure stands
            except CannotAsk as e:
                say(f"    the failed log could not be read ({e}): open the run")
    return 1 if red else 2 if pending else 0


def status(name: str, wait: float, gh=run_gh, paths=None, filtered=None, say=print, clock=time.monotonic, sleep=time.sleep,
           committed=committed_text, changed=changed_paths, resolve=resolve_commit, pushed=None) -> int:
    """One read, or with `wait` a poll that ends when the runs finish or the interval is over.

    The interval is one budget for everything: resolving the commit, reading what it changed and what it owes,
    every gh call, and the sleeping between reads. No read is given more time than is left, and nothing is asked
    once it is spent, so the command returns inside the interval it was given."""
    start = clock()
    deadline = start + wait

    def within(call, *args):
        if not wait:
            return call(*args, CALL_TIMEOUT)
        left = deadline - clock()
        if left <= 0:
            raise BudgetSpent
        try:
            return call(*args, min(CALL_TIMEOUT, left))
        except TimedOut:
            if clock() >= deadline:
                raise BudgetSpent from None  # the interval ran out during the read: that is the wait ending
            raise

    def bounded(args: list[str], timeout: float) -> str:
        return within(gh, args)

    def expired() -> int:
        say(f"ci-status: still not finished after {clock() - start:.0f}s")
        return 2

    try:
        commit = within(resolve, name)
        if paths is None:
            # Each request of the lookup draws on what is left of the interval when it starts, not on one
            # allowance taken at the beginning.
            base = within(pushed, commit) if pushed else push_base(commit, bounded)
            paths = within(changed, commit, base)
        if filtered is None:
            filtered = {}
            for workflow, rel in FILTERED.items():
                text = within(committed, commit, rel)
                if text is not None:
                    filtered[workflow] = workflow_paths(text)
    except BudgetSpent:
        return expired()
    except CannotAsk as e:
        say(f"ci-status: {e}")
        return 3

    while True:
        try:
            verdict = read(commit, bounded, paths, filtered, say)
        except BudgetSpent:
            return expired()
        except CannotAsk as e:
            say(f"ci-status: {e}")
            return 3
        if verdict != 2 or not wait:
            return verdict
        left = deadline - clock()
        if left <= 0:
            return expired()
        say(f"ci-status: waiting ({left:.0f}s left)")
        sleep(min(POLL, left))
        if clock() >= deadline:
            return expired()


def answer(name: str, wait: float, say=print, **readers) -> int:
    """status(), with the one promise its exit code makes kept: 1 means a red run and nothing else.

    An error the reader did not foresee would otherwise leave as a traceback, which exits 1, and a consumer reads 1
    as red CI. It is said as what it is, a reader that could not read, and that is exit 3."""
    try:
        return status(name, wait, say=say, **readers)
    except Exception as e:  # the door for whatever is not handled by name above
        say(f"ci-status: CI could not be read ({type(e).__name__}: {e}); this is not a CI result")
        return 3


def self_test() -> int:
    failures: list[str] = []
    cases = 0

    def named(*args, **kwargs) -> int:
        """status() on a fixture commit: nothing is resolved through git."""
        kwargs.setdefault("resolve", lambda name, timeout: name)
        kwargs.setdefault("pushed", lambda commit, timeout: "ba5e")
        return status(*args, **kwargs)

    def check(name: str, got, want) -> None:
        nonlocal cases
        cases += 1
        if got != want:
            failures.append(f"{name}: got {got!r}, want {want!r}")

    def run(name="gates", status_="completed", conclusion="success", title="a commit", created="2026-11-13T00:00:00Z", attempt=1, rid=1):
        return {"databaseId": rid, "workflowName": name, "status": status_, "conclusion": conclusion, "event": "push",
                "displayTitle": title, "attempt": attempt, "url": f"https://example.invalid/runs/{rid}", "createdAt": created}

    given: list[float] = []
    filtered = {"plan-gates": workflow_paths("on:\n  push:\n    paths:\n      - 'scripts/**'\n      - 'AGENTS.md'\njobs:\n")}
    check("the paths list is read", filtered["plan-gates"], ["scripts/**", "AGENTS.md"])

    def ask(runs, paths=("src/a.cpp",), log="line one\nthe failing line\n", wait=0.0, gh=None, ticks=None):
        said: list[str] = []
        now = [0.0]
        given.clear()

        def fake(args, timeout):
            given.append(timeout)
            if args[:2] == ["run", "view"]:
                if log is None:
                    raise CannotAsk("gh run view failed (HTTP 410)")
                return log
            batch = runs.pop(0) if runs and isinstance(runs[0], list) and len(runs) > 1 else (runs[0] if runs and isinstance(runs[0], list) else runs)
            return json.dumps(batch)

        def sleep(seconds):
            now[0] += seconds
            if ticks is not None:
                ticks.append(seconds)

        code = named("c0ffee", wait, gh=gh or fake, paths=list(paths), filtered=filtered, say=said.append, clock=lambda: now[0], sleep=sleep)
        return code, "\n".join(said)

    code, said = ask([run()])
    check("green", (code, "gates: success" in said), (0, True))
    code, said = ask([run(conclusion="failure")])
    check("red, with its log tail", (code, "gates: failure" in said, "the failing line" in said), (1, True, True))
    code, said = ask([run(conclusion="failure")], log=None)
    check("red, the log unreadable", (code, "could not be read" in said), (1, True))
    check("cancelled is red", ask([run(conclusion="cancelled")])[0], 1)
    check("a failure outranks another workflow still running",
          ask([run(conclusion="failure"), run(name="plan-gates", status_="in_progress", conclusion="", rid=4)], paths=("scripts/x.py",))[0], 1)
    code, said = ask([run(status_="in_progress", conclusion="")])
    check("in progress", (code, "gates: in_progress" in said), (2, True))
    code, said = ask([])
    check("an owed gates run missing", (code, "gates: no run yet" in said), (2, True))
    code, said = ask([run()], paths=("src/a.cpp",))
    check("plan-gates rightly absent outside its paths", (code, "plan-gates" in said), (0, False))
    code, said = ask([run()], paths=("scripts/x.py",))
    check("plan-gates wrongly absent inside its paths", (code, "plan-gates: no run yet" in said), (2, True))
    check("a red proof beside a green run is green",
          ask([run(), run(conclusion="failure", title="gates (red proof)", created="2026-11-13T01:00:00Z", rid=2)])[0], 0)
    check("a green proof does not cover a red run",
          ask([run(conclusion="failure"), run(title="gates (red proof)", created="2026-11-13T01:00:00Z", rid=2)])[0], 1)
    check("a re-run that went green decides", ask([run(conclusion="success", attempt=2)])[0], 0)
    check("a newer run decides over an older red one",
          ask([run(conclusion="failure"), run(created="2026-11-13T02:00:00Z", rid=3)])[0], 0)

    def no_gh(args, timeout):
        raise CannotAsk("gh is not installed or not on PATH: install the GitHub CLI (https://cli.github.com)")

    code, said = ask([], gh=no_gh)
    check("gh missing", (code, "not installed" in said), (3, True))
    real_run = subprocess.run
    try:
        subprocess.run = lambda *a, **k: subprocess.CompletedProcess(a, 1, "", "To get started with GitHub CLI, please run:  gh auth login\n")
        try:
            run_gh(["run", "list"], 5)
            check("gh unauthenticated", "no refusal", "refused")
        except CannotAsk as e:
            check("gh unauthenticated", "gh auth login" in str(e), True)

        def refused_launch(*a, **k):
            raise PermissionError(13, "Access is denied")

        subprocess.run = refused_launch
        said_lines = []
        code = named("c0ffee", 0, paths=["src/a.cpp"], filtered=filtered, say=said_lines.append)
        check("a gh that Windows refuses to start is exit 3, named", (code, "gh could not be started" in " ".join(said_lines)), (3, True))

        def stalled(*a, **k):
            raise subprocess.TimeoutExpired(a, k.get("timeout", 0.0))

        subprocess.run = stalled
        try:
            run_gh(["run", "list"], 5)
            check("a gh call that times out", "no refusal", "refused")
        except CannotAsk as e:
            check("a gh call that times out", "did not answer within 5s" in str(e), True)
    finally:
        subprocess.run = real_run
    ticks: list = []
    code, said = ask([[run(status_="in_progress", conclusion="")], [run()]], wait=30, ticks=ticks)
    check("--wait reads again after one polling interval and ends when the run completes", (code, ticks), (0, [POLL]))
    ticks = []
    code, said = ask([run(status_="queued", conclusion="")], wait=50, ticks=ticks)
    check("--wait sleeps through its whole interval before it expires", (code, sum(ticks), "still not finished after 50s" in said), (2, 50, True))
    ticks = []
    code, said = ask([run(status_="queued", conclusion="")], wait=10, ticks=ticks)
    check("a wait shorter than the polling interval sleeps exactly that long, and says so",
          (code, ticks, "still not finished after 10s" in said, len(given)), (2, [10], True, 1))

    # The interval covers the calls too: a call that uses it up ends the wait (2), where the same stall with no
    # wait is gh failing to answer (3).
    def slow(clock_box):
        def call(args, timeout):
            clock_box[0] += timeout
            raise TimedOut(f"gh run list did not answer within {timeout:.0f}s")
        return call

    box = [0.0]
    said_lines: list[str] = []
    code = named("c0ffee", 12, gh=slow(box), paths=["src/a.cpp"], filtered=filtered, say=said_lines.append,
                  clock=lambda: box[0], sleep=lambda seconds: box.__setitem__(0, box[0] + seconds))
    check("a call that uses up the wait ends it inside the interval", (code, box[0], "still not finished after 12s" in "\n".join(said_lines)), (2, 12.0, True))
    box = [0.0]
    code = named("c0ffee", 0, gh=slow(box), paths=["src/a.cpp"], filtered=filtered, say=lambda line: None, clock=lambda: box[0])
    check("the same stall with no wait is gh failing to answer", code, 3)

    # A failure already read stands when the wait runs out while its log is being fetched.
    box = [0.0]

    def list_then_stall(args, timeout):
        if args[:2] == ["run", "view"]:
            box[0] += timeout
            raise TimedOut("gh run view did not answer")
        return json.dumps([run(conclusion="failure")])

    said_lines = []
    code = named("c0ffee", 10, gh=list_then_stall, paths=["src/a.cpp"], filtered=filtered, say=said_lines.append,
                  clock=lambda: box[0], sleep=lambda seconds: None)
    check("a known failure is still red when the wait ends during its log", (code, "gates: failure" in " ".join(said_lines)), (1, True))

    # What a commit owes comes from the workflow file in that commit, not from the working tree.
    then = "on:\n  push:\n    paths:\n      - 'scripts/**'\njobs:\n"
    seen: list = []

    def at_commit(commit, rel, timeout):
        seen.append((commit, rel))
        return then

    said_lines = []
    code = named("c0ffee", 0, gh=lambda args, timeout: json.dumps([run()]), paths=["scripts/x.py"], say=said_lines.append, committed=at_commit)
    check("the path filter is read from the queried commit", (code, seen, "plan-gates: no run yet" in "\n".join(said_lines)),
          (2, [("c0ffee", PLAN_WORKFLOW)], True))
    code = named("c0ffee", 0, gh=lambda args, timeout: json.dumps([run()]), paths=["scripts/x.py"], say=lambda line: None,
                  committed=lambda commit, rel, timeout: None)
    check("a commit with no plan workflow owes only gates", code, 0)

    def unreadable(commit, rel, timeout):
        raise CannotAsk("git could not read .github/workflows/plan.yml at c0ffee (fatal: bad object)")

    said_lines = []
    code = named("c0ffee", 0, gh=lambda args, timeout: json.dumps([run()]), paths=["scripts/x.py"], say=said_lines.append, committed=unreadable)
    check("a workflow file git cannot read is said, never guessed", (code, "git could not read" in "\n".join(said_lines)), (3, True))

    # What is owed follows the whole push, base to head, as GitHub's path filter does.
    spans: list = []

    def push_changed(touched):
        def listing(commit, base, timeout):
            spans.append((base, commit))
            return touched
        return listing

    said_lines = []
    code = named("c0ffee", 0, gh=lambda args, timeout: json.dumps([run()]), filtered=filtered, say=said_lines.append,
                 changed=push_changed(["src/a.cpp", "scripts/x.py"]))
    check("a push whose earlier commit touched the filter owes plan-gates, though its head did not",
          (code, spans, "plan-gates: no run yet" in " ".join(said_lines)), (2, [("ba5e", "c0ffee")], True))
    code = named("c0ffee", 0, gh=lambda args, timeout: json.dumps([run()]), filtered=filtered, say=lambda line: None,
                 changed=push_changed(["src/a.cpp"]))
    check("a push that changed nothing under the filter owes only gates", code, 0)

    def no_push(commit, timeout):
        raise CannotAsk(f"GitHub lists no push ending at {commit} among the last 100")

    said_lines = []
    code = named("c0ffee", 0, gh=lambda args, timeout: json.dumps([run()]), filtered=filtered, say=said_lines.append, pushed=no_push)
    check("a commit GitHub records no push for is exit 3, never green", (code, "lists no push ending at" in " ".join(said_lines)), (3, True))
    check("the push base is read from GitHub's record of the push",
          push_base("c0ffee", lambda args, timeout: "0123abcd\n", 5), "0123abcd")
    box = [0.0]
    budgets: list = []

    def two_slow_pages(args, timeout):
        budgets.append(timeout)
        box[0] += 9
        return "[]" if args[:2] == ["run", "list"] else ("0ldba5e\n" if "--paginate" in args else "")

    status("c0ffee", 10, gh=two_slow_pages, filtered=filtered, say=lambda line: None, clock=lambda: box[0], sleep=lambda seconds: None,
           resolve=lambda name, timeout: name, changed=lambda commit, base, timeout: ["src/a.cpp"])
    check("the second page of the push lookup gets only what is left of the wait", budgets[:2], [10, 1])
    check("a head older than the newest hundred pushes is found on a later page",
          push_base("c0ffee", lambda args, timeout: "0ldba5e\n" if "--paginate" in args else "", 5), "0ldba5e")

    # Local git is inside the same rules: a failed read is exit 3 and never an empty answer, and a slow one
    # spends the wait like any other read.
    def cannot_list(commit, base, timeout):
        raise CannotAsk("git could not list what c0ffee changed (fatal: bad object)")

    said_lines = []
    code = named("c0ffee", 0, gh=lambda args, timeout: json.dumps([run()]), filtered=filtered, say=said_lines.append, changed=cannot_list)
    check("a failed listing of the commit's paths is exit 3, never green", (code, "git could not list" in " ".join(said_lines)), (3, True))
    code = status("nope", 0, gh=lambda args, timeout: json.dumps([run()]), paths=["src/a.cpp"], filtered=filtered, say=said_lines.append,
                  resolve=lambda name, timeout: (_ for _ in ()).throw(CannotAsk(f"{name} is not a commit here")))
    check("a name that is not a commit is exit 3", (code, "nope is not a commit here" in " ".join(said_lines)), (3, True))
    box = [0.0]

    def slow_git(name, timeout):
        box[0] += timeout
        raise TimedOut(f"git rev-parse did not answer within {timeout:.0f}s")

    asked: list = []
    code = status("c0ffee", 1, gh=lambda args, timeout: asked.append(args) or "[]", paths=["src/a.cpp"], filtered=filtered,
                  say=lambda line: None, clock=lambda: box[0], resolve=slow_git)
    check("slow local git spends the wait: exit 2 at the interval, and nothing more is asked", (code, box[0], asked), (2, 1.0, []))

    said_lines = []
    code = answer("c0ffee", 0, say=said_lines.append, gh=lambda args, timeout: "not json", paths=["src/a.cpp"], filtered=filtered,
                  resolve=lambda name, timeout: name)
    check("an error the reader did not foresee is exit 3 and said, never a traceback",
          (code, "CI could not be read" in " ".join(said_lines), "this is not a CI result" in " ".join(said_lines)), (3, True, True))

    for failure in failures:
        print("FAIL " + failure)
    print(f"{cases} cases, {len(failures)} failed")
    return 1 if failures else 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Read CI for a pushed commit.")
    parser.add_argument("commit", nargs="?", default="HEAD")
    parser.add_argument("--wait", type=float, default=0.0, metavar="SECONDS", help="poll until the runs finish, at most this long")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        return self_test()
    return answer(args.commit, args.wait)


if __name__ == "__main__":
    sys.exit(main())
