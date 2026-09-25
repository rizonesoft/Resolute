#!/usr/bin/env python3
"""todo-graph -- build, validate, query, and render the Resolute TODO graph.

Markdown under todo/ is canonical. This script parses it into a derived cache
(build/todo-cache.json), checks the graph's integrity, and answers questions the
markdown cannot answer by grep -- what is ready, what is blocked, and on what.

    python scripts/todo-graph.py build
    python scripts/todo-graph.py validate
    python scripts/todo-graph.py self-test
    python scripts/todo-graph.py query ready|blocked|stats|deferred|frozen|findings|surfaces
    python scripts/todo-graph.py render > docs-graph.md
    python scripts/todo-graph.py plan [--check]
    python scripts/todo-graph.py classify 'D00 T01 §11' 'D02 T01 §13'
    python scripts/todo-graph.py progress --json

Stdlib only -- this runs before platform/ has a composer.json, let alone vendor/.
Format spec: todo/README.md

Ported machinery: the review-record subsystem (Requires/Context, the run and
plan-health/summary queries, stamp-field parsing for Plan review/Reopened and
Duration ranges, and their validators) arrived from ScratchPad on 2026-09-19.
Section and item numbers in those comments (D00 T01 §N) are ScratchPad's, kept
so the rationale trail survives the port.

A campaign may edit this file when the inflight section already names it
(Build order or dirty list). That is planned section work, not a mid-run
self-improvement. The intelligence hook allows that path (INT-0012); the
four verify commands in `.grok/skills/run-phase/SKILL.md` still run before
staging.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import os
import functools
import re
import subprocess
import shutil
import tempfile
import sys
from dataclasses import dataclass, field, asdict
from datetime import date, datetime, timedelta, timezone
from pathlib import Path

# This tree is written in UTF-8 and prints section markers (U+00A7) and status
# glyphs. A Windows console defaults to cp1252, where those raise
# UnicodeEncodeError mid-command and take a query down with them. Reconfigure
# our own streams rather than asking every caller to set PYTHONIOENCODING: the
# point of a stdlib-only script is that a fresh clone just runs.
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, ValueError):  # already wrapped, or not a real stream
        pass

REPO = Path(__file__).resolve().parent.parent
TODO_DIR = REPO / "todo"
CACHE = REPO / "build" / "todo-cache.json"
SKILLS_DIR = REPO / ".claude" / "skills"

ID_RE = re.compile(r"^[a-z][a-z0-9-]{0,58}[a-z0-9]$")
STATUSES = {"draft", "active", "blocked", "done", "superseded"}
TODO_FILE_RE = re.compile(r"^TODO-(\d{2})-[a-z0-9-]+\.md$")

# "| 3 | §2 | Deliverable text | §1, T02 §4 | [x] |"
ROW_RE = re.compile(
    r"^\|\s*(?P<order>\d+)\s*\|\s*§(?P<sec>\d+)\s*\|"
    r"\s*(?P<deliverable>.+?)\s*\|\s*(?P<deps>.*?)\s*\|\s*\[(?P<status>[ x/])\]\s*\|\s*$"
)
BODY_RE = re.compile(r"^##\s+(?P<num>\d+)\.\s+(?P<title>.+?)\s*$")
# §1 | T02 §3 | D02 T01 §4
XREF_RE = re.compile(r"(?:D(?P<dom>\d{2})\s+)?(?:T(?P<todo>\d{2})\s+)?§(?P<sec>\d+)")
# Skills cite sections absolutely (D00 T04 §6): a bare §N has no origin there.
SKILL_CITE_RE = re.compile(r"D(?P<dom>\d{2})\s+T(?P<todo>\d{2})\s+§(?P<sec>\d+)")
# Short citation forms, banned in skills (D00 T04 §13): a bare §N has no
# origin, a TNN §N without its domain is ambiguous across domains, and a
# file §N is shorthand however real the path. Single-space full D-refs
# never match (each alternative excludes that span); wider spacing falls
# to the span guard at the check-26 site, since fixed-width lookbehinds
# cannot cover SKILL_CITE_RE's \s+.
SKILL_SHORT_RE = re.compile(
    r"(?P<file>[\w./-]+\.md §\d+)"
    r"|(?P<todo>(?<!D\d\d )(?<!\w)T\d\d §\d+)"
    r"|(?P<bare>(?<!\w)(?<!T\d\d )§\d+)"
)
# A backticked candidate oid (or a..b range) on a Review line, with its
# optional round tag (D00 T04 §21: every candidate carries its round).
REVIEW_OID_RE = re.compile(
    r"`(?P<oid>[0-9a-f]{7,40}(?:\.\.[0-9a-f]{7,40})?)`(?P<tag>\(round \d+\))?"
)
BARE_TODO_RE = re.compile(r"(?<![\w§])(?:D\d{2}\s+)?T\d{2}(?!\s*§)(?![\w-])")
STAMP_RE = re.compile(
    r"^>\s*\*\*(?P<kind>Verified|Deferred|Resolved|Review|Duration|CRUD|Verification|Implementer|Moved|Plan review|Reopened):\*\*\s*(?P<body>.+?)\s*$"
)
# A reopened section names the finding that voided its proof: `<YYYY-MM-DD> |
# <finding ref> | <reason>`. The validator requires the date, the bar, and a
# resolvable §ref in the rest.
REOPENED_BODY_RE = re.compile(r"^(?P<date>\d{4}-\d{2}-\d{2})\s*\|\s*(?P<rest>.+)$")
# `> **Implementer:** Fable 5.1 (claude-fable-5-1)` or `not recorded (<why>)`.
# D00 T08 §1: the runner writes it from its own transcript, never by hand.
IMPLEMENTER_RE = re.compile(
    r"^(?:(?P<name>[A-Za-z][A-Za-z0-9 .-]{0,120}?)\s*\((?P<model>[a-z][a-z0-9.-]{0,120})\)|not recorded\b.*)$"
)
REVIEW_FAMILIES = ("codex", "grok", "claude", "kimi", "opencode", "qwen", "gemini")
# A per-kind verdict. Corrected 2026-08-30: a required job id between kind and
# verdict matched no real stamp, so the Progress page showed no chips. The gap
# may cross no `|`, `·` or BACKTICK -- else a match on the fingerprint eats the
# first kind. -> XREF: D00 T06 §47.
# The provenance suffix (D00 T08 §1) follows the verdict and its optional
# finding count: `(codex gpt-5.6-sol ×10)`, `(claude opus ×4)`, `(grok ×7)`
# when the ledger has no model for the family or the model is the family's
# own name (the Grok wrapper records `grok`), `(model not recorded)` when the
# ledger has no leg for the kind. Written by
# `scripts/stamp-provenance.py` from `build/codex-review/dispatches.jsonl`.
REVIEW_ENTRY_RE = re.compile(
    r"`(?P<kind>[a-z][a-z0-9-]+)`"
    r"(?:\s+(?:`[^`]+`|(?:review|opus|aux|task)-[\w-]+))?"
    r"[^|·\n`]{0,60}?"
    r"\b(?P<verdict>approve|needs-attention|advisory|skipped(?:-limit|\s*\(limit\))?)"
    r"(?:\s*\(\d+[^)]*\))?"
    r"(?:\s*\((?:(?P<family>codex|grok|claude|kimi|opencode|qwen|gemini)"
    r"(?:\s+(?P<model>[A-Za-z0-9][\w.:/-]*))?(?:\s*×(?P<runs>\d+))?"
    r"|(?P<unrecorded>model not recorded))\))?",
    re.IGNORECASE,
)
REVIEW_JOBISH_RE = re.compile(r"^(?:review|opus|aux|task)-", re.IGNORECASE)
REVIEW_HEX_RE = re.compile(r"^[0-9a-f]{4,40}$", re.IGNORECASE)
REVIEW_KIND_LABELS = {
    "adversarial": "Adversarial",
    "consistency": "Consistency",
    "optimisation": "Optimisation",
    "optimization": "Optimisation",
    "source-defect": "Source",
    "record": "Record",
    "design": "Design",
    "fidelity": "Fidelity",
    "integration": "Integration",
    # The stage 4 advisory pass (writers-and-reviewers §7): a gray badge.
    "adversarial-final": "Qwen final",
}
DURATION_BODY_RE = re.compile(r"^(?P<minutes>\d+)\s*m?$")
DURATION_END_RE = re.compile(r"^\S+\s+to\s+(?P<end>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)$")
VERIFIED_DATE_RE = re.compile(r"^(?P<date>\d{4}-\d{2}-\d{2})\b")
# A deferral names its owner with "-> XREF: <ref>" and, optionally, the exact
# checklist item that owner carries. Both are what make closure checkable.
DEFER_REF_RE = re.compile(r"->\s*XREF:\s*(?P<ref>(?:D\d{2}\s+)?(?:T\d{2}\s+)?§\d+)")
# A FINDING is a checklist item that records something NOTICED, with the date it
# was noticed and usually who or what noticed it. The convention emerged before it
# was named: by 2026-08-14 roughly forty items across ten files opened with one of
# these verbs and an ISO date, because "a finding is filed, not mentioned" makes
# provenance the whole point of the entry.
#
# Detecting the convention rather than demanding a new marker is deliberate. A new
# marker would need forty edits and would silently miss every finding filed before
# it existed, which is the failure mode this query is meant to close.
FINDING_RE = re.compile(
    r"\*{0,2}(?P<verb>Found|Filed|Handed over|Recorded|Discovered|Corrected|Re-pointed)"
    r"\s+(?P<date>\d{4}-\d{2}-\d{2})",
    re.I,
)

DEFER_ITEM_RE = re.compile(r"\(item:\s*[\"“](?P<item>[^\"”]+)[\"”]")
SEC_RANGE_RE = re.compile(r"§(\d+)(?:\s*-\s*§?(\d+))?")

# The WHOLE body of a `Verified:` stamp, as one anchored grammar (D00 T01 §39).
#
# **Corrected 2026-08-29 by round 1, corroborated by both Codex lenses (High).**
# The first version checked three things separately -- a date PREFIX, then
# `body.split("|")[1]` -- and validating the parts is not validating the line.
# Measured on the committed parser: `2026-08-29 junk-before-pipe | §1 | e`,
# `2026-08-29 | §1` (no closing delimiter) and `2026-08-29 | §1, §3-§2 | e`
# all still verified §1 with no refusal recorded, because a prefix match says
# nothing about what follows it, `parts[1]` is whatever happens to sit between
# the first two pipes, and one valid element made the aggregate non-empty.
#
# So the shape is asserted end to end instead: the date field is EXACTLY the
# date, both delimiters are required, and the evidence field must carry a
# non-space character. All 193 stamps in the live tree already satisfy this.
# `re.ASCII` on both, and it is load-bearing: round 2 measured
# `٢٠٢٦-٠٨-٢٩ | §١ | evidence` verifying §1 with `stamped_on='٢٠٢٦-٠٨-٢٩'`,
# because Python's `\d` is Unicode-aware and `int()` converts Arabic-Indic
# digits happily. The contract says YYYY-MM-DD; a grammar that accepts another
# script's digits is not that grammar, and the date it stores is unusable to
# every consumer that compares stamps as strings.
STAMP_BODY_RE = re.compile(
    r"^(?P<date>\d{4}-\d{2}-\d{2})[ \t]*\|[ \t]*(?P<cover>[^|]*?)[ \t]*\|(?P<evidence>.*)$",
    re.ASCII,
)

# The largest number of sections one stamp may cover. A range stamp exists so a
# handful of sections shipped together share one stamp, and this is far past any
# real use. Round 2 measured `§1-§3000000` materialising three million integers
# in `covered` before anything looked at them, so the bound is checked BEFORE
# the range is built rather than after.
#
# **65, not 64, and the number is taken from the sibling gate rather than
# chosen.** `scripts/section_commit_gate.py` clamps a stamp range with
# `min(end, start + 64)` and then builds an INCLUSIVE range, so it admits
# `start` through `start + 64` -- sixty-five sections. Round 5 measured it:
# a `§1-§1000` stamp expands there to 65 entries ending at §65. At 64 here, the
# gate would recognise a `§1-§65` stamp that `validate` refuses, which is the
# operator-facing deadlock the parity probe below exists to prevent. The probe
# now compares the gate's effective COUNT (`literal + 1`), not its literal,
# because comparing the literal is what made it pass while the two disagreed.
MAX_STAMP_COVERAGE = 65

# One element of the coverage field, anchored. The field is split on commas and
# EVERY element must match this and be ordered, so a reversed range is refused
# rather than silently contributing nothing. `SEC_RANGE_RE` stays what it is --
# a forgiving finditer over free text, which is what lets a stamp's evidence
# prose mention `§4` without claiming it -- and is no longer used on the field
# the graph TRUSTS.
COVER_ITEM_RE = re.compile(r"^§(?P<lo>\d+)(?:[ \t]*-[ \t]*§?(?P<hi>\d+))?$", re.ASCII)

# Surface contract (D00 T03 §15). A real block starts the line. A checklist
# item that mentions `**Fidelity:**` is not a Fidelity block (D00 T01 §22).
FIDELITY_BLOCK_RE = re.compile(r"^\*\*Fidelity:\*\*\s*(.*)$")
JOB_BLOCK_RE = re.compile(r"^\*\*Job:\*\*")
TREATMENT_BLOCK_RE = re.compile(r"^\*\*Treatment:\*\*")
CHROME_BLOCK_RE = re.compile(r"^\*\*Chrome:\*\*")
# `**Needs:** <host>` marks a section that cannot run without a live host the
# plan cannot otherwise see (D00 T07 §28). The Azure VMs deallocate daily
# 00:15-04:14 SAST, so `plan-gate.py next` reads this to skip a marked row
# inside the window and take it first when the host wakes. The list is
# CLOSED: `validate` refuses any other value, so a typo cannot silently
# unmark a section. A second host is one more entry here and one probe in
# plan-gate.py.
NEEDS_BLOCK_RE = re.compile(r"^\*\*Needs:\*\*\s*(?P<value>.+?)\s*$")
NEEDS_ALLOWED: dict[str, str] = {
    "Windows host (build/test)": "windows-host",
    "C++ toolchain (compile)": "cpp-toolchain",
    "Optical drive (drive test)": "optical-drive",
    "USB device (drive test)": "usb-device",
    "Signing certificate (release)": "signing-cert",
    # Added 2026-09-17 by D00 T01 §7. A machine WITHOUT Visual Studio and the
    # Windows Kits, which the development machine is not: absence cannot be
    # simulated on a machine that has the thing, because a toolchain can fall
    # back to a registry key or a well-known path and only a genuinely clean
    # machine shows that it does not. A clean VM, a Windows Sandbox instance, or
    # a second physical machine all serve.
    "Clean Windows machine (no Visual Studio)": "clean-windows",
}

# Environment capabilities a section can require (`**Requires:**` line,
# ported from ScratchPad D00 T01 §13). CLOSED like NEEDS_ALLOWED:
# `validate` refuses any other value, and refuses a mark without its
# reason, so a typo cannot silently unmark a section and every mark
# cites the measurement that convicted it. One value today (the first
# evidenced mark); a second value is one more entry here, one detector
# branch below, and its self-test cases.
REQUIRES_ALLOWED: tuple[str, ...] = (
    "display-session",
)
REQUIRES_BLOCK_RE = re.compile(r"^\*\*Requires:\*\*\s*(?P<body>.+?)\s*$")
REQUIRES_REASON_SEP = " -- "


def detect_context(platform: str | None = None, environ=None) -> set[str]:
    """The runner capabilities `query ready` evaluates `**Requires:**` against.

    `platform`/`environ` default to the live interpreter and process
    environment; tests pass fakes. display-session holds on Windows with
    SESSIONNAME naming an interactive session (console or remote) and
    nowhere else -- in particular never under WSL, whose
    window-station-less session cannot drive the built tools or capture
    their windows, and never as session 0, which names itself
    "Services" and has no window station (headless services, CI runners).
    """
    plat = sys.platform if platform is None else platform
    env = os.environ if environ is None else environ
    ctx: set[str] = set()
    session = (env.get("SESSIONNAME") or "").strip()
    if plat == "win32" and session and session.lower() != "services":
        ctx.add("display-session")
    return ctx
FIDELITY_EXEMPT_RE = re.compile(
    r"no surface of its own|not a surface|no page of its own|not a page|the library is not a surface",
    re.I,
)


# ---------------------------------------------------------------- frontmatter


def parse_frontmatter(text: str) -> tuple[dict, list[str]]:
    """Minimal YAML for our flat schema: scalars, bools, ints, and flow lists.

    Deliberately not a YAML library -- the schema is five required scalar fields
    and three optional ones. A dependency here would have to be installed before
    anyone could validate a TODO, which defeats the point.
    """
    errors: list[str] = []
    if not text.startswith("---"):
        return {}, ["missing frontmatter (file must open with ---)"]
    end = text.find("\n---", 3)
    if end == -1:
        return {}, ["frontmatter opened with --- but never closed"]
    block = text[3:end].strip("\n")
    data: dict = {}
    for lineno, raw in enumerate(block.splitlines(), start=2):
        line = raw.rstrip()
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if ":" not in line:
            errors.append(f"frontmatter line {lineno}: no key (got {line!r})")
            continue
        key, _, val = line.partition(":")
        key, val = key.strip(), val.strip()
        if val.startswith("[") and val.endswith("]"):
            inner = val[1:-1].strip()
            data[key] = (
                [v.strip().strip("\"'") for v in inner.split(",") if v.strip()]
                if inner else []
            )
        elif val in ("true", "false"):
            data[key] = val == "true"
        elif val.isdigit():
            data[key] = int(val)
        else:
            data[key] = val.strip("\"'")
    return data, errors


# --------------------------------------------------------------------- model


@dataclass
class Section:
    num: int
    title: str = ""
    order: int | None = None
    deliverable: str = ""
    depends_on: list[str] = field(default_factory=list)  # raw XREF strings
    status: str = " "
    has_body: bool = False
    has_row: bool = False
    items_total: int = 0
    items_done: int = 0
    items: list[tuple[bool, str]] = field(default_factory=list)  # (done, text)
    has_test_checkpoint: bool = False
    test_checkpoint_text: str = ""
    has_freeze_check: bool = False
    has_commit_item: bool = False
    commit_done: bool = False
    has_fidelity_block: bool = False
    fidelity_exempt: bool = False
    has_job: bool = False
    has_treatment: bool = False
    has_chrome: bool = False
    needs_raw: str = ""          # the `**Needs:**` value as written
    needs: list[str] = field(default_factory=list)  # closed-list keys, e.g. windows-host
    requires_has_line: bool = False  # a `**Requires:**` line is present
    requires_raw: str = ""           # the line body as written (values + reason)
    requires: list[str] = field(default_factory=list)  # closed-list values
    requires_unknown: list[str] = field(default_factory=list)  # values outside REQUIRES_ALLOWED
    requires_reason: str = ""        # the cited measurement (required)
    line: int = 0
    duration_minutes: int | None = None
    duration_end: str | None = None  # `Duration:` range end instant, Zulu shaped or None
    stamped_on: str | None = None
    verified_body: str = ""
    duration_body: str = ""
    review_body: str = ""
    plan_review_body: str = ""
    reopened_body: str = ""
    crud_body: str = ""
    verification_body: str = ""
    implementer_body: str = ""
    # `> **Moved:**` body under the heading: the section's open work is worked
    # OUTSIDE the tree, in the file the body names (writers-and-reviewers §2).
    # The row and the cross-references stay; ready, plan and progress skip it.
    moved: str = ""


@dataclass
class Deferral:
    """One `Deferred:`/`Resolved:` stamp line, parsed so closure can be checked.

    Stored as a raw string until 2026-08-10, which is why deferrals went stale
    unnoticed: nothing could resolve the owner or see that it had shipped.
    """

    line: int = 0
    resolved: bool = False
    body: str = ""
    ref: str = ""      # raw XREF target, e.g. "D09 T01 §1"
    item: str = ""     # the exact checklist item the owner carries


@dataclass
class Todo:
    path: str
    domain: str
    number: str
    id: str = ""
    title: str = ""
    status: str = ""
    frozen: bool = False
    track: str = ""
    depends_on: list[str] = field(default_factory=list)
    superseded_by: str = ""
    sections: dict[int, Section] = field(default_factory=dict)
    verified_sections: set[int] = field(default_factory=set)
    deferred: list["Deferral"] = field(default_factory=list)
    xrefs: list[str] = field(default_factory=list)  # raw "-> XREF:" target text
    fm_errors: list[str] = field(default_factory=list)
    bare_refs: list[str] = field(default_factory=list)
    # (line number, the raw body) of every `Verified:` line the parser refused.
    # Carried rather than flagged here because the loader has no reporter; rule
    # 15 in cmd_validate turns each into the `malformed-stamp` FATAL.
    #
    # It rides `asdict()` into `build/todo-cache.json`, so every todo there now
    # carries `malformed_stamps: []` on a clean tree while `schema_version`
    # stays 1 (round 2, Low, derived). That is deliberate: the cache is derived
    # and gitignored, its one consumer (`scripts/groom-audit.py`) reads named
    # keys and is unaffected -- `groom-audit.py self-test` 17 cases 0 failed
    # against the new shape -- and `schema_version` gates the SHAPE a reader
    # must understand, which an additive field does not change. The two
    # committed projections under `platform/resources/` do not carry it.
    malformed_stamps: list[tuple[int, str]] = field(default_factory=list)


def checklist_state(stripped: str) -> bool | None:
    """Checked state of a checklist opener, None for anything else.

    One shape for the parser and the partial-flip rule (D00 T04 §19):
    two copies would drift back into fixed bugs. Lowercase `x` only,
    matching the parser's long-standing reading; uppercase `[X]` reads
    open in both, deliberately unchanged here.
    """
    if not (stripped.startswith("- [") and len(stripped) > 4 and stripped[4] == "]"):
        return None
    return stripped[3] == "x"


def parse_todo(path: Path) -> Todo:
    try:
        rel = path.relative_to(REPO).as_posix()
    except ValueError:
        rel = path.as_posix()
    m = TODO_FILE_RE.match(path.name)
    todo = Todo(path=rel, domain=path.parent.name, number=m.group(1) if m else "??")
    text = path.read_text(encoding="utf-8")
    fm, todo.fm_errors = parse_frontmatter(text)
    todo.id = str(fm.get("id", ""))
    todo.title = str(fm.get("title", ""))
    todo.status = str(fm.get("status", ""))
    todo.frozen = bool(fm.get("frozen", False))
    todo.track = str(fm.get("track", ""))
    todo.superseded_by = str(fm.get("superseded_by", ""))
    dep = fm.get("depends_on", [])
    # Drop falsy entries at the source: a blank `depends_on:` scalar parses
    # to [""], which validate skips but the shared dependency gate would
    # report as an unknown-unmet edge with an empty label, silently blocking
    # every resolver (§37 round-1 finding, both lenses).
    todo.depends_on = [
        str(d).strip() for d in (dep if isinstance(dep, list) else [dep]) if str(d).strip()
    ]

    current: Section | None = None
    # The sections the most recent Verified line covers; the field lines under
    # it (Review, CRUD, Implementer, Duration) are written to each of them.
    stamp_targets: list[Section] = []
    stamp_orphaned = False  # the last stamp was malformed: its fields belong to no section
    in_order_table = False
    for lineno, line in enumerate(text.splitlines(), start=1):
        stamp = STAMP_RE.match(line)
        if stamp:
            body = stamp.group("body")
            kind = stamp.group("kind")
            if kind == "Verified":
                # PARSE OR REFUSE (D00 T01 §39, dev ticket #7). Before this,
                # ANY `> **Verified:** ...` line verified the current section:
                # `> **Verified:** nonsense` inside an `[x]` section suppressed
                # rule 7's missing-stamp FATAL and, since §38, moved two
                # warning kinds into the acked register. A malformed stamp on a
                # shipped row is worse than a missing one, because it READS as
                # evidence, so it is refused and reported rather than trusted.
                #
                # Three things are checked, and the second and third are the
                # ones a date-only repair would miss: the body opens with a
                # REAL calendar date (`2026-99-99` is date-SHAPED and not a
                # date), the coverage field exists and matches
                # `COVER_FIELD_RE` end to end, and it yields at least one
                # section. The old `if not covered` fallback to the current
                # section is deliberately gone: it is what let a garbage
                # coverage field still verify the section it sat in.
                covered: list[int] = []
                refusal = ""
                day = ""
                shaped = STAMP_BODY_RE.match(body.strip())
                if not shaped:
                    refusal = "is not '<YYYY-MM-DD> | <sections> | <evidence>'"
                elif not shaped.group("evidence").strip():
                    refusal = "has an empty evidence field"
                else:
                    day = shaped.group("date")
                    try:
                        date(*(int(part) for part in day.split("-")))
                    except ValueError:
                        refusal = f"opens with {day!r}, which is not a real calendar date"
                if not refusal:
                    cover_field = shaped.group("cover")
                    for element in cover_field.split(","):
                        item = COVER_ITEM_RE.match(element.strip())
                        if item is None:
                            refusal = (
                                f"has {element.strip()!r} in its coverage field, which is not "
                                f"a section reference or range"
                            )
                            break
                        lo = int(item.group("lo"))
                        hi = int(item.group("hi")) if item.group("hi") else lo
                        if lo < 1 or hi < lo:
                            refusal = (
                                f"has {element.strip()!r} in its coverage field, which covers "
                                f"no section"
                            )
                            break
                        # AGGREGATE, not per element (round 3, Medium). The
                        # first version checked each element before extending,
                        # so `§1-§64, §65-§128` passed twice and covered 128 --
                        # repeating valid ranges restored exactly the unbounded
                        # allocation the cap exists to stop. The bound is on
                        # what the stamp CLAIMS, so it is counted across the
                        # whole field and still checked before the range is
                        # built.
                        if len(covered) + (hi - lo + 1) > MAX_STAMP_COVERAGE:
                            refusal = (
                                f"covers more than {MAX_STAMP_COVERAGE} sections by "
                                f"{element.strip()!r}"
                            )
                            break
                        covered.extend(range(lo, hi + 1))
                if refusal:
                    todo.malformed_stamps.append((lineno, f"{body} -- {refusal}"))
                    stamp_targets, stamp_orphaned = [], True  # its fields reach no section (INT-0110)
                else:
                    todo.verified_sections.update(covered)
                    # The field lines under this stamp belong to EVERY section
                    # it covers, not only the heading it sits under: a range
                    # stamp's Review and Implementer used to reach one section
                    # and leave the rest reading "not recorded" (D00 T08 §1,
                    # Codex on the last wave).
                    stamp_targets = [todo.sections[num] for num in covered if num in todo.sections]
                    stamp_orphaned = False
                    for target in stamp_targets:
                        target.stamped_on = day
                        target.verified_body = body
            elif kind == "Duration" and current is not None:
                for target in stamp_targets or ([] if stamp_orphaned else [current]):
                    # Last marker governs: each Duration line resets
                    # both fields, then applies its own shape. A range
                    # computes its minutes, so minute and range forms
                    # project identically; an unshaped, calendar-invalid,
                    # or inverted range leaves both None (fail-soft:
                    # clearance falls back to day stamps, and no strptime
                    # ever escapes the parser into the query).
                    target.duration_minutes = None
                    target.duration_end = None
                    target.duration_body = body
                    m = DURATION_BODY_RE.fullmatch(body.strip())
                    if m is not None:
                        target.duration_minutes = int(m.group("minutes"))
                        continue
                    e = DURATION_END_RE.fullmatch(body.strip())
                    if e is None:
                        continue
                    try:
                        start = datetime.strptime(
                            body.strip().split(" to ")[0], "%Y-%m-%dT%H:%M:%SZ"
                        ).replace(tzinfo=timezone.utc)
                        end = datetime.strptime(
                            e.group("end"), "%Y-%m-%dT%H:%M:%SZ"
                        ).replace(tzinfo=timezone.utc)
                    except ValueError:
                        continue
                    if end <= start:
                        continue
                    target.duration_end = e.group("end")
                    target.duration_minutes = int((end - start).total_seconds() // 60)
            elif kind == "Review" and current is not None:
                for target in stamp_targets or ([] if stamp_orphaned else [current]):
                    target.review_body = body
            elif kind == "Plan review" and current is not None:
                for target in stamp_targets or ([] if stamp_orphaned else [current]):
                    target.plan_review_body = body
            elif kind == "Reopened" and current is not None:
                for target in stamp_targets or ([] if stamp_orphaned else [current]):
                    target.reopened_body = body
            elif kind == "CRUD" and current is not None:
                for target in stamp_targets or ([] if stamp_orphaned else [current]):
                    target.crud_body = body
            elif kind == "Verification" and current is not None:
                for target in stamp_targets or ([] if stamp_orphaned else [current]):
                    target.verification_body = body
            elif kind == "Implementer" and current is not None:
                for target in stamp_targets or ([] if stamp_orphaned else [current]):
                    target.implementer_body = body
            elif kind == "Moved" and current is not None:
                current.moved = body
            elif kind in ("Deferred", "Resolved"):
                ref = DEFER_REF_RE.search(body)
                item = DEFER_ITEM_RE.search(body)
                todo.deferred.append(
                    Deferral(
                        line=lineno,
                        resolved=(kind == "Resolved"),
                        body=body,
                        ref=ref.group("ref").strip() if ref else "",
                        item=item.group("item").strip() if item else "",
                    )
                )
            # A deferral's "-> XREF:" is a real cross-reference: it is this file
            # pointing at the section that owes the work. Collect it so reciprocity
            # sees it, otherwise the owner acknowledging the hand-off reads as
            # one-sided.
            todo.xrefs.extend(m.group(0) for m in XREF_RE.finditer(body))
            continue

        if line.startswith("## Implementation Order"):
            in_order_table = True
            continue
        if in_order_table and line.startswith("## "):
            in_order_table = False
        if in_order_table:
            row = ROW_RE.match(line)
            if row:
                num = int(row.group("sec"))
                sec = todo.sections.setdefault(num, Section(num=num))
                sec.has_row = True
                sec.order = int(row.group("order"))
                sec.deliverable = row.group("deliverable").strip()
                sec.status = row.group("status")
                deps = row.group("deps").strip()
                if deps and deps not in ("--", "—", "-"):
                    sec.depends_on = [d.strip() for d in deps.split(",") if d.strip()]
            continue

        body = BODY_RE.match(line)
        if body:
            num = int(body.group("num"))
            sec = todo.sections.setdefault(num, Section(num=num))
            sec.title = body.group("title")
            sec.has_body = True
            sec.line = lineno
            current = sec
            stamp_targets = []
            stamp_orphaned = False
            continue
        if line.startswith("## "):
            current = None
            stamp_targets = []

        if current is not None:
            st = line.strip()
            state = checklist_state(st)
            if state is not None:
                current.items_total += 1
                if state:
                    current.items_done += 1
                current.items.append((state, st[5:].strip()))
                low = st.lower()
                if "commit:" in low:
                    current.has_commit_item = True
                    if state:
                        current.commit_done = True
            if "**Test checkpoint:**" in line:
                current.has_test_checkpoint = True
                current.test_checkpoint_text = st
            if "**Freeze check:**" in line:
                current.has_freeze_check = True
            fid = FIDELITY_BLOCK_RE.match(st)
            if fid:
                current.has_fidelity_block = True
                if FIDELITY_EXEMPT_RE.search(fid.group(1) or "") or FIDELITY_EXEMPT_RE.search(st):
                    current.fidelity_exempt = True
            if JOB_BLOCK_RE.match(st):
                current.has_job = True
            if TREATMENT_BLOCK_RE.match(st):
                current.has_treatment = True
            if CHROME_BLOCK_RE.match(st):
                current.has_chrome = True
            needs = NEEDS_BLOCK_RE.match(st)
            if needs:
                current.needs_raw = needs.group("value").strip()
                key = NEEDS_ALLOWED.get(current.needs_raw)
                current.needs = [key] if key else []
            req = REQUIRES_BLOCK_RE.match(st)
            if req:
                current.requires_has_line = True
                body = req.group("body").strip()
                current.requires_raw = body
                values_part, sep, reason = body.partition(REQUIRES_REASON_SEP)
                current.requires_reason = reason.strip() if sep else ""
                values = [v.strip() for v in values_part.split(",") if v.strip()]
                current.requires = [v for v in values if v in REQUIRES_ALLOWED]
                current.requires_unknown = [v for v in values if v not in REQUIRES_ALLOWED]

        if "-> XREF:" in line:
            todo.xrefs.append(line.split("-> XREF:", 1)[1].strip())
        for bare in BARE_TODO_RE.findall(line):
            if "XREF" in line or "Depends" in line or "|" in line:
                todo.bare_refs.append(f"line {lineno}: {bare}")

    # A reopen voids the stamp: the section reads as unverified everywhere
    # downstream, so rule 7 fires until the row is unchecked and dependents
    # must park. The `Verified:` line itself stays in the text as history;
    # the validator requires the row flip.
    for num, s in todo.sections.items():
        if s.reopened_body.strip():
            todo.verified_sections.discard(num)

    return todo


def load_todos() -> list[Todo]:
    if not TODO_DIR.exists():
        return []
    return [
        parse_todo(p)
        for p in sorted(TODO_DIR.glob("*/TODO-*.md"))
        if TODO_FILE_RE.match(p.name)
    ]


# --------------------------------------------------------------------- build


def to_cache(todos: list[Todo]) -> dict:
    out = {"schema_version": 1, "todos": []}
    for t in todos:
        d = asdict(t)
        d["verified_sections"] = sorted(t.verified_sections)
        d["sections"] = [asdict(s) for s in sorted(t.sections.values(), key=lambda s: s.num)]
        out["todos"].append(d)
    return out


def cmd_build(_args) -> int:
    todos = load_todos()
    CACHE.parent.mkdir(parents=True, exist_ok=True)
    CACHE.write_text(json.dumps(to_cache(todos), indent=2) + "\n", encoding="utf-8")
    secs = sum(len(t.sections) for t in todos)
    print(f"built {CACHE.relative_to(REPO)}: {len(todos)} todos, {secs} sections")
    return 0


# ------------------------------------------------------------------ validate


def resolve_ref(ref: str, origin: Todo, by_key: dict[tuple[str, str], Todo]) -> tuple[str, int] | None:
    """Resolve '§3' / 'T02 §1' / 'D02 T01 §4' to (todo_id, section_num)."""
    m = XREF_RE.search(ref)
    if not m:
        return None
    sec = int(m.group("sec"))
    dom = m.group("dom")
    tno = m.group("todo")
    if dom is None and tno is None:
        return (origin.id, sec)
    domain = origin.domain
    if dom is not None:
        matches = [d for d in {t.domain for t in by_key.values()} if d.startswith(dom + "-")]
        if not matches:
            return None
        domain = matches[0]
    target = by_key.get((domain, tno or origin.number))
    return (target.id, sec) if target else None


# D00 T01 §21 (2026-08-28): THE severity map -- the one place a warning
# class's push-time consequence is decided, mirrored row-for-row in
# todo/README.md's severity table (the self-test compares the two, so the
# mirror cannot drift silently). Two-layer contract: "fatal" exits 1 always
# and is never ackable; "warn" rides the §38 ratchet -- a NEW occurrence
# fails validate as WARN* until fixed or deliberately accepted into the
# baseline, and stamped pre-convention occurrences live in the ack ledger.
# Classification rule: push-time actionability. A class lands "fatal" when
# the fix is mechanical and the defect is a structural-integrity break; it
# stays "warn" when the fix is a judgement call (sizing, prose, recording
# early resolution) that a red build cannot resolve.
# An automated filer stamps what it filed FROM, so a second run of the same
# scanner cannot open a second row for one real-world thing. Prose ("search
# before filing") is what every filer already had, and it is a judgement call
# made by whoever is tired at the time. This is mechanical.
#
#   -> SOURCE: build-1042
#   -> SOURCE: inbox-AAMkAGI2...
#
# Free-form after the prefix, one per line, lowercase-normalised. Human filings
# do not need one; two humans filing the same thing twice is a judgement
# problem and this cannot solve it. What it CAN guarantee is that a scanner
# that runs twice a day never files the same production exception twice.
SOURCE_RE = re.compile(r"->\s*SOURCE:\s*(?P<key>[A-Za-z0-9][A-Za-z0-9._:@+-]*)")

# A TODO file caps at 55 sections; past that the work goes in a NEW file
# (operator 2026-09-01). Files only ever grow, because a section number is a
# permanent address -- `DNN TNN §N` cross-references encode it, so renumbering
# to tidy up is not available and a large file can never be made small again.
# The cost is paid by every reader and every grep from then on.
#
# 55 rather than a round number: the largest file was at 53 when this was set,
# so the cap is real headroom rather than an instruction to go and split
# something tonight. Splitting BY SUBJECT into a new file is free; a renumber
# is impossible.
MAX_SECTIONS_PER_FILE = 55

SEVERITY_MAP: dict[str, str] = {
    # a file past the section cap: the next piece of work opens a new TODO
    # file, because section numbers are permanent and a file cannot shrink.
    "over-section-cap": "fatal",
    # two sections claiming the same provenance key is a duplicate filing --
    # the one thing an automated filer can and must prove it did not do.
    "duplicate-source-key": "fatal",
    # a short section ref on a post-cutoff evidence surface (stamp prose,
    # findings file, attestation): new evidence cites full DNN TNN §N
    # refs, like skills since §13 (D00 T04 §21).
    "evidence-citation-short-form": "fatal",
    # a post-cutoff Review line with two or more candidate oids and an
    # untagged one: round-to-commit mapping must be mechanical (D00 T04
    # §21; §13's own line stands as history by explicit exemption).
    "review-citation-role-less": "fatal",
    # a post-cutoff round tag resolving to no recorded panel round, or
    # two candidates sharing one round: the mapping must correspond,
    # not merely exist (D00 T04 §24 item 18).
    "review-citation-role-mismatch": "fatal",
    # superseded frontmatter must name its successor: mechanical, structural.
    "superseded-no-successor": "fatal",
    # an OPEN section whose --filter checkpoint claims another suite stays
    # green is a checkpoint known not to detect its promised regression --
    # naming the test files is a two-minute fix (D00 T06 §26).
    "filter-overclaim-open": "fatal",
    # the stamped fix-forward branch stays ratcheted: the stamp must not be
    # reopened, so the fix is forward-only (§38's deliberate design).
    "filter-overclaim-stamped": "warn",
    # one section = one commit is the format's core contract.
    "no-commit-item": "fatal",
    # an unticked micro-step outside the exemptions inside a shipped
    # [x] section is an integrity break in the shipped claim itself.
    "partial-flip-shipped": "fatal",
    # history the binding cannot read is unverified, not broken: a
    # bare-tree export must still validate (D00 T04 §20).
    "commit-history-unreadable": "warn",
    # Fidelity missing Job/Treatment/Chrome on an OPEN section is already
    # fatal at the emitter; the stamped branches are §38 fix-forward.
    "fidelity-missing-lines-open": "fatal",
    "fidelity-missing-lines-stamped": "warn",
    # an empty section is structurally unimplementable.
    "no-checklist-items": "fatal",
    # 31 items is a sizing judgement a red build cannot resolve.
    "over-30-items": "warn",
    # a frozen TODO without its check (or the reverse) is a safety-marker
    # mismatch with a mechanical fix in either direction.
    "frozen-no-freeze-check": "fatal",
    "freeze-check-not-frozen": "fatal",
    # prose legitimately mentions a TODO file without a section.
    "bare-todo-ref": "warn",
    # the README calls a one-sided XREF BROKEN; the validator now agrees
    # (§21's headline case -- the wording was right, the severity wrong).
    "one-sided-xref": "fatal",
    # a deferral with no owner is an abandonment (process-todo-section §8).
    "deferral-no-owner": "fatal",
    # recording a resolution before the owner ticks is legitimate evidence
    # of work done early; blocking it would forbid honest records.
    "resolved-owner-unshipped": "warn",
    # a TODO absent from its domain INDEX.md is a two-line mechanical fix.
    "missing-from-index": "fatal",
    # a `Verified:` line the parser refused. FATAL rather than WARN because a
    # malformed stamp on a shipped row READS as evidence: it is worse than a
    # missing one, and the fix is to write the line correctly (D00 T01 §39).
    "malformed-stamp": "fatal",
    # a `**Needs:**` value outside NEEDS_ALLOWED: the list is closed so a
    # misspelt host cannot silently unmark a section (D00 T07 §28).
    "needs-unknown": "fatal",
    # a `> **Moved:**` marker naming no file, or a file that does not exist:
    # the section is excluded from ready/plan/progress on the strength of
    # that pointer, so a dead pointer would hide work (writers-and-reviewers §2).
    "moved-target-missing": "fatal",
    "pending-control-contract": "fatal",
    # a stamp dated after the Opus-panel rule landed whose findings carry no
    # panel verdicts reads as reviewed evidence while verifying nothing --
    # the same lie as a malformed stamp, so the same severity.
    "stamp-no-opus-panel": "fatal",
    # a `**Requires:**` value outside REQUIRES_ALLOWED: the list is closed
    # so a misspelt capability cannot silently unmark a section.
    "requires-unknown": "fatal",
    # a `**Requires:**` mark without its reason: the citation is what makes
    # the mark auditable instead of vibes.
    "requires-no-reason": "fatal",
    # a stamp dated after the plan-review rule landed that carries no
    # `Plan review:` completion marker: the second-family round is required
    # procedure, so an unmarked stamp reads as fully reviewed while the
    # round may never have run.
    "stamp-no-plan-review": "fatal",
    # a post-cutoff plan-review record the query cannot parse (a Plan
    # review section without its Manifest line or its Ledger block, a
    # non-row line inside the block, or a content-illegal row):
    # unparseable records silently drop out of governance.
    "plan-review-malformed": "fatal",
    # a filed ledger row whose target file carries no back-link: the filing
    # is untraceable from the target side, so remediation cannot be
    # attributed to the finding.
    "filed-target-no-backlink": "fatal",
    # a `> **Reopened:**` line outside its shape, on a still-checked row,
    # or with a still-stamped dependent: a reopen that does not void proof
    # downstream lets work continue on invalid evidence.
    "stamp-reopened": "fatal",
    # a finding ID appearing twice in one ledger: duplicated IDs attach one
    # finding to the wrong remediation, so multi-target findings ride one
    # row with every target, never split rows.
    "plan-review-duplicate-id": "fatal",
    # a `Plan review:` marker without run lineage (no run ID, a reused run
    # ID, a rerun marker naming no superseded run, or a run the manifest
    # does not carry): precedence without lineage rests on line position
    # alone.
    "plan-review-no-lineage": "fatal",
    # a ledger row whose disposition moved the forbidden way against the
    # committed record, or a row that vanished: later evidence amends via
    # a new row, never by rewriting the old one.
    "ledger-history-violation": "fatal",
    # a post-cutoff findings file without a well-formed `Provenance:`
    # line, or a provenance line outside the field shape, without a
    # shaped run ID, with an unresolving candidate, a missing path, or
    # a run no marker of its section carries: unattributed or
    # misattributed live quotes.
    "provenance-malformed": "fatal",
    # a ledger row whose `supersedes` link names no row of its block,
    # crosses review namespaces, or closes a cycle: orphaned or
    # contradictory amendment history.
    "ledger-supersession-broken": "fatal",
    # a `Risk accepted:` line outside the record shape, with an
    # uncoverable target, expiring before it is recorded, or reviewed
    # outside its record-expiry window: an unauditable waiver.
    "risk-acceptance-malformed": "fatal",
    "risk-acceptance-silent-edit": "fatal",
    "risk-acceptance-chain-broken": "fatal",
    # a skill citing a section that does not exist teaches a reader a dead
    # address; the fix is mechanical (correct the citation or write the
    # section) and only full D-refs are checked, bare §N having no origin.
    "skill-citation-unresolved": "fatal",
    # a skill citing a short section form (bare §N, TNN §N, file §N)
    # teaches an ambiguous address; the fix is mechanical (expand to a
    # full DNN TNN §N ref). D00 T04 §13.
    "skill-citation-short-form": "fatal",
}


# The file a `Moved:` body points at: the first `path/to/file.md` token.
MOVED_PATH_RE = re.compile(r"(?P<path>(?:[\w.-]+/)+[\w.-]+\.md)")


def _fence_shape(line: str) -> tuple[int, str, int, str]:
    # (quote depth, marker char, marker run, info string) for a fence
    # marker line; (quote depth, "", 0, "") otherwise. Blockquote
    # prefixes never hide a fence, but depth is tracked so a quoted
    # close cannot close an unquoted fence and vice versa. Markers
    # indented 4+ past the quote prefix are indented code, not fences.
    m = re.match(r"(?:[ \t]{0,3}>[ \t]?)+", line)
    qd = m.group(0).count(">") if m else 0
    rest = line[m.end():] if m else line
    stripped = rest.strip()
    indent = rest[: len(rest) - len(rest.lstrip())]
    if len(indent.replace("\t", "    ")) >= 4:
        return qd, "", 0, ""
    if stripped.startswith("```") or stripped.startswith("~~~"):
        ch = stripped[0]
        run = len(stripped) - len(stripped.lstrip(ch))
        return qd, ch, run, stripped[run:]
    return qd, "", 0, ""


def _fenced_flags(raw_lines: list[str]) -> tuple[list[bool], int | None]:
    """Per-line kept flags plus the unbalanced opener lineno: the one fence machine.

    `strip_fenced_code` (the text view) and `strip_fenced_map` (the
    line view) both read this walk, so the two views cannot drift
    back into fixed bugs.
    """
    kept: list[bool] = []
    fence = None  # (char, run, opener lineno, quote depth) in one
    for fence_lineno, ln in enumerate(raw_lines, start=1):
        qd, fence_ch, fence_run, info = _fence_shape(ln)
        if fence is not None and qd < fence[3]:
            # Below the open fence's quote depth, the quote ended,
            # closing the fence with it: CommonMark laziness never
            # applies to fenced-code content, so there is no
            # lookahead for a later same-depth close (its
            # whole-remainder scan let later quoted blocks swallow
            # the lines between, hiding whole panels). A blank line
            # is not a blockquote continuation line (CommonMark
            # 0.31.2 section 5.1, example 228), so it ends a quoted
            # fence too; an unquoted fence needs no such bar because
            # its depth already matches (0 < 0 is false), keeping
            # blank lines legal content there. Reprocess the line
            # below: it may open a new fence at its own depth.
            fence = None
        if fence_run:
            if fence is None:
                # CommonMark: a backtick in a backtick-fence info
                # string makes the line a paragraph, never a fence.
                # (Tilde info strings may hold anything.)
                if fence_ch == "`" and "`" in info:
                    kept.append(True)
                else:
                    fence = (fence_ch, fence_run, fence_lineno, qd)
                    kept.append(False)
            elif (
                qd == fence[3]
                and fence_ch == fence[0]
                and fence_run >= fence[1]
                and info == ""
            ):
                # CommonMark close: same quote depth and char, run
                # at least the opener's, and no info string. A
                # ```text line, a shorter or other-char run, or a
                # close at another quote depth is content, never a
                # close; without these bars, quoted verdicts leak
                # out and satisfy the rule. Same-length nesting
                # cannot exist, so genuinely crossed fences fall out
                # as unbalanced below instead of mis-toggling.
                fence = None
                kept.append(False)
            else:
                kept.append(False)
            continue
        if fence is None:
            kept.append(True)
        else:
            kept.append(False)
    if fence is not None:
        return kept, fence[2]
    return kept, None


def strip_fenced_code(text: str) -> tuple[str, int | None]:
    """Return (text with fenced code blocks removed, unbalanced opener lineno or None).

    One fence implementation for the validator's panel rule and the
    plan-health query, which scan the same findings files: two copies
    would drift back into fixed bugs.
    """
    raw_lines = text.splitlines()
    flags, unbalanced = _fenced_flags(raw_lines)
    return "\n".join(ln for ln, keep in zip(raw_lines, flags) if keep), unbalanced


def strip_fenced_map(text: str) -> tuple[list[bool], int | None]:
    """Per-line kept flags plus the unbalanced opener lineno, from the one fence machine.

    The disposition report's view: which raw span lines the rule sees.
    """
    return _fenced_flags(text.splitlines())


# Stamps on or before this date predate the plan-review marker rule and are
# grandfathered. Set to the 2026-09-19 ScratchPad port date, so every
# Resolute stamp predates it. Module-level, not in the validator, because
# `query plan-health` needs the same boundary: one constant, no copies.
PLAN_REVIEW_CUTOFF = "2026-09-19"
# D00 T04 §27: from this date Claude Code is the only writer and GPT
# governs the panel; the validator's rule 16 and plan-health both read it.
GPT_GOVERNS_FROM = "2026-09-23"
# Operator decision 2026-09-25: Grok left the panel, so a `Grok panel`
# record governs no stamp dated on or after this day.
GROK_RETIRED_FROM = "2026-09-25"
_GPT_PANEL_HEAD_RE = re.compile(r"^#{2,6}\s+GPT panel\b", re.IGNORECASE | re.MULTILINE)
_CLAUDE_PANEL_HEAD_RE = re.compile(r"^#{2,6}\s+(?:Opus|Claude) panel\b", re.IGNORECASE | re.MULTILINE)
_GROK_PANEL_HEAD_RE = re.compile(r"^#{2,6}\s+Grok panel\b", re.IGNORECASE | re.MULTILINE)
_OPUS_OUTAGE_RE = re.compile(r"opus outage", re.IGNORECASE)
_GPT_OUTAGE_RE = re.compile(r"gpt outage", re.IGNORECASE)


def panel_fallback(stripped_text: str, stamped_on: str | None) -> tuple[bool, bool]:
    """(ran on the fallback family, carries the matching outage note) for
    one fence-stripped findings text. Before GPT_GOVERNS_FROM, Opus
    governed and a GPT-last record was the fallback; from it, GPT
    governs and any other last record (a Grok fallback, D00 T04 §29, or
    a Claude-family section, which rule 16 also fails) ran on the
    fallback. A text with no panel section is neither."""
    gpt = list(_GPT_PANEL_HEAD_RE.finditer(stripped_text))
    claude = list(_CLAUDE_PANEL_HEAD_RE.finditer(stripped_text))
    grok = list(_GROK_PANEL_HEAD_RE.finditer(stripped_text))
    if not gpt and not claude and not grok:
        return False, False
    others = [h[-1].start() for h in (claude, grok) if h]
    last_is_gpt = bool(gpt) and (not others or gpt[-1].start() > max(others))
    gpt_governs = (stamped_on or "") >= GPT_GOVERNS_FROM
    note = (_GPT_OUTAGE_RE if gpt_governs else _OPUS_OUTAGE_RE).search(stripped_text) is not None
    return last_is_gpt != gpt_governs, note
# Stamps on or before this date predate the evidence-citation rules and
# stand as history (D00 T04 §21): 670 live short forms and 31 role-less
# Review lines sit on sealed records no rule may rewrite. Set to
# 2026-09-20, the day §21 landed; stamps after it cite full refs and
# round-tagged candidates.
EVIDENCE_CITE_CUTOFF = "2026-09-20"
# The grandfathered migration deadline: past this date, unmigrated
# batches read OVERDUE and fail `--check`.
MIGRATION_DEADLINE = "2026-12-31"


def migration_overdue_today(today: str) -> bool:
    """Whether the grandfathered migration is past its deadline."""
    return today > MIGRATION_DEADLINE


# An open major older than this many days past its review's stamp is
# overdue by age (a blown row due date also counts). Recorded default:
# a week is long enough to file or defer, short enough to notice;
# changing it is one constant.
PLAN_REVIEW_OVERDUE_DAYS = 7
# Machine contract for `query plan-health --json`: `schema` is
# `plan-health/<n>`, bumped on any key-shape change. The report exits 0
# (it is a reading, not a gate) unless `--check` or `--fail-on` arms
# it; usage errors exit 2 via argparse. Every list carries a TOTAL sort
# key (the tuple of its scalar fields, so ties are impossible and two
# runs over one tree diff clean) and every field is one type always:
# strings for refs, IDs, owners, dates, and runs ("" when absent, never
# null), bools for flags, ints for counts and line numbers.
PLAN_HEALTH_SCHEMA = "plan-health/4"
# The plan-review record shapes. Module-level because the query and the
# rules all parse them: one pattern, no copies.
PLAN_REVIEW_HEADING_RE = re.compile(r"^#{2,6}\s+Plan review\b", re.IGNORECASE | re.MULTILINE)
FINDINGS_RE = re.compile(r"Raw findings:\s*(\S+\.md)")
# A risk acceptance terminates one escalation: target (a finding ID, a
# run ID, or `outage <rung> <date>`), approver, action owner, record
# date, expiry, review date, evidence commit, an optional supersedes
# link, and a free-text rationale tail. Semicolon-separated like
# provenance; the rationale rides last so it may itself contain
# semicolons.
RISK_ACCEPTED_RE = re.compile(
    r"^Risk accepted:\s*(.+?);\s*approver\s+([A-Za-z0-9_.-]+);\s*owner\s+([A-Za-z0-9_.-]+);\s*"
    r"date\s+(\d{4}-\d{2}-\d{2});\s*expires\s+(\d{4}-\d{2}-\d{2});\s*review\s+(\d{4}-\d{2}-\d{2});\s*"
    r"evidence\s+([0-9a-f]{7,40});\s*(?:supersedes\s+(\d{4}-\d{2}-\d{2});\s*)?rationale\s+(.+?)\s*$"
)
RISK_TARGET_RE = re.compile(r"(?:[A-Z0-9]+-T[0-9]+-S[0-9]+-)?PR[0-9]+$", re.IGNORECASE)
# An outage target binds its instance: the rung plus the outage
# marker's stamp date, date last so multi-word rungs still parse. A
# true both-rung outage carries no run, so no compound can name one;
# the rung-plus-date key is the instance.
RISK_OUTAGE_RE = re.compile(r"^outage\s+(.+?)\s+(\d{4}-\d{2}-\d{2})$", re.IGNORECASE)


def risk_target_kind(target: str) -> str | None:
    """Classify a risk-acceptance target.

    Returns `finding` for a ledger row ID (namespaced or bare `PRn`,
    file-scoped at cover time), `run` for a shaped run ID, `outage`
    for `outage <rung> <date>`, or None when the target names nothing
    coverable. One classifier serves the validator's shape leg and
    the query's covering lookup.
    """
    if RISK_TARGET_RE.match(target):
        return "finding"
    if RUN_ID_SHAPE_RE.match(target):
        return "run"
    om = RISK_OUTAGE_RE.match(target.strip())
    if om is not None:
        try:
            datetime.strptime(om.group(2), "%Y-%m-%d")
        except ValueError:
            return None
        if om.group(1).strip():
            return "outage"
    return None


def outage_key(target: str) -> tuple[str, str] | None:
    """The (rung, date) instance key of an outage target, or None when
    the target is not a shaped outage (the classifier already failed
    it; this never disagrees)."""
    om = RISK_OUTAGE_RE.match(target.strip())
    if om is None:
        return None
    return (om.group(1).strip().lower(), om.group(2))


def acceptance_lines(stripped_text: str) -> list[tuple[str, str, str, str, str, str, str, str, str, str]]:
    """Parse live `Risk accepted:` lines from fence-stripped findings text.

    Returns (target, approver, owner, expires, recorded, review,
    evidence, supersedes, rationale, kind) per well-formed line, in
    file order (supersedes is "" when the record stands alone).
    Malformed or uncoverable lines are skipped, never fatal: they are
    the validator's to flag; the query only consults acceptances for
    live escalations, so a bad line fails loud as a persisting
    escalation, never as a query crash.
    """
    out = []
    for ln in stripped_text.splitlines():
        if not ln.startswith("Risk accepted:"):
            continue
        am = RISK_ACCEPTED_RE.match(ln)
        if am is None:
            continue
        kind = risk_target_kind(am.group(1))
        if kind is None:
            continue
        out.append(
            (
                am.group(1),
                am.group(2),
                am.group(3),
                am.group(5),
                am.group(4),
                am.group(6),
                am.group(7),
                am.group(8) or "",
                am.group(9),
                kind,
            )
        )
    return out


def acceptances_in(ftext: str) -> list[tuple[str, str, str, str, str, str, str, str, str, str]]:
    """Parse `Risk accepted:` lines from raw findings text (fences strip first)."""
    stripped, _u = strip_fenced_code(ftext)
    return acceptance_lines(stripped)


def review_ordered(
    tend: str | None, rend: str | None, tgt_day: str | None, reviewer_day: str
) -> bool:
    """Whether the target review postdates the finding review.

    Duration ends order when both reviews carry them (same-day fixes
    order by completion instant; ties fail closed); without both ends
    the day-stamp rule applies and same-day fails closed. Zulu shapes
    compare lexicographically; the parser stores only shaped ends.
    """
    if tend is not None and rend is not None:
        return tend > rend
    return (tgt_day or "") > reviewer_day


def fix_postdates_review(fix_ts: int | None, rts: int | None, reviewer_day: str) -> bool:
    """Whether the fix postdates the review completion.

    Unprovable timestamps fail closed. With a reviewer instant the fix
    must land strictly after it; without one the fix UTC day must
    strictly postdate the review day.
    """
    if fix_ts is None:
        return False
    if rts is not None:
        return fix_ts > rts
    fday = datetime.fromtimestamp(fix_ts, tz=timezone.utc).date().isoformat()
    return fday > reviewer_day


def acceptance_live(recorded: str, expires: str, today: str) -> bool:
    """Whether an acceptance covers today.

    Coverage needs recorded <= today <= expires: a post-dated record
    (a typo'd year, a waiver from the future) validates clean, which is
    shape plus inversion only and stays wall-clock-free, but covers
    nothing, so the escalation persists loud like any other dangling
    target. ISO dates compare lexicographically; the regex guarantees
    both fields are shaped.
    """
    return recorded <= today <= expires


def run_day(run_id: str) -> str:
    """The calendar day of a run ID's date prefix, or "" when the
    prefix is not a real date (shaped IDs always are; the guard keeps
    the query total)."""
    try:
        return datetime.strptime(run_id[:8], "%Y%m%d").date().isoformat()
    except ValueError:
        return ""


def superseded_acceptances(
    accs: list[tuple[str, str, str, str, str, str, str, str, str, str]],
) -> set[tuple[str, str]]:
    """Acceptance records a later line supersedes: (target, record
    date) pairs named by a `supersedes <date>` link on the same
    target. The chain head governs covering and the review leg;
    superseded records are history, never current."""
    return {(tgt.lower(), sup) for tgt, _a, _o, _e, _r, _v, _i, sup, _t, _k in accs if sup}


def evidence_fresh(sha: str, repo_path: str, current_text: str) -> bool:
    """Whether the owning record still reads as the acceptance's
    evidence commit saw it: the file bytes at the recorded commit
    equal today's bytes. Any change voids (fail-closed materiality:
    renewal rides a superseding record), and an unresolvable commit
    voids too (unprovable fails closed). The self-test patches
    `git_file_at`, never a repo.
    """
    was = git_file_at(sha, repo_path)
    if was is None:
        return False
    return was == current_text


def dim_failing(name: str, entries: list, strict: bool = False) -> bool:
    """Whether a plan-health dimension fails the gate.

    Strict (explicit `--fail-on`) fails on non-emptiness, exactly as the
    flag documents: zero tolerance, even for covered or complete items.
    Lenient (`--check`, `query summary`) fails only on actionables: a
    live risk acceptance terminates the escalation including the gate,
    and a bare partial is a complete review whose spare failed, so it
    lists but never fails (a gate that fails with nothing owed names no
    next action). Criticals and majors fail on any uncovered entry;
    degraded fails only on owed states (outage or retry-owed) without a
    live acceptance; all other dimensions fail on non-emptiness.
    """
    if strict:
        return bool(entries)
    if name == "degraded":
        return any(
            ("outage" in e.get("state", "") or "retry-owed" in e.get("state", ""))
            and not e.get("accepted_by")
            for e in entries
        )
    if name in ("criticals", "majors"):
        return any(not e.get("accepted_by") for e in entries)
    if name == "reviews":
        # Review-due is a warning, never a failure; review-overdue is
        # an owed action.
        return any(e.get("state") == "review-overdue" for e in entries)
    return bool(entries)


# The ledger is a structured block, not prose the query squints at:
# rows live between `Ledger:` and `End of ledger`, every non-blank
# line inside is a row or malformed, and `- [` lines outside the block
# are prose, never rows. No heuristic, no residuals.
LEDGER_OPEN_RE = re.compile(r"^Ledger:\s*$", re.IGNORECASE | re.MULTILINE)
LEDGER_CLOSE_RE = re.compile(r"^End of ledger\s*$", re.IGNORECASE | re.MULTILINE)
LEDGER_ROW_RE = re.compile(
    r"^\s*-\s*\[((?:[A-Z0-9]+-T[0-9]+-S[0-9]+-)?PR[0-9]+)\]\s*\[(critical|major|minor)\]\s+.+?->\s*(accepted|filed|duplicate|rejected|deferred)\b",
    re.IGNORECASE | re.MULTILINE,
)
MANIFEST_RE = re.compile(
    r"^Manifest:\s*sections\s*\[(.*?)\];\s*dependents\s*\[(.*?)\];\s*bytes\s*(\d+)(?:;\s*run\s+(\S+))?\s*$",
    re.IGNORECASE | re.MULTILINE,
)
# Row parts for the run query: the same shape LEDGER_ROW_RE just
# matched, split so structural fields (ID, severity, disposition)
# print whole while only prose truncates.
ROW_PARTS_RE = re.compile(
    r"^\s*-\s*\[(?P<id>[^\]]+)\]\s*\[(?P<sev>[^\]]+)\]\s*(?P<text>.+?)\s*->\s*(?P<disp>[A-Za-z]+)\s*$"
)
# A run ID binds one review run across its marker, manifest, rows, and
# artifacts: `YYYYMMDD-DNN-TNN-SN-<family>[-rN]`. The date prefix is
# the run's timestamp; `-rN` disambiguates reruns. Numbering: within
# one date base the bare base is run 1, `-rN` is run N for N >= 2,
# `-r1` is run 1's accepted synonym (never minted), and `-r0` is
# outside the shape (no leading zeros anywhere in the suffix).
# Numbering restarts per day; the date keeps runs distinct.
RUN_ID_SHAPE_RE = re.compile(r"^\d{8}-D\d+-T\d+-S\d+-[a-z0-9]+(-r[1-9][0-9]*)?$")
_RUN_BASE_RE = re.compile(r"^\d{8}-D\d+-T\d+-S\d+-[a-z0-9]+$")


def normalize_run_id(run: str) -> str:
    """Read a run ID through the `-r1` synonym.

    Every lineage comparison (duplicate runs, supersedes targets,
    marker-manifest match) normalizes first, so `-r1` and the bare base
    compare as the run they both name. The strip applies only when the
    remainder is a bare base, so a family literally named `r1` survives.
    """
    if run.endswith("-r1") and _RUN_BASE_RE.match(run[:-3]):
        return run[:-3]
    return run


def marker_states(body: str) -> dict[str, bool]:
    # The five grammar predicates over one marker body. One function
    # serves the validator's last-line grammar, the outage-predecessor
    # test, and the run query, so every site reads `outage marker` the
    # same way (a bare `outage:` substring also matches prose about an
    # outage beside real filings).
    low = body.lower()
    return {
        "outage": "outage:" in low,
        "nofind": "no findings" in low,
        "filed": re.search(r"\bfiled\b", low) is not None,
        "retry": "retry-owed" in low,
        "partial": re.search(r"\bpartial\s*:", low) is not None,
    }


def is_outage_marker(body: str) -> bool:
    # A predecessor counts as the outage a rerun follows only when it
    # parses as an outage marker: `outage:` with none of the success
    # states beside it. Prose that merely mentions an outage beside
    # filings is a normal marker, and a rerun after it chains via
    # `supersedes`.
    st = marker_states(body)
    return st["outage"] and not (st["filed"] or st["nofind"] or st["retry"] or st["partial"])


def section_markers(todo_lines: dict[str, list[str]], todo: Todo, num: int) -> list[str] | None:
    """Every `Plan review:` line body of one section, in file order.

    A range stamp's fields reach sections whose spans hold no marker
    lines; those read the parsed body as their single line.
    """
    if todo.path not in todo_lines:
        try:
            todo_lines[todo.path] = (TODO_DIR.parent / todo.path).read_text(encoding="utf-8").splitlines()
        except OSError:
            return None
    lines = todo_lines[todo.path]
    spans = sorted((s2.line or 0, n2) for n2, s2 in todo.sections.items())
    start = max(todo.sections[num].line or 0, 1)
    following = [ln for ln, _n in spans if ln > start]
    end = following[0] if following else len(lines) + 1
    out = []
    for ln in lines[start - 1 : end - 1]:
        sm = STAMP_RE.match(ln)
        if sm and sm.group("kind") == "Plan review":
            out.append(sm.group("body"))
    if not out:
        parsed = (todo.sections[num].plan_review_body or "").strip()
        if parsed:
            out.append(parsed)
    return out


RETIRED_RE = re.compile(r"^>\s*\*\*Retired:\*\*\s*(\d{4}-\d{2}-\d{2})\s*\|\s*([^|]+?)\s*\|\s*(.+?)\s*$")


def section_retired(todo_lines: dict[str, list[str]], todo: Todo, num: int) -> str | None:
    """Retirement date of one section, or None.

    A retirement note (`> **Retired:** YYYY-MM-DD | ref | reason`)
    migrates a grandfathered stamp without asserting a review that
    never ran. Fail-closed: the date must be real, the ref must name
    this section (a copied note never migrates its new neighbor),
    and the reason must be non-empty, so prose merely mentioning
    retirement never counts. Malformed notes read as absent: the
    stamp stays listed and the gap stays visible.
    """
    if todo.path not in todo_lines:
        try:
            todo_lines[todo.path] = (TODO_DIR.parent / todo.path).read_text(encoding="utf-8").splitlines()
        except OSError:
            return None
    lines = todo_lines[todo.path]
    spans = sorted((s2.line or 0, n2) for n2, s2 in todo.sections.items())
    start = max(todo.sections[num].line or 0, 1)
    following = [ln for ln, _n in spans if ln > start]
    end = following[0] if following else len(lines) + 1
    for ln in lines[start - 1 : end - 1]:
        rm = RETIRED_RE.match(ln)
        if rm is None:
            continue
        try:
            datetime.strptime(rm.group(1), "%Y-%m-%d")
        except ValueError:
            continue
        xm = XREF_RE.fullmatch(rm.group(2).strip())
        if xm is None or int(xm.group("sec")) != num:
            continue
        xdom, xtodo = xm.group("dom"), xm.group("todo")
        if xdom is not None and not todo.domain.startswith(xdom + "-"):
            continue
        if xtodo is not None and xtodo != todo.number:
            continue
        if not rm.group(3).strip():
            continue
        return rm.group(1)
    return None


RUN_ID_RE = re.compile(r"\brun\s+(\S+?)(?=[,;)]|\s|$)")
SUPERSEDES_RE = re.compile(r"\bsupersedes\s+(\S+?)(?=[,;)]|\s|$)")
# A clearance names the commit that carries the fix: `fix <sha>` in the
# target section, proven against the commit's tree. Multi-commit fix
# loops name the range instead: `fix <base>..<tip>` proves the tip
# tree, base-to-tip ancestry, and a touch inside the range. Shorts stay
# legal: git refuses ambiguous ones, so resolution failure fails closed
# like any unprovable leg.
FIX_COMMIT_RE = re.compile(r"\bfix\s+([0-9a-fA-F]{7,40})(?:\.\.([0-9a-fA-F]{7,40}))?\b")
# A clearance names its proof: `proof <finding-id> <path>[::<test>]`
# in the target section, resolved at the fix tip tree. The query
# proves the pointer names this row and resolves; the target's own
# review attests the test exercises the finding's acceptance condition.
PROOF_RE = re.compile(r"\bproof\s+(\S+)\s+(\S+)")
OWNER_RE = re.compile(r"\bowner\s+([A-Za-z0-9_.-]+)")
DUE_RE = re.compile(r"\bdue\s+(\d{4}-\d{2}-\d{2})")
FOLLOWS_OUTAGE_RE = re.compile(r"\bfollows-outage\b")
# A provenance line binds one live quote to its run: candidate,
# command, exit, tool, digest, path, and run, in that order,
# semicolon-separated. The run is mandatory: run-less provenance
# fails the shape.
PROVENANCE_RE = re.compile(
    r"^Provenance:\s*candidate\s+(\S+);\s*command\s+(.+?);\s*exit\s+(\d+);\s*tool\s+(.+?);\s*digest\s+([0-9a-fA-F]+);\s*path\s+(\S+?);\s*run\s+(\S+?)\s*$"
)


def ledger_block(sec: str) -> tuple[str | None, str | None]:
    """The ledger rows of one Plan review section, or the block defect.

    Returns (block_text, None) on a well-formed block, (None, problem)
    when the `Ledger:`/`End of ledger` structure is missing or broken.
    Rows are only rows inside the block; outside it, `- [` lines are
    prose and no heuristic reads them.
    """
    opens = list(LEDGER_OPEN_RE.finditer(sec))
    closes = list(LEDGER_CLOSE_RE.finditer(sec))
    if not opens:
        return None, "without a Ledger: block"
    if len(opens) > 1:
        return None, "with two Ledger: openers"
    if not closes:
        return None, "with an unclosed Ledger: block"
    if closes[0].start() < opens[0].end():
        return None, "with End of ledger before Ledger:"
    return sec[opens[0].end():closes[0].start()], None


# A finding ID on its own: the row grammar's group 1 as a full token,
# so a `supersedes <target>` link names a row, never prose.
FINDING_ID_RE = re.compile(r"(?:[A-Z0-9]+-T[0-9]+-S[0-9]+-)?PR[0-9]+\Z", re.IGNORECASE)


def finding_namespace(fid: str) -> str:
    """The review namespace of a finding ID: the `D..-T..-S..-` prefix,
    or "" for a bare `PRn`. Amendments stay inside one namespace, so a
    bare row amends bare rows and a namespaced row amends its review."""
    m = re.match(r"(.*?)(PR[0-9]+)\Z", fid, re.IGNORECASE)
    return m.group(1).lower() if m else ""


def ledger_supersedes(block: str) -> dict[str, str]:
    """Row ID (lowercased) -> superseded target for one ledger block.

    The link is `supersedes <finding-id>` after the disposition: the
    token must be exactly ID-shaped, so prose before the arrow (a
    title like `Singleton supersedes stays silent`) and non-ID tokens
    after it are never links. First link wins per row.
    """
    links: dict[str, str] = {}
    for lr in LEDGER_ROW_RE.finditer(block):
        rest = block[lr.end():].split("\n", 1)[0]
        sm = SUPERSEDES_RE.search(rest)
        if sm is None or not FINDING_ID_RE.fullmatch(sm.group(1)):
            continue
        links.setdefault(lr.group(1).lower(), sm.group(1))
    return links


def ledger_supersession(block: str) -> tuple[dict[str, str], set[str]]:
    """(valid links, cyclic rows) for one ledger block.

    A link is valid when its target names another row of the same
    block in the same review namespace and neither end sits in a
    supersedes cycle. Cycles invalidate the members' links (the
    validator owns the failure); the query resolves the rest, so a
    broken link never hides a row and never loops the scan.
    """
    ids = {lr.group(1).lower() for lr in LEDGER_ROW_RE.finditer(block)}
    valid: dict[str, str] = {}
    for rid, tgt in ledger_supersedes(block).items():
        if finding_namespace(tgt) != finding_namespace(rid):
            continue
        if tgt.lower() not in ids:
            continue
        valid[rid] = tgt.lower()
    cyclic: set[str] = set()
    for start in valid:
        path: list[str] = []
        cur: str | None = start
        while cur is not None and cur in valid and cur not in path:
            path.append(cur)
            cur = valid[cur]
        if cur is not None and cur in path:
            cyclic.update(path[path.index(cur):])
    for rid in cyclic:
        valid.pop(rid, None)
    return valid, cyclic


def superseded_ids(block: str) -> set[str]:
    """Rows of one ledger block another valid row supersedes:
    plan-health reads the un-superseded head of each chain as current
    and skips the rest."""
    return set(ledger_supersession(block)[0].values())


def git_file_at(ref: str, repo_path: str) -> str | None:
    """File bytes at a git ref, or None when unprovable (no git, no ref,
    no file). One reader for the history rule and the clearance proof;
    the self-test patches this name, never a repo."""
    try:
        import subprocess

        out = subprocess.run(
            ["git", "-C", str(REPO), "show", f"{ref}:{repo_path}"],
            capture_output=True,
            timeout=30,
        )
    except Exception:
        return None
    if out.returncode != 0:
        return None
    try:
        return out.stdout.decode("utf-8")
    except UnicodeDecodeError:
        return None


def git_commit_touches(sha: str, repo_path: str) -> bool | None:
    """Whether a commit touched a path, or None when unprovable. The
    clearance proof names non-merge commits (merges list no files, so
    they fail closed); the self-test patches this name, never a repo."""
    try:
        import subprocess

        out = subprocess.run(
            ["git", "-C", str(REPO), "show", "--pretty=format:", "--name-only", sha, "--", repo_path],
            capture_output=True,
            timeout=30,
        )
    except Exception:
        return None
    if out.returncode != 0:
        return None
    return repo_path in out.stdout.decode("utf-8", "replace").splitlines()


def git_commit_ts(sha: str) -> int | None:
    """Committer time of a commit (unix epoch, offset-free), or None when
    unprovable.

    The clearance recency leg: the fix must postdate the review
    completion. Committer time, not author time: landing is the ordered
    event. Unix epoch, never a rendered day: `%cs` renders in the
    commit's own offset, so a day read off it is not UTC. Off-shape
    output reads None, never raises; the self-test patches this name,
    never a repo.
    """
    try:
        import subprocess

        out = subprocess.run(
            ["git", "-C", str(REPO), "log", "-1", "--pretty=%ct", sha],
            capture_output=True,
            timeout=30,
        )
    except Exception:
        return None
    if out.returncode != 0:
        return None
    raw = out.stdout.decode("utf-8", "replace").strip()
    if not re.fullmatch(r"\d+", raw):
        return None
    return int(raw)


def git_is_ancestor(base: str, tip: str) -> bool | None:
    """Whether base is an ancestor of tip, or None when unprovable. The
    range sanity leg: a fix loop is linear, so a tip that does not
    descend from its base fails closed."""
    try:
        import subprocess

        out = subprocess.run(
            ["git", "-C", str(REPO), "merge-base", "--is-ancestor", base, tip],
            capture_output=True,
            timeout=30,
        )
    except Exception:
        return None
    if out.returncode == 0:
        return True
    if out.returncode == 1:
        return False
    return None


def git_range_touches(base: str, tip: str, repo_path: str) -> bool | None:
    """Whether a non-merge commit in base..tip touched a path, or None
    when unprovable. The range touch leg."""
    try:
        import subprocess

        out = subprocess.run(
            [
                "git",
                "-C",
                str(REPO),
                "log",
                "--no-merges",
                "--pretty=format:",
                "--name-only",
                f"{base}..{tip}",
                "--",
                repo_path,
            ],
            capture_output=True,
            timeout=30,
        )
    except Exception:
        return None
    if out.returncode != 0:
        return None
    return repo_path in out.stdout.decode("utf-8", "replace").splitlines()


def git_resolves(sha: str) -> bool | None:
    """Whether a sha names an object in the repo, or None when
    unprovable. The provenance-candidate leg: a recorded candidate
    that resolves to nothing attests nothing. Shorts stay legal: git
    refuses ambiguous ones, so resolution failure fails closed like
    any unprovable leg; the self-test patches this name, never a
    repo. `rev-parse --verify --quiet` carries the three states (0
    resolves, 1 names nothing, anything else unprovable): `cat-file
    -e` conflates an absent short with a fatal at 128, which would
    report every bogus candidate as unprovable instead of missing.
    The `^{object}` peel forces the existence check a bare
    full-length hex skips (rev-parse prints an absent 40-hex back at
    exit 0; peeled it exits 1 like an absent short)."""
    try:
        import subprocess

        out = subprocess.run(
            ["git", "-C", str(REPO), "rev-parse", "--verify", "--quiet", f"{sha}^{{object}}"],
            capture_output=True,
            timeout=30,
        )
    except Exception:
        return None
    if out.returncode == 0:
        return True
    if out.returncode == 1:
        return False
    return None


def moved_target(body: str) -> str:
    m = MOVED_PATH_RE.search(body)
    return m.group("path") if m else ""


def _moved_by_ref(todos: list["Todo"]) -> dict[str, str]:
    """'D00 T07 §25' -> the Moved: body, for every section carrying the marker."""
    out: dict[str, str] = {}
    for t in todos:
        dom = t.domain.split("-")[0]
        for num, s in t.sections.items():
            if s.moved:
                out[f"D{dom} T{t.number} §{num}"] = s.moved
    return out


def review_dependents(key, rev: dict, rev_xref: dict) -> set:
    """Review dependents: direct reverse Depends, XREF-only consumers,
    and one transitive Depends hop past the direct set. One hop is the
    documented bound: the manifest records it, and deeper chains
    surface hop by hop as each layer reviews, so no chain is
    invisible, only ever one review away. Full transitive closure
    would pin every review's scope to the whole downstream tree; the
    bound keeps the manifest review-sized while the hop-by-hop
    surfacing keeps it complete."""
    direct = set(rev.get(key, ())) | set(rev_xref.get(key, ()))
    trans = set()
    for d in direct:
        trans |= set(rev.get(d, ()))
    return direct | trans


def cmd_validate(_args) -> int:
    spec = importlib.util.spec_from_file_location("todo_validate", REPO / "scripts/todo-validate.py")
    if spec is None or spec.loader is None:
        raise RuntimeError("TODO validator unavailable")
    validator = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(validator)
    return validator.validate(sys.modules[__name__], _args)


def adjacency_module():
    spec = importlib.util.spec_from_file_location("todo_adjacency", Path(__file__).with_name("todo-adjacency.py"))
    if spec is None or spec.loader is None:
        raise RuntimeError("TODO adjacency inspector unavailable")
    inspector = importlib.util.module_from_spec(spec)
    # Historical inspection must leave the caller's checkout unchanged,
    # including a fresh clone where __pycache__ is not ignored.
    previous_bytecode = sys.dont_write_bytecode
    try:
        sys.dont_write_bytecode = True
        spec.loader.exec_module(inspector)
    finally:
        sys.dont_write_bytecode = previous_bytecode
    return inspector


WARNING_BASELINE = REPO / "todo" / ".warning-baseline"


def warning_key(text: str) -> str:
    """A warning identified by file, section and class -- never by line number.

    Line numbers move whenever anything above them is edited, and a baseline
    keyed on them would go stale on every unrelated commit. File plus section
    plus the first few words of the class is stable and still specific enough
    that a genuinely new warning of an owned class is visible.
    """
    head, _, rest = text.partition(": ")
    path = head.split(":")[0]
    section = ""
    m = re.match(r"\s*§(\d+)", rest)
    if m:
        section = f"§{m.group(1)}"
    cls = " ".join(rest.split()[:8])
    return f"{path}|{section}|{cls}"


def load_warning_baseline() -> set[str] | None:
    if not WARNING_BASELINE.exists():
        return None
    return {
        line.strip()
        for line in WARNING_BASELINE.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.startswith("#")
    }


def cmd_warnings(args: argparse.Namespace) -> int:
    """Show the warning baseline, or re-accept the current set as the new one."""
    todos = load_todos()
    import io, contextlib as _c

    buf = io.StringIO()
    with _c.redirect_stdout(buf):
        cmd_validate(args)
    # Adjacency's semantic advisories deliberately never enter this ratchet.
    current = sorted(
        {warning_key(l[6:].strip()) for l in buf.getvalue().splitlines() if l.startswith(("WARN  ", "WARN* "))}
    )
    if getattr(args, "acked", False):
        # The debt register (D00 T01 §38): the pre-convention occurrences on
        # stamped sections, acknowledged out of the live WARN channel but
        # never dropped -- a shipped-work audit starts here.
        acked = getattr(cmd_validate, "last_acked", [])
        print(f"{len(acked)} acknowledged warning(s) -- stamped pre-convention")
        for a in acked:
            print(f"  ACK  {a}")
        return 0
    if not args.accept:
        base = load_warning_baseline() or set()
        print(f"baseline {len(base)} · current {len(current)}")
        for k in current:
            print(("  NEW  " if k not in base else "       ") + k)
        return 0
    WARNING_BASELINE.write_text(
        "# Warnings accepted as of the date below. A warning NOT in this file is\n"
        "# NEW and fails `validate`. The set may shrink and never grow without a\n"
        "# deliberate --accept. -> XREF: INT-0034.\n"
        f"# accepted {len(current)} warning(s)\n"
        + ("\n".join(current) + "\n" if current else ""),
        encoding="utf-8",
        newline=chr(10),
    )
    try:
        shown = WARNING_BASELINE.relative_to(REPO)
    except ValueError:
        # The self-test rebinds WARNING_BASELINE outside the repo; showing
        # the absolute path there beats crashing the accept it is testing.
        shown = WARNING_BASELINE
    print(f"accepted {len(current)} warning(s) into {shown}")
    return 0


def _cycles(edges: dict[str, set[str]], label: str) -> list[str]:
    out, state, stack = [], {}, []

    def walk(n: str) -> None:
        if state.get(n) == 2:
            return
        if state.get(n) == 1:
            cyc = stack[stack.index(n):] + [n]
            out.append(f"{label} dependency cycle: {' -> '.join(cyc)}")
            return
        state[n] = 1
        stack.append(n)
        for m in sorted(edges.get(n, ())):
            if m in edges:
                walk(m)
        stack.pop()
        state[n] = 2

    for n in sorted(edges):
        walk(n)
    return out


# --------------------------------------------------------------------- query


def _section_state(todos: list[Todo]):
    by_id = {t.id: t for t in todos if t.id}
    by_key = {(t.domain, t.number): t for t in todos}
    done: set[str] = set()
    for t in todos:
        for num, s in t.sections.items():
            if s.status == "x":
                done.add(f"{t.id} §{num}")
    return by_id, by_key, done


def unmet_dependencies(
    target: Todo, sec_num: int, todos: list[Todo], by_key, by_id: dict | None = None
) -> list[dict]:
    """ONE dependency gate for every resolver (D00 T01 §37).

    Before this existed, `query` walked section-row edges AND frontmatter
    whole-TODO edges while `resolve`/`classify`/the operator snapshot walked
    only the row edges, so the same open section was "blocked" in one
    canonical command and "ready" in the runner gate (measured: D07 T02 §6).
    Every caller now asks this function and formats its records; none may
    re-implement readiness semantics.

    Returns one record per unmet edge for §sec_num of `target`:
      section edge  {"kind": "section", "todo_id", "query_label": "<id> §N",
                     "dnn": "DNN TNN §N"}
      whole-TODO    {"kind": "todo", "todo_id", "query_label":
                     "<id> (whole TODO)", "dnn": "... first open §N, K open",
                     "first_open": N|None, "open_count": K}
      unknown       {"kind": "unknown", "query_label", "dnn"} -- an edge that
                     does not resolve is UNMET, never silently ready;
                     `validate` separately reports it FATAL.

    A whole-TODO dependency is complete only when every numbered section in
    that TODO is [x]. An EMPTY prerequisite TODO is unmet: nothing shipped is
    not everything shipped, and `all()` over an empty set must not open the
    gate accidentally. A section carrying `> **Moved:**` counts as done for
    this gate: its row can never flip here, so holding the file edge on it
    would stall whole-TODO dependents forever.
    """
    if sec_num not in target.sections:
        # Callers gate on membership first (resolve/classify exit 1, query
        # iterates real sections); an absent section has no edges to report.
        return []
    s = target.sections[sec_num]
    if by_id is None:
        by_id = {t.id: t for t in todos if t.id}
    unmet: list[dict] = []
    for raw in s.depends_on:
        r = resolve_ref(raw, target, by_key)
        src = by_id.get(r[0]) if r else None
        if src is None or r[1] not in src.sections:
            # Label with the normalized form when the ref at least resolved,
            # byte-matching what query printed before the gate was unified;
            # `validate` rule 5b reports all three unknown shapes FATAL.
            label = f"{r[0]} §{r[1]}" if r else raw
            unmet.append({"kind": "unknown", "query_label": label, "dnn": label})
            continue
        if src.sections[r[1]].moved:
            # Worked outside the tree (writers-and-reviewers §2): its row can
            # never flip here, so a dependent that waited on it would wait
            # forever. The edge is kept for the record and counts as met.
            continue
        if src.sections[r[1]].status != "x":
            sdom = src.domain.split("-")[0]
            unmet.append(
                {
                    "kind": "section",
                    "todo_id": src.id,
                    "query_label": f"{src.id} §{r[1]}",
                    "dnn": f"D{sdom} T{src.number} §{r[1]}",
                }
            )
    for dep in target.depends_on:
        dt = by_id.get(dep)
        if dt is None:
            unmet.append(
                {
                    "kind": "unknown",
                    "query_label": f"{dep} (whole TODO)",
                    "dnn": f"{dep} (whole TODO)",
                }
            )
            continue
        open_secs = sorted(
            n for n, x in dt.sections.items() if x.status != "x" and not x.moved
        )
        if open_secs or not dt.sections:
            ddom = dt.domain.split("-")[0]
            first = f"§{open_secs[0]}" if open_secs else "no sections"
            unmet.append(
                {
                    "kind": "todo",
                    "todo_id": dep,
                    "query_label": f"{dep} (whole TODO)",
                    "dnn": (
                        f"{dep} (whole TODO; D{ddom} T{dt.number}, "
                        f"first open {first}, {len(open_secs)} open)"
                    ),
                    "first_open": open_secs[0] if open_secs else None,
                    "open_count": len(open_secs),
                }
            )
    return unmet


def cmd_query(args) -> int:
    if args.what != "run" and getattr(args, "target", None):
        print(f"query {args.what} takes no target")
        return 2
    if args.what == "adjacency":
        return adjacency_module().cli(sys.modules[__name__], args)
    todos = load_todos()
    by_id, by_key, done = _section_state(todos)
    what = args.what

    if what == "sequence":
        edges, titles = _section_edges(todos)
        chain = _longest_chain(edges)
        # `done` from _section_state is keyed by TODO id, not by the canonical
        # DNN TNN §N reference this report uses, so it cannot be looked up here.
        shipped = {
            f"D{t.domain.split('-')[0]} T{t.number} §{num}"
            for t in todos for num, sec in t.sections.items() if sec.status == "x"
        }
        remaining = [r for r in chain if r not in shipped]
        print(f"sequence: longest dependency chain is {len(chain)} section(s) deep, "
              f"{len(remaining)} still open\n")
        for i, ref in enumerate(reversed(chain)):
            mark = "x" if ref in shipped else " "
            print(f"  {i + 1:>2}. [{mark}] {ref:14} {titles.get(ref, '')[:52]}")
        print("\n  Every section above waits on the one before it. Delay on an OPEN")
        print("  one costs more than delay anywhere else, because nothing later on")
        print("  the chain can start early. The shipped ones are shown for shape:")
        print("  they set the structure and can no longer be delayed.")

        couplings, coupling_problems = _filing_couplings()
        print(f"\n  coupling candidates from review findings: {len(couplings)}")
        if not couplings:
            if coupling_problems:
                print("    None READABLE. That is not the same as none existing:")
            else:
                print("    None. No review has filed a finding to another section, so there")
            print("    is no evidence here either way.")
        else:
            for src, dst, summary in couplings:
                in_deps = dst in edges.get(src, [])
                note = "already a dependency" if in_deps else "NOT a dependency"
                print(f"    {src} -> {dst}  ({note})")
                print(f"      {summary[:66]}")
            print("\n    A filing means one section ran into work another one owns. That")
            print("    is coupling the dependency graph does not carry. It is NOT proof")
            print("    the order is wrong: most filings are work found early, not work")
            print("    needed first.")

        if coupling_problems:
            print("\n  the filing evidence is INCOMPLETE:")
            for problem in coupling_problems:
                print(f"    {problem}")
            print("    Findings that could not be read are not counted above, so the")
            print("    coupling list is a floor rather than the whole picture.")

        print("\n  This command proposes and cannot act. It opens no file for writing.")
        print("  Take a change through the `groom-plan` skill, which is where section")
        print("  addresses, cross-references and the plan projection are kept consistent.")
        return 0

    if what == "calibration":
        try:
            rows = _calibration_rows(todos)
        except GitUnavailable as exc:
            # Loudly, and with nothing reported. A git failure used to become a
            # zero, which entered the outlier maths and would have entered the
            # correlation as an observation of a section that cost nothing.
            print(f"calibration: cannot measure -- {exc}")
            print("  No rows are reported. An unanswerable question is not an answer of zero.")
            return 1
        total_sections = sum(len(t.sections) for t in todos)
        print(f"calibration: {len(rows)} stamped section(s) of {total_sections}\n")
        if not rows:
            print("  Nothing has been stamped yet, so there is nothing to calibrate.")
            return 0
        print(f"  {'section':14} {'items':>5} {'commits':>7} {'minutes':>7}  rework")
        for r in rows:
            mins = "--" if r["minutes"] is None else str(r["minutes"])
            rw = {True: "yes", False: "no", None: "?"}[r["rework"]]
            print(f"  {r['ref']:14} {r['items']:>5} {r['commits']:>7} {mins:>7}  {rw}")
        print("  rework: a commit owned by the section between its ship and its stamp,")
        print("  which is review finding something. A raw commit count cannot see it.")

        # Outliers: a section whose commit count is far from what its item count
        # would suggest. Named, never explained away: the reason is usually
        # outside the plan, which is exactly why an outlier is a question.
        ratios = [(r, r["commits"] / r["items"]) for r in rows if r["items"]]
        if ratios:
            mean = sum(x for _, x in ratios) / len(ratios)
            far = [(r, x) for r, x in ratios if abs(x - mean) > 0.5 * max(mean, 0.01)]
            if far:
                print("\ncommits per item, mean {:.2f}. Furthest from it:".format(mean))
                for r, x in sorted(far, key=lambda p: -abs(p[1] - mean)):
                    print(f"    {r['ref']:14} {x:.2f}")
                print("  An outlier is a question, not a conclusion. A section may have")
                print("  cost what it did for reasons the plan never recorded.")

        print(f"\nsample {len(rows)}, threshold {CALIBRATION_MIN_SAMPLE}")
        if not _calibration_reports_correlation(len(rows)):
            print("  NO CORRELATION IS REPORTED. The sample is below the threshold, and a")
            print("  correlation over this many points is noise with a number attached.")
            print("  Quoting one would produce a figure that looks like evidence, gets")
            print("  cited, and never was. See D00 T04 §3 for why the threshold is 30.")
        else:
            r = _pearson([x["items"] for x in rows], [x["commits"] for x in rows])
            if r is None:
                print("  items against commits: not computable on this sample.")
            else:
                print(f"  items against commits: r = {r:.2f} over {len(rows)} sections.")
            print("  A correlation is still not a cause: item count and cost may both")
            print("  follow from something the plan does not record.")
        return 0


    if what == "stats":
        secs = [s for t in todos for s in t.sections.values()]
        by_status: dict[str, int] = {}
        for t in todos:
            by_status[t.status or "?"] = by_status.get(t.status or "?", 0) + 1
        print(f"domains          {len(list(TODO_DIR.glob('*/INDEX.md')))}")
        print(f"todo files       {len(todos)}")
        print(f"sections         {len(secs)}")
        print(f"  done [x]       {sum(1 for s in secs if s.status == 'x')}")
        print(f"  in progress [/]{sum(1 for s in secs if s.status == '/'):>2}")
        print(f"  open [ ]       {sum(1 for s in secs if s.status == ' ' and not s.moved)}")
        moved_n = sum(1 for s in secs if s.moved)
        if moved_n:
            print(f"  moved          {moved_n}  (worked outside the tree; `> **Moved:**` names where)")
        print(f"checklist items  {sum(s.items_done for s in secs)}/{sum(s.items_total for s in secs)}")
        print(f"frozen todos     {sum(1 for t in todos if t.frozen)}")
        print("todo status      " + ", ".join(f"{k}={v}" for k, v in sorted(by_status.items())))

        # The section cap REPORTS here and GATES in validate, deliberately
        # split. A warning would have to fail validate to be seen (a new WARN
        # outside the baseline returns 1), and the largest file was already at
        # 53 when the cap was set -- so the only honest early warning is one
        # that does not gate. A file arriving at 55 with no notice is the
        # surprise this line exists to prevent.
        near = sorted(
            ((len(t.sections), t.path) for t in todos
             if len(t.sections) >= MAX_SECTIONS_PER_FILE - 5),
            reverse=True,
        )
        if near:
            print(f"section cap      {MAX_SECTIONS_PER_FILE} per file; nearest:")
            for count, path in near:
                left = MAX_SECTIONS_PER_FILE - count
                room = f"{left} left" if left > 0 else "OVER CAP"
                print(f"  {count:>3}  {room:<9}  {path}")
        return 0

    if what == "deferred":
        open_, closed = [], []
        for t in todos:
            for d in t.deferred:
                (closed if d.resolved else open_).append((t, d))
        print("OPEN -- owed to another section")
        if not open_:
            print("    (none)")
        for t, d in open_:
            owner = d.ref or "NO OWNER"
            print(f"    {t.path}:{d.line}  -> {owner}")
            print(f"        {d.body[:150]}")
        print("\nRESOLVED -- closed, kept for the record")
        if not closed:
            print("    (none)")
        for t, d in closed:
            print(f"    {t.path}:{d.line}  -> {d.ref}")
            print(f"        {d.body[:150]}")
        print(f"\n{len(open_)} open, {len(closed)} resolved")
        print("Staleness is enforced by `validate`, not reported here: a deferral")
        print("whose owner has shipped is a FATAL, so it cannot sit in this list.")
        return 0

    if what == "findings":
        # Every finding, newest first, so "what have we noticed and not yet done"
        # is one command instead of ten greps. A finding filed as a plain checklist
        # item inside an unrelated section has no other tripwire: the deferral
        # lifecycle only catches the subset that names an owner.
        rows = []
        for t in todos:
            for num, sec in t.sections.items():
                for done, text in sec.items:
                    if text.lstrip().startswith("~~"):
                        continue  # struck: a decision recorded against, not a finding still open
                    m = FINDING_RE.search(text)
                    if m:
                        rows.append((m.group("date"), done, t.path, num, m.group("verb"), text))
        rows.sort(key=lambda r: (r[0], r[2], r[3]), reverse=True)

        open_rows = [r for r in rows if not r[1]]
        done_rows = [r for r in rows if r[1]]

        print("OPEN -- noticed, filed, not yet done")
        if not open_rows:
            print("    (none)")
        for date, _, path, num, verb, text in open_rows:
            body = re.sub(r"\s+", " ", text).strip()
            print(f"    {date}  {path}  §{num}  ({verb.lower()})")
            print(f"        {body[:160]}")

        if args.all:
            print("\nCLOSED -- filed and since done, kept for the record")
            if not done_rows:
                print("    (none)")
            for date, _, path, num, verb, text in done_rows:
                body = re.sub(r"\s+", " ", text).strip()
                print(f"    {date}  {path}  §{num}  ({verb.lower()})")
                print(f"        {body[:160]}")

        print(f"\n{len(open_rows)} open, {len(done_rows)} closed, {len(rows)} total")
        if not args.all:
            print("Closed findings are hidden; pass --all to include them.")
        print("Findings that name an owner are ALSO tracked as deferrals, where a")
        print("stale one is a FATAL. A plain item here has no such tripwire, which")
        print("is exactly why this list exists.")
        return 0

    if what == "run":
        # One ID resolves to candidate, scope, findings, marker
        # lineage, outage state, and verified artifacts: the
        # operator's one run view instead of manual joins across
        # markers, manifests, and provenance lines. Comparisons read
        # through the -r1 synonym, so the base and -r1 name the same
        # run. A missing target exits 2 (no subject); an unmatched ID
        # exits 1 (nothing to show).
        target = (getattr(args, "target", None) or "").strip()
        if not target:
            print("usage: todo-graph.py query run <run-id>")
            return 2
        want = normalize_run_id(target)

        def _one_line(text: str, width: int) -> str:
            return re.sub(r"\s+", " ", text).strip()[:width]

        # Marker chains through the shared slice, so range-stamped
        # sections read their parsed fallback exactly like the
        # validator does and the two can never drift apart.
        chains: dict[tuple[str, int], list[str]] = {}
        _chain_lines: dict[str, list[str]] = {}
        for t in todos:
            for num in t.sections:
                bodies = section_markers(_chain_lines, t, num) or []
                if bodies:
                    chains[(t.path, num)] = bodies

        def _carries(bodies: list[str]) -> bool:
            for b in bodies:
                rm = RUN_ID_RE.search(b)
                if rm and normalize_run_id(rm.group(1)) == want:
                    return True
            return False

        carrying = {key: bodies for key, bodies in chains.items() if _carries(bodies)}
        # Findings files: every referenced file, deduped, fence-
        # stripped like the validator, so an orphan manifest run
        # still resolves to its record.
        seen_files: dict[str, str] = {}
        for t in todos:
            for _num, _s in t.sections.items():
                _fm = FINDINGS_RE.search(getattr(_s, "review_body", None) or "")
                if not _fm or _fm.group(1) in seen_files:
                    continue
                try:
                    _raw = (TODO_DIR.parent / _fm.group(1)).read_text(encoding="utf-8")
                except OSError:
                    continue
                seen_files[_fm.group(1)], _u = strip_fenced_code(_raw)
        manifests: list[tuple[str, str, str]] = []
        rows: list[tuple[str, str]] = []
        for _path, _text in sorted(seen_files.items()):
            for h in PLAN_REVIEW_HEADING_RE.finditer(_text):
                _sec = _text[h.end() :]
                _nxt = re.search(r"^#{1,6}\s+", _sec, re.MULTILINE)
                if _nxt:
                    _sec = _sec[: _nxt.start()]
                _mm = MANIFEST_RE.search(_sec)
                if not _mm or not _mm.group(4):
                    continue
                if normalize_run_id(_mm.group(4)) != want:
                    continue
                manifests.append((_path, _mm.group(1), _mm.group(2)))
                _block, _bp = ledger_block(_sec)
                if _block is None:
                    continue
                for _lr in LEDGER_ROW_RE.finditer(_block):
                    _rest = _block[_lr.end() :].split("\n", 1)[0]
                    _rm = ROW_PARTS_RE.match(_lr.group(0))
                    _rtext = _one_line(_rm.group("text"), 80) if _rm else ""
                    _row = f"- [{_lr.group(1)}] [{_lr.group(2)}] -> {_lr.group(3)}"
                    if _rest.strip():
                        _row += f" {_one_line(_rest, 140)}"
                    if _rtext:
                        _row += f" :: {_rtext}"
                    rows.append((_path, _row))
        candidates: list[tuple[str, str]] = []
        # File-level by design: Candidate lines name panel rounds and
        # carry no run, so per-record attribution is impossible; the
        # file's candidates are the review's candidates across its
        # rounds. Single-record files attribute exactly; multi-record
        # files decline rather than misattribute.
        for _path, _text in sorted(seen_files.items()):
            if not any(_path == _mp for _mp, _ms, _md in manifests):
                continue
            _records = len(list(PLAN_REVIEW_HEADING_RE.finditer(_text)))
            _lines = []
            for _cl in re.finditer(r"^Candidate:\s*(.+)$", _text, re.MULTILINE):
                _shas = re.findall(r"[0-9a-fA-F]{7,40}", _cl.group(1))
                if _shas:
                    _lines.append(" ".join(_shas))
            if _records > 1:
                candidates.append((_path, f"({len(_lines)} candidates across {_records} records: unattributable to one run)"))
            else:
                candidates.extend((_path, _ln) for _ln in _lines)
        artifacts: list[tuple[str, str, str, str, str, str, str]] = []
        for _path, _text in sorted(seen_files.items()):
            for _ln in _text.splitlines():
                _pm = PROVENANCE_RE.match(_ln)
                if not _pm or normalize_run_id(_pm.group(7)) != want:
                    continue
                artifacts.append(
                    (_path, _pm.group(1), _pm.group(2), _pm.group(3), _pm.group(4), _pm.group(5), _pm.group(6))
                )
        if not carrying and not manifests and not artifacts:
            print(f"unknown run: {target}")
            return 1
        print(f"run {target}")
        print("candidate -- review candidates in files carrying this run (file-level: rounds share the file)")
        if not candidates:
            print("    (none recorded)")
        for _path, _shas in candidates:
            print(f"    {_path} {_shas}")
        print("scope -- manifest scope carrying this run")
        if not manifests:
            print("    (none)")
        for _path, _scope, _deps in manifests:
            print(f"    {_path} sections [{_scope}] dependents [{_deps}]")
        print("findings -- ledger rows under this run")
        if not rows:
            print("    (none)")
        for _path, _row in rows:
            print(f"    {_path} {_row}")
        print("marker lineage -- full chains carrying this run")
        if not carrying:
            print("    (none)")
        for (_path, _num), _bodies in sorted(carrying.items()):
            for _i, _b in enumerate(_bodies, 1):
                _rm2 = RUN_ID_RE.search(_b)
                _run2 = _rm2.group(1) if _rm2 else "none"
                _sm2 = SUPERSEDES_RE.search(_b)
                _edge = f" supersedes {_sm2.group(1)}" if _sm2 else ""
                if FOLLOWS_OUTAGE_RE.search(_b):
                    _edge += " follows-outage"
                print(f"    {_path} §{_num} [{_i}/{len(_bodies)}] run={_run2}{_edge} :: {_one_line(_b, 120)}")
        print("outage state")
        _outages = [
            (_path, _num, _b)
            for (_path, _num), _bodies in sorted(carrying.items())
            for _b in _bodies
            if is_outage_marker(_b)
        ]
        if not _outages:
            print("    clean (no outage markers)")
        for _path, _num, _b in _outages:
            print(f"    {_path} §{_num} {_one_line(_b, 160)}")
        print("verified artifacts -- provenance bound to this run")
        if not artifacts:
            print("    (none)")
        for _path, _cand, _cmd, _exit, _tool, _digest, _ppath in artifacts:
            print(
                f"    {_path} candidate {_cand} exit {_exit} digest {_digest} "
                f"{_one_line(_cmd, 80)} ({_one_line(_tool, 40)}) {_ppath}"
            )
        return 0

    if what == "frozen":
        for t in todos:
            if not t.frozen:
                continue
            checked = sum(1 for s in t.sections.values() if s.has_freeze_check)
            print(f"{t.path}  ({checked}/{len(t.sections)} sections carry a Freeze check)")
        return 0

    if what == "surfaces":
        present: list[tuple[Todo, int, Section]] = []
        missing: list[tuple[Todo, int, Section, list[str]]] = []
        for t in todos:
            for num, s in sorted(t.sections.items()):
                if s.status == "x":
                    continue
                if not s.has_fidelity_block or s.fidelity_exempt:
                    continue
                lack = [
                    n
                    for n, ok in (
                        ("Job", s.has_job),
                        ("Treatment", s.has_treatment),
                        ("Chrome", s.has_chrome),
                    )
                    if not ok
                ]
                if lack:
                    missing.append((t, num, s, lack))
                else:
                    present.append((t, num, s))
        print("OPEN UI -- Job, Treatment, Chrome present")
        if not present:
            print("    (none)")
        for t, num, s in present:
            print(f"    {t.path} §{num}  {s.deliverable}")
        print("\nOPEN UI -- Fidelity page, contract incomplete")
        if not missing:
            print("    (none)")
        for t, num, s, lack in missing:
            print(f"    {t.path} §{num}  missing {', '.join(lack)}")
        print(f"\n{len(present)} present, {len(missing)} missing")
        return 0

    if what in ("plan-health", "summary"):
        # Governance visibility for the review loop. All dimensions are
        # mechanical (marker presence, heading scans, ledger rows, graph
        # edges); nothing here judges prose quality. Text and JSON share
        # one report dict. `query summary` shares this collection and
        # renders the operator digest (text-only, like ready/blocked/
        # stats; machines read --json).
        by_id = {t.id: t for t in todos if t.id}
        by_key = {(t.domain, t.number): t for t in todos}

        def _owed(s) -> bool:
            # One predicate for both dimensions: a stamp owes a plan
            # review unless the marker rule excuses it.
            return s.stamped_on is None or s.stamped_on > PLAN_REVIEW_CUTOFF

        # Structural XREF edges: only `-> XREF:` lines count, never bare
        # §mentions in prose or `filed §N` marker pointers. Filing
        # pointers are claims about where findings went, not scope the
        # review covered.
        out_xref: dict[tuple[str, int], set[tuple[str, int]]] = {}
        rev_xref: dict[tuple[str, int], set[tuple[str, int]]] = {}
        starts: dict[str, list[tuple[int, int]]] = {}
        for t in todos:
            secs = sorted(t.sections.items())
            starts[t.path or ""] = [(s.line or 0, num) for num, s in secs]
        for t in todos:
            if not t.path:
                continue
            try:
                raw = (TODO_DIR.parent / t.path).read_text(encoding="utf-8").splitlines()
            except OSError:
                continue
            spans = starts.get(t.path, [])
            for lineno, line in enumerate(raw, start=1):
                if "-> XREF:" not in line:
                    continue
                num = None
                for sl, sn in spans:
                    if sl <= lineno:
                        num = sn
                    else:
                        break
                if num is None or num not in t.sections:
                    continue
                # The clause only: trailing `-- prose`, `;`-joined SOURCE
                # keys, and parentheticals are not edges (a bare §ref in a
                # SOURCE clause once leaked §14 into §16's scope).
                clause = line.split("-> XREF:", 1)[1]
                for sep in (" -- ", ";", " ("):
                    clause = clause.split(sep, 1)[0]
                for xm in XREF_RE.finditer(clause):
                    r = resolve_ref(xm.group(0), t, by_key)
                    if r and r[0] in by_id and r[1] in by_id[r[0]].sections:
                        out_xref.setdefault((t.id, num), set()).add(r)
                        rev_xref.setdefault(r, set()).add((t.id, num))

        marked = {}
        unmarked = []
        degraded = []
        grandfathered = []
        _ret_lines: dict[str, list[str]] = {}
        today = datetime.now(timezone.utc).date().isoformat()
        # Acceptance provenance: the validator checks only files
        # attached to a post-cutoff (or undated) stamp, first reporter
        # wins per file, so the query consults exactly that set. An
        # acceptance in a grandfathered-only file covers nothing: an
        # unvalidated waiver must fail loud as a persisting escalation,
        # never silence a gate.
        validated_files: set[str] = set()
        for _vt in todos:
            for _vnum in sorted(_vt.verified_sections):
                _vs = _vt.sections.get(_vnum)
                if _vs is None:
                    continue
                if (
                    _vs.stamped_on is not None
                    and _vs.stamped_on <= PLAN_REVIEW_CUTOFF
                ):
                    continue
                _vm = FINDINGS_RE.search(_vs.review_body or "")
                if _vm:
                    validated_files.add(_vm.group(1))
        acc_cache: dict[str, list] = {}
        todo_bytes: dict[str, str] = {}

        def todo_text(path: str) -> str:
            if path not in todo_bytes:
                try:
                    todo_bytes[path] = (TODO_DIR.parent / path).read_text(encoding="utf-8")
                except OSError:
                    todo_bytes[path] = ""
            return todo_bytes[path]

        def file_acceptances(path: str) -> list:
            if path not in acc_cache:
                if path not in validated_files:
                    acc_cache[path] = []
                else:
                    try:
                        acc_cache[path] = acceptances_in(
                            (TODO_DIR.parent / path).read_text(encoding="utf-8")
                        )
                    except OSError:
                        acc_cache[path] = []
            return acc_cache[path]

        for t in todos:
            for num in sorted(t.verified_sections):
                s = t.sections.get(num)
                if s is None:
                    continue
                body = (s.plan_review_body or "").strip()
                if not _owed(s):
                    # Unmarked and excused: the coverage hole `0 unmarked`
                    # hides. Marked grandfathered stamps stay in `marked`;
                    # retired ones drain out of the list (a dated
                    # retirement note migrates without asserting a
                    # review); only the invisible unmigrated set lists
                    # here.
                    if not body:
                        if section_retired(_ret_lines, t, num) is None:
                            grandfathered.append(
                                (
                                    f"{t.path} §{num}",
                                    s.stamped_on or "undated",
                                    migration_overdue_today(today),
                                )
                            )
                    else:
                        marked[(t.id, num)] = s.stamped_on or "undated"
                    continue
                if body:
                    marked[(t.id, num)] = s.stamped_on or "undated"
                    # Degraded states carry their accountability:
                    # `outage: <rung> (owner <n>, due <d>)`, `retry-owed
                    # (owner <n>, due <d>)`, or `partial: <rung>` (one
                    # rung failed, the other's findings stand). Missing
                    # fields read as unaccountable; a past due date reads
                    # as overdue and names its escalation (recipient
                    # operator, trigger the passed due date, action a
                    # rerun or recorded risk acceptance, terminal state a
                    # superseding marker or the acceptance note). A bare
                    # `partial` is a complete review whose spare failed,
                    # so missing fields are not unaccountable (the
                    # validator forbids accountability fields there);
                    # overdue still reads the due date, which only owed
                    # states can carry on a clean tree.
                    state = ""
                    if "outage:" in body.lower():
                        state = "outage"
                    if "retry-owed" in body:
                        state = f"{state}+retry-owed" if state else "retry-owed"
                    if re.search(r"\bpartial\s*:", body.lower()):
                        state = f"{state}+partial" if state else "partial"
                    if state:
                        om = OWNER_RE.search(body)
                        dm = DUE_RE.search(body)
                        owner = om.group(1) if om else ""
                        due = dm.group(1) if dm else ""
                        overdue = bool(due and due < today)
                        # A live risk acceptance terminates the escalation:
                        # run targets match the marker's run through the
                        # -r1 synonym, outage targets match the marker's
                        # rung plus stamp date (instance key), and finding
                        # targets never cover markers. Bare partials carry
                        # no escalation, so nothing consults for them.
                        ab, ae, ar, at, ao = "", "", "", "", ""
                        esc_owner = ""
                        if "outage" in state or "retry-owed" in state:
                            fm = FINDINGS_RE.search(s.review_body or "")
                            rm = RUN_ID_RE.search(body)
                            mrun = normalize_run_id(rm.group(1)) if rm else None
                            omt = re.search(r"outage:\s*([^\(;]+)", body.lower())
                            orung = omt.group(1).strip() if omt else None
                            stamp_day = s.stamped_on or ""
                            if fm:
                                accs = file_acceptances(fm.group(1))
                                supd = superseded_acceptances(accs)
                                for tgt, appr, own, exp, rec, rvw, evi, sup, rat, kind in accs:
                                    if (tgt.lower(), rec) in supd:
                                        continue
                                    okey = outage_key(tgt) if kind == "outage" else None
                                    match = (
                                        kind == "run"
                                        and mrun is not None
                                        and normalize_run_id(tgt) == mrun
                                    ) or (
                                        kind == "outage"
                                        and okey is not None
                                        and orung is not None
                                        and okey == (orung, stamp_day)
                                    )
                                    if not match:
                                        continue
                                    # The target predates the record (run
                                    # date prefix, outage stamp day); a
                                    # prewritten waiver covers nothing.
                                    tday = run_day(tgt) if kind == "run" else stamp_day
                                    if not tday or tday > rec:
                                        continue
                                    if not acceptance_live(rec, exp, today):
                                        # An expired match names the
                                        # escalation owner instead of
                                        # covering.
                                        if not esc_owner:
                                            esc_owner = own
                                        continue
                                    # Stale evidence voids (the TODO file
                                    # owns run and outage records). A
                                    # reopen needs no check here: it
                                    # discards the section from
                                    # verified_sections, so no acceptance
                                    # is ever consulted for it and every
                                    # cover voids by construction.
                                    if not evidence_fresh(evi, t.path, todo_text(t.path)):
                                        continue
                                    ab, ae, ar, at, ao = appr, exp, rvw, rat, own
                                    break
                            if ab:
                                overdue = False
                        degraded.append(
                            {
                                "ref": f"{t.path} §{num}",
                                "state": state,
                                "owner": owner,
                                "due": due,
                                "overdue": overdue,
                                "escalation": (
                                    (
                                        f"{esc_owner}: renew the acceptance or rerun the review"
                                        if esc_owner
                                        else "operator: rerun the review or record risk acceptance"
                                    )
                                    if overdue
                                    else ""
                                ),
                                "accepted_by": ab,
                                "accepted_owner": ao,
                                "accepted_expires": ae,
                                "accepted_review": ar,
                                "accepted_rationale": at,
                            }
                        )
                else:
                    unmarked.append((f"{t.path} §{num}", s.stamped_on or "undated"))
        labels = {(t.id, num): f"{t.path} §{num}" for t in todos for num in t.sections}
        rev = {}
        for t in todos:
            for num, s in t.sections.items():
                for raw in s.depends_on:
                    r = resolve_ref(raw, t, by_key)
                    if r and r[0] in by_id:
                        rev.setdefault((r[0], r[1]), set()).add((t.id, num))

        def _dependents(key) -> set:
            return review_dependents(key, rev, rev_xref)

        uncoverable = {
            (t.id, num)
            for t in todos
            for num in t.verified_sections
            if num in t.sections and _owed(t.sections[num])
        }
        uncovered = []
        for key in sorted(marked):
            for dep in sorted(_dependents(key)):
                # Stamped, review-owed dependents only: an unstamped section
                # cannot have had a plan review at all, and a
                # grandfathered stamp is excused. Either in this list
                # would be a gap no work can clear.
                if dep not in marked and dep in uncoverable:
                    uncovered.append((labels.get(dep, f"{dep[0]} §{dep[1]}"), labels.get(key, f"{key[0]} §{key[1]}")))
        # Fallback and outage classification: panel_fallback() reads the
        # stamp date against GPT_GOVERNS_FROM (D00 T04 §27), mirroring the
        # panel rule's last-wins instead of matching any heading.
        head_re = re.compile(r"^#{1,6}\s+", re.MULTILINE)
        fallback, outages, criticals, unreadable, stale = [], [], [], [], []
        majors, legacy = [], []
        seen = set()
        owners: dict[str, list] = {}
        unshaped: set[str] = set()
        target_texts: dict[str, str] = {}
        old_line = (datetime.now(timezone.utc).date() - timedelta(days=PLAN_REVIEW_OVERDUE_DAYS)).isoformat()
        for t in todos:
            for num in sorted(t.verified_sections):
                s = t.sections.get(num)
                if s is None:
                    continue
                m = FINDINGS_RE.search(s.review_body or "")
                if not m:
                    continue
                owners.setdefault(m.group(1), []).append((t, num))
                if m.group(1) in seen:
                    continue
                seen.add(m.group(1))
                try:
                    text = (TODO_DIR.parent / m.group(1)).read_text(encoding="utf-8")
                except OSError:
                    continue
                # Raw bytes stay for the evidence leg: the owning record
                # compares byte-for-byte against the evidence commit,
                # never stripped (a fence edit is a material change too).
                raw_text = text
                # Same stripper as the panel rule: a fenced worked
                # example must neither count as fallback usage nor as a
                # live critical. An unbalanced fence truncates the scan
                # at the opener, so the file is reported, never silently
                # half-read: the panel rule FATALs this only for
                # post-cutoff stamps, and grandfathered files have no
                # other diagnostic.
                text, unbalanced_opener = strip_fenced_code(text)
                if unbalanced_opener is not None:
                    unreadable.append((m.group(1), unbalanced_opener))
                is_fallback, has_note = panel_fallback(text, s.stamped_on)
                if is_fallback:
                    fallback.append(m.group(1))
                if has_note:
                    outages.append(m.group(1))
                for h in PLAN_REVIEW_HEADING_RE.finditer(text):
                    sec = text[h.end():]
                    nxt = head_re.search(sec)
                    if nxt:
                        sec = sec[:nxt.start()]
                    mm = MANIFEST_RE.search(sec)
                    block, _problem = ledger_block(sec)
                    if mm:
                        scope = set()
                        for grp in (mm.group(1), mm.group(2)):
                            for xm in XREF_RE.finditer(grp):
                                r = resolve_ref(xm.group(0), t, by_key)
                                if r and r[0] in by_id:
                                    scope.add(r)
                        current = {(t.id, num)}
                        for raw in (s.depends_on or []):
                            r = resolve_ref(raw, t, by_key)
                            if r and r[0] in by_id:
                                current.add(r)
                        current |= out_xref.get((t.id, num), set())
                        current |= _dependents((t.id, num))
                        new = current - scope
                        # Growth and removals both flag: a review that
                        # covered removed scope reviewed work that no
                        # longer exists there, which is stale, not
                        # generous. The manifest's run rides along;
                        # records predating runs report "".
                        gone = scope - current
                        if new or gone:
                            stale.append(
                                (
                                    m.group(1),
                                    mm.group(4) or "",
                                    sorted(labels.get(k, f"{k[0]} §{k[1]}") for k in new),
                                    sorted(labels.get(k, f"{k[0]} §{k[1]}") for k in gone),
                                )
                            )
                    else:
                        unshaped.add(m.group(1))
                    if block is None:
                        unshaped.add(m.group(1))
                        continue
                    # A superseded row reads as amended, not current: the
                    # chain head governs both dimensions, so superseded
                    # rows skip before severity sorts them.
                    skipped = superseded_ids(block)
                    for lr in LEDGER_ROW_RE.finditer(block):
                        if lr.group(1).lower() in skipped:
                            continue
                        sev = lr.group(2).lower()
                        disp = lr.group(3).lower()
                        rest = block[lr.end():].split("\n", 1)[0]
                        om = OWNER_RE.search(rest)
                        dm = DUE_RE.search(rest)
                        owner = om.group(1) if om else ""
                        # A deferred row's review date IS its due date
                        # under the deferred vocabulary
                        # (owner/date/trigger), so the query reports it
                        # as `due` rather than flagging a
                        # validator-legal row UNACCOUNTABLE: accepted
                        # rows must spell `due`, deferred rows satisfy
                        # it through `date`.
                        if dm:
                            due = dm.group(1)
                        elif disp == "deferred":
                            dd = re.search(r"\d{4}-\d{2}-\d{2}", rest)
                            due = dd.group(0) if dd else ""
                        else:
                            due = ""
                        # A live acceptance for this row terminates its
                        # escalation; file-scoped, so bare PRn targets
                        # are unambiguous here. The match folds case
                        # like the duplicate-ID rule (the target
                        # pattern admits lowercase, so an exact compare
                        # would validate a waiver that never covers);
                        # padded variants stay distinct IDs per that
                        # same rule, and a padded target dangles loud
                        # as a persisting escalation.
                        ab, ae, ar, at, ao = "", "", "", "", ""
                        esc_owner = ""
                        _accs = file_acceptances(m.group(1))
                        _supd = superseded_acceptances(_accs)
                        for tgt, appr, own, exp, rec, rvw, evi, sup, rat, kind in _accs:
                            if (tgt.lower(), rec) in _supd:
                                continue
                            if not (kind == "finding" and tgt.lower() == lr.group(1).lower()):
                                continue
                            # The row exists (this loop holds it) and the
                            # review predates the record (marker run day,
                            # stamp day when run-less); a prewritten
                            # waiver covers nothing.
                            _rm = RUN_ID_RE.search(s.plan_review_body or "")
                            _tday = run_day(_rm.group(1)) if _rm else (s.stamped_on or "")
                            if not _tday or _tday > rec:
                                continue
                            if not acceptance_live(rec, exp, today):
                                # An expired match names the escalation
                                # owner instead of covering.
                                if not esc_owner:
                                    esc_owner = own
                                continue
                            # Stale evidence voids (the findings file owns
                            # finding records). Reopen voids by
                            # construction, never reaching this loop; no
                            # check here.
                            if not evidence_fresh(evi, m.group(1), raw_text):
                                continue
                            ab, ae, ar, at, ao = appr, exp, rvw, rat, own
                            break
                        if sev == "major" and disp in ("accepted", "deferred"):
                            # Open majors age visibly (deferred majors
                            # count too, or triaging down a level hides
                            # them from the dimension that exists to
                            # watch them). Known wrong plan behavior must
                            # not sit invisible. Overdue is an old review
                            # OR a blown row due date (the accountability
                            # date must fire, not just sit printed);
                            # missing owner or due surfaces; the
                            # validator requires both on new rows, the
                            # query reports the gap everywhere.
                            since = s.stamped_on or ""
                            row_overdue = bool(not since or since < old_line) or bool(
                                due and due < today
                            )
                            if ab:
                                row_overdue = False
                            majors.append(
                                (
                                    m.group(1),
                                    lr.group(1),
                                    since or "undated",
                                    owner,
                                    due,
                                    row_overdue,
                                    (
                                        (
                                            f"{esc_owner}: renew the acceptance or remediate the finding"
                                            if esc_owner
                                            else "operator: remediate the finding or record risk acceptance"
                                        )
                                        if row_overdue
                                        else ""
                                    ),
                                    ab,
                                    ao,
                                    ae,
                                    ar,
                                    at,
                                )
                            )
                            continue
                        if sev != "critical":
                            continue
                        if disp in ("accepted", "deferred"):
                            crow_overdue = bool(due and due < today)
                            if ab:
                                crow_overdue = False
                            criticals.append(
                                (
                                    m.group(1),
                                    lr.group(1),
                                    owner,
                                    due,
                                    crow_overdue,
                                    (
                                        (
                                            f"{esc_owner}: renew the acceptance or remediate the finding"
                                            if esc_owner
                                            else "operator: remediate the finding or record risk acceptance"
                                        )
                                        if crow_overdue
                                        else ""
                                    ),
                                    ab,
                                    ao,
                                    ae,
                                    ar,
                                    at,
                                )
                            )
                        elif disp == "filed":
                            # A filed row clears only when every named
                            # target carries a post-finding verified
                            # remediation: resolved, stamped strictly after
                            # this review (a stamp predating the finding
                            # proves no remediation; day granularity fails
                            # closed), with the finding ID in the target's
                            # file (word-bounded so PR1 never matches
                            # inside PR10), and with a `fix <sha>` naming a
                            # non-merge commit that touched the target file
                            # and whose tree contains the ID (fix-commit
                            # attribution bound to the target's post-finding
                            # stamp). Ranges name `fix <base>..<tip>`
                            # instead: the tip tree carries the ID, the tip
                            # descends from the base, and a non-merge
                            # commit inside the range touched the file
                            # (base excluded, so name the pre-loop tip,
                            # never the first fix commit). Ordering reads
                            # Duration ends when both reviews carry them
                            # (same-day fixes order by completion
                            # instant); without both ends the day-stamp
                            # rule applies and same-day fails closed. The
                            # fix committer timestamp must postdate the
                            # review completion, with the same day
                            # fallback. And the target names `proof
                            # <finding-id> <path>[::<test>]` resolving at
                            # the fix tip tree. Stated boundary: bytes
                            # prove attribution plus a named proof
                            # pointer, not remediation: the semantic proof
                            # that the test exercises the finding's
                            # acceptance condition is the target's own
                            # review and stamp. A sha whose tree lacks the
                            # ID, that never touched the file, that git
                            # cannot prove, that predates the review, or
                            # whose proof names nothing resolving fails
                            # closed, as do unresolvable, unverified,
                            # pre-dated, unlinked, and unnamed targets.
                            # And the review's recorded candidate must be
                            # an ancestor of the fix (causal history, not
                            # wall clocks alone): records predating the
                            # provenance mandate carry no candidate and
                            # skip the leg.
                            refs = [xm.group(0) for xm in XREF_RE.finditer(rest)]
                            provable = bool(refs)
                            reviewer_day = s.stamped_on or "\uffff"  # undated reviewer fails closed
                            rend = s.duration_end
                            rts = (
                                int(
                                    datetime.strptime(rend, "%Y-%m-%dT%H:%M:%SZ")
                                    .replace(tzinfo=timezone.utc)
                                    .timestamp()
                                )
                                if rend is not None
                                else None
                            )
                            for ref in refs:
                                r = resolve_ref(ref, t, by_key)
                                if not r or r[0] not in by_id or r[1] not in by_id[r[0]].sections:
                                    provable = False
                                    break
                                tgt = by_id[r[0]].sections[r[1]]
                                if r[1] not in by_id[r[0]].verified_sections:
                                    provable = False
                                    break
                                if not review_ordered(
                                    tgt.duration_end,
                                    rend,
                                    tgt.stamped_on,
                                    reviewer_day,
                                ):
                                    provable = False
                                    break
                                tpath = by_id[r[0]].path
                                if tpath not in target_texts:
                                    try:
                                        target_texts[tpath] = (TODO_DIR.parent / tpath).read_text(
                                            encoding="utf-8"
                                        )
                                    except OSError:
                                        target_texts[tpath] = ""
                                if not re.search(
                                    r"\b" + re.escape(lr.group(1)) + r"\b",
                                    target_texts[tpath],
                                ):
                                    provable = False
                                    break
                                spans = sorted(starts.get(tpath, []))
                                tgt_start = tgt.line or 1
                                tgt_end = next(
                                    (ln for ln, _sn in spans if ln > tgt_start),
                                    len(target_texts[tpath].splitlines()) + 1,
                                )
                                tgt_text = "\n".join(
                                    target_texts[tpath].splitlines()[tgt_start - 1:tgt_end - 1]
                                )
                                fm = FIX_COMMIT_RE.search(tgt_text)
                                if fm is None:
                                    provable = False
                                    break
                                base, tip = fm.group(1), fm.group(2) or fm.group(1)
                                fixed = git_file_at(tip, tpath)
                                if fixed is None or not re.search(
                                    r"\b" + re.escape(lr.group(1)) + r"\b", fixed
                                ):
                                    provable = False
                                    break
                                if fm.group(2) is not None:
                                    if not git_is_ancestor(base, tip):
                                        provable = False
                                        break
                                    if not git_range_touches(base, tip, tpath):
                                        provable = False
                                        break
                                elif not git_commit_touches(tip, tpath):
                                    provable = False
                                    break
                                fix_ts = git_commit_ts(tip)
                                if not fix_postdates_review(fix_ts, rts, reviewer_day):
                                    provable = False
                                    break
                                proof_ok = False
                                for pm in PROOF_RE.finditer(tgt_text):
                                    if pm.group(1).lower() != lr.group(1).lower():
                                        continue
                                    ppath, _, pname = pm.group(2).partition("::")
                                    pbytes = git_file_at(tip, ppath)
                                    if pbytes is None:
                                        continue
                                    if pname and not re.search(
                                        r"\b" + re.escape(pname) + r"\b", pbytes
                                    ):
                                        continue
                                    proof_ok = True
                                    break
                                if not proof_ok:
                                    provable = False
                                    break
                                cands = []
                                for pln in text.splitlines():
                                    pcm = PROVENANCE_RE.match(pln)
                                    if pcm is not None:
                                        cands.append(pcm.group(1))
                                if cands and not any(
                                    git_is_ancestor(c, tip) for c in cands
                                ):
                                    provable = False
                                    break
                            if not provable:
                                crow_overdue = bool(due and due < today)
                                if ab:
                                    crow_overdue = False
                                criticals.append(
                                    (
                                        m.group(1),
                                        lr.group(1),
                                        owner,
                                        due,
                                        crow_overdue,
                                        (
                                            (
                                                f"{esc_owner}: renew the acceptance or remediate the finding"
                                                if esc_owner
                                                else "operator: remediate the finding or record risk acceptance"
                                            )
                                            if crow_overdue
                                            else ""
                                        ),
                                        ab,
                                        ao,
                                        ae,
                                        ar,
                                        at,
                                    )
                                )
        for path in sorted(unshaped):
            # Legacy records: a Plan review section without a Manifest or
            # without a Ledger block, in a file whose every reviewing
            # stamp predates enforcement. Post-cutoff shapeliness is the
            # validator's FATAL; only the grandfathered set lists here.
            own = owners.get(path, [])
            if own and all(not _owed(ot.sections[onum]) for ot, onum in own if onum in ot.sections):
                legacy.append(path)
        # Acceptance review states: live, un-superseded acceptances whose
        # review date is near (due: within 7 days before) or past
        # (overdue). History never lists (a superseded record's review
        # rode its successor), and lapsed records never list either
        # (expiry escalates on the covered dimension). Overdue clears
        # only through a superseding record whose rationale is the
        # review outcome.
        reviews = []
        due_line = (datetime.now(timezone.utc).date() + timedelta(days=7)).isoformat()
        for path in sorted(seen):
            _paccs = file_acceptances(path)
            _psupd = superseded_acceptances(_paccs)
            for tgt, _appr, own, exp, rec, rvw, _evi, _sup, _rat, _kind in _paccs:
                if (tgt.lower(), rec) in _psupd:
                    continue
                if not acceptance_live(rec, exp, today):
                    continue
                if rvw < rec or rvw > exp:
                    # A review date outside its own record-expiry
                    # window is validator-malformed and names no
                    # coherent obligation; the FATAL is the signal,
                    # not this list.
                    continue
                if rvw < today:
                    _rstate = "review-overdue"
                elif rvw <= due_line:
                    _rstate = "review-due"
                else:
                    continue
                reviews.append(
                    (
                        path,
                        tgt,
                        rvw,
                        _rstate,
                        own,
                        (
                            f"{own}: record the review outcome in a superseding acceptance"
                            if _rstate == "review-overdue"
                            else ""
                        ),
                    )
                )
        # Total sort keys: the tuple of every scalar field, so no two
        # entries tie and text and JSON share one order each.
        degraded_sorted = sorted(
            degraded,
            key=lambda d: (
                d["ref"],
                d["state"],
                d["owner"],
                d["due"],
                d["overdue"],
                d["escalation"],
                d["accepted_by"],
                d["accepted_owner"],
                d["accepted_expires"],
                d["accepted_review"],
                d["accepted_rationale"],
            ),
        )
        majors_sorted = sorted(
            majors, key=lambda m: (m[0], m[1], m[2], m[3], m[4], m[5], m[6], m[7], m[8], m[9], m[10], m[11])
        )
        criticals_sorted = sorted(
            criticals, key=lambda c: (c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10])
        )
        stale_sorted = sorted(stale, key=lambda e: (e[0], e[1]))
        uncovered_sorted = sorted(uncovered)
        unmarked_sorted = sorted(unmarked)
        grandfathered_sorted = sorted(grandfathered)
        fallback_sorted = sorted(fallback)
        outages_sorted = sorted(outages)
        legacy_sorted = sorted(legacy)
        unreadable_sorted = sorted(unreadable)
        reviews_sorted = sorted(reviews)
        report = {
            "schema": PLAN_HEALTH_SCHEMA,
            "reviewed": {
                "marked": len(marked),
                "unmarked": [{"ref": label, "stamped": day} for label, day in unmarked_sorted],
            },
            "uncovered": [
                {"dependent": dep, "waits_on": on} for dep, on in uncovered_sorted
            ],
            "degraded": degraded_sorted,
            "stale": [
                {"file": f, "run": run, "unreviewed": new, "removed": gone}
                for f, run, new, gone in stale_sorted
            ],
            "fallback": fallback_sorted,
            "outages": outages_sorted,
            "criticals": [
                {
                    "id": pr,
                    "file": f,
                    "owner": own,
                    "due": due,
                    "overdue": od,
                    "escalation": esc,
                    "accepted_by": ab,
                    "accepted_owner": ao,
                    "accepted_expires": ae,
                    "accepted_review": ar,
                    "accepted_rationale": at,
                }
                for f, pr, own, due, od, esc, ab, ao, ae, ar, at in criticals_sorted
            ],
            "majors": [
                {
                    "id": pr,
                    "file": f,
                    "since": day,
                    "overdue": od,
                    "owner": own,
                    "due": due,
                    "escalation": esc,
                    "accepted_by": ab,
                    "accepted_owner": ao,
                    "accepted_expires": ae,
                    "accepted_review": ar,
                    "accepted_rationale": at,
                }
                for f, pr, day, own, due, od, esc, ab, ao, ae, ar, at in majors_sorted
            ],
            "grandfathered": [
                {"ref": label, "stamped": day, "overdue": od}
                for label, day, od in grandfathered_sorted
            ],
            "legacy": legacy_sorted,
            "unreadable": [{"file": f, "opener": opener} for f, opener in unreadable_sorted],
            "reviews": [
                {"file": f, "target": tgt, "review": rvw, "state": st, "owner": own, "escalation": esc}
                for f, tgt, rvw, st, own, esc in reviews_sorted
            ],
        }
        # Gate mode: `--fail-on` names dimensions whose non-emptiness
        # fails the run; `--check` is the recommended set (everything
        # actionable except the informational, excused, and chronic
        # sets: fallback, outages, grandfathered, legacy, and stale,
        # which stays gateable explicitly but never passes by default
        # on a growing tree, so a gate that included it would never be
        # green).
        gate_dims = []
        check_mode = getattr(args, "check", False) or what == "summary"
        if check_mode:
            gate_dims += ["unmarked", "uncovered", "degraded", "criticals", "majors", "unreadable", "reviews"]
            # Deadline gate: past the migration deadline, leftover
            # grandfathered batches join `--check`. Explicit `--fail-on
            # grandfathered` gates progress on any date; the default
            # set stays green while time remains.
            if any(e["overdue"] for e in report["grandfathered"]):
                gate_dims += ["grandfathered"]
        if getattr(args, "fail_on", None):
            # Union, not elif: an explicit --fail-on beside --check adds
            # dimensions (a CI gate written `--check --fail-on stale` must
            # gate stale, not silently drop it). Order-stable dedup keeps
            # the verdict line clean.
            gate_dims += [d.strip() for d in args.fail_on.split(",") if d.strip()]
        gate_dims = list(dict.fromkeys(gate_dims))
        dim_lists = {
            "unmarked": report["reviewed"]["unmarked"],
            "uncovered": report["uncovered"],
            "degraded": report["degraded"],
            "stale": report["stale"],
            "fallback": report["fallback"],
            "outages": report["outages"],
            "criticals": report["criticals"],
            "majors": report["majors"],
            "grandfathered": report["grandfathered"],
            "legacy": report["legacy"],
            "unreadable": report["unreadable"],
            "reviews": report["reviews"],
        }
        unknown = [d for d in gate_dims if d not in dim_lists]
        if unknown:
            print(f"plan-health: unknown dimension(s): {', '.join(unknown)}", file=sys.stderr)
            return 2
        # Explicit dims gate strict (non-emptiness); check-set dims gate
        # lenient (actionables only). Union dims go strict: an explicit
        # flag beside --check means zero tolerance for that dimension.
        explicit = (
            {d.strip() for d in args.fail_on.split(",") if d.strip()}
            if getattr(args, "fail_on", None)
            else set()
        )
        failing = [d for d in gate_dims if dim_failing(d, dim_lists[d], strict=(d in explicit))]
        if getattr(args, "json", False):
            print(json.dumps(report, indent=2))
            return 1 if failing else 0
        if what == "summary":
            # Operator digest: incomplete runs are owed states without
            # a live acceptance (bare partials are complete, covered
            # escalations terminated); blocked clearances are uncovered
            # criticals; overdue owners group every overdue escalation;
            # next names the first uncovered entry of the first failing
            # dimension in gate order.
            incomplete = [
                d
                for d in degraded_sorted
                if ("outage" in d["state"] or "retry-owed" in d["state"])
                and not d["accepted_by"]
            ]
            blocked = [c for c in criticals_sorted if not c[6]]
            od_by_owner: dict[str, list[str]] = {}
            for d in degraded_sorted:
                if d["overdue"]:
                    od_by_owner.setdefault(d["owner"] or "?", []).append(d["due"])
            for _f, _pr, own, due, od, _esc, _ab, _ao, _ae, _ar, _at in criticals_sorted:
                if od:
                    od_by_owner.setdefault(own or "?", []).append(due)
            for _f, _pr, _day, own, due, od, _esc, _ab, _ao, _ae, _ar, _at in majors_sorted:
                if od:
                    od_by_owner.setdefault(own or "?", []).append(due)
            print(f"incomplete runs     {len(incomplete)}")
            for d in incomplete:
                print(
                    f"    {d['ref']}  {d['state']}  owner {d['owner'] or '?'}  due {d['due'] or '?'}"
                    + ("  OVERDUE" if d["overdue"] else "")
                )
            print(f"blocked clearances  {len(blocked)}")
            for f, pr, own, due, od, _esc, _ab, _ao, _ae, _ar, _at in blocked:
                print(
                    f"    {pr}  in {f}  owner {own or '?'}  due {due or '?'}"
                    + ("  OVERDUE" if od else "")
                )
            print(f"overdue owners      {len(od_by_owner)}")
            for own in sorted(od_by_owner):
                dues = sorted(x for x in od_by_owner[own] if x)
                oldest = f" (oldest due {dues[0]})" if dues else ""
                print(f"    {own}: {len(od_by_owner[own])} overdue{oldest}")
            nxt = "nothing actionable"
            if failing:
                dim = failing[0]
                pool = dim_lists[dim]
                if dim == "degraded":
                    pool = [
                        e
                        for e in pool
                        if ("outage" in e["state"] or "retry-owed" in e["state"])
                        and not e.get("accepted_by")
                    ]
                elif dim in ("criticals", "majors"):
                    pool = [e for e in pool if not e.get("accepted_by")]
                # Strict dims fail on presence, so an empty actionable
                # pool falls back to the first entry as named.
                first = pool[0] if pool else dim_lists[dim][0]
                if dim == "degraded":
                    nxt = f"{first['ref']} {first['state']} (owner {first['owner'] or '?'}, due {first['due'] or '?'})"
                elif dim in ("criticals", "majors"):
                    nxt = f"{first['id']} in {first['file']} (owner {first['owner'] or '?'}, due {first['due'] or '?'})"
                elif dim == "reviews":
                    nxt = f"{first['target']} in {first['file']} ({first['state']}, owner {first['owner'] or '?'})"
                elif dim == "uncovered":
                    nxt = f"{first['dependent']} waits on {first['waits_on']}"
                elif dim == "unreadable":
                    nxt = f"{first['file']} (fence opened at line {first['opener']})"
                elif dim == "stale":
                    nxt = f"{first['file']} ({len(first['unreviewed'])} unreviewed, {len(first['removed'])} removed)"
                elif isinstance(first, str):
                    nxt = f"{first} ({dim})"
                else:
                    nxt = first.get("ref", dim)
            print(f"next: {nxt}")
            print(f"gate: {'FAIL (' + ', '.join(failing) + ')' if failing else 'ok'}")
            return 1 if failing else 0
        print(f"reviewed sections   {len(marked)} marked, {len(unmarked_sorted)} unmarked post-cutoff")
        for label, day in unmarked_sorted:
            print(f"    {label}  stamped {day}")
        print(f"uncovered dependents  {len(uncovered_sorted)}")
        for dep, on in uncovered_sorted:
            print(f"    {dep}  waits on marked {on}")
        print(f"degraded reviews    {len(degraded_sorted)} degraded markers")
        for d in degraded_sorted:
            tags = f"owner {d['owner'] or '?'}  due {d['due'] or '?'}"
            if d["overdue"]:
                tags += f"  OVERDUE  escalate {d['escalation'].split(':', 1)[0] if d['escalation'] else 'operator'}"
            if d["accepted_by"]:
                tags += (
                    f"  accepted by {d['accepted_by']} owner {d['accepted_owner']}"
                    f" expires {d['accepted_expires']}"
                    f" review {d['accepted_review']} rationale {d['accepted_rationale']}"
                )
            # UNACCOUNTABLE pairs with the owed predicate at collection:
            # a bare partial carries no fields because none are owed.
            if (not d["owner"] or not d["due"]) and (
                "outage" in d["state"] or "retry-owed" in d["state"]
            ):
                tags += "  UNACCOUNTABLE"
            print(f"    {d['ref']}  {d['state']}  {tags}")
        print(f"stale scope         {len(stale_sorted)} reviews whose scope changed since")
        for f, run, new, gone in stale_sorted:
            bits = []
            if run:
                bits.append(f"run {run}")
            if new:
                bits.append(f"unreviewed: {', '.join(new)}")
            if gone:
                bits.append(f"removed: {', '.join(gone)}")
            print(f"    {f}  {'; '.join(bits)}")
        print(f"fallback usage      {len(fallback_sorted)} findings whose governing panel ran on the fallback family")
        for f in fallback_sorted:
            print(f"    {f}")
        print(f"outages             {len(outages_sorted)} findings with an outage note for their era")
        for f in outages_sorted:
            print(f"    {f}")
        print(f"unresolved critical {len(criticals_sorted)}")
        for f, pr, own, due, od, esc, ab, ao, ae, ar, at in criticals_sorted:
            acct = f"owner {own or '?'}  due {due or '?'}"
            if od:
                acct += f"  OVERDUE  escalate {esc.split(':', 1)[0] if esc else 'operator'}"
            if ab:
                acct += f"  accepted by {ab} owner {ao} expires {ae} review {ar} rationale {at}"
            if not own or not due:
                acct += "  UNACCOUNTABLE"
            print(f"    {pr}  in {f}  {acct}")
        print(
            f"open majors         {len(majors_sorted)} "
            f"({sum(1 for m in majors_sorted if m[5])} overdue)"
        )
        for f, pr, day, own, due, od, esc, ab, ao, ae, ar, at in majors_sorted:
            acct = f"owner {own or '?'}  due {due or '?'}"
            if od:
                acct += f"  OVERDUE  escalate {esc.split(':', 1)[0] if esc else 'operator'}"
            if ab:
                acct += f"  accepted by {ab} owner {ao} expires {ae} review {ar} rationale {at}"
            if not own or not due:
                acct += "  UNACCOUNTABLE"
            print(f"    {pr}  in {f}  since {day}  {acct}")
        print(
            f"grandfathered stamps {len(grandfathered_sorted)} (pre-cutoff, excused, unmarked; migrate by {MIGRATION_DEADLINE})"
        )
        batch_left: dict[str, int] = {}
        for label, _day, _od in grandfathered_sorted:
            bf = label.rsplit(" §", 1)[0]
            batch_left[bf] = batch_left.get(bf, 0) + 1
        for bf in sorted(batch_left):
            print(f"    batch {bf}  {batch_left[bf]} left")
        for label, day, od in grandfathered_sorted:
            print(f"    {label}  stamped {day}" + ("  OVERDUE" if od else ""))
        print(f"legacy records      {len(legacy_sorted)} (grandfathered, Plan review without Manifest or Ledger block)")
        for f in legacy_sorted:
            print(f"    {f}")
        print(f"unreadable findings {len(unreadable_sorted)} (unbalanced fence; scans truncated)")
        for f, opener in unreadable_sorted:
            print(f"    {f}  fence opened at line {opener}")
        print(f"acceptance reviews  {len(reviews_sorted)} acceptances due or overdue for review")
        for f, tgt, rvw, st, own, _esc in reviews_sorted:
            print(f"    {tgt}  in {f}  review {rvw}  {st}  owner {own or '?'}")
        if gate_dims:
            print(f"gate: {'FAIL (' + ', '.join(failing) + ')' if failing else 'ok'}")
            return 1 if failing else 0
        return 0

    rows = []
    for t in todos:
        for num, s in sorted(t.sections.items()):
            if s.status == "x" or s.moved:
                continue
            # The one dependency gate (D00 T01 §37); no local edge-walking.
            missing = [
                u["query_label"]
                for u in unmet_dependencies(t, num, todos, by_key, by_id=by_id)
            ]
            rows.append((t, num, s, missing))

    if what == "ready":
        explicit = getattr(args, "context", None)
        ctx = set(explicit) if explicit is not None else detect_context()
        ctx_note = ", ".join(sorted(ctx)) if ctx else "none"
        ready = [r for r in rows if not r[3]]
        ranked = sorted(ready, key=lambda r: (r[0].domain, r[0].number, r[2].order or 0))
        now = []
        elsewhere = []
        for r in ranked:
            s = r[2]
            # Unknown values never clear: `validate` refuses the mark, and no
            # declared context can name them (`--context` choices are closed).
            missing = [v for v in s.requires if v not in ctx]
            missing += [f"unknown:{v}" for v in s.requires_unknown]
            if s.requires_has_line and not s.requires and not s.requires_unknown:
                missing.append("no values (see validate)")
            (elsewhere if missing else now).append((r, missing))
        for (t, num, s, _), _missing in now:
            flag = " 🔒" if t.frozen else ""
            print(f"{t.domain}/{Path(t.path).name} §{num}{flag}  {s.deliverable}")
        if elsewhere:
            print(f"\nrunnable elsewhere (context: {ctx_note}):")
            for (t, num, s, _), missing in elsewhere:
                flag = " 🔒" if t.frozen else ""
                reqs = ", ".join(s.requires + [f"unknown:{v}" for v in s.requires_unknown]) or s.requires_raw
                print(f"{t.domain}/{Path(t.path).name} §{num}{flag}  {s.deliverable}  requires {reqs} (missing: {', '.join(missing)})")
        print(f"\n{len(now)} runnable now, {len(elsewhere)} runnable elsewhere")
    else:  # blocked
        blocked = [r for r in rows if r[3]]
        for t, num, s, missing in sorted(blocked, key=lambda r: (r[0].domain, r[0].number, r[1])):
            print(f"{t.domain}/{Path(t.path).name} §{num}  {s.deliverable}")
            print(f"    waiting on: {', '.join(missing)}")
        print(f"\n{len(blocked)} section(s) blocked")
    return 0


# -------------------------------------------------------------------- render


def cmd_render(_args) -> int:
    todos = load_todos()
    by_key = {(t.domain, t.number): t for t in todos}
    print("# TODO dependency graph\n")
    print("```mermaid")
    print("flowchart LR")
    for domain in sorted({t.domain for t in todos}):
        print(f'  subgraph {domain.replace("-", "_")}["{domain}"]')
        for t in [x for x in todos if x.domain == domain]:
            for num, s in sorted(t.sections.items()):
                mark = {"x": "✓", "/": "~"}.get(s.status, "")
                label = s.deliverable[:44].replace('"', "'")
                print(f'    {_nid(t, num)}["{mark}§{num} {label}"]')
        print("  end")
    for t in todos:
        for num, s in sorted(t.sections.items()):
            for raw in s.depends_on:
                r = resolve_ref(raw, t, by_key)
                if not r:
                    continue
                src = next((x for x in todos if x.id == r[0]), None)
                if src and r[1] in src.sections:
                    print(f"  {_nid(src, r[1])} --> {_nid(t, num)}")
        for dep in t.depends_on:
            src = next((x for x in todos if x.id == dep), None)
            if src and src.sections and t.sections:
                print(f"  {_nid(src, max(src.sections))} -.-> {_nid(t, min(t.sections))}")
    print("```")
    return 0


def _nid(t: Todo, sec: int) -> str:
    return re.sub(r"[^A-Za-z0-9]", "_", f"{t.domain}_{t.number}_{sec}")


# --------------------------------------------------------------- resolve


def resolve_exit_code(raw: str, todos: list[Todo]) -> int:
    """Same exit codes as `cmd_resolve`, without printing. Used by `classify` and the operator snapshot so a phase of 76 open rows does not spawn 76 graph loads."""
    by_prefix = {(t.domain.split("-")[0], t.number): t for t in todos}
    by_key = {(t.domain, t.number): t for t in todos}
    raw = raw.strip()
    if not raw:
        return 2
    m = re.search(r"D(?P<dom>\d{2})\s+T(?P<todo>\d{2})\s+§(?P<sec>\d+)", raw)
    if m:
        target = by_prefix.get((m.group("dom"), m.group("todo")))
        sec = int(m.group("sec"))
        if target is None:
            return 1
    else:
        m2 = re.search(r"§(?P<sec>\d+)", raw)
        if not m2:
            return 2
        sec = int(m2.group("sec"))
        frag = raw[: m2.start()].strip().strip("`|").strip()
        hits = [t for t in todos if frag and frag in t.path]
        if len(hits) != 1:
            return 1
        target = hits[0]
    if sec not in target.sections:
        return 1
    s = target.sections[sec]
    if s.status == "x":
        return 3
    if s.moved:
        return 5
    # The one dependency gate (D00 T01 §37): row edges AND frontmatter
    # whole-TODO edges, identical to `query blocked`. Before this, only the
    # row edges were walked here, so a section could be blocked in `query`
    # and exit 0 from `resolve`/`classify`/the operator snapshot.
    return 4 if unmet_dependencies(target, sec, todos, by_key) else 0


def needs_for_ref(raw: str, todos: list[Todo]) -> list[str]:
    """The closed-list `needs` keys of one section; [] for no marker or an unknown ref; `["unknown:<value>"]` for a marker outside the closed list.

    Same reference forms as `resolve`. `plan-gate.py next` asks this for every
    ready row in one graph load, so a phase of 70 rows costs one subprocess,
    and it holds a row carrying the unknown sentinel as repairable work.
    """
    by_prefix = {(t.domain.split("-")[0], t.number): t for t in todos}
    m = re.search(r"D(?P<dom>\d{2})\s+T(?P<todo>\d{2})\s+§(?P<sec>\d+)", raw.strip())
    if m:
        target = by_prefix.get((m.group("dom"), m.group("todo")))
        sec = int(m.group("sec"))
    else:
        m2 = re.search(r"§(?P<sec>\d+)", raw)
        if not m2:
            return []
        sec = int(m2.group("sec"))
        frag = raw[: m2.start()].strip().strip("`|").strip()
        hits = [t for t in todos if frag and frag in t.path]
        target = hits[0] if len(hits) == 1 else None
    if target is None or sec not in target.sections:
        return []
    section = target.sections[sec]
    if section.needs_raw and not section.needs:
        # Never read as host-free: `validate` refuses the value, and `plan-gate.py
        # next` refuses to run the row (round-1 Grok consistency + record).
        return [f"unknown:{section.needs_raw}"]
    return list(section.needs)


def requires_missing_for_ref(raw: str, todos: list[Todo]) -> list[str]:
    """Closed-list `requires` values unmet by the local context; [] for no marker, an unknown ref, or everything met.

    Same reference forms as `resolve`. The operator snapshot holds a row
    with unmet requirements out of `first_ready`, the way `query ready`
    holds it out of runnable-now.
    """
    by_prefix = {(t.domain.split("-")[0], t.number): t for t in todos}
    m = re.search(r"D(?P<dom>\d{2})\s+T(?P<todo>\d{2})\s+§(?P<sec>\d+)", raw.strip())
    if m:
        target = by_prefix.get((m.group("dom"), m.group("todo")))
        sec = int(m.group("sec"))
    else:
        m2 = re.search(r"§(?P<sec>\d+)", raw)
        if not m2:
            return []
        sec = int(m2.group("sec"))
        frag = raw[: m2.start()].strip().strip("`|").strip()
        hits = [t for t in todos if frag and frag in t.path]
        target = hits[0] if len(hits) == 1 else None
    if target is None or sec not in target.sections:
        return []
    section = target.sections[sec]
    if section.requires_unknown or (section.requires_has_line and not section.requires):
        # Never read as runnable: `validate` refuses the value.
        return [f"unknown:{v}" for v in section.requires_unknown] or ["unknown:no-values"]
    have = detect_context()
    return [v for v in section.requires if v not in have]


def cmd_needs(args: argparse.Namespace) -> int:
    """The `**Needs:**` keys of many refs in one graph load. JSON {ref: [keys]}."""
    refs = [r.strip() for r in args.refs if str(r).strip()]
    todos = load_todos()
    print(json.dumps({ref: needs_for_ref(ref, todos) for ref in refs}, indent=2, sort_keys=True))
    return 0


def cmd_classify(args: argparse.Namespace) -> int:
    """Resolve many refs against one graph load. JSON object of ref -> exit code."""
    refs = [r.strip() for r in args.refs if str(r).strip()]
    todos = load_todos()
    payload = {ref: resolve_exit_code(ref, todos) for ref in refs}
    print(json.dumps(payload, indent=2, sort_keys=True))
    return 0


def cmd_resolve(args: argparse.Namespace) -> int:
    """Turn any reference to a section into the file and number that name it.

    The point is that a person should be able to paste whatever they are
    already looking at -- a row out of the implementation plan, a line from
    `query ready`, a bare `D05 T02 §3` -- and get the file path back, instead
    of translating a domain number into a filename by hand every time.

        todo-graph.py resolve 'D00 T01 §11'
        todo-graph.py resolve '| [ ] | `D00 T01 §11` | Test gates ... | 12 |'
        todo-graph.py resolve '00-workspace/TODO-01-repo-and-delivery-pipeline.md §11'

    Output is the skill's input: path, section, status, and whether the
    dependencies are actually met -- which is the question the caller would
    otherwise have to ask separately and usually forgets to.
    """
    raw = " ".join(args.ref).strip()
    if not raw:
        print("nothing to resolve", file=sys.stderr)
        return 2

    todos = load_todos()

    # Two dicts, deliberately, because two different callers key differently
    # and collapsing them cost this command its entire cross-domain gate.
    #
    # `by_prefix` is what the argument regex below needs: a caller types
    # "D01 T01 §7" and holds the two-digit prefix. `by_key` is what
    # resolve_ref() needs -- it widens "01" to "01-foundation" itself and then
    # looks the pair up, which is also how cmd_validate builds its dict.
    #
    # Until 2026-08-13 this command built ONLY the prefix-keyed dict and
    # handed it to resolve_ref, so every cross-TODO lookup missed and returned
    # None, and the `if not r: continue` below swallowed it. Same-file deps
    # ("§6") never touched the dict at all, so UNMET listed those and nothing
    # else -- a dependency gate that silently ignored exactly the edges that
    # cross a domain boundary, which are the ones a reader cannot hold in their
    # head. `resolve` exits 4 on unmet deps and process-todo-section reads
    # that exit code, so a section could be claimed with its cross-domain
    # dependencies unshipped.
    by_prefix = {(t.domain.split("-")[0], t.number): t for t in todos}
    by_key = {(t.domain, t.number): t for t in todos}

    # A pasted plan row carries the reference in backticks; a bare reference
    # does not. Both reduce to the same regex, applied to the whole string.
    m = re.search(r"D(?P<dom>\d{2})\s+T(?P<todo>\d{2})\s+§(?P<sec>\d+)", raw)
    if m:
        target = by_prefix.get((m.group("dom"), m.group("todo")))
        sec = int(m.group("sec"))
        if target is None:
            print(f"no TODO for domain {m.group('dom')} number {m.group('todo')}", file=sys.stderr)
            return 1
    else:
        # "<path or fragment> §N" -- match the path fragment against known files.
        m2 = re.search(r"§(?P<sec>\d+)", raw)
        if not m2:
            print(f"no section reference found in: {raw[:80]}", file=sys.stderr)
            return 2
        sec = int(m2.group("sec"))
        frag = raw[: m2.start()].strip().strip("`|").strip()
        hits = [t for t in todos if frag and frag in t.path]
        if len(hits) != 1:
            print(
                f"{'no' if not hits else len(hits)} TODO file(s) match {frag!r} -- "
                "give a DNN TNN §N reference or a unique path fragment",
                file=sys.stderr,
            )
            return 1
        target = hits[0]

    if sec not in target.sections:
        print(f"{target.path} has no §{sec}", file=sys.stderr)
        return 1

    s = target.sections[sec]
    dom = target.domain.split("-")[0]

    # Dependency state, resolved rather than restated. A caller who is about to
    # implement wants to know this now, not after reading the file. The one
    # dependency gate (D00 T01 §37): identical records to query/classify.
    unmet = [u["dnn"] for u in unmet_dependencies(target, sec, todos, by_key)]

    print(f"path       {target.path}")
    print(f"section    §{sec} -- {s.title}")
    print(f"ref        D{dom} T{target.number} §{sec}")
    print(f"status     [{s.status}]  ({s.items_done}/{s.items_total} items)")
    print(f"frozen     {'yes -- section needs a Freeze check' if target.frozen else 'no'}")
    print(f"deps       {', '.join(s.depends_on) if s.depends_on else '--'}")
    if s.moved:
        print(f"moved      {s.moved}")
    if s.needs_raw:
        keys = ', '.join(s.needs) if s.needs else 'UNKNOWN -- not in the closed list'
        print(f"needs      {keys} ({s.needs_raw}); confirm the host or device is available before writing Started:")
    if s.requires_has_line:
        if s.requires_unknown or not s.requires:
            bad = f"unknown value(s): {', '.join(s.requires_unknown)}" if s.requires_unknown else "no values"
            print(f"requires   {s.requires_raw}; INVALID -- {bad} (see validate)")
        else:
            have = detect_context()
            missing = [v for v in s.requires if v not in have]
            verdict = "runnable here" if not missing else f"missing here: {', '.join(missing)}"
            print(f"requires   {s.requires_raw}; {verdict}")
    if unmet:
        print(f"UNMET      {', '.join(unmet)}")
    print()
    print(f"skill arg  {target.path.split('todo/', 1)[-1]} §{sec}")

    if s.moved:
        print(
            f"\nNOTE: §{sec} is worked outside the tree: {moved_target(s.moved) or s.moved}. "
            "Not a process-todo-section target; its row never flips here.",
            file=sys.stderr,
        )
        return 5
    if s.status == "x":
        print(
            f"\nNOTE: §{sec} is already [x]. Re-checking shipped work is "
            "review-todo-section in AUDIT stance, not process-todo-section.",
            file=sys.stderr,
        )
        return 3
    if unmet:
        print(
            f"\nNOTE: {len(unmet)} unmet dependency -- process-todo-section stops at "
            "its dependency gate unless these are shipped first.",
            file=sys.stderr,
        )
        return 4
    return 0


# ------------------------------------------------------------------ plan


PLAN = REPO / "todo" / "implementation-plan.md"

# "| [ ] | `D05 T02 §3` | WaybillService and BuyoutMarginService | 8 |"
PLAN_ROW_RE = re.compile(
    r"^\|\s*\[(?P<box>[ x/])\]\s*\|\s*`(?P<ref>D\d{2}\s+T\d{2}\s+§\d+)`\s*\|"
)
# The one line a moved section leaves in the plan (writers-and-reviewers §2):
# `> **Moved:** `D00 T07 §25` -- <the section's own Moved: body>`. Written
# by --sync where the row was, kept in place on later syncs, dropped when
# the marker goes. Not a row: totals, progress and plan-gate never see it.
PLAN_MOVED_RE = re.compile(r"^>\s*\*\*Moved:\*\*\s*`(?P<ref>D\d{2}\s+T\d{2}\s+§\d+)`")
# The Items cell: the trailing numeric column of a plan row. Synced like the box
# character, in place, so the table's alignment survives. Until 2026-09-17 nothing
# wrote this column and nothing checked it, so 28 of 121 rows disagreed with their
# section while `plan --check` reported the plan current (D00 T04 §1).
PLAN_ITEMS_RE = re.compile(r"\|(?P<cell>\s*(?P<items>\d+)\s*)\|\s*$")


def _rel(path: Path) -> str:
    """Repo-relative for messages; the absolute path when outside the repo (self-test fixtures)."""
    try:
        return path.relative_to(REPO).as_posix()
    except ValueError:
        return path.as_posix()


def _moved_line(ref: str, body: str) -> str:
    return f"> **Moved:** `{ref}` -- {body}"


PLAN_PROGRESS_RE = re.compile(
    r"^(?P<prefix>>\s+\*\*Progress:\*\*\s+).*$", re.M
)
# One dash is enough: `:-:` is the shortest legal centred separator and is what
# most of this repo's tables are written with. Requiring two silently skipped
# every centred table, which is most of the phase tables.
SEP_CELL_RE = re.compile(r"^:?-+:?$")


def _width(s: str) -> int:
    """Display width, counting wide glyphs as two columns.

    The prerequisite tables carry 🔴 🟠 ✅ ❌ and the phase tables carry ✔, and
    a naive len() pads those columns one short each -- which looks exactly like
    a misalignment bug in the aligner rather than a property of the font.
    """
    import unicodedata

    return sum(2 if unicodedata.east_asian_width(c) in ("W", "F") else 1 for c in s)


def _split_row(line: str) -> list[str] | None:
    """Split a markdown table row into cells, respecting `inline code`.

    A pipe inside a code span is content, not a delimiter. Nothing in the plan
    relies on that today, but a deliverable named `a|b` would otherwise be
    silently torn into two columns and the row would stop matching its header.
    """
    s = line.strip()
    if not (s.startswith("|") and s.endswith("|")) or len(s) < 2:
        return None
    cells, buf, tick = [], [], False
    i = 1
    body = s[1:-1]
    while i - 1 < len(body):
        c = body[i - 1]
        if c == "`":
            tick = not tick
            buf.append(c)
        elif c == "\\" and i < len(body):
            buf.append(c)
            buf.append(body[i])
            i += 1
        elif c == "|" and not tick:
            cells.append("".join(buf).strip())
            buf = []
        else:
            buf.append(c)
        i += 1
    cells.append("".join(buf).strip())
    return cells


def _align_tables(text: str) -> str:
    """Pad every markdown table's columns to a common width.

    Purely cosmetic, and deliberately not something `--check` fails on: a build
    that goes red over whitespace teaches people to stop reading it. `--sync`
    fixes it, which is enough.
    """
    lines = text.split("\n")
    out: list[str] = []
    i = 0
    while i < len(lines):
        if not lines[i].strip().startswith("|"):
            out.append(lines[i])
            i += 1
            continue

        block, j = [], i
        while j < len(lines) and lines[j].strip().startswith("|"):
            block.append(lines[j])
            j += 1

        rows = [_split_row(b) for b in block]
        # A table needs a header, a separator, and consistent arity. Anything
        # else is left exactly as it was rather than guessed at.
        sep_at = next(
            (
                k
                for k, r in enumerate(rows)
                if r and r and all(SEP_CELL_RE.match(c) for c in r)
            ),
            None,
        )
        if sep_at is None or any(r is None for r in rows):
            out.extend(block)
            i = j
            continue
        ncol = len(rows[sep_at])
        if any(len(r) != ncol for r in rows):
            out.extend(block)
            i = j
            continue

        align = []
        for c in rows[sep_at]:
            align.append("center" if c.startswith(":") and c.endswith(":")
                         else "right" if c.endswith(":") else "left")
        widths = [
            max(_width(r[k]) for n, r in enumerate(rows) if n != sep_at) for k in range(ncol)
        ]
        widths = [max(w, 3) for w in widths]

        for n, r in enumerate(rows):
            if n == sep_at:
                cells = []
                for k in range(ncol):
                    w = widths[k]
                    if align[k] == "center":
                        cells.append(":" + "-" * (w - 2) + ":")
                    elif align[k] == "right":
                        cells.append("-" * (w - 1) + ":")
                    else:
                        cells.append("-" * w)
                out.append("| " + " | ".join(cells) + " |")
                continue
            cells = []
            for k in range(ncol):
                pad = widths[k] - _width(r[k])
                if align[k] == "center":
                    left = pad // 2
                    cells.append(" " * left + r[k] + " " * (pad - left))
                elif align[k] == "right":
                    cells.append(" " * pad + r[k])
                else:
                    cells.append(r[k] + " " * pad)
            out.append("| " + " | ".join(cells) + " |")
        i = j
    return "\n".join(out)


# Calibration (D00 T04 §3). A correlation below this many paired observations is
# noise with a number attached, and the most dangerous thing this can produce is
# a figure that looks like evidence. Thirty is a judgement, not a derivation:
# below roughly that, one outlier moves a coefficient more than the underlying
# relationship does, and this plan already has one, `D00 T03 §1`, which cost nine
# commits because it was blocked on an operator decision mid-flight.
CALIBRATION_MIN_SAMPLE = 30



def _pearson(xs: list[float], ys: list[float]) -> float | None:
    """Correlation, or None when it cannot be computed. Pure, so it is testable."""
    n = len(xs)
    if n < 2 or n != len(ys):
        return None
    mx, my = sum(xs) / n, sum(ys) / n
    cov = sum((a - mx) * (b - my) for a, b in zip(xs, ys))
    vx = sum((a - mx) ** 2 for a in xs) ** 0.5
    vy = sum((b - my) ** 2 for b in ys) ** 0.5
    if not vx or not vy:
        return None
    return cov / (vx * vy)


def _calibration_reports_correlation(sample: int) -> bool:
    """Whether the sample is large enough to quote a correlation at all."""
    return sample >= CALIBRATION_MIN_SAMPLE


class GitUnavailable(Exception):
    """Git could not answer. NOT the same as an answer of zero."""


@functools.lru_cache(maxsize=1)
def _all_commit_subjects() -> tuple[str, ...]:
    """Every commit subject in the repository, oldest last, fetched once.

    Cached because `_owned_commits` is called once per stamped section, and the
    first version re-ran the whole log each time: 380 subjects re-fetched six
    times today and a hundred and twenty times when the plan is finished, with
    the history growing underneath it. Same shape as the performance finding in
    `D00 T04 §1`, caught the same way, by measuring rather than reading.
    """
    try:
        out = subprocess.run(
            ["git", "log", "--format=%s", "--all"],
            cwd=REPO, capture_output=True, text=True, timeout=30,
            # Git emits UTF-8. Without this, Python decodes with the locale
            # codec, which on Windows is cp1252, and every section marker comes
            # back as `Â§` instead of `§`: every subject fails to match and the
            # report shows a confident zero for every section. The first repr of
            # the output looked correct because the terminal re-encoded it.
            encoding="utf-8", errors="replace",
        )
    except (OSError, subprocess.SubprocessError) as exc:
        raise GitUnavailable(f"git log could not run: {exc}") from exc
    if out.returncode != 0:
        # A non-zero exit was previously ignored, so a broken repository or a
        # detached worktree produced a confident zero and fed it to the report
        # as an observation of a costless section.
        raise GitUnavailable(f"git log exited {out.returncode}: {out.stderr.strip()[:120]}")
    return tuple(out.stdout.splitlines())


def _owned_commits(ref: str) -> list[str]:
    """Subjects of the commits this section OWNS, oldest first.

    Ownership is the repository's commit convention: the subject line ends with
    the section reference in parentheses, `... (D00 T03 §2)`.

    It was `git log --grep=<ref>` until 2026-09-17, which matched the reference
    anywhere in the message, including the body. The commit that introduced this
    very report tabulated all six stamped sections in its body and so counted as
    a commit of every one of them: each row rose by one and the outlier
    disappeared. A measurement that its own documentation changes is not a
    measurement. Found by the independent review of 6fb88f3.
    """
    marker = f"({ref})"
    subjects = [l for l in _all_commit_subjects() if l.rstrip().endswith(marker)]
    subjects.reverse()   # oldest first
    return subjects


def _needed_rework(subjects: list[str]) -> bool | None:
    """Did this section need a commit after its ship, before the stamp?

    The convention is one ship commit, then a `review:` stamp. Anything owned by
    the section between them is rework the independent review or self-review
    caused, which is exactly what the checklist asks to be recorded and what a
    raw commit count cannot distinguish from ordinary implementation.
    """
    stamp = next((i for i, s in enumerate(subjects) if s.startswith("review:")), None)
    if stamp is None:
        return None       # not stamped through the usual path; say so, do not guess
    return stamp > 1



def _calibration_rows(todos: list[Todo]) -> list[dict]:
    """One row per STAMPED section: its estimate, and what it actually cost."""
    rows = []
    for t in todos:
        dom = t.domain.split("-")[0]
        for num, sec in sorted(t.sections.items()):
            if sec.status != "x" or sec.moved:
                continue
            ref = f"D{dom} T{t.number} \u00a7{num}"
            subjects = _owned_commits(ref)
            rows.append({
                "ref": ref,
                "items": sec.items_total,
                "commits": len(subjects),
                # Already parsed from the stamp by the loader; re-parsing the
                # body here would be a second reader of one fact.
                "minutes": sec.duration_minutes,
                "rework": _needed_rework(subjects),
            })
    return rows


def _section_edges(todos: list[Todo]) -> tuple[dict[str, list[str]], dict[str, str]]:
    """ref -> the refs it depends on, plus ref -> its title.

    Two kinds of edge, and the first version carried only one:

    * **Section edges**, the `Depends On` column. A reference may be written
      `§N`, `TNN §N` or `DNN TNN §N`, all three of which `AGENTS.md`
      documents, so they are resolved through `resolve_ref` rather than by
      pattern-matching the two forms somebody happened to think of.
    * **Whole-TODO edges**, the frontmatter `depends_on`. Fifteen are declared
      today, and ignoring them made the reported chain 17 sections deep when it
      is 30, with a different endpoint: the report named the wrong path as the
      one where delay costs most, which is its entire purpose. A whole-TODO edge
      means every section of the dependency must ship, which is how
      `unmet_dependencies` already reads it.

    Found by the independent review of 390b560.
    """
    by_id = {t.id: t for t in todos if t.id}
    by_key = {(t.domain, t.number): t for t in todos}

    def canon(todo: Todo, num: int) -> str:
        return f"D{todo.domain.split('-')[0]} T{todo.number} §{num}"

    edges: dict[str, list[str]] = {}
    titles: dict[str, str] = {}
    for t in todos:
        # Every section of every whole-TODO prerequisite, computed once per file.
        file_deps: list[str] = []
        for dep_id in t.depends_on:
            dep = by_id.get(dep_id)
            if dep is None:
                continue
            file_deps.extend(canon(dep, n) for n in dep.sections)

        for num, sec in t.sections.items():
            ref = canon(t, num)
            titles[ref] = sec.title or sec.deliverable or ""
            deps: list[str] = []
            for raw in sec.depends_on:
                hit = resolve_ref(raw, t, by_key)
                if hit is None:
                    continue          # unresolvable: validate reports it, not this
                dep_todo = by_id.get(hit[0])
                if dep_todo is None:
                    continue
                deps.append(canon(dep_todo, hit[1]))
            for fd in file_deps:
                if fd != ref and fd not in deps:
                    deps.append(fd)
            edges[ref] = deps
    return edges, titles



def _longest_chain(edges: dict[str, list[str]]) -> list[str]:
    """The longest dependency chain in the graph, deepest-first order.

    Memoised depth-first. A cycle would otherwise recurse forever, so a node
    already on the current path is treated as terminating that branch: the graph
    should be acyclic and `validate` enforces it, but a tool that hangs on bad
    input is worse than one that reports a short chain.
    """
    best: dict[str, list[str]] = {}

    def walk(node: str, on_path: frozenset) -> list[str]:
        if node in best:
            return best[node]
        if node in on_path or node not in edges:
            return [node]
        longest: list[str] = []
        for dep in edges[node]:
            cand = walk(dep, on_path | {node})
            if len(cand) > len(longest):
                longest = cand
        result = [node] + longest
        best[node] = result
        return result

    overall: list[str] = []
    for node in edges:
        chain = walk(node, frozenset())
        if len(chain) > len(overall):
            overall = chain
    return overall


def _filing_couplings() -> tuple[list[tuple[str, str, str]], list[str]]:
    """Couplings from the findings ledger, and any reason the evidence is incomplete.

    Returns (couplings, problems). The first version returned only the couplings
    and swallowed everything else: an unreadable heading, an import failure, a
    missing script all produced an empty list, and the report then stated that no
    review had filed a finding. "No evidence" and "the evidence could not be
    read" are opposite claims and it made them identical.

    That is the third time in this TODO file that a failure was quietly turned
    into a benign result, after the claims checker dropping a split claim and the
    coverage floor passing with no claims. Found by the independent review of
    390b560.
    """
    mod = REPO / "scripts" / "todo-findings.py"
    if not mod.is_file():
        return [], [f"{mod.name} is missing, so no filing evidence could be read"]
    import importlib.util
    spec = importlib.util.spec_from_file_location("todo_findings", mod)
    if spec is None or spec.loader is None:
        return [], [f"{mod.name} could not be loaded, so no filing evidence could be read"]
    tf = importlib.util.module_from_spec(spec)
    try:
        spec.loader.exec_module(tf)
        findings, bad = tf.collect()
    except Exception as exc:
        return [], [f"reading {mod.name} failed: {exc}"]
    problems = [
        f"{path}:{line} could not be read as a finding -- {why}"
        for path, line, why in bad
    ]
    out = [
        (f.ref, f.filed_to, f.summary)
        for f in findings
        if getattr(f, "filed_to", None)
    ]
    return out, problems



def _plan_state(todos: list[Todo]) -> dict[str, str]:
    """Map 'D05 T02 §3' -> the section's real status character."""
    state: dict[str, str] = {}
    for t in todos:
        dom = t.domain.split("-")[0]
        for num, s in t.sections.items():
            if s.moved:
                continue  # no row in the plan; a Moved line stands in its place
            state[f"D{dom} T{t.number} §{num}"] = s.status
    return state


def _plan_items(todos: list[Todo]) -> dict[str, int]:
    """Map 'D05 T02 §3' -> the section's real checklist item count.

    The plan's Items column is what an operator reads to size the next piece of
    work, so a count typed once and never re-derived is worse than no column.
    """
    counts: dict[str, int] = {}
    for t in todos:
        dom = t.domain.split("-")[0]
        for num, s in t.sections.items():
            if s.moved:
                continue
            counts[f"D{dom} T{t.number} §{num}"] = s.items_total
    return counts


def _sync_items_cell(line: str, want: int) -> tuple[str, int | None]:
    """Rewrite the Items cell to `want`, keeping the cell's width.

    Returns (line, previous) where previous is None when the row has no Items
    cell to sync, so a differently shaped table is left alone rather than mangled.
    """
    m = PLAN_ITEMS_RE.search(line)
    if not m:
        return line, None
    had = int(m.group("items"))
    if had == want:
        return line, had
    width = len(m.group("cell"))
    cell = f"{want}".center(width)
    if len(cell) > width:          # the number outgrew the column; keep one pad
        cell = f" {want} "
    return line[: m.start("cell")] + cell + line[m.end("cell") :], had


def _in_progress_by_ref(todos: list[Todo]) -> dict[str, bool]:
    """Shipped-but-unstamped: Commit item ticked, no Verified stamp. D00 T06 §31."""
    flags: dict[str, bool] = {}
    for t in todos:
        dom = t.domain.split("-", 1)[0]
        for num, s in t.sections.items():
            flags[f"D{dom} T{t.number} §{num}"] = s.status != "x" and (
                s.status == "/"
                or (s.commit_done and num not in t.verified_sections)
            )
    return flags


def _duration_by_ref(todos: list[Todo]) -> dict[str, int | None]:
    """Map 'D05 T02 §3' -> stamp Duration minutes, or None when the field is absent."""
    minutes: dict[str, int | None] = {}
    for t in todos:
        dom = t.domain.split("-")[0]
        for num, s in t.sections.items():
            minutes[f"D{dom} T{t.number} §{num}"] = s.duration_minutes
    return minutes


def _stamped_on_by_ref(todos: list[Todo]) -> dict[str, str | None]:
    """Map 'D05 T02 §3' -> Verified: calendar day, or None when the stamp has no date."""
    days: dict[str, str | None] = {}
    for t in todos:
        dom = t.domain.split("-")[0]
        for num, s in t.sections.items():
            days[f"D{dom} T{t.number} §{num}"] = s.stamped_on
    return days


PHASE_HEADING_RE = re.compile(
    r"^### Phase (?P<id>\d+)\s+(?:\u2014|\u2013|--|-)\s+(?P<title>.+?)\s*$"
)
# Resolute day-1 port: no progress surface consumes these yet, so both
# stay derived and gitignored under build/ beside the cache. When a progress
# surface lands, repoint to its committed path and let --check pin it in CI.
PROGRESS_JSON = REPO / "build" / "todo-progress.json"
OPERATOR_JSON = REPO / "build" / "todo-operator.json"
REVIEW_KIND_RE = re.compile(
    r"`(adversarial|consistency|optimisation|source-defect|record|design|fidelity)`"
)
REQUIRED_REVIEW_KINDS = ("adversarial", "consistency", "optimisation", "record")
# Wave-1 debt named in CLAUDE.md. Verified 2026-08-13/14 without the panel.
REVIEW_DEBT = frozenset(
    {
        "D00 T03 §2",
        "D00 T03 §10",
        "D01 T03 §1",
        "D01 T01 §16",
        "D01 T01 §17",
        "D03 T01 §3",
        "D03 T01 §4",
        "D01 T04 §1",
    }
)


def build_progress(todos: list[Todo]) -> dict:
    """The payload the progress dashboard renders. Same graph as plan --sync.

    Counts and checkbox state come from Implementation Order rows, not from
    campaign.json and not from a second list in PHP. Duration is present only
    when a stamp recorded integer minutes.
    """
    state = _plan_state(todos)
    items_by_ref = _plan_items(todos)
    duration = _duration_by_ref(todos)
    stamped = _stamped_on_by_ref(todos)
    in_flight = _in_progress_by_ref(todos)
    chips = _stamp_chips_by_ref(todos)
    phases: list[dict] = []

    if PLAN.exists():
        lines = PLAN.read_text(encoding="utf-8").splitlines()
        i = 0
        while i < len(lines):
            heading = PHASE_HEADING_RE.match(lines[i])
            if not heading:
                i += 1
                continue
            phase_id = int(heading.group("id"))
            title = heading.group("title").strip()
            sections: list[dict] = []
            i += 1
            while i < len(lines) and not lines[i].startswith("### Phase "):
                row = PLAN_ROW_RE.match(lines[i])
                if row:
                    ref = re.sub(r"\s+", " ", row.group("ref"))
                    cells = _split_row(lines[i]) or []
                    deliverable = cells[2].strip() if len(cells) > 2 else ""
                    done = state.get(ref, row.group("box")) == "x"
                    chip = chips.get(ref) or {}
                    section_row = {
                        "ref": ref,
                        "deliverable": deliverable,
                        "done": done,
                        "in_progress": (not done) and bool(in_flight.get(ref)),
                        "duration_minutes": duration.get(ref),
                        "stamped_on": stamped.get(ref),
                        "verified": bool(chip.get("verified")),
                        "reviews": list(chip.get("reviews") or []),
                    }
                    live = chip.get("live_checks")
                    if live:
                        section_row["live_checks"] = live
                    if section_row["verified"]:
                        # None on a stamp without the field: the page says
                        # "not recorded" rather than inventing a name (D00 T08 §1).
                        section_row["implementer"] = chip.get("implementer")
                    sections.append(section_row)
                i += 1
            total = len(sections)
            done_n = sum(1 for s in sections if s["done"])
            phases.append(
                {
                    "id": phase_id,
                    "heading": f"Phase {phase_id}",
                    "title": title,
                    "done": done_n,
                    "total": total,
                    "complete": total > 0 and done_n == total,
                    "sections": sections,
                }
            )

    # D00 T06 §29: in-progress is 0 < done < total (same membership as
    # 0 < percent < 100 after PHP's clamp). Empty headings are never current:
    # they are never complete, so the old first-incomplete scan opened them.
    # `percent` is not emitted on phase records; PHP derives it from counts.
    current_phase_id = _select_current_phase_id(phases)
    for phase in phases:
        phase["current"] = phase["id"] == current_phase_id
        phase["expanded"] = phase["current"]

    plan_done = sum(phase["done"] for phase in phases)
    plan_total = sum(phase["total"] for phase in phases)
    secs = [s for t in todos for s in t.sections.values()]
    in_progress_n = sum(1 for flag in in_flight.values() if flag)
    done_n = sum(1 for s in secs if s.status == "x")
    # A moved section (writers-and-reviewers §2) is neither open nor done
    # here: `query stats` counts it on its own line, and so does this.
    moved_n = sum(1 for s in secs if s.moved)

    return {
        "stats": {
            "sections": len(secs),
            "done": done_n,
            "in_progress": in_progress_n,
            "open": len(secs) - done_n - in_progress_n - moved_n,
            "moved": moved_n,
        },
        "plan": {
            "done": plan_done,
            "total": plan_total,
            "open": plan_total - plan_done,
            "percent": round(plan_done / plan_total * 100) if plan_total else 0,
        },
        "current_phase_id": current_phase_id,
        "phases": phases,
    }


def _phase_in_progress(phase: dict) -> bool:
    """Work started and work left. Empty headings are neither."""
    total = int(phase.get("total") or 0)
    done = int(phase.get("done") or 0)
    return total > 0 and 0 < done < total


def _select_current_phase_id(phases: list[dict]) -> int | None:
    """First in-progress phase, else first non-empty incomplete, else none.

    Numbered order in the JSON is unchanged. Display order (complete last) is
    a PHP render concern, not this projection. D00 T06 §29.
    """
    for phase in phases:
        if _phase_in_progress(phase):
            return int(phase["id"])
    for phase in phases:
        total = int(phase.get("total") or 0)
        if total > 0 and not phase.get("complete"):
            return int(phase["id"])
    return None


def progress_text(todos: list[Todo]) -> str:
    """Deterministic payload. `generated_at` is stamped only on write. D00 T06 §31."""
    return json.dumps(build_progress(todos), indent=2, sort_keys=True) + "\n"


def _generated_at() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def generated_progress_text(todos: list[Todo], generated_at: str | None = None) -> str:
    payload = build_progress(todos)
    payload["generated_at"] = generated_at or _generated_at()
    return json.dumps(payload, indent=2, sort_keys=True) + "\n"


GENERATED_AT_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")


def _valid_generated_at(value: object) -> bool:
    """Calendar-valid UTC instant, not merely regex-shaped. D00 T06 §31."""
    if not isinstance(value, str) or GENERATED_AT_RE.fullmatch(value) is None:
        return False
    try:
        parsed = datetime.strptime(value, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
    except ValueError:
        return False
    if parsed.strftime("%Y-%m-%dT%H:%M:%SZ") != value:
        return False
    now = datetime.now(timezone.utc)
    if parsed > now + timedelta(days=1):
        return False
    if parsed < now - timedelta(days=365 * 20):
        return False
    return True


def progress_generated_at_ok(written: str) -> bool:
    try:
        data = json.loads(written)
    except json.JSONDecodeError:
        return False
    return isinstance(data, dict) and _valid_generated_at(data.get("generated_at"))


def progress_text_for_check(written: str) -> str:
    """Drop a valid generated_at so plan --check does not race the clock.

    Invalid or missing values are left in place so the compare fails rather than
    treating a corrupt snapshot as current.
    """
    data = json.loads(written)
    if isinstance(data, dict) and _valid_generated_at(data.get("generated_at")):
        data.pop("generated_at", None)
    return json.dumps(data, indent=2, sort_keys=True) + "\n"


def write_progress_json(todos: list[Todo]) -> None:
    PROGRESS_JSON.parent.mkdir(parents=True, exist_ok=True)
    PROGRESS_JSON.write_text(generated_progress_text(todos), encoding="utf-8")


def _latest_closeout() -> str | None:
    files = [
        path
        for path in list((REPO / "docs" / "campaign-runs").glob("*.md"))
        + list((REPO / "docs" / "phase-runs").glob("*.md"))
        if path.name.lower() != "readme.md"
    ]
    if not files:
        return None
    latest = max(files, key=lambda p: p.name)
    return latest.relative_to(REPO).as_posix()


def _open_plan_phases(text: str) -> list[tuple[int, str, list[str]]]:
    """Open `[ ]` rows grouped by `### Phase N` heading. Same split plan-gate uses."""
    heading_re = re.compile(r"^### (Phase\s+(\d+)\b.*)$")
    phases: list[tuple[int, str, list[str]]] = []
    current_id: int | None = None
    current_heading = ""
    current_refs: list[str] = []
    for line in text.splitlines():
        heading = heading_re.match(line)
        if heading:
            if current_id is not None and current_refs:
                phases.append((current_id, current_heading, current_refs))
            current_id = int(heading.group(2))
            current_heading = heading.group(1).strip()
            current_refs = []
            continue
        row = PLAN_ROW_RE.match(line)
        if row and row.group("box") == " " and current_id is not None:
            current_refs.append(re.sub(r"\s+", " ", row.group("ref")))
    if current_id is not None and current_refs:
        phases.append((current_id, current_heading, current_refs))
    return phases


def _campaign_snapshot(todos: list[Todo]) -> dict:
    """Live next-phase fields for operator JSON. Computed from the already-loaded graph.

    Used to shell out to `plan-gate.py next`, which then shelled out to
    `todo-graph.py resolve` once per open Phase 0 row (76 after the 2026-08-20
    remap). That nested spawn is what made `plan --check` take 12s locally and
    exceed plan-gate's 15s timeout on GitHub Actions.
    """
    payload = {
        "phase": None,
        "phase_n": None,
        "open_count": 0,
        "first_open": None,
        "first_ready": None,
        "closeout": _latest_closeout(),
    }
    if not PLAN.is_file():
        return payload
    first_blocked: dict | None = None
    for phase_n, heading, refs in _open_plan_phases(PLAN.read_text(encoding="utf-8")):
        codes = {ref: resolve_exit_code(ref, todos) for ref in refs}
        ready = [ref for ref in refs if codes[ref] == 0 and not requires_missing_for_ref(ref, todos)]
        broken = [ref for ref in refs if codes[ref] not in (0, 3, 4)]
        if ready or broken:
            payload["phase"] = heading
            payload["phase_n"] = phase_n
            payload["open_count"] = len(refs)
            payload["first_open"] = refs[0]
            payload["first_ready"] = ready[0] if ready else None
            return payload
        if first_blocked is None:
            first_blocked = {
                "phase": heading,
                "phase_n": phase_n,
                "open_count": len(refs),
                "first_open": refs[0],
            }
    if first_blocked is not None:
        payload.update(first_blocked)
    return payload


def _review_kinds(body: str) -> list[str]:
    kinds: list[str] = []
    for kind in REVIEW_KIND_RE.findall(body):
        if kind not in kinds:
            kinds.append(kind)
    return kinds


def _review_kind_label(kind: str) -> str | None:
    if kind == "plan":
        return None
    if kind in REVIEW_KIND_LABELS:
        return REVIEW_KIND_LABELS[kind]
    return kind.replace("-", " ").title()


def _review_entries(body: str) -> list[dict]:
    """Kinds that ran on the stamp, not fingerprints, jobs, or prose."""
    seen: set[str] = set()
    out: list[dict] = []
    for match in REVIEW_ENTRY_RE.finditer(body or ""):
        kind = match.group("kind").lower()
        if REVIEW_JOBISH_RE.match(kind) or REVIEW_HEX_RE.match(kind):
            continue
        label = "Gemini final" if kind == "adversarial-final" and (match.group("family") or "").lower() == "gemini" else _review_kind_label(kind)
        if not label or kind in seen:
            continue
        seen.add(kind)
        verdict = re.sub(r"\s+", " ", match.group("verdict").lower())
        if verdict in ("approve", "needs-attention"):
            status = "passed"
        elif verdict == "advisory":
            # A stage 3 or 4 pass (§7): `advisory (family model ×1)` ran,
            # `advisory (skipped)` did not; neither is a verdict on the section.
            status = "skipped" if (match.group("family") or "").lower() == "" else "advisory"
        elif "skip" in verdict:
            status = "skipped"
        else:
            continue
        family = (match.group("family") or "").lower() or None
        model = match.group("model") or None
        runs = int(match.group("runs")) if match.group("runs") else None
        out.append({
            "kind": kind, "status": status, "label": label,
            # `family` None and `model` None together mean "model not recorded":
            # the stamp predates the ledger or nothing was dispatched for the kind.
            "family": family, "model": model, "runs": runs,
        })
    return out


def _implementer(body: str) -> dict | None:
    """`{"name": "Fable 5.1", "model": "claude-fable-5-1"}`, or None when not recorded."""
    m = IMPLEMENTER_RE.fullmatch((body or "").strip())
    if not m or not m.group("model"):
        return None
    return {"name": m.group("name").strip(), "model": m.group("model")}


def _stamp_chips_by_ref(todos: list[Todo]) -> dict[str, dict]:
    chips: dict[str, dict] = {}
    provenance = None
    for t in todos:
        dom = t.domain.split("-")[0]
        for num, sec in t.sections.items():
            ref = f"D{dom} T{t.number} §{num}"
            verified = num in t.verified_sections
            reviews = _review_entries(sec.review_body) if verified else []
            live = []
            canonical_ref = t.path+'#'+str(num)
            outcomes = f"docs/reviews/{t.domain}/D{dom}-T{t.number}-s{num}-review-outcomes.json"
            if verified and (sec.verification_body or (REPO / outcomes).is_file()):
                if provenance is None:
                    spec = importlib.util.spec_from_file_location('progress_provenance', Path(__file__).parent / 'progress-provenance.py')
                    provenance = importlib.util.module_from_spec(spec)
                    spec.loader.exec_module(provenance)
                execution = provenance.load_outcomes(REPO, outcomes, canonical_ref, sec.review_body, reviews)
                for review in reviews:
                    if review['kind'] in execution:
                        review['execution'] = execution[review['kind']]
                live = provenance.live_checks(REPO, canonical_ref, sec.verification_body.strip('` '))
            chips[ref] = {
                "verified": verified,
                "reviews": reviews,
                "live_checks": live,
                "implementer": _implementer(sec.implementer_body) if verified else None,
            }
    return chips


def _review_doc(ref: str) -> str | None:
    match = re.fullmatch(r"D(\d{2}) T(\d{2}) §(\d+)", ref)
    if not match:
        return None
    # Sharded by domain since 2026-08-23. A flat directory was heading for one
    # file per section -- about 435 -- which is navigable by grep and by
    # nothing else. The domain directory is derived from the ref rather than
    # stored, so it cannot drift from where the file actually is.
    domain = _domain_dir(match.group(1))
    if domain is None:
        return None
    rel = f"docs/reviews/{domain}/D{match.group(1)}-T{match.group(2)}-s{match.group(3)}.md"
    return rel if (REPO / rel).is_file() else None


def _domain_dir(number: str) -> str | None:
    """'00' -> '00-workspace'. Read from the tree, never hardcoded."""
    for child in sorted((REPO / "todo").iterdir()):
        if child.is_dir() and child.name.startswith(f"{number}-"):
            return child.name
    return None


def build_operator(todos: list[Todo]) -> dict:
    """Operator Campaign / Findings / Reviews payload. D00 T06 §6."""
    findings: list[dict] = []
    reviews: list[dict] = []
    for t in todos:
        dom = t.domain.split("-")[0]
        for num, sec in t.sections.items():
            ref = f"D{dom} T{t.number} §{num}"
            for done, text in sec.items:
                match = FINDING_RE.search(text)
                if not match:
                    continue
                status = "done" if done else ("filed" if "XREF" in text else "open")
                findings.append(
                    {
                        "date": match.group("date"),
                        "ref": ref,
                        "path": t.path,
                        "section": num,
                        "verb": match.group("verb"),
                        "text": re.sub(r"\s+", " ", text).strip(),
                        "status": status,
                    }
                )
            if num not in t.verified_sections:
                continue
            kinds = _review_kinds(sec.review_body)
            missing = [k for k in REQUIRED_REVIEW_KINDS if k not in kinds]
            reviews.append(
                {
                    "ref": ref,
                    "title": sec.title or sec.deliverable,
                    "kinds": kinds,
                    "skipped_limit": "skipped (limit)" in sec.review_body
                    or "skipped-limit" in sec.review_body,
                    "missing_required": missing,
                    "debt": bool(missing) or ref in REVIEW_DEBT,
                    "doc": _review_doc(ref),
                }
            )
    findings.sort(key=lambda row: (row["date"], row["path"], row["section"]), reverse=True)
    reviews.sort(key=lambda row: row["ref"])
    return {
        "campaign": _campaign_snapshot(todos),
        "findings": findings,
        "reviews": reviews,
    }


def operator_text(todos: list[Todo]) -> str:
    return json.dumps(build_operator(todos), indent=2, sort_keys=True) + "\n"


def write_operator_json(todos: list[Todo]) -> None:
    OPERATOR_JSON.parent.mkdir(parents=True, exist_ok=True)
    OPERATOR_JSON.write_text(operator_text(todos), encoding="utf-8")


def cmd_progress(args: argparse.Namespace) -> int:
    todos = load_todos()
    stamp = _generated_at()
    text = generated_progress_text(todos, stamp)
    sys.stdout.write(text)
    if args.write:
        PROGRESS_JSON.parent.mkdir(parents=True, exist_ok=True)
        PROGRESS_JSON.write_text(text, encoding="utf-8")
        print(f"wrote {_rel(PROGRESS_JSON)}", file=sys.stderr)
    return 0


def cmd_plan(args: argparse.Namespace) -> int:
    """Sync (or check) implementation-plan.md's boxes against the graph.

    The boxes are DERIVED, never hand-maintained. Two places recording the
    same completion state is precisely the drift this repository keeps paying
    for -- a stale `Depends On` edge hid half the project behind a client
    nothing used, and the handover pack diverged from production in both
    directions while reading as authoritative.

    So the plan's checkboxes are a projection of the Implementation Order
    tables, which `review-todo-section` is the only thing allowed to flip.
    `--check` is what CI runs; it fails when the projection has gone stale.
    """
    if not PLAN.exists():
        print(f"{_rel(PLAN)} does not exist.", file=sys.stderr)
        return 2

    todos = load_todos()
    state = _plan_state(todos)
    items_by_ref = _plan_items(todos)

    lines = PLAN.read_text(encoding="utf-8").splitlines()
    out: list[str] = []
    stale: list[str] = []
    unknown: list[str] = []
    seen: list[str] = []

    moved = _moved_by_ref(todos)
    moved_rows: list[str] = []      # moved sections that still hold a row
    stale_notes: list[str] = []     # Moved lines whose section is not moved (or is noted twice)
    noted: set[str] = set()
    pending_notes: list[str] = []   # written where the table that held the row ends

    def flush_notes(next_line: str | None) -> None:
        if not pending_notes:
            return
        if out and out[-1].strip():
            out.append("")
        out.extend(pending_notes)
        pending_notes.clear()
        if next_line is not None and next_line.strip():
            out.append("")

    for line in lines:
        note = PLAN_MOVED_RE.match(line)
        if note:
            nref = re.sub(r"\s+", " ", note.group("ref"))
            if nref in moved and nref not in noted:
                noted.add(nref)
                out.append(_moved_line(nref, moved[nref]))  # regenerated: the pointer is the section's
            else:
                stale_notes.append(nref)
            continue
        m = PLAN_ROW_RE.match(line)
        if not m:
            if pending_notes and not line.startswith("|"):
                flush_notes(line)
            out.append(line)
            continue
        ref = re.sub(r"\s+", " ", m.group("ref"))
        if ref in moved:
            # Not a row any more: it leaves one line saying where it went, at
            # the end of the table it sat in, and never counts (§2 rule).
            moved_rows.append(ref)
            if ref not in noted:
                noted.add(ref)
                pending_notes.append(_moved_line(ref, moved[ref]))
            continue
        seen.append(ref)
        if ref not in state:
            unknown.append(ref)
            out.append(line)
            continue
        want = state[ref]
        if want != m.group("box"):
            stale.append(f"{ref}: plan says [{m.group('box')}], graph says [{want}]")
        want_items = items_by_ref.get(ref)
        if want_items is not None:
            line, had_items = _sync_items_cell(line, want_items)
            if had_items is not None and had_items != want_items:
                stale.append(
                    f"{ref}: plan says {had_items} item(s), graph says {want_items}"
                )
        # Replace the box CHARACTER in place rather than rebuilding the row.
        # Rebuilding would collapse the column padding on every sync, so the
        # file would be aligned exactly until the next time anything shipped --
        # which is the one moment nobody is looking at its whitespace.
        out.append(line[: m.start("box")] + want + line[m.end("box") :])

    # A section listed TWICE is the failure this projection exists to prevent,
    # and it is not caught by any check above: both rows sync happily to the
    # same status, the totals just quietly overcount, and the phase that should
    # have lost the row keeps it. Found 2026-08-12 when `D01 T02 §3` was added
    # to Phase 0 while still sitting in Phase 4 -- `--check` passed.
    flush_notes(None)
    dupes = sorted({r for r in seen if seen.count(r) > 1})

    done = sum(1 for r in seen if state.get(r) == "x")
    total = len(seen)
    pct = round(done / total * 100) if total else 0
    summary = (
        f"**{done} of {total} sections complete ({pct}%).** "
        f"Derived from the Implementation Order tables by "
        f"`python scripts/todo-graph.py plan --sync` -- never edited by hand."
    )
    text = "\n".join(out) + "\n"
    text, n = PLAN_PROGRESS_RE.subn(lambda mo: mo.group("prefix") + summary, text, count=1)
    if n == 0:
        print(
            "warning: no '> **Progress:**' line in the plan, so the summary was "
            "not updated. Add one under the title.",
            file=sys.stderr,
        )

    # A row for a section that does not exist is a worse defect than a stale
    # box: it means the plan is sequencing something the graph has never heard
    # of, and no amount of syncing will make it true.
    for ref in unknown:
        print(f"::error::{_rel(PLAN)} references {ref}, which is not in the graph")

    # EVERY section has a ROW. Not "is mentioned somewhere", and not "is
    # mentioned unless it already shipped".
    #
    # Hardened 2026-08-23 on operator instruction, after the drift it allowed
    # was measured: 435 sections, 417 rows, and `--check` green. Both escape
    # hatches were load-bearing in the wrong direction.
    #
    #   `state[r] != "x"` excused a SHIPPED section from having a row. That
    #   sounds harmless -- the work is done -- but the plan's totals are
    #   computed from its rows, so each excused section silently shrank the
    #   denominator AND the numerator. The plan reported 125/417 = 30% while
    #   the graph held 143/435 = 33%, and `platform/resources/rebuild-progress.json`
    #   feeds that number to the progress dashboard reads.
    #
    #   Matching any backtick-quoted ref anywhere in the file excused a
    #   section from having a row because a SENTENCE named it. The plan's own
    #   prose said so out loud -- "The stamped T05 rows stay named in prose" --
    #   which is a design decision that quietly stopped the projection from
    #   being a projection.
    #
    # Neither hatch is replaced with a softer one. A section that genuinely
    # does not belong in a phase does not exist: `plan --sync` derives from the
    # Implementation Order tables, and a section IS a unit of work in a domain.
    missing = [r for r in state if r not in seen]

    if args.check:
        for s in stale:
            print(f"::error::{_rel(PLAN)} is stale -- {s}")
        for r in moved_rows:
            print(
                f"::error::{_rel(PLAN)} lists {r} as a row, but its section is "
                "moved out of the tree. `plan --sync` replaces the row with a Moved line."
            )
        for r in stale_notes:
            print(
                f"::error::{_rel(PLAN)} carries a Moved line for {r}, which is "
                "not moved (or is noted twice). `plan --sync` drops it."
            )
        for r in dupes:
            print(
                f"::error::{_rel(PLAN)} lists {r} in more than one phase. "
                "One row per section, or the totals overcount and a phase keeps work it handed away."
            )
        if missing:
            print(
                f"::error::{len(missing)} section(s) have no row in the plan, so "
                f"the plan's totals do not describe the project: "
                + ", ".join(sorted(missing)[:8])
                + ("..." if len(missing) > 8 else "")
            )
        expected_json = progress_text(todos)
        written_progress = PROGRESS_JSON.read_text(encoding="utf-8") if PROGRESS_JSON.exists() else ""
        json_stale = (
            not PROGRESS_JSON.exists()
            or not progress_generated_at_ok(written_progress)
            or progress_text_for_check(written_progress) != expected_json
        )
        if json_stale:
            print(
                f"::error::{_rel(PROGRESS_JSON)} is stale -- "
                "run `python scripts/todo-graph.py plan --sync`"
            )
        expected_operator = operator_text(todos)
        operator_stale = (
            not OPERATOR_JSON.exists()
            or OPERATOR_JSON.read_text(encoding="utf-8") != expected_operator
        )
        if operator_stale:
            print(
                f"::error::{_rel(OPERATOR_JSON)} is stale -- "
                "run `python scripts/todo-graph.py plan --sync`"
            )
        if stale or unknown or missing or dupes or json_stale or operator_stale or moved_rows or stale_notes:
            print(
                f"\n{len(stale)} stale row(s), {len(unknown)} unknown ref(s), "
                f"{len(missing)} unsequenced section(s), {len(dupes)} duplicated section(s)"
                f"{f', {len(moved_rows)} moved row(s)' if moved_rows else ''}"
                f"{f', {len(stale_notes)} stale Moved line(s)' if stale_notes else ''}"
                f"{', progress JSON stale' if json_stale else ''}"
                f"{', operator JSON stale' if operator_stale else ''}. "
                "Run `python scripts/todo-graph.py plan --sync`.",
                file=sys.stderr,
            )
            return 1
        print(f"implementation plan is current -- {done}/{total} sections complete ({pct}%)")
        return 0

    text = _align_tables(text)
    PLAN.write_text(text, encoding="utf-8", newline=chr(10))
    write_progress_json(todos)
    write_operator_json(todos)
    for r in dupes:
        print(f"  WARNING: {r} appears in more than one phase")
    print(f"synced {total} row(s) -- {done} complete ({pct}%), {len(stale)} box(es) changed")
    for r in moved_rows:
        print(f"  moved: {r} -- row replaced by a Moved line")
    for r in stale_notes:
        print(f"  dropped a stale Moved line for {r}")
    for s in stale:
        print(f"  {s}")
    if missing:
        print(f"  NOTE: {len(missing)} open section(s) appear in no phase -- run with --check for the list")
    return 0


# ---------------------------------------------------------------------- main


# ------------------------------------------------------------------ self-test


SELF_TEST_TODO_A = """---
schema_version: 1
id: self-test-alpha
domain: 90-selftest
status: active
title: "TODO-01 -- Self-test alpha"
track: Z1
---

# TODO-01 -- Self-test alpha

> **Goal:** Fixture. Never shipped, never read by a human.

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Shipped thing | - |  [x]   |
|   2   |   §2    | Open thing, deps met | §1 |  [ ]   |
|   3   |   §3    | Open thing, dep unmet | §2 |  [ ]   |
|   4   |   §4    | Open thing, cross-file dep unmet | T02 §1 |  [ ]   |

---

## 1. Shipped thing

- [x] Did the thing
- [x] Commit: `"selftest: the thing"`

**Test checkpoint:** `true` proves nothing and is meant to.

> **Verified:** 2026-01-01 | §1 | fixture mentioned §4
> **Review:** round 1, fingerprint `abc123def456` -- `adversarial` review-mt1-aaaa approve · `consistency` review-mt1-bbbb needs-attention · `design` aux-design-x skipped (limit) · `integration` opus-integration-y approve
> **CRUD:** applicable | test.sales cloud-crud.sh 24/24
> **Duration:** 7

## 2. Open thing, deps met

**Needs:** Windows host (build/test)

- [ ] Do the next thing
- [ ] And another
- [x] Commit: `"selftest: the next thing"`

**Test checkpoint:** `true`

> **Deferred:** something for later -> XREF: D90 T02 §1 (item: "A deferred thing")

## 3. Open thing, dep unmet

- [ ] Blocked on §2
- [ ] Commit: `"selftest: blocked"`

**Test checkpoint:** `true`

## 4. Open thing, cross-file dep unmet

- [ ] Blocked on another file
- [ ] Commit: `"selftest: cross-file"`

**Test checkpoint:** `true`
"""

SELF_TEST_TODO_B = """---
schema_version: 1
id: self-test-beta
domain: 90-selftest
status: active
title: "TODO-02 -- Self-test beta"
track: Z1
frozen: true
---

# TODO-02 -- Self-test beta

> **Goal:** Fixture.

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | A deferred thing | - |  [ ]   |

---

## 1. A deferred thing

- [ ] A deferred thing
- [ ] Commit: `"selftest: deferred"`

**Test checkpoint:** `true`
**Freeze check:** fixture
"""

SELF_TEST_TODO_C = """---
schema_version: 1
id: self-test-gamma
domain: 90-selftest
status: active
title: "TODO-03 -- Self-test gamma"
track: Z1
---

# TODO-03 -- Self-test gamma

> **Goal:** Fixture. Requires-mark shapes for the environment gate.

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Unknown value | -- |  [ ]   |
|   2   |   §2    | Missing reason | -- |  [ ]   |
|   3   |   §3    | Empty values | -- |  [ ]   |
|   4   |   §4    | Valid mark | -- |  [ ]   |
|   5   |   §5    | Shipped unmarked | -- |  [x]   |
|   6   |   §6    | Two lines, last wins | -- |  [ ]   |

---

## 1. Unknown value

**Requires:** printerz -- because testing

- [ ] Do the thing
- [ ] Commit: `"selftest: gamma"`

**Test checkpoint:** `true`

## 2. Missing reason

**Requires:** display-session

- [ ] Do the thing
- [ ] Commit: `"selftest: gamma"`

**Test checkpoint:** `true`

## 3. Empty values

**Requires:** ,

- [ ] Do the thing
- [ ] Commit: `"selftest: gamma"`

**Test checkpoint:** `true`

## 4. Valid mark

**Requires:** display-session -- fixture reason, with comma (and parens)

- [ ] Do the thing
- [ ] Commit: `"selftest: gamma"`

**Test checkpoint:** `true`

## 5. Shipped unmarked

- [x] Did the thing
- [x] Commit: `"selftest: gamma"`

**Test checkpoint:** `true`

> **Verified:** 2026-01-01 | §5 | fixture shipped unmarked
> **Review:** round 1, fingerprint `abc123def456` -- `adversarial` approve
> **CRUD:** applicable | fixture

## 6. Two lines, last wins

**Requires:** printerz -- first line loses

**Requires:** display-session -- second wins

- [ ] Do the thing
- [ ] Commit: `"selftest: gamma"`

**Test checkpoint:** `true`
"""

SELF_TEST_PLAN = """# Implementation plan

### Phase 0 -- Fixture phase

| ✔ | Section | Deliverable | Days |
| :-: | :-----: | ----------- | :--: |
| [ ] | `D90 T01 §1` | Shipped thing | 1 |
| [ ] | `D90 T01 §2` | Open thing, deps met | 2 |

### Phase 1 -- Empty fixture phase

### Phase 2 -- Second fixture phase

| ✔ | Section | Deliverable | Days |
| :-: | :-----: | ----------- | :--: |
| [ ] | `D90 T01 §3` | Open thing, dep unmet | 1 |
| [ ] | `D90 T02 §1` | A deferred thing | 1 |
"""


SELF_TEST_TODO_MOVED = """---
schema_version: 1
id: self-test-moved
domain: 93-moved
status: active
title: "TODO-05 -- moved section"
track: Z1
---

# TODO-05 -- moved section

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Moved thing | - |  [ ]   |
|   2   |   §2    | Depends on the moved thing | §1 |  [ ]   |

## 1. Moved thing

> **Moved:** 2026-09-05 to docs/plans/fixture-plan.md (operator instruction); worked there by its named writer without a review chain.

- [x] Shipped before the move
- [ ] ~~Found 2026-01-01 by a fixture: open work, struck~~ Moved 2026-09-05 to docs/plans/fixture-plan.md.
- [ ] Commit: `"selftest: moved"`

**Test checkpoint:** run tests/MovedTest.php.

## 2. Depends on the moved thing

- [ ] Do it
- [ ] Commit: `"selftest: dependent"`

**Test checkpoint:** run tests/DependentTest.php.
"""

SELF_TEST_PLAN_MOVED = """# Implementation plan

> **Progress:** placeholder

### Phase 0 -- Moved fixture phase

| ✔ | Section | Deliverable | Days |
| :-: | :-----: | ----------- | :--: |
| [ ] | `D93 T05 §1` | Moved thing | 1 |
| [ ] | `D93 T05 §2` | Depends on the moved thing | 1 |

Prose after the table.

### Phase 1 -- The ratchet fixture's own row

| ✔ | Section | Deliverable | Days |
| :-: | :-----: | ----------- | :--: |
| [ ] | `D91 T09 §1` | Placeholder | 1 |
"""


def cmd_self_test(_args) -> int:
    """Prove the graph's own contract against synthetic fixtures, in under a second.

    This exists so a run may edit this file as planned section work: the ban in
    `process-phase` is verify-then-adopt, and this is the verify. Before this
    existed the only coverage was `PlanGateTest` inside the Pest suite, which
    runs eight minutes into pre-push -- exactly the wrong place for a check
    whose whole value is being fast enough to run after every edit.

    Fixtures, never the live tree: a self-test that reads `todo/` passes or
    fails for reasons that have nothing to do with this file, and `validate`
    already owns that job.
    """
    import tempfile

    cases: list[tuple[str, object, object]] = []

    def check(name: str, got, want) -> None:
        cases.append((name, got, want))

    global TODO_DIR, PLAN, SKILLS_DIR  # noqa: PLW0603 -- rebinding is the point
    saved_todo_dir, saved_plan, saved_skills = TODO_DIR, PLAN, SKILLS_DIR
    tmp = tempfile.TemporaryDirectory(prefix="todo-graph-selftest-")
    try:
        root = Path(tmp.name)
        (root / "todo" / "90-selftest").mkdir(parents=True)
        a = root / "todo" / "90-selftest" / "TODO-01-self-test-alpha.md"
        b = root / "todo" / "90-selftest" / "TODO-02-self-test-beta.md"
        a.write_text(SELF_TEST_TODO_A, encoding="utf-8")
        b.write_text(SELF_TEST_TODO_B, encoding="utf-8")
        plan = root / "todo" / "implementation-plan.md"
        plan.write_text(SELF_TEST_PLAN, encoding="utf-8")
        TODO_DIR = root / "todo"
        PLAN = plan
        # Fixture validates scan fixture skills, never the live skills: the
        # live files cite live sections that fixture trees do not have.
        (root / "skills").mkdir(exist_ok=True)
        SKILLS_DIR = root / "skills"

        todos = load_todos()
        check("load_todos finds both fixtures", len(todos), 2)
        ta = next((t for t in todos if t.number == "01"), None)
        tb = next((t for t in todos if t.number == "02"), None)
        check("alpha parsed", ta is not None, True)
        check("beta parsed", tb is not None, True)
        if ta is None or tb is None:
            raise RuntimeError("fixtures did not parse; the rest cannot run")

        # --- parsing -------------------------------------------------------
        check("alpha has four sections", len(ta.sections), 4)
        check("alpha frontmatter id", ta.id, "self-test-alpha")
        check("beta is frozen", tb.frozen, True)
        check("alpha is not frozen", ta.frozen, False)
        check("§1 row is shipped", ta.sections[1].status, "x")
        check("§2 row is open", ta.sections[2].status, " ")
        check("§2 counts three items", ta.sections[2].items_total, 3)
        check("§1 counts its done items", ta.sections[1].items_done, 2)
        check("§2 has a Test checkpoint", ta.sections[2].has_test_checkpoint, True)
        # --- the Needs marker (D00 T07 §28) ---------------------------------
        check("§2 Needs parses to the closed-list key", ta.sections[2].needs, ["windows-host"])
        check("§2 Needs keeps the raw value", ta.sections[2].needs_raw, "Windows host (build/test)")
        check("§3 has no Needs", ta.sections[3].needs, [])
        check("needs_for_ref: marked", needs_for_ref("D90 T01 §2", todos), ["windows-host"])
        check("needs_for_ref: unmarked", needs_for_ref("D90 T01 §3", todos), [])
        check("needs_for_ref: unknown ref is []", needs_for_ref("D91 T01 §1", todos), [])
        check(
            "needs_for_ref: pasted plan row",
            needs_for_ref("| [ ] | `D90 T01 §2` | Open thing | 2 |", todos),
            ["windows-host"],
        )

        # --- the Requires marker ---------------------------------------------
        import io as _bio
        import contextlib as _bctx
        check("a section with no Requires line parses empty",
              (ta.sections[3].requires_has_line, ta.sections[3].requires,
               ta.sections[3].requires_unknown, ta.sections[3].requires_reason),
              (False, [], [], ""))
        gamma = root / "todo" / "90-selftest" / "TODO-03-self-test-gamma.md"
        gamma.write_text(SELF_TEST_TODO_C, encoding="utf-8")
        try:
            todos2 = load_todos()
            g = next(t for t in todos2 if t.number == "03")
            check("a valid mark parses values plus reason",
                  (g.sections[4].requires, g.sections[4].requires_reason),
                  (["display-session"], "fixture reason, with comma (and parens)"))
            check("a second Requires line wins fully",
                  (g.sections[6].requires, g.sections[6].requires_unknown,
                   g.sections[6].requires_reason),
                  (["display-session"], [], "second wins"))
            check("an unknown value parses into requires_unknown",
                  (g.sections[1].requires, g.sections[1].requires_unknown),
                  ([], ["printerz"]))
            check("a mark without its separator parses reason-empty",
                  (g.sections[2].requires, g.sections[2].requires_reason),
                  (["display-session"], ""))
            check("a mark with no values parses empty",
                  (g.sections[3].requires, g.sections[3].requires_unknown,
                   g.sections[3].requires_reason),
                  ([], [], ""))
            vbuf = _bio.StringIO()
            with _bctx.redirect_stdout(vbuf), _bctx.redirect_stderr(_bio.StringIO()):
                cmd_validate(None)
            rfatal = [ln for ln in vbuf.getvalue().splitlines()
                      if ln.startswith("FATAL") and "Requires" in ln]
            check("an unknown Requires value is FATAL (requires-unknown)",
                  any("§1" in ln and "not in the closed list" in ln for ln in rfatal), True)
            check("a Requires mark without its reason is FATAL (requires-no-reason)",
                  any("§2" in ln and "with no reason" in ln for ln in rfatal), True)
            check("a Requires mark with no values is FATAL (requires-unknown)",
                  any("§3" in ln and "no values" in ln for ln in rfatal), True)
            check("a mark with no values and no reason draws both FATALs",
                  sum(1 for ln in rfatal if "§3" in ln), 2)
            check("a valid mark draws no Requires FATAL",
                  any("§4" in ln for ln in rfatal), False)
            check("a shipped section without a mark draws no Requires FATAL",
                  any("§5" in ln for ln in rfatal), False)
            check("a valid last line draws no Requires FATAL",
                  any("§6" in ln for ln in rfatal), False)
            check("display-session holds on Windows with SESSIONNAME",
                  detect_context(platform="win32", environ={"SESSIONNAME": "Console"}),
                  {"display-session"})
            check("display-session fails on Windows without a session",
                  detect_context(platform="win32", environ={"SESSIONNAME": "  "}),
                  set())
            check("display-session fails when SESSIONNAME is missing",
                  detect_context(platform="win32", environ={}),
                  set())
            check("display-session fails off Windows",
                  detect_context(platform="linux", environ={}),
                  set())
            check("display-session fails in session 0 (Services)",
                  detect_context(platform="win32", environ={"SESSIONNAME": "Services"}),
                  set())

            def ready_lines(**kw):
                buf = _bio.StringIO()
                with _bctx.redirect_stdout(buf):
                    code = cmd_query(argparse.Namespace(what="ready", all=False, **kw))
                return code, buf.getvalue().splitlines()

            code, lines = ready_lines(context=["display-session"])
            check("an explicit display context lists the marked row runnable",
                  (code, any("§4" in ln and "requires" not in ln for ln in lines)), (0, True))
            code, lines = ready_lines(context=[])
            check("an empty context parks the marked row with its requirement named",
                  (code, any("requires display-session (missing: display-session)" in ln and "§4" in ln for ln in lines)), (0, True))
            code, lines = ready_lines(context=["display-session"])
            check("an unknown value parks even in a display context",
                  (code, any("unknown:printerz" in ln and "§1" in ln for ln in lines)), (0, True))
            check("a mark with no values parks even in a display context",
                  (code, any("no values (see validate)" in ln and "§3" in ln for ln in lines)), (0, True))
            code, lines = ready_lines()
            check("query ready without a context flag still exits 0",
                  code, 0)
            check("the split summary names both counts",
                  any("runnable now" in ln and "runnable elsewhere" in ln for ln in lines), True)
        finally:
            gamma.unlink()
        # --- skill-to-plan citations (D00 T04 §9) ------------------------------
        probe = root / "skills" / "probe-skill"
        probe.mkdir(parents=True)
        probe_skill = probe / "SKILL.md"
        probe_skill.write_text(
            "See D90 T01 §2 for the shape.\n\nBut D90 T01 §9 does not exist.\n"
            "Bare §9, T04 §9, and probe.md §9 are all short forms.\n"
            "Spaced D90  T01  §2 and tabbed D90\tT01\t§2 stay legal.\n",
            encoding="utf-8",
        )
        try:
            sbuf = _bio.StringIO()
            with _bctx.redirect_stdout(sbuf), _bctx.redirect_stderr(_bio.StringIO()):
                cmd_validate(None)
            sfatal = [ln for ln in sbuf.getvalue().splitlines() if ln.startswith("FATAL")]
            check("a resolving skill citation draws no FATAL",
                  any("D90 T01 §2" in ln for ln in sfatal), False)
            check("an unresolving skill citation is FATAL by file and line",
                  any("SKILL.md:3" in ln and "D90 T01 §9" in ln for ln in sfatal), True)
            check("a bare §N in a skill is FATAL by file and line",
                  any("SKILL.md:4" in ln and "short form §9" in ln for ln in sfatal), True)
            check("a TNN §N in a skill is FATAL by file and line",
                  any("SKILL.md:4" in ln and "short form T04 §9" in ln for ln in sfatal), True)
            check("a file §N in a skill is FATAL by file and line",
                  any("SKILL.md:4" in ln and "short form probe.md §9" in ln for ln in sfatal), True)
            check("a wide-spaced full ref in a skill draws no FATAL",
                  any("SKILL.md:5" in ln for ln in sfatal), False)
        finally:
            probe_skill.unlink()
            probe.rmdir()
        check("§2 has a Commit item", ta.sections[2].has_commit_item, True)
        check("beta §1 has a Freeze check", tb.sections[1].has_freeze_check, True)
        check("every body section has a row", all(s.has_row for s in ta.sections.values()), True)
        check("every row has a body", all(s.has_body for s in ta.sections.values()), True)
        check("§1 duration parsed", ta.sections[1].duration_minutes, 7)
        check("§1 duration end absent", ta.sections[1].duration_end, None)
        check("§2 duration fully absent", (ta.sections[2].duration_end, ta.sections[2].duration_minutes), (None, None))
        dur = root / "todo" / "90-selftest" / "TODO-06-duration.md"
        dur.write_text(
            """---
schema_version: 1
id: self-test-duration
domain: 90-selftest
status: active
title: "TODO-06 -- duration"
track: Z1
---

# TODO-06 -- duration

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Minutes then range | - |  [x]   |
|   2   |   §2    | Range then minutes | - |  [x]   |
|   3   |   §3    | Bad range | - |  [x]   |
|   4   |   §4    | Inverted range | - |  [x]   |
|   5   |   §5    | Range then unshaped | - |  [x]   |

## 1. Minutes then range

- [x] Commit: `"selftest: duration"`

> **Verified:** 2026-01-01 | §1 | fixture
> **Duration:** 7
> **Duration:** 2026-01-01T10:00:00Z to 2026-01-01T10:07:00Z

## 2. Range then minutes

- [x] Commit: `"selftest: duration"`

> **Verified:** 2026-01-01 | §2 | fixture
> **Duration:** 2026-01-01T10:00:00Z to 2026-01-01T10:07:00Z
> **Duration:** 9

## 3. Bad range

- [x] Commit: `"selftest: duration"`

> **Verified:** 2026-01-01 | §3 | fixture
> **Duration:** 2026-09-31T10:00:00Z to 2026-09-31T10:07:00Z

## 4. Inverted range

- [x] Commit: `"selftest: duration"`

> **Verified:** 2026-01-01 | §4 | fixture
> **Duration:** 2026-01-01T10:07:00Z to 2026-01-01T10:00:00Z

## 5. Range then unshaped

- [x] Commit: `"selftest: duration"`

> **Verified:** 2026-01-01 | §5 | fixture
> **Duration:** 2026-01-01T10:00:00Z to 2026-01-01T10:07:00Z
> **Duration:** unclear
""",
            encoding="utf-8",
        )
        dd = parse_todo(dur)
        check(
            "stacked Duration resolves last-wins",
            (
                dd.sections[1].duration_end,
                dd.sections[1].duration_minutes,
                dd.sections[2].duration_end,
                dd.sections[2].duration_minutes,
            ),
            ("2026-01-01T10:07:00Z", 7, None, 9),
        )
        check(
            "calendar-invalid Duration fails soft",
            (dd.sections[3].duration_end, dd.sections[3].duration_minutes),
            (None, None),
        )
        check(
            "inverted Duration fails soft",
            (dd.sections[4].duration_end, dd.sections[4].duration_minutes),
            (None, None),
        )
        check(
            "unshaped Duration clears a prior range",
            (dd.sections[5].duration_end, dd.sections[5].duration_minutes),
            (None, None),
        )
        dur.unlink()
        check("§1 is in verified_sections", 1 in ta.verified_sections, True)
        check("alpha carries one deferral", len(ta.deferred), 1)
        check("the deferral names its owner", ta.deferred[0].ref, "D90 T02 §1")
        check("the deferral is open", ta.deferred[0].resolved, False)

        # --- resolve_exit_code: the contract process-phase routes on --------
        check("exit 0 -- open, deps met", resolve_exit_code("D90 T01 §2", todos), 0)
        check("exit 3 -- already shipped", resolve_exit_code("D90 T01 §1", todos), 3)
        check("exit 4 -- dep in the same file", resolve_exit_code("D90 T01 §3", todos), 4)
        check("exit 4 -- dep in another file", resolve_exit_code("D90 T01 §4", todos), 4)
        check("exit 1 -- no such section", resolve_exit_code("D90 T01 §99", todos), 1)
        check("exit 1 -- no such todo", resolve_exit_code("D91 T01 §1", todos), 1)
        check("exit 2 -- no section reference", resolve_exit_code("just some prose", todos), 2)
        check("exit 2 -- empty input", resolve_exit_code("   ", todos), 2)

        # --- the three reference forms all resolve to the same section ------
        check(
            "reference form: path + §N",
            resolve_exit_code("90-selftest/TODO-01-self-test-alpha.md §2", todos),
            0,
        )
        check(
            "reference form: a pasted plan row",
            resolve_exit_code("| [ ] | `D90 T01 §2` | Open thing, deps met | 2 |", todos),
            0,
        )
        check(
            "reference form: prose around a ref",
            resolve_exit_code("please do D90 T01 §2 next", todos),
            0,
        )

        # --- plan projection ------------------------------------------------
        state = _plan_state(todos)
        check("plan state knows the shipped row", state.get("D90 T01 §1"), "x")
        check("plan state knows an open row", state.get("D90 T01 §2"), " ")
        check("plan state covers the second file", state.get("D90 T02 §1"), " ")
        check("plan state has one key per section", len(state), 5)

        phases = _open_plan_phases(plan.read_text(encoding="utf-8"))
        check("open phases skip the empty one", [p[0] for p in phases], [0, 2])
        check("phase 0 lists both its rows", len(phases[0][2]), 2)
        check("phase rows keep their refs", phases[0][2][0], "D90 T01 §1")

        # --- progress arithmetic --------------------------------------------
        prog = build_progress(todos)
        by_id = {p["id"]: p for p in prog["phases"]}
        check("progress emits every heading", sorted(by_id), [0, 1, 2])
        check("phase 0 counts its rows", by_id[0]["total"], 2)
        check("phase 0 counts the shipped one", by_id[0]["done"], 1)
        check("an empty phase totals zero", by_id[1]["total"], 0)
        check("an empty phase is not complete", by_id[1].get("complete"), False)
        check("phase 2 has nothing done", by_id[2]["done"], 0)
        check("progress carries the stamp duration", by_id[0]["sections"][0].get("duration_minutes"), 7)
        check("progress carries the Verified calendar day", by_id[0]["sections"][0].get("stamped_on"), "2026-01-01")
        check("evidence §N does not verify that section", 4 not in ta.verified_sections, True)
        check("coverage field still verifies §1", 1 in ta.verified_sections, True)
        shipped = by_id[0]["sections"][0]
        check("progress verified chip on a stamped row", shipped.get("verified"), True)
        check(
            "progress review kinds follow the job-plus-verdict grammar",
            [r["kind"] for r in shipped.get("reviews") or []],
            ["adversarial", "consistency", "design", "integration"],
        )
        check("needs-attention is Passed", (shipped.get("reviews") or [{}])[1].get("status"), "passed")
        check("skipped-limit is Skipped", (shipped.get("reviews") or [{}, {}, {}])[2].get("status"), "skipped")
        check("fingerprint is not a review kind", "abc123def456" not in [r["kind"] for r in shipped.get("reviews") or []], True)
        check("progress does not upgrade CRUD prose to live proof", shipped.get("live_checks", []), [])
        # D00 T08 §1: provenance on the lens clause, three states.
        prov = _review_entries(
            "fp `abc123abc123` | `adversarial` approve (codex gpt-5.6-sol ×10) · "
            "`consistency` needs-attention (2) (grok ×7) · `design` approve (model not recorded) · "
            "`integration` needs-attention (claude opus ×4)"
        )
        check("provenance: family and model", (prov[0]["family"], prov[0]["model"], prov[0]["runs"]), ("codex", "gpt-5.6-sol", 10))
        check("provenance: count then family, no model", (prov[1]["family"], prov[1]["model"], prov[1]["runs"]), ("grok", None, 7))
        check("provenance: model not recorded", (prov[2]["family"], prov[2]["model"], prov[2]["status"]), (None, None, "passed"))
        check("provenance: claude opus", (prov[3]["family"], prov[3]["model"]), ("claude", "opus"))
        final = _review_entries("`adversarial` approve (codex gpt-6-astra ×1) · `adversarial-final` advisory (qwen qwen3.8-max ×1) · `fidelity` advisory (skipped)")
        check("advisory pass: family, model, status", (final[1]["kind"], final[1]["family"], final[1]["model"], final[1]["status"], final[1]["label"]), ("adversarial-final", "qwen", "qwen3.8-max", "advisory", "Qwen final"))
        check("advisory skipped: status skipped, no family", (final[2]["kind"], final[2]["family"], final[2]["status"]), ("fidelity", None, "skipped"))
        bare = _review_entries("`adversarial` approve · `record` needs-attention (1)")
        check("a stamp without provenance still yields its kinds", [(r["kind"], r["family"]) for r in bare], [("adversarial", None), ("record", None)])
        # D00 T08 §4: Git abbreviations are a range, not just 12-character fingerprints.
        for length in range(4, 41):
            for token in ("a" + "9" * (length - 1), "F" + "0" * (length - 1)):
                check(f"commit token excluded {token}", _review_entries(f"`{token}` approve"), [])
            check(f"digit-leading commit remains inert {length}", _review_entries(f"`{'1' * length}` approve"), [])
        for token in ("abc", "a" * 41):
            check(f"non-commit boundary retains prior classification {len(token)}", [r["kind"] for r in _review_entries(f"`{token}` approve")], [token])
        legacy_kinds = (
            "correctness", "data-safety", "integration", "fix-review", "adversarial",
            "consistency", "optimisation", "record", "opus", "source-defect", "design",
            "adversarial-final", "fidelity", "escalation", "security",
        )
        for kind in legacy_kinds:
            entry = _review_entries(f"`{kind}` approve (claude opus ×2)")
            check(f"actual historical vocabulary preserved {kind}", [(r["kind"], r["family"], r["model"], r["runs"], r["status"]) for r in entry], [(kind, "claude", "opus", 2, "passed")])
        for clause in (None, "", "unrecorded", "`record` refused", "`plan` approve", "`opus-design-20260907` approve"):
            check(f"missing invalid or non-lens clause stays empty {clause}", _review_entries(clause), [])
        check("implementer parses name and model", _implementer("Fable 5.1 (claude-fable-5-1)"), {"name": "Fable 5.1", "model": "claude-fable-5-1"})
        check("implementer not recorded is None", _implementer("not recorded (stamped before D00 T08 §1)"), None)
        check("implementer refuses prose", _implementer("Derick typed this"), None)
        check("stamped row carries implementer key", "implementer" in shipped, True)
        # A range stamp's field lines reach every section it covers (Codex, last wave).
        ranged_dir = Path(tempfile.mkdtemp(prefix="todo-range-"))
        try:
            (ranged_dir / "todo" / "00-workspace").mkdir(parents=True)
            (ranged_dir / "todo" / "00-workspace" / "TODO-09-range.md").write_text(
                "---\nschema_version: 1\nid: range\ndomain: 00-workspace\nstatus: draft\ntitle: Range\n---\n\n# Range\n\n"
                "## Implementation Order\n\n| Order | Section | Deliverable | Depends On | Status |\n| :---: | :-----: | --- | --- | :----: |\n"
                "| 1 | §1 | One | -- | [x] |\n| 2 | §2 | Two | §1 | [x] |\n\n"
                "## 1. One\n\n- [x] a\n\n## 2. Two\n\n- [x] b\n\n"
                "> **Verified:** 2026-09-03 | §1 - §2 | ok\n> **Review:** fp `abc123abc123` | `adversarial` approve (codex ×1)\n> **Implementer:** Opus 5 (claude-opus-5)\n",
                encoding="utf-8",
            )
            ranged = parse_todo(ranged_dir / "todo" / "00-workspace" / "TODO-09-range.md")
            check("range stamp: Review reaches §1", "adversarial" in ranged.sections[1].review_body, True)
            check("range stamp: Review reaches §2", "adversarial" in ranged.sections[2].review_body, True)
            check("range stamp: Implementer reaches §1", _implementer(ranged.sections[1].implementer_body), {"name": "Opus 5", "model": "claude-opus-5"})
            (ranged_dir / "todo" / "00-workspace" / "TODO-09-range.md").write_text(
                (ranged_dir / "todo" / "00-workspace" / "TODO-09-range.md").read_text(encoding="utf-8")
                + "\n> **Verified:** 2026-09-03 | §9 - §1 | backwards\n> **Review:** `design` approve (claude opus ×1)\n",
                encoding="utf-8",
            )
            after = parse_todo(ranged_dir / "todo" / "00-workspace" / "TODO-09-range.md")
            check("a malformed stamp's fields reach no section", "design" in after.sections[2].review_body, False)
        finally:
            shutil.rmtree(ranged_dir, ignore_errors=True)
        open_row = by_id[0]["sections"][1]
        check("unstamped row is not verified", open_row.get("verified"), False)
        check("unstamped row has no review chips", open_row.get("reviews"), [])
        check("unstamped row omits live_checks", "live_checks" in open_row, False)
        check(
            "progress leaves stamped_on null where no Verified date exists",
            by_id[0]["sections"][1].get("stamped_on"),
            None,
        )

        range_todo = root / "todo" / "90-selftest" / "TODO-03-range.md"
        range_todo.write_text(
            """---
schema_version: 1
id: self-test-range
domain: 90-selftest
status: active
title: "TODO-03 -- range stamp"
track: Z1
---

# TODO-03 -- range stamp

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | One | - |  [x]   |
|   2   |   §2    | Two | §1 |  [x]   |
|   3   |   §3    | Three | §2 |  [x]   |

## 1. One

> **Verified:** 2026-08-20 | §1-§3 | range fixture

## 2. Two

## 3. Three
""",
            encoding="utf-8",
        )
        # --- §38: pre-convention warnings ACK on stamped sections only ------
        ack_todo = root / "todo" / "90-selftest" / "TODO-04-acked.md"
        ack_todo.write_text(
            """---
schema_version: 1
id: self-test-acked
domain: 90-selftest
status: active
title: "TODO-04 -- acked warnings"
track: Z1
---

# TODO-04 -- acked warnings

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Stamped, both defects | - |  [x]   |
|   2   |   §2    | Open, both defects | §1 |  [ ]   |
|   3   |   §3    | Ticked but unverified | §1 |  [x]   |
|   4   |   §4    | Open but stamped | §1 |  [ ]   |
|   5   |   §5    | Stamped after the cutoff | §1 |  [x]   |
|   6   |   §6    | Needs a host nobody listed | §1 |  [ ]   |

## 1. Stamped, both defects

- [x] Did it
- [x] Commit: `"selftest: acked"`

**Fidelity:** some page -- fixture.

**Test checkpoint:** `pest --filter=Thing`; everything else must still pass.

> **Verified:** 2026-01-01 | §1 | fixture

## 2. Open, both defects

- [ ] Do it
- [ ] Commit: `"selftest: open"`

**Fidelity:** some page -- fixture.

**Test checkpoint:** `pest --filter=Thing`; everything else must still pass.

## 3. Ticked but unverified

- [x] Did it
- [x] Commit: `"selftest: unverified"`

**Fidelity:** some page -- fixture.

**Test checkpoint:** `pest --filter=Thing`; everything else must still pass.

## 4. Open but stamped

- [ ] Do it
- [ ] Commit: `"selftest: open-stamped"`

**Fidelity:** some page -- fixture.

**Test checkpoint:** `pest --filter=Thing`; everything else must still pass.

> **Verified:** 2026-01-01 | §4 | fixture

## 5. Stamped after the cutoff

- [x] Did it
- [x] Commit: `"selftest: post-cutoff"`

**Fidelity:** some page -- fixture.

**Test checkpoint:** `pest --filter=Thing`; everything else must still pass.

> **Verified:** 2027-01-01 | §5 | fixture

## 6. Needs a host nobody listed

**Needs:** Mars (live host)

- [ ] Do it
- [ ] Commit: `"selftest: needs"`

**Test checkpoint:** `true`
""",
            encoding="utf-8",
        )
        import io as _io
        import contextlib as _ctx

        vbuf = _io.StringIO()
        with _ctx.redirect_stdout(vbuf), _ctx.redirect_stderr(_io.StringIO()):
            cmd_validate(None)
        vout = vbuf.getvalue()
        vacked = getattr(cmd_validate, "last_acked", [])
        check(
            "stamped Fidelity gap is acked, not warned",
            any("TODO-04-acked.md" in a and "**Fidelity:**" in a for a in vacked),
            True,
        )
        check(
            "stamped --filter overclaim is acked, not warned",
            any("TODO-04-acked.md" in a and "`--filter`" in a for a in vacked),
            True,
        )
        check(
            "no WARN line names the stamped section",
            any(
                line.startswith("WARN") and "TODO-04-acked.md" in line and "§1" in line
                for line in vout.splitlines()
            ),
            False,
        )
        check(
            "needs_for_ref: an unknown VALUE is the unknown sentinel, never host-free",
            needs_for_ref("D90 T04 §6", load_todos()),
            ["unknown:Mars (live host)"],
        )
        check(
            "an unknown Needs value is FATAL (needs-unknown)",
            any(
                line.startswith("FATAL") and "TODO-04-acked.md" in line
                and "§6 has **Needs:** 'Mars (live host)'" in line
                for line in vout.splitlines()
            ),
            True,
        )
        check(
            "open Fidelity gap stays FATAL",
            any(
                line.startswith("FATAL") and "TODO-04-acked.md" in line and "§2 has **Fidelity:**" in line
                for line in vout.splitlines()
            ),
            True,
        )
        # D00 T01 §21 (2026-08-28): an OPEN unfalsifiable --filter checkpoint
        # is FATAL now -- a checkpoint known not to detect its promised
        # regression is push-time actionable (name the test files). The
        # stamped branches keep their §38 ack/fix-forward treatment above.
        check(
            "open --filter overclaim is FATAL (§21)",
            any(
                line.startswith("FATAL") and "TODO-04-acked.md" in line and "§2 has a `--filter`" in line
                for line in vout.splitlines()
            ),
            True,
        )
        # The conjunction, not either predicate alone (round-1 consistency
        # finding): [x] with no Verified stamp is NOT acked, and an open row
        # with a Verified stamp is NOT acked.
        check(
            "ticked-but-unverified §3 is not acked",
            any("TODO-04-acked.md" in a and "§3" in a for a in vacked),
            False,
        )
        check(
            "ticked-but-unverified §3 stays in the live channel",
            any(
                line.startswith(("WARN", "FATAL")) and "TODO-04-acked.md" in line and "§3" in line
                for line in vout.splitlines()
            ),
            True,
        )
        check(
            "open-but-stamped §4 is not acked",
            any("TODO-04-acked.md" in a and "§4" in a for a in vacked),
            False,
        )
        check(
            "open-but-stamped §4 Fidelity gap stays FATAL",
            any(
                line.startswith("FATAL") and "TODO-04-acked.md" in line and "§4 has **Fidelity:**" in line
                for line in vout.splitlines()
            ),
            True,
        )
        # The ack is DATE-BOUND: a stamp dated after the cutoff must not ack,
        # or new work could ship the defect under a "pre-convention" label
        # (terminal integration finding).
        check(
            "post-cutoff stamp §5 is not acked",
            any("TODO-04-acked.md" in a and "§5" in a for a in vacked),
            False,
        )
        check(
            "post-cutoff stamp §5 stays in the live channel",
            any(
                line.startswith(("WARN", "FATAL")) and "TODO-04-acked.md" in line and "§5" in line
                for line in vout.splitlines()
            ),
            True,
        )
        # ...and wears the fix-forward message, never the legacy do-not-reopen
        # text, which for a post-convention stamp is an instruction to ship
        # the gap (final integration finding).
        check(
            "severity: filter-overclaim-stamped stays WARN on post-cutoff §5",
            any(
                line.startswith("WARN")
                and "§5" in line
                and "TODO-04-acked.md" in line
                and "fix the checkpoint forward" in line
                for line in vout.splitlines()
            ),
            True,
        )
        check(
            "post-cutoff stamp §5 carries the fix-forward instruction",
            any(
                "§5" in line and "TODO-04-acked.md" in line and "fix it forward" in line
                for line in vout.splitlines()
            ),
            True,
        )
        # Class-isolated (review 2026-08-28): the Fidelity occurrence on the
        # post-cutoff stamp is a ratcheted WARN, never FATAL -- the probe
        # above accepts either prefix and would survive a reclassification.
        check(
            "severity: fidelity-missing-lines-stamped stays WARN on post-cutoff §5",
            any(
                line.startswith("WARN")
                and "§5" in line
                and "TODO-04-acked.md" in line
                and "fix it forward" in line
                for line in vout.splitlines()
            ),
            True,
        )
        check(
            "severity: fidelity-missing-lines-stamped never FATAL",
            any(
                line.startswith("FATAL") and "TODO-04-acked.md" in line and "fix it forward" in line
                for line in vout.splitlines()
            ),
            False,
        )
        ack_todo.unlink()

        # --- §37: one dependency gate -- whole-TODO edges block every -------
        # resolver. A source TODO with one shipped and one open section, and
        # consumers exercising file-level, unknown, empty, mixed, and
        # all-shipped edges.
        dep_src = root / "todo" / "90-selftest" / "TODO-05-dep-source.md"
        dep_empty = root / "todo" / "90-selftest" / "TODO-06-dep-empty.md"
        dep_users = root / "todo" / "90-selftest" / "TODO-07-dep-users.md"

        def dep_source_text(second_status: str) -> str:
            return f"""---
schema_version: 1
id: self-test-dep-source
domain: 90-selftest
status: active
title: "TODO-05 -- dep source"
track: Z1
---

# TODO-05 -- dep source

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Shipped half | - |  [x]   |
|   2   |   §2    | Open half | §1 |  [{second_status}]   |

## 1. Shipped half

## 2. Open half
"""

        dep_src.write_text(dep_source_text(" "), encoding="utf-8")
        dep_empty.write_text(
            """---
schema_version: 1
id: self-test-dep-empty
domain: 90-selftest
status: active
title: "TODO-06 -- dep empty"
track: Z1
---

# TODO-06 -- dep empty
""",
            encoding="utf-8",
        )
        dep_users.write_text(
            """---
schema_version: 1
id: self-test-dep-users
domain: 90-selftest
status: active
title: "TODO-07 -- dep users"
track: Z1
depends_on: ["self-test-dep-source"]
---

# TODO-07 -- dep users

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Blocked by the whole source TODO | - |  [ ]   |
|   2   |   §2    | Mixed: row edge plus the file edge | T05 §2 |  [ ]   |

## 1. Blocked by the whole source TODO

## 2. Mixed: row edge plus the file edge
""",
            encoding="utf-8",
        )
        dtodos = load_todos()
        dkey = {(t.domain, t.number): t for t in dtodos}
        d7 = next(t for t in dtodos if t.id == "self-test-dep-users")
        u1 = unmet_dependencies(d7, 1, dtodos, dkey)
        check(
            "whole-TODO edge blocks: exit 4 from the shared gate",
            resolve_exit_code("D90 T07 §1", dtodos),
            4,
        )
        check(
            "whole-TODO record names the first open section and count",
            [(u.get("kind"), u.get("first_open"), u.get("open_count")) for u in u1],
            [("todo", 2, 1)],
        )
        u2 = unmet_dependencies(d7, 2, dtodos, dkey)
        check(
            "mixed: row edge and file edge both reported",
            sorted(u.get("kind") for u in u2),
            ["section", "todo"],
        )
        # Repaired: the source's final open section flips [x]; the consumer
        # becomes ready WITHOUT editing the consumer.
        dep_src.write_text(dep_source_text("x"), encoding="utf-8")
        rtodos = load_todos()
        check(
            "all-shipped source unblocks the consumer",
            resolve_exit_code("D90 T07 §1", rtodos),
            0,
        )
        check(
            "mixed section becomes ready with the same flip",
            resolve_exit_code("D90 T07 §2", rtodos),
            0,
        )
        # Moved: the source's only open section leaves the tree (row stays
        # [ ], work struck); the consumer becomes ready WITHOUT editing the
        # consumer, or whole-TODO dependents would wait on moved work forever.
        dep_src.write_text(
            dep_source_text(" ").replace(
                "## 2. Open half\n",
                "## 2. Open half\n\n"
                "> **Moved:** 2026-01-02 to docs/testing.md (fixture).\n",
            ),
            encoding="utf-8",
        )
        mtodos = load_todos()
        check(
            "a moved open section does not block the whole-TODO consumer",
            resolve_exit_code("D90 T07 §1", mtodos),
            0,
        )
        check(
            "mixed section ready when its row edge moved out",
            resolve_exit_code("D90 T07 §2", mtodos),
            0,
        )
        # Empty and unknown sources are UNMET, never accidentally satisfied.
        dep_users.write_text(
            dep_users.read_text(encoding="utf-8").replace(
                'depends_on: ["self-test-dep-source"]',
                'depends_on: ["self-test-dep-empty"]',
            ),
            encoding="utf-8",
        )
        check(
            "an EMPTY prerequisite TODO is unmet",
            resolve_exit_code("D90 T07 §1", load_todos()),
            4,
        )
        dep_users.write_text(
            dep_users.read_text(encoding="utf-8").replace(
                'depends_on: ["self-test-dep-empty"]',
                'depends_on: ["self-test-dep-ghost"]',
            ),
            encoding="utf-8",
        )
        check(
            "an UNKNOWN prerequisite id is unmet, not silently ready",
            resolve_exit_code("D90 T07 §1", load_todos()),
            4,
        )
        # A blank `depends_on:` scalar is NO dependency, not an unnamed one:
        # it must neither block nor produce an empty-labeled record
        # (round-1 finding, both lenses).
        dep_users.write_text(
            dep_users.read_text(encoding="utf-8").replace(
                'depends_on: ["self-test-dep-ghost"]',
                "depends_on:",
            ),
            encoding="utf-8",
        )
        btodos = load_todos()
        check(
            "a blank depends_on scalar does not block",
            resolve_exit_code("D90 T07 §1", btodos),
            0,
        )
        check(
            "a blank depends_on scalar parses to no edges",
            next(t for t in btodos if t.id == "self-test-dep-users").depends_on,
            [],
        )
        # A row edge to a real TODO's NONEXISTENT section is unmet (exit 4)
        # and validate rule 5b reports it FATAL -- the unknown shape most
        # likely to survive in a hand-edited tree (round-2 integration).
        dep_users.write_text(
            dep_users.read_text(encoding="utf-8").replace(
                "| Blocked by the whole source TODO | - |",
                "| Blocked by the whole source TODO | T05 §9 |",
            ),
            encoding="utf-8",
        )
        gtodos = load_todos()
        check(
            "row edge to a nonexistent section is unmet",
            resolve_exit_code("D90 T07 §1", gtodos),
            4,
        )
        gbuf = _io.StringIO()
        with _ctx.redirect_stdout(gbuf), _ctx.redirect_stderr(_io.StringIO()):
            cmd_validate(None)
        check(
            "validate reports that edge FATAL",
            any(
                line.startswith("FATAL") and "T05 §9" in line and "does not exist" in line
                for line in gbuf.getvalue().splitlines()
            ),
            True,
        )
        dep_src.unlink()
        dep_empty.unlink()
        dep_users.unlink()

        ranged = parse_todo(range_todo)
        # verified_sections and stamped_on both fan out from the SAME covered
        # list, so a range-stamped section is stamped for the ack predicate
        # too (round-2 integration question, answered here as a proof).
        check("range stamp verifies the whole range", {1, 2, 3} <= ranged.verified_sections, True)
        check("range stamp dates §1", ranged.sections[1].stamped_on, "2026-08-20")
        check("range stamp dates §2", ranged.sections[2].stamped_on, "2026-08-20")
        check("range stamp dates §3", ranged.sections[3].stamped_on, "2026-08-20")

        # --- §39: the stamp parser refuses the line it cannot parse ---------
        # Eighteen cases, fourteen RED and four GREEN, and the ones past the
        # first two are the reason this block exists. A date-only repair passes
        # "nonsense is refused" and "a good stamp is accepted" while
        # `2026-08-29 | nonsense |` still verifies the section it sits in,
        # which is the cheaper substitute §39's Treatment forbids; and
        # validating the PARTS passes all of those while junk after the date, a
        # missing delimiter, an empty evidence field and a reversed range in a
        # list still verify. Round 2 added the two the ANCHORED grammar still
        # let through: another script's digits, and an unbounded range.
        # Every RED case asserts BOTH that the refusal was recorded AND that
        # the section stayed out of verified_sections: a FATAL that still
        # verifies the section would be a gate that reports and permits.
        def malformed_case(name: str, stamp_body: str) -> None:
            f = root / "todo" / "90-selftest" / f"TODO-05-malformed-{name}.md"
            f.write_text(
                "---\n"
                "schema_version: 1\n"
                f"id: self-test-malformed-{name}\n"
                "domain: 90-selftest\n"
                "status: active\n"
                f'title: "TODO-05 -- malformed {name}"\n'
                "track: Z1\n"
                "---\n\n"
                f"# TODO-05 -- malformed {name}\n\n"
                "## Implementation Order\n\n"
                "| Order | Section | Deliverable | Depends On | Status |\n"
                "| :---: | :-----: | ----------- | ---------- | :----: |\n"
                "|   1   |   §1    | One | - |  [x]   |\n\n"
                "## 1. One\n\n"
                "- [x] Commit: `\"selftest: one\"`\n\n"
                f"> **Verified:** {stamp_body}\n",
                encoding="utf-8",
            )
            parsed = parse_todo(f)
            check(f"malformed stamp refused: {name}", len(parsed.malformed_stamps), 1)
            # COUNT, not the set. Red-proving the coverage cap against the
            # uncapped parser printed a three-million-element set into the
            # failure message and 24 MB into the session that ran it: a check
            # whose failure output is unbounded is a check nobody can run under
            # the very condition it exists for.
            check(f"malformed stamp verifies nothing: {name}", len(parsed.verified_sections), 0)
            check(f"malformed stamp leaves stamped_on null: {name}", parsed.sections[1].stamped_on, None)
            f.unlink()

        malformed_case("nonsense", "nonsense")
        malformed_case("no-coverage-field", "2026-08-29")
        malformed_case("garbage-coverage", "2026-08-29 | nonsense | evidence")
        malformed_case("impossible-date", "2026-99-99 | §1 | evidence")
        malformed_case("malformed-range", "2026-08-29 | §3-§ | evidence")
        # Round 1, both Codex lenses (High): validating the PARTS is not
        # validating the LINE. Each of these five verified §1 under the
        # first version of the fix.
        malformed_case("junk-after-date", "2026-08-29 prose-before-coverage | §1 | evidence")
        malformed_case("no-closing-delimiter", "2026-08-29 | §1")
        malformed_case("empty-evidence", "2026-08-29 | §1 |")
        malformed_case("reversed-range-in-a-list", "2026-08-29 | §1, §3-§2 | evidence")
        malformed_case("section-zero", "2026-08-29 | §0 | evidence")
        # Round 2 (both Medium, measured): `\d` is Unicode-aware, so
        # `٢٠٢٦-٠٨-٢٩ | §١ |` verified §1 and stored a stamped_on no consumer
        # can compare; and an ordered but enormous range materialised three
        # million integers before anything looked at them.
        malformed_case("unicode-digits", "٢٠٢٦-٠٨-٢٩ | §١ | evidence")
        malformed_case("range-beyond-the-coverage-cap", "2026-08-29 | §1-§3000000 | evidence")
        # Round 3 (Medium): the cap was per ELEMENT, so two valid ranges
        # summed past it. `§1-§64` alone stays legal, immediately below.
        malformed_case("ranges-summing-past-the-cap", "2026-08-29 | §1-§64, §65-§128 | evidence")
        # The boundary itself, both sides, because round 5 found the cap and the
        # sibling gate's clamp differed by exactly one.
        malformed_case("one-past-the-cap", "2026-08-29 | §1-§66 | evidence")

        good = root / "todo" / "90-selftest" / "TODO-05-well-formed.md"
        good.write_text(
            """---
schema_version: 1
id: self-test-well-formed
domain: 90-selftest
status: active
title: "TODO-05 -- well formed"
track: Z1
---

# TODO-05 -- well formed

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | One | - |  [x]   |

## 1. One

- [x] Commit: `"selftest: one"`

> **Verified:** 2026-08-29 | §1 | evidence
""",
            encoding="utf-8",
        )
        ok_todo = parse_todo(good)
        check("well-formed stamp is not refused", ok_todo.malformed_stamps, [])
        check("well-formed stamp verifies its section", ok_todo.verified_sections, {1})
        check("well-formed stamp dates its section", ok_todo.sections[1].stamped_on, "2026-08-29")
        good.write_text(
            good.read_text(encoding="utf-8").replace(
                "> **Verified:** 2026-08-29 | §1 | evidence",
                "> **Verified:** 2026-08-29 | §1, §3 | evidence carrying | a pipe",
            ),
            encoding="utf-8",
        )
        multi = parse_todo(good)
        check("a comma list of sections is accepted", multi.malformed_stamps, [])
        check("a comma list verifies every element", multi.verified_sections, {1, 3})
        check("a pipe inside the evidence field is legal", multi.sections[1].stamped_on, "2026-08-29")
        good.unlink()
        check("range stamp is not refused", ranged.malformed_stamps, [])
        # The coverage cap is a second copy of a number the sibling gate also
        # carries, and the integration leg was right that nothing pinned them:
        # if the gate's clamp were raised, it would let a wide-range stamp be
        # WRITTEN while `validate` -- in the same pre-commit invocation --
        # refused the identical bytes, leaving the operator with two tools that
        # disagree about a stamp neither will let them fix. Reading the sibling
        # is the same shape as the README parity check above, which is why this
        # is a probe rather than a shared import: both are standalone stdlib
        # scripts by design.
        # Resolute day-1 port: the sibling stamp gate is not ported
        # yet (see Deferred in the repo README), so the parity probe below
        # only runs when the gate exists. When it lands, this skip goes away
        # and the clamp comparison runs unconditionally again.
        gate_path = REPO / "scripts" / "section_commit_gate.py"
        if not gate_path.exists():
            print("todo-graph self-test: SKIP sibling stamp-gate clamp probe (no section_commit_gate.py)")
        else:
            gate_src = gate_path.read_text(encoding="utf-8")
            # The sibling clamps `hi = min(hi, lo + N)` before building an inclusive
            # range (D00 T08 §1 closing wave; it was `min(end, start + N)` before).
            gate_clamp = re.search(r"min\((?:end|hi),\s*(?:start|lo)\s*\+\s*(\d+)\)", gate_src)
            # `+ 1`: the sibling clamps to `start + N` and then builds an INCLUSIVE
            # range, so it admits N+1 sections. Round 5 caught the first version of
            # this probe comparing the LITERAL and passing while the two tools
            # disagreed by exactly one -- a parity probe that reads the wrong half
            # of the expression is the same defect as no probe, and more expensive
            # because it is believed.
            check(
                "the effective stamp-range clamp in section_commit_gate.py matches MAX_STAMP_COVERAGE",
                int(gate_clamp.group(1)) + 1 if gate_clamp else None,
                MAX_STAMP_COVERAGE,
            )
        at_cap = root / "todo" / "90-selftest" / "TODO-05-at-cap.md"
        at_cap.write_text(
            (root / "todo" / "90-selftest" / "TODO-03-range.md").read_text(encoding="utf-8")
            .replace("id: self-test-range", "id: self-test-at-cap")
            .replace("2026-08-20 | §1-§3 | range fixture", "2026-08-20 | §1-§65 | at the cap"),
            encoding="utf-8",
        )
        capped = parse_todo(at_cap)
        check("a range exactly at the coverage cap is accepted", capped.malformed_stamps, [])
        check(
            "a range at the cap covers every section in it",
            len(capped.verified_sections),
            MAX_STAMP_COVERAGE,
        )
        at_cap.unlink()

        # The FATAL is emitted, not merely recorded on the object: rule 15 is
        # what tells the reader WHICH line is wrong, where rule 7 would only
        # say a visibly-stamped section has no stamp.
        bad = root / "todo" / "90-selftest" / "TODO-05-fatal.md"
        bad.write_text(
            (root / "todo" / "90-selftest" / "TODO-03-range.md").read_text(encoding="utf-8")
            .replace("id: self-test-range", "id: self-test-fatal")
            .replace("2026-08-20 | §1-§3 | range fixture", "nonsense"),
            encoding="utf-8",
        )
        import io as _mio
        import contextlib as _mctx

        mbuf = _mio.StringIO()
        with _mctx.redirect_stdout(mbuf), _mctx.redirect_stderr(_mio.StringIO()):
            cmd_validate(None)
        malformed_out = mbuf.getvalue()
        check(
            "malformed-stamp is a FATAL class",
            SEVERITY_MAP.get("malformed-stamp"),
            "fatal",
        )
        check(
            "validate names the offending line",
            "refused '> **Verified:** nonsense" in malformed_out,
            True,
        )
        # Round 2 (Low) narrowed the SUBSTRING to rule 7's own sentence; the
        # Opus integration leg pointed out it had not narrowed the SCOPE.
        # `cmd_validate` walks the whole fixture tree, so asking whether the
        # sentence appears ANYWHERE in the buffer stays green while rule 7
        # stops firing for this fixture, which is the exact failure the round-2
        # comment claimed to close. Assert on the LINE: one output line naming
        # this fixture AND carrying rule 7's sentence.
        check(
            "the malformed stamp also leaves the [x] row missing its stamp",
            any(
                "TODO-05-fatal.md" in ln and "stamp covers it" in ln
                for ln in malformed_out.splitlines()
            ),
            True,
        )
        bad.unlink()
        check(
            "progress leaves duration null where no stamp recorded one",
            by_id[0]["sections"][1].get("duration_minutes"),
            None,
        )
        check(
            "a row's done state comes from the SECTION, not the plan box",
            by_id[0]["sections"][0]["done"],
            True,
        )
        check("verified shipped row is not in_progress", by_id[0]["sections"][0].get("in_progress"), False)
        check("shipped-unstamped row is in_progress", by_id[0]["sections"][1].get("in_progress"), True)
        check("open uncommitted row is not in_progress", by_id[0]["sections"][2].get("in_progress") if len(by_id[0]["sections"]) > 2 else by_id[2]["sections"][0].get("in_progress"), False)
        check("progress_text omits generated_at", "generated_at" in json.loads(progress_text(todos)), False)
        stamped = json.loads(generated_progress_text(todos, "2026-08-25T00:00:00Z"))
        check("generated payload carries generated_at", stamped.get("generated_at"), "2026-08-25T00:00:00Z")
        check(
            "plan --check ignores generated_at",
            progress_text_for_check(json.dumps(stamped, indent=2, sort_keys=True) + "\n"),
            progress_text(todos),
        )
        check("stats.in_progress matches shipped-unstamped rows", prog["stats"]["in_progress"], 1)
        check("valid generated_at is accepted", _valid_generated_at("2026-08-25T00:00:00Z"), True)
        check("regex-shaped invalid day is rejected", _valid_generated_at("2026-02-30T00:00:00Z"), False)
        check("missing generated_at fails the check", progress_generated_at_ok(progress_text(todos)), False)
        bogus = dict(stamped)
        bogus["generated_at"] = "not-a-date"
        check(
            "invalid generated_at is not stripped",
            "generated_at" in json.loads(progress_text_for_check(json.dumps(bogus))),
            True,
        )
        check(
            "phase records omit percent; PHP derives it",
            all("percent" not in phase for phase in prog["phases"]),
            True,
        )
        check("live 1-of-2 fixture is current, not the empty heading", prog["current_phase_id"], 0)
        check("empty heading is not current", by_id[1]["current"], False)
        check("empty heading is not expanded", by_id[1]["expanded"], False)
        check(
            "empty is never current even when it is first incomplete",
            _select_current_phase_id(
                [
                    {"id": 0, "done": 0, "total": 0, "complete": False},
                    {"id": 1, "done": 1, "total": 2, "complete": False},
                ]
            ),
            1,
        )
        check(
            "later partial outranks an earlier 0 percent phase",
            _select_current_phase_id(
                [
                    {"id": 0, "done": 0, "total": 4, "complete": False},
                    {"id": 1, "done": 2, "total": 4, "complete": False},
                ]
            ),
            1,
        )
        check(
            "all-complete has no current",
            _select_current_phase_id([{"id": 0, "done": 2, "total": 2, "complete": True}]),
            None,
        )

        # --- table alignment rewrites the plan file, so it must round-trip ---
        aligned = _align_tables(plan.read_text(encoding="utf-8"))
        check("alignment preserves the line count", len(aligned.splitlines()), len(SELF_TEST_PLAN.splitlines()))
        check(
            "alignment preserves every plan row",
            len([l for l in aligned.splitlines() if PLAN_ROW_RE.match(l)]),
            4,
        )
        check("alignment is idempotent", _align_tables(aligned), aligned)
        check(
            "alignment leaves non-table text alone",
            [l for l in aligned.splitlines() if not l.strip().startswith("|")],
            [l for l in SELF_TEST_PLAN.splitlines() if not l.strip().startswith("|")],
        )

        # --- the row regexes, which decide what is a section at all ----------
        check("ROW_RE accepts an open row", bool(ROW_RE.match("|   2   |   §2    | Thing | - |  [ ]   |")), True)
        check("ROW_RE accepts a shipped row", bool(ROW_RE.match("|   2   |   §2    | Thing | - |  [x]   |")), True)
        check("ROW_RE accepts an in-flight row", bool(ROW_RE.match("|   2   |   §2    | Thing | - |  [/]   |")), True)
        check("ROW_RE rejects a missing box", bool(ROW_RE.match("|   2   |   §2    | Thing | - |     |")), False)
        check("ROW_RE rejects the header", bool(ROW_RE.match("| Order | Section | Deliverable | Depends On | Status |")), False)
        check("PLAN_ROW_RE needs the backticked ref", bool(PLAN_ROW_RE.match("| [ ] | D90 T01 §1 | x | 1 |")), False)
        check("PLAN_ROW_RE accepts a real row", bool(PLAN_ROW_RE.match("| [ ] | `D90 T01 §1` | x | 1 |")), True)

        # --- Items column (D00 T04 §1) ---------------------------------------
        # Until 2026-09-17 nothing wrote or checked this column, so 28 of 121
        # rows disagreed with their section while `plan --check` passed.
        _row = "| [ ] | `D90 T01 §1` | Deliverable                        |   6   |"
        _new, _had = _sync_items_cell(_row, 11)
        check("items sync reads the old count", _had, 6)

        # --- calibration (D00 T04 §3) ----------------------------------------
        # The refusal below threshold is the point of the feature, not a
        # limitation of it: a correlation over six sections is noise with a
        # number attached, and a figure that looks like evidence gets cited.
        check("calibration refuses a correlation below the threshold",
              _calibration_reports_correlation(CALIBRATION_MIN_SAMPLE - 1), False)
        check("calibration reports one at the threshold",
              _calibration_reports_correlation(CALIBRATION_MIN_SAMPLE), True)
        check("pearson on a perfect line", round(_pearson([1, 2, 3], [2, 4, 6]), 6), 1.0)
        check("pearson on a perfect inverse", round(_pearson([1, 2, 3], [6, 4, 2]), 6), -1.0)
        check("pearson needs two points", _pearson([1], [2]), None)
        check("pearson refuses a flat series", _pearson([1, 1, 1], [1, 2, 3]), None)
        # Ownership, not mention. `git log --grep` matched the reference
        # anywhere in a message, so the commit introducing this report counted
        # as a commit of all six sections it tabulated.
        check("rework: ship then stamp is no rework",
              _needed_rework(["intake: x (D00 T01 §1)", "review: stamp (D00 T01 §1)"]), False)
        check("rework: ship, fix, stamp is rework",
              _needed_rework(["intake: x (D00 T01 §1)", "intake: fix (D00 T01 §1)",
                              "review: stamp (D00 T01 §1)"]), True)
        check("rework: unstamped says unknown rather than guessing",
              _needed_rework(["intake: x (D00 T01 §1)"]), None)

        # --- sequence (D00 T04 §4) -------------------------------------------
        _chain = _longest_chain({"a": ["b"], "b": ["c"], "c": [], "z": []})
        check("longest chain walks the whole dependency run", _chain, ["a", "b", "c"])
        check("longest chain ignores a shorter branch",
              _longest_chain({"a": ["b"], "b": [], "x": ["y"], "y": ["z"], "z": []}),
              ["x", "y", "z"])
        # A cycle should be impossible (validate forbids it) but a tool that
        # hangs on bad input is worse than one that reports a short chain.
        _cyc = _longest_chain({"a": ["b"], "b": ["a"]})
        check("longest chain terminates on a cycle", len(_cyc) <= 3, True)
        # _filing_couplings returned a bare list and swallowed every failure, so
        # "no evidence" and "the evidence could not be read" were the same
        # answer. The shape is the guard: a caller that unpacks two values
        # cannot silently go back to ignoring the second.
        _cp = _filing_couplings()
        check("filing couplings returns evidence AND problems", len(_cp), 2)
        check("filing couplings: evidence is a list", isinstance(_cp[0], list), True)
        check("filing couplings: problems is a list", isinstance(_cp[1], list), True)
        # The whole-TODO edges and the TNN §N shorthand are proven by driven runs
        # in this section's checkpoint: the chain moves from 17 to 30 with file
        # edges included, and stays 30 when a dependency is rewritten as
        # shorthand. The self-test loads fixture TODOs, which declare neither.
        # Normalisation of a bare `§N` into a full reference is proven by the
        # driven run in this section's checkpoint, against the real tree. The
        # self-test loads fixture TODOs, where those references do not exist.
        check("items sync writes the new count", _new.rstrip().endswith("11  |"), True)
        check("items sync leaves the ref untouched", "`D90 T01 §1`" in _new, True)
        check("items sync keeps the cell width", len(_new), len(_row))
        check("items sync leaves an already-correct row alone",
              _sync_items_cell(_row, 6), (_row, 6))
        check("items sync widens a number that outgrows the cell",
              _sync_items_cell("| [ ] | `D90 T01 §1` | d |1|", 100)[0].endswith("| 100 |"), True)
        check("items sync ignores a row with no items cell",
              _sync_items_cell("| [ ] | `D90 T01 §1` | no trailing number |", 4)[1], None)
        check(
            "PHASE_HEADING_RE accepts an em dash",
            bool(PHASE_HEADING_RE.match("### Phase 3 — Something")),
            True,
        )
        check(
            "PHASE_HEADING_RE accepts a double hyphen",
            bool(PHASE_HEADING_RE.match("### Phase 3 -- Something")),
            True,
        )

        # --- D00 T01 §21: the severity map, one fixture per class ------------
        # Two isolated domains so the deliberately-missing-INDEX case cannot
        # contaminate the classes that need a clean home. Co-emission note:
        # the empty §3 emits BOTH no-checklist-items and no-commit-item; the
        # probe covers the set.
        (root / "todo" / "91-severity").mkdir(parents=True)
        (root / "todo" / "91-severity" / "INDEX.md").write_text(
            "# 91-severity\n\n- [TODO-05](TODO-05-severity.md)\n- [TODO-06](TODO-06-super.md)\n"
            "- [TODO-10](TODO-10-partial-flip.md)\n",
            encoding="utf-8",
        )
        (root / "todo" / "91-severity" / "TODO-05-severity.md").write_text(
            """---
schema_version: 1
id: self-test-severity
domain: 91-severity
status: active
title: "TODO-05 -- severity fixtures"
track: Z1
---

# TODO-05 -- severity fixtures

See todo/91-severity/TODO-06-super.md for the superseded case.

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | No commit item | - |  [ ]   |
|   2   |   §2    | Partial flip in shipped | - |  [x]   |
|   3   |   §3    | Empty | - |  [ ]   |
|   4   |   §4    | Oversized | - |  [ ]   |
|   5   |   §5    | Deferral and resolution | - |  [ ]   |

## 1. No commit item

- [ ] Do the thing

**Test checkpoint:** run tests/AlphaTest.php.

## 2. Partial flip in shipped

- [x] Did it
- [ ] Never finished this one
- [x] Commit: `"selftest: partial"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §2 | fixture

## 3. Empty

**Test checkpoint:** run tests/AlphaTest.php.

## 4. Oversized

"""
            + "\n".join(f"- [ ] Item {i}" for i in range(1, 31))
            + """
- [ ] Commit: `"selftest: oversized"`

**Test checkpoint:** run tests/AlphaTest.php.

## 5. Deferral and resolution

- [ ] Do it
- [ ] Commit: `"selftest: deferral"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Deferred:** an ownerless deferral with no owner reference at all
> **Resolved:** 2026-01-02 | early closure -> XREF: §1 (item: "Do the thing") | closed by `abc1234`

Depends on T06 without a section: the bare-todo-ref shape.
""",
            encoding="utf-8",
        )
        (root / "todo" / "91-severity" / "TODO-06-super.md").write_text(
            """---
schema_version: 1
id: self-test-super
domain: 91-severity
status: superseded
title: "TODO-06 -- superseded without successor"
track: Z1
---

# TODO-06 -- superseded without successor

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Placeholder | - |  [ ]   |

## 1. Placeholder

- [ ] Thing (frozen marker below makes the check-not-frozen case)
- [ ] Commit: `"selftest: super"`

**Freeze check:** fixture golden outputs.

**Test checkpoint:** run tests/AlphaTest.php.
""",
            encoding="utf-8",
        )
        # --- D00 T04 §19: the partial-flip rule, one section per shape ----
        # Every XREF stays in-file: the one-sided rule skips same-file refs,
        # so these fixtures cannot drown in reciprocity fires. The §13/§14
        # and §15/§16 pairs are twins: identical item text, one exempt and
        # one failing, so a removed exemption breaks its case by construction.
        # D00 T04 §20 retargeted the §15/§16 twins to the failing shape:
        # below-stamp items fail as appended work, and only a `>`-quoted
        # stamp field still passes.
        (root / "todo" / "91-severity" / "TODO-10-partial-flip.md").write_text(
            """---
schema_version: 1
id: self-test-partial
domain: 91-severity
status: active
title: "TODO-10 -- partial-flip fixtures"
track: Z1
---

# TODO-10 -- partial-flip fixtures

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Plain open item | - |  [x]   |
|   2   |   §2    | Struck without marker | - |  [x]   |
|   3   |   §3    | Checkboxed XREF | - |  [x]   |
|   4   |   §4    | Commit excused | - |  [x]   |
|   5   |   §5    | Deferral, Depends owner | - |  [x]   |
|   6   |   §6    | Deferral, XREF owner | - |  [x]   |
|   7   |   §7    | Deferral, no owner | - |  [x]   |
|   8   |   §8    | Deferral, ghost owner | - |  [x]   |
|   9   |   §9    | Target, Depends back | §5 |  [ ]   |
|  10   |   §10   | Target, XREF back | - |  [ ]   |
|  11   |   §11   | Deferral, unlinked owner | - |  [x]   |
|  12   |   §12   | Target, unlinked | - |  [ ]   |
|  13   |   §13   | Fenced example | - |  [x]   |
|  14   |   §14   | Unfenced twin | - |  [x]   |
|  15   |   §15   | Appended work below stamp | - |  [x]   |
|  16   |   §16   | Stamp-field quote | - |  [x]   |
|  17   |   §17   | Commit without colon | - |  [x]   |
|  18   |   §18   | Deferral, mixed owners | - |  [x]   |
|  19   |   §19   | Target, mixed back | §18 |  [ ]   |
|  20   |   §20   | Deferral, XREF past header | - |  [x]   |
|  21   |   §21   | Two Commit items | - |  [x]   |
|  22   |   §22   | Commit not final | - |  [x]   |
|  23   |   §23   | Deferral, shipped owner, no proof | - |  [x]   |
|  24   |   §24   | Target, shipped, no proof | §23 |  [x]   |
|  25   |   §25   | Deferral, shipped owner, proof | - |  [x]   |
|  26   |   §26   | Target, shipped, with proof | §25 |  [x]   |
|  27   |   §27   | Deferral, item-silent target | - |  [x]   |
|  28   |   §28   | Target, item-silent | §27 |  [ ]   |
|  29   |   §29   | Deferral, untyped forward | - |  [x]   |
|  30   |   §30   | Target, typed-back | §29 |  [ ]   |
|  31   |   §31   | Open row with stamp | - |  [ ]   |
|  32   |   §32   | Deferral, XREF past fence | - |  [x]   |
|  33   |   §33   | Deferral, vague citation | - |  [x]   |
|  34   |   §34   | Target, substring only | §33 |  [ ]   |
|  35   |   §35   | Deferral, reordered citation | - |  [x]   |
|  36   |   §36   | Target, reordered words | §35 |  [ ]   |
|  37   |   §37   | Deferral, two debts, section-only proof | - |  [x]   |
|  38   |   §38   | Target, shipped, section-only proof | §37 |  [x]   |
|  39   |   §39   | Deferral, two debts, item proofs | - |  [x]   |
|  40   |   §40   | Target, shipped, item proofs | §39 |  [x]   |
|  41   |   §41   | Deferral, wrong-item proof | - |  [x]   |
|  42   |   §42   | Target, shipped, wrong-item proof | §41 |  [x]   |

## 1. Plain open item

- [x] Did it
- [ ] Never finished this one either
- [x] Commit: `"selftest: plain"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §1 | fixture

## 2. Struck without marker

- [x] Did it
- [ ] ~~Decided against, or so the strike claims~~
- [x] Commit: `"selftest: struck"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §2 | fixture

## 3. Checkboxed XREF

- [x] Did it
- [ ] -> XREF: §4 -- a cross-reference wearing a checkbox
- [x] Commit: `"selftest: xref-item"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §3 | fixture

## 4. Commit excused

- [x] Did it
- [ ] Commit: `"selftest: commit-excused"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §4 | fixture

## 5. Deferral, Depends owner

- [x] Did it
- [ ] ~~Handed to the owning section.~~ **Deferred 2026-01-01 to the section that owns it.**
  -> XREF: §9 (item: "Do the owned work") -- the owner
- [x] Commit: `"selftest: defer-depends"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §5 | fixture

## 6. Deferral, XREF owner

- [x] Did it
- [ ] ~~Handed to the owning section.~~ **Deferred 2026-01-01 to the section that owns it.**
  -> XREF: §10 (item: "Do the other owned work") -- the owner
- [x] Commit: `"selftest: defer-xref"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §6 | fixture

## 7. Deferral, no owner

- [x] Did it
- [ ] ~~Handed to nobody.~~ **Deferred 2026-01-01 to nobody in particular.**

- [x] Commit: `"selftest: defer-unowned"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §7 | fixture

## 8. Deferral, ghost owner

- [x] Did it
- [ ] ~~Handed to a ghost.~~ **Deferred 2026-01-01 to a section that does not exist.**
  -> XREF: §99 (item: "Do the ghost work") -- the owner
- [x] Commit: `"selftest: defer-ghost"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §8 | fixture

## 9. Target, Depends back

- [ ] Do the owned work
- [ ] Commit: `"selftest: target-depends"`

**Test checkpoint:** run tests/AlphaTest.php.

## 10. Target, XREF back

-> XREF: §6 -- acknowledges the hand-off from §6

- [ ] Do the other owned work
- [ ] Commit: `"selftest: target-xref"`

**Test checkpoint:** run tests/AlphaTest.php.

## 11. Deferral, unlinked owner

- [x] Did it
- [ ] ~~Handed nowhere.~~ **Deferred 2026-01-01 to a section that never acknowledged it.**
  -> XREF: §12 (item: "Do the unowned work") -- the owner
- [x] Commit: `"selftest: defer-unlinked"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §11 | fixture

## 12. Target, unlinked

- [ ] Do the unowned work
- [ ] Commit: `"selftest: target-unlinked"`

**Test checkpoint:** run tests/AlphaTest.php.

## 13. Fenced example

- [x] Did it
- [x] Commit: `"selftest: fenced"`

The quoted shape:

```
- [ ] Looks open but is quoted
```

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §13 | fixture

## 14. Unfenced twin

- [x] Did it
- [ ] Looks open but is quoted
- [x] Commit: `"selftest: unfenced"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §14 | fixture

## 15. Appended work below stamp

- [x] Did it
- [x] Commit: `"selftest: stamp-appended"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §15 | fixture
- [ ] Quoted below the stamp

## 16. Stamp-field quote

- [x] Did it
- [x] Commit: `"selftest: stamp-field"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §16 | fixture
> **Review:** round 1 quoted `- [ ] Quoted below the stamp` verbatim

## 17. Commit without colon

- [x] Did it
- [ ] Commit without the colon is not the bookkeeping shape
- [x] Commit: `"selftest: colon-boundary"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §17 | fixture

## 18. Deferral, mixed owners

- [x] Did it
- [ ] ~~Handed twice.~~ **Deferred 2026-01-01 to one live owner and one ghost.**
  -> XREF: §19 (item: "Do the mixed work") -- the live owner
  -> XREF: §99 (item: "Do the ghost work") -- the ghost
- [x] Commit: `"selftest: defer-mixed"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §18 | fixture

## 19. Target, mixed back

- [ ] Do the mixed work
- [ ] Commit: `"selftest: target-mixed"`

**Test checkpoint:** run tests/AlphaTest.php.

## 20. Deferral, XREF past header

- [x] Did it
- [ ] ~~Handed past a header.~~ **Deferred 2026-01-01 to an owner below a header.**
### A note between the item and the XREF
  -> XREF: §9 (item: "Do the owned work") -- past the header, not attached
- [x] Commit: `"selftest: defer-header"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §20 | fixture

## 21. Two Commit items

- [x] Did it
- [x] Commit: `"selftest: commit-first"`
- [x] Commit: `"selftest: commit-second"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §21 | fixture

## 22. Commit not final

- [x] Did it
- [x] Commit: `"selftest: commit-early"`
- [x] More work after the commit

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §22 | fixture

## 23. Deferral, shipped owner, no proof

- [x] Did it
- [ ] ~~Handed to a section that shipped.~~ **Deferred 2026-01-01 to the shipped owner.**
  -> XREF: §24 (item: "Do the shipped work") -- the owner
- [x] Commit: `"selftest: defer-shipped"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §23 | fixture

## 24. Target, shipped, no proof

- [x] Do the shipped work
- [x] Commit: `"selftest: target-shipped"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §24 | fixture

## 25. Deferral, shipped owner, proof

- [x] Did it
- [ ] ~~Handed to a section that shipped.~~ **Deferred 2026-01-01 to the shipped owner.**
  -> XREF: §26 (item: "Do the proven work") -- the owner
- [x] Commit: `"selftest: defer-proven"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §25 | fixture

## 26. Target, shipped, with proof

- [x] Do the proven work
- [x] Commit: `"selftest: target-proven"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §26 | fixture
> **Resolved:** 2026-01-02 | §25 debt done -> XREF: §25 (item: "Do the proven work") -- the deferred work shipped here

## 27. Deferral, item-silent target

- [x] Did it
- [ ] ~~Handed to a linked section.~~ **Deferred 2026-01-01 to a section that links back but carries no such item.**
  -> XREF: §28 (item: "Do the silent work") -- the owner
- [x] Commit: `"selftest: defer-silent"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §27 | fixture

## 28. Target, item-silent

- [ ] Do something unrelated
- [ ] Commit: `"selftest: target-silent"`

**Test checkpoint:** run tests/AlphaTest.php.

## 29. Deferral, untyped forward

- [x] Did it
- [ ] ~~Handed with a bare XREF.~~ **Deferred 2026-01-01 to a section named without its item.**
  -> XREF: §30 -- the owner, no item named
- [x] Commit: `"selftest: defer-untyped"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §29 | fixture

## 30. Target, typed-back

- [ ] Do the untyped work
- [ ] Commit: `"selftest: target-untyped"`

**Test checkpoint:** run tests/AlphaTest.php.

## 31. Open row with stamp

- [x] Did it
- [x] Commit: `"selftest: open-stamped"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §31 | fixture

## 32. Deferral, XREF past fence

- [x] Did it
- [ ] ~~Handed past a fence.~~ **Deferred 2026-01-01 to an owner past a fence.**
```
fenced code here
```
  -> XREF: §9 (item: "Do the owned work") -- past the fence, not attached
- [x] Commit: `"selftest: defer-fence"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §32 | fixture

## 33. Deferral, vague citation

- [x] Did it
- [ ] ~~Handed with one vague word.~~ **Deferred 2026-01-01 to a section carrying the word only inside another.**
  -> XREF: §34 (item: "net") -- the owner
- [x] Commit: `"selftest: defer-vague"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §33 | fixture

## 34. Target, substring only

- [ ] Do the network work
- [ ] Commit: `"selftest: target-vague"`

**Test checkpoint:** run tests/AlphaTest.php.

## 35. Deferral, reordered citation

- [x] Did it
- [ ] ~~Handed with shuffled words.~~ **Deferred 2026-01-01 to a section carrying the same words in another order.**
  -> XREF: §36 (item: "work the network") -- the owner
- [x] Commit: `"selftest: defer-reordered"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §35 | fixture

## 36. Target, reordered words

- [ ] Do the network work
- [ ] Commit: `"selftest: target-reordered"`

**Test checkpoint:** run tests/AlphaTest.php.

## 37. Deferral, two debts, section-only proof

- [x] Did it
- [ ] ~~Handed two debts to one owner.~~ **Deferred 2026-01-01, first debt.**
  -> XREF: §38 (item: "Do the first debt") -- the owner
- [ ] ~~Handed two debts to one owner.~~ **Deferred 2026-01-01, second debt.**
  -> XREF: §38 (item: "Do the second debt") -- the owner
- [x] Commit: `"selftest: defer-two-debts"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §37 | fixture

## 38. Target, shipped, section-only proof

- [x] Do the first debt
- [x] Do the second debt
- [x] Commit: `"selftest: target-two-debts"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §38 | fixture
> **Resolved:** 2026-01-02 | §37 debts done -> XREF: §37 -- the deferred work shipped here

## 39. Deferral, two debts, item proofs

- [x] Did it
- [ ] ~~Handed two debts to one owner.~~ **Deferred 2026-01-01, third debt.**
  -> XREF: §40 (item: "Do the third debt") -- the owner
- [ ] ~~Handed two debts to one owner.~~ **Deferred 2026-01-01, fourth debt.**
  -> XREF: §40 (item: "Do the fourth debt") -- the owner
- [x] Commit: `"selftest: defer-two-proofs"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §39 | fixture

## 40. Target, shipped, item proofs

- [x] Do the third debt
- [x] Do the fourth debt
- [x] Commit: `"selftest: target-two-proofs"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §40 | fixture
> **Resolved:** 2026-01-02 | third debt done -> XREF: §39 (item: "Do the third debt") -- shipped here
> **Resolved:** 2026-01-02 | fourth debt done -> XREF: §39 (item: "Do the fourth debt") -- shipped here

## 41. Deferral, wrong-item proof

- [x] Did it
- [ ] ~~Handed one debt to one owner.~~ **Deferred 2026-01-01 to the shipped owner.**
  -> XREF: §42 (item: "Do the claimed work") -- the owner
- [x] Commit: `"selftest: defer-wrong-item"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §41 | fixture

## 42. Target, shipped, wrong-item proof

- [x] Do the claimed work
- [x] Commit: `"selftest: target-wrong-item"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §42 | fixture
> **Resolved:** 2026-01-02 | claimed work done -> XREF: §41 (item: "Do the wrong work") -- shipped here
""",
            encoding="utf-8",
        )
        # An unindexed file in the ORIGINAL domain (which has no INDEX.md at
        # all -- absent INDEX means every file there flags, which the earlier
        # fixtures would drown in). Instead: a third domain with an INDEX
        # that omits its one file.
        (root / "todo" / "92-unindexed").mkdir(parents=True)
        (root / "todo" / "92-unindexed" / "INDEX.md").write_text(
            "# 92-unindexed\n\n(nothing listed)\n", encoding="utf-8"
        )
        (root / "todo" / "92-unindexed" / "TODO-07-orphan.md").write_text(
            """---
schema_version: 1
id: self-test-unindexed
domain: 92-unindexed
status: active
title: "TODO-07 -- not in INDEX"
track: Z1
---

# TODO-07 -- not in INDEX

Also carries a one-sided XREF: -> XREF: D90 T01 §1 -- alpha never points back.

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Placeholder | - |  [ ]   |

## 1. Placeholder

- [ ] Thing
- [ ] Commit: `"selftest: unindexed"`

**Test checkpoint:** run tests/AlphaTest.php.
""",
            encoding="utf-8",
        )
        # --- D00 T04 §21: evidence-citation fixtures ---------------------
        # Post-cutoff stamps (2026-09-21) fire on short forms and untagged
        # candidates; the 2026-09-20 twin stands as history; Deferred
        # pointer lines keep their XREF grammar; fenced transcript lines
        # never trip the findings scan.
        (root / "todo" / "91-severity" / "TODO-11-evidence-cite.md").write_text(
            """---
schema_version: 1
id: self-test-evidence
domain: 91-severity
status: active
title: "TODO-11 -- evidence-citation fixtures"
track: Z1
---

# TODO-11 -- evidence-citation fixtures

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Short in Verified | - |  [x]   |
|   2   |   §2    | Short in Review | - |  [x]   |
|   3   |   §3    | Clean full refs | - |  [x]   |
|   4   |   §4    | Pre-cutoff twin | - |  [x]   |
|   5   |   §5    | Untagged pair | - |  [x]   |
|   6   |   §6    | Tagged pair | - |  [x]   |
|   7   |   §7    | Single oid | - |  [x]   |
|   8   |   §8    | Findings short | - |  [x]   |
|   9   |   §9    | Deferred XREF | - |  [x]   |
|  10   |   §10   | XREF target | - |  [ ]   |
|  11   |   §11   | Range stamp pair | - |  [x]   |
|  12   |   §12   | Range twin | - |  [ ]   |
|  13   |   §13   | Dash range stamp | - |  [x]   |
|  14   |   §14   | Dash range twin | - |  [ ]   |

## 1. Short in Verified

- [x] Did it
- [x] Commit: `"selftest: ev1"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-09-21 | §1 | filed to §2 for the follow-up

## 2. Short in Review

- [x] Did it
- [x] Commit: `"selftest: ev2"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-09-21 | §2 | clean evidence D91 T11 §3
> **Review:** round 1, candidate `abc1234` -- advisory, see §3 notes

## 3. Clean full refs

- [x] Did it
- [x] Commit: `"selftest: ev3"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-09-21 | §3 | filed to D91 T11 §10 for the follow-up
> **Review:** round 1, candidate `abc1234`(round 1) `def5678`(round 2) -- approve

## 4. Pre-cutoff twin

- [x] Did it
- [x] Commit: `"selftest: ev4"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-09-20 | §4 | filed to §2 for the follow-up
> **Review:** round 1, candidate `abc1234` `def5678` -- approve, see §3 notes

## 5. Untagged pair

- [x] Did it
- [x] Commit: `"selftest: ev5"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-09-21 | §5 | clean evidence
> **Review:** round 2, candidate `abc1234` `def5678` -- approve

## 6. Tagged pair

- [x] Did it
- [x] Commit: `"selftest: ev6"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-09-21 | §6 | clean evidence
> **Review:** round 2, candidate `abc1234`(round 1) `def5678`(round 2) -- approve

## 7. Single oid

- [x] Did it
- [x] Commit: `"selftest: ev7"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-09-21 | §7 | clean evidence
> **Review:** round 1, candidate `abc1234` -- approve

## 8. Findings short

- [x] Did it
- [x] Commit: `"selftest: ev8"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-09-21 | §8 | clean evidence
> **Review:** round 1, candidate `abc1234` -- approve. Raw findings: docs/reviews/91-severity/D91-T11-s8.md

## 9. Deferred XREF

- [x] Did it
- [x] Commit: `"selftest: ev9"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-09-21 | §9 | clean evidence
> **Deferred:** leftover -> XREF: §10 -- needs the target first

## 10. XREF target

- [ ] Carry the leftover for §9
- [ ] Commit: `"selftest: evtarget"`

**Test checkpoint:** run tests/AlphaTest.php.

## 11. Range stamp pair

- [x] Did both
- [x] Commit: `"selftest: ev11"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-09-21 | §11, §12 | clean evidence

## 12. Range twin

- [ ] Twin half of the §11 range stamp
- [ ] Commit: `"selftest: ev12"`

**Test checkpoint:** run tests/AlphaTest.php.

## 13. Dash range stamp

- [x] Did both
- [x] Commit: `"selftest: ev13"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-09-21 | §13-§14 | clean evidence

## 14. Dash range twin

- [ ] Twin half of the §13 range stamp
- [ ] Commit: `"selftest: ev14"`

**Test checkpoint:** run tests/AlphaTest.php.
""",
            encoding="utf-8",
        )
        (root / "docs" / "reviews" / "91-severity").mkdir(parents=True)
        (root / "docs" / "reviews" / "91-severity" / "D91-T11-s8.md").write_text(
            """# Review -- D91 T11 §8, fixture

## Opus panel Round 1

Round 1 over `abc1234` (1 file). Cost 10tokens.

`adversarial` approve
`consistency` approve
`integration` approve
`record` approve

Unfenced prose citing §1 trips the findings scan.

```
Fenced transcript citing §1 never trips the scan.
```
""",
            encoding="utf-8",
        )
        # --- D00 T04 §24 item 18: role-correspondence fixtures --------
        # Post-cutoff stamps whose round tags resolve (§1), miss (§2:
        # round 3 of one recorded round, plus round zero), collide
        # (§3: two candidates sharing round 1), meet duplicated
        # records (§4: two headings claiming round 1), or meet an
        # all-caps suffix (§5: OPUS PANEL ROUND 2 claims 2).
        (root / "todo" / "91-severity" / "TODO-12-role-match.md").write_text(
            """---
schema_version: 1
id: self-test-role-match
domain: 91-severity
status: active
title: "TODO-12 -- role-correspondence fixtures"
track: Z1
---

# TODO-12 -- role-correspondence fixtures

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Matched tags | - |  [x]   |
|   2   |   §2    | Mistagged round | - |  [x]   |
|   3   |   §3    | Duplicate round | - |  [x]   |
|   4   |   §4    | Recorded duplicate | - |  [x]   |
|   5   |   §5    | Case-blind suffix | - |  [x]   |

## 1. Matched tags

- [x] Did it
- [x] Commit: `"selftest: ro1"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-09-21 | §1 | clean evidence
> **Review:** round 2, candidate `abc1234`(round 1) `def5678`(round 2) -- approve. Raw findings: docs/reviews/91-severity/D91-T12-s1.md

## 2. Mistagged round

- [x] Did it
- [x] Commit: `"selftest: ro2"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-09-21 | §2 | clean evidence
> **Review:** round 2, candidate `abc1234`(round 1) `def5678`(round 3) `9abc123`(round 0) -- approve. Raw findings: docs/reviews/91-severity/D91-T12-s2.md

## 3. Duplicate round

- [x] Did it
- [x] Commit: `"selftest: ro3"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-09-21 | §3 | clean evidence
> **Review:** round 2, candidate `abc1234`(round 1) `def5678`(round 1) -- approve. Raw findings: docs/reviews/91-severity/D91-T12-s1.md

## 4. Recorded duplicate

- [x] Did it
- [x] Commit: `"selftest: ro4"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-09-21 | §4 | clean evidence
> **Review:** round 2, candidate `abc1234`(round 1) -- approve. Raw findings: docs/reviews/91-severity/D91-T12-s4.md

## 5. Case-blind suffix

- [x] Did it
- [x] Commit: `"selftest: ro5"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-09-21 | §5 | clean evidence
> **Review:** round 2, candidate `abc1234`(round 1) `def5678`(round 2) -- approve. Raw findings: docs/reviews/91-severity/D91-T12-s5.md
""",
            encoding="utf-8",
        )
        (root / "docs" / "reviews" / "91-severity" / "D91-T12-s1.md").write_text(
            """# Review -- D91 T12 §1, fixture

## GPT panel Round 1

`adversarial` approve
`consistency` approve
`integration` approve
`record` approve

## Opus panel Round 2

`adversarial` approve
`consistency` approve
`integration` approve
`record` approve
""",
            encoding="utf-8",
        )
        (root / "docs" / "reviews" / "91-severity" / "D91-T12-s2.md").write_text(
            """# Review -- D91 T12 §2, fixture

## Opus panel Round 1

`adversarial` approve
`consistency` approve
`integration` approve
`record` approve
""",
            encoding="utf-8",
        )
        (root / "docs" / "reviews" / "91-severity" / "D91-T12-s4.md").write_text(
            """# Review -- D91 T12 §4, fixture

## GPT panel Round 1

`adversarial` approve
`consistency` approve
`integration` approve
`record` approve

## Opus panel Round 1

`adversarial` approve
`consistency` approve
`integration` approve
`record` approve
""",
            encoding="utf-8",
        )
        (root / "docs" / "reviews" / "91-severity" / "D91-T12-s5.md").write_text(
            """# Review -- D91 T12 §5, fixture

## OPUS PANEL ROUND 2

`adversarial` approve
`consistency` approve
`integration` approve
`record` approve
""",
            encoding="utf-8",
        )

        sev_buf = _io.StringIO()
        with _ctx.redirect_stdout(sev_buf), _ctx.redirect_stderr(sev_buf):
            sev_rc = cmd_validate(None)
        sev_out = sev_buf.getvalue()

        def sev_line(prefix: str, needle: str) -> bool:
            return any(
                line.startswith(prefix) and needle in line for line in sev_out.splitlines()
            )

        check("severity: superseded-no-successor is FATAL", sev_line("FATAL", "superseded_by is unset"), True)
        check("severity: no-commit-item is FATAL", sev_line("FATAL", "§1 has no '- [ ] Commit:'"), True)
        check("severity: partial-flip-shipped is FATAL", sev_line("FATAL", "carries an unticked item"), True)
        check("severity: no-checklist-items is FATAL (co-emits no-commit)", sev_line("FATAL", "§3 has no checklist items"), True)
        check("severity: over-30 stays WARN", sev_line("WARN", "31 checklist items"), True)
        check("severity: over-30 never FATAL", sev_line("FATAL", "31 checklist items"), False)
        check("severity: check-not-frozen is FATAL", sev_line("FATAL", "has a Freeze check but frontmatter"), True)
        check("severity: one-sided XREF is FATAL", sev_line("FATAL", "is one-sided"), True)
        check("severity: deferral-no-owner is FATAL", sev_line("FATAL", "deferral names no owner"), True)
        check("severity: resolved-early stays WARN", sev_line("WARN", "has not shipped it yet"), True)
        check("severity: missing-from-INDEX is FATAL", sev_line("FATAL", "not listed in todo/92-unindexed/INDEX.md"), True)
        check("severity: bare-todo-ref stays WARN", sev_line("WARN", "bare TODO reference without a section -- line"), True)
        check("severity: bare-todo-ref never FATAL", sev_line("FATAL", "bare TODO reference without a section"), False)
        check("severity: validate exits 1 on the fixture set", sev_rc, 1)
        # The ratchet layer: a WARN absent from the baseline is marked NEW.
        check("severity: a new WARN carries the ratchet marker", "WARN*" in sev_out, True)

        # --- D00 T04 §19: the partial-flip probes -------------------------
        # The tag anchors on the `§N is [x]` location shape, never on a
        # bare `§N`: quoted item text carries refs of its own (§3's
        # message quotes `§4`), and a bare match would cross-fire.
        def pf_fires(num: int, needle: str) -> bool:
            tag = f"§{num} is [x]"
            return any(
                line.startswith("FATAL")
                and "TODO-10-partial-flip.md" in line
                and tag in line
                and needle in line
                for line in sev_out.splitlines()
            )

        def pf_silent(num: int) -> bool:
            tag = f"§{num} is [x]"
            return not any(
                line.startswith("FATAL")
                and "TODO-10-partial-flip.md" in line
                and tag in line
                for line in sev_out.splitlines()
            )

        check("partial-flip: plain open item fails", pf_fires(1, "Never finished this one either"), True)
        check("partial-flip: struck item without marker fails", pf_fires(2, "no Deferred marker"), True)
        check("partial-flip: checkboxed XREF fails", pf_fires(3, "cross-reference wearing a checkbox"), True)
        check("partial-flip: Commit line passes", pf_silent(4), True)
        check("partial-flip: deferral with Depends owner passes", pf_silent(5), True)
        check("partial-flip: deferral with XREF owner passes", pf_silent(6), True)
        check("partial-flip: deferral naming no owner fails", pf_fires(7, "naming no owner"), True)
        check("partial-flip: deferral with ghost owner fails", pf_fires(8, "resolves to nothing"), True)
        check("partial-flip: deferral with unlinked owner fails", pf_fires(11, "no back-pointer"), True)
        check("partial-flip: fenced example passes", pf_silent(13), True)
        check("partial-flip: unfenced twin fails", pf_fires(14, "Looks open but is quoted"), True)
        check("partial-flip: appended work below stamp fails", pf_fires(15, "Quoted below the stamp"), True)
        check("partial-flip: stamp-field quote passes", pf_silent(16), True)
        check("partial-flip: Commit without colon fails", pf_fires(17, "not the bookkeeping shape"), True)
        check("partial-flip: mixed owners fail on the ghost", pf_fires(18, "resolves to nothing"), True)
        check("partial-flip: XREF past a header is unattached", pf_fires(20, "naming no owner"), True)
        check("partial-flip: two Commit items fail", pf_fires(21, "carries 2 Commit items"), True)
        check("partial-flip: non-final Commit fails", pf_fires(22, "not the final checklist item"), True)
        check("partial-flip: shipped owner without proof fails", pf_fires(23, "without recording the debt done"), True)
        check("partial-flip: shipped owner with proof passes", pf_silent(25), True)
        check("partial-flip: two-debt section-only proof fails", pf_fires(37, "on its Resolved line"), True)
        check("partial-flip: two-debt item proofs pass", pf_silent(39), True)
        check("partial-flip: wrong-item proof fails", pf_fires(41, "not the deferred item"), True)
        check("partial-flip: item-silent target fails", pf_fires(27, "carries no such item"), True)
        check("partial-flip: untyped forward fails", pf_fires(29, "names no item"), True)
        check("partial-flip: XREF past a fence is unattached", pf_fires(32, "naming no owner"), True)
        check("partial-flip: vague citation fails", pf_fires(33, "carries no such item"), True)
        check("partial-flip: reordered citation fails", pf_fires(35, "carries no such item"), True)
        check("open-stamped row fails",
              any(line.startswith("FATAL") and "TODO-10-partial-flip.md" in line
                  and "§31 is [ ]" in line and "stamp covers it" in line
                  for line in sev_out.splitlines()), True)

        # --- D00 T04 §21: evidence-citation rules ----------------------
        # Needles scope to this file's sections and the rule's own
        # message: panel and marker rules fire on these young stamps
        # too, and their noise must not read as ours.
        def ev_fires(num: int, needle: str) -> bool:
            tag = f"§{num} "
            return any(
                line.startswith("FATAL")
                and "TODO-11-evidence-cite.md" in line
                and tag in line
                and needle in line
                for line in sev_out.splitlines()
            )

        def ev_silent(num: int) -> bool:
            tag = f"§{num} "
            return not any(
                line.startswith("FATAL")
                and "TODO-11-evidence-cite.md" in line
                and tag in line
                and ("short form" in line or "untagged" in line)
                for line in sev_out.splitlines()
            )

        check("evidence-cite: short in Verified fails",
              ev_fires(1, "Verified cites short form §2"), True)
        check("evidence-cite: short in Review fails",
              ev_fires(2, "Review cites short form §3"), True)
        check("evidence-cite: clean full refs pass", ev_silent(3), True)
        check("evidence-cite: pre-cutoff twin stands", ev_silent(4), True)
        check("evidence-cite: untagged pair fails",
              ev_fires(5, "untagged candidate abc1234")
              and ev_fires(5, "untagged candidate def5678"), True)
        check("evidence-cite: tagged pair passes", ev_silent(6), True)
        check("evidence-cite: single oid passes", ev_silent(7), True)
        check("evidence-cite: findings short fails",
              any(line.startswith("FATAL")
                  and "D91-T11-s8.md:12" in line and "short form §1" in line
                  for line in sev_out.splitlines()), True)
        check("evidence-cite: fenced short silent",
              not any(line.startswith("FATAL") and "D91-T11-s8.md:15" in line
                      for line in sev_out.splitlines()), True)
        check("evidence-cite: Deferred XREF keeps its grammar", ev_silent(9), True)
        check("evidence-cite: range coverage pair silent",
              ev_silent(11) and ev_silent(12), True)
        check("evidence-cite: dash range coverage silent",
              ev_silent(13) and ev_silent(14), True)

        # --- D00 T04 §24 item 18: role correspondence ------------------
        def ro_fires(num: int, needle: str) -> bool:
            tag = f"§{num} "
            return any(
                line.startswith("FATAL")
                and "TODO-12-role-match.md" in line
                and tag in line
                and needle in line
                for line in sev_out.splitlines()
            )

        def ro_silent(num: int) -> bool:
            tag = f"§{num} "
            return not any(
                line.startswith("FATAL")
                and "TODO-12-role-match.md" in line
                and tag in line
                and ("matching no recorded panel round" in line
                     or "one round reviews one candidate" in line)
                for line in sev_out.splitlines()
            )

        check("role-match: matched tags pass", ro_silent(1), True)
        check("role-match: mistagged round fails",
              ro_fires(2, "tags round 3 on def5678, matching no recorded panel round (1 recorded)"), True)
        check("role-match: round zero fails",
              ro_fires(2, "tags round 0 on 9abc123, matching no recorded panel round (1 recorded)"), True)
        check("role-match: duplicate round fails",
              ro_fires(3, "tags round 1 on 2 candidates (abc1234, def5678), one round reviews one candidate"), True)
        check("role-match: duplicated rounds skip correspondence",
              not any(line.startswith("FATAL") and "TODO-12-role-match.md" in line
                      and "§3 " in line and "matching no recorded" in line
                      for line in sev_out.splitlines()), True)
        # Panel round 2 F8: two headings claiming round 1 fail naming
        # the recorded duplicate (and correspondence skips, one fault
        # owning one defect); an all-caps ROUND 2 suffix claims 2, so
        # the round-1 tag misses while the round-2 tag matches.
        check("role-match: recorded duplicate fails",
              ro_fires(4, "findings record round(s) 1 twice (2 panel headings), rounds run once"), True)
        check("role-match: recorded duplicate skips correspondence",
              not any(line.startswith("FATAL") and "TODO-12-role-match.md" in line
                      and "§4 " in line and "matching no recorded" in line
                      for line in sev_out.splitlines()), True)
        check("role-match: all-caps suffix claims its round",
              ro_fires(5, "tags round 1 on abc1234, matching no recorded panel round (1 recorded)"), True)
        check("role-match: all-caps round tag matches",
              not any(line.startswith("FATAL") and "TODO-12-role-match.md" in line
                      and "§5 " in line and "tags round 2 on def5678" in line
                      for line in sev_out.splitlines()), True)

        # --- D00 T04 §20: the disposition report ----------------------
        rep_buf = _io.StringIO()
        with _ctx.redirect_stdout(rep_buf), _ctx.redirect_stderr(rep_buf):
            rep_rc = cmd_validate(argparse.Namespace(report_shipped_items=True))
        rep_out = rep_buf.getvalue()
        rep_lines = rep_out.splitlines()
        check("report-shipped-items: exit 0", rep_rc, 0)
        check("report-shipped-items: plain open fails",
              any("[FAIL]" in line and "Never finished this one either" in line
                  for line in rep_lines), True)
        check("report-shipped-items: non-repo Commit unverified",
              any("[UNVERIFIED Commit]" in line and "selftest: commit-excused" in line
                  for line in rep_lines), True)
        check("report-shipped-items: deferral exempt with ack",
              any("[EXEMPT deferral]" in line and "Do the owned work" in line
                  and "owner open" in line for line in rep_lines), True)
        check("report-shipped-items: fenced exempt",
              any("[EXEMPT fenced]" in line and "Looks open but is quoted" in line
                  for line in rep_lines), True)
        check("report-shipped-items: below-stamp fails",
              any("[FAIL]" in line and "Quoted below the stamp" in line
                  for line in rep_lines), True)
        check("report-shipped-items: cardinality noted",
              any("[FAIL shape]" in line and "2 Commit items" in line
                  for line in rep_lines), True)
        check("report-shipped-items: quiet sections silent",
              not any(line == "todo/91-severity/TODO-10-partial-flip.md §16:"
                      for line in rep_lines), True)
        check("report-shipped-items: summary shape",
              bool(re.search(r"^shipped items: \d+ Commit, \d+ deferral, \d+ fenced, "
                             r"\d+ unverified, \d+ failures$", rep_out, re.MULTILINE)), True)
        check("checklist_state: open reads False", checklist_state("- [ ] x"), False)
        check("checklist_state: ticked reads True", checklist_state("- [x] x"), True)
        check("checklist_state: uppercase X reads open", checklist_state("- [X] x"), False)
        check("checklist_state: prose reads None", checklist_state("just prose"), None)

        # --- D00 T04 §20: the Commit history binding -------------------
        # The fixture tree sits outside any repo, so its §4 Commit line
        # draws the unreadable warning, never a FATAL.
        check("partial-flip: unreadable history warns, not fatals",
              any(line.startswith("WARN") and "TODO-10-partial-flip.md" in line
                  and "§4" in line and "cannot be read" in line
                  for line in sev_out.splitlines()), True)
        # Bound and unbound legs need a real repo: init one, commit the
        # bound subject with a section suffix (the prefix leg), and
        # validate a two-section tree against it.
        brepo = Path(tempfile.mkdtemp(prefix="todo-graph-commitbind-"))
        try:
            (brepo / "todo" / "90-bind").mkdir(parents=True)
            (brepo / "skills").mkdir(exist_ok=True)
            (brepo / "todo" / "90-bind" / "INDEX.md").write_text(
                "# 90-bind\n\n- [TODO-01](TODO-01-bind.md)\n", encoding="utf-8")
            (brepo / "todo" / "90-bind" / "TODO-01-bind.md").write_text(
                """---
schema_version: 1
id: self-test-commitbind
domain: 90-bind
status: active
title: "TODO-01 -- commit binding"
track: Z1
---

# TODO-01 -- commit binding

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Bound prefix | - |  [x]   |
|   2   |   §2    | Never committed | - |  [x]   |
|   3   |   §3    | Ticked bound | - |  [x]   |
|   4   |   §4    | Ticked thin air | - |  [x]   |
|   5   |   §5    | Duplicate binds right | - |  [x]   |
|   6   |   §6    | Duplicate short fails | - |  [x]   |

## 1. Bound prefix

- [x] Did it
- [ ] Commit: `"workspace: bound work"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §1 | fixture

## 2. Never committed

- [x] Did it
- [ ] Commit: `"workspace: never committed anywhere"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §2 | fixture

## 3. Ticked bound

- [x] Did it
- [x] Commit: `"workspace: bound work"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §3 | fixture

## 4. Ticked thin air

- [x] Did it
- [x] Commit: `"workspace: quoted thin air"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §4 | fixture

## 5. Duplicate binds right

- [x] Did it
- [ ] Commit: `"workspace: dup subject (extended)"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §5 | fixture

## 6. Duplicate short fails

- [x] Did it
- [ ] Commit: `"workspace: dup subject"`

**Test checkpoint:** run tests/AlphaTest.php.

> **Verified:** 2026-01-01 | §6 | fixture
""",
                encoding="utf-8",
            )
            subprocess.run(["git", "init"], cwd=brepo, capture_output=True,
                           text=True, timeout=60)
            bind_rel = Path("todo") / "90-bind" / "TODO-01-bind.md"
            subprocess.run(["git", "add", bind_rel.as_posix()], cwd=brepo,
                           capture_output=True, text=True, timeout=60)
            subprocess.run(["git", "-c", "user.name=t", "-c", "user.email=t@t",
                            "commit", "-m",
                            "workspace: bound work (D00 T99 §1)"],
                           cwd=brepo, capture_output=True, text=True, timeout=60)
            # Two more commits sharing a subject prefix: the duplicate
            # fixture (§§5-6). Both touch the TODO file, so the longer
            # quote binds by subject, not by touch luck.
            for subject in ("workspace: dup subject",
                            "workspace: dup subject (extended)"):
                with (brepo / bind_rel).open("a", encoding="utf-8") as fh:
                    fh.write("\n")
                subprocess.run(["git", "-c", "user.name=t",
                                "-c", "user.email=t@t",
                                "commit", "-am", subject],
                               cwd=brepo, capture_output=True, text=True,
                               timeout=60)
            saved_bind = (TODO_DIR, PLAN, SKILLS_DIR)
            TODO_DIR, PLAN, SKILLS_DIR = (brepo / "todo",
                                          brepo / "todo" / "implementation-plan.md",
                                          brepo / "skills")
            try:
                bind_buf = _io.StringIO()
                with _ctx.redirect_stdout(bind_buf), _ctx.redirect_stderr(bind_buf):
                    cmd_validate(None)
            finally:
                TODO_DIR, PLAN, SKILLS_DIR = saved_bind
            bind_out = bind_buf.getvalue()
            check("partial-flip: bound prefix passes",
                  not any(line.startswith("FATAL") and "§1 is [x]" in line
                          for line in bind_out.splitlines()), True)
            check("partial-flip: unbound Commit fails",
                  any(line.startswith("FATAL") and "TODO-01-bind.md" in line
                      and "§2 is [x]" in line and "bound to no commit" in line
                      for line in bind_out.splitlines()), True)
            check("partial-flip: ticked bound passes",
                  not any(line.startswith("FATAL") and "§3 is [x]" in line
                          for line in bind_out.splitlines()), True)
            check("partial-flip: ticked thin air fails",
                  any(line.startswith("FATAL") and "TODO-01-bind.md" in line
                      and "§4 is [x]" in line and "quoting thin air" in line
                      for line in bind_out.splitlines()), True)
            check("partial-flip: duplicate binds right",
                  not any(line.startswith("FATAL") and "§5 is [x]" in line
                          for line in bind_out.splitlines()), True)
            check("partial-flip: duplicate short fails ambiguous",
                  any(line.startswith("FATAL") and "TODO-01-bind.md" in line
                      and "§6 is [x]" in line and "matching several commits" in line
                      for line in bind_out.splitlines()), True)
            # Unreadable history on ticked lines (self-review fix 3): silent
            # only where verification is impossible (no .git at all),
            # loud where a repo exists but git cannot read it. Copy
            # the bound tree twice: one bare of .git, one with an
            # empty .git git refuses.
            soft = Path(tempfile.mkdtemp(prefix="todo-graph-unreadable-soft-"))
            hard = Path(tempfile.mkdtemp(prefix="todo-graph-unreadable-hard-"))
            try:
                shutil.copytree(brepo / "todo", soft / "todo")
                (soft / "skills").mkdir(exist_ok=True)
                shutil.copytree(brepo / "todo", hard / "todo")
                (hard / "skills").mkdir(exist_ok=True)
                (hard / ".git").mkdir()
                saved_soft = (TODO_DIR, PLAN, SKILLS_DIR)
                TODO_DIR, PLAN, SKILLS_DIR = (soft / "todo",
                                              soft / "todo" / "implementation-plan.md",
                                              soft / "skills")
                try:
                    soft_buf = _io.StringIO()
                    with _ctx.redirect_stdout(soft_buf), _ctx.redirect_stderr(soft_buf):
                        cmd_validate(None)
                finally:
                    TODO_DIR, PLAN, SKILLS_DIR = saved_soft
                soft_out = soft_buf.getvalue()
                check("partial-flip: ticked unverified silent without .git",
                      not any((line.startswith("FATAL") or line.startswith("WARN"))
                              and "TODO-01-bind.md" in line
                              and "§4 is [x]" in line
                              for line in soft_out.splitlines()), True)
                saved_hard = (TODO_DIR, PLAN, SKILLS_DIR)
                TODO_DIR, PLAN, SKILLS_DIR = (hard / "todo",
                                              hard / "todo" / "implementation-plan.md",
                                              hard / "skills")
                try:
                    hard_buf = _io.StringIO()
                    with _ctx.redirect_stdout(hard_buf), _ctx.redirect_stderr(hard_buf):
                        cmd_validate(None)
                finally:
                    TODO_DIR, PLAN, SKILLS_DIR = saved_hard
                hard_out = hard_buf.getvalue()
                check("partial-flip: ticked unverified fails with broken .git",
                      any(line.startswith("WARN") and "TODO-01-bind.md" in line
                          and "§4 is [x]" in line and "history unreadable" in line
                          for line in hard_out.splitlines()), True)
            finally:
                shutil.rmtree(soft, ignore_errors=True)
                shutil.rmtree(hard, ignore_errors=True)
        finally:
            shutil.rmtree(brepo, ignore_errors=True)

        # The partial-flip fixtures fire FATAL by design: remove them now so
        # the frozen, ratchet, sync, and plan-health legs below read the tree
        # they expect. (The ratchet leg repeats this for the older fixtures.)
        (root / "todo" / "91-severity" / "TODO-10-partial-flip.md").unlink()

        # frozen-no-freeze-check needs frozen: true with NO check anywhere --
        # its own file, since TODO-06 carries the inverse case.
        (root / "todo" / "91-severity" / "TODO-08-frozen.md").write_text(
            """---
schema_version: 1
id: self-test-frozen
domain: 91-severity
status: active
title: "TODO-08 -- frozen without check"
frozen: true
track: Z1
---

# TODO-08 -- frozen without check

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Placeholder | - |  [ ]   |

## 1. Placeholder

- [ ] Thing
- [ ] Commit: `"selftest: frozen"`

**Test checkpoint:** run tests/AlphaTest.php.
""",
            encoding="utf-8",
        )
        (root / "todo" / "91-severity" / "INDEX.md").write_text(
            "# 91-severity\n\n- [TODO-05](TODO-05-severity.md)\n- [TODO-06](TODO-06-super.md)\n- [TODO-08](TODO-08-frozen.md)\n",
            encoding="utf-8",
        )
        sev_buf2 = _io.StringIO()
        with _ctx.redirect_stdout(sev_buf2), _ctx.redirect_stderr(sev_buf2):
            cmd_validate(None)
        check(
            "severity: frozen-no-freeze-check is FATAL",
            any(
                line.startswith("FATAL") and "frozen: true but no section carries" in line
                for line in sev_buf2.getvalue().splitlines()
            ),
            True,
        )

        # --- the ratchet's two directions on a WARN-only fixture tree --------
        # Remove the FATAL-carrying fixtures so only warn classes remain
        # (over-30 is the clean single-warn shape; resolved-early and
        # bare-todo-ref stay in TODO-05 beside their fatal siblings),
        # then prove: NEW warn = exit 1 with the WARN* marker; the SAME warn
        # baselined = exit 0. WARNING_BASELINE is rebound like TODO_DIR --
        # the live baseline must never absorb fixture keys.
        for f in ("TODO-05-severity.md", "TODO-06-super.md", "TODO-08-frozen.md",
                  "TODO-11-evidence-cite.md", "TODO-12-role-match.md"):
            (root / "todo" / "91-severity" / f).unlink()
        (root / "docs" / "reviews" / "91-severity" / "D91-T11-s8.md").unlink()
        (root / "docs" / "reviews" / "91-severity" / "D91-T12-s1.md").unlink()
        (root / "docs" / "reviews" / "91-severity" / "D91-T12-s2.md").unlink()
        (root / "docs" / "reviews" / "91-severity" / "D91-T12-s4.md").unlink()
        (root / "docs" / "reviews" / "91-severity" / "D91-T12-s5.md").unlink()
        (root / "todo" / "91-severity" / "INDEX.md").write_text(
            "# 91-severity\n\n- [TODO-09](TODO-09-warn-only.md)\n", encoding="utf-8"
        )
        (root / "todo" / "92-unindexed" / "TODO-07-orphan.md").unlink()
        (root / "todo" / "91-severity" / "TODO-09-warn-only.md").write_text(
            """---
schema_version: 1
id: self-test-warn-only
domain: 91-severity
status: active
title: "TODO-09 -- a single ratcheted warning"
track: Z1
---

# TODO-09 -- a single ratcheted warning

An oversized section: the clean single-WARN shape (over-30-items).

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Placeholder | - |  [ ]   |

## 1. Placeholder

"""
            + "\n".join(f"- [ ] Item {i}" for i in range(1, 32))
            + """
- [ ] Commit: `"selftest: warn only"`

**Test checkpoint:** run tests/AlphaTest.php.
""",
            encoding="utf-8",
        )
        # The earlier phases' fixtures carry FATALs (open Fidelity gaps, a
        # deliberately missing 90-selftest INDEX); a ratchet exit-code proof
        # needs a genuinely warn-only tree, so clear them.
        import shutil as _sh

        _sh.rmtree(root / "todo" / "90-selftest")
        global WARNING_BASELINE  # noqa: PLW0603 -- rebinding is the point
        saved_baseline = WARNING_BASELINE
        WARNING_BASELINE = root / "warning-baseline"
        # An EMPTY baseline file, mirroring the live zero-entry one: absent
        # file = ratchet unarmed, which is not the live contract.
        WARNING_BASELINE.write_text("# empty fixture baseline\n", encoding="utf-8")
        try:
            new_buf = _io.StringIO()
            with _ctx.redirect_stdout(new_buf), _ctx.redirect_stderr(new_buf):
                new_rc = cmd_validate(None)
            check("ratchet: a NEW warn-only tree exits 1", new_rc, 1)
            check("ratchet: the new warning is marked WARN*", "WARN*" in new_buf.getvalue(), True)

            class _AcceptArgs:
                accept = True
                acked = False

            with _ctx.redirect_stdout(_io.StringIO()), _ctx.redirect_stderr(_io.StringIO()):
                cmd_warnings(_AcceptArgs())
            base_buf = _io.StringIO()
            with _ctx.redirect_stdout(base_buf), _ctx.redirect_stderr(base_buf):
                base_rc = cmd_validate(None)
            check("ratchet: the SAME warning baselined exits 0", base_rc, 0)
            check("ratchet: baselined output carries plain WARN, not WARN*", "WARN*" in base_buf.getvalue(), False)
        finally:
            WARNING_BASELINE = saved_baseline

        # --- the Moved marker (writers-and-reviewers §2) ---------------------
        # A section worked outside the tree keeps its row and its edges and is
        # excluded from ready, from plan/--sync, and from the progress totals;
        # validate is clean with the marker and FATAL when it names no file.
        global PROGRESS_JSON, OPERATOR_JSON  # noqa: PLW0603 -- the sync writes them
        saved_json = (PROGRESS_JSON, OPERATOR_JSON)
        (root / "docs" / "plans").mkdir(parents=True, exist_ok=True)
        moved_file = root / "docs" / "plans" / "fixture-plan.md"
        moved_file.write_text("# fixture plan\n", encoding="utf-8")
        (root / "todo" / "93-moved").mkdir(parents=True, exist_ok=True)
        (root / "todo" / "93-moved" / "INDEX.md").write_text(
            "# 93-moved\n\n- [TODO-05](TODO-05-moved.md)\n", encoding="utf-8"
        )
        (root / "todo" / "93-moved" / "TODO-05-moved.md").write_text(
            SELF_TEST_TODO_MOVED, encoding="utf-8"
        )
        plan_m = root / "todo" / "plan-moved.md"
        plan_m.write_text(SELF_TEST_PLAN_MOVED, encoding="utf-8")
        try:
            PLAN = plan_m
            PROGRESS_JSON = root / "build" / "progress.json"
            OPERATOR_JSON = root / "build" / "operator.json"
            todos_m = load_todos()
            tm = next((t for t in todos_m if t.number == "05"), None)
            check("moved fixture parsed", tm is not None, True)
            if tm is None:
                raise RuntimeError("moved fixture did not parse")
            check("Moved: marker parsed onto its section", tm.sections[1].moved.startswith("2026-09-05 to docs/plans/fixture-plan.md"), True)
            check("moved_target reads the path out of the body", moved_target(tm.sections[1].moved), "docs/plans/fixture-plan.md")
            check("moved_target: no path is empty", moved_target("2026-09-05 somewhere else"), "")
            check("the neighbour carries no marker", tm.sections[2].moved, "")
            check("the moved section keeps its row", tm.sections[1].has_row, True)
            check("exit 5 -- moved", resolve_exit_code("D93 T05 §1", todos_m), 5)
            check("a dependency on a moved section is met", resolve_exit_code("D93 T05 §2", todos_m), 0)
            check("plan state omits the moved section", "D93 T05 §1" in _plan_state(todos_m), False)
            check("plan state keeps the neighbour", _plan_state(todos_m).get("D93 T05 §2"), " ")
            check("_moved_by_ref names it", _moved_by_ref(todos_m).get("D93 T05 §1", "").startswith("2026-09-05"), True)
            qbuf = _io.StringIO()
            with _ctx.redirect_stdout(qbuf), _ctx.redirect_stderr(_io.StringIO()):
                cmd_query(argparse.Namespace(what="ready", all=False))
            qout = qbuf.getvalue()
            check("query ready excludes the moved section", "§1  Moved thing" in qout, False)
            check("query ready lists its dependent as ready", "§2  Depends on the moved thing" in qout, True)
            qbuf = _io.StringIO()
            with _ctx.redirect_stdout(qbuf), _ctx.redirect_stderr(_io.StringIO()):
                cmd_query(argparse.Namespace(what="blocked", all=False))
            check("query blocked excludes the moved section", "Moved thing" in qbuf.getvalue(), False)
            sbuf = _io.StringIO()
            with _ctx.redirect_stdout(sbuf), _ctx.redirect_stderr(_io.StringIO()):
                cmd_query(argparse.Namespace(what="stats", all=False))
            check("query stats counts the moved section on its own line", "  moved          1" in sbuf.getvalue(), True)
            fbuf = _io.StringIO()
            with _ctx.redirect_stdout(fbuf), _ctx.redirect_stderr(_io.StringIO()):
                cmd_query(argparse.Namespace(what="findings", all=True))
            check("query findings skips a struck item even when it carries a finding verb", "by a fixture" in fbuf.getvalue(), False)
            # plan: --check refuses the row, --sync replaces it with one Moved line, idempotently.
            with _ctx.redirect_stdout(_io.StringIO()), _ctx.redirect_stderr(_io.StringIO()):
                rc_before = cmd_plan(argparse.Namespace(check=True))
                rc_sync = cmd_plan(argparse.Namespace(check=False))
            check("plan --check refuses a row for a moved section", rc_before, 1)
            check("plan --sync succeeds with a moved row", rc_sync, 0)
            synced = plan_m.read_text(encoding="utf-8")
            moved_lines = [l for l in synced.splitlines() if PLAN_MOVED_RE.match(l)]
            check("sync removed the moved row", "`D93 T05 §1`" in "\n".join(l for l in synced.splitlines() if PLAN_ROW_RE.match(l)), False)
            check("sync kept the neighbour row", "| [ ] | `D93 T05 §2` |" in synced, True)
            check("sync wrote exactly one Moved line", len(moved_lines), 1)
            check("the Moved line names the section and the file", moved_lines[0].startswith("> **Moved:** `D93 T05 §1` -- 2026-09-05 to docs/plans/fixture-plan.md") if moved_lines else False, True)
            synced_lines = synced.splitlines()
            at = next((i for i, l in enumerate(synced_lines) if PLAN_MOVED_RE.match(l)), -1)
            check(
                "the Moved line sits after the table, blank-line separated",
                at > 1 and synced_lines[at - 1] == "" and synced_lines[at - 2].startswith("|") and synced_lines[at + 1] == "",
                True,
            )
            check("sync's progress summary counts one row", "**0 of 2 sections complete (0%).**" in synced, True)
            with _ctx.redirect_stdout(_io.StringIO()), _ctx.redirect_stderr(_io.StringIO()):
                rc_after = cmd_plan(argparse.Namespace(check=True))
                cmd_plan(argparse.Namespace(check=False))
            check("plan --check is clean after the sync", rc_after, 0)
            check("a second sync changes nothing", plan_m.read_text(encoding="utf-8"), synced)
            prog = build_progress(todos_m)
            check("progress: the phase counts only the neighbour", (prog["phases"][0]["total"], prog["phases"][0]["done"]), (1, 0))
            check("progress: the moved section is not a phase row", any(r["ref"] == "D93 T05 §1" for ph in prog["phases"] for r in ph["sections"]), False)
            check("progress: stats count the moved section on its own key, not as open", (prog["stats"]["moved"], prog["stats"]["open"] + prog["stats"]["in_progress"] + prog["stats"]["done"] + prog["stats"]["moved"] == prog["stats"]["sections"]), (1, True))
            # a stale Moved line (its section no longer moved) is dropped by --sync
            plan_m.write_text(synced.replace("`D93 T05 §1`", "`D93 T05 §2`"), encoding="utf-8")
            with _ctx.redirect_stdout(_io.StringIO()), _ctx.redirect_stderr(_io.StringIO()):
                rc_stale = cmd_plan(argparse.Namespace(check=True))
                cmd_plan(argparse.Namespace(check=False))
            check("plan --check refuses a Moved line for an unmoved section", rc_stale, 1)
            check("plan --sync drops the stale Moved line", "> **Moved:** `D93 T05 §2`" in plan_m.read_text(encoding="utf-8"), False)
            # validate: clean with the marker, FATAL when the file it names is gone
            vbuf = _io.StringIO()
            with _ctx.redirect_stdout(vbuf), _ctx.redirect_stderr(_io.StringIO()):
                cmd_validate(None)
            check("validate: a Moved marker naming an existing file is not flagged", "moved-target-missing" in vbuf.getvalue() or "carries a Moved: marker" in vbuf.getvalue(), False)
            moved_file.unlink()
            vbuf = _io.StringIO()
            with _ctx.redirect_stdout(vbuf), _ctx.redirect_stderr(_io.StringIO()):
                cmd_validate(None)
            check(
                "validate: a Moved marker naming a missing file is FATAL",
                any(l.startswith("FATAL") and "TODO-05-moved.md" in l and "carries a Moved: marker" in l for l in vbuf.getvalue().splitlines()),
                True,
            )
        finally:
            PLAN = plan
            PROGRESS_JSON, OPERATOR_JSON = saved_json
            _sh.rmtree(root / "todo" / "93-moved")
            plan_m.unlink()

        # --- README parity: the table IS the map, mechanically ---------------
        readme = (REPO / "todo" / "README.md").read_text(encoding="utf-8")
        table_rows = re.findall(
            r"^\|\s*`([a-z0-9-]+)`\s*\|\s*(FATAL|WARN)\s*\|", readme, re.M
        )
        # Row-for-row (review 2026-08-28): an ORDERED comparison, so a
        # duplicate or reordered README row cannot hide behind a dict.
        check(
            "README severity table matches SEVERITY_MAP row-for-row, in order",
            [(cls, sev.lower()) for cls, sev in table_rows],
            [(cls, sev) for cls, sev in SEVERITY_MAP.items()],
        )
        check(
            "README severity table has no duplicate class rows",
            len({cls for cls, _ in table_rows}),
            len(table_rows),
        )
        check(
            "README's deliberately-left-open note is retired",
            "deliberately left open" in readme,
            False,
        )

        # --- review-record units ------------------------------------------------
        check(
            "run-id shape rejects -r0 and -r01, accepts -r1",
            (
                RUN_ID_SHAPE_RE.match("20260920-D90-T07-S4-gpt-r0") is None
                and RUN_ID_SHAPE_RE.match("20260920-D90-T07-S4-gpt-r01") is None
                and RUN_ID_SHAPE_RE.match("20260920-D90-T07-S4-gpt-r1") is not None
            ),
            True,
        )
        check(
            "normalize reads -r1 as the base, keeps family r1",
            (
                normalize_run_id("20260920-D90-T07-S4-gpt-r1") == "20260920-D90-T07-S4-gpt"
                and normalize_run_id("20260920-D90-T07-S4-r1") == "20260920-D90-T07-S4-r1"
            ),
            True,
        )
        check(
            "risk targets classify by shape",
            (
                risk_target_kind("D90-T07-S4-PR1")
                == risk_target_kind("PR1")
                == "finding"
                and risk_target_kind("20260920-D90-T07-S4-gpt-r2") == "run"
                and risk_target_kind("outage both rungs 2026-09-19") == "outage"
                and risk_target_kind("outage both rungs") is None
                and risk_target_kind("outage both rungs 2026-13-99") is None
                and outage_key("outage both rungs 2026-09-19") == ("both rungs", "2026-09-19")
                and outage_key("outage both rungs") is None
                and risk_target_kind("tomorrow") is None
            ),
            True,
        )
        check(
            "gate fails owed uncovered entries, passes the rest",
            (
                dim_failing("degraded", [{"state": "retry-owed", "accepted_by": ""}])
                and not dim_failing("degraded", [{"state": "retry-owed", "accepted_by": "bob"}])
                and not dim_failing("degraded", [{"state": "partial", "accepted_by": ""}])
                and dim_failing("criticals", [{"accepted_by": ""}])
                and not dim_failing("majors", [{"accepted_by": "bob"}])
                and dim_failing("stale", [{"file": "x"}])
                and not dim_failing("stale", [])
                and dim_failing("degraded", [{"state": "partial", "accepted_by": ""}], strict=True)
                and dim_failing("criticals", [{"accepted_by": "bob"}], strict=True)
            ),
            True,
        )
        check(
            "acceptance covers only between record and expiry",
            (
                acceptance_live("2026-09-01", "2099-01-01", "2026-09-18")
                and acceptance_live("2026-09-18", "2026-09-18", "2026-09-18")
                and not acceptance_live("2020-01-05", "2020-06-01", "2026-09-18")
                and not acceptance_live("2099-01-01", "2099-12-31", "2026-09-18")
            ),
            True,
        )
        check(
            "clearance ordering fails closed on ties, inversions, and dateless days",
            (
                review_ordered(
                    "2026-09-18T15:00:00Z",
                    "2026-09-18T12:00:00Z",
                    "2026-09-18",
                    "2026-09-18",
                )
                and not review_ordered(
                    "2026-09-18T12:00:00Z",
                    "2026-09-18T12:00:00Z",
                    "2026-09-18",
                    "2026-09-18",
                )
                and not review_ordered(
                    "2026-09-18T11:00:00Z",
                    "2026-09-18T12:00:00Z",
                    "2026-09-18",
                    "2026-09-18",
                )
                and review_ordered(None, None, "2026-09-19", "2026-09-18")
                and not review_ordered(None, None, "2026-09-18", "2026-09-18")
                and not review_ordered(
                    "2026-09-18T15:00:00Z", None, "2026-09-18", "2026-09-18"
                )
                and fix_postdates_review(1001, 1000, "2026-09-18")
                and not fix_postdates_review(1000, 1000, "2026-09-18")
                and not fix_postdates_review(999, 1000, "2026-09-18")
                and not fix_postdates_review(None, 1000, "2026-09-18")
                and fix_postdates_review(
                    int(
                        datetime(2026, 9, 19, tzinfo=timezone.utc).timestamp()
                    ),
                    None,
                    "2026-09-18",
                )
                and not fix_postdates_review(
                    int(
                        datetime(2026, 9, 18, tzinfo=timezone.utc).timestamp()
                    ),
                    None,
                    "2026-09-18",
                )
            ),
            True,
        )
        check("run day reads the date prefix", run_day("20260920-D90-T08-S2-sol"), "2026-09-20")
        check("run day fails closed off-shape", run_day("not-a-run"), "")
        check("migration is not overdue before the deadline", migration_overdue_today("2026-09-19"), False)
        check("migration is overdue past the deadline", migration_overdue_today("2027-01-01"), True)
        check(
            "outage markers parse, prose mentions do not",
            (
                is_outage_marker("opus (run 20260920-D90-T08-S2-opus) outage: opus rung (owner zed, due 2099-01-01)")
                and not is_outage_marker("sol (run 20260920-D90-T08-S2-sol) filed D90 T08 §9")
            ),
            True,
        )
        check(
            "fences strip, unbalanced openers report",
            (
                strip_fenced_code("keep\n```\nhide\n```\nkeep2\n"),
                strip_fenced_code("keep\n```\nnever closed\n"),
            ),
            (("keep\nkeep2", None), ("keep", 2)),
        )
        check("finding namespaces split bare from namespaced", (finding_namespace("PR4"), finding_namespace("D90-T08-S2-PR4")), ("", "d90-t08-s2-"))
        _sup_block = "- [D90-T08-S2-PR9] [major] followup -> accepted supersedes D90-T08-S2-PR8\n- [D90-T08-S2-PR8] [major] original -> accepted\n"
        check("supersession resolves heads", (ledger_supersedes(_sup_block), superseded_ids(_sup_block)), ({"d90-t08-s2-pr9": "D90-T08-S2-PR8"}, {"d90-t08-s2-pr8"}))
        check("ledger block defects report", ledger_block("no block here"), (None, "without a Ledger: block"))

        # --- run / plan-health / summary queries --------------------------------
        import io as _qio
        import contextlib as _qctx
        import json as _qjson

        def _qrun(ns):
            buf = _qio.StringIO()
            with _qctx.redirect_stdout(buf), _qctx.redirect_stderr(_qio.StringIO()):
                code = cmd_query(ns)
            return code, buf.getvalue()

        # The severity ratchet test above removed 90-selftest; rebuild it.
        (root / "todo" / "90-selftest").mkdir(parents=True, exist_ok=True)
        rev_todo = root / "todo" / "90-selftest" / "TODO-08-review.md"
        rev_todo.write_text(
            """---
schema_version: 1
id: self-test-review
domain: 90-selftest
status: active
title: "TODO-08 -- Self-test review records"
track: Z1
---

# TODO-08 -- Self-test review records

> **Goal:** Fixture. Plan-review markers, ledgers, and runs for the queries.

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Grandfathered stamp | -- |  [x]   |
|   2   |   §2    | Marked review | -- |  [x]   |
|   3   |   §3    | Unmarked review | -- |  [x]   |
|   4   |   §4    | Degraded review | -- |  [x]   |

---

## 1. Grandfathered stamp

- [x] Did the thing
- [x] Commit: `"selftest: review"`

**Test checkpoint:** `true`

> **Verified:** 2026-01-01 | §1 | fixture
> **Review:** round 1, fingerprint `abc123def456` -- `adversarial` approve
> **CRUD:** applicable | fixture

## 2. Marked review

- [x] Did the thing
- [x] Commit: `"selftest: review"`

**Test checkpoint:** `true`

> **Verified:** 2026-09-20 | §2 | fixture
> **Review:** round 1, fingerprint `abc123def456` -- `adversarial` approve. Raw findings: docs/selftest-review.md
> **Plan review:** sol (run 20260920-D90-T08-S2-sol)
> **CRUD:** applicable | fixture

## 3. Unmarked review

-> XREF: D90 T08 §2

- [x] Did the thing
- [x] Commit: `"selftest: review"`

**Test checkpoint:** `true`

> **Verified:** 2026-09-20 | §3 | fixture
> **Review:** round 1, fingerprint `abc123def456` -- `adversarial` approve
> **CRUD:** applicable | fixture

## 4. Degraded review

- [x] Did the thing
- [x] Commit: `"selftest: review"`

**Test checkpoint:** `true`

> **Verified:** 2026-09-20 | §4 | fixture
> **Review:** round 1, fingerprint `abc123def456` -- `adversarial` approve. Raw findings: docs/selftest-fallback.md
> **Plan review:** sol (run 20260920-D90-T08-S4-sol) retry-owed (owner zed, due 2099-12-31)
> **CRUD:** applicable | fixture
""",
            encoding="utf-8",
        )
        (root / "docs").mkdir(exist_ok=True)
        (root / "docs" / "selftest-review.md").write_text(
            """# Review: fixture

## Opus panel

- `adversarial` approve
- `consistency` approve
- `integration` approve
- `record` approve

## Plan review

Manifest: sections [D90 T08 §2]; dependents [none]; bytes 128; run 20260920-D90-T08-S2-sol

Ledger:
- [D90-T08-S2-PR1] [critical] bad thing -> accepted (owner alice, due 2099-01-01)
- [D90-T08-S2-PR2] [major] old thing -> accepted (owner bob, due 2026-01-01)
- [D90-T08-S2-PR3] [minor] polish -> accepted
- [D90-T08-S2-PR4] [critical] filed thing -> filed D90 T08 §9
End of ledger

Provenance: candidate abc1234; command true; exit 0; tool fixture 1; digest deadbeef; path docs/selftest-review.md; run 20260920-D90-T08-S2-sol
""",
            encoding="utf-8",
        )
        (root / "docs" / "selftest-fallback.md").write_text(
            """# Review: fixture fallback

## Opus panel

- `adversarial` approve
- `consistency` approve
- `integration` approve
- `record` approve

## GPT panel

- `adversarial` approve
- `consistency` approve
- `integration` approve
- `record` approve

Opus outage: sign-off rung unreachable, failed over to Sol.
""",
            encoding="utf-8",
        )
        try:
            code, out = _qrun(argparse.Namespace(what="run", target="20260920-D90-T08-S2-sol"))
            check("query run exits 0 on a recorded run", code, 0)
            check("query run prints marker lineage", "marker lineage" in out and "TODO-08-review.md §2" in out, True)
            check("query run prints ledger rows", "D90-T08-S2-PR1" in out and "D90-T08-S2-PR4" in out, True)
            check("query run prints provenance artifacts", "digest deadbeef" in out, True)
            check("query run prints manifest scope", "sections [D90 T08 §2]" in out, True)
            code, _o = _qrun(argparse.Namespace(what="run", target="20260920-D90-T08-S2-sol-r1"))
            check("query run reads through the -r1 synonym", code, 0)
            code, out = _qrun(argparse.Namespace(what="run", target="20260920-D90-T08-S9-gpt"))
            check("query run exits 1 on an unknown run", (code, "unknown run" in out), (1, True))
            code, _o = _qrun(argparse.Namespace(what="run", target=""))
            check("query run exits 2 with no target", code, 2)

            code, out = _qrun(argparse.Namespace(what="plan-health"))
            check("plan-health exits 0 as a reading", code, 0)
            check("plan-health lists the grandfathered stamp", "TODO-08-review.md §1" in out and "grandfathered stamps 1 " in out, True)
            check("plan-health lists the unmarked review", "TODO-08-review.md §3" in out, True)
            check("plan-health lists the degraded marker", "retry-owed" in out and "TODO-08-review.md §4" in out, True)
            check("plan-health lists the uncovered dependent", "waits on marked" in out and "TODO-08-review.md §3" in out, True)
            check("plan-health lists the open critical", "D90-T08-S2-PR1" in out, True)
            check("plan-health lists the overdue major", "D90-T08-S2-PR2" in out, True)
            check("plan-health skips the minor", "D90-T08-S2-PR3" in out, False)
            check("plan-health lists the fallback file", "docs/selftest-fallback.md" in out, True)
            check("plan-health flags stale scope", "stale scope         1 " in out, True)
            code, out = _qrun(argparse.Namespace(what="plan-health", check=True))
            check("plan-health --check fails on actionables", (code, "gate: FAIL" in out), (1, True))
            code, _o = _qrun(argparse.Namespace(what="plan-health", fail_on="bogus"))
            check("plan-health --fail-on bogus exits 2", code, 2)
            code, _o = _qrun(argparse.Namespace(what="plan-health", fail_on="stale"))
            check("plan-health --fail-on stale fails on presence", code, 1)
            code, out = _qrun(argparse.Namespace(what="plan-health", json=True))
            rep = _qjson.loads(out)
            check("plan-health --json carries the schema", rep["schema"], "plan-health/4")
            check("plan-health --json grandfathered count", len(rep["grandfathered"]), 1)
            check("plan-health --json unmarked count", len(rep["reviewed"]["unmarked"]), 1)

            code, out = _qrun(argparse.Namespace(what="summary"))
            check("summary exits 1 while actionables stand", code, 1)
            check("summary names the first failing dimension entry", "TODO-08-review.md §3" in out, True)
            check("summary counts the unaccepted retry-owed run", "incomplete runs     1" in out, True)
        finally:
            rev_todo.unlink()
            (root / "docs" / "selftest-review.md").unlink()
            (root / "docs" / "selftest-fallback.md").unlink()
        clean = root / "clean"
        (clean / "todo" / "90-clean").mkdir(parents=True)
        (clean / "todo" / "90-clean" / "TODO-01-clean.md").write_text(
            "---\nschema_version: 1\nid: clean\ndomain: 90-clean\nstatus: active\n"
            'title: "TODO-01 -- Clean"\ntrack: Z9\n---\n\n# TODO-01 -- Clean\n\n'
            "> **Goal:** Fixture: one grandfathered stamp, nothing actionable.\n\n"
            "## Implementation Order\n\n"
            "| Order | Section | Deliverable | Depends On | Status |\n"
            "| :---: | :-----: | ----------- | ---------- | :----: |\n"
            "|   1   |   §1    | Old work | -- |  [x]   |\n\n---\n\n## 1. Old work\n\n"
            "- [x] Did the thing\n- [x] Commit: `\"selftest: clean\"`\n\n"
            "**Test checkpoint:** `true`\n\n> **Verified:** 2026-09-01 | §1 | fixture\n",
            encoding="utf-8",
        )
        saved_tree = TODO_DIR
        TODO_DIR = clean / "todo"
        try:
            code, _o = _qrun(argparse.Namespace(what="plan-health", check=True))
            check("plan-health --check passes on a clean tree", code, 0)
            code, out = _qrun(argparse.Namespace(what="summary"))
            check("summary exits 0 on a clean tree", code, 0)
            check(
                "summary on a clean tree names nothing actionable",
                ("incomplete runs     0" in out and "next: nothing actionable" in out),
                True,
            )
        finally:
            TODO_DIR = saved_tree

        # --- validator rules 16-25 --------------------------------------------
        # One fixture TODO plus one findings file per section: each rule fires
        # on its own section while the clean records (§1 Opus, §13 GPT
        # fallback) stay silent. Presence-asserted per section, never
        # buffer-counted: the fixture tree carries known unrelated findings
        # (the deliberately missing 90-selftest INDEX).
        PANEL4 = (
            "## Opus panel\n\n"
            "- `adversarial` approve\n- `consistency` approve\n"
            "- `integration` approve\n- `record` approve\n"
        )
        GPT4 = (
            "## GPT panel\n\n"
            "- `adversarial` approve\n- `consistency` approve\n"
            "- `integration` approve\n- `record` approve\n"
        )
        PANEL3 = (
            "## Opus panel\n\n"
            "- `adversarial` approve\n- `consistency` approve\n- `integration` approve\n"
        )

        def _prov(run: str, path: str) -> str:
            return (
                f"Provenance: candidate abc1234; command true; exit 0; tool fixture 1; "
                f"digest deadbeef; path {path}; run {run}\n"
            )

        def _record(fid: str, run: str, ledger_rows: str) -> str:
            return (
                f"## Plan review\n\nManifest: sections [D90 T09 {fid}]; dependents [none]; "
                f"bytes 64; run {run}\n\nLedger:\n{ledger_rows}End of ledger\n"
            )

        R1 = "20260920-D90-T09-S1-sol"
        R2 = "20260920-D90-T09-S2-sol"
        R4 = "20260920-D90-T09-S4-sol"
        R5 = "20260920-D90-T09-S5-sol"
        R6 = "20260920-D90-T09-S6-sol"
        R7 = "20260920-D90-T09-S7-sol"
        R9 = "20260920-D90-T09-S9-sol"
        R11 = "20260920-D90-T09-S11-sol"
        R12 = "20260920-D90-T09-S12-sol"
        R13 = "20260920-D90-T09-S13-sol"
        R14 = "20260920-D90-T09-S14-sol"
        findings_09 = {
            "docs/selftest-r01.md": (
                PANEL4 + _record("§1", R1, "- [D90-T09-S1-PR1] [critical] bad -> accepted (owner al, due 2099-01-01)\n")
                + _prov(R1, "docs/selftest-r01.md")
            ),
            "docs/selftest-r02.md": PANEL3 + _prov(R2, "docs/selftest-r02.md"),
            "docs/selftest-r03.md": PANEL4 + _prov("20260920-D90-T09-S3-sol", "docs/selftest-r03.md"),
            "docs/selftest-r04.md": PANEL4 + _prov(R4, "docs/selftest-r04.md"),
            "docs/selftest-r05.md": (
                PANEL4
                + _record("§5", R5, "- [D90-T09-S5-PR1] [major] thing -> accepted (owner al, due 2099-01-01)\nthis is not a row\n")
                + _prov(R5, "docs/selftest-r05.md")
            ),
            "docs/selftest-r06.md": (
                PANEL4
                + _record(
                    "§6",
                    R6,
                    "- [D90-T09-S6-PR1] [major] one -> accepted (owner al, due 2099-01-01)\n"
                    "- [D90-T09-S6-PR1] [major] two -> accepted (owner al, due 2099-01-01)\n",
                )
                + _prov(R6, "docs/selftest-r06.md")
            ),
            "docs/selftest-r07.md": (
                PANEL4
                + _record("§7", R7, "- [D90-T09-S7-PR7] [critical] filed thing -> filed D90 T09 §1\n")
                + _prov(R7, "docs/selftest-r07.md")
            ),
            "docs/selftest-r08.md": PANEL4,
            "docs/selftest-r09.md": (
                PANEL4
                + _record("§9", R9, "- [D90-T09-S9-PR1] [critical] thing -> accepted (owner al, due 2099-01-01)\n")
                + _prov(R9, "docs/selftest-r09.md")
            ),
            "docs/selftest-r10.md": PANEL4,
            "docs/selftest-r11.md": PANEL4 + "Risk accepted: garbage line\n" + _prov("20260920-D90-T09-S11-sol", "docs/selftest-r11.md"),
            "docs/selftest-r12.md": (
                PANEL4
                + _record(
                    "§12",
                    R12,
                    "- [D90-T09-S12-PR1] [major] thing -> accepted (owner al, due 2099-01-01) supersedes D90-T09-S12-PR99\n",
                )
                + _prov(R12, "docs/selftest-r12.md")
            ),
            "docs/selftest-r13.md": (
                "## GPT panel\n\n"
                "- `adversarial` approve\n- `consistency` approve\n"
                "- `integration` approve\n- `record` approve\n\n"
                "Opus outage: sign-off rung unreachable, failed over to Sol.\n"
                + _prov("20260920-D90-T09-S13-sol", "docs/selftest-r13.md")
            ),
            "docs/selftest-r14.md": (
                _prov("20260920-D90-T09-S14-sol", "docs/selftest-r14.md")
                + PANEL4 + "```\nnever closed\n"
            ),
            # D00 T04 §27: stamps from 2026-09-23 are GPT-governed.
            "docs/selftest-r15.md": (
                PANEL4 + "\n" + GPT4 + _prov("20260923-D90-T09-S15-sol", "docs/selftest-r15.md")
            ),
            "docs/selftest-r16.md": (
                GPT4.replace("GPT panel", "GPT panel Round 1") + "\n"
                + "## Grok panel Round 2\n\n"
                "- `adversarial` approve\n- `consistency` approve\n"
                "- `integration` approve\n- `record` approve\n\n"
                "GPT outage: sol timed out, the Grok fallback ran.\n"
                + _prov("20260923-D90-T09-S16-sol", "docs/selftest-r16.md")
            ),
            "docs/selftest-r17.md": (
                GPT4 + "\n" + PANEL4.replace("Opus panel", "Claude panel")
                + _prov("20260923-D90-T09-S17-sol", "docs/selftest-r17.md")
            ),
            "docs/selftest-r18.md": (
                PANEL4 + "\n## GPT panel\n\n"
                "- `adversarial` approve\n- `consistency` approve\n- `integration` approve\n"
                + _prov("20260923-D90-T09-S18-sol", "docs/selftest-r18.md")
            ),
            "docs/selftest-r19.md": (
                GPT4 + "\n" + PANEL4.replace("Opus panel", "Claude panel")
                + "\nGPT outage: sol and grok both down.\n"
                + _prov("20260923-D90-T09-S19-sol", "docs/selftest-r19.md")
            ),
            "docs/selftest-r21.md": (
                GPT4 + _record("§21", "20260923-D90-T09-S21-sol", "- [D90-T09-S21-PR0] [minor] clean round -> accepted\n")
                + _prov("20260923-D90-T09-S21-sol", "docs/selftest-r21.md")
            ),
            "docs/selftest-r22.md": (
                GPT4 + _record("§22", "20260923-D90-T09-S22-grok", "- [D90-T09-S22-PR0] [minor] clean round -> accepted\n")
                + _prov("20260923-D90-T09-S22-grok", "docs/selftest-r22.md")
            ),
            # Grok left the panel 2026-09-25: its round governs nothing after.
            "docs/selftest-r23.md": (
                GPT4.replace("GPT panel", "GPT panel Round 1") + "\n"
                + "## Grok panel Round 2\n\n"
                "- `adversarial` approve\n- `consistency` approve\n"
                "- `integration` approve\n- `record` approve\n\n"
                "GPT outage: astra timed out, a Grok round ran anyway.\n"
                + _prov("20260925-D90-T09-S23-sol", "docs/selftest-r23.md")
            ),
            "docs/selftest-r20.md": (
                GPT4 + "\n" + PANEL4.replace("Opus panel", "Grok panel")
                + _prov("20260923-D90-T09-S20-sol", "docs/selftest-r20.md")
            ),
        }
        COMMITTED_R09 = (
            "# Review: committed\n\n## Plan review\n\n"
            "Manifest: sections [D90 T09 §9]; dependents [none]; bytes 64; run " + R9 + "\n\n"
            "Ledger:\n- [D90-T09-S9-PR1] [critical] thing -> filed D90 T09 §1\nEnd of ledger\n"
        )

        def _sec09(num: int, findings: str, marker: str | None, extra: str = "",
                   day: str = "2026-09-20") -> str:
            stamp = (
                f"\n## {num}. Rule probe {num}\n\n- [x] Did the thing\n"
                f'- [x] Commit: `"selftest: rules"`\n\n**Test checkpoint:** `true`\n\n'
                f"> **Verified:** {day} | §{num} | fixture\n"
                f"> **Review:** round 1, fingerprint `abc123def456` -- `adversarial` approve. Raw findings: {findings}\n"
            )
            if marker is not None:
                stamp += f"> **Plan review:** {marker}\n"
            stamp += "> **CRUD:** applicable | fixture\n" + extra
            return stamp

        rules_todo = root / "todo" / "90-selftest" / "TODO-09-rules.md"
        (root / "todo" / "90-selftest").mkdir(parents=True, exist_ok=True)
        _rows09 = "\n".join(
            f"|   {n}   |   §{n}    | Rule probe {n} | -- |  [x]   |" for n in range(1, 24)
        )
        rules_todo.write_text(
            "---\nschema_version: 1\nid: self-test-rules\ndomain: 90-selftest\nstatus: active\n"
            'title: "TODO-09 -- Self-test validator rules"\ntrack: Z1\n---\n\n'
            "# TODO-09 -- Self-test validator rules\n\n> **Goal:** Fixture. One firing section per review rule.\n\n"
            "## Implementation Order\n\n| Order | Section | Deliverable | Depends On | Status |\n"
            "| :---: | :-----: | ----------- | ---------- | :----: |\n" + _rows09 + "\n\n---\n"
            + _sec09(1, "docs/selftest-r01.md", f"sol (run {R1})")
            + _sec09(2, "docs/selftest-r02.md", f"sol (run {R2}) no findings")
            + _sec09(3, "docs/selftest-r03.md", None)
            + _sec09(4, "docs/selftest-r04.md", f"sol (run {R4}) no findings filed D90 T09 §1")
            + _sec09(5, "docs/selftest-r05.md", f"sol (run {R5})")
            + _sec09(6, "docs/selftest-r06.md", f"sol (run {R6})")
            + _sec09(7, "docs/selftest-r07.md", f"sol (run {R7}) filed D90 T09 §1")
            + _sec09(
                8,
                "docs/selftest-r08.md",
                "sol no findings",
                extra="> **Reopened:** 2026-09-20 | D90 T09 §8 | voided by late finding\n",
            )
            + _sec09(9, "docs/selftest-r09.md", f"sol (run {R9})")
            + _sec09(10, "docs/selftest-r10.md", "sol no findings")
            + _sec09(11, "docs/selftest-r11.md", f"sol (run {R11}) no findings")
            + _sec09(12, "docs/selftest-r12.md", f"sol (run {R12})")
            + _sec09(13, "docs/selftest-r13.md", f"sol (run {R13}) no findings")
            + _sec09(14, "docs/selftest-r14.md", f"sol (run {R14}) no findings")
            + _sec09(15, "docs/selftest-r15.md", "sol (run 20260923-D90-T09-S15-sol) no findings", day="2026-09-23")
            + _sec09(16, "docs/selftest-r16.md", "sol (run 20260923-D90-T09-S16-sol) no findings", day="2026-09-23")
            + _sec09(17, "docs/selftest-r17.md", "sol (run 20260923-D90-T09-S17-sol) no findings", day="2026-09-23")
            + _sec09(18, "docs/selftest-r18.md", "sol (run 20260923-D90-T09-S18-sol) no findings", day="2026-09-23")
            + _sec09(19, "docs/selftest-r19.md", "sol (run 20260923-D90-T09-S19-sol) no findings", day="2026-09-23")
            + _sec09(20, "docs/selftest-r20.md", "sol (run 20260923-D90-T09-S20-sol) no findings", day="2026-09-23")
            + _sec09(21, "docs/selftest-r21.md", "sol (run 20260923-D90-T09-S21-sol) partial: grok rung no findings", day="2026-09-23")
            + _sec09(22, "docs/selftest-r22.md", "grok (run 20260923-D90-T09-S22-grok) partial: gpt rung no findings", day="2026-09-23")
            + _sec09(23, "docs/selftest-r23.md", "sol (run 20260925-D90-T09-S23-sol) no findings", day="2026-09-25"),
            encoding="utf-8",
        )
        for _rp, _rt in findings_09.items():
            (root / _rp).write_text(_rt, encoding="utf-8")
        _real_resolves = git_resolves
        _real_file_at = git_file_at
        globals()["git_resolves"] = lambda _sha: True

        def _canned_file_at(_ref: str, _path: str):
            if _ref == "HEAD" and _path == "docs/selftest-r09.md":
                return COMMITTED_R09
            return None

        globals()["git_file_at"] = _canned_file_at
        try:
            vbuf = _bio.StringIO()
            with _bctx.redirect_stdout(vbuf), _bctx.redirect_stderr(_bio.StringIO()):
                vcode = cmd_validate(argparse.Namespace())
            vout = vbuf.getvalue()
            check("validator rules fire fatals on the probe tree", vcode, 1)
            check("rule 16 fires on a missing lens", ("§2 " in vout and "lacks verdicts for: record" in vout), True)
            check("rule 16 fires on an unbalanced fence", ("§14 " in vout and "unbalanced fence" in vout), True)
            check("panel_fallback: pre-cutover GPT last is fallback with its note",
                  panel_fallback("## Opus panel\n\n## GPT panel\nOpus outage: x\n", "2026-09-20"), (True, True))
            check("panel_fallback: pre-cutover Opus last is governing",
                  panel_fallback("## GPT panel\n\n## Opus panel\n", "2026-09-20"), (False, False))
            check("panel_fallback: post-cutover GPT last is governing",
                  panel_fallback("## Opus panel\n\n## GPT panel\n", "2026-09-23"), (False, False))
            check("panel_fallback: post-cutover Claude last is the cross-fill",
                  panel_fallback("## GPT panel\n\n## Claude panel\nGPT outage: x\n", "2026-09-23"), (True, True))
            check("panel_fallback: post-cutover Grok last is the fallback",
                  panel_fallback("## GPT panel\n\n## Grok panel\nGPT outage: x\n", "2026-09-23"), (True, True))
            check("panel_fallback: post-cutover GPT after Grok governs",
                  panel_fallback("## Grok panel\n\n## GPT panel\n", "2026-09-23"), (False, False))
            check("panel_fallback: post-cutover reads the GPT note, not the Opus one",
                  panel_fallback("## Claude panel\nOpus outage: x\n", "2026-09-23"), (True, False))
            check("panel_fallback: no panel is neither", panel_fallback("## Plan review\n", "2026-09-23"), (False, False))
            check("rule 16 fires on a post-cutover Claude-last",
                  ("§17 " in vout and "the writer's family never reviews" in vout), True)
            check("rule 16 fires on a post-cutover Claude-last even with a GPT outage note",
                  ("§19 " in vout and "the writer's family never reviews" in vout), True)
            check("rule 16 fires on a post-cutover Grok-last without the GPT outage note",
                  ("§20 " in vout and "Grok panel governs" in vout and "without the GPT outage note" in vout),
                  True)
            check("rule 16 fires on a Grok-last stamped after Grok left the panel",
                  ("§23 " in vout and "Grok left the panel" in vout), True)
            check("rule 16 keeps a pre-retirement Grok-last with its note",
                  vout.count("Grok left the panel"), 1)
            check("rule 16 fires on a post-cutover GPT-last missing lens",
                  ("§18 " in vout and "GPT panel lacks verdicts for: record" in vout), True)
            check("rule 17 fires on a missing marker", ("§3 " in vout and "carries no `Plan review:`" in vout), True)
            check("rule 17 fires on nofindings-plus-filings", ("§4 " in vout and "both `no findings` and filings" in vout), True)
            check("rule 18 fires on a non-row ledger line", ("§5 " in vout and "malformed ledger row" in vout), True)
            check("rule 20 fires on a duplicate ID", ("§6 " in vout and "duplicate finding ID" in vout), True)
            check("rule 19 fires on a missing back-link", ("§7 " in vout and "no back-link" in vout), True)
            check("rule 21 fires on a still-checked reopen", ("§8 " in vout and "reopened but still [x]" in vout), True)
            check("rule 22 fires on a terminal rewrite", ("§9 " in vout and "moved filed -> accepted" in vout), True)
            check("rule 23 fires on missing provenance", ("§10 " in vout and "no Provenance: line" in vout), True)
            check("rule 24 fires on a malformed acceptance", ("§11 " in vout and "malformed Risk accepted line" in vout), True)
            check("rule 25 fires on an orphaned supersedes", ("§12 " in vout and "names no row of its block" in vout), True)
            # Silence is subject-exact (this file, `: §N `) outside advisory
            # lines: other rules legitimately NAME these sections (rule 19
            # names its target), other fixtures have their own §1, and
            # advisories summarize the file.
            _nonadv = [ln for ln in vout.splitlines() if "adjacency advisory" not in ln]
            check(
                "the clean Opus record stays silent",
                not any(re.search(r"TODO-09-rules\.md:\d+: §1 ", ln) for ln in _nonadv),
                True,
            )
            check(
                "the clean GPT fallback stays silent",
                not any(re.search(r"TODO-09-rules\.md:\d+: §13 ", ln) for ln in _nonadv),
                True,
            )
            check(
                "the post-cutover GPT-governed record stays silent",
                [ln for ln in _nonadv if re.search(r"TODO-09-rules\.md:\d+: §15 ", ln)],
                [],
            )
            for _n, _what in ((21, "a failed grok rung beside a GPT survivor"),
                              (22, "a GPT failure a Grok plan run survived")):
                check(f"plan-review grammar accepts {_what} with no retry owed",
                      [ln for ln in _nonadv if re.search(rf"TODO-09-rules\.md:\d+: §{_n} ", ln)], [])
            check(
                "the post-cutover Grok fallback with its note stays silent",
                [ln for ln in _nonadv if re.search(r"TODO-09-rules\.md:\d+: §16 ", ln)],
                [],
            )
        finally:
            globals()["git_resolves"] = _real_resolves
            globals()["git_file_at"] = _real_file_at
            rules_todo.unlink()
            for _rp in findings_09:
                (root / _rp).unlink()

    finally:
        TODO_DIR, PLAN, SKILLS_DIR = saved_todo_dir, saved_plan, saved_skills
        tmp.cleanup()

    failed = [(n, got, want) for n, got, want in cases if got != want]
    for name, got, want in failed:
        print(f"todo-graph self-test: FAIL {name}: got {got!r}, want {want!r}", file=sys.stderr)
    print(f"todo-graph self-test: {len(cases)} cases, {len(failed)} failed")
    return 1 if failed else 0


def main() -> int:
    p = argparse.ArgumentParser(prog="todo-graph", description=__doc__.split("\n")[0])
    sub = p.add_subparsers(dest="cmd", required=True)
    sub.add_parser("build", help="parse todo/ into build/todo-cache.json").set_defaults(fn=cmd_build)
    va = sub.add_parser("validate", help="structural and graph integrity checks")
    va.add_argument(
        "--report-shipped-items",
        action="store_true",
        help="list every unchecked item under shipped rows with its disposition (a reading, not a gate)",
    )
    va.set_defaults(fn=cmd_validate)
    wa = sub.add_parser("warnings", help="show or re-accept the warning baseline")
    # Mutually exclusive: --accept writes the baseline (the one durable side
    # effect here) and --acked only reads; passing both must be an argparse
    # error, not a silent no-op of the write (round-2 integration finding).
    wa_mode = wa.add_mutually_exclusive_group()
    wa_mode.add_argument("--accept", action="store_true", help="accept the current set as the baseline")
    wa_mode.add_argument(
        "--acked",
        action="store_true",
        help="list acknowledged warnings (stamped pre-convention debt register, D00 T01 §38)",
    )
    wa.set_defaults(fn=cmd_warnings)
    sub.add_parser(
        "self-test",
        help="prove this script's own contract against fixtures (fast; run it after editing this file)",
    ).set_defaults(fn=cmd_self_test)
    q = sub.add_parser("query", help="ask the graph a question")
    q.add_argument(
        "what",
        choices=["ready", "blocked", "stats", "deferred", "frozen", "findings", "surfaces", "adjacency", "calibration", "sequence", "plan-health", "summary", "run"],
    )
    q.add_argument("target", nargs="?", help="run: run ID to inspect")
    q.add_argument("--all", action="store_true", help="findings: include ones already done")
    q.add_argument("--file", help="adjacency: exact repository-relative TODO path")
    q.add_argument("--at", help="adjacency: inspect an isolated historical commit")
    q.add_argument("--json", action="store_true", help="adjacency, plan-health: machine-readable report")
    q.add_argument("--check", action="store_true", help="plan-health: exit 1 on actionable entries (covered escalations and bare partials pass; --fail-on gates presence)")
    q.add_argument("--fail-on", metavar="DIMS", help="plan-health: comma-separated dimensions whose non-emptiness exits 1")
    q.add_argument("--require-owned", action="store_true", help="adjacency: refuse incomplete file ownership at closeout")
    q.add_argument("--require-conformance", action="store_true", help="adjacency: require non-vacuous tree-wide kind coverage")
    q.add_argument(
        "--context",
        nargs="*",
        choices=sorted(REQUIRES_ALLOWED),
        default=None,
        help="ready: evaluate requirements against exactly these capabilities instead of the detected local context (planning)",
    )
    q.set_defaults(fn=cmd_query)
    sub.add_parser("render", help="mermaid dependency graph on stdout").set_defaults(fn=cmd_render)
    rs = sub.add_parser("resolve", help="turn any section reference into its file and number")
    rs.add_argument("ref", nargs="+", help="'D00 T01 §11', a pasted plan row, or '<path> §N'")
    rs.set_defaults(fn=cmd_resolve)
    cl = sub.add_parser(
        "classify",
        help="resolve many refs in one graph load; JSON {ref: exit_code}",
    )
    cl.add_argument("refs", nargs="*", help="D00 T01 §11 and friends")
    cl.set_defaults(fn=cmd_classify)
    nd = sub.add_parser(
        "needs",
        help="the **Needs:** host keys of many refs in one graph load; JSON {ref: [keys]}",
    )
    nd.add_argument("refs", nargs="*", help="D02 T01 §3 and friends")
    nd.set_defaults(fn=cmd_needs)
    pl = sub.add_parser("plan", help="sync implementation-plan.md's checkboxes from the graph")
    mode = pl.add_mutually_exclusive_group()
    mode.add_argument(
        "--check",
        action="store_true",
        help="report staleness and exit 1 instead of rewriting the file (what CI runs)",
    )
    # Accepted and ignored: syncing is the default, but the plan's own
    # instructions say `--sync`, and a documented command that errors is worse
    # than a redundant flag.
    mode.add_argument("--sync", action="store_true", help="rewrite the boxes (the default)")
    pl.set_defaults(fn=cmd_plan)
    pr = sub.add_parser("progress", help="emit rebuild-progress JSON for the progress dashboard")
    pr.add_argument("--json", action="store_true", help="JSON on stdout (the only format)")
    pr.add_argument(
        "--write",
        action="store_true",
        help="also write platform/resources/rebuild-progress.json",
    )
    pr.set_defaults(fn=cmd_progress)
    args = p.parse_args()
    if args.cmd == "query" and args.what != "adjacency" and any(getattr(args, key, None) for key in ("file", "at", "json", "require_owned", "require_conformance")):
        p.error("--file/--at/--json/--require-owned/--require-conformance apply only to query adjacency")
    return args.fn(args)


if __name__ == "__main__":
    sys.exit(main())
