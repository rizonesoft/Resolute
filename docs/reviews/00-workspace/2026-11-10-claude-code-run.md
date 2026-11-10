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

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-10T14:58:34Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 2a7345735f5d66b6f6c22c6b3c3053b456c1b8fe
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 14
- Digest: 150a38b0f9f34752

## adversarial: needs-attention

1. **P1: Prompt admission bypasses the launcher reservation.** `scripts/lib/run_guard.py:279` protects `start()`, but `on_prompt()` at line 192 still checks only whether the recorded session is alive. Reproduce by submitting `process plan` in another session after launcher admission but before its Claude process registers. The prompt hook replaces the reserved owner, then the launcher starts its already-admitted session: two writers are admitted. A read-only probe also confirmed that this route accepts ownership while `reviewing()` is true. Route prompt admission through the same ownership checks.

2. **P1: Persistent startup failures cause unlimited restarts.** `scripts/start-unattended-run.ps1:306` limits only starts within the preceding hour. With an authentication or API failure that leaves each interactive session idle, `replace-stuck` kills it after 45 minutes and the launcher starts another. This cadence never reaches five starts per hour. The watchdog also returns early while the launcher lives, before enforcing its inactivity limit. Reproduce with an expired credential or sustained API failure before heartbeat creation and leave the shortcut running. The failure loop continues indefinitely. Bound consecutive restarts without progress across these longer intervals.

3. **P2: Credential lookup holds the state lock longer than a stop can wait.** `scripts/lib/run_guard.py:756` holds the lock through `watch()` and `real_spawn()`, including the new 1Password lookup, which permits 60 seconds. Lock acquisition times out after five seconds. Reproduce after reboot with 1Password locked: while the watchdog waits for authorization, run `pwsh scripts/start-unattended-run.ps1 -Stop`. The halt can time out without recording the stop, and the watchdog subsequently launches Claude. Fetch credentials outside the lock, then reacquire it and revalidate admission before spawning.

4. **P2: Shell-wrapped foreground reviews evade detection.** `scripts/dispatch_hook.py:63` recognizes a directly invoked Python interpreter but misses the ordinary Windows invocation `pwsh -NoProfile -Command "python scripts/review-dispatch.py ..."` submitted through Bash without `run_in_background`. A read-only regex probe confirmed that the direct invocation matches and the wrapped invocation does not. Consequently, a long review can run foreground and be terminated by the shell timeout. Inspect supported shell wrappers or enforce this requirement at a boundary that receives the actual dispatcher invocation.

Verification used source inspection and read-only probes. The full test suites were not run because they create files.

HIGHEST: P1
OVERALL: needs-attention

- Settled: round 1 P1 1, the `process plan` prompt goes through the same admission as `start` (`admission_refusal`): it cannot take a run a live launcher reserved, the watchdog resumed, or a review is reading
- Settled: round 1 P1 2, a launcher restart counts with the watchdog's resumes, and three in a row that change nothing end the run as stalled, however far apart they are
- Settled: round 1 P2 3, the sign-in is fetched before the state lock and the decision to spawn is taken again under it, so a stop is never kept waiting behind 1Password
- Settled: round 1 P2 4, an opening quote counts as a command position, so a review wrapped in `pwsh -Command "..."` or `bash -c '...'` needs the background option too

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-10T15:04:59Z
- Effort: low
- Writer model: claude-fable-5-2
- Policy: 2a7345735f5d66b6f6c22c6b3c3053b456c1b8fe
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 10
- Digest: 3cfd78413fd2abe2

## consistency: needs-attention

1. **P2: Launcher cache errors bypass the credential fallback used by the watchdog.** `scripts/start-unattended-run.ps1:218-220` catches only `CryptographicException`. An unreadable cache raises `IOException` or `UnauthorizedAccessException` and terminates the launcher because `$ErrorActionPreference` is `Stop`. The sibling implementation at `scripts/lib/run_guard.py:593-598` handles these failures and continues with stored login.

   Reproduce with 1Password unavailable and `%LOCALAPPDATA%\Resolute\claude-token.dpapi` temporarily held open with exclusive sharing, as can occur during backup or security scanning. Start the Desktop launcher: it exits before session admission despite a usable stored login. Handle cache read failures consistently with the watchdog, without exposing the contents.

Source inspection only; tests were not run because they write files.

HIGHEST: P2
OVERALL: needs-attention

- Settled: round 2 P2 1, the launcher treats any failure to read the token cache as no cache and goes on to the stored login, as the watchdog does; driven with the cache held open exclusively

## Round 3: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-10T15:06:48Z
- Effort: low
- Writer model: claude-fable-5-2
- Policy: 2a7345735f5d66b6f6c22c6b3c3053b456c1b8fe
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: quality
- Lines: 8
- Digest: b0be84d5b1d5c352

## quality: needs-attention

1. **P3: The live-marker tests can pass without testing lock contention.** `scripts/tests/test_run_guard.py:633` checks the marker immediately after creation, so `review_running()` normally returns through its five-second grace period (`scripts/lib/run_guard.py:649`) without probing the lock. The test ages the marker only after killing its holder. The same-process test at line 576 also uses a fresh marker. Reproduction: make the lock probe always report unlocked; these tests can still pass. Age the marker while the separate holder remains alive, assert it still counts as running, then kill the holder and assert removal.

Source inspection only; the suites were not run because they create files.

HIGHEST: P3
OVERALL: needs-attention

- Settled: round 3 P3 1, the killed-dispatcher test ages the marker while its holder is alive and requires it to still count, so the lock probe itself is exercised (a probe changed to always report unlocked now fails it)

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-10T15:10:04Z
- Candidate: c46d87de9e286fc592617560e6b9384edca4d2e0
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 2a7345735f5d66b6f6c22c6b3c3053b456c1b8fe
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 53
- Digest: 53902afba9599171

Not complete for the operator: stopping, recovery after watchdog takeover, and elevated-test readiness still have gaps.

Read-only review of the specified range, which contains 12 commits. No files changed. I ran in-memory probes; I did not run the supplied suites because they create files. The accepted signed-in-session requirement is not reopened.

**Part 1: completeness**

1. **present: Desktop shortcut and launcher.** Installation, clone-relative paths and launch instructions exist at `scripts/start-unattended-run.ps1:63`; operator documentation is at `AGENTS.md:160`.

2. **present: Sign-in and encrypted fallback.** Vault lookup and cache fallback are at `scripts/start-unattended-run.ps1:182` and `:214`; watchdog credential selection and atomic encrypted-cache replacement are at `scripts/lib/run_guard.py:582` and `:601`. Documented at `AGENTS.md:166`.

3. **present: One-writer admission.** Launcher admission runs under the state lock at `scripts/run-guard.py:124`; shared admission checks are at `scripts/lib/run_guard.py:302`. The admission tests cover competing launchers, watchdog ownership, reviews and restart conflicts. Documented at `AGENTS.md:162`.

4. **present: Review waiting and reviewer lifetime.** Locked markers are implemented at `scripts/review-dispatch.py:62`; guard interpretation is at `scripts/lib/run_guard.py:642`. Stop-hook waiting is at `:223`. The killed-dispatcher test covers child termination and aged-marker lock contention. The process-plan skill documents waiting for notification.

5. **present: Launcher restart and idle-session replacement.** The monitoring job invokes `replace-stuck` at `scripts/start-unattended-run.ps1:305`; restart accounting and stopped-run refusal are at `scripts/lib/run_guard.py:267`. Documented at `AGENTS.md:161` and `:165`.

6. **present: Watchdog installation and dead-session resume.** Task installation is at `scripts/run-guard.py:34`; resume/fresh-session command construction is at `scripts/lib/run_guard.py:508`. Its accepted Windows sign-in boundary is documented at `AGENTS.md:163`.

7. **missing-in-scope: Recovery of a hung watchdog-owned session.** `scripts/lib/run_guard.py:339` marks it stalled after three hours and explicitly leaves it running. Unlike launcher-owned sessions, it receives no replacement. An in-memory probe confirmed this terminal state. The test `test_a_hung_resumed_session_is_reported_and_left_alone` codifies the limitation. The earlier fix for launcher-owned hangs does not cover this path.

8. **present: Stop intent prevents subsequent restarts.** `scripts/start-unattended-run.ps1:81` records the external halt; `scripts/lib/run_guard.py:277` refuses automatic restart of an inactive run. Normal exit and typed stop are handled at `:325` and `:179`.

9. **missing-in-scope: External stop reaches the active writer.** `halt()` only changes state at `scripts/lib/run_guard.py:368`. It neither signals the writer nor supplies it a stop instruction. `scripts/run-guard.py:151` promises a resumed session “will stop at the end of its turn”, but the inactive Stop hook merely stops enforcing continuation. A running goal can continue working before that boundary. The operator needs an acknowledged stop, not just disabled recovery.

10. **missing-in-scope: Elevated-test readiness before walking away.** `scripts/start-unattended-run.ps1:148` checks only whether task arguments contain the clone path. A task registered before a driver change passes this check and prints readiness, although `tools/elevated-smoke.ps1:355` subsequently refuses its stale hashes. Check the definition and pinned hashes while the operator can still consent. This concerns changes already present at launch, not the accepted limitation on driver changes during the run.

11. **present: Language servers and setup documentation.** Configuration is in `tools/claude-plugins/resolute-lsp/.lsp.json:1`; startup and lifetime control are at `scripts/lsp-launch.py:37` and `:55`. Prerequisites and diagnostic limitations are documented in `tools/claude-plugins/README.md:17`. Lifecycle tests exist at `scripts/tests/test_tooling.py:182`.

12. **present: Fetching delegate and operating contract.** `.claude/agents/delegate-facts.md:1` defines its model, tools and evidence contract; `docs/replays/2026-11-10-delegate-facts-replay.md:7` records the replay. Routing is documented at `AGENTS.md:152`.

13. **present: Build recovery and parallel analysis.** Moved-tree cleanup is implemented at `scripts/build.ps1:171`, with preservation tests at `scripts/tests/test_tooling.py:61`. Serial/parallel findings, logs and refusal ordering are compared by tests at `:141` and `:151`.

**Part 2: excellence**

1. **in-scope: Recovery becomes slower and less capable after watchdog takeover.** The operator goes from 45-minute idle replacement to a three-hour wait followed by abandonment of a live child. **Target:** apply equivalent idle detection and bounded replacement after takeover, within 55 minutes, while preserving review waiting and one-writer ownership.

2. **in-scope: External stopping gives an unsupported assurance.** The command can report halted while the writer remains active. **Target:** one stop command delivers cancellation, reports acknowledgement or explicitly reports pending stop, and prevents further work after the next safe boundary.

3. **in-scope: Elevated-test startup output overstates readiness.** A matching path is presented as sufficient preparation. **Target:** detect stale hashes or mismatched task definition before printing readiness, with renewal offered during that same attended launch.

4. **in-scope: Harmless quoted commands are mistaken for foreground reviews.** An in-memory probe showed `echo "python scripts/review-dispatch.py --writer claude --prompt p.md"` matches `RUNS_A_REVIEW` at `scripts/dispatch_hook.py:64`. The shell-wrapper fix treats every opening quote as executable context. **Target:** allow ordinary quoted output while continuing to reject actual foreground dispatcher invocations, including supported shell wrappers.

**Gap list**

1. **missing-in-scope:** Replace hung watchdog-owned sessions instead of marking them stalled and leaving them running.
2. **missing-in-scope:** Deliver and acknowledge external stop to the active writer.
3. **missing-in-scope:** Verify elevated-task definition and pinned hashes before declaring launch readiness.
4. **in-scope:** Match launcher recovery timing and bounded replacement after watchdog takeover.
5. **in-scope:** Make stop output accurately distinguish requested, pending and acknowledged cessation.
6. **in-scope:** Surface elevated-test repair while the operator is still present.
7. **in-scope:** Distinguish quoted command text from executable review commands.

COMPLETION: gaps

- Settled: completion gaps 1 and 4, a session the watchdog resumed is held to the launcher's rule: silent for 45 minutes with no review in flight it is ended and the next tick starts another, on the same bounded count; one that works for three hours and changes nothing is ended with its run instead of left running
- Settled: completion gaps 2 and 5, `-Stop` (`halt --end-session`) ends the session's process as well as halting the guard and says which; a plain `halt` says when the session is still running; driven against a real working session
- Settled: completion gaps 3 and 6, `tools/elevated-smoke.ps1 -Check` answers whether `-Run` would be refused (task definition and pinned hashes), and the launcher asks it at start and offers the registration then
- Settled: completion gap 7, a quoted string counts as commands only after a shell's command flag (`-Command`, `-c`, `/c`); `echo "..."` and a commit message are text
