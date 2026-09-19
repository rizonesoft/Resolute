---
schema_version: 1
id: CHANGEME-unique-kebab-id
domain: CHANGEME-NN-domain
status: draft
title: "TODO-NN -- CHANGEME Title"
depends_on: []
track: CHANGEME
---

# TODO-NN -- CHANGEME Title

> **Goal:** CHANGEME: one paragraph. What is true when this file is finished, in plain terms.

> [!IMPORTANT]
> **Current state:** CHANGEME: what exists RIGHT NOW, before this TODO runs. Name real files and real gaps.

## Inputs

- [CHANGEME spec or capture](CHANGEME-path) -- what this TODO consumes from it
- -> XREF: CHANGEME DNN TNN §N -- the related work and what flows each way (reciprocate in the target file)

## Outcome

- CHANGEME: observable end state, not an activity.
- CHANGEME: a second end state.

**Adjacency:** CHANGEME: all=not-applicable (reason) or all nine keys exactly once, separated by semicolons.

**Adjacency rationale:** CHANGEME: the substantive decisions behind the line above, in prose.

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | CHANGEME deliverable | -- |  [ ]   |
|   2   |   §2    | CHANGEME deliverable | §1 |  [ ]   |

---

## 1. CHANGEME Section Title

CHANGEME: one paragraph of context: why this section exists and what it must not break.

- [ ] CHANGEME micro-step in `backtick/path`. Done when: CHANGEME observable end state. Cheaper substitute: CHANGEME the wrong thing.
- [ ] Commit: `"CHANGEME: one-line commit message"`

**Test checkpoint:** CHANGEME: the falsifiable command or drive that proves this section. It must be able to fail.

## 2. CHANGEME Section Title

CHANGEME: one paragraph of context.

(UI sections also carry `**Fidelity:**`, `**Job:**`, `**Treatment:**`, and `**Chrome:**` blocks. Host- or device-bound sections carry a `**Needs:**` line from the closed list in `todo/README.md`, e.g. `**Needs:** Windows host (build/test)`.)

- [ ] CHANGEME micro-step in `backtick/path`. Done when: CHANGEME observable end state.
- [ ] Commit: `"CHANGEME: one-line commit message"`

**Test checkpoint:** CHANGEME: the falsifiable proof.

## Verification

- [ ] `pwsh scripts/check-all.ps1` -- exits 0: both architectures build, clang-tidy clean against the baseline, tests pass
- [ ] `ctest --preset x64-debug` exits 0 with this file's suites reporting
- [ ] CHANGEME: file-level checks this file owes as a whole
- [ ] `python scripts/todo-graph.py validate` clean
