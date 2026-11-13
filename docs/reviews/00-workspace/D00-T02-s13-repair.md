## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T04:27:58Z
- Candidate: f34a25263b02d35d0e8e619377650cc860a82b4d
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: f34a25263b02d35d0e8e619377650cc860a82b4d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 9
- Digest: 8be7d5a0ebb0d2f1

1. **P1, plan, line 745:** The refusal test exercises “the check,” not the capture entry point. It can pass with the check disconnected or called after `Restore-Pair`, which already touches files at script line 318. Require one invocation with `-Out shot.txt` that proves exit 2, the clash diagnostic, and unchanged existing files and recovery artifacts. It must fail if the entry-point guard is removed or moved after recovery.

2. **P2, plan, line 744:** Verification omits the existing-capture state: sidecars written before this repair contain no image hash. Specify a nonzero refusal naming the missing hash and explaining that the pair cannot be verified. Add one legacy-sidecar case; the proposed matching/mismatching-hash cases do not exercise this real repository state.

3. **P2, plan, line 750:** The Test checkpoint still requires the locked-sidecar refusal to fail when readback is removed. That refusal comes from the file lock and remains effective without readback, as line 735 already acknowledges. Replace this requirement with the staged-corruption case from line 743, and include the two Repair 1 acceptance results in the checkpoint.

HIGHEST: P1
PLAN: gaps
OVERALL: needs-attention

- Planned: finding 1 (P1), a self-test case runs the script itself with `-Out shot.txt` beside a pair and a `shot.png.new` leftover, proving exit 2 and every file unchanged, failing with the guard removed or moved after recovery, in the section-correction commit that follows this record
- Planned: finding 2 (P2), `-Verify` refuses a sidecar without a hash as unverifiable, with a case, in the same commit
- Planned: finding 3 (P2), the Test checkpoint names the staged-corruption case for the readback and adds Repair 1's cases, in the same commit

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T04:31:41Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: f34a25263b02d35d0e8e619377650cc860a82b4d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: bdcc9976869983c5

### adversarial: approve

No actionable findings. Read-only CLI checks covered missing-image refusal, legacy-sidecar refusal, and `.txt` output rejection. The file-writing self-test was inspected but not executed. No files were modified.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T04:33:23Z
- Candidate: 29d8d89a6e5d484ed857580616c535a0848d462d
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: f34a25263b02d35d0e8e619377650cc860a82b4d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 24
- Digest: c019a573578ef698

Part 1: completeness

1. **present:** Image binding is generated from the actual encoded PNG bytes and stored in its sidecar. Evidence: `scripts/capture-window.ps1:529`, `:559`, `:589`.
2. **present:** A reader can verify a saved pair independently, with success or failure exit status. Evidence: `scripts/capture-window.ps1:122`, `:361`; usage documented at `docs/testing.md:65`.
3. **present:** Missing images, missing sidecars, mismatched hashes and legacy sidecars without hashes are refused. Mismatches name both hashes. Evidence: `scripts/capture-window.ps1:127`. The missing-image refusal was also exercised read-only during this review.
4. **present:** Staged files are read back before publication; replacement failures attempt rollback and report failure. Evidence: `scripts/capture-window.ps1:198`, `:218`; locked-sidecar and corrupted-readback cases at `:270`, `:278`.
5. **present:** Interrupted publication and interrupted rollback have persistent recovery markers, consumed on the next capture to that path. Evidence: `scripts/capture-window.ps1:154`, `:175`, `:383`; recovery cases at `:285`, `:297`.
6. **present:** Concurrent writers are serialized, with bounded waiting and abandoned-lock recovery. Evidence: `scripts/capture-window.ps1:140`; tests at `:305`.
7. **present:** An output that would overwrite its own sidecar is refused before locking or recovery. Evidence: `scripts/capture-window.ps1:372`; entry-point regression case with existing files and recovery leftovers at `:339`.
8. **present:** Binding, mixed-pair refusal, legacy refusal and successful replacement have regression cases. Evidence: `scripts/capture-window.ps1:323`, `:349`. Recorded mutation checks and real-capture verification appear in `todo/00-workspace/TODO-02-test-backbone.md:745`.

Controls, focus order, dialogs, settings, elevation and system-change undo do not apply to this section’s repository-tooling surface. File recovery is covered above.

Verification limit: I inspected the candidate and recorded evidence but did not rerun the self-test or captures, because those write files.

Part 2: excellence

Counterpart: **none**, as declared. AutoIt behavioral parity and `DESIGN.md`’s rendered-interface requirements are not applicable.

No concrete shortfalls found within the revised contract. Content binding, rather than simultaneous two-file replacement, is the explicitly recorded design decision.

Gap list: empty.

COMPLETION: complete
