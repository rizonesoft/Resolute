---
schema_version: 1
id: bioscodes-complete
domain: 04-tools-port
status: draft
title: "TODO-05 -- BiosCodes: Complete Port and Enhancement"
depends_on: []
track: P2
---

# TODO-05 -- BiosCodes: Complete Port and Enhancement

> **Goal:** BiosCodes ships as a complete, distribution-ready C++ tool: the 7-vendor beep database and the live WMI info page reproduced exactly, every surface and string accounted for, distribution-complete, plus fenced enhancements that make it the definitive beep-code tool. The build, the first-ever logging, and the export stay in `D04 T01 §5`; this file specifies, completes, and enhances without touching the frozen data.

> [!IMPORTANT]
> **Current state:** Nothing exists in C++. The AutoIt tool is `resolute_au3/SDK/Concrete/BiosCodes/BiosCodes.au3` (2,516 lines): 7 vendor tabs (AMI, AST, Award, Compaq, Dell, IBM, Phoenix) with per-pattern meanings composed from 244 `[BeepInformation]` pack keys, a BIOS Information page reading Win32_BaseBoard and Win32_BIOS over WMI into a 2-column list, a shared details Edit, 3 language packs (`de`, `en`, `ko`), and doc templates. BiosCodes is frozen: its beep data and WMI mappings transfer exactly. The driven run and hands-on competitor use below could not be done from this host and are owed at build, owned by `D04 T01 §5`'s capture item and the enhancement sections' first items respectively.

<!-- claim: lines resolute_au3/SDK/Concrete/BiosCodes/BiosCodes.au3 = 2516 -->
<!-- claim: exists resolute_au3/Resolute/Language/BiosCodes/en.lng -->
<!-- claim: exists resolute_au3/Resolute/Language/BiosCodes/de.lng -->
<!-- claim: exists resolute_au3/Resolute/Language/BiosCodes/ko.lng -->

## Inputs

- [`resolute_au3/SDK/Concrete/BiosCodes/BiosCodes.au3`](../../resolute_au3/SDK/Concrete/BiosCodes/BiosCodes.au3) -- the tool being inventoried and completed
- [`resolute_au3/SDK/Concrete/BiosCodes/BiosCodes.sni`](../../resolute_au3/SDK/Concrete/BiosCodes/BiosCodes.sni) -- the build descriptor: what ships with it
- [`resolute_au3/Resolute/Language/BiosCodes/en.lng`](../../resolute_au3/Resolute/Language/BiosCodes/en.lng) -- the English pack (UTF-16); `[BeepInformation]` holds the 244-key database
- -> XREF: D04 T01 §5 -- the build this file specifies for

## Outcome

- All 7 vendor tables transfer with pattern counts, meaning composition rules, and the Intel/Insyde verdict; the WMI field mappings transfer exactly.
- Every BiosCodes window, control, string, setting, and shipped file is inventoried with `file:line` and mapped to framework or tool code.
- The tool ships distribution-complete: migrated settings, 3 packs, docs, icon, installer and update entries, About, F1, guide page, tests, and a green conformance check.
- Two fenced enhancements ship (cross-vendor pattern search, vendor auto-detect), each proven non-interfering by a re-run parity check.
- The frozen beep data and WMI mappings are identical, and no enhancement changes a lookup answer.

**Adjacency:** list=applicable @ D04 T05 §2; document=not-applicable (the tool looks up and displays; the export the tool never had belongs to `D04 T01 §5`, not this file); settings=applicable @ D04 T05 §3; reporting=not-applicable (a lookup answer is a display, not a report); notifications=not-applicable (the tool reports on its surface and logs; it sends no notification); permissions=not-applicable (WMI reads need no privilege the user lacks, and there is no role model); audit=not-applicable (lookups leave a log line, not an audit trail); exchange=not-applicable (nothing is imported or exported here); reverse=not-applicable (looking something up changes nothing that needs undoing)

**Adjacency rationale:** List anchors on §2 where the vendor pattern lists are the browsed record surface, and settings on §3 as what distribution-complete means. Everything else stays not-applicable with the reason each belongs elsewhere or nowhere: document and exchange defer to the `D04 T01 §5` export this file must not double-own, and reporting, notifications, permissions, audit, and reverse have nothing to anchor to in a lookup tool.

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Beep data and WMI inventory | -- |  [ ]   |
|   2   |   §2    | Surface inventory with shared-layer map | -- |  [ ]   |
|   3   |   §3    | Distribution completeness | D04 T01 §5 |  [ ]   |
|   4   |   §4    | Cross-vendor pattern search | D04 T01 §5, §6 |  [ ]   |
|   5   |   §5    | Vendor auto-detect from WMI | D04 T01 §5, §6 |  [ ]   |
|   6   |   §6    | Migrate beep data to reference DB | D04 T01 §5, D00 T06 §3, D01 T01 §14 |  [ ]   |
|   7   |   §7    | User-editable database (CRUD) | §6 |  [ ]   |

---

## 1. Beep Data and WMI Inventory

The frozen content, pinned. Seven `_Display*BeepCodes` functions (`BiosCodes.au3:783-1263`): AMI (`:783`, 15 patterns), AST (`:831`), Award (`:888`), Compaq (`:917`), Dell (`:950`), IBM (`:983`), Phoenix (`:1022-1263`, the long table including the Intel 1-3-3-3 combo description). Each composes meanings from `[BeepInformation]` pack indices plus footer keys; the index arithmetic is the frozen mapping. The WMI page (`__WMI_BaseBoard` `:1355`, `__WMI_Bios` `:1405`) reads Win32_BaseBoard and Win32_BIOS into 30-column arrays with characteristic decode, bool-to-Yes/No, and date conversion.

**Fidelity:** no surface of its own; this section is the record parity is measured against.
**Needs:** C++ toolchain (compile)

- [ ] Pin all 7 vendor tables: pattern count per vendor, every meaning-composition rule with its pack indices, and the footer keys. Done when: each vendor names its count and rules, and the 244-key total is reconciled against the tables.
- [ ] Verdict the Intel and Insyde keys (`Button_BIOS_Intel`, `Button_BIOS_Insyde`, `Label_Intel_Desc`): the sidebar builds 8 buttons (BIOS Info plus 7 vendors) with no Intel or Insyde button, so these keys are either read inside the Phoenix display or dead. Done when: each key is traced to its read or cut as dead with the trace quoted.
- [ ] Pin the WMI mappings: every Win32_BaseBoard and Win32_BIOS property read, its display column, and the decode helpers (characteristic, bool, date, state, array-join), plus the WMI error presentation (`__ReturnWMIError`, `MyErrFunc`). Done when: every property names its column and every helper names its rule.
- [ ] Record the system-parameter verdict: the window procs toggle `SPI_SETDRAGFULLWINDOWS` off during resize and restore after (`:1637-1674`). Done when: the verdict is recorded (cut: the Direct2D window resizes live and no tool writes a system parameter to move its own window) with the resize behavior it replaces stated.
- [ ] Commit: `"bioscodes: beep data and WMI inventory"`

**Test checkpoint:** All 7 tables name counts and composition rules reconciled to 244 keys; Intel/Insyde keys are traced or cut; every WMI property names its column with helpers pinned; the SPI verdict is recorded. `D04 T01 §5` can state its parity comparison (same lookups, same info) from this section alone. Cheaper substitute that fails the checkpoint: tables without the composition rules, which pins the strings but not the answers.

-> XREF: D04 T01 §5 -- the build that proves parity from this inventory

## 2. Surface Inventory With Shared-Layer Map

Every BiosCodes window, control, string, setting, and shipped file, with `file:line`, mapped to framework or tool code. The main window (`:536`, resizable `OVERLAPPEDWINDOW` with min/max proc): heading, subheading, 8 pushlike sidebar buttons (`:600-604`, BIOS Info plus 7 vendors), a hidden-button tab control (`:608`), the BIOS Info page (3 pushlike section buttons `:614-616`, 2-column ListView `:621-629`), 7 vendor tabs each with a pattern List (`:640-`, 200 wide except Compaq 300), the shared details Edit, status icon and label, donate strip, update animation. File/Help menus standard. Preferences (`:1968`, 450x500, three framework tabs, no tool page).

**Fidelity:** no surface of its own; this section is the record the build renders from.
**Needs:** C++ toolchain (compile)

- [ ] Inventory the main window control by control with string sources: all 8 sidebar buttons, the BIOS Info section buttons and both ListView columns with widths, all 7 pattern Lists with widths, the details Edit, the heading and subheading, and the status elements. Done when: every control names its strings and the Compaq width exception is recorded with its content reason.
- [ ] Inventory the event model: sidebar click selects the page, list click shows the meaning, vendor-button click with no list selection shows the default text (`_ExecuteButtonAction` `:1581`, `Case Else`), hover tooltips on icons. Done when: every event names its handler and the default-text rule is stated.
- [ ] Inventory settings, logging, and distribution: the framework-only `.ini` keys (no tool-specific key; vendor selection and list position are unpersisted, kept so for parity), the absent logging (the tool writes no log at all; `D04 T01 §5` adds it, not this file), and the `.sni` ship list (exe pair, ini, three docs, two `.ani` files cut; no pack ships at all, recorded as a ship-list gap §3 closes). Done when: every key and shipped file carries keep, cut, or remapped.
- [ ] Map every inventoried piece to framework or tool code: window, menus, prefs host, log, update, About, crash, singleton, F1 to the framework; vendor tabs, lists, details Edit, WMI page, and decodes to the tool; nothing to the repair contract (recorded: a lookup changes nothing, per the `D04 T01 §5` treatment). Done when: no piece maps to two homes and the contract exclusion is stated.
- [ ] Commit: `"bioscodes: surface inventory with shared-layer map"`

**Test checkpoint:** A walk of `BiosCodes.au3` finds every control, string, setting, and shipped file recorded with verdict and home; the event model names every handler and the default-text rule; the pack ship gap is recorded; the contract exclusion is stated. Cheaper substitute that fails the checkpoint: controls without the event model, which ships buttons with unknown behavior.

-> XREF: D04 T01 §5 -- the build that renders from this inventory

## 3. Distribution Completeness

Everything that makes the ported tool shippable: settings migration, 3 packs, docs, icon, installer and update entries, About, F1, guide page, tests, and conformance. Runs after `D04 T01 §5` proves parity on the core. The §5 export is that section's scope, not this file's; this section ships everything around it.

**Fidelity:** the tool as shipped: installer entries, docs, and About, against the AutoIt distribution.
**Job:** a user can install, run, update, and remove the tool with nothing missing. Consumer: the installed tool and its docs.
**Treatment:** every AutoIt-shipped artifact has a C++ successor or a recorded cut. Cheaper substitute that fails the checkpoint: a tool that runs from the build tree but was never installed anywhere, which is how missing files ship.
**Chrome:** consume the framework installer entries, About, and help. No tool-side installer logic.
**Needs:** Windows host (build/test)

- [ ] Migrate settings and ship the packs: an existing AutoIt `.ini` migrates its framework keys with a log line; all 3 packs ship (closing the §2 ship-list gap) and the pack-hygiene rules from `D08 T01 §3` hold. Done when: a fixture `.ini` migrates and the pack check passes on all 3, both quoted.
- [ ] Ship the docs set from the three templates: every template renders with generated metadata (no typed version or date) and the set matches the `D08 T01 §1` contract. Done when: all three render and the conformance check agrees.
- [ ] Register installer and update-file entries per `D06 T01 §3` and `D06 T01 §5`: portable and installed modes, the application icon, and the update descriptor. Done when: both modes install and remove cleanly on a fixture machine.
- [ ] Wire About, F1, and the guide page: About from the registry for the BiosCodes descriptor, F1 through the surface map, and the user-guide page in the same commit as the behavior it documents. Done when: all three resolve and the guide page shares its commit.
- [ ] Prove tests and conformance: unit tests for the tool-specific logic (table lookups, composition rules, WMI decode helpers) run under the harness, and the `D07 T01 §3` check passes for the tool. Done when: `ctest` names the suites green and the conformance report is quoted.
- [ ] Prove first-run and upgrade: a clean machine goes from install to working with no manual step, and a machine carrying the AutoIt BiosCodes upgrades with settings preserved and one copy left. Done when: both paths are driven and quoted. Cheaper substitute that fails the checkpoint: testing upgrade by reading the code, which is how two copies ship.
- [ ] Commit: `"bioscodes: distribution completeness"`

**Test checkpoint:** Fixture `.ini` migrates; 3 packs pass hygiene; three docs render generated; both install modes round-trip; About, F1, and the guide page resolve; tests and conformance quote green; first-run and upgrade are driven. Cheaper substitute that fails the checkpoint: a checklist ticked from the build tree, which proves the tool compiles rather than ships.

-> XREF: D04 T01 §5 -- the parity core this section ships

## 4. Cross-Vendor Pattern Search

**Deliberate new behavior.** The AutoIt tool browses one vendor's list at a time; a user who does not know their BIOS vendor hunts through seven tabs. This section adds a pattern search across all vendors ("1 long 2 short" finds every vendor's matching entry with its meaning). Read-only over frozen data: no lookup answer changes.

Competitor context (source-based, hands-on owed at build): web references (ComputerHope's beep-code pages, manufacturer manuals) list codes per vendor but require knowing the vendor and being online; CPU-Z-class tools show system information with no beep database at all. None searches a pattern across vendors offline. This tool keeps its offline database and gains the search none of them has.

**Fidelity:** the search input and cross-vendor results, against `DESIGN.md`; new surface, no AutoIt baseline.
**Job:** a user who heard the beeps but does not know the vendor reaches every candidate meaning. Consumer: the results list and the carried answer.
**Treatment:** plain-word matching with an exact stated rule, ranked by a recorded rule, every result naming its vendor. Cheaper substitute that fails the checkpoint: substring matching with no rule, which matches everything and ranks nothing.
**Chrome:** consume the framework input and list surfaces. No bespoke search control.
**Needs:** Windows host (build/test)

- [ ] Confirm the competitor table hands-on: use the named web references and one system-info tool, verify the documented behaviors above, and correct the table. Done when: each row names the version or page used and what was observed, quoted.
- [ ] Search every vendor's patterns: the input, the exact matching rule (words, numbers, long/short synonyms), the ranking rule, the result rows naming vendor plus meaning, and the no-match presentation with its pack key. Done when: a pattern known to two vendors returns both in ranked order, and an unknown pattern renders no-match, both quoted.
- [ ] Cover the finer details: keyboard path, screen-reader names and result announcements, both themes and DPI scalings, and the exact texts with pack keys. Done when: each is driven or captured, none deferred.
- [ ] Prove non-interference: the `D04 T01 §5` parity check re-runs clean with this section shipped. Done when: the comparison is quoted showing no difference.
- [ ] Commit: `"bioscodes: cross-vendor pattern search"`

**Test checkpoint:** Competitor rows name used versions; a two-vendor pattern returns both ranked; unknown renders no-match; finer details are driven or captured; the parity comparison re-runs clean. Cheaper substitute that fails the checkpoint: results without vendor names, which answer the pattern and hide which machine it applies to.

-> XREF: D04 T01 §5 -- the parity check this section must not disturb

## 5. Vendor Auto-Detect From WMI

**Deliberate new behavior.** The tool already reads the BIOS manufacturer over WMI, then ignores it and opens on the BIOS Info page. This section matches the manufacturer string to a vendor tab and opens that tab first, falling back to the Info page when nothing matches. Navigation only: no data changes, and the user can still browse every tab.

**Fidelity:** the opened-first tab; no new surface beyond the matching.
**Job:** a user sees their vendor's codes first without knowing their vendor. Consumer: the selected tab on launch.
**Treatment:** match on normalized manufacturer substrings with a recorded table; unknown or unreadable WMI opens the Info page exactly as today. Cheaper substitute that fails the checkpoint: matching on exact strings, which misses every vendor that spells its name twice.
**Chrome:** none; this section selects a tab.
**Needs:** Windows host (build/test)

- [ ] Open the detected vendor first: the normalization and match table (AMI, Award/Phoenix, Dell, IBM/Lenovo, Compaq/HP, AST) with each entry's substrings, the unknown fallback, and the WMI-unreadable fallback. Done when: fixtures for three matched vendors and both fallbacks open the right page, quoted.
- [ ] Cover the finer details: screen-reader announcement of the selected tab, and the exact texts with pack keys. Done when: each is driven or captured, none deferred.
- [ ] Prove non-interference: the `D04 T01 §5` parity check re-runs clean with this section shipped. Done when: the comparison is quoted showing no difference.
- [ ] Commit: `"bioscodes: vendor auto-detect from WMI"`

**Test checkpoint:** Three matched fixtures and both fallbacks open correctly; finer details are driven or captured; the parity comparison re-runs clean. Cheaper substitute that fails the checkpoint: auto-detect without the fallbacks, which strands every unknown machine on a wrong vendor's codes.

-> XREF: D04 T01 §5 -- the parity check this section must not disturb

## 6. Migrate Beep Data to the Reference Database

BiosCodes becomes the platform's first consumer: its lookups read the embedded beep dataset through the framework loader instead of the packs, and the extended data from `D00 T06 §4` (new vendors, blink codes, POST codes) ships in the tool with its surfaces. A migration, not a rewrite: every original answer stays identical.

**Fidelity:** the vendor tabs plus the new blink family presentation, against `DESIGN.md`; new vendors follow the existing tab shape.
**Job:** a user looks up beep, blink, and POST codes from one database that keeps growing. Consumer: the lookup answers and the WMI page.
**Treatment:** same answers from a new store, then new answers from new data, proven in that order. Cheaper substitute that fails the checkpoint: migrating and extending in one step, which cannot tell a moved answer from a new one.
**Chrome:** consume the framework list surfaces and the loader. No new dialog for the migration itself.
**Needs:** Windows host (build/test)

- [ ] Migrate lookups to the loader: every vendor table and the WMI page read through `D01 T01 §14`, and the packs carry UI strings only. Done when: the pack-driven code path is gone and the lookup diff from `D00 T06 §3` still shows zero differences, quoted.
- [ ] Ship the extended data: new vendor tabs, the blink family as a typed presentation distinct from beeps, and POST codes, all with pack-keyed UI strings. Done when: every new entry from `D00 T06 §4` is reachable and rendered, quoted.
- [ ] Cover the finer details: keyboard path, screen-reader names and announcements, both themes and DPI scalings, and the exact texts with pack keys. Done when: each is driven or captured, none deferred.
- [ ] Prove non-interference: the `D04 T01 §5` parity check re-runs clean with this section shipped. Done when: the comparison is quoted showing no difference.
- [ ] Commit: `"bioscodes: migrate beep data to the reference database"`

**Test checkpoint:** Pack-driven lookups are gone with the diff at zero; every extended entry is reachable; finer details are driven or captured; the parity comparison re-runs clean. Cheaper substitute that fails the checkpoint: new tabs without the migration diff, which ship new answers on an unproven store.

-> XREF: D00 T06 §3 -- the migrated dataset this section consumes
-> XREF: D04 T01 §5 -- the parity check this section must not disturb

## 7. User-Editable Database (CRUD)

**Deliberate new behavior.** The shipped database is frozen and read-only; this section layers a user stratum over it: the user adds, edits, and deletes their own beep, blink, and POST entries, stored per-user, badged as user data, and included in lookup and search. Nobody waits for a release to record a code they just decoded.

**Fidelity:** the user-entry editor and badged rows, against `DESIGN.md`; new surface, no AutoIt baseline.
**Job:** a user records a code the database lacks and finds it again like any other entry. Consumer: the user stratum file and the lookup answers.
**Treatment:** user entries live beside shipped data, never inside it; shipped entries cannot be edited, only supplemented. Cheaper substitute that fails the checkpoint: editing shipped entries in place, which corrupts the frozen data with local guesses.
**Chrome:** consume the framework list surfaces, dialog, and message layer. No new dialog chrome beyond the editor.
**Needs:** Windows host (build/test)

- [ ] Store the user stratum per-user with atomic write and readback: add, edit, and delete entries across all three families with validation (pattern shape, required meaning, vendor exists). Done when: all three operations round-trip through a forced restart, and invalid input is refused naming the field, quoted.
- [ ] Keep shipped entries immutable and badge user entries: shipped rows render locked with no edit path, user rows render badged, and a user entry never overwrites a shipped answer (same pattern plus vendor renders both, shipped first). Done when: the lock and badge rules hold on fixtures, quoted.
- [ ] Include user entries in lookup and cross-vendor search with their badge, and in F1 results. Done when: a user entry is found by lookup, by search, and by F1, quoted.
- [ ] Export and import the user stratum: one file out with the entries plus their versions, one file in with validation refusing bad rows by number, so entries carry to another machine. Done when: a round-trip preserves every entry and a corrupt file is refused naming its row, quoted.
- [ ] Cover the finer details: keyboard path, screen-reader names and announcements, both themes and DPI scalings, empty-stratum presentation, and the exact texts with pack keys. Done when: each is driven or captured, none deferred.
- [ ] Prove non-interference: the `D04 T01 §5` parity check re-runs clean with this section shipped, and a populated user stratum leaves every shipped answer unchanged. Done when: both comparisons are quoted showing no difference.
- [ ] Commit: `"bioscodes: user-editable database"`

**Test checkpoint:** CRUD round-trips with validation; shipped locked and user badged with both rendered on collision; user entries found by lookup, search, and F1; export/import round-trips with corrupt refused by row; finer details driven or captured; parity clean with empty and populated strata. Cheaper substitute that fails the checkpoint: user entries without the badge, which present guesses as vendor data.

-> XREF: D04 T01 §5 -- the parity check this section must not disturb

## Verification

- [ ] All 7 vendor tables and the WMI mappings transfer exactly
- [ ] Every BiosCodes line is inventoried with its verdict and home
- [ ] The tool installs, runs, updates, and removes with nothing missing
- [ ] Both enhancements ship fenced with quoted non-interference parity re-runs
- [ ] The frozen beep data and WMI mappings are identical
- [ ] `python scripts/todo-graph.py validate` clean
