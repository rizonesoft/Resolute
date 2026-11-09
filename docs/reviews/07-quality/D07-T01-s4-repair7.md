## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T10:09:26Z
- Candidate: fd42314b9a049693e68d0d4a7111e77edad27496
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: fd42314b9a049693e68d0d4a7111e77edad27496
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 7
- Digest: f76224f40c4c9045

1. **P3, plan:** Capture interruption remains timing-dependent at `scripts/smoke-run.py:1576` and `:1616`. Both fixtures use `Event.wait(30)`, which releases without observing interruption after 30 seconds. Additionally, the production loop at `:418` checks its deadline before checking abort, so descheduling beyond its 10-second deadline can still skip interruption even while the worker remains blocked. Keep the worker blocked until explicit release, and control the test clock or synchronization so deadline expiry cannot bypass the intended abort observation. Release workers in `finally`. The claimed scheduling-independent proof remains incomplete.

HIGHEST: P3

PLAN: gaps

OVERALL: needs-attention

- Filed: D07 T01 S6 (scheduling-independent capture interruption, repair7 plan P3)

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T10:10:55Z
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: fd42314b9a049693e68d0d4a7111e77edad27496
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 9
- Digest: 0057a0c9170b3b79

## adversarial: approve

No new actionable adversarial findings in the candidate. The capture scheduling issue is already filed under `D07 T01 §6`.

Static review only; self-tests and driven evidence were not rerun. No files modified.

HIGHEST: none

OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T10:12:46Z
- Candidate: fd42314b9a049693e68d0d4a7111e77edad27496
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: fd42314b9a049693e68d0d4a7111e77edad27496
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 27
- Digest: 52a50725c5c8b1e9

The repair still has an in-scope diagnostic-loss gap, so it does not fully meet the quality bar. Both commits were inspected. No files were modified; supplied self-test and GUI results were not rerun.

**Part 1: completeness**

1. **present:** Fail-closed containment, `scripts/smoke-run.py:633`.
2. **present:** Five step rows across normal, refused and exceptional paths, `scripts/smoke-run.py:512`, `:1012`, `:1053`.
3. **present:** Observed capture and cleanup interruptions propagate to the suite verdict, `scripts/smoke-run.py:1044`, `:1055`. Scheduling-independent proof remains deferred to §6.
4. **missing-in-scope:** All release failures are not preserved. `capture_window_bounded` abandons its worker’s result on timeout or interruption; subsequent GDI cleanup exceptions remain in the private `box` and never reach the report (`scripts/smoke-run.py:409`, `:420`, `:423`).
5. **present:** Guarded report writes and stdout fallback, `scripts/smoke-run.py:1015`, `:1068`.
6. **present:** Failure evidence before teardown, `scripts/smoke-run.py:903`, `:907`.
7. **missing-out-of-scope:** Fully deterministic capture-interruption proof remains §6 work (`todo/07-quality/TODO-01-quality-bar.md:234`). The five-diagnostic production assertion now requires every message, exactly five rows and exit `1` (`scripts/smoke-run.py:1733`).
8. **present:** Nightly verdict, report path and failure propagation, `tools/nightly.ps1:265`.

**Part 2: excellence**

1. **in-scope:** Preserve asynchronous capture cleanup diagnostics. Target: a capture that finishes cleanup after timeout or interruption must retain each release failure in the final report, without sacrificing bounded execution. An unfinished cleanup must be explicitly reported as unverified.
2. **out-of-scope:** Scheduling-independent interruption proof, §6. Target: explicit worker release, controlled deadline progression, release in `finally`, and failure when abort observation is removed. Current `Event.wait(30)` cases still depend on scheduling (`scripts/smoke-run.py:1576`, `:1616`).
3. **out-of-scope:** Blocked-capture timeout proof, §6. Target: return within the bound while capture remains blocked; removing the bound must fail the regression (`todo/07-quality/TODO-01-quality-bar.md:233`).
4. **out-of-scope:** Elevated RegStudio proof, §5. Target: elevated start/main/About/exit passes, preferences explicitly absent, paired with non-elevated blocked evidence (`todo/07-quality/TODO-01-quality-bar.md:222`).

**Gap list**

1. **missing-in-scope, P2:** Late capture-release errors are discarded at `scripts/smoke-run.py:420` and `:423`. A read-only execution of the actual bounded-capture function with a controlled clock returned `None`; releasing its worker afterward caused an injected `ReleaseDC failed` exception that could no longer reach the caller. The synchronous five-diagnostic assertion does not cover this path.
2. **missing-out-of-scope:** Scheduling and blocked-capture timeout regressions remain tracked in §6.
3. **missing-out-of-scope:** Elevated RegStudio evidence remains tracked in §5.

COMPLETION: gaps

- Implemented: abandoned capture workers drained into the report before the verdict (late failures named, still-blocked workers reported unverified) in the repair8 build, reviewed on D07-T01-s4-repair8.md
- Filed: D07 T01 S6 (blocked-capture timeout proof, already tracked)
