---
schema_version: 1
id: quality-bar
domain: 07-quality
status: draft
title: "TODO-01 -- Quality Bar"
depends_on: []
track: Q1
---

# TODO-01 -- Quality Bar

> **Goal:** The suite has a written, checkable definition of what "done" means for a tool, a warning count that only goes down, a smoke run that answers whether all fourteen tools still work, and a conformance check that catches a tool drifting away from the house style. This file does not build features. It is what makes a claim about a feature believable.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** There is no written quality bar, no test suite, no smoke run, and no conformance check in this repository. The measured baseline is: 0 Au3Check errors, 847 unique Au3Check warnings at `-w 1..7` across the 14 concrete scripts (610 `already declared/assigned`, 178 unused locals, 54 `'Local' specifier in global scope`, 4 deprecated `Dim`, 1 global-in-function); 7 of 14 tools writing settings to a `.lng`; 5 of 14 with no logging; 41 of 54 launcher menu items hardcoded in English; 3 tools with no language directory; 3 with no documentation directory; and 4 tools that are the same 2,389-line file. Every one of those numbers is a starting point this file drives toward zero, and every one of them is owned by a section somewhere else in the tree.

## Inputs

- [`scripts/au3check-baseline.txt`](../../scripts) -- the ratchet file §2 drives down, created by `D00 T01 §2`
- [`docs/captures/house-style/`](../../docs) -- the captures §4 checks each tool against, created by `D00 T02 §3`
- -> XREF: [`00-workspace/TODO-01 §2`](../00-workspace/TODO-01-toolchain-and-gates.md) -- the Au3Check gate and the baseline this file ratchets
- -> XREF: [`00-workspace/TODO-02 §5`](../00-workspace/TODO-02-test-backbone.md) -- the smoke run this file turns into a standing check
- -> XREF: [`03-system-tools/TODO-01 §1`](../03-system-tools/TODO-01-system-tool-repairs.md) -- the tools measured against the bar §1 writes
- -> XREF: [`06-distro-release/TODO-01 §2`](../06-distro-release/TODO-01-build-and-release.md) -- the release build that refuses to stage when these checks fail

## Outcome

- `docs/quality/bar.md` states what a tool must be able to prove before it is called done, and every item on it names the check that proves it.
- The Au3Check baseline only ever shrinks, enforced rather than encouraged.
- A single command answers whether all fourteen tools still start, render, and exit cleanly.
- A tool that drifts from the house style is caught by a check rather than by a reviewer's memory.

**Adjacency:** list=applicable @ D07 T01 §3; document=applicable @ D07 T01 §1; settings=not-applicable (the quality checks have no tunable a user changes; their thresholds are decisions recorded in the bar itself); reporting=applicable @ D07 T01 §3; notifications=not-applicable (a local check notifies nobody; CI notification waits for a runner); permissions=applicable @ D07 T01 §1; audit=applicable @ D07 T01 §2; exchange=not-applicable (nothing here reads or writes a third-party format); reverse=not-applicable (a check changes nothing, so there is nothing to undo)

**Adjacency rationale:** Audit is §2 and it is the point of the ratchet: the baseline file is the committed record of what this repository has accepted and when, so its diff is the audit trail for every quality decision made here. Permissions lands on §1 rather than on a check, because "what does this tool do without elevation" is an item on the bar every tool must answer, and a bar that omits it would let seven tools pass while failing on a user's machine. Settings and reverse are the two honest not-applicables: a threshold in the bar is a decision recorded in prose, not a value a user tunes, and a read-only check has no undo.

## Implementation Order

| Order | Section | Deliverable                                | Depends On | Status |
| :---: | :-----: | ------------------------------------------ | ---------- | :----: |
|   1   |   §1    | The bar: what done means for a tool        | --         |  [ ]   |
|   2   |   §2    | Warning ratchet that only goes down        | §1, D00 T01 §2 |  [ ]   |
|   3   |   §3    | Standing smoke run and its report          | §1, D00 T02 §5 |  [ ]   |
|   4   |   §4    | House-style conformance check              | §1, D00 T02 §3 |  [ ]   |

---

## 1. The Bar: What Done Means for a Tool

Fourteen tools, fourteen different ideas of finished. Without a written bar, "is this tool done" is answered by whoever is asked, and the answer moves. This section writes it down, and it writes it as checks rather than as aspirations, because a bar nothing measures is a mission statement.

- [ ] Write `docs/quality/bar.md` with one row per requirement and, for each, the command or artifact that proves it. Done when: every row names a check, and no row says "should" without naming what refuses it. Cheaper substitute: a list of principles with no check named, which cannot fail and therefore cannot pass.
- [ ] Include the requirements this tree has already established: Au3Check clean against the baseline, builds both architectures, settings through the shared contract in an `.ini`, every action logged, every user-visible string from the language layer, a documentation directory, a language pack, elevation refused by name, and every destructive action reversible or honestly declared irreversible. Done when: all nine appear with their proving check.
- [ ] Add the surface requirements: every control working or deferred to a named section, and the rendered surface compared against a capture. Done when: both appear and name `review-todo-section` as their enforcer.
- [ ] Score all 14 tools against the bar as of today and commit the result as `docs/quality/scorecard.md`. Done when: every tool has a row, every cell is pass, fail, or not-applicable with a reason, and the fails match the measured current state rather than an estimate.
- [ ] File each fail that has no owner through `add-todo`, so the scorecard's red cells each point at a section. Done when: every fail cell names a section reference that resolves.
- [ ] State what the bar does not cover and why, so its silence is not read as approval. Done when: the exclusions are listed with reasons.
- [ ] Commit: `"quality: write the bar and score every tool against it"`

**Test checkpoint:** `docs/quality/bar.md` exists with a named check on every row, and `docs/quality/scorecard.md` scores all 14 tools. Every fail cell names a reference that `python scripts/todo-graph.py resolve` accepts without exiting 1 or 2, proven by running it over the extracted references. The resolve output is quoted in the commit body.

## 2. Warning Ratchet That Only Goes Down

`D00 T01 §2` freezes the current 847 warnings so the gate can be switched on without failing on day one. That is a starting position, not a resting place. This section makes the number a one-way count and drives it down where it is cheapest to do so.

- [ ] Enforce the direction: the gate fails when the baseline grows, and `-UpdateBaseline` refuses to add entries unless an override flag is passed and the reason is recorded in the commit. Done when: adding a warning and running `-UpdateBaseline` without the override fails and names the new entries.
- [ ] Record the current count in `docs/quality/scorecard.md` as the starting figure with its date, so progress is measurable rather than remembered. Done when: the figure and date are recorded and match a fresh sweep.
- [ ] Clear the 54 `'Local' specifier in global scope` warnings across the concrete tools, the class with the most mechanical fix. Done when: the class is zero repo-wide and the baseline shrank by 54. Cheaper substitute: suppressing the warning level.
- [ ] Clear the 4 deprecated `Dim` declarations repo-wide. Done when: `grep -rn "^\s*Dim " SDK/` returns nothing and the class is zero.
- [ ] Triage the 610 `already declared/assigned` warnings into deliberate guards and real duplicates, and record the split. Done when: the split is recorded per file, and the deliberate ones carry a reason in the baseline.
- [ ] File the remaining classes as their own work with owners rather than fixing them here. Done when: each remaining class has a section reference that resolves.
- [ ] Commit: `"quality: make the warning baseline one-way and clear the mechanical classes"`

**Test checkpoint:** `pwsh scripts/au3check-all.ps1` exits 0 and reports zero warnings of the `'Local' specifier in global scope` and deprecated `Dim` classes repo-wide. The baseline diff shows removals only. Adding a warning and running `-UpdateBaseline` without the override flag exits non-zero naming the new entries. All three outputs are quoted in the commit body.

## 3. Standing Smoke Run and Its Report

`D00 T02 §5` builds the smoke run. This section turns it into something that happens rather than something that exists, and makes its output the thing a person reads when asking whether the suite is healthy.

**Needs:** Windows host (build/test)

- [ ] Make the smoke run part of `scripts/check-all.ps1` behind a switch, since it needs built executables and a desktop session. Done when: `-Smoke` runs it and the default run says clearly that it was skipped and why.
- [ ] Publish the report at a stable path, `docs/reports/smoke-latest.md`, alongside the dated ones, so there is one place to look. Done when: a run updates both and the stable file names the run's date and commit.
- [ ] Make the report readable as a status, not a log: one line per tool with started, window found, closed cleanly, and the capture path, and a summary line at the top. Done when: a reader can answer "is the suite healthy" from the first line.
- [ ] Record per-tool history so a tool that fails intermittently is visible as intermittent rather than as a one-off. Done when: three runs produce a history table showing all three outcomes per tool.
- [ ] Make the release build require a passing smoke run, so a red suite cannot ship. Done when: a failing smoke run makes `scripts/release.ps1` refuse and name the failing tool.
- [ ] Commit: `"quality: run the suite smoke check and publish its report"`

**Test checkpoint:** `pwsh scripts/check-all.ps1 -Smoke` runs all 14 tools and updates `docs/reports/smoke-latest.md`, whose first line answers the health question and whose body names every tool. Three consecutive runs produce a history table with three outcomes per tool. A deliberately broken tool makes `scripts/release.ps1` refuse and name it. All three outputs are quoted in the commit body.

## 4. House-Style Conformance Check

Fourteen tools share one SDK, and the way that stops being true is one tool at a time: a private progress bar here, a second About dialog there, each one reasonable on its own. A reviewer cannot hold fourteen surfaces in memory. A check can.

**Fidelity:** this section builds no surface of its own. It compares other tools' surfaces against `docs/captures/house-style/`.

- [ ] Add `scripts/style-conformance.ps1` reporting, per tool, which shared includes it consumes and which shared behavior it implements privately instead. Done when: it reports a per-tool table and flags any tool defining a function whose name matches a shared include's entry point. Cheaper substitute: checking only the `#include` lines, which passes a tool that includes the file and then ignores it.
- [ ] Flag the specific drifts this suite is prone to: a private progress bar, a private About dialog, a private settings writer, a private log format, a private message dialog. Done when: all five checks run and a scratch tool with a private progress bar is flagged.
- [ ] Compare each tool's rendered main window against the house-style capture as part of the smoke run, and report differences rather than failing on them, because a legitimate difference exists and a check that cries wolf gets muted. Done when: the smoke report carries a per-tool difference note and the approved-deviation list is honored.
- [ ] Keep the approved-deviation list in `docs/captures/house-style/README.md` as the single place a deviation is recorded, and make the check read it. Done when: adding an entry to the list silences exactly that difference and nothing else.
- [ ] Add the conformance result to the scorecard so drift is visible beside the other measures. Done when: the scorecard gains a column and all 14 tools have a value in it.
- [ ] Commit: `"quality: check every tool against the house style"`

**Test checkpoint:** `pwsh scripts/style-conformance.ps1` reports all 14 tools with their consumed includes and flags a scratch tool carrying a private progress bar. Adding that difference to the approved-deviation list silences it and nothing else. The scorecard's conformance column is populated for all 14 tools. All three outputs are quoted in the commit body.

## Verification

- [ ] `docs/quality/bar.md` names a check for every requirement, and every fail on `docs/quality/scorecard.md` names a section that resolves
- [ ] `pwsh scripts/au3check-all.ps1` exits 0 and the baseline has shrunk against its recorded starting figure
- [ ] `pwsh scripts/check-all.ps1 -Smoke` runs all 14 tools and publishes `docs/reports/smoke-latest.md`
- [ ] `pwsh scripts/style-conformance.ps1` reports all 14 tools with no unapproved drift
- [ ] `python scripts/todo-graph.py validate` clean
