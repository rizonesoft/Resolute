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

ROOT = HERE.parent
DEFAULT_RUNS = ROOT / "docs" / "reviews" / "run-records.md"

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
FAMILY_MODEL = {"GPT": "gpt-5.6-sol", "Opus": "opus"}
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
                errors.append((rl_lineno, f"opportunity must be one of {OPPORTUNITIES}"))
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


def report(runs, runs_path):
    lines = []
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
    findings, _bad = TF.collect()
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
    lines.append("Cost (recorded tokens; USD prices outside the record):")
    known = [(run.section, n, items["cost"])
             for run in runs for _, n, items in run.round_lines
             if items.get("cost") != "unresolved"]
    total_rounds = sum(run.rounds or 0 for run in runs)
    if known:
        total_tokens = sum(int(cost[:-6]) for _, _, cost in known)
        lines.append(f"- {len(known)}/{total_rounds} rounds recorded, {total_tokens} tokens")
        for section, n, cost in known:
            lines.append(f"- {section} round {n}: {cost}")
    else:
        lines.append(f"- no recorded cost ({total_rounds}/{total_rounds} unresolved)")
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
    lines.append("")
    lines.extend(revisit_lines(runs))
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


def check_export(doc):
    """Assert an export file: version, shape, values, internal counts.
    Returns a list of messages (empty means sound). Every closed set the
    parser enforces is re-asserted here, so a hand-edited export cannot
    smuggle values the records could never hold. The as-of binds the
    snapshot; live-tree agreement is NOT checked here, a snapshot is a
    moment, so `refuted` is bounded by the listed refs rather than proven
    against the ledger. Dispositions ride per ref so the snapshot stands
    alone; a value outside the ledger set fails."""
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
                problems.append(f"{section} round {num}: opportunity must be one of {OPPORTUNITIES}")
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
    check("unreadable-reported", runs_u == [] and any("cannot read" in m for _, m in errors_u),
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
                                          ("opportunity", "full-scope", "partial", "opportunity must be"),
                                          ("purpose", "section-review", "vibes", "purpose must be"),
                                          ("provenance", "reconstructed", "oral-tradition",
                                           "provenance must be")):
        bad = good.replace(f"{bad_key}: {orig}", f"{bad_key}: {bad_val}", 1)
        _r, errors_g = parse_runs(bad)
        check_runs(_r, errors_g)
        check(f"bad-{bad_key}-fails", any(want in m for _, m in errors_g), f"{errors_g}")

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
    other.unlink()
    tmp.rmdir()

    print(f"todo-runs self-test: {total[0]} cases, {len(failures)} failed")
    for failure in failures:
        print(f"FAIL {failure}")
    return 1 if failures else 0


def main(argv=None):
    args = list(sys.argv[1:] if argv is None else argv)
    if "--self-test" in args:
        return _self_test()
    if "--check-export" in args:
        rest = [a for a in args if a != "--check-export"]
        if len(rest) != 1:
            print("usage: todo-runs.py --check-export <export.json>", file=sys.stderr)
            return 2
        try:
            doc = json.loads(Path(rest[0]).read_text(encoding="utf-8"))
        except (OSError, ValueError) as exc:
            print(f"{rest[0]}: cannot read export: {exc}")
            return 1
        problems = check_export(doc)
        for problem in problems:
            print(f"{rest[0]}: {problem}")
        if not problems:
            print(f"{rest[0]}: {export_sound_line(doc)}")
        return 1 if problems else 0
    mode_report = "--report" in args
    mode_export = "--export" in args
    rest = [a for a in args if a not in ("--check", "--report", "--export")]
    runs_path = Path(rest[0]) if rest else DEFAULT_RUNS
    runs, errors = run_check(runs_path)
    if errors:
        for lineno, msg in errors:
            where = f"{runs_path}:{lineno}" if lineno else f"{runs_path}"
            print(f"{where}: {msg}")
        return 1
    if mode_report:
        sys.stdout.write(report(runs, runs_path))
    elif mode_export:
        sys.stdout.write(json.dumps(export_runs(runs, runs_path), indent=2) + "\n")
    else:
        rounds = sum(r.rounds or 0 for r in runs)
        print(f"{len(runs)} runs, {rounds} rounds: all resolve, all covered, counts agree")
    return 0


if __name__ == "__main__":
    sys.exit(main())
