## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T02:35:05Z
- Candidate: ae358ad6f94e86ce0d059d591a3993cb1aba702d
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: ae358ad6f94e86ce0d059d591a3993cb1aba702d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 11
- Digest: 1e7ae26055a38f1f

1. **P1, lines 65, 67-68:** The claimed input coverage starts too late. At the candidate, the driver launches, positions and changes the first window while `InputTickAtStart` is still zero; it waits for idle and establishes the baseline afterward. Require idle admission and a valid baseline before launching any window, then uninterrupted monitoring without rebasing away resumed input. Add an active-at-start refusal check proving no launcher opens.

2. **P1, line 68:** The capture drill does not require interruption while the capture child is actually running, or verification after it exits. Currently, input during the final `WaitForExit(200)` interval is missed when that call returns true. Require a final input check before accepting the shot, and a drill that exercises the child’s capture interval through completion. It must discard the interrupted result and prevent subsequent shots.

3. **P2, lines 67-68:** Input-query failure is missing from the refusal contract. `Test-InputResumed` currently returns false when `GetLastInputInfo` fails, treating unavailable monitoring as permission to continue. Require stand-down when the baseline or subsequent input query cannot be obtained, with one failing-query test proving cleanup and no further capture.

4. **P2, line 68:** Cleanup proves only that the launcher exited. The capture child has an unbounded wait and is outside the `finally` cleanup. Require a bounded capture wait and cleanup of all owned processes on timeout, interruption and exceptions. Extend the drill’s readback to prove no capture process survives or subsequently recreates discarded files.

HIGHEST: P1
PLAN: gaps
OVERALL: needs-attention

- Planned: finding 1 (P1), idle admission and one baseline before any window is launched, never rebased, with an active-at-start refusal that launches nothing, in the section-correction commit that follows this record
- Planned: finding 2 (P1), the capture drill injects input while the capture child runs, and a final check after the child exits decides the shot, in the same commit
- Planned: finding 3 (P2), a failed input query stands the run down, in the self-test and in a driven drill, in the same commit
- Planned: finding 4 (P2), a bounded wait for the capture child and every owned process tree ended on every way out before discarded files are removed, with the drills reading back that no process survives and no file comes back, in the same commit

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T02:55:54Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: ae358ad6f94e86ce0d059d591a3993cb1aba702d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 10
- Digest: 7467caf80eb4d5b0

### adversarial: needs-attention

1. **P1: Resumed input can become the accepted baseline.** `scripts/capture-launcher-readme.ps1:334-335` deliberately waits 100 ms after injecting input, then accepts whichever input tick is newest. Reproduction: after idle admission, the operator makes one mouse movement during that sleep and stops. That movement becomes the baseline, so the driver launches and proceeds through all four shots despite resumed input. The admission check passes activity it must refuse. Distinguish the injected event from operator input instead of accepting an arbitrary later tick.

2. **P1: Cancellation deletes previously successful evidence.** `scripts/capture-launcher-readme.ps1:303` removes the destination PNG and sidecar on every failure, even before the capture child starts. Reproduction: successfully capture into an output directory, then rerun with the same date and directory using `-DrillFailQuery`, or resume input during positioning. The existing details-dark pair is deleted although this invocation never wrote a replacement. Uncommitted captures are lost. This is separate from the already tracked non-atomic pair-writing issue: cleanup deletes files belonging to an earlier run. Capture into invocation-owned temporary paths and preserve existing destinations on failure.

3. **P2: Desktop actions occur after unchecked input intervals.** `scripts/capture-launcher-readme.ps1:203-208` checks input before each sleep but returns without checking afterward. At `:267-275`, input during the last view-change sleep therefore allows `SetForegroundWindow` to steal focus before the next check notices it. Reproduction: click another application during that final 200 ms interval. Similarly, input during successful-shot cleanup permits the next `Take-Shot` to launch another window at `:246` before checking input. Check again after waits and before foreground changes and each launch.

HIGHEST: P1
OVERALL: needs-attention

- Fixed: finding 1 (resumed input could become the baseline). 5eea58f8: the driver watches every mouse and keyboard event through low-level hooks, which see whether Windows injected an event and its sender's mark. Its own move-and-back is marked; every other event, the drill's unmarked touch included, counts as the operator's (`Watch.IsOperator`, three self-test cases). Admission clears the operator count and then reads the idle time, so no event falls between them, and each own event must be seen by the watch, proving the hooks are alive. Driven at 5eea58f8: the capture, theme and failed-query drills stood down, exit 3, folder empty after 5 s, no owned process left.
- Fixed: finding 2 (a stand-down deleted an earlier run's files). 5eea58f8: shots go to a staging folder of the run's own inside -OutDir and are published together, by rename, only when all four succeeded; a stand-down removes only that folder. Driven: a good run into one folder, then a positioning drill and a failed-query drill into the same folder; each `earlier files unchanged (names, hashes, write times; no staging folder left): True`.
- Fixed: finding 3 (unchecked intervals). 5eea58f8: `Wait-Checked` checks before the wait and after each step, and the driver checks before each launch and before the capture child starts; its own marked input precedes the foreground change. The replay into a path with spaces then reproduced all four shots as written, exit 0, every file rewritten, every sidecar at revision 5eea58f8 with the built exe's hash.
