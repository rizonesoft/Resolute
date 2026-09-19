---
schema_version: 1
id: launcher-surfaces
domain: 03-launcher
status: draft
title: "TODO-02 -- Launcher Surface Specification"
depends_on: []
track: P1
---

# TODO-02 -- Launcher Surface Specification

> **Goal:** Every launcher surface is specified control by control before it is built: what it shows, what each control does, where every string comes from, and, for every AutoIt control, whether it is kept, cut with a reason, or remapped to its new home. `D03 T01` builds from this file; nothing it renders is invented at build time.

> [!IMPORTANT]
> **Current state:** Nothing exists in C++. The AutoIt launcher is `resolute_au3/SDK/Concrete/Resolute/Resolute.au3` (2,663 lines): a taskbar-clone start bar with a start button, CPU/RAM/disk meters, lock-key lights, and a clock; a 9-menu 54-item start-menu cascade; a main window with a System Repair group, an 11-icon System Tools group, a 22-icon Power Tools group, and a status list; a tray icon; and a 3-tab Preferences dialog. Its strings live in `resolute_au3/Resolute/Language/Resolute/en.lng` (UTF-16), and its menu cascade is largely hardcoded English. The C++ direction in `D03 T01` is a hub, not a shell: this file records what survives that change and why.

<!-- claim: lines resolute_au3/SDK/Concrete/Resolute/Resolute.au3 = 2663 -->
<!-- claim: count "_GuiCtrlMenuEx_CreateMenuItem" resolute_au3/SDK/Concrete/Resolute/Resolute.au3 = 54 -->
<!-- claim: exists resolute_au3/Resolute/Language/Resolute/en.lng -->

## Inputs

- [`resolute_au3/SDK/Concrete/Resolute/Resolute.au3`](../../resolute_au3/SDK/Concrete/Resolute/Resolute.au3) -- the launcher being specified, control by control
- [`resolute_au3/Resolute/Language/Resolute/en.lng`](../../resolute_au3/Resolute/Language/Resolute/en.lng) -- the string source; UTF-16, sections `[Menus]`, `[Preferences]`, `[Messages]`
- [`DESIGN.md`](../../DESIGN.md) -- the contract every kept surface is rebuilt under; the AutoIt windows are behavior reference only
- -> XREF: [`03-launcher/TODO-01 §1`](./TODO-01-launcher.md) -- the build that consumes this specification

## Outcome

- Every AutoIt launcher control is kept, cut with a dated reason, or remapped to a named new home, and the account is complete.
- Every C++ launcher surface names its controls, its strings with their pack source, its states, and its empty and failure presentations.
- No shipped surface carries a placeholder, a hardcoded string, or a control whose behavior was invented at build time.

**Adjacency:** list=applicable @ D03 T02 §3; document=not-applicable (the launcher produces no document a user carries; the tools do); settings=applicable @ D03 T02 §7; reporting=applicable @ D03 T02 §2; notifications=applicable @ D03 T02 §7; permissions=applicable @ D03 T02 §7; audit=applicable @ D03 T02 §5; exchange=not-applicable (nothing is imported or exported here); reverse=not-applicable (launching a tool changes nothing that needs undoing)

**Adjacency rationale:** List anchors on §3 because the tool list is the record surface a user browses in the hub direction. Settings, notifications, and permissions converge on §7 because the launcher's own page, its notices, and its elevation indicator are one chrome surface. Reporting anchors on §2 where the status list shows repair outcomes, and audit on §5 where the suite log viewer reads them back. Document, exchange, and reverse stay not-applicable: the launcher carries no document, imports nothing, and undoes nothing.

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Start bar and start-menu cascade map | -- |  [ ]   |
|   2   |   §2    | Main content and repair groups | -- |  [ ]   |
|   3   |   §3    | Tool list surface | -- |  [ ]   |
|   4   |   §4    | System locations browser | -- |  [ ]   |
|   5   |   §5    | Suite log viewer surface | -- |  [ ]   |
|   6   |   §6    | Symptom search surface | -- |  [ ]   |
|   7   |   §7    | Launcher chrome and notices | -- |  [ ]   |

---

## 1. Start Bar and Start-Menu Cascade Map

The AutoIt launcher opens as a taskbar clone (`Resolute.au3:739-820`): a start button opening a 9-menu cascade (`:823-839`, 54 items), CPU and RAM bar meters with percentage labels, a disk bar with a free-space label, Caps/Num/Scroll lock lights, elevation, architecture, and removable-drive icons, and a clock plus date that update on timers. The C++ launcher is a hub window, not a shell, so this section maps every one of those controls to kept, cut, or remapped, and enumerates the cascade menu by menu with the same verdict per item.

**Fidelity:** the launcher window frame and its menus, against `DESIGN.md` sections 8 and 11.
**Job:** a user reaches every kept behavior from the hub without hunting through a cascade. Consumer: the menus and indicators `D03 T01 §1` builds.
**Treatment:** the cascade is flattened into its honest homes (tool list, system locations, Help menu) rather than ported as a cascade. Cheaper substitute that fails the checkpoint: porting the 9-menu cascade as-is, which preserves fifty unlocalized strings and a navigation shape the hub direction exists to replace.
**Chrome:** consume the framework window, popup menu, and status bar. No custom-drawn meters.

- [ ] Verdict the start-bar indicators: start button, both usage meters with their percentage labels, the disk bar with its free-space label, the three lock lights, the elevation, architecture, and removable-drive icons, and the clock plus date. Done when: each carries keep, cut, or remapped with a dated reason; the recorded direction cuts the meters, lights, and clock (the Windows taskbar owns them and a second copy is not a launcher feature), keeps the elevation state as a status-bar indicator, and remaps the start button to the hub window itself. Cheaper substitute that fails the checkpoint: cutting without a reason, which lets the next reader re-litigate every control.
- [ ] Verdict the cascade menu by menu: File, Accessories, Administration, Maintenance, Hardware, Optimize, Repair, Security, System, Development, and Help, all 54 items walked from `Resolute.au3:827-` to the cascade end. Done when: every item names its target (shell CLSID, tool launch, dialog, or URL) and carries keep, cut, or remapped; shell locations remap to §4, tool launches remap to §3, and hardcoded-English items are cut or given pack strings because `DESIGN.md` §11 forbids hardcoded strings.
- [ ] Specify the File menu kept behaviors: Preferences, the Logging submenu (open log file, open log directory), Minimize, and Close with its Alt+F4 accelerator. Done when: each names its pack key from `[Menus]`, its enabled states, and what it does, quoted against `en.lng`.
- [ ] Specify the Help menu kept behaviors: update check, publisher home, downloads, support, issue creation, and About, each with its URL or dialog target. Done when: every target is named and the Donate item carries the `D01 T03 §7` verdict rather than a second decision. Cheaper substitute that fails the checkpoint: specifying the Help menu without targets, which ships six dead entries.
- [ ] Specify the tray icon verdict and the minimize behavior. Done when: the icon, its Minimize and Close items, the tooltip, and double-click restore each carry keep or cut with a dated reason; the recorded direction cuts the tray (taskbar progress per `D01 T02 §4` replaces its one live function) and keeps minimize as ordinary window minimize.
- [ ] Commit: `"launcher-spec: start bar and cascade map"`

**Test checkpoint:** Every control in `Resolute.au3:739-820` and every one of the 54 cascade items carries a verdict, and a walk of the source finds none unaccounted. Every kept string names its pack key. Every cut names its reason and its reversal cost. Cheaper substitute that fails the checkpoint: verdicts for the menus but not the items, which leaves fifty behaviors undecided.

-> XREF: D03 T01 §1 -- the build that consumes this map

## 2. Main Content and Repair Groups

Below the start bar the AutoIt main window carries a heading block (program name plus version, subheading, tool description: `Resolute.au3:946-952`), a System Repair group with three buttons (Scan System Files, Check Health (Dism), Restore Health: `:960-968`), an 11-icon System Tools group (`:971-990`, tooltips only on Command Prompt and Registry Editor) with a 6-item System context menu (`:995-1011`, one item commented out), a 22-icon Power Tools group (`:1013-1031`) whose icons read "Coming Soon!", and a single-column Courier New status list with 7 state icons (`:1033-1051`). This section verdicts every group and specifies what the hub shows instead.

**Fidelity:** the launcher main content, against `DESIGN.md` and `docs/captures/house-style/`.
**Job:** a user sees what the launcher offers and what it just did. Consumer: the main content `D03 T01 §1` builds.
**Treatment:** repair actions move to the repair library and tools move to the list; the main window keeps identity, status, and navigation. Cheaper substitute that fails the checkpoint: keeping the icon grids, which preserves twenty-two "Coming Soon!" promises and tooltips on two of eleven icons.
**Chrome:** consume the framework window, list surface, and status bar. No icon grids with tooltip-only labels.

- [ ] Verdict the heading block and the System Repair group. Done when: the heading (name, version, subheading, description) is kept with its string sources named, and all three repair buttons remap to `D05 T01 §2` (Complete Windows Repair owns repairs without a topical home) with the launcher carrying no repair behavior of its own.
- [ ] Verdict the System Tools group icon by icon, all 11 with their launch targets, plus the 6-item System context menu with the commented-out item called out as dead. Done when: every icon names its target and remaps to §3 (tool launches) or §4 (shell locations); no icon survives as an icon.
- [ ] Verdict the Power Tools group icon by icon, all 22. Done when: every icon names its target or is recorded as a Coming-Soon placeholder, and every placeholder is cut: a distribution-ready launcher ships no disabled promises. Cheaper substitute that fails the checkpoint: remapping placeholders to a "coming soon" list, which ships the same promise in a new control.
- [ ] Specify the status list: columns, state icons with their meanings, font and color via tokens (never Courier New hardcoded), selection, copy, and clearing. Done when: all 7 AutoIt states map to named statuses with icons, and the empty state is specified.
- [ ] Specify the main-window layout: heading, content region, and status region with their resize behavior and minimum size. Done when: the layout names its regions, every region's behavior at the minimum size, and the `DESIGN.md` §5 rules it follows.
- [ ] Commit: `"launcher-spec: main content and repair groups"`

**Test checkpoint:** All 3 repair buttons, all 11 System Tools icons, all 22 Power Tools icons, all 6 context items, and all 7 list states carry verdicts, and a walk of `Resolute.au3:946-1051` finds none unaccounted. The specified layout names every region and its minimum-size behavior. Cheaper substitute that fails the checkpoint: a layout without the verdicts, which lets cut controls drift back in at build time.

-> XREF: D03 T01 §1 -- the build that consumes this content spec

## 3. Tool List Surface

The hub's record surface: every installed tool found, listed, and launchable, per the `D03 T01 §2` direction. This section specifies the list at control level: rows, columns, states, the filter, the retired-product presentation, and every empty and failure presentation. Nothing here is ported pixel-for-pixel; the AutoIt icon grids are the behavior reference for what "installed" and "launchable" must mean.

**Fidelity:** the tool list, against `DESIGN.md` and `docs/captures/house-style/`.
**Job:** a user sees what is installed and starts any of it. Consumer: the rendered list `D03 T01 §2` builds.
**Treatment:** rows with name, version, and state, probed from the executables, never a fixed table. Cheaper substitute that fails the checkpoint: specifying the columns without the states, which ships a list that cannot say a tool is missing.
**Chrome:** consume the framework list surface with virtualization. No second list implementation.

- [ ] Specify the row: tool icon (the per-tool Rizonesoft asset), name, version read from the executable, state, and launch affordance, with the keyboard path to each. Done when: every row element names its source, and the version source rule (executable, never a table) is stated.
- [ ] Specify the states: installed and launchable, installed but not launchable with its reason, not found with its last-seen record, and retired with its successor named. Done when: each state names its icon, its text with pack source, and what clicking the row does.
- [ ] Specify the filter: placement, matching rule, clearing, result count, and the no-match presentation. Done when: the matching rule is exact (substring, case behavior, which fields) and the no-match text names its pack key.
- [ ] Specify the empty and failure presentations: no tools installed, discovery in progress, and discovery failed. Done when: each names its text, its action (if any), and its pack source; no state renders a bare empty list. Cheaper substitute that fails the checkpoint: one "no tools" string covering all three, which tells a user with a failed probe that they installed nothing.
- [ ] Commit: `"launcher-spec: tool list surface"`

**Test checkpoint:** Every row element names its source; all four states name icon, text, and click behavior; the filter rule is exact; all three empty and failure presentations name text and action. The `D03 T01 §2` checklist can be built from this section with no invented control. Cheaper substitute that fails the checkpoint: a row spec without states, which is a picture of a list rather than a specification.

-> XREF: D03 T01 §2 -- the build that consumes this list spec

## 4. System Locations Browser

The searchable catalog of Windows system locations per the `D03 T01 §4` direction, fed by the remapped cascade items from §1 and the remapped System Tools icons from §2. This section specifies the browser: the list, the search, the entry presentation, and the failure presentation when a location will not open.

**Fidelity:** the locations browser, against `DESIGN.md`; new surface, no AutoIt baseline beyond the cascade items it absorbs.
**Job:** a user reaches a Windows system location without knowing its CLSID. Consumer: the browser `D03 T01 §4` builds and the launched shell location.
**Treatment:** a curated catalog with localized names, each entry verified to open. Cheaper substitute that fails the checkpoint: specifying the browser without the failure presentation, which ships silent nothing-happens for every dead CLSID.
**Chrome:** consume the framework list surface and message layer. No new dialog.

- [ ] Specify the entry: display name with pack source, description or hint, category, icon, and the launch affordance, with the keyboard path. Done when: every element names its source and the category set is fixed.
- [ ] Specify the search: placement, matching rule across names and categories, clearing, result count, and the no-match presentation naming the pack key. Done when: the rule is exact and a search that matches nothing says so with its next step.
- [ ] Specify the failure presentation: a location that will not open names itself, says what was attempted, and logs one line. Done when: the message text names its pack key and the log-line rule is stated.
- [ ] Commit: `"launcher-spec: system locations browser"`

**Test checkpoint:** Every entry element names its source; the search rule is exact with a specified no-match; the failure message names its pack key and the log rule. The `D03 T01 §4` checklist can be built from this section with no invented control. Cheaper substitute that fails the checkpoint: an entry spec without categories, which ships an ungrouped wall of locations.

-> XREF: D03 T01 §4 -- the build that consumes this browser spec

## 5. Suite Log Viewer Surface

One place to read fourteen tools' logs, per the `D03 T01 §5` direction. The AutoIt suite has no viewer (Logging offers open-file and open-directory only), so this section specifies the new surface whole: the reading view, the three filters, the malformed-log presentations, and the export.

**Fidelity:** the log viewer, against `DESIGN.md` and `docs/captures/house-style/`; new surface, no AutoIt baseline.
**Job:** a user or support reader reads every tool's log in one place, filtered to their question. Consumer: the viewer `D03 T01 §5` builds and the exported view.
**Treatment:** one view over the shared log format, so a new tool appears without the viewer changing. Cheaper substitute that fails the checkpoint: a viewer that opens one tool's log at a time, which is the AutoIt behavior with a window around it.
**Chrome:** consume the framework window, list surface, and message layer. No per-tool parser.

- [ ] Specify the reading view: line layout (timestamp, tool, severity, message), monospace machine values per `DESIGN.md` §4, text selection and copy, and the follow-tail behavior with its toggle. Done when: every element is named and the follow rule states what pauses it.
- [ ] Specify the three filters (tool, severity, date): placement, control shapes, combining rule, clearing, and the filtered-empty presentation. Done when: the combining rule is exact and clearing restores the full view.
- [ ] Specify the degraded inputs: a missing, empty, or malformed log each renders a stated result naming the tool, never an error dialog. Done when: all three name their text with pack sources.
- [ ] Specify the export: trigger, file naming, atomic write with readback, format matching the rendered view, and the success and failure notices. Done when: the format is fixed and both notices name their pack keys. Cheaper substitute that fails the checkpoint: an export that writes whatever the view holds without naming its format, which produces files no support reader can rely on.
- [ ] Commit: `"launcher-spec: suite log viewer surface"`

**Test checkpoint:** The reading view names line layout, copy, and the follow rule; all three filters name placement, combining, and clearing; all three degraded inputs name their text; the export names format, naming, and both notices. The `D03 T01 §5` checklist can be built from this section with no invented control. Cheaper substitute that fails the checkpoint: filters without a combining rule, which ships three filters that disagree.

-> XREF: D03 T01 §5 -- the build that consumes this viewer spec

## 6. Symptom Search Surface

The search that routes "my machine does X" to the tool that fixes it, per the `D03 T01 §6` direction. New surface, no AutoIt baseline. This section specifies the input, the results, the ranking presentation, the no-match presentation, and the repair-item routing presentation.

**Fidelity:** the search and results surface, against `DESIGN.md` and `docs/captures/house-style/`; new surface.
**Job:** a user who can describe their problem reaches the right tool without knowing its name. Consumer: the search `D03 T01 §6` builds and the launched tool.
**Treatment:** symptoms declared by each tool, matched on plain words, ranked by a recorded rule. Cheaper substitute that fails the checkpoint: results without ranking reasons, which ships an ordering nobody can explain or fix.
**Chrome:** consume the framework input and list surfaces. No bespoke search control.

- [ ] Specify the input: placement, placeholder text with pack source, matching rule (plain words, case and stemming behavior), minimum length, and the keyboard path from anywhere in the launcher. Done when: the rule is exact and the global shortcut is named.
- [ ] Specify the result row: tool icon and name, the matched symptom text with its pack source, the ranking reason shown per row, and the launch affordance. Done when: every element is named and the reason display rule is exact.
- [ ] Specify the no-match presentation: the text naming its pack key, the diagnostic tools offered, and what launching one does with the query. Done when: an unmatched search never renders an empty list.
- [ ] Specify the repair-item routing: when no whole tool owns a symptom, the result names the owning tool and item (e.g. the Complete Windows Repair item) and launching opens that item, not just the tool. Done when: the presentation rule and the deep-launch contract are both stated. Cheaper substitute that fails the checkpoint: routing to the tool's front door, which answers "printer not working" with a window and no printer.
- [ ] Commit: `"launcher-spec: symptom search surface"`

**Test checkpoint:** The input names rule, placeholder, and shortcut; every result element is named with the reason rule exact; the no-match presentation names text and diagnostics; the item-routing contract states presentation and deep launch. The `D03 T01 §6` checklist can be built from this section with no invented control. Cheaper substitute that fails the checkpoint: a results spec without the item-routing contract, which strands every symptom no whole tool owns.

-> XREF: D03 T01 §6 -- the build that consumes this search spec

## 7. Launcher Chrome and Notices

Everything the launcher owns around its content: its Preferences page in the framework dialog, its first-run behavior, its elevation indicator and declined-elevation text, its launch-failure texts, its closing confirmation, and its language-restart notice. String sources are the `[Messages]` and `[Preferences]` pack sections plus the framework message layer from `D01 T03 §1`.

**Fidelity:** the launcher chrome and notices, against `DESIGN.md` §11; notices reuse the framework message dialog, no new dialog.
**Job:** a user is told what happened in terms that suggest what to do. Consumer: the notices `D03 T01 §3` shows and the prefs page it hosts.
**Treatment:** every failure cause carries its own named message; declined elevation is an outcome, not an error. Cheaper substitute that fails the checkpoint: one generic failure string with the cause interpolated, which reads as well and localizes half as well.
**Chrome:** consume the framework message layer, prefs host, and status bar. No launcher-drawn dialog.

- [ ] Specify the launcher Preferences page: its controls, their defaults, and their setting keys through the framework writer. Done when: every control names its key and default, and no launcher setting bypasses the writer.
- [ ] Specify first-run: settings migration notice (if any), update-check behavior per the shipped default, and what the window shows before discovery completes. Done when: each names its text or its deliberate silence with a reason.
- [ ] Specify the launch-failure texts: corrupted executable, missing file, and declined elevation, each with its own message, title, pack key, and log line. Done when: all three are named and declining elevation returns to the launcher with nothing left running.
- [ ] Specify the closing confirmation and the language-restart notice from the `[Messages]` and `[Preferences]` pack sections. Done when: both name their pack keys, their buttons, and the do-not-ask-again rule (or its deliberate absence with a reason). Cheaper substitute that fails the checkpoint: confirmations without stated buttons, which ship OK/Cancel on a question that needs Close/Minimize.
- [ ] Specify the elevation indicator: placement in the status bar, elevated and non-elevated presentations, and its tooltip text with pack source. Done when: both states are named and the indicator never blocks content.
- [ ] Commit: `"launcher-spec: chrome and notices"`

**Test checkpoint:** Every prefs control names key and default; first-run names text or deliberate silence; all three failure texts name message, title, key, and log line; both confirmations name keys and buttons; both elevation states are named. The `D03 T01 §3` checklist can be built from this section with no invented string. Cheaper substitute that fails the checkpoint: failure texts without log lines, which tell the user and hide it from support.

-> XREF: D03 T01 §3 -- the build that consumes this chrome spec

## Verification

- [ ] Every AutoIt launcher control carries keep, cut with reason, or remapped to a named home
- [ ] Every specified surface names its controls, strings with pack sources, states, and empty and failure presentations
- [ ] No specified surface carries a placeholder, a hardcoded string, or an unlocalized cascade item
- [ ] Every `D03 T01` build section can be built from its spec section with no invented control
- [ ] `python scripts/todo-graph.py validate` clean
