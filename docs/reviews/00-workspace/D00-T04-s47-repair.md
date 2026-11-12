## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T21:46:03Z
- Candidate: f7b3aea0f4fc8521e39155651c00f39df9754e6b
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: f7b3aea0f4fc8521e39155651c00f39df9754e6b
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 7
- Digest: fc30db17fa6cdb5e

1. **P1, plan lens, line 1930:** The tests do not prove interrupt classification when `os.replace` succeeds and then raises `KeyboardInterrupt` before returning. All four specified tests could pass while that case incorrectly reports “unchanged.” Add a replacement wrapper that performs the real rename and then raises; assert exit 130, published-but-unverified wording, new plan bytes, no `synced` line and no temporary file.

2. **P2, plan lens, line 1936:** The checkpoint requires “no leftover temporary file” for every case, including the permanently held temporary-file case. That contradicts line 1924 and cannot pass with the required behavior. Explicitly exempt that case: assert one leftover at the reported full path after bounded removal attempts, then release and remove it during test teardown.

HIGHEST: P1
PLAN: gaps
OVERALL: needs-attention

- Planned: finding 1, a rename-then-interrupt case asserting exit 130, the published-but-unverified line, the new plan's bytes, no synced line and no temporary file, in the section-correction commit that follows this record
- Planned: finding 2, the checkpoint exempts the temporary file held for good, which asserts one leftover at the named path, in the same commit

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T21:51:18Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: f7b3aea0f4fc8521e39155651c00f39df9754e6b
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: eadbf62dd921cb50

### adversarial: needs-attention

1. **P2**: `scripts/todo-graph.py:953`: Ctrl+C during cleanup bypasses the new interrupt handler. Reproduce by running `python scripts/todo-graph.py plan --sync` when a write fails from a full disk and a Windows scanner temporarily holds the temporary file without delete sharing, then press Ctrl+C during `_discard`’s retry delay. `KeyboardInterrupt` escapes, leaving the temporary file without the required diagnostic naming it and confirming the plan is unchanged. A read-only fault-injection probe confirmed an uncaught `KeyboardInterrupt`, no diagnostic, and only one cleanup attempt. Handle interruption during cleanup too, retaining the temporary path for reporting.

HIGHEST: P2
OVERALL: needs-attention

## Writer note: round 1 finding fixed

- Fixed: finding 1 (Ctrl+C during the cleanup's retry wait escaped). `_discard` ends its tries on an interrupt and still names the temporary file it leaves; one self-test case interrupts the wait and asserts the refusal, the named leftover and the unchanged plan. Self-test 296 cases, 0 failed; `plan --check` current.
