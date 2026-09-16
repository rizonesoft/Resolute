# 00 Workspace

> **Phase 0**

Toolchain, gates, build, and the test backbone every later domain leans on. Nothing here ships to a user; everything later depends on it being boring and green.

## TODOs

| TODO | Title | Status |
| ---- | ----- | :----: |
| [TODO-01](./TODO-01-toolchain-and-gates.md) | C++ Toolchain and Gates | draft |
| [TODO-02](./TODO-02-test-backbone.md) | Test Backbone | draft |
| [TODO-03](./TODO-03-codebase-intake.md) | ExoSuite Codebase Intake | draft |
| [TODO-04](./TODO-04-self-correction.md) | Self-Correction and Feedback | draft |

## Completed

| TODO | Title | Completed |
| ---- | ----- | :-------: |

## In scope

- Taking the ExoSuite codebase in with its history, and renaming it to Resolute
- Repository-scoped llvm-mingw toolchain, bootstrapped rather than installed
- CMake structure, dependency policy, and static linking
- Warnings as errors, clang-tidy, and one command that runs every gate
- Catch2 harness, disposable fixtures, house-style captures, and the parity driver
- The checks that keep the plan honest about itself: claims, staleness, a findings ledger, calibration

## Out of scope

- The framework and the repair contract (01, 02)
- The tools themselves (03, 04, 05)
- Release packaging (06), which consumes the build this domain writes
- The quality bar's content (07); this domain builds machinery, not standards

---

Format spec: [../README.md](../README.md) · Root index: [../TODO-00-INDEX.md](../TODO-00-INDEX.md)
