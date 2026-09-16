# 01 SDK Core

> **Phase 1**

`SDK/Includes/` is why this suite is a suite. Every shared behavior has one implementation here with a stated contract, and every tool consumes it.

## TODOs

| TODO | Title | Status |
| ---- | ----- | :----: |
| [TODO-01](./TODO-01-shared-include-contracts.md) | Shared Include Contracts | draft |

## Completed

| TODO | Title | Completed |
| ---- | ----- | :-------: |

## In scope

- The include inventory and consumer map
- Settings, logging, localization, update, and elevation contracts
- Declaration hygiene in the shared layer

## Out of scope

- Applying a contract inside a specific tool, which belongs to that tool's domain
- The house-style captures (00), which this domain's surfaces are checked against
- Anything that ships to a user directly; this domain ships to the other domains

---

Format spec: [../README.md](../README.md) · Root index: [../TODO-00-INDEX.md](../TODO-00-INDEX.md)
