# Resolute Power Tools -- TODO Index

The live execution plan for the suite. Format spec: [README.md](./README.md).

## How to use this tree

- **This file** carries domain order and the active TODOs. Keep it at that altitude: no checklists.
- **Each domain's `INDEX.md`** owns its own backlog and is the place to look for scope within a domain.
- Give every topic **one canonical home**. Cross-link with XREFs instead of duplicating scope.
- Numbering is local to a domain (`TODO-01`, `TODO-02`…) and never reused.
- When work graduates to documentation, move it to the domain's Completed section rather than leaving a stale checklist here.

## Domain order

Domains are numbered in **allocation order**. `DNN TNN §N` cross-references encode the domain number, so a remap rewrites every reference in the same commit.

**Execution order lives in the dependency graph**, not in this column. Ask the graph: `python scripts/todo-graph.py query ready`. The **Phase** column below is the coarse sequencing.

| No. | Domain | Phase | Purpose |
| :-: | ------ | :---: | ------- |
| 00 | [Workspace](./00-workspace/INDEX.md) | 0 | AutoIt3 toolchain pin, Au3Check gate, one-command build, test harness, fixtures, captures. |
| 01 | [SDK Core](./01-sdk-core/INDEX.md) | 1 | `SDK/Includes/`: settings, logging, localization, update, elevation. One implementation each. |
| 02 | [Launcher](./02-launcher/INDEX.md) | 1 | `Resolute.exe`: settings, menu localization, tool discovery, launch failure reporting. |
| 03 | [System Tools](./03-system-tools/INDEX.md) | 2 | ReBar, Ownership, ComIntRep, USBRepair, DVDRepair, PixRepair, BiosCodes. Frozen behaviors. |
| 04 | [Browser Tools](./04-browser-tools/INDEX.md) | 2 | Firemin, Chromin, Edgemin, Watermin: one shared optimizer core, four browser profiles. |
| 05 | [MemBoost](./05-memboost/INDEX.md) | 2 | System memory optimizer: frozen trim path, settings with consumers, measured statistics. |
| 06 | [Distro and Release](./06-distro-release/INDEX.md) | 3 | Build descriptors, release set, signing, installer, version rule, release checklist. |
| 07 | [Quality](./07-quality/INDEX.md) | 3 | The done-bar, the warning ratchet, the standing smoke run, house-style conformance. |
| 08 | [Documentation and Localization](./08-docs-localization/INDEX.md) | 4 | Per-tool docs, language coverage, the user guide. |

The Phase column is the coarse domain grouping, not an executable schedule. Current dependency-safe sequencing and live counts come only from [`implementation-plan.md`](./implementation-plan.md) plus `python scripts/todo-graph.py query stats`. Do not infer readiness from a domain number or repeat fixed totals here.

## Coverage: every tool in the suite, and who owns it

| Tool | Domain | State |
| ---- | ------ | ----- |
| Resolute (launcher) | 02-launcher | TODO written |
| ReBar (registry backup and restore) | 03-system-tools | TODO written, frozen |
| Ownership (file ownership and ACLs) | 03-system-tools | TODO written, frozen |
| ComIntRep (COM interface repair) | 03-system-tools | TODO written, frozen |
| USBRepair | 03-system-tools | TODO written, frozen; needs a USB device |
| DVDRepair | 03-system-tools | TODO written, frozen; needs an optical drive |
| PixRepair | 03-system-tools | TODO written, covered by the settings and elevation sections |
| BiosCodes | 03-system-tools | TODO written, gains logging and an export |
| Firemin (Firefox) | 04-browser-tools | TODO written |
| Chromin (Chrome) | 04-browser-tools | TODO written |
| Edgemin (Edge) | 04-browser-tools | TODO written |
| Watermin (Waterfox) | 04-browser-tools | TODO written |
| MemBoost | 05-memboost | TODO written, frozen |
| Distro (the SDK builder) | 06-distro-release | TODO written; it has no build descriptor of its own yet |

A coverage claim rests on the source it was derived from. This table was derived from the directories under `SDK/Concrete/` and the tool list in `Resolute/Docs/Resolute/Readme.txt` on 2026-09-16. That Readme still lists `Rescue`, which commit `e9b6259` removed from this repository; `D08 T01 §1` owns the correction. Any tool added later gets a row and an owner here first.

## The measured starting point

Every number below was measured on 2026-09-16 and is the state the plan starts from. Each is owned by a section, so none of them is merely an observation.

| Measurement | Value | Owned by |
| ----------- | ----- | -------- |
| Au3Check errors across the 14 concrete scripts | 0 | `D00 T01 §2` |
| Unique Au3Check warnings at `-w 1..7` | 847 | `D07 T01 §2` |
| Tools writing settings to `<Tool>.lng` instead of `.ini` | 7 of 14 | `D02 T01 §1`, `D03 T01 §1` |
| Tools that include no logging at all | 5 of 14 | `D01 T01 §4`, `D04 T01 §5` |
| Browser tools that are the same 2,389-line script | 4 | `D04 T01 §1` |
| Launcher menu items hardcoded in English | 41 of 54 | `D02 T01 §2` |
| Build descriptors hardcoding one developer's drive | 13 of 13 | `D00 T01 §4` |
| Tools with no language directory | 3 | `D04 T01 §6` |
| Tools with no documentation directory | 3 | `D08 T01 §1` |
| Automated tests in the repository | 0 | `D00 T02 §1` |

## Active TODOs

- [00 Workspace] [TODO-01 Toolchain and Gates](./00-workspace/TODO-01-toolchain-and-gates.md) -- toolchain pin, Au3Check gate, one-command build, repository-relative descriptors.
- [00 Workspace] [TODO-02 Test Backbone](./00-workspace/TODO-02-test-backbone.md) -- test harness, disposable fixtures, house-style captures, driven-run driver, smoke run.
- [01 SDK Core] [TODO-01 Shared Include Contracts](./01-sdk-core/TODO-01-shared-include-contracts.md) -- settings, logging, localization, update, and elevation contracts.
- [02 Launcher] [TODO-01 Resolute Launcher](./02-launcher/TODO-01-resolute-launcher.md) -- settings repair, menu localization, tool discovery, launch failures.
- [03 System Tools] [TODO-01 System Tool Repairs](./03-system-tools/TODO-01-system-tool-repairs.md) -- settings repair, freeze checks, reverses, elevation refusal.
- [04 Browser Tools] [TODO-01 Browser Tool Consolidation](./04-browser-tools/TODO-01-browser-tool-consolidation.md) -- shared optimizer core, four profiles, logging, language packs.
- [05 MemBoost] [TODO-01 MemBoost Trim and Surface](./05-memboost/TODO-01-memboost-trim-and-surface.md) -- frozen trim path, settings consumers, notifications, measured statistics.
- [06 Distro and Release] [TODO-01 Build and Release](./06-distro-release/TODO-01-build-and-release.md) -- descriptors, release set, signing, installer, version rule, checklist.
- [07 Quality] [TODO-01 Quality Bar](./07-quality/TODO-01-quality-bar.md) -- the bar, the ratchet, the smoke run, house-style conformance.
- [08 Documentation and Localization] [TODO-01 Documentation and Localization](./08-docs-localization/TODO-01-docs-and-localization.md) -- per-tool docs, coverage matrix, user guide.

---

Format spec: [README.md](./README.md) · Execution order: [implementation-plan.md](./implementation-plan.md)
