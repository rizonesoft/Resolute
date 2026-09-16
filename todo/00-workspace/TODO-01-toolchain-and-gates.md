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
> **Current state (verified 2026-09-16):** Nothing in this domain exists. `src/` has not been created. There is no `CMakeLists.txt`, no vcpkg manifest, no compiler pin, and no gate script anywhere in the repository. The AutoIt suite under `resolute_au3/` builds through `SDK/Distro.exe` from `.sni` descriptors whose paths point at `R:\Workspace\Resolute`, a directory that no longer exists, so that tree does not build from a clean checkout either. Every later section in this plan cites a build, a static-analysis run, a unit test, or a parity run, and none of those can happen until this file ships.

## Inputs

- [`resolute_au3/SDK/Concrete/ReBar/ReBar.au3`](../../resolute_au3/SDK/Concrete/ReBar/ReBar.au3) -- the framework being ported; its `#AutoIt3Wrapper_OutFile` directives are already repository-relative and are the model for output paths
- [`docs/brainstorm/2026-09-16-completion-brainstorm.md`](../../docs/brainstorm/2026-09-16-completion-brainstorm.md) -- the toolkit decision and its rationale
- -> XREF: [`00-workspace/TODO-02 §1`](./TODO-02-test-backbone.md) -- the Catch2 harness this file's build must produce
- -> XREF: [`01-framework/TODO-01 §1`](../01-framework/TODO-01-framework-core.md) -- the first real consumer of the build
- -> XREF: [`07-quality/TODO-01 §2`](../07-quality/TODO-01-quality-bar.md) -- the warning ratchet that builds on §3

## Outcome

- A pinned toolchain that reports its own versions and fails by name when one is missing.
- One command builds any tool, or every tool, for both architectures, from a clean checkout.
- Warnings are errors, and the level is the same for every target.
- `clang-tidy` runs over the tree and its findings are counted, so the ratchet has a number to start from.
- One command runs every gate, and it is the command a push owes.

**Adjacency:** list=not-applicable (a build system holds no records a user browses); document=not-applicable (nothing here produces a document a user carries); settings=applicable @ D00 T01 §2; reporting=applicable @ D00 T01 §5; notifications=not-applicable (a local gate notifies nobody); permissions=not-applicable (single-user desktop toolchain, no roles); audit=not-applicable (git history is the audit for a build script); exchange=not-applicable (nothing imports or exports here); reverse=not-applicable (a build produces artifacts under `build/`, and deleting that directory is the whole reverse)

**Adjacency rationale:** Settings anchors on §2 because the vcpkg manifest and the CMake preset set are this domain's configuration surface, and they are the thing a second developer has to reproduce exactly. Reporting anchors on §5 because the combined gate is what a human reads to decide whether a change is shippable, and a gate that reports nothing legible is a gate people stop running.

## Implementation Order

| Order | Section | Deliverable                                  | Depends On | Status |
| :---: | :-----: | -------------------------------------------- | ---------- | :----: |
|   1   |   §1    | Portable toolchain bootstrap                 | --         |  [ ]   |
|   2   |   §2    | CMake skeleton and vcpkg manifest            | §1         |  [ ]   |
|   3   |   §3    | Warnings as errors at one level              | §2         |  [ ]   |
|   4   |   §4    | One command builds any tool                  | §2         |  [ ]   |
|   5   |   §5    | One command runs every gate                  | §3, §4     |  [ ]   |

---

## 1. Portable Toolchain Bootstrap

The toolchain is repository-scoped: a bare Windows machine with no Visual Studio installed runs one script and can build. That is the decision, and this section is where it is either true or quietly false. Nothing is vendored into git; everything is downloaded to a gitignored directory against a recorded hash.

The sharp edge is that `clang-cl` is not a complete toolchain on Windows. It needs the Windows SDK headers and import libraries and a C++ standard library, and neither ships in the LLVM archive. The LLVM archive is freely redistributable; the Windows SDK is not, so it is **downloaded at bootstrap from Microsoft's own package feed** rather than committed. If that acquisition proves unworkable, this section is where the plan finds out, not `D01`.

**Needs:** Windows host (build/test)

- [ ] Record the pins in `toolchain.json` at the repository root: LLVM release, Windows SDK version, CRT version, CMake, Ninja, and the vcpkg baseline commit, each with a download URL and a SHA-256. Done when: every value is an exact version and every entry carries a hash. Cheaper substitute: naming versions without hashes, which makes the bootstrap reproducible only until a URL is re-cut.
- [ ] `scripts/bootstrap.ps1` **detects before it downloads**, in a fixed order: `.toolchain/` first, then the machine's installed components. Done when: a second run downloads nothing and finishes in seconds, and the detection order is documented so a repository-scoped component always wins over a machine-installed one of the same version.
- [ ] Detect the **pinned version specifically**, not merely presence. Done when: a machine carrying a different Windows SDK version than the pin does not silently satisfy the check. Cheaper substitute that defeats the point of pinning: accepting any installed SDK, which makes two machines disagree while both report success.
- [ ] Decide and record what happens when only a non-pinned version is present: download the pin alongside it, or report and stop for the operator to choose. Done when: the behavior is a dated default with its cost of changing, and the message names both the found version and the wanted one.
- [ ] Locate a machine-installed Windows SDK properly rather than by guessing a path. Done when: the lookup reads `HKLM\SOFTWARE\Microsoft\Windows Kits\Installed Roots` and the resolved root and version are printed.
- [ ] Download each missing component into `.toolchain/`, verify its hash, and refuse to proceed on a mismatch. Done when: a deliberately corrupted hash aborts the bootstrap with a named message and leaves `.toolchain/` unchanged.
- [ ] Acquire the Windows SDK and CRT headers and libraries into `.toolchain/` without a Visual Studio install, and record which mechanism was used and under which licence terms. Done when: a machine with no Visual Studio compiles and links a program calling `CreateFileW`, and the mechanism and licence are named here.
- [ ] Decide and record the C++ standard library: MSVC STL from the acquired CRT, or LLVM's libc++. Done when: the decision is dated, carries its cost of changing, and names which one wxWidgets and Catch2 are built against.
- [ ] Pin the **latest stable** Windows SDK, and set the runtime floor separately to Windows 10 1809 through `WINVER`, `_WIN32_WINNT`, and the application manifest. Done when: `toolchain.json` names the exact current SDK version, the floor macros are set in one place in CMake, and this section states why the two are independent knobs. Cheaper substitute: pinning the SDK to the floor version, which trades away every newer header to solve a problem the floor macros already solve.
- [ ] Add a floor check so an above-floor API cannot ship silently. Done when: a deliberate call to an API newer than the floor fails the build or is flagged by `clang-tidy`, and the diagnostic is quoted. Record which mechanism was used.
- [ ] Record why the floor is Windows 10 1809 rather than the Vista-through-Win10 range the AutoIt manifests declare. Done when: this section names dark mode and per-monitor DPI v2 as the two features that set it, with the cost of lowering it.
- [ ] Add `.toolchain/` to `.gitignore`. Done when: a full bootstrap leaves `git status` clean.
- [ ] `scripts/cpp-env.ps1` reports every resolved component and its version, and fails by name. Done when: it prints all six on a bootstrapped machine, and deleting one component makes it exit 1 naming that component and the bootstrap command that restores it.
- [ ] Prove the bare-machine claim. Done when: bootstrap and build succeed on a Windows machine with no Visual Studio installed, and this section records where that was proven and on what Windows build.
- [ ] Commit: `"workspace: repository-scoped clang-cl toolchain bootstrap"`

**Test checkpoint:** `pwsh scripts/bootstrap.ps1` populates `.toolchain/` from the pins and leaves `git status` clean. A second run downloads nothing and finishes in seconds, quoted. On a machine carrying a non-pinned Windows SDK, the run reports both the found and the wanted version rather than accepting it. A corrupted hash aborts with a named message. `pwsh scripts/cpp-env.ps1` prints six resolved versions; deleting one component makes it exit 1 naming that component. Bootstrap and build both succeed on a machine with no Visual Studio, and that machine's Windows build is quoted.

## 2. CMake Skeleton and vcpkg Manifest

The dependency set is small and the temptation to vendor it by hand is real. A manifest is what makes "it builds on my machine" reproducible, and wxWidgets static is a large enough dependency that building it twice by accident is a genuine cost.

**Needs:** C++ toolchain (compile)

- [ ] Create `src/` with a top-level `CMakeLists.txt` targeting C++23, and a `CMakePresets.json` carrying an x86 and an x64 configuration that resolve their compiler, generator, and vcpkg root from `.toolchain/` rather than from `PATH`. Done when: `cmake --preset x64-debug` configures on a clean checkout, and configuring with a different compiler earlier on `PATH` still selects the bootstrapped one.
- [ ] Generate no Visual Studio solution and commit none. Done when: the repository contains no `.sln` or `.vcxproj`, and the presets drive VS, VS Code, and a bare terminal identically.
- [ ] Add `vcpkg.json` declaring `wxwidgets` and `catch2`, with the baseline pinned to the commit recorded in §1, and a custom triplet naming `clang-cl` as the compiler. Done when: a clean checkout with no vcpkg cache resolves and builds both dependencies unattended under `clang-cl`.
- [ ] Pin wxWidgets to static linkage explicitly, so the triplet cannot silently produce a DLL build. Done when: the configured triplet is asserted in CMake and configuration fails with a named message if it is not static.
- [ ] Put all build output under `build/`, which is already gitignored, with nothing written inside `src/`. Done when: a full configure and build leaves `git status` clean.
- [ ] Prove the skeleton compiles and links something real: a placeholder executable that links wxWidgets and opens no window. Done when: it builds for both architectures and runs to exit 0.
- [ ] Record the resulting binary size for the placeholder, as the baseline the per-tool size budget is measured against. Done when: both architecture sizes are in this section, dated.
- [ ] Commit: `"workspace: cmake skeleton and vcpkg manifest with static wxWidgets"`

**Test checkpoint:** `cmake --preset x64-debug && cmake --build --preset x64-debug` succeeds on a clean checkout with no vcpkg cache. The placeholder links statically, proven by `dumpbin /dependents` showing no `wx` DLL. `git status` is clean afterwards. The two baseline binary sizes are quoted.

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

- [ ] `pwsh scripts/bootstrap.ps1` populates `.toolchain/` from the pins and leaves `git status` clean
- [ ] `pwsh scripts/cpp-env.ps1` exits 0 and prints every resolved component version
- [ ] `pwsh scripts/build.ps1 -All` builds every defined target for both architectures
- [ ] `pwsh scripts/check-all.ps1` exits 0 on a clean tree
- [ ] A fresh clone into a different absolute path builds with no file edited
- [ ] Bootstrap and build succeed on a machine with no Visual Studio installed
- [ ] No absolute path appears in any build file, and no `.sln` or `.vcxproj` is committed
- [ ] `python scripts/todo-graph.py validate` clean
