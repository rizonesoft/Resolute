## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:28:15Z
- Candidate: 96c50dde7a5d24475c1fbeb401d3b719cb00d474
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 96c50dde7a5d24475c1fbeb401d3b719cb00d474
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 13
- Digest: c7cbe9e0e24923b4

1. **P2: Capture-handle cleanup remains incomplete.** `scripts/smoke-run.py:309-336` acquires resources before entering `try`, discards the original selected bitmap, then attempts to delete the bitmap while it remains selected. Release results are unchecked. Restore the original selection, protect partial acquisition, attempt every release independently, and report failures. This outstanding repair2 requirement remains in scope.

2. **P2: Exceptional cleanup still loses failure evidence and lacks regression proof.** At `scripts/smoke-run.py:507-509`, a process-close exception replaces a termination exception; at `:640-644`, a thread-close failure overwrites the resume error. Preserve each failure. The existing `_BadProc` test is not a `WinProc`, so it never exercises the new process-release `finally`. Add injected termination, resume and release failures, plus a stand-down cleanup-wait test, asserting actual release calls and demonstrating failure against the old behavior.

3. **P2: The new main-level tests are nondeterministic and incomplete.** `scripts/smoke-run.py:1150-1159` restores live input queries and uses the real clock before expecting refusal. During quiet hours with an idle operator, this “windowless” test can launch real tools and return 1 instead of 2. Control time, admission and input; assert zero launches on baseline refusal, retained interruption detection, and five rows per tool for both directory-creation and report-write failures on refusal and admitted-run paths.

4. **P2: The PowerShell test does not exercise nightly’s actual reporting contract.** `scripts/smoke-run.py:1163-1169` executes a copied regex against one literal. It never executes `tools/nightly.ps1:265-273`, checks report paths or failure propagation, or covers all five verdicts through PowerShell. Reverting nightly’s parser can leave this new test passing. Exercise the production reporting block and demonstrate that the relevant old behavior fails.

HIGHEST: P2

PLAN: gaps

OVERALL: needs-attention

- Planned: GDI capture restores selection, guards acquisition, releases independently with failures raised (repair3 plan gap 1)
- Planned: termination and release failures both preserved; WinProc release exercised by injected failures (gap 2)
- Planned: deterministic main() tests with stubbed admission, input, and tool list (gap 3)
- Planned: nightly's production verdict line extracted and executed for every verdict (gap 4)

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:30:48Z
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 96c50dde7a5d24475c1fbeb401d3b719cb00d474
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 11
- Digest: 2623d58f1ec7952b

## adversarial: needs-attention

1. **P2: Failed DC release can still produce a passing capture.** `scripts/smoke-run.py:365` ignores `ReleaseDC`’s return value. **Reproduction:** an in-memory probe supplied a valid, nonblank capture and made `ReleaseDC` return `0`. `capture_window_bounded()` returned the image successfully, allowing the main step to pass despite failed cleanup. Check the release result and propagate failure.

2. **P3: Capture failures lose the diagnostic evidence this repair promises to preserve.** `scripts/smoke-run.py:369` replaces the original exception with cleanup errors, and `:388-400` stores that exception but never returns or raises it. **Reproduction:** injecting a `PrintWindow` exception alongside failed bitmap deletion produced only `RuntimeError("OSError('DeleteObject(bitmap) failed')")`; the production bounded wrapper returned `None`, losing both named failures from the report. Preserve the primary and cleanup failures and propagate them through the wrapper.

Verified with windowless, in-memory probes. No files modified; GUI evidence was not rerun.

HIGHEST: P2

OVERALL: needs-attention

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:32:46Z
- Effort: low
- Writer model: muse-wonder-1.0
- Policy: 96c50dde7a5d24475c1fbeb401d3b719cb00d474
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 7
- Digest: 1192671ccdbc891d

## consistency: approve

No new actionable consistency findings in either commit. Static review only; supplied driven evidence was not rerun. No files modified.

HIGHEST: none

OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:34:51Z
- Candidate: 2747092f4a1d98a23034e597efeb1b9424070078
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 96c50dde7a5d24475c1fbeb401d3b719cb00d474
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 30
- Digest: 82e00a8c3387a4c7

The repair is not complete and does not yet meet the quality bar. A windowless, in-memory probe reproduced lost cleanup failures. No files were modified; supplied GUI runs were not rerun.

**Part 1: completeness**

1. **present:** Fail-closed containment through atomic job-list process creation, with configuration failure preventing launch. `scripts/smoke-run.py:613`.
2. **present:** Five step rows for selected tools, including refusal, interruption and exception paths. `scripts/smoke-run.py:499`, `:983`, `:1015`.
3. **missing-in-scope:** Cleanup detects resumed input but only breaks its wait. It does not propagate stand-down to the caller. On the final tool, the report can therefore omit the interruption. `scripts/smoke-run.py:547`, `:879`, `:1013`.
4. **missing-in-scope:** Checked, exception-safe release with every failure preserved is incomplete. Early `return None` statements bypass the error aggregation after `finally`; bitmap selection and restoration results remain unchecked. The outer exception recovery also suppresses cleanup exceptions. `scripts/smoke-run.py:322`, `:329`, `:350`, `:373`, `:1020`.
5. **present:** Report creation and writing have guarded stdout fallbacks. `scripts/smoke-run.py:986`, `:1032`.
6. **present:** About/exit failures and unexpected drive exceptions collect evidence before teardown. `scripts/smoke-run.py:825`, `:866`, `:880`.
7. **missing-in-scope:** Production-path and `main()` tests exist, but the promised exceptional-release and interruption regressions remain absent. `_BadProc` never exercises `WinProc.close()`; the admitted `main()` fixture has zero tools. `scripts/smoke-run.py:1134`, `:1209`.
8. **present:** Nightly reports the verdict and concrete candidate report path. Integration proof remains weaker than required, as detailed below. `tools/nightly.ps1:265`.

**Part 2: excellence**

1. **in-scope:** Resource-failure diagnostics fall below the tooling bar. Target: every acquisition/capture failure combined with any release failure preserves all named failures through the bounded wrapper and report.
2. **in-scope:** Interruption handling lacks an observable final-tool outcome. Target: input arriving during cleanup stops further driving and produces `stood-down`, while retaining any cleanup failures and the appropriate nonzero exit.
3. **in-scope:** Regression coverage does not substantiate the repair record’s promises. Target: injected termination, resume, process/thread/job/GDI release failures assert actual release calls and retained diagnostics; `main()` tests assert exactly five rows per tool for directory-creation and report-write failures, and zero launches on refusal.
4. **in-scope:** The PowerShell test executes only the extracted parser line. Target: exercise the production reporting block for all verdicts and exit classes, asserting the concrete path and failure-list propagation. `scripts/smoke-run.py:1242`; `tools/nightly.ps1:271`.
5. **out-of-scope:** Elevated RegStudio evidence remains owned by §5. Target: paired elevated success and non-elevated blocked reports. `todo/07-quality/TODO-01-quality-bar.md:217`.
6. **out-of-scope:** Blocked-capture timeout regression remains owned by §6. Target: the bounded wrapper returns while capture remains blocked, and the test fails when the bound is removed. `todo/07-quality/TODO-01-quality-bar.md:229`.

**Gap list**

1. **missing-in-scope, P2:** Preserve cleanup failures on early capture returns. My probe made `PrintWindow` return zero and all three releases fail; `capture_window()` returned `None` without reporting any release failure. Failed DC creation likewise swallowed failed `ReleaseDC`. Check selection/restoration results and remove the outer cleanup exception suppression.
2. **missing-in-scope, P2:** Propagate cleanup-time stand-down into the final suite result, including when it occurs on the last tool.
3. **missing-in-scope, P2:** Add the missing exceptional-release, final-cleanup interruption, nonempty `main()` fallback and nightly reporting regressions. Passing current self-tests does not close these previously identified obligations.
4. **missing-out-of-scope:** Elevated RegStudio proof and blocked-capture timeout testing remain explicitly assigned to §5 and §6.

COMPLETION: gaps

- Implemented: capture early returns aggregate release failures, cleanup stand-down propagates to the suite verdict, outer cleanup unsuppressed in the repair4 build, reviewed on D07-T01-s4-repair4.md
- Implemented: exceptional-release injection, nonempty main() fallback, and nightly reporting-block execution tests in the repair4 build, reviewed on D07-T01-s4-repair4.md
- Filed: D07 T01 S6 (blocked-capture timeout proof, already tracked)
