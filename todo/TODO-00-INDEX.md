# Resolute -- TODO Index

The live execution plan for the C++ rewrite. Format spec: [README.md](./README.md).

## How to use this tree

- **This file** carries domain order and the active TODOs. Keep it at that altitude: no checklists.
- **Each domain's `INDEX.md`** owns its own backlog and is the place to look for scope within a domain.
- Give every topic **one canonical home**. Cross-link with XREFs instead of duplicating scope.
- Numbering is local to a domain (`TODO-01`, `TODO-02`) and never reused.
- When work graduates to documentation, move it to the domain's Completed section rather than leaving a stale checklist here.

## What this plan is

Resolute is being rewritten in C++ from a mature AutoIt3 implementation. The AutoIt suite lives at `resolute_au3/` and is the **executable specification**: a port is finished when it demonstrably does the same thing, proven by the parity driver in `D00 T02 §4`.

The decisions this plan runs on are recorded in [`docs/brainstorm/2026-09-16-completion-brainstorm.md`](../docs/brainstorm/2026-09-16-completion-brainstorm.md). The archived AutoIt plan is at [`resolute_au3/todo/`](../resolute_au3/todo/README.md) and is superseded.

## Domain order

Domains are numbered in **allocation order**. `DNN TNN §N` cross-references encode the domain number, so a remap rewrites every reference in the same commit.

**Execution order lives in the dependency graph**, not in this column. Ask the graph: `python scripts/todo-graph.py query ready`. The **Phase** column below is the coarse sequencing.

| No. | Domain | Phase | Purpose |
| :-: | ------ | :---: | ------- |
| 00 | [Workspace](./00-workspace/INDEX.md) | 0 | Toolchain, gates, build, and the test backbone every later domain leans on. |
| 01 | [Framework](./01-framework/INDEX.md) | 1 | The shared framework every tool consumes. |
| 02 | [Repair Contract](./02-repair-contract/INDEX.md) | 1 | The second shared layer, consumed only by tools that change a user's system. |
| 03 | [Launcher](./03-launcher/INDEX.md) | 2 | The Resolute hub: tool discovery, launch, failure reporting, the suite log viewer, and the Windows system locations imported from WinPower. |
| 04 | [Tool Ports](./04-tools-port/INDEX.md) | 2 | Every existing tool ported to the C++ framework, proven 1:1 against its AutoIt counterpart. |
| 05 | [New Tools](./05-new-tools/INDEX.md) | 3 | Six programs from samples/ become products, and four new utilities join the suite. |
| 06 | [Distro and Release](./06-distro-release/INDEX.md) | 4 | Build, sign, package, and ship. |
| 07 | [Quality](./07-quality/INDEX.md) | 0 | The bar, written before the work rather than after it. |
| 08 | [Documentation and Localization](./08-docs-localization/INDEX.md) | 4 | A complete documentation set per tool, and one shared string pool composed into each tool's pack at build time so a standalone tool still carries everything it needs. |
| 09 | [AutoIt Maintenance](./09-au3-maintenance/INDEX.md) | 0 | Keeping the shipping AutoIt suite alive and buildable for as long as the rewrite takes, without it becoming a second development effort. |

The Phase column is the coarse domain grouping, not an executable schedule. Current dependency-safe sequencing and live counts come only from [`implementation-plan.md`](./implementation-plan.md) plus `python scripts/todo-graph.py query stats`. Do not infer readiness from a domain number or repeat fixed totals here.

## The two shared layers

Everything in this plan is organized around them. A defect is anything that reimplements either privately.

| Layer | Domain | Consumed by |
| ----- | ------ | ----------- |
| Framework | 01 | every tool |
| Repair contract | 02 | the tools that change a user's system |

## Coverage: every tool, and who owns it

Every shipped tool lives at `extensions/<Tool>/` and builds as its own standalone executable.

| Tool | Domain | State |
| ---- | ------ | ----- |
| Resolute (launcher) | 03-launcher | TODO written |
| Ownership | 04-tools-port | TODO written, frozen, vertical slice |
| ComIntRep (Complete Internet Repair) | 04-tools-port | TODO written, frozen |
| PixRepair | 04-tools-port | TODO written, frozen |
| BiosCodes | 04-tools-port | TODO written, frozen |
| MemBoost | 04-tools-port | TODO written |
| Firemin (absorbing Chromin, Edgemin, Watermin) | 04-tools-port | TODO written, consolidation |
| Drive Repair (USBRepair plus DVDRepair) | 04-tools-port | TODO written, frozen, consolidation |
| Complete Windows Repair | 05-new-tools | TODO written, intake |
| QuickErase | 05-new-tools | TODO written, intake |
| WinClean | 05-new-tools | TODO written, intake |
| UUIDGen | 05-new-tools | TODO written, intake pilot |
| Indicators | 05-new-tools | TODO written, intake |
| SaveDesk | 05-new-tools | TODO written, new development |
| Autoruns Manager (startup, services, tasks, context menus) | 05-new-tools | TODO written, new, consolidation |
| Hosts File Editor | 05-new-tools | TODO written, new |
| Restore Point Manager | 05-new-tools | TODO written, new |
| Driver Manager | 05-new-tools | TODO written, new |
| Disk Health | 05-new-tools | TODO written, new |
| Crash Decoder | 05-new-tools | TODO written, new |
| File Unlocker | 05-new-tools | TODO written, new |
| System Report | 05-new-tools | TODO written, new |
| Battery Health | 05-new-tools | TODO written, new |
| Boot Options | 05-new-tools | TODO written, new |
| File Association Repair | 05-new-tools | TODO written, new |
| Policy Inspector | 05-new-tools | TODO written, new |
| Attribute Repair | 05-new-tools | TODO written, new |
| System Change Journal | 05-new-tools | TODO written, new, composed |
| Repair History | 05-new-tools | TODO written, new, composed |
| Sleep and Wake Diagnostics | 05-new-tools | TODO written, new |
| Boot Time Analyzer | 05-new-tools | TODO written, new |
| Why Is This Denied | 05-new-tools | TODO written, new, composed |
| Pending Reboot Inspector | 05-new-tools | TODO written, new |
| Activation Diagnostics | 05-new-tools | TODO written, new |
| Network Share Diagnostics | 05-new-tools | TODO written, new |
| Undelete | 05-new-tools | TODO written, GPL v3 port, frozen |
| Erase Verification | 05-new-tools | TODO written, new, composed |
| Rescue Imaging | 05-new-tools | TODO written, GPL v3 port, frozen |
| RegStudio | 05-new-tools | TODO written, intake, frozen once shipped |
| Console | -- | **dropped**, see `D00 T03 §1`; source preserved in history |
| ReBar | 01-framework | **discontinued** as a tool; it becomes the C++ framework |
| Distro | 09-au3-maintenance | **discontinued** with the AutoIt suite; the C++ build replaces it |
| WinPower | 03-launcher | not taken in; the launcher replaces it |

---

Format spec: [README.md](./README.md) · Plan: [implementation-plan.md](./implementation-plan.md)
