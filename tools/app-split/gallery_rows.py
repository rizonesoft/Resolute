"""Write the README gallery's `moved` rows and their icons from the tools' own repositories.

Every tool left this repository for its own (docs/plans/2026-11-15-app-split.md). The README's gallery still lists
them: this reads each tool's spec under tools/app-split/specs for its name and its one-line job, copies the 48 pixel
render of its icon from <Resolute_Bin>/<Tool>/brand/ to docs/readme/icons/, and writes the rows to
docs/readme/tools.json. scripts/readme-blocks.py then renders them. Run it again when a tool's name, tagline or icon
changes:

    python tools/app-split/gallery_rows.py [D:\\Resolute_Bin]
"""
import json
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BIN = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(r"D:\Resolute_Bin")


def main() -> int:
    rows, missing = [], []
    for spec_file in sorted((ROOT / "tools" / "app-split" / "specs").glob("*.json"), key=lambda p: p.stem.lower()):
        spec = json.loads(spec_file.read_text(encoding="utf-8"))
        icon = BIN / spec["name"] / "brand" / f"{spec['slug']}-icon-48.png"
        if not icon.is_file():
            missing.append(f"{spec['name']}: {icon}")
            continue
        shutil.copyfile(icon, ROOT / "docs" / "readme" / "icons" / f"{spec['name']}.png")
        rows.append({"name": spec["name"], "display": spec["display"], "job": spec["tagline"].rstrip(".") + "."})
    if missing:
        print("gallery_rows: no icon yet for\n  " + "\n  ".join(missing))
        return 1
    path = ROOT / "docs" / "readme" / "tools.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    data["moved"] = sorted(rows, key=lambda row: row["display"].lower())
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8", newline="\n")
    print(f"gallery_rows: {len(rows)} tool(s) listed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
