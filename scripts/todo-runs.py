#!/usr/bin/env python3
"""Review-run records: who reviewed what, and what each round cost.

Reads docs/reviews/run-records.md, one block per stamped section whose review
reached an independent round. Each block names the section, the date, the
runner, and every independent round with its model, effort, outcome, reviewed
candidate, and the finding refs that round raised, plus the empty/refuted
counts. Attribution is per round, on the round line, so per-model yield is a
query rather than a reading of comments.

A run records the finding REFS its rounds raised, exactly the refs carrying an
(independent) mark in the section's review file. Findings described only in
review prose, without a ref, are noted in `#` comments and counted nowhere:
dimensions count refs, and a ref-less finding must not silently join them.

Cross-checks (--check): every listed ref resolves to an independent-marked
finding parsed by todo-findings.py; every independent-marked ref appears in
exactly one run's rounds; every review file has a run block, so a deleted
engagement fails loudly; empty equals the rounds with outcome empty; refuted
equals the listed refs whose disposition is refuted; panel runs re-read their
round verdicts from the review file; every candidate is a commit that exists.

--report prints the run dimensions: engagements, rounds per section, panel
verdict overlap (rounds sharing a four-lens signature), the empty-round
index, and the source split (independent from runs, self from ledger).
"""

import importlib.util
import io
import re
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent


def _load_findings():
    spec = importlib.util.spec_from_file_location("todo_findings", HERE / "todo-findings.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


TF = _load_findings()

ROOT = HERE.parent
DEFAULT_RUNS = ROOT / "docs" / "reviews" / "run-records.md"

RUNNERS = ("codex", "panel")
EFFORTS = ("high", "medium", "low")
OUTCOMES = ("findings", "empty", "error")
FAMILY_MODEL = {"GPT": "gpt-5.6-sol", "Opus": "opus"}

RUN_RE = re.compile(r"^run:\s*(?P<section>D\d{2}-T\d{2}-S\d+)\s*$")
FIELD_RE = re.compile(r"^(?P<key>date|runner|rounds|round|empty|refuted):\s*(?P<value>.*)$")
ROUND_ITEM_RE = re.compile(r"(?P<key>model|effort|outcome|candidate):\s*(?P<value>\S+)")
ROUND_FINDINGS_RE = re.compile(r"\bfindings:\s*(?P<refs>.*)$")
REQUIRED_FIELDS = ("date", "runner", "rounds", "empty", "refuted")
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
SHA_RE = re.compile(r"^[0-9a-f]{7,40}$")
REF_RE = re.compile(r"^D\d{2}-T\d{2}-S\d+-F\d+$")
PANEL_HEADING_RE = re.compile(r"^#{2,}\s*(?P<family>GPT|Opus) panel Round (?P<n>\d+)\s*$")
PANEL_VERDICT_RE = re.compile(r"^\s*`(?P<lens>[A-Za-z-]+)`\s+(?P<verdict>approve|needs-attention|advisory)\b")
HEADING_RE = re.compile(r"^#{1,6}\s+")
FENCE_RE = re.compile(r"^\s*(`{3,}|~{3,})")
LENSES = ("adversarial", "consistency", "integration", "record")


class Run:
    __slots__ = ("section", "date", "runner", "rounds", "round_lines",
                 "empty", "refuted", "lineno", "fields_seen")

    def __init__(self, section, lineno):
        self.section = section
        self.lineno = lineno
        self.date = None
        self.runner = None
        self.rounds = None
        # (lineno, number, {model, effort, outcome, candidate, findings?})
        self.round_lines = []
        self.empty = None
        self.refuted = None
        self.fields_seen = {"run"}

    def findings(self):
        """All refs raised, in round order: the per-round attribution union."""
        refs = []
        for _lineno, _n, items in sorted(self.round_lines, key=lambda r: r[1]):
            refs.extend(items.get("findings", []))
        return refs


def parse_runs(text):
    """Parse the runs file. Returns (runs, errors). Comments and blank lines skipped."""
    runs = []
    errors = []
    current = None

    def finish():
        if current is not None:
            for field in REQUIRED_FIELDS:
                if field not in current.fields_seen:
                    errors.append((current.lineno, f"missing field {field!r}, reported not assumed"))
            runs.append(current)

    for lineno, raw in enumerate(text.splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        m = RUN_RE.match(line)
        if m:
            finish()
            current = Run(m.group("section"), lineno)
            continue
        if current is None:
            if not runs and not errors:
                continue  # header preamble before the first run block
            errors.append((lineno, f"outside any run block: {raw.strip()!r}"))
            continue
        if re.match(r"^findings\s*:", line):
            errors.append((lineno, "run-level findings moved to the round lines; "
                                   "attribute each ref to its round"))
            continue
        f = FIELD_RE.match(line)
        if f is None:
            errors.append((lineno, f"not a field line: {raw.strip()!r}"))
            continue
        key, value = f.group("key"), f.group("value").strip()
        if key == "round":
            rm = re.match(r"(?P<n>\d+)\s+(?P<rest>.*)$", value)
            if rm is None:
                errors.append((lineno, "round line needs a number first"))
                continue
            rest = rm.group("rest")
            items = dict(ROUND_ITEM_RE.findall(rest))
            fm = ROUND_FINDINGS_RE.search(rest)
            if fm is None:
                errors.append((lineno, "round line misses findings (write it empty, never omit it)"))
                continue
            items["findings"] = [r.strip() for r in fm.group("refs").split(",") if r.strip()]
            current.round_lines.append((lineno, int(rm.group("n")), items))
            continue
        if key in current.fields_seen:
            errors.append((lineno, f"duplicate field {key!r}"))
            continue
        current.fields_seen.add(key)
        if key in ("rounds", "empty", "refuted"):
            if not re.fullmatch(r"\d+", value):
                errors.append((lineno, f"{key} is not a number: {value!r}"))
                continue
            setattr(current, key, int(value))
        else:
            setattr(current, key, value)
    finish()
    return runs, errors


def check_runs(runs, errors):
    """Structural checks. Appends (lineno, message); returns the error list."""
    seen_sections = {}
    for run in runs:
        if run.section in seen_sections:
            errors.append((run.lineno, f"duplicate run block for {run.section}"))
        else:
            seen_sections[run.section] = run.lineno
        if not run.date or not DATE_RE.match(run.date):
            errors.append((run.lineno, f"bad or missing date: {run.date!r}"))
        if run.runner not in RUNNERS:
            errors.append((run.lineno, f"runner must be one of {RUNNERS}, got {run.runner!r}"))
        if run.rounds is None or run.rounds < 1:
            errors.append((run.lineno, "rounds must be a positive number"))
        numbers = sorted(n for _, n, _ in run.round_lines)
        if numbers != list(range(1, len(run.round_lines) + 1)):
            errors.append((run.lineno, f"round numbers must run 1..N, got {numbers}"))
        if run.rounds is not None and len(run.round_lines) != run.rounds:
            errors.append((run.lineno,
                           f"rounds says {run.rounds} but {len(run.round_lines)} round lines present"))
        for rl_lineno, _n, items in run.round_lines:
            for need in ("model", "effort", "outcome", "candidate"):
                if need not in items:
                    errors.append((rl_lineno, f"round line misses {need}"))
            if "effort" in items and items["effort"] not in EFFORTS:
                errors.append((rl_lineno, f"effort must be one of {EFFORTS}"))
            if "outcome" in items and items["outcome"] not in OUTCOMES:
                errors.append((rl_lineno, f"outcome must be one of {OUTCOMES}"))
            if "candidate" in items and not SHA_RE.match(items["candidate"]):
                errors.append((rl_lineno, f"candidate is not a hex sha: {items['candidate']!r}"))
            for ref in items.get("findings", []):
                if not REF_RE.match(ref):
                    errors.append((rl_lineno, f"finding ref must be D..-T..-S..-F<n>, got {ref!r}"))
            if items.get("outcome") == "empty" and items.get("findings"):
                errors.append((rl_lineno, "an empty round lists no findings; move them or fix the outcome"))
        empties = sum(1 for _, _, items in run.round_lines if items.get("outcome") == "empty")
        if run.empty is not None and run.empty != empties:
            errors.append((run.lineno, f"empty says {run.empty} but {empties} round(s) came back empty"))
        if run.refuted is None or run.refuted < 0:
            errors.append((run.lineno, "refuted must be a non-negative number"))
    return errors


def _section_of_ref(ref):
    return "-".join(ref.split("-")[:3])


def _display_section(compact):
    m = re.match(r"^D(\d{2})-T(\d{2})-S(\d+)$", compact)
    return f"D{m.group(1)} T{m.group(2)} §{m.group(3)}"


def _review_path(compact):
    m = re.match(r"^D(\d{2})-T(\d{2})-S(\d+)$", compact)
    dom, todo, sec = m.group(1), m.group(2), int(m.group(3))
    for parent in TF.REVIEWS.iterdir():
        if not parent.is_dir():
            continue
        cand = parent / f"D{dom}-T{todo}-s{sec}.md"
        if cand.is_file():
            return cand
    return None


def _review_files():
    """Compact sections with a committed-shape review file under docs/reviews/."""
    sections = set()
    if not TF.REVIEWS.is_dir():
        return sections
    for path in TF.REVIEWS.rglob("*.md"):
        display = TF._ref_for(path.name)
        if display is not None:
            sections.add(_compact_section(display))
    return sections


def cross_check(runs, collected=None, review_sections=None):
    """Refs resolve, marks are covered exactly once, every file has a run.

    `collected` and `review_sections` override the tree reads for tests.
    Returns a list of (lineno, message) with lineno 0 when no run line fits.
    """
    errors = []
    findings, bad = collected if collected is not None else TF.collect()
    for path, lineno, msg in bad:
        errors.append((0, f"{path.name}:{lineno}: unparseable heading, runs cannot cover it: {msg}"))
    by_ref = {}
    for f in findings:
        ref = f"{_compact_section(f.ref)}-{f.number}"
        by_ref.setdefault(ref, []).append(f)
    claimed = {}
    for run in runs:
        for ref in run.findings():
            if ref not in by_ref:
                errors.append((run.lineno, f"{ref} resolves to no finding heading"))
                continue
            if by_ref[ref][0].source != "independent":
                errors.append((run.lineno, f"{ref} is not independent-marked; "
                                           f"runs list independent refs only"))
                continue
            claimed.setdefault(ref, []).append(run.section)
            if _section_of_ref(ref) != run.section:
                errors.append((run.lineno, f"{ref} belongs to another section's file"))
    for ref, sections in claimed.items():
        if len(sections) > 1:
            errors.append((0, f"{ref} claimed by {len(sections)} runs: {', '.join(sections)}"))
    for ref, fs in sorted(by_ref.items()):
        if fs[0].source == "independent" and ref not in claimed:
            errors.append((0, f"{ref} carries (independent) but no run lists it"))
    have_runs = {run.section for run in runs}
    files = review_sections if review_sections is not None else _review_files()
    for section in sorted(files - have_runs):
        errors.append((0, f"{section} has a review file but no run block; "
                          f"a deleted engagement changes the counts silently"))
    for run in runs:
        if run.refuted is None:
            continue
        got = sum(1 for ref in run.findings()
                  if ref in by_ref and by_ref[ref][0].disposition == "refuted")
        if got != run.refuted:
            errors.append((run.lineno, f"refuted says {run.refuted} but {got} listed ref(s) are refuted"))
    return errors


def _compact_section(display):
    m = re.match(r"^D(\d{2}) T(\d{2}) §(\d+)$", display)
    return f"D{m.group(1)}-T{m.group(2)}-S{m.group(3)}"


def panel_verdicts(path):
    """Per-round {lens: verdict} from the panel sections of one review file."""
    rounds = {}
    current = None
    in_fence = False
    for line in io.open(path, encoding="utf-8", errors="replace").read().splitlines():
        if FENCE_RE.match(line):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        pm = PANEL_HEADING_RE.match(line)
        if pm:
            current = (pm.group("family"), int(pm.group("n")))
            rounds.setdefault(current, {})
            continue
        if HEADING_RE.match(line):
            current = None
            continue
        if current is not None:
            vm = PANEL_VERDICT_RE.match(line)
            if vm:
                rounds[current][vm.group("lens").lower()] = vm.group("verdict")
    return rounds


def check_panel_rounds(runs):
    """Panel runs re-read their round verdicts: numbers, models, full lenses.

    Error rounds (voided attempts) carry no verdicts and are skipped in
    the mapping: usable rounds meet panel sections 1..k in run order."""
    errors = []
    for run in runs:
        path = _review_path(run.section)
        if path is None:
            errors.append((run.lineno, f"no review file found for {run.section}"))
            continue
        verdicts = panel_verdicts(path)
        if run.runner == "panel" and not verdicts:
            errors.append((run.lineno, "runner is panel but the review file has no panel sections"))
            continue
        if run.runner != "panel" and verdicts:
            errors.append((run.lineno, "review file has panel sections but runner is not panel"))
            continue
        if run.runner != "panel":
            continue
        by_number = {}
        for (family, n), lens in verdicts.items():
            by_number.setdefault(n, []).append((family, lens))
        usable = [(n, items) for _, n, items in run.round_lines
                  if items.get("outcome") != "error"]
        for panel_n, (_n, items) in enumerate(usable, 1):
            n = panel_n
            if n not in by_number:
                errors.append((run.lineno, f"round {n} has no panel section in the review file"))
                continue
            families = by_number[n]
            if len(families) != 1:
                errors.append((run.lineno, f"round {n} has {len(families)} panel sections"))
                continue
            family, lens = families[0]
            want = FAMILY_MODEL[family]
            if items.get("model") != want:
                errors.append((run.lineno,
                               f"round {n} is a {family} panel round but lists model {items.get('model')!r}"))
            missing = [lens_name for lens_name in LENSES if lens_name not in lens]
            if missing:
                errors.append((run.lineno, f"round {n} panel verdicts miss {', '.join(missing)}"))
            non_approve = [lens_name for lens_name, v in lens.items() if v != "approve"]
            if items.get("outcome") == "empty" and non_approve:
                errors.append((run.lineno,
                               f"round {n} is recorded empty but {', '.join(non_approve)} did not approve"))
            if items.get("outcome") == "findings" and not non_approve:
                errors.append((run.lineno, f"round {n} is recorded findings but every lens approved"))
    return errors


def check_candidates(runs):
    """Every reviewed candidate names a commit that exists. Needs git."""
    errors = []
    shas = sorted({items["candidate"] for run in runs for _, _, items in run.round_lines
                   if "candidate" in items and SHA_RE.match(items["candidate"])})
    for sha in shas:
        hit = subprocess.run(["git", "cat-file", "-t", sha], cwd=ROOT,
                             capture_output=True, text=True)
        if hit.returncode != 0 or hit.stdout.strip() != "commit":
            errors.append((0, f"candidate {sha} is not a commit in this repository"))
    return errors


def run_check(runs_path):
    try:
        text = io.open(runs_path, encoding="utf-8").read()
    except OSError as exc:
        return [], [(0, f"cannot read {runs_path}: {exc}")]
    runs, errors = parse_runs(text)
    check_runs(runs, errors)
    if not errors:
        errors.extend(cross_check(runs))
        errors.extend(check_panel_rounds(runs))
        errors.extend(check_candidates(runs))
    return runs, errors


def report(runs):
    lines = []
    lines.append(f"{len(runs)} review runs, "
                 f"{sum(r.rounds or 0 for r in runs)} independent rounds.")
    empty_engagements = sum(1 for r in runs if all(
        items.get("outcome") == "empty" for _, _, items in r.round_lines))
    lines.append(f"{len(runs)} engagements, {empty_engagements} empty, "
                 f"{sum(r.refuted or 0 for r in runs)} refuted.")
    lines.append("")
    lines.append("Rounds per section:")
    for run in runs:
        models = ",".join(dict.fromkeys(items.get("model", "?")
                                        for _, _, items in run.round_lines))
        lines.append(f"- {run.section}: {run.rounds} round(s), {models}, "
                     f"{len(run.findings())} finding(s), {run.empty} empty")
    lines.append("")
    lines.append("Panel verdict overlap (rounds sharing a four-lens signature):")
    sigs = {}
    for run in runs:
        if run.runner != "panel":
            continue
        path = _review_path(run.section)
        for (family, n), lens in sorted(panel_verdicts(path).items()):
            sig = "/".join(f"{lens_name}={lens.get(lens_name, '?')}" for lens_name in LENSES)
            sigs.setdefault(sig, []).append(f"{run.section} round {n} ({family})")
    if not sigs:
        lines.append("- no panel rounds recorded")
    else:
        for sig in sorted(sigs):
            lines.append(f"- {sig}: {', '.join(sigs[sig])}")
        dupes = {sig: rs for sig, rs in sigs.items() if len(rs) > 1}
        lines.append(f"- overlap: {len(dupes)} signature(s) shared" if dupes
                     else "- overlap: no two panel rounds share a signature")
    lines.append("")
    lines.append("Empty-round index:")
    empties = [f"{run.section} round {n}"
               for run in runs for _, n, items in run.round_lines
               if items.get("outcome") == "empty"]
    if empties:
        lines.extend(f"- {entry}" for entry in empties)
    else:
        lines.append("- no empty round recorded")
    lines.append("")
    lines.append("Source split (independent from runs, self from ledger):")
    findings, _bad = TF.collect()
    ledger_by_section = {}
    for f in findings:
        ledger_by_section.setdefault(_compact_section(f.ref), []).append(f)
    total_ind = total_self = 0
    for run in runs:
        ledger = ledger_by_section.get(run.section, [])
        independent = len(run.findings())
        self_raised = len(ledger) - independent
        total_ind += independent
        total_self += self_raised
        lines.append(f"- {run.section}: independent {independent}, self {self_raised}")
    lines.append(f"- total: independent {total_ind}, self {total_self}")
    return "\n".join(lines) + "\n"


def _self_test():
    failures = []
    total = [0]

    def check(name, cond, detail=""):
        total[0] += 1
        if not cond:
            failures.append(f"{name}: {detail or 'failed'}")

    good = """run: D00-T01-S1
date: 2026-09-17
runner: codex
rounds: 2
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 6bb635e findings: D00-T01-S1-F1, D00-T01-S1-F2
round: 2 model: gpt-6-astra effort: high outcome: empty candidate: 8437dd5 findings:
empty: 1
refuted: 0
"""
    runs, errors = parse_runs(good)
    check("parse-clean", not errors and len(runs) == 1, f"{errors}")
    check_runs(runs, errors)
    check("check-clean", not errors, f"{errors}")
    check("round-count", runs[0].round_lines[1][1] == 2)
    check("findings-split", runs[0].findings() == ["D00-T01-S1-F1", "D00-T01-S1-F2"],
          f"{runs[0].findings()}")

    commented = "# a comment\n\n" + good.replace(
        "empty: 1\n", "empty: 1\n# round 1 also saw a stale duplicate; not a finding\n")
    runs_c, errors_c = parse_runs(commented)
    check("comments-ignored", not errors_c and len(runs_c) == 1, f"{errors_c}")

    bad_empty = good.replace("empty: 1\n", "empty: 0\n")
    _r, errors_b = parse_runs(bad_empty)
    check_runs(_r, errors_b)
    check("empty-mismatch-fails", any("empty says 0" in m for _, m in errors_b), f"{errors_b}")

    bad_fields = good.replace("effort: high outcome", "outcome")
    _r, errors_f = parse_runs(bad_fields)
    check_runs(_r, errors_f)
    check("missing-round-field-fails", any("misses effort" in m for _, m in errors_f), f"{errors_f}")

    bad_effort = good.replace("effort: high", "effort: extreme")
    _r, errors_e = parse_runs(bad_effort)
    check_runs(_r, errors_e)
    check("bad-effort-fails", any("effort must be" in m for _, m in errors_e), f"{errors_e}")

    bad_ref = good.replace("D00-T01-S1-F2", "D00-T01-S1-F1-F2")
    _r, errors_r = parse_runs(bad_ref)
    check_runs(_r, errors_r)
    check("group-ref-rejected", any("must be D..-T..-S..-F" in m for _, m in errors_r), f"{errors_r}")

    bad_rounds = good.replace("rounds: 2\n", "rounds: 3\n")
    _r, errors_n = parse_runs(bad_rounds)
    check_runs(_r, errors_n)
    check("rounds-count-fails", any("rounds says 3" in m for _, m in errors_n), f"{errors_n}")

    preamble = "# Review-run records\n\nA prose preamble.\n\n" + good
    _r, errors_p = parse_runs(preamble)
    check("preamble-skipped", not errors_p and len(_r) == 1, f"{errors_p}")
    outside = good + "a stray prose line\n"
    _r, errors_o = parse_runs(outside)
    check("outside-block-fails", any("not a field line" in m for _, m in errors_o), f"{errors_o}")

    dupe = good + good.replace("run: D00-T01-S1", "run: D00-T01-S1")
    _r, errors_d = parse_runs(dupe)
    check_runs(_r, errors_d)
    check("duplicate-run-fails", any("duplicate run" in m for _, m in errors_d), f"{errors_d}")

    missing_field = good.replace("empty: 1\n", "")
    _r, errors_m = parse_runs(missing_field)
    check("missing-field-reported", any("missing field 'empty'" in m for _, m in errors_m),
          f"{errors_m}")

    no_findings_key = good.replace("candidate: 8437dd5 findings:", "candidate: 8437dd5")
    _r, errors_k = parse_runs(no_findings_key)
    check("missing-findings-key-fails", any("misses findings" in m for _, m in errors_k),
          f"{errors_k}")

    run_level = good.replace("round: 2 model", "findings: D00-T01-S1-F9\nround: 2 model")
    _r, errors_l = parse_runs(run_level)
    check("run-level-findings-fails", any("moved to the round lines" in m for _, m in errors_l),
          f"{errors_l}")

    empty_with = good.replace("outcome: empty candidate: 8437dd5 findings:",
                              "outcome: empty candidate: 8437dd5 findings: D00-T01-S1-F9")
    _r, errors_w = parse_runs(empty_with)
    check_runs(_r, errors_w)
    check("empty-with-findings-fails", any("empty round lists no findings" in m for _, m in errors_w),
          f"{errors_w}")

    ind = TF.Finding("D00 T01 §1", None, 1, "F1", "s", "record", "fixed", None, "independent")
    slf = TF.Finding("D00 T01 §1", None, 2, "F2", "s", "record", "fixed", None, "self")
    fixture = ([ind, slf], [])
    sections = {"D00-T01-S1"}
    _r, _e = parse_runs(good)
    cc = cross_check(_r, collected=fixture, review_sections=sections)
    check("self-ref-rejected", any("not independent-marked" in m for _, m in cc), f"{cc}")

    only_self = good.replace("D00-T01-S1-F1, D00-T01-S1-F2", "D00-T01-S1-F1")
    _r, _e = parse_runs(only_self)
    cc = cross_check(_r, collected=fixture, review_sections=sections | {"D00-T01-S9"})
    check("missing-run-reported", any("no run block" in m for _, m in cc), f"{cc}")

    runs_u, errors_u = run_check(Path("/tmp/nope-does-not-exist.md"))
    check("unreadable-reported", runs_u == [] and any("cannot read" in m for _, m in errors_u),
          f"{runs_u} {errors_u}")

    print(f"todo-runs self-test: {total[0]} cases, {len(failures)} failed")
    for failure in failures:
        print(f"FAIL {failure}")
    return 1 if failures else 0


def main(argv=None):
    args = list(sys.argv[1:] if argv is None else argv)
    if "--self-test" in args:
        return _self_test()
    mode_report = "--report" in args
    rest = [a for a in args if a not in ("--check", "--report")]
    runs_path = Path(rest[0]) if rest else DEFAULT_RUNS
    runs, errors = run_check(runs_path)
    if errors:
        for lineno, msg in errors:
            where = f"{runs_path}:{lineno}" if lineno else f"{runs_path}"
            print(f"{where}: {msg}")
        return 1
    if mode_report:
        sys.stdout.write(report(runs))
    else:
        rounds = sum(r.rounds or 0 for r in runs)
        print(f"{len(runs)} runs, {rounds} rounds: all resolve, all covered, counts agree")
    return 0


if __name__ == "__main__":
    sys.exit(main())
