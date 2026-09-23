---
schema_version: 1
id: ownership-complete
domain: 04-tools-port
status: draft
title: "TODO-02 -- Ownership: Complete Port and Enhancement"
depends_on: []
track: P2
---

# TODO-02 -- Ownership: Complete Port and Enhancement

> **Goal:** Ownership ships as a complete, distribution-ready C++ tool with nothing the AutoIt version had left behind, plus fenced enhancements that make it the obvious choice over every take-ownership alternative. The vertical slice in `D04 T01 §1` proves parity on the core; this file inventories everything, completes distribution, and enhances without touching the frozen effect.

> [!IMPORTANT]
> **Current state:** Nothing exists in C++. The AutoIt tool is `resolute_au3/SDK/Concrete/Ownership/Ownership.au3` (1,633 lines, ~77 of them real logic): a context-menu installer writing `Directory` and `Drive` `runas` shell entries, with a one-button one-checkbox main window, the standard 3-tab Preferences dialog, Menus File/Help, a status list, a donate strip, splash and `.ani` animations, a single `en.lng` pack, and doc templates. Ownership is frozen: its computed effect is reproduced exactly. The driven run and hands-on competitor use below could not be done from this host and are owed at build, owned by `D04 T01 §1`'s first item and the enhancement sections' first items respectively.

<!-- claim: lines resolute_au3/SDK/Concrete/Ownership/Ownership.au3 = 1633 -->
<!-- claim: count "_Registry_Write" resolute_au3/SDK/Concrete/Ownership/Ownership.au3 = 10 -->
<!-- claim: count "_Registry_Delete" resolute_au3/SDK/Concrete/Ownership/Ownership.au3 = 4 -->
<!-- claim: exists resolute_au3/Resolute/Language/Ownership/en.lng -->

## Inputs

- [`resolute_au3/SDK/Concrete/Ownership/Ownership.au3`](../../resolute_au3/SDK/Concrete/Ownership/Ownership.au3) -- the tool being inventoried and completed
- [`resolute_au3/SDK/Concrete/Ownership/Ownership.sni`](../../resolute_au3/SDK/Concrete/Ownership/Ownership.sni) -- the build descriptor: what ships with it
- [`resolute_au3/Resolute/Language/Ownership/en.lng`](../../resolute_au3/Resolute/Language/Ownership/en.lng) -- the only pack (UTF-16); `[Custom]` and `[Messages2]` carry the tool's own strings
- -> XREF: D04 T01 §1 -- the vertical slice this file inventories for, completes after, and enhances without disturbing

## Outcome

- Every Ownership window, control, string, behavior, setting, and shipped file is inventoried with `file:line` and mapped to framework, repair contract, or tool code.
- The tool ships distribution-complete: migrated settings, packs, docs, icon, installer and update entries, About, F1, guide page, tests, and a green conformance check.
- Two fenced enhancements ship (verify-after-write with per-tree status; remove-all with stuck-state repair), each proven non-interfering by a re-run parity fixture.
- The frozen effect (the two written trees with exact values and command strings) is byte-identical, and no enhancement changes it.

**Adjacency:** list=applicable @ D04 T02 §3; document=applicable @ D04 T02 §2; settings=applicable @ D04 T02 §2; reporting=applicable @ D04 T02 §3; notifications=not-applicable (the tool reports on its surface and logs; it sends no notification); permissions=applicable @ D04 T02 §1; audit=applicable @ D04 T02 §3; exchange=not-applicable (nothing is imported or exported here); reverse=applicable @ D04 T02 §4

**Adjacency rationale:** List, reporting, and audit converge on §3 because per-tree status is the record surface a user browses, the report of what the install did, and the trail a support reader checks. Document and settings pair on §2 because the documentation set and the migrated settings are what "distribution-complete" means. Permissions anchors on §1 where the inventory records the missing elevation request the port must add. Reverse anchors on §4 where remove-all completes the undo the original never fully had. Notifications and exchange stay not-applicable: this tool speaks on its surface and imports nothing.

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Complete inventory with shared-layer map | -- |  [ ]   |
|   2   |   §2    | Distribution completeness | D04 T01 §1 |  [ ]   |
|   3   |   §3    | Verify-after-write and per-tree status | D04 T01 §1 |  [ ]   |
|   4   |   §4    | Remove-all and stuck-state repair | D04 T01 §1 |  [ ]   |

---

## 1. Complete Inventory With Shared-Layer Map

Everything Ownership is, with `file:line`, and every piece mapped to the framework, the repair contract, or tool-specific code. Read the whole 1,633 lines; the inventory below names what to record, and the section is done when a walk of the source finds nothing unaccounted.

The load-bearing finding is recorded here, not discovered at build: the tool writes and deletes exactly **two** trees (`Directory` and `Drive`, `Ownership.au3:681-696` install, `:704-705` remove; 10 writes, 4 deletes), while the status check reads **four** (`:644-647`, adding `*` and `dllfile`, which no line in the file ever writes). `D04 T01 §1`'s correction block says four; its build-time validation must reconcile against this inventory, and the freeze scope is the two written trees with exact values.

**Fidelity:** no surface of its own; this section is the record the slice builds from.
**Needs:** C++ toolchain (compile)

- [ ] Inventory the windows and controls: the main window (`:518`, size and flags) with heading, subheading, pause checkbox (`:581`), Install/Uninstall toggle button (`:583`), status list (`:588`), donate strip (`:605-613`), update animation icon, and commented-out processing icon (dead, cut with reason); the Preferences dialog (`:1082`, 450x500) with all three tabs and every control; File menu (Preferences, Logging submenu, Close) and Help menu (update, home, downloads, support, GitHub, Donate, About) with every item (`:527-552`). Done when: every control-creation call in the file is recorded with its window and purpose.
- [ ] Inventory the strings: every pack section read (`[Custom]`, `[Messages2]`, plus the framework sections), the hardcoded "Take Ownership" program name and registry label (`:277`, `:682`, `:690`, frozen, kept exact and noted unlocalized-by-freeze), and the ESC-minimize hotkey (`:507-511`) with its verdict. Done when: every string names pack key or hardcoded-with-reason.
- [ ] Inventory the behaviors: the two written trees with all five values each (default label, `HasLUAShield`, `NoWorkingDirectory`, `command` default and `IsolatedCommand`), the `&& Pause` variant from the checkbox state (`:672-678`), the install/remove log lines from `[Messages2]`, the OR-of-four status rule, the single-instance guard (`:435`), and the absent elevation request (no `#RequireAdmin`, no admin check: the port checks at the action per `D01 T01 §6`, recorded as a parity-relevant gap the framework closes). Done when: every read and write is marked, and the two-tree effect is stated as the freeze scope.
- [ ] Inventory settings, logging, update, and distribution: the framework-only `.ini` keys (no tool-specific key exists; the pause checkbox is deliberately unpersisted, kept so for parity), the `[Messages2]` log lines and what is never logged, the update check path, and the `.sni` ship list (exe pair, ini, three docs, en pack, two `.ani` files: verdict the animations cut, replaced by the shared progress). Done when: every key, line, and shipped file is recorded with keep, cut, or remapped.
- [ ] Map every inventoried piece to framework, repair contract, or tool code: settings, logging, localization, update, elevation, prefs host, About, crash, singleton, F1 to the framework; install/remove/status/verify/undo items to the repair contract; the toggle button, pause checkbox, and per-tree status to the tool. Done when: no piece maps to two homes and no shared piece maps to the tool.
- [ ] Commit: `"ownership: complete inventory with shared-layer map"`

**Test checkpoint:** A walk of `Ownership.au3` line by line finds every window, control, string, behavior, setting, and shipped file recorded with its verdict and home; the two-tree effect is stated with line numbers against `D04 T01 §1`'s four; the `.sni` ship list is fully verdict. Cheaper substitute that fails the checkpoint: an inventory of the windows without the behaviors, which is a screenshot inventory rather than a port plan.

-> XREF: D04 T01 §1 -- the slice build this inventory feeds

## 2. Distribution Completeness

Everything that makes the ported tool shippable rather than merely working: settings migration, packs, docs, icon, installer and update entries, About, F1, guide page, tests, and conformance. Runs after the slice proves parity on the core.

**Fidelity:** the tool as shipped: installer entries, docs, and About, against the AutoIt distribution.
**Job:** a user can install, run, update, and remove the tool with nothing missing. Consumer: the installed tool and its docs.
**Treatment:** every AutoIt-shipped artifact has a C++ successor or a recorded cut. Cheaper substitute that fails the checkpoint: a tool that runs from the build tree but was never installed anywhere, which is how missing files ship.
**Chrome:** consume the framework installer entries, About, and help. No tool-side installer logic.
**Needs:** Windows host (build/test)

- [ ] Migrate settings and ship the packs: an existing AutoIt `.ini` migrates its framework keys with a log line; `en.lng` ships and the pack-hygiene rules from `D08 T01 §3` hold. Done when: a fixture `.ini` migrates and the pack check passes, both quoted.
- [ ] Ship the docs set from the three templates (`Changes.tpl`, `License.tpl`, `Readme.tpl`): every template renders with generated metadata (no typed version or date) and the set matches the `D08 T01 §1` contract. Done when: all three render and the conformance check agrees.
- [ ] Register installer and update-file entries per `D06 T01 §3` and `D06 T01 §5`: portable and installed modes, the application icon, and the update descriptor. Done when: both modes install and remove cleanly on a fixture machine.
- [ ] Wire About, F1, and the guide page: About from the registry for the Ownership descriptor, F1 through the surface map, and the user-guide page in the same commit as the behavior it documents. Done when: all three resolve and the guide page shares its commit.
- [ ] Prove tests and conformance: unit tests for the tool-specific logic run under the harness, and the `D07 T01 §3` check passes for the tool. Done when: `ctest` names the suites green and the conformance report is quoted.
- [ ] Prove first-run and upgrade: a clean machine goes from install to working with no manual step, and a machine carrying the AutoIt Ownership upgrades with settings preserved and one copy left. Done when: both paths are driven and quoted. Cheaper substitute that fails the checkpoint: testing upgrade by reading the code, which is how two copies ship.
- [ ] Commit: `"ownership: distribution completeness"`

**Test checkpoint:** Fixture `.ini` migrates; packs pass hygiene; three docs render generated; both install modes round-trip; About, F1, and the guide page resolve; tests and conformance quote green; first-run and upgrade are driven. Cheaper substitute that fails the checkpoint: a checklist ticked from the build tree, which proves the tool compiles rather than ships.

-> XREF: D04 T01 §1 -- the parity core this section ships

## 3. Verify-After-Write and Per-Tree Status

**Deliberate new behavior.** The AutoIt tool writes and hopes: no readback, and a single OR-of-four status that cannot say which tree is missing. This section adds verify-after-write (every written value read back, mismatch refused by name) and per-tree status (each of the four trees shown installed or missing). Pure reads plus display: the frozen effect is untouched.

Competitor context (source-based, hands-on owed at build): TakeOwnershipEx (Winaero, v1.2-era) acts directly on a chosen path with a take/restore toggle rather than installing a shell entry ([source](https://winaero.com/takeownershipex/)); Easy Context Menu (Sordum) manages ownership entries among dozens of toggles. Neither verifies its writes readably. This tool stays a context-menu installer (the frozen job) and beats both on honesty: it shows exactly what is installed, per tree, verified.

**Fidelity:** the per-tree status surface, against `DESIGN.md`; new surface, no AutoIt baseline.
**Job:** a user sees exactly which entries are installed and trusts the install worked. Consumer: the status surface and one log line per verification.
**Treatment:** verify every write by readback; show per-tree state always, not only on failure. Cheaper substitute that fails the checkpoint: verifying only on failure, which cannot distinguish "wrote wrong" from "never wrote".
**Chrome:** consume the framework list surface and message layer. No new dialog.
**Needs:** Windows host (build/test)

- [ ] Confirm the competitor table hands-on: run TakeOwnershipEx and Easy Context Menu, verify the documented behaviors above against the named versions, and correct the table. Done when: each row names the version used and what was observed, quoted.
- [ ] Verify after every write: each of the 10 values is read back after install and any mismatch refuses by tree, value, expected, and found, with one log line. Done when: a deliberately corrupted write is refused naming all four, quoted.
- [ ] Show per-tree status: all four `runas` trees each render installed or missing with their values' state, replacing the single OR status; the Install/Uninstall toggle follows all-installed versus otherwise with the rule stated. Done when: a fixture with one tree removed renders exactly that tree missing.
- [ ] Cover the finer details: tooltips on the status icons, keyboard reachability with tab order, screen-reader names, both themes and DPI scalings, and the exact texts with pack keys. Done when: each is driven or captured, none deferred.
- [ ] Prove non-interference: the `D04 T01 §1` parity fixture re-runs with zero differing fields with this section shipped. Done when: the report is quoted showing zero diff.
- [ ] Commit: `"ownership: verify-after-write and per-tree status"`

**Test checkpoint:** Competitor rows name used versions; a corrupted write is refused naming tree, value, expected, and found; one removed tree renders exactly missing; finer details are driven or captured; the parity fixture re-runs zero-diff. Cheaper substitute that fails the checkpoint: per-tree status without verify, which displays state it never checked.

-> XREF: D04 T01 §1 -- the parity fixture this section must not disturb

## 4. Remove-All and Stuck-State Repair

**Deliberate new behavior.** The AutoIt remove path deletes two trees while status reads four, so residue in `*` or `dllfile` (left by an older version) leaves the tool permanently "installed" with an Uninstall button that changes nothing. This section makes remove delete all four `runas` trees and makes that stuck state unreachable. Fenced justification: residue the tool never wrote is not the tool's frozen effect; the frozen effect is the two written trees with exact values, unchanged. On a residue-free machine the outcome is identical to the original, proven by re-running parity.

**Fidelity:** the remove path and its confirmation, against `DESIGN.md` §11; no new dialog.
**Job:** uninstall means uninstalled, even with residue from an older version. Consumer: the cleaned `HKCR` trees, read back.
**Treatment:** remove-all with a confirmation naming the trees found, including residue. Cheaper substitute that fails the checkpoint: deleting all four silently, which hides from the user that residue existed.
**Chrome:** consume the framework message layer for the confirmation. No new dialog.
**Needs:** Windows host (build/test)

- [ ] Remove all four trees: uninstall deletes every `runas` tree found under the four parents, after a confirmation naming each tree and whether it is tool-written or residue. Done when: a fixture carrying all four plus residue removes all of them, quoted, and the confirmation names each.
- [ ] Make the stuck state unreachable: with per-tree status from §3, any present tree renders missing-or-present honestly and the toggle always offers the action that changes state. Done when: a residue-only fixture renders honestly and one Uninstall clears it.
- [ ] Prove non-interference: the `D04 T01 §1` parity fixture (residue-free) re-runs with zero differing fields with this section shipped. Done when: the report is quoted showing zero diff.
- [ ] Commit: `"ownership: remove-all and stuck-state repair"`

**Test checkpoint:** A four-tree-plus-residue fixture clears fully with each tree named in the confirmation; a residue-only fixture renders honestly and clears in one action; the residue-free parity fixture re-runs zero-diff. Cheaper substitute that fails the checkpoint: remove-all without the confirmation naming residue, which fixes the state and hides the history.

-> XREF: D04 T01 §1 -- the parity fixture this section must not disturb

## Verification

- [ ] Every AutoIt Ownership line is inventoried with its verdict and home
- [ ] The tool installs, runs, updates, and removes with nothing missing
- [ ] Both enhancements ship fenced with quoted non-interference parity re-runs
- [ ] The frozen two-tree effect is byte-identical including both command strings
- [ ] `python scripts/todo-graph.py validate` clean
