#!/usr/bin/env python3
"""todo-findings -- read across every review's findings and report what keeps recurring.

`review-todo-section` writes a findings file per section under `docs/reviews/`, so no
individual finding is lost. What was missing is the view *across* them: a defect class
can be found in five consecutive sections and nobody notices, because each review reads
only its own candidate.

That is what this closes. It reads every findings file, extracts each finding, and
reports counts by category and disposition. When a category reaches two, it prints the
question `D00 T04 §2` requires somebody to answer: what check would have caught this?

**The ledger is derived, never typed.** `docs/reviews/findings.md` is generated output
with a do-not-edit header. A hand-maintained ledger is a second home for a fact that
already has one, and it drifts exactly like a figure duplicated in prose.

A finding is a Markdown heading in a findings file:

    ### F1 -- four claims pointed into gitignored `samples/` -- consistency -- FIXED (self) [major]
    ### F2 -- the build is not reproducible -- reproducibility -- FILED to `D07 T01` (independent) [major]

Four fields separated by ` -- `: the number, the summary, the category, the disposition.
The disposition carries a trailing source marker, `(independent)` or `(self)`: who
raised the finding, not who fixed it. The heading closes with a severity marker,
`[critical]`, `[major]`, or `[minor]`: how bad it is, rated as raised. A heading
this cannot parse, or a finding whose source or severity is missing or outside
the closed set, is REPORTED, never skipped: skipping is how the split-claim
defect hid in the claims checker, where the count simply dropped and the total
still said everything held.

Exit codes: 0 everything parsed, 1 at least one heading could not be read.

Refusals carry stable diagnostic codes (D00 T04 §22, `scripts/todo-diag.py`):
usage is FIND-001 (exit 2), unreadable headings FIND-002, a stale ledger
FIND-003, incomplete transitions FIND-004, a refused write FIND-005
(exit 1 each). `--format json` renders refusals as one JSON array of
code/path/line/message objects; usage errors stay text, since argv did
not parse and no format was selected.
"""

from __future__ import annotations

import argparse
import io
import re
import subprocess
import sys
from collections import Counter, defaultdict
from pathlib import Path


def _load_diag():
    """The shared diagnostic registry, loaded by path so this script
    stays runnable however it is entered (CLI, importlib, self-test)."""
    import importlib.util
    mod = sys.modules.get("todo_diag")
    if mod is not None:
        return mod
    spec = importlib.util.spec_from_file_location(
        "todo_diag", Path(__file__).with_name("todo-diag.py"))
    mod = importlib.util.module_from_spec(spec)
    sys.modules["todo_diag"] = mod
    spec.loader.exec_module(mod)
    return mod


DIAG = _load_diag()

ROOT = Path(__file__).resolve().parent.parent
REVIEWS = ROOT / "docs" / "reviews"
LEDGER = REVIEWS / "findings.md"
TRANSITIONS = REVIEWS / "transitions.md"
NONFINAL = ("refuted", "withdrawn", "duplicate", "routed")

# D00-T03-s1.md -> ("D00 T03 §1")
FILE_RE = re.compile(r"^D(?P<dom>\d{2})-T(?P<todo>\d{2})-s(?P<sec>\d+)\.md$")
# `F<digits>` then a ` -- ` separator. The first version accepted any `###`
# heading starting with F, so `### Findings`, `### Frozen check` and
# `### Fixes applied` were all read as malformed findings. A check that fires on
# ordinary headings gets switched off, which is worse than not having it.
HEADING_RE = re.compile(r"^###\s+(?P<body>F\d+(?:\s*-\s*F?\d+)?\s+--\s+\S.*)$")

# The closed category set. Anything outside it is reported rather than bucketed,
# so a new category arrives by decision instead of by invention at the point of
# writing. Adding one is a commit to this list.
CATEGORIES = {
    "correctness":     "the code does the wrong thing",
    "consistency":     "disagrees with the rest of the suite, its naming, or its layout",
    "integration":     "a consumer, caller, or downstream artifact no longer holds",
    "record":          "the plan or the evidence misdescribes what happened",
    "adversarial":     "fails under hostile or unexpected input",
    "source-defect":   "a Win32 contract, registry layout, or other source read wrongly",
    "design":          "the rendered surface disagrees with the design contract",
    "performance":     "correct, and too slow or too costly to be used",
    "reproducibility": "the same input does not produce the same output",
    "test-coverage":   "correct, and nothing exercises it, so a regression would be silent",
}

# `test-coverage` added 2026-09-17 by decision, the same way `corrected` was.
# It is distinct from `correctness`: the code under it does the right thing
# today, and the finding is that NOTHING WOULD NOTICE if it stopped. D07 T01
# §1 produced the first one that had nowhere to go: a checker whose five
# failure modes had all been driven by hand, which missed a sixth because a
# hand-driven probe is bounded by what its author thought to try. Filing that
# as `correctness` would have said the checker was wrong, and it was not.

# A disposition is what was DONE about the finding, normalised to its first word.
#
# `corrected` added 2026-09-17 by decision, not by invention at the point of
# writing, which is what D00 T04 §2 requires. It is genuinely distinct from the
# others: a finding about the PLAN, corrected in the plan before any code was
# written. `fixed` means code changed, `filed` means another section owns it,
# `refuted` means the finding was wrong. Several sections have produced this
# kind and had nowhere to put it.
DISPOSITIONS = {"fixed", "filed", "refuted", "advisory", "routed", "cleared",
                "corrected", "withdrawn", "duplicate"}

# Outcome queries over dispositions. `refuted` is raised-then-disproven by
# evidence (not triage judgement); `withdrawn` is retracted by the raiser;
# `duplicate` is already tracked elsewhere; `routed` left this section (see
# filed_to); `non-defect` is the union that answers "raised but not a defect".
# A query with no matches prints zero rather than vanishing, so the report's
# shape is stable and a future first use shows up as a count, not a new line.
OUTCOMES = {
    "refuted":    "raised, then shown not-a-defect by evidence",
    "withdrawn":  "raised, then retracted by the raiser",
    "duplicate":  "the same defect already tracked elsewhere",
    "routed":     "handed to another section",
    "non-defect": "raised but not a defect: refuted or cleared",
}

# A range heading names several findings at once: `F1-F4`, `F1 - 4`. Each
# counts separately, because totals, splits, and rates are per finding and a
# range that counts once understates all three (D00 T04 §7).
RANGE_RE = re.compile(r"^F(?P<lo>\d+)\s*-\s*F?(?P<hi>\d+)$")


# `FILED to \`D07 T01 §2\`` -- the section a finding was handed to. D00 T04 §4
# reads these as coupling the dependency graph does not carry.
FILED_TO_RE = re.compile(r"\bFILED\s+to\s+`?(D\d{2}\s+T\d{2}\s+§\d+)`?", re.IGNORECASE)


# Who raised the finding. `independent` is anyone or anything other than the
# implementing session: the external reviewer, a panel round, the operator.
# `self` is the session's own work: its lenses, probes, validation runs, gates.
# A gate is self, not independent: the session runs the gate on its own work,
# the way it runs a probe. Anything outside the set is reported, never bucketed.
SOURCES = {
    "independent": "raised by someone other than the implementing session",
    "self":        "raised by the implementing session itself",
}

# How bad the finding is, rated as raised. The scale mirrors the plan-review
# ledger's, so one vocabulary covers both: critical invalidates safety, data
# integrity, or the stamp; major is wrong behavior; minor is polish. Severity
# rates surviving contribution, not alleged impact: findings that were never
# defects (refuted, withdrawn, duplicate) carry minor, because the defect
# either was not one or, for duplicates, counts at its home row. Cleared
# rates as raised like fixed: the disposition marks a resolved question, and
# the question can be major. Anything outside the set is reported, never
# bucketed, like every other marker on the heading. The parser enforces the
# never-defect minor rule below: anything but minor fails the gate by name.
SEVERITIES = {
    "critical": "invalidates safety, data integrity, or the stamp",
    "major":    "wrong behavior in code, plan, or record",
    "minor":    "polish or wording, or no surviving defect",
}

# The trailing source marker on the disposition: `FIXED (self)`,
# `FILED to D07 T01 (independent)`. Only the trailing parenthetical counts;
# a parenthetical anywhere earlier is prose and is ignored.
SOURCE_RE = re.compile(r"\(([^()]*)\)\s*$")

# The severity marker closes the heading: `FIXED (self) [major]`. Trailing
# only, like the source: a bracket anywhere earlier is prose. Stripped before
# the source is read, so the source rule never sees it.
SEVERITY_RE = re.compile(r"\[(?P<sev>[^\[\]]*)\]\s*$")


class Finding:
    __slots__ = ("ref", "path", "line", "number", "summary", "category", "disposition",
                 "filed_to", "source", "severity")

    def __init__(self, ref, path, line, number, summary, category, disposition,
                 filed_to=None, source=None, severity=None):
        self.ref = ref
        self.path = path
        self.line = line
        self.number = number
        self.summary = summary
        self.category = category
        self.disposition = disposition
        self.filed_to = filed_to
        self.source = source
        self.severity = severity


def _ref_for(name: str) -> str | None:
    m = FILE_RE.match(name)
    if not m:
        return None
    return f"D{m.group('dom')} T{m.group('todo')} §{m.group('sec')}"


def _normalise_disposition(raw: str) -> str | None:
    """First word, lowercased, stripped of markup. 'FILED to `D07 T01`' -> 'filed'."""
    word = re.sub(r"[^A-Za-z-]", " ", raw).strip().split(" ")[0].lower()
    if word in DISPOSITIONS:
        return word
    # "ROOT CAUSE CLEARED, residue FILED" and similar: take the first known word.
    for token in re.sub(r"[^A-Za-z-]", " ", raw).lower().split():
        if token in DISPOSITIONS:
            return token
    return None


def parse_file(path: Path) -> tuple[list[Finding], list[tuple[Path, int, str]]]:
    ref = _ref_for(path.name)
    if ref is None:
        return [], []
    findings: list[Finding] = []
    bad: list[tuple[Path, int, str]] = []
    for lineno, line in enumerate(
        io.open(path, encoding="utf-8", errors="replace").read().splitlines(), 1
    ):
        m = HEADING_RE.match(line)
        if not m:
            continue
        parts = [p.strip() for p in m.group("body").split(" -- ")]
        if len(parts) < 4:
            bad.append((path, lineno, f"needs 'F<n> -- summary -- category -- disposition (source) [severity]', got {len(parts)} field(s)"))
            continue
        number, summary, category, disposition = parts[0], parts[1], parts[2], " -- ".join(parts[3:])
        cat = category.strip("`*_ ").lower()
        if cat not in CATEGORIES:
            bad.append((path, lineno, f"unknown category {category!r}; add it to CATEGORIES by decision or fix the heading"))
            continue
        disp = _normalise_disposition(disposition)
        if disp is None:
            bad.append((path, lineno, f"unreadable disposition {disposition!r}; expected one of {sorted(DISPOSITIONS)}"))
            continue
        vm = SEVERITY_RE.search(disposition)
        if vm is None:
            bad.append((path, lineno, f"no severity marker; end the heading with [critical], [major], or [minor]"))
            continue
        severity = vm.group("sev").strip().lower()
        if severity not in SEVERITIES:
            bad.append((path, lineno, f"unknown severity {vm.group('sev')!r}; expected one of {sorted(SEVERITIES)}"))
            continue
        if disp in ("refuted", "withdrawn", "duplicate") and severity != "minor":
            bad.append((path, lineno, f"never-defect severity rule: {number} is {disp} "
                        f"but carries {severity}; refuted, withdrawn, and duplicate "
                        f"findings are minor"))
            continue
        unmarked = disposition[:vm.start()].rstrip()
        sm = SOURCE_RE.search(unmarked)
        if sm is None:
            bad.append((path, lineno, f"no source marker; end the disposition with (independent) or (self)"))
            continue
        source = sm.group(1).strip().lower()
        if source not in SOURCES:
            bad.append((path, lineno, f"unknown source {sm.group(1)!r}; expected one of {sorted(SOURCES)}"))
            continue
        target = FILED_TO_RE.search(unmarked)
        rm = RANGE_RE.match(number)
        if rm is not None:
            lo, hi = int(rm.group("lo")), int(rm.group("hi"))
            if lo >= hi:
                bad.append((path, lineno, f"range {number} runs backward; write the lower number first"))
                continue
            numbers = [f"F{n}" for n in range(lo, hi + 1)]
        else:
            numbers = [number]
        for num in numbers:
            findings.append(Finding(ref, path, lineno, num, summary, cat, disp,
                                    target.group(1) if target else None, source,
                                    severity))
    return findings, bad


def collect() -> tuple[list[Finding], list[tuple[Path, int, str]]]:
    findings: list[Finding] = []
    bad: list[tuple[Path, int, str]] = []
    if not REVIEWS.is_dir():
        return findings, bad
    for path in sorted(REVIEWS.rglob("*.md")):
        f, b = parse_file(path)
        findings.extend(f)
        bad.extend(b)
    return findings, bad


TRANSITION_RE = re.compile(r"^transition:\s*(?P<ref>D\d{2}-T\d{2}-S\d+-F\d+)\s*$")
TRANSITION_FIELD_RE = re.compile(r"^(?P<key>date|from|to|why|evidence|as-of):\s*(?P<value>.*)$")
TRANSITION_DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
TRANSITION_SHA_RE = re.compile(r"^[0-9a-f]{7,40}$")
_TRANSITION_FROM_OK = frozenset(set(DISPOSITIONS) | {"raised"})
_COMPACT_RE = re.compile(r"^D(?P<dom>\d{2}) T(?P<todo>\d{2}) §(?P<sec>\d+)$")


def _compact_ref(display: str, number: str) -> str | None:
    m = _COMPACT_RE.match(display)
    if not m:
        return None
    return f"D{m.group('dom')}-T{m.group('todo')}-S{m.group('sec')}-{number}"


def _transition_commit_resolves(sha: str) -> bool:
    """The as-of binding resolves to a commit in this repository. Needs git."""
    try:
        hit = subprocess.run(["git", "cat-file", "-t", sha], cwd=ROOT,
                             capture_output=True, text=True, timeout=30)
    except (OSError, subprocess.SubprocessError):
        return False
    return hit.returncode == 0 and hit.stdout.strip() == "commit"


def check_transitions(findings: list[Finding], path: Path = TRANSITIONS) -> list[tuple[int, str]]:
    """Every non-final ledger row keeps its when, why, and evidence.

    Returns (lineno, message) problems, unlocated as lineno 0; the
    caller adds the path and the FIND-004 code at emission.

    Returns problems (empty means complete): each block needs its
    six fields, must name a live row, and its `to` must agree with
    the row's disposition; the `as-of` binds the commit whose tree
    holds the quoted record and must resolve; each non-final row
    needs exactly one block.
    """
    problems: list[tuple[int, str]] = []
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as exc:
        return [(0, f"cannot read transitions: {exc}")]
    blocks: list[tuple[int, str, dict[str, str]]] = []
    current: tuple[int, str, dict[str, str]] | None = None
    for lineno, raw in enumerate(text.splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        m = TRANSITION_RE.match(line)
        if m:
            if current is not None:
                blocks.append(current)
            current = (lineno, m.group("ref"), {})
            continue
        if current is None:
            continue  # header preamble before the first block
        f = TRANSITION_FIELD_RE.match(line)
        if f is None:
            problems.append((lineno, f"not a transition field: {line[:60]!r}"))
            continue
        key, value = f.group("key"), f.group("value").strip()
        if key in current[2]:
            problems.append((lineno, f"duplicate field {key!r}"))
            continue
        if not value:
            problems.append((lineno, f"empty field {key!r}, quoted not blank"))
            continue
        current[2][key] = value
    if current is not None:
        blocks.append(current)
    by_ref: dict[str, Finding] = {}
    for f in findings:
        compact = _compact_ref(f.ref, f.number)
        if compact is not None:
            by_ref[compact] = f
    seen: dict[str, int] = {}
    for lineno, ref, fields in blocks:
        for need in ("date", "from", "to", "why", "evidence", "as-of"):
            if need not in fields:
                problems.append((lineno, f"{ref} misses {need}"))
        if "date" in fields and not TRANSITION_DATE_RE.match(fields["date"]):
            problems.append((lineno, f"{ref} date is not YYYY-MM-DD"))
        if "as-of" in fields:
            if not TRANSITION_SHA_RE.match(fields["as-of"]):
                problems.append((lineno, f"{ref} binds as-of "
                                f"{fields['as-of']!r}, not a sha"))
            elif not _transition_commit_resolves(fields["as-of"]):
                problems.append((lineno, f"{ref} binds as-of {fields['as-of']}, "
                                f"which resolves to no commit"))
        if "from" in fields and fields["from"] not in _TRANSITION_FROM_OK:
            problems.append((lineno, f"{ref} moves from {fields['from']!r}, unknown"))
        if "to" in fields and fields["to"] not in NONFINAL:
            problems.append((lineno, f"{ref} moves to {fields['to']!r}, "
                            f"transitions track {', '.join(NONFINAL)}"))
        if ref in seen:
            problems.append((lineno, f"{ref} already has a block at line {seen[ref]}"))
        else:
            seen[ref] = lineno
        if ref not in by_ref:
            problems.append((lineno, f"{ref} names no live finding"))
            continue
        if "to" in fields and by_ref[ref].disposition != fields["to"]:
            problems.append((lineno, f"{ref} says {fields['to']} but "
                            f"the row reads {by_ref[ref].disposition}"))
    for ref in sorted(r for r, f in by_ref.items() if f.disposition in NONFINAL):
        if ref not in seen:
            problems.append((0, f"{ref} reads {by_ref[ref].disposition} but keeps no transition"))
    return problems


REPEAT_QUESTION = (
    "seen {n} times: what check would have caught this? Record the answer in "
    "D00 T04 §2, even when the answer is that no cheap check exists."
)


def _rel(path: Path) -> str:
    try:
        return path.relative_to(ROOT).as_posix()
    except ValueError:
        return path.as_posix()   # a self-test fixture outside the repository


def _bad_items(bad: list[tuple[Path, int, str]]) -> list[dict]:
    """The unreadable headings as structured refusals (FIND-002)."""
    return [DIAG.refusal("FIND-002", _rel(path), lineno, why)
            for path, lineno, why in bad]


def _print_bad(bad: list[tuple[Path, int, str]]) -> None:
    if not bad:
        return
    print("  headings this could not read, reported rather than skipped:")
    for path, lineno, why in bad:
        print(f"    {DIAG.emit('FIND-002', _rel(path), lineno, why)}")
    print()


def _transition_items(tproblems: list[tuple[int, str]],
                      path: Path) -> list[dict]:
    """Transition problems as structured refusals (FIND-004)."""
    return [DIAG.refusal("FIND-004", _rel(path), lineno or None, p)
            for lineno, p in tproblems]


def _print_transitions(tproblems: list[tuple[int, str]], path: Path) -> None:
    print("  transitions incomplete, one line each:")
    for lineno, p in tproblems:
        print(f"    {DIAG.emit('FIND-004', _rel(path), lineno or None, p)}")
    print()


def report(findings: list[Finding], bad: list[tuple[Path, int, str]],
           json_mode: bool = False) -> int:
    by_cat = Counter(f.category for f in findings)
    by_disp = Counter(f.disposition for f in findings)
    by_section = defaultdict(list)
    for f in findings:
        by_section[f.ref].append(f)

    print(f"todo-findings: {len(findings)} finding(s) across {len(by_section)} section(s)\n")

    print("  by category")
    for cat, n in by_cat.most_common():
        flag = "  <-- repeat" if n >= 2 else ""
        print(f"    {cat:16} {n}{flag}")

    print("\n  by disposition")
    for disp, n in by_disp.most_common():
        print(f"    {disp:16} {n}")

    by_source = Counter(f.source for f in findings)
    print("\n  by source")
    for src, n in by_source.most_common():
        print(f"    {src:16} {n}")

    by_sev = Counter(f.severity for f in findings)
    print("\n  by severity")
    for sev in ("critical", "major", "minor"):
        print(f"    {sev:16} {by_sev[sev]}")

    print("\n  by outcome")
    for name in ("refuted", "withdrawn", "duplicate", "routed", "non-defect"):
        n = by_disp[name] if name != "non-defect" else by_disp["refuted"] + by_disp["cleared"]
        print(f"    {name:16} {n}")

    repeats = [(c, n) for c, n in by_cat.most_common() if n >= 2]
    if repeats:
        print("\n  repeats, which D00 T04 §2 says must become a question")
        for cat, n in repeats:
            print(f"    {cat}: " + REPEAT_QUESTION.format(n=n))

    tproblems = check_transitions(findings, TRANSITIONS)
    if json_mode:
        items = _bad_items(bad) + _transition_items(tproblems, TRANSITIONS)
        if items:
            print(DIAG.dumps(items), end="")
    else:
        if bad:
            print()
            _print_bad(bad)
        if tproblems:
            _print_transitions(tproblems, TRANSITIONS)

    print(f"todo-findings: {len(findings)} parsed, {len(bad)} unreadable, "
          f"{len(tproblems)} transition problem(s)")
    return 1 if (bad or tproblems) else 0


def render_ledger(findings: list[Finding]) -> str:
    by_cat = Counter(f.category for f in findings)
    by_sev = Counter(f.severity for f in findings)
    by_section = defaultdict(list)
    for f in findings:
        by_section[f.ref].append(f)

    out: list[str] = []
    out.append("# Review findings, all sections")
    out.append("")
    out.append("<!-- GENERATED by scripts/todo-findings.py --write. Do not edit by hand. -->")
    out.append("")
    out.append(
        "Derived from the per-section findings files under `docs/reviews/`, which stay "
        "authoritative. This file is a view, not a record: editing it changes nothing and "
        "is overwritten on the next run. `D00 T04 §2` owns it."
    )
    out.append("")
    out.append(f"**{len(findings)} findings across {len(by_section)} sections.**")
    out.append("")
    out.append("## By category")
    out.append("")
    out.append("| Category | Count | What it means |")
    out.append("| --- | ---: | --- |")
    for cat, n in by_cat.most_common():
        out.append(f"| `{cat}` | {n} | {CATEGORIES[cat]} |")
    out.append("")
    out.append("## By severity")
    out.append("")
    out.append("| Severity | Count | What it means |")
    out.append("| --- | ---: | --- |")
    for sev in ("critical", "major", "minor"):
        out.append(f"| `{sev}` | {by_sev[sev]} | {SEVERITIES[sev]} |")
    out.append("")
    out.append("## Every finding")
    out.append("")
    out.append("| Section | # | Severity | Category | Disposition | Source | Summary |")
    out.append("| --- | --- | --- | --- | --- | --- | --- |")
    for ref in sorted(by_section):
        for f in by_section[ref]:
            out.append(f"| `{ref}` | {f.number} | {f.severity} | `{f.category}` | {f.disposition} | {f.source} | {f.summary} |")
    out.append("")
    return "\n".join(out)


def _self_test() -> int:
    import tempfile
    tmp = Path(tempfile.mkdtemp(prefix="todo-findings-"))
    f = tmp / "D00-T99-s1.md"
    f.write_text(
        "# R\n\n"
        "### F1 -- a thing went wrong -- consistency -- FIXED (self) [major]\n\n"
        "### F2 -- another thing -- consistency -- FILED to `D01 T01 §1` (independent) [major]\n\n"
        "### F3 -- a third -- performance -- FIXED [major]\n\n"
        "### F4 -- no category here -- FIXED (self)\n\n"
        "### F5 -- bad category -- nonsense -- FIXED (self)\n\n"
        "### F6 -- bad source -- record -- FIXED (codex) [major]\n\n"
        "### Not a finding heading\n",
        encoding="utf-8",
    )
    failed = 0
    findings, bad = parse_file(f)

    if len(findings) != 2:
        print(f"  FAIL  expected 2 parsed findings, got {len(findings)}")
        failed += 1
    if len(bad) != 4:
        print(f"  FAIL  expected 4 unreadable headings, got {len(bad)}")
        failed += 1
    if not any("no source marker" in w for _, _, w in bad):
        print("  FAIL  a missing source was not reported")
        failed += 1
    if not any("unknown source" in w for _, _, w in bad):
        print("  FAIL  an unknown source was not reported")
        failed += 1
    if [f.source for f in findings] != ["self", "independent"]:
        print(f"  FAIL  sources parsed wrong: {[f.source for f in findings]}")
        failed += 1
    # Range headings expand; a backward range reports instead
    (tmp / "D00-T10-s1.md").write_text(
        "### F1-F3 -- three at once -- record -- FIXED (self) [minor]\n\n"
        "### F5-F2 -- backward -- record -- FIXED (self) [minor]\n",
        encoding="utf-8",
    )
    rf, rb = parse_file(tmp / "D00-T10-s1.md")
    if [f.number for f in rf] != ["F1", "F2", "F3"]:
        print(f"  FAIL  range expanded wrong: {[f.number for f in rf]}")
        failed += 1
    if not any("runs backward" in w for _, _, w in rb):
        print("  FAIL  a backward range was not reported")
        failed += 1
    # New outcome dispositions parse; the queries derive from them
    (tmp / "D00-T10-s2.md").write_text(
        "### F1 -- retracted -- record -- WITHDRAWN (self) [minor]\n\n"
        "### F2 -- twice seen -- record -- DUPLICATE (independent) [minor]\n",
        encoding="utf-8",
    )
    of, ob = parse_file(tmp / "D00-T10-s2.md")
    if [f.disposition for f in of] != ["withdrawn", "duplicate"] or ob:
        print("  FAIL  outcome dispositions did not parse clean")
        failed += 1
    both = findings + rf + of
    by = Counter(f.disposition for f in both)
    if by["withdrawn"] != 1 or by["duplicate"] != 1 or by["refuted"] + by["cleared"] != 0:
        print("  FAIL  outcome counts wrong")
        failed += 1
    if findings and findings[0].ref != "D00 T99 §1":
        print(f"  FAIL  ref from filename wrong: {findings[0].ref}")
        failed += 1
    if findings and findings[1].disposition != "filed":
        print(f"  FAIL  disposition normalisation wrong: {findings[1].disposition}")
        failed += 1

    cats = Counter(x.category for x in findings)
    if cats["consistency"] != 2:
        print(f"  FAIL  repeat detection: consistency should be 2, got {cats['consistency']}")
        failed += 1

    # A non-findings file in docs/reviews must be ignored, not reported as broken.
    other = tmp / "2026-09-16-plan-audit.md"
    other.write_text("### F1 -- looks like a finding but is not in a section file\n", encoding="utf-8")
    of, ob = parse_file(other)
    if of or ob:
        print("  FAIL  a non-section review file was parsed")
        failed += 1

    # A compound disposition still resolves.
    if _normalise_disposition("ROOT CAUSE CLEARED, residue FILED to `D00 T01 §2`") != "cleared":
        print("  FAIL  compound disposition not resolved")
        failed += 1

    # The ledger is a pure function of its input: same findings, same bytes.
    if render_ledger(findings) != render_ledger(findings):
        print("  FAIL  ledger rendering is not deterministic")
        failed += 1

    # Ordinary headings that begin with F must be ignored, not reported as
    # malformed findings. A check that fires on `### Findings` gets switched off.
    noise = tmp / "D00-T98-s1.md"
    NL = chr(10)
    noise.write_text(NL.join([
        "## Findings", "", "### Findings", "", "### Frozen check", "",
        "### Fixes applied", "", "### F1 -- real -- record -- FIXED (self) [major]", "",
    ]), encoding="utf-8")
    nf, nb = parse_file(noise)
    if len(nf) != 1 or nb:
        print(f"  FAIL  heading noise: parsed {len(nf)}, bad {len(nb)}, want 1 and 0")
        failed += 1
    noise.unlink()


    # The independent review of 43a299a: --write must not publish a ledger it
    # knows is incomplete, and every mode must name the heading it could not read.
    import contextlib
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        _print_bad([(f, 7, "unknown category")])
    if "D00-T99-s1.md:7" not in buf.getvalue():
        print("  FAIL  _print_bad did not name the file and line")
        failed += 1
    buf2 = io.StringIO()
    with contextlib.redirect_stdout(buf2):
        _print_bad([])
    if buf2.getvalue():
        print("  FAIL  _print_bad printed something with nothing to report")
        failed += 1

    # Transitions: every non-final row keeps its when, why, and evidence.
    tfind = [
        Finding("D00 T04 §9", f, 1, "F1", "retracted", "record", "withdrawn",
                source="self", severity="minor"),
        Finding("D00 T04 §9", f, 2, "F2", "stays fixed", "record", "fixed",
                source="self", severity="major"),
    ]
    tpath = tmp / "transitions.md"
    tpath.write_text(
        "# fixture\n\n"
        "transition: D00-T04-S9-F1\n"
        "date: 2026-09-19\n"
        "from: raised\n"
        "to: withdrawn\n"
        "why: the raiser retracted it\n"
        "evidence: D00-T04-s9.md round 3\n"
        "as-of: 0a24c03\n",
        encoding="utf-8",
    )
    if check_transitions(tfind, tpath):
        print(f"  FAIL  a complete transition block was not accepted: "
              f"{check_transitions(tfind, tpath)}")
        failed += 1
    # A block missing a field, naming nothing live, and disagreeing with the row.
    tpath.write_text(
        "transition: D00-T04-S9-F1\n"
        "date: 2026-09-19\n"
        "from: raised\n"
        "to: duplicate\n"
        "evidence: x\n"
        "as-of: 0a24c03\n"
        "\n"
        "transition: D00-T04-S9-F9\n"
        "date: 2026-09-19\n"
        "from: raised\n"
        "to: withdrawn\n"
        "why: ghost\n"
        "evidence: x\n"
        "as-of: 0a24c03\n",
        encoding="utf-8",
    )
    tp = check_transitions(tfind, tpath)
    if not any("misses why" in p for _, p in tp):
        print("  FAIL  a transition block missing `why` was not reported")
        failed += 1
    if not any("names no live finding" in p for _, p in tp):
        print("  FAIL  a transition naming no live row was not reported")
        failed += 1
    if not any("says duplicate but the row reads withdrawn" in p for _, p in tp):
        print("  FAIL  a transition disagreeing with its row was not reported")
        failed += 1
    # A non-final row with no block, a duplicate block, a bad date, a `to`
    # outside the tracked set.
    tpath.write_text(
        "transition: D00-T04-S9-F1\n"
        "date: 19-09-2026\n"
        "from: raised\n"
        "to: withdrawn\n"
        "why: x\n"
        "evidence: y\n"
        "as-of: 0a24c03\n"
        "\n"
        "transition: D00-T04-S9-F1\n"
        "date: 2026-09-19\n"
        "from: raised\n"
        "to: withdrawn\n"
        "why: x\n"
        "evidence: y\n"
        "as-of: 0a24c03\n"
        "\n"
        "transition: D00-T04-S9-F2\n"
        "date: 2026-09-19\n"
        "from: raised\n"
        "to: fixed\n"
        "why: x\n"
        "evidence: y\n"
        "as-of: 0a24c03\n",
        encoding="utf-8",
    )
    tp2 = check_transitions(tfind, tpath)
    if not any("date is not YYYY-MM-DD" in p for _, p in tp2):
        print("  FAIL  a transition with a bad date was not reported")
        failed += 1
    if not any("already has a block" in p for _, p in tp2):
        print("  FAIL  a duplicate transition block was not reported")
        failed += 1
    if not any("moves to 'fixed'" in p for _, p in tp2):
        print("  FAIL  a transition to a final disposition was not reported")
        failed += 1
    # §15: the as-of binds a resolving commit, and a dead binding fails.
    tpath.write_text(
        "transition: D00-T04-S9-F1\n"
        "date: 2026-09-19\n"
        "from: raised\n"
        "to: withdrawn\n"
        "why: the raiser retracted it\n"
        "evidence: D00-T04-s9.md round 3\n"
        "as-of: 0000000\n",
        encoding="utf-8",
    )
    if not any("resolves to no commit" in p for _, p in check_transitions(tfind, tpath)):
        print("  FAIL  a transition binding a dead commit was not reported")
        failed += 1
    tpath.write_text(
        "transition: D00-T04-S9-F1\n"
        "date: 2026-09-19\n"
        "from: raised\n"
        "to: withdrawn\n"
        "why: the raiser retracted it\n"
        "evidence: D00-T04-s9.md round 3\n"
        "as-of: yesterday\n",
        encoding="utf-8",
    )
    if not any("not a sha" in p for _, p in check_transitions(tfind, tpath)):
        print("  FAIL  a transition binding a non-sha was not reported")
        failed += 1
    # §16: a duplicate block reports even when the ref is dead.
    tpath.write_text(
        "transition: D00-T04-S9-F9\n"
        "date: 2026-09-19\n"
        "from: raised\n"
        "to: withdrawn\n"
        "why: ghost\n"
        "evidence: x\n"
        "as-of: 0a24c03\n"
        "\n"
        "transition: D00-T04-S9-F9\n"
        "date: 2026-09-19\n"
        "from: raised\n"
        "to: withdrawn\n"
        "why: ghost again\n"
        "evidence: x\n"
        "as-of: 0a24c03\n",
        encoding="utf-8",
    )
    dup_problems = [p for _, p in check_transitions(tfind, tpath) if "S9-F9" in p]
    if dup_problems != [
        "D00-T04-S9-F9 names no live finding",
        "D00-T04-S9-F9 already has a block at line 1",
        "D00-T04-S9-F9 names no live finding",
    ]:
        print(f"  FAIL  the dead-ref duplicate refusal shape drifted: {dup_problems}")
        failed += 1
    # §16 plan review: two distinct dead refs draw two dead messages, never a duplicate.
    tpath.write_text(
        "transition: D00-T04-S9-F9\n"
        "date: 2026-09-19\n"
        "from: raised\n"
        "to: withdrawn\n"
        "why: ghost\n"
        "evidence: x\n"
        "as-of: 0a24c03\n"
        "\n"
        "transition: D00-T04-S9-F8\n"
        "date: 2026-09-19\n"
        "from: raised\n"
        "to: withdrawn\n"
        "why: another ghost\n"
        "evidence: x\n"
        "as-of: 0a24c03\n",
        encoding="utf-8",
    )
    distinct = check_transitions(tfind, tpath)
    if [p for _, p in distinct if "names no live finding" in p] != [
        "D00-T04-S9-F9 names no live finding",
        "D00-T04-S9-F8 names no live finding",
    ] or any("already has a block" in p for _, p in distinct):
        print(f"  FAIL  distinct dead refs misfired: {distinct}")
        failed += 1
    # §16 plan review: a live ref duplicated draws only the duplicate message.
    tpath.write_text(
        "transition: D00-T04-S9-F1\n"
        "date: 2026-09-19\n"
        "from: raised\n"
        "to: withdrawn\n"
        "why: the raiser retracted it\n"
        "evidence: x\n"
        "as-of: 0a24c03\n"
        "\n"
        "transition: D00-T04-S9-F1\n"
        "date: 2026-09-19\n"
        "from: raised\n"
        "to: withdrawn\n"
        "why: still retracted\n"
        "evidence: x\n"
        "as-of: 0a24c03\n",
        encoding="utf-8",
    )
    if check_transitions(tfind, tpath) != [
        (9, "D00-T04-S9-F1 already has a block at line 1"),
    ]:
        print(f"  FAIL  the live duplicate refusal shape drifted: {check_transitions(tfind, tpath)}")
        failed += 1
    # §16: a never-defect carrying anything but minor fails by name.
    # All six bad cells fire (refuted/withdrawn/duplicate by major/critical).
    fpath = tmp / "D00-T04-s99.md"
    fpath.write_text(
        "### F1 -- x -- record -- REFUTED (self) [critical]\n"
        "### F2 -- x -- record -- REFUTED (self) [major]\n"
        "### F3 -- x -- record -- WITHDRAWN (self) [critical]\n"
        "### F4 -- x -- record -- WITHDRAWN (self) [major]\n"
        "### F5 -- x -- record -- DUPLICATE (self) [critical]\n"
        "### F6 -- x -- record -- DUPLICATE (self) [major]\n",
        encoding="utf-8",
    )
    _f, _b = parse_file(fpath)
    ruled = [m for _, _, m in _b if "never-defect severity rule" in m]
    if len(ruled) != 6 or _f:
        print(f"  FAIL  not all six bad never-defect cells fired: {_b} {_f}")
        failed += 1
    fpath.write_text(
        "### F1 -- x -- record -- REFUTED (self) [minor]\n"
        "### F2 -- x -- record -- WITHDRAWN (self) [minor]\n"
        "### F3 -- x -- record -- DUPLICATE (self) [minor]\n",
        encoding="utf-8",
    )
    _f, _b = parse_file(fpath)
    if _b or len(_f) != 3 or any(f.severity != "minor" for f in _f):
        print(f"  FAIL  minor never-defects were not accepted: {_b} {_f}")
        failed += 1
    tpath.write_text("# nothing tracked yet\n", encoding="utf-8")
    if not any("keeps no transition" in p for _, p in check_transitions(tfind, tpath)):
        print("  FAIL  a non-final row without a block was not reported")
        failed += 1
    tpath.unlink()

    # Severity closes the heading: missing and unknown both report, and a
    # bracket earlier in the line is prose, not the marker.
    (tmp / "D00-T10-s3.md").write_text(
        "### F1 -- unmarked -- record -- FIXED (self)\n\n"
        "### F2 -- odd mark -- record -- FIXED (self) [trivial]\n\n"
        "### F3 -- [bracketed] prose -- record -- FIXED (self) [minor]\n",
        encoding="utf-8",
    )
    sf, sb = parse_file(tmp / "D00-T10-s3.md")
    if not any("no severity marker" in w for _, _, w in sb):
        print("  FAIL  a missing severity was not reported")
        failed += 1
    if not any("unknown severity 'trivial'" in w for _, _, w in sb):
        print("  FAIL  an unknown severity was not reported")
        failed += 1
    if [x.severity for x in sf] != ["minor"]:
        print(f"  FAIL  severity parsed wrong: {[x.severity for x in sf]}")
        failed += 1

    # D00 T04 §22: the FIND registry is closed (codes plus exits), and an
    # unlisted code fails closed instead of printing.
    find_codes = {c: DIAG.CODES[c] for c in DIAG.CODES if c.startswith("FIND-")}
    if find_codes != {"FIND-001": (2, "usage: bad flags or arguments"),
                      "FIND-002": (1, "unreadable finding headings"),
                      "FIND-003": (1, "stale findings ledger"),
                      "FIND-004": (1, "incomplete outcome transitions"),
                      "FIND-005": (1, "write refused: ledger would drop headings")}:
        print(f"  FAIL  FIND registry drifted: {find_codes}")
        failed += 1
    for bad_call in (lambda: DIAG.emit("FIND-999", None, None, "x"),
                     lambda: DIAG.refusal("FIND-999", None, None, "x")):
        try:
            bad_call()
            print("  FAIL  an unlisted code printed instead of failing")
            failed += 1
        except ValueError as exc:
            if "unlisted diagnostic code 'FIND-999'" not in str(exc):
                print(f"  FAIL  unlisted code failed wrong: {exc}")
                failed += 1

    # D00 T04 §22: main-level exits plus codes, driven against a fixture
    # corpus with the tree globals rebound (restored below).
    mdir = tmp / "main"
    mrev = mdir / "reviews"
    mrev.mkdir(parents=True)
    clean = ("### F1 -- x -- record -- FIXED (self) [minor]\n")
    (mrev / "D00-T99-s1.md").write_text("# R\n\n" + clean, encoding="utf-8")
    (mrev / "transitions.md").write_text("# nothing tracked yet\n", encoding="utf-8")
    mledger = mrev / "findings.md"
    saved_globals = (REVIEWS, LEDGER, TRANSITIONS)
    globals()["REVIEWS"], globals()["LEDGER"], globals()["TRANSITIONS"] = \
        mrev, mledger, mrev / "transitions.md"
    import contextlib
    import json as _json

    def _run_main(argv):
        out, err = io.StringIO(), io.StringIO()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            try:
                code = main(argv)
            except SystemExit as exited:
                code = f"exit:{exited.code}"
        return code, out.getvalue(), err.getvalue()

    try:
        mfind, _mbad = collect()
        mledger.write_text(render_ledger(mfind), encoding="utf-8")
        code, out, _ = _run_main(["--check"])
        if code != 0:
            print(f"  FAIL  fixture green --check exited {code}: {out}")
            failed += 1
        mledger.write_text("stale\n", encoding="utf-8")
        code, out, _ = _run_main(["--check"])
        if code != 1 or "[FIND-003]" not in out:
            print(f"  FAIL  stale ledger fired wrong: exit={code} {out!r}")
            failed += 1
        code, out, _ = _run_main(["--check", "--format", "json"])
        try:
            stale_doc = _json.loads(out)
        except ValueError:
            stale_doc = None
        if (code != 1 or not isinstance(stale_doc, list)
                or [sorted(d) for d in stale_doc]
                != [["code", "line", "message", "path"]]
                or stale_doc[0]["code"] != "FIND-003"
                or stale_doc[0]["code"] not in DIAG.CODES):
            print(f"  FAIL  stale JSON schema wrong: exit={code} {out!r}")
            failed += 1
        (mrev / "D00-T99-s2.md").write_text(
            "# R\n\n### F1 -- x -- record -- FIXED\n", encoding="utf-8")
        mfind2, _mbad2 = collect()
        mledger.write_text(render_ledger(mfind2), encoding="utf-8")
        code, out, _ = _run_main(["--check"])
        if code != 1 or "[FIND-002]" not in out:
            print(f"  FAIL  bad heading fired wrong: exit={code} {out!r}")
            failed += 1
        code, out, _ = _run_main(["--check", "--format", "json"])
        try:
            bad_doc = _json.loads(out)
        except ValueError:
            bad_doc = None
        if (code != 1 or not isinstance(bad_doc, list) or not bad_doc
                or any(sorted(d) != ["code", "line", "message", "path"]
                       for d in bad_doc)
                or bad_doc[0]["code"] != "FIND-002"):
            print(f"  FAIL  malformed input JSON wrong: exit={code} {out!r}")
            failed += 1
        (mrev / "D00-T99-s2.md").unlink()
        (mrev / "D00-T99-s1.md").write_text(
            "# R\n\n### F1 -- x -- record -- WITHDRAWN (self) [minor]\n",
            encoding="utf-8")
        mfind3, _mbad3 = collect()
        mledger.write_text(render_ledger(mfind3), encoding="utf-8")
        code, out, _ = _run_main(["--check"])
        if code != 1 or "[FIND-004]" not in out:
            print(f"  FAIL  transition gap fired wrong: exit={code} {out!r}")
            failed += 1
        (mrev / "D00-T99-s1.md").write_text("# R\n\n" + clean, encoding="utf-8")
        (mrev / "D00-T99-s2.md").write_text(
            "# R\n\n### F1 -- x -- record -- FIXED\n", encoding="utf-8")
        if mledger.is_file():
            mledger.unlink()
        code, out, _ = _run_main(["--write"])
        if code != 1 or "[FIND-005]" not in out or mledger.is_file():
            print(f"  FAIL  write refusal fired wrong: exit={code} {out!r}")
            failed += 1
        code, _, err = _run_main(["--bogus"])
        if code != "exit:2" or "[FIND-001]" not in err:
            print(f"  FAIL  usage fired wrong: {code} {err!r}")
            failed += 1
    finally:
        globals()["REVIEWS"], globals()["LEDGER"], globals()["TRANSITIONS"] = \
            saved_globals

    for x in (f, other, tmp / "D00-T10-s1.md", tmp / "D00-T10-s2.md",
              tmp / "D00-T10-s3.md", fpath):
        x.unlink()
    import shutil
    shutil.rmtree(mdir, ignore_errors=True)
    tmp.rmdir()
    print(f"todo-findings self-test: 45 cases, {failed} failed")
    return 1 if failed else 0


class _CodedParser(argparse.ArgumentParser):
    """Usage errors carry FIND-001: the synopsis stays bare help, the
    error line is the refusal."""

    def error(self, message):
        self.print_usage(sys.stderr)
        print(DIAG.emit("FIND-001", None, None, message), file=sys.stderr)
        self.exit(2)


def main(argv: list[str] | None = None) -> int:
    ap = _CodedParser(
        prog="todo-findings",
        description="Report what review keeps finding, across every section.",
    )
    ap.add_argument("--write", action="store_true",
                    help="regenerate docs/reviews/findings.md from the per-section files")
    ap.add_argument("--check", action="store_true",
                    help="fail if findings.md is stale, without rewriting it")
    ap.add_argument("--self-test", action="store_true", help="prove this script against a fixture")
    ap.add_argument("--format", choices=("text", "json"), default="text",
                    help="render refusals as text lines or one JSON array")
    args = ap.parse_args(argv)

    if args.self_test:
        return _self_test()

    findings, bad = collect()
    json_mode = args.format == "json"

    if args.write or args.check:
        # Unreadable headings are named in EVERY mode. The first version printed
        # them only in the default report, so --write published a ledger with the
        # unparsed findings missing and said nothing, and --check then printed
        # "ledger current" while exiting 1: a failure with no reason attached.
        # Found by the independent review of 43a299a.
        if not json_mode:
            _print_bad(bad)
        want = render_ledger(findings)
        have = LEDGER.read_text(encoding="utf-8") if LEDGER.is_file() else ""
        if args.check:
            if want != have:
                if json_mode:
                    print(DIAG.dumps(
                        _bad_items(bad) + [DIAG.refusal(
                            "FIND-003", _rel(LEDGER), None,
                            "ledger is stale -- run "
                            "`python scripts/todo-findings.py --write`")]),
                        end="")
                else:
                    print(DIAG.emit(
                        "FIND-003", _rel(LEDGER), None,
                        "ledger is stale -- run "
                        "`python scripts/todo-findings.py --write`"))
                return 1
            if bad:
                if json_mode:
                    print(DIAG.dumps(_bad_items(bad)), end="")
                else:
                    print(DIAG.emit(
                        "FIND-002", None, None,
                        f"ledger matches, but {len(bad)} heading(s) "
                        "above are missing from it"))
                return 1
            tproblems = check_transitions(findings, TRANSITIONS)
            if tproblems:
                if json_mode:
                    print(DIAG.dumps(
                        _transition_items(tproblems, TRANSITIONS)), end="")
                else:
                    _print_transitions(tproblems, TRANSITIONS)
                return 1
            if not json_mode:
                print(f"todo-findings: ledger current, {len(findings)} finding(s), "
                      "transitions complete")
            else:
                print(DIAG.dumps([]), end="")
            return 0
        if bad:
            # Refuse to publish a ledger known to be incomplete. Overwriting it
            # with whatever happened to parse makes the omission permanent and
            # invisible, which is the opposite of what this file is for.
            if json_mode:
                print(DIAG.dumps(
                    _bad_items(bad) + [DIAG.refusal(
                        "FIND-005", _rel(LEDGER), None,
                        f"refusing to write a ledger missing {len(bad)} "
                        "finding(s)")]),
                    end="")
            else:
                print(DIAG.emit(
                    "FIND-005", _rel(LEDGER), None,
                    f"refusing to write a ledger missing {len(bad)} "
                    "finding(s). Fix the heading(s) above first."))
            return 1
        LEDGER.parent.mkdir(parents=True, exist_ok=True)
        LEDGER.write_text(want, encoding="utf-8", newline=chr(10))
        if not json_mode:
            print(f"todo-findings: wrote {LEDGER.relative_to(ROOT).as_posix()}, "
                  f"{len(findings)} finding(s)")
        else:
            print(DIAG.dumps([]), end="")
        return 0

    return report(findings, bad, json_mode)


if __name__ == "__main__":
    sys.exit(main())
