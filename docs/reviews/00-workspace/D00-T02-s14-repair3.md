## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T05:25:03Z
- Candidate: 3488d243edf5c54aea70615a345907018602e066
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 3488d243edf5c54aea70615a345907018602e066
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 3
- Digest: 5363a394b6e0de2b

HIGHEST: none
PLAN: complete
OVERALL: approve

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T07:53:20Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 3488d243edf5c54aea70615a345907018602e066
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 613389440e4d5082

### adversarial: approve

No actionable findings in the candidate diff. Read-only review; self-tests and desktop captures were not rerun because they write files.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T07:56:04Z
- Candidate: 76fe7fb3af1d4ce133b8520e93c2146fba35f97d
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 3488d243edf5c54aea70615a345907018602e066
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 21
- Digest: 69ac8b0a504b2597

Reviewed commit `76fe7fb3` without modifying files. Runtime results are supplied evidence, not fresh runs.

Part 1: completeness

1. **present:** The initial frame read uses the shared inspection and refuses before copying or publishing on failure. Evidence: `scripts/capture-window.ps1:715`.
2. **present:** Refusals include the handle, available title/PID and failed step; readable results yield the frame. Evidence: `scripts/capture-window.ps1:191`; regression assertion at `:512`, with the supplied identity-removal failure.
3. **missing-in-scope:** Disappearance during the first inspection can still be reported as unreadable rather than gone. After the initial `IsWindow` succeeds, a target can close before the compositor or rectangle query. Those failure branches return without checking existence again, leaving `Gone=false`; the final existence check is bypassed. Evidence: `scripts/capture-window.ps1:153`, `:156`, `:157`. The test supplies an already-classified `Gone=true` record (`:502`), so it cannot catch this classification failure. Recheck existence on failed native reads, preserve the failed step and available identity, and cover this path with one regression case.
4. **present:** Hidden targets and invalid dimensions refuse; subsequent checks reject disappearance, movement and covering windows before publication. Evidence: `scripts/capture-window.ps1:200`, `:724`, `:759`, `:768`; existing target-state assertion at `:513`.
5. **present:** Missing target selection refuses, and Repair 3 introduces no new input surface. Evidence: `scripts/capture-window.ps1:597`.
6. **present:** First-read refusal stops the invocation-owned target unless `-KeepOpen` applies and releases the pair lock. Cancellation also releases that lock through `finally`. Evidence: `scripts/capture-window.ps1:688`, `:718`, `:852`; lock-release assertions at `:529` and `:547`.
7. **present:** Refusal precedes output publication. Existing persistence stages and reads back PNG/sidecar bytes, replaces individual files atomically, and supports rollback and interrupted-write recovery, including publication failures from locked files. Evidence: `scripts/capture-window.ps1:303`, `:326`, `:335`, `:346`, `:840`. Pair persistence remains §13’s responsibility.

Part 2: excellence

1. **in-scope:** First-read diagnostics can misclassify a window that closes during inspection, weakening recovery guidance. Target: every failed compositor/frame read checks whether the handle still exists before classifying the refusal, retaining identity and the failed operation. This is the same gap as Part 1 item 3. No additional concrete speed or recovery shortfall is established for Repair 3.

Gap list

1. **missing-in-scope / in-scope:** `scripts/capture-window.ps1:153` and `:156`: classify disappearance on native-read failure at the shared inspection layer and add a regression case that fails without that classification.

COMPLETION: gaps

- Implemented: a window that closes while it is read is gone, not unreadable (the section's Repair 4 item), reviewed on `docs/reviews/00-workspace/D00-T02-s14-repair4.md`.
