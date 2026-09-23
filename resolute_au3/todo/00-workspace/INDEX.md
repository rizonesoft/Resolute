# 00 Workspace

> **Phase 0**

Toolchain, gates, build, and the test backbone every later domain leans on. Nothing here ships to a user; everything later depends on it being boring and green.

## TODOs

| TODO | Title | Status |
| ---- | ----- | :----: |
| [TODO-01](./TODO-01-toolchain-and-gates.md) | Toolchain and Gates | draft |
| [TODO-02](./TODO-02-test-backbone.md) | Test Backbone | draft |

## Completed

| TODO | Title | Completed |
| ---- | ----- | :-------: |

## In scope

- AutoIt3 toolchain location and version pin
- Au3Check gate and its warning baseline
- One-command build for any tool, and repository-relative build descriptors
- The AutoIt test harness, fixtures, captures, and the driven-run driver

## Out of scope

- The tools themselves (02, 03, 04, 05)
- The shared includes they consume (01)
- Release packaging and signing (06), which consumes the build this domain writes
- The quality bar's content (07); this domain builds the machinery it runs on

---

Format spec: [../README.md](../README.md) · Root index: [../TODO-00-INDEX.md](../TODO-00-INDEX.md)
