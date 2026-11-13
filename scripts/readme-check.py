"""Lint and link gate for the repository's face (D00 T05 §2).

    python scripts/readme-check.py             check README.md, CONTRIBUTING.md, SECURITY.md and the GitHub templates
    python scripts/readme-check.py --self-test

Each problem is named with its file and line, exit 1 when there is any:
- a relative link, image or <source> whose file does not exist, or whose #anchor names no heading there (GitHub's slugs);
- an em dash, or an en dash between words (a numeric range such as 1-5 is fine), which AGENTS.md rules out;
- a heading that skips a level, or more than one top-level heading;
- a paragraph broken across lines (AGENTS.md: one line per paragraph and per list item);
- trailing whitespace;
- a README toolchain badge whose llvm-mingw version is not the one toolchain.json pins.
Links to the web are not fetched: this gate runs offline on every push. Stdlib only.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
FILES = ["README.md", "CONTRIBUTING.md", "SECURITY.md", ".github/PULL_REQUEST_TEMPLATE.md"]
TEMPLATE_GLOB = ".github/ISSUE_TEMPLATE/*.md"

LINK = re.compile(r"(?<!!)\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
IMAGE = re.compile(r"!\[[^\]]*\]\(([^)\s]+)\)")
HTML_SRC = re.compile(r"""<(?:img|source)\b[^>]*?\b(?:src|srcset)\s*=\s*["']([^"']+)["']""", re.IGNORECASE)
HTML_HREF = re.compile(r"""<a\b[^>]*?\bhref\s*=\s*["']([^"']+)["']""", re.IGNORECASE)


def slug(heading: str) -> str:
    """GitHub's anchor for a heading: markup removed, lower case, punctuation dropped, spaces to hyphens."""
    text = re.sub(r"`([^`]*)`", r"\1", heading)
    text = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", text)
    text = re.sub(r"<[^>]+>", "", text).strip().lower()
    text = re.sub(r"[^\w\- ]", "", text)
    return text.replace(" ", "-")


def anchors(path: Path) -> set[str]:
    found, seen, fenced = set(), {}, False
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.lstrip().startswith("```"):
            fenced = not fenced
            continue
        heading = re.match(r"^#{1,6}\s+(.*?)\s*#*\s*$", line)
        if heading and not fenced:
            base = slug(heading.group(1))
            count = seen.get(base, 0)
            found.add(base if count == 0 else f"{base}-{count}")
            seen[base] = count + 1
    for name in re.findall(r"""<a\b[^>]*\bname\s*=\s*["']([^"']+)["']""", path.read_text(encoding="utf-8")):
        found.add(name)
    return found


def check_file(path: Path, repo: Path) -> list[str]:
    problems = []
    rel = path.relative_to(repo).as_posix()
    lines = path.read_text(encoding="utf-8").splitlines()
    fenced, top_level, last_level, in_html_comment = False, 0, 0, False
    previous_prose = False
    # A template's YAML front matter (between --- lines at the top) is data for GitHub, not prose.
    front_matter_end = 0
    if lines and lines[0].strip() == "---":
        front_matter_end = next((i + 1 for i in range(1, len(lines)) if lines[i].strip() == "---"), 0)
    for number, line in enumerate(lines, 1):
        where = f"{rel}:{number}"
        if number <= front_matter_end:
            continue
        if line.lstrip().startswith("```"):
            fenced = not fenced
            previous_prose = False
            continue
        if fenced:
            continue
        if "<!--" in line and "-->" not in line:
            in_html_comment = True
        if in_html_comment:
            if "-->" in line:
                in_html_comment = False
            previous_prose = False
            continue
        if line != line.rstrip():
            problems.append(f"{where}: trailing whitespace")
        if "—" in line:
            problems.append(f"{where}: an em dash; use a comma, colon, parentheses or a full stop")
        if re.search(r"[A-Za-z]\s*–\s*[A-Za-z]", line):
            problems.append(f"{where}: an en dash between words; use a comma, colon or parentheses")
        heading = re.match(r"^(#{1,6})\s", line)
        if heading:
            level = len(heading.group(1))
            if level == 1:
                top_level += 1
                if top_level > 1:
                    problems.append(f"{where}: a second top-level heading")
            elif last_level and level > last_level + 1:
                problems.append(f"{where}: a heading skips from level {last_level} to {level}")
            last_level = level
        stripped = line.strip()
        prose = bool(stripped) and not heading and not re.match(r"^([-*+]|\d+\.)\s|^\||^>|^<|^!\[|^\[!|^---+$|^={3,}$", stripped)
        if prose and previous_prose:
            problems.append(f"{where}: a paragraph continues on a new line; keep each paragraph on one line")
        previous_prose = prose
        for pattern in (LINK, IMAGE, HTML_SRC, HTML_HREF):
            for target in pattern.findall(line):
                problems += check_target(target, path, repo, where)
    return problems


def check_target(target: str, source: Path, repo: Path, where: str) -> list[str]:
    target = target.split()[0]   # a srcset entry may carry a descriptor
    if re.match(r"^[a-z][a-z0-9+.-]*:", target, re.IGNORECASE) or target.startswith("//"):
        return []   # the web, mail and the like: not fetched offline
    file_part, _, anchor = target.partition("#")
    destination = source if not file_part else (source.parent / file_part).resolve()
    if file_part and not destination.exists():
        return [f"{where}: links to {file_part}, which does not exist"]
    if anchor and destination.is_file() and destination.suffix.lower() == ".md" and anchor not in anchors(destination):
        return [f"{where}: links to #{anchor} in {destination.relative_to(repo).as_posix() if destination.is_relative_to(repo) else destination}, which has no such heading"]
    return []


def targets(repo: Path) -> list[Path]:
    paths = [repo / name for name in FILES if (repo / name).is_file()]
    return paths + sorted(repo.glob(TEMPLATE_GLOB))


def toolchain_badge(repo: Path) -> list[str]:
    """The README's toolchain badge names the pinned llvm-mingw version (shields writes a hyphen as two)."""
    pin_file, readme = repo / "toolchain.json", repo / "README.md"
    if not pin_file.is_file() or not readme.is_file():
        return []
    components = json.loads(pin_file.read_text(encoding="utf-8"))["components"]
    pinned = next((c["version"] for c in components if c.get("name") == "llvm-mingw"), None)
    shown = re.findall(r"img\.shields\.io/badge/llvm--mingw-([0-9A-Za-z.]+)-", readme.read_text(encoding="utf-8"))
    if not shown:
        return ["README.md: no llvm-mingw toolchain badge"]
    return [f"README.md: the toolchain badge says llvm-mingw {v}, toolchain.json pins {pinned}" for v in shown if v != pinned]


def run(repo: Path) -> list[str]:
    problems = toolchain_badge(repo)
    for name in FILES:
        if not (repo / name).is_file():
            problems.append(f"{name}: missing")
    for path in targets(repo):
        problems += check_file(path, repo)
    return problems


def self_test() -> int:
    failed = []

    def check(name: str, ok: bool, detail: str = "") -> None:
        print(("PASS " if ok else "FAIL ") + name + ("" if ok or not detail else f": {detail}"))
        if not ok:
            failed.append(name)

    with tempfile.TemporaryDirectory(prefix="readme-check-") as tmp:
        root = Path(tmp)
        (root / ".github" / "ISSUE_TEMPLATE").mkdir(parents=True)
        (root / "docs").mkdir()
        (root / "docs" / "guide.md").write_text("# Guide\n\n## How do I start?\n", encoding="utf-8")
        (root / "image.png").write_bytes(b"\x89PNG")
        (root / "toolchain.json").write_text(json.dumps({"components": [{"name": "llvm-mingw", "version": "20260908"}]}), encoding="utf-8")
        clean = ("# Project\n\n![llvm-mingw](https://img.shields.io/badge/llvm--mingw-20260908-blue)\n\nOne line per paragraph, see [the guide](docs/guide.md#how-do-i-start) and [below](#usage).\n\n"
                 "## Usage\n\n<img src=\"image.png\" alt=\"shot\">\n\n- an item\n- another\n\n| a | b |\n| - | - |\n\nA range of 1–5 is fine.\n")
        for name in ("CONTRIBUTING.md", "SECURITY.md", ".github/PULL_REQUEST_TEMPLATE.md"):
            (root / name).write_text("# Title\n\nText.\n", encoding="utf-8")
        (root / "README.md").write_text(clean, encoding="utf-8")
        (root / ".github" / "ISSUE_TEMPLATE" / "bug.md").write_text("---\nname: Bug\nabout: Report one\nlabels: bug\n---\n\n## What happened?\n", encoding="utf-8")
        check("a clean set passes, a template's front matter read as data", run(root) == [], repr(run(root)))
        cases = {
            "a broken relative link": (clean.replace("docs/guide.md#", "docs/missing.md#"), "links to docs/missing.md, which does not exist"),
            "a broken anchor": (clean.replace("#how-do-i-start", "#how-do-i-stop"), "which has no such heading"),
            "a missing image": (clean.replace("image.png", "absent.png"), "links to absent.png, which does not exist"),
            "an em dash": (clean.replace("One line per paragraph,", "One line per paragraph —"), "an em dash"),
            "a skipped heading level": (clean.replace("## Usage", "#### Usage"), "skips from level 1 to 4"),
            "a wrapped paragraph": (clean.replace("A range of 1–5 is fine.", "A range of 1–5\nis fine."), "keep each paragraph on one line"),
            "trailing whitespace": (clean.replace("- an item", "- an item  "), "trailing whitespace"),
            "a toolchain badge off the pin": (clean.replace("llvm--mingw-20260908", "llvm--mingw-20250101"), "toolchain.json pins 20260908"),
        }
        for label, (text, expected) in cases.items():
            (root / "README.md").write_text(text, encoding="utf-8")
            problems = run(root)
            check(f"{label} fails by name", any(expected in p and p.startswith("README.md:") for p in problems), repr(problems))
        (root / "README.md").write_text(clean, encoding="utf-8")
        (root / "SECURITY.md").unlink()
        check("a missing trust file fails by name", "SECURITY.md: missing" in run(root), repr(run(root)))
    if failed:
        print(f"self-test: {len(failed)} failed: " + "; ".join(failed))
        return 1
    print("self-test: all pass")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="readme-check.py", description="Lint and link gate for the repository's face.")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args(argv)
    if args.self_test:
        return self_test()
    problems = run(REPO)
    for problem in problems:
        print(f"readme-check: {problem}")
    if not problems:
        print(f"readme-check: {len(targets(REPO))} files clean")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
