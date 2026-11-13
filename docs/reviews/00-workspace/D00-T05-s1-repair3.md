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

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T03:22:00Z
- Effort: low
- Writer model: claude-opus-5-5
- Policy: ae358ad6f94e86ce0d059d591a3993cb1aba702d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: 28524da6e1766952

### consistency: approve

No findings under the scheduled consistency lens.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T03:24:05Z
- Candidate: d6d40512a594f8c2066f8215f74c6a918a2e0e3e
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: ae358ad6f94e86ce0d059d591a3993cb1aba702d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 29
- Digest: 271047dc6e413f3f

Part 1: completeness

Reviewed the candidate diff, contract, implementation and all four images without modifying files. Driven-run results below are recorded evidence, not runs repeated during this review. GUI controls, keyboard order, persistent settings and registry restore do not apply to this capture driver.

1. **present: build prerequisite.** The clean-checkout bootstrap and launcher build are recorded at `todo/00-workspace/TODO-05-repo-face.md:61`.
2. **present: two views in both themes.** All four committed `2026-11-13-D00-T05-s1-launcher-*.png` files are 1582 × 991 pixels. Visual inspection confirms the named views and themes.
3. **present: provenance and replay.** Sidecars contain host, date, revision, executable hash, DPI, geometry and a quoted command. Command generation is at `scripts/capture-launcher-readme.ps1:184`; the recorded unedited replay and readback are at `todo/00-workspace/TODO-05-repo-face.md:73`.
4. **present: ordinary desktop admission and interruption handling.** Explicit visibility refusal, idle admission, input checks and capture timeout are implemented at `scripts/capture-launcher-readme.ps1:236`, `:408`, `:373` and `:374`. Interruption, query-failure and active-at-start drills are recorded at `todo/00-workspace/TODO-05-repo-face.md:72`.
5. **present: preservation before publication.** Captures use invocation-owned staging; normal capture failures remove that staging rather than previous outputs. Evidence: `scripts/capture-launcher-readme.ps1:322`, `:327`, `:432`, and the preservation drill in the committed repair review.
6. **missing-in-scope: safe publication and truthful failure reporting.** `Publish-Shots` replaces eight files individually at `scripts/capture-launcher-readme.ps1:389`. If an existing sidecar is locked, its PNG can already have been replaced when the next move fails. Earlier pairs can also have changed. Cleanup deletes the remaining staged files, while `:429` incorrectly reports “nothing was published”. There is no publication readback or recovery. This is the driver's new publication layer, separate from the capture helper’s already-filed `D00 T02 §13` issue. Add one refused-publication regression proving existing evidence survives.
7. **missing-in-scope: bounded handling of an unresponsive launcher.** Theme and view commands use synchronous `SendMessageW` at `scripts/capture-launcher-readme.ps1:348` and `:352`. A hung launcher blocks the driver before its capture timeout exists, preventing input checks and cleanup. Require bounded dispatch and one hung-window regression proving nonzero exit and owned-process cleanup.
8. **missing-in-scope: cleanup when the driver itself terminates.** Processes start independently at `scripts/capture-launcher-readme.ps1:332` and `:369`; cleanup depends on reaching `finally` at `:381`. There is no lifetime-bound job object. Terminating the driver can leave its launcher or capture child running. Require process-tree containment and one driver-termination test demonstrating no surviving owned processes, consistent with `docs/testing.md:155`.
9. **present: focused regression coverage for existing rules.** `Invoke-SelfTest` at `scripts/capture-launcher-readme.ps1:198` checks argument quoting, input classification and failed queries. Recorded desktop drills cover ordinary interruption and replay. These do not cover items 6–8.

Part 2: excellence

Counterpart: **none**, as declared. AutoIt behavioral parity is not applicable. This section adds no product UI, so it does not independently owe launcher control accessibility or a new DPI matrix. It falls short on operational safety and recovery:

1. **in-scope: publication can undermine the evidence it publishes.** At `scripts/capture-launcher-readme.ps1:393`, a refused replacement can leave mixed generations and misleading success/failure provenance. **Target:** a refused publication preserves the previous complete set, successful publication reads back matching pairs, and diagnostics accurately identify any incomplete recovery.
2. **in-scope: a hung window defeats responsiveness.** Synchronous commands at `scripts/capture-launcher-readme.ps1:348` and `:352` suspend stand-down handling indefinitely. **Target:** bounded window commands, continued interruption responsiveness, and cleanup within a documented finite deadline.
3. **in-scope: process lifetime is weaker than the repository’s no-orphans rule.** The `finally` cleanup at `scripts/capture-launcher-readme.ps1:381` cannot execute after forced driver termination. **Target:** terminating the driver automatically ends every process it owns without affecting pre-existing applications.

Gap list

1. **missing-in-scope / in-scope:** Make driver publication recoverable and verified; preserve previous evidence on a locked destination and report the actual outcome (`scripts/capture-launcher-readme.ps1:389`).
2. **missing-in-scope / in-scope:** Bound synchronous launcher commands and prove cleanup for an unresponsive window (`scripts/capture-launcher-readme.ps1:348`).
3. **missing-in-scope / in-scope:** Bind owned process trees to the driver’s lifetime and prove cleanup after driver termination (`scripts/capture-launcher-readme.ps1:332`).

COMPLETION: gaps
