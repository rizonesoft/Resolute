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
