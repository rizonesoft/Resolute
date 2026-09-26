# Resolute -- Implementation Plan to 100%

The order to run every section in, from today to a signed release of the C++ suite.

> **Progress:** **49 of 231 sections complete (21%).** Derived from the Implementation Order tables by `python scripts/todo-graph.py plan --sync` -- never edited by hand.
>
> **Plan/graph parity.** Every numbered TODO section, open or shipped, appears in exactly one phase table row. `plan --check` enforces missing, unknown, duplicate, and status parity. Read live totals from the generated Progress line above and `python scripts/todo-graph.py query stats`; never repeat a fixed denominator in prose.

Seeded 2026-09-16 for the C++ rewrite. The decisions behind it are in [`../docs/brainstorm/2026-09-16-completion-brainstorm.md`](../docs/brainstorm/2026-09-16-completion-brainstorm.md). The AutoIt plan this replaces is archived at [`../resolute_au3/todo/`](../resolute_au3/todo/README.md).

**How to use this.** The front door is the `process-plan` skill. It audits, then runs `process-phase` on the first phase that has a ready row, then the next ready phase after that closeout or park. One row is `process-todo-section` then `review-todo-section`. Do not invent a side loop.

**Copy a row and paste it.** The skills resolve a reference from whatever shape it arrives in, so this is a complete instruction:

```
process todo section: | [ ] | `D00 T03 §1` | Subtree merge with history preserved | 6 |
```

> [!IMPORTANT]
> **The boxes are derived. Never tick one by hand.**
>
> They are a projection of each TODO's Implementation Order table, and those flip in exactly one place: `review-todo-section`, after a `Verified:` stamp exists.
>
> ```bash
> python scripts/todo-graph.py plan --sync     # rewrite the boxes, then re-align every table
> python scripts/todo-graph.py plan --check    # fail if they have gone stale
> ```

---

## The acceptance bar

The finished suite is **every Rizonesoft product behaving like one product**, **Groomed 2026-09-17: this said "fourteen", which is the size of the suite being replaced rather than the size of the one being built.** Fourteen is right for `D04 T01`, the port. `D05` adds the intakes and the new tools on top of it, and the recorded target in the brainstorm record is **80 tools and a repair library**. The bar below is what each of them is held to, and the count is deliberately not repeated here: read it from `query stats`, because a number written into prose is the thing this tree keeps having to correct. Each is built by one command from a clean checkout on a machine with no Visual Studio, each checked by the same gates, each proven to do exactly what its AutoIt predecessor did, each storing settings through one writer, logging every action, speaking the user's language on every surface, refusing by name when it lacks a privilege, undoing every system change it makes or saying plainly that it cannot, rendering correctly at every DPI and in both appearances, and running standalone in an empty folder.

| Aim                                  | Owned by                                                                     |
| ------------------------------------ | ---------------------------------------------------------------------------- |
| A bare Windows machine can build it  | `D00 T01 §1` (bootstrap) · `D00 T01 §4` (build)                              |
| One command checks everything        | `D00 T01 §5` (all gates) · `D07 T01 §2` (ratchet)                            |
| Proof is possible at all             | `D00 T02 §1` (harness) · `D00 T02 §2` (fixtures) · `D00 T02 §4` (parity)     |
| The port is genuinely 1:1            | `D00 T02 §4` (driver) · `D04 T01 §1`-`§5` (every port)                       |
| One settings writer, one path        | `D01 T01 §2`                                                                 |
| Every tool leaves a trace            | `D01 T01 §3` · `D02 T01 §6`                                                  |
| Every surface speaks the language    | `D01 T01 §4` · `D08 T01 §2`                                                  |
| Elevation refused by name            | `D01 T01 §6` · `D02 T01 §1`                                                  |
| Every change has a reverse           | `D02 T01 §4` · `D04 T01 §2` · `D05 T01 §5`                                   |
| It looks like a 2026 application     | [`DESIGN.md`](../DESIGN.md) · `D01 T01 §7`-`§8` · `D01 T02` (the whole file) |
| It is usable without a mouse or eyes | `D01 T02 §5` (the accessibility floor)                                       |
| Each tool ships alone                | `D01 T01 §9` · `D07 T01 §1` · `D06 T01 §3`                                   |
| One suite, not fourteen products     | `D01 T01 §1` · `D02 T01 §1` · `D07 T01 §3`                                   |
| Retiring products tell their users   | `D06 T01 §5`                                                                 |
| What defines done is written down    | `D07 T01 §1`                                                                 |

---

## Where the project stands

Nothing in this plan has been built, but the C++ tree is **not** starting from zero.

The ExoSuite codebase, taken in by `D00 T03 §1` and renamed to Resolute by `§2`, is a working native C++23 application: a 6,865-line Direct2D and DirectWrite UI framework, a 573-line application shell at intake, 572 after `D00 T01 §3` removed an MSVC-only pragma, a working repository-scoped llvm-mingw toolchain, an extension model where each tool builds as a standalone executable, and a 1.39 MB fully static binary. It has no tests, no vcpkg, and none of the non-UI framework layers. It becomes the Resolute launcher, and its UI library becomes the framework's UI half.

The suite being replaced is mature and shipping: fourteen tools, roughly 43,000 lines of AutoIt3, a working builder, and an installer. Two measurements shape this plan. Roughly **21,000 of those 43,000 lines are fourteen copies of one framework**, which is why the real porting job is one framework plus fourteen small bodies of logic rather than a 43,000-line rewrite. And the per-tool logic, with that framework subtracted, is: `Ownership` 77 lines, `USBRepair` 147, `DVDRepair` 274, `PixRepair` 341, `BiosCodes` 960, `ComIntRep` 1,903.

Every open section is in scope and must appear in exactly one phase. A dependency may park a row; it does not remove it. `plan --check` is the proof. Completion-first: a row flips only whole, and debt always names its collector (`D00 T04 §19` owns the mechanical check).

---

## Prerequisites

**These are not sections. They are things that must be true before certain sections can start.**

### 1. A Windows host

Everything here is Windows-only. The toolchain is repository-scoped and bootstrapped, so the host needs no Visual Studio and no Windows SDK, but it still needs to be Windows.

### 2. The signing procedure

Signing already happens outside this repository. `D06 T01 §3` documents and verifies that procedure rather than building a new one. Credentials never enter the repository.

### 3. A USB device and an optical drive

`D04 T01 §4` cannot be fully proven without them. Its no-device path is proven first without hardware, deliberately, so the row makes progress while the hardware is unavailable and parks on the rest.

### 4. A clean test machine

`D06 T01 §3` install-tests, uninstall-tests, and upgrade-tests. A machine that has had the suite installed cannot prove a clean install. A virtual machine with a snapshot is sufficient.

---

## The phases


### Phase 0 -- Gates, proof, and the bar

Nothing in this plan can be proven until this phase is done. It opens by taking the ExoSuite codebase in and renaming it, because that is what makes `src/` real. It also carries the conformance profile, which runs early rather than late because it is what every tool is built against, and the maintenance that keeps the shipping AutoIt suite alive meanwhile.

|  ✔  | Section       | Deliverable                                       | Items |
| :-: | ------------- | ------------------------------------------------- | :---: |
| [x] | `D00 T03 §1`  | Subtree merge with history preserved              |  11   |
| [x] | `D00 T03 §2`  | Rename the product to Resolute                    |   7   |
| [x] | `D00 T03 §3`  | Rename the library and the toolchain              |   5   |
| [x] | `D00 T03 §4`  | Correct the stale documentation                   |  10   |
| [x] | `D00 T04 §1`  | Staleness Detection for Every Claim-Free Block    |   9   |
| [x] | `D00 T04 §2`  | The Review-Finding Ledger                         |   8   |
| [x] | `D00 T04 §3`  | Section Calibration                               |   6   |
| [x] | `D00 T04 §4`  | Re-Sequencing on Evidence                         |   7   |
| [x] | `D00 T04 §5`  | Make the Adjacency Advisory Actionable            |   7   |
| [x] | `D00 T04 §6`  | The Adversarial Reviewer                          |   7   |
| [x] | `D00 T04 §7`  | Review-run records                                |   4   |
| [x] | `D00 T04 §8`  | Revisit the two-model decision                    |   7   |
| [x] | `D00 T04 §9`  | Review-input integrity                            |   5   |
| [x] | `D00 T04 §10` | Run-record follow-ups                             |   5   |
| [x] | `D00 T04 §11` | Bind the rename scan to the diff header           |   3   |
| [x] | `D00 T04 §12` | Prove the manifest, not just emit it              |   8   |
| [x] | `D00 T04 §13` | Bind the stamp to the push                        |   6   |
| [x] | `D00 T04 §14` | Bar bool versions from the export gate            |   2   |
| [x] | `D00 T04 §15` | Run-record vocabulary and evidence follow-ups     |  12   |
| [x] | `D00 T04 §16` | Blinded-run checker defects                       |   6   |
| [x] | `D00 T04 §17` | Report without walking the corpus twice           |   2   |
| [x] | `D00 T04 §18` | Second two-model revisit, independently rated     |   8   |
| [x] | `D00 T04 §19` | No partial flips                                  |   6   |
| [x] | `D00 T04 §20` | Review-tooling operability follow-ups             |  20   |
| [x] | `D00 T04 §21` | Review-input integrity hardening                  |  17   |
| [x] | `D00 T04 §22` | Checker diagnostic codes and structured errors    |   4   |
| [x] | `D00 T04 §30` | CI read-back and reachable provenance             |   3   |
| [x] | `D00 T04 §31` | Red CI repaired, not waited on                    |   5   |
| [x] | `D00 T04 §32` | Campaign guard: stop hook, heartbeat, breaker     |   4   |
| [x] | `D00 T04 §33` | CI repair-loop follow-ups                         |   9   |
| [x] | `D00 T04 §34` | Campaign guard follow-ups                         |   8   |
| [x] | `D00 T04 §35` | CI read-back follow-ups                           |  10   |
| [x] | `D00 T04 §36` | Campaign guard lifecycle follow-ups               |  11   |
| [x] | `D00 T04 §37` | CI read-back hardening                            |   8   |
| [ ] | `D00 T04 §38` | Campaign guard identity and recovery              |  12   |
| [ ] | `D00 T04 §39` | CI read-back and repair completeness              |  10   |
| [ ] | `D00 T04 §40` | Campaign guard fence completeness                 |  12   |
| [ ] | `D00 T04 §23` | Single-reviewer panel revisit                     |   5   |
| [x] | `D00 T04 §24` | Review-tooling follow-ups                         |  24   |
| [ ] | `D00 T04 §25` | Checker diagnostic follow-ups                     |  13   |
| [ ] | `D00 T04 §26` | Review-flow follow-ups                            |  16   |
| [x] | `D00 T04 §27` | One writer, a GPT-governed panel, slot-bound pins |   6   |
| [ ] | `D00 T04 §28` | Slot-table review follow-ups                      |   6   |
| [x] | `D00 T04 §29` | Grok fallbacks on the newest Grok model           |   6   |
| [x] | `D00 T01 §1`  | Portable toolchain bootstrap                      |  14   |
| [x] | `D00 T01 §2`  | CMake structure and dependencies                  |  11   |
| [x] | `D00 T01 §3`  | Warnings as errors at one level                   |   6   |
| [x] | `D00 T01 §4`  | One command builds any tool                       |   6   |
| [x] | `D00 T01 §5`  | One command runs every gate                       |   6   |
| [x] | `D00 T01 §6`  | Keep the toolchain current                        |  12   |
| [x] | `D00 T02 §1`  | Catch2 harness and assertion conventions          |   6   |
| [x] | `D00 T02 §2`  | Fixture store and disposable targets              |   6   |
| [x] | `D00 T02 §3`  | House-Style Contract, Checked Against Source      |   6   |
| [x] | `D00 T02 §4`  | Parity driver for a built tool                    |   7   |
| [x] | `D07 T01 §1`  | The conformance profile                           |   7   |
| [ ] | `D07 T01 §2`  | Warning and analysis ratchet                      |   6   |
| [ ] | `D07 T01 §3`  | Conformance check and its report                  |  12   |
| [ ] | `D07 T01 §4`  | Standing smoke run over the suite                 |   5   |
| [ ] | `D09 T01 §1`  | Make the AutoIt suite buildable again             |   5   |
| [ ] | `D09 T01 §2`  | Clear the housekeeping defects                    |   5   |
| [ ] | `D09 T01 §3`  | Maintenance scope and retirement procedure        |   7   |
| [x] | `D00 T02 §5`  | Cover the inherited UI library                    |   7   |
| [ ] | `D00 T01 §8`  | Run the unit suite under release                  |   2   |
| [ ] | `D00 T01 §9`  | Remove the Linux execution surface                |   5   |
| [ ] | `D00 T02 §6`  | Remove the tautological width check               |   3   |
| [ ] | `D00 T02 §7`  | Driven UI completion tests                        |   3   |
| [ ] | `D00 T02 §8`  | Icon manifest audit                               |   3   |
| [ ] | `D00 T02 §9`  | Rendered-output regression tests                  |   4   |
| [ ] | `D00 T02 §10` | Focus-free UI suite conversion                    |   8   |
| [ ] | `D00 T02 §11` | Nightly full-suite regression run                 |   8   |
| [ ] | `D00 T02 §12` | Port-vs-port visual comparison                    |   4   |
| [ ] | `D00 T05 §1`  | Visual Proof Capture With Provenance              |   5   |
| [ ] | `D00 T05 §2`  | README Rewrite Plus Repo-Face Files               |  18   |
| [ ] | `D00 T05 §3`  | Setup-Path CI Plus Reproducibility                |   5   |
| [ ] | `D00 T06 §1`  | MySQL Schema, Authoring Workflow                  |   5   |
| [ ] | `D00 T06 §2`  | Export, Embedding, Versioning                     |   7   |
| [ ] | `D00 T06 §3`  | Beep Database Migration Off Packs                 |   5   |
| [ ] | `D00 T06 §4`  | Data Extension: Vendors, Blink, POST              |   5   |
| [ ] | `D00 T06 §5`  | Consumer Contract for Tools                       |   4   |
| [ ] | `D10 T01 §1`  | About Bar, Topics, Social Preview                 |   4   |
| [ ] | `D10 T01 §2`  | Branch Protection, Real Check Names               |   4   |
| [ ] | `D10 T01 §3`  | Cold-Reader Taste Pass                            |   3   |
| [ ] | `D10 T01 §4`  | Demo Clip Recorded and Embedded                   |   5   |


### Phase 1 -- The two shared layers

The framework every tool consumes, the repair contract the destructive half consumes, and the design system that makes `DESIGN.md` true. This is where roughly 21,000 lines of AutoIt duplication stop being reproduced. Nothing after this phase is affordable without it.

|  ✔  | Section       | Deliverable                                  | Items |
| :-: | ------------- | -------------------------------------------- | :---: |
| [ ] | `D01 T01 §1`  | Application shell and lifecycle              |   8   |
| [ ] | `D01 T01 §2`  | Settings: one writer, one path               |  10   |
| [ ] | `D01 T01 §4`  | Localization and the pack loader             |   7   |
| [ ] | `D01 T03 §1`  | Standard window, menus, message layer        |   6   |
| [ ] | `D01 T03 §2`  | Preferences shell, general, performance      |   7   |
| [ ] | `D01 T03 §3`  | Language page and tool-page contract         |   5   |
| [ ] | `D01 T01 §7`  | Standard window, About, and preferences      |  10   |
| [ ] | `D01 T01 §8`  | DPI awareness and system theme               |   7   |
| [ ] | `D01 T03 §4`  | Per-tool log surface                         |   5   |
| [ ] | `D01 T01 §3`  | Logging and the log surface                  |   7   |
| [ ] | `D01 T03 §5`  | Update dialog and announcement               |   5   |
| [ ] | `D01 T01 §5`  | Update check and consolidation announcement  |   9   |
| [ ] | `D01 T01 §9`  | Standalone proof in an empty folder          |   6   |
| [ ] | `D01 T03 §6`  | Refusal, crash, singleton, shutdown          |   6   |
| [ ] | `D01 T01 §6`  | Elevation and its refusal path               |   7   |
| [ ] | `D01 T01 §10` | Crash Handling and Single Instance           |   9   |
| [ ] | `D01 T01 §11` | Command Line and Exit Codes                  |   9   |
| [ ] | `D02 T01 §1`  | The repair item and the run loop             |   6   |
| [ ] | `D02 T01 §2`  | Diagnose before repair                       |   9   |
| [ ] | `D02 T01 §3`  | Per-item result and the surface              |   6   |
| [ ] | `D02 T01 §4`  | Restore record and undo                      |   8   |
| [ ] | `D02 T01 §5`  | Transcript the user can carry                |   5   |
| [ ] | `D02 T01 §6`  | One log line per action and per refusal      |   5   |
| [ ] | `D01 T02 §1`  | Tokens made unbypassable                     |   6   |
| [ ] | `D01 T02 §2`  | Spacing grid, density, and responsive layout |   7   |
| [ ] | `D01 T02 §3`  | Content area: virtualization and scrolling   |   6   |
| [ ] | `D01 T02 §4`  | Window chrome and shell integration          |   7   |
| [ ] | `D01 T02 §5`  | The accessibility floor                      |  10   |
| [ ] | `D01 T02 §6`  | Performance floor                            |   8   |
| [ ] | `D01 T02 §7`  | Text presentation and machine values         |   5   |
| [ ] | `D01 T03 §7`  | Splash, donate, string audit                 |   4   |


### Phase 2 -- The launcher and the ports

Every existing tool moves onto the shared layers, proven 1:1 against its AutoIt counterpart. The vertical slice through Ownership comes first and is the moment the architecture is either validated or corrected cheaply.

|  ✔  | Section      | Deliverable                                  | Items |
| :-: | ------------ | -------------------------------------------- | :---: |
| [ ] | `D03 T02 §1` | Start bar and cascade map                    |   6   |
| [ ] | `D03 T02 §2` | Main content and repair groups               |   6   |
| [ ] | `D03 T01 §1` | Launcher on the framework                    |   6   |
| [ ] | `D03 T02 §3` | Tool list surface                            |   5   |
| [ ] | `D03 T01 §2` | Tool discovery and the tool list             |   5   |
| [ ] | `D03 T02 §4` | System locations browser                     |   4   |
| [ ] | `D03 T01 §4` | Windows system locations                     |   6   |
| [ ] | `D03 T02 §5` | Suite log viewer surface                     |   5   |
| [ ] | `D03 T01 §5` | Suite log viewer                             |   5   |
| [ ] | `D03 T02 §6` | Symptom search surface                       |   5   |
| [ ] | `D03 T01 §6` | Symptom routing                              |   8   |
| [ ] | `D03 T02 §7` | Launcher chrome and notices                  |   6   |
| [ ] | `D03 T01 §3` | Launch, failure reporting, and elevation     |   5   |
| [ ] | `D04 T02 §1` | Ownership inventory, shared-layer map        |   6   |
| [ ] | `D04 T03 §1` | ComIntRep repair inventory, reversibility    |   6   |
| [ ] | `D04 T03 §2` | ComIntRep surface inventory, layer map       |   5   |
| [ ] | `D04 T04 §1` | PixRepair sequences and timing               |   5   |
| [ ] | `D04 T04 §2` | PixRepair surface inventory, layer map       |   5   |
| [ ] | `D04 T05 §1` | BiosCodes beep data and WMI inventory        |   5   |
| [ ] | `D04 T05 §2` | BiosCodes surface inventory, layer map       |   5   |
| [ ] | `D04 T06 §1` | MemBoost trim path, triggers                 |   6   |
| [ ] | `D04 T06 §2` | MemBoost surface inventory, layer map        |   5   |
| [ ] | `D04 T01 §1` | Vertical slice: Ownership end to end         |   8   |
| [ ] | `D04 T02 §2` | Ownership distribution completeness          |   7   |
| [ ] | `D04 T02 §3` | Verify-after-write, per-tree status          |   6   |
| [ ] | `D04 T02 §4` | Remove-all, stuck-state repair               |   4   |
| [ ] | `D04 T01 §2` | The five remaining frozen tools              |   9   |
| [ ] | `D04 T03 §3` | ComIntRep distribution completeness          |   8   |
| [ ] | `D04 T03 §4` | Per-repair verification and outcome          |   6   |
| [ ] | `D04 T03 §5` | Pre-repair restore-point offer               |   4   |
| [ ] | `D04 T03 §6` | Opt-in completion chime                      |   3   |
| [ ] | `D04 T04 §3` | PixRepair distribution completeness          |   7   |
| [ ] | `D04 T04 §4` | Display corrections                          |   5   |
| [ ] | `D04 T04 §5` | Draggable targeted window                    |   5   |
| [ ] | `D04 T04 §6` | Session timer with auto-stop                 |   4   |
| [ ] | `D04 T01 §3` | Browser optimizer: four tools into one       |   9   |
| [ ] | `D04 T01 §4` | Drive Repair: USBRepair and DVDRepair merged |  10   |
| [ ] | `D04 T01 §5` | MemBoost and BiosCodes                       |   9   |
| [ ] | `D04 T05 §3` | BiosCodes distribution completeness          |   7   |
| [ ] | `D04 T05 §6` | Migrate Beep Data to Reference DB            |   5   |
| [ ] | `D04 T05 §4` | Cross-vendor pattern search                  |   5   |
| [ ] | `D04 T05 §5` | Vendor auto-detect from WMI                  |   4   |
| [ ] | `D04 T05 §7` | User-Editable Database (CRUD)                |   7   |
| [ ] | `D04 T06 §3` | MemBoost distribution completeness           |   8   |
| [ ] | `D04 T06 §4` | Editable exclusion list                      |   5   |
| [ ] | `D04 T06 §5` | Per-process trim report                      |   5   |
| [ ] | `D04 T06 §6` | Only-list trim mode                          |   5   |


### Phase 3 -- Intake and new capability

Seven programs from `samples/` become products and eleven new utilities join, all through one intake contract, on a framework that already exists. This phase is where the rewrite starts paying for itself, and it is where the suite stops being a port and starts being a better product than the one it replaces. Two of its tools matter beyond themselves: RegStudio is a registry editor that can undo what it did, and the Restore Point Manager gives every other tool in the suite a second undo layer.

|  ✔  | Section      | Deliverable                                       | Items |
| :-: | ------------ | ------------------------------------------------- | :---: |
| [ ] | `D05 T01 §1` | The intake contract, proven on UUIDGen            |   7   |
| [ ] | `D05 T01 §2` | Complete Windows Repair                           |  11   |
| [ ] | `D05 T01 §3` | QuickErase and WinClean                           |  14   |
| [ ] | `D05 T01 §4` | Indicators and SaveDesk                           |   6   |
| [ ] | `D05 T01 §5` | The four new utilities                            |  11   |
| [ ] | `D05 T02 §1` | RegStudio on the shared framework                 |   7   |
| [ ] | `D05 T02 §2` | The registry engine                               |   7   |
| [ ] | `D05 T02 §3` | Browse, display, and virtualize                   |   6   |
| [ ] | `D05 T02 §4` | Editing, with a reverse                           |   8   |
| [ ] | `D05 T02 §5` | Search across hives                               |   5   |
| [ ] | `D05 T02 §6` | Backup, restore, and `.reg` exchange              |   7   |
| [ ] | `D05 T03 §1` | Restore Point Manager                             |   8   |
| [ ] | `D05 T03 §2` | Driver Manager: backup and rollback               |   8   |
| [ ] | `D05 T03 §3` | Disk Health                                       |   7   |
| [ ] | `D05 T03 §4` | Crash Decoder                                     |   6   |
| [ ] | `D05 T03 §5` | File Unlocker                                     |   7   |
| [ ] | `D05 T03 §6` | System Report                                     |   7   |
| [ ] | `D05 T03 §7` | Battery Health, Boot Options, File Associations   |   7   |
| [ ] | `D05 T03 §8` | Policy Inspector and Attribute Repair             |   9   |
| [ ] | `D05 T04 §1` | System Change Journal                             |   8   |
| [ ] | `D05 T04 §2` | Repair History                                    |   8   |
| [ ] | `D05 T04 §3` | Sleep and Wake Diagnostics                        |   7   |
| [ ] | `D05 T04 §4` | Boot Time Analyzer                                |   6   |
| [ ] | `D05 T04 §5` | Why Is This Denied                                |   6   |
| [ ] | `D05 T04 §6` | Pending Reboot Inspector                          |   5   |
| [ ] | `D05 T04 §7` | Activation and Network Share Diagnostics          |   6   |
| [ ] | `D05 T05 §1` | The recovery engine, read-only by design          |   9   |
| [ ] | `D05 T05 §2` | Undelete                                          |   6   |
| [ ] | `D05 T05 §3` | Erase verification                                |   8   |
| [ ] | `D05 T05 §4` | Rescue imaging                                    |  15   |
| [ ] | `D05 T06 §1` | Shadow Copy Browser                               |   7   |
| [ ] | `D05 T06 §2` | Windows Disk Space                                |   7   |
| [ ] | `D05 T06 §3` | Wi-Fi Diagnostics                                 |   8   |
| [ ] | `D05 T06 §4` | Profile Manager                                   |   7   |
| [ ] | `D05 T06 §5` | Icon Cache and Default Apps Repair                |   6   |
| [ ] | `D05 T06 §6` | Resource History and USB Device History           |   7   |
| [ ] | `D05 T06 §7` | Credential, Display, and Connection Viewers       |   8   |
| [ ] | `D05 T07 §1` | Update Blocker and Update History                 |   7   |
| [ ] | `D05 T07 §2` | Shell Extension Bisector and Explorer Performance |   7   |
| [ ] | `D05 T07 §3` | Defender Manager and Security Status              |   7   |
| [ ] | `D05 T07 §4` | BitLocker, Certificates, and Recovery             |   7   |
| [ ] | `D05 T07 §5` | Privacy and Telemetry Settings                    |   6   |
| [ ] | `D05 T07 §6` | Environment, Features, Power, and Locale          |   6   |
| [ ] | `D05 T07 §7` | Network Configuration Tools                       |   7   |
| [ ] | `D05 T07 §8` | Files, Boot, Audio, and Inventory                 |  11   |
| [ ] | `D05 T07 §9` | Printing, Search, and Scheduled Tasks             |   6   |


### Phase 4 -- Ship it, in every language

The suite is correct by here. This phase makes it shippable and makes it speak every language the suite speaks, including to the users of the four products that are retiring.

|  ✔  | Section       | Deliverable                                    | Items |
| :-: | ------------- | ---------------------------------------------- | :---: |
| [ ] | `D06 T01 §1`  | Release Descriptors, Portable by Construction  |   5   |
| [ ] | `D06 T01 §2`  | One Command Builds the Release Set             |   5   |
| [ ] | `D06 T01 §6`  | Version Rule, Changelog, and Release Checklist |   6   |
| [ ] | `D06 T01 §8`  | Licensing and Attribution                      |  12   |
| [ ] | `D01 T01 §14` | Embedded Dataset Loader                        |   4   |
| [ ] | `D06 T01 §11` | Tag-Derived Version Scheme Record              |   5   |
| [ ] | `D06 T01 §10` | Identity Registry and Version Agreement        |  10   |
| [ ] | `D06 T01 §17` | About Dialog, From the Registry                |   8   |
| [ ] | `D06 T01 §5`  | Update Files and Consolidation Announcements   |   7   |
| [ ] | `D06 T01 §7`  | Focused Builds From One Codebase               |   7   |
| [ ] | `D06 T01 §12` | Versioner Wiring and String Migration          |   4   |
| [ ] | `D06 T01 §13` | Stamped-Surface Agreement Test                 |   5   |
| [ ] | `D06 T01 §14` | Help Content Pipeline: Guide to Offline HTML   |   5   |
| [ ] | `D06 T01 §18` | F1 Context Help Through the Surface Map        |   5   |
| [ ] | `D06 T01 §3`  | Installers: Per Tool and Whole Suite           |  12   |
| [ ] | `D06 T01 §9`  | The Bare-Machine Proof                         |   7   |
| [ ] | `D06 T01 §4`  | Migration From the AutoIt Suite                |   7   |
| [ ] | `D06 T01 §15` | Web Publishing and Link Switch                 |   4   |
| [ ] | `D06 T01 §16` | Final Acceptance: The Suite As Shipped         |   6   |
| [ ] | `D08 T01 §1`  | Documentation set for every tool               |   9   |
| [ ] | `D08 T01 §2`  | Shared string pool and build-time composition  |   6   |
| [ ] | `D08 T01 §3`  | Coverage matrix and pack hygiene               |   7   |
| [ ] | `D08 T01 §4`  | Rewrite the shipped documentation              |   7   |
| [ ] | `D08 T01 §5`  | Repository and developer documentation         |   5   |

> **Moved:** `D01 T01 §12` -- 2026-09-23 to todo/06-distro-release/TODO-01-build-and-release.md (operator instruction); worked there as `D06 T01 §17` by that file's owner.
> **Moved:** `D01 T01 §13` -- 2026-09-23 to todo/06-distro-release/TODO-01-build-and-release.md (operator instruction); worked there as `D06 T01 §18` by that file's owner.

> **Moved:** `D00 T01 §7` -- 2026-09-17 to todo/06-distro-release/TODO-01-build-and-release.md (operator instruction); worked there as `D06 T01 §9` by that file's owner.

---

## What this plan deliberately does not do

- **It does not redesign the tools.** The port is 1:1 on behavior. New capability enters through `add-todo` like anything else, and Phase 3 is where it lands.
- **It does not set up CI.** There is no runner for this repository today. `D00 T01 §5` puts the whole gate set behind one command so wiring a runner later is a small job.
- **It does not unify tool versions.** `D06 T01 §6` writes the rule that explains the spread rather than declaring it wrong.
- **It does not maintain the AutoIt suite beyond keeping it shippable.** `D09 T01 §3` writes that scope down so the rewrite does not quietly become two projects.
- **It does not vendor a compiler into git.** The bootstrap downloads a pinned llvm-mingw toolchain into an ignored directory instead.
- **It does not keep the ExoSuite name.** `D00 T03` renames the product, the UI library, and the toolchain to Resolute, because there is one product here rather than two.

