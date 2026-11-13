## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T00:03:50Z
- Candidate: 948648b96a13967db30fc632a12966ee62be258d
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 948648b96a13967db30fc632a12966ee62be258d
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
- Run: 2026-11-13T00:06:30Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 948648b96a13967db30fc632a12966ee62be258d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 75ed1a49b75f187a

### adversarial: approve

No actionable findings in the candidate diff. Review was read-only; I did not rerun `-SelfTest`, which creates files and scheduled tasks.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T00:08:47Z
- Candidate: 35e99029c0f2f5f2c222db4b3fb6ff07edb5bf05
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 948648b96a13967db30fc632a12966ee62be258d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 43
- Digest: 5eda283ea62e5b96

The candidate has gaps. AutoIt parity and visual fidelity are not applicable to this repository tooling. I inspected the diff and source without modifying files; runtime results below are the section’s recorded evidence, not fresh executions.

**Part 1: completeness**

1. **present:** Operator commands and invalid-mode refusal. `-Register`, `-Replace`, `-Run`, `-Remove`, `-Check`, `-Readback` and `-SelfTest` are exposed; selecting anything other than one mode exits 2. Evidence: `tools/elevated-smoke.ps1:31`, `:1212`. GUI controls, tooltips, focus order, themes and user settings do not apply.

2. **present:** Consent refusal, insufficient elevation, wrong-account consent, missing Python and running-task refusal. Existing mismatched registrations require explicit replacement. Evidence: `tools/elevated-smoke.ps1:857`, `:862`, `:870`, `:875`, `:1038`, `:1060`.

3. **present:** Persistent registration and subsequent readback. New hashes are staged and read back before switching; readiness checks gate transaction completion and are reused by later `-Check` and `-Run` calls. Evidence: `tools/elevated-smoke.ps1:945`, `:952`, `:959`, `:966`, `:1075`.

4. **present:** Rollback for caught registration failures, including report-write failures. Task restoration, hash/runtime restoration and directory permission restoration are attempted; incomplete rollback is reported. Post-commit backup deletion failure is a note. Evidence: `tools/elevated-smoke.ps1:971`, `:1008`, `:1019`. The documented exclusions for staged copies, descendant ownership and unexpected entries mean this is not literally restoration of every filesystem change.

5. **present:** Routine rollback regression coverage. The sandbox exercises first-registration failure, replacement failures after named steps, readiness refusal and successful replacement. Recorded evidence reports 50 passes and three deliberately broken variants exiting 1. Evidence: `tools/elevated-smoke.ps1:678`, `:691`, `:697`; `todo/07-quality/TODO-01-quality-bar.md:366`.

6. **missing-in-scope, G1:** The explicitly required failing-rename regression was removed. The new cases fail after whole transaction steps; none exercises `Switch-Path` failing between moving the live copy aside and installing its replacement. A filesystem rename refusal is a real condition, not a contrived combination. Evidence: `tools/elevated-smoke.ps1:381`, `:383`, `:385`, `:691`; the still-checked requirement is `todo/07-quality/TODO-01-quality-bar.md:325`.

7. **present:** Bounded run waiting, result validation and task removal with absence readback. Evidence: `tools/elevated-smoke.ps1:1134`, `:1158`, `:1169`, `:1183`. These do not cover abrupt caller termination.

8. **missing-out-of-scope, G2:** The elevated smoke can outlive its caller. Already filed under quality tooling, **D07 T01 §10**, at `todo/07-quality/TODO-01-quality-bar.md:430`.

9. **missing-out-of-scope, G3:** Wrapper and registration console windows still appear. Already filed under **D07 T01 §10**, at `todo/07-quality/TODO-01-quality-bar.md:434`.

10. **missing-out-of-scope, G4:** The real elevated rollback drill remains outstanding. The sandbox deliberately excludes protection changes and highest privilege. Already filed under **D07 T01 §10**, at `todo/07-quality/TODO-01-quality-bar.md:435`.

**Part 2: excellence**

Counterpart: **none**. This is repository tooling, with no AutoIt behavior or product UI to reproduce. No DPI, dark-mode, framework-control or frozen-behavior shortfall applies.

1. **out-of-scope, G5: Recovery after registration process termination or reboot.** Rollback depends on the current process reaching `catch`; prior task XML exists only in memory. Interruption between the renames can leave the live path absent, and the next attempt deletes an existing `.old` before recovering it. Evidence: `tools/elevated-smoke.ps1:379`, `:880`, `:971`. **Target:** before deleting retained state on a subsequent registration, recover or explicitly resolve an interrupted transaction; demonstrate one interrupted-swap recovery. This needs a new quality-tooling section covering durable recovery beyond §7’s exception rollback. It is not filed by this read-only review.

2. **out-of-scope, G2: Caller-lifetime safety.** **Target:** stop the elevated driver and its descendants within 30 seconds of caller termination, with a recorded stand-down verdict. Existing owner: D07 T01 §10.

3. **out-of-scope, G3: Console-window polish.** **Target:** zero wrapper or registration console flashes while retaining the smoke’s intended tool windows. Existing owner: D07 T01 §10.

**Gap list**

1. **missing-in-scope, G1:** Restore one failing-rename regression that proves the previous live copy returns and fails when that restoration is removed.
2. **missing-out-of-scope / out-of-scope, G2:** Couple elevated smoke lifetime to its caller; already filed in D07 T01 §10.
3. **missing-out-of-scope / out-of-scope, G3:** Eliminate wrapper and registration console windows; already filed in D07 T01 §10.
4. **missing-out-of-scope, G4:** Execute the real elevated rollback drill; already filed in D07 T01 §10.
5. **out-of-scope, G5:** Recover interrupted registration state before discarding retained copies; new D07 quality-tooling section needed, not filed during this read-only review.

COMPLETION: gaps

- Implemented: gap 1 (the failing-rename regression was removed with `Switch-Runtime`) on the repair record `docs/reviews/07-quality/D07-T01-s7-repair5.md`
- Filed: D07 T01 §10 (the elevated task outlives a closed caller; already that section's first item)
- Filed: D07 T01 §10 (the wrapper and the registration show a console window; item added 2026-11-13)
- Filed: D07 T01 §10 (the real elevated rollback drill; item "Prove the rollback at this registration")
- Filed: D07 T01 §11 (a registration interrupted between its renames is not recovered by the next one)
