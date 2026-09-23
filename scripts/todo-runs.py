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

Refusals carry stable diagnostic codes from the single registry in
`scripts/todo-diag.py` (D00 T04 §22): `CODES` maps each code to its exit
and family, and is the only documented place the list lives (this
docstring names the registry, never the mapping). `--format json`
renders gate-mode refusals as one JSON array of
code/path/line/message objects (green prints `[]`); `--report`
prints prose with no array once the gate passes (problems refuse as
one array first, like the gate), and `--export` prints the export
document; usage errors stay text, since argv did not parse and no
format was selected.

Exit codes: 0 the run file is sound, 1 a refusal fired (an unreadable
input or a failed cross-check), 2 usage.
"""

import datetime
import importlib.util
import io
import json
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


def _load_diag():
    """The shared diagnostic registry (one instance per process)."""
    mod = sys.modules.get("todo_diag")
    if mod is not None:
        return mod
    spec = importlib.util.spec_from_file_location("todo_diag", HERE / "todo-diag.py")
    mod = importlib.util.module_from_spec(spec)
    sys.modules["todo_diag"] = mod
    spec.loader.exec_module(mod)
    return mod


DIAG = _load_diag()


def _load_panel_slots():
    """The review wiring table's loader (D00 T04 §27): model names live
    in `.conclave/panel.toml`, never in this module."""
    mod = sys.modules.get("panel_slots")
    if mod is not None:
        return mod
    spec = importlib.util.spec_from_file_location("panel_slots", HERE / "panel_slots.py")
    mod = importlib.util.module_from_spec(spec)
    sys.modules["panel_slots"] = mod
    spec.loader.exec_module(mod)
    return mod


PANEL_SLOTS = _load_panel_slots()

ROOT = HERE.parent
DEFAULT_RUNS = ROOT / "docs" / "reviews" / "run-records.md"
DEFAULT_BANK = ROOT / "docs" / "reviews" / "crossover" / "comparisons.md"
# Panel sections past the newest banked comparison before the bank reads
# stale: the mid-window calibration point of a 5-section window (§18
# standing schedule banks one decision crossover plus one mid-window
# calibration round per window). Cost of changing: re-pin the fresh and
# stale bank legs below.
BANK_STALE_AFTER = 3
# What each trigger state owes (D00 T04 §24 item 3), pinned verbatim.
TRIGGER_LEGEND = (
    'Trigger legend:',
    '- count met (§23 unblocked, runs on schedule)',
    '- FIRED or ARMED (file the early revisit now, quoting these lines)',
    '- quiet (nothing owed)',
)

RUNNERS = ("codex", "panel")
EFFORTS = ("high", "medium", "low")
OUTCOMES = ("findings", "empty", "error", "stamp", "independent")
PROVIDERS = ("openai", "anthropic")
# Outcomes the panel mapping skips: error voids the attempt's verdicts,
# while stamp (a stamp-review pass) and independent (a non-panel
# independent pass) never had panel verdicts. Skipped rounds keep their
# refs: usable findings count in yield and coverage, but meet no panel
# section.
SKIPPED_OUTCOMES = ("error", "stamp", "independent")
# The §8 decision window: the last 5 panel-reviewed sections at decision
# time, per-section Sol full-scope 5/2/5/3/4. §18 counts past this set.
REVISIT_WINDOW = ("D00-T02-S5", "D00-T04-S6", "D00-T04-S7", "D00-T04-S9", "D00-T04-S10")
REVISIT_NEED = 5
OPPORTUNITIES = ("full-scope", "delta-plus-regressions", "unresolved")
PURPOSES = ("section-review", "stamp-review", "sign-off", "fix-loop", "unresolved")
PROVENANCES = ("recorded", "reconstructed")
# Panel heading word -> every model of that family the registry names,
# retired pins included so historical rounds keep checking (D00 T04 §27:
# `Claude panel` is the family word, legacy records say `Opus panel`).
FAMILY_MODELS = {
    "GPT": PANEL_SLOTS.family_models("codex"),
    "Opus": PANEL_SLOTS.family_models("claude"),
    "Claude": PANEL_SLOTS.family_models("claude"),
}
# The rungs the cut-leg interim reports, one per family.
CUT_LEG_FAMILIES = ("GPT", "Claude")
SCHEMA_VERSION = 1
# Version 2 adds per-ref dispositions to every round line, so a snapshot
# consumer computes accepted yield without rejoining live records.
EXPORT_VERSION = 2

RUN_RE = re.compile(r"^run:\s*(?P<section>D\d{2}-T\d{2}-S\d+)\s*$")
SCHEMA_RE = re.compile(r"^schema:\s*(?P<version>\d+)\s*$")
FIELD_RE = re.compile(r"^(?P<key>date|runner|rounds|round|empty|refuted):\s*(?P<value>.*)$")
ROUND_ITEM_RE = re.compile(r"(?P<key>model|effort|outcome|candidate|provider|version|cost|latency|opportunity|purpose|provenance):\s*(?P<value>\S+)")
ROUND_FINDINGS_RE = re.compile(r"\bfindings:\s*(?P<refs>.*)$")
REQUIRED_FIELDS = ("date", "runner", "rounds", "empty", "refuted")
REQUIRED_ROUND_KEYS = ("model", "effort", "outcome", "candidate", "provider", "version",
                       "cost", "latency", "opportunity", "purpose", "provenance")
COST_RE = re.compile(r"^(?:unresolved|[0-9]+tokens)$")
LATENCY_RE = re.compile(r"^(?:unresolved|[0-9]+s)$")
TIMESTAMP_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
SHA_RE = re.compile(r"^[0-9a-f]{7,40}$")
REF_RE = re.compile(r"^D\d{2}-T\d{2}-S\d+-F\d+$")
COMPARISON_RE = re.compile(r"^comparison:\s*(?P<dir>\S+)\s+class:\s*(?P<class>\S+)"
                           r"\s+jaccard:\s*(?P<jaccard>\S+)\s+"
                           r"pairs:\s*(?P<pairs>\d+)\s+union:\s*(?P<union>\d+)\s*$")
# Findings that carry no value in the cut legs: raised-then-disproven,
# retracted, or already tracked elsewhere. Anything else (fixed, filed,
# advisory, corrected, cleared, routed) and any unresolvable ref counts
# as a find, so bad data breaks a zero run instead of arming it.
ZERO_BLIND_DISPOSITIONS = ("refuted", "withdrawn", "duplicate")
PANEL_HEADING_RE = re.compile(r"^#{2,}\s*(?P<family>GPT|Opus|Claude) panel Round (?P<n>\d+)\s*$")
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
    schema_lineno = None

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
        sm = SCHEMA_RE.match(line)
        if sm is not None:
            if current is not None or runs:
                errors.append((lineno, "schema declares once, ahead of the first run block"))
            elif schema_lineno is not None:
                errors.append((lineno, "duplicate schema declaration"))
            elif int(sm.group("version")) != SCHEMA_VERSION:
                errors.append((lineno, f"schema {sm.group('version')} is not {SCHEMA_VERSION}; "
                                       f"this parser reads {SCHEMA_VERSION} only"))
                schema_lineno = lineno
            else:
                schema_lineno = lineno
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
    if schema_lineno is None:
        errors.append((0, f"no schema declaration; declare `schema: {SCHEMA_VERSION}` ahead of the runs"))
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
            for need in REQUIRED_ROUND_KEYS:
                if need not in items:
                    errors.append((rl_lineno, f"round line misses {need}"))
            if "effort" in items and items["effort"] not in EFFORTS:
                errors.append((rl_lineno, f"effort must be one of {EFFORTS}"))
            if "outcome" in items and items["outcome"] not in OUTCOMES:
                errors.append((rl_lineno, f"outcome must be one of {OUTCOMES}"))
            if "candidate" in items and not SHA_RE.match(items["candidate"]):
                errors.append((rl_lineno, f"candidate is not a hex sha: {items['candidate']!r}"))
            if "provider" in items and items["provider"] not in PROVIDERS:
                errors.append((rl_lineno, f"provider must be one of {PROVIDERS}"))
            # version is free text by design (pins differ per provider);
            # unknown versions read `unresolved` by convention, not by gate.
            if "cost" in items and not COST_RE.match(items["cost"]):
                errors.append((rl_lineno, "cost reads `<int>tokens` or `unresolved`"))
            if "latency" in items and not LATENCY_RE.match(items["latency"]):
                errors.append((rl_lineno, "latency reads `<int>s` or `unresolved`"))
            if "opportunity" in items and items["opportunity"] not in OPPORTUNITIES:
                errors.append((rl_lineno, f"opportunity {items['opportunity']!r} must be "
                                          f"one of {OPPORTUNITIES}"))
            if "purpose" in items and items["purpose"] not in PURPOSES:
                errors.append((rl_lineno, f"purpose must be one of {PURPOSES}"))
            if "provenance" in items and items["provenance"] not in PROVENANCES:
                errors.append((rl_lineno, f"provenance must be one of {PROVENANCES}"))
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


def panel_usable(round_lines):
    """Rounds the panel mapping spans, in run order: every round whose
    outcome carries panel verdicts. Skipped outcomes (SKIPPED_OUTCOMES)
    meet no panel section, whatever numbers they consumed, so usable
    rounds meet panel sections 1..k."""
    return [(n, items) for _, n, items in round_lines
            if items.get("outcome") not in SKIPPED_OUTCOMES]


def check_panel_rounds(runs):
    """Panel runs re-read their round verdicts: numbers, models, full lenses.

    Skipped rounds carry no verdicts and are skipped in the mapping:
    usable rounds meet panel sections 1..k in run order."""
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
        usable = panel_usable(run.round_lines)
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
            if items.get("model") not in FAMILY_MODELS[family]:
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
        try:
            hit = subprocess.run(["git", "cat-file", "-t", sha], cwd=ROOT,
                                 capture_output=True, text=True, timeout=30)
        except (OSError, subprocess.SubprocessError) as exc:
            errors.append((0, f"candidate {sha} could not be checked: git failed ({exc})"))
            continue
        if hit.returncode != 0 or hit.stdout.strip() != "commit":
            errors.append((0, f"candidate {sha} is not a commit in this repository"))
    return errors


def run_check(runs_path, collected=None, review_sections=None):
    """Check the runs file. `collected` overrides the ledger read, so one
    TF.collect() serves the check and the report (§17); `review_sections`
    overrides the review-file scan the same way, so main-level drives
    stay hermetic (D00 T04 §22). Errors return as (code, lineno, message),
    one code per checking phase; the phases themselves still append plain
    (lineno, message) pairs."""
    try:
        text = io.open(runs_path, encoding="utf-8").read()
    except OSError as exc:
        return [], [("RUN-002", 0, f"cannot read {runs_path}: {exc}")]
    runs, errors = parse_runs(text)
    tagged = [("RUN-002", lineno, msg) for lineno, msg in errors]
    shape: list = []
    check_runs(runs, shape)
    tagged += [("RUN-003", lineno, msg) for lineno, msg in shape]
    if not tagged:
        tagged += [("RUN-004", lineno, msg)
                   for lineno, msg in cross_check(runs, collected, review_sections)]
        tagged += [("RUN-005", lineno, msg)
                   for lineno, msg in check_panel_rounds(runs)]
        tagged += [("RUN-006", lineno, msg)
                   for lineno, msg in check_candidates(runs)]
    return runs, tagged


def _corpus_clean() -> bool:
    """The findings corpus matches HEAD: no staged, unstaged, or
    untracked difference under docs/reviews. The export and report read
    dispositions and counts from these files beside the runs file, so
    any difference would postdate the bound commit and voids it."""
    try:
        status = subprocess.run(["git", "status", "--porcelain=v1", "-z",
                                 "--", "docs/reviews"],
                                cwd=ROOT, capture_output=True, text=True, timeout=30)
    except (OSError, subprocess.SubprocessError):
        return False
    return status.returncode == 0 and not status.stdout


def as_of(runs_path):
    """The report's binding: the HEAD commit whose tree holds exactly the
    exported bytes, plus a UTC timestamp. Content identity, not a label:
    the file's hash must equal HEAD's copy of it, and the findings
    corpus must match HEAD too, so a dirty tree, an older file, or any
    other path reads `unresolved` rather than borrowing the checkout's
    HEAD. Never guessed: a report that cannot name its commit says so."""
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    try:
        hit = subprocess.run(["git", "rev-parse", "HEAD"], cwd=ROOT,
                             capture_output=True, text=True, timeout=30)
        sha = hit.stdout.strip() if hit.returncode == 0 else ""
    except (OSError, subprocess.SubprocessError):
        sha = ""
    if not SHA_RE.match(sha) or len(sha) != 40:
        return {"commit": "unresolved", "timestamp": stamp}
    try:
        rel = Path(runs_path).resolve().relative_to(ROOT).as_posix()
        have = subprocess.run(["git", "hash-object", str(runs_path)], cwd=ROOT,
                              capture_output=True, text=True, timeout=30)
        want = subprocess.run(["git", "rev-parse", f"HEAD:{rel}"], cwd=ROOT,
                              capture_output=True, text=True, timeout=30)
    except (OSError, subprocess.SubprocessError, ValueError):
        return {"commit": "unresolved", "timestamp": stamp}
    if have.returncode != 0 or want.returncode != 0:
        return {"commit": "unresolved", "timestamp": stamp}
    if have.stdout.strip() != want.stdout.strip():
        return {"commit": "unresolved", "timestamp": stamp}
    if not _corpus_clean():
        return {"commit": "unresolved", "timestamp": stamp}
    return {"commit": sha, "timestamp": stamp}


def coverage_lines(runs):
    """Recorded-vs-unresolved counts per field and model over round lines."""
    lines = ["Coverage (recorded vs unresolved, by field and model):"]
    rounds = [items for run in runs for _, _, items in run.round_lines]
    models = sorted({items.get("model", "?") for items in rounds})
    for field in ("cost", "latency", "version"):
        per = [(m, sum(1 for items in rounds
                       if items.get("model", "?") == m and items.get(field) != "unresolved"),
                sum(1 for items in rounds if items.get("model", "?") == m))
               for m in models]
        got = sum(g for _, g, _ in per)
        detail = ", ".join(f"{m} {g}/{t}" for m, g, t in per)
        lines.append(f"- {field}: {got}/{len(rounds)} recorded ({detail})")
    return lines


def cost_lines(runs):
    """Recorded cost totals: grand, per model, then per round."""
    lines = ["Cost (recorded tokens; USD prices outside the record):"]
    known = [(run.section, n, items["cost"], items.get("model", "?"))
             for run in runs for _, n, items in run.round_lines
             if items.get("cost") != "unresolved"]
    total_rounds = sum(run.rounds or 0 for run in runs)
    if not known:
        lines.append(f"- no recorded cost ({total_rounds}/{total_rounds} unresolved)")
        return lines
    total_tokens = sum(int(cost[:-6]) for _, _, cost, _ in known)
    lines.append(f"- {len(known)}/{total_rounds} rounds recorded, {total_tokens} tokens")
    per_model: dict[str, list[int]] = {}
    for _, _, cost, model in known:
        slot = per_model.setdefault(model, [0, 0])
        slot[0] += int(cost[:-6])
        slot[1] += 1
    for model in sorted(per_model):
        tokens, rounds_n = per_model[model]
        lines.append(f"- {model}: {tokens} tokens over {rounds_n} recorded round(s)")
    for section, n, cost, _model in known:
        lines.append(f"- {section} round {n}: {cost}")
    return lines


def revisit_lines(runs):
    """The §18 trigger from the query: panel sections past the §8 window."""
    past = [run.section for run in runs
            if run.runner == "panel" and run.section not in REVISIT_WINDOW]
    lines = ["Revisit trigger (§18 past the §8 window of five: "
             f"{', '.join(REVISIT_WINDOW)}):"]
    state = "trigger met" if len(past) >= REVISIT_NEED else "trigger open"
    names = ", ".join(past) if past else "none"
    lines.append(f"- {len(past)}/{REVISIT_NEED} panel-reviewed sections past the window "
                 f"({names}): {state}")
    return lines


def _read_bank(bank_path):
    """Banked blinded comparisons, or the reason the bank won't read."""
    try:
        text = Path(bank_path).read_text(encoding="utf-8")
    except OSError as exc:
        return [], f"bank unreadable ({exc.strerror or exc})"
    comps, bad = [], None
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        match = COMPARISON_RE.match(stripped)
        if match is None:
            bad = f"bank line unparsed: {stripped}"
            break
        try:
            jaccard = float(match.group("jaccard"))
        except ValueError:
            bad = f"bank jaccard unparsed: {stripped}"
            break
        comps.append({"dir": match.group("dir"), "class": match.group("class"),
                      "jaccard": jaccard, "pairs": int(match.group("pairs")),
                      "union": int(match.group("union"))})
    return comps, bad


def leg_lines(runs, findings, bank_path=None):
    """The §20 interim cut-leg assessment between revisits: trailing
    full-scope zero sections per panel rung (fix-loop sections and
    sections with no full-scope round for the rung are invisible,
    per §18 consecutiveness), and the banked overlap comparisons
    with their activation state. A zero is a section whose full-scope
    rounds raised no surviving finding; surviving means a ledger
    disposition outside the never-defect triple, and unresolvable
    refs count as finds."""
    by_ref = {}
    for f in findings:
        by_ref.setdefault(f"{_compact_section(f.ref)}-{f.number}", f.disposition)
    panel = [run for run in runs if run.runner == "panel"]
    lines = ["Cut-leg interim (§20 between-revisit watch):"]
    bits = []
    for family in CUT_LEG_FAMILIES:
        models = FAMILY_MODELS[family]
        sections = []
        for run in panel:
            full = [items for _, _, items in run.round_lines
                    if items.get("model") in models
                    and items.get("opportunity") == "full-scope"]
            if not full:
                continue
            zero = not any(by_ref.get(ref, "unresolved") not in ZERO_BLIND_DISPOSITIONS
                           for items in full for ref in items.get("findings", []))
            sections.append(zero)
        if not sections:
            bits.append(f"{family}: no full-scope round observed")
            continue
        run_len = 0
        for zero in reversed(sections):
            if not zero:
                break
            run_len += 1
        bit = f"{family}: {run_len} trailing full-scope zero(s)"
        if run_len >= 3:
            bit += (" FIRED -- file the early revisit (D00 T04 §23 trigger) "
                    "with these lines quoted")
        bits.append(bit)
    lines.append("- zero runs (trailing full-scope zero sections per rung, "
                 "fix-loop invisible): " + "; ".join(bits))
    comps, bad = _read_bank(bank_path or DEFAULT_BANK)
    if bad is not None:
        lines.append(f"- overlap comparisons banked: {bad}: DORMANT (unmeasured)")
        lines.append(f"- bank freshness: {bad}: unmeasured")
        return lines
    classes = sorted({c["class"] for c in comps})
    detail = "; ".join(f"{c['class']} Jaccard {c['jaccard']:.2f} "
                       f"over union {c['union']}" for c in comps) or "none banked"
    if len(comps) >= 2 and len(classes) >= 2:
        mean = sum(c["jaccard"] for c in comps) / len(comps)
        state = f"ACTIVE, mean Jaccard {mean:.2f}"
        if mean > 0.5:
            # ARMED, never FIRED (D00 T04 §20 round 1 F3): the Jaccard
            # half is met, but the cut also needs the trailing rung's
            # value-per-cost below half the leader's, which only
            # blinded ratings can supply. The revisit runs that half;
            # the interim watch cannot announce a cut the rule would
            # not fire.
            state += (" ARMED (Jaccard half met, blinded value half pending) "
                      "-- file the early revisit (D00 T04 §23 trigger) "
                      "with these lines quoted")
    else:
        state = "DORMANT (activation needs 2 spanning 2 classes)"
    lines.append(f"- overlap comparisons banked: {len(comps)} spanning "
                 f"{len(classes)} class(es) ({detail}): {state}")
    if not comps:
        since = len(panel)
        head, tail, past = "none banked", "panel sections on record", 1
        stale = since >= past
    else:
        # Newest by directory, not by list position (panel round 5
        # F19): a hand-appended out-of-order bank line made the
        # last-listed entry pose as newest, so `since` under-counted
        # and the leg read fresh on overdue calibration.
        newest = max(c["dir"] for c in comps)
        newest_date = newest[:10] if DATE_RE.match(newest[:10]) else None
        if newest_date is None:
            since = len(panel)
            head, tail, past = f"{newest} (undated)", "panel sections on record", 1
            stale = since >= past
        else:
            since = sum(1 for run in panel if run.date and run.date > newest_date)
            head, tail, past = newest, "panel sections since", BANK_STALE_AFTER
            stale = since >= past
    if stale:
        fresh = (f"STALE (calibration owed past {past}) "
                 "-- file the early revisit (D00 T04 \u00a723 trigger) "
                 "with these lines quoted")
    else:
        fresh = "fresh"
    lines.append(f"- bank freshness: newest banked {head}; {since} {tail}: {fresh}")
    return lines


def report(runs, runs_path, collected=None):
    """The run dimensions. `collected` overrides the ledger reads, so one
    TF.collect() serves the check and the report (§17)."""
    lines = []
    findings, _bad = collected if collected is not None else TF.collect()
    binding = as_of(runs_path)
    lines.append(f"as-of: {binding['commit']} {binding['timestamp']}")
    lines.append(f"{len(runs)} review runs, "
                 f"{sum(r.rounds or 0 for r in runs)} independent rounds.")
    empty_engagements = sum(1 for r in runs if all(
        items.get("outcome") == "empty" for _, _, items in r.round_lines))
    lines.append(f"{len(runs)} engagements, {empty_engagements} empty, "
                 f"{sum(r.refuted or 0 for r in runs)} refuted.")
    lines.append("")
    lines.append("Findings by model (rounds, findings raised, refuted among them):")
    by_model: dict[str, list] = {}
    for run in runs:
        for _lineno, _n, items in run.round_lines:
            slot = by_model.setdefault(items.get("model", "?"), [0, 0])
            slot[0] += 1
            slot[1] += len(items.get("findings", []))
    refuted_by_model: dict[str, int] = {}
    by_ref = {f"{_compact_section(f.ref)}-{f.number}": f for f in findings}
    for run in runs:
        for _lineno, _n, items in run.round_lines:
            got = sum(1 for ref in items.get("findings", [])
                      if ref in by_ref and by_ref[ref].disposition == "refuted")
            if got:
                refuted_by_model[items.get("model", "?")] = \
                    refuted_by_model.get(items.get("model", "?"), 0) + got
    for model in sorted(by_model):
        rounds_n, raised = by_model[model]
        lines.append(f"- {model}: {rounds_n} round(s), {raised} raised, "
                     f"{refuted_by_model.get(model, 0)} refuted")
    lines.append("")
    lines.extend(cost_lines(runs))
    lines.append("")
    lines.extend(coverage_lines(runs))
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
    lines.append("")
    lines.extend(revisit_lines(runs))
    lines.append("")
    lines.extend(leg_lines(runs, findings))
    lines.append("")
    lines.extend(TRIGGER_LEGEND)
    return "\n".join(lines) + "\n"


def export_runs(runs, runs_path, collected=None):
    """The machine export §8 consumes: versioned JSON with the as-of
    binding and every run's rounds. Consumers assert export_version
    before reading anything else. Every round line carries its refs'
    ledger dispositions, so a snapshot consumer computes accepted yield
    without rejoining live records that may postdate the as-of.
    `collected` overrides the ledger read for tests."""
    findings, _bad = collected if collected is not None else TF.collect()
    by_ref = {}
    for f in findings:
        by_ref.setdefault(f"{_compact_section(f.ref)}-{f.number}", f.disposition)
    return {
        "export_version": EXPORT_VERSION,
        "schema": SCHEMA_VERSION,
        "as_of": as_of(runs_path),
        "runs": [
            {
                "section": run.section,
                "date": run.date,
                "runner": run.runner,
                "rounds": run.rounds,
                "empty": run.empty,
                "refuted": run.refuted,
                "round_lines": [
                    {"number": n, **{k: items.get(k) for k in REQUIRED_ROUND_KEYS
                                    if k in items},
                     "findings": list(items.get("findings", [])),
                     "dispositions": {ref: by_ref.get(ref, "unresolved")
                                      for ref in items.get("findings", [])}}
                    for _, n, items in sorted(run.round_lines, key=lambda r: r[1])
                ],
            }
            for run in runs
        ],
    }


def _is_int(value):
    return isinstance(value, int) and not isinstance(value, bool)


def _commit_resolves(sha):
    """The as-of binding resolves to a commit in this repository. Needs git."""
    try:
        hit = subprocess.run(["git", "cat-file", "-t", sha], cwd=ROOT,
                             capture_output=True, text=True, timeout=30)
    except (OSError, subprocess.SubprocessError):
        return False
    return hit.returncode == 0 and hit.stdout.strip() == "commit"


def check_export(doc):
    """Assert an export file: version, shape, values, internal counts.
    Returns a list of messages (empty means sound). Every closed set the
    parser enforces is re-asserted here, so a hand-edited export cannot
    smuggle values the records could never hold. The as-of binds the
    snapshot: a well-formed commit must resolve here, so a fabricated
    binding fails instead of riding an `internally sound` verdict.
    Byte-agreement with the bound tree is NOT checked here, a snapshot
    is a moment, so `refuted` is bounded by the listed refs rather than
    proven against the ledger; consumers regenerate at consume time
    rather than trusting handed files. Dispositions ride per ref so the
    snapshot stands alone; a value outside the ledger set fails."""
    problems = []
    if not isinstance(doc, dict):
        return ["export is not an object"]
    if not _is_int(doc.get("export_version")):
        problems.append(f"export_version must be an int, got "
                        f"{type(doc.get('export_version')).__name__}")
        return problems
    if doc.get("export_version") != EXPORT_VERSION:
        problems.append(f"export_version is {doc.get('export_version')!r}, "
                        f"this checker asserts {EXPORT_VERSION}")
        return problems
    if not _is_int(doc.get("schema")):
        problems.append(f"schema must be an int, got "
                        f"{type(doc.get('schema')).__name__}")
    elif doc.get("schema") != SCHEMA_VERSION:
        problems.append(f"schema is {doc.get('schema')!r}, "
                        f"this checker asserts {SCHEMA_VERSION}")
    as_of_doc = doc.get("as_of", {})
    commit = as_of_doc.get("commit") if isinstance(as_of_doc, dict) else None
    stamp = as_of_doc.get("timestamp") if isinstance(as_of_doc, dict) else None
    if commit != "unresolved" and not (isinstance(commit, str) and len(commit) == 40
                                       and SHA_RE.match(commit)):
        problems.append("as_of commit is neither a full sha nor `unresolved`")
    elif isinstance(commit, str) and len(commit) == 40 and SHA_RE.match(commit) \
            and not _commit_resolves(commit):
        problems.append("as_of commit resolves to no commit in this repository")
    if not (isinstance(stamp, str) and TIMESTAMP_RE.match(stamp)):
        problems.append("as_of timestamp is not UTC `YYYY-MM-DDTHH:MM:SSZ`")
    runs = doc.get("runs")
    if not isinstance(runs, list):
        problems.append("runs is not a list")
        return problems
    seen = set()
    homed: dict[str, str] = {}
    for run in runs:
        if not isinstance(run, dict):
            problems.append("a run entry is not an object")
            continue
        section = run.get("section", "?")
        if not isinstance(section, str):
            problems.append(f"a run entry names its section with {section!r}, not a string")
            section = "?"
        if section in seen:
            problems.append(f"{section}: duplicate run entry")
        seen.add(section)
        if not (isinstance(run.get("date"), str) and DATE_RE.match(run["date"])):
            problems.append(f"{section}: date is not YYYY-MM-DD")
        if run.get("runner") not in RUNNERS:
            problems.append(f"{section}: runner must be one of {RUNNERS}")
        for key in ("rounds", "empty", "refuted"):
            if not _is_int(run.get(key)) or run[key] < 0:
                problems.append(f"{section}: {key} must be a non-negative int")
        if _is_int(run.get("rounds")) and run["rounds"] < 1:
            problems.append(f"{section}: rounds must be a positive number")
        lines = run.get("round_lines", [])
        if not isinstance(lines, list):
            problems.append(f"{section}: round_lines is not a list")
            continue
        if run.get("rounds") != len(lines):
            problems.append(f"{section}: rounds says {run.get('rounds')} but "
                            f"{len(lines)} round lines present")
        numbers = sorted(line["number"] for line in lines
                         if isinstance(line, dict) and _is_int(line.get("number")))
        if any(not (isinstance(line, dict) and _is_int(line.get("number"))) for line in lines):
            problems.append(f"{section}: every round line numbers itself with an int")
        if numbers != list(range(1, len(lines) + 1)):
            problems.append(f"{section}: round numbers must run 1..N, got {numbers}")
        empties = sum(1 for line in lines if isinstance(line, dict)
                      and line.get("outcome") == "empty")
        if run.get("empty") != empties:
            problems.append(f"{section}: empty says {run.get('empty')} but "
                            f"{empties} round(s) came back empty")
        listed = sum(len(line["findings"]) for line in lines
                     if isinstance(line, dict) and isinstance(line.get("findings"), list))
        if _is_int(run.get("refuted")) and run["refuted"] > listed:
            problems.append(f"{section}: refuted says {run['refuted']} but "
                            f"only {listed} ref(s) listed")
        for line in lines:
            if not isinstance(line, dict):
                problems.append(f"{section}: a round line is not an object")
                continue
            missing = [k for k in REQUIRED_ROUND_KEYS if k not in line] + \
                [k for k in ("findings", "dispositions") if k not in line]
            if missing:
                problems.append(f"{section} round {line.get('number')}: misses {', '.join(missing)}")
                continue
            num = line.get("number")
            if not (isinstance(line.get("model"), str) and line["model"]):
                problems.append(f"{section} round {num}: model is not a name")
            if line.get("effort") not in EFFORTS:
                problems.append(f"{section} round {num}: effort must be one of {EFFORTS}")
            if line.get("outcome") not in OUTCOMES:
                problems.append(f"{section} round {num}: outcome must be one of {OUTCOMES}")
            if not (isinstance(line.get("candidate"), str) and SHA_RE.match(line["candidate"])):
                problems.append(f"{section} round {num}: candidate is not a hex sha")
            if line.get("provider") not in PROVIDERS:
                problems.append(f"{section} round {num}: provider must be one of {PROVIDERS}")
            if not (isinstance(line.get("version"), str) and line["version"]):
                problems.append(f"{section} round {num}: version is not a name")
            if not (isinstance(line.get("cost"), str) and COST_RE.match(line["cost"])):
                problems.append(f"{section} round {num}: cost reads `<int>tokens` or `unresolved`")
            if not (isinstance(line.get("latency"), str) and LATENCY_RE.match(line["latency"])):
                problems.append(f"{section} round {num}: latency reads `<int>s` or `unresolved`")
            if line.get("opportunity") not in OPPORTUNITIES:
                problems.append(f"{section} round {num}: opportunity "
                                f"{line.get('opportunity')!r} must be one of {OPPORTUNITIES}")
            if line.get("purpose") not in PURPOSES:
                problems.append(f"{section} round {num}: purpose must be one of {PURPOSES}")
            if line.get("provenance") not in PROVENANCES:
                problems.append(f"{section} round {num}: provenance must be one of {PROVENANCES}")
            refs = line.get("findings")
            if not isinstance(refs, list):
                problems.append(f"{section} round {num}: findings is not a list")
            else:
                for ref in refs:
                    if not (isinstance(ref, str) and REF_RE.match(ref)):
                        problems.append(f"{section} round {num}: ref {ref!r} is not D..-T..-S..-F<n>")
                        continue
                    home = ref.rsplit("-F", 1)[0]
                    if home != section:
                        problems.append(f"{section} round {num}: ref {ref} belongs to {home}")
                    if ref in homed:
                        problems.append(f"{ref} claimed twice: {homed[ref]} and "
                                        f"{section} round {num}")
                    else:
                        homed[ref] = f"{section} round {num}"
                if line.get("outcome") == "empty" and refs:
                    problems.append(f"{section} round {num}: an empty round lists no findings")
            disps = line.get("dispositions")
            if not isinstance(disps, dict):
                problems.append(f"{section} round {num}: dispositions is not an object")
            elif isinstance(refs, list):
                for ref in refs:
                    if not isinstance(ref, str):
                        continue  # already reported above
                    if ref not in disps:
                        problems.append(f"{section} round {num}: ref {ref} carries "
                                        f"no disposition")
                    elif disps[ref] not in TF.DISPOSITIONS:
                        problems.append(f"{section} round {num}: ref {ref} disposition "
                                        f"{disps[ref]!r} is outside the ledger set")
                for ref in disps:
                    if ref not in refs:
                        problems.append(f"{section} round {num}: disposition for {ref} "
                                        f"names no listed ref")
    return problems


def export_sound_line(doc):
    """The --check-export PASS line: version, run count, and the as-of
    binding, so a gate quote of the count rides its producing commit."""
    as_of_doc = doc.get("as_of", {})
    commit = as_of_doc.get("commit") if isinstance(as_of_doc, dict) else None
    return (f"export version {EXPORT_VERSION}, {len(doc['runs'])} runs, "
            f"as-of {commit}, internally sound")


def _self_test():
    failures = []
    total = [0]

    def check(name, cond, detail=""):
        total[0] += 1
        if not cond:
            failures.append(f"{name}: {detail or 'failed'}")

    good = """schema: 1
run: D00-T01-S1
date: 2026-09-17
runner: codex
rounds: 2
round: 1 model: gpt-6-astra effort: high outcome: findings candidate: 6bb635e provider: openai version: gpt-6-astra cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: reconstructed findings: D00-T01-S1-F1, D00-T01-S1-F2
round: 2 model: gpt-6-astra effort: high outcome: empty candidate: 8437dd5 provider: openai version: gpt-6-astra cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: fix-loop provenance: reconstructed findings:
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

    no_findings_key = good.replace("provenance: reconstructed findings:",
                                    "provenance: reconstructed")
    _r, errors_k = parse_runs(no_findings_key)
    check("missing-findings-key-fails", any("misses findings" in m for _, m in errors_k),
          f"{errors_k}")

    run_level = good.replace("round: 2 model", "findings: D00-T01-S1-F9\nround: 2 model")
    _r, errors_l = parse_runs(run_level)
    check("run-level-findings-fails", any("moved to the round lines" in m for _, m in errors_l),
          f"{errors_l}")

    empty_with = good.replace("purpose: fix-loop provenance: reconstructed findings:",
                              "purpose: fix-loop provenance: reconstructed findings: D00-T01-S1-F9")
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
    check("unreadable-reported",
          runs_u == [] and errors_u
          and errors_u[0][0] == "RUN-002"
          and any("cannot read" in m for _, _, m in errors_u),
          f"{runs_u} {errors_u}")

    no_schema = good.replace("schema: 1\n", "")
    _r, errors_s = parse_runs(no_schema)
    check("missing-schema-fails", any("no schema declaration" in m for _, m in errors_s),
          f"{errors_s}")
    wrong_schema = good.replace("schema: 1\n", "schema: 99\n")
    _r, errors_v = parse_runs(wrong_schema)
    check("wrong-schema-fails", any("is not 1" in m for _, m in errors_v), f"{errors_v}")
    late_schema = good.replace("empty: 1\n", "empty: 1\nschema: 1\n")
    _r, errors_t = parse_runs(late_schema)
    check("late-schema-fails", any("ahead of the first run" in m for _, m in errors_t),
          f"{errors_t}")

    no_provider = good.replace("provider: openai ", "")
    _r, errors_p = parse_runs(no_provider)
    check_runs(_r, errors_p)
    check("missing-provider-fails", any("misses provider" in m for _, m in errors_p),
          f"{errors_p}")
    for bad_key, orig, bad_val, want in (("provider", "openai", "xai", "provider must be"),
                                          ("outcome", "findings", "vibes", "outcome must be"),
                                          ("cost", "unresolved", "12", "cost reads"),
                                          ("cost", "unresolved", "12 dollars", "cost reads"),
                                          ("latency", "unresolved", "soon", "latency reads"),
                                          ("opportunity", "full-scope", "partial",
                                           "opportunity 'partial' must be"),
                                          ("purpose", "section-review", "vibes", "purpose must be"),
                                          ("provenance", "reconstructed", "oral-tradition",
                                           "provenance must be")):
        bad = good.replace(f"{bad_key}: {orig}", f"{bad_key}: {bad_val}", 1)
        _r, errors_g = parse_runs(bad)
        check_runs(_r, errors_g)
        check(f"bad-{bad_key}-fails", any(want in m for _, m in errors_g), f"{errors_g}")
    # §20: the opportunity refusal names the label, and the accepted triple passes.
    mislabeled = good.replace("opportunity: full-scope", "opportunity: partial", 1)
    _r, errors_m = parse_runs(mislabeled)
    check_runs(_r, errors_m)
    check("bad-opportunity-names-label",
          any("opportunity 'partial' must be one of" in m for _, m in errors_m),
          f"{errors_m}")
    for label in OPPORTUNITIES:
        relabeled = good.replace("opportunity: full-scope", f"opportunity: {label}", 1)
        _r, errors_l = parse_runs(relabeled)
        check_runs(_r, errors_l)
        check(f"opportunity-{label}-passes",
              not any("opportunity" in m for _, m in errors_l), f"{errors_l}")

    import tempfile
    tmp = Path(tempfile.mkdtemp(prefix="todo-runs-"))
    other = tmp / "other-records.md"
    other.write_text(good, encoding="utf-8")
    exported = export_runs(runs, other)
    check("export-version", exported["export_version"] == EXPORT_VERSION, f"{exported!r}"[:200])
    check("export-round-trip", check_export(exported) == [], f"{check_export(exported)}")
    tampered = json.loads(json.dumps(exported))
    tampered["export_version"] = 99
    check("export-version-asserted",
          any("export_version" in m for m in check_export(tampered)), f"{check_export(tampered)}")
    tampered = json.loads(json.dumps(exported))
    tampered["export_version"] = True
    check("export-version-not-bool",
          any("export_version must be an int, got bool" in m for m in check_export(tampered)),
          f"{check_export(tampered)}")
    tampered = json.loads(json.dumps(exported))
    tampered["schema"] = True
    check("export-schema-not-bool",
          any("schema must be an int, got bool" in m for m in check_export(tampered)),
          f"{check_export(tampered)}")
    tampered = json.loads(json.dumps(exported))
    tampered["runs"][0]["rounds"] = 99
    check("export-counts-asserted",
          any("rounds says 99" in m for m in check_export(tampered)), f"{check_export(tampered)}")

    # Round 1 hardened the export checker past presence: values now assert.
    tampered = json.loads(json.dumps(exported))
    tampered["as_of"]["commit"] = "xyz"
    tampered["as_of"]["timestamp"] = "soon"
    tampered["schema"] = 99
    shape = check_export(tampered)
    check("export-binding-asserted",
          any("neither a full sha" in m for m in shape)
          and any("not UTC" in m for m in shape)
          and any("schema is 99" in m for m in shape), f"{shape}")
    tampered = json.loads(json.dumps(exported))
    tampered["runs"][0]["date"] = "yesterday"
    tampered["runs"][0]["runner"] = "speedy"
    tampered["runs"][0]["rounds"] = "2"
    meta = check_export(tampered)
    check("export-runmeta-asserted",
          any("not YYYY-MM-DD" in m for m in meta)
          and any("runner must be" in m for m in meta)
          and any("rounds must be a non-negative int" in m for m in meta), f"{meta}")
    tampered = json.loads(json.dumps(exported))
    tampered["runs"][0]["round_lines"][0]["effort"] = "extreme"
    tampered["runs"][0]["round_lines"][0]["cost"] = "free"
    tampered["runs"][0]["round_lines"][0]["findings"] = "D00-T01-S1-F1"
    vals = check_export(tampered)
    check("export-roundvals-asserted",
          any("effort must be" in m for m in vals)
          and any("cost reads" in m for m in vals)
          and any("findings is not a list" in m for m in vals), f"{vals}")
    tampered = json.loads(json.dumps(exported))
    tampered["runs"][0]["refuted"] = 99
    check("export-refuted-bounded",
          any("only 2 ref(s) listed" in m for m in check_export(tampered)),
          f"{check_export(tampered)}")
    tampered = json.loads(json.dumps(exported))
    tampered["runs"][0]["round_lines"][1]["findings"] = ["D00-T01-S1-F9"]
    check("export-empty-clean",
          any("empty round lists no findings" in m for m in check_export(tampered)),
          f"{check_export(tampered)}")

    # Round 2 closed the crash and the silent shapes: unhashable sections,
    # zero-round runs, mis-homed and double-claimed refs.
    tampered = json.loads(json.dumps(exported))
    tampered["runs"][0]["section"] = ["D00-T01-S1"]
    check("export-section-typed",
          any("not a string" in m for m in check_export(tampered)),
          f"{check_export(tampered)}")
    tampered = json.loads(json.dumps(exported))
    tampered["runs"][0]["rounds"] = 0
    tampered["runs"][0]["round_lines"] = []
    tampered["runs"][0]["empty"] = 0
    check("export-rounds-positive",
          any("positive number" in m for m in check_export(tampered)),
          f"{check_export(tampered)}")
    tampered = json.loads(json.dumps(exported))
    tampered["runs"][0]["round_lines"][0]["findings"] = ["D00-T01-S9-F1"]
    check("export-ref-homed",
          any("belongs to D00-T01-S9" in m for m in check_export(tampered)),
          f"{check_export(tampered)}")
    tampered = json.loads(json.dumps(exported))
    tampered["runs"][0]["round_lines"][0]["findings"] = ["D00-T01-S1-F1",
                                                         "D00-T01-S1-F1"]
    check("export-ref-unique",
          any("claimed twice" in m for m in check_export(tampered)),
          f"{check_export(tampered)}")

    # §15: skipped outcomes parse, and the panel mapping spans usable only.
    shapes = """schema: 1
run: D00-T01-S9
date: 2026-09-20
runner: panel
rounds: 5
round: 1 model: gpt-5.6-sol effort: medium outcome: findings candidate: 6bb635e provider: openai version: gpt-5.6-sol cost: 12tokens latency: 34s opportunity: full-scope purpose: section-review provenance: recorded findings: D00-T01-S9-F1
round: 2 model: gpt-5.6-sol effort: medium outcome: error candidate: 8437dd5 provider: openai version: gpt-5.6-sol cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: fix-loop provenance: recorded findings:
round: 3 model: gpt-5.6-sol effort: medium outcome: findings candidate: 8437dd5 provider: openai version: gpt-5.6-sol cost: unresolved latency: unresolved opportunity: delta-plus-regressions purpose: fix-loop provenance: recorded findings:
round: 4 model: opus effort: medium outcome: independent candidate: 8437dd5 provider: anthropic version: unresolved cost: unresolved latency: unresolved opportunity: full-scope purpose: section-review provenance: recorded findings: D00-T01-S9-F2
round: 5 model: gpt-5.6-sol effort: high outcome: stamp candidate: 8437dd5 provider: openai version: gpt-5.6-sol cost: unresolved latency: unresolved opportunity: full-scope purpose: stamp-review provenance: recorded findings:
empty: 0
refuted: 0
"""
    runs_k, errors_k = parse_runs(shapes)
    check_runs(runs_k, errors_k)
    check("skipped-outcomes-parse", not errors_k, f"{errors_k}")
    usable_k = panel_usable(runs_k[0].round_lines)
    check("mapping-skips-nonpanel", [n for n, _ in usable_k] == [1, 3], f"{usable_k}")

    # §15: unresolved-field coverage per field and model.
    cov = coverage_lines(runs_k)
    check("coverage-fields", cov == [
        "Coverage (recorded vs unresolved, by field and model):",
        "- cost: 1/5 recorded (gpt-5.6-sol 1/4, opus 0/1)",
        "- latency: 1/5 recorded (gpt-5.6-sol 1/4, opus 0/1)",
        "- version: 4/5 recorded (gpt-5.6-sol 4/4, opus 0/1)",
    ], f"{cov}")

    # §20: the cost report reads both runners.
    both = shapes.replace("provider: anthropic version: unresolved cost: unresolved",
                          "provider: anthropic version: opus cost: 8tokens", 1)
    runs_b, errors_b = parse_runs(both)
    check_runs(runs_b, errors_b)
    check("cost-both-runners-parse", not errors_b, f"{errors_b}")
    lines_b = cost_lines(runs_b)
    check("cost-per-model", lines_b == [
        "Cost (recorded tokens; USD prices outside the record):",
        "- 2/5 rounds recorded, 20 tokens",
        "- gpt-5.6-sol: 12 tokens over 1 recorded round(s)",
        "- opus: 8 tokens over 1 recorded round(s)",
        "- D00-T01-S9 round 1: 12tokens",
        "- D00-T01-S9 round 4: 8tokens",
    ], f"{lines_b}")

    # §20: the candidate check reports git failure instead of tracing.
    mock_run = Run("D00-T01-S9", 1)
    mock_run.round_lines = [(0, 1, {"candidate": "6bb635e"})]
    real_subprocess_run = subprocess.run

    def _boom(*_a, **_k):
        raise OSError("drill: git missing")

    subprocess.run = _boom
    try:
        cand_errs = check_candidates([mock_run])
    finally:
        subprocess.run = real_subprocess_run
    check("candidates-git-failure-reports",
          any("could not be checked" in m and "6bb635e" in m for _, m in cand_errs),
          f"{cand_errs}")

    # §15: the §18 trigger reads from the query, window named.
    def _mkrun(section, runner):
        run = Run(section, 1)
        run.runner = runner
        return run
    trig_open = [_mkrun(s, "panel") for s in REVISIT_WINDOW[:2]] + \
        [_mkrun("D00-T04-S11", "panel"), _mkrun("D00-T01-S1", "codex")]
    got_open = revisit_lines(trig_open)
    check("revisit-open", got_open == [
        "Revisit trigger (§18 past the §8 window of five: "
        "D00-T02-S5, D00-T04-S6, D00-T04-S7, D00-T04-S9, D00-T04-S10):",
        "- 1/5 panel-reviewed sections past the window (D00-T04-S11): trigger open",
    ], f"{got_open}")
    trig_met = [_mkrun(s, "panel") for s in REVISIT_WINDOW] + \
        [_mkrun(s, "panel") for s in ("D00-T04-S8", "D00-T04-S11", "D00-T04-S12",
                                      "D00-T04-S13", "D00-T04-S14")]
    got_met = revisit_lines(trig_met)
    check("revisit-met", got_met[1] == "- 5/5 panel-reviewed sections past the window "
          "(D00-T04-S8, D00-T04-S11, D00-T04-S12, D00-T04-S13, D00-T04-S14): "
          "trigger met", f"{got_met}")

    # §15: per-ref dispositions ride the export and the checker asserts them.
    f1 = TF.Finding("D00 T01 §1", None, 1, "F1", "s", "record", "fixed", None, "independent")
    f2 = TF.Finding("D00 T01 §1", None, 2, "F2", "s", "record", "refuted", None, "independent")
    injected = export_runs(runs, other, collected=([f1, f2], []))
    first = injected["runs"][0]["round_lines"][0]
    check("export-dispositions-carried",
          first["dispositions"] == {"D00-T01-S1-F1": "fixed",
                                    "D00-T01-S1-F2": "refuted"},
          f"{first['dispositions']}")
    check("export-dispositions-round-trip", check_export(injected) == [],
          f"{check_export(injected)}")
    tampered = json.loads(json.dumps(injected))
    del tampered["runs"][0]["round_lines"][0]["dispositions"]["D00-T01-S1-F1"]
    check("export-disposition-missing",
          any("carries no disposition" in m for m in check_export(tampered)),
          f"{check_export(tampered)}")
    tampered = json.loads(json.dumps(injected))
    tampered["runs"][0]["round_lines"][0]["dispositions"]["D00-T01-S1-F1"] = "vibes"
    check("export-disposition-valued",
          any("outside the ledger set" in m for m in check_export(tampered)),
          f"{check_export(tampered)}")
    tampered = json.loads(json.dumps(injected))
    tampered["runs"][0]["round_lines"][0]["dispositions"]["D00-T01-S1-F9"] = "fixed"
    check("export-disposition-homed",
          any("names no listed ref" in m for m in check_export(tampered)),
          f"{check_export(tampered)}")
    tampered = json.loads(json.dumps(injected))
    del tampered["runs"][0]["round_lines"][0]["dispositions"]
    check("export-dispositions-required",
          any("misses dispositions" in m for m in check_export(tampered)),
          f"{check_export(tampered)}")

    # §15: the sound line binds the count to its producing commit.
    check("export-sound-foreign",
          export_sound_line(injected) == f"export version {EXPORT_VERSION}, "
          f"1 runs, as-of {injected['as_of']['commit']}, internally sound",
          export_sound_line(injected))
    bound = {"export_version": EXPORT_VERSION, "runs": [{}, {}],
             "as_of": {"commit": "f" * 40, "timestamp": "2026-09-20T00:00:00Z"}}
    check("export-sound-commit",
          export_sound_line(bound) == f"export version {EXPORT_VERSION}, "
          f"2 runs, as-of {'f' * 40}, internally sound",
          export_sound_line(bound))

    # Round 2: a fabricated as-of fails even when well-formed; a real one holds.
    tampered = json.loads(json.dumps(injected))
    tampered["as_of"]["commit"] = "0" * 40
    check("export-asof-fabricated",
          any("resolves to no commit" in m for m in check_export(tampered)),
          f"{check_export(tampered)}")
    tampered = json.loads(json.dumps(injected))
    tampered["as_of"]["commit"] = "730a4db2185da1621d4c88ad013551d30b25b40e"
    check("export-asof-resolving",
          not any("resolves to no commit" in m or "neither a full sha" in m
                  for m in check_export(tampered)),
          f"{check_export(tampered)}")

    # §16: conflicting mode flags fail naming the conflict.
    old_err = sys.stderr
    sys.stderr = io.StringIO()
    try:
        conflict_code = main(["--report", "--export"])
        conflict_text = sys.stderr.getvalue()
    finally:
        sys.stderr = old_err
    check("report-export-conflict",
          conflict_code == 2 and "--report and --export conflict" in conflict_text,
          f"{conflict_code} {conflict_text!r}")

    # §16: a wrong schema draws exactly one message, never the false absence.
    bad_schema = good.replace("schema: 1", "schema: 99", 1)
    _r, errors_v = parse_runs(bad_schema)
    check("schema-version-exactly-one",
          errors_v == [(1, "schema 99 is not 1; this parser reads 1 only")],
          f"{errors_v}")

    # §17: one TF.collect() serves the check and the report.
    head_sha = subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=ROOT,
                              capture_output=True, text=True,
                              timeout=30).stdout.strip()
    one_text = good.replace("6bb635e", head_sha).replace("8437dd5", head_sha)
    one_path = tmp / "runs-one.md"
    one_path.write_text(one_text, encoding="utf-8")
    ind1 = TF.Finding("D00 T01 §1", None, 1, "F1", "s", "record", "fixed",
                      source="independent", severity="minor")
    ind2 = TF.Finding("D00 T01 §1", None, 2, "F2", "s", "record", "fixed",
                      source="independent", severity="minor")
    collect_calls = []
    real_collect = TF.collect
    real_files = _review_files
    TF.collect = lambda *a, **k: (collect_calls.append(1),
                                  ([ind1, ind2], []))[1]
    globals()["_review_files"] = lambda: {"D00-T01-S1"}
    old_out = sys.stdout
    sys.stdout = io.StringIO()
    try:
        one_code = main(["--report", str(one_path)])
    finally:
        sys.stdout = old_out
        TF.collect = real_collect
        globals()["_review_files"] = real_files
    one_path.unlink()
    check("report-single-collection",
          one_code == 0 and len(collect_calls) == 1,
          f"{one_code} {len(collect_calls)} collects")

    # Round 1 bound the as-of to content identity: HEAD only when HEAD's
    # tree holds exactly the exported bytes, `unresolved` otherwise.
    foreign = as_of(other)
    check("as-of-foreign-unresolved", foreign["commit"] == "unresolved", f"{foreign}")
    check("as-of-stamp-shaped", bool(TIMESTAMP_RE.match(foreign["timestamp"])), f"{foreign}")
    live = as_of(DEFAULT_RUNS)
    agree = subprocess.run(["git", "hash-object", str(DEFAULT_RUNS)], cwd=ROOT,
                           capture_output=True, text=True, timeout=30)
    want = subprocess.run(["git", "rev-parse", "HEAD:docs/reviews/run-records.md"], cwd=ROOT,
                          capture_output=True, text=True, timeout=30)
    head = subprocess.run(["git", "rev-parse", "HEAD"], cwd=ROOT,
                          capture_output=True, text=True, timeout=30)
    identical = (agree.returncode == 0 and want.returncode == 0
                 and agree.stdout.strip() == want.stdout.strip())
    st = subprocess.run(["git", "status", "--porcelain=v1", "-z", "--", "docs/reviews"],
                        cwd=ROOT, capture_output=True, text=True, timeout=30)
    corpus_clean = st.returncode == 0 and not st.stdout
    expect = head.stdout.strip() if (identical and corpus_clean) else "unresolved"
    check("as-of-agrees-with-git", live["commit"] == expect, f"{live} want {expect}")

    # §20: the interim leg query reads trailing zero runs and the bank.
    def _mkleg(section, rounds):
        run = _mkrun(section, "panel")
        run.round_lines = [(0, n + 1, items) for n, items in enumerate(rounds)]
        return run
    sol = FAMILY_MODELS["GPT"][0]
    leg_find = TF.Finding("D00 T04 §31", None, 1, "F1", "s", "record",
                          "fixed", None, "independent")
    leg_dead = TF.Finding("D00 T04 §31", None, 2, "F2", "s", "record",
                          "refuted", None, "independent")
    quiet_runs = [
        _mkleg("D00-T04-S31", [{"model": sol, "opportunity": "full-scope",
                                "findings": []}]),
        _mkleg("D00-T04-S32", [{"model": sol, "opportunity": "full-scope",
                                "findings": ["D00-T04-S31-F1"]}]),
    ]
    bank_one = tmp / "leg-bank-one.md"
    bank_one.write_text("comparison: 2026-09-20-s18 class: review-tooling "
                        "jaccard: 0.00 pairs: 0 union: 3\n", encoding="utf-8")
    got_quiet = leg_lines(quiet_runs, [leg_find, leg_dead], bank_one)
    check("legs-quiet", got_quiet == [
        "Cut-leg interim (§20 between-revisit watch):",
        "- zero runs (trailing full-scope zero sections per rung, fix-loop "
        "invisible): GPT: 0 trailing full-scope zero(s); "
        "Claude: no full-scope round observed",
        "- overlap comparisons banked: 1 spanning 1 class(es) "
        "(review-tooling Jaccard 0.00 over union 3): "
        "DORMANT (activation needs 2 spanning 2 classes)",
        "- bank freshness: newest banked 2026-09-20-s18; 0 panel sections "
        "since: fresh",
    ], f"{got_quiet}")
    def _mkdated(section, date):
        run = _mkrun(section, "panel")
        run.date = date
        run.round_lines = []
        return run
    fresh_runs = [_mkdated("D00-T04-S40", "2026-09-21"),
                  _mkdated("D00-T04-S41", "2026-09-22")]
    got_fresh = leg_lines(fresh_runs, [], bank_one)
    check("legs-bank-fresh",
          got_fresh[3] == "- bank freshness: newest banked 2026-09-20-s18; "
          "2 panel sections since: fresh", f"{got_fresh}")
    stale_runs = fresh_runs + [_mkdated("D00-T04-S42", "2026-09-23")]
    got_stale = leg_lines(stale_runs, [], bank_one)
    check("legs-bank-stale",
          got_stale[3] == "- bank freshness: newest banked 2026-09-20-s18; "
          "3 panel sections since: STALE (calibration owed past 3) -- file "
          "the early revisit (D00 T04 \u00a723 trigger) with these lines quoted",
          f"{got_stale}")
    bank_empty = tmp / "leg-bank-empty.md"
    bank_empty.write_text("# nothing banked yet\n", encoding="utf-8")
    got_empty = leg_lines(fresh_runs, [], bank_empty)
    check("legs-bank-empty-stale",
          got_empty[3] == "- bank freshness: newest banked none banked; "
          "2 panel sections on record: STALE (calibration owed past 1) -- file "
          "the early revisit (D00 T04 \u00a723 trigger) with these lines quoted",
          f"{got_empty}")
    bank_undated = tmp / "leg-bank-undated.md"
    bank_undated.write_text("comparison: s99 class: review-tooling "
                            "jaccard: 0.00 pairs: 0 union: 1\n", encoding="utf-8")
    got_undated = leg_lines(fresh_runs, [], bank_undated)
    check("legs-bank-undated-stale",
          got_undated[3] == "- bank freshness: newest banked s99 (undated); "
          "2 panel sections on record: STALE (calibration owed past 1) -- file "
          "the early revisit (D00 T04 \u00a723 trigger) with these lines quoted",
          f"{got_undated}")
    # Newest, not last-listed (panel round 5 F19): the newer entry
    # leads the bank, so position-based reading would count two
    # sections since the older tail.
    bank_ooo = tmp / "leg-bank-ooo.md"
    bank_ooo.write_text("comparison: 2026-09-21-cal class: plan-record "
                        "jaccard: 0.40 pairs: 2 union: 5\n"
                        "comparison: 2026-09-20-s18 class: review-tooling "
                        "jaccard: 0.00 pairs: 0 union: 3\n", encoding="utf-8")
    got_ooo = leg_lines(fresh_runs, [], bank_ooo)
    check("legs-bank-newest-not-last",
          got_ooo[3] == "- bank freshness: newest banked 2026-09-21-cal; "
          "1 panel sections since: fresh", f"{got_ooo}")
    legend_out = report([], tmp / "runs22.md", collected=([], [])).splitlines()
    check("report-legend", legend_out[-4:] == list(TRIGGER_LEGEND),
          f"{legend_out[-4:]}")
    fired_runs = [
        _mkleg("D00-T04-S31", [{"model": sol, "opportunity": "full-scope",
                                "findings": []}]),
        _mkleg("D00-T04-S32", [{"model": sol,
                                "opportunity": "delta-plus-regressions",
                                "findings": ["D00-T04-S31-F1"]}]),
        _mkleg("D00-T04-S33", [{"model": sol, "opportunity": "full-scope",
                                "findings": ["D00-T04-S31-F2"]}]),
        _mkleg("D00-T04-S34", [{"model": sol, "opportunity": "full-scope",
                                "findings": []}]),
    ]
    got_fired = leg_lines(fired_runs, [leg_find, leg_dead], bank_one)
    check("legs-zero-fired",
          got_fired[1] == "- zero runs (trailing full-scope zero sections per rung, "
          "fix-loop invisible): "
          "GPT: 3 trailing full-scope zero(s) FIRED -- file the early "
          "revisit (D00 T04 §23 trigger) with these lines quoted; "
          "Claude: no full-scope round observed", f"{got_fired}")
    unknown_runs = [
        _mkleg("D00-T04-S31", [{"model": sol, "opportunity": "full-scope",
                                "findings": []}]),
        _mkleg("D00-T04-S32", [{"model": sol, "opportunity": "full-scope",
                                "findings": ["D00-T04-S99-F9"]}]),
    ]
    got_unknown = leg_lines(unknown_runs, [leg_find, leg_dead], bank_one)
    check("legs-unknown-ref-breaks-run",
          "GPT: 0 trailing full-scope zero(s)" in got_unknown[1]
          and "FIRED" not in got_unknown[1], f"{got_unknown}")
    bank_two = tmp / "leg-bank-two.md"
    bank_two.write_text("comparison: 2026-09-20-s18 class: review-tooling "
                        "jaccard: 0.00 pairs: 0 union: 3\n"
                        "comparison: 2026-09-21-cal class: plan-record "
                        "jaccard: 0.40 pairs: 2 union: 5\n", encoding="utf-8")
    got_active = leg_lines(quiet_runs, [leg_find, leg_dead], bank_two)
    check("legs-overlap-active-quiet",
          got_active[2] == "- overlap comparisons banked: 2 spanning 2 class(es) "
          "(review-tooling Jaccard 0.00 over union 3; "
          "plan-record Jaccard 0.40 over union 5): ACTIVE, mean Jaccard 0.20",
          f"{got_active}")
    bank_hot = tmp / "leg-bank-hot.md"
    bank_hot.write_text("comparison: 2026-09-20-s18 class: review-tooling "
                        "jaccard: 0.60 pairs: 3 union: 5\n"
                        "comparison: 2026-09-21-cal class: plan-record "
                        "jaccard: 0.80 pairs: 4 union: 5\n", encoding="utf-8")
    got_hot = leg_lines(quiet_runs, [leg_find, leg_dead], bank_hot)
    check("legs-overlap-armed",
          got_hot[2] == "- overlap comparisons banked: 2 spanning 2 class(es) "
          "(review-tooling Jaccard 0.60 over union 5; "
          "plan-record Jaccard 0.80 over union 5): ACTIVE, mean Jaccard 0.70 "
          "ARMED (Jaccard half met, blinded value half pending) "
          "-- file the early revisit (D00 T04 §23 trigger) "
          "with these lines quoted", f"{got_hot}")
    got_nobank = leg_lines(quiet_runs, [leg_find, leg_dead],
                            tmp / "leg-bank-absent.md")
    check("legs-bank-unreadable",
          got_nobank[2].startswith("- overlap comparisons banked: bank unreadable ")
          and got_nobank[2].endswith(": DORMANT (unmeasured)"), f"{got_nobank}")
    # D00 T04 §22: the RUN registry is closed (codes plus exits), and an
    # unlisted code fails closed instead of printing.
    run_codes = {c: DIAG.CODES[c] for c in DIAG.CODES if c.startswith("RUN-")}
    check("codes-registry-closed", run_codes == {
        "RUN-001": (2, "usage: conflicting flags or bad arguments"),
        "RUN-002": (1, "run-file read or parse"),
        "RUN-003": (1, "run-block shape"),
        "RUN-004": (1, "finding attribution and coverage"),
        "RUN-005": (1, "panel-round correspondence"),
        "RUN-006": (1, "candidate resolution"),
        "RUN-007": (1, "export document problems")}, f"{run_codes}")
    for bad_call in (lambda: DIAG.emit("RUN-999", None, None, "x"),
                     lambda: DIAG.refusal("RUN-999", None, None, "x")):
        try:
            bad_call()
            check("codes-unlisted-closed", False, "an unlisted code printed")
        except ValueError as exc:
            check("codes-unlisted-closed",
                  "unlisted diagnostic code 'RUN-999'" in str(exc), f"{exc}")

    # D00 T04 §22: main-level exits plus codes, driven against fixture
    # runs files. Post-shape legs thread collected plus review_sections
    # so no leg reads the live tree; the review-file scan rebinds the
    # same way and restores below.
    import contextlib

    def _run_main(argv, **kw):
        out, err = io.StringIO(), io.StringIO()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            code = main(argv, **kw)
        return code, out.getvalue(), err.getvalue()

    real_sha = subprocess.run(["git", "rev-parse", "HEAD"], cwd=ROOT,
                              capture_output=True, text=True,
                              timeout=30).stdout.strip()[:7]
    mrev = tmp / "reviews22"
    mdom = mrev / "99-domain"
    mdom.mkdir(parents=True)
    mreview = mdom / "D00-T99-s9.md"
    mreview.write_text(
        "## Opus panel Round 1\n\n"
        "`adversarial` needs-attention\n"
        "`consistency` approve\n"
        "`integration` approve\n"
        "`record` approve\n",
        encoding="utf-8",
    )
    base_run = ("schema: 1\nrun: D00-T99-S9\ndate: 2026-09-20\n"
                "runner: panel\nrounds: 1\n"
                "round: 1 model: opus effort: medium outcome: findings "
                "candidate: %s provider: anthropic version: unresolved "
                "cost: unresolved latency: unresolved opportunity: full-scope "
                "purpose: section-review provenance: recorded "
                "findings: D00-T99-S9-F1\n"
                "empty: 0\nrefuted: 0\n")
    f1 = TF.Finding("D00 T99 §9", None, 1, "F1", "s", "record", "fixed",
                    None, "independent")
    saved_reviews = TF.REVIEWS
    TF.REVIEWS = mrev
    try:
        rp = tmp / "runs22.md"
        rp.write_text("not a runs file at all\n", encoding="utf-8")
        code, out, _ = _run_main(["--check", str(rp)])
        check("exit-parse", code == 1 and "[RUN-002]" in out, f"{code} {out!r}")
        rp.write_text(base_run % real_sha, encoding="utf-8")
        bad_effort = rp.read_text(encoding="utf-8").replace(
            "effort: medium", "effort: bogus", 1)
        rp.write_text(bad_effort, encoding="utf-8")
        code, out, _ = _run_main(["--check", str(rp)])
        check("exit-shape", code == 1 and "[RUN-003]" in out, f"{code} {out!r}")
        code, out, _ = _run_main(["--check", str(tmp / "missing22.md")])
        check("exit-unreadable", code == 1 and "[RUN-002]" in out,
              f"{code} {out!r}")
        rp.write_text(base_run % real_sha, encoding="utf-8")
        f9 = TF.Finding("D00 T99 §9", None, 9, "F9", "s", "record", "fixed",
                        None, "independent")
        code, out, _ = _run_main(
            ["--check", str(rp)], collected=([f1, f9], []),
            review_sections={"D00-T99-S9"})
        check("exit-coverage",
              code == 1 and "[RUN-004]" in out
              and "but no run lists it" in out
              and "[RUN-005]" not in out and "[RUN-006]" not in out,
              f"{code} {out!r}")
        mreview.write_text("# no panel sections here\n", encoding="utf-8")
        code, out, _ = _run_main(
            ["--check", str(rp)], collected=([f1], []),
            review_sections={"D00-T99-S9"})
        check("exit-panel",
              code == 1 and "[RUN-005]" in out
              and "no panel sections" in out
              and "[RUN-004]" not in out and "[RUN-006]" not in out,
              f"{code} {out!r}")
        mreview.write_text(
            "## Opus panel Round 1\n\n"
            "`adversarial` needs-attention\n"
            "`consistency` approve\n"
            "`integration` approve\n"
            "`record` approve\n",
            encoding="utf-8",
        )
        rp.write_text(base_run % "0000000", encoding="utf-8")
        code, out, _ = _run_main(
            ["--check", str(rp)], collected=([f1], []),
            review_sections={"D00-T99-S9"})
        check("exit-candidates",
              code == 1 and "[RUN-006]" in out
              and "is not a commit in this repository" in out
              and "[RUN-004]" not in out and "[RUN-005]" not in out,
              f"{code} {out!r}")
        rp.write_text(base_run % real_sha, encoding="utf-8")
        code, out, _ = _run_main(
            ["--check", str(rp)], collected=([f1], []),
            review_sections={"D00-T99-S9"})
        check("exit-green",
              code == 0 and "all resolve, all covered, counts agree" in out,
              f"{code} {out!r}")
        code, out, _ = _run_main(
            ["--report", "--format", "json", str(rp)], collected=([f1], []),
            review_sections={"D00-T99-S9"})
        check("report-json-prose",
              code == 0 and "review runs," in out and "[" not in out,
              f"{code} {out!r}")
        code, _, err = _run_main(["--report", "--export"])
        check("exit-conflict", code == 2 and "[RUN-001]" in err, f"{code} {err!r}")
        code, _, err = _run_main(["--check-export"])
        check("exit-check-export-usage", code == 2 and "[RUN-001]" in err,
              f"{code} {err!r}")
        code, _, err = _run_main(["--check-export", "--bogus"])
        check("exit-export-flag", code == 2 and "[RUN-001]" in err
              and "unknown option" in err, f"{code} {err!r}")
        code, out, _ = _run_main(["--check-export", "--format", "json",
                                 str(tmp / "missing22.json")])
        try:
            unread_doc = json.loads(out)
        except ValueError:
            unread_doc = None
        check("json-export-unreadable",
              code == 1 and isinstance(unread_doc, list) and unread_doc
              and all(sorted(d) == ["code", "line", "message", "path"]
                      for d in unread_doc)
              and unread_doc[0]["code"] == "RUN-007",
              f"{code} {out!r}")
        code, _, err = _run_main(["--format"])
        check("exit-format-usage", code == 2 and "[RUN-001]" in err,
              f"{code} {err!r}")
        code, _, err = _run_main(["--format", "yaml"])
        check("exit-format-value", code == 2 and "[RUN-001]" in err,
              f"{code} {err!r}")
        code, _, err = _run_main(["--bogus"])
        check("exit-unknown-flag", code == 2 and "[RUN-001]" in err
              and "unknown option" in err, f"{code} {err!r}")
        code, _, err = _run_main(["-check"])
        check("exit-single-dash", code == 2 and "[RUN-001]" in err
              and "unknown option '-check'" in err, f"{code} {err!r}")
        code, _, err = _run_main(["-bogus"])
        check("exit-single-dash-bogus", code == 2 and "[RUN-001]" in err
              and "unknown option '-bogus'" in err, f"{code} {err!r}")
        code, _, err = _run_main(["--check-export", "-x"])
        check("exit-export-single-dash", code == 2 and "[RUN-001]" in err
              and "unknown option '-x'" in err, f"{code} {err!r}")
        code, _, err = _run_main(["a.md", "b.md"])
        check("exit-surplus-positional", code == 2 and "[RUN-001]" in err
              and "at most one" in err, f"{code} {err!r}")
        code, _, err = _run_main(["--self-test", "--check"])
        check("exit-selftest-surplus", code == 2 and "[RUN-001]" in err,
              f"{code} {err!r}")
        code_s, _, err_s = _run_main(["--self-test", "--format", "json"])
        code_e, _, err_e = _run_main(["--self-test", "--format=json"])
        check("exit-selftest-format",
              code_s == 2 and "[RUN-001]" in err_s
              and code_e == 2 and "[RUN-001]" in err_e,
              f"{code_s} {err_s!r} / {code_e} {err_e!r}")
        rp.write_text("not a runs file at all\n", encoding="utf-8")
        code, out, _ = _run_main(
            ["--check", "--format=json", str(rp)])
        try:
            eq_doc = json.loads(out)
        except ValueError:
            eq_doc = None
        check("format-equals-form",
              code == 1 and isinstance(eq_doc, list) and eq_doc
              and eq_doc[0]["code"] == "RUN-002",
              f"{code} {out!r}")
        code, out, _ = _run_main(
            ["--check-export", str(tmp / "missing22.json")])
        check("exit-export-unreadable", code == 1 and "[RUN-007]" in out,
              f"{code} {out!r}")
        xp = tmp / "export22.json"
        xp.write_text('{"schema": 99}\n', encoding="utf-8")
        code, out, _ = _run_main(["--check-export", str(xp)])
        check("exit-export-problems", code == 1 and "[RUN-007]" in out,
              f"{code} {out!r}")
        rp.write_text("not a runs file at all\n", encoding="utf-8")
        code, out, _ = _run_main(["--check", "--format", "json", str(rp)])
        try:
            malformed_doc = json.loads(out)
        except ValueError:
            malformed_doc = None
        check("json-malformed-schema",
              code == 1 and isinstance(malformed_doc, list)
              and malformed_doc
              and all(sorted(d) == ["code", "line", "message", "path"]
                      for d in malformed_doc)
              and malformed_doc[0]["code"] == "RUN-002"
              and malformed_doc[0]["code"] in DIAG.CODES,
              f"{code} {out!r}")
        code, out, _ = _run_main(
            ["--check-export", "--format", "json", str(xp)])
        try:
            export_doc = json.loads(out)
        except ValueError:
            export_doc = None
        check("json-export-schema",
              code == 1 and isinstance(export_doc, list) and export_doc
              and all(sorted(d) == ["code", "line", "message", "path"]
                      for d in export_doc)
              and export_doc[0]["code"] == "RUN-007",
              f"{code} {out!r}")
    finally:
        TF.REVIEWS = saved_reviews

    bank_one.unlink()
    bank_two.unlink()
    bank_hot.unlink()
    bank_empty.unlink()
    bank_undated.unlink()
    bank_ooo.unlink()
    other.unlink()
    (tmp / "reviews22" / "99-domain" / "D00-T99-s9.md").unlink()
    (tmp / "reviews22" / "99-domain").rmdir()
    (tmp / "reviews22").rmdir()
    (tmp / "runs22.md").unlink()
    (tmp / "export22.json").unlink()
    tmp.rmdir()

    print(f"todo-runs self-test: {total[0]} cases, {len(failures)} failed")
    for failure in failures:
        print(f"FAIL {failure}")
    return 1 if failures else 0


class _Usage(Exception):
    """A RUN-001 usage refusal. main renders it; it never escapes main."""
    def __init__(self, message):
        super().__init__(message)
        self.message = message


def _tokenize(raw):
    """One non-mutating pass over raw argv. Returns (fmt, rest): the
    selected format plus every token the gates see, `--format` shapes
    consumed, order kept. Raises _Usage on a malformed --format. No
    gate pops: every gate reads the same `rest`, so a flag swallowed
    before a gate (round-3 A1) is structurally unrepresentable. A
    doubled --format resolves last-wins, sequentially."""
    fmt = "text"
    rest = []
    i, n = 0, len(raw)
    while i < n:
        arg = raw[i]
        if arg.startswith("--format="):
            fmt = arg.split("=", 1)[1]
            i += 1
        elif arg == "--format":
            if i + 1 >= n or raw[i + 1].startswith("--"):
                raise _Usage("usage: --format wants text or json")
            fmt = raw[i + 1]
            i += 2
        else:
            rest.append(arg)
            i += 1
    if fmt not in ("text", "json"):
        raise _Usage("usage: --format wants text or json, got %r" % (fmt,))
    return fmt, rest


def main(argv=None, collected=None, review_sections=None):
    args = list(sys.argv[1:] if argv is None else argv)
    if "--self-test" in args and args != ["--self-test"]:
        print(DIAG.emit("RUN-001", None, None,
                        "usage: todo-runs.py --self-test takes no other arguments"),
              file=sys.stderr)
        return 2
    if args == ["--self-test"]:
        return _self_test()
    try:
        fmt, rest = _tokenize(args)
    except _Usage as exc:
        print(DIAG.emit("RUN-001", None, None, exc.message), file=sys.stderr)
        return 2
    json_mode = fmt == "json"
    if "--check-export" in rest:
        rest = [a for a in rest if a != "--check-export"]
        # Single dash refuses like double (D00 T04 §24 item 22): a
        # mistyped flag must not parse as a path (RUN-002/RUN-007);
        # a runs file with a leading dash spells ./-name.
        if len(rest) != 1 or rest[0].startswith("-"):
            detail = (
                f"; unknown option {rest[0]!r}"
                if rest and rest[0].startswith("-")
                else ""
            )
            print(DIAG.emit("RUN-001", None, None,
                            "usage: todo-runs.py --check-export <export.json>"
                            + detail),
                  file=sys.stderr)
            return 2
        try:
            xport = Path(rest[0]).as_posix()
            doc = json.loads(Path(rest[0]).read_text(encoding="utf-8"))
        except (OSError, ValueError) as exc:
            if json_mode:
                print(DIAG.dumps([DIAG.refusal(
                    "RUN-007", xport, None,
                    f"cannot read export: {exc}")]), end="")
            else:
                print(DIAG.emit("RUN-007", xport, None,
                                f"cannot read export: {exc}"))
            return 1
        problems = check_export(doc)
        if problems:
            if json_mode:
                print(DIAG.dumps([DIAG.refusal("RUN-007", xport, None, p)
                                  for p in problems]), end="")
            else:
                for problem in problems:
                    print(DIAG.emit("RUN-007", xport, None, problem))
            return 1
        if not json_mode:
            print(f"{rest[0]}: {export_sound_line(doc)}")
        else:
            print(DIAG.dumps([]), end="")
        return 0
    mode_report = "--report" in args
    mode_export = "--export" in args
    if mode_report and mode_export:
        print(DIAG.emit("RUN-001", None, None,
                        "usage: todo-runs.py [--check] [--report | --export] "
                        "[runs-file]; --report and --export conflict, pass at "
                        "most one"),
              file=sys.stderr)
        return 2
    rest = [a for a in rest if a not in ("--check", "--report", "--export")]
    # Single dash refuses here too (D00 T04 §24 item 22, like the
    # --check-export gate above): never a runs path.
    for a in rest:
        if a.startswith("-"):
            print(DIAG.emit("RUN-001", None, None,
                            "usage: todo-runs.py [--check] [--report | --export] "
                            f"[runs-file]; unknown option {a!r}"),
                  file=sys.stderr)
            return 2
    if len(rest) > 1:
        print(DIAG.emit("RUN-001", None, None,
                        "usage: todo-runs.py [--check] [--report | --export] "
                        "[runs-file]; at most one runs-file path"),
              file=sys.stderr)
        return 2
    runs_path = Path(rest[0]) if rest else DEFAULT_RUNS
    if collected is None:
        collected = TF.collect()
    runs, errors = run_check(runs_path, collected, review_sections)
    if errors:
        if json_mode:
            print(DIAG.dumps(
                [DIAG.refusal(code, runs_path.as_posix(), lineno or None, msg)
                 for code, lineno, msg in errors]), end="")
        else:
            for code, lineno, msg in errors:
                print(DIAG.emit(code, runs_path.as_posix(), lineno or None, msg))
        return 1
    if mode_report:
        sys.stdout.write(report(runs, runs_path, collected))
    elif mode_export:
        sys.stdout.write(json.dumps(export_runs(runs, runs_path), indent=2) + "\n")
    elif json_mode:
        print(DIAG.dumps([]), end="")
    else:
        rounds = sum(r.rounds or 0 for r in runs)
        print(f"{len(runs)} runs, {rounds} rounds: all resolve, all covered, counts agree")
    return 0


if __name__ == "__main__":
    sys.exit(main())
