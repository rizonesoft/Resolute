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

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T22:53:58Z
- Effort: low
- Writer model: claude-fable-5-2
- Policy: f93d89c4bd4d6e639864bf61e9e053cbf3084ed9
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
- Run: 2026-11-12T22:55:47Z
- Candidate: 0f55ef535a895694392b4944205c4e26c6bbf001
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: f93d89c4bd4d6e639864bf61e9e053cbf3084ed9
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 25
- Digest: 7370742e9658c85a

Part 1: completeness

1. **present:** CLI entry points, defaults and help: optional commit defaults to `HEAD`, with `--wait` and `--self-test` (`scripts/ci-status.py:392`). GUI controls, focus order, tooltips and DPI settings do not apply to this repository tooling.
2. **present:** Success, failed, pending and missing-run states, with workflow names, attempts and run URLs (`scripts/ci-status.py:141`). Known failure survives a failed or expired log download (`scripts/ci-status.py:160`).
3. **present:** Workflow requirements come from the queried commit, including the absent-workflow case (`scripts/ci-status.py:78`, `scripts/ci-status.py:195`). Proof runs are excluded (`scripts/ci-status.py:129`).
4. **missing-in-scope, P2:** The requested wait does not bound the complete operation. `git show` and `git diff-tree` retain independent 30-second timeouts; initial `git rev-parse` has none (`scripts/ci-status.py:84`, `:96`, `:400`). An in-memory probe requesting one second, with a Git read consuming two seconds, returned after two seconds. Slow disk or antivirus I/O is sufficient; no contrived conditions are needed.
5. **missing-in-scope, P2:** Local Git failures do not consistently produce the documented reader-error outcome. `changed_paths()` neither catches subprocess exceptions nor checks the return code (`scripts/ci-status.py:95`). An injected timeout escaped `status()` instead of producing a named exit code. An unchecked failed read can also become an empty changed-path list, weakening the owed-workflow decision.
6. **present:** Missing `gh`, authentication failures, API failures and network timeouts have named outcomes (`scripts/ci-status.py:61`). Invalid commit references have an explicit refusal (`scripts/ci-status.py:400`).
7. **present:** Failure summaries extract the gate table and independently label and tail each failed gate’s log, defaulting to 80 lines (`scripts/ci-gate-summary.ps1:44`). Missing output, missing logs and absent summary data have explicit messages (`:39`, `:51`, `:65`, `:70`).
8. **present:** The workflow publishes the summary and retains failure logs for 14 days (`.github/workflows/gates.yml:92`, `:100`). These readers introduce no settings, registry changes or user-data mutations requiring undo or atomic persistence.
9. **present, with coverage gaps identified above:** The candidate’s self-test ran successfully: **26 cases, 0 failed**. Its existing cases do not expose items 4 and 5. The supplied two-failure artifact replay supports summary extraction; I did not independently verify a hosted run of the revised workflow.

Part 2: excellence

Counterpart: **none**. AutoIt behavioral parity and the suite’s graphical accessibility, theme and DPI requirements are not applicable. The relevant quality concerns are bounded responsiveness and actionable failure reporting.

1. **in-scope, P2:** The command can exceed its advertised maximum wait. Target: one deadline covering commit resolution, changed-path discovery, workflow retrieval, network calls and sleeping, with no operation receiving more than the remaining budget. Add one regression covering slow local Git preparation.
2. **in-scope, P2:** Local Git failures can escape as a traceback or be mistaken for valid empty data. Target: every unsuccessful Git read identifies the operation and returns exit 3, except wait-budget exhaustion, which returns exit 2. Never calculate a green verdict from failed path discovery. Add focused regression coverage for these failure outcomes.

Gap list

1. **missing-in-scope / in-scope, P2:** Apply the wait deadline to all Git preparation, including initial commit resolution (`scripts/ci-status.py:84`, `:96`, `:400`).
2. **missing-in-scope / in-scope, P2:** Handle Git exceptions and nonzero exits explicitly so failed path discovery cannot become empty input or an unhandled traceback (`scripts/ci-status.py:95`).

COMPLETION: gaps

- Implemented: gap 1 (the wait interval did not cover the local git reads) on the repair record `docs/reviews/00-workspace/D00-T01-s10-repair2.md`
- Implemented: gap 2 (a failed git read could escape as a traceback or be read as an empty path list) on the same repair record
