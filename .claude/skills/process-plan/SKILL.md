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

A run without a guard dies silently when the session stalls, so starting the first phase also starts the run guard, always (D00 T04 §32, ported from ScratchPad). The guard has three parts, and they cover different failures.

- **Stop hook** (`.claude/hooks/campaign-stop.ps1`, wired in `.claude/settings.json`): while the run is open, it blocks this session's end of turn and names the next ready row. It lets the turn end when the guard file is gone, the run file has a `## Closeout` heading or a column-0 `PARKED` line, or `query ready` prints `0 runnable now`. It blocks only the session named in the guard file, never subagents or a second session, and it fails open on a bad payload or a thrown error. `python scripts/campaign_guard.py --self-test` drives it against a throwaway workspace inside `scripts/check-all.ps1`. It fails open, but a thrown error is recorded as `hook_error` in the state file, and the heartbeat reports it (D00 T04 §34).
- **Stall breaker** (inside the hook): after 3 blocks in a row with no change to HEAD, the working-tree diff, the untracked files' contents (hashed, bounded), or the run file outside its `## Critical events` section, the hook lets the turn end and counts a trip in `build/claude-campaign-state.json`. Real progress resets the count. A session that cannot move is stuck, and pushing it again only spends money. Bookkeeping is not progress: a heartbeat or retry line in Critical events leaves the fingerprint unchanged (D00 T04 §34).
- **Heartbeat** (`CronCreate`): it fires only when this session is idle, and it runs inside this session with full context, so it is a real resume, not a detached reminder. It covers the turns the hook cannot hold: a tripped breaker, an API error, a crash out of the turn.

Start it in this order:

1. `CronList`. Adopt an existing job only when its prompt contains `Claude run-guard heartbeat for Resolute`, names this run file, and the guard file exists and names this session (a missing guard means no adoptable run: recreate); any other heartbeat job for Resolute is stale (another phase's run file, or a guard written by another session) and is `CronDelete`d first, because a heartbeat watching the wrong run file sees that run's closeout and deletes itself while this run is open. Otherwise `CronCreate` with cron `3-59/5 * * * *`, recurring true, and the canonical prompt below with `<N>` and `<run file>` filled in.
2. Acquire the guard: `python scripts/campaign_guard.py acquire --session $CLAUDE_CODE_SESSION_ID --phase <N> --run-file <run file> --cron-id <job id>` writes `build/claude-campaign-guard.json` (gitignored; `runner`, `workspace`, `phase`, the repo-relative `run_file`, `session_id`, `cron_id`). It creates the guard exclusively and refuses one another session holds, so two sessions never share a run; the owning session re-points its own guard with the same command, and taking over another session's live guard needs the operator's `--handover <reason>`, recorded in the guard (D00 T04 §34). Every guard change holds an interprocess lock, so no two changes interleave. A refused `acquire` means another session owns the run: `CronDelete` the job step 1 just created, start nothing, and report the owner. Delete any stale `build/claude-campaign-state.json`.
3. Record the session id, the job id, and the guard write in the run file's Critical events.

The run file's end markers are exact: a closeout is a line `## Closeout` followed by the closeout text, and a park is a column-0 line `PARKED <UTC stamp> <one-line reason>` followed by the park record. The hook and the heartbeat read only those two shapes.

The heartbeat is session-only: it dies with this session, and a recurring job expires after 7 days. A run still open on day 7 creates a new job and rewrites `cron_id`. A run resumed in a new session rewrites the guard with the new `session_id` and creates a new job; the old guard's session id no longer matches, so the hook never blocks the wrong session.

Every way a run ends (closeout, park, plan done, operator stop, escalation, a stall the heartbeat stops) deletes all three, always through the locked, session-checked `end` and never by deleting files directly: `python scripts/campaign_guard.py end --session $CLAUDE_CODE_SESSION_ID --reason <closeout|park|plan-done|operator-stop|escalation>` checks that path's marker (the `## Closeout` heading, the column-0 `PARKED` line, `0 runnable now`, nothing for a stop, a `PARKED ... escalation:` line), deletes the guard file and the state file, and names the heartbeat job, which the runner then `CronDelete`s and confirms gone with `CronList` (D00 T04 §34).

Escalation ends the run before its report: a report to the operator (an exhausted repair bound, an unverifiable CI, a cause the tree cannot fix) first writes a column-0 `PARKED <UTC> escalation: <cause>` line, then runs `end --reason escalation` and deletes the job, so the Stop hook lets the report turn end and no heartbeat resumes against it. Resume recreates the guard and the job before any other step.

Operator stop: pressing Esc interrupts without the hook firing. A stop or pause said in words deletes the guard file, the state file, and the job, in that order (`end --reason operator-stop`, then `CronDelete`), before confirming. Resume recreates all three before any other step.

A red CI read-back is not a stop either: the run repairs it through the loop the `review-todo-section` push block states (D00 T04 §31), and the hook keeps blocking while it does.

Claude Code is the only runner (`AGENTS.md`, operator decision 2026-09-23). No other harness starts, adopts, or resumes a campaign.

Canonical prompt:

```text
Claude run-guard heartbeat for Resolute Phase <N> (run file <run file>). This session went idle while a campaign run may still be open. Check, then act, in this turn.

1. If build/claude-campaign-guard.json exists but its `session_id` is not this session's `$CLAUDE_CODE_SESSION_ID`, this job is not the run's: CronDelete this job, read and change nothing else, and reply NOT THE OWNER.
2. Run `python scripts/campaign_guard.py hook-error --session $CLAUDE_CODE_SESSION_ID`. If it prints a line, the Stop hook failed open: append that line to <run file>'s Critical events before anything else.
3. If build/claude-campaign-guard.json is missing, the run is over: CronDelete this job (find it with CronList by this prompt's first sentence), delete build/claude-campaign-state.json if present, and reply RUN FINISHED.
4. If <run file> has a line "## Closeout" or a column-0 line starting "PARKED", run `python scripts/todo-graph.py query ready`. If it prints `0 runnable now`, the plan run is over: run `python scripts/campaign_guard.py end --session $CLAUDE_CODE_SESSION_ID --reason plan-done`, CronDelete this job, and reply RUN FINISHED. Otherwise the phase ended but the plan did not: delete nothing, and resume under step 6, where process-plan re-points the guard to the next phase. A phase closeout alone never ends a plan run.
5. If build/claude-campaign-state.json has trips of 2 or more: the run stalled twice with no change to the tree. Do not resume. Append a Critical events line to the run file naming what blocks it, run `python scripts/campaign_guard.py end --session $CLAUDE_CODE_SESSION_ID --reason stall`, CronDelete this job, and report the stall to the operator.
6. Otherwise resume the campaign under process-plan: re-run `python scripts/todo-graph.py query ready`, pick up the open section in the run file exactly where it stopped, and keep shipping: finish the section, stamp it, then the next section, then the next phase. A commit is not a stop, and a red CI is repaired, not waited on. Stop only at closeout, park, or an operator stop.
```

## 2. After a phase closeout or park

`process-phase` ends in exactly one of three ways: the phase table is all `[x]` and closeout is written; every leftover `[ ]` row is blocked or runnable-elsewhere in this context and it parked; or the operator paused it.

A parked phase is **not** complete, and it is **not** a stall. Do not call it either.

```bash
python scripts/todo-graph.py query ready
```

If another phase has a ready row, re-point the guard to the new phase's run file before anything else: `CronDelete` the old job, `CronCreate` a new one from the canonical prompt with the new phase and run file, re-point the guard with `python scripts/campaign_guard.py acquire` (`phase`, `run_file`, `cron_id`, and `session_id` from this shell), delete `build/claude-campaign-state.json`, and record the new ids in the new run file; then start `process-phase` on it in the same turn. Same session, same rules. If no phase has a ready row, the remaining leftovers are blocked, runnable-elsewhere in this context, or the plan is done: report which. Commit the phase's run file at closeout or park at the latest (earlier ships allowed): reconstructed round figures must resolve to a committed copy, never an untracked path. When the plan is done (no `[ ]` rows anywhere), run the terminal acceptance before deleting the guard: re-execute the `D06 T01 §16` procedure fresh on a clean machine. A failure reopens `D06 T01 §16` through `review-todo-section` in audit stance and the plan is not done; a pass is recorded in the findings file, then the run ends through `python scripts/campaign_guard.py end --session $CLAUDE_CODE_SESSION_ID --reason plan-done`, which deletes the guard file and the state file under the guard lock, and the heartbeat job it names is `CronDelete`d. The acceptance row proves the suite shippable when it ships; the re-run proves it still is when everything else has landed.

## 3. Deny

- Do not invent a side loop that ships rows outside `process-todo-section` plus `review-todo-section`.
- Do not start a second run, and do not start one while the current run is paused unless the operator said resume.
- Do not tick `implementation-plan.md` by hand.
- Do not claim a phase is complete while its table has `[ ]` rows.
- Do not treat a named phase as the whole plan. Chaining is this skill's job, and only this skill's.
- Do not end the turn on the audit table. Starting is the next action, in the same turn.
- Do not start a run without its guard file and heartbeat job, and do not end, stop, or pause a run without deleting both.
