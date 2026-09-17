#!/usr/bin/env python3
"""Check that the conformance profile is a contract rather than prose.

`D07 T01 §1` owns `docs/conformance-profile.md`. That document says what a
finished tool is, and every other domain is measured against it.

THIS SCRIPT CHECKS THE DOCUMENT, NOT THE TOOLS. Evaluating real tools against
the profile is `D07 T01 §3`, and the two are deliberately separate: a profile
that is internally broken would make every tool result meaningless, and that
failure has to be visible on its own.

The section's original checkpoint asked that clauses be "stated in evaluable
terms" and that a mapping "is quoted". Both are satisfiable by asserting them,
which is how a document gets signed off without being checked. So every clause
of the checkpoint is now something this script decides:

  1. every clause row is complete, with a kind and a method from a closed set
  2. every clause names an owner section that RESOLVES to a real section
  3. every measured defect class is closed by at least one clause that exists
  4. no design value is restated here, because DESIGN.md is the one source

Exit codes:
  0  the profile holds
  1  the profile is broken, and every reason is named
  2  the profile file is missing or unreadable
"""

import re
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
PROFILE = REPO / "docs" / "conformance-profile.md"
GRAPH = REPO / "scripts" / "todo-graph.py"

# Closed sets. A value outside one of these arrives by decision, not by
# invention at the point of writing a row.
KINDS = {"universal", "repair"}
METHODS = {"exists", "absent", "search", "run", "readback", "capture", "count"}

# The measured AutoIt defect classes the profile is derived from. Eight, and
# the count is load-bearing: `D07 T01 §1` originally said seven, a figure that
# appeared nowhere in the source it pointed at.
EXPECTED_DEFECTS = 8

CLAUSE_ROW = re.compile(r"^\|\s*(C\d+)\s*\|")
DEFECT_ROW = re.compile(r"^\|\s*(D\d+)\s*\|")
SECTION_REF = re.compile(r"^D\d\d T\d\d §\d+$")
CLAUSE_CITE = re.compile(r"C\d+")

# A design value restated here would become a second source of truth that
# disagrees with DESIGN.md the first time either moves.
HEX_COLOUR = re.compile(r"#[0-9A-Fa-f]{6}\b")
PIXEL_SIZE = re.compile(r"\b\d+px\b")


def cells(line):
    """The cells of a markdown table row, without the outer pipes."""
    return [c.strip() for c in line.strip().strip("|").split("|")]


def resolves(ref, cache):
    """Does this section reference name a section that exists?

    `todo-graph.py resolve` is the front door for this everywhere else in the
    repository, so it is the front door here too rather than a second parser
    of the same tree. Exit 0 is open, 3 is already shipped, 4 is open with
    unmet dependencies: all three mean the section EXISTS, which is all a
    clause owner has to be. Exit 1 is no such section and 5 is a section that
    moved out of the tree, and a clause pointing at either has no address.
    """
    if ref in cache:
        return cache[ref]
    result = subprocess.run(
        [sys.executable, str(GRAPH), "resolve", ref],
        capture_output=True, text=True, cwd=str(REPO),
    )
    cache[ref] = result.returncode in (0, 3, 4)
    return cache[ref]


def main():
    if not PROFILE.exists():
        print(f"profile-check: {PROFILE.relative_to(REPO)} does not exist")
        return 2

    text = PROFILE.read_text(encoding="utf-8")
    lines = text.split("\n")
    problems = []

    clauses = {}
    defects = {}

    for number, line in enumerate(lines, 1):
        match = CLAUSE_ROW.match(line)
        if match:
            row = cells(line)
            cid = match.group(1)
            if cid in clauses:
                problems.append(f"line {number}: clause {cid} is declared twice")
                continue
            if len(row) != 6:
                problems.append(
                    f"line {number}: clause {cid} has {len(row)} cells, needs 6 "
                    "(ID, Kind, Method, Clause, Evidence, Owner)")
                continue
            _, kind, method, clause, evidence, owner = row
            if kind not in KINDS:
                problems.append(
                    f"line {number}: clause {cid} kind '{kind}' is not one of "
                    + ", ".join(sorted(KINDS)))
            if method not in METHODS:
                problems.append(
                    f"line {number}: clause {cid} is not stated in evaluable terms: "
                    f"method '{method}' is not one of " + ", ".join(sorted(METHODS)))
            if not clause:
                problems.append(f"line {number}: clause {cid} states nothing")
            if not evidence:
                problems.append(
                    f"line {number}: clause {cid} names no evidence, so nothing "
                    "could decide it")
            if not owner:
                problems.append(f"line {number}: clause {cid} names no owner section")
            elif not SECTION_REF.match(owner):
                problems.append(
                    f"line {number}: clause {cid} owner '{owner}' is not a section "
                    "reference of the form 'DNN TNN §N'")
            clauses[cid] = {"kind": kind, "owner": owner, "line": number}
            continue

        match = DEFECT_ROW.match(line)
        if match:
            row = cells(line)
            did = match.group(1)
            if len(row) != 3:
                problems.append(
                    f"line {number}: defect {did} has {len(row)} cells, needs 3 "
                    "(Defect, What was measured, Closed by)")
                continue
            _, measured, closed = row
            cited = CLAUSE_CITE.findall(closed)
            if not measured:
                problems.append(f"line {number}: defect {did} records no measurement")
            if not cited:
                problems.append(
                    f"line {number}: defect {did} is closed by no clause, so the "
                    "profile would not have caught it")
            defects[did] = {"cites": cited, "line": number}

    # Owners must RESOLVE. A reference in valid form pointing at a section that
    # does not exist reads as an address and is not one.
    cache = {}
    for cid, clause in sorted(clauses.items()):
        owner = clause["owner"]
        if SECTION_REF.match(owner) and not resolves(owner, cache):
            problems.append(
                f"line {clause['line']}: clause {cid} owner '{owner}' does not "
                "resolve to a section that exists")

    # Every clause a defect cites must exist, or the mapping is decorative.
    for did, defect in sorted(defects.items()):
        for cid in defect["cites"]:
            if cid not in clauses:
                problems.append(
                    f"line {defect['line']}: defect {did} cites clause {cid}, "
                    "which is not in the profile")

    if not clauses:
        problems.append("the profile contains no clauses at all")
    if len(defects) != EXPECTED_DEFECTS:
        problems.append(
            f"the profile maps {len(defects)} measured defect class(es), "
            f"expected {EXPECTED_DEFECTS}")

    for kind in sorted(KINDS):
        if not any(c["kind"] == kind for c in clauses.values()):
            problems.append(
                f"the profile has no '{kind}' clauses, so it does not "
                "distinguish the two tool kinds")

    # Design values belong to DESIGN.md. Checked over the whole document,
    # including the prose, because a value copied into a paragraph drifts
    # exactly as readily as one copied into a table.
    for number, line in enumerate(lines, 1):
        for found in HEX_COLOUR.findall(line) + PIXEL_SIZE.findall(line):
            problems.append(
                f"line {number}: '{found}' is a design value restated here. "
                "DESIGN.md is the one source; adopt it by reference.")

    if problems:
        print(f"profile-check: {len(problems)} problem(s) in "
              f"{PROFILE.relative_to(REPO)}")
        for problem in problems:
            print(f"  {problem}")
        return 1

    universal = sum(1 for c in clauses.values() if c["kind"] == "universal")
    repair = sum(1 for c in clauses.values() if c["kind"] == "repair")
    print(f"profile-check: {len(clauses)} clause(s) ok "
          f"-- {universal} universal, {repair} repair "
          f"-- {len(defects)} measured defect class(es), all closed "
          f"-- {len(cache)} owner section(s), all resolve")
    for did, defect in sorted(defects.items()):
        print(f"  {did} closed by {', '.join(defect['cites'])}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
