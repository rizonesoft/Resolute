"""Generate the README's tool gallery and progress block (D00 T05 §2).

    python scripts/readme-blocks.py            write both blocks into README.md and the gallery's icons
    python scripts/readme-blocks.py --check    exit 1 naming each block or icon that is stale; writes nothing
    python scripts/readme-blocks.py --self-test

The gallery's rows come from docs/readme/tools.json, checked against the tree: every AutoIt tool with a .sni under
resolute_au3/SDK/Concrete/ (the launcher and the internal ReBar aside) and every tool under extensions/ must have a row,
and every row's icon and plan must exist. A row's C++ state is read from the plan that owns it. The progress block is
read from the plan projection todo/implementation-plan.md and from `todo-graph.py query ready --json`, writing neither.
Each block sits between its own marker comments; nothing outside them is touched. Stdlib only, like the rest of scripts/.
"""

from __future__ import annotations

import argparse
import json
import re
import struct
import subprocess
import sys
import tempfile
import zlib
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
NOT_PRODUCTS = {"Resolute", "ReBar"}   # the launcher (the README's subject) and the internal framework (brainstorm decision 11)
ICON_SIZE = 48


class Stale(Exception):
    """A refusal by name: an unmapped tool, a missing source, or a stale block."""


# ----- icons ------------------------------------------------------------------------------------------------------

def _stored_zlib(data: bytes) -> bytes:
    """A zlib stream of stored (uncompressed) blocks, written by hand. A compressor's output differs between zlib
    builds, so a compressed icon regenerated on another machine has other bytes and --check calls the tree stale
    there (CI did, 2026-11-13); stored blocks have exactly one encoding, and these icons are a few kilobytes."""
    out = bytearray(b"\x78\x01")
    blocks = [data[i:i + 65535] for i in range(0, len(data), 65535)] or [b""]
    for n, block in enumerate(blocks):
        out += struct.pack("<BHH", 1 if n == len(blocks) - 1 else 0, len(block), len(block) ^ 0xFFFF) + block
    return bytes(out) + struct.pack(">I", zlib.adler32(data) & 0xFFFFFFFF)


def _png(width: int, height: int, rgba: bytes) -> bytes:
    def chunk(kind: bytes, data: bytes) -> bytes:
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)
    rows = b"".join(b"\x00" + rgba[y * width * 4:(y + 1) * width * 4] for y in range(height))
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", _stored_zlib(rows)) + chunk(b"IEND", b""))


def _dib_to_rgba(dib: bytes) -> tuple[int, int, bytes]:
    """An icon frame's DIB (header, palette, colour bits, then the AND mask) as top-down RGBA."""
    header, width, height2, _, bpp = struct.unpack("<IiiHH", dib[:16])
    height = height2 // 2
    colours = struct.unpack("<I", dib[32:36])[0] or (1 << bpp if bpp <= 8 else 0)
    palette_at = header
    bits_at = palette_at + colours * 4
    stride = ((width * bpp + 31) // 32) * 4
    mask_stride = ((width + 31) // 32) * 4
    mask_at = bits_at + stride * height
    palette = [dib[palette_at + i * 4: palette_at + i * 4 + 4] for i in range(colours)]
    has_alpha = bpp == 32 and any(dib[bits_at + i + 3] for i in range(0, stride * height, 4))
    out = bytearray(width * height * 4)
    for y in range(height):
        src_row = height - 1 - y   # bottom-up
        row = dib[bits_at + src_row * stride: bits_at + (src_row + 1) * stride]
        mask_row = dib[mask_at + src_row * mask_stride: mask_at + (src_row + 1) * mask_stride]
        for x in range(width):
            if bpp == 32:
                b, g, r, a = row[x * 4: x * 4 + 4]
            elif bpp == 24:
                b, g, r = row[x * 3: x * 3 + 3]
                a = 255
            else:
                index = (row[(x * bpp) // 8] >> (8 - bpp - (x * bpp) % 8)) & ((1 << bpp) - 1)
                b, g, r = palette[index][:3]
                a = 255
            if not has_alpha:
                masked = (mask_row[x // 8] >> (7 - x % 8)) & 1 if mask_row else 0
                a = 0 if masked else 255
            at = (y * width + x) * 4
            out[at: at + 4] = bytes((r, g, b, a))
    return width, height, bytes(out)


def icon_png(path: Path, size: int = ICON_SIZE) -> bytes:
    """The icon's frame of the given size (or the nearest larger one) as PNG bytes."""
    data = path.read_bytes()
    count = struct.unpack("<H", data[4:6])[0]
    frames = []
    for i in range(count):
        w, _, _, _, _, bpp, length, offset = struct.unpack("<BBBBHHII", data[6 + 16 * i: 22 + 16 * i])
        frames.append((w or 256, bpp, data[offset: offset + length]))
    exact = [f for f in frames if f[0] == size]
    chosen = max(exact, key=lambda f: f[1]) if exact else min((f for f in frames if f[0] >= size), key=lambda f: f[0], default=max(frames, key=lambda f: f[0]))
    if chosen[2][:8] == b"\x89PNG\r\n\x1a\n":
        return chosen[2]
    return _png(*_dib_to_rgba(chosen[2]))


# ----- the gallery ------------------------------------------------------------------------------------------------

def tree_tools(repo: Path) -> set[str]:
    autoit = {p.parent.name for p in (repo / "resolute_au3" / "SDK" / "Concrete").glob("*/*.sni")} - NOT_PRODUCTS
    cpp = {p.name for p in (repo / "extensions").iterdir() if p.is_dir()} if (repo / "extensions").is_dir() else set()
    return autoit | cpp


def plan_state(repo: Path, plan: dict) -> tuple[str, int, int]:
    """'planned', 'in progress' or 'shipped', with the sections done and the sections owed."""
    if "file" in plan:
        text = (repo / plan["file"]).read_text(encoding="utf-8")
        rows = re.findall(r"^\|\s*\d+\s*\|\s*§\d+\s*\|.*\|\s*\[(x| )\]\s*\|\s*$", text, re.MULTILINE)
        done, total, started = rows.count("x"), len(rows), "> **Started:**" in text
    else:
        proc = subprocess.run([sys.executable, str(repo / "scripts" / "todo-graph.py"), "resolve", plan["ref"]],
                              capture_output=True, encoding="utf-8", cwd=str(repo), check=False)
        if proc.returncode in (1, 2):
            raise Stale(f"the plan section {plan['ref']} does not resolve")
        status = re.search(r"^status\s+\[(x| )\]", proc.stdout, re.MULTILINE)
        done, total, started = (1 if status and status.group(1) == "x" else 0), 1, "> **Started:**" in proc.stdout
    if total and done == total:
        return "shipped", done, total
    return ("in progress" if done or started else "planned"), done, total


def gallery(repo: Path, tools_map: dict) -> tuple[str, dict[str, bytes]]:
    rows = tools_map["tools"]
    names = {row["name"] for row in rows}
    missing = sorted(tree_tools(repo) - names)
    if missing:
        raise Stale(f"docs/readme/tools.json has no row for {', '.join(missing)}, which the tree has")
    icons, lines = {}, []
    lines.append("| | Tool | What it does | Today | C++ |")
    lines.append("| :-: | --- | --- | --- | --- |")
    for row in rows:
        icon = repo / row["icon"]
        if not icon.is_file():
            raise Stale(f"{row['name']}'s icon {row['icon']} does not exist")
        icons[f"docs/readme/icons/{row['name']}.png"] = icon_png(icon)
        state, done, total = plan_state(repo, row["plan"])
        owner = row["plan"].get("ref") or Path(row["plan"]["file"]).stem
        cpp = {"planned": "planned", "in progress": f"in progress, {done} of {total} sections", "shipped": "shipped"}[state]
        cpp += f" ([{owner}]({row['plan'].get('file') or 'todo/implementation-plan.md'}))"
        if row.get("folds_into"):
            cpp += f"; folds into {row['folds_into']} ([decision]({tools_map['decision']}))"
        today = "new, C++ only" if row.get("new") else "AutoIt, shipping"
        name = f"**{row['name']}**" + (" (frozen)" if row.get("frozen") else "")
        lines.append(f"| <img src=\"docs/readme/icons/{row['name']}.png\" width=\"32\" height=\"32\" alt=\"{row['name']} icon\"> | {name} | {row['job']} | {today} | {cpp} |")
    lines.append("")
    lines.append("Frozen tools change a system in ways that are hard to undo, so their C++ ports reproduce the AutoIt effect exactly, proven by a parity check.")
    return "\n".join(lines), icons


# ----- the progress block -----------------------------------------------------------------------------------------

def query_ready(repo: Path) -> list[dict]:
    proc = subprocess.run([sys.executable, str(repo / "scripts" / "todo-graph.py"), "query", "ready", "--json"],
                          capture_output=True, encoding="utf-8", cwd=str(repo), check=False)
    if proc.returncode != 0:
        raise Stale(f"todo-graph.py query ready --json failed: {proc.stderr.strip()[:200]}")
    return json.loads(proc.stdout)


def progress(repo: Path, ready: list[dict] | None = None) -> str:
    plan = (repo / "todo" / "implementation-plan.md").read_text(encoding="utf-8")
    phases, current, phase_of = [], None, {}
    for line in plan.splitlines():
        heading = re.match(r"^### Phase (\d+) -- (.+)$", line)
        if heading:
            current = [int(heading.group(1)), heading.group(2).strip(), 0, 0]
            phases.append(current)
            continue
        row = re.match(r"^\|\s*\[(x| )\]\s*\|\s*`([^`]+)`", line)
        if row and current is not None:
            current[3] += 1
            current[2] += row.group(1) == "x"
            phase_of[row.group(2)] = current[0]
    if not phases:
        raise Stale("todo/implementation-plan.md has no phase tables")
    rows = ready if ready is not None else query_ready(repo)
    ready_phases = sorted({phase_of[r["ref"]] for r in rows if r["ref"] in phase_of})
    done = sum(p[2] for p in phases)
    total = sum(p[3] for p in phases)
    lines = [f"**{done} of {total} sections done** ({done * 100 // total} percent), read from [the plan](todo/implementation-plan.md).", "",
             "| Phase | Done | Of |", "| --- | :-: | :-: |"]
    lines += [f"| {n}. {title} | {d} | {t} |" for n, title, d, t in phases]
    lines.append("")
    if ready_phases:
        first = next(p for p in phases if p[0] == ready_phases[0])
        lines.append(f"Next to run: phase {first[0]}, {first[1]}.")
    else:
        lines.append("Next to run: none; every open section is waiting on something.")
    return "\n".join(lines)


# ----- writing and checking ---------------------------------------------------------------------------------------

def place(text: str, name: str, block: str) -> str:
    begin, end = f"<!-- {name}:begin -->", f"<!-- {name}:end -->"
    if text.count(begin) != 1 or text.count(end) != 1:
        raise Stale(f"README.md must hold exactly one {begin} and one {end}")
    head, rest = text.split(begin)
    _, tail = rest.split(end)
    return f"{head}{begin}\n<!-- generated by scripts/readme-blocks.py; edit docs/readme/tools.json or the plan, never this block -->\n{block}\n{end}{tail}"


def build(repo: Path, ready: list[dict] | None = None) -> tuple[str, dict[str, bytes]]:
    readme = (repo / "README.md").read_text(encoding="utf-8")
    tools_map = json.loads((repo / "docs" / "readme" / "tools.json").read_text(encoding="utf-8"))
    table, icons = gallery(repo, tools_map)
    readme = place(readme, "tool-gallery", table)
    readme = place(readme, "plan-progress", progress(repo, ready))
    return readme, icons


def stale_parts(repo: Path, ready: list[dict] | None = None) -> list[str]:
    readme, icons = build(repo, ready)
    stale = []
    current = (repo / "README.md").read_text(encoding="utf-8")
    for name in ("tool-gallery", "plan-progress"):
        if current.split(f"<!-- {name}:begin -->")[1].split(f"<!-- {name}:end -->")[0] != readme.split(f"<!-- {name}:begin -->")[1].split(f"<!-- {name}:end -->")[0]:
            stale.append(f"the {name} block in README.md")
    for rel, data in icons.items():
        path = repo / rel
        if not path.is_file() or path.read_bytes() != data:
            stale.append(rel)
    known = set(icons)
    for path in sorted((repo / "docs" / "readme" / "icons").glob("*.png")):
        if f"docs/readme/icons/{path.name}" not in known:
            stale.append(f"docs/readme/icons/{path.name} (no row names it)")
    return stale


def write(repo: Path, ready: list[dict] | None = None) -> None:
    readme, icons = build(repo, ready)
    (repo / "docs" / "readme" / "icons").mkdir(parents=True, exist_ok=True)
    for path in (repo / "docs" / "readme" / "icons").glob("*.png"):
        if f"docs/readme/icons/{path.name}" not in icons:
            path.unlink()
    for rel, data in icons.items():
        (repo / rel).write_bytes(data)
    (repo / "README.md").write_bytes(readme.encode("utf-8"))


# ----- self-test --------------------------------------------------------------------------------------------------

def self_test() -> int:
    failed = []

    def check(name: str, ok: bool, detail: str = "") -> None:
        print(("PASS " if ok else "FAIL ") + name + ("" if ok or not detail else f": {detail}"))
        if not ok:
            failed.append(name)

    with tempfile.TemporaryDirectory(prefix="readme-blocks-") as tmp:
        root = Path(tmp)
        # A fixture tree: one AutoIt tool, one C++ tool, their icons and plans, a two-phase plan projection.
        concrete = root / "resolute_au3" / "SDK" / "Concrete"
        for name in ("Alpha", "Resolute", "ReBar"):
            (concrete / name).mkdir(parents=True)
            (concrete / name / f"{name}.sni").write_text("[Rizonesoft SDK]\n", encoding="utf-8")
        (root / "extensions" / "Beta").mkdir(parents=True)
        icon_dir = root / "icons"
        icon_dir.mkdir()
        # A 48 px 32-bit icon frame (one opaque red pixel row by row), so the PNG path is exercised.
        w = h = 48
        pixels = bytes((0, 0, 255, 255)) * (w * h)
        mask = bytes(((w + 31) // 32) * 4 * h)
        dib = struct.pack("<IiiHHIIiiII", 40, w, h * 2, 1, 32, 0, len(pixels) + len(mask), 0, 0, 0, 0) + pixels + mask
        ico = struct.pack("<HHH", 0, 1, 1) + struct.pack("<BBBBHHII", w, h, 0, 0, 1, 32, len(dib), 22) + dib
        for name in ("Alpha", "Beta"):
            (icon_dir / f"{name}.ico").write_bytes(ico)
        (root / "plans").mkdir()
        plan_file = root / "plans" / "TODO-01-alpha.md"
        plan_file.write_text("| Order | Section | Deliverable | Depends On | Status |\n| :---: | :-----: | --- | --- | :----: |\n"
                             "|   1   |   §1    | One | -- |  [ ]   |\n|   2   |   §2    | Two | §1 |  [ ]   |\n", encoding="utf-8")
        (root / "docs" / "readme").mkdir(parents=True)
        tools_map = {"decision": "docs/decision.md", "tools": [
            {"name": "Alpha", "job": "does alpha", "icon": "icons/Alpha.ico", "plan": {"file": "plans/TODO-01-alpha.md"}, "frozen": True},
            {"name": "Beta", "job": "does beta", "icon": "icons/Beta.ico", "plan": {"file": "plans/TODO-01-alpha.md"}, "new": True}]}
        (root / "docs" / "readme" / "tools.json").write_text(json.dumps(tools_map), encoding="utf-8")
        (root / "todo").mkdir()
        projection = root / "todo" / "implementation-plan.md"
        projection.write_text("### Phase 0 -- First\n\n| [x] | `D00 T01 §1` | a |\n| [ ] | `D00 T01 §2` | b |\n\n"
                              "### Phase 1 -- Second\n\n| [ ] | `D01 T01 §1` | c |\n", encoding="utf-8")
        (root / "README.md").write_text("# Fixture\n\n<!-- tool-gallery:begin -->\n<!-- tool-gallery:end -->\n\n"
                                        "<!-- plan-progress:begin -->\n<!-- plan-progress:end -->\n", encoding="utf-8")
        ready = [{"ref": "D00 T01 §2"}]

        readme, icons = build(root, ready)
        check("a row per mapped tool, with its icon, frozen marker and state",
              "**Alpha** (frozen)" in readme and "| does alpha | AutoIt, shipping | planned" in readme and "new, C++ only" in readme
              and set(icons) == {"docs/readme/icons/Alpha.png", "docs/readme/icons/Beta.png"}, readme)
        idat = icons["docs/readme/icons/Alpha.png"][41:]   # after the signature, IHDR, and IDAT's length and name
        rows = 48 * (1 + 48 * 4)
        check("an icon's PNG is written the same on every machine: stored blocks, no compressor",
              idat[:2] == b"\x78\x01" and idat[2] == 1 and struct.unpack("<HH", idat[3:7]) == (rows, rows ^ 0xFFFF)
              and zlib.decompress(idat[:2 + 5 + rows + 4]) == b"".join(b"\x00" + bytes((255, 0, 0, 255)) * 48 for _ in range(48)))
        check("an icon's bitmap frame becomes a PNG of its size",
              icons["docs/readme/icons/Alpha.png"][:8] == b"\x89PNG\r\n\x1a\n" and struct.unpack(">II", icons["docs/readme/icons/Alpha.png"][16:24]) == (48, 48))
        plan_file.write_text(plan_file.read_text(encoding="utf-8").replace("|   1   |   §1    | One | -- |  [ ]   |", "|   1   |   §1    | One | -- |  [x]   |"), encoding="utf-8")
        readme2, _ = build(root, ready)
        check("a plan section done changes the tool's state", "in progress, 1 of 2 sections" in readme2, readme2)
        check("the progress block counts each phase and names the next ready one",
              "**1 of 3 sections done**" in readme and "| 0. First | 1 | 2 |" in readme and "Next to run: phase 0, First." in readme, readme)
        projection.write_text(projection.read_text(encoding="utf-8").replace("| [ ] | `D00 T01 §2`", "| [x] | `D00 T01 §2`"), encoding="utf-8")
        readme3, _ = build(root, [{"ref": "D01 T01 §1"}])
        check("a section done moves the totals and the next phase", "**2 of 3 sections done**" in readme3 and "Next to run: phase 1, Second." in readme3, readme3)
        readme4, _ = build(root, [])
        check("with nothing ready, the block says none is", "Next to run: none" in readme4, readme4)

        (root / "extensions" / "Gamma").mkdir()
        try:
            build(root, ready)
            refused = None
        except Stale as stale:
            refused = str(stale)
        check("a tool the tree has and the map lacks is refused by name", refused is not None and "Gamma" in refused, repr(refused))
        (root / "extensions" / "Gamma").rmdir()

        write(root, ready)
        before = {p: p.read_bytes() for p in root.rglob("*") if p.is_file()}
        clean = stale_parts(root, ready)
        after = {p: p.read_bytes() for p in root.rglob("*") if p.is_file()}
        check("--check on a current tree finds nothing stale and changes no file", clean == [] and before == after, repr(clean))
        text = (root / "README.md").read_text(encoding="utf-8").replace("does alpha", "does alpha, edited by hand")
        (root / "README.md").write_text(text, encoding="utf-8")
        stale = stale_parts(root, ready)
        check("a hand edit inside the gallery is named stale", stale == ["the tool-gallery block in README.md"], repr(stale))
    if failed:
        print(f"self-test: {len(failed)} failed: " + "; ".join(failed))
        return 1
    print("self-test: all pass")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="readme-blocks.py", description="Generate the README's tool gallery and progress block.")
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args(argv)
    try:
        if args.self_test:
            return self_test()
        if args.check:
            stale = stale_parts(REPO)
            for part in stale:
                print(f"readme-blocks: stale: {part}; run python scripts/readme-blocks.py")
            if not stale:
                print("readme-blocks: README.md's generated blocks and icons are current")
            return 1 if stale else 0
        write(REPO)
        print("readme-blocks: wrote the tool gallery, the progress block and the gallery's icons")
        return 0
    except Stale as stale:
        print(f"readme-blocks: refused: {stale}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
