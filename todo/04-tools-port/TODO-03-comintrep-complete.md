---
schema_version: 1
id: comintrep-complete
domain: 04-tools-port
status: draft
title: "TODO-03 -- ComIntRep: Complete Port and Enhancement"
depends_on: []
track: P2
---

# TODO-03 -- ComIntRep: Complete Port and Enhancement

> **Goal:** Complete Internet Repair ships as a complete, distribution-ready C++ tool: all 14 repairs inventoried with their reversibility, every surface and string accounted for, distribution-complete, plus fenced enhancements that make it the definitive internet-repair tool. The build and parity proof stay in `D04 T01 §2`, which ordered this file; this file specifies, completes, and enhances without touching the frozen effect.

> [!IMPORTANT]
> **Current state:** Nothing exists in C++. The AutoIt tool is `resolute_au3/SDK/Concrete/ComIntRep/ComIntRep.au3` (3,459 lines, 95 functions, 83 net of the framework copy): 14 dispatched repairs driven through hidden `cmd.exe` commands, a checkbox main window with an info pane and expander, five menus, a 4-tab Preferences dialog, 16 language packs, welcome/complete sounds, and doc templates. ComIntRep is frozen: its computed effect is reproduced exactly. The driven run and hands-on competitor use below could not be done from this host and are owed at build, owned by `D04 T01 §2`'s capture item and the enhancement sections' first items respectively.

<!-- claim: lines resolute_au3/SDK/Concrete/ComIntRep/ComIntRep.au3 = 3459 -->
<!-- claim: count "^Func " resolute_au3/SDK/Concrete/ComIntRep/ComIntRep.au3 = 95 -->
<!-- claim: exists resolute_au3/Resolute/Language/ComIntRep/en.lng -->

## Inputs

- [`resolute_au3/SDK/Concrete/ComIntRep/ComIntRep.au3`](../../resolute_au3/SDK/Concrete/ComIntRep/ComIntRep.au3) -- the tool being inventoried and completed
- [`resolute_au3/SDK/Concrete/ComIntRep/ComIntRep.sni`](../../resolute_au3/SDK/Concrete/ComIntRep/ComIntRep.sni) -- the build descriptor: what ships with it
- [`resolute_au3/Resolute/Language/ComIntRep/en.lng`](../../resolute_au3/Resolute/Language/ComIntRep/en.lng) -- the English pack (UTF-16); `[Custom]` names the repairs, `[Messages2]` narrates them
- -> XREF: D04 T01 §2 -- the build this file specifies for, ordered by that section's first item

## Outcome

- All 14 repairs are enumerated with source lines, exact commands, areas touched, and reversible, partial, or no-reverse verdicts with mechanisms.
- Every ComIntRep window, control, string, setting, sound, and shipped file is inventoried with `file:line` and mapped to framework, repair contract, or tool code.
- The tool ships distribution-complete: migrated settings, 16 packs, docs, icon, installer and update entries, About, F1, guide page, tests, and a green conformance check.
- Three fenced enhancements ship (per-repair verification, restore-point offer, opt-in chime), each proven non-interfering by a re-run parity fixture.
- The frozen effect (the exact command sequences, registry writes, file operations, and service configurations) is byte-identical, and no enhancement changes it.

**Adjacency:** list=applicable @ D04 T03 §2; document=applicable @ D04 T03 §3; settings=applicable @ D04 T03 §3; reporting=applicable @ D04 T03 §4; notifications=not-applicable (the tool reports on its surface and logs; it sends no notification); permissions=applicable @ D04 T03 §1; audit=applicable @ D04 T03 §4; exchange=applicable @ D04 T03 §2; reverse=applicable @ D04 T03 §1

**Adjacency rationale:** Reverse anchors on §1 because each repair's reversibility verdict is recorded there, which is what the undo story is built from. List anchors on §2 where the repair checkboxes are the browsed record surface, and exchange beside it because the File Export submenu carries diagnostics out of the tool. Document and settings pair on §3 as what distribution-complete means. Reporting and audit converge on §4 where per-repair verification reports and trails each outcome. Permissions anchors on §1 where the inventory records the missing elevation request. Notifications stays not-applicable.

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Repair inventory with reversibility | -- |  [ ]   |
|   2   |   §2    | Surface inventory with shared-layer map | -- |  [ ]   |
|   3   |   §3    | Distribution completeness | D04 T01 §2 |  [ ]   |
|   4   |   §4    | Per-repair verification and outcome | D04 T01 §2 |  [ ]   |
|   5   |   §5    | Pre-repair restore-point offer | D04 T01 §2 |  [ ]   |
|   6   |   §6    | Opt-in completion chime | D04 T01 §2 |  [ ]   |

---

## 1. Repair Inventory With Reversibility

All 14 dispatched repairs (`_ProcessSelectedOption` cases 0-13, `ComIntRep.au3:1640-1669`), each with its source lines, exact commands and writes, areas touched, and a reversibility verdict: reversible (mechanism named), partial (what restores and what does not), or none (what the user is told instead, on the surface). The repair contract's restore record is built from these verdicts, not invented at build time.

Recorded dead code, cut with reason here: `_RepairNeroUpdate` (`:2287`, never dispatched and its body fully commented), `_RepairWorkGroups` (`:1482`), `_InstallIP6` (`:1464`), and `_UnInstallIP6` (`:1473`, all three defined but never called); the XP/2003 branches (below the Windows 10 1809 floor); the commented inner-repair calls (`:2219-2221`, `:1753-1758`).

**Fidelity:** no surface of its own; this section is the record the build declares items from.
**Needs:** C++ toolchain (compile)

- [ ] Inventory the network-stack repairs with commands and verdicts: TCP/IP reset (`:1676`, `netsh interface ipv4/ipv6 reset`, no reverse), Winsock catalog reset (`:1705`, `netsh winsock reset` via `__ResetWinsock`, no reverse, reboot required), release/renew (`:1740`, `ipconfig /release /renew`, transient), DNS flush/register (`:1766`, `ipconfig /flushdns /registerdns`, transient), ARP flush (`:1782`, `netsh interface ip delete arpcache` or equivalent as read, transient). Done when: each names exact commands, areas, and verdict with mechanism or surface text.
- [ ] Inventory the IE and update repairs: IE re-registration (`:1794`, ~100 DLL/OCX `regsvr32` calls plus its MsgBox, no reverse; record that IE is retired on supported Windows so the sequence largely no-ops, reproduced exactly anyway), update-history clear (`:2119`, qmgr `.dat` delete plus three `BackupRemoveDirectory` moves, reversible via the backups), Windows Update repair (`:2150`, service stops including Nero NAUpdate, two `sc sdset` SDDL strings frozen verbatim, service configs, 50 DLL registrations, fsutil, bitsadmin, policy-key deletes, AU-value writes, `wuauclt /detectnow`; verdict partial with each half named). Done when: the SDDL strings and DLL lists are pinned by quotation or line range, and each verdict names its mechanism.
- [ ] Inventory the configuration repairs: cryptography (`:2336`, CryptSvc stop/config/start, catroot2 backup-move, tmp/KB `.CAT` and `oem*.*` deletes; verdict partial), proxy reset (`:2402`, `netsh winhttp reset proxy`, no reverse), firewall reset (`:2433`, `netsh advfirewall reset`, no reverse), hosts restore (`:2463`, backup copy then default rewrite, reversible via the backup with the template bytes frozen), WINS renew (`:2530`, `nbtstat -R -RR`, transient), network-computers visible (`:2545`, FDResPub stop/config-auto/start, no backup recorded). Done when: each names commands, verdict, and the backup paths where they exist.
- [ ] Record the cross-repair behaviors: the `_RunCommand` wrapper (`:2801`, hidden `cmd.exe`, output streamed to the log line by line), per-repair progress percentages, the reboot prompt (`_BootMessage` YESNO plus `_Reboot` OKCANCEL-with-timeout and `Shutdown(18)`), the missing elevation request (no `#RequireAdmin`, no admin check: the port checks at the action per `D01 T01 §6`), and the OR rule for nothing (repairs run independently; no repair depends on another). Done when: each behavior names its lines and its new home.
- [ ] Name the TCP/IP reset's backup and verdict the dead setting (groom 2026-09-23 gap scan) : `BackupIPData` (default 1) runs `__ExportIPConfiguration` before every TCP/IP reset (`ComIntRep.au3:1214-1215`, `:1680-1682`), the reset's only backup, and `BackupData` is read and written but consumed nowhere (`:3241-3242`). Done when: the TCP/IP reset row names the gated pre-reset export as its backup, and `BackupData` carries a dead-setting verdict with its reason.
- [ ] Commit: `"comintrep: repair inventory with reversibility"`

**Test checkpoint:** All 14 repairs name lines, exact commands, areas, and verdicts; the dead functions and branches are cut with reasons; the SDDL strings, DLL lists, and hosts bytes are pinned; the wrapper, progress, reboot, and elevation gap are recorded. `D04 T01 §2` can declare every repair-contract item from this section with nothing left to read. Cheaper substitute that fails the checkpoint: repair names without commands, which plans fourteen titles rather than fourteen behaviors.

-> XREF: D04 T01 §2 -- the build that declares items from this inventory

## 2. Surface Inventory With Shared-Layer Map

Every ComIntRep window, control, string, setting, sound, and shipped file, with `file:line`, mapped to framework, repair contract, or tool code. The main window (`:613`): heading, warning subheading, Select All checkbox (`:775`, commented-out save-selection checkbox beside it, cut as dead while `_SaveSelection`/`_LoadSelection` persist silently), 14 repair checkboxes generated in a loop (`:784`), the pushlike extender (`:811`), the info Edit pane (`_ShowRepairInfo`), Go/Go-Stop button (`:814`), status list, donate strip, update animation. Five menus (`:618-623`): File (Event Viewer, Preferences, Logging submenu with IP-reset log, 4-item Export submenu, Reboot, Close), Maintenance (create restore point), Troubleshoot (10 MS diagnostics, speed-test URL, router-passwords URL), Tools (RDP, IE properties, and the three dead items whose functions are never called, cut), Help (standard plus Donate). Preferences (`:2881`, 450x500, four tabs: the three framework pages plus the tool page with backup-data and export-IP checkboxes `:2891-2893`).

**Fidelity:** no surface of its own; this section is the record the build renders from.
**Needs:** C++ toolchain (compile)

- [ ] Inventory the main window control by control with string sources: every checkbox label from `[Custom]`, the info texts `Info_01` through `Info_15` with their typos quoted for the string audit (`Info_03` "becuase", `Info_06` prose), the Go/Stop labels, the extender tooltips, and the successor notice (`Label_Sub_Heading_Notice`, kept as a successor pointer through the consolidation mechanism, not as ad copy). Done when: every control names its strings and its verdict.
- [ ] Inventory the menus item by item with targets: Event Viewer, the Export submenu's four commands (`__ExportIPConfiguration`, `__ExportWinsockLSPs`, `__ExportARPEntries`, `__ExportNetBIOSStatistics`), Reboot, the restore-point shell call, the 10 troubleshooter IDs, the two URLs, RDP, IE properties, and the standard Help items; the three dead Tools items cut with the uncalled-function evidence. Done when: every item names its target or its cut reason.
- [ ] Inventory settings, sounds, and distribution: the `[Selection]` keys 0-13 (persisted silently, kept), the framework `.ini` keys, `Welcome.wav` on start (`:855`) and `Complete.wav` on finish (`:2640`) both cut as autoplay with the opt-in verdict deferred to §6, and the `.sni` ship list (exe pair, ini, three docs, 16 packs, four `.ani` files cut, two sounds cut). Done when: every key, sound, and shipped file carries keep, cut, or remapped.
- [ ] Map every inventoried piece to framework, repair contract, or tool code: window, menus (kept whole per the tool's five-menu shape, recorded as the deliberate exception to the two-menu standard with reason), prefs host, log, update, elevation, About, crash, singleton, F1 to the framework; the 14 repairs plus verify to the contract; checkboxes, info pane, extender, Go, exports, and shell launches to the tool. Done when: no piece maps to two homes and the five-menu exception is recorded with reason.
- [ ] Commit: `"comintrep: surface inventory with shared-layer map"`

**Test checkpoint:** A walk of `ComIntRep.au3` finds every control, menu item, string, setting, sound, and shipped file recorded with verdict and home; the dead items cite the uncalled functions; the five-menu exception is recorded. Cheaper substitute that fails the checkpoint: a control list without string sources, which ships fourteen checkboxes with invented labels.

-> XREF: D04 T01 §2 -- the build that renders from this inventory

## 3. Distribution Completeness

Everything that makes the ported tool shippable: settings migration, 16 packs, docs, icon, installer and update entries, About, F1, guide page, tests, and conformance. Runs after `D04 T01 §2` proves parity on the core.

**Fidelity:** the tool as shipped: installer entries, docs, and About, against the AutoIt distribution.
**Job:** a user can install, run, update, and remove the tool with nothing missing. Consumer: the installed tool and its docs.
**Treatment:** every AutoIt-shipped artifact has a C++ successor or a recorded cut. Cheaper substitute that fails the checkpoint: a tool that runs from the build tree but was never installed anywhere, which is how missing files ship.
**Chrome:** consume the framework installer entries, About, and help. No tool-side installer logic.
**Needs:** Windows host (build/test)

- [ ] Migrate settings and ship the packs: an existing AutoIt `.ini` (framework keys plus `[Selection]`) migrates with a log line; all 16 packs ship and the pack-hygiene rules from `D08 T01 §3` hold across them. Done when: a fixture `.ini` migrates and the pack check passes on all 16, both quoted.
- [ ] Ship the docs set from the three templates: every template renders with generated metadata (no typed version or date; the 632-line `Changes.txt` range is normalized per the `D08 T01 §1` entry-shape rule) and the set matches the contract. Done when: all three render and the conformance check agrees.
- [ ] Register installer and update-file entries per `D06 T01 §3` and `D06 T01 §5`: portable and installed modes, the application icon, and the update descriptor. Done when: both modes install and remove cleanly on a fixture machine.
- [ ] Wire About, F1, and the guide page: About from the registry for the ComIntRep descriptor, F1 through the surface map to the repair info texts, and the user-guide page in the same commit as the behavior it documents. Done when: all three resolve and the guide page shares its commit.
- [ ] Prove tests and conformance: unit tests for the tool-specific logic (dispatch, selection persistence, export formatting) run under the harness, and the `D07 T01 §3` check passes for the tool. Done when: `ctest` names the suites green and the conformance report is quoted.
- [ ] Prove first-run and upgrade: a clean machine goes from install to working with no manual step, and a machine carrying the AutoIt ComIntRep upgrades with settings and selection preserved and one copy left. Done when: both paths are driven and quoted. Cheaper substitute that fails the checkpoint: testing upgrade by reading the code, which is how two copies ship.
- [ ] Migrate the `[ComIntRep]` tool keys (groom 2026-09-23 gap scan) : the migration carries the framework keys plus `[Selection]` only, so `BackupIPData` and `BackupData` would be dropped. Done when: a fixture AutoIt settings file with both keys migrates with `BackupIPData` preserved and `BackupData` handled per its `§1` verdict, quoted.
- [ ] Commit: `"comintrep: distribution completeness"`

**Test checkpoint:** Fixture `.ini` migrates; 16 packs pass hygiene; three docs render generated; both install modes round-trip; About, F1, and the guide page resolve; tests and conformance quote green; first-run and upgrade are driven. Cheaper substitute that fails the checkpoint: a checklist ticked from the build tree, which proves the tool compiles rather than ships.

-> XREF: D04 T01 §2 -- the parity core this section ships

## 4. Per-Repair Verification and Outcome

**Deliberate new behavior.** The AutoIt tool runs each command and logs its output; nothing checks the repair worked. This section adds per-repair verification (after each repair, read back its effect: service states, key values, file states) and a per-item outcome (verified, already correct, failed with reason) in the result list. Pure reads plus display: the frozen effect is untouched.

Competitor context (source-based, hands-on owed at build): Tweaking.com Windows Repair (v4.x) ships an overlapping repair set (firewall, IE, hosts file, Windows Update, Winsock) with presets and post-repair custom scripts ([source](https://www.neowin.net/news/windows-repair-192/)); Complete Windows Repair is this tool's own bundled successor; the built-in Windows troubleshooters (which this tool links to) diagnose without fixing deeply. None verifies per repair readably. This tool beats all three on honesty: every repair reports what it proved, not just what it ran.

**Fidelity:** the per-repair outcome in the result list, against `DESIGN.md` §11; new presentation, no AutoIt baseline.
**Job:** a user knows which repairs worked, not just which ran. Consumer: the result list and the transcript.
**Treatment:** verify by reading the repaired state, never by re-reading the command output. Cheaper substitute that fails the checkpoint: marking success from exit code zero, which proves the command ran rather than the repair worked.
**Chrome:** consume the repair-contract result list. No second list.
**Needs:** Windows host (build/test)

- [ ] Confirm the competitor table hands-on: run Tweaking.com Windows Repair and the built-in troubleshooters, verify the documented behaviors above against the named versions, and correct the table. Done when: each row names the version used and what was observed, quoted.
- [ ] Verify each repair by state: all 14 repairs name their verification reads (service query, key readback, file presence, command probe) and the pass rule for each. Done when: every repair names reads that fail when the repair is reverted on a fixture, quoted per repair.
- [ ] Report per-item outcome: verified, already correct, skipped, refused, or failed with reason, each with its text and pack key, carried into the transcript. Done when: a fixture exercising all five renders each correctly.
- [ ] Cover the finer details: tooltips, keyboard reachability with tab order, screen-reader names, both themes and DPI scalings, and the exact texts with pack keys. Done when: each is driven or captured, none deferred.
- [ ] Prove non-interference: the `D04 T01 §2` parity fixture re-runs with zero differing fields with this section shipped. Done when: the report is quoted showing zero diff.
- [ ] Commit: `"comintrep: per-repair verification and outcome"`

**Test checkpoint:** Competitor rows name used versions; all 14 verifications fail on reverted fixtures; all five outcomes render on an exercising fixture; finer details are driven or captured; the parity fixture re-runs zero-diff. Cheaper substitute that fails the checkpoint: outcomes without verification reads, which display confidence the tool never earned.

-> XREF: D04 T01 §2 -- the parity fixture this section must not disturb

## 5. Pre-Repair Restore-Point Offer

**Deliberate new behavior.** The AutoIt `Info_01` text recommends a System Restore Point but offers no action; the Maintenance menu buries the creation three clicks away. This section offers one-click restore-point creation before Go runs, with a do-not-ask-again rule. PromptOnly UX around the effect: the frozen repairs are untouched.

**Fidelity:** the pre-repair offer, through the framework message layer; no new dialog.
**Job:** a user is one click from a rollback before any repair runs. Consumer: the created restore point, verified to exist.
**Treatment:** offer every run until declined with do-not-ask-again; never block the repairs on the offer. Cheaper substitute that fails the checkpoint: creating the point silently, which spends minutes and disk on a decision the user never made.
**Chrome:** consume the framework message layer only. No new dialog.
**Needs:** Windows host (build/test)

- [ ] Offer the restore point before Go: the prompt names what it will do and how to skip it forever, creation runs the same shell call as the Maintenance item, and success or failure is reported by name with one log line. Done when: accept creates a verified point, decline runs repairs, and do-not-ask-again persists, all quoted.
- [ ] Cover the finer details: keyboard path, screen-reader names, both themes, and the exact texts with pack keys. Done when: each is driven or captured, none deferred.
- [ ] Prove non-interference: the `D04 T01 §2` parity fixture re-runs with zero differing fields with this section shipped and the offer declined. Done when: the report is quoted showing zero diff.
- [ ] Commit: `"comintrep: pre-repair restore-point offer"`

**Test checkpoint:** Accept creates a verified point, decline runs, do-not-ask-again persists; finer details are driven or captured; the declined parity fixture re-runs zero-diff. Cheaper substitute that fails the checkpoint: an offer without the verified point, which promises a rollback it never made.

-> XREF: D04 T01 §2 -- the parity fixture this section must not disturb

## 6. Opt-In Completion Chime

**Deliberate new behavior.** The AutoIt tool autoplays `Welcome.wav` on start and `Complete.wav` on finish. Autoplay audio is cut (§2); this section restores the finish signal as an opt-in chime, off by default, replaying the shipped `Complete.wav` bytes. Sound only, after the effect: the frozen repairs are untouched.

**Fidelity:** the preference checkbox and the played chime; no new surface beyond the checkbox.
**Job:** a user running long repairs hears completion without watching. Consumer: the played audio plus the announced status.
**Treatment:** off by default, chosen in Preferences, never on first run unasked. Cheaper substitute that fails the checkpoint: on-by-default with a mute, which is autoplay with an extra step.
**Chrome:** consume the framework Preferences checkbox. No player UI.
**Needs:** Windows host (build/test)

- [ ] Ship the opt-in chime: the preference defaults off, enabling plays the shipped bytes on completion only (never on start), and the status announcement fires regardless of the setting. Done when: off plays nothing, on plays once at completion, and the announcement is quoted both ways.
- [ ] Prove non-interference: the `D04 T01 §2` parity fixture re-runs with zero differing fields with this section shipped. Done when: the report is quoted showing zero diff.
- [ ] Commit: `"comintrep: opt-in completion chime"`

**Test checkpoint:** Off plays nothing, on plays once at completion, the announcement fires both ways; the parity fixture re-runs zero-diff. Cheaper substitute that fails the checkpoint: a chime without the announcement, which signals nothing to a user who cannot hear it.

-> XREF: D04 T01 §2 -- the parity fixture this section must not disturb

## Verification

- [ ] All 14 repairs name lines, commands, areas, and reversibility verdicts
- [ ] Every ComIntRep line is inventoried with its verdict and home
- [ ] The tool installs, runs, updates, and removes with nothing missing
- [ ] All three enhancements ship fenced with quoted non-interference parity re-runs
- [ ] The frozen effect is byte-identical across commands, writes, files, and services
- [ ] `python scripts/todo-graph.py validate` clean
