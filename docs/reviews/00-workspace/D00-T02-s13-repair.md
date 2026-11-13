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
