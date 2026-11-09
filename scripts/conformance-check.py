#!/usr/bin/env python3
"""Evaluate the conformance profile against every shipped tool.

Owner: D07 T01 section 3. Reports one matrix cell per tool per clause
of docs/conformance-profile.md: PASS, FAIL, EXC (dated exception), or
NYE (not yet evaluable). A clause fails the gate only when its owner
section has shipped; an open owner reports NYE with the owner named,
never a pass. A shipped owner with no evaluator in the table below
is a checker error, so an owner shipping without extending this
check turns the gate red instead of leaving a silent cell. Beyond
the clauses, the section's own checks gate: inventory reconciliation,
shipped-set composition, PE dependency policy, size budgets, and
duplicate repair subjects.

Stdlib only, like every TODO tool. Exit 0 pass, 1 refusal.
"""

from __future__ import annotations

import argparse
import importlib.util
import re
import shutil
import struct
import subprocess
import sys
import tempfile
from pathlib import Path


class Refusal(Exception):
    """A named reason the check will not pass."""


# ---------------------------------------------------------------- tools
# One entry per shipped tool. Reconciled against CMake executable
# targets on every run: an unregistered target, a missing artifact,
# or a missing budget fails by name. Budgets are the size promise
# measured 2026-11-09 plus headroom for the framework each tool will
# statically absorb; a tool that needs tens of megabytes to show a
# window has broken the portable-folder promise the suite sells.
TOOLS = {
    "Resolute": {
        "target": "Resolute",
        "source_dir": "src",
        "exe": "Bin/Release/Resolute.exe",
        "kind": "universal",
        "budget": 6 * 1024 * 1024,
        "tidy_target": "root",
        "shipped": ["Bin/Release/Resolute.exe"],
    },
    "RegStudio": {
        "target": "RegStudio",
        "source_dir": "extensions/RegStudio",
        "exe": "Bin/Release/System/RegStudio.exe",
        "kind": "universal",  # joins repair kind when it consumes the repair contract
        "budget": 4 * 1024 * 1024,
        "tidy_target": "RegStudio",
        "shipped": ["Bin/Release/System/RegStudio.exe"],
    },
}

# Test targets that land in Bin/Release but are not shipped tools.
TEST_ARTIFACTS = {
    "Bin/Release/resolute_tests.exe",
    "Bin/Release/resolute_flasher.exe",
    "Bin/Release/resolute_focus_hook.dll",
}

SELF_SECTION = "D07 T01 \u00a73"

ADD_EXECUTABLE_RE = re.compile(r"add_executable\s*\(\s*([A-Za-z0-9_.-]+)")
CLAUSE_RE = re.compile(
    r"^\|\s*(C\d+)\s*\|\s*(universal|repair)\s*\|\s*([a-z]+)\s*\|([^|]*)\|([^|]*)\|\s*(D\d\d T\d\d \u00a7\d+)\s*\|"
)
EXCEPTION_RE = re.compile(
    r"^\|\s*([A-Za-z0-9_.-]+)\s*\|\s*(C\d+)\s*\|\s*(\d{4}-\d{2}-\d{2})\s*\|([^|]+)\|\s*(D\d\d T\d\d \u00a7\d+)\s*\|"
)


def parse_profile(text: str):
    clauses, exceptions = [], []
    in_exceptions = False
    for line in text.splitlines():
        if line.startswith("## "):
            in_exceptions = line.strip().lower() == "## exceptions"
            continue
        m = CLAUSE_RE.match(line)
        if m:
            clauses.append(
                {
                    "id": m.group(1),
                    "kind": m.group(2),
                    "method": m.group(3),
                    "clause": m.group(4).strip(),
                    "evidence": m.group(5).strip(),
                    "owner": m.group(6),
                }
            )
            continue
        if in_exceptions:
            m = EXCEPTION_RE.match(line)
            if m:
                exceptions.append(
                    {
                        "tool": m.group(1),
                        "clause": m.group(2),
                        "date": m.group(3),
                        "reason": m.group(4).strip(),
                        "closing": m.group(5),
                    }
                )
    if not clauses:
        raise Refusal("profile carries no clause rows this parser recognizes")
    return clauses, exceptions


def owner_status(root: Path, cache: dict):
    """ref -> 'shipped' | 'open' | 'moved', via the graph's resolve
    exit codes (3 shipped, 0/4 open, 5 moved). Anything else is a
    checker error: a missing owner must never read as not-yet."""

    def status(ref: str) -> str:
        if ref == SELF_SECTION:
            return "shipped"
        if ref not in cache:
            proc = subprocess.run(
                ["python", "scripts/todo-graph.py", "resolve", ref],
                cwd=root,
                capture_output=True,
                text=True,
                errors="replace",
            )
            cache[ref] = proc.returncode
        code = cache[ref]
        if code == 3:
            return "shipped"
        if code in (0, 4):
            return "open"
        if code == 5:
            return "moved"
        raise Refusal(
            f"owner {ref} does not resolve (todo-graph resolve exit {code}); "
            "the profile cites a section that is not there"
        )

    return status


def reconcile_inventory(root: Path, tools: dict):
    """CMake executable targets (tests excluded by directory) must be
    exactly the registered tools, each with artifact and budget."""
    problems = []
    found = {}
    cmake_files = [root / "src" / "CMakeLists.txt"]
    ext = root / "extensions"
    if ext.is_dir():
        cmake_files += sorted(ext.glob("*/CMakeLists.txt"))
    for f in cmake_files:
        if not f.is_file():
            continue
        for m in ADD_EXECUTABLE_RE.finditer(f.read_text(errors="replace")):
            found[m.group(1)] = f.relative_to(root).as_posix()
    registered = {spec["target"]: name for name, spec in tools.items()}
    for target, where in sorted(found.items()):
        if target not in registered:
            problems.append(
                f"executable target '{target}' ({where}) is not a registered tool; "
                "register it in scripts/conformance-check.py TOOLS"
            )
    for name, spec in sorted(tools.items()):
        if spec["target"] not in found:
            problems.append(f"tool '{name}' registers target '{spec['target']}' no CMake file declares")
        if not spec.get("budget"):
            problems.append(f"tool '{name}' has no recorded size budget")
        exe = root / spec["exe"]
        if not exe.is_file():
            problems.append(f"tool '{name}': declared artifact {spec['exe']} is missing; the release build must run first")
        for rel in spec["shipped"]:
            if not (root / rel).is_file():
                problems.append(f"tool '{name}': declared shipped file {rel} is missing")
    return problems


def shipped_set_problems(root: Path, tools: dict):
    """Every file under Bin/Release is declared shipped, a named test
    artifact, or a failure by name (the stray a.exe rule)."""
    declared = set(TEST_ARTIFACTS)
    for spec in tools.values():
        declared.update(spec["shipped"])
    problems = []
    base = root / "Bin" / "Release"
    if base.is_dir():
        for f in sorted(p for p in base.rglob("*") if p.is_file()):
            rel = f.relative_to(root).as_posix()
            if rel not in declared:
                problems.append(
                    f"undeclared file in the shipped set: {rel} is produced by no registered tool; "
                    "declare it, register its tool, or remove it"
                )
    return problems


# ------------------------------------------------------------- PE policy
# Allowed imports: Windows API-set contracts and this system allowlist.
# Compiler runtimes are refused (the suite links static), msvcrt.dll
# excepted as a Windows system library. Anything else means the tool
# is not standalone.
SYSTEM_DLLS = {
    "advapi32.dll", "bcrypt.dll", "cfgmgr32.dll", "comctl32.dll",
    "comdlg32.dll", "crypt32.dll", "d2d1.dll", "dbghelp.dll",
    "dwmapi.dll", "dwrite.dll", "gdi32.dll", "imm32.dll",
    "kernel32.dll", "msimg32.dll", "msvcrt.dll", "ntdll.dll", "ole32.dll",
    "oleaut32.dll", "powrprof.dll", "rpcrt4.dll", "secur32.dll",
    "setupapi.dll", "shcore.dll", "shell32.dll", "shlwapi.dll",
    "user32.dll", "userenv.dll", "uxtheme.dll", "version.dll",
    "windowscodecs.dll", "winhttp.dll", "winmm.dll", "ws2_32.dll",
}


def pe_imports(data: bytes):
    """Normal and delay-load imported DLL names from PE bytes.
    A malformed or unreadable PE is a Refusal, never a pass."""
    try:
        if data[:2] != b"MZ":
            raise ValueError("no MZ signature")
        pe_off = struct.unpack_from("<I", data, 0x3C)[0]
        if data[pe_off : pe_off + 4] != b"PE\0\0":
            raise ValueError("no PE signature")
        num_sections = struct.unpack_from("<H", data, pe_off + 6)[0]
        opt_size = struct.unpack_from("<H", data, pe_off + 20)[0]
        opt = pe_off + 24
        magic = struct.unpack_from("<H", data, opt)[0]
        dd_base = opt + (112 if magic == 0x20B else 96)

        def directory(index):
            return struct.unpack_from("<II", data, dd_base + index * 8)

        sections = []
        sec_off = opt + opt_size
        for i in range(num_sections):
            vsize, vaddr, rsize, rptr = struct.unpack_from(
                "<IIII", data, sec_off + i * 40 + 8
            )
            sections.append((vaddr, max(vsize, rsize), rptr))

        def rva_to_off(rva):
            for vaddr, span, rptr in sections:
                if vaddr <= rva < vaddr + span:
                    return rptr + (rva - vaddr)
            raise ValueError(f"RVA {rva:#x} outside sections")

        def cstring(rva):
            off = rva_to_off(rva)
            end = data.index(b"\0", off)
            return data[off:end].decode("ascii", "strict")

        names = []
        imp_rva, _ = directory(1)
        if imp_rva:
            off = rva_to_off(imp_rva)
            while True:
                fields = struct.unpack_from("<IIIII", data, off)
                if not any(fields):
                    break
                names.append(cstring(fields[3]))
                off += 20
        delay_rva, _ = directory(13)
        if delay_rva:
            off = rva_to_off(delay_rva)
            while True:
                fields = struct.unpack_from("<IIIIIIII", data, off)
                if not any(fields):
                    break
                names.append(cstring(fields[1]))
                off += 32
        return names
    except (ValueError, struct.error, IndexError, UnicodeDecodeError) as exc:
        raise Refusal(f"malformed or unreadable PE: {exc}") from exc


def pe_problems(path: Path):
    try:
        data = path.read_bytes()
    except OSError as exc:
        return [f"{path.name}: cannot read executable ({exc})"]
    try:
        names = pe_imports(data)
    except Refusal as exc:
        return [f"{path.name}: {exc}"]
    problems = []
    for name in names:
        low = name.lower()
        if low.startswith(("api-ms-win-", "ext-ms-win-")):
            continue
        if low in SYSTEM_DLLS:
            continue
        problems.append(
            f"{path.name} imports non-system DLL '{name}'; the suite links static and ships standalone"
        )
    return problems


# ------------------------------------------------------------ evaluators
SHARED_BASENAMES = {
    "settings", "logging", "localization", "update", "elevation",
    "crash", "singleinstance", "commandline", "aboutdialog",
    "preferences", "repairitem", "repairrun", "resultlist",
    "restorerecord", "transcript",
}
SOURCE_SUFFIXES = {".h", ".hpp", ".cpp", ".cc", ".cxx", ".inl"}


def eval_layout(root: Path, tool, spec, ctx):
    """C23: no shared-layer file in a tool, no tool file in a layer."""
    problems = []
    src = root / spec["source_dir"]
    if src.is_dir():
        for f in sorted(p for p in src.rglob("*") if p.is_file()):
            if "build" in f.parts or f.suffix.lower() not in SOURCE_SUFFIXES:
                continue
            # A tool's own same-named file inside the LAUNCHER's src/
            # is not a tool carrying framework code: src/ hosts the
            # framework itself. The rule bites on extension tools.
            if spec["source_dir"] == "src":
                continue
            stem = f.stem.lower()
            if stem in SHARED_BASENAMES:
                problems.append(
                    f"{f.relative_to(root).as_posix()} carries a shared-layer name "
                    f"('{f.stem}') in a tool tree"
                )
    for layer in ("src/framework", "src/repair"):
        base = root / layer
        if not base.is_dir():
            continue
        for f in sorted(p for p in base.rglob("*") if p.is_file()):
            if f.suffix.lower() not in SOURCE_SUFFIXES:
                continue
            text = f.read_text(errors="replace")
            if re.search(r'#include\s+["<][^">]*extensions/', text):
                problems.append(
                    f"{f.relative_to(root).as_posix()} is shared-layer code including a tool-private path"
                )
    if problems:
        return "FAIL", "; ".join(problems)
    return "PASS", "no shared-layer name or cross-include found"


COPYRIGHT_YEAR_RE = re.compile(r"(?i)copyright[^0-9]{0,12}(19|20)\d\d")
VERSION_LITERAL_RE = re.compile(r'(?i)\bversion\s*[:=]\s*"\d+\.\d+')


def eval_generated_values(root: Path, tool, spec, ctx):
    """C22: no hardcoded copyright year or version in tool sources.
    Generated inputs (.rc.in templates) are the mechanism, exempt."""
    hits = []
    src = root / spec["source_dir"]
    if src.is_dir():
        for f in sorted(p for p in src.rglob("*") if p.is_file()):
            if "build" in f.parts or f.name.endswith(".in"):
                continue
            if f.suffix.lower() not in SOURCE_SUFFIXES | {".rc", ".txt", ".md"}:
                continue
            for lineno, line in enumerate(f.read_text(errors="replace").splitlines(), 1):
                if COPYRIGHT_YEAR_RE.search(line) or VERSION_LITERAL_RE.search(line):
                    hits.append(f"{f.relative_to(root).as_posix()}:{lineno}")
    if hits:
        return "FAIL", "hardcoded year/version literal at " + ", ".join(hits[:6])
    return "PASS", "no hardcoded copyright year or version literal"


def eval_build_clean(root: Path, tool, spec, ctx):
    """C24: current gate evidence only. The build gates prove the
    warning-clean build by having run before this check in
    check-all.ps1; the analysis count is recounted here from the
    ratchet's raw log with the baseline's counting rule, per target.
    Missing evidence is a checker error, never a stale pass."""
    log = ctx.get("tidy_log")
    if not log or not Path(log).is_file():
        raise Refusal(
            "C24 has no current analysis evidence (no tidy log); "
            "run through check-all.ps1 or pass --tidy-log"
        )
    ratchet = ctx["ratchet"]
    db = ctx["compile_db"](spec)
    if not db.is_file():
        raise Refusal(f"C24: compile database missing for {tool} at {db}")
    measured = set()
    lines = Path(log).read_text(errors="replace").splitlines()
    # The ratchet log holds every target's output; findings are
    # attributed by source path under the tool's tree (root target:
    # everything not under extensions/<other tool>).
    all_findings = ratchet.collect_findings(lines, root)
    prefix = (root / spec["source_dir"]).as_posix().lower()
    others = [
        (root / s["source_dir"]).as_posix().lower()
        for n, s in ctx["tools"].items()
        if n != tool and s["source_dir"] != "src"
    ]
    for key in all_findings:
        f = key.split("|", 1)[0]
        if tool == "Resolute":
            if any(f.startswith(o + "/") for o in others):
                continue
            measured.add(key)
        elif f.startswith(prefix + "/"):
            measured.add(key)
    baseline = ctx["baseline"]
    ceiling = baseline["targets"][spec["tidy_target"]]
    # The log recount is a lower bound for the target (header
    # findings outside the tool tree belong to the target too); the
    # ratchet gate itself already enforced the exact count. A recount
    # above the ceiling is a certain regression; at or below it, the
    # gate's own pass stands as the measurement.
    if len(measured) > ceiling:
        return "FAIL", f"recounted {len(measured)} in-tree findings above baseline {ceiling}"
    return "PASS", f"build artifacts present; in-tree recount {len(measured)} <= baseline {ceiling}"


EVALUATORS = {
    "C22": eval_generated_values,
    "C23": eval_layout,
    "C24": eval_build_clean,
}

REPAIR_SUBJECT_RES = [
    re.compile(r'RepairItem\s*\{\s*"([^"]+)"'),
    re.compile(r'REPAIR_ITEM\s*\(\s*"([^"]+)"'),
    re.compile(r'repair_subject\s*=\s*"([^"]+)"'),
]


def repair_duplicate_problems(root: Path):
    subjects = {}
    problems = []
    bases = [root / "extensions", root / "src" / "repair", root / "src"]
    seen_files = set()
    for base in bases:
        if not base.is_dir():
            continue
        for f in sorted(p for p in base.rglob("*") if p.is_file()):
            if f in seen_files or "build" in f.parts:
                continue
            seen_files.add(f)
            if f.suffix.lower() not in SOURCE_SUFFIXES:
                continue
            text = f.read_text(errors="replace")
            for rx in REPAIR_SUBJECT_RES:
                for m in rx.finditer(text):
                    where = f.relative_to(root).as_posix()
                    # The owning tool: extensions/<Tool>/ or launcher.
                    parts = Path(where).parts
                    owner = parts[1] if parts[0] == "extensions" and len(parts) > 1 else "launcher"
                    if m.group(1) in subjects and subjects[m.group(1)][0] != owner:
                        problems.append(
                            f"repair subject '{m.group(1)}' declared by both "
                            f"{subjects[m.group(1)][0]} ({subjects[m.group(1)][1]}) and {owner} ({where})"
                        )
                    subjects.setdefault(m.group(1), (owner, where))
    return problems, len(subjects)


def load_ratchet(root: Path):
    spec = importlib.util.spec_from_file_location(
        "tidy_ratchet", root / "scripts" / "tidy-ratchet.py"
    )
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def compile_db_for(root: Path, spec):
    if spec["tidy_target"] == "root":
        return root / "build" / "release" / "compile_commands.json"
    return (
        root / "extensions" / spec["tidy_target"]
        / "build" / "Release" / "compile_commands.json"
    )


def run(root: Path, tidy_log, tools=None, profile_text=None, status_fn=None) -> int:
    tools = tools if tools is not None else TOOLS
    profile_path = root / "docs" / "conformance-profile.md"
    text = profile_text if profile_text is not None else profile_path.read_text(encoding="utf-8")
    clauses, exceptions = parse_profile(text)
    status = status_fn if status_fn is not None else owner_status(root, {})

    problems = []
    problems += reconcile_inventory(root, tools)
    problems += shipped_set_problems(root, tools)
    dup_problems, subject_count = repair_duplicate_problems(root)
    problems += dup_problems

    for name, spec in sorted(tools.items()):
        exe = root / spec["exe"]
        if exe.is_file():
            problems += pe_problems(exe)
            total = sum((root / rel).stat().st_size for rel in spec["shipped"] if (root / rel).is_file())
            if total > spec["budget"]:
                problems.append(
                    f"tool '{name}' ships {total} bytes, above its budget {spec['budget']}"
                )

    # Exceptions are validated before cells are decided.
    exc_map = {}
    for exc in exceptions:
        key = (exc["tool"], exc["clause"])
        closing = status(exc["closing"])
        if closing == "shipped":
            problems.append(
                f"exception {exc['tool']} {exc['clause']}: closing section {exc['closing']} "
                "has shipped, so the exception is spent; remove it or re-date it"
            )
        exc_map[key] = exc

    ratchet = load_ratchet(root)
    baseline_targets = sorted({s["tidy_target"] for s in tools.values()})
    baseline = ratchet.parse_baseline(
        (root / "todo" / ".tidy-baseline").read_text(encoding="utf-8"),
        baseline_targets,
    )
    ctx = {
        "tidy_log": tidy_log,
        "ratchet": ratchet,
        "baseline": baseline,
        "tools": tools,
        "compile_db": lambda spec: compile_db_for(root, spec),
    }

    names = sorted(tools)
    cells = {}
    details = []
    for clause in clauses:
        owner_state = status(clause["owner"])
        for name in names:
            spec = tools[name]
            if clause["kind"] == "repair" and spec["kind"] != "repair":
                cells[(clause["id"], name)] = "-"
                continue
            if (name, clause["id"]) in exc_map:
                cells[(clause["id"], name)] = "EXC"
                details.append(
                    f"{clause['id']} {name}: exception dated {exc_map[(name, clause['id'])]['date']}"
                    f" closing at {exc_map[(name, clause['id'])]['closing']}"
                )
                continue
            if owner_state in ("open", "moved"):
                cells[(clause["id"], name)] = "NYE"
                continue
            evaluator = EVALUATORS.get(clause["id"])
            if evaluator is None:
                raise Refusal(
                    f"clause {clause['id']} owner {clause['owner']} has shipped but no "
                    "evaluator is registered; extend scripts/conformance-check.py EVALUATORS"
                )
            state, evidence = evaluator(root, name, spec, ctx)
            cells[(clause["id"], name)] = state
            if state == "FAIL":
                problems.append(
                    f"{name} fails {clause['id']} (owner {clause['owner']}): {evidence}"
                )
            details.append(f"{clause['id']} {name}: {state} {evidence}")

    # Matrix.
    width = max(len(n) for n in names)
    header = "| Clause | Owner | " + " | ".join(names) + " |"
    print(header)
    print("| --- | --- | " + " | ".join("---" for _ in names) + " |")
    for clause in clauses:
        row = [cells.get((clause["id"], n), "NYE") for n in names]
        print(f"| {clause['id']} | {clause['owner']} | " + " | ".join(row) + " |")
    for d in details:
        print(f"conformance detail: {d}")

    suite_total = 0
    for name in names:
        spec = tools[name]
        total = sum((root / rel).stat().st_size for rel in spec["shipped"] if (root / rel).is_file())
        suite_total += total
        print(f"conformance: size {name} {total} bytes, budget {spec['budget']}")
    print(f"conformance: suite total {suite_total} bytes over {len(names)} tool(s)")
    print(f"conformance: repair subjects declared {subject_count}, duplicates {len(dup_problems)}")
    print(
        "conformance: budget rationale: one portable folder per tool, no installer "
        "payload, no shared runtime download; sizes above are the dated evidence"
    )

    if problems:
        raise Refusal("; ".join(problems))
    fails = sum(1 for v in cells.values() if v == "FAIL")
    nyes = sum(1 for v in cells.values() if v == "NYE")
    print(
        f"conformance: {len(clauses)} clause(s) x {len(names)} tool(s), "
        f"{fails} failing, {nyes} not yet evaluable"
    )
    return 0


def make_pe(imports, delay_imports=()):
    """Minimal PE32+ image carrying the given import DLL names."""
    section_rva = 0x1000
    names = list(imports) + list(delay_imports)
    blob = bytearray()
    name_rvas = {}
    for n in names:
        name_rvas[n] = section_rva + len(blob)
        blob += n.encode() + b"\0"
    while len(blob) % 8:
        blob += b"\0"
    imp_off = len(blob)
    for n in imports:
        blob += struct.pack("<IIIII", 0, 0, 0, name_rvas[n], 0)
    if imports:
        blob += b"\0" * 20
    delay_off = len(blob)
    for n in delay_imports:
        blob += struct.pack("<IIIIIIII", 0, name_rvas[n], 0, 0, 0, 0, 0, 0)
    if delay_imports:
        blob += b"\0" * 32
    raw_size = (len(blob) + 0x1FF) & ~0x1FF
    blob += b"\0" * (raw_size - len(blob))

    headers = bytearray(0x200)
    headers[0:2] = b"MZ"
    pe_off = 0x80
    struct.pack_into("<I", headers, 0x3C, pe_off)
    headers[pe_off : pe_off + 4] = b"PE\0\0"
    struct.pack_into("<H", headers, pe_off + 6, 1)  # sections
    opt_size = 240
    struct.pack_into("<H", headers, pe_off + 20, opt_size)
    opt = pe_off + 24
    struct.pack_into("<H", headers, opt, 0x20B)
    dd = opt + 112
    struct.pack_into("<II", headers, dd + 8, section_rva + imp_off if imports else 0, 0)
    struct.pack_into("<II", headers, dd + 13 * 8, section_rva + delay_off if delay_imports else 0, 0)
    sec = opt + opt_size
    struct.pack_into("<IIII", headers, sec + 8, raw_size, section_rva, raw_size, 0x200)
    return bytes(headers) + bytes(blob)


def repro_check(root: Path) -> int:
    """Build the release set twice (forcing relinks) and compare
    hashes. Not part of the gate: it costs two builds. Run before a
    release, and by D07 T01 section 3's checkpoint."""
    import hashlib

    exes = [root / spec["exe"] for spec in TOOLS.values()]

    def build_and_hash():
        for exe in exes:
            exe.unlink(missing_ok=True)
        proc = subprocess.run(
            ["pwsh", "-NoProfile", "-File", str(root / "scripts" / "build.ps1"),
             "-All", "-Config", "Release"],
            cwd=root, capture_output=True, text=True, errors="replace",
        )
        if proc.returncode != 0:
            raise Refusal(f"release build failed during repro check:\n{proc.stdout[-800:]}{proc.stderr[-400:]}")
        return {
            exe.name: hashlib.sha256(exe.read_bytes()).hexdigest() for exe in exes
        }

    first = build_and_hash()
    second = build_and_hash()
    for name in sorted(first):
        print(f"conformance: repro {name} build1 {first[name]} build2 {second[name]}")
    if first != second:
        diff = [n for n in first if first[n] != second[n]]
        raise Refusal(f"release build is not reproducible: {', '.join(diff)} differ across two clean builds")
    print("conformance: repro identical across two clean builds")
    return 0


def self_test() -> int:
    failures = []
    cases = 0
    scratch = []

    def mkdtemp():
        d = Path(tempfile.mkdtemp())
        scratch.append(d)
        return d

    def case(name, fn):
        nonlocal cases
        cases += 1
        try:
            fn()
        except Exception as exc:  # noqa: BLE001
            failures.append(f"{name}: {exc}")

    def refuses(fn, needle):
        try:
            fn()
        except Refusal as exc:
            assert needle in str(exc), f"refusal did not name {needle!r}: {exc}"
            return
        raise AssertionError(f"expected refusal naming {needle!r}")

    def pe_cases():
        ok = make_pe(["KERNEL32.dll", "api-ms-win-core-file-l1-1-0.dll"], ["USER32.dll"])
        tmp = mkdtemp()
        p = tmp / "tool.exe"
        p.write_bytes(ok)
        assert pe_problems(p) == [], pe_problems(p)
        p.write_bytes(make_pe(["libstdc++-6.dll"]))
        got = pe_problems(p)
        assert got and "libstdc++-6.dll" in got[0], got
        p.write_bytes(make_pe([], ["EVIL.dll"]))
        got = pe_problems(p)
        assert got and "EVIL.dll" in got[0], got
        p.write_bytes(b"not a pe")
        got = pe_problems(p)
        assert got and "malformed" in got[0], got

    case("PE policy: system pass, runtime and delay-load refused, malformed refused", pe_cases)

    PROFILE = """# P

| ID | Kind | Method | Clause | Evidence | Owner |
| --- | --- | --- | --- | --- | --- |
| C23 | universal | absent | layout | layout check | D07 T01 \u00a73 |
| C24 | universal | run | builds clean | gate evidence | D00 T01 \u00a73 |
| C99 | universal | run | future | future | D01 T01 \u00a71 |
| C98 | repair | run | repair only | repair | D02 T01 \u00a71 |

## Exceptions

| Tool | Clause | Date | Reason | Closing |
| --- | --- | --- | --- | --- |
"""

    def fixture(profile=PROFILE, status_map=None):
        tmp = mkdtemp()
        (tmp / "docs").mkdir()
        (tmp / "todo").mkdir()
        (tmp / "scripts").mkdir()
        shutil.copy(Path(__file__).parent / "tidy-ratchet.py", tmp / "scripts" / "tidy-ratchet.py")
        (tmp / "todo" / ".tidy-baseline").write_text("count: 0\ntarget root: 0\n")
        (tmp / "src").mkdir()
        (tmp / "src" / "CMakeLists.txt").write_text("add_executable(ToolA WIN32 main.cpp)\n")
        (tmp / "src" / "main.cpp").write_text("int main(){}\n")
        (tmp / "Bin" / "Release").mkdir(parents=True)
        (tmp / "Bin" / "Release" / "ToolA.exe").write_bytes(make_pe(["KERNEL32.dll"]))
        (tmp / "build" / "release").mkdir(parents=True)
        (tmp / "build" / "release" / "compile_commands.json").write_text("[]")
        log = tmp / "tidy.log"
        log.write_text("")
        tools = {
            "ToolA": {
                "target": "ToolA", "source_dir": "src",
                "exe": "Bin/Release/ToolA.exe", "kind": "universal",
                "budget": 10 * 1024 * 1024, "tidy_target": "root",
                "shipped": ["Bin/Release/ToolA.exe"],
            }
        }
        statuses = {"D00 T01 \u00a73": "shipped", "D01 T01 \u00a71": "open", "D02 T01 \u00a71": "open"}
        if status_map:
            statuses.update(status_map)

        def status(ref):
            if ref == SELF_SECTION:
                return "shipped"
            if ref in statuses:
                return statuses[ref]
            raise Refusal(f"owner {ref} does not resolve")

        return tmp, tools, log, status

    def matrix_ok():
        tmp, tools, log, status = fixture()
        assert run(tmp, log, tools, PROFILE, status) == 0

    case("matrix passes with shipped C23/C24 and open C99", matrix_ok)

    def shipped_without_evaluator():
        tmp, tools, log, status = fixture(status_map={"D01 T01 \u00a71": "shipped"})
        refuses(lambda: run(tmp, log, tools, PROFILE, status), "no evaluator is registered")

    case("shipped owner without evaluator is a checker error", shipped_without_evaluator)

    def layout_violation():
        tmp, tools, log, status = fixture()
        tools["ToolA"]["source_dir"] = "extensions/ToolA"
        d = tmp / "extensions" / "ToolA"
        d.mkdir(parents=True)
        (d / "Settings.cpp").write_text("// private settings\n")
        refuses(lambda: run(tmp, log, tools, PROFILE, status), "shared-layer name")

    case("layout violation fails by name", layout_violation)

    def stray_file():
        tmp, tools, log, status = fixture()
        (tmp / "Bin" / "Release" / "a.exe").write_bytes(b"x")
        refuses(lambda: run(tmp, log, tools, PROFILE, status), "undeclared file in the shipped set: Bin/Release/a.exe")

    case("stray shipped file fails by name", stray_file)

    def unregistered_target():
        tmp, tools, log, status = fixture()
        (tmp / "src" / "CMakeLists.txt").write_text(
            "add_executable(ToolA WIN32 main.cpp)\nadd_executable(Sneak WIN32 main.cpp)\n"
        )
        refuses(lambda: run(tmp, log, tools, PROFILE, status), "'Sneak'")

    case("unregistered executable target fails by name", unregistered_target)

    def over_budget():
        tmp, tools, log, status = fixture()
        tools["ToolA"]["budget"] = 10
        refuses(lambda: run(tmp, log, tools, PROFILE, status), "above its budget")

    case("over-budget tool fails by name", over_budget)

    def dup_repair():
        tmp, tools, log, status = fixture()
        for tool in ("ToolA", "ToolB"):
            d = tmp / "extensions" / tool
            d.mkdir(parents=True)
            (d / "r.cpp").write_text('RepairItem{ "hosts-file" };\n')
        refuses(lambda: run(tmp, log, tools, PROFILE, status), "repair subject 'hosts-file'")

    case("duplicate repair subject fails by name", dup_repair)

    def exceptions():
        prof = PROFILE + "| ToolA | C99 | 2026-11-09 | not yet | D01 T01 \u00a71 |\n"
        tmp, tools, log, status = fixture(profile=prof)
        assert run(tmp, log, tools, prof, status) == 0
        tmp, tools, log, status = fixture(
            profile=prof, status_map={"D01 T01 \u00a71": "shipped"}
        )
        refuses(lambda: run(tmp, log, tools, prof, status), "exception is spent")

    case("exception holds while closing open, fails once shipped", exceptions)

    def missing_evidence():
        tmp, tools, log, status = fixture()
        refuses(lambda: run(tmp, tmp / "no.log", tools, PROFILE, status), "no current analysis evidence")

    case("C24 without current evidence is a checker error", missing_evidence)

    for d in scratch:
        shutil.rmtree(d, ignore_errors=True)
    if failures:
        for f in failures:
            print(f"conformance-check self-test FAIL: {f}")
        return 1
    print(f"conformance-check self-test: {cases} case(s) ok")
    return 0


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--self-test", action="store_true")
    ap.add_argument("--repro-check", action="store_true")
    ap.add_argument("--tidy-log", default=None)
    ap.add_argument("--root", default=None)
    args = ap.parse_args(argv)
    if args.self_test:
        return self_test()
    root = Path(args.root).resolve() if args.root else Path(__file__).resolve().parent.parent
    try:
        if args.repro_check:
            return repro_check(root)
        return run(root, args.tidy_log)
    except Refusal as exc:
        print(f"conformance: FAILED: {exc}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
