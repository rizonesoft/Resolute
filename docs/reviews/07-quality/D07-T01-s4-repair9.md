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

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T10:23:29Z
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: d000e177dea2c642069dcd5dd78ffdd892523bf6
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 9
- Digest: 963d056754a9a94a

### adversarial: approve

No new actionable findings in either commit. Read-only controlled probes covered input during a blocked join, final-join completion, and deadline expiry.

Full self-tests and desktop runs were not repeated. Filed scheduling proofs remain outside this pass.

HIGHEST: none

OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T10:25:44Z
- Candidate: cd3f9da1cc979df57f57920901630783b4efb832
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: d000e177dea2c642069dcd5dd78ffdd892523bf6
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 25
- Digest: 4ee5eec66ca29830

The ninth repair is complete within its stated scope and meets the applicable quality bar. Remaining proof weaknesses are already assigned elsewhere. I inspected both commits and ran read-only controlled drain probes; I did not repeat the full self-test or desktop runs.

Part 1: completeness

1. **present:** Fail-closed containment, `scripts/smoke-run.py:671`.
2. **present:** Five step rows across execution, refusal, interruption and error paths, `scripts/smoke-run.py:549`, `:1050`, `:1087`.
3. **present:** Stand-down reaches the suite verdict, including input during joining, final-join completion and deadline expiry, `scripts/smoke-run.py:434`, `:1101`. All three controlled probes passed.
4. **present:** Checked synchronous releases and asynchronous diagnostic collection, with unresolved workers failing as unverified, `scripts/smoke-run.py:357`, `:434`, `:662`, `:756`, `:959`.
5. **present:** Guarded refusal and final reports, `scripts/smoke-run.py:1053`, `:1110`.
6. **present:** Failure evidence precedes teardown, `scripts/smoke-run.py:927`, `:941`.
7. **missing-out-of-scope:** Fully scheduling-independent capture regressions. The new test still uses timed workers and real deadlines, `scripts/smoke-run.py:1829`. Explicitly owned by D07 T01 §6, `todo/07-quality/TODO-01-quality-bar.md:234`.
8. **present:** Nightly verdict, concrete report path and failure-list propagation, `tools/nightly.ps1:265`.

Part 2: excellence

1. **out-of-scope:** Capture proof remains weaker than deterministic TODO-tooling tests. Target: controlled clocks and explicitly released workers; removing abort observation must fail even after scheduler delays. Include final-join completion and deadline-expiry cases in durable tests. Owner: §6.
2. **out-of-scope:** Full RegStudio user-path evidence remains unavailable non-elevated. Target: elevated start, main, About and exit pass, preferences explicitly absent, paired with the non-elevated blocked result. Owner: §5, `todo/07-quality/TODO-01-quality-bar.md:227`.

Gap list

1. **missing-in-scope:** None identified.
2. **missing-out-of-scope:** Scheduling-independent capture and timeout proof, D07 T01 §6.
3. **missing-out-of-scope:** Elevated RegStudio pass, D07 T01 §5.

COMPLETION: complete
