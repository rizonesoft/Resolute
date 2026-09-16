---
schema_version: 1
id: shared-include-contracts
domain: 01-sdk-core
status: draft
title: "TODO-01 -- Shared Include Contracts"
depends_on: []
track: S1
---

# TODO-01 -- Shared Include Contracts

> **Goal:** `SDK/Includes/` is the reason this suite is a suite. Every shared behavior a tool needs -- settings, logging, localization, elevation, update, the About dialog -- has exactly one implementation there, with a stated contract, and every tool consumes it rather than carrying its own copy. When this file is done, fixing a shared bug means fixing one file, and a new tool inherits the house behavior by including it.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** `SDK/Includes/` holds 27 `.au3` files totalling roughly 13,000 lines. The contracts are real but undocumented and unevenly consumed. Concrete gaps measured today: **seven tools write their settings to `<Tool>.lng` instead of `<Tool>.ini`** (`ComIntRep.au3:348,1164`, `DVDRepair.au3:306,824`, `Ownership.au3:301,888`, `PixRepair.au3:305,1155`, `ReBar.au3`, `Resolute.au3:435,1889`, `USBRepair.au3`), which is why `Resolute/Resolute.lng` currently contains `[Resolute] PortableEdition=1` while `Resolute/Resolute.ini` holds the rest. **Five tools include no `Logging.au3` at all** (`BiosCodes`, `Chromin`, `Edgemin`, `Firemin`, `Watermin`), so five of fourteen tools leave no trace. `MemBoost.au3:314` includes `Logging.au3` with doubled backslashes where every other tool uses single. All 14 tools carry `#RequireAdmin`, but only the four browser tools ever call `IsAdmin()`. Au3Check at `-w 1..7` attributes 13 warnings to `Localization.au3`, 10 to `Update.au3`, 8 to `Donate.au3`, 4 to `GuiMenuEx.au3`, and 3 each to `Logging.au3` and `Icons.au3`.

## Inputs

- [`SDK/Includes/Logging.au3`](../../SDK/Includes/Logging.au3) -- 22 functions, the suite's audit trail; §4 states its contract and closes the five-tool gap
- [`SDK/Includes/Localization.au3`](../../SDK/Includes/Localization.au3) -- 8 functions including `_Localization_Load`; §5 states its contract
- [`SDK/Includes/Update.au3`](../../SDK/Includes/Update.au3) and [`SDK/Includes/Versioning.au3`](../../SDK/Includes/Versioning.au3) -- §6 states their contract
- [`SDK/Includes/About.au3`](../../SDK/Includes/About.au3) -- the shared About dialog every tool renders; captured by `D00 T02 §3`
- -> XREF: [`00-workspace/TODO-02 §3`](../00-workspace/TODO-02-test-backbone.md) -- the house-style captures this file's surfaces are checked against
- -> XREF: [`02-launcher/TODO-01 §1`](../02-launcher/TODO-01-resolute-launcher.md) -- the launcher is the first consumer of the settings contract §3 writes
- -> XREF: [`03-system-tools/TODO-01 §1`](../03-system-tools/TODO-01-system-tool-repairs.md) -- six of the seven misfiled settings paths are repaired there against this contract
- -> XREF: [`04-browser-tools/TODO-01 §1`](../04-browser-tools/TODO-01-browser-tool-consolidation.md) -- the shared browser core is extracted into this directory under these contracts
- -> XREF: [`08-docs-localization/TODO-01 §2`](../08-docs-localization/TODO-01-docs-and-localization.md) -- the language coverage matrix consumes the localization contract §5 states

## Outcome

- Each shared include carries a header block stating what it owns, what it assumes, and which tools consume it, and `docs/sdk/includes.md` lists the same map in one place.
- Settings have one writer, one path, and one file extension across every tool in the suite.
- Every tool logs, and a destructive action that writes no log line fails review.
- No user-facing string is hardcoded where a `.lng` key exists for it.
- A tool that needs elevation and does not have it says so and refuses, rather than failing halfway through a system change.

**Adjacency:** list=applicable @ D01 T01 §1; document=not-applicable (the SDK renders no printed or saved document; tools that do own it themselves); settings=applicable @ D01 T01 §3; reporting=applicable @ D01 T01 §4; notifications=applicable @ D01 T01 §7; permissions=applicable @ D01 T01 §7; audit=applicable @ D01 T01 §4; exchange=applicable @ D01 T01 §3; reverse=applicable @ D01 T01 §3

**Adjacency rationale:** This file owns the shared behavior behind most of the nine keys, which is why so few are not-applicable. Settings, exchange, and reverse all land on §3 because they are one mechanism seen from three sides: the contract writes the value, the `.ini` is a file format somebody else may author or edit by hand, and a settings write that cannot be undone or reset to default is the reverse case. Audit and reporting both land on §4: the log is the audit trail, and the log viewer and its export are the report over it. Permissions and notifications land on §7 together because elevation refusal is only useful if the user is told, so the refusal path and the way it announces itself are one decision. Document is the only clean not-applicable: the SDK draws surfaces, it does not produce a document a user carries, and the one tool that prints is out of scope here.

## Implementation Order

| Order | Section | Deliverable                                       | Depends On | Status |
| :---: | :-----: | ------------------------------------------------- | ---------- | :----: |
|   1   |   §1    | Include inventory and consumer map                | --         |  [ ]   |
|   2   |   §2    | Declaration hygiene across `SDK/Includes/`        | §1, D00 T01 §2 |  [ ]   |
|   3   |   §3    | Settings contract: one writer, one path           | §1, D00 T02 §1 |  [ ]   |
|   4   |   §4    | Logging contract and the five silent tools        | §1, D00 T02 §1 |  [ ]   |
|   5   |   §5    | Localization contract: no hardcoded UI strings    | §1, D00 T02 §1 |  [ ]   |
|   6   |   §6    | Update and version contract                       | §1, D00 T02 §1 |  [ ]   |
|   7   |   §7    | Elevation contract and its refusal path           | §1, §4, D00 T02 §3 |  [ ]   |

---

## 1. Include Inventory and Consumer Map

Nobody can say today which tools depend on which include, so nobody can say what a change to `Icons.au3` breaks. This section answers that once, in a file that stays true because a later section checks it. It is deliberately the first row: every other section in this file needs to know who its consumers are before it changes a contract.

- [ ] Generate the consumer map: for each file in `SDK/Includes/`, the tools whose `.au3` includes it, derived by parsing `#include` lines under `SDK/Concrete/`. Done when: the map covers all 27 includes and all 14 tools, and names includes with zero consumers. Cheaper substitute: a hand-written list, which is wrong the first time somebody adds an include.
- [ ] Add `scripts/include-map.ps1` producing that map as markdown, so it is regenerated rather than maintained. Done when: running it twice produces identical output, and the output names `UDF/Localization.au3` as a duplicate of `Includes/Localization.au3` if it still is one.
- [ ] Write `docs/sdk/includes.md` from the generated map, with a one-line purpose for each include written by reading it. Done when: every include has a purpose line that names its main entry point, and no line says "utilities".
- [ ] Add a header block to each include naming what it owns, what globals it assumes the host script declared, and what it must not be used for. Done when: all 27 files carry the block and the assumed globals are the ones Au3Check actually reports as already-declared.
- [ ] Record the unresolved questions as dated defaults rather than blockers: which of `Localization.au3` under `Includes/` and under `UDF/` is canonical, and whether `Icons.au3` is still consumed. Done when: each has a recorded default, the reason, and the cost of changing it.
- [ ] Commit: `"sdk-core: inventory every shared include and map its consumers"`

**Test checkpoint:** `pwsh scripts/include-map.ps1` exits 0 and its output matches the committed `docs/sdk/includes.md` byte for byte; adding an `#include` to a scratch copy of a tool changes the map. Both outputs are quoted in the commit body.

## 2. Declaration Hygiene Across `SDK/Includes/`

Au3Check attributes a small but concentrated share of the repo's 847 warnings to the shared includes, and those are the ones that multiply: a warning in `About.au3` is re-reported by all 14 tools. Fixing the shared layer first is what makes the tool-level numbers in `D07 T01 §2` meaningful rather than noise.

- [ ] Fix the `'Local' specifier in global scope` warnings in `SDK/Includes/` by promoting each to `Global` or moving it inside the function that uses it, one include at a time. Done when: the Au3Check sweep reports zero of that class from any file under `SDK/Includes/`. Source: the 54 occurrences measured 2026-09-16.
- [ ] Fix the `declared, but not used in func` warnings in `SDK/Includes/` by removing the declaration or using it, never by suppressing the check. Done when: the class is zero for `SDK/Includes/` and no `#AutoIt3Wrapper_Au3Check_Parameters` was weakened to achieve it. Cheaper substitute: lowering the warning level until the output is quiet.
- [ ] Replace the 4 deprecated `Dim` declarations with `Local` or `Global` as the scope requires. Done when: `grep -rn "^\s*Dim " SDK/Includes/` returns nothing and the class is zero.
- [ ] Triage the `already declared/assigned` warnings from the shared includes: the `If Not IsDeclared(...) Then Global ...` guards in `About.au3:60-62` are deliberate and stay, so record them as accepted in `scripts/au3check-baseline.txt` with the reason, and fix the rest. Done when: every remaining occurrence from `SDK/Includes/` is either fixed or carries a written reason.
- [ ] Shrink `scripts/au3check-baseline.txt` by exactly the keys this section fixed, and prove the count moved. Done when: the baseline diff shows only removals and the sweep still exits 0.
- [ ] Re-run the consumer map's tools: build two tools that consume the changed includes and confirm both still compile. Done when: `Resolute` and `MemBoost` build to both architectures after the change.
- [ ] Commit: `"sdk-core: clear declaration warnings from the shared includes"`

**Test checkpoint:** `pwsh scripts/au3check-all.ps1` exits 0 and reports zero warnings of classes `'Local' specifier in global scope`, `declared, but not used in func`, and deprecated `Dim` originating from any file under `SDK/Includes/`; the baseline file shrank and its diff contains no additions; `pwsh scripts/build.ps1 Resolute` and `pwsh scripts/build.ps1 MemBoost` both succeed. All outputs are quoted in the commit body.

## 3. Settings Contract: One Writer, One Path

Seven of fourteen tools write their settings to a file named `.lng`, which is the extension this suite uses for language packs. The result is live today: `Resolute/Resolute.lng` holds `[Resolute] PortableEdition=1` while `Resolute/Resolute.ini` holds `ProcessPriority`, `LoggingEnabled`, and the rest. Two files, two writers, one user wondering why a setting did not stick. This section writes the contract; the tool-level repairs are owned by their own domains and depend on this row.

- [ ] Add `SDK/Includes/Settings.au3` owning the settings path and every read and write: `_Settings_Init($sShortName)`, `_Settings_Read($sSection, $sKey, $sDefault)`, `_Settings_Write($sSection, $sKey, $vValue)`, `_Settings_Path()`. Done when: the path is derived in exactly one place and always ends in `.ini`. Cheaper substitute: a helper that computes the path but lets callers keep their own `IniWrite`.
- [ ] Make the write atomic and read back what it wrote: write to a temporary file beside the target, verify the value, then replace. Done when: killing the process between write and replace leaves the original file intact and parseable. Source: the `FileEx.au3` helpers already in `SDK/Includes/`.
- [ ] Provide the migration: when `<ShortName>.lng` exists in the settings location and holds sections that are not language data, copy those values into `<ShortName>.ini`, leave the `.lng` in place, and log what moved. Done when: a fixture `.lng` carrying `[Resolute] PortableEdition=1` produces an `.ini` with the same value and a log line naming both files. The `.lng` is not deleted, because a language pack may legitimately share the name.
- [ ] Add the reverse: `_Settings_Reset($sSection)` restoring a section to its defaults, and prove the round trip. Done when: writing a value, resetting, and reading returns the default rather than the written value.
- [ ] Treat the `.ini` as a file somebody else may have edited: a malformed or unreadable file produces defaults plus a logged warning, never a crash and never a silent overwrite of the user's file. Done when: a fixture `.ini` with a truncated section still yields defaults and leaves the file on disk unchanged.
- [ ] Write the contract into the include header and into `docs/sdk/includes.md`: one writer, `.ini` only, atomic, read back, migration is one-way. Done when: both say the same thing and name `_Settings_Path` as the only path authority.
- [ ] Add `tests/settings.test.au3` covering write-readback, atomic replace, migration, reset, and the malformed-file path. Done when: all five assertions run under the harness.
- [ ] Commit: `"sdk-core: one settings writer, one path, one file extension"`

**Test checkpoint:** `AutoIt3.exe tests/run-tests.au3 --filter settings` exits 0 with five assertions reported; the migration assertion is driven from a fixture `.lng` containing `[Resolute] PortableEdition=1` and proves the value lands in the `.ini` with a log line naming both files; the malformed-file assertion proves the original bytes are unchanged after the read. Outputs are quoted in the commit body.

## 4. Logging Contract and the Five Silent Tools

`Logging.au3` is this suite's audit trail: 22 functions, log levels, a log file per tool under `Resolute/Logging/`. Five tools do not include it, and four of those five are the browser optimizers that terminate and restart a user's browser. An action that changes a user's system and leaves no trace cannot be supported after the fact.

- [ ] State the contract in the include header: what gets a log line (every destructive action, every refusal, every failure), what must never be logged (paths that contain credentials, full registry value data), and which function to call for each level. Done when: the header names all five `__Logging_Validate*` levels and gives one example call each.
- [ ] Fix `MemBoost.au3:314` to use the single-backslash include form every other tool uses. Done when: the include line matches the other 8 consumers character for character and MemBoost still compiles to both architectures.
- [ ] Add a `_Logging_Action($sTool, $sAction, $sTarget, $bSucceeded)` entry point for the one line a destructive action owes, so a tool does not have to compose it. Done when: a call produces a single line carrying tool, action, target, and outcome, and the format is documented in the header.
- [ ] Wire `BiosCodes` to the logging include and log its one observable action. Done when: running the built tool produces a log file under `Resolute/Logging/` naming the action. The four browser tools are a separate case and are owned by their own domain, which depends on this row.
- [ ] Add the log-size guard's contract: `Resolute.ini` already carries `LoggingStorageSize=5242880`, so state that the setting is the consumer-facing control and prove `Logging.au3` reads it. Done when: a fixture setting a small size causes rotation, proving the value is read rather than ignored. Cheaper substitute: documenting the setting without checking anything reads it.
- [ ] Add `tests/logging.test.au3` covering a written line, the action line's shape, the rotation trigger, and the refusal to log a redacted field. Done when: all four assertions run under the harness.
- [ ] Commit: `"sdk-core: state the logging contract and give BiosCodes a trace"`

**Test checkpoint:** `AutoIt3.exe tests/run-tests.au3 --filter logging` exits 0 with four assertions; a driven run of the built `BiosCodes.exe` produces a log file under `Resolute/Logging/` whose content is quoted; `grep -c 'Includes\\\\Logging.au3' SDK/Concrete/MemBoost/MemBoost.au3` returns 0 after the include-form fix. Outputs are quoted in the commit body.

## 5. Localization Contract: No Hardcoded UI Strings

`Localization.au3` provides `_Localization_Load($sSection, $sKey, $sDefault)` and a set of section loaders, and the suite ships translations for several tools. It is undermined by strings written directly into the surface code: the launcher alone creates 54 menu items, of which 41 carry a literal English string. A translation that cannot reach the menu is a translation nobody sees.

- [ ] State the contract in the include header: every user-visible string comes from `_Localization_Load` with an English default, keys are stable, and a default is the fallback rather than the source of truth. Done when: the header says so and names the `.lng` layout it expects.
- [ ] Add `scripts/find-hardcoded-strings.ps1` reporting literal strings passed to GUI-creating calls across `SDK/Concrete/`, with a per-tool count. Done when: it reports the launcher's 41 literal menu items and produces a per-tool table. Cheaper substitute: grepping for quotes, which reports every path and format string in the repo.
- [ ] Commit the baseline report as `docs/reports/hardcoded-strings.md` so the number is diffable and the tool-level sections can be measured against it. Done when: the report exists and its totals match the script's output.
- [ ] Add `_Localization_Missing()` reporting keys a surface asked for that the active `.lng` does not define, so a partial translation is visible rather than silent. Done when: loading a fixture `.lng` missing a key produces a report entry and the English default still renders.
- [ ] Decide and record the fallback chain as a dated default: selected language, then `en.lng`, then the in-code default. Done when: the decision is written into this section with the cost of changing it, and a fixture proves all three legs.
- [ ] Add `tests/localization.test.au3` covering the three-leg fallback, the missing-key report, and the `_Localization_ReplaceVar` substitution. Done when: three assertions run under the harness.
- [ ] Commit: `"sdk-core: state the localization contract and measure the hardcoded strings"`

**Test checkpoint:** `AutoIt3.exe tests/run-tests.au3 --filter localization` exits 0 with three assertions, including a fixture `.lng` that omits a key and still renders the English default while reporting the key as missing; `pwsh scripts/find-hardcoded-strings.ps1` reports 41 literal menu strings for `Resolute.au3`, matching the count measured 2026-09-16. Outputs are quoted in the commit body.

## 6. Update and Version Contract

`Update.au3` checks for a newer version and `Versioning.au3` reports the current one, and between them they decide what a user is told about the software they are running. The failure mode worth preventing is an update check that fails silently, leaving a user on an old build believing they are current.

- [ ] State the contract in both include headers: where the version comes from, what the check contacts, what it does on failure, and what it never does without the user asking. Done when: both headers answer all four, and `_SoftwareUpdateCheck($iMenuSource)`'s two modes (startup and user-invoked) are distinguished.
- [ ] Make a failed check visible when the user asked for it and quiet when it was automatic, and log both. Done when: a check against an unreachable host shows a message in user-invoked mode, shows nothing in startup mode, and writes a log line in both.
- [ ] Confirm the version reported to the user comes from the compiled resource rather than a constant in the script, and fix it where it does not. Done when: `_GetProgramVersion` is what the About dialog shows, and a rebuild with a bumped `.sni` version changes the displayed string without a source edit. Source: `#AutoIt3Wrapper_Res_Fileversion` in each tool, and `Version=` in each `.sni`.
- [ ] Record the version-drift rule: the `.sni` `Version=` and the script's `#AutoIt3Wrapper_Res_Fileversion` are expected to differ by one build during development, and the release build reconciles them. Done when: the rule is written here and `D06 T01 §5` is named as its enforcer.
- [ ] Add `tests/update.test.au3` covering the unreachable-host path in both modes and the version-source assertion. Done when: three assertions run under the harness with no network dependency, using a fixture endpoint.
- [ ] Commit: `"sdk-core: state the update and version contract and prove the failure path"`

**Test checkpoint:** `AutoIt3.exe tests/run-tests.au3 --filter update` exits 0 with three assertions; the unreachable-host assertions prove a visible message in user-invoked mode and none in startup mode, with a log line in both. Outputs are quoted in the commit body.

## 7. Elevation Contract and Its Refusal Path

All 14 tools carry `#RequireAdmin`, which means Windows prompts before the script runs and the script assumes it won. Only the four browser tools ever call `IsAdmin()`. So the suite's answer to "what happens when elevation is declined" is currently "the process does not start", which is right for some tools and wrong for the ones that have useful read-only functions. More importantly, no tool re-checks before the action itself, which is the check that matters.

**Fidelity:** the refusal notice uses the suite's existing message dialog from `SDK/Includes/Messages.au3`, matching the About dialog's chrome captured in `docs/captures/house-style/`. No new dialog style.
**Job:** a user who declines elevation, or runs a tool from a context that cannot elevate, is told which action needs which privilege instead of watching a system change fail halfway. Consumer: the tool-level destructive paths in `D03 T01` and `D05 T01`, which call the refusal rather than assuming admin.
**Treatment:** a re-check immediately before the privileged call, not only at startup, with a named message. Cheaper substitute that fails the checkpoint: relying on `#RequireAdmin` at startup and assuming the privilege is still held at action time.
**Chrome:** consume `SDK/Includes/Messages.au3` and `SDK/Includes/Logging.au3`. Do not invent a second message dialog or a second log format.

- [ ] Add `_Elevation_Require($sAction)` to a shared include: returns true when the process can perform the action, and otherwise shows the named message, logs the refusal, and returns false. Done when: the function exists, is called with an action name, and never itself performs the action.
- [ ] State the contract in the header: `#RequireAdmin` is the startup gate, `_Elevation_Require` is the action gate, and every destructive path calls the second one. Done when: the header says so and names the destructive paths that owe the call.
- [ ] Add the refusal message with a `.lng` key and an English default naming the action and the privilege. Done when: the message renders from the `.lng` and falls back to English, proven against a fixture.
- [ ] Log every refusal through `_Logging_Action` with `$bSucceeded` false. Done when: a refused action produces exactly one log line naming the action and the reason.
- [ ] Account for the surface: the refusal dialog is the only control this section adds. Its button set, its title, and its icon come from `Messages.au3`; nothing else on any tool's surface changes here. Done when: the rendered dialog is captured and compared against the house-style capture, and the capture is committed under `docs/captures/`.
- [ ] Add `tests/elevation.test.au3` proving the refusal path without elevation: the action is not performed, the message is produced, and the log line exists. Done when: three assertions run under the harness in an unelevated session.
- [ ] Commit: `"sdk-core: gate every privileged action at the action, not only at startup"`

**Test checkpoint:** In an unelevated session, `AutoIt3.exe tests/run-tests.au3 --filter elevation` exits 0 with three assertions proving the action was refused, the message shown, and one log line written naming the action. The rendered refusal dialog is captured and compared against `docs/captures/house-style/`. Outputs and the capture path are quoted in the commit body.

## Verification

- [ ] `pwsh scripts/au3check-all.ps1` exits 0 with zero warnings from `SDK/Includes/` outside the accepted, reasoned entries
- [ ] `AutoIt3.exe tests/run-tests.au3` exits 0 with the settings, logging, localization, update, and elevation suites all reporting
- [ ] `docs/sdk/includes.md` regenerates identically from `scripts/include-map.ps1`
- [ ] Every tool builds to both architectures after the shared-include changes
- [ ] `python scripts/todo-graph.py validate` clean
