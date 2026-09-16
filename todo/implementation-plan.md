# Resolute -- Implementation Plan to 100%

The order to run every section in, from today to a signed release of the C++ suite.

> **Progress:** **0 of 54 sections complete (0%).** Derived from the Implementation Order tables by `python scripts/todo-graph.py plan --sync` -- never edited by hand.
>
> **Plan/graph parity.** Every numbered TODO section, open or shipped, appears in exactly one phase table row. `plan --check` enforces missing, unknown, duplicate, and status parity. Read live totals from the generated Progress line above and `python scripts/todo-graph.py query stats`; never repeat a fixed denominator in prose.

Seeded 2026-09-16 for the C++ rewrite. The decisions behind it are in [`../docs/brainstorm/2026-09-16-completion-brainstorm.md`](../docs/brainstorm/2026-09-16-completion-brainstorm.md). The AutoIt plan this replaces is archived at [`../resolute_au3/todo/`](../resolute_au3/todo/README.md).

**How to use this.** The front door is the `process-plan` skill. It audits, then runs `process-phase` on the first phase that has a ready row, then the next ready phase after that closeout or park. One row is `process-todo-section` then `review-todo-section`. Do not invent a side loop.

**Copy a row and paste it.** The skills resolve a reference from whatever shape it arrives in, so this is a complete instruction:

```
process todo section: | [ ] | `D00 T01 §1` | Portable toolchain bootstrap | 12 |
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

The finished suite is **fourteen Rizonesoft products that behave like one product**, each built by one command from a clean checkout on a machine with no Visual Studio, each checked by the same gates, each proven to do exactly what its AutoIt predecessor did, each storing settings through one writer, logging every action, speaking the user's language on every surface, refusing by name when it lacks a privilege, undoing every system change it makes or saying plainly that it cannot, rendering correctly at every DPI and in both appearances, and running standalone in an empty folder.

| Aim                                 | Owned by                                                                 |
| ----------------------------------- | ------------------------------------------------------------------------ |
| A bare Windows machine can build it | `D00 T01 §1` (bootstrap) · `D00 T01 §4` (build)                          |
| One command checks everything       | `D00 T01 §5` (all gates) · `D07 T01 §2` (ratchet)                        |
| Proof is possible at all            | `D00 T02 §1` (harness) · `D00 T02 §2` (fixtures) · `D00 T02 §4` (parity) |
| The port is genuinely 1:1           | `D00 T02 §4` (driver) · `D04 T01 §1`-`§5` (every port)                   |
| One settings writer, one path       | `D01 T01 §2`                                                             |
| Every tool leaves a trace           | `D01 T01 §3` · `D02 T01 §6`                                              |
| Every surface speaks the language   | `D01 T01 §4` · `D08 T01 §2`                                              |
| Elevation refused by name           | `D01 T01 §6` · `D02 T01 §1`                                              |
| Every change has a reverse          | `D02 T01 §4` · `D04 T01 §2` · `D05 T01 §5`                               |
| It looks like a 2026 application    | `D01 T01 §8` (DPI and theme)                                             |
| Each tool ships alone               | `D01 T01 §9` · `D07 T01 §1` · `D06 T01 §3`                               |
| One suite, not fourteen products    | `D01 T01 §1` · `D02 T01 §1` · `D07 T01 §3`                               |
| Retiring products tell their users  | `D06 T01 §4`                                                             |
| What defines done is written down   | `D07 T01 §1`                                                             |

---

## Where the project stands

Nothing in this plan has been built. `src/` does not exist yet.

The suite being replaced is mature and shipping: fourteen tools, roughly 43,000 lines of AutoIt3, a working builder, and an installer. Two measurements shape this plan. Roughly **21,000 of those 43,000 lines are fourteen copies of one framework**, which is why the real porting job is one framework plus fourteen small bodies of logic rather than a 43,000-line rewrite. And the per-tool logic, with that framework subtracted, is: `Ownership` 77 lines, `USBRepair` 147, `DVDRepair` 274, `PixRepair` 341, `BiosCodes` 960, `ComIntRep` 1,903.

Every open section is in scope and must appear in exactly one phase. A dependency may park a row; it does not remove it. `plan --check` is the proof.

---

## Prerequisites

**These are not sections. They are things that must be true before certain sections can start.**

### 1. A Windows host

Everything here is Windows-only. `D00 T01 §1` makes the toolchain repository-scoped so that host needs no Visual Studio, but it still needs to be Windows.

### 2. The signing procedure

Signing already happens outside this repository. `D06 T01 §3` documents and verifies that procedure rather than building a new one. Credentials never enter the repository.

### 3. A USB device and an optical drive

`D04 T01 §4` cannot be fully proven without them. Its no-device path is proven first without hardware, deliberately, so the row makes progress while the hardware is unavailable and parks on the rest.

### 4. A clean test machine

`D06 T01 §3` install-tests, uninstall-tests, and upgrade-tests. A machine that has had the suite installed cannot prove a clean install. A virtual machine with a snapshot is sufficient.

---

## The phases


### Phase 0 -- Gates, proof, and the bar

Nothing in this plan can be proven until this phase is done. It also carries the conformance profile, which runs early rather than late because it is what every tool is built against, and the maintenance that keeps the shipping AutoIt suite alive meanwhile.

|  ✔  | Section      | Deliverable                                | Items |
| :-: | ------------ | ------------------------------------------ | :---: |
| [ ] | `D00 T01 §1` | Portable toolchain bootstrap               |  15   |
| [ ] | `D00 T01 §2` | CMake skeleton and vcpkg manifest          |   8   |
| [ ] | `D00 T01 §3` | Warnings as errors at one level            |   6   |
| [ ] | `D00 T01 §4` | One command builds any tool                |   6   |
| [ ] | `D00 T01 §5` | One command runs every gate                |   5   |
| [ ] | `D00 T02 §1` | Catch2 harness and assertion conventions   |   5   |
| [ ] | `D00 T02 §2` | Fixture store and disposable targets       |   6   |
| [ ] | `D00 T02 §3` | House-style capture store                  |   5   |
| [ ] | `D00 T02 §4` | Parity driver for a built tool             |   6   |
| [ ] | `D07 T01 §1` | The conformance profile                    |   6   |
| [ ] | `D07 T01 §2` | Warning and analysis ratchet               |   5   |
| [ ] | `D07 T01 §3` | Conformance check and its report           |   6   |
| [ ] | `D07 T01 §4` | Standing smoke run over the suite          |   5   |
| [ ] | `D09 T01 §1` | Make the AutoIt suite buildable again      |   4   |
| [ ] | `D09 T01 §2` | Clear the housekeeping defects             |   5   |
| [ ] | `D09 T01 §3` | Maintenance scope and retirement procedure |   5   |


### Phase 1 -- The two shared layers

The framework every tool consumes, and the repair contract the destructive half consumes. This is where roughly 21,000 lines of AutoIt duplication stop being reproduced. Nothing after this phase is affordable without it.

|  ✔  | Section      | Deliverable                                 | Items |
| :-: | ------------ | ------------------------------------------- | :---: |
| [ ] | `D01 T01 §1` | Application shell and lifecycle             |   6   |
| [ ] | `D01 T01 §2` | Settings: one writer, one path              |   7   |
| [ ] | `D01 T01 §3` | Logging and the log surface                 |   6   |
| [ ] | `D01 T01 §4` | Localization and the pack loader            |   7   |
| [ ] | `D01 T01 §5` | Update check and consolidation announcement |   7   |
| [ ] | `D01 T01 §6` | Elevation and its refusal path              |   6   |
| [ ] | `D01 T01 §7` | Standard window, About, and preferences     |   7   |
| [ ] | `D01 T01 §8` | DPI awareness and system theme              |   6   |
| [ ] | `D01 T01 §9` | Standalone proof in an empty folder         |   6   |
| [ ] | `D02 T01 §1` | The repair item and the run loop            |   6   |
| [ ] | `D02 T01 §2` | Diagnose before repair                      |   6   |
| [ ] | `D02 T01 §3` | Per-item result and the surface             |   6   |
| [ ] | `D02 T01 §4` | Restore record and undo                     |   7   |
| [ ] | `D02 T01 §5` | Transcript the user can carry               |   5   |
| [ ] | `D02 T01 §6` | One log line per action and per refusal     |   5   |


### Phase 2 -- The launcher and the ports

Every existing tool moves onto the shared layers, proven 1:1 against its AutoIt counterpart. The vertical slice through Ownership comes first and is the moment the architecture is either validated or corrected cheaply.

|  ✔  | Section      | Deliverable                                  | Items |
| :-: | ------------ | -------------------------------------------- | :---: |
| [ ] | `D03 T01 §1` | Launcher on the framework                    |   6   |
| [ ] | `D03 T01 §2` | Tool discovery and the tool list             |   5   |
| [ ] | `D03 T01 §3` | Launch, failure reporting, and elevation     |   5   |
| [ ] | `D03 T01 §4` | Windows system locations                     |   5   |
| [ ] | `D03 T01 §5` | Suite log viewer                             |   5   |
| [ ] | `D04 T01 §1` | Vertical slice: Ownership end to end         |   8   |
| [ ] | `D04 T01 §2` | The five remaining frozen tools              |   7   |
| [ ] | `D04 T01 §3` | Browser optimizer: four tools into one       |   8   |
| [ ] | `D04 T01 §4` | Drive Repair: USBRepair and DVDRepair merged |   8   |
| [ ] | `D04 T01 §5` | MemBoost and BiosCodes                       |   8   |


### Phase 3 -- Intake and new capability

Six programs from samples/ become products and four new utilities join, all through one intake contract, on a framework that already exists. This phase is where the rewrite starts paying for itself.

|  ✔  | Section      | Deliverable                            | Items |
| :-: | ------------ | -------------------------------------- | :---: |
| [ ] | `D05 T01 §1` | The intake contract, proven on UUIDGen |   5   |
| [ ] | `D05 T01 §2` | Complete Windows Repair                |   7   |
| [ ] | `D05 T01 §3` | QuickErase and WinClean                |   8   |
| [ ] | `D05 T01 §4` | Indicators and SaveDesk                |   6   |
| [ ] | `D05 T01 §5` | The four new utilities                 |   7   |


### Phase 4 -- Ship it, in every language

The suite is correct by here. This phase makes it shippable and makes it speak every language the suite speaks, including to the users of the four products that are retiring.

|  ✔  | Section      | Deliverable                                    | Items |
| :-: | ------------ | ---------------------------------------------- | :---: |
| [ ] | `D06 T01 §1` | Release descriptors, portable by construction  |   5   |
| [ ] | `D06 T01 §2` | One command builds the release set             |   5   |
| [ ] | `D06 T01 §3` | Installer and portable edition, install-tested |   6   |
| [ ] | `D06 T01 §4` | Update files and consolidation announcements   |   6   |
| [ ] | `D06 T01 §5` | Version rule, changelog, and release checklist |   5   |
| [ ] | `D08 T01 §1` | Documentation set for every tool               |   6   |
| [ ] | `D08 T01 §2` | Shared string pool and build-time composition  |   6   |
| [ ] | `D08 T01 §3` | Coverage matrix and pack hygiene               |   6   |

---

## What this plan deliberately does not do

- **It does not redesign the tools.** The port is 1:1 on behavior. New capability enters through `add-todo` like anything else, and Phase 3 is where it lands.
- **It does not set up CI.** There is no runner for this repository today. `D00 T01 §5` puts the whole gate set behind one command so wiring a runner later is a small job.
- **It does not unify tool versions.** `D06 T01 §5` writes the rule that explains the spread rather than declaring it wrong.
- **It does not maintain the AutoIt suite beyond keeping it shippable.** `D09 T01 §3` writes that scope down so the rewrite does not quietly become two projects.
- **It does not vendor a compiler into git.** `D00 T01 §1` downloads a pinned toolchain into an ignored directory instead.

