# 02 Repair Contract

> **Phase 1**

The second shared layer, consumed only by tools that change a user's system. Diagnose, report, repair, verify, undo. ComIntRep is the reference implementation it is extracted from.

## TODOs

| TODO | Title | Status |
| ---- | ----- | :----: |
| [TODO-01](./TODO-01-repair-contract.md) | Repair Contract | draft |

## Completed

| TODO | Title | Completed |
| ---- | ----- | :-------: |

## In scope

- The repair item and the shared run loop
- Diagnose before repair, so only applicable repairs are offered
- Per-item results that reconcile, and a transcript a user can carry
- Restore records and a real undo
- One log line per action and per refusal

## Out of scope

- Tools that do not change the system, such as the optimizer and BiosCodes
- The framework layer underneath it (01)
- The individual repair tools that consume it (04, 05)

---

Format spec: [../README.md](../README.md) · Root index: [../TODO-00-INDEX.md](../TODO-00-INDEX.md)
