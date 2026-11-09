## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:18:48Z
- Candidate: 9f5a90156e343e6fa6d739409e5da7158b838610
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 9f5a90156e343e6fa6d739409e5da7158b838610
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 13
- Digest: 71067a4ffaebc970

1. **P2: Resource release remains incomplete.** `scripts/smoke-run.py:477` never closes the process handle. At `:599`, failed attribute update or process creation returns without deleting an initialized attribute list. Thread-handle closure at `:607` ignores failure. Require checked release on every acquired-resource path.

2. **P2: Stand-down still fails open when its baseline query fails.** `tick_resumed()` returns false for a negative baseline (`scripts/smoke-run.py:260`), disabling cancellation for the entire collecting run if the query at `:887` fails. The self-test at `:994` explicitly preserves this behavior. Refuse or stand down on either failed query, and test the production admission path.

3. **P2: Cleanup failures can remain unreported.** Launch-error paths directly call cleanup and job closure (`scripts/smoke-run.py:639`, `:652`), bypassing `cleanup_safely()`. The outer exception handler suppresses cleanup exceptions (`:907`). `TerminateProcess` failures are also ignored (`:519`). Route every exit through checked cleanup that records failures on the exit row.

4. **P2: Reporting resilience is incomplete.** The refusal report still writes without protection (`scripts/smoke-run.py:872`). Exception evidence is attempted only after `drive_tool()` has already terminated the process in its `finally` block (`:780`, `:904`), losing the available failure surface. Capture before teardown and provide the structured stdout fallback for refusal reports too.

5. **P2: Regression proof does not cover the claimed repairs.** The nightly test (`scripts/smoke-run.py:1058`) tests a separate Python regex, so breaking the actual PowerShell parser or removing report paths leaves it green. The successful launch test (`:1051`) explicitly terminates the child, so it cannot prove job containment or handle release. Add production-path failure injections for resource release, reporting, cleanup and baseline-query failure, plus assertions against actual nightly behavior. These gaps are separate from the deferred §6 capture-timeout test.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

- Planned: checked resource release on every path (repair2 plan gap 1)
- Planned: collecting gate refuses a failed baseline query (gap 2)
- Planned: every exit through cleanup_safely, checked TerminateProcess (gap 3)
- Planned: guarded refusal report, evidence captured before teardown (gap 4)
- Planned: production containment proof (job close reaps child), handle-release and nightly contract tests (gap 5)

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:22:21Z
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 9f5a90156e343e6fa6d739409e5da7158b838610
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 11
- Digest: 9b95c45f5def40cf

## adversarial: needs-attention

1. **P2: Collecting admission still permits an unchecked cancellation baseline.** `scripts/smoke-run.py:921` replaces the sample validated at `:897`. If this later query fails, `tick_resumed(-1, ...)` always returns false, disabling stand-down. Input arriving between admission and this replacement baseline is also forgotten. **Reproduction:** windowless probes through `main()` supplied gate/baseline/subsequent ticks of `100/-1/200` and `100/200/200`. Both invoked the driver, reported `resumed=False`, and returned exit 0. Preserve the validated baseline through execution and reject failed samples.

2. **P2: Refusal reporting still crashes when directory creation fails.** `scripts/smoke-run.py:902` calls `mkdir()` outside the report-write guard. An inaccessible report directory therefore prevents both the structured stdout fallback and the intended refusal exit. **Reproduction:** invoke the refusal branch through `main()` with `SMOKE_DIR.mkdir()` raising `PermissionError`. The exception escapes and stdout contains no report. Include directory creation inside the guarded reporting operation.

Probes used in-memory substitutions; no files modified or GUI runs performed.

HIGHEST: P2

OVERALL: needs-attention

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:23:46Z
- Effort: low
- Writer model: muse-wonder-1.0
- Policy: 9f5a90156e343e6fa6d739409e5da7158b838610
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 7
- Digest: 937ca9b5504eb7eb

## consistency: approve

No new actionable consistency findings in the three commits. Static review only; supplied driven evidence was not rerun.

HIGHEST: none

OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:25:58Z
- Candidate: b7cade261843edf5bdcd04dbbf167fbca903e651
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 9f5a90156e343e6fa6d739409e5da7158b838610
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 28
- Digest: 296b3ab66ad6af11

The repair is **not complete** and **does not yet meet the repository’s quality bar**. One windowless failure-injection probe confirmed incomplete handle release. Supplied GUI evidence was not rerun; no files were modified.

Part 1: completeness

1. **present:** Fail-closed containment, including preserving configuration errors and atomic job-list creation. `scripts/smoke-run.py:546`.
2. **present:** Five step rows on handled execution, refusal, interruption and cleanup-failure paths. `scripts/smoke-run.py:453`, `:811`, `:903`.
3. **missing-in-scope:** One validated baseline reaches interactive waits, but cleanup still waits up to five seconds without checking cancellation. This was explicitly outstanding in the first repair’s completion review. `scripts/smoke-run.py:494`, `:520`; `docs/reviews/07-quality/D07-T01-s4-repair.md:112`.
4. **missing-in-scope:** Release is not guaranteed on every acquired-resource path. A termination exception skips process-handle closure; a resume failure followed by a termination exception skips thread-handle closure. The probe recorded only job closure after injected termination failure. Capture resource releases also ignore their results. `scripts/smoke-run.py:487`, `:626`, `:334`.
5. **present:** Refusal and final report directory creation and writes are guarded, with structured stdout fallback. `scripts/smoke-run.py:906`, `:952`.
6. **present:** Operational failure evidence is attempted before teardown, with unavailable-capture explanations. `scripts/smoke-run.py:789`, `:803`, `:838`.
7. **missing-in-scope:** Production launch coverage exists, but admission, reporting and exceptional resource-release regressions remain insufficiently tested. Nightly assertions inspect strings and a separate Python regex rather than execute its verdict contract. `scripts/smoke-run.py:1091`, `:1111`, `:1113`.
8. **present:** Nightly parses hyphenated verdicts and emits the concrete report path for each exit category. `tools/nightly.ps1:265`.

Part 2: excellence

1. **in-scope:** Resource ownership remains weaker than the checked-cleanup bar. Target: every acquired process/thread handle receives a checked release attempt even when termination or another release fails; preserve each failure in the report.
2. **in-scope:** Regression proof remains weaker than the TODO tooling’s production-behavior bar. Target: tests through `main()` reject failed baselines and retain interruption detection; injected report-directory/write failures produce five rows on stdout; exceptional cleanup tests verify actual release calls. Execute the PowerShell reporting logic for all five verdicts and assert paths and failure propagation.
3. **out-of-scope:** Blocked-capture timeout proof remains owned by `D07 T01 §6`. Target: the blocked worker test passes with the bound and fails when it is removed.
4. **out-of-scope:** RegStudio’s successful elevated smoke pass remains owned by `D07 T01 §5`. Target: observed start, main, About and exit passes, with preferences explicitly absent.

Gap list

1. **missing-in-scope, P2:** Exception-safe process/thread release, demonstrated by the windowless cleanup probe.
2. **missing-in-scope, P2:** Production-path regression coverage requested by this repair’s plan review remains incomplete. `docs/reviews/07-quality/D07-T01-s4-repair2.md:25`.
3. **missing-in-scope, P3:** Cleanup wait still lacks the required stand-down check.
4. **missing-out-of-scope:** Blocked-capture timeout test and elevated RegStudio proof remain explicitly assigned to §§6 and 5.

COMPLETION: gaps

- Implemented: exception-safe process/thread release, stand-down-aware cleanup wait, main()-level and PowerShell-expression regression tests in the repair3 build, reviewed on D07-T01-s4-repair3.md
- Filed: D07 T01 S6 (blocked-capture timeout proof, already tracked)
