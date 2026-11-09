## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:38:16Z
- Candidate: 0c8393c0835b975cd0f1100ad5dbf4751f4e86ca
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 0c8393c0835b975cd0f1100ad5dbf4751f4e86ca
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 9
- Digest: 17ae3de0c2a2a5a2

1. **P2, plan:** Cleanup stand-down is still lost when `drive_tool()` raises on the final tool. The flag is checked only after a successful return, before the exception handler’s cleanup ([smoke-run.py:1029](D:/GitHub/Resolute/scripts/smoke-run.py:1029)). An in-memory probe of production `main()` with the flag set and a driver exception produced `Suite verdict: **fail**`, omitting interruption. Propagate the flag after both paths, retaining failure exit status, and add a final-tool exception regression.

2. **P2, plan:** Regression proof remains incomplete ([smoke-run.py:1269](D:/GitHub/Resolute/scripts/smoke-run.py:1269)). No new test injects capture acquisition/release failures or cleanup-time interruption. The termination/release test exercises exception aggregation already present in the parent commit, so it does not detect this repair’s changes. Add production-path cases that fail with the repaired behavior reverted, including resume, thread, job and GDI release diagnostics.

3. **P2, plan:** Reporting tests do not meet the stated obligations. The nonempty `main()` fixture tests directory creation failure only, not a separate report-write failure after successful directory creation ([smoke-run.py:1293](D:/GitHub/Resolute/scripts/smoke-run.py:1293)). The nightly block test omits `refused`, `stood-down` and timeout exit handling, and never asserts the concrete report path despite its test label ([smoke-run.py:1321](D:/GitHub/Resolute/scripts/smoke-run.py:1321)). Add those cases and assertions.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

- Planned: cleanup stand-down propagates on the exception path with a final-tool regression (repair4 plan gap 1)
- Planned: capture release-injection, cleanup-interruption, and resume-failure production tests (gap 2)
- Planned: report-write failure after mkdir, refused/stood-down/timeout nightly classes with path assertions (gap 3)

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:40:54Z
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 0c8393c0835b975cd0f1100ad5dbf4751f4e86ca
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 8
- Digest: 36955ba3aceacf9c

### adversarial: needs-attention

1. **P2: Cleanup can observe resumed input without propagating stand-down.** At `scripts/smoke-run.py:566`, `self.resumed()` can return true and suppress `kill()`, but this branch never sets `stood_down_during_cleanup`. If input arrives as the five-second cleanup deadline expires on the final tool, `main()` reports `fail` instead of `stood-down`, losing the interruption outcome. **Reproduction:** an in-memory probe through production `cleanup_safely()` and `main()` kept the process alive, advanced the cleanup clock past its deadline, and supplied resumed input. Result: `cleanup stand-down flag: False`, verdict `fail`, exit `1`. Set the flag whenever cleanup observes resumed input; preserve the failure exit status.

No files modified. GUI evidence was not rerun.

HIGHEST: P2  
OVERALL: needs-attention

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:42:03Z
- Effort: low
- Writer model: muse-wonder-1.0
- Policy: 0c8393c0835b975cd0f1100ad5dbf4751f4e86ca
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 7
- Digest: 8d12c48d889c49e8

## consistency: approve

No new actionable consistency findings in either candidate commit. Static review only; supplied self-test and driven evidence were not rerun. No files modified.

HIGHEST: none

OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:45:04Z
- Candidate: 68753c4ec9cdf876e7a94e2bbc7fafac182dd08e
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 0c8393c0835b975cd0f1100ad5dbf4751f4e86ca
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 29
- Digest: 4eb4233770247bcf

The repair still has user-visible diagnostic gaps and does not yet meet the regression-test bar. Inspected all three commits. No files modified; GUI runs and the full self-test were not rerun. Two read-only, in-memory probes exercised production functions with injected dependencies.

**Part 1: completeness**

1. **present**: Fail-closed containment, `scripts/smoke-run.py:633`.
2. **present**: Five step rows across handled execution and refusal paths, `scripts/smoke-run.py:512`, `1003`, `1037`.
3. **missing-in-scope**: Stand-down from every wait. Exception-time failure capture can observe interruption without propagating it to the suite. `failure_capture()` converts `ABORTED` into generic capture-unavailable text at `scripts/smoke-run.py:943`. If the process has already exited, cleanup never sets its interruption flag. On the final tool, `main()` consequently reports `fail`, losing stand-down. The injected probe confirmed this lost flag.
4. **missing-in-scope**: Preservation of every release failure. When resume fails, termination raises, and thread release also fails, `spawn_contained()` stores resume/thread diagnostics in `job.error` at `scripts/smoke-run.py:716` and `721`. The launch exception handler reports only the raised termination error at `765`; cleanup does not report an unchanged `job.error` at `929`. The injected probe confirmed both diagnostics disappear from the rows.
5. **present**: Guarded report writes and stdout fallback, `scripts/smoke-run.py:1006`, `1053`.
6. **present**: Failure evidence collected before teardown, `scripts/smoke-run.py:900`.
7. **missing-in-scope**: Regression proof for the exact repaired failures. The cleanup test at `scripts/smoke-run.py:1384` checks only the cleanup flag, not final-tool `main()` propagation on normal and exceptional returns. It also misses the deadline branch repaired by `68753c4e`. The capture test at `1377` asserts only “release failed”, so losing individual release diagnostics could still pass.
8. **present**: Nightly verdict, report-path reporting, and failure-list propagation, `tools/nightly.ps1:265`; production reporting-block tests at `scripts/smoke-run.py:1326`.

**Part 2: excellence**

1. **in-scope**: Match the tooling bar with diagnostic-specific production-path assertions. Target: simultaneous resume, termination, thread, process, and job failures retain every applicable operation name in the final report, with exit `1`.
2. **in-scope**: Prove interruption end to end. Target: final-tool normal return, exception return, cleanup deadline, and exception-capture interruption each produce `stood-down`; existing failures retain exit `1`. Each regression must fail when its corresponding fix is reverted.
3. **out-of-scope**: Elevated RegStudio evidence remains owned by §5. Target: the approved elevated run records its expected steps passing and preferences absent.
4. **out-of-scope**: Blocked-capture timeout proof remains owned by §6. Target: production capture returns within its bound, and the test fails when that bound is removed.

**Gap list**

1. **missing-in-scope, P2**: Preserve exception-capture interruption through the final suite verdict.
2. **missing-in-scope, P2**: Preserve combined launch and thread-release diagnostics through exception handling.
3. **missing-in-scope, P2**: Add precise regressions for final-tool propagation, deadline interruption, and complete diagnostic aggregation.
4. **missing-out-of-scope**: Elevated RegStudio pass, §5.
5. **missing-out-of-scope**: Blocked-capture timeout test, §6.

COMPLETION: gaps

- Implemented: capture interruption reaches the suite verdict, combined launch diagnostics preserved in the repair5 build, reviewed on D07-T01-s4-repair5.md
- Implemented: precise diagnostic aggregation and final-tool propagation regressions in the repair5 build, reviewed on D07-T01-s4-repair5.md
- Filed: D07 T01 S6 (blocked-capture timeout proof, already tracked)
