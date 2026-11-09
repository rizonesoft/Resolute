## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T18:25:31Z
- Candidate: 16031ca887fc3da7a34f9079e26610083560cf5d
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 67e3e7de6aba9aadab9ccb8e035741b45ccec285
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 7
- Digest: e9d7c08438bd78e3

1. **P2, plan items 2-3:** Foreground loss does not cover all resumed operator input. Input can resume while the launcher remains foreground, including between the idle check and activation. Require input monitoring throughout launch, positioning, activation, and capture; on resumption, dismiss owned processes, discard the interrupted capture, and stop subsequent shots. Add a mid-shot interruption drill proving these outcomes. The impossible-idle drill proves only refusal before launch. This remains required by `docs/testing.md:36-40` and the prior completion findings.

2. **P3, plan items 1 and 3:** Checking that sidecars contain `-Visible` and `-Date`, then recapturing through the driver, does not prove the recorded command executes as written. Require running an exact generated sidecar command without editing it and quoting its successful result. Verify its recorded output names and provenance, including a path containing spaces to exercise quoting.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

- Planned: both plan gaps folded (writer, 2026-11-09). (1) Input is monitored throughout each shot (a changed last-input tick during positioning, theme or view changes, settling, or the capture itself stands the run down, dismisses owned processes, and discards the interrupted capture; no later shot is attempted), with a live mid-shot interruption drill quoted in the record. (2) The recorded sidecar command is replayed exactly as written, unedited, into an output path containing spaces, and its outputs are verified.
