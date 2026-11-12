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

## Round 3: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T23:06:54Z
- Effort: low
- Writer model: claude-fable-5-2
- Policy: 9bf730ea8cd5fc1e2e7682c1029e125d39f6a91a
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: quality
- Lines: 6
- Digest: d771924a2ba3d3a5

### quality: needs-attention

1. **P3, scripts/ci-status.py:490:** The failed-path-listing test substitutes a function that already raises `CannotAsk`, bypassing the `changed_paths()` error handling it should protect. The whole-push tests likewise supply precomputed paths. Reproduction: load the candidate into memory, replace the `changed_paths()` definition with `return []`, then run `self_test()`. All 35 cases still pass. This regression would let an ordinary push touching `scripts/` omit the required `plan-gates` check. Replace the mocked listing test with one exercising the real helper against a failed git result.

HIGHEST: P3
OVERALL: needs-attention

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T23:08:54Z
- Candidate: 98de93ee04831f1f5e5e6a95b09577345f9103b0
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 9bf730ea8cd5fc1e2e7682c1029e125d39f6a91a
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 22
- Digest: 004363e3f6939500

Part 1: completeness

1. **present:** One-command interface with default `HEAD`, explicit commit, `--wait`, help and self-test: `scripts/ci-status.py:516`. No GUI controls, focus order, tooltips or dialogs apply to this repository tooling.
2. **present:** Commit resolution and failed Git reads cannot silently become empty successful results: `scripts/ci-status.py:80`, `:97`, `:104`, `:135`. The self-test covers failed path listing, invalid commit and resolution consuming the wait budget.
3. **present:** Workflow obligations use the recorded push’s base-to-head changes and the queried commit’s workflow file: `scripts/ci-status.py:117`, `:254`. Tests cover earlier changes within a push, no matching changes, missing push records and pagination.
4. **present:** Green, failed, cancelled, pending and missing-run states; deciding attempts; proof-run exclusion; URLs and failed-log fallback: `scripts/ci-status.py:175`, `:187`. Covered by the self-test.
5. **present:** Shared wait budget, bounded calls, polling feedback and elapsed-time reporting: `scripts/ci-status.py:219`. Tests cover completion, expiry and remaining budget across push lookup requests.
6. **missing-in-scope, P2:** A Windows refusal to launch `gh` escapes the verdict contract. `run_gh()` catches missing executables and timeouts but not `PermissionError` or other launch `OSError`s (`scripts/ci-status.py:63`). A permission refusal therefore produces an uncaught traceback and process exit 1, which consumers interpret as failed CI, rather than exit 3 identifying an unreadable result. I reproduced the uncaught `PermissionError` by injecting that OS failure into the actual `status()` path. Add the named refusal handling and one regression case.
7. **present:** No application settings, persistence, registry changes or repair actions are introduced by the reader, so atomic saving, readback, elevation and undo are not applicable. Its operations are Git and GitHub reads (`scripts/ci-status.py:63`, `:80`, `:187`).
8. **present:** The candidate’s self-test runs successfully: **35 cases, 0 failed**. The brief’s 33-case count predates the two additional cases recorded in the candidate. Live GitHub outcomes quoted in the brief were not independently repeated here.

Part 2: excellence

Counterpart: **none**. This is repository tooling with `Fidelity: none`; AutoIt behavioral parity, DPI, themes and shared UI controls are not applicable.

1. **in-scope, P2:** Permission-refusal feedback is weaker than the section’s explicit error contract and the clear-refusal principle in `DESIGN.md:204`. Target: when Windows refuses to launch `gh`, print the failed operation and actionable reason, return **3**, and produce no traceback. One regression case should prove that consumers cannot mistake this refusal for red CI. This is the same gap as Part 1 item 6.

Gap list

1. **missing-in-scope / in-scope, P2:** `scripts/ci-status.py:63`: handle `gh` launch permission/OS failures as a named exit-3 refusal, with one regression test.

COMPLETION: gaps

- Implemented: gap 1 (a refused `gh` launch escaped as a traceback and exit 1, which reads as red CI) on the repair record `docs/reviews/00-workspace/D00-T01-s10-repair3.md`
- Filed: D00 T01 §11 (round 3's P3: the failed-listing test substitutes a function that already raises, so it does not exercise `changed_paths()` itself)
