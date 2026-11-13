## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T01:14:04Z
- Candidate: 853a8ae659335b5a70242b8de571f9c446211d36
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 853a8ae659335b5a70242b8de571f9c446211d36
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 7
- Digest: 733401becece18ef

1. **P1, plan, line 492:** The proof checks only that `Invoke-Run` refuses an already-held lock. It would pass if `Invoke-Run` acquired and immediately released the lock before readiness, leaving the original race intact. Add one sandbox case that attempts registration from inside an admitted run, before task launch, verifies refusal without changing registration state, and verifies acquisition succeeds after the run exits. Require this case to fail when the run releases its lock early.

2. **P2, plan, lines 484 and 492:** `-Remove` remains outside transaction coordination. At this commit, `Invoke-Remove` unregisters the task without acquiring the registration lock. It can therefore remove the task after registration’s readiness check but before commit, allowing registration to report success with no task present. Include removal in the same lock protocol, with a named busy refusal and one sandbox case proving removal during registration leaves the task untouched.

HIGHEST: P1
PLAN: gaps
OVERALL: needs-attention

- Planned: finding 1 (a refused run does not show the run keeps the lock), a probe from another thread inside the admitted run and after it, failing on a run that releases early, in the section-correction commit that follows this record
- Planned: finding 2 (`-Remove` was outside the lock), removal under the same lock with a named refusal and a case that leaves the task in place, in the same commit

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T01:21:59Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 853a8ae659335b5a70242b8de571f9c446211d36
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: d6d3e3435d7f6d41

### adversarial: approve

No actionable findings in the candidate diff. Review was read-only; I did not rerun `-SelfTest`, which creates files and a scheduled task.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T01:24:14Z
- Candidate: c5bb62106bb31eb76f4984c3a4e775f90d4acd4b
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 853a8ae659335b5a70242b8de571f9c446211d36
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 38
- Digest: bbe72f3068fdc440

The exclusion mechanism is implemented, but the operator feedback has one in-scope gap. Caller-death cleanup remains an existing, separately tracked limitation.

Read-only review of `d2d59ff..c5bb621`. Test results below are commit-recorded evidence, not independently rerun: `-SelfTest` changes temporary files and scheduled tasks.

Part 1: completeness

1. **present:** Registration and recovery share one machine-wide, nonblocking lock. Recovery executes inside the registration transaction. Evidence: [elevated-smoke.ps1:1221](/D:/Resolute/tools/elevated-smoke.ps1:1221), recovery admission at line 1264.

2. **present:** Runs acquire that lock before readiness checks and retain it through execution, report validation and cleanup. Removal acquires it before reading or changing the task. Both release it in `finally`. Evidence: [elevated-smoke.ps1:1534](/D:/Resolute/tools/elevated-smoke.ps1:1534), removal at line 1629.

3. **present:** Busy operations return refusal code 2 without proceeding. An access-denied mutex open also counts as busy; an abandoned mutex can be acquired. Evidence: [elevated-smoke.ps1:1199](/D:/Resolute/tools/elevated-smoke.ps1:1199). Self-tests cover contention, access refusal and abandonment.

4. **present:** Interrupted-registration persistence and restoration exist: the journal is written through a temporary file, read back and renamed; recovery restores previous files and task state, compares readback and only then removes the journal. Locked-file recovery can be retried. Evidence: [elevated-smoke.ps1:430](/D:/Resolute/tools/elevated-smoke.ps1:430), recovery at line 475; held-file test at line 891.

5. **present:** Failure and trust boundaries are represented: untrusted journals are rejected unread; registration checks elevation; transaction failures attempt rollback and report incomplete restoration. Evidence: [elevated-smoke.ps1:501](/D:/Resolute/tools/elevated-smoke.ps1:501), lines 1244 and 1381. These paths cover ordinary permission and filesystem failures without requiring a speculative test matrix.

6. **present:** Recovery’s deliberate restoration limits are documented, including retained directory permissions and ownership. Evidence: [testing.md:85](/D:/Resolute/docs/testing.md:85). The lock introduces no persistent setting or additional system change needing undo.

7. **present:** Regression evidence covers refusal without launch, lock held inside an admitted run and free afterward, and removal refusal without unregistering. Commit `c5bb621` records 73 passing checks and three broken-copy variants exiting 1. Test implementations: [elevated-smoke.ps1:961](/D:/Resolute/tools/elevated-smoke.ps1:961).

8. **missing-in-scope:** Busy feedback incorrectly identifies the competing operation as a registration. A second `-Run` during an ordinary smoke run reports “a registration … is running”; registration likewise reports “another registration” when a run owns the lock. Evidence: [elevated-smoke.ps1:1538](/D:/Resolute/tools/elevated-smoke.ps1:1538) and line 1226. Use truthful operation-neutral wording and update the existing message assertion at line 984.

GUI controls, tooltips, keyboard focus, dialogs, themes and DPI are not applicable to this repository-tooling feature.

Part 2: excellence

Counterpart: **none**. AutoIt behavioral parity and frozen-tool effects are not applicable. `DESIGN.md`’s truthful refusal guidance is relevant; its visual requirements are not.

1. **in-scope:** Misleading contention messages weaken diagnosis. Target: every busy refusal names the attempted action, says another elevated-smoke operation holds the lock, and tells the operator to retry afterward. No holder-identification subsystem is needed. Governing evidence: [DESIGN.md:204](/D:/Resolute/DESIGN.md:204).

2. **out-of-scope:** Closing or killing the calling session can still leave the scheduled smoke running after its mutex disappears. Registration checks running/queued task state, but caller-lifetime cleanup is unfinished. Target: stop the driver and its children within 30 seconds of caller exit. Already owned by **D07 T01 §10**, [quality-bar.md:451](/D:/Resolute/todo/07-quality/TODO-01-quality-bar.md:451); no duplicate section is needed.

Consolidated gaps

1. **missing-in-scope / in-scope:** Correct registration-only busy messages for the now-shared operation lock and update the existing assertion.
2. **out-of-scope:** Complete caller-death cleanup under existing D07 T01 §10, including its 30-second process-tree termination proof.

COMPLETION: gaps

- Implemented: gap 1 (the busy refusals named only a registration) on the repair record `docs/reviews/07-quality/D07-T01-s11-repair2.md`
- Filed: D07 T01 §10 (the task outliving its caller; already that section's first item)
