---
schema_version: 1
id: memboost-complete
domain: 04-tools-port
status: draft
title: "TODO-06 -- MemBoost: Complete Port and Enhancement"
depends_on: []
track: P2
---

# TODO-06 -- MemBoost: Complete Port and Enhancement

> **Goal:** MemBoost ships as a complete, distribution-ready C++ tool: the trim path and its triggers reproduced exactly, every surface and string accounted for, distribution-complete, plus fenced enhancements that make it the best memory trimmer on Windows. The build, the first-ever logging, and the trim-parity proof stay in `D04 T01 §5`; this file specifies, completes, and enhances. MemBoost is not in the frozen set, but `D04 T01 §5` pins its trim path for parity, so every enhancement below carries a non-interference re-run exactly as a frozen tool's would.

> [!IMPORTANT]
> **Current state:** Nothing exists in C++. The AutoIt tool is `resolute_au3/SDK/Concrete/MemBoost/MemBoost.au3` (2,625 lines): EmptyWorkingSet trimming over all processes with three auto modes (off, intelligent at >90% load and rising, timer countdown), an optional ForceBehave priority demote, live memory/CPU stats with peak bars, threshold warnings, a tray icon with Show/Hide/Optimize/Exit, a 4-tab Preferences dialog, and a single `en.lng` pack. The driven run and hands-on competitor use below could not be done from this host and are owed at build, owned by `D04 T01 §5`'s capture item and the enhancement sections' first items respectively.

<!-- claim: lines resolute_au3/SDK/Concrete/MemBoost/MemBoost.au3 = 2625 -->
<!-- claim: exists resolute_au3/Resolute/Language/MemBoost/en.lng -->

## Inputs

- [`resolute_au3/SDK/Concrete/MemBoost/MemBoost.au3`](../../resolute_au3/SDK/Concrete/MemBoost/MemBoost.au3) -- the tool being inventoried and completed
- [`resolute_au3/SDK/Concrete/MemBoost/MemBoost.sni`](../../resolute_au3/SDK/Concrete/MemBoost/MemBoost.sni) -- the build descriptor: what ships with it
- [`resolute_au3/Resolute/Language/MemBoost/en.lng`](../../resolute_au3/Resolute/Language/MemBoost/en.lng) -- the only pack (UTF-16); `[Custom]` holds two keys, everything else is hardcoded
- -> XREF: D04 T01 §5 -- the build this file specifies for

## Outcome

- The trim path, both auto triggers, ForceBehave, warnings, and the stats loop transfer with exact rules and the dead wiring called out.
- Every MemBoost window, control, string, setting, sound path, and shipped file is inventoried with `file:line` and mapped to framework or tool code.
- The tool ships distribution-complete: migrated settings, packs, docs, icon, installer and update entries, About, F1, guide page, tests, and a green conformance check.
- Three fenced enhancements ship (exclusion list, trim report, only-list mode), each proven non-interfering by a re-run trim fixture.
- The pinned trim effect is identical, and no enhancement changes what a default trim touches.

**Adjacency:** list=applicable @ D04 T06 §4; document=not-applicable (the trim report is a display, not a carried document; the export it deserves belongs to a future filing, not this one); settings=applicable @ D04 T06 §3; reporting=applicable @ D04 T06 §5; notifications=applicable @ D04 T06 §2; permissions=not-applicable (trimming needs no privilege the user lacks, and there is no role model); audit=not-applicable (trims leave log lines, not an audit trail); exchange=not-applicable (nothing is imported or exported here); reverse=not-applicable (freed working sets page back in on demand; there is nothing to undo)

**Adjacency rationale:** List anchors on §4 where the exclusion list is the browsed record surface, reporting on §5 where the trim report states what happened, and settings on §3 as what distribution-complete means. Notifications anchors on §2 where the inventory records the TrayTip completion and threshold warnings the port must voice. Document stays not-applicable with its future noted rather than promised. Permissions, audit, exchange, and reverse have nothing to anchor to in a trimmer.

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Trim path and trigger inventory | -- |  [ ]   |
|   2   |   §2    | Surface inventory with shared-layer map | -- |  [ ]   |
|   3   |   §3    | Distribution completeness | D04 T01 §5 |  [ ]   |
|   4   |   §4    | Editable exclusion list | D04 T01 §5 |  [ ]   |
|   5   |   §5    | Per-process trim report | D04 T01 §5 |  [ ]   |
|   6   |   §6    | Only-list trim mode | D04 T01 §5 |  [ ]   |

---

## 1. Trim Path and Trigger Inventory

The pinned behavior, quoted. `_OptimizeMemory` (`MemBoost.au3:1518-1656`): re-entry guard, manual/auto flag, countdown reset in timer mode, button disable, process-list snapshot, double stat refresh, per-process `_WinAPI_EmptyWorkingSet` skipping own PID and substring-matched exclusions, optional ForceBehave demote above Normal to Normal, 1% progress updates, 1ms sleep every 10 processes, completion TrayTip plus sound on manual only, re-enable, double stat refresh. Triggers (`_UpdateTimer`, `:1659-1716`): off, intelligent (load above 90% and `_IsMemoryIncreasing`), timer (countdown seconds then trim). Warnings (`_UpdateMemoryStats`, `:1163-1174`): every N seconds when load meets the threshold. Stats loop (`:1041-1177`): memory load, per-counter labels, CPU usage with peak bars.

**Fidelity:** no surface of its own; this section is the record parity is measured against.
**Needs:** C++ toolchain (compile)

- [ ] Pin the trim loop: snapshot order, self-PID skip, exclusion substring rule, EmptyWorkingSet call, ForceBehave demote rule (above Normal to Normal by name), progress cadence, sleep cadence, and the processed count. Done when: every step names its lines, and the lying comment (`:1577`, "only idle processes" while trimming all non-excluded) is recorded as corrected, not ported.
- [ ] Pin the triggers: intelligent mode's exact condition (load threshold plus rising check with `_IsMemoryIncreasing`'s rule quoted), timer mode's countdown and reset rule, and the manual/auto flag handoff including its reset (`:1654`). Done when: each trigger names its condition and the flag lifecycle is exact.
- [ ] Pin warnings and stats: the warning interval counter, threshold comparison, the completion TrayTip text and icon, the CPU sampling rule, and the peak-bar semantics. Done when: each names its lines; the two `.mp3` sound paths are recorded broken (never shipped per the `.sni`, which carries only `.wav`) and cut, with completion and warnings voiced through notification plus log instead.
- [ ] Record the dead and debug residue: the always-empty exclusion array (`:469`, populated nowhere), the `ConsoleWrite("DEBUG:` lines, and `build.cmd`/`build.log` (build archaeology, not scope). Done when: each carries cut with reason, except the exclusion wiring, which §4 resurrects as a fenced feature.
- [ ] Pin MemBoost's two system changes with their reverse or no-reverse verdict (groom 2026-09-23 gap scan) : `StartWithWindows` creates or removes `@StartupDir\<title>.lnk` (`MemBoost.au3:2402-2407`) and `ForceBehave` lowers other processes' priority to Normal during a trim (`:1582-1585`), and the inventory treats both as rows while the reverse reads not-applicable. Done when: the shortcut's reverse (removal on uncheck) is owned and the priority demotion carries an honest no-reverse statement shown on the surface, both recorded in the inventory.
- [ ] Commit: `"memboost: trim path and trigger inventory"`

**Test checkpoint:** Every trim step, both triggers, the flag lifecycle, warnings, TrayTip, stats, and CPU rules are quoted with lines; the lying comment, broken sounds, debug lines, and build residue carry recorded verdicts. `D04 T01 §5` can state its trim-fixture comparison from this section alone. Cheaper substitute that fails the checkpoint: the trim loop without the flag lifecycle, which cannot tell manual from automatic in the port.

-> XREF: D04 T01 §5 -- the build that proves trim parity from this inventory

## 2. Surface Inventory With Shared-Layer Map

Every MemBoost window, control, string, setting, and shipped file, with `file:line`, mapped to framework or tool code. The main window (`:702`, caption-plus-popup with minimize, no maximize): heading, three stat groups with GDI+ bars (42 graphic controls), Optimize/Preferences/Close buttons (`:980-986`, hardcoded English), status icon and label, donate strip, update animation. File/Help menus standard. Tray icon (`:1805-1833`): Show/Hide, Optimize Now, Exit, all hardcoded including the "Memory Booster" misnomer. Preferences (`:1953`, 450x500, topmost, four tabs): the three framework pages plus the tool page with 3 mode radios (`:1966-1971`, hardcoded), interval combo, warning checkboxes and combos, notification/sound/startup checkboxes.

**Fidelity:** no surface of its own; this section is the record the build renders from.
**Needs:** C++ toolchain (compile)

- [ ] Inventory the main window control by control: every stat label and bar with its update rule, all three buttons with their pack-keyed replacements, the minimize-to-tray behavior, and the restore path. Done when: every control names its strings (pack key or hardcoded-with-replacement) and the GDI+ bars map to shared progress controls.
- [ ] Inventory the tray icon and menus: the icon states, all three items with corrected pack strings (the "Memory Booster" name dies here), the double-click and hotkey behavior, and the standard File/Help items. Done when: every item names its corrected string and behavior.
- [ ] Inventory the Preferences tool page control by control: mode radios, interval combo with its values, warning controls with ranges, notification, sound, startup, always-on-top, and start-minimized checkboxes. Done when: every control names its setting key, and the tool-specific settings inventory (AutoOptimize, AutoOptimizeSeconds, ForceBehave, StartWithWindows, AlwaysOnTop, ShowNotifications, PlaySounds, PlayWarnings, WarnEvery, WarnIfLoad, StartMinimized) is complete with defaults.
- [ ] Inventory distribution inputs and map every piece: the `.sni` ship list (exe pair, ini, three docs, en pack, four `.ani` files cut, two `.wav` files cut with the broken-sound verdict), the framework-only-plus-tool `.ini` sections, and the home of every piece (window, menus, prefs host, log, update, elevation n/a with reason, About, crash, singleton, F1 to the framework; trim engine, stats loop, tray, tool page to the tool; nothing to the repair contract, recorded: trimming is not a repair with a result to undo). Done when: every shipped file carries keep, cut, or remapped, and no shared piece maps to the tool.
- [ ] Commit: `"memboost: surface inventory with shared-layer map"`

**Test checkpoint:** A walk of `MemBoost.au3` finds every control, string, setting, and shipped file recorded with verdict and home; every hardcoded string names its pack replacement; the contract exclusion is stated. Cheaper substitute that fails the checkpoint: controls without the string verdicts, which ports hardcoded English into a localizable suite.

-> XREF: D04 T01 §5 -- the build that renders from this inventory

## 3. Distribution Completeness

Everything that makes the ported tool shippable: settings migration, packs, docs, icon, installer and update entries, About, F1, guide page, tests, and conformance. Runs after `D04 T01 §5` proves parity on the core.

**Fidelity:** the tool as shipped: installer entries, docs, and About, against the AutoIt distribution.
**Job:** a user can install, run, update, and remove the tool with nothing missing. Consumer: the installed tool and its docs.
**Treatment:** every AutoIt-shipped artifact has a C++ successor or a recorded cut. Cheaper substitute that fails the checkpoint: a tool that runs from the build tree but was never installed anywhere, which is how missing files ship.
**Chrome:** consume the framework installer entries, About, and help. No tool-side installer logic.
**Needs:** Windows host (build/test)

- [ ] Migrate settings and ship the packs: an existing AutoIt `.ini` (framework keys plus the eleven tool keys) migrates with a log line; `en` ships and the pack-hygiene rules from `D08 T01 §3` hold. Done when: a fixture `.ini` migrates and the pack check passes, both quoted.
- [ ] Ship the docs set from the three templates: every template renders with generated metadata (no typed version or date) and the set matches the `D08 T01 §1` contract. Done when: all three render and the conformance check agrees.
- [ ] Register installer and update-file entries per `D06 T01 §3` and `D06 T01 §5`: portable and installed modes, the application icon, and the update descriptor. Done when: both modes install and remove cleanly on a fixture machine.
- [ ] Wire About, F1, and the guide page: About from the registry for the MemBoost descriptor, F1 through the surface map, and the user-guide page in the same commit as the behavior it documents. Done when: all three resolve and the guide page shares its commit.
- [ ] Prove tests and conformance: unit tests for the tool-specific logic (trigger conditions, exclusion matching, stats formatting) run under the harness, and the `D07 T01 §3` check passes for the tool. Done when: `ctest` names the suites green and the conformance report is quoted.
- [ ] Prove first-run and upgrade: a clean machine goes from install to working with no manual step, and a machine carrying the AutoIt MemBoost upgrades with settings preserved and one copy left. Done when: both paths are driven and quoted. Cheaper substitute that fails the checkpoint: testing upgrade by reading the code, which is how two copies ship.
- [ ] Clean the startup shortcut on uninstall and on upgrade from AutoIt (groom 2026-09-23 gap scan) : a stale `.lnk` from the AutoIt build can point at the old executable after the upgrade. Done when: uninstall removes the startup entry, the upgrade path re-points or removes an AutoIt-era shortcut, and both are proven on a fixture profile, quoted.
- [ ] Commit: `"memboost: distribution completeness"`

**Test checkpoint:** Fixture `.ini` migrates; packs pass hygiene; three docs render generated; both install modes round-trip; About, F1, and the guide page resolve; tests and conformance quote green; first-run and upgrade are driven. Cheaper substitute that fails the checkpoint: a checklist ticked from the build tree, which proves the tool compiles rather than ships.

-> XREF: D04 T01 §5 -- the parity core this section ships

## 4. Editable Exclusion List

**Deliberate new behavior.** The AutoIt exclusion array exists, is honored by the trim loop, and is populated nowhere: a feature wired to nothing. This section resurrects it as an editable list (add, remove, enable per entry, substring matching kept): games, VMs, and DAWs stay untouched while everything else trims. Empty list trims exactly as the original.

Competitor context (source-based, hands-on owed at build): CleanMem ships ignore lists plus only lists with logging and Task Scheduler runs ([source](https://techyorker.com/5-best-ram-cleaners-optimizers-for-windows-10-11/)); Wise Memory Optimizer offers one-click plus auto mode with no exclusions ([source](https://softbuzz.net/best-free-ram-optimizer-for-windows-10/)); Mem Reduct shows real-time stats, open source ([source](https://softbuzz.net/best-free-ram-optimizer-for-windows-10/)). This tool matches CleanMem's ignore lists, beats Wise on control, and beats Mem Reduct on automation it already ships.

**Fidelity:** the exclusion list surface, against `DESIGN.md`; new surface, no AutoIt baseline beyond the dead array.
**Job:** a user protects sensitive processes from trimming once and trusts it forever. Consumer: the persisted list and the skipped processes.
**Treatment:** substring matching exactly as the loop implements it, managed through add/remove/enable, persisted with the settings. Cheaper substitute that fails the checkpoint: exact-name matching, which misses every versioned executable the substring rule catches.
**Chrome:** consume the framework list surface. No new dialog beyond the row editor.
**Needs:** Windows host (build/test)

- [ ] Confirm the competitor table hands-on: run CleanMem, Wise Memory Optimizer, and Mem Reduct, verify the documented behaviors above against the named versions, and correct the table. Done when: each row names the version used and what was observed, quoted.
- [ ] Ship the editable list: add, remove, and per-entry enable with the substring rule stated on the surface, persisted atomically, honored by manual and automatic trims alike. Done when: a listed process survives a trim that trims an unlisted one, quoted, and the list survives a restart.
- [ ] Cover the finer details: empty-list presentation, tooltips, keyboard path with tab order, screen-reader names, both themes and DPI scalings, and the exact texts with pack keys. Done when: each is driven or captured, none deferred.
- [ ] Prove non-interference: the `D04 T01 §5` trim fixture re-runs identical with this section shipped and the list empty. Done when: the comparison is quoted showing no difference.
- [ ] Commit: `"memboost: editable exclusion list"`

**Test checkpoint:** Competitor rows name used versions; a listed process survives beside a trimmed one; the list persists; finer details are driven or captured; the empty-list trim fixture re-runs identical. Cheaper substitute that fails the checkpoint: exclusions honored on manual trims only, which is a list the timer ignores.

-> XREF: D04 T01 §5 -- the trim fixture this section must not disturb

## 5. Per-Process Trim Report

**Deliberate new behavior.** The AutoIt tool reports a processed count and nothing else. This section reports per process: what trimmed, what was skipped and why (self, excluded, only-list), and how much each freed, with totals. Pure reads plus display: the trim is untouched.

**Fidelity:** the trim report, against `DESIGN.md`; new presentation, no AutoIt baseline.
**Job:** a user sees what a trim did instead of trusting a count. Consumer: the report and one log line per trim.
**Treatment:** measure before and after per process; report honestly including zeroes. Cheaper substitute that fails the checkpoint: reporting freed memory from the global counter, which credits the trim with whatever else moved.
**Chrome:** consume the framework list surface. No new dialog.
**Needs:** Windows host (build/test)

- [ ] Report per process: each processed process names before/after working set and freed bytes; each skipped one names its reason; totals close against the measured delta. Done when: a fixture trim's report reconciles process by process, quoted.
- [ ] Log one line per trim with totals and duration, and keep the report reachable after the window that ran it closes. Done when: the log line names totals and the report persists per the stated rule.
- [ ] Cover the finer details: empty-report presentation, keyboard path, screen-reader names, both themes and DPI scalings, and the exact texts with pack keys. Done when: each is driven or captured, none deferred.
- [ ] Prove non-interference: the `D04 T01 §5` trim fixture re-runs identical with this section shipped. Done when: the comparison is quoted showing no difference.
- [ ] Commit: `"memboost: per-process trim report"`

**Test checkpoint:** A fixture report reconciles per process with skip reasons; the log line names totals; the report persists; finer details are driven or captured; the trim fixture re-runs identical. Cheaper substitute that fails the checkpoint: a report without skip reasons, which shows what trimmed and hides what it chose not to touch.

-> XREF: D04 T01 §5 -- the trim fixture this section must not disturb

## 6. Only-List Trim Mode

**Deliberate new behavior.** The mirror of §4 for locked-down machines: when the only-list is non-empty, trims touch listed processes and nothing else. Default empty (hence off): an empty only-list trims exactly as the original.

**Fidelity:** the only-list surface, against `DESIGN.md`; new surface, sibling to §4.
**Job:** an admin confines trimming to approved processes on a shared or sensitive machine. Consumer: the persisted list and the confined trim.
**Treatment:** non-empty only-list wins over everything except self-protection; the interaction with the exclusion list is stated on the surface (excluded beats listed, with the reason shown). Cheaper substitute that fails the checkpoint: an only-list that also trims unlisted processes "just this once", which is a mode that lies about its name.
**Chrome:** consume the framework list surface. No new dialog beyond the row editor.
**Needs:** Windows host (build/test)

- [ ] Ship only-list mode: add, remove, and per-entry enable with the substring rule, persisted atomically, honored by manual and automatic trims. Done when: with two processes listed, exactly those trim and nothing else, quoted, and emptying the list restores full trimming.
- [ ] State the list interaction on the surface: excluded beats listed, self is never trimmed, and each rule names its reason. Done when: a process on both lists is skipped with the reason shown, quoted.
- [ ] Cover the finer details: empty-list presentation, tooltips, keyboard path with tab order, screen-reader names, both themes and DPI scalings, and the exact texts with pack keys. Done when: each is driven or captured, none deferred.
- [ ] Prove non-interference: the `D04 T01 §5` trim fixture re-runs identical with this section shipped and the list empty. Done when: the comparison is quoted showing no difference.
- [ ] Commit: `"memboost: only-list trim mode"`

**Test checkpoint:** Listed-only trimming is exact with restore on empty; the both-lists case skips with reason shown; finer details are driven or captured; the empty-list trim fixture re-runs identical. Cheaper substitute that fails the checkpoint: only-list mode without the interaction rule, which leaves two lists fighting silently.

-> XREF: D04 T01 §5 -- the trim fixture this section must not disturb

## Verification

- [ ] The trim path, triggers, warnings, and stats transfer with exact rules
- [ ] Every MemBoost line is inventoried with its verdict and home
- [ ] The tool installs, runs, updates, and removes with nothing missing
- [ ] All three enhancements ship fenced with quoted non-interference trim re-runs
- [ ] The pinned trim effect is identical
- [ ] `python scripts/todo-graph.py validate` clean
