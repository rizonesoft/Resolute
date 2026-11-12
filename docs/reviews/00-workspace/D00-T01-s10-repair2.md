## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T22:58:58Z
- Candidate: 9bf730ea8cd5fc1e2e7682c1029e125d39f6a91a
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 9bf730ea8cd5fc1e2e7682c1029e125d39f6a91a
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 5
- Digest: ff141ee8b5740712

1. **P2, plan, lines 912, 918 and 922:** Workflow obligations use the queried commit’s changed paths, but GitHub evaluates the whole push’s base-to-head diff. A push containing a TODO edit followed by a C++ commit therefore owes `plan-gates`, although the specified reader can treat its absence as green. Conversely, a change reverted within the same push can leave the reader waiting for a workflow GitHub correctly skipped. Define how the reader obtains the push comparison range, refuse to infer green when that range cannot be established, and test both multi-commit cases. The existing single-commit tests would pass without this behavior. [GitHub’s comparison rules](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#git-diff-comparisons).

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

- Planned: finding 1, what is owed is read from the push GitHub recorded (base to head), with cases for a multi-commit push that owes plan-gates, one that does not, and a commit with no recorded push refusing green, in the section-correction commit that follows this record
