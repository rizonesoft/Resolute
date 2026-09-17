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
> **Current state (verified 2026-09-16):** A working toolchain bootstrap and CMake structure arrive with `D00 T03`, from the ExoSuite codebase: llvm-mingw 20251216 ucrt-x86_64, CMake 4.2.3, Ninja 1.13.1, C++23, presets driving Ninja with LTO on release, and full static linking producing a 1.39 MB executable. There is **no vcpkg**, and after `D00 T03 §1` retires `Console` and the `libvterm` submodule with it, **no external dependency at all** beyond the toolchain and Catch2. What did not exist anywhere when this was written was hash verification on the bootstrap, a locator that fails by name, a warning level applied across targets, `clang-tidy`, a one-command build, or a combined gate. **Groomed 2026-09-17: five of those six now exist**, built by `§1`, `§3` and `§4`. `scripts/bootstrap.ps1` verifies hashes before replacing anything, `scripts/cpp-env.ps1` fails by name, `cmake/ResoluteWarnings.cmake` applies the level to every target the project owns and fails the configure if one is missed, `.clang-tidy` exists with a recorded baseline, and `scripts/build.ps1` builds any tool or all of them. **The combined gate is the one still open**, and `§5` owns it: `scripts/check-all.ps1` does not exist. The AutoIt suite under `resolute_au3/` separately does not build from a clean checkout, because thirteen `.sni` descriptors point at `R:\Workspace\Resolute`, a directory that no longer exists; `D09 T01 §1` owns that.

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
|   1   |   §1    | Harden the toolchain bootstrap               | D00 T03 §3 |  [x]   |
|   2   |   §2    | CMake structure and dependencies             | §1         |  [x]   |
|   3   |   §3    | Warnings as errors at one level              | §2         |  [x]   |
|   4   |   §4    | One command builds any tool                  | §2         |  [x]   |
|   5   |   §5    | One command runs every gate                  | §3, §4     |  [x]   |
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

> **Verified:** 2026-09-17 | §1 | `toolchain.json` pins all three components with URLs and SHA-256 taken from real downloads and independently cross-checked against GitHub's own recorded digests, all three matching · second bootstrap run installs nothing in 0.7s and leaves `git status` clean · a corrupted hash aborts naming expected and actual **and the old install survives**, driven · a `dir` escaping `reskit/` is refused, driven · `cpp-env.ps1` proves four paths: all resolving, this machine's real ninja 1.13.2 on PATH rejected against the pin, not-found-anywhere, and a component missing a required field, each naming what it looked at and what fixes it · the self-contained probe calling `CreateFileW` and `D2D1CreateFactory` compiles, links and **runs**, with 3 include and 4 library paths all inside `reskit/` · the floor is genuinely 1809: `NTDDI_VERSION=0x0A000006` added where only a generic `0x0A00` existed, and `Resolute.exe` now carries a manifest, read back from the binary
> **Review:** round 2, candidate `6bb635e` `87fbb48` `9874bf8` `8437dd5` plus the follow-up fix -- `adversarial` approve after fixes (4) · `consistency` approve · `integration` approve · `source-defect` approve · `design` not-applicable · `record` approve. Raw findings: docs/reviews/00-workspace/D00-T01-s1.md
> **Independent:** `codex review --commit 6bb635e` (gpt-6-astra, high) returned **three P2 findings**; two new and both correct, the third already fixed in a commit it had not read. Its value was probe specificity: on the stale-stamp defect it constructed the case mine missed by one step, removing only the executable and leaving the attestation behind, which is the difference between testing that a check fires and testing what it trusts. Two earlier invocations against this commit produced no output within their window; a third succeeded, and a smaller commit reviewed in seconds, so the cause appears to be commit size.
> **CRUD:** applicable | driven: `bootstrap.ps1` wrote `reskit/llvm-mingw` from a hash-verified download and its `.pinned-version` stamp was read back by `cpp-env.ps1`; the destructive path was exercised twice, once by hash mismatch and once by a traversal `dir`, and in both the existing install was still present afterwards
> **Duration:** 335
> **Implementer:** Claude Opus 5 (claude-opus-5[1m])

## 2. CMake Structure and Dependencies

> **Started:** 2026-09-17T06:16:45Z

The intake brings a working CMake structure: C++23, presets driving Ninja, LTO on release, and full static linking. This section makes it the repository's structure rather than one application's, and settles how dependencies arrive now that there is no vcpkg and no wxWidgets.

> [!IMPORTANT]
> **Validated 2026-09-17 before implementation. Five corrections, and one of them changes what the main item has to do.**
>
> **`samples/` has not been deleted.** An item below says "before the operator deleted `samples/`". All four checkouts are still on disk: `ExoSuite`, `RegStudio`, `SDImage`, `Undelete`, with `git ls-files samples` empty. What *is* true, and is the thing that matters, is that `build/release/CMakeCache.txt` contains **zero** references to `samples`.
>
> **The static-linking item is already satisfied, and not by what it names.** It asks for `-static -static-libgcc -static-libstdc++` "set once for every target". The root `CMakeLists.txt:46` sets only `add_link_options(-static)`; the other two appear solely inside `extensions/RegStudio`. And yet the objective holds: `llvm-objdump -p Bin/Release/Resolute.exe` lists **no compiler runtime DLL at all**, no `libgcc_s_seh-1`, no `libstdc++-6`, no `libwinpthread-1`. The `api-ms-win-crt-*` entries are the OS UCRT, not a compiler runtime. So the item's *goal* is met while its *prescription* is not, and the honest fix is to make the flags match what already works rather than to add flags that change nothing.
>
> **The executable already imports neither shipped DLL.** `Resolute.exe` names neither `ResoluteUI.dll` nor `Lucide.dll` in its import table, which confirms `ResoluteUI_static` is linked and leaves exactly one thing standing between this and a single file: the runtime `LoadLibraryW` in the icon loader. That is the section's real work, and everything else here is already true or nearly so.
>
> **Two paths are stale from `§3`'s rename.** The `Test checkpoint` still cites `shared/exo-ui/src/icons.cpp:15`, and an item still names `System/ExoUI.dll`. Both moved to `resolute-ui` and `ResoluteUI.dll`.
>
> **The sizes moved again, by 3,584 bytes.** `§1` added an application manifest. `Resolute.exe` is **1,384,960** bytes against the 1,381,376 recorded here, and the shipped set is **4,079,106** against 4,074,176.

**Needs:** C++ toolchain (compile)

- [x] Make the presets resolve their compiler and generator from the bootstrapped toolchain rather than from `PATH`. **The defect was exactly as described:** both presets carried `"CMAKE_C_COMPILER": "clang"`, a bare name, so whatever `PATH` offered first won. All four tool paths are now pinned to `${sourceDir}/reskit`, including `CMAKE_RC_COMPILER` and `CMAKE_MAKE_PROGRAM`, which were not mentioned and were resolving the same way.

  **Driven proof.** A decoy `clang.cmd`, `clang++.cmd` and `ninja.cmd` were placed first on `PATH`, verified to be what `Get-Command` resolved, and the configure still selected:

  ```
  CMAKE_CXX_COMPILER:STRING=R:/.../Resolute/reskit/llvm-mingw/bin/clang++.exe
  CMAKE_MAKE_PROGRAM:UNINITIALIZED=R:/.../Resolute/reskit/ninja/ninja.exe
  ```

  **What this does not pin, stated plainly:** `cmake` itself. The presets govern what CMake *uses*; CMake has to be found before it can read them. `reskit/Init-ResKit.ps1` or an explicit path is still required, and `scripts/cpp-env.ps1` is what reports whether the right one is there.
- [x] **Cut the build's dependency on the gitignored `samples/` tree.** **Closed 2026-09-17 by the preset pinning above**, which is the preference half this item still owed: the toolchain is now selected because the presets name it, proven against a decoy first on `PATH`, not because something put it there first. Filed 2026-09-17 by the review of `D00 T03 §1`. `build/release/CMakeCache.txt` resolved `CMAKE_CXX_COMPILER`, `CMAKE_MAKE_PROGRAM`, and `CMAKE_COMMAND` into `samples/ExoSuite/exokit/`, while the merged tree's own `exokit/` held only scripts. `D00 T03 §1` states the local checkouts are working copies that may stay on disk, and that is false while the compiler is resolved through one of them: deleting `samples/` breaks the build. Done when: a configure from a tree with `samples/` absent succeeds, proven by moving it aside and configuring, and no cache path in `build/` contains the string `samples`. **Half proven 2026-09-17. Corrected: `samples/` has not been deleted**, all four checkouts are still on disk and `git ls-files samples` is empty, so the tree is unchanged from when this was written. What was proven: the directory was renamed aside, `build/release` deleted, and a clean configure and 52/52 build ran with it absent. What that does **not** prove, and what this item still owes, is preference: the toolchain was found because `Init-ExoKit.ps1` puts it on `PATH` first, not because a preset pins it, so a stray `clang` earlier on `PATH` could still win. Cheaper substitute that fails the checkpoint: deleting `build/` and reconfiguring on a machine where `samples/` still exists, which proves nothing because the bootstrap would find it again.
- [x] Generate no Visual Studio solution and commit none. Verified 2026-09-17: `git ls-files` matching `.sln` or `.vcxproj` returns nothing, and the generator is Ninja in both presets, so VS, VS Code and a bare terminal all drive the same configure.
- [x] Settle how dependencies arrive. **Corrected 2026-09-17 after independent review:** the tree does **not** have none. `shared/lucide/CMakeLists.txt:9` fetches `sammycage/lunasvg` v3.5.0 through `FetchContent` at configure time and links it into Lucide, so a fresh configure reaches GitHub. Retiring the `libvterm` submodule removed the `--recursive` requirement, not the dependency. Done when: the decision is dated, covers **lunasvg and Catch2** as the third-party code, states whether lunasvg is pinned by tag or by hash, and gives the rule for adding a dependency later. Cheaper substitute: adding a package manager for two dependencies.

  **Decided 2026-09-17. `FetchContent`, pinned by commit, and no package manager.**

  lunasvg was pinned by the **tag** `v3.5.0`, and it is now pinned by the commit that tag resolved to, `83c58df8103dc7dca423dfd824992af94d49bed6`. A tag is a movable reference: it can be repointed at different code while the version string stays the same, and a `FetchContent` build follows it without anything appearing to change. `GIT_SHALLOW` had to go with it, because a shallow clone fetches only a branch tip and an arbitrary commit need not be reachable from one. Verified by a full clean rebuild: the fetched source is at that commit.

  Catch2 arrives the same way when `D00 T02 §1` lands, pinned by commit for the same reason.

  **The rule for adding a dependency later:** it arrives through `FetchContent` pinned by commit, it is recorded here with what it is for, and the decision names what the suite would do without it. Two dependencies do not justify a package manager, and a package manager is itself a dependency with its own bootstrap, its own pinning story and its own failure modes. That trade changes if the count grows past a handful, and this line is where to revisit it.
<!-- claim: count "lunasvg" shared/lucide/CMakeLists.txt = 7 -->
<!-- claim: absent .gitmodules -->
- [x] Keep static linking explicit and enforced. **Corrected 2026-09-17:** the goal is already met and the prescription is not. The root sets only `add_link_options(-static)`; `-static-libgcc` and `-static-libstdc++` appear nowhere outside `extensions/RegStudio`. `llvm-objdump -p` on the built executable nonetheless lists no compiler runtime DLL. Done when: all three flags are set **once at the root** so every target inherits them and no per-tool `CMakeLists.txt` has to remember, `extensions/RegStudio` stops setting its own copy, and the import table is re-checked after the change and still names no compiler runtime. Cheaper substitute that fails the checkpoint: leaving the flags per-target, which is the fourteen-copies failure `AGENTS.md` exists to prevent, arriving one tool at a time.

  **Done 2026-09-17.** All three flags are set once at `CMakeLists.txt:46` and `extensions/RegStudio` no longer repeats them. Re-checked after the change: `llvm-objdump -p Bin/Release/Resolute.exe` lists **23 imports, none of them a compiler runtime**, no `libgcc_s_seh-1`, no `libstdc++-6`, no `libwinpthread-1`, and neither shipped DLL.

  **That reassurance was wrong, and the independent review proved it by building.** `extensions/RegStudio` is commented out of the *root* build at `CMakeLists.txt:63`, which is what I checked. It is not out of the build: it is a standalone CMake project with its own `project()` call, and `reskit/Build-Extension.ps1` configures it with `cmake ..` from inside its own directory, so the root `CMakeLists.txt` is never read on that path. Deleting its flags therefore gave the standalone build fresh `libc++.dll` and `libunwind.dll` imports, an executable that would not start on a machine without them.

  **So "set once" had to mean one FILE, not one CMakeLists.** `cmake/ResoluteLinkPolicy.cmake` holds the flags and is included by the root and by the extension, by path. Proven by configuring and building RegStudio exactly the way its own script does: **17 imports, none a compiler runtime**.

  The same entry points were also passing `-DCMAKE_C_COMPILER=clang`, a bare name from `PATH`, which is the identical defect the presets had. All three scripts now name the `reskit` path.
- [x] **Replace the runtime icon loader, which is what actually breaks standalone.** Corrected 2026-09-17 after independent review: an earlier draft of this item blamed the `SHARED` library targets, which was wrong. `src/CMakeLists.txt` links `ResoluteUI_static`, so the UI library is already static. The real dependency is explicit: `LucideIcons::Load()` at `shared/resolute-ui/src/icons.cpp:15` calls `LoadLibraryW(L"System\Lucide.dll")` and resolves entry points with `GetProcAddress`. Done when: icons render with **no DLL present beside the executable**, proven by deleting `System/` and running. Cheaper substitute that fails the checkpoint: checking the executable's import table, which cannot see a runtime `LoadLibrary` and would pass a tool that still needs a DLL.

  **Done 2026-09-17.** `Lucide_static` was added beside the DLL target, `lucide.h` gained a `LUCIDE_STATIC` branch so the API carries no import or export decoration when linked in, and `LucideIcons::Load()` binds the six entry points **directly** under that definition. Every call site is unchanged: the function pointers are still what callers use, only their source differs.

  Then both SHARED targets were removed, because nothing linked them and nothing could: `AGENTS.md` states a tool may never depend at runtime on another tool, on the launcher, or on a suite-wide file, which is exactly what a shared `ResoluteUI.dll` would be. Checked by search before removing: the launcher links the static variant and `extensions/RegStudio` links only Win32 libraries.

  **Proven three ways, because the import table cannot see this defect:**

  ```
  Bin/Release contains exactly one file        Resolute.exe
  launched with no DLL anywhere                window 'Resolute', four control classes live
  loaded Lucide/ResoluteUI modules             NONE
  icon count read from a linked binary         icons=29  first=badge-info
  ```

  **Read that first line precisely.** It means the *launcher* ships as one file. `Bin/Release/System/` is not empty in general: it is where **extension executables** are deployed for the launcher to discover, which is the `RESEXT` model in `docs/extensions.md`. Building RegStudio puts `RegStudio.exe` there, as it should. What is gone is shared **libraries**: no tool loads a DLL that another tool owns, which is the rule `AGENTS.md` states and which the two removed SHARED targets would have broken.

  The last line is the one the checkpoint insists on: a launcher with no icons still draws a window, so counting them is the only thing that distinguishes a working icon set from a missing one.
<!-- claim: count "LoadLibraryW" shared/resolute-ui/src/icons.cpp = 3 -->
<!-- claim: count "LUCIDE_STATIC" shared/resolute-ui/src/icons.cpp = 2 -->
<!-- claim: count "Lucide_static" src/CMakeLists.txt = 1 -->
<!-- claim: count "ResoluteUI_static" src/CMakeLists.txt = 1 -->
- [x] Record what the release preset ships today, so the change has a before. **Re-measured 2026-09-17 after `§1` added the application manifest:** `Bin/Release/Resolute.exe` at **1,384,960** bytes plus `System/ResoluteUI.dll` at 898,048 and `System/Lucide.dll` at 1,717,760, **4,079,106** bytes in total. This read 1,381,376 and `ExoUI.dll` before; the manifest added 3,584 bytes and `§3` renamed the library. **Corrected 2026-09-17 by `D00 T03 §2`:** this read `ExoSuite.exe` at 1,380,352 bytes. The rename added 1,024 bytes, which is the version-resource block that executable had never carried. `shared/resolute-ui/CMakeLists.txt:33` and `shared/lucide/CMakeLists.txt:58` still build `SHARED` targets even though the application does not link ExoUI's. Done when: the unused shared target is either removed or its purpose recorded.
- [x] Put all build output under `build/`, which is already gitignored, with nothing written inside `src/`. Verified 2026-09-17 after a full clean configure and build from a deleted `build/` and `Bin/`: `git status --porcelain build/ Bin/` is empty, and `src/` shows only the intended source edits. The generated `Resolute.rc` lands in `build/`, not beside its `.rc.in`.
- [x] Prove the structure builds the real application, not a placeholder. Verified 2026-09-17: `build/` and `Bin/` deleted, configure and build from scratch produce `Bin/Release/Resolute.exe`, which **runs** and creates its window with all four control classes live. There are no submodules, so `--recursive` is moot; `.gitmodules` is absent and claimed as such.
- [x] Record the binary size as the baseline the per-tool size budget is measured against. **Measured 2026-09-17, and the number moved for a reason worth recording:**

  | Stage | Shipped set | Bytes |
  | --- | --- | ---: |
  | pre-intake | `ExoSuite.exe` alone | 1,423,872 |
  | before this section | `Resolute.exe` + 2 DLLs | 4,079,106 |
  | **after this section** | **`Resolute.exe` alone** | **2,512,384** |

  The executable grew because Lucide and lunasvg are now inside it; the **shipped set** fell by 1,566,722 bytes, 38 percent, because two DLLs stopped shipping. The per-tool budget is measured against the shipped set, not the executable, so **2,512,384 bytes is the baseline** and the launcher is the fattest thing the suite will ship: it carries the icon set every tool draws from.
- [x] Commit: `"workspace: repository cmake structure and dependency policy"`

**Test checkpoint:** `cmake --preset release && cmake --build --preset release` succeeds on a clean checkout after bootstrap and produces `Resolute.exe`. The executable's imports are listed and carry no compiler runtime DLL. **Separately, the executable is run with `System/` deleted and its icons still render**, because the import table cannot see the `LoadLibraryW` in `shared/resolute-ui/src/icons.cpp` and an import-only check would pass a tool that still needs a DLL. The icon count is read back from the running process, not inferred from the window appearing: a launcher with no icons still draws a window. No path in `build/` names `samples`, and a configure succeeds with `samples/` moved aside. `git status` is clean afterwards. The binary size is quoted against the 1.39 MB baseline.

> **Verified:** 2026-09-17 | §2 | the **launcher ships as one file**, `Bin/Release/Resolute.exe` at 2,512,384 bytes, down from three files totalling 4,079,106 · proven by the only instrument that can see this defect: launched with no DLL anywhere it creates its window with four control classes live and loads **no** Lucide or ResoluteUI module, and a linked binary reports **icons=29, first=badge-info**, because a launcher with no icons still draws a window · imports 23, none a compiler runtime or shipped DLL · both SHARED targets removed after checking by search that nothing linked them and `AGENTS.md` forbids anything ever doing so · presets pin all four tool paths to `reskit`, proven against decoy `clang`, `clang++` and `ninja` placed first on `PATH` · lunasvg moved from the movable tag `v3.5.0` to commit `83c58df8`, verified by a clean refetch · both presets build; `git status` clean after a full configure and build
> **Review:** round 2, candidate `6062ecb` `701fd87` `820047c` `85c3707` plus the follow-up -- `adversarial` approve after fixes · `consistency` approve after fix (1) · `integration` approve after fixes (2) · `source-defect` approve · `design` not-applicable · `record` approve after fix (1). Raw findings: docs/reviews/00-workspace/D00-T01-s2.md
> **Independent:** `codex review --commit 6062ecb` (gpt-6-astra, high) returned **one P1**, the first of this project, and it was worth more than a list. Centralising the link flags broke RegStudio's standalone build, adding `libc++.dll` and `libunwind.dll` imports. I had written into this section that the change was "unbuilt" because RegStudio is commented out of the **root** build; it is a standalone CMake project its own script configures directly. The reviewer did not argue that, it built it. Second section running where its advantage was constructing a probe rather than reading a diff.
> **CRUD:** applicable | driven: `reskit/Build-Resolute.ps1` and `reskit/Build-Extension.ps1` were **run**, not inspected, which is how three defects surfaced including one predating this session: PowerShell does not expand `$Var` in the bareword `-DNAME=$Var`, so these scripts had never configured a build type
> **Duration:** 19
> **Implementer:** Claude Opus 5 (claude-opus-5[1m])

## 3. Warnings as Errors at One Level

> **Started:** 2026-09-17T07:17:17Z

A warning level that varies per target is a warning level nobody trusts. A gate that is optional is a gate that is off, and this is the section that stops that from recurring.

> [!IMPORTANT]
> **Validated 2026-09-17 before implementation. Five corrections, and one of them changes what two items have to do.**
>
> **This section was written against a toolchain that no longer exists.** Two items and the checkpoint name **vcpkg** and **wxWidgets** as the third-party code that must be exempt from warnings as errors. `§2` settled that there is no vcpkg and no wxWidgets: dependencies arrive through `FetchContent` pinned by commit. The real third-party code is **lunasvg**, and it lands in `build/<preset>/_deps`, so the exemption has to be written against that path rather than against a package manager.
>
> **The figure in the opening sentence could not be verified and has been removed.** It read "the AutoIt tree carried 45 to 68 warnings per tool for years". That range appears nowhere else in the tree, carries no recorded source, and **cannot be re-derived**: checking it needs `Au3Check.exe` and an AutoIt toolchain, neither of which is on this machine nor bootstrapped by `reskit`. An unsourced number that reads as a measurement is worse than no number, because the next reader has no way to know it was never measured. The argument does not depend on it.
>
> **"The placeholder target" is stale.** The item asks that `clang-tidy` run "over the placeholder target". There is no placeholder: `Resolute`, `ResoluteUI_static` and `Lucide_static` are real targets building real code, proven by `§2`.
>
> **`clang-tidy` has no compile database on release.** Only the debug preset sets `CMAKE_EXPORT_COMPILE_COMMANDS`, so `build/release` has no `compile_commands.json` and `clang-tidy` cannot run there at all. `clang-tidy.exe` itself **is** present, at `reskit/llvm-mingw/bin/clang-tidy.exe`. There is also no `.clang-tidy` file, so the tool would run its default checks rather than a chosen set.
>
> **There are no warning flags at the root at all.** `-Wall` appears only at `extensions/RegStudio/CMakeLists.txt:25` and `:30`, per target, twice, which is the exact pattern the `§2` P1 was about: a policy set where only one entry point reads it. The launcher and the shared library are compiled with **no** warning flags today.

**Needs:** C++ toolchain (compile)

**Measured 2026-09-17 before any fix**, with `-Wall -Wextra` applied at the root as a temporary probe and then reverted:

| Source | Warnings under the probe |
| --- | ---: |
| `build/release/_deps` (lunasvg) | 93 |
| **ours** (`shared/resolute-ui`, `src`) | **13** |
| total | 106 |

**Thirteen is small enough to fix rather than baseline**, so `-Werror` goes on with nothing suppressed and no warning baseline file for the compiler gate. That is the difference between a gate that is on and a gate that is on with an exception list nobody revisits.

> [!WARNING]
> **The 93 is an artifact of the probe and not a property of this build. Corrected 2026-09-17, during implementation.**
>
> The probe applied `-Wall -Wextra` with `add_compile_options` **at the root**, and a `FetchContent` dependency is an ordinary subdirectory of the same build, so lunasvg inherited the flags. That inheritance is the thing the shipped policy exists to prevent. Under the policy as it ships, nothing applies those flags to lunasvg: a clean rebuild recompiles its 23 translation units and emits **0** warnings.
>
> So the count was never measuring lunasvg's own build. It was measuring what would happen if the policy were written the wrong way, which is worth knowing and is not the same claim.
>
> **This also invalidated the proof the checkpoint was going to use.** "Leave lunasvg's 93 warnings in place while the build succeeds" cannot be run, because there are no 93 warnings to leave. The exemption is proven directly instead, and the direct proof is strictly better: the **same** deliberate unused variable is compiled in `src/main.cpp` and in `lunasvg.cpp`, and only one of them fails. A count that happens to be non-zero shows a dependency is noisy; an identical probe passing on one side of the line and failing on the other shows where the line is.

- [x] Set the project warning level once, in one place, applied to every target the project owns. `cmake/ResoluteWarnings.cmake` holds the level, `-Wall -Wextra -Werror`, and both entry points include it: the root and `extensions/RegStudio`, the same two the link policy taught `§2` to cover.

  **The Done-when was delivered by a different mechanism, and the substitution is the interesting part of this section.** It asked that a new target "with no extra configuration" *inherit* the level. Inheritance is `add_compile_options` at a directory scope, and that is exactly what reaches lunasvg, because a `FetchContent` dependency is an ordinary subdirectory of this same build. The prescription and the next item are in direct conflict: you cannot have inheritance and a by-construction third-party exemption from the same mechanism.

  What shipped is the stronger half. The policy is applied per target, so nothing can leak into a dependency, and `resolute_assert_warnings_complete()` runs last at both entry points and **fails the configure** naming any target the project owns that never got it. A missed target is therefore impossible to ship rather than merely unlikely, which is what the item was protecting against. Inheritance can also be defeated by a target that sets its own options; an audit of what was actually applied cannot.

  **Driven both ways.** A throwaway `add_library(ThrowawayProbe STATIC throwaway_probe.cpp)` added with no warning configuration:

  ```
  configure   exit 1
    resolute_set_warnings() was never called for: ThrowawayProbe
  ```

  and with the one line added, the configure passes and the target's deliberate warning fails the build:

  ```
  throwaway_probe.cpp:1:23: error: unused variable 'deliberately_unused' [-Werror,-Wunused-variable]
  ```

  The second run is the falsifiability check: without it the first failure could have been the target being broken for some unrelated reason.
- [x] Enable warnings as errors for project targets and **disable** them for third-party dependencies. **Corrected 2026-09-17:** this read "for vcpkg dependencies" and "a warning inside wxWidgets", and neither exists; `§2` settled that dependencies arrive by `FetchContent` and the third-party code is **lunasvg**, which carries 93 of the tree's 106 warnings. Done when: a warning in `src/` fails the build, and lunasvg still compiles with its 93 warnings without failing anything. The exemption must hold **by construction**, not by an exclusion list: a dependency is exempt because nothing applied the policy to it, so a dependency added later is exempt without anybody remembering to add it.

  **Verified 2026-09-17 by compiling the identical probe on both sides of the line.** The same `int deliberately_unused = 42;` was inserted into `src/main.cpp` and into `_deps/lunasvg-src/source/lunasvg.cpp`:

  ```
  src/main.cpp      error: unused variable [-Werror,-Wunused-variable]   build exit 1
  lunasvg.cpp       recompiled, 0 errors                                 build exit 0
  ```

  This is a better proof than counting a dependency's warnings, because it holds the code constant and varies only which side of the policy it sits on.

  **And the exemption is structural, read from the build itself.** `build/release/compile_commands.json` carries `-Werror` on **13 of 13** of our C++ translation units and **0 of 21** under `_deps`. Nothing names lunasvg anywhere: it is exempt because no call reached it.
- [x] Add `clang-tidy` configuration and wire it to the compile database. **Corrected 2026-09-17:** there is no "placeholder target"; `Resolute`, `ResoluteUI_static` and `Lucide_static` are real. Also, only the debug preset exports a compile database, so `clang-tidy` cannot run against release at all, and no `.clang-tidy` file exists so the tool would run an unchosen default set. Done when: a `.clang-tidy` exists naming the checks, **both** presets export `compile_commands.json`, and `clang-tidy` runs over our real translation units and reports a count.

  **Done 2026-09-17.** `.clang-tidy` names the set, `CMakePresets.json` now sets `CMAKE_EXPORT_COMPILE_COMMANDS` on **release as well as debug**, and `clang-tidy` runs over the 13 translation units the compile database lists as ours.

  **The check set is narrower than "everything", and the reason is in the file.** What is in: `bugprone-*`, `clang-analyzer-*`, `performance-*`, `misc-*`, the families that find defects. What is out: `modernize-*` and `readability-*`, which are churn and style, and style is `DESIGN.md`'s decision rather than a linter's.

  **One exclusion is worth stating here because the number is startling.** `misc-const-correctness` alone produced **524 of 577** findings on the first run, 91 percent, every one of them "this local could be `const`". A baseline that is nine parts one style check is a baseline where a real regression is invisible, which is the opposite of what the ratchet exists for. It is excluded on the same defects-not-style principle as `readability-*`, and re-enabling it is a decision to make `const` a suite-wide convention and fix 524 sites, not a config tweak.
- [x] Record the starting finding count as the ratchet baseline. **The number is 59**, in `todo/.tidy-baseline`, measured 2026-09-17 over the 13 translation units the release compile database lists as ours.

  **59 unique findings from 84 raw diagnostic lines**, and the gap is the part that matters. A finding in a header is reported once per translation unit that includes it, and the same header arrives as both `resolute/theme.h` and `resolute/controls/../theme.h`. So the baseline file specifies the count as unique `(file, line, column, check)` tuples with the path normalised, because `D07 T01 §2` has to re-derive this number and a baseline nobody can reproduce is a number rather than a measurement.

  | Check | Findings |
  | --- | ---: |
  | `performance-no-int-to-ptr` | 25 |
  | `bugprone-switch-missing-default-case` | 12 |
  | `performance-enum-size` | 8 |
  | `clang-analyzer-security.ArrayBound` | 4 |
  | `performance-unnecessary-value-param` | 2 |
  | `clang-analyzer-deadcode.DeadStores` | 2 |
  | six others, one each | 6 |
  | **total** | **59** |

  > [!WARNING]
  > **This was committed as 52 and corrected to 59 by the independent review.** The seven missing findings were every `clang-analyzer-*` diagnostic, and they were in the log the whole time. My counting script matched the check name with the character class `[a-z0-9,.-]+`, and analyzer checks are spelled `clang-analyzer-security.ArrayBound`, with uppercase letters. Every one of them failed to match and was dropped silently, leaving a plausible total that was quietly wrong.
  >
  > **The measurement instrument was the defect, not the run.** The number came out looking reasonable, which is exactly why nothing flagged it: a parser that drops a whole category reports a smaller number, not an error. Had it shipped, the ratchet's first honest run would have reported 59 against a baseline of 52 and failed this unchanged tree as a regression.
  >
  > The character-class trap is now written into `todo/.tidy-baseline` itself, because `D07 T01 §2` has to write this same parser and would meet the same edge.

  The 25 `performance-no-int-to-ptr` are Win32 talking: `LPARAM` and `WPARAM` are integers that carry pointers, so the cast is the API rather than a mistake.

  **One of the 52 is a latent defect rather than a finding, and it is named in the baseline file so the ratchet starts with a target.** `bugprone-use-after-move` at `shared/resolute-ui/src/animation.cpp:55`: `AnimationManager::Add` reads `anim.id` after `std::move(anim)`. It returns the correct value today only because `Animation`'s implicit move copies its trivially-copyable `uint32_t id` rather than stealing it. Give `Animation` a user-defined move constructor and every caller storing an animation handle starts getting garbage, and it will not look like a memory bug.

  **Not fixed here, deliberately.** This section owns the gate, not the code the gate found; fixing it would be the section widening into work `D07 T01 §2` exists to sequence. Recorded rather than silently carried.
- [x] Prove the gate can fail. Verified 2026-09-17:

  ```
  src/main.cpp:34:41: error: unused variable 'deliberately_unused' [-Werror,-Wunused-variable]
  build exit 1
  ```

  and reverting it returns the build to exit 0 with zero warnings in our code. The diagnostic names `-Werror` itself, so the failure is the gate rather than a compile error that would have happened anyway.
- [x] Commit: `"workspace: warnings as errors at one level, with a tidy baseline"`

<!-- claim: exists cmake/ResoluteWarnings.cmake -->
<!-- claim: exists .clang-tidy -->
<!-- claim: exists todo/.tidy-baseline -->
<!-- claim: count "CMAKE_EXPORT_COMPILE_COMMANDS" CMakePresets.json = 2 -->
<!-- claim: count "resolute_set_warnings" cmake/ResoluteWarnings.cmake = 4 -->

**Test checkpoint:** A deliberate warning in `src/` fails the build; the **identical** warning inside **lunasvg** does not, proven by compiling the same statement on both sides of the policy line. `clang-tidy` reports a count that matches `todo/.tidy-baseline`. The failing and passing outputs are both quoted.

**Corrected 2026-09-17, twice.** First, this named a "vcpkg dependency", which does not exist. Second, the replacement proof, "leaving lunasvg's own 93 warnings in place", was itself withdrawn during implementation: that count was an artifact of a probe applying flags at the root, and under the shipped policy lunasvg emits zero. The proof is now the identical statement compiled on each side of the line, which holds the code constant and varies only the policy. The substitution is not cosmetic: a package manager's exemption would be configured per package, and `FetchContent` brings the dependency in as an ordinary subdirectory of the same build, so the exemption has to come from **not applying** the policy rather than from turning it off. The checkpoint therefore also requires that the third-party exemption survive a dependency being added without anybody editing a list.

> **Verified:** 2026-09-17 | §3 | the launcher and the shared library were compiled with **no warning flags at all** before this; `-Wall` existed only inside `extensions/RegStudio`, per target, twice · the gate fires: `src/main.cpp:34:41: error: unused variable 'deliberately_unused' [-Werror,-Wunused-variable]`, exit 1, and reverting returns exit 0 · the gate exempts third-party code, proven by compiling the **identical** statement in `lunasvg.cpp`, recompiled, exit 0, which holds the code constant and varies only which side of the policy line it sits on · structural confirmation from the build itself: `-Werror` on **13 of 13** our C++ translation units and **0 of 21** under `_deps` · the gate cannot be missed: a throwaway target with no configuration fails the configure with `resolute_set_warnings() was never called for: ThrowawayProbe`, and adding the one line makes the configure pass and the target's own deliberate warning fail the build · release exit 0 with 0 warnings, 2,512,384 bytes, 23 imports, no compiler runtime · debug exit 0 with 0 warnings · RegStudio builds standalone through its own script with 0 warnings and `-Werror` verified present in its own `build.ninja`, which is the path the root never reaches · driven: window 'Resolute', responding · 13 warnings in our code all **fixed** rather than baselined, so `-Werror` went on with nothing suppressed · `clang-tidy` baseline 59 unique findings from 84 raw diagnostics, with the reproduction procedure recorded · both presets now export `compile_commands.json`
> **Review:** round 2, candidate `cbd5164` `8dcb167` -- `adversarial` approve after fixes · `consistency` approve · `integration` approve · `source-defect` approve after fix (1) · `design` not-applicable · `record` approve after fixes (2). Raw findings: docs/reviews/00-workspace/D00-T01-s3.md
> **Independent:** `codex review --commit cbd5164` (gpt-6-astra, high) returned **one P2 and it was right**. The baseline shipped as 52; running the procedure this section documented yields 59. The seven missing findings were every `clang-analyzer-*` diagnostic, and they were in my log the whole time: my counting script matched the check name with `[a-z0-9,.-]+` and analyzer checks are spelled `clang-analyzer-security.ArrayBound`, with uppercase. A parser that drops a category reports a smaller plausible number rather than an error, so nothing flagged it, and the ratchet's first honest run would have failed this unchanged tree against its own baseline. Third section running where the reviewer's advantage was **running the thing rather than reading it**.
> **CRUD:** not-applicable | this section adds no data path. The behavioural evidence is the gate proven in both directions and on both sides of the third-party line, and the failure path is exercised three times: a warning that must fail, an identical warning that must not, and a target that must not be allowed to skip the policy.
> **Duration:** 25
> **Implementer:** Claude Opus 5 (claude-opus-5[1m])
> **Deferred:** the 59 findings stay in the baseline for the ratchet, with two named first targets: the `bugprone-use-after-move` in `AnimationManager::Add`, correct today only because `Animation`'s implicit move copies its trivially-copyable id, and four bounds findings of which two share a one-sided index guard that proves the lower bound and never `kCategoryCount`. This section owns the gate, not the code the gate found. -> XREF: D07 T01 §2 -- the ratchet that drives this count down


## 4. One Command Builds Any Tool

> **Started:** 2026-09-17T07:58:18Z

The AutoIt suite reached fourteen tools with no way to build them all, which is how thirteen `.sni` descriptors came to point at a directory that no longer exists. One command, exercised from the start, is what keeps that from happening again.

**Needs:** C++ toolchain (compile)

> [!NOTE]
> **The motivating claim was checked and holds, exactly as written.** All **13** `.sni` descriptors under `resolute_au3/SDK/Concrete/` carry paths rooted at `R:\Workspace\Resolute`, **91 occurrences** in total, and that directory does not exist: this repository is at `R:\conclave\projects\Resolute`. Every `ScriptPath`, `Icon`, `OutFilePath` and `DistributionPath` in the AutoIt build system points into nothing. This is the failure the section exists to prevent, and it is real rather than rhetorical.

> [!IMPORTANT]
> **Validated 2026-09-17 before implementation. Six corrections, and two of them change what items have to do.**
>
> **"Both architectures" contradicts a decision `§1` already recorded.** `§1` settled it as a dated default: **x86-64 is the only architecture built**, ARM64 is out of scope until there is a machine to drive a test on, and `armv7` and `i686` are "noted and not wanted: 32-bit Windows is outside the 1809 floor's practical audience". The phrase is inherited from the AutoIt suite, where all 13 descriptors set `CompileBoth=Y` and shipped an `X64` binary beside a 32-bit one. That was true of AutoIt and is not true here. Corrected to the one architecture the suite builds.
>
> **`scripts/build.ps1` does not exist, and three build scripts already do.** `reskit/Build-Resolute.ps1` and `reskit/Build-Extension.ps1` both work and were driven in `§2`. `reskit/Build-All.ps1` **is broken**: it decides whether to build the launcher with `Test-Path shell/CMakeLists.txt`, and there is no `shell/` directory, so `$HasShell` is false and **it silently builds no launcher at all**. It also bypasses the presets, configuring with a raw `cmake .. -G Ninja` and repeating all four tool paths inline. This is the same failure `§1` and `§2` each found once: a script that reports success while doing nothing teaches the reader to ignore it.
>
> **The output location item names the wrong directory.** It asks that executables land "under `build/`". `build/` is where CMake's own trees live, one per preset; the **shipped** output is `Bin/<Config>/`, set at `CMakeLists.txt:40-41`, and it is what `§2`'s stamp recorded as "Bin/Release, launcher build: exactly one file". Moving the output to `build/` would contradict a stamped section and mix derived CMake state with shipped binaries. Corrected to `Bin/<Config>/`, which satisfies what the item actually requires: one documented, predictable, repository-relative place with no absolute path.
>
> **"The placeholder from §2" is stale**, the same phrase `§3` carried. `§2` proved the structure builds the real application; `Resolute`, `ResoluteUI_static` and `Lucide_static` are real targets.
>
> **Two genuine output defects were found while checking that item, and this section owns both.** `extensions/RegStudio/CMakeLists.txt:15` sets `CMAKE_RUNTIME_OUTPUT_DIRECTORY` to `${CMAKE_SOURCE_DIR}/bin`, which is the extension's own directory only while it is built standalone; built from the root it would write into the repository root. And `Build-Extension.ps1` deploys to `Bin\Release\System` unconditionally, so a **Debug** extension build lands in the **Release** tree.
>
> **No absolute path appears in any tracked build file today**, checked across every `CMakeLists.txt`, `CMakePresets.json`, `.cmake` and `.ps1` that `git ls-files` reports. The only match was `https://github.com/sammycage/lunasvg.git`, which is a URL. So that half of the item is already true and the work is keeping it true.

- [x] `scripts/build.ps1 <Tool>` builds one tool. **Corrected 2026-09-17, twice.** It read "for both architectures", which contradicts `§1`'s dated default that x86-64 is the only architecture built and that `i686` is noted and not wanted; the phrase came from the AutoIt suite, where all 13 descriptors set `CompileBoth=Y`. And it read "builds the placeholder from `§2`", and there is no placeholder: `§2` proved the structure builds the real application. Done when: it builds `Resolute` and it builds `RegStudio`, and exits non-zero with a named message for an unknown tool name. **It must also replace the three build scripts already in `reskit/` rather than become a fourth**, because "one command" is the deliverable and four commands is the thing this section exists to prevent.

  **Done 2026-09-17.** `scripts/build.ps1` builds either target and the three `reskit/Build-*.ps1` scripts are gone. Targets are **discovered**, not listed: any directory under `extensions/` with a `CMakeLists.txt` is a target, so a tool added later is built without this script being edited.

  ```
  pwsh scripts/build.ps1 NotATool
    build: unknown tool 'NotATool'
      known targets: Resolute, RegStudio
      or build everything with: pwsh scripts/build.ps1 -All
    exit 2
  ```

  **An extension is built standalone, with its own `project()` call and the root never read.** That is deliberate: `§2` shipped a defect that appears only on that path, and a build command that reached extensions through the root could not see that class of defect at all.
- [x] `scripts/build.ps1 -All` builds every tool the project defines. Verified 2026-09-17, both configurations:

  ```
  building 2 target(s), Release, x86-64
    Resolute         OK      Bin\Release\Resolute.exe
    RegStudio        OK      Bin\Release\System\RegStudio.exe
  build: 2 target(s) built, Release, output under Bin\Release  exit 0
  ```

  Each target is named with its result and the path it landed at, and a failure prints `FAILED` beside the target and exits non-zero with a count, so the report cannot say "done" while something did not build. That is the defect the script it replaces had.
- [x] Support a release configuration alongside debug. Verified 2026-09-17: `-Config Debug` and `-Config Release` both build both targets, the configuration is named in the opening line, in every per-target line, and in the closing summary. Release defaults, because that is what ships.
- [x] Make the output location predictable and repository-relative. **Corrected 2026-09-17:** this said "under `build/`". `build/` holds CMake's own trees, one per preset; the shipped output is `Bin/<Config>/`, set at `CMakeLists.txt:40-41` and recorded in `§2`'s stamp as "Bin/Release, launcher build: exactly one file". Moving it would contradict a stamped section and mix derived CMake state with shipped binaries. Done when: the launcher lands in `Bin/<Config>/` and every extension in `Bin/<Config>/System/`, for **both** configurations, documented in the script's own help, and no absolute path appears in any tracked build file. Cheaper substitute: the absolute-path habit that broke every `.sni` in the AutoIt tree.

  **Two real defects found while checking this, both owned here.** `extensions/RegStudio/CMakeLists.txt:15` sets the output directory from `${CMAKE_SOURCE_DIR}`, which is the extension's own directory only while it is built standalone and becomes the repository root when it is built from the root. And `Build-Extension.ps1` deploys to `Bin\Release\System` unconditionally, so a Debug build of an extension lands in the Release tree, which is precisely an unpredictable output location.

  **Both fixed, and the output proven for both configurations 2026-09-17:**

  ```
  2512384  Bin/Release/Resolute.exe
   772096  Bin/Release/System/RegStudio.exe
  8703488  Bin/Debug/Resolute.exe
  1036288  Bin/Debug/System/RegStudio.exe
  ```

  A Debug extension now lands in the Debug tree. Under the script this replaces it would have landed in `Bin/Release/System/`, overwriting the Release binary with a Debug one carrying the same name, which is the kind of defect that is found by somebody shipping the wrong file.

  > [!WARNING]
  > **The table above was true when measured and had already stopped being true, and the independent review caught it. Corrected 2026-09-17.**
  >
  > Separating the *build trees* by configuration was not enough, because `RegStudio` wrote its executable to one path for every configuration. Build Release, build Debug, then build Release again: nothing changed, so ninja reports the Release build up to date, the Debug executable is still sitting at that path, and it is deployed as Release. The reviewer reproduced it and found the two files byte-identical; re-checking this repository found `Bin/Release/System/RegStudio.exe` already **was** the Debug binary at 1,036,288 bytes.
  >
  > So the first fix in this item, `CMAKE_SOURCE_DIR` to `CMAKE_CURRENT_SOURCE_DIR`, corrected a real defect and left a worse one behind it. The output now derives from `CMAKE_CURRENT_BINARY_DIR`, which is already per configuration, and the script searches only that configuration's own build tree instead of taking the newest executable from a shared directory. Looking in a shared directory and sorting by timestamp is a guess; looking in exactly one place is an answer.
  >
  > Re-driven as the reviewer drove it, Release then Debug then Release:
  >
  > ```
  > 2512384  Bin/Release/Resolute.exe
  >  772096  Bin/Release/System/RegStudio.exe
  > 8703488  Bin/Debug/Resolute.exe
  > 1036288  Bin/Debug/System/RegStudio.exe
  > ```
  >
  > **This is the second time in two sections that an evidence table of mine recorded a number that was accurate at the moment of measurement and wrong by the time it was read.** `§3`'s was a parser that dropped a category; this one is a build that overwrote its own subject. Neither was caught by re-reading the table.

  **No absolute path appears in any tracked build file**, re-checked after the change across every `CMakeLists.txt`, `CMakePresets.json`, `.cmake` and `.ps1` that `git ls-files` reports. The one match is `https://github.com/sammycage/lunasvg.git`, a URL.

  **Two further review findings, both fixed and both driven.** `cmake --preset` reads `CMakePresets.json` from the **current** directory, so the launcher could only be built from the repository root; the configure now runs from the root and `pwsh ./build.ps1 Resolute` works from `scripts/`. And every command was piped to `Out-Null`, so a failed compile printed "compile failed" and discarded the compiler's diagnostics. The full output is now kept under `build/logs/`, gitignored, with the last 25 lines printed on failure:

  ```
  --- last 25 lines of Resolute-Release-build.log ---
  FAILED: [code=1] src/CMakeFiles/Resolute.dir/main.cpp.obj
  src/main.cpp:574:13: error: variable has incomplete type 'void'
  ...
  --- full log: build\logs\Resolute-Release-build.log
  build: compile failed for Resolute
    Resolute         FAILED
  build: 1 of 1 target(s) failed (Release)
  exit 1
  ```
- [x] Prove a clean-checkout build. Done when: a fresh clone into a different absolute path builds without editing a single file, and this section records the path it was proven in. **Stated plainly 2026-09-17:** a fresh clone has the scripts and no toolchain, because everything `scripts/bootstrap.ps1` downloads into `reskit/` is gitignored. So the proof is clone, supply the toolchain the way a new machine would, then build with nothing edited. What this actually tests is that no absolute path is baked into a build file, which is why the clone must be at a **different** path rather than a copy of this one.

  **Proven 2026-09-17 at `R:\resolute-cleancheck`**, a clean export of all **8,124** tracked files, given the toolchain the way a new machine would be, and then built with nothing edited:

  ```
  building at: R:\resolute-cleancheck
    Resolute         OK      Bin\Release\Resolute.exe
    RegStudio        OK      Bin\Release\System\RegStudio.exe      exit 0
    Resolute         OK      Bin\Debug\Resolute.exe
    RegStudio        OK      Bin\Debug\System\RegStudio.exe        exit 0

  2512384  Bin/Release/Resolute.exe     772096  Bin/Release/System/RegStudio.exe
  8698880  Bin/Debug/Resolute.exe      1035776  Bin/Debug/System/RegStudio.exe
  ```

  The checkout started with no `Bin/` and no `build/`, and it **runs**: window 'Resolute', responding. Tracked files changed by the build: **0**, measured by diffing the built tree against the index it was exported from, which is the check that makes "without editing a single file" falsifiable rather than assumed.

  **Re-run after the review fixes rather than carried forward**, and both configurations built this time. The first pass proved the pre-fix code, and this section had just been shown what stale evidence costs.

  The two **Release** binaries are byte-identical to this tree's. The two **Debug** ones differ by a few hundred bytes, which is expected rather than alarming: `§2` established that this build is not reproducible, and debug information embeds the build directory, which is the one thing deliberately different between the two trees. Release matching while Debug does not is the signature of exactly that, and it doubles as an unplanned check that no build path reaches the shipped binary.

  > [!WARNING]
  > **The first attempt failed, and the reason is worth recording.** Exporting into the session scratchpad aborted with `Filename too long` on hundreds of files. The longest tracked path is **165 characters**, inside `resolute_au3/samples/`, and Windows' classic limit is 260, so the repository can only be checked out where the root path is under roughly 95 characters. At `R:\conclave\projects\Resolute` that leaves ample room and nothing is wrong today. It is recorded because "clone it anywhere and it builds" is not quite true, the failure is a checkout failure rather than a build failure, and the fix is `git config core.longpaths true` on the clone rather than anything in this repository.
- [x] Commit: `"workspace: one command builds any tool or all of them"`

<!-- claim: exists scripts/build.ps1 -->
<!-- claim: absent reskit/Build-All.ps1 -->
<!-- claim: absent reskit/Build-Resolute.ps1 -->
<!-- claim: absent reskit/Build-Extension.ps1 -->

> **Verified:** 2026-09-17 | §4 | `scripts/build.ps1` builds the launcher, any extension, or everything with `-All`, in either configuration, and the three `reskit/Build-*.ps1` are gone, so "one command" is true rather than aspirational · targets are **discovered** from `extensions/`, so a tool added later builds without editing the script · an extension is built **standalone**, with its own `project()` call and the root never read, which is the only path on which `§2`'s P1 was visible · `-All` reports every target with its result and its output path, and exits non-zero with a count when any fails · an unknown tool exits **2** naming it and listing the known targets · **the clean-checkout proof**: 8,124 tracked files exported to `R:\resolute-cleancheck`, no `Bin/` and no `build/`, toolchain supplied as a new machine would get it, both configurations built with **0 tracked files changed**, measured by diffing the built tree against the index it came from, and the launcher runs there: window 'Resolute', responding · the Release binaries are byte-identical to this tree's while the Debug ones differ, the expected signature of debug info embedding the build directory and an unplanned check that no build path reaches the shipped binary · output is one documented place, `Bin/<Config>/` and `Bin/<Config>/System/`, proven for both configurations · no absolute path in any tracked build file, excluding one `https://` URL · a deliberate compile error surfaces the failing command and all three diagnostics from `build/logs/`
> **Review:** round 2, candidate `b87af92` `67554f2` -- `adversarial` approve after fixes · `consistency` approve after fixes (2) · `integration` approve after fixes · `source-defect` approve after fix (1) · `design` not-applicable · `record` approve after fixes (2). Raw findings: docs/reviews/00-workspace/D00-T01-s4.md
> **Independent:** `codex review --commit b87af92` (gpt-6-astra, high) returned **three findings, one P1 and two P2, and all three were right**. The P1: `RegStudio` wrote its executable to one path for every configuration, so Release, Debug, Release again leaves ninja reporting the third build up to date and the **Debug** binary is deployed as Release. The reviewer found the two byte-identical, and this repository had already done it: `Bin/Release/System/RegStudio.exe` was the 1,036,288-byte Debug binary. This section had already "fixed" that line during validation, `CMAKE_SOURCE_DIR` to `CMAKE_CURRENT_SOURCE_DIR`, correcting a real defect and leaving a worse one. Its advantage was again probe construction, and this time the probe was a **sequence**: any one build passes, any two pass, only the third exposes it.
> **CRUD:** applicable | driven: the script was **run** in every mode rather than inspected, which is how the unknown-tool path, the cross-configuration deploy, the working-directory dependency and the discarded diagnostics were each seen. The failure path is exercised directly: a deliberate syntax error in `src/main.cpp` produces `FAILED`, the exact clang invocation and three diagnostics, then reverted.
> **Duration:** 18
> **Implementer:** Claude Opus 5 (claude-opus-5[1m])
> **Deferred:** the repository cannot be checked out where the root path exceeds roughly 95 characters, because the longest tracked path is 165 and Windows' classic limit is 260. The fix is `git config core.longpaths true` on the clone rather than anything here, and the deep paths are inside `resolute_au3/samples/`, which the maintenance domain owns. -> XREF: D09 T01 §1 -- the AutoIt tree's build paths

**Test checkpoint:** `pwsh scripts/build.ps1 -All` exits 0 and names every target built, in both configurations. A fresh clone into a different absolute path builds with no file edited, and that path is quoted. An unknown tool name exits non-zero with the named message. The three superseded scripts in `reskit/` are gone, proven by search, so "one command" is true rather than aspirational.

## 5. One Command Runs Every Gate

> **Started:** 2026-09-17T10:37:12Z

Five gates that must each be remembered are five gates that get skipped under time pressure. This is the command a push owes, and it exists so that "did you run the checks" has a single answer.

**Needs:** C++ toolchain (compile)

> [!IMPORTANT]
> **Validated 2026-09-17 before implementation. Four corrections, and one of them is a claim this file broke in its own previous section.**
>
> **"Both architectures" contradicts `§1`, for the second time in this file.** `§1` recorded the dated default that **x86-64 is the only architecture built**, with `i686` "noted and not wanted". `§4` corrected the same inherited phrase two sections ago and this one still carries it. Corrected to the two **configurations** the suite actually builds, Debug and Release, which is what "both" was reaching for on a toolchain that has one target.
>
> **A claim in `D00 T04 §5` goes false the moment this section ships, and it is misfiled.** an `absent scripts/check-all.ps1` claim sits in the body of `D00 T04 §5`, which is about the adjacency advisory and says nothing about this script. The sentence it actually supports is in `D00 T04 §1`: "that script **does not exist**: `D00 T01 §5` builds it". Both sections are stamped. The claim moves to the sentence it supports and flips to `exists`, which is claim maintenance rather than a rewrite: no checklist item, tick, or `Done when:` changes, and `§1`'s reasoning is untouched and was correct, since what it required is exactly what this section is doing.
>
> **And writing that sentence filed a claim.** The paragraph above originally quoted the claim's literal HTML-comment syntax to explain it, and `todo-claims.py` parsed the quotation as a real claim, taking the tree from 61 to 62 with an `absent` assertion this very section was about to falsify. The claim grammar has no escape, so **documenting a claim files one**. Written around here by describing the claim instead of reproducing it. Worth knowing before somebody writes a guide to the claim syntax inside a TODO.
>
> **Two self-correction checks exist and are not named.** The item list names `todo-claims.py` and `todo-graph.py validate`. It does not name `plan --check` or `todo-findings.py --check`, both of which exist now and both of which go stale **silently**. This is not hypothetical: the independent review of `§4` surfaced a stale `build/todo-progress.json` that my own gate sweep had missed, because I ran `plan --check` before ticking items rather than after. A combined gate that omits a check which fails quietly is not "a single answer". Added, and recorded as going beyond what `D00 T04 §1` registered, with that as the reason.
>
> **The boundary with the ratchet, stated so this section does not build it.** This section makes the tidy gate compare a count against `todo/.tidy-baseline`, currently **59**, and fail when it is higher. `D07 T01 §2` owns the **ratchet**: rewriting the baseline down in the same commit, naming which target regressed, and refusing a silent raise. Compare here, ratchet there.

- [x] Surface the self-correction checks in the combined gate. **Registered 2026-09-17 by `D00 T04 §1`, which owns the checks but not this script:** `scripts/todo-claims.py` exits non-zero on a **stale claim** and on a **fallen coverage floor**, and both must fail the combined gate rather than print and be ignored. Done when: both conditions are exercised against a deliberately broken fixture and both fail `check-all.ps1` by name.

  **Extended 2026-09-17, beyond what `D00 T04 §1` registered, with the reason.** `plan --check` and `todo-findings.py --check` are also self-correction checks, they both exist, and they both go stale **silently**. The independent review of `§4` caught a stale `build/todo-progress.json` that my own sweep had missed. A combined gate that omits a check which fails quietly does not give "did you run the checks" a single answer, which is this section's stated purpose. Done when: both also run and both fail the gate by name.

  **All four conditions driven 2026-09-17, each against its own deliberately broken fixture.**

  ```
  stale claim     claim pointed at scripts/no-such-file.ps1
                  STALE todo/00-workspace/TODO-04-self-correction.md:87
                  claims FAILED, check-all exit 1
  coverage floor  claims disabled in two covered Current state blocks
                  FLOOR coverage fell to 2, below the recorded floor of 3
                  claims FAILED, check-all exit 1
  ```

  `plan --check` needed no fixture: it **failed on the first real run**, catching a stale `build/todo-operator.json` that nothing else in the sweep would have. That is the evidence for extending this item, arriving before the item was finished.

  **One probe caught the claim system catching me.** Raising `COVERAGE_FLOOR` in the source to force the floor condition tripped a *different* claim, `'COVERAGE_FLOOR = 3' in scripts/todo-claims.py matches 1 times`. The floor value is itself claimed, so lowering it to pass is not available. The fixture was rebuilt to remove claims rather than move the floor.
- [x] `scripts/check-all.ps1` runs the build in **both configurations**, `clang-tidy` against the baseline, the Catch2 suite, and `python scripts/todo-graph.py validate`. **Corrected 2026-09-17:** this read "for both architectures", which contradicts `§1`'s recorded default that x86-64 is the only architecture built; `§4` corrected the same phrase and this one was missed. Debug and Release are what "both" means on a single-target toolchain. Done when: all four run in one invocation and the script exits non-zero if any fails. **Done 2026-09-17**, ten gates in one invocation:

  ```
  build Debug        ok              4.8s
  build Release      ok              7.0s
  tidy               ok            147.6s  59 finding(s), baseline 59
  tests              not present     0.0s  tests/ does not exist; D00 T02 §1 lands the harness
  graph validate     ok              0.5s
  graph self-test    ok              0.6s
  plan --check       ok              0.3s
  claims             ok              3.4s
  claims self-test   ok              0.9s
  findings ledger    ok              0.1s
  check-all: 10 gate(s) ok, 1 not present        exit 0
  ```
- [x] Report legibly: one line per gate with its result and duration, and the failure detail only for gates that failed. **Corrected 2026-09-17:** "three passes and one failure" was written when the build was one gate. A single deliberate warning now fails **two**, `build Debug` and `build Release`, because the same source is compiled twice, and that is the gate being right rather than wrong. Done when: a run with one deliberate warning fails only the build gates, every other gate passes, and detail is printed for the failures alone.

  Driven with an unused variable in `shared/resolute-ui/src/theme.cpp`:

  ```
  build Debug        FAILED          6.7s
  build Release      FAILED          6.1s
  tidy               ok            158.8s  59 finding(s), baseline 59
  graph validate     ok              0.6s
  ... and five more, all ok
  --- build Debug: last 25 lines of gate-build-debug.log ---
  ```

  The eight passing gates printed one line each and no detail. **The probe was deliberately moved to `theme.cpp` first:** putting it in `src/main.cpp` also failed the claims gate, because `main.cpp` carries a `lines` claim and appending to it changed the count. That is two gates doing their jobs, and it made the report harder to read as a demonstration of one.
- [x] Make the tidy gate compare against the baseline rather than zero. **Both observed 2026-09-17.**

  ```
  equal   tidy ok       59 finding(s), baseline 59
  above   tidy FAILED   clang-tidy found 59 finding(s), above the baseline of 58
  ```

  The second was driven by lowering the baseline rather than by manufacturing a finding, because it is the **comparator** under test and varying the cheaper side keeps the probe honest and reversible.

  > [!WARNING]
  > **The independent review found this gate reporting success on analysis that never ran, and an entire extension it never looked at. Corrected 2026-09-17.**
  >
  > **P1.** The loop ignored every `clang-tidy` exit code and the counter recognised only `warning:` lines. Analysis that cannot complete emits **errors and zero warnings**, so a broken config, an unreadable compile database or a failed analyser produced a count of 0, which is under any baseline, and the gate reported `ok`. Reproduced with an invalid `.clang-tidy` key.
  >
  > **This is the fifth time this file has found a check that reports success while doing nothing**, after `§1`'s "reskit/ is unchanged" on a destructive abort, `§2`'s "No .exe found" after a successful link, `§4`'s build script that built no launcher, and `§4`'s Debug binary deployed as Release. It is the first one I wrote myself, in the section whose whole purpose is that the checks cannot be skipped, while writing comments about that exact failure.
  >
  > **And the obvious half of the fix was not the half that works.** The review proposed tracking failures for every invocation. Driven, `clang-tidy` **exits 0** on an unknown config key: the probe reports `0 of 14 invocation(s) exited non-zero, 56 error diagnostic(s)`. Exit codes alone would not have caught it. The load-bearing check is scanning for `clang-diagnostic-error`, `error: ` and `Error while processing`, and both are kept because they fail differently.
  >
  > **P2.** The gate read only the **root** compile database. `RegStudio` is commented out of the root `CMakeLists.txt` and builds standalone, so it appeared in no database the gate read, **0 of 35 root entries**, and its own build tree exported none at all. A shipped extension was analysed by nothing while the combined command reported success.
  >
  > `scripts/build.ps1` now exports a compile database for every extension, and the gate reads all of them.
  >
  > **The baseline moved 59 to 103, and that is a coverage increase rather than a regression:**
  >
  > | | findings |
  > | --- | ---: |
  > | launcher + shared | 59, **unchanged** |
  > | `RegStudio`, newly covered | 44 |
  > | total | **103** |
  >
  > The 59 not moving is the check on the move. `todo/.tidy-baseline` records the raise with this reasoning, because that file says the ratchet only goes down and a raise has to earn its paragraph.

  **The counter is reimplemented in PowerShell here and it agrees with the Python one**, both reporting 59 on the same tree. That is worth stating: `§3` recorded a baseline of 52 instead of 59 because its check-name character class was lowercase-only, and a second independent implementation landing on the same number is the check that mistake never got.
- [x] Tolerate the harness not existing yet. Verified 2026-09-17: `tests/` does not exist, the gate reports `not present` with the reason and the section that removes it, and the run still exits 0.

  ```
  tests   not present   0.0s   tests/ does not exist; D00 T02 §1 lands the harness
                               and removes this tolerance
  ```

  Reported in yellow and counted separately in the summary, `10 gate(s) ok, 1 not present`, rather than folded into the ok count. A gate that never ran must not read as a gate that passed, which is the whole reason this tolerance is allowed to exist at all.
  -> XREF: D00 T02 §1 -- lands the harness and removes this tolerance
- [x] Commit: `"workspace: one command runs every gate"`

<!-- claim: exists scripts/check-all.ps1 -->
<!-- claim: count "COVERAGE_FLOOR" scripts/check-all.ps1 = 0 -->

> **Verified:** 2026-09-17 | §5 | `scripts/check-all.ps1` runs **ten gates in one invocation** and exits 0 on a clean tree: both build configurations, `clang-tidy` against the baseline, the Catch2 suite, graph validate, graph self-test, `plan --check`, claims, claims self-test and the findings ledger, one line each with its duration and **detail printed only for gates that failed** · every failure path driven against its own fixture: a build warning fails both build gates while eight pass, a baseline lowered to 58 fails tidy alone naming both numbers, a claim pointed at a nonexistent file fails claims by name, and claims disabled in two covered blocks produce `coverage fell to 2, below the recorded floor of 3` · `plan --check` needed no fixture, **failing on the first real run** and catching a stale `build/todo-operator.json` nothing else in the sweep would have, which is the evidence for extending the item arriving before the item was finished · the tests gate reports `not present` with the section that removes it and is counted separately rather than folded into ok, because a gate that never ran must not read as one that passed · tidy now covers **14 TUs from 2 databases** including the standalone extension, baseline **103** with the launcher and shared library unchanged at 59
> **Review:** round 2, candidate `e7d634f` `cecf69f` -- `adversarial` approve after fixes · `consistency` approve after fixes (2) · `integration` approve after fix (1) · `source-defect` approve · `design` approve · `record` approve after fixes (3). Raw findings: docs/reviews/00-workspace/D00-T01-s5.md
> **Independent:** `codex review --commit e7d634f` (gpt-6-astra, high) returned **one P1 and one P2, both right**. The P1 is the worst finding in this file: the tidy gate ignored every `clang-tidy` exit code and counted only `warning:` lines, so analysis that could not complete produced **errors and zero warnings**, a count under any baseline, and the gate said `ok`. **The fifth check this file has caught reporting success while doing nothing, and the first I wrote myself**, in the section whose purpose is that checks cannot be skipped. The reviewer built an isolated fixture with an invalid `.clang-tidy` rather than arguing from the loop. Its proposed fix, tracking per-invocation failures, would **not** have caught its own reproduction: `clang-tidy` exits 0 on an unknown config key, `0 of 14 invocation(s) exited non-zero, 56 error diagnostic(s)`. The load-bearing check is the error-diagnostic scan; both are kept.
> **CRUD:** applicable | driven: the gate was **run** in six states rather than inspected, which is how the report format, the two-configuration failure, and the interaction between the probe and the claims gate were each seen. Two probes were rebuilt after their first run taught something: the build warning moved out of `src/main.cpp` because that file carries a `lines` claim and appending to it failed a second gate, and the coverage-floor fixture stopped raising `COVERAGE_FLOOR` because that value is **itself claimed**, so lowering the floor to pass is not available.
> **Duration:** 35
> **Implementer:** Claude Opus 5 (claude-opus-5[1m])
> **Deferred:** the tests gate's `not present` branch is a tolerance, not a pass, and it is removed by the section that lands the harness. -> XREF: D00 T02 §1 -- lands the Catch2 harness and deletes this branch

**Test checkpoint:** `pwsh scripts/check-all.ps1` exits 0 on a clean tree and prints one line per gate. Introducing one deliberate warning makes it exit non-zero and show only that gate's detail. A tidy count one above the baseline fails. All three runs are quoted in the commit body.

## 6. Keep the Toolchain Current

> **Started:** 2026-09-17T13:46:50Z

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

<!-- claim: count "20260908" toolchain.json = 3 -->
<!-- claim: exists scripts/cpp-env.ps1 -->
<!-- claim: exists src/Resolute.manifest -->
<!-- claim: count "NTDDI_VERSION=0x0A000006" CMakeLists.txt = 1 -->
<!-- claim: count "4\.4\.3" toolchain.json = 3 -->
<!-- claim: count "1\.13\.2" toolchain.json = 2 -->

**The tension this section resolves.** Pinning and "latest" pull against each other and both are right: a pin buys reproducibility, currency buys compiler fixes and newer C++23 support. The resolution is that **a pin is a dated decision, not a permanent one**, and that falling behind must be *visible* rather than discovered by accident nine months later.

**Needs:** Windows host (build/test)

> [!IMPORTANT]
> **Validated 2026-09-17 before implementation. The table holds; three other things do not.**
>
> **The version table was re-measured rather than trusted, because currency is this section's whole subject.** Querying the three release APIs again returns exactly what is recorded above: llvm-mingw `20260908` published 2026-09-08, CMake `v4.4.3` published 2026-08-25, Ninja `v1.13.2` published 2025-11-20. A section about pins going stale is the last place to take a recorded figure on faith.
>
> **The size baseline is wrong, and `§2` says so explicitly.** An item asks that the new binary be quoted "against the 1.39 MB figure `§2` records". `§2` records **2,512,384 bytes** as the baseline, in those words, and lists 1,423,872 bytes as the **pre-intake** `ExoSuite.exe` that figure superseded. Measuring a post-bump binary against a number from before the intake would compare two different products.
>
> **An advisory that needs the internet is being wired into a gate that must work without it.** The last two items add `scripts/toolchain-latest.ps1` and put it in `scripts/check-all.ps1`. That check queries GitHub. `§1` built a bootstrap that works offline once `reskit/` is populated, and `§5` built a gate whose whole value is that it can always be run. Neither item says what happens on a machine with no network, and "warning, not a failure" does not cover it: an unreachable API is not the same as a pin being behind, and reporting one as the other is the reporting defect `D00 T04 §5` just finished fixing. The items now require the two be distinguishable.
>
> **Six claims in this section go stale the moment the pins move.** They count the outgoing versions in `toolchain.json`. They are updated in the same commit as the bump, which is what the claim system is for.

**Build order.** Bump one component at a time and run the full gate between each. Bumping all three at once means a new diagnostic cannot be attributed to the thing that caused it.

1. **Ninja first**, because it is a patch release and the least likely to change behaviour. Done when: the gate passes on `1.13.2`.
2. **CMake second.** Two minor releases can change policy defaults, which is a configure-time failure and therefore loud. Done when: the gate passes on `4.4.3` with no new policy warnings, or each one is resolved and recorded.
3. **llvm-mingw last**, because it carries the compiler and is the only one that can produce new warnings across the whole tree. Done when: the gate passes and the new clang version is recorded.

- [x] Record the clang version each llvm-mingw release carries, not just the release date. **Measured from the installed compilers, not from release notes:**

  | llvm-mingw | clang |
  | --- | --- |
  | `20251216`, outgoing | 21.1.8 |
  | `20260908`, incoming | **23.1.1** |

  **Two major versions of clang, which the date does not tell you.** That is the whole reason this item exists: `20251216` to `20260908` reads like nine months and is actually clang 21 to clang 23.
- [x] Bump Ninja to `1.13.2` alone, then run the full gate. Done 2026-09-17. Hash taken from a real download and cross-checked against GitHub's recorded digest, both `07fc8261b42b20e7...`, and the byte count matches at 291,570.

  **The bootstrap refused to replace it, which is `§1` working.** The first run reported `ninja is present but is not the pinned version, found 1.13.1, wanted 1.13.2` and stopped, naming `-Replace` as the flag. A silent replacement is what `§1` decided against, and this is the first time that decision was exercised by something other than its own test.
- [x] Bump CMake to `4.4.3` alone, then run the full gate. Done 2026-09-17, hash `4d52ebab7193a698...` matching GitHub's digest, 54,408,599 bytes.

  **No new policy warnings.** Two minor releases were the risk this item names, and a clean configure from a deleted `build/` produced zero matches for `policy`, `CMP[0-9]{4}`, `deprecat` or `Warning`. Recorded as a measurement rather than an absence of complaints: the configure log was searched, not glanced at.
- [x] Bump llvm-mingw to `20260908` alone, then run the full gate. Done 2026-09-17, hash `1bcf74d06b724aee...` matching GitHub's digest, 190,677,197 bytes.

  **Clang 21.1.8 to 23.1.1 produced ZERO new compiler warnings** across a full clean rebuild at `-Wall -Wextra -Werror`, both configurations. That is a better outcome than this item expected and it is worth not overstating: it says the tree is clean at the level `§3` set, not that two major versions changed nothing.
- [x] **Treat new compiler diagnostics as findings, not as noise to silence.** **Nothing was suppressed, because nothing needed to be: the compiler produced no new warnings.** No `-Wno-` was added anywhere and the warning level did not move.

  **The static analyser is the other half, and it moved a lot.** `clang-tidy` went 103 to **169**, and the increase is attributed exactly rather than waved at:

  | | findings | |
  | --- | ---: | --- |
  | `bugprone-signed-bitwise` | +49 | check is new in this clang-tidy |
  | `bugprone-unhandled-code-paths` | +12 | check is new in this clang-tidy |
  | `misc-use-internal-linkage` | +4 | existing check, widened |
  | `performance-faster-string-find` | +2 | check is new in this clang-tidy |
  | `bugprone-nondeterministic-pointer-iteration-order` | **-1** | see below |
  | | **+66** | |

  **Every pre-existing check reports an identical count**: 36 stayed 36, 16 stayed 16, 8 stayed 8, 4 stayed 4, and every single-finding check kept its one. Same code, same checks, same numbers, which is what makes this a stronger analyser rather than worse code. The baseline is raised to 169 in `todo/.tidy-baseline` with that accounting, not with a shrug.

  **The finding that disappeared is worth more than the sixty-six that arrived.** `bugprone-nondeterministic-pointer-iteration-order` fired at `src/main.cpp:382`, "sorting pointers is nondeterministic". The code is unchanged and the check still exists in clang-tidy 23; it simply no longer fires, and re-running that check alone on that file confirms zero. The sort compares **cell contents** and never a pointer value, so the order was always deterministic. **clang-tidy 21 was wrong and 23 is right.** A bump that retires a false positive is the return on currency this section exists to collect, and it is the one thing here that could not have been got by staying put.
- [x] Re-measure the binary size after the bump, against the recorded baseline. **Corrected 2026-09-17:** this said "the 1.39 MB figure `§2` records". `§2` records **2,512,384 bytes** as the baseline in those words; 1,423,872 bytes is the **pre-intake** `ExoSuite.exe` that figure replaced, and comparing a post-bump launcher to it would compare two different products. Done when: the new size is quoted against **2,512,384 bytes**, because a compiler change moves it and the per-tool size budget is measured against the shipped set.

  ```
  baseline (§2)   2,512,384
  after the bump  2,744,832      +232,448 bytes, +9.25%
  ```

  **Recorded, not explained away.** Clang 23 emits a larger binary for this tree than clang 21 did. The imports are unchanged, still no compiler runtime and no shipped DLL, so nothing started shipping alongside it; the executable itself grew. The per-tool budget is measured against the shipped set, so **2,744,832 bytes is the baseline from here**, and if a later section needs the 9 percent back, this is the line that says where it went.
- [x] Add `scripts/toolchain-latest.ps1`, which reports each pin against the upstream latest release and exits non-zero when any is behind. Done when: running it today reports all three as current, and artificially lowering one pin makes it exit non-zero naming that component, the pinned version, and the latest. **Extended 2026-09-17:** it must also distinguish **cannot reach the API** from **pin is behind**, with its own exit code, because reporting an unreachable network as a stale pin is the same defect `D00 T04 §5` fixed in the adjacency advisory: a message asserting something the check never established.

  **Three exit codes, each driven 2026-09-17:**

  ```
  all current        llvm-mingw 20260908 | cmake 4.4.3 | ninja 1.13.2     exit 0
  one behind         cmake is behind, pinned 4.0.0, latest 4.4.3          exit 1
  unreachable        could not reach upstream for llvm-mingw, cmake,
                     ninja. Currency is UNKNOWN, not current.             exit 2
  ```

  The unreachable case was driven by pointing the process at a dead proxy, not simulated. **Exit 2 is the one that matters**: a check reporting "current" because it reached nothing would be the sixth instance in this file of a check claiming success for work it never did, and `§5` was the fifth.

  > [!WARNING]
  > **The independent review found the mirror of that defect, and it was mine too. Corrected 2026-09-17.**
  >
  > Guarding against asserting what the check never established is half the job. The other half is not **throwing away what it did**. With one component unreachable and another confirmed behind, the early `exit 2` fired first and the confirmed finding was never printed: the combined gate showed only the generic unreachable line and the known stale pin vanished.
  >
  > Established facts are now reported before unknowns are, and the exit code still says 2, because overall currency really is unknown. Driven with `cmake` pointed at a nonexistent repository while `ninja` was pinned to `1.0.0`:
  >
  > ```
  > toolchain-latest: ninja is behind, pinned 1.0.0, latest 1.13.2
  > toolchain-latest: could not reach upstream for cmake. Currency is UNKNOWN, not current.
  > exit 2
  >
  > check-all: toolchain  unknown  upstream unreachable; currency not checked,
  >                                not current; ninja is behind, pinned 1.0.0,
  >                                latest 1.13.2
  > ```
  >
  > **The first attempt at that fix printed `unknown; System.Object[]`.** In PowerShell, `'x', (expr) -join '; '` joins across the comma rather than binding to the parenthesised expression, so the two-value assignment collapsed into one string. Caught by reading the output rather than by any check, which is the argument for reading it.
- [x] **Keep the check advisory, never automatic.** **Proven by search rather than asserted:** `toolchain.json` is referenced four times in `scripts/toolchain-latest.ps1`, at `Test-Path`, in an error message, and at `Get-Content`. There are **zero** `Set-Content`, `Out-File` or `ConvertTo-Json` calls in the file. There is no write path.

  The reason is recorded in the script's own header, where somebody about to add one will read it: an unattended bump of a compiler can break a build nobody is watching, and the reproducibility a pin buys is worth more than being current by a few days. This section is what the decision to move a pin looks like written down, and it took three separate gate runs to make.
- [x] Decide the re-evaluation cadence and record it as a dated default.

  **Dated default, 2026-09-17: the check runs on every `check-all.ps1` invocation, and a pin is re-evaluated at each phase boundary.**

  **Who runs it: whoever pushes.** Not a person with a calendar reminder, because that is the arrangement that produced the nine-month gap this section opens with. The check is in the gate a push already owes, so falling behind becomes visible on the next push rather than the next time somebody thinks to look.

  **Cadence for acting, as opposed to noticing:** a phase boundary. Between them the advisory accumulates and is ignored on purpose, because bumping a compiler mid-phase drops a new diagnostic into unrelated work where it cannot be attributed.

  **Cost of changing:** low. The cadence is one sentence here and one advisory gate in `check-all.ps1`. Making it stricter costs a failing gate instead of a warning line; making it looser costs exactly what this section was written to repair.
- [x] Wire the check into the combined gate as a **warning, not a failure**. Done when: a pin that has fallen behind prints a named advisory line in `scripts/check-all.ps1` output and does not fail the build, **and a machine with no network prints that it could not check rather than that the pins are current**. `§1`'s bootstrap works offline once `reskit/` is populated and `§5`'s gate is valuable precisely because it can always be run; a gate that silently reports "current" when it reached nothing would be the fifth instance of a check reporting success while doing nothing, which `§5` was the fourth.

  **Driven 2026-09-17 with a pin artificially lowered:**

  ```
  toolchain   behind   0.9s   ninja is behind, pinned 1.0.0, latest 1.13.2
  ```

  The row is yellow, `Failed` is false, and the build is not stopped. **The run did exit 1, and not because of this gate**: lowering the pin broke the `1.13.2` claim on `toolchain.json`, so the claims gate failed. Two checks doing their jobs, and worth recording that `toolchain.json` cannot be quietly edited even to test something, because a claim is watching it.
- [x] Record what this section cannot promise.

  **Being current is not being correct.** A newer compiler can regress, can emit a worse binary, or can be wrong in a new way. This bump gives direct evidence in both directions: clang-tidy 23 **retired a false positive** clang-tidy 21 reported, and the same bump made the launcher **9.25 percent larger**. Neither was predictable from a version number, and a policy of "always take the latest" would have taken both without noticing either.

  **What the pin buys is that a regression is one file away from being undone.** Reverting `toolchain.json` to `20251216`, `4.2.3`, `1.13.1` and running `bootstrap.ps1 -Replace` restores the previous toolchain exactly, because every entry carries its own SHA-256. That is why this section bumps pins rather than removing them.

  **What is not proven here:** that `20260908` is better for this tree in ways the gate cannot see. The gate proves it builds, produces no new compiler warnings, leaves every pre-existing analyser check unchanged, and yields a binary that runs. It does not prove the generated code is faster, smaller elsewhere, or more correct at runtime, and nothing in this section should be read as saying so.
- [x] Commit: `"workspace: bring the toolchain pins current and report when they fall behind"`

<!-- claim: exists scripts/toolchain-latest.ps1 -->
<!-- claim: count "Set-Content" scripts/toolchain-latest.ps1 = 0 -->
<!-- claim: count "clang 23" toolchain.json = 0 -->

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
- [ ] `pwsh scripts/build.ps1 -All` builds every defined target. **Corrected 2026-09-17:** this read "for both architectures", which contradicts `§1`'s recorded default that x86-64 is the only architecture built
- [ ] `pwsh scripts/check-all.ps1` exits 0 on a clean tree
- [ ] A fresh clone into a different absolute path builds with no file edited
- [ ] Bootstrap and build succeed on a machine with no Visual Studio and no Windows SDK installed
- [ ] No absolute path appears in any build file, and no `.sln` or `.vcxproj` is committed
- [ ] `python scripts/todo-graph.py validate` clean
