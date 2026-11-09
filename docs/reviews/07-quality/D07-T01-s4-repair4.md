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
