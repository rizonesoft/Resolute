## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:06:37Z
- Candidate: 3971a345c61babf1c4450f37ad35cbc52729d935
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 3971a345c61babf1c4450f37ad35cbc52729d935
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 17
- Digest: 514c2541c06cca39

1. **P1: Containment failure still executes the child.** `scripts/smoke-run.py:491-499` calls `NtResumeProcess` before checking assignment success. A windowless probe confirmed `assign failed → RESUMED → terminate`. Descendants can escape before cleanup. Resume only after successful containment, check the resume result, and guarantee job closure on launch failure; the current `OSError` return at line 511 leaks the job handle.

2. **P2: Stand-down remains incomplete and can report operator interruption as failure.** Capture waits (`:349`) and exit waits (`:600`) do not check input. An aborted window wait becomes a start or About failure (`:515-524`, `:568-571`), rather than stand-down. A probe confirmed aborted startup returns `False` with failed rows. Input during the last tool can also escape suite-level detection. Every wait needs cancellation handling that dismisses the tool and preserves the interruption verdict.

3. **P2: Nightly cannot parse the stand-down verdict.** `tools/nightly.ps1:269` uses `(\w+)`, which does not match `stood-down`; the actual PowerShell expression returned false. The morning report therefore records `unknown` for this required outcome. Add a regression covering every emitted verdict.

4. **P2: Cleanup exceptions can silently retain a passing result.** At `scripts/smoke-run.py:704-711`, `ensure_rows(..., "fail", ...)` adds nothing when all five rows already exist. An exception from final cleanup can consequently leave five successful/absent rows and a passing suite. Record cleanup failure explicitly and close the job independently of whether process cleanup succeeds.

5. **P2: Failure evidence is still incomplete.** A nonzero process exit (`scripts/smoke-run.py:601-602`) records only its status, without a failure capture or an explicit reason none exists. Unexpected driver exceptions (`:705`) likewise omit capture availability. These paths still fail §4’s actionable-failure requirement. Also, fence refusal renders an empty table (`:678`), contradicting the repair’s stated five-rows-per-tool requirement.

6. **P2: Regression proof does not cover the repaired behavior.** All 26 self-tests pass despite the reproduced containment, interruption, and nightly defects. The added tests exercise helpers directly, so removing their production integration would leave them green. Add windowless failure-injection tests for containment refusal, interrupted waits, cleanup/reporting failures, and nightly verdict propagation. The separately filed blocked-capture timeout case does not cover these paths.

HIGHEST: P1

PLAN: gaps

OVERALL: needs-attention

- Planned: resume only after successful containment, resume result checked, job closed on launch failure (repair plan gap 1, P1)
- Planned: stand-down inside capture and exit waits, aborted waits read as stand-down (gap 2)
- Planned: nightly verdict regex matches stood-down, regression over every verdict (gap 3)
- Planned: cleanup failure records a named row, job closes independently (gap 4)
- Planned: crash exit and driver exceptions name capture availability, refusal renders five rows per tool (gap 5)
- Planned: windowless failure-injection tests for containment, interrupted waits, cleanup (gap 6)

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:10:01Z
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 3971a345c61babf1c4450f37ad35cbc52729d935
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 11
- Digest: ded634564f588f59

## adversarial: needs-attention

1. **P2: Forced cancellation can still orphan a suspended child.** `scripts/smoke-run.py:484-486` creates the process before assigning it to the kill-on-close job. Terminating the driver between these operations leaves the child alive, permanently suspended and outside containment. Suspension prevents execution but does not guarantee cleanup. **Reproduction:** pause immediately before `run.job.assign(run.proc)`, terminate the driver, and inspect the child PID. This is source-derived, not a driven reproduction.

2. **P2: Failure captures bypass operator stand-down.** `scripts/smoke-run.py:673` calls `capture_window_bounded` without the abort callback. A blocked failure capture therefore retains the tool for another ten seconds after input resumes. On the exit-timeout path (`:640-643`), the function then returns `False` without checking input again, so interruption during the final tool can also lose the stand-down verdict. **Reproduction:** make the exit failure capture block, then resume input during capture. A windowless spy confirmed that this call receives no abort callback. This is a production cancellation defect, distinct from the filed timeout-test coverage item.

All 29 self-test checks passed. No files modified; no GUI or forced-termination reproduction performed.

HIGHEST: P2

OVERALL: needs-attention

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:13:21Z
- Effort: low
- Writer model: muse-wonder-1.0
- Policy: 3971a345c61babf1c4450f37ad35cbc52729d935
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 7
- Digest: d2ed96a134b784f1

## consistency: approve

No additional actionable consistency findings in the two candidate commits. Static review only; no tests or GUI runs performed, and no files modified.

HIGHEST: none

OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:15:52Z
- Candidate: 7c664ceb79fd377a390ed9699b5fcfc2461f4765
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 3971a345c61babf1c4450f37ad35cbc52729d935
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 32
- Digest: cc13373265770676

The repair is **not complete** and **does not yet meet the repository’s quality bar**. I inspected all four commits and reran the 29 self-tests successfully. Windowless probes nevertheless reproduced containment, cleanup-reporting, and input-detection defects. No files changed; GUI drills were not rerun.

Part 1: completeness

1. **missing-in-scope: exactly five rows per tool on every path.** The five step rows are filled, but cleanup failures append sixth and potentially seventh rows (`scripts/smoke-run.py:774`, `:780`). Record cleanup failures within the five-step contract or in separate diagnostics.
2. **missing-in-scope: stand-down inside every wait.** Capture callbacks are connected, but `tick_resumed()` misses input across tick rollover and treats input-query failure as no input (`scripts/smoke-run.py:237`, `:252`). A probe returned false for baseline `0xfffffff0`, current `20`. Cleanup also waits up to five seconds without cancellation (`:473`).
3. **missing-in-scope: guaranteed kill-on-close containment from creation.** Atomic job-list creation exists, but `spawn_contained()` clears the job-configuration error (`scripts/smoke-run.py:523`). A failed `SetInformationJobObject` therefore still reaches `CreateProcessW`, potentially using a job without kill-on-close. The windowless probe confirmed this.
4. **missing-in-scope: checked API calls and typed bindings.** Window-enumeration APIs still lack signatures; message posting, process termination and job closure ignore failure returns (`scripts/smoke-run.py:264`, `:330`, `:508`, `:428`). Process/thread handles and the initialized attribute list are never released (`:575-591`).
5. **missing-in-scope: resilient reporting with failure evidence.** The outer exception handler supplies only `driver error`, without capture availability, and suppresses cleanup exceptions (`scripts/smoke-run.py:877-884`). Final report writes remain unguarded (`:850`, `:892`), so an unwritable report destination loses the structured result.
6. **present:** unknown selections fail by name before launch (`scripts/smoke-run.py:833-838`).
7. **missing-in-scope: nightly preserves verdict and concrete report path.** Verdict parsing is repaired, but emitted notes omit the resolved `$smokeReportPath`; the failure branch gives no report filename or directory (`tools/nightly.ps1:265-273`).
8. **missing-in-scope: cleanup failures named.** Python exceptions are reported in normal cleanup, but a failed `CloseHandle` is ignored and its handle discarded (`scripts/smoke-run.py:426-429`). The probe confirmed this silent failure.

Part 2: excellence

1. **in-scope: containment must fail closed.** Target: every job-configuration failure prevents process creation; forced driver termination leaves zero owned processes. Preserve the original API name and error code.
2. **in-scope: production regression coverage remains inadequate.** The “containment refusal” test replaces `JobBox.assign()` with a lambda and tests that lambda, although production now uses `spawn_contained()` (`scripts/smoke-run.py:971-985`). Target: tests invoke production launch, interruption, cleanup and reporting paths, and fail when those protections are removed. Include automated nightly verdict/path assertions.
3. **in-scope: resource ownership and diagnostics need completion.** Target: close every acquired process/thread handle, delete every initialized attribute list, and report failed cleanup APIs by name. Inject failures to verify that none retain a passing outcome.
4. **in-scope: cancellation and reporting need failure-path proof.** Target: rollover and input-query failure cannot silently continue collection; interrupted waits preserve stand-down; recoverable exceptions retain five step outcomes and capture availability; report-write failure still emits an actionable result.
5. **out-of-scope:** the deliberately blocked capture-timeout regression remains owned by `D07 T01 §6` (`todo/07-quality/TODO-01-quality-bar.md:229-238`). Its measurable target is already specified: bounded return while capture remains blocked, with the test failing when the bound is removed.

Gap list

1. **missing-in-scope, P1:** preserve failed job setup and prohibit launch without verified kill-on-close configuration.
2. **missing-in-scope, P2:** complete API checking, bindings and resource release.
3. **missing-in-scope, P2:** repair cancellation edge cases and error-path reporting.
4. **missing-in-scope, P2:** replace disconnected helper checks with production-path regression tests.
5. **missing-in-scope, P2:** reconcile cleanup diagnostics with exactly five step rows.
6. **missing-in-scope, P3:** emit the concrete smoke-report path in every nightly outcome.
7. **missing-out-of-scope:** complete the separately filed §6 capture-timeout proof.

COMPLETION: gaps

- Implemented: fail-closed job configuration, five-row cleanup diagnostics, rollover/fail-closed stand-down, handle and attribute release, guarded report write, exception capture evidence in the repair2 build, reviewed on D07-T01-s4-repair2.md
- Implemented: production-path launch tests and nightly verdict parsing in the repair2 build, reviewed on D07-T01-s4-repair2.md
- Implemented: concrete smoke-report path in every nightly outcome in the repair2 build, reviewed on D07-T01-s4-repair2.md
- Filed: D07 T01 S6 (blocked-capture timeout proof, already tracked)
