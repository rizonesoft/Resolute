#!/usr/bin/env python3
"""One-way ratchet over clang-tidy findings, per target (D07 T01 section 2).

Owns what scripts/check-all.ps1's tidy gate used to inline: running
clang-tidy over every compile database, counting unique findings per
target and globally, comparing against todo/.tidy-baseline, refusing a
silent baseline raise, rewriting the baseline down when the count
drops, and refusing duplicate resource ids. Stdlib only, like every
TODO tool here.

Counting rule (todo/.tidy-baseline is the authority): unique
(file, line, column, check) tuples with the path normalised
(separators to '/', '..' collapsed, case folded), findings inside
_deps/ excluded. Check names carry uppercase and dots
(clang-analyzer-security.ArrayBound); the character class must too.
Per-target counts deduplicate within one compile database; the total
deduplicates globally, so a shared-header finding counts once per
surfacing target and once in the total, and total <= sum(targets).

Exit codes: 0 pass (a rewrite-down is a pass that says so), 1 refusal.
Nothing is rewritten on a refusal, an incomplete analysis, or a
malformed baseline.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

FINDING_RE = re.compile(
    r"^(?P<file>.*?):(?P<line>\d+):(?P<col>\d+):\s+warning:\s+.*?\[(?P<check>[A-Za-z0-9_.,-]+)\]\s*$"
)
COUNT_RE = re.compile(r"^count:\s*(\d+)$")
TARGET_RE = re.compile(r"^target\s+([A-Za-z0-9_.-]+):\s*(\d+)$")
RAISED_RE = re.compile(
    r"^#\s*Raised\s+(?P<target>[A-Za-z0-9_.-]+)\s+(?P<old>\d+)\s*->\s*(?P<new>\d+)\s+on\s+(?P<date>\d{4}-\d{2}-\d{2}):\s*(?P<reason>\S.*)$"
)
ERROR_RE = re.compile(r"clang-diagnostic-error|error: |Error while processing")


class Refusal(Exception):
    """A named reason the ratchet will not pass."""


def normalise_file(raw: str, root: Path) -> str:
    p = raw.replace("\\", "/")
    try:
        p = Path(p)
        if not p.is_absolute():
            p = (root / p)
        p = os.path.normpath(str(p)).replace("\\", "/")
    except (OSError, ValueError):
        pass
    return str(p).lower()


def collect_findings(lines, root: Path) -> set:
    """Unique (file,line,col,check) keys from clang-tidy output lines."""
    seen = set()
    for text in lines:
        m = FINDING_RE.match(text.rstrip("\n"))
        if not m:
            continue
        f = normalise_file(m.group("file"), root)
        if "/_deps/" in f:
            continue
        seen.add(f"{f}|{m.group('line')}|{m.group('col')}|{m.group('check')}")
    return seen


def parse_baseline(text: str, expected_targets) -> dict:
    """Validate the baseline grammar; return {'count': n, 'targets': {...}}.

    Grammar: comment lines start with '#'; exactly one 'count: <n>';
    exactly one 'target <name>: <n>' per expected target; no unknown
    non-comment lines; count <= sum(targets). Any violation is a
    Refusal naming the defect.
    """
    count = None
    targets = {}
    for lineno, raw in enumerate(text.splitlines(), 1):
        t = raw.strip()
        if not t or t.startswith("#"):
            continue
        m = COUNT_RE.match(t)
        if m:
            if count is not None:
                raise Refusal(f"baseline line {lineno}: duplicate 'count:' line")
            count = int(m.group(1))
            continue
        m = TARGET_RE.match(t)
        if m:
            name = m.group(1)
            if name in targets:
                raise Refusal(f"baseline line {lineno}: duplicate target '{name}'")
            if name not in expected_targets:
                raise Refusal(f"baseline line {lineno}: unknown target '{name}'")
            targets[name] = int(m.group(2))
            continue
        raise Refusal(f"baseline line {lineno}: unrecognised line {t!r}")
    if count is None:
        raise Refusal("baseline has no 'count: <n>' line")
    for name in expected_targets:
        if name not in targets:
            raise Refusal(f"baseline has no 'target {name}:' line")
    if count > sum(targets.values()):
        raise Refusal(
            f"baseline count {count} exceeds the per-target sum {sum(targets.values())}; "
            "the total deduplicates globally and cannot exceed it"
        )
    return {"count": count, "targets": targets}


def raised_lines(text: str) -> list:
    out = []
    for raw in text.splitlines():
        m = RAISED_RE.match(raw.strip())
        if m:
            out.append(
                (m.group("target"), int(m.group("old")), int(m.group("new")), raw.strip())
            )
    return out


def parse_baseline_lenient(text: str) -> dict:
    """Parse a base-revision baseline in its own era's grammar.

    The base predates today's target set whenever a tool was added, so
    it is parsed for the count and target lines it actually carries
    instead of being validated against today's expected targets:
    discarding its per-target counts on a validation failure would
    silently drop raise protection for every existing target exactly
    when a new target arrives (review round 1). Duplicate or
    unrecognised lines still refuse, naming the base as malformed.
    """
    count = None
    targets = {}
    for lineno, raw in enumerate(text.splitlines(), 1):
        t = raw.strip()
        if not t or t.startswith("#"):
            continue
        m = COUNT_RE.match(t)
        if m:
            if count is not None:
                raise Refusal(f"base baseline line {lineno}: duplicate 'count:' line")
            count = int(m.group(1))
            continue
        m = TARGET_RE.match(t)
        if m:
            if m.group(1) in targets:
                raise Refusal(f"base baseline line {lineno}: duplicate target '{m.group(1)}'")
            targets[m.group(1)] = int(m.group(2))
            continue
        raise Refusal(f"base baseline line {lineno}: unrecognised line {t!r}")
    if count is None:
        raise Refusal("base baseline has no 'count: <n>' line; the raise guard cannot run")
    return {"count": count, "targets": targets}


def check_raise_guard(current_text: str, base_text, expected_targets) -> list:
    """Refuse a baseline raise that no new recorded reason authorizes.

    Compares the current baseline against the base revision's. Every
    target (and the total, as target 'total') whose count rose needs a
    '# Raised <target> <old> -> <new> on <date>: <reason>' line present
    now and absent at base, matching the exact transition. A target
    the base does not carry (a newly added tool, in a base that has
    per-target lines at all) compares against 0, so new coverage is
    authorized the same way as a raise. A scalar-era base (no target
    lines) compares only the total. Returns the authorizing lines so
    the gate can name them.
    """
    if base_text is None:
        raise Refusal(
            "no base baseline to compare against; the raise guard fails closed "
            "(pass --base <rev> naming a revision that carries todo/.tidy-baseline)"
        )
    base = parse_baseline_lenient(base_text)
    current = parse_baseline(current_text, expected_targets)
    base_lines = {line for _, _, _, line in raised_lines(base_text)}
    new_lines = [r for r in raised_lines(current_text) if r[3] not in base_lines]

    def authorized(target, old, new):
        for t, o, n, line in new_lines:
            if t == target and o == old and n == new:
                return line
        return None

    named = []
    if current["count"] > base["count"]:
        line = authorized("total", base["count"], current["count"])
        if line is None:
            raise Refusal(
                f"baseline total raised {base['count']} -> {current['count']} without a new "
                f"'# Raised total {base['count']} -> {current['count']} on <date>: <reason>' line"
            )
        named.append(line)
    for name in expected_targets:
        old = base["targets"].get(name)
        if old is None and base["targets"]:
            old = 0
        new = current["targets"][name]
        if old is not None and new > old:
            line = authorized(name, old, new)
            if line is None:
                raise Refusal(
                    f"baseline target '{name}' raised {old} -> {new} without a new "
                    f"'# Raised {name} {old} -> {new} on <date>: <reason>' line"
                )
            named.append(line)
    return named


def rewrite_baseline(text: str, measured_count: int, measured_targets: dict) -> str:
    """Return the baseline text with counts rewritten down to measured.

    A '# Raised' line whose <new> was the value just rewritten down is
    adjusted to the measured value: an authorized raise to 177 that
    measurement then writes down to 173 must still authorize 173 on
    the next unchanged run, or the rewrite produces a baseline its
    own guard refuses (completion review gap 1). The reason text is
    untouched; only the ceiling it recorded follows the measurement.
    """
    current = parse_baseline_lenient(text)
    ceilings = {"total": (current["count"], measured_count)}
    for name, val in current["targets"].items():
        if name in measured_targets:
            ceilings[name] = (val, measured_targets[name])
    out = []
    for raw in text.splitlines():
        t = raw.strip()
        if COUNT_RE.match(t):
            out.append(f"count: {measured_count}")
            continue
        m = TARGET_RE.match(t)
        if m:
            out.append(f"target {m.group(1)}: {measured_targets[m.group(1)]}")
            continue
        m = RAISED_RE.match(t)
        if m and m.group("target") in ceilings:
            old_ceiling, measured = ceilings[m.group("target")]
            if int(m.group("new")) == old_ceiling and measured < old_ceiling:
                # Replace the matched numeric span itself: the grammar
                # accepts any spacing around '->', so a literal spaced
                # substring would miss '5->9' (repair plan review).
                indent = len(raw) - len(raw.lstrip())
                start, end = m.span("new")
                raw = raw[: indent + start] + str(measured) + raw[indent + end :]
        out.append(raw)
    return "\n".join(out) + "\n"


def write_atomic(path: Path, text: str) -> None:
    """Replace a file atomically and read it back (AGENTS.md: atomic
    writes, readback). A failed write leaves the original intact."""
    tmp = path.with_name(path.name + ".tmp")
    try:
        tmp.write_text(text)
        os.replace(tmp, path)
    except OSError as exc:
        try:
            tmp.unlink()
        except OSError:
            pass
        raise Refusal(f"could not persist {path}: {exc}") from exc
    if path.read_text() != text:
        raise Refusal(f"readback mismatch after writing {path}; baseline not trusted")


ID_CLASSES = ("IDI", "IDC", "IDM", "IDS", "IDD", "IDB", "IDA", "IDR")
DEFINE_RE = re.compile(r"^\s*#define\s+(ID[A-Z]_[A-Za-z0-9_]+)\s+(0[xX][0-9A-Fa-f]+|\d+)")
INCLUDE_RE = re.compile(r'^\s*#include\s+"([^"]+)"')
RC_STMT_RE = re.compile(r"^\s*(0[xX][0-9A-Fa-f]+|\d+)\s+(ICON|BITMAP|CURSOR|24|RT_MANIFEST)\b")


def resource_namespaces(root: Path) -> list:
    """One namespace per .rc/.rc.in outside build trees: its own lines
    plus the headers it includes by quoted path (transitively)."""
    scripts = []
    for base in (root / "src", root / "shared", root / "extensions"):
        if not base.is_dir():
            continue
        for p in sorted(base.rglob("*")):
            if "build" in p.parts:
                continue
            if p.suffix == ".rc" or p.name.endswith(".rc.in"):
                scripts.append(p)
    namespaces = []
    for script in scripts:
        files = []
        queue = [script]
        seen = set()
        while queue:
            f = queue.pop(0)
            if f in seen or not f.is_file():
                continue
            seen.add(f)
            files.append(f)
            for line in f.read_text(errors="replace").splitlines():
                m = INCLUDE_RE.match(line)
                if m:
                    cand = (f.parent / m.group(1)).resolve()
                    if cand.is_file():
                        queue.append(cand)
        namespaces.append((script, files))
    return namespaces


def check_resource_ids(root: Path) -> list:
    """Duplicate resource ids within one executable's namespace.

    Refuses a symbol defined twice in a namespace, and two ids of one
    class sharing a numeric value there. The same value in another
    class or another executable is legal and passes.
    """
    problems = []
    for script, files in resource_namespaces(root):
        ns = script.relative_to(root).as_posix()
        symbols = {}
        values = {}
        for f in files:
            rel = f.relative_to(root).as_posix() if f.is_relative_to(root) else str(f)
            for lineno, line in enumerate(
                f.read_text(errors="replace").splitlines(), 1
            ):
                m = DEFINE_RE.match(line)
                if m:
                    sym, val = m.group(1), int(m.group(2), 0)
                    where = f"{rel}:{lineno}"
                    if sym in symbols:
                        problems.append(
                            f"duplicate resource id: {sym} defined at {symbols[sym][1]} "
                            f"and again at {where} in namespace {ns}"
                        )
                    else:
                        symbols[sym] = (val, where)
                    cls = sym.split("_", 1)[0]
                    if cls in ID_CLASSES:
                        key = (cls, val)
                        if key in values and values[key][0] != sym:
                            problems.append(
                                f"duplicate resource id value: {values[key][0]} "
                                f"({values[key][1]}) and {sym} ({where}) both define "
                                f"{cls} value {val} in namespace {ns}"
                            )
                        else:
                            values.setdefault(key, (sym, where))
                    continue
                if f == script:
                    m = RC_STMT_RE.match(line)
                    if m:
                        val = int(m.group(1), 0)
                        cls = "RT_MANIFEST" if m.group(2) in ("24", "RT_MANIFEST") else m.group(2)
                        where = f"{rel}:{lineno}"
                        key = (cls, val)
                        label = f"{cls} statement"
                        if key in values:
                            problems.append(
                                f"duplicate resource id value: {values[key][0]} "
                                f"({values[key][1]}) and {label} ({where}) both use "
                                f"{cls} value {val} in namespace {ns}"
                            )
                        else:
                            values[key] = (label, where)
    if problems:
        raise Refusal("; ".join(problems))
    return [s.relative_to(root).as_posix() for s, _ in resource_namespaces(root)]


def expected_targets(root: Path) -> dict:
    """Target name -> compile database path. One per extension dir."""
    targets = {"root": root / "build" / "release" / "compile_commands.json"}
    ext = root / "extensions"
    if ext.is_dir():
        for tool in sorted(p for p in ext.iterdir() if p.is_dir()):
            targets[tool.name] = tool / "build" / "Release" / "compile_commands.json"
    return targets


def run_analysis(root: Path, clang_tidy: Path, targets: dict, log_path):
    """Run clang-tidy per target. Returns (per-target finding sets,
    global set, per-target sorted finding lines). Refuses when the
    analysis is incomplete: a missing database, an empty target, a
    failed invocation, or an error diagnostic."""
    log_lines = []

    def flush_log():
        # Diagnostics are persisted before every refusal, including the
        # failing invocation's own output: a gate whose log holds an
        # earlier run (or nothing) sends the reader to re-run clang-tidy
        # by hand to see the error that just failed them (round 2).
        if log_path is not None:
            Path(log_path).parent.mkdir(parents=True, exist_ok=True)
            Path(log_path).write_text("".join(log_lines))

    # Every expected database is checked before any analysis runs: a
    # missing extension database must refuse in seconds, not after the
    # root target has been analysed in full.
    for name, db in targets.items():
        if not db.is_file():
            flush_log()
            raise Refusal(
                f"target '{name}': compile database missing at {db.relative_to(root).as_posix()}; "
                "the release build must run first"
            )
    per_target = {}
    global_set = set()
    total_tus = 0
    for name, db in targets.items():
        entries = json.loads(db.read_text())
        tus = [
            e["file"]
            for e in entries
            if "_deps" not in e["file"] and not e["file"].endswith(".rc")
        ]
        if not tus:
            flush_log()
            raise Refusal(f"target '{name}': compile database has no translation units")
        found = set()
        for tu in tus:
            total_tus += 1
            proc = subprocess.run(
                [str(clang_tidy), "-p", str(db.parent), "--quiet", tu],
                capture_output=True,
                text=True,
                errors="replace",
            )
            out = (proc.stdout or "") + (proc.stderr or "")
            log_lines.append(out)
            if proc.returncode != 0:
                flush_log()
                raise Refusal(
                    f"target '{name}': clang-tidy exited {proc.returncode} on {tu}; "
                    "the finding count is not evidence until analysis completes"
                )
            if ERROR_RE.search(out):
                flush_log()
                raise Refusal(
                    f"target '{name}': error diagnostic while analysing {tu}; "
                    "the finding count is not evidence until analysis completes"
                )
            found |= collect_findings(out.splitlines(), root)
        per_target[name] = found
        global_set |= found
    flush_log()
    return per_target, global_set, total_tus


def baseline_at_revision(root: Path, rev: str):
    """The baseline at a revision, or a Refusal: an unresolvable
    comparison revision must fail closed, never disable the guard
    (review round 1)."""
    proc = subprocess.run(
        ["git", "show", f"{rev}:todo/.tidy-baseline"],
        cwd=root,
        capture_output=True,
        text=True,
        errors="replace",
    )
    if proc.returncode != 0:
        raise Refusal(
            f"comparison revision '{rev}' has no readable todo/.tidy-baseline "
            f"(git show exited {proc.returncode}); the raise guard fails closed, "
            "pass --base <rev> naming a revision that carries it"
        )
    return proc.stdout


def default_base(root: Path, override):
    if override:
        return override
    probe = subprocess.run(
        ["git", "rev-parse", "--verify", "origin/master"],
        cwd=root,
        capture_output=True,
        text=True,
    )
    return "origin/master" if probe.returncode == 0 else "HEAD"


def run(root: Path, clang_tidy: Path, base_override, log_path) -> int:
    baseline_path = root / "todo" / ".tidy-baseline"
    targets = expected_targets(root)
    names = sorted(targets)
    if not baseline_path.is_file():
        raise Refusal("todo/.tidy-baseline is missing")
    current_text = baseline_path.read_text()
    baseline = parse_baseline(current_text, names)

    base_rev = default_base(root, base_override)
    named_raises = check_raise_guard(
        current_text, baseline_at_revision(root, base_rev), names
    )
    for line in named_raises:
        print(f"tidy-ratchet: authorized raise vs {base_rev}: {line}")

    namespaces = check_resource_ids(root)

    if not clang_tidy.is_file():
        raise Refusal(f"clang-tidy not found at {clang_tidy}")
    per_target, global_set, total_tus = run_analysis(root, clang_tidy, targets, log_path)
    measured_targets = {n: len(s) for n, s in per_target.items()}
    measured_count = len(global_set)

    regressed = []
    if measured_count > baseline["count"]:
        regressed.append(
            f"total {measured_count} is above the baseline {baseline['count']}"
        )
    for name in names:
        if measured_targets[name] > baseline["targets"][name]:
            all_findings = sorted(per_target[name])
            shown = all_findings[:20]
            findings = "\n".join(shown)
            if len(all_findings) > len(shown):
                findings += f"\n... and {len(all_findings) - len(shown)} more (full log: {log_path})"
            regressed.append(
                f"target '{name}' {measured_targets[name]} is above its baseline "
                f"{baseline['targets'][name]}; its findings:\n{findings}"
            )
    if regressed:
        # The one-line summary repeats last: check-all.ps1 shows only the
        # tail of a failing gate, and a findings list must not push the
        # target and counts out of it (completion review gap 4).
        summary = "; ".join(
            r.split("; its findings:")[0] if "; its findings:" in r else r.split("\n")[0]
            for r in regressed
        )
        raise Refusal("; ".join(regressed) + f"\nsummary: {summary}")

    dropped = measured_count < baseline["count"] or any(
        measured_targets[n] < baseline["targets"][n] for n in names
    )
    if dropped:
        new_text = rewrite_baseline(current_text, measured_count, measured_targets)
        write_atomic(baseline_path, new_text)
        print(
            f"tidy-ratchet: REWRITTEN DOWN total {baseline['count']} -> {measured_count}, "
            + ", ".join(
                f"{n} {baseline['targets'][n]} -> {measured_targets[n]}" for n in names
            )
            + "; commit todo/.tidy-baseline with the change that earned it"
        )
        baseline = {"count": measured_count, "targets": dict(measured_targets)}
    print(
        f"tidy-ratchet: {measured_count} finding(s), baseline {baseline['count']}, "
        + ", ".join(f"{n} {measured_targets[n]}/{baseline['targets'][n]}" for n in names)
        + f", over {total_tus} TU(s) from {len(targets)} database(s); "
        f"resource ids ok in {len(namespaces)} namespace(s)"
    )
    return 0


def self_test() -> int:
    failures = []
    cases = 0
    scratch_dirs = []

    def mkdtemp() -> Path:
        # Tracked so every fixture tree is removed when the suite ends,
        # pass or fail: check-all runs this suite on every invocation.
        d = Path(tempfile.mkdtemp())
        scratch_dirs.append(d)
        return d

    def case(name, fn):
        nonlocal cases
        cases += 1
        try:
            fn()
        except Exception as exc:  # noqa: BLE001 - a self-test names every failure
            failures.append(f"{name}: {exc}")

    def refuses(fn, needle):
        try:
            fn()
        except Refusal as exc:
            assert needle in str(exc), f"refusal did not name {needle!r}: {exc}"
            return
        raise AssertionError(f"expected a refusal naming {needle!r}")

    root = Path("C:/repo")
    targets = ["RegStudio", "root"]

    def count_cases():
        lines = [
            "C:/repo/src/a.cpp:1:2: warning: x [bugprone-foo]",
            "C:/repo/src/a.cpp:1:2: warning: x [bugprone-foo]",
            "C:/REPO/src/../src/a.cpp:1:2: warning: x [bugprone-foo]",
            "C:/repo/src/b.h:3:4: warning: y [clang-analyzer-security.ArrayBound]",
            "C:/repo/build/_deps/catch/c.h:1:1: warning: z [bugprone-foo]",
            "not a diagnostic",
        ]
        got = collect_findings(lines, root)
        assert len(got) == 2, f"expected 2 unique findings, got {sorted(got)}"

    case("counting deduplicates, normalises, keeps analyzer names", count_cases)

    good = "count: 5\ntarget RegStudio: 2\ntarget root: 4\n"

    case("baseline parses", lambda: parse_baseline(good, targets))
    case(
        "duplicate count refused",
        lambda: refuses(lambda: parse_baseline(good + "count: 5\n", targets), "duplicate 'count:'"),
    )
    case(
        "missing target refused",
        lambda: refuses(lambda: parse_baseline("count: 1\ntarget root: 1\n", targets), "RegStudio"),
    )
    case(
        "unknown target refused",
        lambda: refuses(lambda: parse_baseline(good + "target Nope: 0\n", targets), "unknown target 'Nope'"),
    )
    case(
        "duplicate target refused",
        lambda: refuses(lambda: parse_baseline(good + "target root: 4\n", targets), "duplicate target 'root'"),
    )
    case(
        "count above target sum refused",
        lambda: refuses(
            lambda: parse_baseline("count: 9\ntarget RegStudio: 2\ntarget root: 4\n", targets),
            "exceeds the per-target sum",
        ),
    )
    case(
        "junk line refused",
        lambda: refuses(lambda: parse_baseline(good + "hello\n", targets), "unrecognised line"),
    )

    raised_total = "# Raised total 5 -> 6 on 2026-11-09: wider coverage\ncount: 6\ntarget RegStudio: 2\ntarget root: 4\n"
    case(
        "unreasoned total raise refused",
        lambda: refuses(
            lambda: check_raise_guard("count: 6\ntarget RegStudio: 2\ntarget root: 4\n", good, targets),
            "baseline total raised 5 -> 6",
        ),
    )

    def reasoned():
        named = check_raise_guard(raised_total, good, targets)
        assert named and "wider coverage" in named[0], named

    case("reasoned total raise passes and is named", reasoned)
    case(
        "reused historical raise line authorizes nothing",
        lambda: refuses(
            lambda: check_raise_guard(
                "# Raised total 5 -> 6 on 2026-11-09: wider coverage\ncount: 6\ntarget RegStudio: 2\ntarget root: 4\n",
                raised_total.replace("count: 6", "count: 5"),
                targets,
            ),
            "baseline total raised 5 -> 6",
        ),
    )
    offset = "count: 5\ntarget RegStudio: 3\ntarget root: 3\n"
    case(
        "offset target raise refused (total flat)",
        lambda: refuses(lambda: check_raise_guard(offset, good, targets), "target 'RegStudio' raised 2 -> 3"),
    )

    def offset_reasoned():
        text = "# Raised RegStudio 2 -> 3 on 2026-11-09: new TU covered\n" + offset
        named = check_raise_guard(text, good, targets)
        assert named and "RegStudio" in named[0], named

    case("reasoned target raise passes and is named", offset_reasoned)

    def rewrite():
        out = rewrite_baseline(good, 4, {"RegStudio": 1, "root": 3})
        assert parse_baseline(out, targets) == {"count": 4, "targets": {"RegStudio": 1, "root": 3}}, out

    case("rewrite down produces a valid baseline", rewrite)

    def resource_tree(files):
        tmp = mkdtemp()
        for rel, content in files.items():
            p = tmp / rel
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_text(content)
        return tmp

    def dup_symbol():
        tmp = resource_tree(
            {
                "src/a.rc": '#include "r.h"\nIDI_APPFALLBACK ICON "x.ico"\n',
                "src/r.h": "#define IDI_APPFALLBACK 102\n#define IDI_APPFALLBACK 103\n",
            }
        )
        refuses(lambda: check_resource_ids(tmp), "IDI_APPFALLBACK defined at")

    case("twice-defined resource symbol refused by name", dup_symbol)

    def dup_value():
        tmp = resource_tree(
            {
                "src/a.rc": '#include "r.h"\n',
                "src/r.h": "#define IDI_ONE 101\n#define IDI_TWO 101\n",
            }
        )
        refuses(lambda: check_resource_ids(tmp), "both define IDI value 101")

    case("same-class duplicate value refused by name", dup_value)

    def legal_reuse():
        tmp = resource_tree(
            {
                "src/a.rc": '#include "r.h"\n1 24 "m.manifest"\n',
                "src/r.h": "#define IDI_ONE 1\n#define IDC_ONE 1\n",
                "extensions/T/resources/b.rc": '1 ICON "i.ico"\n1 24 "m.manifest"\n',
            }
        )
        ns = check_resource_ids(tmp)
        assert len(ns) == 2, ns

    case("legal reuse passes (class, manifest, other executable)", legal_reuse)

    def git_base():
        tmp = mkdtemp()
        (tmp / "todo").mkdir()
        base_file = tmp / "todo" / ".tidy-baseline"
        base_file.write_text(good)
        env = dict(os.environ, GIT_CONFIG_NOSYSTEM="1")
        for args in (
            ["git", "init", "-q", "-b", "master"],
            ["git", "config", "user.email", "t@example.invalid"],
            ["git", "config", "user.name", "t"],
            ["git", "add", "."],
            ["git", "commit", "-qm", "base"],
            ["git", "update-ref", "refs/remotes/origin/master", "HEAD"],
        ):
            subprocess.run(args, cwd=tmp, check=True, capture_output=True, env=env)
        raised = "count: 6\ntarget RegStudio: 2\ntarget root: 4\n"
        refuses(
            lambda: check_raise_guard(raised, baseline_at_revision(tmp, "HEAD"), targets),
            "baseline total raised 5 -> 6",
        )
        base_file.write_text(raised)
        subprocess.run(["git", "add", "."], cwd=tmp, check=True, capture_output=True, env=env)
        subprocess.run(["git", "commit", "-qm", "raise"], cwd=tmp, check=True, capture_output=True, env=env)
        assert default_base(tmp, None) == "origin/master"
        refuses(
            lambda: check_raise_guard(
                raised, baseline_at_revision(tmp, default_base(tmp, None)), targets
            ),
            "baseline total raised 5 -> 6",
        )

    case("unreasoned raise refused uncommitted and committed-ahead", git_base)

    def upfront_databases():
        tmp = mkdtemp()
        db = tmp / "build" / "release" / "compile_commands.json"
        db.parent.mkdir(parents=True)
        db.write_text(json.dumps([{"file": "a.cpp", "directory": str(tmp), "command": "cc a.cpp"}]))
        targets_map = {
            "root": db,
            "Ext": tmp / "extensions" / "Ext" / "build" / "Release" / "compile_commands.json",
        }
        # The clang-tidy path does not exist: if analysis of 'root' ran
        # first this would raise FileNotFoundError, not name 'Ext'.
        refuses(
            lambda: run_analysis(tmp, tmp / "no-clang-tidy.exe", targets_map, None),
            "target 'Ext': compile database missing",
        )

    case("missing database refused before any analysis runs", upfront_databases)

    three = ["Ownership", "RegStudio", "root"]
    case(
        "adding a target keeps raise protection for existing targets",
        lambda: refuses(
            lambda: check_raise_guard(
                "count: 5\ntarget Ownership: 0\ntarget RegStudio: 1\ntarget root: 5\n",
                good,
                three,
            ),
            "target 'root' raised 4 -> 5",
        ),
    )

    def new_target_authorized():
        text = (
            "# Raised Ownership 0 -> 3 on 2026-11-09: Ownership came under analysis\n"
            "# Raised total 5 -> 8 on 2026-11-09: Ownership came under analysis\n"
            "count: 8\ntarget Ownership: 3\ntarget RegStudio: 2\ntarget root: 4\n"
        )
        named = check_raise_guard(text, good, three)
        assert len(named) == 2, named

    case("new target authorized by its 0 -> N line", new_target_authorized)
    case(
        "unresolvable comparison revision fails closed",
        lambda: refuses(
            lambda: baseline_at_revision(Path.cwd(), "refs/heads/review-missing-base"),
            "fails closed",
        ),
    )
    case(
        "missing base baseline fails closed",
        lambda: refuses(lambda: check_raise_guard(good, None, targets), "fails closed"),
    )

    def failed_analysis_keeps_its_log():
        tmp = mkdtemp()
        db = tmp / "build" / "release" / "compile_commands.json"
        db.parent.mkdir(parents=True)
        db.write_text(json.dumps([{"file": "a.cpp", "directory": str(tmp), "command": "cc a.cpp"}]))
        log = tmp / "logs" / "gate-tidy.log"
        # sys.executable stands in for a clang-tidy that fails: it exits
        # non-zero on tidy arguments and prints to stderr.
        refuses(
            lambda: run_analysis(tmp, Path(sys.executable), {"root": db}, log),
            "clang-tidy exited",
        )
        assert log.is_file() and log.read_text().strip(), "failing run left no diagnostics log"

    case("failed analysis persists its diagnostics log", failed_analysis_keeps_its_log)

    def run_end_to_end():
        # The complete operation over a real git repository, with the
        # analyzer stubbed at run_analysis's function boundary (the
        # subprocess path itself is covered by the drills in the
        # section record and the failed-log case above).
        tmp = mkdtemp()
        (tmp / "todo").mkdir()
        (tmp / "src").mkdir()
        (tmp / "src" / "a.rc").write_text('1 ICON "i.ico"\n')
        (tmp / "extensions" / "Ext").mkdir(parents=True)
        baseline = tmp / "todo" / ".tidy-baseline"
        baseline.write_text("count: 5\ntarget Ext: 2\ntarget root: 3\n")
        env = dict(os.environ, GIT_CONFIG_NOSYSTEM="1")
        for args in (
            ["git", "init", "-q", "-b", "master"],
            ["git", "config", "user.email", "t@example.invalid"],
            ["git", "config", "user.name", "t"],
            ["git", "add", "."],
            ["git", "commit", "-qm", "base"],
            ["git", "update-ref", "refs/remotes/origin/master", "HEAD"],
        ):
            subprocess.run(args, cwd=tmp, check=True, capture_output=True, env=env)

        measured = {"root": {"a|1|1|x", "a|2|1|x", "a|3|1|x"}, "Ext": {"b|1|1|x", "b|2|1|x"}}
        real_analysis = run_analysis

        def fake_analysis(root, clang_tidy, targets, log_path):
            glob = set().union(*measured.values())
            return {k: set(v) for k, v in measured.items()}, glob, 2

        globals()["run_analysis"] = fake_analysis
        try:
            tidy = Path(sys.executable)
            before = baseline.read_bytes()
            assert run(tmp, tidy, None, tmp / "log.txt") == 0
            assert baseline.read_bytes() == before, "equal run rewrote the baseline"

            measured["root"].add("a|4|1|x")
            measured["Ext"].discard("b|2|1|x")
            try:
                run(tmp, tidy, None, tmp / "log.txt")
                raise AssertionError("offset regression passed")
            except Refusal as exc:
                last = str(exc).strip().splitlines()[-1]
                assert last.startswith("summary:") and "'root' 4 is above its baseline 3" in last, last
            assert baseline.read_bytes() == before, "refused run rewrote the baseline"

            baseline.write_text(
                "# Raised total 5 -> 7 on 2026-11-09: wider coverage\n"
                "# Raised root 3 -> 5 on 2026-11-09: wider coverage\n"
                "count: 7\ntarget Ext: 2\ntarget root: 5\n"
            )
            measured["Ext"] = {"b|1|1|x", "b|2|1|x"}
            assert run(tmp, tidy, None, tmp / "log.txt") == 0
            text = baseline.read_text()
            assert "count: 6" in text and "target root: 4" in text, text
            assert "# Raised total 5 -> 6" in text and "# Raised root 3 -> 4" in text, text
            assert run(tmp, tidy, None, tmp / "log.txt") == 0, "unchanged rerun after rewrite refused"

            def failing_analysis(root, clang_tidy, targets, log_path):
                raise Refusal("analysis did not complete (stub)")

            globals()["run_analysis"] = failing_analysis
            before = baseline.read_bytes()
            try:
                run(tmp, tidy, None, tmp / "log.txt")
                raise AssertionError("incomplete analysis passed")
            except Refusal:
                pass
            assert baseline.read_bytes() == before, "incomplete run rewrote the baseline"
        finally:
            globals()["run_analysis"] = real_analysis

    case("run() end to end: equal, offset refusal, rewrite then rerun, incomplete", run_end_to_end)

    def ceiling_spacing_variants():
        for arrow in ("5 -> 9", "5->9", "5  ->  9"):
            text = (
                f"# Raised total {arrow} on 2026-11-09: wider coverage\n"
                f"# Raised root {arrow} on 2026-11-09: wider coverage\n"
                "count: 9\ntarget root: 9\n"
            )
            out = rewrite_baseline(text, 7, {"root": 7})
            assert "9 on 2026" not in out, (arrow, out)
            named = check_raise_guard(out, "count: 5\ntarget root: 5\n", ["root"])
            assert len(named) == 2, (arrow, out, named)

    case("rewrite adjusts Raised ceilings at any accepted spacing", ceiling_spacing_variants)

    def persistence_failures():
        from unittest import mock

        tmp = mkdtemp()
        dest = tmp / ".tidy-baseline"
        dest.write_text("original\n")

        (tmp / ".tidy-baseline.tmp").mkdir()
        refuses(lambda: write_atomic(dest, "new\n"), "could not persist")
        assert dest.read_text() == "original\n"
        (tmp / ".tidy-baseline.tmp").rmdir()

        with mock.patch("os.replace", side_effect=OSError("simulated replace failure")):
            refuses(lambda: write_atomic(dest, "new\n"), "could not persist")
        assert dest.read_text() == "original\n"

        def wrong_replace(src, dst):
            Path(dst).write_text("corrupted\n")

        with mock.patch("os.replace", wrong_replace):
            refuses(lambda: write_atomic(dest, "new\n"), "readback mismatch")

    case("persistence failures refuse and leave the original intact", persistence_failures)

    for d in scratch_dirs:
        shutil.rmtree(d, ignore_errors=True)
    if failures:
        for f in failures:
            print(f"tidy-ratchet self-test FAIL: {f}")
        return 1
    print(f"tidy-ratchet self-test: {cases} case(s) ok")
    return 0


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--self-test", action="store_true")
    ap.add_argument("--base", default=None, help="comparison revision for the raise guard")
    ap.add_argument("--clang-tidy", default=None)
    ap.add_argument("--log", default=None, help="write raw clang-tidy output here")
    ap.add_argument("--root", default=None)
    args = ap.parse_args(argv)

    if args.self_test:
        return self_test()

    root = Path(args.root).resolve() if args.root else Path(__file__).resolve().parent.parent
    clang_tidy = (
        Path(args.clang_tidy)
        if args.clang_tidy
        else root / "reskit" / "llvm-mingw" / "bin" / "clang-tidy.exe"
    )
    try:
        return run(root, clang_tidy, args.base, args.log)
    except Refusal as exc:
        print(f"tidy-ratchet: FAILED: {exc}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
