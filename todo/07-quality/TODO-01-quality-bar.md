---
schema_version: 1
id: quality-bar
domain: 07-quality
status: draft
title: "TODO-01 -- The Quality Bar"
depends_on: []
track: Q1
---

# TODO-01 -- The Quality Bar

> **Goal:** "Done" is a checklist a machine can run, not an opinion. The conformance profile says what a tool must be, the conformance check proves it per tool, and the ratchet makes sure the numbers only move one way.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** Nothing here exists. This domain runs **early**, not late: the profile is what every tool is built against and what every intake is measured against, so it is a dependency of the framework's acceptance rather than a review of finished work. The AutoIt suite is the evidence for why: with no written bar, seven tools stored settings in a language-pack file, six wrote no log, four had no documentation directory, and five had no language pack, and none of that was visible as a defect because nothing said it should be otherwise.

## Inputs

- [`docs/brainstorm/2026-09-16-completion-brainstorm.md`](../../docs/brainstorm/2026-09-16-completion-brainstorm.md) -- the measured conformance matrix the profile is derived from
- -> XREF: [`00-workspace/TODO-01 §3`](../00-workspace/TODO-01-toolchain-and-gates.md) -- the tidy baseline this domain ratchets
- -> XREF: [`01-framework/TODO-01 §1`](../01-framework/TODO-01-framework-core.md) -- the framework the profile mostly describes consuming correctly
- -> XREF: [`01-framework/TODO-02 §1`](../01-framework/TODO-02-design-system.md) -- the design contract the conformance check enforces
- -> XREF: [`00-workspace/TODO-04 §2`](../00-workspace/TODO-04-self-correction.md) -- the findings ledger, which is the ratchet idea applied to review rather than to code

## Outcome

- A written profile that says what a finished tool is, in terms a check can evaluate.
- A check that runs the profile against every tool and fails by name.
- A ratchet on warnings and static-analysis findings that only goes down.
- A standing smoke run over the whole suite.

**Adjacency:** list=applicable @ D07 T01 §3; document=applicable @ D07 T01 §1; settings=not-applicable (the quality tooling owns no user-facing settings); reporting=applicable @ D07 T01 §3; notifications=not-applicable (a local check notifies nobody); permissions=not-applicable (no role model in a developer gate); audit=applicable @ D07 T01 §2; exchange=not-applicable (nothing imports or exports here); reverse=not-applicable (a check changes nothing that needs undoing)

**Adjacency rationale:** Document anchors on §1 because the profile is the one artifact in this domain a person reads rather than runs, and a bar nobody can read is a bar nobody meets. Audit anchors on §2 because the ratchet is the project's memory of its own quality: the baseline file is the record that makes a regression visible rather than arguable.

## Implementation Order

| Order | Section | Deliverable                            | Depends On   | Status |
| :---: | :-----: | -------------------------------------- | ------------ | :----: |
|   1   |   §1    | The conformance profile                | --           |  [ ]   |
|   2   |   §2    | Warning and analysis ratchet           | D00 T01 §3   |  [ ]   |
|   3   |   §3    | Conformance check and its report       | §1           |  [ ]   |
|   4   |   §4    | Standing smoke run over the suite      | §3           |  [ ]   |

---

## 1. The Conformance Profile

The document every other domain is measured against. It runs first because a bar written after the work is a description, not a standard.

- [ ] Write the profile covering: consumes the framework, no private settings or log or localization code, settings in an `.ini` through the shared writer, one log line per action, every surface string from a pack, a documentation set, an update short name and file, an About page, DPI correct at four scalings, both appearances, and standalone in an empty folder. Done when: every clause is stated so that a check could evaluate it.
- [ ] Adopt [`DESIGN.md`](../../DESIGN.md) by reference rather than restating it. Done when: the profile names the contract as the source for every visual and interaction clause, and the check evaluates against it. Cheaper substitute: copying the design rules into the profile, which creates a second record that drifts.
- [ ] Add the clauses that apply only to a repair tool: consumes the repair contract, records prior state, verifies by read-back, and has a reverse or says it does not. Done when: the profile distinguishes the two tool kinds.
- [ ] Require standalone-ness explicitly. Done when: the profile states that a built tool alone in an empty directory must start, localize, show About, and check for updates.
- [ ] Make each clause cite its owner section. Done when: every clause names the section that implements it, so a failure has an address.
- [ ] Derive the profile from the measured AutoIt gaps rather than from taste. Done when: each of the seven measured defect classes maps to a clause that would have caught it.
- [ ] Commit: `"quality: the conformance profile"`

**Test checkpoint:** The profile states every clause in evaluable terms, distinguishes tool kinds, requires standalone-ness, and cites an owner per clause. Each of the seven measured AutoIt defect classes maps to a clause that would have caught it, and the mapping is quoted.

## 2. Warning and Analysis Ratchet

**Needs:** C++ toolchain (compile)

- [ ] Record the per-target baseline for compiler warnings and static-analysis findings. Done when: the baseline file exists and the combined gate compares against it.
- [ ] Make the ratchet one-way. Done when: a count above the baseline fails, a count equal passes, and a count below rewrites the baseline down in the same commit.
- [ ] Report which target regressed, not just that something did. Done when: a deliberate regression names the target and the finding.
- [ ] Prevent a silent baseline raise. Done when: raising a baseline requires an explicit recorded reason and the check names it.
- [ ] Commit: `"quality: a ratchet that only goes down"`

**Test checkpoint:** A count above the baseline fails and names the target and finding. A count equal passes. A count below rewrites the baseline down. A raise without a recorded reason is refused. All four quoted.

## 3. Conformance Check and Its Report

- [ ] Implement the check so it evaluates the profile against every shipped tool. Done when: it produces one row per tool per clause.
- [ ] Fail by name. Done when: a tool missing a documentation set is named with the clause it failed and the section that owns it.
- [ ] Check that **no repair has two homes**. Done when: every repair-contract item declared anywhere in the suite is checked for a duplicate subject in another tool, and a deliberate duplicate fails the check by name. This is the settings-path defect in a new place: one repair in two tools diverges the first time either is touched.
- [ ] Decide whether the release build must be **reproducible**, and record the decision either way. **Filed 2026-09-17 by `D00 T03 §3`, which measured it:** two consecutive clean builds of identical sources produced `Lucide.dll` at `8B25CFEE72714F28` and `08C187347BF55A19`, the same size both times. Nothing in the tree asks for reproducibility today, so this is not yet a defect, but it has two concrete costs. A signed release cannot be independently confirmed to come from the tagged source, which matters for a suite of system utilities that run elevated. And byte-comparison is unavailable as a verification instrument, which `D00 T03 §3` discovered when its own checkpoint asked for it and had to fall back to comparing exported symbols. Done when: the decision is dated, states whether reproducibility is wanted, and if it is, names the mechanism, most likely `-Wl,--no-insert-timestamp` plus `-ffile-prefix-map` for embedded paths, with a check that builds twice and compares. Cheaper substitute that fails the checkpoint: declaring the build reproducible because the sizes match, which is exactly the evidence that turned out not to mean it.
- [ ] Enforce a **per-tool size budget**, because the suite's size claim is a product promise and an unchecked promise decays. Done when: each tool's executable is measured at release, compared against a recorded budget, and a tool exceeding it fails the check by name. **Measure the shipped set, not the executable.** Corrected 2026-09-17: the `release` preset currently produces `Resolute.exe` at 1,381,376 bytes **plus** `System/ExoUI.dll` and `System/Lucide.dll`, 4,074,176 bytes in total, because the UI libraries are declared `SHARED`. `D00 T01 §2` owns making the default build static; until it does, a budget measured on the executable alone would report 1.32 MiB for a tool that actually ships 3.9 MB.
- [ ] Report the whole-suite total alongside it. Done when: the release report states the per-tool sizes and their sum, so the claim can be stated from measurement rather than estimate.
- [ ] Record what the budget buys. Done when: this section states that a competing suite of roughly twenty tools commonly exceeds 200 MB, so the comparison the claim rests on is written down rather than assumed.
- [ ] Check the **source layout** declared in `AGENTS.md` still holds. Done when: no file under `src/framework/` or `src/repair/` was added by a tool, no tool carries a file that belongs to a shared layer, and a deliberate violation fails the check by name. Cheaper substitute: trusting review, which is how a shared layer acquires a tool-specific special case.
- [ ] Include the standalone clause by actually running the tool in an empty directory. Done when: a tool that reaches outside its folder fails the check, proven by a deliberate regression.
- [ ] Make the report readable as a matrix. Done when: the full report renders as tools by clauses and is quoted here.
- [ ] Wire it into the combined gate. Done when: a conformance failure fails `scripts/check-all.ps1`.
- [ ] Commit: `"quality: the conformance check"`

**Test checkpoint:** The check produces a tool-by-clause matrix, quoted. A tool missing a documentation set is named with its clause and owner section. A tool that writes outside its folder fails the standalone clause. A conformance failure fails the combined gate.

## 4. Standing Smoke Run Over the Suite

- [ ] Drive every shipped tool through start, main surface, About, preferences, and exit. Done when: every tool is covered and a crash in any one is reported without stopping the run.
- [ ] Capture each tool's main surface on every run. Done when: the capture set is produced and compared against the previous run.
- [ ] Report the run as one artifact. Done when: a full run produces a single report naming every tool and its result, quoted.
- [ ] Make a smoke failure actionable. Done when: a failure names the tool, the step, and the captured state at failure.
- [ ] Commit: `"quality: a standing smoke run over the whole suite"`

**Test checkpoint:** A full smoke run covers every shipped tool through five steps each and produces one report, quoted. A deliberately broken tool is reported without stopping the run, naming tool, step, and captured state.

## Verification

- [ ] The conformance profile states every clause in evaluable terms with an owner per clause
- [ ] `pwsh scripts/check-all.ps1` includes the conformance check and the ratchet
- [ ] Every shipped tool passes every clause of the profile, or has a recorded exception
- [ ] A smoke run covers every shipped tool and produces one report
- [ ] `python scripts/todo-graph.py validate` clean
