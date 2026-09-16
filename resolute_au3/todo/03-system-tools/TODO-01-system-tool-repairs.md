---
schema_version: 1
id: system-tool-repairs
domain: 03-system-tools
status: draft
title: "TODO-01 -- System Tool Repairs"
depends_on: []
frozen: true
track: T1
---

# TODO-01 -- System Tool Repairs

> **Goal:** The seven tools that change a user's system -- `ReBar`, `Ownership`, `ComIntRep`, `USBRepair`, `DVDRepair`, `PixRepair`, and `BiosCodes` -- store their settings where the rest of the suite does, prove what they write against a disposable fixture rather than a developer's machine, log every action, and can undo or refuse what they do. What these tools compute and write is frozen: restructuring is allowed, changing the effect is not, because the effect lands on somebody's registry, ACLs, or drive.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** Six of these seven tools write their settings to `<Tool>.lng` instead of `.ini`: `ComIntRep.au3:348,1164`, `DVDRepair.au3:306,824`, `Ownership.au3:301,888`, `PixRepair.au3:305,1155`, `ReBar.au3`, `USBRepair.au3`. `BiosCodes` writes correctly to `.ini` (`BiosCodes.au3:294,1774`) but includes no `Logging.au3`, so it leaves no trace at all. The other six do include `Logging.au3`. All seven carry `#RequireAdmin` and none of them calls `IsAdmin()` before a privileged action. There are no tests and no fixtures for any of them. Au3Check at `-w 1..7` reports 0 errors and, per tool: ComIntRep 68, PixRepair 61, ReBar 60, Ownership 60, BiosCodes 63, USBRepair 51, DVDRepair 51 unique warnings.

> [!CAUTION]
> **This file is superseded in part and must not be built against until it is re-authored.** Recorded 2026-09-16 during the completion brainstorm; see `docs/brainstorm/2026-09-16-completion-brainstorm.md`.
>
> **`§2` describes behavior that does not exist.** `ReBar` is not a registry backup tool. `SDK/Concrete/ReBar/ReBar.au3:32` declares `#AutoIt3Wrapper_Res_Description=ReBar Framework`, it ships `Templates/*.tpl`, and it contains no backup or restore logic. `§2` specifies a golden backup fixture, a round-trip assertion, and a corrupt-backup refusal for a capability the tool has never had.
>
> **The frozen set in this file is wrong.** It names seven tools; `ReBar` changes nothing on a user's system and does not belong in it. The real frozen set here is six: `Ownership`, `ComIntRep`, `USBRepair`, `DVDRepair`, `PixRepair`, `BiosCodes`.
>
> **`ReBar` is internal tooling, not a product,** and is being promoted to a shared SDK include that every tool consumes. That extraction gets its own file and subsumes much of this file's `§1`.
>
> **`USBRepair` and `DVDRepair` are merging** into one Drive Repair tool, which changes `§5`.
>
> **The adjacency block below is stale**: `reverse` and `exchange` anchor on `§2` and need re-anchoring once this file is re-authored.

## Inputs

- [`SDK/Concrete/ReBar/ReBar.au3`](../../SDK/Concrete/ReBar/ReBar.au3) -- registry backup and restore; the frozen behavior §2 pins
- [`SDK/Concrete/Ownership/Ownership.au3`](../../SDK/Concrete/Ownership/Ownership.au3) -- ownership and ACL takeover; §3
- [`SDK/Concrete/ComIntRep/ComIntRep.au3`](../../SDK/Concrete/ComIntRep/ComIntRep.au3) -- COM interface re-registration; §4
- -> XREF: [`00-workspace/TODO-02 §2`](../00-workspace/TODO-02-test-backbone.md) -- the disposable registry and filesystem fixtures every freeze check here runs against
- -> XREF: [`01-sdk-core/TODO-01 §3`](../01-sdk-core/TODO-01-shared-include-contracts.md) -- the settings contract §1 applies, and the elevation contract §6 applies
- -> XREF: [`02-launcher/TODO-01 §3`](../02-launcher/TODO-01-resolute-launcher.md) -- the launcher that starts these tools and reports when one will not start
- -> XREF: [`07-quality/TODO-01 §1`](../07-quality/TODO-01-quality-bar.md) -- the done-bar these tools are measured against

## Outcome

- Every one of these tools reads and writes settings through the shared contract, in a `.ini`, and a value set in the UI survives a restart.
- Every destructive action has a fixture that proves what it writes, and a freeze check that fails if the effect changes.
- Every destructive action has a reverse, or an honest statement of why it cannot have one and what the user should do instead.
- Every destructive action and every refusal writes exactly one log line.
- A tool without the privilege it needs refuses by name before touching anything.

**Adjacency:** list=applicable @ D03 T01 §2; document=applicable @ D03 T01 §7; settings=applicable @ D03 T01 §1; reporting=applicable @ D03 T01 §7; notifications=applicable @ D03 T01 §6; permissions=applicable @ D03 T01 §6; audit=applicable @ D03 T01 §1; exchange=applicable @ D03 T01 §2; reverse=applicable @ D03 T01 §2

**Adjacency rationale:** Reverse is the load-bearing key in this file and it anchors on §2 because a registry backup is the suite's clearest case: the backup exists so the restore exists, and a restore that cannot refuse a corrupt backup is worse than no restore. Exchange lands there too, because a `.reg`-style backup is a file format a user may carry to another machine or edit, so the restore path treats it as untrusted input. List is §2 for the same reason: a user with several backups needs to find the right one without opening each. Permissions and notifications pair on §6: these tools fail at the privileged call, and the refusal must both stop the action and say so. Document and reporting pair on §7, which is where `BiosCodes` gains the trace it has never had and where a user-carryable result is defined.

## Implementation Order

| Order | Section | Deliverable                                          | Depends On | Status |
| :---: | :-----: | ---------------------------------------------------- | ---------- | :----: |
|   1   |   §1    | Settings path repair across the six tools            | D01 T01 §3 |  [ ]   |
|   2   |   §2    | ReBar registry backup, restore, and refusal          | §1, D00 T02 §2 |  [ ]   |
|   3   |   §3    | Ownership takeover and its reverse                   | §1, D00 T02 §2 |  [ ]   |
|   4   |   §4    | ComIntRep re-registration and its reverse            | §1, D00 T02 §2 |  [ ]   |
|   5   |   §5    | USBRepair and DVDRepair drive actions                | §1         |  [ ]   |
|   6   |   §6    | Elevation refusal across all seven tools             | §1, D01 T01 §7 |  [ ]   |
|   7   |   §7    | BiosCodes trace and result output                    | §1         |  [ ]   |

---

## 1. Settings Path Repair Across the Six Tools

Six tools write their settings into a file named `.lng`, the extension this suite uses for language packs. It is the same defect the launcher has, in six more places, and it is the cheapest correct thing in this file. It is first because every later section in this file needs the tool to be able to remember something.

- [ ] Replace both `$g_sPathIni` assignments in each of `ComIntRep.au3` (348, 1164), `DVDRepair.au3` (306, 824), `Ownership.au3` (301, 888), `PixRepair.au3` (305, 1155), `ReBar.au3`, and `USBRepair.au3` with `_Settings_Init(<ShortName>)`. Done when: `grep -ln 'g_sProgShortName & "\.lng"' SDK/Concrete/*/*.au3` returns nothing for these six files. Cheaper substitute: changing the extension string and leaving twelve path computations in place.
- [ ] Route every settings `IniRead` and `IniWrite` in those six files through `_Settings_Read` and `_Settings_Write`. Done when: the remaining `Ini*` calls in each file are against non-settings files and each is commented with what it reads.
- [ ] Run the shared migration on first start for each tool, so an existing `<Tool>.lng` carrying settings is copied into `<Tool>.ini` with a log line. Done when: a fixture `.lng` per tool produces the migrated `.ini` and the line.
- [ ] Prove the round trip per tool on the real surface: change a setting, restart, read it back. Done when: all six are driven and all six hold their value. Cheaper substitute: proving one tool and assuming the other five.
- [ ] Confirm `BiosCodes` already uses `.ini` and needs no change here, and record that it was checked rather than skipped. Done when: this section states the check and the file:line that confirms it.
- [ ] Commit: `"system-tools: store settings in .ini through the shared contract"`

**Freeze check:** No behavior these tools perform changes in this section: only where their settings live. The freeze evidence is that each tool, driven through its main action against a fixture before and after the change, produces byte-identical results. Fixture source: `tests/fixtures/`.

**Test checkpoint:** `grep -ln 'g_sProgShortName & "\.lng"' SDK/Concrete/*/*.au3` returns nothing. A driven run of each of the six built tools changes one setting, restarts, and reads the same value back from `<Tool>.ini`; a fixture `.lng` is migrated with a log line. All six round trips are quoted in the commit body.

## 2. ReBar Registry Backup, Restore, and Refusal

`ReBar` backs up and restores registry state. It is the most dangerous thing in this repository and the least tested, and the reason is circular: there was no safe target to test against. `D00 T02 §2` builds that target, so the reason is gone.

**Fidelity:** the ReBar main window and its backup list, against `docs/captures/house-style/`. Layout unchanged by this section; the restore refusal reuses the shared message dialog.
**Job:** a user can back up a registry area, find that backup again later, restore it, and be refused clearly when the backup is not usable. Consumer: the backup files themselves, read back by the restore path.
**Treatment:** restore validated against the backup's own header before a single value is written, and refused as a whole when validation fails. Cheaper substitute that fails the checkpoint: a restore that writes what it can and reports partial success, which leaves the registry in a state neither the backup nor the original.
**Chrome:** consume `SDK/Includes/Registry.au3`, `SDK/Includes/Messages.au3`, and `SDK/Includes/Logging.au3`.
**Needs:** Windows host (build/test)

- [ ] Pin the current backup format: write a fixture backup of `HKCU\Software\Rizonesoft\Fixtures` using the shipped code and commit it under `tests/fixtures/rebar/` as the golden artifact. Done when: the fixture exists and the code that produced it is identified by commit.
- [ ] Add `tests/rebar.test.au3` proving a round trip against the sandbox key: back up, change values, restore, and compare every value and type. Done when: the assertion compares all value types the tool handles, not only strings.
- [ ] Add the refusal: a backup whose header does not match, or which is truncated, is rejected before any write, with a named message and a log line. Done when: a deliberately corrupted fixture produces the refusal and the sandbox key is byte-identical afterwards.
- [ ] Make the restore all-or-nothing, or state plainly in the UI and the log that it is not and what the user must do after a partial restore. Done when: the behavior is one of those two and the checkpoint proves which.
- [ ] Give the backup list a findable identity: each backup shows what it covers and when it was taken, so a user can pick one without opening it. Done when: the list renders both for the fixture backups and the rendered surface is captured.
- [ ] Account for the surface: every control on the ReBar window is working or deferred to a named section. Done when: the account is written and each deferral resolves.
- [ ] Log every backup, restore, and refusal through `_Logging_Action`. Done when: each of the three produces exactly one line naming the target key.
- [ ] Commit: `"rebar: prove registry backup and restore against a fixture, and refuse a bad backup"`

**Freeze check:** Round-tripping `tests/fixtures/rebar/` through backup and restore reproduces every value and type in `HKCU\Software\Rizonesoft\Fixtures` exactly, and a corrupted backup is refused with no write. What the tool writes to the registry does not change in this section; any change to the written effect needs operator approval recorded here. Fixture source: `tests/fixtures/rebar/`.

**Test checkpoint:** `AutoIt3.exe tests/run-tests.au3 --filter rebar` exits 0: the round-trip assertion restores every value and type, and the corrupted-backup assertion proves the sandbox key is unchanged after the refusal. The refusal message and one log line per action are quoted. The backup list is captured under `docs/captures/runs/`.

## 3. Ownership Takeover and Its Reverse

`Ownership` takes ownership of files and directories and grants access. Taking ownership of a system file is easy; giving it back is the part users need and the part nobody tests. A takeover with no reverse is a support call.

**Fidelity:** the Ownership main window and its result list, against `docs/captures/house-style/`.
**Job:** a user can take ownership of a path, see exactly what changed, and put it back. Consumer: the filesystem ACLs themselves, read back by the verification step.
**Treatment:** the prior owner and ACL recorded before the change, so the reverse restores the actual previous state rather than a guess at a default. Cheaper substitute that fails the checkpoint: a reverse that sets ownership to the current user or to `TrustedInstaller` by convention.
**Chrome:** consume `SDK/Includes/FileEx.au3`, `SDK/Includes/Messages.au3`, and `SDK/Includes/Logging.au3`.
**Needs:** Windows host (build/test)

- [ ] Record the prior owner and ACL for every path before changing it, into a restore record beside the log. Done when: a takeover against the filesystem sandbox writes a record naming the prior owner.
- [ ] Add the reverse: restore ownership and ACL from the record, and prove the path's owner and ACL match what they were. Done when: the assertion compares owner and ACL before and after the round trip.
- [ ] Refuse rather than half-apply on a path the process cannot touch, naming the path and the reason. Done when: a sandbox path with a deny ACE produces the refusal and leaves every other path in the batch untouched or explicitly reported.
- [ ] Report per path what happened: changed, skipped, or failed, with the reason. Done when: a mixed batch produces one row per path and the counts add up to the batch size.
- [ ] Account for the surface: every control on the Ownership window is working or deferred to a named section. Done when: the account is written and each deferral resolves.
- [ ] Log every takeover and every restore through `_Logging_Action`. Done when: both produce one line each naming the path.
- [ ] Commit: `"ownership: record the prior owner and make the takeover reversible"`

**Freeze check:** Against `tests/fixtures/filetree/`, a takeover followed by a restore returns every path to its recorded prior owner and ACL, compared entry by entry. What the tool grants on takeover does not change in this section. Fixture source: `tests/fixtures/filetree/`.

**Test checkpoint:** `AutoIt3.exe tests/run-tests.au3 --filter ownership` exits 0: the round-trip assertion compares owner and ACL before and after, and the deny-ACE assertion proves the refusal names the path and leaves the rest of the batch accounted for. The per-path result list is captured and quoted.

## 4. ComIntRep Re-registration and Its Reverse

`ComIntRep` re-registers COM interfaces to repair a broken installation. Re-registration is the kind of change that fixes one machine and breaks another, so what it touches must be recorded and undoable.

**Fidelity:** the ComIntRep main window and its result list, against `docs/captures/house-style/`.
**Job:** a user can repair COM registrations, see which ones changed, and undo the change if the repair made things worse. Consumer: the registry itself, read back by the verification step.
**Treatment:** the prior registration state captured before each change, with the reverse restoring it. Cheaper substitute that fails the checkpoint: re-registering and reporting success from the exit code of the registration call.
**Chrome:** consume `SDK/Includes/Registry.au3`, `SDK/Includes/Messages.au3`, and `SDK/Includes/Logging.au3`.
**Needs:** Windows host (build/test)

- [ ] Enumerate what the tool re-registers and record the list here with its source in the code. Done when: the list is complete and each entry names the function that acts on it.
- [ ] Capture prior state per entry before changing it, through the ReBar backup path rather than a second mechanism. Done when: a run against the sandbox produces a backup the restore path accepts.
- [ ] Verify each re-registration actually took effect rather than trusting the call's return. Done when: the assertion reads the registration back and compares it.
- [ ] Add the reverse for the whole run, restoring from the captured state. Done when: a sandbox run followed by an undo leaves the sandbox key identical to its pre-run state.
- [ ] Report per entry: repaired, already correct, skipped, or failed with the reason. Done when: a mixed run produces one row per entry and the counts add up.
- [ ] Account for the surface: every control on the ComIntRep window is working or deferred to a named section. Done when: the account is written and each deferral resolves.
- [ ] Commit: `"comintrep: capture prior state, verify each repair, and make the run undoable"`

**Freeze check:** Against the sandbox key, a repair run followed by its undo reproduces the pre-run state value for value. Which interfaces the tool repairs does not change in this section. Fixture source: `tests/fixtures/comintrep/`.

**Test checkpoint:** `AutoIt3.exe tests/run-tests.au3 --filter comintrep` exits 0: the verify assertion reads each registration back, and the undo assertion proves the sandbox key matches its pre-run state. The per-entry result list is captured and quoted.

## 5. USBRepair and DVDRepair Drive Actions

Both tools act on removable and optical drives. Neither can be proven without the device attached, which is exactly what a `Needs:` line is for: the row waits for the device rather than being quietly skipped or falsely stamped.

**Fidelity:** the USBRepair and DVDRepair main windows, against `docs/captures/house-style/`.
**Job:** a user can repair a drive, see what was attempted, and be told clearly when no suitable drive is present. Consumer: the drive state itself, read back after the action.
**Treatment:** the no-device case handled as a first-class outcome with a named message, and the action itself verified against the drive after it runs. Cheaper substitute that fails the checkpoint: reporting success because the command returned zero.
**Chrome:** consume `SDK/Includes/Messages.au3` and `SDK/Includes/Logging.au3`.
**Needs:** USB device (drive test)

- [ ] Handle the no-device case in both tools: a named message, a log line, and no action attempted. Done when: both tools driven on a host with no removable and no optical drive produce the message and change nothing. This part needs no device and is proven first.
- [ ] Enumerate the actions each tool performs and record them here with their code locations. Done when: both lists are complete and each entry names its function.
- [ ] Verify each action against the drive after it runs rather than trusting the return code. Done when: a driven run against an attached USB device reads the drive state back and the assertion compares it.
- [ ] Confirm before every destructive drive action, naming the drive by letter, label, and size. Done when: the confirmation names all three and declining it performs nothing.
- [ ] State plainly which of these actions have no reverse, in the UI and in this section, with what the user should do instead. Done when: each irreversible action carries that statement on the surface, not only in the docs.
- [ ] Account for the surface on both tools: every control working or deferred to a named section. Done when: both accounts are written and each deferral resolves.
- [ ] Commit: `"usbrepair, dvdrepair: verify drive actions and handle the no-device case"`

**Freeze check:** What each tool does to a drive does not change in this section. The evidence is the recorded action list before and after, plus a driven run against an attached device whose read-back drive state matches the pre-change expectation for a no-op action. Fixture source: `tests/fixtures/drives/` for the no-device case; a physical device for the rest.

**Test checkpoint:** On a host with no removable or optical drive, both built tools produce the named no-device message, write one log line each, and change nothing. With a USB device attached, a driven `USBRepair` run confirms by letter, label, and size, and the post-action read-back is quoted. The optical leg is recorded as not run with the reason if no optical drive is present, and the row does not stamp until it has been.

## 6. Elevation Refusal Across All Seven Tools

Seven tools request elevation at startup and then assume they have it. None re-checks at the action. The shared contract exists; this section applies it where the damage would happen.

**Fidelity:** the refusal notice, reusing the shared message dialog captured in `docs/captures/house-style/`. No new dialog.
**Job:** a user without the privilege a tool needs is told which action needs what, before anything is changed. Consumer: the log, and the action path that does not run.
**Treatment:** `_Elevation_Require` called immediately before each privileged call, not only at startup. Cheaper substitute that fails the checkpoint: checking `IsAdmin()` once at startup and treating it as true for the session.
**Chrome:** consume `SDK/Includes/Messages.au3`, `SDK/Includes/Logging.au3`, and the shared `_Elevation_Require`.

- [ ] Identify every privileged call site across the seven tools and record the list here with file and line. Done when: the list is complete and each entry names the action it guards.
- [ ] Call `_Elevation_Require(<action>)` immediately before each, refusing rather than attempting when it returns false. Done when: every site is guarded and no site calls `IsAdmin()` directly any more.
- [ ] Prove the refusal unelevated for at least one action per tool. Done when: seven assertions run in an unelevated session, each proving nothing was changed.
- [ ] Log each refusal once, naming the tool and the action. Done when: the seven assertions produce exactly seven log lines.
- [ ] Decide and record what each tool does when it can still do something useful unelevated, as a dated default per tool. Done when: each of the seven carries a one-line decision with the cost of changing it.
- [ ] Commit: `"system-tools: gate every privileged action at the call site"`

**Freeze check:** No privileged action's effect changes in this section; what changes is whether it is attempted without the privilege. The evidence is that an elevated driven run of each tool's main action produces the same result as before the change, compared against the pre-change run. Fixture source: `tests/fixtures/`.

**Test checkpoint:** In an unelevated session, `AutoIt3.exe tests/run-tests.au3 --filter elevation-tools` exits 0 with seven assertions, each proving the action was refused by name, nothing was changed, and one log line was written. The seven messages are quoted in the commit body.

## 7. BiosCodes Trace and Result Output

`BiosCodes` is the one tool here that already stores its settings correctly and the one tool that writes no log at all. It is also the only tool in this group whose output a user would plausibly want to keep: a beep-code lookup is something you write down and carry to the machine that is beeping.

**Fidelity:** the BiosCodes main window and its code list, against `docs/captures/house-style/`.
**Job:** a user can look up a beep code, and save or print the result to carry to the machine that produced it. Consumer: the saved file, and the log.
**Treatment:** a real export of the looked-up result, written atomically and read back. Cheaper substitute that fails the checkpoint: a copy-to-clipboard button presented as an export.
**Chrome:** consume `SDK/Includes/Logging.au3`, `SDK/Includes/FileEx.au3`, and `SDK/Includes/Messages.au3`.

- [ ] Include `Logging.au3` in `BiosCodes.au3` using the same single-backslash form the other tools use, and log lookups through `_Logging_Action`. Done when: a driven lookup produces a log file under `Resolute/Logging/` naming the code looked up.
- [ ] Add the export: save the current result as a text file, written atomically and read back before reporting success. Done when: the saved file's content matches the rendered result and a write to a read-only location reports failure rather than claiming success.
- [ ] Make the code list findable without knowing the exact code: filter by manufacturer and by code fragment. Done when: a driven filter narrows the list and clearing it restores the full list.
- [ ] Confirm the language packs `Resolute/Language/BiosCodes/` (`de`, `en`, `ko`) still resolve after the change, and report any key the surface asks for that they lack. Done when: each pack is driven and its missing keys are reported.
- [ ] Account for the surface: every control on the BiosCodes window is working or deferred to a named section. Done when: the account is written and each deferral resolves.
- [ ] Commit: `"bioscodes: log every lookup and let the user carry the result"`

**Test checkpoint:** A driven run looks up a code, writes a log line naming it, exports the result to a file whose content matches the rendered result, and fails visibly when the export target is read-only. The filter narrows and restores the list. Each of the three language packs is driven and its missing keys reported. All outputs are quoted and the surface is captured under `docs/captures/runs/`.

## Verification

- [ ] `pwsh scripts/au3check-all.ps1` exits 0 with no new warnings from any of the seven tools
- [ ] `pwsh scripts/build.ps1 -All` builds all seven to both architectures
- [ ] `AutoIt3.exe tests/run-tests.au3` exits 0 with the rebar, ownership, comintrep, and elevation-tools suites reporting
- [ ] Every freeze check in this file ran and passed, with its result quoted in the covering stamp
- [ ] No fixture residue remains under `HKCU\Software\Rizonesoft\Fixtures` or the temp tree after a full run
- [ ] `python scripts/todo-graph.py validate` clean
