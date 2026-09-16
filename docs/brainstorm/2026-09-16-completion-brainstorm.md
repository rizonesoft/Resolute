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
---

# PIVOT: rewrite in C++

Taken 2026-09-16, after the findings above. Everything recorded before this point was written against the AutoIt suite. The product decisions survive the pivot; the AutoIt-specific mechanics do not.

## Decisions taken, round 5

13. **Resolute is rewritten in C++.** Target C++23 on MSVC 2022, built with CMake and vcpkg.
14. **UI toolkit is wxWidgets, statically linked.** Chosen over WinUI 3, Qt 6, and raw Win32.
15. **The clone is 1:1 on behavior, not on pixels.** Identical effects on the system, verified by diffing against the AutoIt build on the same fixture. The UI is rebuilt to the conformance profile with DPI and dark mode corrected.
16. **Migration is framework first, then all tools.** The framework is built and hardened before the tools port.
17. **One repository, two trees.** `resolute_au3/` holds the frozen AutoIt suite as the executable specification; the C++ tree sits beside it; one `todo/` covers both.

## Why wxWidgets and not WinUI 3

Measured UI inventory across the whole suite: 281 labels, 180 groups, 135 icons, 97 tab items, 92 checkboxes, 79 buttons, 28 combos, 22 listviews, 17 inputs. There is no custom rendering and no animation anywhere. This is a Win32 dialog application, and WinUI 3 exists to solve problems this suite does not have.

Against that, WinUI 3 costs four things that matter here:

1. **It breaks the standalone constraint.** Framework-dependent deployment needs the Windows App SDK runtime installed; self-contained ships roughly 40 to 60 MB per tool. Current executables are 1 to 2 MB and independently distributed. `UUIDGen` is 209 lines of AutoIt.
2. **Elevation.** Every tool here needs administrator rights. Unpackaged WinUI 3 can elevate but has a poor history of it; packaged MSIX effectively cannot.
3. **MSIX container semantics fight system repair**, which is the entire product.
4. **C++/WinRT is the second-class path.** Microsoft's WinUI 3 investment is C#-first.

wxWidgets wins on the decisive point: the wxWindows Licence carries an explicit static-linking exception, so a single self-contained executable ships with no source obligation. Native Win32 controls underneath, per-monitor DPI in 3.2+, Windows dark mode in 3.3, 5 to 12 MB per tool, trivial elevation.

Qt 6 has the better tooling, and Qt Linguist would suit 35 language packs well, but LGPLv3 forces either dynamic linking (roughly 30 MB of DLLs beside every independently distributed tool) or a commercial licence.

Raw Win32 remains the purist option and is viable precisely because the framework is written once. It was not chosen because dark mode and DPI would both be hand-built.

## What the framework discovery does to the estimate

The port is **not** 43,000 lines of AutoIt.

Roughly 21,000 of those lines are fourteen copies of `ReBar`. The unique logic is about 22,000 lines, and the framework inside it is 1,556 lines written once. Per tool, the real logic is: `Ownership` ~77, `USBRepair` ~147, `DVDRepair` ~274, `PixRepair` ~341, `BiosCodes` ~960, `ComIntRep` ~1,903.

So the work is one framework plus fourteen small bodies of logic. Estimate: 5,000 to 8,000 lines of C++ for the framework, 40,000 to 60,000 for the suite.

## Risk carried by decision 16

Framework-first means no migrated tool reaches users until late, and two codebases run in parallel meanwhile. The named mitigation is a **vertical slice**: the framework is proven end to end through one real tool before the remaining thirteen are ported. `Ownership`, at roughly 77 lines of real logic, is the cheapest candidate; `UUIDGen` is cheaper still but is not an existing product.

The AutoIt suite stays shippable throughout. It needs a maintenance owner in the plan, not a freeze.

## What survives the pivot

Product decisions, unchanged:

- The conformance profile, and that it must assert standalone-ness.
- The two-layer architecture: framework for every tool, repair contract for the repair tools.
- Both consolidations: four browser tools into one, `USBRepair` plus `DVDRepair` into Drive Repair.
- `ReBar` internal, `Distro` internal, fourteen shipped products.
- The intake list, and that `SaveDesk` is new development rather than a port.
- The consolidation announcement design: `Successor` key plus a language-pack template.
- Build-time language composition, per-tool update files, the `Doors/` layout question.
- Every feature and utility recommendation.
- High DPI and dark mode, which stop being retrofits and become requirements of the new framework.

What dies: `Au3Check` gates, `.sni` portability, the `.lng` settings repair, `Au3Stripper`, and the browser-tool source consolidation as a source problem. Those evaporate rather than needing doing.

## Repository layout after the move

Commits `2c125ff` and `71caa37`.

```
resolute_au3/      the frozen AutoIt suite: SDK/, Resolute/, samples/
src/               the C++ tree (not yet created)
todo/              one execution plan covering both
scripts/           todo-graph.py and friends, language-agnostic, kept
docs/              captures, brainstorm, reviews
```

The ignore patterns were anchored to the old root and had to be unanchored; the move otherwise swept 368 build artifacts into the repository. The `Samples/` ignore rule was dropped because it never matched: the directory is lowercase and the pattern was not, so `samples/` has always been tracked. It stays tracked, as the intake source.

`resolute_au3/samples/Resources/` (180 files) has never been tracked and still is not. Decide whether it should be.


## Decisions taken, round 6

18. **The toolchain is repository-scoped, built on `clang-cl`.** LLVM, CMake, Ninja, and vcpkg are downloaded into a gitignored `.toolchain/` against recorded hashes. A bare Windows machine with no Visual Studio bootstraps and builds.
19. **The build is IDE-agnostic.** CMake presets are the source of truth; no `.sln` or `.vcxproj` is committed. Visual Studio, VS Code, and a bare terminal drive the same presets.
20. **The minimum supported Windows is 10 1809.** This was already implied by choosing dark mode and per-monitor DPI v2, and is now recorded rather than discovered.
21. **The Windows SDK pins to the latest stable**, with the runtime floor set separately through `WINVER`, `_WIN32_WINNT`, and the manifest. A build check prevents an above-floor API shipping silently.
22. **Bootstrap detects before it downloads**, and detects the *pinned* version specifically. A machine carrying a different SDK version does not silently satisfy the check, because that would make two machines disagree while both report success.

### The sharp edge in decision 18

`clang-cl` is not a complete toolchain on Windows. It needs the Windows SDK headers and import libraries and a C++ standard library, and neither ships in the LLVM archive.

The LLVM archive is freely redistributable. The Windows SDK is not, so it is downloaded at bootstrap from Microsoft's own package feed rather than committed. `D00 T01 §1` owns proving that acquisition works, and is written so the plan finds out there rather than in `D01`.

### What this is worth

The AutoIt tree does not build from a clean checkout today, because thirteen build descriptors hardcode a path that no longer exists. Making the toolchain repository-scoped is the direct answer to that failure mode: there is no machine-specific state left to go stale.

---

# Where this left the tree, 2026-09-16

The plan is seeded and green.

- **10 domains, 11 TODO files, 54 sections, 334 checklist items.**
- `validate`: 0 fatal, 0 warning, 43 adjacency advisories.
- `plan --check`: current, 0 of 54 complete.
- `self-test`: 393 cases, 0 failed.
- **4 sections ready now:** `D00 T01 §1` (toolchain bootstrap), `D07 T01 §1` (the conformance profile), `D09 T01 §1` and `§2` (make the AutoIt suite buildable again, and clear its housekeeping defects).

The phases are: gates and the bar; the two shared layers; the launcher and the ports; intake and new capability; ship it in every language.

`07-quality` deliberately carries no file-level dependency, so the conformance profile can be written immediately. It is what every tool is built against, so it runs first rather than reviewing finished work.

---

# ExoSuite changes the plan, 2026-09-16

`samples/ExoSuite` was inspected at the operator's request. It is not a sketch: it is a working native C++23 application with a shared UI framework, a repository-scoped toolchain, and an extension model. It supersedes two decisions taken earlier today.

## What was measured

| Piece | Reality |
| --- | --- |
| `shared/exo-ui` | 6,865 lines of C++23: theme, typography, DPI, animation, icons, render, and six controls |
| Rendering | Direct2D and DirectWrite, with native `ID2D1SvgDocument` SVG icon rendering |
| Icons | Lucide, ISC licensed, 29 bundled |
| `exokit/` | A working bootstrap: llvm-mingw 20251216 ucrt-x86_64, CMake 4.2.3, Ninja 1.13.1 |
| `extensions/` | `RegStudio` and `Console`, each a standalone `WIN32` executable linking exo-ui statically |
| `src/main.cpp` | 573 lines. The application is a shell composing `exo::Toolbar`, `Sidebar`, `StatusBar`, `ContentView`, `ListView` |
| `Bin/Release/ExoSuite.exe` | **1.39 MB**, fully static via `-static -static-libgcc -static-libstdc++` |
| Dependencies | **No vcpkg.** `deps/libvterm` is a **git submodule** on `neovim/libvterm`, populated with 81 files |
| Tests | **None.** `test_font.cpp` is a scratch file |
| Standard | C++23, CMake presets, Ninja, LTO on release |

The README still describes Rust and Slint and is stale: commit `efdce6177` removed that prototype and restored the native C++23 architecture.

**573 lines of application on 6,865 lines of shared framework is the framework-plus-thin-tool split this session spent the day designing.** It already exists and it already ships.

## Decisions taken, round 7

23. **ExoSuite becomes the Resolute launcher.** One product, not two. Its Control Panel browsing and extension discovery is what the launcher does, the WinPower system-locations import folds into it naturally, and `RegStudio` and `Console` become Resolute tools.
24. **ExoUI replaces wxWidgets as the UI layer.** Decision 14 is superseded.
25. **ExoKit replaces the clang-cl bootstrap as the toolchain.** Decision 18 is superseded.
26. **Lucide for UI glyphs, Rizonesoft icons for applications.** Each tool keeps the application icon users recognize.

## Why ExoUI over wxWidgets

- **1.39 MB static**, against 5 to 12 MB for wxWidgets and 40 to 60 MB for a self-contained WinUI 3. It is the same size class as the AutoIt executables it replaces.
- **Direct2D is vector-crisp at every DPI by construction.** High DPI stops being a retrofit and becomes a property. `#AutoIt3Wrapper_Res_HiDpi=N` across fourteen scripts was the second most visible defect in the suite, and this removes the whole category.
- **Dark mode is already built to a higher standard** than wxWidgets offers: a full semantic palette with four surface elevation levels, animated crossfade, DWM system accent reading, and high-contrast detection.
- SVG icons render natively, so iconography is sharp at every scaling without a bitmap set per size.
- It is the operator's own code, so there is no third-party UI dependency to track.

## Why ExoKit over clang-cl plus an acquired Windows SDK

The risk flagged in decision 18 was that `clang-cl` needs Windows SDK headers and import libraries that cannot be vendored, so the bootstrap depended on acquiring them from Microsoft's feed.

**llvm-mingw removes that risk entirely.** It is a self-contained UCRT-targeting archive carrying its own headers and import libraries. No Windows SDK, no `xwin`, no licence question, and it already works.

It also ships `aarch64`, `arm64ec`, `armv7`, `i686`, and `x86_64` targets, so ARM64 Windows becomes nearly free.

**The honest tradeoff:** llvm-mingw targets the MinGW-w64 environment rather than the MSVC ABI. MSVC-built static libraries cannot be linked, and debugging is LLDB rather than the Visual Studio debugger. Everything here is built from source, so the cost is small, but it is a real constraint on ever consuming a binary-only third-party library.

## What ExoUI does not cover

Checked directly: the only matches for settings, logging, localization, or update in the exo-ui headers were `UpdateDpi`. **ExoUI is UI only.**

The split is therefore clean, and it is good news for the framework domain:

| Layer | Status |
| --- | --- |
| Theme, typography, DPI, animation, icons, render, six controls | **Exists.** `D01 T01 §7` and `§8` become adoption rather than construction |
| Settings, logging, localization, update, elevation, tool descriptor, standalone layout | **Still owed.** `D01 T01 §1` to `§6` and `§9` stand |

The two hardest sections in the framework domain were the ones already written.

## What this leaves open

- **`exo-ui` has no test coverage**, and neither does ExoSuite. `D00 T02` is unchanged in scope and is now the largest remaining gap in Phase 0.
- **`samples/ExoSuite` and `samples/RegStudio` are embedded git repositories** with their own history. Bringing them in needs a decision: preserve history through a subtree merge, or vendor the working tree and lose it.
- **`exo-ui` has six controls.** The repair tools need a result list, a progress surface, a preferences page host, and standard dialogs. Whether those are extensions to exo-ui or a Resolute layer above it is undecided.
- **No vcpkg** means Catch2 needs vendoring or `FetchContent`.
- **ExoSuite's README is stale** and describes a Rust and Slint stack that was removed.

## Decisions taken, round 8

27. **Everything renames to Resolute now.** The product, the UI library, and the toolchain. Measured scope: the product name is in 32 files, and `exo::`, `EXOUI_API`, and `exo/` appear 108 times across 25 files. It is the cheapest this will ever be, and it stops fourteen tools from including headers named for a retired product.
28. **The codebase comes in through a subtree merge**, preserving history. `exo-ui` is about to become the foundation of fourteen tools, and how it reached its current shape is recoverable now and never again once the embedded repositories are discarded.

### The names chosen

Recorded as a dated default, changeable at the cost of redoing a mechanical rename:

| Was | Becomes |
| --- | --- |
| `ExoSuite.exe` | `Resolute.exe` |
| `shared/exo-ui` | `shared/resolute-ui` |
| namespace `exo::` | namespace `rui::` |
| `EXOUI_API` | `RESUI_API` |
| include prefix `exo/` | `resolute/` |
| `exokit/` | `reskit/`, bootstrapped from the repository root |

### Build portability, confirmed

The toolchain stays fully repository-scoped and is **more** portable than the superseded clang-cl plan. The bootstrap downloads llvm-mingw, CMake, and Ninja into an ignored directory. No Visual Studio, no Windows SDK, no installer, nothing registered on the machine. `D00 T01 §1` hardens it with recorded hashes, detect-before-download, a fail-by-name locator, and a proof on a machine that has neither Visual Studio nor a Windows SDK.

---

# Plan state after the ExoSuite intake

- **10 domains, 12 TODO files, 58 sections.**
- `validate`: 0 fatal, 0 warning, 46 adjacency advisories. `plan --check`: current at 0 of 58.
- **4 sections ready:** `D00 T03 §1` (subtree merge), `D07 T01 §1` (conformance profile), `D09 T01 §1` and `§2` (AutoIt maintenance).

`D00 T03` is the new front door: take the codebase in, rename it, correct its documentation. `D00 T01 §1` changed from building a bootstrap to hardening one. `D01 T01 §7` changed from building the standard surfaces to adopting the UI library and binding it to the settings and localization layers; `§8` changed from DPI and theme work, which Direct2D makes unnecessary, to extending the library with the result list, progress surface, and dialogs the repair tools need.

## Decisions taken, round 9

29. **`DESIGN.md` at the repository root is the permanent design contract.** Named for breadth: it governs colour tokens, the type ramp, the spacing grid, motion, iconography, window chrome, accessibility, performance, and content tone, which is more than "UX" suggests. It sits beside `AGENTS.md` as a peer contract and is updated by editing it, in a commit that also restakes the affected captures.
30. **The contract binds through the existing Fidelity mechanism.** `todo/README.md` now points every `Fidelity:` block at `DESIGN.md`, with the captures under `docs/captures/house-style/` as its visual reference. **Where a capture and the contract disagree, the contract wins** and the capture is restaked. `D07 T01 §1` adopts it by reference rather than restating it, so there is one record rather than two that drift.
31. **`AGENTS.md` carries the three overriding rules**: a tool never draws a control the shared library provides, never hardcodes a colour, size, or spacing value, and application icons are the one deliberate exception.

## Gaps filled

Three gaps were named at the end of the previous round. All three are now routed.

**The test gap.** `D00 T02 §5` covers the inherited UI library: theme token resolution, the DPI layer's metrics at four scalings, each named easing at its endpoints, icon resolution, and the controls' non-visual logic. The library renders the launcher correctly today, which is evidence it works rather than evidence it keeps working, and fourteen tools are about to depend on it.

**The UX roadmap.** `samples/ExoSuite/TODO-ux.md` holds 66 done and **101 open** items. `D01 T02` routes all of them across seven sections: tokens made unbypassable, the spacing grid with density and responsive layout, content virtualization, window chrome, the accessibility floor, the performance floor, and text presentation. Its Verification block requires every open item in that file to be shipped, routed, or marked superseded, so nothing is lost silently.

**The stale README.** `D00 T03 §4` owns it, and also reconciles `TODO.md` and `TODO-ux.md` against this plan.

### The largest gap the measurement exposed

Every control in the suite is custom-drawn, and **not one of them reports anything to a screen reader.** The entire accessibility section of `TODO-ux.md` is open: 8 items, including UI Automation providers, Narrator announcements, reduced motion, and hit-target sizes.

That is invisible to anyone not using assistive technology, which is exactly why it survived. `DESIGN.md` section 9 states it as a floor rather than an aspiration, and `D01 T02 §5` makes it true with a checkpoint that drives Narrator over every control and quotes what it said.

---

# Plan state after the design contract

- **10 domains, 13 TODO files, 66 sections.**
- `validate`: 0 fatal, 0 warning, 48 adjacency advisories. `plan --check`: current at 0 of 66.
- `self-test`: 393 cases, 0 failed.

Phase 1 now carries the design system alongside the framework and the repair contract. The acceptance bar gained a row: the suite is usable without a mouse or eyes, owned by `D01 T02 §5`.

## Decisions taken, round 10

32. **RegStudio joins the suite as a product**, with its own TODO file rather than a section, because a registry editor is a large tool and its own backlog carries 323 open items.
33. **RegStudio is a repair-contract tool, not a viewer.** Every registry write goes through the restore record and undo. That is the whole reason to build it: the registry editor everybody already has cannot put anything back.

## What RegStudio actually is, measured 2026-09-16

It exists twice, and `src/` and `CMakeLists.txt` are **byte-identical** between the two copies. `samples/RegStudio/` carries the git history, latest commit `c9b8a0b`; `samples/ExoSuite/extensions/RegStudio/` is the copy that arrives with the intake. The root copy is authoritative.

**It is an early prototype, not a near-complete tool.** Its own `TODO.md` reports **95 items done and 323 open**, roughly 23 percent.

| Aspect | Reality |
| --- | --- |
| Size | 1,086 lines, **all in one `src/main.cpp`** |
| Structure | `src/core/` and `src/ui/` exist but contain only `.gitkeep` |
| Works | Window with resizable panes, menu bar, dark title bar via `DwmSetWindowAttribute`, a TreeView and ListView created |
| Registry access | **6 API calls**, enough to demonstrate, not enough to be an editor |
| Missing | The registry engine, value editing, search, backup and restore, privilege handling |
| UI layer | Native Win32 `comctl32`, **not** the shared UI library |

That last row matters: conforming RegStudio to `DESIGN.md` means **replacing its control layer**, not restyling it. `D05 T02 §1` says so explicitly and names restyling as the cheaper substitute that fails the checkpoint.

### Why it is worth building anyway

Every registry editor can change a value. The one that ships with Windows cannot put it back.

`D05 T02 §4` makes undo the tool's defining feature, and it is specific about what that requires: prior state captured to a restore record on disk **before** any write, so undo survives the tool closing. An in-memory undo stack is named as the cheaper substitute that fails, because it is gone at exactly the moment a user discovers they need it.

The file also carries a protected-path set requiring a second explicit confirmation, and treats an imported `.reg` file as untrusted input that is previewed as a change set before anything is written. Shelling out to `reg.exe import` is named as the substitute that fails, because it applies an unknown change set with no preview and no undo.

## Open: the Console extension

`samples/ExoSuite/extensions/Console/` is **1,762 lines** across seven files: a real terminal emulator with PTY sessions and a terminal view, backed by the vendored `deps/libvterm`.

It arrives with the intake whether or not it is wanted, and it has no owner in the plan. It is listed in the coverage table as **needing a keep-or-drop decision**. Shipping a terminal emulator is a different product proposition from shipping system repair tools, and that is a call rather than an oversight.

---

# Plan state after RegStudio

- **10 domains, 14 TODO files, 72 sections.**
- `validate`: 0 fatal, 0 warning, 50 adjacency advisories. `plan --check`: current at 0 of 72.

Phase 3 now carries seven intakes plus four new utilities, with RegStudio the largest.

## Correction and layout, round 11

**Correction:** `deps/libvterm` was recorded earlier as vendored. It is a **git submodule** pointing at `neovim/libvterm`, populated with 81 files. It is the tree's only external dependency, and a submodule contradicts the bare-machine bootstrap property, because a clone without `--recursive` cannot build. `D00 T03 §1` now owns the decision and names leaving it as the substitute that fails.

**The merge lands at the repository root**, and the six collisions are all trivial:

| Collision | What it actually is | Resolution |
| --- | --- | --- |
| `todo/` | one file, `todo/extensions/TODO-Console.md` | route, then remove |
| `docs/` | one file, `docs/extensions.md` | move into the repository's `docs/` |
| `README.md` | the stale Rust and Slint one | the repository's wins; §4 rewrites the content |
| `.gitignore`, `.gitattributes` | build and `Bin/` rules | merge into the repository's |
| `build/` | ignored on both sides | nothing to reconcile |

`.github/` carries issue templates only, no CI workflows, so nothing is inherited there.

**Resulting root layout**, now recorded in `D00 T03 §1` and agreed by `AGENTS.md`:

```
CMakeLists.txt  CMakePresets.json
src/          the launcher shell
shared/       resolute-ui, lucide
extensions/   the tools, each a standalone executable
deps/         third-party source
reskit/       the bootstrapped toolchain
resources/    application icons
resolute_au3/ the frozen specification
todo/ docs/ scripts/
```

This corrects `AGENTS.md`, which described `src/` as "the C++ suite". After the intake `src/` is only the launcher shell: the framework lives in `shared/` and the tools in `extensions/`.

## Decisions taken, round 12

The operator delegated these. Each is recorded with its reasoning so it can be overturned on evidence rather than re-argued from scratch.

34. **Every tool lives at `extensions/<Tool>/`** and builds as its own standalone executable linking the shared library statically. `src/` is the launcher shell and nothing else. This is the model ExoSuite already uses, and "standalone or integrated" is precisely the independent-distribution constraint, so the port inherits a proven arrangement rather than inventing one.
35. **`Console` is dropped as a shipped product.** Its 1,762 lines stay reachable in history.
36. **The `deps/libvterm` submodule goes with it**, leaving the tree with **no external dependencies at all** beyond the bootstrapped toolchain and Catch2.

### Why Console is dropped

It is the operator's own working code, so the reasoning is stated rather than assumed.

- **It is off-mission.** Resolute is system repair. A terminal emulator is a developer tool, and no comparable suite ships one: not Sysinternals, not NirSoft.
- **Windows Terminal exists, is excellent, and ships with Windows 11.** Competing with a free first-party terminal is a poor use of the only scarce resource here.
- **The conformance cost is real.** As a shipped product it would owe the full profile: a documentation set, an update file, an About page, up to 35 language packs, `DESIGN.md` conformance, and the accessibility floor. A terminal grid with a UI Automation provider is genuinely hard, and it would be hard for a tool nobody asked this suite for.
- **It carries the tree's only external dependency.** `libvterm` was a submodule, which quietly breaks the bare-machine property: a clone without `--recursive` cannot build. Dropping Console removes the submodule, the dependency, and that failure mode together.

**What the real need actually is.** Several repair tools shell out to `netsh`, `sfc`, `dism`, and `chkdsk`, and a user wants to see what those printed. That is a read-only command output surface, not a terminal emulator: no PTY, no escape sequence parsing, no `libvterm`. The repair contract's per-item result and transcript in `D02 T01 §3` and `§5` already cover it.

**Reversing this is cheap.** `D00 T03 §1` requires the retired source to be reachable in history with the commit named, so restoring Console is a `git checkout` rather than a rewrite.

### What the shape now is

```
src/          the launcher shell, and nothing else
shared/       resolute-ui, lucide
extensions/   every tool, each a standalone executable
deps/         empty after Console retires
reskit/       the bootstrapped toolchain
```

A fresh clone **without** `--recursive` builds everything. `D00 T01 §2` asserts exactly that.
