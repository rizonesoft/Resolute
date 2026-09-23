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

If no phase has a ready row, every remaining `[ ]` row is blocked or runnable-elsewhere in this context. Report them and stop. That is a genuine halt, and it is the only one this skill has.

Ready means runnable-now in the current context: `query ready` splits runnable-now from runnable-elsewhere, and this skill offers only runnable-now rows. Elsewhere rows stay visible in the recorded lines, never offered, never started; re-run the query rather than trusting a previous list.

### Run guard

A run without a guard dies silently when the session stalls, so starting the first phase also starts the run guard, always. List the harness scheduled jobs: if no Run-guard heartbeat for this workspace exists, create one on `*/10 * * * *` (recurring, skips while a run is active) with the canonical prompt below, and record its job id in the run's findings file. If a guard for this workspace already exists, adopt it: record its id and do not create a second. If the harness offers no scheduled jobs, record that the run is unguarded instead of pretending otherwise. The guard skips while a turn holds the token: resurrection of an idle session only, never keepalive of a live one. A fires-during-active guard fired into a live ScratchPad turn on 2026-09-18 and the runtime cancelled the turn plus its background suite run; the same shape here would kill the run it guards.

Canonical prompt (fill `<N>`, `<date>`, `<workspace>`; the run file is `docs/phase-runs/<date>-phase-<N>.md`):

Run-guard heartbeat for the Resolute Phase <N> run (workspace <workspace>). Decide read-only FIRST whether the run is live: it is live if ANY of these hold: (a) any file under src/ shared/ extensions/ tests/ todo/ scripts/ resources/ docs/ modified in the last 25 minutes (find -newermt, excluding Bin/build); (b) any Muse session log under ~/.local/share/muse/sessions appended in the last 25 minutes; (c) any cmake/ninja/ctest/clang process running for this repo. If live: take NO guard action (no audit, no new run, no guard commits) and CONTINUE the run work in progress in this same turn (process-plan: pick up exactly where the session left off; never end the turn on this heartbeat while work remains). Completion condition: the run is done only when todo/implementation-plan.md shows every row [x] (all sections shipped and stamped) or every leftover row is blocked or runnable-elsewhere in this context and the run file records PARKED; until then, each heartbeat keeps processing (audit, then process-phase on the first ready phase). Blocked rows re-evaluate every heartbeat: re-run `query ready` rather than trusting a previous blocked list, since a row whose blockers have all shipped is dependency-ready and ships in table order when runnable here. If NOT live (a/b/c all stale/absent) AND the run file exists with NEITHER a "## Closeout" header NOR a "PARKED" marker AND `python scripts/todo-graph.py query ready` from the workspace root prints at least one runnable-now row: the run stalled with no live writer, so resume it (audit, then process-phase on the first ready phase), single writer, trunk master, never --no-verify, never force-push. This guard is deleted at run closeout; do not extend it. On Windows, prove liveness with PowerShell: `Get-ChildItem -Recurse` LastWriteTime under src/ shared/ extensions/ tests/ todo/ scripts/ resources/ docs/ excluding Bin/build, session logs under %USERPROFILE%\.local\share\muse\sessions, and `Get-Process cmake,ninja,ctest,clang` for this repo.

## 2. After a phase closeout or park

`process-phase` ends in exactly one of three ways: the phase table is all `[x]` and closeout is written; every leftover `[ ]` row is blocked or runnable-elsewhere in this context and it parked; or the operator paused it.

A parked phase is **not** complete, and it is **not** a stall. Do not call it either.

```bash
python scripts/todo-graph.py query ready
```

If another phase has a ready row, re-point the guard to the new phase's run file (delete, recreate, record the new id) and start `process-phase` on it in the same turn. Same session, same rules. If no phase has a ready row, the remaining leftovers are blocked, runnable-elsewhere in this context, or the plan is done: report which. Commit the phase's run file at closeout or park at the latest (earlier ships allowed): reconstructed round figures must resolve to a committed copy, never an untracked path. When the plan is done (no `[ ]` rows anywhere), run the terminal acceptance before deleting the guard: re-execute the `D06 T01 §16` procedure fresh on a clean machine. A failure reopens `D06 T01 §16` through `review-todo-section` in audit stance and the plan is not done; a pass is recorded in the findings file, then the guard is deleted. The acceptance row proves the suite shippable when it ships; the re-run proves it still is when everything else has landed.

## 3. Deny

- Do not invent a side loop that ships rows outside `process-todo-section` plus `review-todo-section`.
- Do not start a second run, and do not start one while the current run is paused unless the operator said resume.
- Do not tick `implementation-plan.md` by hand.
- Do not claim a phase is complete while its table has `[ ]` rows.
- Do not treat a named phase as the whole plan. Chaining is this skill's job, and only this skill's.
- Do not end the turn on the audit table. Starting is the next action, in the same turn.
- Do not start a run without starting its guard, and do not end, stop, or pause a run without deleting it.
