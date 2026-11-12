## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T21:22:30Z
- Candidate: 275fcec6756a9835a8d394b85423b2bab8a961c9
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 275fcec6756a9835a8d394b85423b2bab8a961c9
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 5
- Digest: c6dcb151835a8210

1. **P2, plan lens, section lines 1896, 1897 and 1904:** Byte-for-byte preservation is required but not proven by the existing self-test. At the candidate, `scripts/todo-graph.py:1273` compares `read_text()` with the fixture string, which normalizes Windows line endings. A refused sync that rewrites CRLF as LF could still pass. Require before/after `read_bytes()` comparisons for every refusal case, including the new `Moved` case, with a CRLF fixture.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

- Planned: finding 1, every refusal case compares `read_bytes` before and after under LF and CRLF, in the section-correction commit that follows this record
