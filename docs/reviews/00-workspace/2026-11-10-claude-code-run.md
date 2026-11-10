## Plan review: none

- Writer: claude
- Run: 2026-11-10T14:42:14Z
- Candidate: 2a7345735f5d66b6f6c22c6b3c3053b456c1b8fe
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 2a7345735f5d66b6f6c22c6b3c3053b456c1b8fe
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
- Run: 2026-11-10T14:45:01Z
- Candidate: 2a7345735f5d66b6f6c22c6b3c3053b456c1b8fe
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 2a7345735f5d66b6f6c22c6b3c3053b456c1b8fe
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 23
- Digest: 80b14cd8d95e4484

1. **P1, plan:** `scripts/start-unattended-run.ps1:256`, `scripts/lib/run_guard.py:268`: `-Stop` during the advertised 30-second restart delay is undone. The next iteration calls `start()`, which clears the halted state and launches another writer. Make automatic restart conditional on the same run still being active, checked under the state lock. Add a stop-during-backoff regression.

2. **P1, plan:** `scripts/lib/run_guard.py:261`, `scripts/start-unattended-run.ps1:228`: launcher admission does not enforce one writer per tree. `start()` checks the recorded owner and watchdog child, but ignores unrelated live sessions, another launcher's reservation, and reviews in flight. Two launchers can both register before either Claude session becomes visible; restarts bypass the initial interactive warning entirely. Use one atomic admission path for launcher and watchdog, with ownership retained across startup and restart. Test concurrent launchers and an unrelated session appearing during backoff.

3. **P1, plan:** `scripts/run-guard.py:38`: the watchdog uses `/IT`, which explicitly requires the user to be logged in. After a reboot with nobody logging in, recovery never runs, regardless of the DPAPI cache. Configure and verify execution without an interactive login, including access to the same account's cache and executable paths. A mocked `task_installed=True` cannot prove this behavior.

4. **P1, plan:** `scripts/review-dispatch.py:501`, `scripts/lib/run_guard.py:593`: a killed dispatcher releases its marker lock without necessarily killing its reviewer or descendants. Cleanup relies on Python's `finally`, which does not execute on forced termination. The guard then treats the review as finished and can resume writing beside the surviving reviewer. Bind the reviewer tree to the dispatcher's lifetime with a Windows job object. Extend the killed-dispatcher test to launch a real child and verify its termination; the current test only kills a sleeping marker holder.

5. **P1, plan:** `scripts/lib/run_guard.py:297`, `scripts/lib/run_guard.py:255`: a live interactive session whose first API call fails before it creates a heartbeat can remain idle indefinitely. `StopFailure` only records the error, the launcher waits for process exit, and the watchdog returns immediately for a live session. Define recovery for a live but non-progressing owned session, including missing or expired heartbeat and authentication failure. Prove it with a driven failure before the first successful turn.

6. **P2, plan:** `scripts/lib/run_guard.py:458`: watchdog recovery drops the launcher's explicit model, question prohibition and goal instructions. A fresh recovery session receives only `process plan` and the permission mode, so it does not preserve the unattended launch contract. Persist and reuse the relevant launch settings for both resume and fresh-session fallback. The current command test explicitly accepts the reduced command.

7. **P2, plan:** `scripts/start-unattended-run.ps1:185`: the launcher does not consume the encrypted token cache when 1Password is unavailable, although the watchdog does. Starting unattended with a locked vault and expired stored login therefore fails despite a usable cached token. Share the credential-selection behavior and test that exact combination without exposing credential values.

8. **P2, plan:** `scripts/review-dispatch.py:69`, `scripts/lib/run_guard.py:574`: marker publication and inspection have unhandled failure paths. The marker becomes visible before its lock is acquired, allowing a probe to contend with dispatcher startup; an unreadable marker raises out of the guard, causing the Stop hook to fail open. Define publication and unreadable-marker behavior explicitly, and test both with separate Windows processes. Normal acquisition and stale-file cleanup do not prove these paths.

9. **P2, plan:** `scripts/dispatch_hook.py:69`: foreground-review detection exempts an entire command when its first word is `git`. A read-only probe confirmed that `git status; python scripts/review-dispatch.py --writer claude --prompt p.md` passes. Conversely, a quoted multiline string containing a review command is refused. Distinguish executable commands from quoted content and apply the background requirement to each invocation. Add both regressions.

10. **P2, plan:** `scripts/build.ps1:192`, `scripts/lsp-launch.py:130`, `scripts/tidy-ratchet.py:539`: the stated tests do not prove several new operational promises. There are no launcher, moved-build cleanup or LSP lifecycle tests, and no explicit serial-versus-parallel ratchet comparison covering out-of-order completion and refusal. Add focused proofs for preserving non-derived files during cleanup, actual LSP startup and parent-death cleanup, and identical ratchet counts, logs and refusal selection. Those behaviors could be broken while the existing cited tests still pass.

HIGHEST: P1
PLAN: gaps
OVERALL: needs-attention

- Settled: P1 1, a restart never revives a stopped run: `start --restart` refuses unless the run is still active, under the state lock (`test_a_stop_given_while_the_launcher_waited_is_not_undone_by_its_restart`)
- Settled: P1 2, `start` is the one admission: it refuses another live launcher, a review in flight, and any other open session unless the operator accepted it at the keyboard, which a restart never carries (`Admission` tests)
- Not taken: P1 3, the watchdog task stays `/IT`. Running it with nobody logged on needs the operator's Windows password stored in the task, and DPAPI under a passwordless S4U logon cannot open the token cache. The limit is stated in AGENTS.md: after a reboot the run resumes once the operator's Windows session exists (signed in or auto-logon; locked is fine)
- Settled: P1 4, the dispatcher joins a kill-on-close job object before it starts a reviewer, so a killed dispatcher takes its reviewer with it (`test_a_killed_dispatcher_takes_its_reviewer_with_it`, with a real child)
- Settled: P1 5, a live session that has written nothing to its transcript for 45 minutes with no review in flight is ended by `run-guard.py replace-stuck`, which the launcher runs every five minutes, and the launcher's restart replaces it (`Stuck` tests)
- Settled: P2 6, the guard keeps what the launcher started the run with (model, tools switched off, goal) and a resumed or fresh session gets the same; a fresh session is started under an id the guard records as the owner
- Settled: P2 7, the launcher falls back to the DPAPI cache when 1Password does not answer (`test_the_launcher_can_read_the_cache_the_guard_wrote`)
- Settled: P2 8, the dispatcher's lock waits instead of failing when the guard is probing, a marker younger than five seconds is taken as running unprobed, and one that cannot be opened is taken as running instead of raising out of the hook
- Settled: P2 9, the hook reads every command on the line whatever the first word is, and takes quoted blocks (here-strings, here-documents) out first (`test_a_review_after_another_command_is_still_a_review`)
- Settled: P2 10, `scripts/tests/test_tooling.py`: the moved-clone cleanup keeps everything that is not a stale build tree or the fetched dependencies, four-at-a-time analysis gives the serial findings, log and refusal with units finishing out of order, and a killed session leaves no launcher or language server
