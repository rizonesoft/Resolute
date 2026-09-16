---
schema_version: 1
id: memboost-trim-and-surface
domain: 05-memboost
status: draft
title: "TODO-01 -- MemBoost Trim and Surface"
depends_on: []
frozen: true
track: M1
---

# TODO-01 -- MemBoost Trim and Surface

> **Goal:** MemBoost's working-set trim does exactly what it does today, provably, and everything around it is honest: every one of its nineteen settings has a consumer, its tray and notification behavior matches what the settings promise, and its live statistics are measured rather than estimated. The trim itself is frozen, because it reaches into every process on the machine and a change to what it computes is a change to somebody's running system.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** `SDK/Concrete/MemBoost/MemBoost.au3` is 2,625 lines at version 11.1.1.2429 and is the most actively developed tool in the suite; the last eight commits on this repository are MemBoost fixes to label colors, redraw stability, progress-bar geometry, and tray tooltips. It writes settings correctly to `MemBoost.ini`, which currently carries nineteen keys including `AutoOptimize`, `AutoOptimizeSeconds=60`, `ForceBehave`, `AlwaysOnTop`, `ShowNotifications`, `PlaySounds`, `PlayWarnings`, `WarnEvery=60`, `WarnIfLoad=80`, `StartWithWindows`, and `StartMinimized`. It includes `Logging.au3`, but at line 314 with doubled backslashes where every other consumer uses single. The optimize path is `_OptimizeMemory()` at line 1518 with `_ReduceMemory()` at 1735 and `_IsMemoryIncreasing()` at 1717. There are 21 tray, sound, and notification call sites. There are no tests. Au3Check reports 0 errors and 54 unique warnings for this file. `Resolute/Language/MemBoost/` exists; `Resolute/Docs/MemBoost/` does not.

## Inputs

- [`SDK/Concrete/MemBoost/MemBoost.au3`](../../SDK/Concrete/MemBoost/MemBoost.au3) -- the tool; every section here changes it
- [`Resolute/MemBoost.ini`](../../Resolute/MemBoost.ini) -- the nineteen settings §2 audits for consumers
- [`Resolute/Sounds/`](../../Resolute/Sounds) -- the sound assets `PlaySounds` and `PlayWarnings` promise
- -> XREF: [`01-sdk-core/TODO-01 §4`](../01-sdk-core/TODO-01-shared-include-contracts.md) -- the logging contract, and the include-form fix this tool needs
- -> XREF: [`00-workspace/TODO-02 §4`](../00-workspace/TODO-02-test-backbone.md) -- the driven-run driver every checkpoint here uses
- -> XREF: [`08-docs-localization/TODO-01 §1`](../08-docs-localization/TODO-01-docs-and-localization.md) -- the missing `Resolute/Docs/MemBoost/` directory

## Outcome

- The trim path is pinned by a freeze check, so a refactor cannot quietly change what it does to a running system.
- Every setting in `MemBoost.ini` has a named consumer, proven by changing the value and observing the behavior.
- The tray icon, notifications, sounds, and warnings do what the settings say they do, including when turned off.
- The memory and CPU figures on the surface are measured from a named source and match an independent reading.

**Adjacency:** list=applicable @ D05 T01 §4; document=not-applicable (MemBoost shows live state and files nothing a user carries; its history is the log); settings=applicable @ D05 T01 §2; reporting=applicable @ D05 T01 §4; notifications=applicable @ D05 T01 §3; permissions=applicable @ D05 T01 §1; audit=applicable @ D05 T01 §1; exchange=applicable @ D05 T01 §2; reverse=applicable @ D05 T01 §1

**Adjacency rationale:** Reverse anchors on §1 and the honest answer is recorded there rather than invented: trimming a working set has no undo button, because the operating system pages memory back in as processes need it, and the section states that on the surface instead of implying a reversible operation. Permissions is §1 for the same reason it matters most there: trimming another user's process needs privilege the tool may not have, and the per-process refusal is part of the frozen behavior. List and reporting pair on §4 because the process list and the statistics are the same data seen twice, and a figure a user cannot trace to a source is the defect that section closes. Exchange sits with settings on §2: `MemBoost.ini` is hand-edited by users often enough that malformed input is a real path.

## Implementation Order

| Order | Section | Deliverable                                    | Depends On | Status |
| :---: | :-----: | ---------------------------------------------- | ---------- | :----: |
|   1   |   §1    | Pin the trim path with a freeze check          | D00 T02 §2, D01 T01 §4 |  [ ]   |
|   2   |   §2    | Every setting has a proven consumer            | §1         |  [ ]   |
|   3   |   §3    | Tray, notifications, sounds, and warnings      | §2         |  [ ]   |
|   4   |   §4    | Live statistics measured, not estimated        | §1         |  [ ]   |

---

## 1. Pin the Trim Path with a Freeze Check

MemBoost reaches into every process on the machine and asks Windows to trim its working set. It is the most-edited file in this repository and the least protected: eight of the last ten commits touched it, none of them could have been checked against anything, and a refactor that changes which processes are skipped would not be noticed until a user's application stalled.

**Fidelity:** no surface change in this section. The optimization view, progress bar, and statistics panel stay exactly as the recent commits left them, and the pre-change capture is the proof.
**Job:** a user can reclaim memory from running processes and know which ones were skipped and why. Consumer: the log line, and the result shown on the surface.
**Treatment:** the process selection and the trim call pinned against a fixture so a refactor that changes the effect fails, plus a per-process outcome. Cheaper substitute that fails the checkpoint: reporting a total reclaimed figure with no per-process outcome, which cannot distinguish a successful trim from a silently skipped one.
**Chrome:** consume `SDK/Includes/ProcessEx.au3`, `SDK/Includes/Logging.au3`, and `SDK/Includes/GDIPlusProgressBar.au3`.
**Needs:** Windows host (build/test)

- [ ] Fix the include form at `MemBoost.au3:314` to the single-backslash `"..\..\Includes\Logging.au3"` every other consumer uses. Done when: the line matches the other eight consumers character for character and the tool still builds to both architectures.
- [ ] Record the current selection rule: which processes `_OptimizeMemory()` acts on, which it skips, and why, read from the code at lines 1518, 1717, and 1735 rather than from memory. Done when: the rule is written into this section with its line references.
- [ ] Add `tests/memboost-trim.test.au3` asserting the selection rule against a process-list fixture, with no live trim. Done when: the assertion distinguishes an included process from a skipped one, and changing the rule in a scratch copy makes it fail. Cheaper substitute: asserting that the function returns without error.
- [ ] Record the per-process outcome: trimmed, skipped with a reason, or refused for privilege, and log each through `_Logging_Action`. Done when: a driven run produces one outcome per process it considered, and the counts add up to the process count.
- [ ] Prove the privilege case: a process the tool cannot open is reported as refused rather than counted as trimmed. Done when: a driven unelevated run reports refusals and the total reclaimed excludes them.
- [ ] State on the surface that a trim is not reversible by the tool and that memory returns as processes need it, in the language layer with an English default. Done when: the statement renders on the optimization view and reads as a fact rather than a warning.
- [ ] Commit: `"memboost: pin the trim selection rule and report every process outcome"`

**Freeze check:** `AutoIt3.exe tests/run-tests.au3 --filter memboost-trim` reproduces the recorded selection rule against `tests/fixtures/memboost/process-list.json`, process for process. What MemBoost trims, and what it skips, does not change in this section; any change to the selection or the trim call needs operator approval recorded here. Fixture source: `tests/fixtures/memboost/`.

**Test checkpoint:** `AutoIt3.exe tests/run-tests.au3 --filter memboost-trim` exits 0, and altering the selection rule in a scratch copy makes it fail. A driven run of the built tool produces one logged outcome per process considered, with the counts adding up, quoted in the commit body. An unelevated driven run reports refusals and excludes them from the reclaimed total.

## 2. Every Setting Has a Proven Consumer

`MemBoost.ini` carries nineteen keys. A setting nothing reads is worse than no setting at all, because the user changes it, observes no difference, and concludes the tool is broken. This section checks each one by changing it and watching.

- [ ] List all nineteen keys with the function that reads each, from `_LoadConfiguration()` at line 1402 and its callers. Done when: every key has a named reader or is marked as having none.
- [ ] For each key with a reader, prove the consumer by changing the value and observing the behavior on a driven run. Done when: nineteen observations are recorded, each naming what changed on screen or in behavior. Cheaper substitute: confirming the value is read into a variable, which proves nothing about whether anything uses it.
- [ ] For each key with no consumer, decide: wire it to the behavior it promises, or remove it and say so here. Done when: every orphan has a dated decision with the cost of changing it, and none is left undecided.
- [ ] Prove the write path: each setting changed in the UI is written through the shared contract and survives a restart. Done when: a driven run changes three settings across three different panels, restarts, and reads all three back.
- [ ] Handle a hand-edited file: a malformed value produces the default plus a logged warning, and the user's file is not overwritten. Done when: a fixture `.ini` with `AutoOptimizeSeconds=abc` yields the default and leaves the file's other lines byte-identical.
- [ ] Add the settings assertions to the harness: default fallback, malformed value, and round trip. Done when: three assertions run.
- [ ] Commit: `"memboost: prove a consumer for every setting"`

**Freeze check:** The trim behavior itself does not change here. The evidence is that the §1 trim assertion still passes unchanged after this section's edits, quoted in the stamp. Fixture source: `tests/fixtures/memboost/`.

**Test checkpoint:** The nineteen-key table is complete with an observation per key, quoted in the commit body. `AutoIt3.exe tests/run-tests.au3 --filter memboost-settings` exits 0 with three assertions, including the malformed-value assertion proving the user's file is unchanged. A driven run changes three settings, restarts, and reads all three back from `MemBoost.ini`.

## 3. Tray, Notifications, Sounds, and Warnings

There are 21 tray, sound, and notification call sites and four settings that claim to control them: `ShowNotifications`, `PlaySounds`, `PlayWarnings`, `WarnEvery`, and `WarnIfLoad`. The failure mode is a tool that keeps beeping after a user turned sounds off, which is the kind of defect that gets a tool uninstalled.

**Fidelity:** the tray icon, its tooltip, its menu, and the notification balloon, against `docs/captures/house-style/` and the recent tray-tooltip work already in this repository. Layout is unchanged; behavior is what this section proves.
**Job:** a user is told when memory is low or an optimization finished, in the way they chose, and is not told when they chose silence. Consumer: the settings from §2, read at the moment of notifying rather than at startup.
**Treatment:** every notification path checked against its setting at the point of use, with the off case proven for each. Cheaper substitute that fails the checkpoint: reading the setting once at startup, so turning notifications off mid-session has no effect until a restart.
**Chrome:** consume `SDK/Includes/Messages.au3` for dialogs, the existing tray implementation, and `Resolute/Sounds/` for audio. Do not add a second notification path.
**Needs:** Windows host (build/test)

- [ ] Enumerate all 21 call sites and map each to the setting that governs it. Done when: every site has a governing setting or is listed as ungoverned with a decision.
- [ ] Check the setting at the point of use, not at startup, for every site. Done when: toggling `ShowNotifications` mid-session changes the next notification without a restart.
- [ ] Prove the off case for each of `ShowNotifications`, `PlaySounds`, and `PlayWarnings`: with each set to 0, the corresponding output does not occur. Done when: three driven runs each prove silence.
- [ ] Prove `WarnIfLoad=80` and `WarnEvery=60` are honored: a simulated load above the threshold warns once per interval, not continuously. Done when: a driven run at a simulated 85 percent load produces exactly one warning in the interval.
- [ ] Prove the tray menu: every item on it is working or deferred to a named section, including the ones the recent tooltip work touched. Done when: the account covers every item and each deferral resolves.
- [ ] Confirm each sound file the settings promise exists in `Resolute/Sounds/`, and handle a missing file as a logged warning rather than a crash. Done when: removing one sound file produces the warning and the tool continues.
- [ ] Commit: `"memboost: honor every notification setting at the point of use"`

**Freeze check:** The trim behavior does not change here; the §1 assertion still passes unchanged, quoted in the stamp. Fixture source: `tests/fixtures/memboost/`.

**Test checkpoint:** Three driven runs with `ShowNotifications=0`, `PlaySounds=0`, and `PlayWarnings=0` each produce no corresponding output, quoted. A driven run at a simulated 85 percent load with `WarnIfLoad=80` and `WarnEvery=60` produces exactly one warning in the interval. Toggling `ShowNotifications` mid-session changes the next notification without a restart. A removed sound file produces a logged warning and no crash. The tray menu account is complete.

## 4. Live Statistics Measured, Not Estimated

The surface shows memory and CPU figures, and recent commits have been fixing how they are drawn. What has not been established is where the numbers come from and whether they are right, which is the part a user actually relies on when deciding whether to optimize.

**Fidelity:** the statistics panel and the memory and CPU rows, against `docs/captures/house-style/` and the current build, whose geometry the recent commits deliberately set. This section does not move anything.
**Job:** a user can see current memory and CPU load and trust the figures enough to act on them. Consumer: the user's decision to optimize, and the warning threshold in §3.
**Treatment:** every displayed figure traced to a named API or counter and compared against an independent reading. Cheaper substitute that fails the checkpoint: a figure derived from a previous figure plus an assumption, which drifts without ever looking wrong.
**Chrome:** consume `SDK/Includes/CompInfo.au3`, `SDK/Includes/GDIPlusProgressBar.au3`, and `SDK/Includes/FFLabels.au3`. Do not add a second progress bar or label style.
**Needs:** Windows host (build/test)

- [ ] Name the source of every displayed figure: total, used, available, committed, and CPU, from `_UpdateMemoryStats()` at line 1060 and `_GetCPUUsage()` at line 1178. Done when: each figure names the API or counter it comes from.
- [ ] Compare each against an independent reading taken at the same moment. Done when: a driven run records the tool's figures beside a reading from a second source and the differences are within a stated tolerance.
- [ ] State the refresh interval and prove the figures update at it. Done when: a driven run over three intervals shows three distinct readings and the interval matches the stated value.
- [ ] Make the process list findable: a user can see which processes hold the memory, sorted, without knowing a process name. Done when: the list renders, sorts, and its top entry matches an independent reading.
- [ ] Account for the surface: every control, label, and bar on the statistics panel is working or deferred to a named section. Done when: the account covers the panel and each deferral resolves.
- [ ] Confirm the panel matches the capture after the change, since the recent commits set this geometry deliberately. Done when: the rendered panel is compared against the pre-change capture and any difference is listed and approved.
- [ ] Commit: `"memboost: trace every displayed figure to a measured source"`

**Freeze check:** The trim behavior does not change here; the §1 assertion still passes unchanged, quoted in the stamp. Fixture source: `tests/fixtures/memboost/`.

**Test checkpoint:** A driven run records the tool's memory and CPU figures beside an independent reading taken at the same moment, with the differences inside the stated tolerance and both sets quoted. Three consecutive readings over three refresh intervals are distinct. The process list's top entry matches the independent reading. The rendered panel is compared against the pre-change capture.

## Verification

- [ ] `pwsh scripts/au3check-all.ps1` exits 0 with no new warnings from `MemBoost.au3`
- [ ] `pwsh scripts/build.ps1 MemBoost` builds both architectures
- [ ] `AutoIt3.exe tests/run-tests.au3 --filter memboost` exits 0 with the trim, settings, and statistics suites reporting
- [ ] Every freeze check in this file ran and passed, with its result quoted in the covering stamp
- [ ] Every one of the nineteen settings in `MemBoost.ini` has a recorded consumer or a dated removal decision
- [ ] `python scripts/todo-graph.py validate` clean
