## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T01:50:02Z
- Candidate: 3984c0ebaecd02b02374bb8c84e93ea8744d38c3
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 3984c0ebaecd02b02374bb8c84e93ea8744d38c3
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
- Run: 2026-11-13T01:53:08Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 3984c0ebaecd02b02374bb8c84e93ea8744d38c3
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 8
- Digest: e66e1dca2c444c4a

### adversarial: needs-attention

1. **P3** · `tools/elevated-smoke.ps1:1232`: `-ProveRollback` still loses early refusal codes. Reproduce on a first registration with no protected directory and missing `reskit\python\python.exe`, using `-Register -ProveRollback`. `Invoke-ProveRollback` discards code 12, reports that the injected failure did not occur, and returns 2. Consequently, the new fallback at line 1550 finds no message, and the operator still receives only the generic failure instead of the missing-Python reason and remedy. Preserve the early refusal code through the proof wrapper.

Static review only; the state-changing self-test was not run.

HIGHEST: P3
OVERALL: needs-attention

## Writer note: settled

- Filed: D07 T01 §10 (round 1's P3: an early refusal inside `-Register -ProveRollback` is turned into the proof's own generic failure, so its exit code is lost; it belongs to that section's item "Prove the rollback at this registration", the one place `-ProveRollback` is run, which now names it)

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T01:55:27Z
- Candidate: 964499cb90b3b75e8a8a6722cf8170294a17853f
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 3984c0ebaecd02b02374bb8c84e93ea8744d38c3
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 26
- Digest: babc5342e16eb116

Part 1: completeness

1. **present:** Early refusals have distinct exit codes and readable reasons, including wrong-account consent and missing Python. Evidence: `tools/elevated-smoke.ps1:69`, `:1302`, `:1308`, `:1312`.
2. **present:** The original operator window prints the reason when no new log exists, then returns failure. Evidence: `tools/elevated-smoke.ps1:1546`.
3. **present:** Actionable recovery instructions cover signing in with the correct account, bootstrapping Python, waiting for an active task, and retrying after lock contention. Evidence: `tools/elevated-smoke.ps1:71`.
4. **present:** Cancelled consent or failure to launch the elevated process produces an explanation and nonzero result. Evidence: `tools/elevated-smoke.ps1:1539`.
5. **present:** First-registration refusal requires no persistent message file or undo operation. The missing-Python test checks that neither directory nor task was created. Evidence: `tools/elevated-smoke.ps1:839`.
6. **present:** The surrounding section provides atomic journal publication, readback, recovery, and retry after a locked file prevents recovery. Evidence: `tools/elevated-smoke.ps1:442`, `:487`, `:905`; operator documentation at `docs/testing.md:85`.
7. **present:** Exit-code mapping and the missing-Python transaction have regression checks. Evidence: `tools/elevated-smoke.ps1:844`, `:1083`. Candidate commit `964499c` records 78 passing checks and two failing broken copies.
8. **missing-in-scope:** The parent-window test does not exercise output. At `tools/elevated-smoke.ps1:1087`, it checks only whether two source strings exist. An in-memory check confirmed that reversing the condition at `:1551` preserves this assertion while suppressing the explanation for the exact first-registration case. Replace this source inspection with one behavioral case invoking the parent path with an empty log and refusal code, asserting the displayed reason and nonzero result.

GUI controls, focus order, tooltips, theme settings, and DPI rendering do not apply to this repository-tooling change.

Part 2: excellence

Counterpart: none in `resolute_au3/`. Behavioral parity and the graphical surface requirements of `DESIGN.md` are not applicable.

1. **in-scope:** Verification is weaker than the feature’s central promise: that the operator actually sees the refusal. Target: one behavioral regression test capturing the parent’s output for an empty-log refusal, failing when that output branch is removed or inverted. This replaces the existing source-string check, without adding a test matrix.

Gap list

1. **missing-in-scope / in-scope:** Replace the source-string assertion at `tools/elevated-smoke.ps1:1087` with a behavioral test proving the refusal reaches the original operator window.

Review was read-only. The self-test was not rerun because it writes temporary files and creates a scheduled task; its recorded results were inspected.

COMPLETION: gaps

- Implemented: gap 1 (the operator's-window case read source strings, not output) on the repair record `docs/reviews/07-quality/D07-T01-s11-repair4.md`
