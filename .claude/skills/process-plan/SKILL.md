---
name: process-plan
description: Front door for todo/implementation-plan.md. Audits the plan, then runs process-phase on the first phase with a ready row, then the next ready phase after each closeout or park. Use when the user says process the plan, or asks how to run it. --audit is audit only. A named phase is one phase and does not chain.
---

# Process the Implementation Plan

The only front door for `todo/implementation-plan.md` when the user did not name a single phase. The file is a **derived projection**: processing it is not "pick a row and improvise", and it is not "tick the boxes".

This skill does not ship a section. It does not write a stamp. Writes stay serial, and the run this skill starts is the only writer on the tree.

## 0. Route

```bash
git status -sb
python scripts/todo-graph.py validate
python scripts/todo-graph.py query ready
```

| State | Do this |
| ----- | ------- |
| Another writer holds the tree | Stop and say so. Two writers on one tree is how a call ships without its interface. |
| Argument is `--audit` | Audit below, then stop. Do not start a run. |
| Argument is a phase (`0`, `Phase 0`) | That is `process-phase` for that phase only. It does not chain. |
| Empty argument, "the plan", "process the plan", or this file's path | Audit, then **start `process-phase` on the first phase with a ready row, in this same turn**. After that phase's closeout *or park*, pick the next ready phase. Repeat until no phase has a ready row. |

**An audit-only reply is a process defect.** Ending on the audit table while a ready phase exists is how a plan stalls while everyone agrees it is fine. Starting the phase is the next action, in the same turn.

## 1. Audit the whole plan

```bash
python scripts/todo-graph.py validate
python scripts/todo-graph.py plan --check
python scripts/todo-graph.py query ready
python scripts/todo-graph.py query blocked
```

The audit is these commands and the recorded lines, nothing more: the deep phase repair belongs to `process-phase` step 1. Fix every FATAL before talking about shipping. If `plan --check` is stale, run `plan --sync`, then re-check. **Never tick a box in `implementation-plan.md` by hand**: the boxes are a projection of the Implementation Order tables.

Record these lines **in the run's findings file**, not as the turn's last words:

1. Graph: fatal count.
2. Plan currency: the `--check` result.
3. Ready rows: count and first ref per phase.
4. Blocked rows: count and what blocks them.
5. The phase being started, and why it is first.

If no phase has a ready row, every remaining `[ ]` row is blocked. Report them and stop. That is a genuine halt, and it is the only one this skill has.

## 2. After a phase closeout or park

`process-phase` ends in exactly one of three ways: the phase table is all `[x]` and closeout is written; every leftover `[ ]` row is blocked and it parked; or the operator paused it.

A parked phase is **not** complete, and it is **not** a stall. Do not call it either.

```bash
python scripts/todo-graph.py query ready
```

If another phase has a ready row, start `process-phase` on it in the same turn. Same session, same rules. If no phase has a ready row, the remaining leftovers are blocked or the plan is done: report which.

## 3. Deny

- Do not invent a side loop that ships rows outside `process-todo-section` plus `review-todo-section`.
- Do not start a second run, and do not start one while the current run is paused unless the operator said resume.
- Do not tick `implementation-plan.md` by hand.
- Do not claim a phase is complete while its table has `[ ]` rows.
- Do not treat a named phase as the whole plan. Chaining is this skill's job, and only this skill's.
- Do not end the turn on the audit table. Starting is the next action, in the same turn.
