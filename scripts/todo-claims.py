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

Exit codes: 0 all claims hold, 1 at least one is stale, 2 a claim is malformed.
"""

from __future__ import annotations

import argparse
import glob
import io
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CLAIM_RE = re.compile(r"<!--\s*claim:\s*(.+?)\s*-->")
# count "<pattern>" <glob> = N   -- pattern is quoted because it may contain spaces
COUNT_RE = re.compile(r'^count\s+"(.+)"\s+(\S+)\s*=\s*(\d+)$')
LINES_RE = re.compile(r"^lines\s+(\S+)\s*=\s*(\d+)$")
PATH_RE = re.compile(r"^(exists|absent)\s+(\S+)$")


class Stale(Exception):
    """A claim parsed cleanly and is no longer true."""


class Malformed(Exception):
    """A claim could not be parsed, which is a defect in the TODO, not in the repo."""


def _resolve(pattern: str) -> list[Path]:
    """Glob relative to the repository root. Returns [] when nothing matches."""
    return [Path(p) for p in sorted(glob.glob(str(ROOT / pattern), recursive=True))]


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
        rx = re.compile(pattern)
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


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(
        prog="todo-claims",
        description="Re-verify the measured claims a TODO makes about this repository.",
    )
    ap.add_argument(
        "--root", default="todo", help="directory to scan for claims (default: todo)"
    )
    ap.add_argument(
        "--quiet", action="store_true", help="print only failures and the summary"
    )
    ap.add_argument(
        "--self-test", action="store_true", help="prove this script against known facts"
    )
    args = ap.parse_args(argv)

    if args.self_test:
        return _self_test()

    files = sorted((ROOT / args.root).rglob("*.md"))
    claims = collect(files)
    if not claims:
        print(f"todo-claims: no claims found under {args.root}/")
        print("  A TODO that measures something should record it as a claim, so the")
        print("  measurement is re-checked rather than trusted. See AGENTS.md.")
        return 0

    stale, malformed = [], []
    for path, lineno, claim in claims:
        rel = path.relative_to(ROOT).as_posix()
        try:
            ok = evaluate(claim)
            if not args.quiet:
                print(f"  ok    {rel}:{lineno}  {ok}")
        except Stale as exc:
            stale.append((rel, lineno, str(exc)))
        except Malformed as exc:
            malformed.append((rel, lineno, str(exc)))

    for rel, lineno, msg in malformed:
        print(f"MALFORMED {rel}:{lineno}  {msg}")
    for rel, lineno, msg in stale:
        print(f"STALE     {rel}:{lineno}  {msg}")

    print(
        f"\ntodo-claims: {len(claims)} claim(s) -- "
        f"{len(claims) - len(stale) - len(malformed)} hold, "
        f"{len(stale)} stale, {len(malformed)} malformed"
    )
    if malformed:
        return 2
    return 1 if stale else 0


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
    fixture.unlink()
    tmp.rmdir()

    total = len(cases) + 3
    print(f"todo-claims self-test: {total} cases, {failed} failed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
