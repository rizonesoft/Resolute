---
name: process-phase
description: Attended runner that takes one phase of todo/implementation-plan.md to 100 percent. Repair the phase, gap-check it, then ship section after section via process-todo-section plus review-todo-section, parking only when every leftover row is blocked here. Use when the user says process, run, or finish a phase.
---

# Process Phase

One phase, start to 100%, or parked when the rest of it cannot run here. You do not stop in between.

Exactly three endings: zero open rows and a written closeout; every leftover row blocked or waiting in this context, so the phase is parked and `process-plan` moves to the next ready phase; or the operator's own pause. A parked phase is neither complete nor a stall.

The whole plan is `process-plan`, not this skill. When the session entered through `process-plan`, return to it after closeout or park; a session pinned to one phase ends here.

Attended means interruptible, not stoppable: answer a mid-run message briefly and continue the loop in the same turn. The one exception outranks everything: if the user tells you to stop or pause, obey immediately, record it in the run file, and wait (the `UserPromptSubmit` hook on `scripts/run-guard.py` clears the active run guard automatically on an operator `stop` / `pause` / `cancel` / `abort` prompt, or run `python scripts/run-guard.py clear --reason operator-stop`).

Completion never buys completion with a bypass: no `--no-verify`, no amend of a candidate under review, no force-push. A red gate is work, not a skip.

## Step 0: open the run

Read `todo/README.md` (the format every TODO edit keeps) before the run's first write, then check that no other writer holds the tree (`git status`; ask about unfamiliar uncommitted work). Writes are serial: this run is the only writer. Open the run file `docs/phase-runs/<YYYY-MM-DD>-phase-<N>.md` (create `docs/phase-runs/` if absent) and append every finding the moment it is made: the file survives session death where chat scrollback does not.

```markdown
# Phase run: <heading>

## Phase repairs              (Step 1: what was wrong with the plan, what was corrected, where)
## Shipped-row verification   (Step 1b: each spine [x] row, stamp and re-run checkpoint result)
## Gap audit                  (Step 2: gaps found, where each was filed; the park record lands here)
## Sections                   (Step 3: one entry per section: ref, outcome, review verdict)
## Critical events            (every stop, pause, resume, session death)
## Lessons                    (what was learned this run, worth keeping)
```

Read the most recent prior run file for this phase, if one exists: anything unresolved there is this run's first input.

## Step 1: repair the phase before running it

1. `python scripts/todo-graph.py validate`: fix every refusal now.
2. `python scripts/todo-graph.py plan --check`: if stale, `plan --sync`.
3. For every open row in the phase: `python scripts/todo-graph.py resolve '<ref>'`. Record the exit code. Exit 4 with unmet dependencies outside this phase, or a waiting Need this session cannot satisfy (`Signing certificate`, `External device`, `Live service`, `Operator decision`, `Upstream release`, or a host that is not reachable), is a leftover, not a stall: leave the row, ship every exit-0 row, and park when only leftovers remain. Exit 1 or 2 means the plan cites a section that does not exist: repair the reference against the TODO files; a broken reference blocks a park.
4. Read each open section's TODO file top to bottom for phase-level staleness only (per-section validation happens again inside `process-todo-section`): work already shipped elsewhere, sections made moot by a later decision, Current state blocks contradicted by the tree. Correct with dated `**Corrected YYYY-MM-DD:**` notes.

### Step 1b: shipped rows are verified, not trusted

`[x]` rows are claims. Re-check the shipped rows an open row in this phase depends on (the spine): `resolve` exits 3, the stamp holds, and the section's Test checkpoint still passes when re-run. A checkpoint that no longer passes means the section regressed: treat it as this phase's work through `review-todo-section` in audit stance before building on it.

## Step 2: gap-audit the phase for 100% completeness

Read the phase as a user would use it, end to end, against its governing documents (`DESIGN.md`, `resolute_au3/`, `AGENTS.md`). Ask what is missing for a 100% complete phase: screens, dialogs, controls, settings consumers, refusal/error paths, undo/restore paths, persistence read-backs, or handoffs between domains nobody specified. Split any coarse umbrella sections into small, single-responsibility sections and expand any summary checkboxes into concrete micro-steps. File each gap with `add-todo` (evidence, owner, dependency) and sync the plan. Never cap planning or silently drop scope. A gap found is a gap filed the same turn.

## Step 3: ship the phase, one row at a time

In the generated plan's table order, for each open row: `process-todo-section`, then `review-todo-section`, whose rounds run to a clean terminal round and whose one-pass completion and excellence review comes last, on pain of the dispatcher refusing the pass. Every gap it files becomes a new section through `add-todo` in this phase or the one that owns it. Record each outcome in the run file, with the completion verdict and any sections filed. Commit the section work, then its stamp commit.

Long jobs never stall the run:

- One heavy job at a time: a build, a review round, and a long test suite never overlap, because other sessions share this machine. Before each, read `(Get-Counter '\Memory\Available MBytes').CounterSamples[0].CookedValue`; under 3000 MB, wait (re-check every minute, up to 30 minutes) instead of starting a job the host may kill.
- A review runs alone: nothing touches a tracked file while a reviewer reads the tree. Launch `scripts/review-dispatch.py` with the shell tool's `run_in_background` option, which `scripts/dispatch_hook.py` enforces (a foreground or detached run is refused, because only that option tells the session when it finishes), then end the turn and wait: while `build/review-in-flight/` names a live dispatcher, the Stop hook in `scripts/run-guard.py` lets the turn end and the review's notification resumes the row. Stage `docs/reviews/` with the next commit, since the dispatcher appends to it.
- After launching a background job, confirm within a few minutes that its process exists and its output file is growing or it has finished. Never wait on a job whose process is gone: a job that ended without its result (killed, no output, no notification) is relaunched once, alone, and the relaunch recorded in the findings file and the run file; a second loss is a Critical event, and the row continues with the next step that does not need that result or parks as a leftover.
- An idle wait longer than 15 minutes with no job alive is a stall: re-check the job, resume the row, and record it.

Skip rows whose `resolve` is not exit 0 here, and rows whose Needs name a host or resource this session cannot reach, and re-check them after each stamp: the graph moves as rows flip. When every remaining open row is a leftover, the phase parks: write a column-0 `PARKED <UTC stamp> <one-line reason>` line in the run file followed by the park record (each leftover, what blocks it, where the blocker lives), commit the run file, and return to `process-plan`.

## Step 4: closeout

When the phase table is all `[x]`: `process-todo-file` on any file the phase exhausted, re-run `pwsh scripts/check-all.ps1`, confirm `query stats` and the regenerated plan show the phase complete, write the closeout under a `## Closeout` heading in the run file (what shipped, what was repaired, what was learned), commit, and report. A phase is complete when its table says so and the closeout is written: not before.

## Guardrails

- Do not invent a side loop that ships rows outside `process-todo-section` plus `review-todo-section`.
- Do not tick `implementation-plan.md` by hand. It is generated; sync it.
- Do not claim a phase complete while its table has `[ ]` rows, and do not call a parked phase complete or a stall.
- Do not end the turn on the audit. Ship, park, or close out.
