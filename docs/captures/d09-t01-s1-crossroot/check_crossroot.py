import pathlib, re, sys

ev = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else r"R:\scratch\crossroot-evidence")
readback = (ev / "descriptor-readback.txt").read_text(encoding="utf-8", errors="replace")
warnings = (ev / "distro-warnings.txt").read_text(encoding="utf-8", errors="replace")

tools = re.findall(r"^=== (\w+)\\", readback, re.M)
EXPECTED = ["BiosCodes", "Chromin", "ComIntRep", "DVDRepair", "Edgemin", "Firemin",
            "MemBoost", "Ownership", "PixRepair", "ReBar", "Resolute", "USBRepair", "Watermin"]
fail = 0
if sorted(tools) != EXPECTED:
    print(f"expected exactly the 13 tools {EXPECTED}, found {tools}")
    fail += 1
for tool in tools:
    m = re.search(rf"^Icon=(.+)$", readback.split(f"=== {tool}\\")[1].split("===")[0], re.M)
    icon = m.group(1).strip() if m else ""
    if not re.match(r"^R:\\resolute-repair2\\resolute_au3\\SDK\\Resources\\Icons\\" + tool + r"\.ico$", icon):
        print(f"BAD ICON {tool}: {icon}")
        fail += 1
    if f"Icons\\{tool}.ico (different root); absolute path kept." not in warnings:
        print(f"MISSING WARNING {tool}")
        fail += 1
print(f"crossroot evidence: tools={len(tools)} failures={fail}")
sys.exit(1 if fail else 0)
