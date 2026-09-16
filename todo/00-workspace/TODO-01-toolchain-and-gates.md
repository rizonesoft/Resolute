---
schema_version: 1
id: cpp-toolchain-and-gates
domain: 00-workspace
status: draft
title: "TODO-01 -- C++ Toolchain and Gates"
depends_on: []
track: W1
---

# TODO-01 -- C++ Toolchain and Gates

> **Goal:** A clean checkout builds any tool with one command, on a machine whose toolchain versions are pinned rather than remembered. Every gate the project owes runs from one entry point, so a change is either provably clean or provably not.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** A working toolchain bootstrap and CMake structure arrive with `D00 T03`, from the ExoSuite codebase: llvm-mingw 20251216 ucrt-x86_64, CMake 4.2.3, Ninja 1.13.1, C++23, presets driving Ninja with LTO on release, and full static linking producing a 1.39 MB executable. There is **no vcpkg**, and after `D00 T03 §1` retires `Console` and the `libvterm` submodule with it, **no external dependency at all** beyond the toolchain and Catch2. What does not exist anywhere is hash verification on the bootstrap, a locator that fails by name, a warning level applied across targets, `clang-tidy`, a one-command build, or a combined gate. The AutoIt suite under `resolute_au3/` separately does not build from a clean checkout, because thirteen `.sni` descriptors point at `R:\Workspace\Resolute`, a directory that no longer exists; `D09 T01 §1` owns that.

## Inputs

- [`samples/ExoSuite/exokit/Bootstrap-ExoKit.ps1`](../../samples/ExoSuite/exokit/Bootstrap-ExoKit.ps1) -- the working bootstrap this file hardens
- [`samples/ExoSuite/CMakePresets.json`](../../samples/ExoSuite/CMakePresets.json) -- the preset structure this file adopts
- [`docs/brainstorm/2026-09-16-completion-brainstorm.md`](../../docs/brainstorm/2026-09-16-completion-brainstorm.md) -- the toolchain decision and its rationale
- -> XREF: [`00-workspace/TODO-02 §1`](./TODO-02-test-backbone.md) -- the Catch2 harness this file's build must produce
- -> XREF: [`00-workspace/TODO-03 §3`](./TODO-03-codebase-intake.md) -- the intake that moves the toolchain bootstrap to the repository root before this file hardens it
- -> XREF: [`01-framework/TODO-01 §1`](../01-framework/TODO-01-framework-core.md) -- the first real consumer of the build
- -> XREF: [`07-quality/TODO-01 §2`](../07-quality/TODO-01-quality-bar.md) -- the warning ratchet that builds on §3
- -> XREF: [`00-workspace/TODO-04 §1`](./TODO-04-self-correction.md) -- the claim and staleness checks that join §5's combined gate

## Outcome

- A pinned toolchain that reports its own versions and fails by name when one is missing.
- One command builds any tool, or every tool, for both architectures, from a clean checkout.
- Warnings are errors, and the level is the same for every target.
- `clang-tidy` runs over the tree and its findings are counted, so the ratchet has a number to start from.
- One command runs every gate, and it is the command a push owes.

**Adjacency:** list=not-applicable (a build system holds no records a user browses); document=not-applicable (nothing here produces a document a user carries); settings=applicable @ D00 T01 §2; reporting=applicable @ D00 T01 §5; notifications=not-applicable (a local gate notifies nobody); permissions=not-applicable (single-user desktop toolchain, no roles); audit=not-applicable (git history is the audit for a build script); exchange=not-applicable (nothing imports or exports here); reverse=not-applicable (a build produces artifacts under `build/`, and deleting that directory is the whole reverse)

**Adjacency rationale:** Settings anchors on §2 because the CMake preset set and the dependency policy are this domain's configuration surface, and they are the thing a second developer has to reproduce exactly. Reporting anchors on §5 because the combined gate is what a human reads to decide whether a change is shippable, and a gate that reports nothing legible is a gate people stop running.

## Implementation Order

| Order | Section | Deliverable                                  | Depends On | Status |
| :---: | :-----: | -------------------------------------------- | ---------- | :----: |
|   1   |   §1    | Harden the toolchain bootstrap               | D00 T03 §3 |  [ ]   |
|   2   |   §2    | CMake structure and dependencies             | §1         |  [ ]   |
|   3   |   §3    | Warnings as errors at one level              | §2         |  [ ]   |
|   4   |   §4    | One command builds any tool                  | §2         |  [ ]   |
|   5   |   §5    | One command runs every gate                  | §3, §4     |  [ ]   |

---

## 1. Harden the Toolchain Bootstrap

The toolchain is repository-scoped: a bare Windows machine with no Visual Studio installed runs one script and can build. **That already works.** `D00 T03 §3` moves ExoKit's bootstrap to the repository root; this section hardens it to the standard the rest of the plan needs.

What it pulls today is llvm-mingw 20251216 ucrt-x86_64, CMake 4.2.3, and Ninja 1.13.1. llvm-mingw matters because it is a **self-contained UCRT-targeting archive carrying its own headers and import libraries**, so there is no Windows SDK to acquire and no licence question to answer. That was the single largest risk in this domain and the existing bootstrap removes it.

What it lacks is hash verification, detect-before-download, a locator that fails by name, and any proof that it works on a machine other than the one it was written on.

**Needs:** Windows host (build/test)


**Build order.** The existing `reskit/Bootstrap-ExoKit.ps1` already works; this hardens it. Change one thing at a time and re-run the bootstrap after each.

1. **Write `toolchain.json` first**, recording exactly what the existing script pulls today: llvm-mingw `20251216`, CMake `4.2.3`, Ninja `1.13.1`, each with its URL. Done when: the file's versions match the script's variables exactly, compared line by line.
2. **Add the SHA-256 for each**, taken from a real download. Done when: every entry has a hash and re-running the bootstrap verifies all three.
3. **Add detect-before-download**, checking the toolchain directory first. Done when: a second bootstrap run downloads nothing and finishes in seconds, timed and quoted.
4. **Add the fail-by-name locator** as `scripts/cpp-env.ps1`. Done when: deleting one component makes it exit 1 naming that component and the command that restores it.
5. **Set the Windows floor** in CMake only, not in the bootstrap. Done when: `WINVER` and `_WIN32_WINNT` are set once and every target inherits them.
6. **Prove the bare-machine claim last**, because it is the only stage needing a second machine. Done when: bootstrap and build both succeed where no Visual Studio and no Windows SDK are installed.

- [ ] Record the pins in `toolchain.json` at the repository root: the llvm-mingw release, CMake, and Ninja, each with a download URL and a SHA-256. Done when: every value is an exact version and every entry carries a hash, and the versions match what the ExoKit bootstrap pulls today. Cheaper substitute: naming versions without hashes, which makes the bootstrap reproducible only until a URL is re-cut.
- [ ] `scripts/bootstrap.ps1` **detects before it downloads**, in a fixed order: `.toolchain/` first, then the machine's installed components. Done when: a second run downloads nothing and finishes in seconds, and the detection order is documented so a repository-scoped component always wins over a machine-installed one of the same version.
- [ ] Detect the **pinned version specifically**, not merely presence. Done when: a directory carrying a different llvm-mingw release than the pin does not silently satisfy the check. Cheaper substitute that defeats the point of pinning: accepting any toolchain that is present, which makes two machines disagree while both report success.
- [ ] Decide and record what happens when only a non-pinned version is present: replace it with the pin, or report and stop for the operator to choose. Done when: the behavior is a dated default with its cost of changing, and the message names both the found version and the wanted one.
- [ ] Download each missing component into `.toolchain/`, verify its hash, and refuse to proceed on a mismatch. Done when: a deliberately corrupted hash aborts the bootstrap with a named message and leaves `.toolchain/` unchanged.
- [ ] Confirm the self-contained claim rather than assuming it. Done when: a machine with no Visual Studio and no Windows SDK compiles and links a program calling `CreateFileW` and a Direct2D entry point, using only the bootstrapped toolchain.
- [ ] Record the MinGW-w64 tradeoff plainly. Done when: this section states that the toolchain targets the MinGW-w64 environment rather than the MSVC ABI, so MSVC-built static libraries cannot be linked and debugging is LLDB, with the cost of changing that decision.
- [ ] Record what the extra llvm-mingw targets are worth. Done when: the `aarch64`, `arm64ec`, `armv7`, and `i686` targets are named and this section states whether ARM64 Windows is in scope, as a dated default.
- [ ] Set the runtime floor to Windows 10 1809 through `WINVER`, `_WIN32_WINNT`, and the application manifest, in one place in CMake. Done when: the floor macros are set once and inherited by every target. The Windows SDK pin is not needed here: llvm-mingw supplies its own headers, which is why decision 21's separate-pin problem does not arise under this toolchain.
- [ ] Add a floor check so an above-floor API cannot ship silently. Done when: a deliberate call to an API newer than the floor fails the build or is flagged by `clang-tidy`, and the diagnostic is quoted. Record which mechanism was used.
- [ ] Record why the floor is Windows 10 1809 rather than the Vista-through-Win10 range the AutoIt manifests declare. Done when: this section names dark mode, per-monitor DPI v2, and Direct2D SVG rendering as the features that set it, with the cost of lowering it.
- [ ] Ensure the bootstrapped toolchain directory is gitignored. Done when: a full bootstrap leaves `git status` clean.
- [ ] `scripts/cpp-env.ps1` reports every resolved component and its version, and fails by name. Done when: it prints all six on a bootstrapped machine, and deleting one component makes it exit 1 naming that component and the bootstrap command that restores it.
- [ ] Prove the bare-machine claim. Done when: bootstrap and build succeed on a Windows machine with no Visual Studio installed, and this section records where that was proven and on what Windows build.
- [ ] Commit: `"workspace: repository-scoped clang-cl toolchain bootstrap"`

**Test checkpoint:** `pwsh scripts/bootstrap.ps1` populates the toolchain directory from the pins and leaves `git status` clean. A second run downloads nothing and finishes in seconds, quoted. A non-pinned llvm-mingw release is reported rather than accepted, naming found and wanted. A corrupted hash aborts with a named message. `pwsh scripts/cpp-env.ps1` prints three resolved versions; deleting one component makes it exit 1 naming it. Bootstrap and build both succeed on a machine with no Visual Studio and no Windows SDK, compiling a Direct2D entry point, and that machine's Windows build is quoted.

## 2. CMake Structure and Dependencies

The intake brings a working CMake structure: C++23, presets driving Ninja, LTO on release, and full static linking. This section makes it the repository's structure rather than one application's, and settles how dependencies arrive now that there is no vcpkg and no wxWidgets.

**Needs:** C++ toolchain (compile)

- [ ] Make the presets resolve their compiler and generator from the bootstrapped toolchain rather than from `PATH`. Done when: configuring with a different `clang` earlier on `PATH` still selects the bootstrapped one, proven by the configure output.
- [ ] Generate no Visual Studio solution and commit none. Done when: the repository contains no `.sln` or `.vcxproj`, and the presets drive VS, VS Code, and a bare terminal identically.
- [ ] Settle how dependencies arrive. **Corrected 2026-09-17 after independent review:** the tree does **not** have none. `shared/lucide/CMakeLists.txt:9` fetches `sammycage/lunasvg` v3.5.0 through `FetchContent` at configure time and links it into Lucide, so a fresh configure reaches GitHub. Retiring the `libvterm` submodule removed the `--recursive` requirement, not the dependency. Done when: the decision is dated, covers **lunasvg and Catch2** as the third-party code, states whether lunasvg is pinned by tag or by hash, and gives the rule for adding a dependency later. Cheaper substitute: adding a package manager for two dependencies.
<!-- claim: count "lunasvg" shared/lucide/CMakeLists.txt = 6 -->
<!-- claim: absent .gitmodules -->
- [ ] Keep static linking explicit and enforced. Done when: `-static -static-libgcc -static-libstdc++` is set once for every target, and a build producing a runtime DLL dependency fails, proven by checking the built executable's imports.
- [ ] **Replace the runtime icon loader, which is what actually breaks standalone.** Corrected 2026-09-17 after independent review: an earlier draft of this item blamed the `SHARED` library targets, which was wrong. `src/CMakeLists.txt:10` links `ExoUI_static`, so ExoUI is already static. The real dependency is explicit: `LucideIcons::Load()` at `shared/exo-ui/src/icons.cpp:15` calls `LoadLibraryW(L"System\Lucide.dll")` and resolves entry points with `GetProcAddress`. Done when: icons render with **no DLL present beside the executable**, proven by deleting `System/` and running. Cheaper substitute that fails the checkpoint: checking the executable's import table, which cannot see a runtime `LoadLibrary` and would pass a tool that still needs a DLL.
<!-- claim: count "LoadLibraryW" shared/exo-ui/src/icons.cpp = 2 -->
<!-- claim: count "ExoUI_static" src/CMakeLists.txt = 1 -->
- [ ] Record what the release preset ships today, so the change has a before. Measured 2026-09-17: `Bin/Release/ExoSuite.exe` at 1,380,352 bytes plus `System/ExoUI.dll` and `System/Lucide.dll`, 3.9 MB in total. `shared/exo-ui/CMakeLists.txt:33` and `shared/lucide/CMakeLists.txt:58` still build `SHARED` targets even though the application does not link ExoUI's. Done when: the unused shared target is either removed or its purpose recorded.
- [ ] Put all build output under `build/`, which is already gitignored, with nothing written inside `src/`. Done when: a full configure and build leaves `git status` clean.
- [ ] Prove the structure builds the real application, not a placeholder. Done when: `Resolute.exe` builds from a clean checkout after bootstrap, cloned **without** `--recursive`.
- [ ] Record the binary size as the baseline the per-tool size budget is measured against. Done when: the size is in this section, dated, against the 1.39 MB the pre-intake build produced.
- [ ] Commit: `"workspace: repository cmake structure and dependency policy"`

**Test checkpoint:** `cmake --preset release && cmake --build --preset release` succeeds on a clean checkout after bootstrap and produces `Resolute.exe`. The executable's imports are listed and carry no compiler runtime DLL. `git status` is clean afterwards. The binary size is quoted against the 1.39 MB baseline.

## 3. Warnings as Errors at One Level

A warning level that varies per target is a warning level nobody trusts. The AutoIt tree carried 45 to 68 warnings per tool for years because the gate was optional; this is the section that stops that from recurring.

**Needs:** C++ toolchain (compile)

- [ ] Set the project warning level once, in one place, applied to every target the project owns. Done when: a new target added with no extra configuration inherits it, proven by adding a throwaway target with a deliberate warning and watching it fail.
- [ ] Enable warnings as errors for project targets and **disable** them for vcpkg dependencies. Done when: a warning in `src/` fails the build and a warning inside wxWidgets does not.
- [ ] Add `clang-tidy` configuration and wire it to the compile database. Done when: `clang-tidy` runs over the placeholder target and reports a count.
- [ ] Record the starting finding count as the ratchet baseline. Done when: the number is in `todo/.tidy-baseline` and named here. Cheaper substitute: leaving the baseline implicit and comparing against zero, which makes the first real run unfixably red.
- [ ] Prove the gate can fail. Done when: a deliberate unused-variable in `src/` fails the build with the expected diagnostic, and reverting it passes.
- [ ] Commit: `"workspace: warnings as errors at one level, with a tidy baseline"`

**Test checkpoint:** A deliberate warning in `src/` fails the build; the same warning inside a vcpkg dependency does not. `clang-tidy` reports a count that matches `todo/.tidy-baseline`. The failing and passing outputs are both quoted.

## 4. One Command Builds Any Tool

The AutoIt suite reached fourteen tools with no way to build them all, which is how thirteen `.sni` descriptors came to point at a directory that no longer exists. One command, exercised from the start, is what keeps that from happening again.

**Needs:** C++ toolchain (compile)

- [ ] `scripts/build.ps1 <Tool>` builds one tool for both architectures. Done when: it builds the placeholder from §2 and exits non-zero with a named message for an unknown tool name.
- [ ] `scripts/build.ps1 -All` builds every tool the project defines. Done when: it builds everything currently defined and its output names each target and its result.
- [ ] Support a release configuration alongside debug. Done when: both configurations build and the script says which it produced.
- [ ] Make the output location predictable and repository-relative. Done when: built executables land in one documented place under `build/` and no absolute path appears in any build file. Cheaper substitute: the absolute-path habit that broke every `.sni` in the AutoIt tree.
- [ ] Prove a clean-checkout build. Done when: a fresh clone into a different directory builds without editing a single file, and this section records the directory it was proven in.
- [ ] Commit: `"workspace: one command builds any tool or all of them"`

**Test checkpoint:** `pwsh scripts/build.ps1 -All` exits 0 and names every target built. A fresh clone into a different absolute path builds with no file edited, and that path is quoted. An unknown tool name exits non-zero with the named message.

## 5. One Command Runs Every Gate

Five gates that must each be remembered are five gates that get skipped under time pressure. This is the command a push owes, and it exists so that "did you run the checks" has a single answer.

**Needs:** C++ toolchain (compile)

- [ ] `scripts/check-all.ps1` runs the build for both architectures, `clang-tidy` against the baseline, the Catch2 suite, and `python scripts/todo-graph.py validate`. Done when: all four run in one invocation and the script exits non-zero if any fails.
- [ ] Report legibly: one line per gate with its result and duration, and the failure detail only for gates that failed. Done when: a run with one deliberate failure shows three passes and one failure with its detail, and the passing detail is not dumped.
- [ ] Make the tidy gate compare against the baseline rather than zero. Done when: a finding count equal to the baseline passes and one above it fails, both observed.
- [ ] Tolerate the harness not existing yet. Done when: with `D00 T02 §1` unshipped, the test gate reports "not present" and does not fail the run, and this behavior is removed by that section.
- [ ] Commit: `"workspace: one command runs every gate"`

**Test checkpoint:** `pwsh scripts/check-all.ps1` exits 0 on a clean tree and prints one line per gate. Introducing one deliberate warning makes it exit non-zero and show only that gate's detail. A tidy count one above the baseline fails. All three runs are quoted in the commit body.

## Verification

- [ ] `pwsh scripts/bootstrap.ps1` populates the toolchain from the pins and leaves `git status` clean
- [ ] `pwsh scripts/cpp-env.ps1` exits 0 and prints every resolved component version
- [ ] `pwsh scripts/build.ps1 -All` builds every defined target for both architectures
- [ ] `pwsh scripts/check-all.ps1` exits 0 on a clean tree
- [ ] A fresh clone into a different absolute path builds with no file edited
- [ ] Bootstrap and build succeed on a machine with no Visual Studio and no Windows SDK installed
- [ ] No absolute path appears in any build file, and no `.sln` or `.vcxproj` is committed
- [ ] `python scripts/todo-graph.py validate` clean
