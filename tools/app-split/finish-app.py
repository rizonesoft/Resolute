#!/usr/bin/env python3
"""Steps 5 and 6 of the app split for one app, from its spec: the brand build file, DESIGN.md, README.md, the
reference README, the project section of AGENTS.md and the plan. docs/plans/2026-11-15-app-split.md is the tracker.

    python tools/app-split/finish-app.py tools/app-split/specs/<App>.json [--bin D:\\Resolute_Bin]

A file the app already has is left alone, so a hand-written one wins; pass --replace <name> to rewrite one. The
session then builds the assets (`python brand/build.py`), writes the shortcuts, validates and syncs the plan, and
commits and pushes, which is step 7.

The plan is one file on one skeleton every ported tool shares (build, baseline, inventory, engine, parity, window,
activity, settings and About, the tool's own enhancements, distribution), filled with the tool's own items from the
spec. Stdlib only.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

WAIT = "sdk-framework"


def table(rows: list[list[str]], head: list[str]) -> str:
    lines = ["| " + " | ".join(head) + " |", "| " + " | ".join("---" for _ in head) + " |"]
    return "\n".join(lines + ["| " + " | ".join(r) + " |" for r in rows])


def build_py(s: dict) -> str:
    hue, icon = s["hue"], s["icon"]
    return f'''#!/usr/bin/env python3
"""Build {s["display"]}'s brand assets: the icon, its renders, the wordmarks and both banners.

    python brand/build.py            write every asset under brand/
    python brand/build.py --check    exit 1 when a tracked asset differs from what this script builds

The icon was chosen by the operator on 2026-11-15: {icon["idea"]} DESIGN.md describes it;
sdk/brand/brandkit.py turns this description into the files. Run `pwsh scripts/sdk.ps1` first: the kit and the fonts
come from the pinned SDK.
"""
import sys
from pathlib import Path

BRAND = Path(__file__).resolve().parent
sys.path.insert(0, str(BRAND.parent / "sdk" / "brand"))
import brandkit  # noqa: E402

# The icon on a 96-unit grid, free-standing. A stroke in the fill's colour with round joins rounds every corner.
LARGE = {icon["large"]!r}
# The drawing used below 40 pixels: fewer parts, larger openings.
SMALL = {icon["small"]!r}

if __name__ == "__main__":
    sys.exit(brandkit.main(BRAND, brandkit.app_assets(
        slug={s["slug"]!r}, name={s["display"]!r}, tagline={s["tagline"]!r},
        large=LARGE, small=SMALL, social_ground={hue["social_ground"]!r}, social_muted={hue["social_muted"]!r})))
'''


def design_md(s: dict) -> str:
    hue, icon, win, slug, name = s["hue"], s["icon"], s["window"], s["slug"], s["display"]
    palette = [[f"{hue['name']} light", f"`{hue['light']}`", "The face toward the light"],
               [hue["name"], f"`{hue['dark']}`", "The face away from the light"]]
    palette += [[n, f"`{v}`", use] for n, v, use in hue.get("extra", [])]
    palette += [["Social ground", f"`{hue['social_ground']}`", "The social banner's ground"],
                ["Social muted", f"`{hue['social_muted']}`", "Secondary text on that ground"],
                ["Graphite, Paper", "`#17191E`, `#F6F5F2`", "The suite's neutrals: banner ground and text"]]
    assets = [[f"`{slug}-icon.svg`, `-512.png`, `-256.png`, `-192.png`, `-64.png`, `-48.png`", "The icon, detailed drawing"],
              [f"`{slug}-icon-small.svg`, `-32.png`, `-16.png`", "The icon's small drawing"],
              [f"`{slug}.ico`", "The Windows icon, ten sizes from 16 to 256"],
              [f"`{slug}-wordmark-light.svg`, `.png`, `-dark.svg`, `.png`", "The icon with the name"],
              ["`readme-banner.svg`, `.png`", "The README banner, 1280 by 320"],
              ["`social-preview.svg`, `.png`", "The repository's social preview, 1280 by 640"]]
    old = "The icons the AutoIt version shipped with are kept under `reference/au3/` as a record and are never used." if s.get("au3") else ""
    return f"""# DESIGN.md

{name}'s design guide: what is its own, and where the rest comes from.

**Everything not said here is the suite's.** Colour tokens, type ramp, spacing, motion, window chrome, accessibility floor, every control and the tool window's layout come from the suite's design contract, `sdk/DESIGN.md` (Resolute-SDK at the commit `sdk.json` pins). {name} never draws a control the shared library provides and never hardcodes a colour, a size or a spacing value. This file holds only what the contract leaves to a tool: its identity, and what its window's sections contain.

Both were chosen by the operator on 2026-11-15, each from three directions.

## 1. Identity

**{icon["idea"]}**

{chr(10).join("- " + p for p in icon["points"])}

{table(palette, ["Name", "Value", "Use"])}

Type is the suite's: Sora Bold for the name, Inter for a tagline. Inside the tool, text is the system font, as the contract says.

Tagline: "{s["tagline"]}".

The assets are in `brand/`, all written by `python brand/build.py` from the description in that file (`--check` fails when one differs from what the script builds). The kit and the fonts come from `sdk/brand/`.

{table(assets, ["File", "What it is"])}

Rules: the icon is never recoloured, outlined, stretched or set on a tile, and its openings are never filled. {old}

## 2. The window

**The suite's tool window** (`sdk/DESIGN.md` section 16): sections on the left, the selected section's content on the right with its title and actions in a header, a status bar under both. What is {name}'s own is the list of sections and what the first one shows.

### Sections

{table([[a, b] for a, b in win["sections"]], ["Section", "What it holds"])}

### The {win["sections"][0][0]} screen

{chr(10).join("- " + n for n in win["notes"])}

### What the window does not have

{win["cut"]}
"""


def readme_md(s: dict) -> str:
    name, slug, r = s["display"], s["slug"], s["readme"]
    ref = "| `reference/au3/` | The AutoIt original: source, shipped files, the last distribution. Frozen |\n" if s.get("au3") else ""
    status_ref = " The AutoIt original, which is the specification the port is measured against, is under [`reference/au3/`](reference/au3/)." if s.get("au3") else ""
    new = "\n".join(f"- **{a}** {b}" for a, b in r["new"])
    return f"""<p align="center">
  <img src="brand/readme-banner.png" alt="{name}: {s["tagline"]}" width="100%">
</p>

# {name}

**{r["lead"]}**

{name} is one of the tools of [Resolute](https://github.com/rizonesoft/Resolute), Rizonesoft's suite of Windows system utilities. It ships on its own as a single executable and is also bundled with the Resolute launcher.

## What does it do?

{chr(10).join(p + chr(10) for p in r["what"]).rstrip()}

## What is new in the C++ version?

{r["new_intro"]}

{new}

## Status

Planned, not yet built. The plan is in [`todo/`](todo/), and [`todo/implementation-plan.md`](todo/implementation-plan.md) is its generated view.{status_ref}

## Building

On Windows 10 or 11 x64 with Git and PowerShell 7:

```powershell
git clone https://github.com/rizonesoft/{s["name"]}.git
cd {s["name"]}
pwsh scripts/sdk.ps1           # fetches Resolute-SDK at the commit sdk.json pins, into sdk/
pwsh sdk/scripts/bootstrap.ps1 # downloads the pinned toolchain into sdk/reskit/, hash-checked
```

The build itself arrives with the first section of the plan. {name} uses the suite's shared UI library, build rules and toolchain from [Resolute-SDK](https://github.com/rizonesoft/Resolute-SDK), pinned by commit in [`sdk.json`](sdk.json).

## Repository layout

| Path | What is there |
| --- | --- |
| `src/`, `resources/`, `tests/` | The C++ tool, its resources and its Catch2 tests, as the plan builds them |
{ref}| `brand/`, `DESIGN.md` | The tool's icon, wordmark and banners, and the guide to them and to its window |
| `todo/` | The plan |
| `sdk.json` | The Resolute-SDK commit this repository builds against |
| `docs/origin/` | The tool's plan text as it stood in the Resolute repository at the move |

## License

GNU General Public License, version 3. See [`LICENSE`](LICENSE). Resolute-SDK, which this tool links, is MIT.
"""


def reference_md(s: dict, ref: Path) -> str:
    several = len(s["au3"]) > 1
    what = (f"the AutoIt tools {', '.join(s['au3'][:-1])} and {s['au3'][-1]}, which {s['display']} merges into one, each in its own folder"
            if several else f"the AutoIt version of {s['display']} as it ships today")
    prefix = "<tool>/" if several else ""
    rows = [[f"`{prefix}src/`", "The script, its build descriptor (`.sni`), its settings template and its document templates"],
            [f"`{prefix}shipped/`", "What an installed copy carries: settings, documents and language packs"],
            [f"`{prefix}update/`", "The update files the tool's update check read"],
            [f"`{prefix}icons/`", "The icons the AutoIt tool shipped with, kept as a record. The C++ tool's identity is new and is in `brand/`: nothing is derived from these"],
            [f"`{prefix}dist/`", "The last distribution build, for a driven parity run"],
            [f"`{prefix}local/`", "Not tracked: older distribution builds, loose executables and run logs, as they were on the development machine"]]
    # Only the folders this app really has: not every tool shipped a distribution build or update files.
    tools = s["au3"] if several else [""]
    def present(folder: str) -> bool:
        return any((ref / tool / folder).exists() for tool in tools)
    rows = [row for row, folder in zip(rows, ("src", "shipped", "update", "icons", "dist", "local")) if present(folder)]
    if not present("dist"):
        rows.append(["(no `dist/`)", "No distribution zip came with this tool. A driven run uses a build under `local/`, which is not tracked: the baseline section of the plan records which one"])
    return f"""# The AutoIt original

This folder is {what}. It is the specification the C++ tool is measured against: frozen, read, never edited. Changing a file here changes what the port has to match.

It was moved out of the Resolute repository on 2026-11-15. `MOVED-FROM.tsv` maps every file to the path it had there.

{table(rows, ["Path", "What it is"])}

{s["reference"]["note"]}

The scripts cannot be compiled from this folder alone. They include the suite's shared AutoIt framework (`ReBar`, the shared includes and resources), which moves to `reference/au3-sdk/` in Resolute-SDK. For the port that does not matter: the parity check runs the shipped executable from `dist/` and compares its effect, and the source is read for what the tool does.
"""


def agents_section(s: dict) -> str:
    name = s["display"]
    frozen = ("- **The effect is frozen.** What the AutoIt original computes and writes is reproduced exactly and proven by the parity check. Restructuring is allowed; changing the effect is not.\n"
              if s.get("frozen") else "")
    ref = "| `reference/au3/` | The AutoIt original. Frozen: read, never edited |\n" if s.get("au3") else ""
    return f"""## This project

{name} is one tool of Rizonesoft's Resolute suite of Windows system utilities: {s["job"]} It is developed and released standalone, as one statically linked executable, and is also bundled with the Resolute launcher (`rizonesoft/Resolute`), which imports it only when a distribution is built. Windows only: C++23 on llvm-mingw, CMake and Ninja, the suite's Direct2D UI library, Catch2 v3 for tests.

| Path | Purpose |
| ---- | ------- |
| `src/`, `resources/`, `tests/` | The tool, its embedded resources and its Catch2 suites |
| `sdk.json`, `sdk/` | The Resolute-SDK pin, and the SDK at that commit (not tracked; `pwsh scripts/sdk.ps1`) |
{ref}| `brand/`, `DESIGN.md` | The tool's identity, built by `python brand/build.py`, and its window's sections |
| `todo/` | The plan. Read `todo/README.md` before authoring or implementing |

Rules that are this project's own:

- **Shared code comes from the SDK and is never copied.** The UI library, the framework, the repair contract, the build policies and the toolchain are `sdk/`. If the tool needs something shared, it is added to Resolute-SDK and taken here by bumping `sdk.json`. A private settings writer, log writer, About dialog or progress bar is a defect.
- **`sdk/` is never edited here.** A change to it is made in the SDK's repository.
{frozen}- **The tool never depends at runtime** on another tool, on the launcher or on a suite-wide file.
- **Every surface answers to `sdk/DESIGN.md`**, and the tool's own `DESIGN.md` says what its sections contain. No hardcoded colour, size or spacing.
- **User systems first:** atomic writes, readback, a reverse for every system change or an honest statement that there is none, and elevation checked at the action.
- **Sections waiting on the SDK's framework** carry the Need `{WAIT}`. It is removed when the framework section they name has shipped in the SDK and `sdk.json` pins a commit that has it.
- **Licence:** GPL v3. Resolute-SDK is MIT and may be linked; nothing GPL goes back into it.

"""


def section(n: int, title: str, intro: str, phase: int, needs: str, items: list[str], checkpoint: str, build: list[str],
            commit: str, freeze: str | None, surface: dict | None = None) -> str:
    out = [f"## {n}. {title}", "", intro, "", f"**Phase:** {phase}", f"**Needs:** {needs}", f"**Surface:** {'yes' if surface else 'no'}"]
    if surface:
        out += [f"**Fidelity:** {surface['fidelity']}", f"**Job:** {surface['job']}", f"**Treatment:** {surface['treatment']}", f"**Chrome:** {surface['chrome']}"]
    if freeze:
        out.append(f"**Freeze check:** {freeze}")
    out += ["", "**Build order:**", ""] + [f"{i}. {b}" for i, b in enumerate(build, 1)] + [""]
    out += [f"- [ ] {item}" for item in items] + [f"- [ ] Commit: `{commit}`", "", f"**Test checkpoint:** {checkpoint}", ""]
    return "\n".join(out)


def plan_md(s: dict) -> tuple[str, list[str]]:
    name, exe, p, win = s["display"], s["name"], s["plan"], s["window"]
    frozen = bool(s.get("frozen"))
    port = bool(s.get("au3"))
    first = win["sections"][0][0]
    ctest = "sdk\\reskit\\cmake\\bin\\ctest.exe --preset debug"
    fr_ref = "Nothing under `reference/au3/` changes, checked with `git status --short reference`." if frozen else None
    fr_parity = "The parity check of §5 re-runs with zero differing fields." if frozen else None
    secs: list[tuple[str, str, str]] = []   # title, depends, body

    def add(title, depends, **kw):
        n = len(secs) + 1
        secs.append((title, depends, section(n, title, **kw)))
        return n

    add("Build Skeleton on the Pinned SDK", "--", phase=0, needs="windows-host", freeze=fr_ref,
        intro=f"The repository builds an empty {name} window against the pinned SDK with one command, so every later section has somewhere to land and the standalone build is true from the first commit.",
        build=[f"Write `CMakeLists.txt`, `CMakePresets.json` and `scripts/build.ps1` on the SDK's shape. Done when: `pwsh scripts/build.ps1 -Config Debug` produces `Bin\\Debug\\{exe}.exe`.",
               "Write `src/main.cpp`, `resources/app.manifest` and `resources/resource.rc` with the icon from `brand/`. Done when: the executable starts and shows an empty window with the tool's icon."],
        items=[f"Write the root `CMakeLists.txt`: `project({exe} LANGUAGES CXX RC)`, `include(sdk/cmake/ResoluteSdk.cmake)`, `resolute_sdk_add_libraries()`, the `{exe}` target with `resolute_set_warnings`, and `resolute_assert_warnings_complete()` last. Done when: `sdk\\reskit\\cmake\\bin\\cmake.exe --preset debug` configures. Cheaper substitute: retyping the standard, definitions or link flags here, which the SDK owns.",
               "Write `CMakePresets.json` with `debug` and `release` presets naming the compilers under `sdk/reskit/`. Done when: both presets configure from an empty `build/`. Cheaper substitute: compilers found on `PATH`, which makes two machines build differently.",
               "Write `scripts/build.ps1` (`-Config Debug|Release`) with the toolchain assertion and the stale-tree cleanup, on the shape of Resolute's. Done when: with `sdk/` absent it exits 1 naming `pwsh scripts/sdk.ps1` as the fix.",
               f"Write `src/main.cpp` opening one empty top-level window through the SDK's UI library, with `resources/app.manifest` declaring per-monitor DPI v2 and the Windows 10 1809 floor. Done when: `Bin\\Debug\\{exe}.exe` shows a window that re-lays out when dragged between monitors of different scale.",
               f"Embed `brand/{s['slug']}.ico` through `resources/resource.rc`. Done when: the executable shows the tool's icon in Explorer and on the taskbar at 100 and 150 percent.",
               "Add `tests/CMakeLists.txt` with Catch2 pinned by commit and one case that the test binary runs. Done when: `" + ctest + "` passes with one case.",
               f"Prove the executable is standalone: copy `Bin\\Release\\{exe}.exe` alone to an empty folder and start it. Done when: it starts, and `llvm-readobj --coff-imports` lists only Windows system libraries."],
        checkpoint=f"`pwsh scripts/build.ps1 -Config Release` ends with `{exe}` `OK`, `{ctest}` passes, and the import table of `Bin\\Release\\{exe}.exe` names no `libc++` or `libunwind` library.",
        commit="build: an empty window on the pinned SDK, standalone")

    if port:
        add("AutoIt Baseline Captured", "§1", phase=1, needs="windows-host, attended", freeze=fr_ref,
            intro=f"The shipped AutoIt tool is the only source of truth for what {name} does. This section runs it once, around a snapshot of everything it touches, and commits what it did, before any C++ imitates it.",
            build=["Unpack `reference/au3/` `dist/` into a scratch folder and drive the original around a before and after snapshot. Done when: the record of its effect is committed under `docs/baseline/`.",
                   "Capture its windows at 100 percent for the surface inventory. Done when: the captures are committed with their provenance."],
            items=p["baseline_items"] + ["Capture each window of the original to `docs/baseline/` with a provenance file naming the build, the machine and the scale. Done when: every window the inventory of §3 names has a capture.",
                                         "Record in `docs/baseline/README.md` exactly how the run was made, so it can be repeated. Done when: the file names the executable, its build number, the fixture and every step."],
            checkpoint="`git ls-files docs/baseline` lists the effect record, the captures and `README.md`, and the record names every change the run made.",
            commit="baseline: what the shipped AutoIt tool does, recorded from a real run")
        add("Inventory With Shared-Layer Map", "§2", phase=1, needs="none", freeze=fr_ref,
            intro="Everything the AutoIt tool is, with `file:line`, and every piece mapped to the SDK's framework, the SDK's repair contract, or this tool's own code. The section is done when a walk of the source finds nothing unaccounted.",
            build=["Write `docs/inventory.md` from a line-by-line walk of the source under `reference/au3/`. Done when: every window, control, string, behaviour, setting and shipped file is recorded with its verdict.",
                   "Map each piece to its home. Done when: no piece maps to two homes and no shared piece maps to the tool."],
            items=p["inventory_items"] + ["Map every inventoried piece in `docs/inventory.md` to the framework, the repair contract or tool code: settings, logging, localization, update, elevation, Preferences, About, crash handling and single instance to the framework. Done when: no piece has two homes. Cheaper substitute: an inventory of the windows without the behaviours, which is a screenshot list, not a port plan.",
                                          "Record each cut (splash, animations, donate strip, anything else the window loses) in `docs/inventory.md` with its reason. Done when: every control of the original is working in a named section or cut by name."],
            checkpoint="`docs/inventory.md` exists, names a home for every piece, and a search of it finds no line marked unmapped.",
            commit="inventory: every piece of the original, with its home")
    base = "§3" if port else "§1"
    eng = p["engine"]
    engine_n = add(eng["title"], base, phase=2, needs=eng.get("needs", "windows-host"), intro=eng["intro"], build=eng["build"], items=eng["items"],
                   checkpoint=eng["checkpoint"], commit=eng["commit"], freeze="The fixtures under `tests/fixtures/` that state the original's effect do not change in this section." if frozen else None)
    if port:
        add("Parity Against the AutoIt Original", f"§{engine_n}", phase=2, needs="windows-host, attended",
            freeze="The baseline under `docs/baseline/` does not change; a difference is fixed in the C++ tool." if frozen else None,
            intro=f"The C++ {name} and the AutoIt original run against the same fixture and their effects are compared field by field. Every difference is fixed in the C++ tool or recorded as a deliberate change with its reason.",
            build=["Write `tests/parity_test.cpp` comparing the engine's effect with the committed baseline. Done when: it reports every differing field by name.",
                   "Fix differences until it reports zero. Done when: the report is quoted in the commit message."],
            items=p["parity_items"] + ["Write `tests/parity_test.cpp`: run the engine against the fixture and compare its record with `docs/baseline/` field by field. Done when: `" + ctest + " -L parity` passes, and fails naming the field when one value in the engine is changed.",
                                       "Record every deliberate difference in `docs/parity.md` with its reason. Done when: the file lists each, or says there is none. Cheaper substitute: loosening the comparison, which hides the difference instead of deciding it."],
            checkpoint=f"`{ctest} -L parity` passes with zero differing fields, quoted, and fails when one engine value is changed.",
            commit="parity: the C++ tool does what the AutoIt original does")
    after = f"§{len(secs)}"
    rows = ", ".join(f"{a} ({b})" for a, b in win["rows"])
    win_n = add(f"Window and {first} Screen", after, phase=3, needs="windows-host, display-session", freeze=fr_parity,
                surface={"fidelity": f"the main window and its {first} section, against `DESIGN.md` section 2 and `sdk/DESIGN.md` section 16, in light and dark at 100 and 150 percent.",
                         "job": f"{win['job']} Consumer: the rendered window, driven with real data and read back.",
                         "treatment": f"every row state shown with an icon and a word, the primary action labelled with what it will do. Cheaper substitute that fails the checkpoint: a list that shows state by colour alone.",
                         "chrome": "the SDK's sidebar, list, toolbar and status bar controls. No control of the tool's own."},
                intro=f"The window the operator chose: sections on the left ({', '.join(a for a, _ in win['sections'])}), the {first} section's content on the right, a status bar under both.",
                build=[f"Build the window in `src/ui/MainWindow.cpp` from the SDK's controls. Done when: every section is in the sidebar and {first} is selected at start.",
                       f"Bind the {first} screen to the engine in `src/ui/{first.replace(' ', '')}View.cpp`. Done when: the rows show the engine's real state."],
                items=[f"Create `src/ui/MainWindow.cpp` with the SDK's sidebar listing {', '.join(a for a, _ in win['sections'])}, the content area and the status bar. Done when: selecting each section switches the content and the selection indicator slides. Cheaper substitute: a private list control, which the contract forbids.",
                       f"Build the {first} screen in `src/ui/{first.replace(' ', '')}View.cpp`: its rows are {rows}. Done when: each row shows the engine's state for it, with an icon and a word. Cheaper substitute: rows typed into the view, which show nothing real.",
                       f"Put the actions in the content header: {win['primary']} as the accent button, {win['secondary']} beside it. Done when: each calls the engine and the rows update from a re-read, not from an assumption.",
                       f"Show the status bar text from the rows, in words (for example \"{win['status']}\"). Done when: it changes with the rows.",
                       "Make every control reachable by keyboard in a sensible tab order, with an accessible name on each. Done when: the window is driven end to end without a mouse, and a UI Automation walk names every control.",
                       "Capture the window in light and dark at 100 and 150 percent to `docs/captures/`. Done when: four captures are committed with their provenance.",
                       "Add a driven test in `tests/window_test.cpp` that starts the window, reads the rows through UI Automation and compares them with the engine. Done when: `" + ctest + " -L window` passes, and fails when a row's state is forced wrong."],
                checkpoint=f"`{ctest} -L window` passes, the four captures exist under `docs/captures/`, and the window is operated by keyboard alone.",
                commit=f"ui: the sidebar window and the {first} screen")
    act_n = add("Activity Section", f"§{win_n}", phase=3, needs="windows-host, display-session", freeze=fr_parity,
                surface={"fidelity": "the Activity section, against `DESIGN.md` section 2.", "job": "a person sees what the tool did and when, without opening a log file. Consumer: the list, read back against the log.",
                         "treatment": "one line per action, newest first, with the time and the outcome in words. Cheaper substitute that fails the checkpoint: showing the raw log file in a text box.",
                         "chrome": "the SDK's list control."},
                intro="What the tool did, newest first: the readable face of its log. Each action the engine takes adds one line here and one line to the log, from one call.",
                build=["Record each engine action in `src/core/Activity.cpp`. Done when: one call writes the log line and the Activity entry.",
                       "Show them in `src/ui/ActivityView.cpp`. Done when: the list matches the log line for line."],
                items=["Add `src/core/Activity.cpp`: an action record (time, what, outcome) written once and read by both the log and the Activity list. Done when: a test shows one engine action produces exactly one record. Cheaper substitute: writing the log and the list separately, which lets them disagree.",
                       "Build `src/ui/ActivityView.cpp` listing the records newest first, the time in monospace. Done when: after two actions the list shows two lines in the right order.",
                       "Make a line's text selectable and copyable. Done when: Ctrl+C on a selected line puts its text on the clipboard.",
                       "Show an empty state with one sentence when nothing has been done. Done when: a first run shows it and it disappears after the first action.",
                       "Cover it in `tests/activity_test.cpp`. Done when: `" + ctest + " -L activity` passes, and fails when the record of an action is dropped."],
                checkpoint=f"`{ctest} -L activity` passes and the Activity list equals the log's lines after a driven run.",
                commit="ui: the Activity section, the log made readable")
    add("Settings and About Sections", f"§{win_n}", phase=3, needs=f"windows-host, display-session, {WAIT}", freeze=fr_parity,
        surface={"fidelity": "the Settings and About sections, against `sdk/DESIGN.md`.", "job": "a person changes language, theme, update and logging settings and sees what version they run. Consumer: the framework's settings file, read back.",
                 "treatment": "the framework's own pages, hosted in the sidebar. Cheaper substitute that fails the checkpoint: a private settings page writing its own file.",
                 "chrome": "the framework's Preferences pages and About page. No page of the tool's own beyond what `DESIGN.md` names."},
        intro="Both sections are the SDK framework's pages hosted in this window: the tool supplies its descriptor and nothing else. They wait on the framework, which is planned in Resolute-SDK and not yet built.",
        build=["Host the framework's Preferences pages in `src/ui/SettingsView.cpp`. Done when: a changed setting is read back from the framework's settings file.",
               "Host the framework's About page in `src/ui/AboutView.cpp` from `src/Descriptor.h`. Done when: it shows this tool's name, version and licence."],
        items=["Write `src/Descriptor.h`: the tool's name, version source, licence, home page and update address, and no behaviour. Done when: the framework builds its About page from it.",
               "Host the framework's Preferences pages in `src/ui/SettingsView.cpp`. Done when: changing the theme there changes the window, and the value is read back from the settings file after a restart. Cheaper substitute: a settings writer in the tool.",
               "Host the framework's About page in `src/ui/AboutView.cpp`. Done when: it shows the descriptor's values and the GPL v3 notice.",
               "Add the tool's own options that `DESIGN.md` names, if any, as a page declared to the framework. Done when: each is listed, persisted by the framework and read back.",
               "Cover both in `tests/settings_test.cpp`. Done when: `" + ctest + " -L settings` passes with a fixture settings file."],
        checkpoint=f"`{ctest} -L settings` passes, and a setting changed in the window is read back from the framework's file after a restart.",
        commit="ui: Settings and About, hosted from the framework")
    reverse_n = None
    for e in p["enhancements"]:
        surface = None
        if e.get("surface"):
            surface = {"fidelity": e["surface"]["fidelity"], "job": e["surface"]["job"], "treatment": e["surface"]["treatment"], "chrome": "the SDK's controls. No control of the tool's own."}
        needs = "windows-host" + (", display-session" if surface else "") + (f", {e['needs']}" if e.get("needs") else "")
        n = add(e["title"], e.get("depends", f"§{win_n}"), phase=4, needs=needs, freeze=fr_parity, surface=surface, intro=e["intro"], build=e["build"], items=e["items"],
                checkpoint=e["checkpoint"], commit=e["commit"])
        if e.get("reverse"):
            reverse_n = n
    add("Distribution Completeness", f"§{len(secs)}", phase=5, needs=f"windows-host, {WAIT}", freeze=fr_parity,
        intro="Everything that makes the tool shippable and not merely working: settings carried over from the AutoIt version, language packs, documents, update file, version, and the checks a release owes.",
        build=["Carry over what an installed AutoIt copy has. Done when: a fixture `.ini` migrates with a log line.",
               "Produce the release set with one command. Done when: `pwsh scripts/release.ps1` writes the portable folder and its checksums."],
        items=[("Migrate an existing AutoIt settings file through the framework, with one log line. Done when: a fixture `.ini` from `reference/au3/` `shipped/` migrates and the values are read back. Cheaper substitute: starting fresh, which loses a user's settings."
                if port else "Declare the tool's settings to the framework with their defaults. Done when: a first run writes them and a second run reads them back."),
               ("Ship the language packs the original has, through the framework's loader. Done when: every pack under `reference/au3/` `shipped/` loads and the pack-hygiene check passes."
                if port else "Ship the English pack through the framework's loader, with every string a key. Done when: a search of `src/` finds no user-facing literal."),
               "Write `docs/guide.md`, the user guide, covering every section of the window. Done when: each section and each action has its paragraph, in the same commit as any behaviour it documents.",
               "Write `CHANGELOG.md` and generate the Changes, License and Readme documents from it and `LICENSE`. Done when: no version or date is typed by hand in any of them.",
               "Derive the version from the git tag at build time into the resource and the descriptor. Done when: the executable's file version, its About page and its update file agree.",
               "Write the update file the framework's update check reads. Done when: a build one version behind is told about the newer one.",
               "Write `scripts/release.ps1` producing the portable folder, its zip and SHA-256 sums. Done when: the zip unpacks to a folder that runs on a machine with nothing else installed. Cheaper substitute: testing from the build tree, which proves it compiles, not that it ships.",
               "Add `scripts/check-all.ps1` and `.github/workflows/gates.yml` running build, tests and the plan gates on every push. Done when: the run for the commit is green."],
        checkpoint="`pwsh scripts/check-all.ps1` ends `check-all: <n> gate(s) ok`, the release zip runs from an empty folder, and the executable, About page and update file state one version.",
        commit="release: the tool ships complete")

    order = [f"| {i} | §{i} | {t} | {d} | [ ] |" for i, (t, d, _) in enumerate(secs, 1)]
    adj = [f"list=applicable @ D00 T01 §{win_n}", "document=not-applicable (the tool produces nothing a user carries, sends or prints)",
           f"settings=applicable @ D00 T01 §{act_n + 1}", f"reporting=applicable @ D00 T01 §{act_n}",
           "notifications=not-applicable (the tool reports on its own surface and in its log; it sends no notification)",
           f"permissions=applicable @ D00 T01 §{engine_n}" if s.get("elevated") else "permissions=not-applicable (nothing the tool does needs a right the user lacks)",
           f"audit=applicable @ D00 T01 §{act_n}", "exchange=not-applicable (nothing is imported or exported)",
           f"reverse=applicable @ D00 T01 §{reverse_n}" if reverse_n else f"reverse=not-applicable ({p['no_reverse']})"]
    head = f"""---
schema_version: 1
id: {s["slug"]}
domain: 00-{s["slug"]}
status: active
title: "TODO-01 -- {name}"
{"frozen: true" + chr(10) if frozen else ""}---

# TODO-01 -- {name}

> **Goal:** {p["goal"]}

> **Current state:** Measured 2026-11-15. {p["current_state"]}

## Inputs

{chr(10).join("- " + i for i in p["inputs"])}
- `DESIGN.md`: the tool's identity and its window's sections, and `sdk/DESIGN.md`, the suite's contract every surface answers to.
- `docs/origin/`: this tool's plan sections as they stood in the Resolute repository at the move, with the reasoning behind them.

## Outcome

{chr(10).join("- " + o for o in p["outcome"])}

**Adjacency:** {"; ".join(adj)}

**Adjacency rationale:** {p["adjacency_rationale"]}

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| ----- | ------- | ----------- | ---------- | ------ |
{chr(10).join(order)}

"""
    tail = f"""## Verification

{chr(10).join("- " + v for v in p["verification"])}
- `python scripts/todo-graph.py validate` and `python scripts/todo-graph.py plan --check` pass.
"""
    return head + "\n".join(b for _, _, b in secs) + tail, [t for t, _, _ in secs]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("spec", type=Path)
    ap.add_argument("--bin", type=Path, default=Path(r"D:\Resolute_Bin"))
    ap.add_argument("--replace", action="append", default=[], help="a file to rewrite even though the app has it")
    args = ap.parse_args()
    s = json.loads(args.spec.read_text(encoding="utf-8"))
    app = args.bin / s["name"]
    if not (app / "sdk.json").is_file():
        print(f"finish-app: {app} is not a split app folder (no sdk.json): run new-app.ps1 first")
        return 1
    plan, titles = plan_md(s)
    slug = s["slug"]
    scope = s["plan"]["scope"]
    phases = {"0": "Repository and build", "1": "Baseline and inventory", "2": "The engine and parity", "3": "The window",
              "4": "The tool's own features", "5": "Distribution", "99": "Manual, operator only"}
    old_plan = json.loads((app / "todo" / "plan.json").read_text(encoding="utf-8"))
    plan_json = {"title": f"{s['display']} implementation plan", "acceptance": old_plan.get("acceptance"), "phases": phases,
                 "needs": ["windows-host", "display-session", "attended", "owner-decision", WAIT], "waiting": ["owner-decision", WAIT]}
    files = {
        "brand/build.py": build_py(s), "DESIGN.md": design_md(s), "README.md": readme_md(s),
        f"todo/00-{slug}/TODO-01-{slug}.md": plan,
        f"todo/00-{slug}/INDEX.md": f"# 00-{slug} -- Domain Index\n\n| File | Scope | Status |\n| ---- | ----- | ------ |\n| TODO-01-{slug}.md | {scope} | active |\n\n## Completed\n",
        "todo/TODO-00-INDEX.md": ("# TODO-00 -- Root Index\n\nGoverning documents: [AGENTS.md](../AGENTS.md) for what this repository is, [DESIGN.md](../DESIGN.md) for the tool's identity and window. "
                                  "Generated plan: [implementation-plan.md](./implementation-plan.md).\n\n## Active TODOs\n\n| Domain | File | Scope |\n| ------ | ---- | ----- |\n"
                                  f"| 00 | 00-{slug}/TODO-01-{slug}.md | {scope} |\n\n## Completed TODOs\n"),
        "todo/plan.json": json.dumps(plan_json, indent=2) + "\n",
    }
    if s.get("au3"):
        files["reference/au3/README.md"] = reference_md(s, app / "reference" / "au3")
    always = {"todo/plan.json", "todo/TODO-00-INDEX.md"}
    for rel, text in files.items():
        path = app / rel
        if path.exists() and rel not in always and rel not in args.replace:
            print(f"finish-app: kept {rel} (already there)")
            continue
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8", newline="\n")
        print(f"finish-app: wrote {rel}")
    agents = app / "AGENTS.md"
    text = agents.read_text(encoding="utf-8")
    if "## This project" not in text:
        marker = "## Working rules\n"
        if marker not in text:
            print("finish-app: AGENTS.md has no '## Working rules' heading to place the project section before")
            return 1
        agents.write_text(text.replace(marker, agents_section(s) + marker, 1), encoding="utf-8", newline="\n")
        print("finish-app: added the project section to AGENTS.md")
    print(f"finish-app: {len(titles)} plan section(s): " + "; ".join(titles))
    return 0


if __name__ == "__main__":
    sys.exit(main())
