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

- **Stop hook** (`.claude/hooks/campaign-stop.ps1`, wired in `.claude/settings.json`): while the run is open, it blocks this session's end of turn and names the next ready row. It lets the turn end when the guard file is gone, the run file has a `## Closeout run=<run id>` heading or a column-0 `PARKED <UTC> run=<run id>` line, or `query ready` prints `0 runnable now`. It blocks only the session named in the guard file, never subagents or a second session, and it fails open on a bad payload or a thrown error. `python scripts/campaign_guard.py --self-test` drives it against a throwaway workspace inside `scripts/check-all.ps1`. It fails open, but every thrown error is recorded in a file of its own under `build/claude-campaign-hook-errors/`, carrying a unique id and the session, run id, and generation the hook had read when it failed (none when it failed before reading the owner), and the heartbeat reports and acknowledges each by its id (D00 T04 §34, D00 T04 §38).
- **Stall breaker** (inside the hook): after 3 blocks in a row with no change to HEAD, the working-tree diff, the untracked files (content hashed for the first 500, size and write time for the next 5000, the name past that: an edit that keeps a file's size and time past the first 500 is invisible, and so is any edit past 5500), or the run file without its `- bookkeeping:` lines, the hook lets the turn end and counts a trip in `build/claude-campaign-state.json`. Real progress resets the count. A session that cannot move is stuck, and pushing it again only spends money. Bookkeeping is not progress: a heartbeat or retry note is written as a `- bookkeeping: ...` line and leaves the fingerprint unchanged, while any other Critical events line counts (D00 T04 §34, D00 T04 §36). Every block message, and the state file's `coverage`, says how many untracked paths were hashed, counted by size and write time, and counted by name only, so the degraded coverage is visible when it bites (D00 T04 §38). The hook reads and writes its state under the same OS lock as `campaign_guard.py` (D00 T04 §36); the state carries its run's id, and a state carrying another run's id reads as a fresh breaker (D00 T04 §38).
- **Heartbeat** (`CronCreate`): it fires only when this session is idle, and it runs inside this session with full context, so it is a real resume, not a detached reminder. It covers the turns the hook cannot hold: a tripped breaker, an API error, a crash out of the turn.

Every command that changes the guard's files re-checks its caller under the guard lock (D00 T04 §38): `end`, an owner's `reset-state`, and `hook-error --ack` take `--generation`, `--cron-id`, and `--run` (all three required, D00 T04 §40) and refuse when any is no longer the guard's, so a heartbeat made obsolete between its `whoami` and a later step changes nothing; `cancel-confirmed` takes `--session` and `--generation` and refuses a record another session scheduled. `CronList` shows only a prompt's first 80 or so characters, so the canonical prompt opens with its identity, `Claude run-guard heartbeat <generation> <workspace digest>`, 52 characters whatever the path: the digest is twelve hex characters of the sha256 of the canonical workspace path and the run file, so two checkouts sharing a folder name never collide (`python scripts/campaign_guard.py heartbeat-tag --generation <generation> --run-file <run file>` prints it, D00 T04 §40), and every command that reads jobs takes the `CronList` text itself (`--cronlist -`, the printout on stdin) rather than a list of ids somebody vouched for.

Start it in this order:

1. Reconcile first: `CronList`, then `python scripts/campaign_guard.py reconcile --session $CLAUDE_CODE_SESSION_ID --run-file <run file> --cronlist -` with the `CronList` printout on stdin, and do what it prints: `CronDelete` an orphan or stale job, re-point to a live job that carries the guard's generation, append a missing run-file record, report (never cancel) another session's pending job, and start nothing when another session owns the guard. A job counts as this run's only when its prompt names this repository and this run file; any other heartbeat is left alone. A crash between creating a job, acquiring the guard, and recording both is repaired here, before a second one is made (D00 T04 §36, D00 T04 §38).
2. Mint a generation: `python scripts/campaign_guard.py mint-generation`. `CronCreate` with cron `3-59/5 * * * *`, recurring true, and the canonical prompt below with `<N>`, `<workspace digest>` (from `heartbeat-tag`), `<run file>`, and `<generation>` filled in.
3. Acquire the guard: `python scripts/campaign_guard.py acquire --session $CLAUDE_CODE_SESSION_ID --phase <N> --run-file <run file> --cron-id <job id> --generation <generation>` writes `build/claude-campaign-guard.json` (gitignored; `runner`, `workspace`, `phase`, the repo-relative `run_file`, `session_id`, `cron_id`, `generation`, `job_created_at`, and `run_id`, the identity every terminal marker of this run carries, kept across re-points and handovers of the same run). It creates the guard exclusively and refuses one another session holds, so two sessions never share a run; the owning session re-points its own guard with the same command, and taking over another session's live guard needs the operator's `--handover <reason>`, recorded in the guard (D00 T04 §34). Every guard change holds an interprocess lock, so no two changes interleave. A refused `acquire` means another session owns the run: `CronDelete` the job step 2 just created, start nothing, and report the owner.
4. Record the session id, the job id, the generation, and the guard write in the run file's Critical events, quoting the `acquire:` line verbatim: `reconcile` checks that the run file names the guard's job and generation, and `recover` rebuilds a quarantined guard from that line (D00 T04 §40).

What a guard change keeps (D00 T04 §38): a handover, or a re-point that keeps the run file, keeps the run id, so the breaker's blocks and stall trips carry over and a stalled campaign never gets a fresh allowance by changing hands; a new run (a fresh guard, or a re-point to another run file) starts with a clean breaker. Unacknowledged hook errors survive every guard change, each still naming the session and run that raised it. A guard written before run ids gains a run id and a generation at its first locked access, and from then on only markers carrying that id count.

Each guard change publishes its files by atomic replace in a stated order, so a crash at any step leaves a state every reader handles (D00 T04 §38): `acquire` publishes the guard, then resets another run's state (a state left behind reads as a fresh breaker); `end` publishes the pending-cancellation record, then deletes the guard, then the state (a record whose job the live guard still names reads `end incomplete`: re-run `end`, never `CronDelete` a live run's heartbeat; an orphan state is read by no hook and `reset-state --expect-no-guard yes` clears it); a hook error is written to a temporary name and renamed.

Before every `CronDelete`, the runner and the heartbeat alike run `python scripts/campaign_guard.py delete-check --session $CLAUDE_CODE_SESSION_ID --cron-id <job>` and delete only on `DELETE OK` (D00 T04 §40): it refuses only the live guard's current job while this session owns the guard, read under the lock just before the delete, so a re-point between listing and deletion never loses the live heartbeat. Two jobs carrying one generation are resolved by rotating the generation, never by keeping one: a new job from the canonical prompt with a fresh generation, `acquire` re-pointed to it with `--expect-generation` and `--expect-run` (a compare-and-swap: a rotation named for a guard that has since ended, moved, or changed hands refuses, and its new job is deleted), then every old carrier deleted, so a firing of a deleted duplicate already in flight reads `NOT THE CURRENT JOB` and stops. A `CronList` printout that does not read as a listing (anything but job lines or the tool's own `No scheduled jobs.`) answers `UNKNOWN`: `reconcile` names nothing for deletion and `whoami` withholds the job.

A failed write, replace, or delete leaves the same states a crash does (D00 T04 §40): a publish removes its temporary and keeps the old bytes, and a failed delete inside `end` leaves either a live run (re-run `end`) or an orphan state no hook reads. Files are not fsynced: a power loss can lose the last change, which then reads as the earlier consistent state; a recorded default, whose cost of changing is one fsync per publish. A guard file that does not parse is repaired to a bounded end: `python scripts/campaign_guard.py quarantine --session $CLAUDE_CODE_SESSION_ID` moves every unreadable guard, state, or pending record into `build/claude-campaign-quarantine/`, bytes kept, and `python scripts/campaign_guard.py recover --session $CLAUDE_CODE_SESSION_ID --run-file <run file>` rebuilds the guard from the run file's last verbatim `acquire:` line, for its recorded session only, and reads it back.

Every start drains what the last run left (D00 T04 §40): `reconcile` names each pending cancellation (this session's to `CronDelete`, another session's to report) and each hook error the last run did not acknowledge; with no guard yet, an orphan error's line is appended to the run file, origin and all, then acknowledged under the starting session's own identity with `hook-error --session $CLAUDE_CODE_SESSION_ID --startup yes --ack <id>`. The retry trigger is every start and, for this session's own records, every heartbeat firing; a record whose scheduling session is gone is reported at each start until the operator clears it.

At every section boundary (after each stamp), check the heartbeat: `CronList`, then `python scripts/campaign_guard.py health --session $CLAUDE_CODE_SESSION_ID --jobs <live heartbeat job ids>` and `python scripts/campaign_guard.py expiry --session $CLAUDE_CODE_SESSION_ID`. Inside a long section, run the same check at least every 60 minutes of wall time, and always before any recovery wait (a CI read-back past its first ceiling, a reviewer or platform outage awaited), because a heartbeat that died mid-section is exactly the one that must be live when the wait ends (D00 T04 §38). A missing job, or one within 12 hours of its 7-day expiry, is replaced (steps 2 and 3 with a fresh generation) and the repair recorded in the run file (D00 T04 §36).

The run file's end markers are exact and carry the run's id, the guard's `run_id` that `acquire` prints: a closeout is a line `## Closeout run=<run id>` followed by the closeout text, and a park is a column-0 line `PARKED <UTC stamp> run=<run id> <one-line reason>` followed by the park record, wherever in the file it sits. The hook, `end`, and the heartbeat honour only markers carrying this run's id, so a reused run file's old markers never end a new run however the file is edited (D00 T04 §36); a guard written before run ids accepts any marker until its first locked access migrates it (D00 T04 §38).

The heartbeat is session-only: it dies with this session, and a recurring job expires after 7 days, which the section-boundary `expiry` check replaces before it lapses. A run resumed in a new session takes the guard with `acquire --handover <reason>` and a new job and generation; the old session's heartbeat then reads `NOT THE OWNER` from `whoami`, drains the pending cancellations its own scheduler holds, and deletes itself, and the hook never blocks the wrong session. The new session reports, never cancels, a pending job its predecessor scheduled: only the scheduling session can delete it.

Every way a run ends (closeout, park, plan done, operator stop, escalation, a stall the heartbeat stops) deletes all three, always through the locked, identity-checked `end` and never by deleting files directly: `python scripts/campaign_guard.py end --session $CLAUDE_CODE_SESSION_ID --reason <closeout|park|plan-done|operator-stop|escalation> --generation <generation> --cron-id <job id> --run <run id>` checks that path's marker (the `## Closeout` heading, the column-0 `PARKED` line, `0 runnable now`, nothing for a stop, a `PARKED ... escalation:` line), deletes the guard file and the state file, leaves `build/claude-campaign-pending-cancel.json` naming the heartbeat job with its scheduling session and generation, and names it; the runner `CronDelete`s it, confirms it gone with `CronList`, and only then runs `python scripts/campaign_guard.py cancel-confirmed --session $CLAUDE_CODE_SESSION_ID --cron-id <job> --generation <generation>`, so a failed delete stays recoverable (D00 T04 §34, D00 T04 §36, D00 T04 §38).

Escalation ends the run before its report: a report to the operator (an exhausted repair bound, an unverifiable CI, a cause the tree cannot fix) first writes a column-0 `PARKED <UTC> run=<run id> escalation: <cause>` line, then runs `end --reason escalation` with its `--generation`, `--cron-id`, and `--run` and deletes the job, so the Stop hook lets the report turn end and no heartbeat resumes against it. Resume recreates the guard and the job before any other step.

Operator stop: pressing Esc interrupts without the hook firing. A stop or pause said in words deletes the guard file, the state file, and the job, in that order (`end --reason operator-stop`, then `CronDelete`), before confirming. Resume recreates all three before any other step.

A red CI read-back is not a stop either: the run repairs it through the loop the `review-todo-section` push block states (D00 T04 §31), and the hook keeps blocking while it does.

Claude Code is the only runner (`AGENTS.md`, operator decision 2026-09-23). No other harness starts, adopts, or resumes a campaign.

Canonical prompt:

```text
Claude run-guard heartbeat <generation> <workspace digest>: the campaign for Resolute Phase <N>, run file <run file>. This session went idle while a campaign run may still be open. Check, then act, in this turn. S below is $CLAUDE_CODE_SESSION_ID and G is <generation>. One rule governs every fenced command below (`hook-error --ack`, `end`, `cancel-confirmed`): it either succeeds or refuses, and a refusal means the guard moved since step 2 read it, so run nothing else this firing has planned, append the refusal as a `- bookkeeping:` line, and start again at step 2. A CronDelete of this job only ever follows a command that succeeded, and every CronDelete of any job follows `python scripts/campaign_guard.py delete-check --session S --cron-id <job>` printing DELETE OK.

1. Run `python scripts/campaign_guard.py pending-cancel --session S`. For each `pending-cancel: CronDelete <job> generation=<g>` line, CronDelete that job, confirm it gone with CronList, then run `python scripts/campaign_guard.py cancel-confirmed --session S --cron-id <job> --generation <g>`. Append any `report` line to <run file>'s Critical events as a `- bookkeeping: ` line (it repeats on every firing while the other session holds the job, and a repeat is not progress) and change nothing for it. An `end incomplete` line means an end of this run (an operator stop, a park, an escalation) crashed half-way and the run is not to resume: after step 2 prints the job, run `python scripts/campaign_guard.py end --session S --reason <the reason the line names> --generation G --cron-id <job id> --run <run id>` (its marker, if the reason needs one, is already in the run file), then follow step 4's CronDelete and `cancel-confirmed` path and reply RUN FINISHED, or report it to the operator for an escalation or a stall. Never resume under step 6 while such a line prints.
2. Run CronList, then `python scripts/campaign_guard.py whoami --session S --generation G --cronlist -` with the CronList printout on stdin. If it prints NO GUARD, the run is over: run `python scripts/campaign_guard.py reset-state --expect-no-guard yes`, CronDelete this job (the CronList job whose prompt starts "Claude run-guard heartbeat G"), confirm it gone with CronList, and reply RUN FINISHED. If it prints NOT THE OWNER or NOT THE CURRENT JOB, this job is not the run's: CronDelete this job, read and change nothing else, and reply with that line. If it prints MALFORMED GUARD, run step 3 without any --ack, report the malformed guard to the operator (its repair is `quarantine`, then `recover --run-file <run file>`), and stop. Otherwise it prints `OWNER run=<run id> job=<job id>`: keep both. If it prints a DUPLICATE GENERATION line, rotate the generation as that line says (a new job from this prompt with a fresh generation, acquire re-pointed to it, then the old carriers deleted, each after delete-check), and stop this firing: its generation is now obsolete. If it prints NO LIVE CARRIER or UNKNOWN LISTING, or otherwise withholds the job, run no fenced step this firing: append the line to <run file>'s Critical events and resume under step 6, where the section-boundary health check replaces the job.
3. Run `python scripts/campaign_guard.py hook-error --session S`. Each line it prints is one error the Stop hook recorded: append the line to <run file>'s Critical events, then run `python scripts/campaign_guard.py hook-error --session S --generation G --cron-id <job id> --run <run id> --ack <the id inside the line's brackets>`.
4. If <run file> has a line "## Closeout run=<run id>" or a column-0 line starting "PARKED" that carries "run=<run id>", with the run id step 2 printed, run `python scripts/todo-graph.py query ready`. If it prints `0 runnable now`, the plan run is over: run `python scripts/campaign_guard.py end --session S --reason plan-done --generation G --cron-id <job id> --run <run id>`. Only after `end` succeeds for plan-done (a refusal follows the rule above), CronDelete this job, confirm it gone with CronList, then run `python scripts/campaign_guard.py cancel-confirmed --session S --cron-id <job id> --generation G`, and reply RUN FINISHED. Otherwise the phase ended but the plan did not: delete nothing, and resume under step 6, where process-plan re-points the guard to the next phase. A phase closeout alone never ends a plan run.
5. If build/claude-campaign-state.json carries `run_id` equal to the run id step 2 printed and trips of 2 or more: the run stalled twice with no change to the tree. Do not resume. Append a Critical events line to the run file naming what blocks it and run `python scripts/campaign_guard.py end --session S --reason stall --generation G --cron-id <job id> --run <run id>`. Only after `end` succeeds (a refusal follows the rule above: step 2 runs again, and this step then reads the state afresh), CronDelete this job, confirm it gone with CronList, then run `cancel-confirmed` for it as step 4 does, and report the stall to the operator.
6. Otherwise append `- bookkeeping: heartbeat resumed <UTC>` to the run file's Critical events and resume the campaign under process-plan: re-run `python scripts/todo-graph.py query ready`, pick up the open section in the run file exactly where it stopped, and keep shipping: finish the section, stamp it, then the next section, then the next phase. A commit is not a stop, and a red CI is repaired, not waited on. Stop only at closeout, park, or an operator stop.
```

## 2. After a phase closeout or park

`process-phase` ends in exactly one of three ways: the phase table is all `[x]` and closeout is written; every leftover `[ ]` row is blocked or runnable-elsewhere in this context and it parked; or the operator paused it.

A parked phase is **not** complete, and it is **not** a stall. Do not call it either.

```bash
python scripts/todo-graph.py query ready
```

If another phase has a ready row, re-point the guard to the new phase's run file before anything else: `CronCreate` a new job from the canonical prompt with the new phase and run file, re-point the guard to it with `python scripts/campaign_guard.py acquire` (`phase`, `run_file`, `cron_id`, a fresh `generation`, and `session_id` from this shell) (a new run file is a new run: it resets the breaker state under the guard lock), then `delete-check` and `CronDelete` the old job (in that order: the old job stays the guard's until the re-point, and `delete-check` refuses a current job, D00 T04 §40), and record the new ids in the new run file, the `acquire:` line verbatim; then start `process-phase` on it in the same turn. Same session, same rules. If no phase has a ready row, the remaining leftovers are blocked, runnable-elsewhere in this context, or the plan is done: report which. Commit the phase's run file at closeout or park at the latest (earlier ships allowed): reconstructed round figures must resolve to a committed copy, never an untracked path. When the plan is done (no `[ ]` rows anywhere), run the terminal acceptance before deleting the guard: re-execute the `D06 T01 §16` procedure fresh on a clean machine. A failure reopens `D06 T01 §16` through `review-todo-section` in audit stance and the plan is not done; a pass is recorded in the findings file, then the run ends through `python scripts/campaign_guard.py end --session $CLAUDE_CODE_SESSION_ID --reason plan-done --generation <generation> --cron-id <job id> --run <run id>`, which deletes the guard file and the state file under the guard lock, and the heartbeat job it names is `CronDelete`d. The acceptance row proves the suite shippable when it ships; the re-run proves it still is when everything else has landed.

## 3. Deny

- Do not invent a side loop that ships rows outside `process-todo-section` plus `review-todo-section`.
- Do not start a second run, and do not start one while the current run is paused unless the operator said resume.
- Do not tick `implementation-plan.md` by hand.
- Do not claim a phase is complete while its table has `[ ]` rows.
- Do not treat a named phase as the whole plan. Chaining is this skill's job, and only this skill's.
- Do not end the turn on the audit table. Starting is the next action, in the same turn.
- Do not start a run without its guard file and heartbeat job, and do not end, stop, or pause a run without deleting both.
