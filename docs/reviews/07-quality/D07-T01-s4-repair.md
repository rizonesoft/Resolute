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
