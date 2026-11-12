#!/usr/bin/env python3
"""todo-graph -- validate, query, and project the Resolute TODO graph.

Markdown under todo/ is canonical; this script reads it and never writes it,
except `plan --sync`, which rewrites the derived boxes and Items counts in
todo/implementation-plan.md.

    python3 scripts/todo-graph.py validate
    python3 scripts/todo-graph.py self-test
    python3 scripts/todo-graph.py query ready|blocked|stats|deferred|adjacency|night-debt
    python3 scripts/todo-graph.py plan --sync | --check
    python3 scripts/todo-graph.py resolve 'D00 T01 §11'

Stdlib only. Format spec: todo/README.md
"""

from __future__ import annotations

import argparse
import contextlib
import importlib.util
import io
import json
import os
import re
import subprocess
import sys
import tempfile
import unicodedata
from dataclasses import dataclass, field
from datetime import date
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
# Rebound by the self-test to a fixture tree.
TODO_DIR = REPO / "todo"
PLAN = TODO_DIR / "implementation-plan.md"

ID_RE = re.compile(r"^[a-z][a-z0-9-]{0,58}[a-z0-9]$")
STATUSES = {"draft", "active", "blocked", "done", "superseded"}
TODO_FILE_RE = re.compile(r"^TODO-(\d{2})-[a-z0-9-]+\.md$")
MAX_SECTIONS_PER_FILE = 55
# The most sections one Verified stamp may cover; bounds a range before it is built.
MAX_STAMP_COVERAGE = 65

# "| 3 | §2 | Deliverable text | §1, T02 §4 | [x] |"
ROW_RE = re.compile(
    r"^\|\s*(?P<order>\d{1,9})\s*\|\s*§(?P<sec>\d{1,9})\s*\|"
    r"\s*(?P<deliverable>.+?)\s*\|\s*(?P<deps>.*?)\s*\|\s*\[(?P<status>[ x/])\]\s*\|\s*$"
)
BODY_RE = re.compile(r"^##\s+(?P<num>\d{1,9})\.\s+(?P<title>.+?)\s*$")
# §1 | T02 §3 | D02 T01 §4
XREF_RE = re.compile(r"(?:D(?P<dom>\d{2})\s+)?(?:T(?P<todo>\d{2})\s+)?§(?P<sec>\d{1,9})(?!\d)")
# Stamp lines. Kinds beyond Verified, Deferred, Resolved and Moved survive on
# historical stamps; they are recognised so their cross-references count, and
# otherwise ignored.
STAMP_RE = re.compile(
    r"^>\s*\*\*(?P<kind>Verified|Deferred|Resolved|Review|Duration|CRUD|Verification|Implementer"
    r"|Moved|Plan review|Reopened|Started|Night-owed|Night-verified):\*\*\s*(?P<body>.+?)\s*$"
)
# `<YYYY-MM-DD> | <coverage> | <evidence>`; ASCII so other scripts' digits never read as a date.
STAMP_BODY_RE = re.compile(
    r"^(?P<date>\d{4}-\d{2}-\d{2})[ \t]*\|[ \t]*(?P<cover>[^|]*?)[ \t]*\|(?P<evidence>.*)$",
    re.ASCII,
)
COVER_ITEM_RE = re.compile(r"^§(?P<lo>\d{1,9})(?:[ \t]*-[ \t]*§?(?P<hi>\d{1,9}))?$", re.ASCII)
DEFER_REF_RE = re.compile(r"->\s*XREF:\s*(?P<ref>(?:D\d{2}\s+)?(?:T\d{2}\s+)?§\d+)")
# The target of an explicit `-> XREF:`, backticked or not; it must name a real section.
XREF_TARGET_RE = re.compile(r"->\s*XREF:\s*`?(?P<ref>(?:D\d{2}\s+)?(?:T\d{2}\s+)?§\d{1,9})(?!\d)")
DEFER_ITEM_RE = re.compile(r"\(item:\s*[\"“](?P<item>[^\"”]+)[\"”]")
MOVED_PATH_RE = re.compile(r"(?P<path>(?:[\w.-]+/)+[\w.-]+\.md)")

# `**Needs:** <host>`: a closed list, so a typo cannot silently unmark a section.
NEEDS_BLOCK_RE = re.compile(r"^\*\*Needs:\*\*\s*(?P<value>.+?)\s*$")
NEEDS_ALLOWED: dict[str, str] = {
    "Windows host (build/test)": "windows-host",
    "C++ toolchain (compile)": "cpp-toolchain",
    "Optical drive (drive test)": "Optical drive (drive test)",
    "USB device (drive test)": "USB device (drive test)",
    "Signing certificate (release)": "Signing certificate (release)",
    "Clean Windows machine (no Visual Studio)": "Clean Windows machine (no Visual Studio)",
}
# `**Requires:** <values> -- <reason>`: capabilities `query ready` checks against the context.
REQUIRES_BLOCK_RE = re.compile(r"^\*\*Requires:\*\*\s*(?P<body>.+?)\s*$")
REQUIRES_ALLOWED: tuple[str, ...] = ("display-session", "operator")
REQUIRES_REASON_SEP = " -- "
# `**Manual:** operator-only -- <reason>` travels with `**Requires:** operator`.
MANUAL_BLOCK_RE = re.compile(r"^\*\*Manual:\*\*\s*(?P<body>.*?)\s*$")
MANUAL_ALLOWED = ("operator-only",)


def detect_context(platform: str | None = None, environ=None) -> set[str]:
    """Capabilities this runner has. display-session: an interactive Windows session.

    `operator` is never detected: only `--context operator` declares it.
    """
    plat = sys.platform if platform is None else platform
    env = os.environ if environ is None else environ
    session = (env.get("SESSIONNAME") or "").strip()
    if plat == "win32" and session and session.lower() != "services":
        return {"display-session"}
    return set()


# ---------------------------------------------------------------- frontmatter


def parse_frontmatter(text: str) -> tuple[dict, list[str]]:
    """Flat YAML: scalars, bools, small ints and flow lists. No library on purpose."""
    if not text.startswith("---"):
        return {}, ["missing frontmatter (file must open with ---)"]
    end = text.find("\n---", 3)
    if end == -1:
        return {}, ["frontmatter opened with --- but never closed"]
    data: dict = {}
    errors: list[str] = []
    for lineno, raw in enumerate(text[3:end].strip("\n").splitlines(), start=2):
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
            data[key] = [v.strip().strip("\"'") for v in inner.split(",") if v.strip()] if inner else []
        elif val in ("true", "false"):
            data[key] = val == "true"
        elif val.isascii() and val.isdigit() and len(val) <= 9:
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
    depends_on: list[str] = field(default_factory=list)
    status: str = " "
    has_body: bool = False
    has_row: bool = False
    line: int = 0
    items: list[tuple[bool, str]] = field(default_factory=list)  # (done, text)
    has_test_checkpoint: bool = False
    needs_raw: str = ""
    needs: list[str] = field(default_factory=list)
    requires_has_line: bool = False
    requires_raw: str = ""
    requires: list[str] = field(default_factory=list)
    requires_unknown: list[str] = field(default_factory=list)
    requires_reason: str = ""
    manual_raw: str | None = None
    # `> **Moved:**` body: the open work lives in the file it names; ready and plan skip it.
    moved: str = ""

    @property
    def items_total(self) -> int:
        return len(self.items)

    @property
    def items_done(self) -> int:
        return sum(1 for done, _ in self.items if done)


@dataclass
class Deferral:
    line: int
    resolved: bool
    body: str
    ref: str  # owner, e.g. "D09 T01 §1"
    item: str  # the exact checklist item the owner carries, when named


@dataclass
class Todo:
    path: str
    domain: str
    number: str
    id: str = ""
    title: str = ""
    status: str = ""
    depends_on: list[str] = field(default_factory=list)
    superseded_by: str = ""
    sections: dict[int, Section] = field(default_factory=dict)
    verified_sections: set[int] = field(default_factory=set)
    deferred: list[Deferral] = field(default_factory=list)
    xrefs: list[str] = field(default_factory=list)
    xref_targets: list[tuple[int, str]] = field(default_factory=list)  # (line, ref) of each `-> XREF: <ref>`
    fm_errors: list[str] = field(default_factory=list)
    malformed_stamps: list[tuple[int, str]] = field(default_factory=list)

    @property
    def prefix(self) -> str:
        return self.domain.split("-")[0]

    def ref(self, num: int) -> str:
        return f"D{self.prefix} T{self.number} §{num}"


def parse_verified(body: str) -> tuple[list[int], str]:
    """The sections a Verified body covers, or ([], why it was refused)."""
    shaped = STAMP_BODY_RE.match(body.strip())
    if not shaped:
        return [], "is not '<YYYY-MM-DD> | <sections> | <evidence>'"
    if not shaped.group("evidence").strip():
        return [], "has an empty evidence field"
    day = shaped.group("date")
    try:
        date(*(int(part) for part in day.split("-")))
    except ValueError:
        return [], f"opens with {day!r}, which is not a real calendar date"
    covered: list[int] = []
    for element in shaped.group("cover").split(","):
        item = COVER_ITEM_RE.match(element.strip())
        if item is None:
            return [], f"has {element.strip()!r} in its coverage field, which is not a section reference or range"
        lo = int(item.group("lo"))
        hi = int(item.group("hi")) if item.group("hi") else lo
        if lo < 1 or hi < lo:
            return [], f"has {element.strip()!r} in its coverage field, which covers no section"
        if len(covered) + (hi - lo + 1) > MAX_STAMP_COVERAGE:
            return [], f"covers more than {MAX_STAMP_COVERAGE} sections by {element.strip()!r}"
        covered.extend(range(lo, hi + 1))
    return covered, ""


def parse_todo(path: Path) -> Todo:
    m = TODO_FILE_RE.match(path.name)
    try:
        rel = path.relative_to(TODO_DIR.parent).as_posix()
    except ValueError:
        rel = path.as_posix()
    todo = Todo(path=rel, domain=path.parent.name, number=m.group(1) if m else "??")
    text = path.read_text(encoding="utf-8")
    fm, todo.fm_errors = parse_frontmatter(text)
    todo.id = str(fm.get("id", ""))
    todo.title = str(fm.get("title", ""))
    todo.status = str(fm.get("status", ""))
    todo.superseded_by = str(fm.get("superseded_by", ""))
    dep = fm.get("depends_on", [])
    todo.depends_on = [str(d).strip() for d in (dep if isinstance(dep, list) else [dep]) if str(d).strip()]

    current: Section | None = None
    in_order_table = False
    for lineno, line in enumerate(text.splitlines(), start=1):
        todo.xref_targets += [(lineno, x.group("ref")) for x in XREF_TARGET_RE.finditer(line)]
        stamp = STAMP_RE.match(line)
        if stamp:
            kind, body = stamp.group("kind"), stamp.group("body")
            if kind == "Verified":
                covered, refusal = parse_verified(body)
                if refusal:
                    todo.malformed_stamps.append((lineno, f"{body} -- {refusal}"))
                todo.verified_sections.update(covered)
            elif kind == "Moved" and current is not None:
                current.moved = body
            elif kind in ("Deferred", "Resolved"):
                ref = DEFER_REF_RE.search(body)
                item = DEFER_ITEM_RE.search(body)
                todo.deferred.append(Deferral(
                    line=lineno,
                    resolved=kind == "Resolved",
                    body=body,
                    ref=ref.group("ref").strip() if ref else "",
                    item=item.group("item").strip() if item else "",
                ))
            # Every reference in a stamp line is a cross-reference (a deferral points at its owner).
            todo.xrefs.extend(x.group(0) for x in XREF_RE.finditer(body))
            continue

        if line.startswith("## Implementation Order"):
            in_order_table = True
            continue
        if in_order_table and line.startswith("## "):
            in_order_table = False
        if in_order_table:
            row = ROW_RE.match(line)
            if row:
                sec = todo.sections.setdefault(int(row.group("sec")), Section(num=int(row.group("sec"))))
                sec.has_row = True
                sec.order = int(row.group("order"))
                sec.deliverable = row.group("deliverable").strip()
                sec.status = row.group("status")
                deps = row.group("deps").strip()
                if deps and deps not in ("--", "—", "-"):
                    sec.depends_on = [d.strip() for d in deps.split(",") if d.strip()]
            continue

        heading = BODY_RE.match(line)
        if heading:
            num = int(heading.group("num"))
            current = todo.sections.setdefault(num, Section(num=num))
            current.title = heading.group("title")
            current.has_body = True
            current.line = lineno
            continue
        if line.startswith("## "):
            current = None

        if current is not None:
            st = line.strip()
            if st.startswith("- [") and len(st) > 4 and st[4] == "]":
                current.items.append((st[3] == "x", st[5:].strip()))
            if "**Test checkpoint:**" in line:
                current.has_test_checkpoint = True
            needs = NEEDS_BLOCK_RE.match(st)
            if needs:
                current.needs_raw = needs.group("value").strip()
                key = NEEDS_ALLOWED.get(current.needs_raw)
                current.needs = [key] if key else []
            manual = MANUAL_BLOCK_RE.match(st)
            if manual:
                current.manual_raw = manual.group("body").partition(REQUIRES_REASON_SEP)[0].strip()
            req = REQUIRES_BLOCK_RE.match(st)
            if req:
                current.requires_has_line = True
                current.requires_raw = req.group("body").strip()
                values_part, sep, reason = current.requires_raw.partition(REQUIRES_REASON_SEP)
                current.requires_reason = reason.strip() if sep else ""
                values = [v.strip() for v in values_part.split(",") if v.strip()]
                current.requires = [v for v in values if v in REQUIRES_ALLOWED]
                current.requires_unknown = [v for v in values if v not in REQUIRES_ALLOWED]

        if "-> XREF:" in line:
            todo.xrefs.append(line.split("-> XREF:", 1)[1].strip())
    return todo


def load_todos() -> list[Todo]:
    if not TODO_DIR.exists():
        return []
    return [parse_todo(p) for p in sorted(TODO_DIR.glob("*/TODO-*.md")) if TODO_FILE_RE.match(p.name)]


class Graph:
    def __init__(self, todos: list[Todo]):
        self.todos = todos
        self.by_id = {t.id: t for t in todos if t.id}
        self.by_key = {(t.domain, t.number): t for t in todos}
        self.by_prefix = {(t.prefix, t.number): t for t in todos}

    def resolve_ref(self, ref: str, origin: Todo) -> tuple[str, int] | None:
        """'§3' / 'T02 §1' / 'D02 T01 §4', read from `origin`, to (todo id, section)."""
        m = XREF_RE.search(ref)
        if not m:
            return None
        sec, dom, tno = int(m.group("sec")), m.group("dom"), m.group("todo")
        if dom is None and tno is None:
            return (origin.id, sec)
        domain = origin.domain
        if dom is not None:
            matches = [d for d in {t.domain for t in self.todos} if d.startswith(dom + "-")]
            if not matches:
                return None
            domain = matches[0]
        target = self.by_key.get((domain, tno or origin.number))
        return (target.id, sec) if target else None

    def section(self, ref: str, origin: Todo) -> tuple[Todo, Section] | None:
        r = self.resolve_ref(ref, origin)
        target = self.by_id.get(r[0]) if r else None
        if target is None or r[1] not in target.sections:
            return None
        return target, target.sections[r[1]]

    def unmet(self, t: Todo, num: int) -> list[tuple[str, str]]:
        """Unmet dependencies of `t` §num as (query label, DNN label).

        A row edge is met when its section is [x] or Moved. A whole-TODO edge
        (frontmatter depends_on) is met when every section there is [x] or
        Moved; an empty TODO is unmet. An edge that does not resolve is unmet.
        """
        unmet: list[tuple[str, str]] = []
        for raw in t.sections[num].depends_on:
            r = self.resolve_ref(raw, t)
            src = self.by_id.get(r[0]) if r else None
            if src is None or r[1] not in src.sections:
                label = f"{r[0]} §{r[1]}" if r else raw
                unmet.append((label, label))
            elif src.sections[r[1]].status != "x" and not src.sections[r[1]].moved:
                unmet.append((f"{src.id} §{r[1]}", src.ref(r[1])))
        for dep in t.depends_on:
            dt = self.by_id.get(dep)
            if dt is None:
                unmet.append((f"{dep} (whole TODO)", f"{dep} (whole TODO)"))
                continue
            open_secs = sorted(n for n, x in dt.sections.items() if x.status != "x" and not x.moved)
            if open_secs or not dt.sections:
                first = f"§{open_secs[0]}" if open_secs else "no sections"
                unmet.append((
                    f"{dep} (whole TODO)",
                    f"{dep} (whole TODO; D{dt.prefix} T{dt.number}, first open {first}, {len(open_secs)} open)",
                ))
        return unmet

    def find(self, raw: str) -> tuple[Todo | None, int | None, str]:
        """A pasted reference ('D00 T01 §11', a plan row, '<path fragment> §N') to (todo, section, error)."""
        raw = raw.strip()
        m = re.search(r"D(?P<dom>\d{2})\s+T(?P<todo>\d{2})\s+§(?P<sec>\d+)", raw)
        if m:
            target = self.by_prefix.get((m.group("dom"), m.group("todo")))
            if target is None:
                return None, None, f"no TODO for domain {m.group('dom')} number {m.group('todo')}"
            return target, int(m.group("sec")), ""
        m2 = re.search(r"§(?P<sec>\d+)", raw)
        if not m2:
            return None, None, f"no section reference found in: {raw[:80]}"
        frag = raw[: m2.start()].strip().strip("`|").strip()
        hits = [t for t in self.todos if frag and frag in t.path]
        if len(hits) != 1:
            return None, None, (
                f"{'no' if not hits else len(hits)} TODO file(s) match {frag!r} -- "
                "give a DNN TNN §N reference or a unique path fragment"
            )
        return hits[0], int(m2.group("sec")), ""


# ------------------------------------------------------------------ validate


def cycles(edges: dict[str, set[str]], label: str) -> list[str]:
    out, state, stack = [], {}, []

    def walk(n: str) -> None:
        if state.get(n) == 2:
            return
        if state.get(n) == 1:
            out.append(f"{label} dependency cycle: {' -> '.join(stack[stack.index(n):] + [n])}")
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


def moved_target(body: str) -> str:
    m = MOVED_PATH_RE.search(body)
    if m:
        return m.group("path")
    # Support bare root-relative markdown paths such as `AGENTS.md` or `DESIGN.md`.
    m2 = re.search(r"(?P<path>[\w.-]+\.md)", body)
    return m2.group("path") if m2 else ""


def problems(todos: list[Todo]) -> list[str]:
    """Every integrity problem in the tree. Each one is fatal."""
    if not todos:
        return ["no TODO files found under todo/"]
    g = Graph(todos)
    out: list[str] = []
    seen_ids: dict[str, Todo] = {}
    for t in todos:
        out += [f"{t.path}: {e}" for e in t.fm_errors]
        for fld in ("id", "status", "title"):
            if not getattr(t, fld):
                out.append(f"{t.path}: frontmatter missing required field '{fld}'")
        if t.id and not ID_RE.match(t.id):
            out.append(f"{t.path}: id {t.id!r} fails ^[a-z][a-z0-9-]*[a-z0-9]$ (2-60 chars)")
        if t.status and t.status not in STATUSES:
            out.append(f"{t.path}: status {t.status!r} not one of {sorted(STATUSES)}")
        if t.status == "superseded" and not t.superseded_by:
            out.append(f"{t.path}: status is 'superseded' but superseded_by is unset")
        if t.id in seen_ids:
            out.append(f"{t.path}: duplicate id {t.id!r} (also in {seen_ids[t.id].path})")
        if t.id:
            seen_ids[t.id] = t
        if len(t.sections) > MAX_SECTIONS_PER_FILE:
            out.append(
                f"{t.path} has {len(t.sections)} sections, over the {MAX_SECTIONS_PER_FILE} cap: "
                "put new work in a new TODO file in the same domain"
            )
        index = TODO_DIR / t.domain / "INDEX.md"
        if not index.exists():
            out.append(f"todo/{t.domain}/INDEX.md is missing")
        elif Path(t.path).name not in index.read_text(encoding="utf-8"):
            out.append(f"{t.path}: not listed in todo/{t.domain}/INDEX.md")
        for dep in t.depends_on:
            if dep not in g.by_id:
                out.append(f"{t.path}: depends_on {dep!r} does not match any TODO id")
        for lineno, detail in t.malformed_stamps:
            out.append(f"{t.path}:{lineno}: refused '> **Verified:** {detail}")

        for num, s in sorted(t.sections.items()):
            where = f"{t.path}:{s.line}: §{num}"
            if s.has_row and not s.has_body:
                out.append(f"{t.path}: Implementation Order row §{num} has no '## {num}.' body section")
            if s.has_body and not s.has_row:
                out.append(f"{t.path}: '## {num}. {s.title}' has no Implementation Order row")
            if not s.has_body:
                continue
            if not s.has_test_checkpoint:
                out.append(f"{where} has no '**Test checkpoint:**'")
            if not s.items:
                out.append(f"{where} has no checklist items")
            if s.status == "x" and num not in t.verified_sections:
                out.append(f"{t.path}: §{num} is [x] in Implementation Order but no '> **Verified:**' stamp covers it")
            if s.status == "x":
                orphaned = [
                    txt for done, txt in s.items
                    if not done and not txt.lstrip().startswith(("~~", "->"))
                    and not txt.lstrip().lower().startswith("commit:")
                ]
                if orphaned:
                    out.append(
                        f"{where} is [x] but carries {len(orphaned)} unticked item(s): tick, strike "
                        f"(~~...~~) or re-home each. First: {orphaned[0][:80]!r}"
                    )
            if s.needs_raw and not s.needs:
                out.append(f"{where} has **Needs:** {s.needs_raw!r}, not in {sorted(NEEDS_ALLOWED)}")
            if s.requires_has_line and (s.requires_unknown or not s.requires):
                bad = ", ".join(s.requires_unknown) or "no values"
                out.append(f"{where} has **Requires:** {bad}, not in {list(REQUIRES_ALLOWED)}")
            if s.requires_has_line and not s.requires_reason:
                out.append(f"{where} has **Requires:** with no reason after ' -- '")
            if s.manual_raw is not None and s.manual_raw not in MANUAL_ALLOWED:
                out.append(f"{where} has **Manual:** {s.manual_raw!r}, not in {list(MANUAL_ALLOWED)}")
            elif s.manual_raw is not None and "operator" not in s.requires:
                out.append(f"{where} is **Manual:** operator-only without **Requires:** operator")
            if s.moved:
                target = moved_target(s.moved)
                if not target or not (TODO_DIR.parent / target).is_file():
                    out.append(f"{where} has a Moved: marker that names no existing file ({s.moved[:80]!r})")
            for raw in s.depends_on:
                r = g.resolve_ref(raw, t)
                if r is None:
                    out.append(f"{t.path}: §{num} Depends On {raw!r} does not resolve")
                elif g.section(raw, t) is None:
                    out.append(f"{t.path}: §{num} Depends On {raw!r} -> {r[0]} §{r[1]}, which does not exist")

        for lineno, ref in t.xref_targets:
            if g.section(ref, t) is None:
                out.append(f"{t.path}:{lineno}: -> XREF: {ref} names no existing section")
        for raw in t.xrefs:
            r = g.resolve_ref(raw, t)
            target = g.by_id.get(r[0]) if r and r[0] != t.id else None
            if target is not None and not any(
                (back := g.resolve_ref(x, target)) and back[0] == t.id for x in target.xrefs
            ):
                out.append(f"{t.path}: XREF to {target.path} is one-sided -- {target.path} does not point back")

        for d in t.deferred:
            where = f"{t.path}:{d.line}"
            short = (d.body[:60] + "…") if len(d.body) > 60 else d.body
            if not d.ref:
                out.append(f"{where}: deferral names no owner (no '-> XREF:') -- {short}")
                continue
            owner = g.section(d.ref, t)
            if owner is None:
                out.append(f"{where}: deferral owner '{d.ref}' does not resolve to a real section -- {short}")
                continue
            otodo, osec = owner
            settled = osec.status == "x"
            if d.item:
                matched = next((done for done, text in osec.items if d.item.lower() in text.lower()), None)
                if matched is None:
                    out.append(
                        f"{where}: deferral names item \"{d.item}\" but {otodo.path} §{osec.num} has no such item"
                    )
                    continue
                settled = matched
            if settled and not d.resolved:
                out.append(
                    f"{where}: deferral is stale -- {otodo.path} §{osec.num} shipped the work; "
                    f"close it with '> **Resolved:**' -- {short}"
                )

    out += cycles({t.id: set(t.depends_on) for t in todos if t.id}, "TODO")
    sec_edges: dict[str, set[str]] = {}
    for t in todos:
        for num, s in t.sections.items():
            sec_edges[f"{t.id} §{num}"] = {
                f"{r[0]} §{r[1]}" for raw in s.depends_on if (r := g.resolve_ref(raw, t))
            }
    out += cycles(sec_edges, "section")
    return out


def cmd_validate(_args) -> int:
    todos = load_todos()
    found = problems(todos)
    for p in found:
        print(f"FATAL {p}")
    print(f"\n{len(todos)} todos, {sum(len(t.sections) for t in todos)} sections -- {len(found)} fatal")
    return 1 if found else 0


# --------------------------------------------------------------------- query


def _load_sibling(filename: str, modname: str):
    path = Path(__file__).with_name(filename)
    spec = importlib.util.spec_from_file_location(modname, path)
    mod = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = mod
    spec.loader.exec_module(mod)
    return mod


def cmd_query(args) -> int:
    if args.what == "adjacency":
        adj = _load_sibling("todo-adjacency.py", "todo_adjacency")
        return adj.cli(sys.modules[__name__], args)
    if args.what == "night-debt":
        nd = _load_sibling("todo-night-debt.py", "todo_night_debt")
        return nd.cli(["--json"] if getattr(args, "json", False) else [])

    todos = load_todos()
    g = Graph(todos)
    if args.what == "stats":
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
        print("todo status      " + ", ".join(f"{k}={v}" for k, v in sorted(by_status.items())))
        near = sorted(
            ((len(t.sections), t.path) for t in todos if len(t.sections) >= MAX_SECTIONS_PER_FILE - 5),
            reverse=True,
        )
        if near:
            print(f"section cap      {MAX_SECTIONS_PER_FILE} per file; nearest:")
            for count, path in near:
                left = MAX_SECTIONS_PER_FILE - count
                label = f"{left} left" if left > 0 else "at cap" if left == 0 else "OVER CAP"
                print(f"  {count:>3}  {label:<9}  {path}")
        return 0

    if args.what == "deferred":
        open_ = [(t, d) for t in todos for d in t.deferred if not d.resolved]
        closed = [(t, d) for t in todos for d in t.deferred if d.resolved]
        for heading, rows in (("OPEN -- owed to another section", open_), ("\nRESOLVED -- closed, kept for the record", closed)):
            print(heading)
            if not rows:
                print("    (none)")
            for t, d in rows:
                print(f"    {t.path}:{d.line}  -> {d.ref or 'NO OWNER'}")
                print(f"        {d.body[:150]}")
        print(f"\n{len(open_)} open, {len(closed)} resolved")
        return 0

    rows = [
        (t, num, s, [label for label, _ in g.unmet(t, num)])
        for t in todos
        for num, s in sorted(t.sections.items())
        if s.status != "x" and not s.moved
    ]
    if args.what == "ready":
        ctx = set(args.context) if args.context is not None else detect_context()
        ready = sorted((r for r in rows if not r[3]), key=lambda r: (r[0].domain, r[0].number, r[2].order or 0))
        now, elsewhere = [], []
        for r in ready:
            s = r[2]
            missing = [v for v in s.requires if v not in ctx] + [f"unknown:{v}" for v in s.requires_unknown]
            if s.requires_has_line and not s.requires and not s.requires_unknown:
                missing.append("no values (see validate)")
            (elsewhere if missing else now).append((r, missing))
        if getattr(args, "json", False):
            print(json.dumps([
                {"ref": t.ref(num), "path": t.path, "section": num, "deliverable": s.deliverable, "needs": s.needs}
                for (t, num, s, _), _missing in now
            ], indent=2))
            return 0
        for (t, num, s, _), _missing in now:
            print(f"{t.domain}/{Path(t.path).name} §{num}  {s.deliverable}")
        if elsewhere:
            print(f"\nrunnable elsewhere (context: {', '.join(sorted(ctx)) or 'none'}):")
            for (t, num, s, _), missing in elsewhere:
                reqs = ", ".join(s.requires + [f"unknown:{v}" for v in s.requires_unknown]) or s.requires_raw
                print(f"{t.domain}/{Path(t.path).name} §{num}  {s.deliverable}  requires {reqs} (missing: {', '.join(missing)})")
        print(f"\n{len(now)} runnable now, {len(elsewhere)} runnable elsewhere")
        return 0

    blocked = sorted((r for r in rows if r[3]), key=lambda r: (r[0].domain, r[0].number, r[1]))
    for t, num, s, missing in blocked:
        print(f"{t.domain}/{Path(t.path).name} §{num}  {s.deliverable}")
        print(f"    waiting on: {', '.join(missing)}")
    print(f"\n{len(blocked)} section(s) blocked")
    return 0


# ------------------------------------------------------------------- resolve


def cmd_resolve(args) -> int:
    """Any pasted reference to its file and state.

    Exit codes: 0 ready, 1 unknown, 2 unparseable, 3 already [x], 4 unmet dependencies, 5 moved.
    """
    raw = " ".join(args.ref).strip()
    if not raw:
        print("nothing to resolve", file=sys.stderr)
        return 2
    g = Graph(load_todos())
    target, sec, error = g.find(raw)
    if target is None:
        print(error, file=sys.stderr)
        return 2 if error.startswith("no section reference") else 1
    if sec not in target.sections:
        print(f"{target.path} has no §{sec}", file=sys.stderr)
        return 1
    s = target.sections[sec]
    unmet = [dnn for _, dnn in g.unmet(target, sec)]
    print(f"path       {target.path}")
    print(f"section    §{sec} -- {s.title}")
    print(f"ref        {target.ref(sec)}")
    print(f"status     [{s.status}]  ({s.items_done}/{s.items_total} items)")
    print(f"deps       {', '.join(s.depends_on) if s.depends_on else '--'}")
    if s.moved:
        print(f"moved      {s.moved}")
    if s.needs_raw:
        print(f"needs      {', '.join(s.needs) or 'UNKNOWN -- not in the closed list'} ({s.needs_raw})")
    if s.requires_has_line:
        if s.requires_unknown or not s.requires:
            print(f"requires   {s.requires_raw}; INVALID (see validate)")
        else:
            missing = [v for v in s.requires if v not in detect_context()]
            print(f"requires   {s.requires_raw}; {'runnable here' if not missing else 'missing here: ' + ', '.join(missing)}")
    if unmet:
        print(f"UNMET      {', '.join(unmet)}")
    print()
    print(f"skill arg  {target.path.split('todo/', 1)[-1]} §{sec}")
    if s.moved:
        print(f"\nNOTE: §{sec} is worked outside the tree: {moved_target(s.moved) or s.moved}.", file=sys.stderr)
        return 5
    if s.status == "x":
        print(f"\nNOTE: §{sec} is already [x].", file=sys.stderr)
        return 3
    if unmet:
        print(f"\nNOTE: {len(unmet)} unmet dependency; ship those first.", file=sys.stderr)
        return 4
    return 0


# ---------------------------------------------------------------------- plan

# "| [ ] | `D05 T02 §3` | Deliverable | 8 |"
PLAN_ROW_RE = re.compile(r"^\|\s*\[(?P<box>[ x/])\]\s*\|\s*`(?P<ref>D\d{2}\s+T\d{2}\s+§\d+)`\s*\|")
# The line a Moved section leaves where its row was.
PLAN_MOVED_RE = re.compile(r"^>\s*\*\*Moved:\*\*\s*`(?P<ref>D\d{2}\s+T\d{2}\s+§\d+)`")
PLAN_PROGRESS_RE = re.compile(r"^(?P<prefix>>\s+\*\*Progress:\*\*\s+).*$", re.M)
PLAN_ITEM_TAIL_RE = re.compile(r"\|\s*(?P<n>\d+)\s*\|\s*$")
SEP_CELL_RE = re.compile(r"^:?-+:?$")
PLAN_HEADING_RE = re.compile(r"^(?P<marks>#{1,6})\s")
PLAN_PHASE_RE = re.compile(r"^### Phase\b")
STRAY_ADVICE = "Move each row into its phase's table, then run `python3 scripts/todo-graph.py plan --sync`."


def _width(s: str) -> int:
    """Display width: wide glyphs take two columns."""
    return sum(2 if unicodedata.east_asian_width(c) in ("W", "F") else 1 for c in s)


def _split_row(line: str) -> list[str] | None:
    """Table cells; a pipe inside `inline code` or escaped is content."""
    s = line.strip()
    if not (s.startswith("|") and s.endswith("|")) or len(s) < 2:
        return None
    body = s[1:-1]
    cells, buf, tick, i = [], [], False, 0
    while i < len(body):
        c = body[i]
        if c == "`":
            tick = not tick
            buf.append(c)
        elif c == "\\" and i + 1 < len(body):
            buf += [c, body[i + 1]]
            i += 1
        elif c == "|" and not tick:
            cells.append("".join(buf).strip())
            buf = []
        else:
            buf.append(c)
        i += 1
    cells.append("".join(buf).strip())
    return cells


def align_tables(text: str) -> str:
    """Pad every well-formed markdown table's columns to a common width."""
    lines = text.split("\n")
    out: list[str] = []
    i = 0
    while i < len(lines):
        if not lines[i].strip().startswith("|"):
            out.append(lines[i])
            i += 1
            continue
        j = i
        while j < len(lines) and lines[j].strip().startswith("|"):
            j += 1
        block = lines[i:j]
        i = j
        rows = [_split_row(b) for b in block]
        sep_at = next((k for k, r in enumerate(rows) if r and all(SEP_CELL_RE.match(c) for c in r)), None)
        if sep_at is None or any(r is None for r in rows) or any(len(r) != len(rows[sep_at]) for r in rows):
            out.extend(block)
            continue
        ncol = len(rows[sep_at])
        align = [
            "center" if c.startswith(":") and c.endswith(":") else "right" if c.endswith(":") else "left"
            for c in rows[sep_at]
        ]
        widths = [max(3, max(_width(r[k]) for n, r in enumerate(rows) if n != sep_at)) for k in range(ncol)]
        for n, r in enumerate(rows):
            cells = []
            for k in range(ncol):
                w = widths[k]
                if n == sep_at:
                    cells.append(":" + "-" * (w - 2) + ":" if align[k] == "center" else "-" * (w - 1) + ":" if align[k] == "right" else "-" * w)
                    continue
                pad = w - _width(r[k])
                if align[k] == "center":
                    cells.append(" " * (pad // 2) + r[k] + " " * (pad - pad // 2))
                elif align[k] == "right":
                    cells.append(" " * pad + r[k])
                else:
                    cells.append(r[k] + " " * pad)
            out.append("| " + " | ".join(cells) + " |")
    return "\n".join(out)


def _items_table_next(line: str, current: str) -> str:
    """Where the lines after `line` sit: "" (no table), "header:N" (an N-cell Items header awaiting its delimiter
    row) or "table".

    A table is a header row with an Items column and the delimiter row directly under it, with as many cells; a header
    without that delimiter is paragraph text and so are the rows under it. A blank line ends a Markdown table, so it
    ends membership too: a row after it is in no table."""
    if not line.startswith("|"):
        return ""
    if PLAN_ROW_RE.match(line):
        return current if current == "table" else ""
    cells = [c.strip() for c in line.strip().strip("|").split("|")]
    if current.startswith("header:"):
        return "table" if all(SEP_CELL_RE.match(c) for c in cells) and len(cells) == int(current[7:]) else ""
    return f"header:{len(cells)}" if "Items" in cells else ""


def _in_phase_next(line: str, current: bool) -> bool:
    """Whether the lines after `line` sit under a `### Phase` heading.

    A phase runs from its heading to the next heading of the same or a higher level; a deeper one stays inside."""
    m = PLAN_HEADING_RE.match(line)
    if m is None or len(m.group("marks")) > 3:
        return current
    return bool(PLAN_PHASE_RE.match(line))


def cmd_plan(args) -> int:
    """Sync (default) or check implementation-plan.md's boxes and Items counts against the graph."""
    if not PLAN.exists():
        print(f"{PLAN} does not exist.", file=sys.stderr)
        return 2
    todos = load_todos()
    state, item_counts, moved = {}, {}, {}
    for t in todos:
        for num, s in t.sections.items():
            if s.moved:
                moved[t.ref(num)] = s.moved
            else:
                state[t.ref(num)] = s.status
                item_counts[t.ref(num)] = s.items_total

    out: list[str] = []
    stale, unknown, seen, moved_rows, stale_notes = [], [], [], [], []
    stray: list[str] = []  # rows in no phase table: no runner reaches them in table order
    noted: set[str] = set()
    pending_notes: list[str] = []  # Moved lines, written where the table that held the row ends
    items_table = ""
    in_phase = False

    def flush_notes(next_line: str | None) -> None:
        if not pending_notes:
            return
        if out and out[-1].strip():
            out.append("")
        out.extend(pending_notes)
        pending_notes.clear()
        if next_line is not None and next_line.strip():
            out.append("")

    for lineno, line in enumerate(PLAN.read_text(encoding="utf-8").splitlines(), 1):
        note = PLAN_MOVED_RE.match(line)
        if note:
            ref = re.sub(r"\s+", " ", note.group("ref"))
            if ref in moved and ref not in noted:
                noted.add(ref)
                out.append(f"> **Moved:** `{ref}` -- {moved[ref]}")
            else:
                stale_notes.append(ref)
            items_table = ""  # a note is not a table line: it ends the table above it, so a row under it is in none
            continue
        m = PLAN_ROW_RE.match(line)
        if not m:
            items_table = _items_table_next(line, items_table)
            in_phase = _in_phase_next(line, in_phase)
            if pending_notes and not line.startswith("|"):
                flush_notes(line)
            out.append(line)
            continue
        ref = re.sub(r"\s+", " ", m.group("ref"))
        if not (in_phase and items_table == "table"):
            where = "sits in no table with an Items header" if in_phase else "sits under no `### Phase` heading"
            stray.append(f"{PLAN.name} line {lineno}: the row for {ref} is outside every phase table ({where})")
        if ref in moved:
            moved_rows.append(ref)
            if ref not in noted:
                noted.add(ref)
                pending_notes.append(f"> **Moved:** `{ref}` -- {moved[ref]}")
            continue
        seen.append(ref)
        if ref not in state:
            unknown.append(ref)
            out.append(line)
            continue
        want = state[ref]
        if want != m.group("box"):
            stale.append(f"{ref}: plan says [{m.group('box')}], graph says [{want}]")
        line = line[: m.start("box")] + want + line[m.end("box"):]
        if items_table == "table":
            tail = PLAN_ITEM_TAIL_RE.search(line)
            if tail is None:
                stale.append(f"{ref}: plan row has no Items count, graph says {item_counts[ref]}")
            elif int(tail.group("n")) != item_counts[ref]:
                stale.append(f"{ref}: plan says {tail.group('n')} items, graph says {item_counts[ref]}")
                line = line[: tail.start("n")] + str(item_counts[ref]) + line[tail.end("n"):]
        out.append(line)
    flush_notes(None)

    dupes = sorted({r for r in seen if seen.count(r) > 1})
    missing = [r for r in state if r not in seen]
    done = sum(1 for r in seen if state.get(r) == "x")
    total = len(seen)
    pct = round(done / total * 100) if total else 0
    summary = (
        f"**{done} of {total} sections complete ({pct}%).** Derived from the Implementation Order "
        f"tables by `python3 scripts/todo-graph.py plan --sync` -- never edited by hand."
    )
    text, n = PLAN_PROGRESS_RE.subn(lambda mo: mo.group("prefix") + summary, "\n".join(out) + "\n", count=1)
    if n == 0:
        print("warning: no '> **Progress:**' line in the plan to update.", file=sys.stderr)
    for ref in unknown:
        print(f"::error::{PLAN.name} references {ref}, which is not in the graph")

    if stray and not args.check:
        # Refused, and nothing written: a sync that rewrote the file around a stray row would bless where it sits.
        for e in stray:
            print(f"::error::{e}")
        print(STRAY_ADVICE, file=sys.stderr)
        return 1

    if args.check:
        errors = (
            stray
            + [f"{PLAN.name} is stale -- {s}" for s in stale]
            + [f"{PLAN.name} lists moved section {r} as a row" for r in moved_rows]
            + [f"{PLAN.name} carries a stale Moved line for {r}" for r in stale_notes]
            + [f"{PLAN.name} lists {r} in more than one phase" for r in dupes]
        )
        if missing:
            errors.append(
                f"{len(missing)} section(s) have no row in the plan: "
                + ", ".join(sorted(missing)[:8]) + ("..." if len(missing) > 8 else "")
            )
        for e in errors:
            print(f"::error::{e}")
        if errors or unknown:
            # A sync would be refused for the same stray rows, so with one present it is not the remedy.
            print(STRAY_ADVICE if stray else "Run `python3 scripts/todo-graph.py plan --sync`.", file=sys.stderr)
            return 1
        print(f"implementation plan is current -- {done}/{total} sections complete ({pct}%)")
        return 0

    PLAN.write_text(align_tables(text), encoding="utf-8", newline="\n")  # LF: .gitattributes pins *.md
    print(f"synced {total} row(s) -- {done} complete ({pct}%), {len(stale)} box(es) changed")
    for r in dupes:
        print(f"  WARNING: {r} appears in more than one phase")
    for r in moved_rows:
        print(f"  moved: {r} -- row replaced by a Moved line")
    for r in stale_notes:
        print(f"  dropped a stale Moved line for {r}")
    for s in stale:
        print(f"  {s}")
    if missing:
        print(f"  NOTE: {len(missing)} section(s) appear in no phase -- run with --check for the list")
    return 0


# ----------------------------------------------------------------- self-test

FIXTURE_A = """---
id: alpha
domain: 00-core
status: active
title: "TODO-01 -- Alpha"
---

# TODO-01 -- Alpha

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | First | -- |  [x]   |
|   2   |   §2    | Second | §1 |  [ ]   |
|   3   |   §3    | Third | D01 T01 §1 |  [ ]   |

## 1. First

- [x] Build it. -> XREF: D01 T01 §1

**Test checkpoint:** `dotnet test` green.

> **Verified:** 2026-10-18 | §1 | 3 passed
> **Review:** Opus, approve

## 2. Second

- [ ] Build it.

**Test checkpoint:** green.

## 3. Third

- [ ] Build it.

**Requires:** operator -- needs a person at the keyboard

**Test checkpoint:** green.

## Verification
"""

FIXTURE_B = """---
id: beta
domain: 01-app
status: draft
title: "TODO-01 -- Beta"
---

# TODO-01 -- Beta

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Beta one | D00 T01 §1 |  [ ]   |
|   2   |   §2    | Beta two | -- |  [ ]   |

## 1. Beta one

- [ ] Build it. -> XREF: D00 T01 §1

**Test checkpoint:** green.

## 2. Beta two

> **Moved:** worked in todo/01-app/TODO-01-beta.md

- [ ] Build it.

**Test checkpoint:** green.
"""

FIXTURE_PLAN = """# Plan

> **Progress:** stale.

### Phase 0 -- Fixture

| Box | Ref | Deliverable | Items |
| :-: | --- | ----------- | :---: |
| [ ] | `D00 T01 §1` | First | 1 |
| [ ] | `D00 T01 §2` | Second | 1 |
| [ ] | `D00 T01 §3` | Third | 9 |
| [ ] | `D01 T01 §1` | Beta one | 1 |
| [ ] | `D01 T01 §2` | Beta two | 1 |
"""


def cmd_self_test(_args) -> int:
    global TODO_DIR, PLAN
    saved = (TODO_DIR, PLAN)
    failures: list[str] = []
    cases = 0

    def check(name: str, got, want) -> None:
        nonlocal cases
        cases += 1
        if got != want:
            failures.append(f"{name}: got {got!r}, want {want!r}")

    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp) / "todo"

        def write(a: str = FIXTURE_A, b: str = FIXTURE_B, plan: str = FIXTURE_PLAN) -> None:
            for domain, name, text in (("00-core", "TODO-01-alpha.md", a), ("01-app", "TODO-01-beta.md", b)):
                (root / domain).mkdir(parents=True, exist_ok=True)
                (root / domain / name).write_text(text, encoding="utf-8")
                (root / domain / "INDEX.md").write_text(f"[{name}](./{name})\n", encoding="utf-8")
            (root / "implementation-plan.md").write_text(plan, encoding="utf-8")

        def found(a: str = FIXTURE_A, b: str = FIXTURE_B) -> list[str]:
            write(a, b)
            return problems(load_todos())

        def red(name: str, needle: str, a: str = FIXTURE_A, b: str = FIXTURE_B) -> None:
            got = found(a, b)
            check(name, any(needle in p for p in got), True)

        TODO_DIR, PLAN = root, root / "implementation-plan.md"
        try:
            check("clean fixture validates", found(), [])
            todos = load_todos()
            g = Graph(todos)
            alpha = g.by_id["alpha"]
            check("verified covers §1", alpha.verified_sections, {1})
            check("row deps parse", alpha.sections[2].depends_on, ["§1"])
            check("requires parse", (alpha.sections[3].requires, alpha.sections[3].requires_reason), (["operator"], "needs a person at the keyboard"))
            check("moved parse", bool(g.by_id["beta"].sections[2].moved), True)
            check("cross-domain resolve", g.resolve_ref("D01 T01 §1", alpha), ("beta", 1))
            check("same-file resolve", g.resolve_ref("§2", alpha), ("alpha", 2))
            check("unmet open dependency", g.unmet(alpha, 3), [("beta §1", "D01 T01 §1")])
            check("met dependency", g.unmet(alpha, 2), [])
            write(b=FIXTURE_B.replace("| Beta one | D00 T01 §1 |", "| Beta one | D00 T01 §1, §2 |"))
            g2 = Graph(load_todos())
            check("moved section counts as met", g2.unmet(g2.by_id["beta"], 1), [])
            write(a=FIXTURE_A.replace("title:", "depends_on: [beta]\ntitle:"))
            g2 = Graph(load_todos())
            check("whole-TODO dependency waits on its open section", [lbl for lbl, _ in g2.unmet(g2.by_id["alpha"], 2)], ["beta (whole TODO)"])
            write(a=FIXTURE_A.replace("| Second | §1 |", "| Second | §1, §7 |"))
            g2 = Graph(load_todos())
            check("unresolvable edge is unmet", g2.unmet(g2.by_id["alpha"], 2), [("alpha §7", "alpha §7")])
            write()
            check("parse_verified range", parse_verified("2026-10-18 | §1-§3, §5 | ok"), ([1, 2, 3, 5], ""))
            check("parse_verified bad date", parse_verified("2026-02-30 | §1 | ok")[0], [])
            check("parse_verified no evidence", parse_verified("2026-10-18 | §1 |  ")[1], "has an empty evidence field")
            check("parse_verified cap", bool(parse_verified("2026-10-18 | §1-§66 | ok")[1]), True)
            check("parse_verified cap is across elements", bool(parse_verified("2026-10-18 | §1-§40, §41-§80 | ok")[1]), True)
            check("detect_context console", detect_context("win32", {"SESSIONNAME": "Console"}), {"display-session"})
            check("detect_context services", detect_context("win32", {"SESSIONNAME": "Services"}), set())
            check("find by DNN", g.find("| [ ] | `D01 T01 §2` | x |")[:2], (g.by_id["beta"], 2))
            check("find by path", g.find("00-core/TODO-01-alpha.md §3")[:2], (alpha, 3))
            check("find unparseable", g.find("nothing")[0], None)

            # One red fixture per rule.
            red("row without body", "has no '## 4.' body section",
                FIXTURE_A.replace("|   3   |   §3    | Third | D01 T01 §1 |  [ ]   |",
                                  "|   3   |   §3    | Third | D01 T01 §1 |  [ ]   |\n|   4   |   §4    | Ghost | -- |  [ ]   |"))
            red("body without row", "has no Implementation Order row", FIXTURE_A + "\n## 9. Stray\n\n- [ ] x\n\n**Test checkpoint:** g.\n")
            red("no test checkpoint", "has no '**Test checkpoint:**'", FIXTURE_A.replace("**Test checkpoint:** `dotnet test` green.", ""))
            red("no checklist items", "has no checklist items", FIXTURE_A.replace("- [ ] Build it.\n\n**Test checkpoint:** green.\n\n## 3.", "**Test checkpoint:** green.\n\n## 3."))
            red("[x] without stamp", "no '> **Verified:**' stamp covers it", FIXTURE_A.replace("> **Verified:** 2026-10-18 | §1 | 3 passed\n", ""))
            red("malformed stamp", "refused '> **Verified:**", FIXTURE_A.replace("2026-10-18 | §1 | 3 passed", "yesterday | §1 | 3 passed"))
            red("orphaned item in shipped section", "unticked item", FIXTURE_A.replace("- [x] Build it. -> XREF: D01 T01 §1", "- [x] Build it. -> XREF: D01 T01 §1\n- [ ] Forgot this"))
            red("unresolved depends", "does not resolve", FIXTURE_A.replace("| Second | §1 |", "| Second | Q |"))
            red("missing depends target", "which does not exist", FIXTURE_A.replace("| Second | §1 |", "| Second | §7 |"))
            red("section cycle", "section dependency cycle", FIXTURE_A.replace("| First | -- |", "| First | §2 |"))
            red("todo cycle", "TODO dependency cycle",
                FIXTURE_A.replace("title:", "depends_on: [beta]\ntitle:"), FIXTURE_B.replace("title:", "depends_on: [alpha]\ntitle:"))
            red("unknown todo dependency", "does not match any TODO id", FIXTURE_A.replace("title:", "depends_on: [gamma]\ntitle:"))
            red("one-sided xref", "is one-sided", FIXTURE_A, FIXTURE_B.replace("- [ ] Build it. -> XREF: D00 T01 §1", "- [ ] Build it."))
            red("missing field", "missing required field 'title'", FIXTURE_A.replace('title: "TODO-01 -- Alpha"\n', ""))
            red("bad status", "not one of", FIXTURE_A.replace("status: active", "status: someday"))
            red("bad id", "fails ^[a-z]", FIXTURE_A.replace("id: alpha", "id: Alpha"))
            red("duplicate id", "duplicate id", FIXTURE_A, FIXTURE_B.replace("id: beta", "id: alpha"))
            red("superseded without successor", "superseded_by is unset", FIXTURE_A.replace("status: active", "status: superseded"))
            red("unknown needs", "has **Needs:**", FIXTURE_A.replace("**Requires:** operator", "**Needs:** a laptop\n\n**Requires:** operator"))
            red("unknown requires", "has **Requires:** wizard", FIXTURE_A.replace("**Requires:** operator", "**Requires:** wizard"))
            red("requires without reason", "with no reason", FIXTURE_A.replace(" -- needs a person at the keyboard", ""))
            red("manual without operator", "without **Requires:** operator",
                FIXTURE_A.replace("**Requires:** operator -- needs a person at the keyboard", "**Manual:** operator-only -- by hand"))
            red("moved target missing", "names no existing file", FIXTURE_A, FIXTURE_B.replace("todo/01-app/TODO-01-beta.md", "todo/01-app/gone.md"))
            red("deferral without owner", "names no owner", FIXTURE_A.replace("> **Review:** Opus, approve", "> **Deferred:** polish later"))
            red("deferral owner unknown", "does not resolve to a real section", FIXTURE_A.replace("> **Review:** Opus, approve", "> **Deferred:** polish -> XREF: §8"))
            red("stale deferral", "deferral is stale", FIXTURE_A.replace("> **Review:** Opus, approve", "> **Deferred:** polish -> XREF: §1"))
            check("resolved deferral is clean", found(FIXTURE_A.replace("> **Review:** Opus, approve", "> **Resolved:** polish -> XREF: §1")), [])
            red("stale deferral by ticked item", "deferral is stale",
                FIXTURE_A.replace("- [ ] Build it.\n\n**Test checkpoint:** green.\n\n## 3.", "- [x] Build it.\n\n**Test checkpoint:** green.\n\n## 3.")
                .replace("> **Review:** Opus, approve", "> **Deferred:** polish -> XREF: §2 (item: \"Build it\")"))
            red("xref to a missing section", "names no existing section",
                FIXTURE_A.replace("- [ ] Build it.\n\n**Test checkpoint:** green.\n\n## 3.", "- [ ] Build it. -> XREF: D01 T01 §9\n\n**Test checkpoint:** green.\n\n## 3."))
            check("struck, XREF and Commit items do not orphan a shipped section", found(FIXTURE_A.replace(
                "- [x] Build it. -> XREF: D01 T01 §1", "- [x] Build it. -> XREF: D01 T01 §1\n- [ ] ~~Dropped~~\n- [ ] -> XREF: D01 T01 §1\n- [ ] Commit: later")), [])
            check("stamp-line XREFs count for reciprocity", found(FIXTURE_A, FIXTURE_B.replace(
                "- [ ] Build it. -> XREF: D00 T01 §1", "- [ ] Build it.\n\n> **Deferred:** later -> XREF: D00 T01 §2")), [])
            red("deferral item reworded", "has no such item", FIXTURE_A.replace("> **Review:** Opus, approve", "> **Deferred:** polish -> XREF: §2 (item: \"Paint it\")"))
            write()
            (root / "01-app" / "INDEX.md").write_text("nothing\n", encoding="utf-8")
            check("missing from index", any("not listed in" in p for p in problems(load_todos())), True)
            def sized(total: int) -> str:
                return FIXTURE_A.replace("## Verification", "".join(
                    f"## {n}. S{n}\n\n- [ ] x\n\n**Test checkpoint:** g.\n\n" for n in range(4, total + 1)
                ) + "## Verification").replace(
                    "|   3   |   §3    | Third | D01 T01 §1 |  [ ]   |",
                    "|   3   |   §3    | Third | D01 T01 §1 |  [ ]   |\n" + "\n".join(f"| {n} | §{n} | S{n} | -- | [ ] |" for n in range(4, total + 1)),
                )
            red("section cap", "over the 55 cap", sized(56))
            check("a file at the cap is valid", any("cap" in p for p in found(sized(55))), False)

            # plan --sync then --check.
            write()
            ns = argparse.Namespace(check=False)
            with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                cmd_plan(ns)
                synced = PLAN.read_text(encoding="utf-8")
                check("plan check after sync", cmd_plan(argparse.Namespace(check=True)), 0)
            check("sync flips the box", "| [x] | `D00 T01 §1`" in synced, True)
            check("sync fixes the Items count", "`D00 T01 §3` | Third       |   1   |" in synced, True)
            check("sync replaces a moved row", "> **Moved:** `D01 T01 §2` -- worked in todo/01-app/TODO-01-beta.md" in synced, True)
            check("sync writes progress", "**1 of 4 sections complete (25%).**" in synced, True)
            write()
            with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                check("plan check stale", cmd_plan(argparse.Namespace(check=True)), 1)
            for name, broken in (
                ("duplicate row", synced.replace("| [ ] | `D00 T01 §2`", "| [ ] | `D00 T01 §2` | Second | 1 |\n| [ ] | `D00 T01 §2`", 1)),
                ("moved row", synced + "\n| [ ] | `D01 T01 §2` | Beta two | 1 |\n"),
                ("stale Moved line", synced + "\n> **Moved:** `D00 T01 §2` -- nowhere\n"),
                ("Items drift", synced.replace("Third       |   1   |", "Third       |   7   |")),
            ):
                write(plan=broken)
                with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                    check(f"plan check refuses {name}", cmd_plan(argparse.Namespace(check=True)), 1)
            # A row in no phase table is refused by --check and by --sync, by name and line, and sync writes nothing.
            beta_row = next(row for row in synced.splitlines() if "`D01 T01 §1`" in row) + "\n"
            without = synced.replace(beta_row, "")
            check("the fixture row is there to move", without != synced, True)
            table_end = "> **Moved:** `D01 T01 §2`"
            note_line = next(row for row in synced.split("\n") if row.startswith(table_end))
            after_note = [row for row in synced.split("\n") if row != note_line]
            after_note.insert(next(n for n, row in enumerate(after_note) if row.startswith("| :-:")) + 1, note_line)
            after_note = "\n".join(after_note)
            for name, broken, where in (
                ("after closing prose", without + "\n## What this plan does not do\n\nClosing prose.\n" + beta_row, "under no `### Phase` heading"),
                ("in a whole table after a later heading",
                 without + "\n## After the phases\n\n| Box | Ref | Deliverable | Items |\n| :-: | --- | ----------- | :---: |\n" + beta_row,
                 "under no `### Phase` heading"),
                ("below a paragraph under the phase heading",
                 without.replace(table_end, "A paragraph.\n" + beta_row + "\n" + table_end), "in no table with an Items header"),
                ("under an Items header that lost its delimiter row",
                 "\n".join(ln for ln in synced.split("\n") if not ln.startswith("| :-:")), "in no table with an Items header"),
                ("after the blank line that ends the phase table",
                 without.replace(table_end, beta_row + "\n" + table_end), "in no table with an Items header"),
                ("after a Moved note that follows the table's delimiter row", after_note, "in no table with an Items header"),
            ):
                line_no = broken.splitlines().index(beta_row.rstrip("\n")) + 1
                # Both line endings, compared as bytes: a refused sync that rewrote CRLF as LF would have written.
                for mode, ending in ((True, "\n"), (False, "\n"), (True, "\r\n"), (False, "\r\n")):
                    write()
                    on_disk = broken.replace("\n", ending).encode("utf-8")
                    PLAN.write_bytes(on_disk)
                    said, advice = io.StringIO(), io.StringIO()
                    with contextlib.redirect_stdout(said), contextlib.redirect_stderr(advice):
                        code = cmd_plan(argparse.Namespace(check=mode))
                    label = f"plan {'check' if mode else 'sync'} refuses a row {name} ({'CRLF' if ending == chr(13) + chr(10) else 'LF'})"
                    check(label, code, 1)
                    check(f"{label}, named",
                          f"line {line_no}: the row for D01 T01 §1 is outside every phase table (sits {where})" in said.getvalue(), True)
                    check(f"{label}, file unchanged byte for byte", PLAN.read_bytes(), on_disk)
                    check(f"{label}, says to move the row first", "Move each row into its phase's table, then run" in advice.getvalue(), True)
                    check(f"{label}, never says only to sync", "\nRun `python3 scripts/todo-graph.py plan --sync`." in "\n" + advice.getvalue(), False)
            write(plan=synced)
            with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                check("the same row inside its phase table is accepted", cmd_plan(argparse.Namespace(check=True)), 0)
            write(plan=FIXTURE_PLAN.replace("| [ ] | `D01 T01 §1` | Beta one | 1 |\n", ""))
            with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                cmd_plan(ns)
                check("plan check missing row", cmd_plan(argparse.Namespace(check=True)), 1)
            check("align pads columns", align_tables("| a | bb |\n| - | :-: |\n| ccc | d |"),
                  "| a   | bb  |\n| --- | :-: |\n| ccc |  d  |")

            # query ready and resolve exit codes.
            write()
            out = io.StringIO()
            with contextlib.redirect_stdout(out):
                cmd_query(argparse.Namespace(what="ready", context=[]))
            check("ready lists the first runnable row", out.getvalue().splitlines()[0], "00-core/TODO-01-alpha.md §2  Second")
            check("ready summary", out.getvalue().strip().splitlines()[-1], "2 runnable now, 0 runnable elsewhere")
            out = io.StringIO()
            with contextlib.redirect_stdout(out):
                cmd_query(argparse.Namespace(what="ready", context=[], json=True))
            check("ready json lists first ref", json.loads(out.getvalue())[0]["ref"], "D00 T01 §2")
            out = io.StringIO()
            with contextlib.redirect_stdout(out):
                cmd_query(argparse.Namespace(what="blocked", context=None))
            check("blocked names the wait", "waiting on: beta §1" in out.getvalue(), True)
            write(a=FIXTURE_A.replace("| Third | D01 T01 §1 |", "| Third | -- |"))
            for ctx, want in (([], "requires operator (missing: operator)"), (["operator"], "00-core/TODO-01-alpha.md §3  Third")):
                out = io.StringIO()
                with contextlib.redirect_stdout(out):
                    cmd_query(argparse.Namespace(what="ready", context=ctx))
                check(f"ready splits Requires with context {ctx}", want in out.getvalue(), True)
            write(a=FIXTURE_A.replace("> **Review:** Opus, approve", "> **Deferred:** polish -> XREF: §2"))
            for what, want in (("stats", "sections         5"), ("stats", "moved          1"), ("deferred", "1 open, 0 resolved")):
                out = io.StringIO()
                with contextlib.redirect_stdout(out):
                    cmd_query(argparse.Namespace(what=what, context=None))
                check(f"query {what} reports {want.split()[0]}", want in out.getvalue(), True)
            for total, want in ((55, "55  at cap"), (56, "56  OVER CAP")):
                write(a=sized(total))
                out = io.StringIO()
                with contextlib.redirect_stdout(out):
                    cmd_query(argparse.Namespace(what="stats", context=None))
                check(f"query stats labels {total} sections {want.split(None, 1)[1]}", want in out.getvalue(), True)
            write()
            with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                for ref, want in (("D00 T01 §2", 0), ("D00 T01 §9", 1), ("garbage", 2), ("D00 T01 §1", 3), ("D00 T01 §3", 4), ("D01 T01 §2", 5)):
                    check(f"resolve {ref}", cmd_resolve(argparse.Namespace(ref=[ref])), want)

            # Output stays UTF-8 when the console code page cannot encode the text.
            run_on_fixture = (
                "import importlib.util, pathlib, sys\n"
                "spec = importlib.util.spec_from_file_location('tg', sys.argv[1])\n"
                "m = importlib.util.module_from_spec(spec); sys.modules['tg'] = m; spec.loader.exec_module(m)\n"
                "m.TODO_DIR = pathlib.Path(sys.argv[2]); sys.argv = ['todo-graph', 'resolve', sys.argv[3]]\n"
                "sys.exit(m.main())\n"
            )
            proc = subprocess.run(
                [sys.executable, "-c", run_on_fixture, str(Path(__file__).resolve()), str(root), "→ §1"],
                capture_output=True, env={**os.environ, "PYTHONIOENCODING": "cp1252"},
            )
            check("non-cp1252 output exits cleanly", (proc.returncode, "→".encode() in proc.stderr), (1, True))
        finally:
            TODO_DIR, PLAN = saved

    for f in failures:
        print(f"FAIL {f}")
    print(f"{cases} cases, {len(failures)} failed")
    return 1 if failures else 0


# ---------------------------------------------------------------------- main


def main() -> int:
    # TODO text is UTF-8; a Windows console code page cannot encode all of it.
    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, "reconfigure"):
            stream.reconfigure(encoding="utf-8", errors="replace")
    p = argparse.ArgumentParser(prog="todo-graph", description=__doc__.split("\n")[0])
    sub = p.add_subparsers(dest="cmd", required=True)
    sub.add_parser("validate", help="integrity checks; exit 1 on any problem").set_defaults(fn=cmd_validate)
    sub.add_parser("self-test", help="prove this script against fixtures").set_defaults(fn=cmd_self_test)
    q = sub.add_parser("query", help="ask the graph a question")
    q.add_argument("what", choices=["ready", "blocked", "stats", "deferred", "adjacency", "night-debt"])
    q.add_argument(
        "--context", nargs="*", default=None, choices=sorted(REQUIRES_ALLOWED), metavar="CAP",
        help="ready: evaluate **Requires:** against exactly these capabilities instead of the detected ones",
    )
    q.add_argument("--json", action="store_true", help="ready, adjacency, night-debt: output JSON")
    q.add_argument("--file", help="adjacency: inspect a single TODO file")
    q.add_argument("--at", help="adjacency: inspect at a historical commit")
    q.add_argument("--require-owned", action="store_true", help="adjacency: exit 1 on unowned diagnostics")
    q.add_argument("--require-conformance", action="store_true", help="adjacency: exit 1 on conformance diagnostics")
    q.set_defaults(fn=cmd_query)
    rs = sub.add_parser("resolve", help="turn any section reference into its file and state")
    rs.add_argument("ref", nargs="+", help="'D00 T01 §11', a pasted plan row, or '<path> §N'")
    rs.set_defaults(fn=cmd_resolve)
    pl = sub.add_parser("plan", help="sync implementation-plan.md from the graph")
    mode = pl.add_mutually_exclusive_group()
    mode.add_argument("--check", action="store_true", help="exit 1 when the plan is stale instead of rewriting it")
    mode.add_argument("--sync", action="store_true", help="rewrite the plan (the default)")
    pl.set_defaults(fn=cmd_plan)
    args = p.parse_args()
    return args.fn(args)


if __name__ == "__main__":
    sys.exit(main())
