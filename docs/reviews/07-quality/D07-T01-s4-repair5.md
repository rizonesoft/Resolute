## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:47:44Z
- Candidate: 1148d2544565973a62bb04bcfb39bf4c24d3c4ae
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 1148d2544565973a62bb04bcfb39bf4c24d3c4ae
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 7
- Digest: 09d6cdb297fd3fc2

1. **P2, plan:** Interruption regression coverage remains incomplete ([scripts/smoke-run.py:1475](D:/GitHub/Resolute/scripts/smoke-run.py:1475)). Tests inject flags directly, bypassing `failure_capture()` and cleanup’s deadline branch. Removing the capture flag assignment or deadline fix would leave these tests passing. The exception test also checks narrative text instead of `Suite verdict: **stood-down**`. Exercise those production paths through final-tool `main()`, including normal and exceptional returns, and assert the verdict and failure-preserving exit code.

2. **P2, plan:** Combined launch/release diagnostic preservation has no regression test ([scripts/smoke-run.py:1467](D:/GitHub/Resolute/scripts/smoke-run.py:1467)). The added aggregation test covers GDI capture releases, not simultaneous resume, termination, thread, process, and job failures. Removing the new launch-handler diagnostic merge would pass these added tests. Inject the combined failures through the production launch/cleanup path and assert every applicable diagnostic survives into the final report with exit `1`.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

- Planned: production capture-interruption and cleanup-deadline tests through final-tool main() (repair5 plan gap 1)
- Planned: combined launch diagnostics regression through the production drive path (gap 2)

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:50:03Z
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 1148d2544565973a62bb04bcfb39bf4c24d3c4ae
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 9
- Digest: c01514ff7681fe1e

## adversarial: needs-attention

1. **P2: Cleanup can detect resumed input without reporting stand-down.** `scripts/smoke-run.py:566` calls `self.resumed()` after the cleanup deadline but never sets `stood_down_during_cleanup` when it returns true. On the final tool, the suite therefore loses the interruption verdict. **Reproduction:** a windowless, in-memory probe of candidate `00763069` kept the child alive, advanced the clock past the cleanup deadline, and returned true for resumed input. Production `cleanup_safely()` closed the job but left the stand-down flag false. Set the flag whenever either cleanup branch observes resumed input.

No files modified. GUI runs and the full self-test were not rerun.

HIGHEST: P2

OVERALL: needs-attention

## Writer note: settled (repair5 round 1)

- Settled: the cleanup deadline-branch finding repeats the repair4 round-1 finding, already fixed in 68753c4e: both cleanup branches set stood_down_during_cleanup (scripts/smoke-run.py lines 563 and 571 at the repair5 tip). The round prompt named candidate 00763069, before that fix; round 2 is dispatched against the current tip.

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:51:21Z
- Effort: low
- Writer model: muse-wonder-1.0
- Policy: 1148d2544565973a62bb04bcfb39bf4c24d3c4ae
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 7
- Digest: 2be63d6f814b7dbf

## consistency: approve

No new actionable consistency findings in `1148d254` or `00763069`. Static review only; supplied self-test and driven evidence were not rerun. No files modified.

HIGHEST: none

OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:53:16Z
- Candidate: d6454f63a29d0bc395faaf1286f7515cbaf6a72a
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 1148d2544565973a62bb04bcfb39bf4c24d3c4ae
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 28
- Digest: fb9cd4d0aa86ba14

The repair is not yet complete against its stated regression requirements, so it does not yet meet the repository’s quality bar. Static review found remaining proof gaps. I inspected both commits; no files were modified, and supplied driven results were not rerun.

**Part 1: completeness**

1. **present**: Fail-closed containment, [scripts/smoke-run.py:633](/D:/GitHub/Resolute/scripts/smoke-run.py:633).
2. **present**: Five step rows, including refusal, interruption and exception paths, [scripts/smoke-run.py:512](/D:/GitHub/Resolute/scripts/smoke-run.py:512).
3. **present**: Capture and cleanup interruption propagate to the suite verdict, [scripts/smoke-run.py:949](/D:/GitHub/Resolute/scripts/smoke-run.py:949), [scripts/smoke-run.py:1044](/D:/GitHub/Resolute/scripts/smoke-run.py:1044). Regression proof remains incomplete, as detailed below.
4. **present**: Checked releases and combined diagnostic reporting on synchronous paths, [scripts/smoke-run.py:357](/D:/GitHub/Resolute/scripts/smoke-run.py:357), [scripts/smoke-run.py:764](/D:/GitHub/Resolute/scripts/smoke-run.py:764), [scripts/smoke-run.py:921](/D:/GitHub/Resolute/scripts/smoke-run.py:921).
5. **present**: Guarded report writes with stdout fallback, [scripts/smoke-run.py:1015](/D:/GitHub/Resolute/scripts/smoke-run.py:1015), [scripts/smoke-run.py:1068](/D:/GitHub/Resolute/scripts/smoke-run.py:1068).
6. **present**: Failure evidence collected before teardown, [scripts/smoke-run.py:903](/D:/GitHub/Resolute/scripts/smoke-run.py:903).
7. **missing-in-scope**: Production-path regressions covering the repaired capture-wait branch, cleanup-deadline branch, exceptional verdict and complete combined diagnostics.
8. **present**: Nightly verdict, report path and failure propagation, [tools/nightly.ps1:265](/D:/GitHub/Resolute/tools/nightly.ps1:265).

**Part 2: excellence**

1. **in-scope**: Regression tests must detect removal of each repaired branch. The current tests can remain green after removing the capture-worker interruption assignment or cleanup-deadline assignment. Target: each such mutation fails a named test.
2. **in-scope**: Combined-failure proof stops at two strings in the start row. Target: the production launch and cleanup path preserves resume, termination, thread, process and job failures in the final report, with five rows and exit `1`.
3. **out-of-scope**: Elevated RegStudio evidence remains owned by §5. Target: the paired elevated pass and non-elevated blocked report specified at [TODO-01-quality-bar.md:227](/D:/GitHub/Resolute/todo/07-quality/TODO-01-quality-bar.md:227).
4. **out-of-scope**: Blocked-capture timeout proof remains owned by §6. Target: bounded return while capture remains blocked, and failure when the bound is removed, [TODO-01-quality-bar.md:233](/D:/GitHub/Resolute/todo/07-quality/TODO-01-quality-bar.md:233).

**Gap list**

1. **missing-in-scope, P2**: Both new capture tests use `abort=lambda: True`, returning at the precheck before `capture_window_bounded()` runs. They never exercise the repaired `ABORTED` branch. Trigger interruption after capture begins and verify final-tool propagation through normal and exceptional returns. [scripts/smoke-run.py:1510](/D:/GitHub/Resolute/scripts/smoke-run.py:1510)
2. **missing-in-scope, P2**: `_SlowProc` exits on its third poll; cleanup observes interruption inside the loop, never at the deadline. Keep the process alive, advance the clock past the deadline, and assert the final stood-down verdict. [scripts/smoke-run.py:1400](/D:/GitHub/Resolute/scripts/smoke-run.py:1400)
3. **missing-in-scope, P2**: The exception test directly sets `run.interrupted` and checks narrative text rather than `Suite verdict: **stood-down**`. Exercise production capture interruption during exception handling and assert that exact verdict while preserving exit `1`. [scripts/smoke-run.py:1490](/D:/GitHub/Resolute/scripts/smoke-run.py:1490)
4. **missing-in-scope, P2**: The combined-diagnostics test replaces `spawn_contained()`, creates no process, and checks neither thread-release text nor process/job failures, final report or exit code. Inject failures beneath the production launch/cleanup functions and assert every diagnostic survives. [scripts/smoke-run.py:1553](/D:/GitHub/Resolute/scripts/smoke-run.py:1553)

COMPLETION: gaps

- Implemented: ABORTED-branch, cleanup-deadline, exceptional-verdict, and combined-diagnostic production regressions in the repair6 build, reviewed on D07-T01-s4-repair6.md
- Filed: D07 T01 S6 (blocked-capture timeout proof, already tracked)
