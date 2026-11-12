## Plan review: none

- Writer: claude
- Run: 2026-11-12T18:51:06Z
- Candidate: 565bc4ec98ff0850eafceba6d6b77295b8809257
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 565bc4ec98ff0850eafceba6d6b77295b8809257
- Execution: invalid
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Skipped: astra (invalid terminal verdict)
- Lines: 1
- Digest: d0e98b1c73c67d0f

No reviewer returned a plan review. This pass is not an approval.

## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T18:53:29Z
- Candidate: 565bc4ec98ff0850eafceba6d6b77295b8809257
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 565bc4ec98ff0850eafceba6d6b77295b8809257
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 13
- Digest: 07b94fe285282afb

1. **P1** `scripts/lib/run_guard.py:619`: Process containment covers only sessions started through `run-guard.py session`. The supported operator action of typing `process plan` into an existing Claude session activates the guard without establishing that containment. Detached tools and reviewers can therefore outlive its window. Cover this entry path and test closing its window with a descendant running.

2. **P1** `scripts/start-unattended-run.ps1:348`: The job cannot contain `\Resolute\ElevatedSmoke`, which the campaign starts through Task Scheduler (`tools/elevated-smoke.ps1:385`). That process belongs to the scheduler, and killing its caller prevents the caller’s cleanup from running. Add lifetime coupling for the elevated task and its descendants, with proof that closing the campaign window stops them.

3. **P2** `scripts/start-unattended-run.ps1:243`: Containment begins after launcher preparation. The separately started 1Password process is outside the job; closing the window while it waits bypasses both its timeout and cleanup. Establish containment before launching preparation processes and verify shutdown during that wait.

4. **P1** `scripts/tests/test_run_guard.py:438`: The windowless assertion compares the supplied flag with the same helper that supplied it. Replacing `no_window()` with `return 0` still passes on Windows. Assert against `subprocess.CREATE_NO_WINDOW` independently so the required regression test detects loss of window suppression.

5. **P2** `scripts/start-unattended-run.ps1:104`: Shortcut installation succeeds with plain icons when Pillow or SVG rendering support is missing. Thus the required overlays are optional on a fresh installation, with no automated proof of the resulting shortcuts. Provide a dependable overlay asset or rendering path and verify both shortcuts’ targets, runner arguments and badged icons.

HIGHEST: P1
PLAN: gaps
OVERALL: needs-attention

- Settled: outage, the first plan pass above returned no review because the writer sent it the round prompt, which has no `PLAN:` line; the second pass used the plan prompt and returned
- Settled: P1 1, a session that takes the run by the `process plan` prompt is put in a kill-on-close job object of its own (`win_job.end_children_with`, called from `on_prompt` through `Env.contain`), once, and a failure is said in the session; proven on a real process tree by `test_what_a_running_process_starts_afterwards_ends_with_it`, and by `Contained` for when it is and is not applied
- Filed: P1 2, `D07 T01 §10` (item: "Couple the task to its caller in `tools/elevated-smoke.ps1`"): the elevated smoke task's action is consent-pinned, so coupling it to its caller needs the operator to register it again with one UAC prompt and cannot be proven in this session; until then a smoke run in progress when the window closes runs to its own end, at most the caller's 900 second bound
- Not taken: P2 3, the 1Password read is a console process attached to the launcher's own console (`UseShellExecute = false`, no detach, no new console), and Windows ends every process attached to a console when its window is closed; it starts nothing of its own and holds no state to clean up, so there is nothing for a job object to add before the session starts
- Settled: P1 4, the launcher test asserts `subprocess.CREATE_NO_WINDOW` itself, not the helper's return value, so a helper that returned 0 fails it
- Not taken: P2 5, the badge is this machine's own launcher icon, rendered outside the repository, and the runner marks are other companies' trademarks that are not kept in the tree; a missing Pillow is said on screen and the shortcut still works with the plain suite icon, as in the operator's other repositories. Committing rendered icons would put those marks in the repository. Readback on this machine, 2026-11-12: both shortcuts carry `-Runner claude` and `-Runner agy` and point at `resolute-campaign-claude.ico` and `resolute-campaign-carbon.ico` under `%LOCALAPPDATA%\Resolute`, each holding nine sizes from 16 to 256 with its badge

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T18:59:35Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 565bc4ec98ff0850eafceba6d6b77295b8809257
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: f1feb1b330518a46

### adversarial: approve

No substantiated findings. Reviewed the diff and process-lifetime paths; 26 focused tests passed. Window-close behavior was not exercised live.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T19:02:51Z
- Candidate: 8acaf1b941f901a0552d26e05dddd1fc45695d8b
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 565bc4ec98ff0850eafceba6d6b77295b8809257
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 66
- Digest: ad8125ea7f5333d6

The candidate has gaps. Forty selected tests passed, including heartbeat and Stop-hook cases. I made no file changes. Native shortcut launches, window closure and reboot were not exercised.

**Part 1: completeness**

1. **present:** Both named shortcuts and runner commands are implemented, including Carbon’s model and goal. Evidence: `scripts/start-unattended-run.ps1:94`, `:307`. The committed review records shortcut readback, but there is no launcher integration test.

2. **missing-in-scope:** Required icon overlays are optional. Missing rendering dependencies produce successful shortcut installation with plain icons. Evidence: `scripts/start-unattended-run.ps1:102`, `scripts/campaign-icon.py:13`. Provide a dependable badged-icon path and verify both resulting shortcuts.

3. **present:** Automatic restart, resume and watchdog installation commands are removed. Evidence: `scripts/run-guard.py:48`; `test_there_is_no_command_that_resumes_a_run_or_schedules_one`. The host query found no task named `Resolute run watchdog`.

4. **present:** A dead owner is recorded as `ended` when status inspects it, without spawning a replacement. This covers the dead-process state left by closure, crash or reboot. Evidence: `scripts/lib/run_guard.py:315`, `:667`; `test_a_dead_session_is_recorded_as_ended_and_is_not_resumed` and `test_status_records_a_run_whose_session_is_gone_as_ended_and_says_so`.

5. **present:** Live-session heartbeat, Stop-hook continuation, review waiting and usage-limit silence retain their behavior. Evidence: `scripts/lib/run_guard.py:153`, `:224`, `:257`; heartbeat and Stop tests remain unchanged and passed in the selected run. `test_a_live_session_is_never_ended_however_quiet_it_is` covers silence.

6. **present:** Normal runner exit returns through the job wrapper and records the ending without restarting. Evidence: `scripts/lib/run_guard.py:638`, `scripts/start-unattended-run.ps1:348`; `test_a_session_that_ends_takes_everything_it_started_with_it`. Claude’s normal session-exit event is covered separately at `scripts/lib/run_guard.py:307`.

7. **missing-in-scope:** Typing `stop` lacks proof of the promised whole-run shutdown. Claude’s handler only changes guard state; it does not end existing background descendants or clear the runner’s goal. Carbon has no corresponding hook here. Evidence: `scripts/lib/run_guard.py:172`, `scripts/start-unattended-run.ps1:299`, `:329`. The existing stop test checks state only. Prove both actual runners stop work and leave no owned background activity.

8. **missing-in-scope:** `-Stop` can falsely report success when Windows refuses termination. `end_tree()` ignores `taskkill`’s return code, and `end_sessions()` returns the PID as successfully ended without readback. Evidence: `scripts/lib/run_guard.py:335`, `:612`, `scripts/run-guard.py:109`. Add a refusal test and verify termination before reporting success.

9. **present:** Successful containment of an existing Claude session is implemented for a typed `process plan`. Evidence: `scripts/lib/run_guard.py:199`, `scripts/lib/win_job.py:82`; `test_what_a_running_process_starts_afterwards_ends_with_it`.

10. **missing-in-scope:** A refused job object leaves that typed-prompt run active and uncontained. It receives a warning, but status does not expose containment failure and no recovery occurs unless the start prompt is repeated. Evidence: `scripts/lib/run_guard.py:201`, `:655`; `test_a_session_that_could_not_be_tied_is_said_and_tried_again` explicitly accepts this state. The promised cleanup guarantee is absent on this path.

11. **missing-in-scope:** Starting through a prompt after a crash inherits the dead run’s counters instead of establishing a fresh run. Evidence: `scripts/lib/run_guard.py:192`; `test_a_session_can_take_a_run_whose_owner_died_and_keeps_its_counters`. An in-memory reproduction with `idle=4`, `yields=2` and an unchanged tree made the newly started run declare itself stalled on its first Stop event. Record the old ending and reset the new run’s counters.

12. **present:** Competing launcher, live owner and review-in-flight admission refusals exist; another open Claude session requires operator acceptance. Evidence: `scripts/lib/run_guard.py:288`, `scripts/start-unattended-run.ps1:221`; the `Admission` tests passed.

13. **present:** Missing runner CLI produces a named refusal before admission. A job-object refusal in the launcher wrapper starts no runner. Evidence: `scripts/start-unattended-run.ps1:147`, `scripts/run-guard.py:38`, `scripts/lib/run_guard.py:647`. Neither refusal has a dedicated launcher integration test.

14. **missing-out-of-scope:** Elevated smoke can survive campaign-window closure because Task Scheduler owns it outside the job. Evidence: `tools/elevated-smoke.ps1:385`, `:419`. The brief expressly excludes smoke-script changes; this requires the already-filed **D07 T01 §10**, owned by quality tooling. Filing it does not make the whole-run cleanup promise true.

15. **present:** The requested cache-test helper supplies `CREATE_NO_WINDOW` on Windows and zero elsewhere, with an independent assertion against the Windows constant. Evidence: `scripts/tests/test_run_guard.py:48`, `:489`. Capture and smoke scripts are unchanged.

16. **present:** Agent-facing process-plan instructions remove automatic resurrection, and historical phase-run records are unchanged. Evidence: `.claude/skills/process-plan/SKILL.md:24` and its `.agents`/`.codex` counterparts; `AGENTS.md:134`.

17. **missing-in-scope:** Operator documentation overstates cleanup. The unconditional promise at `scripts/start-unattended-run.ps1:329` and `AGENTS.md:162` omits the elevated-task exception, containment refusal and unverified typed-stop behavior. The committed review also calls the orphaned smoke bounded by the caller’s 900-second timeout, although that timeout runs in the caller that has just died (`tools/elevated-smoke.ps1:396`).

**Part 2: excellence**

1. **in-scope:** Shutdown feedback is stronger than its evidence. **Target:** report “ended” only after verified termination; otherwise name the surviving process or refused operation and provide the manual stop route. Evidence: `scripts/lib/run_guard.py:612`, `scripts/run-guard.py:109`.

2. **in-scope:** Shortcut installation can require dependency installation and a second attempt to deliver the requested appearance. **Target:** one successful installation produces both named shortcuts with verified overlays. Evidence: `scripts/start-unattended-run.ps1:104`.

3. **in-scope:** Known admission conflicts are discovered after bootstrap, elevated-task registration prompts and credential lookup. **Target:** identify already-known competing runs or reviews before those steps, retaining the final atomic admission check. Evidence: `scripts/start-unattended-run.ps1:182`, `:205`, `:286`, `:340`.

4. **in-scope:** Tests prove component behavior more strongly than the operator’s actual routes. **Target:** bounded evidence for both runner commands, typed stop, `/exit`, wrapper termination and `-Stop`, plus missing-CLI and job-refusal cases. Current process tests use Python stand-ins (`scripts/tests/test_run_guard.py:355`, `:401`); outside-stop tests mock termination (`:437`).

5. **out-of-scope:** Elevated smoke can continue driving the desktop after the operator closes the campaign. **Target:** the already-filed D07 T01 §10 requires its driver and descendants to stop within 30 seconds of caller death, with task-state and process readback.

**Gap list**

1. **missing-in-scope:** Make required shortcut overlays dependable and verify the installed artifacts.
2. **missing-in-scope:** Prove typed `stop` ends work and owned background activity in both runners.
3. **missing-in-scope:** Detect and report failed `-Stop` termination.
4. **missing-in-scope:** Resolve and expose failed containment for prompt-started runs.
5. **missing-in-scope:** Record dead-run endings and reset counters on a fresh operator start.
6. **missing-out-of-scope:** Couple elevated smoke lifetime to its caller, already filed as D07 T01 §10.
7. **missing-in-scope:** Correct unconditional cleanup promises and the unsupported orphan timeout claim.
8. **in-scope:** Base shutdown success messages on termination readback.
9. **in-scope:** Deliver badged shortcuts in one successful installation.
10. **in-scope:** Surface known admission conflicts before costly preparation.
11. **in-scope:** Add evidence covering actual launcher, stop and refusal routes.
12. **out-of-scope:** Meet D07 T01 §10’s 30-second elevated-smoke shutdown target.

COMPLETION: gaps

## What was done about the completion review

The gap list above, item by item. Fixes are in the commit after the candidate; nothing here is re-reviewed.

- Settled: gap 3 and 8, `-Stop` reports the session ended only once its process is gone (`still_running`), and says `NOT ended` and exits 1 when Windows refused (`test_a_process_that_would_not_end_is_named_and_one_that_went_is_not`)
- Settled: gap 5, a session that takes a run whose owner died starts a new run with none of the old one's counters (`begin`; `test_a_session_that_takes_a_run_whose_owner_died_starts_a_new_run` reproduces the stall on the first turn and fails without the fix)
- Settled: gap 2 in part, a typed `stop` now tells the session to stop working and end its background work, and the launcher's goal counts an operator stop as met, so the goal no longer drives the session on (`test_the_operators_stop_tells_the_session_to_stop_working`). Not proven against the real runners: no test here starts Claude Code or Antigravity, and Antigravity has no hook, so its typed stop rests on the goal text alone. Closing the window is the route that ends every process, and the launcher now says so
- Settled: gap 4 in part, `status` shows `window_bound`, so a prompt-started run whose session could not be put in a job object is visible as such, beside the warning given in the session. It is not retried by itself: the run is held all the same, because the guard fails open
- Settled: gap 7, the launcher's help and its on-screen line, and `AGENTS.md`, state the elevated-smoke exception and no longer promise that every route ends every process. Correction to the `Filed:` line under the plan review: the 900 second bound is the caller's and dies with it, so an elevated smoke run in progress when the window closes runs to its own end; `D07 T01 §10` says so now
- Settled: gap 10, the launcher reads the guard before the toolchain, the elevated task and 1Password, and refuses there for an active run or a review in flight; the admission under the lock still decides
- Filed: gap 6 and 12, `D07 T01 §10` (item: "Couple the task to its caller in `tools/elevated-smoke.ps1`"), as under the plan review
- Not taken: gap 1 and 9, as under the plan review: the badge is rendered per machine because the runner marks are other companies' trademarks and stay out of the tree; without Pillow the shortcut carries the plain suite icon and the launcher says so
- Not taken: gap 11, tests that drive the real `claude` and `agy` programs, a real window close and a reboot would start real sessions on the operator's desktop and account; the process-tree behaviour is proven on real processes with stand-in sessions, and the first real start is the operator's
