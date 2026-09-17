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

- [`scripts/bootstrap.ps1`](../../scripts/bootstrap.ps1) -- the working bootstrap this file hardens. **Moved there by `D00 T03 §3`**. **Repointed 2026-09-17 by `D00 T03 §2`:** it read `samples/ExoSuite/...`, which the intake made redundant and the operator then deleted, so the link would have died
- [`CMakePresets.json`](../../CMakePresets.json) -- the preset structure this file adopts. **Repointed 2026-09-17 by `D00 T03 §2`**, same reason
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
|   6   |   §6    | Keep the toolchain current                   | §1, §5     |  [ ]   |
|   7   |   §7    | The bare-machine proof                       | §1         |  [ ]   |

---

## 1. Harden the Toolchain Bootstrap

> **Started:** 2026-09-16T23:55:44Z

The toolchain is repository-scoped: a bare Windows machine with no Visual Studio installed runs one script and can build. **That already works.** `D00 T03 §3` moved the bootstrap to the repository root; this section hardens it to the standard the rest of the plan needs.

> [!IMPORTANT]
> **Validated 2026-09-17 before implementation. Five corrections, and one of them is a scope decision worth seeing.**
>
> **The bare-machine proof is moved to `§7`, not weakened.** Its own Build order calls it "the only stage needing a second machine", and this development machine has Visual Studio and the Windows Kits installed, checked directly. Windows Sandbox, which would have served as a clean machine, is not installed and enabling it needs elevation and a reboot, which is an operator action. So the item cannot be satisfied here by any honest means. Leaving it inside this section would hold thirteen items that need nothing, and with them the 27 open sections that depend on this one, against hardware nobody has today. It becomes `§7` with its own `**Needs:**` line and a checkpoint at least as strict.
>
> **What *can* be proven here, and is, is narrower and still worth having:** that a compile and link consults nothing outside `reskit/`. That is the actual self-contained claim. It is not the same as proving a machine without Visual Studio works, because absence cannot be simulated on a machine that has it, and `§7` says so.
>
> **The floor macros are already set, and not to what this section says.** `CMakeLists.txt:23-24` sets `WINVER=0x0A00` and `_WIN32_WINNT=0x0A00`, which is Windows 10 generically. **1809 is nowhere expressed**: that needs `NTDDI_VERSION=0x0A000006`, which is absent. And `Resolute.exe` ships **no application manifest at all**, so the third leg of the floor does not exist; only `extensions/RegStudio` has one.
>
> **`cpp-env.ps1` "prints all six" is wrong.** Three components are pinned, and the checkpoint in this same section says three. Corrected to three.
>
> **The commit message contradicts the toolchain.** It says `clang-cl`, which is the MSVC-ABI driver. This toolchain is llvm-mingw targeting MinGW-w64, which another item in this very section requires be recorded as a tradeoff. Corrected.

What it pulls today is llvm-mingw 20251216 ucrt-x86_64, CMake 4.2.3, and Ninja 1.13.1. llvm-mingw matters because it is a **self-contained UCRT-targeting archive carrying its own headers and import libraries**, so there is no Windows SDK to acquire and no licence question to answer. That was the single largest risk in this domain and the existing bootstrap removes it.

What it lacks is hash verification, detect-before-download, a locator that fails by name, and any proof that it works on a machine other than the one it was written on.

**Needs:** Windows host (build/test)


**Build order.** The existing `scripts/bootstrap.ps1` already works; this hardens it. Change one thing at a time and re-run the bootstrap after each.

1. **Write `toolchain.json` first**, recording exactly what the existing script pulls today: llvm-mingw `20251216`, CMake `4.2.3`, Ninja `1.13.1`, each with its URL. Done when: the file's versions match the script's variables exactly, compared line by line.
2. **Add the SHA-256 for each**, taken from a real download. Done when: every entry has a hash and re-running the bootstrap verifies all three.
3. **Add detect-before-download**, checking the toolchain directory first. Done when: a second bootstrap run downloads nothing and finishes in seconds, timed and quoted.
4. **Add the fail-by-name locator** as `scripts/cpp-env.ps1`. Done when: deleting one component makes it exit 1 naming that component and the command that restores it.
5. **Set the Windows floor** in CMake only, not in the bootstrap. Done when: `WINVER` and `_WIN32_WINNT` are set once and every target inherits them.
6. **Prove that nothing outside `reskit/` is consulted.** Done when: a compile and link of a program using `CreateFileW` and a Direct2D entry point shows no include or library path outside `reskit/`. The stronger claim, that a machine without Visual Studio works, moved to `§7`: it needs hardware this one is not.

- [x] Record the pins in `toolchain.json` at the repository root: the llvm-mingw release, CMake, and Ninja, each with a download URL and a SHA-256. Done when: every value is an exact version and every entry carries a hash, and the versions match what the ExoKit bootstrap pulls today. Cheaper substitute: naming versions without hashes, which makes the bootstrap reproducible only until a URL is re-cut.
- [x] `scripts/bootstrap.ps1` **detects before it downloads**, in a fixed order: `reskit/` first, then the machine's installed components. **Corrected 2026-09-17 by `D00 T03 §3`:** this said `.toolchain/`, while the Build order below said `reskit/` and the Inputs said `exokit/`. Three names for one directory in one section. `reskit/` is what `§3` creates and what `.gitignore` already covers. Done when: a second run downloads nothing and finishes in seconds, and the detection order is documented so a repository-scoped component always wins over a machine-installed one of the same version.
- [x] Detect the **pinned version specifically**, not merely presence. Done when: a directory carrying a different llvm-mingw release than the pin does not silently satisfy the check. Cheaper substitute that defeats the point of pinning: accepting any toolchain that is present, which makes two machines disagree while both report success.
- [x] Decide and record what happens when only a non-pinned version is present. **Decided 2026-09-17: report and stop.** `bootstrap.ps1` exits 1 naming the component, what it found, what was wanted, and the `-Replace` flag that overwrites. It does not replace on its own.

  The reason is asymmetric cost. Replacing silently discards a toolchain somebody may have put there deliberately, and the operator finds out when their build changes behaviour. Stopping costs one extra flag. Cost of changing: one branch in `bootstrap.ps1`.

  **A third state turned up that the item did not anticipate**, and it is the one that occurs in practice: a component installed by an *earlier* bootstrap, before this section existed, carries no provenance stamp. Reporting "found 21.1.8, wanted 20251216" there would be actively misleading, because 21.1.8 is the clang version and 20251216 is the llvm-mingw release and the two are not comparable. It now says "an install with no verified-provenance stamp (its llvm-mingw reports 21.1.8)".
- [x] Download each missing component into `reskit/`, verify its hash, and refuse to proceed on a mismatch. **Corrected 2026-09-17 by `D00 T03 §3`**, same reason. Done when: a deliberately corrupted hash aborts the bootstrap with a named message and leaves `reskit/` unchanged.

  **The message was a lie for one window, found by the independent review of `6bb635e`.** Under `-Replace` the old install was deleted *before* the download, so a network failure or a hash mismatch destroyed a working toolchain while the abort still printed "reskit/ is unchanged". The order is now download, verify, extract, and only then replace, which is the atomic-write requirement `AGENTS.md` states. Proven by corrupting a hash during `-Replace`: `ninja.exe` exists before and after.
- [x] Confirm the self-contained claim rather than assuming it. **Narrowed 2026-09-17:** the original wording required a machine with no Visual Studio and no Windows SDK, and this one has both, checked directly. Done when: a program calling `CreateFileW` and a Direct2D entry point compiles and links with the bootstrapped toolchain, **and the compiler's own search paths are dumped and shown to contain nothing outside `reskit/`**. Cheaper substitute that fails the checkpoint: observing that it compiles, which on a machine with the Windows SDK installed proves only that some header was found somewhere.
- [x] Record the MinGW-w64 tradeoff plainly. **Written 2026-09-17.**

  This toolchain is llvm-mingw: clang targeting the **MinGW-w64 environment**, not the MSVC ABI. Four consequences, and none of them is hypothetical:

  1. **An MSVC-built static library cannot be linked.** Anything shipped as a `.lib` built by `cl` is unusable without rebuilding it from source with this compiler. A vendor who ships binaries only is a vendor this suite cannot consume.
  2. **Debugging is LLDB**, not the Visual Studio debugger. Visual Studio can attach to the process, but the DWARF debug info clang emits here is not what its debugger reads best.
  3. **The C++ runtime is libc++ with the UCRT underneath**, so the MSVC C++ ABI does not apply and a C++ interface cannot be shared across the boundary with an MSVC-built module. A C interface can.
  4. **Windows-specific MSVC extensions are not all available**, most visibly the SEH forms that assume the MSVC personality.

  What is bought for that: a self-contained archive with its own headers and import libraries, so a machine needs no Visual Studio and no Windows SDK, and there is no licence question about redistributing an SDK.

  **Cost of changing:** moving to clang-cl or MSVC means acquiring and pinning a Windows SDK separately, which is the problem `AGENTS.md` decision 21 describes and which this toolchain sidesteps. The code itself is portable between them; the acquisition story is not.
- [x] Record what the extra llvm-mingw targets are worth. **Measured and decided 2026-09-17.** The archive carries four target trees beside `x86_64-w64-mingw32`: `aarch64-w64-mingw32`, `arm64ec-w64-mingw32`, `armv7-w64-mingw32`, and `i686-w64-mingw32`. They are present at no extra cost, since they ship in the same archive already pinned.

  **Dated default: ARM64 Windows is out of scope, and x86-64 is the only architecture built.** Not because it is hard, but because nothing yet proves the rest: every tool in this suite is a Windows system utility whose behaviour is verified by driven runs against a real machine, and there is no ARM64 machine here to drive one on. Shipping an untested ARM64 binary of a tool that takes ownership of files or repairs a drive is worse than shipping none.

  **Cost of changing:** low and falling. The toolchain already has the target, so it is a preset and a CI machine rather than a toolchain change. `armv7` and `i686` are noted and not wanted: 32-bit Windows is outside the 1809 floor's practical audience.
- [x] Set the runtime floor to Windows 10 1809 through `WINVER`, `_WIN32_WINNT`, `NTDDI_VERSION`, and the application manifest, in one place in CMake. **Corrected 2026-09-17:** two of these already exist and neither expresses 1809. `CMakeLists.txt:23-24` sets `WINVER=0x0A00` and `_WIN32_WINNT=0x0A00`, which is Windows 10 generically; the release is carried by `NTDDI_VERSION`, which is absent, so **1809 is nowhere stated**. `Resolute.exe` also ships **no application manifest**, so the third leg does not exist at all. Done when: all three macros are set once and inherited, `NTDDI_VERSION` names 1809 specifically, and the executable carries a manifest declaring its supported OS and DPI awareness, read back from the built binary. The Windows SDK pin decision 21 describes is not needed here: llvm-mingw supplies its own headers, so the separate-pin problem does not arise under this toolchain.
- [x] Add a floor check so an above-floor API cannot ship silently. **Mechanism: the mingw-w64 header guards themselves, driven by `NTDDI_VERSION`.** No `clang-tidy` rule was needed. Measured 2026-09-17: 161 headers in this toolchain gate declarations on `NTDDI_VERSION >=` and 187 on `_WIN32_WINNT >=`.

  Proven in both directions, using the macros `CMakeLists.txt` actually sets. `GetCurrentPackageInfo2` is gated at `NTDDI_WIN10_19H1`, one release above the floor:

  ```
  at NTDDI_VERSION=0x0A000006 (1809)   exit 1
    error: use of undeclared identifier 'PackagePathType_Effective'
  at NTDDI_VERSION=0x0A000007 (19H1)   exit 0
  ```

  The second line is the falsifiability check: without it the failure could have been a typo rather than the floor.

  **The guarding is incomplete, and that matters more than the mechanism working.** `GetMachineTypeAttributes` is a Windows 11 API, and this toolchain gates it at `_WIN32_WINNT >= _WIN32_WINNT_WIN10`, which the floor satisfies, so it compiles cleanly at 1809. `_WIN32_WINNT_WIN10` is a single value for every Windows 10 and 11 release; only `NTDDI_VERSION` carries the release, and not every declaration uses it. So this check catches an above-floor API **when the header gates on `NTDDI_VERSION`**, and silently permits one gated only at `_WIN32_WINNT`. It is a real check with a known hole, not a guarantee, and a tool that must run on 1809 still owes a driven run there.
- [x] Record why the floor is Windows 10 1809 rather than the Vista-through-Win10 range the AutoIt manifests declare. **Written 2026-09-17.** Three features set it, and each one is load-bearing rather than cosmetic:

  1. **Dark mode.** The undocumented `uxtheme` entry points the suite uses to darken window chrome appeared in 1809. Below it the title bar and common controls stay light while the Direct2D surface is dark, which looks broken rather than unstyled.
  2. **Per-monitor DPI v2 as this suite uses it.** The awareness mode arrived in 1703, but automatic non-client and dialog scaling settled in 1809. Below it every dialog needs hand-scaling, which is exactly the per-tool duplication `DESIGN.md` exists to prevent.
  3. **Direct2D SVG rendering.** `ID2D1DeviceContext5` and the SVG document API are 1809. Lucide ships SVG, and the alternative is rasterising every icon at every scale factor.

  **Cost of lowering it:** each feature needs a runtime-detected fallback path, and each fallback is a second rendering path nobody drives. The AutoIt suite declares Vista through Windows 10 in its manifests, which was correct for a toolkit drawing standard controls and is not correct for one drawing its own.
- [x] Ensure the bootstrapped toolchain directory is gitignored. Done when: a full bootstrap leaves `git status` clean.
- [x] `scripts/cpp-env.ps1` reports every resolved component and its version, and fails by name.

  **A stale stamp let a foreign binary pass, found by the same review.** If the repository executable disappeared but its `.pinned-version` file remained, resolution fell back to PATH while the check still read the repository stamp, so an unrelated binary was accepted on the strength of an attestation belonging to something else. Fixed by making the capability explicit rather than inferred: `toolchain.json` now carries `reportsOwnVersion`, true for CMake and Ninja whose own answer is authoritative, false for llvm-mingw which reports a clang version and never its release. The stamp is consulted **only** for the repository copy, and only when the component cannot report its own release. Both scripts share the rule so they cannot disagree. Proven by removing `reskit/ninja/ninja.exe` while leaving its stamp: the check now finds the machine's own ninja 1.13.2 on PATH and rejects it.

  **Four paths are driven, not described:** all three resolving; present-but-wrong-version via a real foreign ninja on this machine's PATH; not found anywhere; and a `toolchain.json` that will not parse. **Corrected 2026-09-17:** this said "all six" against **three** pinned components, and the checkpoint in this same section already said three. Done when: it prints all three with their versions on a bootstrapped machine, and deleting one component makes it exit 1 naming that component and the bootstrap command that restores it.
- [x] Commit: `"workspace: harden the repository-scoped toolchain bootstrap"` **Corrected 2026-09-17:** the message said `clang-cl`, which is the MSVC-ABI driver. This toolchain is llvm-mingw targeting MinGW-w64, a tradeoff another item in this section requires be recorded.

**Test checkpoint:** `pwsh scripts/bootstrap.ps1` populates the toolchain directory from the pins and leaves `git status` clean. A second run downloads nothing and finishes in seconds, quoted. A non-pinned llvm-mingw release is reported rather than accepted, naming found and wanted, driven by planting a wrong version. A corrupted hash aborts with a named message and leaves `reskit/` unchanged, driven. `pwsh scripts/cpp-env.ps1` prints three resolved versions; deleting one component makes it exit 1 naming that component and the command that restores it, driven. A program calling `CreateFileW` and a Direct2D entry point compiles and links, and the compiler's dumped search paths contain no directory outside `reskit/`. `NTDDI_VERSION` names 1809 and the built `Resolute.exe` carries a manifest, read back from the binary. The bare-machine claim is **not** proven here and is `§7`'s: this machine has Visual Studio and the Windows Kits installed, checked directly.

## 2. CMake Structure and Dependencies

The intake brings a working CMake structure: C++23, presets driving Ninja, LTO on release, and full static linking. This section makes it the repository's structure rather than one application's, and settles how dependencies arrive now that there is no vcpkg and no wxWidgets.

**Needs:** C++ toolchain (compile)

- [ ] Make the presets resolve their compiler and generator from the bootstrapped toolchain rather than from `PATH`. Done when: configuring with a different `clang` earlier on `PATH` still selects the bootstrapped one, proven by the configure output.
- [ ] **Cut the build's dependency on the gitignored `samples/` tree.** Filed 2026-09-17 by the review of `D00 T03 §1`. `build/release/CMakeCache.txt` resolved `CMAKE_CXX_COMPILER`, `CMAKE_MAKE_PROGRAM`, and `CMAKE_COMMAND` into `samples/ExoSuite/exokit/`, while the merged tree's own `exokit/` held only scripts. `D00 T03 §1` states the local checkouts are working copies that may stay on disk, and that is false while the compiler is resolved through one of them: deleting `samples/` breaks the build. Done when: a configure from a tree with `samples/` absent succeeds, proven by moving it aside and configuring, and no cache path in `build/` contains the string `samples`. **Half proven 2026-09-17 before the operator deleted `samples/`:** the directory was renamed aside, `build/release` deleted, and a clean configure and 52/52 build ran with it absent. What that does **not** prove, and what this item still owes, is preference: the toolchain was found because `Init-ExoKit.ps1` puts it on `PATH` first, not because a preset pins it, so a stray `clang` earlier on `PATH` could still win. Cheaper substitute that fails the checkpoint: deleting `build/` and reconfiguring on a machine where `samples/` still exists, which proves nothing because the bootstrap would find it again.
- [ ] Generate no Visual Studio solution and commit none. Done when: the repository contains no `.sln` or `.vcxproj`, and the presets drive VS, VS Code, and a bare terminal identically.
- [ ] Settle how dependencies arrive. **Corrected 2026-09-17 after independent review:** the tree does **not** have none. `shared/lucide/CMakeLists.txt:9` fetches `sammycage/lunasvg` v3.5.0 through `FetchContent` at configure time and links it into Lucide, so a fresh configure reaches GitHub. Retiring the `libvterm` submodule removed the `--recursive` requirement, not the dependency. Done when: the decision is dated, covers **lunasvg and Catch2** as the third-party code, states whether lunasvg is pinned by tag or by hash, and gives the rule for adding a dependency later. Cheaper substitute: adding a package manager for two dependencies.
<!-- claim: count "lunasvg" shared/lucide/CMakeLists.txt = 6 -->
<!-- claim: absent .gitmodules -->
- [ ] Keep static linking explicit and enforced. Done when: `-static -static-libgcc -static-libstdc++` is set once for every target, and a build producing a runtime DLL dependency fails, proven by checking the built executable's imports.
- [ ] **Replace the runtime icon loader, which is what actually breaks standalone.** Corrected 2026-09-17 after independent review: an earlier draft of this item blamed the `SHARED` library targets, which was wrong. `src/CMakeLists.txt` links `ResoluteUI_static`, so the UI library is already static. The real dependency is explicit: `LucideIcons::Load()` at `shared/resolute-ui/src/icons.cpp:15` calls `LoadLibraryW(L"System\Lucide.dll")` and resolves entry points with `GetProcAddress`. Done when: icons render with **no DLL present beside the executable**, proven by deleting `System/` and running. Cheaper substitute that fails the checkpoint: checking the executable's import table, which cannot see a runtime `LoadLibrary` and would pass a tool that still needs a DLL.
<!-- claim: count "LoadLibraryW" shared/resolute-ui/src/icons.cpp = 2 -->
<!-- claim: count "ResoluteUI_static" src/CMakeLists.txt = 1 -->
- [ ] Record what the release preset ships today, so the change has a before. Measured 2026-09-17: `Bin/Release/Resolute.exe` at **1,381,376** bytes plus `System/ExoUI.dll` and `System/Lucide.dll`, 4,074,176 bytes in total. **Corrected 2026-09-17 by `D00 T03 §2`:** this read `ExoSuite.exe` at 1,380,352 bytes. The rename added 1,024 bytes, which is the version-resource block that executable had never carried. `shared/resolute-ui/CMakeLists.txt:33` and `shared/lucide/CMakeLists.txt:58` still build `SHARED` targets even though the application does not link ExoUI's. Done when: the unused shared target is either removed or its purpose recorded.
- [ ] Put all build output under `build/`, which is already gitignored, with nothing written inside `src/`. Done when: a full configure and build leaves `git status` clean.
- [ ] Prove the structure builds the real application, not a placeholder. Done when: `Resolute.exe` builds from a clean checkout after bootstrap, cloned **without** `--recursive`.
- [ ] Record the binary size as the baseline the per-tool size budget is measured against. Done when: the size is in this section, dated, against the 1.39 MB the pre-intake build produced.
- [ ] Commit: `"workspace: repository cmake structure and dependency policy"`

**Test checkpoint:** `cmake --preset release && cmake --build --preset release` succeeds on a clean checkout after bootstrap and produces `Resolute.exe`. The executable's imports are listed and carry no compiler runtime DLL. **Separately, the executable is run with `System/` deleted and its icons still render**, because the import table cannot see the `LoadLibraryW` in `shared/exo-ui/src/icons.cpp:15` and an import-only check would pass a tool that still needs a DLL. No path in `build/` names `samples`, and a configure succeeds with `samples/` moved aside. `git status` is clean afterwards. The binary size is quoted against the 1.39 MB baseline.

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

- [ ] Surface the self-correction checks in the combined gate. **Registered 2026-09-17 by `D00 T04 §1`, which owns the checks but not this script:** `scripts/todo-claims.py` exits non-zero on a **stale claim** and on a **fallen coverage floor**, and both must fail the combined gate rather than print and be ignored. Done when: both conditions are exercised against a deliberately broken fixture and both fail `check-all.ps1` by name.
- [ ] `scripts/check-all.ps1` runs the build for both architectures, `clang-tidy` against the baseline, the Catch2 suite, and `python scripts/todo-graph.py validate`. Done when: all four run in one invocation and the script exits non-zero if any fails.
- [ ] Report legibly: one line per gate with its result and duration, and the failure detail only for gates that failed. Done when: a run with one deliberate failure shows three passes and one failure with its detail, and the passing detail is not dumped.
- [ ] Make the tidy gate compare against the baseline rather than zero. Done when: a finding count equal to the baseline passes and one above it fails, both observed.
- [ ] Tolerate the harness not existing yet. Done when: with `D00 T02 §1` unshipped, the test gate reports "not present" and does not fail the run, and this behavior is removed by that section.
- [ ] Commit: `"workspace: one command runs every gate"`

**Test checkpoint:** `pwsh scripts/check-all.ps1` exits 0 on a clean tree and prints one line per gate. Introducing one deliberate warning makes it exit non-zero and show only that gate's detail. A tidy count one above the baseline fails. All three runs are quoted in the commit body.

## 6. Keep the Toolchain Current

`§1` pins the toolchain so two machines agree. A pin with no expiry is how a project quietly ships a two-year-old compiler: the bootstrap keeps working, so nothing ever says the pin is old.

> [!IMPORTANT]
> **Measured 2026-09-17 against the upstream release APIs.** The pins are further behind than the working bootstrap suggests, because a bootstrap that succeeds tells you nothing about currency.
>
> | Component | Pinned | Latest | Published | Gap |
> | --- | --- | --- | --- | --- |
> | llvm-mingw | `20251216` | `20260908` | 2026-09-08 | about 9 months |
> | CMake | `4.2.3` | `4.4.3` | 2026-08-25 | two minor releases |
> | Ninja | `1.13.1` | `1.13.2` | 2025-11-20 | one patch |
>
> The pinned llvm-mingw carries clang 21.1.8, measured from a real bootstrap on 2026-09-17.

<!-- claim: count "20251216" toolchain.json = 3 -->
<!-- claim: exists scripts/cpp-env.ps1 -->
<!-- claim: exists src/Resolute.manifest -->
<!-- claim: count "NTDDI_VERSION=0x0A000006" CMakeLists.txt = 1 -->
<!-- claim: count "4\.2\.3" toolchain.json = 3 -->
<!-- claim: count "1\.13\.1" toolchain.json = 2 -->

**The tension this section resolves.** Pinning and "latest" pull against each other and both are right: a pin buys reproducibility, currency buys compiler fixes and newer C++23 support. The resolution is that **a pin is a dated decision, not a permanent one**, and that falling behind must be *visible* rather than discovered by accident nine months later.

**Needs:** Windows host (build/test)

**Build order.** Bump one component at a time and run the full gate between each. Bumping all three at once means a new diagnostic cannot be attributed to the thing that caused it.

1. **Ninja first**, because it is a patch release and the least likely to change behaviour. Done when: the gate passes on `1.13.2`.
2. **CMake second.** Two minor releases can change policy defaults, which is a configure-time failure and therefore loud. Done when: the gate passes on `4.4.3` with no new policy warnings, or each one is resolved and recorded.
3. **llvm-mingw last**, because it carries the compiler and is the only one that can produce new warnings across the whole tree. Done when: the gate passes and the new clang version is recorded.

- [ ] Record the clang version each llvm-mingw release carries, not just the release date. Done when: this section names the clang version for the outgoing pin (21.1.8, measured 2026-09-17) and for the incoming one, because "llvm-mingw 20260908" says nothing about what changed for the code.
- [ ] Bump Ninja to `1.13.2` alone, then run the full gate. Done when: `scripts/check-all.ps1` passes and the pin, URL, and SHA-256 in `toolchain.json` are updated together.
- [ ] Bump CMake to `4.4.3` alone, then run the full gate. Done when: configure produces no new policy warnings, or each new one is resolved and named here with what it changed.
- [ ] Bump llvm-mingw to `20260908` alone, then run the full gate. Done when: the build passes at the project warning level with warnings as errors.
- [ ] **Treat new compiler diagnostics as findings, not as noise to silence.** Done when: every new warning the bump surfaces is either fixed or suppressed with a named reason at the narrowest scope, and a blanket suppression is recorded as a decision with its cost. Cheaper substitute that fails the checkpoint: lowering the warning level or adding a global `-Wno-` to make the bump quiet, which discards exactly the value the newer compiler provides.
- [ ] Re-measure the binary size after the bump, against the recorded baseline. Done when: the new size is quoted against the 1.39 MB figure `§2` records, because a compiler change moves it and the per-tool size budget is measured against it.
- [ ] Add `scripts/toolchain-latest.ps1`, which reports each pin against the upstream latest release and exits non-zero when any is behind. Done when: running it today reports all three as current, and artificially lowering one pin makes it exit non-zero naming that component, the pinned version, and the latest.
- [ ] **Keep the check advisory, never automatic.** Done when: the script reports and does not edit `toolchain.json`, and this section records why: an unattended bump of a compiler can break a build nobody is watching, and the reproducibility a pin buys is worth more than being current by a few days.
- [ ] Decide the re-evaluation cadence and record it as a dated default. Done when: the cadence is written with its cost of changing, and it names who runs the check. Cheaper substitute: leaving it to whoever notices, which is what produced the nine-month gap this section opens with.
- [ ] Wire the check into the combined gate as a **warning, not a failure**. Done when: a pin that has fallen behind prints a named advisory line in `scripts/check-all.ps1` output and does not fail the build.
- [ ] Record what this section cannot promise. Done when: it states that being current is not the same as being correct, because a newer compiler can regress, and that the pin exists so a regression can be backed out by editing one file.
- [ ] Commit: `"workspace: bring the toolchain pins current and report when they fall behind"`

**Test checkpoint:** `toolchain.json` names llvm-mingw `20260908`, CMake `4.4.3`, and Ninja `1.13.2`, each with a URL and a SHA-256, and a clean bootstrap from those pins populates the toolchain directory and leaves `git status` clean. `scripts/check-all.ps1` passes at each of the three bumps, run separately. Every new compiler diagnostic is named here with its disposition. The binary size is quoted against the 1.39 MB baseline. `pwsh scripts/toolchain-latest.ps1` exits 0 with all three current; lowering one pin makes it exit non-zero naming the component, the pinned version, and the latest. The check writes nothing, proven by there being no write path to `toolchain.json`.

## 7. The Bare-Machine Proof

The whole argument for a repository-scoped toolchain is that a machine with nothing installed can build this. Until that is run on such a machine, it is a design intention rather than a fact.

> [!IMPORTANT]
> **Split out of `§1` on 2026-09-17, and not weakened in the move.** `§1`'s own Build order called this "the only stage needing a second machine". The development machine has Visual Studio and the Windows Kits installed, verified directly, and Windows Sandbox is not installed, so there is no honest way to run this here. Holding `§1`'s other thirteen items, and the 27 open sections downstream of it, against hardware nobody has was the wrong trade.
>
> **`§1` proves the narrower claim** that a compile and link consults nothing outside `reskit/`. That is real and it is not this. **Absence cannot be simulated on a machine that has the thing**: a toolchain can silently fall back to a registry key, an environment variable, or a well-known path, and only a machine genuinely without Visual Studio can show that it does not.

**Needs:** Clean Windows machine (no Visual Studio)

A clean VM, a Windows Sandbox instance, or a second physical machine all serve. Windows Sandbox is the cheapest: it needs the `Containers-DisposableClientVM` feature enabled, which requires elevation and a reboot, so it is an operator action rather than something a session can arrange.

- [ ] Record what the machine is before anything is installed on it. Done when: its Windows build number, and the verified absence of Visual Studio, the Windows Kits, `cl.exe` and `msbuild`, are written here, gathered the same way `§1` gathered them for the development machine.
- [ ] Clone and bootstrap with nothing else present. Done when: `git clone` without `--recursive` followed by `pwsh scripts/bootstrap.ps1` populates `reskit/` on that machine, and the elapsed time is recorded.
- [ ] Build the real application, not a sample. Done when: `cmake --preset release && cmake --build --preset release` produces `Bin/Release/Resolute.exe` on that machine, and the binary's size is compared against the figure this repository records.
- [ ] Run it. Done when: the executable starts on that machine and creates its window, which is the only thing that proves the produced binary has no unmet runtime dependency. Cheaper substitute that fails the checkpoint: a successful link, which says nothing about what the loader will ask for.
- [ ] Record what the run needed that the bootstrap did not supply, if anything. Done when: either nothing is named, or each missing piece is named with where it came from, because that list is the real content of this section.
- [ ] Commit: `"workspace: the bare-machine proof"`

**Test checkpoint:** The machine's Windows build is quoted alongside evidence that Visual Studio, the Windows Kits, `cl.exe` and `msbuild` are all absent. A clone without `--recursive` and one bootstrap produce a working toolchain, timed. `Resolute.exe` builds and its size matches what this repository records, or the difference is explained. The executable **runs** and creates its window on that machine. Anything the run needed beyond the bootstrap is named with its source.

## Verification

- [ ] `pwsh scripts/bootstrap.ps1` populates the toolchain from the pins and leaves `git status` clean
- [ ] `pwsh scripts/cpp-env.ps1` exits 0 and prints every resolved component version
- [ ] `pwsh scripts/build.ps1 -All` builds every defined target for both architectures
- [ ] `pwsh scripts/check-all.ps1` exits 0 on a clean tree
- [ ] A fresh clone into a different absolute path builds with no file edited
- [ ] Bootstrap and build succeed on a machine with no Visual Studio and no Windows SDK installed
- [ ] No absolute path appears in any build file, and no `.sln` or `.vcxproj` is committed
- [ ] `python scripts/todo-graph.py validate` clean
