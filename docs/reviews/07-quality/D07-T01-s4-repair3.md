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
