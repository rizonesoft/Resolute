## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T13:45:46Z
- Candidate: 69c9a232753ba70ba0e9fc8d1beee6137038f923
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 69c9a232753ba70ba0e9fc8d1beee6137038f923
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 9
- Digest: 38d6663662108f3e

1. **P2, line 78:** “Open in default app” specifies only successful launching. Add its keyboard trigger, enabled states, localized failure presentation and recovery for a missing file, missing association or launch refusal. Carry these into §4 and the matrix; proving only that a file reaches an associated program leaves ordinary failures untested.

2. **P2, line 79:** UI Automation help text does not make the disabled reason visible to a sighted keyboard user without a screen reader. Require the reason to appear when keyboard navigation focuses the disabled item, and check both its visible presentation and accessible text.

3. **P2, line 85:** Taskbar failure behavior is contradictory: it requires “paused or error” on failure and clearing on failure, without choosing the state or defining its duration. Specify one deterministic transition and clearing trigger, including partial completion and handoff to another running task. The matrix must verify failure and handoff, not merely running and an unspecified end state.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

## Writer note: plan findings

- Planned: "Open in default app" specified whole (trigger, states, three failures) in the log surface that owns it, as a new item in D01 T03 §4, the Repair 1 item pointing there (P2).
- Planned: the disabled reason shown as a tooltip on keyboard focus as well as exposed as help text, in the Repair 1 item and in D01 T02 §8's items (P2).
- Planned: one taskbar rule: clear on success or cancel, error or paused state held until the window is next activated, and handoff to the next running task, each with a matrix check (P2).
