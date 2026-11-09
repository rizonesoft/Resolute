## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T09:56:46Z
- Candidate: a896bb2f70a95d835ada0cfc5fcea58d39a165ea
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: a896bb2f70a95d835ada0cfc5fcea58d39a165ea
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 11
- Digest: 145fbbb71acb90fe

1. **P2:** [scripts/smoke-run.py:1585](/D:/GitHub/Resolute/scripts/smoke-run.py:1585) triggers input after 4.9 seconds, before cleanup’s 5-second deadline. The loop can set `stood_down_during_cleanup` first, so removing the deadline assignment still passes. Control the clock to reach only the deadline branch, then assert the final suite verdict.

2. **P2:** [scripts/smoke-run.py:1573](/D:/GitHub/Resolute/scripts/smoke-run.py:1573) uses real capture against HWND `99`. Capture can finish before the worker checks interruption, making the purported ABORTED-branch regression timing-dependent. Keep the capture worker alive deterministically until interruption is observed.

3. **P2:** [scripts/smoke-run.py:1599](/D:/GitHub/Resolute/scripts/smoke-run.py:1599) replaces `drive_tool` and calls `failure_capture` before raising. It bypasses production exception handling at lines 903-906. Removing that handler’s capture would leave this test green. Inject the exception beneath the real driver and verify capture interruption reaches the exceptional final-tool verdict.

4. **P2:** [scripts/smoke-run.py:1624](/D:/GitHub/Resolute/scripts/smoke-run.py:1624) tests only resume and thread-close messages in `job.error`. It neither injects termination, process-close and job-close failures nor exercises their propagation through production cleanup into the report. The required combined five-diagnostic report, five rows and exit `1` remain unproved.

HIGHEST: P2  
PLAN: gaps  
OVERALL: needs-attention

- Planned: controlled-clock deadline branch, deterministic ABORTED capture, real-driver exception evidence, combined five-diagnostic rows (repair6 plan gaps 1-4)

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T10:00:09Z
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: a896bb2f70a95d835ada0cfc5fcea58d39a165ea
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 11
- Digest: 0ccc9afe5ff1e62e

## adversarial: needs-attention

1. **P2: The windowless self-test now opens an unfenced desktop window.** [scripts/smoke-run.py:1672](D:/GitHub/Resolute/scripts/smoke-run.py:1672) drives the real `deaf` fixture, which creates a Tk window. `--self-test` returns before admission checks, and this call uses synthetic elapsed time instead of operator input. **Reproduction:** run `python scripts/smoke-run.py --self-test` during active daytime use without `--visible`. It launches the fixture despite the desktop fence. Move this case behind explicit headful admission or exercise the production exception handler with windowless dependencies.

2. **P2: Slow startup makes the new exception regression fail without reaching its exception.** [scripts/smoke-run.py:1661](D:/GitHub/Resolute/scripts/smoke-run.py:1661) starts a 1.5-second interruption timer before launching Python/Tk, while the main capture deliberately sleeps one second. Startup taking roughly half a second can therefore interrupt the main capture; startup exceeding 1.5 seconds interrupts the launch wait. Both paths return normally, setting `_evidence_ok = False`. **Reproduction:** inject a 1.6-second delay around `spawn_contained` in memory before running this case. The unchanged production handler fails its regression check. Trigger interruption from the exception-capture phase using controlled synchronization instead of launch-relative wall time.

Static review only; reproduction procedures above were not executed. No files modified.

HIGHEST: P2

OVERALL: needs-attention

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T10:02:07Z
- Effort: low
- Writer model: muse-wonder-1.0
- Policy: a896bb2f70a95d835ada0cfc5fcea58d39a165ea
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 9
- Digest: e802a2803245ab98

## consistency: needs-attention

1. **P2:** `scripts/smoke-run.py:1672` at candidate `a3dc5650` violates the documented “windowless logic tests” contract. It launches the `deaf` fixture, which creates a visible Tk window, while `--self-test` bypasses admission. Reproduction: run `python scripts/smoke-run.py --self-test` during active daytime use without `--visible`. This conflicts with `docs/testing.md` desktop fencing rules.

The working-tree HEAD is newer (`493b887b`) and replaces this case with windowless dependencies. The finding applies to the explicitly requested candidate. Static inspection only; reproduction not executed.

HIGHEST: P2

OVERALL: needs-attention

## Writer note: settled (repair6 round 2)

- Settled: the round-2 finding names candidate a3dc5650; the reviewer itself records that HEAD 493b887b replaces the case with windowless dependencies (injected window enumeration, capture, and post; phase-triggered interruption; no Tk window). The round prompt's candidate list predated that fix commit. Round 3 is dispatched against the current tip.

## Round 3: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T10:04:12Z
- Effort: low
- Writer model: muse-wonder-1.0
- Policy: a896bb2f70a95d835ada0cfc5fcea58d39a165ea
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: quality
- Lines: 11
- Digest: ddeb37a87497f74a

## quality: needs-attention

1. **P2: The controlled clock still exercises the loop interruption, not deadline interruption.** `scripts/smoke-run.py:1589-1601`: cleanup establishes deadline `1007`; loop checks advance to `1004`, then `1006`. At `1006`, `resumed()` becomes true inside the loop, setting the flag before deadline expiry. **Reproduction:** an executed, in-memory mutation removing only the deadline flag assignment at line 571 still produced `stood_down_during_cleanup=True`. The regression therefore passes with the previously observed production defect restored. Advance directly past the deadline before input becomes true.

2. **P3: The combined-diagnostics regression bypasses and incompletely asserts its claimed behavior.** `scripts/smoke-run.py:1689-1704`: `_bad_spawn2` fabricates launch diagnostics without creating a process, so process-handle release never runs. Assertions omit thread-release and process-release diagnostics, rendered output, and exit status. **Reproduction:** remove `CloseHandle(thread) failed` from the injected string; every assertion remains satisfied. Inject failures beneath production launch and cleanup, then assert all five diagnostics in the report and exit `1`.

No files modified. Full self-test and GUI evidence were not rerun.

HIGHEST: P2

OVERALL: needs-attention

## Round 4: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T10:05:36Z
- Effort: low
- Writer model: muse-wonder-1.0
- Policy: a896bb2f70a95d835ada0cfc5fcea58d39a165ea
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: integration
- Lines: 9
- Digest: aa23a778214b0925

## integration: approve

No actionable integration findings in the three specified commits. Static inspection found no broken nightly, conformance-consumer, or check-all fence contract.

No files modified. Self-tests and driven evidence were not rerun.

HIGHEST: none

OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T10:07:34Z
- Candidate: e4fe34d14835015e8319f64746ef9d1f4ed1e0d2
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: a896bb2f70a95d835ada0cfc5fcea58d39a165ea
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 26
- Digest: aae29f04f255096d

The repair is **not complete against its regression requirements**, so it does **not yet meet the quality bar**. Inspected all five commits. No files modified; supplied driven results were not rerun.

**Part 1: completeness**

1. **present**: Fail-closed containment, `scripts/smoke-run.py:633`.
2. **present**: Five step rows across normal, refusal and exceptional paths, `scripts/smoke-run.py:512`, `:1012`, `:1053`.
3. **present**: Capture and cleanup stand-down propagate to the suite verdict, `scripts/smoke-run.py:571`, `:949`, `:1044`, `:1059`.
4. **present**: Checked synchronous handle releases and diagnostic aggregation, `scripts/smoke-run.py:357`, `:624`, `:719`, `:764`, `:921`. Complete combined-failure regression proof remains missing.
5. **present**: Guarded reports with stdout fallback, `scripts/smoke-run.py:1015`, `:1068`.
6. **present**: Exceptional failure evidence before teardown, `scripts/smoke-run.py:903`.
7. **missing-in-scope**: Deterministic production-path proof remains weaker than claimed: the combined assertion permits missing diagnostics and extra rows; capture interruption still relies on a two-second sleep.
8. **present**: Nightly verdict, report path and propagation into its failures list, `tools/nightly.ps1:265`.

**Part 2: excellence**

1. **in-scope**: Combined-failure assertions must reject loss of any required diagnostic. Target: inject resume, termination, thread-close, process-close and job-close failures beneath production functions; require all five messages, exactly five step rows and exit `1`.
2. **in-scope**: Capture interruption must be independent of scheduling speed. Target: keep the capture worker blocked through explicit synchronization until interruption is observed, then release it.
3. **out-of-scope**: Elevated RegStudio proof remains owed under §5. Target: elevated start/main/About/exit pass, preferences absent, paired with non-elevated blocked evidence (`todo/07-quality/TODO-01-quality-bar.md:222`).
4. **out-of-scope**: Blocked-capture timeout proof remains owed under §6. Target: bounded return while capture remains blocked, with the test failing when the bound is removed (`todo/07-quality/TODO-01-quality-bar.md:233`).

**Gap list**

1. **missing-in-scope, P2**: [scripts/smoke-run.py:1715](D:/GitHub/Resolute/scripts/smoke-run.py:1715) does not inject termination failure. Its assertion uses process-close **or** job-close and accepts `>= 5` rows. An executed, read-only evaluation of the actual assertion accepted missing termination and process-release diagnostics plus **six rows**. This leaves the recorded five-diagnostic requirement unresolved.
2. **missing-in-scope, P3**: [scripts/smoke-run.py:1574](D:/GitHub/Resolute/scripts/smoke-run.py:1574), also `:1611`, uses `sleep(2)` to keep capture alive. If the caller is descheduled until that sleep finishes, it misses the intended ABORTED branch. This is timing-dependent rather than deterministic.

COMPLETION: gaps

- Implemented: all five launch and release diagnostics asserted exactly (five rows, exit 1) and event-blocked deterministic captures in the repair7 build, reviewed on D07-T01-s4-repair7.md
- Filed: D07 T01 S6 (blocked-capture timeout proof, already tracked)
