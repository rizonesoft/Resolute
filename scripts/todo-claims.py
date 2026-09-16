#!/usr/bin/env python3
"""todo-claims -- re-verify the measured claims a TODO makes about this repository.

`todo-graph.py validate` proves the tree is internally consistent: every section has a
row, every reference resolves, every stamp covers what it claims. It cannot tell whether
a `Current state` block is still *true*, because an absence and an out-of-date figure
both look exactly like prose.

That is the gap this closes. A TODO states what it measured; this re-measures it.

A claim is an HTML comment, so it is invisible in rendered Markdown and inert to every
other parser that reads these files:

    <!-- claim: exists resolute_au3/SDK/Concrete/ReBar/ReBar.au3 -->
    <!-- claim: absent resolute_au3/SDK/Concrete/Rescue/Rescue.au3 -->
    <!-- claim: lines resolute_au3/SDK/Concrete/ReBar/ReBar.au3 = 1556 -->
    <!-- claim: count "\\.lng" resolute_au3/SDK/Concrete/*/*.au3 = 14 -->

A claim must be written on ONE line. The pattern may contain `\\n` as two characters,
which means a newline, but a real line break inside a claim splits it in half and is
reported rather than skipped: see `--coverage` and the unterminated-claim check.

Patterns are matched with `re.MULTILINE`, so `^` and `$` mean line start and line end.

A claim protects a figure somebody thought to record. `--coverage` protects the rest,
by naming every `Current state` block that carries no claim at all and by reporting a
block whose cited files have moved since the date it states.

Exit codes: 0 all claims hold, 1 at least one is stale or coverage fell, 2 a claim is
malformed.
"""

from __future__ import annotations

import argparse
import glob
import io
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CLAIM_RE = re.compile(r"<!--\s*claim:\s*(.+?)\s*-->")
# An opened claim that never closes on the same line. Split across two lines it
# matches nothing at all, so the claim silently disappears and the total still
# reads "all hold": a check reporting success for its own absence. Found
# 2026-09-17 by D00 T03 §4, which wrote two such claims by accident.
CLAIM_OPEN_RE = re.compile(r"<!--\s*claim:")
INLINE_CODE_RE = re.compile(r"`[^`]*`")
# count "<pattern>" <glob> = N   -- pattern is quoted because it may contain spaces
COUNT_RE = re.compile(r'^count\s+"(.+)"\s+(\S+)\s*=\s*(\d+)$')
LINES_RE = re.compile(r"^lines\s+(\S+)\s*=\s*(\d+)$")
PATH_RE = re.compile(r"^(exists|absent)\s+(\S+)$")

CURRENT_STATE_RE = re.compile(r"\*\*Current state\s*\(verified\s+(\d{4}-\d{2}-\d{2})\)")
HEADING_RE = re.compile(r"^#{1,6}\s")
# A path cited in prose: backticked, containing a slash or a dot, no spaces.
CITED_PATH_RE = re.compile(r"`([A-Za-z0-9_][A-Za-z0-9_./\-]*[A-Za-z0-9_/])`")

# The coverage ratchet. Raising this is a recorded decision: it changes with a
# commit, and the check refuses to let it fall. It is deliberately set to what
# was MEASURED on 2026-09-17 by D00 T04 §1, not to what would be nice: a floor
# above the real number fails on day one and gets deleted rather than met.
# 3 of 20 `Current state` blocks carried a claim when this was written.
COVERAGE_FLOOR = 3
DEFAULT_ROOT = "todo"


class Stale(Exception):
    """A claim parsed cleanly and is no longer true."""


class Malformed(Exception):
    """A claim could not be parsed, which is a defect in the TODO, not in the repo."""


def _resolve(pattern: str) -> list[Path]:
    """Glob relative to the repository root. Returns [] when nothing matches."""
    return [Path(p) for p in sorted(glob.glob(str(ROOT / pattern), recursive=True))]


def _ignored(target: str) -> bool:
    """Is this path ignored by the repository?

    A claim citing an ignored path holds only on a machine that happens to have
    that tree on disk, and fails for everyone else. Four claims cited
    `samples/ExoSuite/...` for a day for exactly this reason: they existed on the
    one machine that mattered, so `exists` was satisfied while the claim was
    worthless to any other clone. Found by the review of D00 T03 §1, made a check
    by D00 T04 §2 after `consistency` repeated six times.
    """
    probe = target.split("*")[0].rstrip("/")
    if not probe:
        return False
    try:
        out = subprocess.run(
            ["git", "check-ignore", "-q", "--", probe],
            cwd=ROOT, capture_output=True, timeout=10,
        )
    except (OSError, subprocess.SubprocessError):
        return False
    return out.returncode == 0


def _check_path(verb: str, target: str) -> str:
    hits = _resolve(target)
    if verb == "exists":
        if not hits:
            raise Stale(f"{target} does not exist")
        return f"{target} exists"
    if hits:
        raise Stale(f"{target} exists, and the claim says it should not")
    return f"{target} absent"


def _check_lines(target: str, expected: int) -> str:
    hits = _resolve(target)
    if not hits:
        raise Stale(f"{target} does not exist, so its line count cannot be checked")
    if len(hits) > 1:
        raise Malformed(f"'lines' needs one file; {target} matched {len(hits)}")
    actual = len(io.open(hits[0], encoding="utf-8", errors="replace").read().splitlines())
    if actual != expected:
        raise Stale(f"{target} is {actual} lines, the claim says {expected}")
    return f"{target} is {expected} lines"


def _check_count(pattern: str, target: str, expected: int) -> str:
    try:
        # MULTILINE so `^` and `$` mean line start and line end. Without it `^`
        # matches only at the start of the file and a line-anchored claim
        # silently counts 0, which reads as a stale figure rather than as a
        # pattern that cannot work. Found 2026-09-17 by D00 T03 §4.
        rx = re.compile(pattern, re.MULTILINE)
    except re.error as exc:
        raise Malformed(f"bad regex {pattern!r}: {exc}") from exc
    hits = _resolve(target)
    if not hits:
        raise Stale(f"{target} matched no files, so the count cannot be checked")
    actual = 0
    for path in hits:
        if path.is_dir():
            continue
        text = io.open(path, encoding="utf-8", errors="replace").read()
        actual += len(rx.findall(text))
    if actual != expected:
        raise Stale(f"{pattern!r} in {target} matches {actual} times, the claim says {expected}")
    return f"{pattern!r} in {target} matches {expected} times"


def evaluate(claim: str) -> str:
    """Return a human-readable confirmation, or raise Stale / Malformed."""
    target = None
    if m := PATH_RE.match(claim):
        target = m.group(2)
    elif m2 := LINES_RE.match(claim):
        target = m2.group(1)
    elif m3 := COUNT_RE.match(claim):
        target = m3.group(2)
    if target and _ignored(target):
        raise Malformed(
            f"{target} is gitignored, so this claim holds only on a machine that "
            "has that path on disk. Cite something the repository tracks."
        )
    if m := PATH_RE.match(claim):
        return _check_path(m.group(1), m.group(2))
    if m := LINES_RE.match(claim):
        return _check_lines(m.group(1), int(m.group(2)))
    if m := COUNT_RE.match(claim):
        return _check_count(m.group(1), m.group(2), int(m.group(3)))
    raise Malformed(f"unrecognised claim: {claim}")


def collect(paths: list[Path]) -> list[tuple[Path, int, str]]:
    found = []
    for path in paths:
        for lineno, line in enumerate(
            io.open(path, encoding="utf-8", errors="replace").read().splitlines(), 1
        ):
            for m in CLAIM_RE.finditer(line):
                found.append((path, lineno, m.group(1)))
    return found


def collect_unterminated(paths: list[Path]) -> list[tuple[Path, int, str]]:
    """Claim comments opened on a line that does not close them.

    A claim written across two lines matches CLAIM_RE nowhere, so without this it
    is not stale, not malformed, and not counted: it is simply gone, while the
    summary still reports every remaining claim holding.
    """
    found = []
    for path in paths:
        for lineno, line in enumerate(
            io.open(path, encoding="utf-8", errors="replace").read().splitlines(), 1
        ):
            # Strip inline code spans first. Prose *about* claims quotes the
            # opening token in backticks, and counting that as an unterminated
            # claim makes the check fire on its own documentation. A real claim
            # is never written inside backticks, so nothing genuine is hidden.
            scan = INLINE_CODE_RE.sub("", line)
            opens = len(CLAIM_OPEN_RE.findall(scan))
            closes = len(CLAIM_RE.findall(scan))
            if opens > closes:
                found.append((path, lineno, scan.strip()[:70]))
    return found


# ---------------------------------------------------------------- coverage


def _git_last_change(rel: str) -> str | None:
    """Committer date of the last commit touching `rel`, as YYYY-MM-DD, or None."""
    try:
        out = subprocess.run(
            ["git", "log", "-1", "--format=%cs", "--", rel],
            cwd=ROOT, capture_output=True, text=True, timeout=20,
        )
    except (OSError, subprocess.SubprocessError):
        return None
    val = out.stdout.strip()
    return val or None


def current_state_blocks(paths: list[Path]) -> list[dict]:
    """Every `Current state (verified DATE)` block, with its claims and cited paths.

    A block runs from its own line to the next Markdown heading, which is where the
    prose it introduces ends.
    """
    blocks = []
    for path in paths:
        lines = io.open(path, encoding="utf-8", errors="replace").read().splitlines()
        for i, line in enumerate(lines):
            m = CURRENT_STATE_RE.search(line)
            if not m:
                continue
            end = len(lines)
            for j in range(i + 1, len(lines)):
                if HEADING_RE.match(lines[j]):
                    end = j
                    break
            region = lines[i:end]
            text = "\n".join(region)
            # Keep anything shaped like a path, present or not. A cited file
            # that has been DELETED or renamed since the block was written is
            # the strongest evidence the block is stale, and filtering on
            # existence discarded exactly that case. Git answers for paths it
            # has ever tracked and stays silent for prose that merely looks
            # like a path, so the filter is git's rather than the filesystem's.
            cited = [c for c in CITED_PATH_RE.findall(text) if "/" in c or "." in c]
            try:
                shown = path.relative_to(ROOT).as_posix()
            except ValueError:
                shown = path.as_posix()   # a self-test fixture outside the repo
            blocks.append({
                "path": shown,
                "line": i + 1,
                "verified": m.group(1),
                "claims": len(CLAIM_RE.findall(text)),
                "cited": sorted(set(cited)),
            })
    return blocks


def run_coverage(
    paths: list[Path], quiet: bool = False, apply_floor: bool = True,
    check_dates: bool = True,
) -> tuple[int, int, list[str]]:
    """Report claim coverage and date-suspect blocks. Returns (covered, total, problems).

    `apply_floor` is False when scanning a subtree through `--root`. The floor is a
    repository-wide figure, and enforcing it against part of the tree fails on a
    perfectly healthy subtree, which is how an exit code stops meaning anything.
    """
    blocks = current_state_blocks(paths)
    total = len(blocks)
    covered = sum(1 for b in blocks if b["claims"] > 0)
    problems: list[str] = []

    uncovered = [b for b in blocks if b["claims"] == 0]
    if not quiet:
        print(f"todo-claims coverage: {covered}/{total} `Current state` block(s) carry a claim")
        if uncovered:
            print("\n  no claim, so nothing re-measures them:")
            for b in uncovered:
                print(f"    {b['path']}:{b['line']}  verified {b['verified']}")

    # The date check shells out to git once per cited path, 74 times on the
    # 2026-09-17 tree, and that is the whole cost of this function. The floor
    # needs only claim counts, which are free, so the default run skips it and
    # `--coverage` pays for it deliberately.
    suspect = []
    for b in (blocks if check_dates else []):
        moved = []
        for rel in b["cited"]:
            when = _git_last_change(rel)
            if when and when > b["verified"]:
                moved.append((rel, when))
        if moved:
            suspect.append((b, moved))

    if suspect and not quiet:
        print("\n  may be stale: cited files changed after the stated date.")
        print("  This cannot read prose, so it reports suspicion, never a verdict.")
        for b, moved in suspect:
            print(f"    {b['path']}:{b['line']}  verified {b['verified']}")
            for rel, when in moved[:4]:
                print(f"      {rel} last changed {when}")
            if len(moved) > 4:
                print(f"      ... and {len(moved) - 4} more")

    if apply_floor and covered < COVERAGE_FLOOR:
        problems.append(
            f"coverage fell to {covered}, below the recorded floor of {COVERAGE_FLOOR}. "
            "The floor ratchets: raise it deliberately, never lower it to pass."
        )
    return covered, total, problems


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(
        prog="todo-claims",
        description="Re-verify the measured claims a TODO makes about this repository.",
    )
    ap.add_argument(
        "--root", default=DEFAULT_ROOT,
        help="directory to scan for claims (default: todo). A subtree is scanned "
             "without the coverage floor, which is a whole-plan figure.",
    )
    ap.add_argument(
        "--quiet", action="store_true", help="print only failures and the summary"
    )
    ap.add_argument(
        "--coverage", action="store_true",
        help="report which `Current state` blocks carry no claim, and which look stale",
    )
    ap.add_argument(
        "--self-test", action="store_true", help="prove this script against known facts"
    )
    args = ap.parse_args(argv)

    if args.self_test:
        return _self_test()

    files = sorted((ROOT / args.root).rglob("*.md"))
    # The floor describes the whole plan. A --root subtree is scanned without it.
    scoped_floor = args.root.strip("/") == DEFAULT_ROOT

    if args.coverage:
        covered, total, problems = run_coverage(
            files, quiet=args.quiet, apply_floor=scoped_floor
        )
        for p in problems:
            print(f"\nFLOOR     {p}")
        if args.quiet:
            note = "" if scoped_floor else "  (floor not applied: --root selects a subtree)"
            print(f"todo-claims coverage: {covered}/{total}, floor {COVERAGE_FLOOR}{note}")
        return 1 if problems else 0

    claims = collect(files)
    unterminated = collect_unterminated(files)
    if not claims and not unterminated:
        print(f"todo-claims: no claims found under {args.root}/")
        print("  A TODO that measures something should record it as a claim, so the")
        print("  measurement is re-checked rather than trusted. See AGENTS.md.")
        # The floor is still owed. Returning here unconditionally meant that
        # deleting every claim in the tree made the gate pass, which is the one
        # failure a coverage floor exists to prevent.
        _, _, problems = run_coverage(
            files, quiet=True, apply_floor=scoped_floor, check_dates=False
        )
        for problem in problems:
            print(f"FLOOR     {problem}")
        return 1 if problems else 0

    stale, malformed = [], []
    held = 0   # counted, not derived: `malformed` also holds unterminated
               # comments that were never in `claims`, so subtracting its
               # length from the claim total reports a number that is wrong
               # in both directions at once.
    for path, lineno, claim in claims:
        rel = path.relative_to(ROOT).as_posix()
        try:
            ok = evaluate(claim)
            held += 1
            if not args.quiet:
                print(f"  ok    {rel}:{lineno}  {ok}")
        except Stale as exc:
            stale.append((rel, lineno, str(exc)))
        except Malformed as exc:
            malformed.append((rel, lineno, str(exc)))

    for path, lineno, snippet in unterminated:
        rel = path.relative_to(ROOT).as_posix()
        malformed.append((rel, lineno, f"claim opened and not closed on this line: {snippet}"))

    for rel, lineno, msg in malformed:
        print(f"MALFORMED {rel}:{lineno}  {msg}")
    for rel, lineno, msg in stale:
        print(f"STALE     {rel}:{lineno}  {msg}")

    covered, total, problems = run_coverage(
        files, quiet=True, apply_floor=scoped_floor, check_dates=False
    )
    for problem in problems:
        print(f"FLOOR     {problem}")

    floor_note = "" if scoped_floor else "  (floor not applied: --root selects a subtree)"
    print(
        f"\ntodo-claims: {len(claims)} claim(s) -- "
        f"{held} hold, "
        f"{len(stale)} stale, {len(malformed)} malformed; "
        f"coverage {covered}/{total}, floor {COVERAGE_FLOOR}{floor_note}"
    )
    if malformed:
        return 2
    return 1 if (stale or problems) else 0


def _self_test() -> int:
    """Prove the checker against a fixture, not against this file.

    Checking this script's own text would be self-referential: the test literals
    contain the patterns they search for, so the counts would include themselves.
    """
    import tempfile

    tmp = Path(tempfile.mkdtemp(prefix="todo-claims-"))
    fixture = tmp / "fixture.txt"
    fixture.write_text("alpha\nbeta\nalpha\n", encoding="utf-8")
    rel = fixture.relative_to(fixture.anchor).as_posix()

    # _resolve globs from ROOT, so the fixture is reached by absolute path.
    global ROOT
    saved_root, ROOT = ROOT, Path(fixture.anchor)

    cases = [
        (f"exists {rel}", True),
        (f"absent {rel}", False),
        ("exists nowhere/at/all.txt", False),
        ("absent nowhere/at/all.txt", True),
        (f"lines {rel} = 3", True),
        (f"lines {rel} = 4", False),
        ("lines nowhere/at/all.txt = 1", False),
        (f'count "alpha" {rel} = 2', True),
        (f'count "alpha" {rel} = 5', False),
        (f'count "gamma" {rel} = 0', True),
        # MULTILINE: `^` means line start, so two of the three lines start with a.
        (f'count "^alpha" {rel} = 2', True),
        (f'count "^beta" {rel} = 1', True),
        # Without MULTILINE this would be 0 and the claim would read as stale.
        (f'count "^alpha" {rel} = 0', False),
    ]
    failed = 0
    for claim, should_hold in cases:
        try:
            evaluate(claim)
            held = True
        except Stale:
            held = False
        except Malformed as exc:
            print(f"  FAIL  {claim}: unexpectedly malformed: {exc}")
            failed += 1
            continue
        if held != should_hold:
            print(f"  FAIL  {claim}: expected {'hold' if should_hold else 'stale'}")
            failed += 1

    for bad in ["nonsense", "lines no-equals-sign", 'count unquoted glob = 1']:
        try:
            evaluate(bad)
        except Malformed:
            continue
        except Stale:
            pass
        print(f"  FAIL  {bad!r}: expected Malformed")
        failed += 1

    ROOT = saved_root

    # The gitignored-path check, added by D00 T04 §2 after `consistency`
    # repeated six times. ROOT is restored above, so this runs against the real
    # repository, which is the only place git can answer.
    try:
        evaluate("exists build/release")
    except Malformed as exc:
        if "gitignored" not in str(exc):
            print(f"  FAIL  gitignored claim raised the wrong error: {exc}")
            failed += 1
    except Stale:
        print("  FAIL  a claim citing a gitignored path was allowed through")
        failed += 1
    else:
        print("  FAIL  a claim citing a gitignored path was allowed through")
        failed += 1

    # A tracked path must NOT trip it, or the check is useless noise.
    try:
        evaluate("exists AGENTS.md")
    except Malformed as exc:
        print(f"  FAIL  a tracked path was rejected as gitignored: {exc}")
        failed += 1
    except Stale:
        pass

    # An unterminated claim is reported, not skipped. This is the defect that
    # made two real claims vanish while the summary said everything held.
    split = tmp / "split.md"
    split.write_text(
        '<!-- claim: count "\n- x" TODO.md = 1 -->\n<!-- claim: exists a.txt -->\n',
        encoding="utf-8",
    )
    found = collect_unterminated([split])
    if len(found) != 1:
        print(f"  FAIL  unterminated claim: expected 1 report, got {len(found)}")
        failed += 1

    # Prose about claims quotes the opening token in backticks. Counting that
    # would make the check fire on its own documentation, which it did on first
    # run: the filed item describing this defect tripped it.
    prose = tmp / "prose.md"
    prose.write_text(
        "A claim opened with `<!-- claim:` and not closed is reported.\n",
        encoding="utf-8",
    )
    if collect_unterminated([prose]):
        print("  FAIL  prose quoting the claim token was reported as unterminated")
        failed += 1

    whole = tmp / "whole.md"
    whole.write_text("<!-- claim: exists a.txt -->\n", encoding="utf-8")
    if collect_unterminated([whole]):
        print("  FAIL  a well-formed claim was reported as unterminated")
        failed += 1

    # Coverage: a block with a claim is covered, one without is named.
    cov = tmp / "cov.md"
    cov.write_text(
        "# T\n\n> **Current state (verified 2020-01-01):** prose.\n"
        "<!-- claim: absent nowhere.txt -->\n\n"
        "## S\n\n> **Current state (verified 2020-01-02):** prose with no claim.\n",
        encoding="utf-8",
    )
    blocks = current_state_blocks([cov])
    if len(blocks) != 2:
        print(f"  FAIL  coverage: expected 2 blocks, got {len(blocks)}")
        failed += 1
    elif blocks[0]["claims"] != 1 or blocks[1]["claims"] != 0:
        print(f"  FAIL  coverage: claim attribution wrong: {[b['claims'] for b in blocks]}")
        failed += 1

    # --- the four findings the independent review of f875758 raised ---------
    # F3: the floor is a whole-plan figure; a --root subtree must not trip it.
    _, _, probs = run_coverage([cov], quiet=True, apply_floor=False)
    if probs:
        print("  FAIL  floor was applied to a subtree scan")
        failed += 1
    _, _, probs = run_coverage([cov], quiet=True, apply_floor=True)
    if not probs:
        print("  FAIL  floor was not applied when it should have been")
        failed += 1

    # F2: a cited path that no longer exists must survive into the git check,
    # because a deleted source is the strongest evidence a block went stale.
    gone = tmp / "gone.md"
    gone.write_text(
        "# T\n\n> **Current state (verified 2020-01-01):** cites `shared/exo-ui` "
        "and `src/main.cpp`.\n",
        encoding="utf-8",
    )
    cited = current_state_blocks([gone])[0]["cited"]
    if "shared/exo-ui" not in cited:
        print("  FAIL  a deleted cited path was filtered out before the git check")
        failed += 1

    for f in (fixture, split, whole, cov, prose, gone):
        f.unlink()
    tmp.rmdir()

    total = len(cases) + 3 + 10
    print(f"todo-claims self-test: {total} cases, {failed} failed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
