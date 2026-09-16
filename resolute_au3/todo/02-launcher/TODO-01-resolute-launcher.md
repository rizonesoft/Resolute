---
schema_version: 1
id: resolute-launcher
domain: 02-launcher
status: draft
title: "TODO-01 -- Resolute Launcher"
depends_on: []
track: L1
---

# TODO-01 -- Resolute Launcher

> **Goal:** `Resolute.exe` is the front door to the suite, and it behaves like one: it stores its settings where every other tool stores theirs, its menu speaks the user's language, it tells the user what happened when a tool will not start, and every action it takes leaves a trace. A user who only ever opens Resolute should be able to reach and run every tool in the suite from it.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** `SDK/Concrete/Resolute/Resolute.au3` is 2,663 lines and builds `Resolute.exe` / `Resolute_X64.exe` at version 23.2.0.857. It sets its settings path to `$g_sRootDir & "\" & $g_sProgShortName & ".lng"` at line 435 and again at line 1889, so settings land in `Resolute/Resolute.lng` (which currently holds `[Resolute] PortableEdition=1` and a `[Donate]` section) while `Resolute/Resolute.ini` separately holds `ProcessPriority`, `SaveRealtime`, `ReduceMemory`, `LoggingEnabled`, and `LoggingStorageSize`. It creates 54 menu items, of which 41 carry a literal English string, 12 read from the language layer, and 1 is computed at runtime by `_GetAutorunProtectionStatus()`. It includes `Logging.au3` and 13 other shared includes. Tool launching goes through `_ExecuteResoluteTool(<ShortName>, <Display Name>)`, with one wrapper function per tool (`_StartUSBRepair`, `_StartBiosCodes`, and so on). The menu still lists tools whose availability is never checked before launch.

## Inputs

- [`SDK/Concrete/Resolute/Resolute.au3`](../../SDK/Concrete/Resolute/Resolute.au3) -- the launcher; every section here changes it
- [`Resolute/Resolute.ini`](../../Resolute/Resolute.ini) and [`Resolute/Resolute.lng`](../../Resolute/Resolute.lng) -- the split settings state §1 reconciles
- [`Resolute/Language/Resolute/`](../../Resolute/Language/Resolute) -- the launcher's existing language packs, which §2 extends
- -> XREF: [`01-sdk-core/TODO-01 §3`](../01-sdk-core/TODO-01-shared-include-contracts.md) -- the settings contract §1 consumes, and the localization contract §2 consumes
- -> XREF: [`00-workspace/TODO-02 §4`](../00-workspace/TODO-02-test-backbone.md) -- the driven-run driver every checkpoint in this file uses
- -> XREF: [`03-system-tools/TODO-01 §1`](../03-system-tools/TODO-01-system-tool-repairs.md) -- the same settings-path defect, repaired in the six system tools

## Outcome

- The launcher reads and writes its settings through one contract, in one file, and a value set in the UI survives a restart.
- Every menu item renders from the language layer, so a translated `.lng` translates the whole menu.
- Launching a tool that is missing, blocked, or fails to start produces a named message and a log line instead of silence.
- Every launcher action is traceable in `Resolute/Logging/`.

**Adjacency:** list=applicable @ D02 T01 §3; document=not-applicable (the launcher prints nothing and files nothing; the tools it starts own their own output); settings=applicable @ D02 T01 §1; reporting=applicable @ D02 T01 §4; notifications=applicable @ D02 T01 §3; permissions=applicable @ D02 T01 §5; audit=applicable @ D02 T01 §4; exchange=applicable @ D02 T01 §1; reverse=applicable @ D02 T01 §1

**Adjacency rationale:** The launcher's list is its tool menu, and §3 is where "can the user find and reach every tool" is answered, including the ones that are not installed. Settings, exchange, and reverse converge on §1 because the settings file is also a file a user may edit by hand and must be able to reset; the migration this section performs is precisely the case where all three matter at once. Notifications is the launch-failure message rather than a tray balloon, and it belongs with the launch path in §3 because a failure nobody is told about is the defect being fixed there. Permissions is §5: the launcher runs elevated and starts tools that also request elevation, so what happens when the user declines the second prompt is a real path with a real answer.

## Implementation Order

| Order | Section | Deliverable                                   | Depends On | Status |
| :---: | :-----: | --------------------------------------------- | ---------- | :----: |
|   1   |   §1    | Settings path repair and migration            | D01 T01 §3, D00 T02 §4 |  [ ]   |
|   2   |   §2    | Menu localization for all 54 items            | D01 T01 §5, D00 T02 §3 |  [ ]   |
|   3   |   §3    | Tool discovery, launch, and failure reporting | §1         |  [ ]   |
|   4   |   §4    | Launcher logging and the log surface          | §3         |  [ ]   |
|   5   |   §5    | Elevation behavior when a launch is declined  | §3         |  [ ]   |

---

## 1. Settings Path Repair and Migration

The launcher writes its settings into `Resolute.lng`, a filename this suite uses for language packs, while `Resolute.ini` holds a different half of the same settings. Both files exist on disk right now with overlapping sections. This is the defect that makes "I changed that setting and it did not stick" a plausible bug report, and the fix is mechanical once the settings contract exists.

- [ ] Replace both assignments of `$g_sPathIni` in `SDK/Concrete/Resolute/Resolute.au3` (lines 435 and 1889) with a call to `_Settings_Init("Resolute")` from the shared contract. Done when: no line in the file composes a settings path itself, and `grep -n 'g_sProgShortName & "\.lng"' SDK/Concrete/Resolute/Resolute.au3` returns nothing. Cheaper substitute: changing `.lng` to `.ini` in two places and leaving the path logic in the tool.
- [ ] Route every `IniRead` and `IniWrite` against the settings file through `_Settings_Read` and `_Settings_Write`. Done when: the only remaining `IniRead`/`IniWrite` calls in the file are against files that are not the settings file, and each of those is commented with what it is.
- [ ] Run the migration on first start: values found in `Resolute.lng` that are settings rather than language data are copied into `Resolute.ini`, with a log line naming both files. Done when: with the current `Resolute.lng` present, a driven first run produces `PortableEdition=1` in `Resolute.ini` and a log line naming the migration.
- [ ] Keep the portable-edition behavior intact: `PortableEdition` decides whether the settings live beside the executable or under the user profile (`$g_sRootDir = $g_sAppDataRoot` at line 1900), and that decision still works after the change. Done when: both editions are driven and each writes to the expected location.
- [ ] Prove the round trip on the real surface: change a setting in the UI, close, reopen, and confirm it held. Done when: a driven run sets `ProcessPriority`, restarts the tool, and reads the same value back from `Resolute.ini`.
- [ ] Commit: `"launcher: store settings in Resolute.ini through the shared contract"`

**Test checkpoint:** A driven run of the built `Resolute.exe` against a fixture profile containing the current `Resolute.lng`: the migration writes `PortableEdition=1` into `Resolute.ini`, logs the move, and a subsequent UI change to `ProcessPriority` survives a close and reopen, read back from `Resolute.ini`. `grep -n 'g_sProgShortName & "\.lng"' SDK/Concrete/Resolute/Resolute.au3` returns nothing. Both outputs are quoted in the commit body.

## 2. Menu Localization for All 54 Items

The launcher ships language packs and then hardcodes 41 of its 54 menu strings in English. A translator can translate the About dialog and watch the menu stay English, which is worse than shipping no translation at all because it looks like the translation is broken.

**Fidelity:** the launcher's menu bar and tool menus as captured in `docs/captures/house-style/resolute-main-window.png`. Item order, separators, icons, and accelerators are unchanged by this section; only the string source changes.
**Job:** a user running a translated build reads the whole menu in their language. Consumer: `Resolute/Language/Resolute/*.lng`, which gains a key per item and is read by `_Localization_Load`.
**Treatment:** every menu string resolved through `_Localization_Load` with the current English text as its default, so an untranslated build renders exactly what it renders today. Cheaper substitute that fails the checkpoint: translating the 12 items that already read from the language layer and declaring the menu localized.
**Chrome:** consume `SDK/Includes/GuiMenuEx.au3` for item creation and `SDK/Includes/Localization.au3` for strings. Do not add a second string lookup path.

- [ ] Add a `[Menu]` section to `Resolute/Language/Resolute/en.lng` with one stable key per menu item, using the current literal text as the value. Done when: the section holds a key for each of the 41 literal items and no two keys collide.
- [ ] Replace each literal string in a `_GuiCtrlMenuEx_CreateMenuItem` call with `_Localization_Load("Menu", "<key>", "<current English text>")`. Done when: `pwsh scripts/find-hardcoded-strings.ps1` reports 0 literal menu strings for `Resolute.au3`, down from the 41 measured 2026-09-16.
- [ ] Account for every item on the surface: each of the 54 items is either localized by this section or listed here as deferred to a named section with its reason. The one item computed by `_GetAutorunProtectionStatus()` is a status string rather than a fixed label, so it is localized at its source rather than in the menu call, and this section says which it chose. Done when: the count of localized plus deferred equals 54 and every deferral names a resolving section.
- [ ] Prove the fallback: a `.lng` missing a `[Menu]` key renders the English default and reports the key as missing. Done when: a fixture `.lng` with one key removed is driven and both behaviors are observed.
- [ ] Prove a translation reaches the menu: add the same keys to one existing non-English pack and drive the launcher with it selected. Done when: the capture shows the translated menu and is committed under `docs/captures/runs/`.
- [ ] Update `Resolute/Docs/Resolute/Readme.txt` where it describes language support, in this commit. Done when: the file names the `[Menu]` section as translatable.
- [ ] Commit: `"launcher: read every menu string from the language layer"`

**Test checkpoint:** `pwsh scripts/find-hardcoded-strings.ps1` reports 0 literal menu strings for `Resolute.au3`. A driven run with a non-English pack selected captures a menu rendered in that language, compared against the house-style capture for layout; a driven run with a key removed from the pack renders the English default and reports the missing key. Both captures are committed and quoted in the commit body.

## 3. Tool Discovery, Launch, and Failure Reporting

`_ExecuteResoluteTool` starts a tool by short name. Nothing checks first whether that tool's executable is present, which architecture to prefer, or what to do when the process never appears. A user whose install is missing one tool clicks a menu item and gets nothing at all.

**Fidelity:** the tool menu and the launch-failure message, against `docs/captures/house-style/`. The failure message uses the shared message dialog, not a new one.
**Job:** a user can see which tools are available and start any of them, and is told why when one will not start. Consumer: the log written by §4, and the menu state itself.
**Treatment:** availability resolved before the item is clicked, so an unavailable tool is visibly unavailable with a reason, and a launch that fails produces a named message. Cheaper substitute that fails the checkpoint: disabling an item with no reason, which is indistinguishable from an oversight.
**Chrome:** consume `SDK/Includes/GuiMenuEx.au3`, `SDK/Includes/Messages.au3`, and `SDK/Includes/Logging.au3`.

- [ ] Add availability resolution to `_ExecuteResoluteTool`'s callers: for each tool short name, locate `<ShortName>.exe` or `<ShortName>_X64.exe` beside the launcher and record which was found. Done when: the resolution is in one function and every `_Start*` wrapper uses it.
- [ ] Prefer the 64-bit executable on a 64-bit host and fall back to the 32-bit one, recording which was chosen. Done when: both paths are driven on this host and the choice appears in the log.
- [ ] Show an unavailable tool as disabled with a reason the user can read, naming the expected filename. Done when: removing `USBRepair.exe` leaves the item disabled with a message naming the file, and the item re-enables when the file returns.
- [ ] Report a launch that fails or whose window never appears, with a named message and a log line. Done when: replacing a tool executable with a file that exits immediately produces the message and one log line rather than silence.
- [ ] Account for the surface: every one of the launcher's tool menu items is resolved to available, disabled-with-reason, or deferred to a named section. Done when: the account covers all of them and no item is disabled without a reason.
- [ ] Commit: `"launcher: resolve tool availability before launching and report every failure"`

**Test checkpoint:** A driven run with `USBRepair.exe` and `USBRepair_X64.exe` removed shows the item disabled with a message naming the expected file, and a log line; restoring the files re-enables it. A tool executable replaced by an immediate-exit stub produces the launch-failure message and exactly one log line. Both runs are captured under `docs/captures/runs/` and quoted in the commit body.

## 4. Launcher Logging and the Log Surface

The launcher already includes `Logging.au3` and already has a log-size setting in `Resolute.ini`. What is missing is the discipline that every action produces a line, and the surface that lets a user look at those lines when something went wrong.

**Fidelity:** the log view, against `docs/captures/house-style/`. If the launcher already renders a log list through `Logging.au3`'s `_Logging_EditWrite`, this section captures and keeps that surface rather than replacing it.
**Job:** a user can see what the launcher did, and open the log file or its directory, without knowing where logs live. Consumer: `Resolute/Logging/`, read back by `_Logging_OpenFile` and `_Logging_OpenDirectory`.
**Treatment:** one line per action through `_Logging_Action`, with the existing open-file and open-directory controls proven to work. Cheaper substitute that fails the checkpoint: logging only errors, which leaves a successful-but-wrong launch untraceable.
**Chrome:** consume `SDK/Includes/Logging.au3` for both the write path and the viewer. Do not add a second log format or a second viewer.

- [ ] Log every launcher action through `_Logging_Action`: tool launched, tool unavailable, launch failed, setting changed, update checked. Done when: a driven session producing all five leaves five identifiable lines.
- [ ] Prove `LoggingEnabled` and `LoggingStorageSize` from `Resolute.ini` are read and honored. Done when: setting `LoggingEnabled=0` stops the writes and a small `LoggingStorageSize` triggers rotation, both observed.
- [ ] Prove the viewer controls: open log file and open log directory both reach the current log. Done when: both are driven and the opened path matches the file the session wrote.
- [ ] Redact what the contract forbids: no full registry value data and no path containing a user credential reaches a log line. Done when: a driven case that would have logged one shows the redaction marker instead.
- [ ] Account for the surface: every control on the log view is working or deferred to a named section. Done when: the account is written and each deferral resolves.
- [ ] Commit: `"launcher: log every action and prove the log surface reaches it"`

**Test checkpoint:** A driven session performs all five logged actions and the log file contains five matching lines, quoted. `LoggingEnabled=0` produces none. A reduced `LoggingStorageSize` produces a rotation. The open-file control opens the same path the session wrote. All four are quoted in the commit body.

## 5. Elevation Behavior When a Launch Is Declined

The launcher carries `#RequireAdmin`, and so does every tool it starts. That means a user can be prompted twice, and can decline the second prompt. Today that produces nothing: no message, no log line, and a menu item that looks like it did not work.

**Fidelity:** the refusal notice, reusing the shared message dialog captured in `docs/captures/house-style/`. No new dialog.
**Job:** a user who declines a tool's elevation prompt is told which tool needed it and why nothing happened. Consumer: the log from §4.
**Treatment:** the declined case detected and reported distinctly from a launch failure, because the causes and the remedies differ. Cheaper substitute that fails the checkpoint: reporting a declined elevation as a generic launch failure.
**Chrome:** consume `SDK/Includes/Messages.au3` and `SDK/Includes/Logging.au3`, and the shared `_Elevation_Require` contract.

- [ ] Detect the declined-elevation case when starting a tool and distinguish it from the executable being missing or crashing. Done when: the three cases produce three different messages and three different log lines.
- [ ] Show the named message: which tool, which privilege, and that nothing was changed. Done when: the message names all three and renders from the language layer with an English default.
- [ ] Log the refusal through `_Logging_Action` with a false outcome. Done when: exactly one line is written and it names the tool.
- [ ] Confirm the launcher itself remains usable after a declined launch: no stuck state, no disabled menu, no orphaned process. Done when: a driven run declines a prompt and then successfully launches a different tool in the same session.
- [ ] Account for the surface: the refusal dialog is the only control added; its buttons and title come from `Messages.au3`. Done when: the rendered dialog is captured and compared against the house-style capture.
- [ ] Commit: `"launcher: report a declined elevation as its own case"`

**Test checkpoint:** A driven run declining a tool's elevation prompt produces the named message, one log line with a false outcome, and a launcher that then launches a different tool successfully in the same session. The three failure cases (declined, missing, crashed) produce three distinct messages, each quoted. The capture is committed under `docs/captures/runs/`.

## Verification

- [ ] `pwsh scripts/au3check-all.ps1` exits 0 with no new warnings from `Resolute.au3`
- [ ] `pwsh scripts/build.ps1 Resolute` builds both architectures
- [ ] `pwsh scripts/find-hardcoded-strings.ps1` reports 0 literal menu strings for `Resolute.au3`
- [ ] A driven session reaches every tool menu item and every item is available or disabled with a reason
- [ ] Settings written through the UI are readable from `Resolute/Resolute.ini` after a restart
- [ ] `python scripts/todo-graph.py validate` clean
