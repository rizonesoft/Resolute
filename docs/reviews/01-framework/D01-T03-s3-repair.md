## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T15:21:24Z
- Candidate: fa84f0bb6cfa365f72ba43e748d4fe41d383caa2
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: fa84f0bb6cfa365f72ba43e748d4fe41d383caa2
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 9
- Digest: eb9b9d95dfaf9598

1. **P2, line 200:** Selecting the stored row when it arrives can overwrite a choice the user made during the scan. Specify that automatic selection occurs only before a user choice, preserve pending edits as rows arrive, and keep opening the dialog clean. Add a delayed-scan check that chooses English before the stored pack arrives, then verifies the selection and saved read-back remain English.

2. **P2, lines 198–199:** The asynchronous impact calculation has no defined continuation when Preferences closes before confirmation. The task survives closure, but its confirmation belongs to the closed dialog. Specify whether closure cancels preparation or retains a pending confirmation for reopening; execution must require explicit confirmation. Add a delayed-impact check covering close and reopen, with no deletion before consent and no duplicate invocation.

3. **P2, line 199:** The required refusal check covers a missing impact function, but not an existing function failing because a target folder is unreadable or disappears. The checkpoint can pass without exercising this promised runtime refusal. Add a matrix case that makes impact calculation fail and verifies the reason appears, no confirmation or action runs, and the button becomes available again.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

## Writer note: plan gaps

- Planned: all three, folded into the Repair items before the build: the stored row is chosen on arrival only when the user has not chosen one, and a choice made during the scan is kept (gap 1); closing Preferences while an impact is worked out cancels it, and an action runs only from its confirmation (gap 2); the matrix drives an impact function that fails on an unreadable target (gap 3).

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T15:24:18Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: fa84f0bb6cfa365f72ba43e748d4fe41d383caa2
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 7e239e4eb59f3216

### adversarial: needs-attention

1. **P2: Restart waiting still permits new edits.** `docs/framework/language-page.md:123` disables Save, “the list” and the way out, but does not disable editable controls on other pages. The unsaved-edit check happens before this wait, and acknowledgement proceeds directly to shutdown. **Reproduction:** use the specified five-second acknowledgement fixture; press Restart now, switch to Performance using Ctrl+Tab, and toggle Reduce memory before acknowledgement. The specified shutdown loses that edit without Save/Discard/Cancel. Require all preference edits and action invocations to remain disabled during the restart handoff, including keyboard and UI Automation activation, and cover this sequence in the restart matrix.

HIGHEST: P2
OVERALL: needs-attention
