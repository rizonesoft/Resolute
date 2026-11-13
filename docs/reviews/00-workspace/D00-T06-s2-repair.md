## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T18:13:19Z
- Candidate: 9022b7fe3a78152f2e97f6a72f07868939d57719
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 9022b7fe3a78152f2e97f6a72f07868939d57719
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 5
- Digest: 03829c6ef7b52642

1. **P3**, `todo/00-workspace/TODO-06-reference-data.md:145`: The `Done when:` incorrectly requires all four cases to produce a traceback or lose their reason before the fix. At this commit, staging-write and replacement failures already become `EmbedError` with the original reason when cleanup succeeds. Require before-fix failure demonstrations for destination creation and failed cleanup; retain the other cases as preservation checks. Otherwise, the acceptance condition cannot be met honestly.

HIGHEST: P3
PLAN: gaps
OVERALL: needs-attention
