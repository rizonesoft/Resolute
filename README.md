# Resolute

Rizonesoft's suite of Windows system utilities: a launcher plus a set of repair and optimization tools, each of which also ships on its own.

The suite is being rewritten in C++ from a mature AutoIt3 implementation. Both trees are in this repository: the AutoIt suite under `resolute_au3/` still works and is the specification the port is measured against, and the C++ suite is what replaces it.

## The stack

| Piece | Choice |
| --- | --- |
| Language | C++23 |
| UI | Direct2D and DirectWrite, drawn by the shared `ResoluteUI` library |
| Icons | Lucide, rendered from SVG through lunasvg |
| Compiler | clang 21 from llvm-mingw, targeting the UCRT |
| Build | CMake with Ninja, driven by presets |
| Toolchain | repository-scoped: nothing is installed system-wide, and no Visual Studio is required |

The toolchain is downloaded into `reskit/` by one script. A machine with no Visual Studio and no Windows SDK can build this, because llvm-mingw carries its own headers and import libraries.

## Building

From a clean clone, in PowerShell 7, on Windows x64:

```powershell
pwsh scripts/bootstrap.ps1        # downloads llvm-mingw, CMake and Ninja into reskit/
. .\reskit\Init-ResKit.ps1        # puts them on PATH for this shell
cmake --preset release
cmake --build --preset release
```

The result is `Bin/Release/Resolute.exe`.

`bootstrap.ps1` skips anything already present, so running it a second time costs under a second. Use `-Force` to re-download. The `debug` preset exists alongside `release` and takes the same two commands.

A clone does **not** need `--recursive`: there are no submodules.

## Layout

| Path | What is there |
| --- | --- |
| `src/` | the launcher shell, and nothing else |
| `shared/resolute-ui/` | the Direct2D UI library every tool draws with. Namespace `rui::`, include prefix `resolute/`, export macro `RESUI_API` |
| `shared/lucide/` | the icon set |
| `extensions/` | the tools, each building as its own standalone executable |
| `reskit/` | the downloaded toolchain, plus the environment and build helpers. The binaries are gitignored |
| `scripts/` | the bootstrap, and the TODO tooling |
| `resources/icons/` | application icons, one per product |
| `resolute_au3/` | the AutoIt suite, frozen. The executable specification |
| `todo/` | the execution plan. `todo/README.md` explains the format |
| `docs/` | architecture notes, reviews, and captures |

## Architecture

Three layers, and the rule that keeps them apart is that a tool never reimplements what a layer below it provides.

**The UI library**, `shared/resolute-ui/`, owns every control the suite draws: the sidebar, toolbar, status bar, list and content views, and the popup menu, along with theming, DPI, typography, and animation. It is built both as `ResoluteUI_static` and as `ResoluteUI` (shared). A tool consumes it; a tool that draws its own list view is a defect, not a shortcut.

**The application shell**, `src/`, is the launcher. It discovers tools, presents them, and starts them. It is not a place for tool behaviour.

**The extension model** is that every tool is a standalone executable that describes itself. The launcher scans `System/*.exe` for an embedded `RESEXT` resource and builds its list from what it finds: no configuration file, no registry, no install step. `docs/extensions.md` has the details.

Two shared layers are planned and do not exist yet: `src/framework/`, which will own startup, settings, logging, localization, update, elevation, and About for every tool; and `src/repair/`, which will own the diagnose-report-repair-verify-undo contract the repair tools share. `AGENTS.md` carries the full source layout.

## What is not here yet

Stated plainly, so nobody plans around something that does not exist.

- **No tests.** There is no `tests/` directory and no test framework wired in. `D00 T02` brings Catch2 and the harness.
- **No `src/framework/` or `src/repair/`.** The two shared layers above are designed and not built. `D01 T01` and `D02 T01` own them.
- **No vcpkg, and no package manager.** The only third-party code is lunasvg, fetched at configure time by `shared/lucide/CMakeLists.txt`, and Catch2 once tests land.
- **Not yet a single file.** The `release` preset ships `Resolute.exe` **plus** `System/ResoluteUI.dll` and `System/Lucide.dll`. The executable links the UI library statically, but the icon loader still resolves `Lucide.dll` at runtime with `LoadLibraryW`. `D00 T01 §2` owns making the shipped set one file, and until it does, "statically linked" describes the intent rather than the output.
- **The build is not reproducible.** Two clean builds of identical sources produce different bytes at identical size. `D07 T01` owns deciding whether that should change.

## The tools

`Resolute` (launcher) with `BiosCodes`, `ComIntRep`, `DVDRepair`, `Ownership`, `PixRepair`, `USBRepair`, `Firemin`, `Chromin`, `Edgemin`, `Watermin`, and `MemBoost` in the AutoIt suite, plus `RegStudio` in the C++ tree.

Six of them change a system in ways that are hard to undo: `Ownership`, `ComIntRep`, `USBRepair`, `DVDRepair`, `PixRepair`, and `BiosCodes`. What those compute and write is frozen, and the C++ port reproduces their effect exactly, proven against the AutoIt original on the same fixture.

## Working in this repository

`AGENTS.md` is the contract for anyone, human or agent, changing this tree. `DESIGN.md` is the design contract every user-facing surface answers to. `todo/` is the live plan, and `todo/README.md` explains how to read and extend it.

```powershell
python scripts/todo-graph.py validate   # the plan's structure
python scripts/todo-claims.py           # re-measures what the plan claims about this repo
```

## Licence

**Not yet declared.** There is no `LICENSE` file in this repository, verified 2026-09-17. The AutoIt suite ships under GPL v3 and the C++ codebase arrived from repositories Rizonesoft owns outright, so the suite's licence is a decision rather than an inheritance. `D06 T01 §8` owns making it, and until it does, treat this tree as all rights reserved.
