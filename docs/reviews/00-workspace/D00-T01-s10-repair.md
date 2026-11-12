## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T22:48:40Z
- Candidate: f93d89c4bd4d6e639864bf61e9e053cbf3084ed9
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: f93d89c4bd4d6e639864bf61e9e053cbf3084ed9
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 7
- Digest: a285c98400bfc286

1. **P2, plan lens, section lines 912 and 918:** Workflow requirements are not tied to the requested commit. The candidate reader loads `plan.yml` from the current working tree (`scripts/ci-status.py:150`), so editing its filters while an earlier candidate’s CI runs can change whether that candidate requires `plan-gates`, potentially reporting green prematurely. Require reading the workflow definition from the queried commit, reporting retrieval failures, and testing that subsequent working-tree edits cannot change its verdict.

2. **P2, plan lens, section lines 918 and 920:** The wait repair contradicts the promised time bound: it sleeps until the deadline and then starts another network read. The existing timeout wrapper also grants at least one second after expiry (`scripts/ci-status.py:155`). An instantaneous fake response passes the proposed checkpoint while a slow real request exceeds the bound. Specify one deadline covering polling and subprocess calls, no new calls after expiry, and exit 2 when the wait budget expires. Add a fake-clock case where the request itself consumes time, distinguishing budget expiry from an independent API timeout.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

- Planned: finding 1, the path filter read from the queried commit with retrieval failures reported, in the section-correction commit that follows this record
- Planned: finding 2, one deadline over sleeping and every gh call, no call after expiry, budget expiry (2) told apart from a gh timeout (3), in the same commit
