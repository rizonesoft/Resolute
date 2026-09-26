#!/usr/bin/env python3
"""The fence's debt check. D00 T02 §10.

Every case tests/focus-audit.md names as fenced must end a fenced run either
green or skipped with a machine-readable SKIP line, which makes it debt the
stamp records as `Night-owed:`. A fenced case in neither list fails, like an
unaccounted control: it ran and failed, or it never ran at all.

    ctest --preset headful -V > build/headful.log
    python scripts/fence-debt.py --log build/headful.log            # the check
    python scripts/fence-debt.py --log build/headful.log --stamp    # the Night-owed: line
    python scripts/fence-debt.py --self-test

--cases narrows the check to the named cases (comma-separated), for a
section whose surface owns only some of the fenced rows.
"""

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
AUDIT = ROOT / "tests" / "focus-audit.md"

ROW = re.compile(r"^\|(?P<cells>.*)\|\s*$")
NAME = re.compile(r"`([^`]+)`")
RESULT = re.compile(r"Test\s+#\d+:\s+(?P<name>.+?)\s+\.+\s*(?:\*+)?(?P<state>Passed|Skipped|Failed|Timeout|Not Run)\b")
SKIP = re.compile(r'^(?:\d+:\s+)?SKIP "(?P<name>[^"]+)" (?P<reason>.+?)\s*$')


def fenced_cases(audit_text):
    """The case names on audit rows whose tier column says fenced."""
    cases = []
    for line in audit_text.splitlines():
        m = ROW.match(line.strip())
        if not m:
            continue
        cells = [c.strip() for c in m.group("cells").split("|")]
        if len(cells) < 4 or cells[3] != "fenced":
            continue
        for name in NAME.findall(cells[1]):
            if name not in cases:
                cases.append(name)
    return cases


def read_log(log_text):
    """(passed names, {skipped name: reason}, {other name: state})."""
    passed, skipped, other = set(), {}, {}
    for line in log_text.splitlines():
        s = SKIP.match(line.strip())
        if s:
            skipped.setdefault(s.group("name"), s.group("reason"))
            continue
        r = RESULT.search(line)
        if r:
            name, state = r.group("name"), r.group("state")
            if state == "Passed":
                passed.add(name)
            elif state != "Skipped":
                other[name] = state
    return passed, skipped, other


def judge(cases, log_text):
    """[(case, verdict, detail)] with verdict green, owed, or unaccounted."""
    passed, skipped, other = read_log(log_text)
    out = []
    for case in cases:
        if case in other:
            out.append((case, "unaccounted", other[case]))
        elif case in skipped:
            out.append((case, "owed", skipped[case]))
        elif case in passed:
            out.append((case, "green", ""))
        else:
            out.append((case, "unaccounted", "absent from the run"))
    return out


def stamp_line(verdicts):
    owed = [f"{c} ({d})" for c, v, d in verdicts if v == "owed"]
    return "Night-owed: " + ("; ".join(owed) if owed else "none")


def self_test():
    audit = "\n".join([
        "| Site | Cases | Disposition | Tier | Placement intent |",
        "| --- | --- | --- | --- | --- |",
        "| a | `Alpha case`, `Beta case` | fence | fenced | [place:primary] |",
        "| b | `Gamma case` | keep | default | none |",
        "| c | `Delta case` | fence | fenced | [place:dpi96] |",
    ])
    log = "\n".join([
        "1/3 Test #1: Alpha case .......................   Passed    0.20 sec",
        '2: SKIP "Beta case" headful: outside the quiet-hours window',
        "2/3 Test #2: Beta case ........................***Skipped   0.10 sec",
        "3/3 Test #3: Delta case .......................***Failed    0.10 sec",
    ])
    checks = []
    cases = fenced_cases(audit)
    checks.append(("fenced rows only", cases == ["Alpha case", "Beta case", "Delta case"]))
    v = {c: (verdict, d) for c, verdict, d in judge(cases, log)}
    checks.append(("a passed case is green", v["Alpha case"][0] == "green"))
    checks.append(("a SKIP line is owed with its reason", v["Beta case"] == ("owed", "headful: outside the quiet-hours window")))
    checks.append(("a failed case is unaccounted", v["Delta case"] == ("unaccounted", "Failed")))
    checks.append(("a case absent from the run is unaccounted",
                   judge(["Epsilon case"], log) == [("Epsilon case", "unaccounted", "absent from the run")]))
    checks.append(("a skip without its SKIP line is unaccounted",
                   judge(["Beta case"], log.replace('2: SKIP "Beta case"', "2: nothing")) ==
                   [("Beta case", "unaccounted", "absent from the run")]))
    checks.append(("the stamp line lists the debt",
                   stamp_line(judge(["Alpha case", "Beta case"], log)) ==
                   "Night-owed: Beta case (headful: outside the quiet-hours window)"))
    checks.append(("no debt says none", stamp_line(judge(["Alpha case"], log)) == "Night-owed: none"))
    bad = [n for n, ok in checks if not ok]
    for n in bad:
        print(f"fence-debt self-test FAIL: {n}")
    print(f"fence-debt self-test: {len(checks) - len(bad)}/{len(checks)} pass")
    return 1 if bad else 0


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--log", help="a fenced run's output (ctest --preset headful -V)")
    ap.add_argument("--audit", default=str(AUDIT))
    ap.add_argument("--cases", help="comma-separated case names to check instead of every fenced row")
    ap.add_argument("--stamp", action="store_true", help="print the Night-owed: line")
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args(argv)
    if args.self_test:
        return self_test()
    if not args.log:
        ap.error("--log is required")
    cases = fenced_cases(Path(args.audit).read_text(encoding="utf-8"))
    if args.cases:
        wanted = [c.strip() for c in args.cases.split(",") if c.strip()]
        missing = [c for c in wanted if c not in cases]
        if missing:
            print("fence-debt: not fenced in the audit table: " + "; ".join(missing))
            return 1
        cases = wanted
    verdicts = judge(cases, Path(args.log).read_text(encoding="utf-8", errors="replace"))
    if args.stamp:
        print(stamp_line(verdicts))
    for case, verdict, detail in verdicts:
        print(f"  {verdict:<11} {case}" + (f"  ({detail})" if detail else ""))
    unaccounted = [c for c, v, _ in verdicts if v == "unaccounted"]
    green = sum(1 for _, v, _ in verdicts if v == "green")
    owed = sum(1 for _, v, _ in verdicts if v == "owed")
    print(f"fence-debt: {len(verdicts)} fenced case(s): {green} green, {owed} night-owed, {len(unaccounted)} unaccounted")
    return 1 if unaccounted else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
