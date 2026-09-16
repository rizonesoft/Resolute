---
schema_version: 1
id: regstudio
domain: 05-new-tools
status: draft
title: "TODO-02 -- RegStudio"
depends_on: [intake-and-new-tools, repair-contract]
frozen: true
track: P3
---

# TODO-02 -- RegStudio

> **Goal:** A registry editor that can undo what it did. RegStudio browses, searches, edits, and exports the registry on the shared framework, and every change it makes is recorded before it happens and reversible afterwards, which is the one thing the tool everybody already has cannot do.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** RegStudio exists twice and both copies are byte-identical in `src/` and `CMakeLists.txt`: `samples/RegStudio/` carries the git history and a build output, and `samples/ExoSuite/extensions/RegStudio/` is the copy that arrives with the ExoSuite intake. The authoritative history is the root copy, latest commit `c9b8a0b`.
>
> It is an **early prototype, not a near-complete tool.** Its own `TODO.md` reports **95 items done and 323 open**, roughly 23 percent. All 1,086 lines are in a single `src/main.cpp`; `src/core/` and `src/ui/` exist but contain only `.gitkeep`. What works is the window with resizable panes, the menu bar, a dark title bar via `DwmSetWindowAttribute`, and a TreeView and ListView created with 6 registry API calls behind them. What does not exist is the registry engine, value editing, search, backup and restore, and any privilege handling.
>
> It is built on **native Win32 `comctl32` controls, not the shared UI library**, so conforming it to `DESIGN.md` means replacing its control layer rather than restyling it.

## Inputs

- [`samples/RegStudio/src/main.cpp`](../../samples/RegStudio/src/main.cpp) -- the whole tool today, 1,086 lines
- [`samples/RegStudio/TODO.md`](../../samples/RegStudio/TODO.md) -- 95 done, 323 open; this file routes what is still wanted
- -> XREF: [`00-workspace/TODO-03 §1`](../00-workspace/TODO-03-codebase-intake.md) -- the intake that reconciles the two copies and brings the history in
- -> XREF: [`02-repair-contract/TODO-01 §4`](../02-repair-contract/TODO-01-repair-contract.md) -- the restore record and undo every edit here goes through
- -> XREF: [`05-new-tools/TODO-01 §1`](./TODO-01-intake-and-new-tools.md) -- the intake contract this tool is measured against

## Outcome

- RegStudio runs on the shared framework and the shared UI library, conformant on its first shipped build.
- Every registry change is recorded before it happens and can be undone.
- A user can find a key or value without knowing exactly where it lives.
- A user can export a subtree, hand it to somebody, and import it back safely.
- The tool refuses by name rather than failing obscurely when it lacks the privilege.

**Adjacency:** list=applicable @ D05 T02 §3; document=applicable @ D05 T02 §6; settings=applicable @ D05 T02 §1; reporting=applicable @ D05 T02 §4; notifications=applicable @ D05 T02 §4; permissions=applicable @ D05 T02 §4; audit=applicable @ D05 T02 §4; exchange=applicable @ D05 T02 §6; reverse=applicable @ D05 T02 §4

**Adjacency rationale:** Reverse, permissions, audit, reporting, and notifications all converge on §4 because that is the section where this tool becomes dangerous: an editor that writes to the registry owes an undo, a refusal, a trail, and a clear statement of what it just did, and those five are the same obligation seen from five sides. Exchange and document pair on §6 because a `.reg` file is simultaneously the export a user carries to another machine and untrusted input on the way back in, which is the single riskiest path in the tool.

## Implementation Order

| Order | Section | Deliverable                               | Depends On             | Status |
| :---: | :-----: | ----------------------------------------- | ---------------------- | :----: |
|   1   |   §1    | RegStudio on the shared framework         | D05 T01 §1, D01 T01 §9 |  [ ]   |
|   2   |   §2    | The registry engine                       | §1                     |  [ ]   |
|   3   |   §3    | Browse, display, and virtualize           | §2, D01 T02 §3         |  [ ]   |
|   4   |   §4    | Editing, with a reverse                   | §2, D02 T01 §4         |  [ ]   |
|   5   |   §5    | Search across hives                       | §3                     |  [ ]   |
|   6   |   §6    | Backup, restore, and `.reg` exchange      | §4                     |  [ ]   |

---

## 1. RegStudio on the Shared Framework

1,086 lines in one file, on control primitives the rest of the suite does not use. This section makes it a Resolute tool rather than a standalone program that happens to live in the repository.

**Fidelity:** the RegStudio main window, against `DESIGN.md` and `docs/captures/house-style/`. The existing window is a starting point, not a baseline to preserve: its `comctl32` controls are being replaced.
**Job:** a user opens a registry editor that looks and behaves like every other Resolute tool. Consumer: the rendered window, and the settings that persist.
**Treatment:** the tool rebuilt as framework plus shared controls plus its own registry logic. Cheaper substitute that fails the checkpoint: restyling the `comctl32` controls to look similar, which leaves a second control layer in the suite forever.
**Chrome:** consume the framework and the shared UI library. Do not keep a private control layer, settings writer, or theme handling.
**Needs:** C++ toolchain (compile)

- [ ] Reconcile the two copies and record which was taken. Done when: only one RegStudio source tree exists in the repository and this section names the commit it came from.
- [ ] Split `main.cpp` into the structure its own layout intends: registry logic under `core/`, surfaces under `ui/`, and an entry point that does neither. Done when: no file mixes registry access with rendering, and `core/` has no dependency on any UI header.
- [ ] Replace the `comctl32` control layer with the shared UI library. Done when: no `WC_TREEVIEW`, `WC_LISTVIEW`, or `comctl32` control remains, proven by search.
- [ ] Remove its private dark-title-bar handling in favour of the framework's theme. Done when: the tool's own `DwmSetWindowAttribute` call is gone and the window still themes correctly in both appearances.
- [ ] Route its settings through the shared writer: window geometry, pane ratio, last-visited key. Done when: all three persist and survive a restart, proven by readback.
- [ ] Localize every string. Done when: driving with an incomplete pack lists the missing keys and nothing renders as bare English.
- [ ] Commit: `"regstudio: rebuild on the shared framework and ui library"`

**Test checkpoint:** No `comctl32` control and no private theme call remains, both proven by search. `core/` has no UI dependency. Window geometry, pane ratio, and last key persist across a restart, quoted. An incomplete pack produces a missing-key list. The window is captured in both appearances and compared against `DESIGN.md`.

## 2. The Registry Engine

The part that does not exist yet. Six registry calls in a UI file is a demo; this section is the real thing, and it is deliberately separated from the surface so it can be tested without a window.

**Fidelity:** no surface of its own; §3 renders what this produces.
**Needs:** C++ toolchain (compile)

- [ ] Implement key enumeration, value enumeration, and read across every hive, with RAII handles. Done when: a fixture key tree is enumerated completely and no handle leaks under a repeated-open assertion.
- [ ] Support every value type Windows defines, including the ones editors commonly skip: `REG_MULTI_SZ`, `REG_EXPAND_SZ`, `REG_QWORD`, `REG_BINARY`, and unknown types preserved rather than dropped. Done when: a fixture carrying every type round-trips byte-identically.
- [ ] Handle the 32-bit and 64-bit registry views explicitly. Done when: a value written to the `WOW6432Node` view is distinguishable from its 64-bit counterpart, and the surface can say which it is showing.
- [ ] Report access failures as a named outcome rather than an empty result. Done when: a key the process cannot read is reported as denied, not as empty, and the two are distinguishable in the engine's return.
- [ ] Guard every write behind the framework's elevation check, at the call rather than at startup. Done when: an unelevated write is refused by name and nothing is changed.
- [ ] Add engine assertions that run with no window created. Done when: enumeration, every value type, both views, and the denied case all assert headlessly.
- [ ] Commit: `"regstudio: the registry engine"`

**Freeze check:** What this engine writes to the registry is frozen from the moment it ships. A fixture key tree, written and read back, must produce byte-identical values and types across changes. Fixture source: `tests/fixtures/regstudio/`.

**Test checkpoint:** A fixture tree enumerates completely with no handle leak under repeated open. Every value type round-trips byte-identically, quoted per type. The two registry views are distinguishable. A denied key reports denied rather than empty. An unelevated write is refused by name. All assertions run headlessly.

## 3. Browse, Display, and Virtualize

A registry browser that stutters on a large key is a browser people stop trusting, and some real keys hold thousands of values.

**Fidelity:** the tree and value list, against `DESIGN.md` and `docs/captures/house-style/`.
**Job:** a user can navigate to a key and read its values without waiting. Consumer: the rendered tree and list.
**Treatment:** the value list virtualized through the shared control, and the tree populated lazily. Cheaper substitute that fails the checkpoint: loading a key's whole subtree on expand, which hangs on the hives users most want to inspect.
**Chrome:** consume the shared tree and list controls, and the monospace rule from `DESIGN.md` section 4 for paths and values.
**Needs:** Windows host (build/test)

- [ ] Populate the tree lazily, one level at a time. Done when: expanding a key with a large subtree returns immediately, measured and quoted.
- [ ] Render values through the shared virtualized list. Done when: a fixture key with 10,000 values scrolls smoothly and the render cost is quoted.
- [ ] Render machine values in monospace and make them selectable and copyable. Done when: a path and a binary value are each selected and copied, both driven.
- [ ] Show the full key path, and which registry view is being shown. Done when: both render and the view indicator changes when the view changes.
- [ ] Handle a key that disappears while being viewed. Done when: deleting the viewed key externally produces a named message rather than a stale display or a crash.
- [ ] Commit: `"regstudio: lazy tree, virtualized values"`

**Test checkpoint:** Expanding a large subtree returns immediately, timing quoted. A 10,000-value fixture scrolls smoothly with render cost quoted. A path and a binary value are copied, both driven. The view indicator tracks the active view. An externally deleted key produces a named message.

## 4. Editing, With a Reverse

The reason this tool is worth building. Every registry editor can change a value; the one everybody already has cannot put it back. That is the whole differentiator, and it is what makes this a repair-contract tool rather than a viewer.

**Fidelity:** the edit dialogs and the confirmation, reusing the shared dialogs. No new dialog type.
**Job:** a user can change the registry and undo it, including after closing the tool. Consumer: the registry itself, read back by verify, and the restore record on disk.
**Treatment:** prior state captured through the repair contract's restore record before any write, so undo restores what was actually there. Cheaper substitute that fails the checkpoint: an in-memory undo stack, which is gone the moment the tool closes, which is exactly when the user discovers they need it.
**Chrome:** consume the repair contract for the restore record and undo, and the framework's dialogs and logging.
**Needs:** Windows host (build/test)

- [ ] Implement create, rename, modify, and delete for keys and values, each as a repair-contract item. Done when: all four are declared items and none writes outside the contract's loop.
- [ ] Capture prior state before every write, into a restore record. Done when: each of the four operations against the fixture writes a record naming the target and its prior value and type.
- [ ] Verify every write by reading it back. Done when: a write whose effect is deliberately suppressed reports failed rather than succeeded.
- [ ] Implement undo, including after a restart. Done when: an edit, a full application restart, and then an undo returns the fixture to its pre-edit state, compared value by value and type by type.
- [ ] Confirm destructive operations by naming exactly what will be affected: the key path, and the count of values or subkeys. Done when: deleting a key with children names both and declining performs nothing.
- [ ] Refuse by name without the privilege, and log every write and every refusal exactly once. Done when: an unelevated delete is refused naming the key, and a mixed session produces one line per operation.
- [ ] Protect the paths that break a running Windows. Done when: a declared protected-path set requires a second, explicit confirmation naming the risk, and the set is listed here with its reasoning.
- [ ] Commit: `"regstudio: registry editing with a real undo"`

**Freeze check:** What an edit writes does not change once shipped. Evidence is an edit and undo cycle against `tests/fixtures/regstudio/` reproducing the pre-edit state value for value and type for type.

**Test checkpoint:** All four operations are declared contract items and none writes outside the loop, proven by search. Each writes a restore record naming prior value and type. A suppressed write reports failed. An edit, restart, and undo restores the fixture exactly, asserted. Deleting a key with children names path and count; declining does nothing. An unelevated delete is refused by name. A protected path requires a second confirmation.

## 5. Search Across Hives

A registry editor is mostly used by someone who was told a key exists somewhere and cannot find it.

**Fidelity:** the search surface and its results, against `DESIGN.md`.
**Job:** a user who knows part of a name or value can find where it lives. Consumer: the result list, and navigation from it.
**Treatment:** search that runs without freezing the window and can be stopped. Cheaper substitute that fails the checkpoint: a synchronous search across `HKLM`, which appears to hang the application for minutes.
**Chrome:** consume the shared list control and the progress surface.
**Needs:** Windows host (build/test)

- [ ] Search key names, value names, and value data, each independently selectable. Done when: a fixture planted with a distinct string is found by each of the three modes.
- [ ] Run the search off the UI thread, with progress and a working cancel. Done when: a search across a large hive leaves the window responsive and cancel stops it within a stated time.
- [ ] Show results as a list that navigates to the hit. Done when: selecting a result opens the containing key with the hit selected.
- [ ] Report a search that could not read part of the tree. Done when: a denied subtree is reported rather than silently skipped, so the user knows the result set is incomplete.
- [ ] Commit: `"regstudio: search across hives"`

**Test checkpoint:** A planted fixture string is found by name, value-name, and data search, each quoted. A large-hive search leaves the window responsive and cancels within the stated time, both driven. Selecting a result navigates to the hit. A denied subtree is reported rather than skipped.

## 6. Backup, Restore, and `.reg` Exchange

A `.reg` file is the registry's exchange format, and importing one is the most dangerous single action this tool can take, because the file may have come from anywhere.

**Fidelity:** the import and export surfaces, reusing the shared file dialogs and result list.
**Job:** a user can export a subtree, carry it elsewhere, and import it back, knowing what it will do before it does it. Consumer: the `.reg` file, and the registry it is applied to.
**Treatment:** an import previewed as a per-item change set before anything is written, applied through the repair contract so it is undoable. Cheaper substitute that fails the checkpoint: shelling out to `reg.exe import`, which applies an unknown change set with no preview and no undo.
**Chrome:** consume the repair contract, the shared result list, and the framework's file dialogs.
**Needs:** Windows host (build/test)

- [ ] Export a key subtree to a `.reg` file that Windows itself accepts. Done when: an exported fixture subtree is imported by `regedit` on a clean machine and produces identical state.
- [ ] Export atomically and read back before reporting success. Done when: an export to a read-only target reports failure rather than claiming success.
- [ ] Treat an imported `.reg` as untrusted input. Done when: a malformed file, a truncated file, and a file containing a protected path are each refused with a named message, and nothing is written in any of the three cases.
- [ ] Preview an import as a change set before applying. Done when: the preview lists create, modify, and delete per entry, and the counts match what is applied.
- [ ] Apply an import through the repair contract so it is undoable as one run. Done when: importing a fixture and then undoing it returns the registry to its pre-import state exactly.
- [ ] Support the full-hive backup and restore path, or state plainly that it is out of scope and what the user should use instead. Done when: the behavior is one of those two and this section records which.
- [ ] Commit: `"regstudio: reg export, previewed import, and undoable restore"`

**Freeze check:** The format RegStudio exports does not change once shipped, because users keep those files. Evidence is an exported fixture that `regedit` imports to identical state, re-run after any change to the export path.

**Test checkpoint:** An exported subtree is imported by `regedit` on a clean machine to identical state. An export to a read-only target reports failure. Malformed, truncated, and protected-path imports are each refused with nothing written, all three quoted. An import preview's counts match what is applied. Import followed by undo restores the pre-import state exactly.

## Verification

- [ ] `pwsh scripts/check-all.ps1` exits 0 with the regstudio suite reporting
- [ ] No `comctl32` control, private theme call, or private settings path remains
- [ ] Every registry write goes through the repair contract and is undoable after a restart
- [ ] Every freeze check in this file ran and passed
- [ ] RegStudio passes the conformance check and runs standalone in an empty folder
- [ ] Every open item in `samples/RegStudio/TODO.md` is shipped here, routed elsewhere, or marked superseded
- [ ] `python scripts/todo-graph.py validate` clean
