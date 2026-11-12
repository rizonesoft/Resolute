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

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T21:53:43Z
- Effort: low
- Writer model: claude-fable-5-2
- Policy: f7b3aea0f4fc8521e39155651c00f39df9754e6b
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: 423fc4f323e25d5c

### consistency: approve

No actionable consistency findings in the candidate diff.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T21:55:11Z
- Candidate: 32a5dc029f915ddebd7b96807997a0aea31a49b3
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: f7b3aea0f4fc8521e39155651c00f39df9754e6b
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 24
- Digest: 64896a55f2bd0cae

Part 1: completeness

1. **present**: Atomic publication in the plan’s directory, UTF-8/LF preservation, flush, `fsync`, temporary-file verification and replacement. Evidence: `scripts/todo-graph.py:930`; byte-exact regression assertions at `scripts/todo-graph.py:1454`.
2. **present**: Full-disk, permission and locked-destination failures preserve the old plan before replacement, report the path and failed step, return 1 and suppress success output. Evidence: `scripts/todo-graph.py:950`; seven fault cases at `scripts/todo-graph.py:1461`.
3. **present**: Ctrl+C handling distinguishes interrupted publication from interruption after replacement, returning 130. Evidence: `scripts/todo-graph.py:952`, `scripts/todo-graph.py:1095`; five interruption cases at `scripts/todo-graph.py:1524`.
4. **present**: Temporary-file cleanup has bounded retries and names any remaining file with deletion instructions. Interruption during cleanup also retains that diagnostic. Evidence: `scripts/todo-graph.py:889`; regression cases at `scripts/todo-graph.py:1485` and `scripts/todo-graph.py:1508`.
5. **present**: Post-publication readback failures explicitly report “published” and unverified, without claiming the original bytes survived. Evidence: `scripts/todo-graph.py:958`; regression cases at `scripts/todo-graph.py:1547`.
6. **present**: Subsequent commands read the saved plan from disk; `plan --check` checks its consistency. Evidence: `scripts/todo-graph.py:1001`, `scripts/todo-graph.py:1071`.
7. **present**: Documentation describes atomic replacement and the different failure outcomes. Evidence: the Tooling paragraph beside `plan --sync` in `todo/README.md`.
8. **present**: Regression coverage is connected to repository and CI gates. Evidence: `scripts/check-all.ps1:226`, `.github/workflows/plan.yml:31`.

GUI controls, focus order, themes, DPI, settings, elevation and system-change restore records do not apply to this declared repository-tooling surface. Its recovery contract preserves the old plan before replacement and reports verification failure afterward.

Part 2: excellence

Counterpart: **none**, as explicitly declared for §47. AutoIt parity and the C++ UI requirements are not applicable.

No concrete shortfalls found against the section’s designed behavior or the applicable safety and diagnostic principles of `DESIGN.md`.

Gap list: empty.

Review limit: inspected the candidate and regression assertions without modifying files. Tests were not executed because the self-test writes temporary fixtures. This is a product-completeness assessment, not a fresh gate result or section stamp.

COMPLETION: complete
