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
