# Resolute Power Tools -- Implementation Plan to 100%

The order to run every section in, from today to a signed release.

> **Progress:** **0 of 51 sections complete (0%).** Derived from the Implementation Order tables by `python scripts/todo-graph.py plan --sync` -- never edited by hand.
>
> **Plan/graph parity.** Every numbered TODO section, open or shipped, appears in exactly one phase table row. `plan --check` enforces missing, unknown, duplicate, and status parity. Read live totals from the generated Progress line above and `python scripts/todo-graph.py query stats`; never repeat a fixed denominator in prose.

Seeded 2026-09-16 by porting the Intelligent Notepad TODO system. Current state and dependency ordering are derived from this repository as measured on that date; dated operational evidence remains dated evidence and must be re-read before an external change.

**How to use this.** The front door for this file is the `process-plan` skill. It audits, then runs `process-phase` on the first phase that has a ready row, then the next ready phase after that closeout or park, until no ready phase remains. A phase whose leftover `[ ]` rows are blocked by another phase (or another unmet dep) is parked, not a stall, and is not called complete. One row is `process-todo-section` then `review-todo-section`. Do not invent a side loop. Within a phase, follow the rows in order; if a newly discovered edge points later, add or split the prerequisite under `groom-plan` rather than moving the existing consumer.

**Copy a row and paste it.** The skills resolve a reference from whatever shape it arrives in, so this is a complete instruction:

```
process todo section: | [ ] | `D00 T01 §1` | AutoIt3 toolchain pin and locator | 6 |
```

No translating domain `00` and TODO `01` into a filename. `todo-graph.py resolve` does it, and reports the unmet dependencies while it is there.

> [!IMPORTANT]
> **The boxes are derived. Never tick one by hand.**
>
> They are a projection of each TODO's Implementation Order table, and those flip in exactly one place: `review-todo-section`, after a `Verified:` stamp exists. A box ticked here would be a second record of the same fact.
>
> ```bash
> python scripts/todo-graph.py plan --sync     # rewrite the boxes, then re-align every table
> python scripts/todo-graph.py plan --check    # fail if they have gone stale
> ```
>
> `--sync` also pads the table columns, so the file stays readable in source without anyone hand-padding it. `--check` deliberately ignores alignment: a build that goes red over whitespace is a build people stop reading.
>
> `--check` also fails when a row names a section the graph has never heard of, and when an open section appears in **no** phase: which is how this file would otherwise quietly stop being a plan for the whole project.

---

## The acceptance bar

The finished suite is **fourteen Rizonesoft tools that behave like one product**: every tool built by one command from a clean checkout, checked by the same gates, storing its settings in the same place through the same writer, logging every action it takes, speaking the user's language on every surface, refusing by name when it lacks the privilege it needs, and able to undo every system change it makes or say plainly that it cannot. Every destructive behavior is pinned by a freeze check against a disposable fixture, and the release that ships them is produced by a procedure rather than by habit.

Each clause has an owner, and this table is where to look when asking "is aim X actually covered":

| Aim                               | Owned by                                                                    |
| --------------------------------- | --------------------------------------------------------------------------- |
| One command builds anything       | `D00 T01 §3` (build) · `D00 T01 §4` (paths) · `D06 T01 §2` (release set)    |
| One command checks everything     | `D00 T01 §2` (Au3Check) · `D00 T01 §5` (all gates) · `D07 T01 §2` (ratchet) |
| Proof is possible at all          | `D00 T02 §1` (harness) · `D00 T02 §2` (fixtures) · `D00 T02 §4` (driver)    |
| One settings writer, one path     | `D01 T01 §3` (contract) · `D02 T01 §1` · `D03 T01 §1` (the seven repairs)   |
| Every tool leaves a trace         | `D01 T01 §4` (contract) · `D04 T01 §5` (the four silent browser tools)      |
| Every surface speaks the language | `D01 T01 §5` (contract) · `D02 T01 §2` (41 menu strings) · `D08 T01 §2`     |
| Elevation refused by name         | `D01 T01 §7` (contract) · `D03 T01 §6` (seven tools) · `D02 T01 §5`         |
| Destructive behavior pinned       | `D03 T01 §2-§5` (freeze checks) · `D05 T01 §1` (trim)                       |
| Every change has a reverse        | `D03 T01 §2-§4` · `D05 T01 §1` (the honest non-reverse) · `D06 T01 §4`      |
| One suite, not fourteen products  | `D04 T01 §1` (shared core) · `D07 T01 §4` (conformance) · `D00 T02 §3`      |
| Shippable releases                | `D06 T01` (descriptors, signing, installer, checklist)                      |

---

## Where the project stands

The generated Progress line at the top is the phase-plan snapshot; `python scripts/todo-graph.py query stats` is the full graph and item snapshot. Those are the only current totals.

Nothing in this plan has been built yet. The suite itself is mature and shipping: fourteen tools, roughly 43,000 lines of AutoIt3, a working SDK, and an installer. What does not exist is any of the machinery that makes a change to it safe. Phase 0 is the first ready work because every proof in every later phase depends on it.

The measured starting point is recorded in [`TODO-00-INDEX.md`](./TODO-00-INDEX.md) and each figure names the section that owns it. Two of those figures explain the shape of this plan: seven of fourteen tools write their settings into a file named `.lng`, and four of the browser tools are literally the same 2,389-line script. Neither is a mystery to diagnose; both are just work nobody had a safe way to do.

Every open section is in scope and must appear in exactly one phase. A dependency may park a row; it does not remove it. `plan --check` is the proof.

The total can rise when an audit identifies real scope. Say so plainly, route it once, and sync the plan and progress projection; a lower percentage after adding required work is more truthful than a false completion claim.

---

## Prerequisites

**These are not sections. They are the things that must be true before certain sections can start.** Their lead time is the real risk in this plan: a section can be rescheduled in an afternoon, a certificate or a piece of hardware cannot.

### 1. A Windows host with AutoIt3 installed

Everything here is AutoIt3 on Windows. `Au3Check.exe` and `Aut2Exe.exe` come from the AutoIt3 install, and the built tools only run on Windows. `D00 T01 §1` pins the location; until it does, every gate is a thing somebody remembers to run. Sections that need the host carry `**Needs:** Windows host (build/test)` or `**Needs:** AutoIt3 toolchain (compile)`, and `resolve` prints it.

### 2. A code-signing certificate

`D06 T01 §3` owns signing and carries `**Needs:** Signing certificate (release)`. Tools that repair a system and are not signed get blocked or quarantined, so this is a release blocker rather than a polish item. Nothing else in the plan waits on it.

### 3. A USB device and an optical drive

`D03 T01 §5` cannot be proven without them, and it says so with `**Needs:** USB device (drive test)`. Its no-device path is proven first without hardware, which is deliberate: the row makes progress while the hardware is unavailable and parks on the rest.

### 4. A clean test machine for install testing

`D06 T01 §4` install-tests, uninstall-tests, and upgrade-tests. A machine that has had the suite installed before cannot prove a clean install. A virtual machine with a snapshot is sufficient.

---

## The phases

Five phases. Phase 0 makes proof possible, Phase 1 makes the shared behavior correct, Phase 2 fixes the tools against that behavior, Phase 3 ships and measures, Phase 4 documents.

### Phase 0 -- Toolchain, gates, and the test backbone

Nothing else in this plan can be proven until this phase is done. Every later checkpoint cites Au3Check, a build, a fixture, a capture, or a driven run, and none of those exists today.

|  ✔  | Section      | Deliverable                          | Items |
| :-: | ------------ | ------------------------------------ | :---: |
| [ ] | `D00 T01 §1` | AutoIt3 toolchain pin and locator    |   6   |
| [ ] | `D00 T01 §2` | Au3Check gate and warning baseline   |   7   |
| [ ] | `D00 T01 §3` | One-command build for any tool       |   7   |
| [ ] | `D00 T01 §4` | Repository-relative `.sni` paths     |   6   |
| [ ] | `D00 T01 §5` | One command that runs every gate     |   5   |
| [ ] | `D00 T02 §1` | AutoIt test harness and assertions   |   7   |
| [ ] | `D00 T02 §2` | Fixture store and disposable targets |   7   |
| [ ] | `D00 T02 §3` | House-style capture store            |   7   |
| [ ] | `D00 T02 §4` | Driven-run driver for a built tool   |   6   |
| [ ] | `D00 T02 §5` | Suite smoke run and its report       |   5   |

### Phase 1 -- Shared contracts and the launcher

The SDK is what makes this a suite rather than fourteen products that share a folder. The contracts land first, then the launcher becomes the first consumer of each, which is what proves the contract is usable before six more tools are changed against it.

|  ✔  | Section      | Deliverable                                    | Items |
| :-: | ------------ | ---------------------------------------------- | :---: |
| [ ] | `D01 T01 §1` | Include inventory and consumer map             |   6   |
| [ ] | `D01 T01 §2` | Declaration hygiene across `SDK/Includes/`     |   7   |
| [ ] | `D01 T01 §3` | Settings contract: one writer, one path        |   8   |
| [ ] | `D01 T01 §4` | Logging contract and the five silent tools     |   7   |
| [ ] | `D01 T01 §5` | Localization contract: no hardcoded UI strings |   7   |
| [ ] | `D01 T01 §6` | Update and version contract                    |   6   |
| [ ] | `D01 T01 §7` | Elevation contract and its refusal path        |   7   |
| [ ] | `D02 T01 §1` | Settings path repair and migration             |   6   |
| [ ] | `D02 T01 §2` | Menu localization for all 54 items             |   7   |
| [ ] | `D02 T01 §3` | Tool discovery, launch, and failure reporting  |   6   |
| [ ] | `D02 T01 §4` | Launcher logging and the log surface           |   6   |
| [ ] | `D02 T01 §5` | Elevation behavior when a launch is declined   |   6   |

### Phase 2 -- The tools, against the contracts

Seventeen rows, three domains, one pattern: apply the shared contract, pin what is dangerous with a freeze check, prove the reverse, and account for the surface. The browser consolidation sits here rather than earlier because it is the largest single reduction in this repository and it needs the harness and the captures to be safe.

|  ✔  | Section      | Deliverable                                   | Items |
| :-: | ------------ | --------------------------------------------- | :---: |
| [ ] | `D03 T01 §1` | Settings path repair across the six tools     |   6   |
| [ ] | `D03 T01 §2` | ReBar registry backup, restore, and refusal   |   8   |
| [ ] | `D03 T01 §3` | Ownership takeover and its reverse            |   7   |
| [ ] | `D03 T01 §4` | ComIntRep re-registration and its reverse     |   7   |
| [ ] | `D03 T01 §5` | USBRepair and DVDRepair drive actions         |   7   |
| [ ] | `D03 T01 §6` | Elevation refusal across all seven tools      |   6   |
| [ ] | `D03 T01 §7` | BiosCodes trace and result output             |   6   |
| [ ] | `D04 T01 §1` | Extract the shared optimizer core             |   6   |
| [ ] | `D04 T01 §2` | Browser profile descriptors                   |   6   |
| [ ] | `D04 T01 §3` | Firemin on the shared core                    |   7   |
| [ ] | `D04 T01 §4` | Chromin, Edgemin, Watermin on the shared core |   7   |
| [ ] | `D04 T01 §5` | Logging across all four                       |   6   |
| [ ] | `D04 T01 §6` | Language packs for the three missing tools    |   5   |
| [ ] | `D05 T01 §1` | Pin the trim path with a freeze check         |   7   |
| [ ] | `D05 T01 §2` | Every setting has a proven consumer           |   7   |
| [ ] | `D05 T01 §3` | Tray, notifications, sounds, and warnings     |   7   |
| [ ] | `D05 T01 §4` | Live statistics measured, not estimated       |   7   |

### Phase 3 -- Release and quality

The suite is correct by here; this phase is what makes it shippable and keeps it that way. The two domains interleave deliberately: the release procedure refuses to ship when the quality checks fail, so neither is finished without the other.

|  ✔  | Section      | Deliverable                                    | Items |
| :-: | ------------ | ---------------------------------------------- | :---: |
| [ ] | `D06 T01 §1` | Complete and portable build descriptors        |   6   |
| [ ] | `D06 T01 §2` | One command builds the whole release set       |   6   |
| [ ] | `D06 T01 §3` | Signing the release set                        |   6   |
| [ ] | `D06 T01 §4` | Installer and portable edition, install-tested |   7   |
| [ ] | `D06 T01 §5` | Version rule, changelog, and release checklist |   6   |
| [ ] | `D07 T01 §1` | The bar: what done means for a tool            |   7   |
| [ ] | `D07 T01 §2` | Warning ratchet that only goes down            |   7   |
| [ ] | `D07 T01 §3` | Standing smoke run and its report              |   6   |
| [ ] | `D07 T01 §4` | House-style conformance check                  |   6   |

### Phase 4 -- Documentation and localization

Last because it documents what the earlier phases built, and because a guide written against a surface that is about to change is a guide nobody trusts twice.

|  ✔  | Section      | Deliverable                                  | Items |
| :-: | ------------ | -------------------------------------------- | :---: |
| [ ] | `D08 T01 §1` | Per-tool documentation, complete and current |   7   |
| [ ] | `D08 T01 §2` | Language coverage matrix and partial packs   |   7   |
| [ ] | `D08 T01 §3` | User guide for the surfaces users meet       |   6   |

---

## What this plan deliberately does not do

Saying so here keeps silence from reading as an oversight.

- **It does not add features.** Every row either makes an existing behavior provable, corrects a measured defect, or removes duplication. New tools and new capabilities enter through `add-todo` like anything else.
- **It does not set up CI.** There is no runner for this repository today. `D00 T01 §5` puts the whole gate set behind one command so that wiring a runner later is a small job rather than a project, and a runner gets its own section when there is one to configure.
- **It does not renumber or unify tool versions.** The spread from 11.1.1.869 to 23.2.0.857 is real and `D06 T01 §5` writes the rule that explains it rather than declaring it wrong.
- **It does not touch `Samples/`.** That directory is gitignored and is not part of the product.
- **It does not restore `Rescue`.** Commit `e9b6259` removed it. `D08 T01 §1` corrects the documentation that still lists it; bringing the tool back would be new work with its own file.
