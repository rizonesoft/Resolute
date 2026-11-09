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
