"""Name the right repository on every Moved line and struck item of a plan section that became several tools.

mark_moved.py takes one repository per section. A section that was split into two or more tools (the tracker says which)
was left pointing every item at the first one. This reads the tracker's queue, and for each such section rewrites the
Moved line to list all of its repositories, and each struck item's arrow to the tools that item names, or to all of the
section's tools when it names none.

    python tools/app-split/fix_moved_names.py            rewrite in place and report
    python tools/app-split/fix_moved_names.py --check    exit 1 if a rewrite is still needed
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TRACKER = ROOT / "docs" / "plans" / "2026-11-15-app-split.md"
ROW = re.compile(r"^\| \d+ \| (\w+) \| new \| 05/T(\d+) ((?:§\d+(?:, )?)+) \|", re.M)
ARROW = re.compile(r" -> `rizonesoft/[\w`, /]+$")
MOVED = re.compile(r"worked in the `rizonesoft/.*?(?:by its own plan|each by its own plan)\.")


def sections() -> dict[tuple[str, int], list[str]]:
    found: dict[tuple[str, int], list[str]] = {}
    for name, todo, refs in ROW.findall(TRACKER.read_text(encoding="utf-8")):
        for number in re.findall(r"§(\d+)", refs):
            found.setdefault((todo, int(number)), []).append(name)
    return found


def rewrite(path: Path, number: int, tools: list[str]) -> str:
    lines = path.read_text(encoding="utf-8").split("\n")
    start = next(i for i, line in enumerate(lines) if line.startswith(f"## {number}. "))
    end = next((i for i in range(start + 1, len(lines)) if lines[i].startswith("## ")), len(lines))
    repos = ", ".join(f"`rizonesoft/{t}`" for t in tools[:-1]) + f" and `rizonesoft/{tools[-1]}`"
    for i in range(start, end):
        line = lines[i]
        if "**Moved:**" in line:
            lines[i] = MOVED.sub(f"worked in the {repos} repositories (under `D:\\\\Resolute_Bin`), each by its own plan.", line)
        elif arrow := ARROW.search(line):
            named = [t for t in tools if re.search(rf"\b{t}\b", line[:arrow.start()])]
            lines[i] = ARROW.sub(" -> " + ", ".join(f"`rizonesoft/{t}`" for t in (named or tools)), line)
    return "\n".join(lines)


def main() -> int:
    check, changed = "--check" in sys.argv, []
    for (todo, number), tools in sorted(sections().items()):
        if len(tools) < 2:
            continue
        path = next((ROOT / "todo" / "05-new-tools").glob(f"TODO-{todo}-*.md"))
        text = rewrite(path, number, tools)
        if text != path.read_text(encoding="utf-8"):
            changed.append(f"D05 T{todo} §{number}: {', '.join(tools)}")
            if not check:
                path.write_text(text, encoding="utf-8", newline="\n")
    print("\n".join(changed) or "fix_moved_names: every split section names its repositories")
    return 1 if check and changed else 0


if __name__ == "__main__":
    sys.exit(main())
