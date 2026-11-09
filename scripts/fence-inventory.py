#!/usr/bin/env python3
"""Reconcile the fenced inventory both ways. D00 T02 section 12.

Every test ctest discovers under the `headful` label must have a row in
tests/focus-audit.md with its placement, and every fenced row must name a
discovered test, so a new or renamed fenced case can neither escape the
placement declaration nor the debt accounting.

    ctest --preset debug -N -L headful > build/headful-list.txt
    python scripts/fence-inventory.py --list build/headful-list.txt
    python scripts/fence-inventory.py --self-test
"""

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
AUDIT = ROOT / "tests" / "focus-audit.md"

LISTED = re.compile(r"^\s*Test\s+#\d+:\s+(?P<name>.+?)\s*$")
ROW = re.compile(r"^\|(?P<cells>.*)\|\s*$")
NAME = re.compile(r"`([^`]+)`")


def discovered(list_text):
    out = []
    for line in list_text.splitlines():
        m = LISTED.match(line)
        if m and m.group("name") not in out:
            out.append(m.group("name"))
    return out


def fenced_rows(audit_text):
    out = []
    for line in audit_text.splitlines():
        m = ROW.match(line.strip())
        if not m:
            continue
        cells = [c.strip() for c in m.group("cells").split("|")]
        if len(cells) < 4 or cells[3] != "fenced":
            continue
        for name in NAME.findall(cells[1]):
            if name not in out:
                out.append(name)
    return out


def reconcile(found, rows):
    """(undeclared discovered tests, stale rows) naming each offender."""
    undeclared = [t for t in found if t not in rows]
    stale = [r for r in rows if r not in found]
    return undeclared, stale


def self_test():
    audit = "\n".join([
        "| Site | Cases | Disposition | Tier | Placement intent |",
        "| --- | --- | --- | --- | --- |",
        "| a | `Alpha case` | fence | fenced | [place:primary] |",
        "| b | `Beta case` | fence | fenced | [place:dpi96] |",
    ])
    listing = "\n".join([
        "Test project D:/build",
        "  Test #1: Alpha case",
        "  Test #2: Beta case",
        "Total Tests: 2",
    ])
    checks = []
    rows = fenced_rows(audit)
    found = discovered(listing)
    checks.append(("rows and discoveries parse", rows == ["Alpha case", "Beta case"] and found == rows))
    checks.append(("a clean inventory reconciles", reconcile(found, rows) == ([], [])))
    checks.append(("an undeclared fenced test is named",
                   reconcile(found + ["Gamma case"], rows) == (["Gamma case"], [])))
    checks.append(("a stale row is named",
                   reconcile(found, rows + ["Delta case"]) == ([], ["Delta case"])))
    comma = "Launcher capture, dark at 100 percent"
    checks.append(("a case name with a comma stays whole",
                   discovered("  Test #9: " + comma) == [comma]))
    bad = [n for n, ok in checks if not ok]
    for n in bad:
        print(f"fence-inventory self-test FAIL: {n}")
    print(f"fence-inventory self-test: {len(checks) - len(bad)}/{len(checks)} pass")
    return 1 if bad else 0


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--list", help="a `ctest -N -L headful` listing")
    ap.add_argument("--audit", default=str(AUDIT))
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args(argv)
    if args.self_test:
        return self_test()
    if not args.list:
        ap.error("--list is required")
    found = discovered(Path(args.list).read_text(encoding="utf-8", errors="replace"))
    rows = fenced_rows(Path(args.audit).read_text(encoding="utf-8"))
    undeclared, stale = reconcile(found, rows)
    for name in undeclared:
        print(f"fence-inventory: undeclared fenced test (no focus-audit row): {name}")
    for name in stale:
        print(f"fence-inventory: stale fenced row (not discovered): {name}")
    print(f"fence-inventory: {len(found)} discovered, {len(rows)} fenced row(s), "
          f"{len(undeclared)} undeclared, {len(stale)} stale")
    return 1 if (undeclared or stale) else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
