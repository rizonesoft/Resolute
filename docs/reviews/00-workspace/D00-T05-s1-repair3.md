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
