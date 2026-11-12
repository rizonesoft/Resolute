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

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T22:52:06Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: f93d89c4bd4d6e639864bf61e9e053cbf3084ed9
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 4bbe43c20f4bb9bc

### adversarial: needs-attention

1. **P2: Expiring a log download discards a known CI failure.** `scripts/ci-status.py:213` catches `BudgetSpent` and returns 2 even when `read()` already identified a completed failed run. Real reproduction: run `python scripts/ci-status.py <failed-pushed-commit> --wait 10` when listing runs succeeds but downloading the failed log exhausts the remaining time. The command prints `gates: failure`, then incorrectly reports `still not finished` and exits 2 instead of 1. Automation consequently treats known red CI as pending. Reproduced with injected responses and clock, without file changes. Preserve the known failure verdict when optional log retrieval exhausts the budget.

HIGHEST: P2
OVERALL: needs-attention

## Writer note: round 1 finding fixed

- Fixed: finding 1 (the wait ending during the failed log's download turned a known failure into exit 2). The log fetch now treats a spent interval as an unread log, and the failure stands; one case covers it. `python scripts/ci-status.py --self-test`: 26 cases, 0 failed.
