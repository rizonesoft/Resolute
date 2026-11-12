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

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T23:02:29Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 9bf730ea8cd5fc1e2e7682c1029e125d39f6a91a
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 8
- Digest: 969f56402eca0cbd

### adversarial: needs-attention

1. **P2**: [scripts/ci-status.py:124](/D:/Resolute/scripts/ci-status.py:124) searches only the latest 100 pushes, then treats an absent match as proof the commit was never pushed as a head. Ordinary repository activity therefore makes historical CI checks stop working. Reproduce by querying a previously pushed head after 100 subsequent pushes: the command exits 3 without reading its workflow results, although its push remains on a later activity page. GitHub supports [cursor pagination](https://docs.github.com/en/rest/repos/repos#list-repository-activities). Follow those pages within the existing timeout budget, distinguishing an exhausted search from an incomplete one.

The single-request failure path was verified locally; live GitHub reproduction was blocked by the session’s network proxy.

HIGHEST: P2
OVERALL: needs-attention

## Writer note: round 1 finding fixed

- Fixed: finding 1 (only the newest 100 pushes were searched, and no match was read as never pushed). The reader asks the first page, and when the head is not on it asks every page (`gh api --paginate`); a search cut short is exit 3, and only a finished one says GitHub lists no such push. One case covers a head found on a later page. `python scripts/ci-status.py --self-test`: 34 cases, 0 failed; a real read of a mid-push commit still exits 3 after the full search.

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T23:04:14Z
- Effort: low
- Writer model: claude-fable-5-2
- Policy: 9bf730ea8cd5fc1e2e7682c1029e125d39f6a91a
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: 27e8dc3c19c7c1fa

### consistency: needs-attention

1. **P2, scripts/ci-status.py:125:** `push_base()` gives both GitHub requests the same timeout, bypassing the shared deadline between requests. Real path: query a historical head beyond the newest 100 pushes with `--wait 10` over a slow connection. If the first request takes 9 seconds, pagination still receives 10 seconds instead of the remaining 1. A deterministic reproduction returned exit 3 after 18 simulated seconds, with request budgets `[10, 10]`. This contradicts the section’s shared interval and expiry contract. Pass the deadline-aware `bounded` callback into `push_base()` so each request recalculates its remaining time.

HIGHEST: P2
OVERALL: needs-attention

## Writer note: round 2 finding fixed, and settled

- Fixed: finding 1 (the two requests of the push lookup each took the allowance measured before the first). The lookup now goes through the deadline-aware call, so each request gets what is left when it starts; one case shows budgets of 10 and then 1. `python scripts/ci-status.py --self-test`: 35 cases, 0 failed.
- Not taken: further refinements of how exactly `--wait` divides its interval (the reader now returns inside it, asks nothing after it, and reports the time waited). Under the `AGENTS.md` test cadence a finding whose whole consequence is a wait running some seconds long on a path that needs a historical head, a short interval and a slow connection at once is `P3`.
