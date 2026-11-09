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
