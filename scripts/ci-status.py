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
is filtered by the `paths` list in .github/workflows/plan.yml, so a commit owes it only when it touches one of
those paths; any other workflow that did run for the commit is read as well. GitHub attaches runs to the head
of a push, so ask about a commit that was pushed as a head.

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
PLAN_WORKFLOW = ROOT / ".github" / "workflows" / "plan.yml"
ALWAYS_OWED = ("gates",)
FILTERED = {"plan-gates": PLAN_WORKFLOW}
PROOF_SUFFIX = " (red proof)"
CALL_TIMEOUT = 30  # seconds for one gh call
POLL = 20  # seconds between reads under --wait
LOG_TAIL = 40
FIELDS = "databaseId,workflowName,status,conclusion,event,displayTitle,attempt,url,createdAt"


class CannotAsk(Exception):
    """gh could not answer; the message names why and what to do."""


def run_gh(args: list[str], timeout: float) -> str:
    try:
        done = subprocess.run(["gh", *args], capture_output=True, text=True, encoding="utf-8", errors="replace",
                              timeout=timeout, cwd=ROOT)
    except FileNotFoundError:
        raise CannotAsk("gh is not installed or not on PATH: install the GitHub CLI (https://cli.github.com)") from None
    except subprocess.TimeoutExpired:
        raise CannotAsk(f"gh {args[0]} {args[1]} did not answer within {timeout:.0f}s: check the network and run this again") from None
    if done.returncode != 0:
        said = (done.stderr or done.stdout).strip().splitlines()
        first = said[0] if said else f"exit {done.returncode}"
        if re.search(r"auth login|not logged in|authentication", " ".join(said), re.I):
            raise CannotAsk(f"gh is not signed in ({first}): run `gh auth login`")
        raise CannotAsk(f"gh {args[0]} {args[1]} failed ({first})")
    return done.stdout


def changed_paths(commit: str) -> list[str]:
    done = subprocess.run(["git", "diff-tree", "--no-commit-id", "--name-only", "-r", "-m", "--root", commit],
                          capture_output=True, text=True, encoding="utf-8", cwd=ROOT, timeout=CALL_TIMEOUT)
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
    verdict = 0
    for name in sorted(set(owed(paths, filtered)) | set(speaks)):
        run = speaks.get(name)
        if run is None:
            say(f"{name}: no run yet for {commit[:12]}")
            verdict = max(verdict, 2)
            continue
        where = f"attempt {run.get('attempt', 1)}, {run['url']}"
        if run["status"] != "completed":
            say(f"{name}: {run['status']} ({where})")
            verdict = max(verdict, 2)
        elif run["conclusion"] == "success":
            say(f"{name}: success ({where})")
        else:
            say(f"{name}: {run['conclusion'] or 'no conclusion'} ({where})")
            verdict = 1 if verdict in (0, 1, 2) else verdict
            try:
                tail = gh(["run", "view", str(run["databaseId"]), "--log-failed"], CALL_TIMEOUT).splitlines()[-LOG_TAIL:]
                for line in tail:
                    say("    " + line)
                if not tail:
                    say("    (the failed log is empty: open the run)")
            except CannotAsk as e:
                say(f"    the failed log could not be read ({e}): open the run")
    return verdict


def status(commit: str, wait: float, gh=run_gh, paths=None, filtered=None, say=print, clock=time.monotonic, sleep=time.sleep) -> int:
    if paths is None:
        paths = changed_paths(commit)
    if filtered is None:
        filtered = {name: workflow_paths(path.read_text(encoding="utf-8")) for name, path in FILTERED.items() if path.exists()}
    deadline = clock() + wait

    def bounded(args: list[str], timeout: float) -> str:
        left = deadline - clock()
        return gh(args, max(1.0, min(timeout, left)) if wait else timeout)

    while True:
        try:
            verdict = read(commit, bounded, paths, filtered, say)
        except CannotAsk as e:
            say(f"ci-status: {e}")
            return 3
        if verdict != 2 or clock() + POLL > deadline:
            if verdict == 2 and wait:
                say(f"ci-status: still not finished after {wait:.0f}s")
            return verdict
        say(f"ci-status: waiting ({max(0, deadline - clock()):.0f}s left)")
        sleep(POLL)


def self_test() -> int:
    failures: list[str] = []
    cases = 0

    def check(name: str, got, want) -> None:
        nonlocal cases
        cases += 1
        if got != want:
            failures.append(f"{name}: got {got!r}, want {want!r}")

    def run(name="gates", status_="completed", conclusion="success", title="a commit", created="2026-11-13T00:00:00Z", attempt=1, rid=1):
        return {"databaseId": rid, "workflowName": name, "status": status_, "conclusion": conclusion, "event": "push",
                "displayTitle": title, "attempt": attempt, "url": f"https://example.invalid/runs/{rid}", "createdAt": created}

    filtered = {"plan-gates": workflow_paths("on:\n  push:\n    paths:\n      - 'scripts/**'\n      - 'AGENTS.md'\njobs:\n")}
    check("the paths list is read", filtered["plan-gates"], ["scripts/**", "AGENTS.md"])

    def ask(runs, paths=("src/a.cpp",), log="line one\nthe failing line\n", wait=0.0, gh=None, ticks=None):
        said: list[str] = []
        now = [0.0]

        def fake(args, timeout):
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

        code = status("c0ffee", wait, gh=gh or fake, paths=list(paths), filtered=filtered, say=said.append, clock=lambda: now[0], sleep=sleep)
        return code, "\n".join(said)

    code, said = ask([run()])
    check("green", (code, "gates: success" in said), (0, True))
    code, said = ask([run(conclusion="failure")])
    check("red, with its log tail", (code, "gates: failure" in said, "the failing line" in said), (1, True, True))
    code, said = ask([run(conclusion="failure")], log=None)
    check("red, the log unreadable", (code, "could not be read" in said), (1, True))
    check("cancelled is red", ask([run(conclusion="cancelled")])[0], 1)
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
    code, said = ask([[run(status_="in_progress", conclusion="")], [run()]], wait=300, ticks=ticks)
    check("--wait ends when the run completes", (code, ticks), (0, [POLL]))
    ticks = []
    code, said = ask([run(status_="queued", conclusion="")], wait=50, ticks=ticks)
    check("--wait expires inside its bound", (code, sum(ticks) <= 50, "still not finished after 50s" in said), (2, True, True))

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
    done = subprocess.run(["git", "rev-parse", "--verify", args.commit + "^{commit}"], capture_output=True, text=True, cwd=ROOT)
    if done.returncode != 0:
        print(f"ci-status: {args.commit} is not a commit here")
        return 3
    return status(done.stdout.strip(), args.wait)


if __name__ == "__main__":
    sys.exit(main())
