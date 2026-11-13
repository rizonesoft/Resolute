## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T23:52:32Z
- Candidate: 3e31e73f6ffa6b67e33a9430a1cd23a7dc8ee707
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 3e31e73f6ffa6b67e33a9430a1cd23a7dc8ee707
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
- Run: 2026-11-12T23:53:59Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 3e31e73f6ffa6b67e33a9430a1cd23a7dc8ee707
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 97028ffe9df7f530

### adversarial: approve

No actionable findings in the candidate changes. Review was read-only; I did not rerun tests that create files or scheduled tasks.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T23:55:53Z
- Candidate: 6fecddb2e493b473072c30cbe1958282ee101f05
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 3e31e73f6ffa6b67e33a9430a1cd23a7dc8ee707
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 59
- Digest: 63f125e8d91ac99a

Part 1: completeness

Reviewed the candidate diff and matching source files. No files were modified. Runtime results below are the section’s recorded evidence, not tests rerun during this review.

This is repository tooling. Menus, tooltips, focus order, dialogs, theme rendering and application settings are not applicable.

1. **present:** Operator commands and invalid-mode refusal: registration, replacement, run, removal, checks and readback are exposed; ambiguous modes exit 2. Evidence: `tools/elevated-smoke.ps1:1112`.

2. **present:** Consent and account checks: declined elevation, another administrator’s credentials, missing pinned Python and a running task are refused. Evidence: `tools/elevated-smoke.ps1:773`, `:778`, `:785`, `:960`.

3. **present:** Preservation without explicit replacement: an existing registration that fails readiness is refused without replacement. Evidence: `tools/elevated-smoke.ps1:938`.

4. **present:** Registration success uses the shared readiness list on all public registration paths. Evidence: `tools/elevated-smoke.ps1:927`, `:972`; regression assertions at `:621`. Recorded real readback: `todo/07-quality/TODO-01-quality-bar.md:361`.

5. **present:** Pinned drivers, protected execution copies, per-run executable hashes and account-specific manifest permissions. Evidence: `tools/elevated-smoke.ps1:79`, `:136`, `:1012`; consumer regression evidence in `todo/07-quality/TODO-01-quality-bar.md:357`.

6. **present:** Task restoration uses the valid `-Xml` parameter, with a real throwaway-task regression and cleanup. Evidence: `tools/elevated-smoke.ps1:353`, `:641`; the deliberately broken version fails with process exit 1 in `todo/07-quality/TODO-01-quality-bar.md:361`.

7. **present:** Failed runtime moves restore the old runtime; failure to delete the old copy after a successful swap becomes a reported note. Evidence: `tools/elevated-smoke.ps1:362`; regression cases at `:590` and `:635`.

8. **missing-in-scope:** Final readiness failure falls outside the registration rollback transaction. `Invoke-RegisterElevated` swaps the runtime and returns before `Invoke-Register` checks task security and the remaining readiness conditions. A refusal there returns 2 but retains the replacement task, hashes and runtime. This contradicts the promise that failed registration restores the previous setup. Evidence: `tools/elevated-smoke.ps1:870`, `:924`, `:972`. Keep recovery available until final readiness passes, with one regression proving restoration after a final-readiness refusal.

9. **missing-in-scope:** Pinned-hash persistence is not atomic. Registration deletes the previous file before writing the replacement; rollback reconstructs it with another write. An interrupted write or full disk can therefore destroy the durable previous pins, and rollback can fail under the same disk condition. Evidence: `tools/elevated-smoke.ps1:853`, `:886`. Write and verify a sibling candidate before replacement, retaining the previous file until registration commits; prove a failed publication preserves its bytes.

10. **present:** Run bounds, report freshness, suite verdict, scheduler result and environment verdict are checked. Evidence: `tools/elevated-smoke.ps1:110`, `:1030`; report regressions at `:514`. Recorded successful driven run: `todo/07-quality/TODO-01-quality-bar.md:360`.

11. **present:** Timeout cleanup, process readback and task removal have explicit failure outcomes. Evidence: `tools/elevated-smoke.ps1:438`, `:1069`, `:1083`; recorded cleanup with RegStudio running in `todo/07-quality/TODO-01-quality-bar.md:355`.

12. **present:** Self-test failures propagate through the process exit code, including protection against incidental pipeline output. Evidence: `tools/elevated-smoke.ps1:695`, `:1117`; positive and deliberately broken runs in `todo/07-quality/TODO-01-quality-bar.md:361`.

13. **missing-out-of-scope:** Closing or killing the caller can leave the elevated smoke running. Already owned by D07 T01 §10, `todo/07-quality/TODO-01-quality-bar.md:425`.

14. **missing-out-of-scope:** Registration and the task wrapper still produce unwanted console windows. Already owned by D07 T01 §10, `todo/07-quality/TODO-01-quality-bar.md:429`.

15. **missing-out-of-scope:** The integrated live rollback drill remains unperformed. The throwaway-task regression proves task restoration, not restoration of the complete installed registration. Already owned by D07 T01 §10, `todo/07-quality/TODO-01-quality-bar.md:430`.

Part 2: excellence

Counterpart: **none**. AutoIt behavioral parity and the C++ framework’s visual, DPI and accessibility requirements are not applicable to this tooling. The relevant quality shortfalls concern recovery and operator feedback.

1. **in-scope:** Registration can report failure after committing the replacement. Target: every final readiness refusal restores the previous task, pins and runtime, demonstrated by one regression. Evidence: `tools/elevated-smoke.ps1:972`.

2. **in-scope:** Persistent pins can be lost during replacement. Target: a failed write or publication leaves the previous hash file byte-identical and readable. Evidence: `tools/elevated-smoke.ps1:853`.

3. **out-of-scope:** Elevated work survives its initiating session. Target: stop the complete smoke process tree within 30 seconds of caller termination and record the stand-down. Owner: D07 T01 §10.

4. **out-of-scope:** Wrapper consoles interrupt the desktop. Target: zero wrapper or registration console windows, while tested application windows remain visible. Owner: D07 T01 §10.

5. **out-of-scope:** Integrated recovery lacks live proof. Target: quote the injected registration failure, unchanged registration-state readback and subsequent `-Check` readiness from the consented drill. Owner: D07 T01 §10.

Gap list

1. **missing-in-scope / in-scope:** Keep registration rollback available through final readiness validation, `tools/elevated-smoke.ps1:972`.
2. **missing-in-scope / in-scope:** Publish pinned hashes atomically while retaining the previous durable copy, `tools/elevated-smoke.ps1:853`.
3. **missing-out-of-scope / out-of-scope:** End elevated smoke when its caller ends, already filed in D07 T01 §10.
4. **missing-out-of-scope / out-of-scope:** Eliminate wrapper and registration console windows, already filed in D07 T01 §10.
5. **missing-out-of-scope / out-of-scope:** Complete the integrated live rollback drill, already filed in D07 T01 §10.

COMPLETION: gaps

- Implemented: gap 1 (a readiness refusal after the commit kept the replacement) on the repair record `docs/reviews/07-quality/D07-T01-s7-repair4.md`
- Implemented: gap 2 (the pinned hashes were deleted before their replacement was written) on the same repair record
- Filed: D07 T01 §10 (the elevated task outlives a closed caller; already that section's first item)
- Filed: D07 T01 §10 (the wrapper and the registration show a console window; item added 2026-11-13)
- Filed: D07 T01 §10 (the live rollback drill; item "Prove the rollback at this registration")
