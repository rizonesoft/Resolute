---
name: process-phase
description: Attended runner that takes one phase of todo/implementation-plan.md to 100% -- repair the phase, gap-check it, then ship section after section via process-todo-section plus review-todo-section, parking only when every leftover row is blocked or runnable-elsewhere in this context. Use when the user says process, run, or finish a phase.
---

# Process Phase

One phase, start to 100%, or parked when the rest of it is blocked or runnable-elsewhere here. You do not stop in between.

**Exactly three endings.** Zero open rows and a written closeout. Every leftover row blocked or runnable-elsewhere here, so the phase is **parked** and `process-plan` moves to the next ready phase. Or the operator's own pause. There is no fourth, and a parked phase is neither complete nor a stall.

The whole plan is `process-plan`, not this skill. This skill is one named phase. When the session entered through `process-plan` with no phase argument, return to it after closeout or park so it can start the next ready phase; a session pinned to one phase ends here.

The user is present but is not the engine. Talk to them when something genuinely needs them; never wait on them for anything you can decide, verify, or fix yourself.

**Completion-first never buys completion with a bypass.** `--no-verify`, `--amend`, and force-push are forbidden to this run. If a gate refuses, the run fixes the cause. It does not push, and it does not pause: a red gate is work. A failed push is a red gate, not a skip: diagnose, fix, retry. Never leave an unpushed stack on the theory that CI will catch up later.

**Attended means interruptible, not stoppable.** When the user sends a message mid-run, answer it briefly and continue the loop in the same turn. The one exception outranks everything: **if the user tells you to stop or pause the run, obey immediately**, confirm, and wait. Their instruction beats completion-first, always. Stopping or pausing deletes the run guard first, so no heartbeat resumes against the operator's instruction; resume recreates it before any other step.

## Step 0 -- open the run

Check that no other writer holds the tree (`git status`, and ask about unfamiliar uncommitted work). Then open the run's findings file: `docs/phase-runs/<YYYY-MM-DD>-phase-<N>.md` (create `docs/phase-runs/` if absent). **Every finding this run produces is appended there the moment it is made, not at the end**: the file survives session death where chat scrollback does not, and it is what the user reads during and after the run. Structure:

```markdown
# Phase run: <heading>

## Phase repairs              (Step 1: what was wrong with the plan, what was corrected, where)
## Shipped-row verification   (Step 1b: each [x] row -- stamp ok / checkpoint re-run result / audit outcome)
## Gap audit                  (Step 2: gaps found, where each was filed, rows pulled in; the park record lands here)
## Sections                   (Step 3: one entry per section -- ref, outcome, review verdict, corrections)
## Critical events            (every stop, pause, resume, and session death)
## Lessons                    (what was learned this run, worth keeping)
```

Read the most recent prior file in `docs/phase-runs/` for this phase, if one exists: anything unresolved there is this run's first input.

Run guard: if this session entered through `process-plan`, the plan owns the guard; verify the guard file `build/claude-campaign-guard.json` names this session and the heartbeat job exists (`CronList`), and record the check, but do not create a second. If pinned to this phase standalone, start the guard exactly as the `process-plan` skill specifies (Stop hook, guard file, heartbeat), with this phase's run file.

## Step 1 -- repair the phase before running it

The phase table is a plan, and plans drift. Fix it before building on it. In order:

1. `python scripts/todo-graph.py validate`: fix every FATAL now.
2. `python scripts/todo-graph.py plan --check`: if stale, `plan --sync`.
3. For EVERY open row in the phase: `python scripts/todo-graph.py resolve '<ref>'`. Record the exit code.
   - Exit 4 with unmet deps **outside this phase** is a **leftover, not a stall**. Leave the row here, ship every exit-0 runnable-now row, and park when only leftovers remain. Do not drag a later phase's dependency into this one, and do not loop back hoping the answer changes.
   - A row whose `resolve` verdict is runnable-elsewhere **in this context** is a leftover, not a shippable row, whatever the exit code: it stays visible, never ships here, and parks with the rest when only leftovers remain. Re-run `resolve` rather than trusting a previous verdict.
   - Exit 1/2: the row cites a section that does not exist: repair the reference against the TODO file. A broken ref is repairable work, so it blocks a park.
4. Read each open section's TODO file top to bottom, looking for **phase-level** staleness only (per-section validation happens again inside `process-todo-section`): sections whose work already shipped elsewhere, sections made moot by a decision since, callouts whose blocker no longer exists. Correct with dated `**Corrected YYYY-MM-DD:**` notes.

### Step 1b -- shipped rows are verified, not trusted

`[x]` rows in the phase are claims, and a claim is checked. At run start, re-check shipped rows that an OPEN row in this phase depends on: the dependency spine the new work builds on. For each spine row:

1. Confirm a `Verified:` stamp covers it (`resolve` exits 3 and the stamp names the section).
2. Re-run its `Test checkpoint` command if it names one. A checkpoint that no longer passes means the section regressed after shipping: treat it as this phase's work (diagnose, fix forward, re-review with `review-todo-section` in audit stance).
3. If anything about the implementation looks wrong against today's source, invoke `review-todo-section` in audit stance on that section. It either re-confirms the row or downgrades it to `[ ]`, and a downgraded row rejoins the loop like any other.

## Step 2 -- gap-audit the phase

Read the phase as a user would use it, end to end, and ask what is missing: surfaces with no owner, controls with no section, handoffs between domains nobody specified. File each gap with `add-todo` (with evidence and an owner), pull the resulting rows into the phase table where they belong, and sync the plan. A gap found is a gap filed the same turn: the audit that only lists gaps in chat has not audited.

## Step 3 -- ship the phase, one row at a time

In table order, for each open row: `process-todo-section`, then `review-todo-section`. Record each outcome in the findings file's Sections log. After each stamp, sync the plan. Commit per section; push per the two-push discipline (ship push, then stamp push). After every push, `python scripts/review_prompt.py ci-wait <pushed head> --since <remote head before the push>` reads CI back (a push whose paths miss the workflow's filter reads `not triggered`) and the run file records its line; the next section waits for green (D00 T04 §30), because every later section would otherwise build on it. A red read-back is a failed gate, and the run repairs it rather than waiting on it (D00 T04 §31): `ci-wait` prints the failing job and step and a bounded excerpt of the failed log, the run diagnoses from that evidence, fixes the cause forward in a repair commit (or, when the red is the just-stamped section's own change, reopens that section through audit stance), pushes through this same block, and reads CI back again. Every repair commit has an owner (D00 T04 §33): a red the just-stamped section caused is repaired under that section, reopened; a red caused anywhere else is repaired under a section of its own, the reopened owner of the broken code or a new section filed through `add-todo` with a checkpoint and review, and the repair commit's message names that section, never an unowned commit. A reopened section is repaired, re-reviewed, and re-stamped through this skill before anything continues, and a red on a SHIP push makes the repair commit the new candidate: its checkpoint, independent review, and panel run against the repaired head, never the pre-repair sha, because evidence never transfers across a changed candidate. On green, with any reopened section re-stamped, it continues with the next section in the same turn. The repair is bounded per episode (D00 T04 §33): an episode runs from the first red to the next green, and it gets at most three repair attempts per repair episode across its consecutive reds, so a new red never resets the count; the run file numbers each attempt within the episode (`attempt N of 3`) with its commit and its `ci-wait` line, and a unit patched in three consecutive attempts is rethought rather than patched again. `ci-wait` prints a red's `cause:` line, and the cause decides, not the step's name: a failing repository-controlled step (the workflow file, a pinned action, a setup script, the repository's own commands) is repairable even when it failed during job setup, and a red whose failed-step log cannot be fetched is diagnosed from the full log, or by re-running locally at the pushed commit the step command `ci-wait` prints. The run escalates to the operator only for a cause the tree cannot fix: a runner or platform fault (`cause: platform fault`, such as a lost runner or a GitHub outage), a read-back still unverifiable after `ci-wait`'s one retry (GitHub unreachable, `gh` missing or unauthenticated, runner quota; a run still queued or in progress is waited on to its ceiling first, because a slow run is not an unreachable one), or the repair bound exhausted; the run file records the cause before the report, and the report is the only stop. The report ends the run first (D00 T04 §34): a column-0 `PARKED <UTC> escalation: <cause>` line in the run file, then `python scripts/campaign_guard.py end --session $CLAUDE_CODE_SESSION_ID --reason escalation` and `CronDelete` of the heartbeat it names, so the Stop hook lets the report turn end and no heartbeat resumes against it.

Skip rows whose `resolve` is not exit 0 or whose verdict is runnable-elsewhere here, and re-check them after each stamp: the graph moves as rows flip. When every remaining open row is exit 4 (or otherwise unshippable here), the phase parks: write the park record (each leftover, what blocks it, where the blocker lives), commit the findings file, and if pinned standalone end the guard (`python scripts/campaign_guard.py end --session $CLAUDE_CODE_SESSION_ID --reason park`, then `CronDelete` the job it names) and record its deletion. Then return to `process-plan` (or end, if pinned).

## Step 4 -- closeout

When the table is all `[x]`, close the files before closing the phase: for every TODO file with a row this phase shipped, invoke `process-todo-file`. It runs the file-level Verification block, sweeps loose ends, reconciles deferrals, and sets `status: done` where the whole file is exhausted; a file with rows in later phases gets the sweep and keeps its status. A finding the sweep produces is filed before the closeout, never carried silently.

Then re-run the full suite once, confirm the plan shows the phase complete, write the closeout (what shipped, what was repaired, what was learned, which files closed), commit, delete the guard if pinned standalone (the plan deletes it when chained), and report. A phase is complete when its table says so, its touched files are closed out, and the closeout is written: not before.

## Guardrails

- Do not invent a side loop that ships rows outside `process-todo-section` plus `review-todo-section`.
- Do not tick `implementation-plan.md` by hand. Sync it.
- Do not claim a phase complete while its table has `[ ]` rows.
- Do not call a parked phase complete, and do not call it a stall.
- Do not end the turn on the audit. Ship, park, or close out.
- Do not leave a run guarded after it ends, and do not pause with the guard live: stop deletes first, resume recreates.
