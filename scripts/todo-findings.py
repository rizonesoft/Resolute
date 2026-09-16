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

    ### F1 -- four claims pointed into gitignored `samples/` -- consistency -- FIXED
    ### F2 -- the build is not reproducible -- reproducibility -- FILED to `D07 T01`

Four fields separated by ` -- `: the number, the summary, the category, the disposition.
A heading this cannot parse is REPORTED, never skipped: skipping is how the split-claim
defect hid in the claims checker, where the count simply dropped and the total still
said everything held.

Exit codes: 0 everything parsed, 1 at least one heading could not be read.
"""

from __future__ import annotations

import argparse
import io
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REVIEWS = ROOT / "docs" / "reviews"
LEDGER = REVIEWS / "findings.md"

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
}

# A disposition is what was DONE about the finding, normalised to its first word.
DISPOSITIONS = {"fixed", "filed", "refuted", "advisory", "routed", "cleared"}


class Finding:
    __slots__ = ("ref", "path", "line", "number", "summary", "category", "disposition")

    def __init__(self, ref, path, line, number, summary, category, disposition):
        self.ref = ref
        self.path = path
        self.line = line
        self.number = number
        self.summary = summary
        self.category = category
        self.disposition = disposition


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
            bad.append((path, lineno, f"needs 'F<n> -- summary -- category -- disposition', got {len(parts)} field(s)"))
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
        findings.append(Finding(ref, path, lineno, number, summary, cat, disp))
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


REPEAT_QUESTION = (
    "seen {n} times: what check would have caught this? Record the answer in "
    "D00 T04 §2, even when the answer is that no cheap check exists."
)


def _print_bad(bad: list[tuple[Path, int, str]]) -> None:
    if not bad:
        return
    print("  headings this could not read, reported rather than skipped:")
    for path, lineno, why in bad:
        try:
            rel = path.relative_to(ROOT).as_posix()
        except ValueError:
            rel = path.as_posix()   # a self-test fixture outside the repository
        print(f"    {rel}:{lineno}  {why}")
    print()


def report(findings: list[Finding], bad: list[tuple[Path, int, str]]) -> int:
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

    repeats = [(c, n) for c, n in by_cat.most_common() if n >= 2]
    if repeats:
        print("\n  repeats, which D00 T04 §2 says must become a question")
        for cat, n in repeats:
            print(f"    {cat}: " + REPEAT_QUESTION.format(n=n))

    if bad:
        print()
        _print_bad(bad)

    print(f"todo-findings: {len(findings)} parsed, {len(bad)} unreadable")
    return 1 if bad else 0


def render_ledger(findings: list[Finding]) -> str:
    by_cat = Counter(f.category for f in findings)
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
    out.append("## Every finding")
    out.append("")
    out.append("| Section | # | Category | Disposition | Summary |")
    out.append("| --- | --- | --- | --- | --- |")
    for ref in sorted(by_section):
        for f in by_section[ref]:
            out.append(f"| `{ref}` | {f.number} | `{f.category}` | {f.disposition} | {f.summary} |")
    out.append("")
    return "\n".join(out)


def _self_test() -> int:
    import tempfile
    tmp = Path(tempfile.mkdtemp(prefix="todo-findings-"))
    f = tmp / "D00-T99-s1.md"
    f.write_text(
        "# R\n\n"
        "### F1 -- a thing went wrong -- consistency -- FIXED\n\n"
        "### F2 -- another thing -- consistency -- FILED to `D01 T01 §1`\n\n"
        "### F3 -- a third -- performance -- FIXED\n\n"
        "### F4 -- no category here -- FIXED\n\n"
        "### F5 -- bad category -- nonsense -- FIXED\n\n"
        "### Not a finding heading\n",
        encoding="utf-8",
    )
    failed = 0
    findings, bad = parse_file(f)

    if len(findings) != 3:
        print(f"  FAIL  expected 3 parsed findings, got {len(findings)}")
        failed += 1
    if len(bad) != 2:
        print(f"  FAIL  expected 2 unreadable headings, got {len(bad)}")
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
        "### Fixes applied", "", "### F1 -- real -- record -- FIXED", "",
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


    for x in (f, other):
        x.unlink()
    tmp.rmdir()
    print(f"todo-findings self-test: 11 cases, {failed} failed")
    return 1 if failed else 0


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(
        prog="todo-findings",
        description="Report what review keeps finding, across every section.",
    )
    ap.add_argument("--write", action="store_true",
                    help="regenerate docs/reviews/findings.md from the per-section files")
    ap.add_argument("--check", action="store_true",
                    help="fail if findings.md is stale, without rewriting it")
    ap.add_argument("--self-test", action="store_true", help="prove this script against a fixture")
    args = ap.parse_args(argv)

    if args.self_test:
        return _self_test()

    findings, bad = collect()

    if args.write or args.check:
        # Unreadable headings are named in EVERY mode. The first version printed
        # them only in the default report, so --write published a ledger with the
        # unparsed findings missing and said nothing, and --check then printed
        # "ledger current" while exiting 1: a failure with no reason attached.
        # Found by the independent review of 43a299a.
        _print_bad(bad)
        want = render_ledger(findings)
        have = LEDGER.read_text(encoding="utf-8") if LEDGER.is_file() else ""
        if args.check:
            if want != have:
                print("todo-findings: docs/reviews/findings.md is stale -- "
                      "run `python scripts/todo-findings.py --write`")
                return 1
            if bad:
                print(f"todo-findings: ledger matches, but {len(bad)} heading(s) "
                      "above are missing from it")
                return 1
            print(f"todo-findings: ledger current, {len(findings)} finding(s)")
            return 0
        if bad:
            # Refuse to publish a ledger known to be incomplete. Overwriting it
            # with whatever happened to parse makes the omission permanent and
            # invisible, which is the opposite of what this file is for.
            print(f"todo-findings: refusing to write a ledger missing {len(bad)} "
                  "finding(s). Fix the heading(s) above first.")
            return 1
        LEDGER.parent.mkdir(parents=True, exist_ok=True)
        LEDGER.write_text(want, encoding="utf-8", newline=chr(10))
        print(f"todo-findings: wrote {LEDGER.relative_to(ROOT).as_posix()}, "
              f"{len(findings)} finding(s)")
        return 0


    return report(findings, bad)


if __name__ == "__main__":
    sys.exit(main())
