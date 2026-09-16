# Completion Brainstorm -- 2026-09-16

Living capture for the "complete Resolute in full" brainstorm.
Raw findings and candidate work land here first, then route through `add-todo` once decided.
Nothing here is a commitment until it has a TODO section and a row in the plan.

## The operator's framing

- `ComIntRep` (Complete Internet Repair) is the maturity benchmark. Every other tool comes up to its standard.
- `Firemin` and `USBRepair` are the other two mature, near-complete tools.
- Consistency is the headline ask: update files, translations, About pages, docs, and everything else that should look the same across fourteen tools.
- Completeness is the second ask: no half-wired surface, no tool missing a thing every other tool has.
- New programs from `samples/` join the suite, Complete Windows Repair first.
- New features and new utilities are wanted on top.

## Measured state, 2026-09-16

Verified by reading the tree on this date. Re-read before acting on any figure.

### The conformance matrix

| Tool | Lines | Logging | Docs files | Lang packs | Settings ext | `.sni` |
| --- | ---: | :---: | ---: | ---: | :---: | :---: |
| ComIntRep | 3459 | yes | 3 | 16 | `.lng` (wrong) | yes |
| Distro | 3507 | yes | 0 | 0 | `.ini` | **none** |
| Resolute | 2663 | yes | 3 | 1 | `.lng` (wrong) | yes |
| MemBoost | 2625 | **no** | 0 | 1 | `.ini` | yes |
| BiosCodes | 2516 | **no** | 4 | 3 | `.ini` | yes |
| Firemin | 2389 | **no** | 3 | 35 | `.ini` | yes |
| Chromin | 2389 | **no** | 4 | 0 | `.ini` | yes |
| Edgemin | 2389 | **no** | 0 | 0 | `.ini` | yes |
| Watermin | 2389 | **no** | 0 | 0 | `.ini` | yes |
| PixRepair | 1897 | yes | 3 | 2 | `.lng` (wrong) | yes |
| DVDRepair | 1830 | yes | 3 | 10 | `.lng` (wrong) | yes |
| USBRepair | 1703 | yes | 3 | 8 | `.lng` (wrong) | yes |
| Ownership | 1633 | yes | 3 | 1 | `.lng` (wrong) | yes |
| ReBar | 1556 | yes | 3 | 2 | `.lng` (wrong) | yes |

Every tool consumes `About.au3`, `Update.au3`, and a `Localization.au3`. Those three are already uniform.

### What the benchmark actually is

`ComIntRep` is the standard on surface completeness, not on every axis.
It carries sixteen language packs, the full documentation set, logging, splash, registry and file helpers, and a real result list.
It also carries the `.lng` settings defect, so "the ComIntRep standard" must be written down as a profile rather than defined as "whatever ComIntRep does".

### Defects found while measuring

- **Build is broken from a clean checkout.** Every `.sni` hardcodes `R:\Workspace\Resolute\...`, and the repository lives at `R:\conclave\projects\Resolute`. Owned by `D00 T01 §4`.
- **Seven tools store settings in a `.lng` file**, the suite's language-pack extension: `ComIntRep`, `DVDRepair`, `Ownership`, `PixRepair`, `ReBar`, `USBRepair`, and the `Resolute` launcher.
- **Six tools write no log at all**: `BiosCodes`, `Firemin`, `Chromin`, `Edgemin`, `Watermin`, `MemBoost`.
- **Four tools have no documentation directory**: `Edgemin`, `Watermin`, `MemBoost`, `Distro`.
- **Five tools have no language pack**: `Chromin`, `Edgemin`, `Watermin`, plus `Distro`; `MemBoost`, `Ownership`, and `Resolute` have English only.
- **Language file naming is inconsistent**: `DVDRepair` ships `zh-tw` where everyone else ships `zh-TW`; `USBRepair` ships `sv.ini` where every other pack is `.lng`.
- **`Distro` builds every tool but itself**: no `.sni`, no docs, no language pack.
- **`SDK/Concrete/Rescue/` still exists** carrying only a `Distribution/338/` build output with no source, after the tool was removed.
- **`Compress`, `Sign`, and `SignInstall` are `0` in all thirteen `.sni` files.** Nothing ships signed today.
- The `.sni` build number is always exactly one behind the `.au3`. This is the auto-increment convention, not drift. `D06 T01 §5` must encode it rather than "fix" it.

### Update mechanism, as built

Each tool derives `$g_sRemoteUpdateFile` as `<UpdateServer>/<ShortName>.ruz` on a beta build and `<ShortName>.ru` on a release build.
`Update.au3` is shared and uniform. What does not exist anywhere in the tree is the generator that produces those `.ru` / `.ruz` files at release time.

## Candidate additions in `samples/`

### Tracked and on disk

| Candidate | Source | Lines | Version | Note |
| --- | --- | ---: | --- | --- |
| **Complete Windows Repair** | `samples/ComWinRep/WinRepair.au3` | 2028 | 1.0.0.339 | Has its own `.sni`, `Docs/`, `Themes/`, `Distribution/`. The flagship addition. |
| QuickErase | `samples/QuickErase/QuickErace.au3` | 723 | 0.4.2.421 | Secure file deletion. Filename is misspelled in the sample. |
| UUIDGen | `samples/UUIDGen/UUIDGen.au3` | 209 | 0.2.6.276 | UUID generator. Smallest possible intake pilot. |
| Indicators | `samples/Indicators/Indicators.au3` | 349 | 0.0.8.81 | On-screen indicator utility. |

`samples/Resources/` holds shared art assets and is not a tool.

### Removed in commit `8d7469a`, recoverable

Restore with `git checkout 8d7469a^ -- "<path>"`.

| Candidate | Source | Note |
| --- | --- | --- |
| WinClean | `samples/WinClean/EvBeGone.au3` plus `UDF/SecureDelete.au3`, `UDF/Services.au3` | Cleanup tool; overlaps QuickErase on secure delete. |
| SaveDesk | `samples/SaveDesk/` | Desktop icon layout save and restore. |
| WinPower | `samples/WinPower 0.0.3.325922/WinPower.au3` plus `Modules/` | Administration and control-panel launcher. |
| FixWin 10.0.1.0 | `samples/FixWin 10.0.1.0/` | Binary reference only, no AutoIt source. |
| IconExtractor | `samples/IconExtractor-1.0-beta1/` | Binary reference only, no AutoIt source. |

## Open decisions

Each one changes the shape of the TODO tree. Recorded here before it is answered so the answer has a home.

1. **Sequencing.** Do new tools enter before, during, or after the existing fourteen reach conformance?
2. **Intake set.** Which of the seven candidates become products, and which stay samples?
3. **Translation strategy.** Thirty-five packs for Firemin against zero for three browser tools is the widest gap in the suite. Shared string pool, or per-tool packs?
4. **Versioning.** `Resolute` is at 23.2, the tools at 11.x and 12.x, the candidates at 0.x and 1.x. Converge or keep the spread and write the rule?
5. **Signing.** Signing is off in every descriptor. Is a certificate available, and does the first conformant release ship signed?
6. **Update manifests.** Who generates `<ShortName>.ru` and `.ruz`, and is that part of the release command?

## Decisions taken, 2026-09-16

Answered by the operator during the brainstorm. These are settled unless revisited.

1. **Sequencing: profile first, then intake.** The conformance profile is written and the Phase 0 gates land before any sample becomes a product. Each new tool arrives already conformant through a repeatable intake contract, so no new tool ever joins the cleanup backlog.
2. **Intake set:** Complete Windows Repair, QuickErase, UUIDGen, Indicators, WinClean, SaveDesk. `WinPower` is **not** taken in as a tool: the `Resolute` launcher is its replacement, and the importable WinPower features move into the launcher instead.
3. **Translations: shared common pool.** Menu, About, Update, and common dialog strings are translated once for the suite; per-tool packs carry only tool-specific keys.
4. **Versioning: keep the spread, write the rule.** Per-tool versions stay independent. `D06 T01 §5` documents the scheme and the `.sni` build auto-increment convention.

### Consequences of decision 1

`D07 T01 §1` ("The bar: what done means for a tool") currently sits in Phase 3. Under this decision it becomes an early dependency of everything, because the profile is what tools conform to and what intake measures against. Moving it needs a `groom-plan` pass rather than a hand edit.

### Consequences of decision 2

- `WinClean` is a real port: `EvBeGone.au3` (582 lines) plus `UDF/Services.au3` (249), `UDF/Resources.au3` (297), `UDF/SecureDelete.au3`, `UDF/Utilities.au3`.
- `SaveDesk` is **not** a port. `samples/SaveDesk/` holds only a `[Research]/` directory of third-party ICU material with no Rizonesoft source. It is new development against a researched concept, and it is the only intake candidate that is.
- `WinPower` yields three importable things, listed under "WinPower import" below.
- `samples/WinClean/UDF/Services.au3` is a service-control UDF (`_SvcStart`, `_SvcStop`, `_SvcPause`, `_SvcResume`, `_SvcSetStartMode`, `_SvcGetStartMode`, `_SvcGetDisplayName`). Nothing in `SDK/Includes/` does this today, and Complete Windows Repair will need it. It is a shared include, not a WinClean private.

## Correction: ReBar is the framework, and the plan has it wrong

Operator note, 2026-09-16: "I did attempt to create a Framework (ReBar) that should also be updated."
Verified against the source, and it changes the shape of this whole effort.

`SDK/Concrete/ReBar/ReBar.au3:32` declares `#AutoIt3Wrapper_Res_Description=ReBar Framework`.
It carries `Templates/Changes.tpl`, `License.tpl`, and `Readme.tpl`: the documentation set every tool owes.
It contains **no registry backup or restore logic at all**; the only match for "restore" in the file is `Opt("SendCapslockMode", 1)`.

### The seeded plan is factually wrong about it

- `D03 T01 §2` is titled "ReBar registry backup, restore, and refusal" and specifies a golden backup fixture, a round-trip assertion, and a corrupt-backup refusal. None of that behavior exists, and none of it belongs in a framework.
- `TODO-01 -- System Tool Repairs` lists `ReBar` among "the seven tools that change a user's system" and freezes it. `ReBar` changes nothing on a user's system. The frozen set is six tools, not seven.
- The adjacency block anchors `reverse` and `exchange` on `D03 T01 §2`, so those keys need re-anchoring once the section is corrected.

This is drift in the seeded tree, not a defect in the code, and it must be repaired through `groom-plan` before any Phase 2 work is planned against it.

## The measurement that reframes everything

`ReBar` is a **copy-paste template, not a library.** Every tool carries its own copy of the framework.

All fourteen tools privately define `_SetWorkingDirectories`, `_GenerateIniFile`, `_LoadConfiguration`, and `_SaveConfiguration`. Thirteen also privately define `_ShowPreferencesDlg` and `_SetProcessPriority`. Thirteen carry a private `Includes/Localization.au3` of 122 to 491 lines.

Subtracting the 1,556-line framework that `ReBar` is, the actual product logic per tool is:

| Tool | Main script | Framework | Product logic |
| --- | ---: | ---: | ---: |
| ReBar | 1556 | 1556 | 0 (it is the framework) |
| Ownership | 1633 | ~1556 | **~77** |
| USBRepair | 1703 | ~1556 | ~147 |
| DVDRepair | 1830 | ~1556 | ~274 |
| PixRepair | 1897 | ~1556 | ~341 |
| BiosCodes | 2516 | ~1556 | ~960 |
| ComIntRep | 3459 | ~1556 | ~1903 |

Roughly **1,500 lines times fourteen tools, near 21,000 lines**, out of about 43,000 in the repository, is fourteen copies of one framework.
That is the reason the suite drifted: seven tools got `.lng` and seven got `.ini` because the settings path is written out fourteen separate times.

### The consequence

Every consistency item the operator asked for falls out of one change: **promote `ReBar` from a template that is copied into a shared include that is consumed.**

- Settings path is corrected once, not in seven files.
- Logging is added once, not to six tools.
- The About page, the update check, the preferences dialog, the language list, and the process priority surface become one implementation each.
- A new tool is the framework include plus its own logic, which is what makes the intake contract cheap.
- Standalone distribution is preserved, because AutoIt resolves includes at compile time and each `.exe` still carries its own copy.

This subsumes much of Phase 1 as currently written. `D01 T01 §3` (settings), `§4` (logging), `§5` (localization), `§6` (update), and `§7` (elevation) are five contracts over what is really one framework, and they should be re-planned as one extraction with the contracts as its acceptance criteria.

`ComIntRep` remains the benchmark for what a *repair tool* looks like on top of the framework, which is the shared repair contract from decision 5. The two layers are: `ReBar` framework for every tool, repair contract for the repair tools.

## Standing constraint: every tool ships standalone

Stated by the operator, 2026-09-16. This governs every consistency decision in this document.

Each tool is distributed independently, exactly as it is today: its own download, its own update file, its own language packs, its own `Docs/` set, its own About page.
A tool is never allowed to depend on another tool, on the launcher, or on a suite-wide file being present on disk at runtime.
"Shared" in this document therefore always means **shared at author time and at build time**, never shared at runtime.

### What this changes

- **The shared common language pool is a build-time merge, not a runtime lookup.** The pool is authored once under the SDK. `Distro` composes each tool's shipped `<lang>.lng` by merging the common keys with that tool's own keys, so what lands in a user's folder is one complete self-contained pack per tool. Translate once, ship standalone. A runtime `Resolute/Language/Common/` would break the standalone rule and is rejected.
- **The shared repair contract is an `#include`.** AutoIt resolves includes at compile time, so a shared core costs nothing at distribution: each `.exe` carries its own copy. No runtime dependency is created.
- **Every tool keeps its own `.ru` / `.ruz` update file** at `<UpdateServer>/<ShortName>.<ext>`. The release procedure generates one per tool, not one for the suite.
- **Every tool keeps its own `Docs/<Tool>/` set and its own About page.** The conformance profile requires these per tool; it never centralizes them.
- **The conformance check must verify standalone-ness**, not only presence: a built tool placed in an empty directory with only its own files must start, localize, show About, and check for updates.

## Decisions taken, round 2

5. **A shared repair contract is adopted.** One SDK include owning the result list, transcript export, restore record, undo, and logging, consumed by every repair tool. It is an include, so it does not compromise standalone distribution.
6. **Two consolidations are approved.**
   - The four browser optimizers ship as **one tool with a browser picker**. `Firemin` is the surviving brand.
   - `USBRepair` and `DVDRepair` merge into one **Drive Repair** tool.
   - `QuickErase` and `WinClean` stay separate products.
7. **Signing already happens outside the repository.** The existing procedure is documented rather than replaced, and `Sign = 0` in the descriptors is explained rather than flipped. `D06 T01 §3` becomes a documentation and verification task.
8. **The conformance profile moves to Phase 0.** `D07 T01 §1` and `D07 T01 §4` are pulled early through `groom-plan`, because the profile defines what every later section conforms to and what intake measures against.

### Open consequence of decision 6

Consolidation retires `Chromin`, `Edgemin`, `Watermin`, and `DVDRepair` as separately distributed products.
Each of those has a live update file (`Chromin.ru` and so on) that existing installations poll.
The release procedure owes a migration answer: what an installed `Chromin` sees when it next checks for updates. Unresolved; needs a decision before the consolidation ships.

## Decisions taken, round 3

9. **`ReBar` is promoted from copy-paste template to a shared SDK include.** Every tool becomes the framework include plus its own logic. This is the load-bearing decision of the whole effort and it subsumes most of Phase 1 as currently written.
10. **`D03 T01 §2` is rewritten as framework work.** The registry-backup section is deleted, `ReBar` leaves the frozen set (six tools, not seven), the `reverse` and `exchange` adjacency keys are re-anchored, and the extraction gets its own file.
11. **`ReBar` is internal tooling, not a product.** No download page, no translations, no update file, no documentation set owed. It leaves the product count. Its `$g_sUrlProgPage` currently points at `downloads/resolute/` and that is now a defect to clear rather than a page to fill.

### Product count after decisions 6 and 11

Starting from fourteen concrete tools:

- `ReBar` becomes internal: **-1**
- `Chromin`, `Edgemin`, `Watermin` fold into `Firemin`: **-3**
- `DVDRepair` folds into `USBRepair` as **Drive Repair**: **-1**
- `Distro` is the builder, internal by nature: **-1**

That leaves **eight shipped products**: `Resolute` (launcher), `Firemin`, `ComIntRep`, `Drive Repair`, `MemBoost`, `BiosCodes`, `Ownership`, `PixRepair`.

Intake adds **six**: Complete Windows Repair, QuickErase, WinClean, SaveDesk, UUIDGen, Indicators.

**Fourteen shipped products at the end**, against fourteen concrete tools today, with every one of them conformant and roughly 21,000 lines of duplication gone. The suite gets more capable without getting wider.

### The two shared layers

| Layer | Scope | Owns |
| --- | --- | --- |
| `ReBar` framework include | every tool, all fourteen | startup, working directories, `.ini` generation, configuration load and save, preferences dialog, language list, update check, logging surface, process priority, About, shutdown |
| Repair contract include | the repair tools only | diagnose pass, result list with per-item status, transcript export, restore record, undo, one log line per action |

`ComIntRep` is the reference implementation of the second layer. `ReBar` is the reference implementation of the first.

## Decisions taken, round 4

12. **A retired product keeps its own update file and announces the consolidation.** `Chromin.ru`, `Edgemin.ru`, `Watermin.ru`, and `DVDRepair.ru` stay live. Each serves a final update notification that says the product has been consolidated and points at its successor. Installed copies keep working and get told where to go, rather than going silent.

### What decision 12 needs from the update mechanism

The `.ru` file is an INI read by `SDK/Includes/Update.au3:93,98`, with `[Update]` carrying `LatestBuild` and `UpdateURL`.
The redirect half is already expressible today: raise `LatestBuild` above any shipped build and set `UpdateURL` to the successor's page.
What does not exist is the wording. The dialog text comes from the tool's own language pack, not from the server, so nothing in the current format can say "consolidated".

**Design, for the framework extraction to implement:** add an optional `Successor` key to `[Update]` carrying only the successor's display name, and a matching template string in the language packs along the lines of `%s is now part of %s`.
The server supplies the name; the pack supplies the sentence.
This keeps translation in the packs where it belongs, so the announcement arrives in the user's language rather than in English from a server.
A free-text `Message` key from the server was considered and rejected for exactly that reason.

Unknown keys are ignored by the current `IniRead` calls, so the change is backward compatible with every shipped build.

**The capability generalizes.** Once the update file can carry a templated announcement, every tool has a server-side channel for "this build has a known issue" or "this version is end of support", without shipping a new binary. Worth designing for deliberately rather than discovering later.

## Two more consistency findings, 2026-09-16

### High DPI is off on all fourteen tools

Every script carries `#AutoIt3Wrapper_Res_HiDpi=N`.
On the high-resolution displays most laptops now ship with, Windows bitmap-scales these windows, so the whole suite renders soft while the rest of the desktop is sharp. It is the most visible quality gap in the product and it is invisible on a development machine at 100 percent scaling.

**This is not a one-line flip.** AutoIt GUIs built on absolute pixel coordinates re-lay-out incorrectly when the process becomes DPI-aware. Turning it on means auditing coordinate math per window. The honest sequencing is: the framework extraction makes the shared surfaces DPI-correct once, and each tool's own window is then a much smaller audit.

### Copyright years span 2022 to 2025

`Distro` 2022; `ComIntRep`, `DVDRepair`, `MemBoost`, `Ownership`, `PixRepair`, `ReBar`, `Resolute`, `USBRepair` 2023; `BiosCodes` 2024; `Chromin`, `Edgemin`, `Firemin`, `Watermin` 2025.
A copyright year that is typed by hand into fourteen scripts will always be wrong in some of them. It should be generated at build time by `Distro`, not maintained.

`Res_Language=2057` (English, United Kingdom) is at least consistent across all fourteen.

## Open question: what is a tool's on-disk layout when distributed standalone?

Raised by the `samples/ComWinRep/` intake, and it matters because of the standing standalone constraint.

Complete Windows Repair uses a `Doors/` runtime directory holding `Cache/`, `Language/`, `Logging/`, `Themes/`, and its `.ini`: one tool, one folder, everything it needs beside the executable.

The shipped suite instead puts `Language/<Tool>/`, `Logging/`, and `Docs/<Tool>/` at a shared `Resolute/` root, which is natural for a suite install and awkward for a tool distributed on its own.

The two models need reconciling before the conformance profile is written, because the profile has to assert where a standalone tool finds its own files. Unresolved.

## WinPower import

`samples/WinPower 0.0.3.325922/` restored from `8d7469a^`. 349 lines plus two small modules.

| What | Source | Destination |
| --- | --- | --- |
| Shell CLSID launcher (God Mode, Action Center, Backup and Restore, Biometric Devices) | `Modules/mControlPanel.au3`, `Modules/mAdministration.au3` | `Resolute` launcher, as a curated Windows system locations surface |
| The CLSID catalog, 151 entries | `samples/!CLSID Shortcuts/` at `8d7469a^` | Data for the launcher surface above; restore from history when the section is built |
| `_RepairFontRegistrations`, `_ResetTcpipAll`, `_RebuildWMI` | `WinPower.au3:229,242,258` | Complete Windows Repair; `_ResetTcpipAll` overlaps `ComIntRep` and must not become a second implementation |

## Candidate work, not yet routed

Held here until a decision turns it into a section.

- A written **tool conformance profile**: the checklist a tool must satisfy to be called done, derived from `ComIntRep` plus the defects it does not cover. Likely home: `D07 T01 §1`.
- A **conformance check** that runs the profile against every tool and fails by name. Likely home: `D07 T01 §4`.
- A **new-tool intake contract**: the repeatable procedure that brings a `samples/` program into `SDK/Concrete/` already conformant, so it never joins the backlog. Likely a new file under a new domain.
- A **shared common language pool** so menu, About, Update, and dialog strings are translated once for the suite rather than fourteen times.
- A **release update-manifest generator** producing `.ru` and `.ruz`.
- Naming and casing hygiene pass across language packs.
- Remove or restore `SDK/Concrete/Rescue/`.
- Give `Distro` the `.sni`, docs, and pack every other tool has.

## Restructure worklist

What the decisions above oblige the TODO tree to become. Nothing here is authored yet.
Ordered by dependency: each item needs the ones above it.

### A. New files to author through `create-todo`

1. **`todo/01-sdk-core/TODO-02-rebar-framework.md`** -- the framework extraction. Promote `ReBar` from copy-paste template to `SDK/Includes/`. Acceptance criteria are the five contracts currently spread across `D01 T01 §3`-`§7`: settings, logging, localization, update, elevation. Proves standalone distribution survives the change.
2. **`todo/01-sdk-core/TODO-03-repair-contract.md`** -- the Diagnose, Report, Repair, Verify, Undo contract. `ComIntRep` is the reference implementation. Owns the result list, transcript export, restore record, undo, and the registry backup capability that the deleted `D03 T01 §2` was reaching for.
3. **`todo/09-tool-intake/TODO-01-intake-contract.md`** -- the repeatable procedure that brings a `samples/` program into `SDK/Concrete/` already conformant. `UUIDGen` at 209 lines is the pilot that proves it.
4. **`todo/09-tool-intake/TODO-02-…`** onward -- one file or section per intake: Complete Windows Repair, QuickErase, WinClean, SaveDesk, UUIDGen, Indicators.

### B. Files needing re-authoring, not editing

5. **`todo/03-system-tools/TODO-01`** -- more than half its sections change. `ReBar` leaves, the frozen set drops to six, `§2` goes, `§5` becomes Drive Repair, and `§1` is largely subsumed by the framework extraction. Carries a `[!CAUTION]` banner until this lands.
6. **`todo/04-browser-tools/TODO-01`** -- the target is now **one tool with a browser picker**, not four thin tools on a shared core. `§3` and `§4` collapse; `§6` (language packs for three tools) mostly evaporates; a migration section is owed for the retired `Chromin`, `Edgemin`, and `Watermin` update files.

### C. Files needing targeted correction

7. **`todo/01-sdk-core/TODO-01`** -- `§3` through `§7` become acceptance criteria of the framework extraction rather than five parallel contracts. Re-point, do not delete.
8. **`todo/07-quality/TODO-01`** -- `§1` (the bar) and `§4` (conformance check) move to Phase 0 per decision 8. The profile must also assert **standalone-ness**: a built tool in an empty directory with only its own files starts, localizes, shows About, and checks for updates.
9. **`todo/06-distro-release/TODO-01`** -- `§3` becomes "document and verify the existing external signing procedure" rather than "build signing". Add the update-manifest generator producing `.ru` and `.ruz` per tool. Add the migration answer for retired products' update files.
10. **`todo/08-docs-localization/TODO-01`** -- the shared language pool is a **build-time merge owned by `Distro`**, not a runtime shared file. Add the language-pack hygiene pass: `zh-tw` to `zh-TW` in `DVDRepair`, `sv.ini` to `sv.lng` in `USBRepair`.
11. **`todo/02-launcher/TODO-01`** -- add the WinPower import: the Windows system locations surface built from the 151-entry CLSID catalog at `8d7469a^`.
12. **`todo/00-workspace/TODO-01`** -- `§4` (repository-relative `.sni` paths) is the one section that blocks literally everything, because no tool builds from a clean checkout today. Note that `ReBar`'s `#AutoIt3Wrapper_OutFile` directives are already relative and are the model to copy.

### D. Housekeeping, needs a home

13. Delete `SDK/Concrete/Rescue/`, which holds only a `Distribution/338/` build output with no source.
14. Give `Distro` the `.sni`, documentation set, and language pack every other tool has. The builder currently builds everything but itself.
15. Clear `ReBar`'s `$g_sUrlProgPage`, which points at `downloads/resolute/` for a tool that is no longer a product.
16. Delete `SDK/Concrete/BiosCodes/Includes/Localization.au3.backup`.
17. Rename `samples/QuickErase/QuickErace.au3` on intake.

### E. Deferred question

18. **Migration for retired products.** `Chromin`, `Edgemin`, `Watermin`, and `DVDRepair` have live update files that installed copies poll. What those installations see when the products retire is unanswered and blocks the consolidation shipping.

## New feature and utility ideas

Recommended during the brainstorm, none committed.

### Per-tool features

- **`ComIntRep`**: a diagnose pass that tests DNS resolution, TCP connect, proxy, and TLS, then pre-selects only the repairs that apply, instead of presenting a checklist the user guesses from. Before and after network state diff. Restore point before a run.
- **`Firemin`**: measured effect over time rather than the instantaneous drop, per-process rules, an exclusion list, and a threshold trigger so trimming becomes a policy instead of a hammer.
- **Drive Repair**: a diagnose and report mode enumerating devices with their Device Manager error codes before repairing. Write-protection removal, drive-letter conflict resolution, stuck safe-removal.
- **`Resolute` launcher**: the WinPower system locations surface, suite-wide settings the tools inherit, one update-all surface, and the shared log viewer.

### Candidate new utilities

Ranked by demand against risk.

1. **Startup Manager** -- what runs at boot, with enable, disable, and undo. Perennial demand, low risk.
2. **Service Manager** -- `samples/WinClean/UDF/Services.au3` already provides the primitives.
3. **Context Menu Editor** -- popular, self-contained, reversible.
4. **Windows Update Reset** -- `windows-10-update-reset.bat`, `windows-11-update-reset.bat`, and `WMI.bat` exist at `8d7469a^` and are ready-made source for Complete Windows Repair rather than a separate tool.
5. **Hosts File Editor** -- small, pairs naturally with `ComIntRep`.
6. **Disk Space Analyzer** -- high demand, much larger build than the rest of this list.

**Not recommended:** a registry cleaner. The whole category has a poor reputation and it would sit badly beside tools whose pitch is that they can undo everything.
