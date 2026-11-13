## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T14:29:48Z
- Candidate: e09b2ef204151cbaf69d3ed594f5c4b99f8257d6
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: e09b2ef204151cbaf69d3ed594f5c4b99f8257d6
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 9
- Digest: f0f87b74533b41a6

1. **P2, plan, section line 138:** “Return to High now” changes the process priority but never explicitly clears the session override. The existing reconciliation rule can therefore restore Realtime on the next unrelated Save. Specify clearing the override after confirmed success, retaining an accurate state on refusal, and checking that High survives an unrelated Save and reopening Preferences.

2. **P2, plan, section line 139:** Preserving an unedited fractional or out-of-range log limit conflicts with the existing validation rule, which validates every enabled input and rejects those values. An unrelated Save can still be blocked. Explicitly exempt unchanged stored limits from input validation, retain their exact byte value separately from the rounded display, and check successful unrelated saves with both fractional and out-of-range stored limits.

3. **P2, plan, section line 142:** “Reached the server and got an answer” includes HTTP errors and malformed update files, which `D01 T01 §5` already treats as failures. Define completion as receiving and successfully parsing a valid update response. Require those failure cases to preserve `UpdateLastCheck`, display the failed-attempt time, and prove this through timestamp read-back.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

## Writer note: plan findings

- Planned: "Return to High now" clears the session override on a confirmed change, keeps it with the reason on a refusal, and is checked across an unrelated save and a reopen (P2).
- Planned: only an edited control is validated; an unedited limit's exact bytes are kept apart from the rounded display, checked for a fractional and an out-of-range stored limit (P2).
- Planned: a completed check is a valid, parsed update response; HTTP errors and malformed files leave `UpdateLastCheck` unchanged, read back (P2).

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T14:32:54Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: e09b2ef204151cbaf69d3ed594f5c4b99f8257d6
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 68f686f2b226aeea

### adversarial: needs-attention

1. **P2: Restoring on the same monitor bypasses work-area clamping.** `docs/framework/preferences.md:44` places clamping only in the fallback branch. Reproduce by saving a large Preferences window on a high-resolution monitor, reducing that monitor’s resolution, then reopening Preferences with the tool still on it. If the saved rectangle still overlaps the monitor, none of the fallback conditions applies: the dialog restores at its old bounds, potentially leaving Save and Cancel off-screen. The previous contract clamped oversized geometry on every open. Require size and position clamping against the current work area on every restore, including a matching monitor.

HIGHEST: P2
OVERALL: needs-attention
