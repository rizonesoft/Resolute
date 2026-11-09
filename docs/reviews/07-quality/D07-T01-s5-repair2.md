## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T22:33:59Z
- Candidate: cb55fcbab83ad795ab8bd10274a5af2b4e017460
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 30f6d352855eeea2e9ac1a5f3735bca422607ade
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 5
- Digest: 3547ed807bf5d22a

1. **P2, plan item 2:** At `scripts/smoke-run.py:2281`, cleanup is asserted before the elevated-token case acquires its third synthetic handle. That case can omit or duplicate closure without failing the assertion. Assert the closure delta after each acquisition, including the elevated case, to prove every handle closes exactly once.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

- Planned: P2 closure asserted after the elevated-token acquisition as well, in 6be8a10

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T22:35:36Z
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 30f6d352855eeea2e9ac1a5f3735bca422607ade
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 9
- Digest: e1405621d222a5f8

### adversarial: needs-attention

1. **P3, `scripts/smoke-run.py:2267`: Synthetic token handle reaches a real cleanup API.** `_open_ok()` fabricates handle `99`, but the fixture leaves `kernel32.CloseHandle` intact. Production `is_elevated()` consequently passes `99` to the operating system at line 233. The test does not own that handle. Reproduce with the token-info failure fixture and a recording `CloseHandle` stub: an isolated in-memory probe returned `None` and recorded `[99]`. Stub and restore `CloseHandle` alongside the token APIs, and assert cleanup of the synthetic handle.

Full self-test not rerun because it writes files. No files modified.

HIGHEST: P3

OVERALL: needs-attention

- Not taken: round 1 P3 (synthetic handle reaches real CloseHandle) already implemented in cb55fcb, the repair2 candidate; that round's reused prompt named the earlier aae9f55 candidate, so it describes pre-repair code. Verified in cb55fcb diff and self-test.

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T22:36:47Z
- Candidate: 6be8a109756a5dcfb2a4e383f370bb673010de75
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 30f6d352855eeea2e9ac1a5f3735bca422607ade
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 20
- Digest: ba6a91b6600c6ae1

Static review of `aae9f55` and in-memory probes completed. No files modified. Full self-test results remain writer-supplied because that test writes files. References below use candidate line numbers.

**Part 1: completion gaps**

1. **missing-in-scope:** Missing-handle reporting is corrected at `scripts/smoke-run.py:329` and `:1302`, but the regression at `:2400` does not require termination to be reported as unverified, as repair-plan P2 requires. An in-memory probe confirmed its assertion accepts a report containing no termination information.
2. **present:** Production token-query and shell-error mappings are exercised at `scripts/smoke-run.py:2263`, covering token failures, elevation states, error 1223, error 5 and successful handle return. Fixture isolation remains defective, detailed below.
3. **present:** `scripts/smoke-run.py:2312` tests distinct confirmed and unconfirmed termination outcomes, requiring termination and handle closure.
4. **present:** Default selection and report-write fallback exercise the elevation path through `main()` at `scripts/smoke-run.py:2403` and `:2412`.
5. **present:** Help includes the documented elevated command at `scripts/smoke-run.py:1254`, verified by the assertion at `:2445`.

**Part 2: excellence shortfalls**

1. **in-scope:** The token fixture fabricates handle `99` at `scripts/smoke-run.py:2267` while leaving `kernel32.CloseHandle` real. Production `is_elevated()` passes that synthetic handle to it at `:233`; an isolated probe confirmed the call path. Target: stub and restore `CloseHandle`, assert each acquired synthetic token closes exactly once, and allow zero synthetic handles to reach the real API.

**Consolidated gap list**

1. **missing-in-scope:** Require the missing-handle regression to assert both launch and termination are unverified.
2. **in-scope:** Isolate synthetic token handles from real `CloseHandle` calls and assert cleanup.

COMPLETION: gaps
