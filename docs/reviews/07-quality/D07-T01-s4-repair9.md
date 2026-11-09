## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T10:21:22Z
- Candidate: d000e177dea2c642069dcd5dd78ffdd892523bf6
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: d000e177dea2c642069dcd5dd78ffdd892523bf6
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 9
- Digest: c5b9a020f5a14921

1. **P2:** `scripts/smoke-run.py:448-452` misses input arriving during the final join when the worker finishes or the deadline expires. The loop exits without another input check, and `main` calculates the verdict without rechecking. A deterministic, read-only probe reproduced `input_resumed=True`, `stood_down=False`, with the late failure retained. Observe input after draining and before verdict calculation, preserving diagnostics and exit 1.

2. **P2:** `scripts/smoke-run.py:1799-1816` does not prove interruption during draining: `abort=lambda: True` stops before any join. It also uses real deadlines and a worker’s timed wait, so it is not scheduling-independent. Add a controlled worker/clock regression that introduces input during a join and verifies the resulting `stood-down` report, retained diagnostics and exit 1 through `main`.

HIGHEST: P2

PLAN: gaps

OVERALL: needs-attention

- Planned: input observed after the drain and before the verdict (repair9 plan gap 1)
- Planned: through-main drain-join interruption regression (gap 2)
