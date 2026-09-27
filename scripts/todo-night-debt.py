#!/usr/bin/env python3
"""Night debt, derived from the stamps. D00 T02 §11.

A section that ships outside the quiet-hours window stamps with the fenced
cases it could not run as a `Night-owed:` stamp line, bound to its reviewed
candidate. The nightly run collects them; each green collection is recorded
as a `Night-verified:` stamp line on the same section. What is still owed is
the owed cases minus the verified ones, read from the TODO files at query
time, so no side ledger can drift from the stamps:

    > **Night-owed:** candidate <sha> | "<case>" (<reason>); "<case>" (<reason>)
    > **Night-owed:** none
    > **Night-verified:** YYYY-MM-DD | candidate <sha> | run <id> | "<case>"; "<case>"

A verification clears only its own candidate's debt: a green run of a newer
commit proves that commit, not the one the section was reviewed at.

    python scripts/todo-graph.py query night-debt          # the table
    python scripts/todo-graph.py query night-debt --json   # for tools/nightly.ps1
    python scripts/todo-night-debt.py --self-test
"""

import datetime
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
AUDIT = ROOT / "tests" / "focus-audit.md"

HEADING = re.compile(r"^## (\d+)\. ")
TODO_NAME = re.compile(r"TODO-(\d+)-")
VERIFIED_DATE = re.compile(r"^> \*\*Verified:\*\* (\d{4}-\d{2}-\d{2})")
OWED = re.compile(r"^> \*\*Night-owed:\*\* (.*)$")
CLEARED = re.compile(r"^> \*\*Night-verified:\*\* (\d{4}-\d{2}-\d{2}) \| candidate ([0-9a-f]{7,40}) \| run (\S+) \| (.*)$")
OWED_BODY = re.compile(r"^candidate ([0-9a-f]{7,40}) \| (.*)$")
ENTRY = re.compile(r'"([^"]+)"(?:\s*\(([^)]*)\))?')
PLACE = re.compile(r"\[place:[^\]]+\]")


def placements(audit_text):
    """{case: placement tag} from the audit table's fenced rows."""
    out = {}
    for line in audit_text.splitlines():
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < 5 or cells[3] != "fenced":
            continue
        tag = PLACE.search(cells[4])
        for case in re.findall(r"`([^`]+)`", cells[1]):
            out[case] = tag.group(0) if tag else "(no placement declared)"
    return out


def section_ref(path, num):
    domain = path.parent.name.split("-")[0]
    m = TODO_NAME.search(path.name)
    return f"D{domain} T{m.group(1) if m else '??'} §{num}"


def debts_in(text, ref, today, place):
    """Open debt entries in one TODO file's text."""
    open_entries = []
    current, stamp_date, owed, cleared = None, None, [], set()

    def flush():
        for sha, case, reason in owed:
            if (sha, case) in cleared:
                continue
            age = (today - stamp_date).days if stamp_date else None
            open_entries.append({"section": ref(current), "case": case, "candidate": sha, "reason": reason,
                                 "place": place.get(case, "(not in the audit table)"), "age_nights": age})

    for line in text.splitlines():
        h = HEADING.match(line)
        if h:
            if current is not None:
                flush()
            current, stamp_date, owed, cleared = int(h.group(1)), None, [], set()
            continue
        if current is None:
            continue
        v = VERIFIED_DATE.match(line)
        if v:
            stamp_date = datetime.date.fromisoformat(v.group(1))
        o = OWED.match(line)
        if o:
            body = o.group(1).strip()
            m = OWED_BODY.match(body)
            if m:
                for case, reason in ENTRY.findall(m.group(2)):
                    owed.append((m.group(1), case, reason))
        c = CLEARED.match(line)
        if c:
            for case, _ in ENTRY.findall(c.group(4)):
                cleared.add((c.group(2), case))
    if current is not None:
        flush()
    return open_entries


def collect(root=ROOT, today=None):
    today = today or datetime.date.today()
    place = placements(AUDIT.read_text(encoding="utf-8")) if AUDIT.exists() else {}
    out = []
    for path in sorted((root / "todo").glob("*/TODO-*.md")):
        out += debts_in(path.read_text(encoding="utf-8"), lambda n, p=path: section_ref(p, n), today, place)
    return out


def render(entries):
    lines = [f"night-debt: {len(entries)} open"]
    for e in entries:
        age = "?" if e["age_nights"] is None else str(e["age_nights"])
        lines.append(f"  {e['section']}  \"{e['case']}\"  {e['place']}  candidate {e['candidate'][:8]}  "
                     f"age {age} night(s)  ({e['reason']})")
    return "\n".join(lines)


def self_test():
    audit = "\n".join([
        "| Site | Cases | Disposition | Tier | Placement intent |",
        "| --- | --- | --- | --- | --- |",
        "| x | `Launcher capture, dark at 150 percent` | fence | fenced | `[place:dpi144]`: why |",
        "| y | `Popup case` | fence | fenced | `[place:primary]`: why |",
    ])
    place = placements(audit)
    todo = "\n".join([
        "## 3. A Section",
        "> **Verified:** 2026-09-20 | §3 | shipped by day",
        '> **Night-owed:** candidate abcdef1234 | "Launcher capture, dark at 150 percent" (outside the window); "Popup case" (outside the window)',
        '> **Night-verified:** 2026-09-22 | candidate abcdef1234 | run 20260922-020500 | "Popup case"',
        '> **Night-verified:** 2026-09-23 | candidate 9999999999 | run 20260923-020500 | "Launcher capture, dark at 150 percent"',
        "## 4. Another",
        "> **Verified:** 2026-09-21 | §4 | Night-owed: none",
        "> **Night-owed:** none",
    ])
    got = debts_in(todo, lambda n: f"D00 T02 §{n}", datetime.date(2026, 9, 24), place)
    checks = [
        ("one case still owed", len(got) == 1),
        ("a verification of another candidate clears nothing",
         got and got[0]["case"] == "Launcher capture, dark at 150 percent" and got[0]["candidate"] == "abcdef1234"),
        ("its placement comes from the audit table", got and got[0]["place"] == "[place:dpi144]"),
        ("its age counts nights since the stamp", got and got[0]["age_nights"] == 4),
        ("a comma inside a case name stays in it", got and "," in got[0]["case"]),
        ("the reason is kept", got and got[0]["reason"] == "outside the window"),
        ("none owes nothing", all(e["section"] != "D00 T02 §4" for e in got)),
        ("the table names the entry", "D00 T02 §3" in render(got) and "age 4 night(s)" in render(got)),
    ]
    bad = [n for n, ok in checks if not ok]
    for n in bad:
        print(f"night-debt self-test FAIL: {n}")
    print(f"night-debt self-test: {len(checks) - len(bad)}/{len(checks)} pass")
    return 1 if bad else 0


def cli(argv):
    if "--self-test" in argv:
        return self_test()
    entries = collect()
    if "--json" in argv:
        print(json.dumps(entries, indent=1))
    else:
        print(render(entries))
    return 0


if __name__ == "__main__":
    sys.exit(cli(sys.argv[1:]))
