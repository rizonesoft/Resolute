## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T22:24:37Z
- Candidate: 42c7bd9bc543c9f42d1cad5868be919c261e9ecf
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 42c7bd9bc543c9f42d1cad5868be919c261e9ecf
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 5
- Digest: 4234caddab1267ab

1. **P2, plan item 1:** The reporting fix lacks an explicit regression test through `main()`, required by the completion finding. Add a case where the shell succeeds without a process handle, exercising production `relaunch_elevated()` and `main()`. Assert exit 2, launch and termination reported as unverified, and absence of “No tool was launched.” A regression restoring the current false assertion must fail this test.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

- Planned: P2 production-path missing-handle case through main() in the repair commit (shell stubbed to succeed without a handle, real relaunch_elevated and main, exit 2, unverified wording, no false no-launch claim)

- Implemented: completion gaps 1-5 and plan P2 in aae9f55 (missing-handle unverified through main, Win32-boundary tests, termination-confirmation assertions, default-selection and report-fallback cases, --help command); self-test all pass

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T22:28:32Z
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 42c7bd9bc543c9f42d1cad5868be919c261e9ecf
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 7
- Digest: 487b85b643450450

### adversarial: approve

No actionable adversarial findings in this candidate. Static review only; the self-test was not rerun because it writes temporary files.

HIGHEST: none

OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T22:29:53Z
- Candidate: aae9f55a41cddcbebfffde8e26c7451b006e13bb
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 42c7bd9bc543c9f42d1cad5868be919c261e9ecf
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 20
- Digest: 4a98763978e981b9

Static review and isolated, in-memory probes completed. No files modified. The full self-test was not rerun because it writes files; its passing result remains writer-supplied evidence.

**Part 1: completion gaps**

1. **missing-in-scope:** Missing-handle reporting is corrected at `scripts/smoke-run.py:329` and `:1302`, but the regression at `:2400` does not assert that termination is unverified, as repair-plan P2 requires. An isolated probe confirmed the assertion passes with termination information entirely absent.
2. **present:** Production token-query and shell-error mappings are exercised at `scripts/smoke-run.py:2263` through `:2307`, including token failures, error 1223, error 5, and successful handle return. The new fixture has an isolation defect described below.
3. **present:** Tests at `scripts/smoke-run.py:2312` require distinct confirmed and unconfirmed termination outcomes, plus termination and handle closure.
4. **present:** Default selection and elevation report-write fallback are exercised through `main()` at `scripts/smoke-run.py:2403` and `:2412`.
5. **present:** Help includes the exact elevated command at `scripts/smoke-run.py:1254`, with an assertion at `:2445`.

**Part 2: excellence shortfalls**

1. **in-scope:** The token fixture fabricates handle `99` at `scripts/smoke-run.py:2267` but leaves `kernel32.CloseHandle` real. Production `is_elevated()` passes that fabricated handle to it at `:233`. An isolated probe confirmed this call path. Target: stub and restore `CloseHandle` alongside the token APIs; assert each successful token acquisition closes its synthetic handle exactly once, with no synthetic handle reaching the real API.

**Consolidated gap list**

1. **missing-in-scope:** Require the missing-handle regression to assert both launch and termination are unverified.
2. **in-scope:** Isolate synthetic token handles from real `CloseHandle` calls and assert cleanup.

COMPLETION: gaps
