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

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T15:25:38Z
- Effort: low
- Writer model: claude-fable-5-2
- Policy: fa84f0bb6cfa365f72ba43e748d4fe41d383caa2
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: 00d6206cb399aec5

## consistency: approve

No findings in the three Repair items covered by this candidate.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T15:28:11Z
- Candidate: 288351e209e66c076997b80824e57fb955a33ec6
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: fa84f0bb6cfa365f72ba43e748d4fe41d383caa2
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 33
- Digest: 81004a7844f2c81b

The three repair items are complete as specification changes. I found no remaining in-scope product gap in this diff. User-level completeness and executed parity remain pending in the already assigned implementation work.

Part 1: completeness

1. **present:** Retained AutoIt behavior and deliberate deviations are accounted for in `docs/framework/language-page.md:13`. Selection persists through `Language`, matching `ReBar.au3:1303`. The settled default, flags and prompt changes are recorded decisions, not parity defects.
2. **present:** Language discovery, English recovery and faulty-pack handling are specified at `language-page.md:51` and `:138`. Named checks at `:271` cover damaged English, missing translations, missing packs and preservation of stored choices.
3. **present:** Slow discovery has a responsive pending state, announcements and protection against overwriting a user's choice (`language-page.md:56`). Checks at `:253` and `:254` exercise delayed reads, clean opening and saving a choice made during scanning.
4. **present:** Preview, persistence and read-back are distinguished (`language-page.md:81`; `docs/framework/preferences.md:51`). Failed or unconfirmed saves retain unsaved state (`preferences.md:57`); Cancel and Discard undo preview without claiming to reverse an already written file.
5. **present:** Restart covers unsaved edits, running-task refusal, launch failure, timeout and cancellation (`language-page.md:106`, `:110`, `:118`). The new waiting contract disables edits and actions across every page while preserving navigation and copying (`:124`). Named checks at `:264` cover timeout and cancellation.
6. **present:** Tool-page controls, validation, declaration refusal and saved-versus-applied outcomes are specified (`docs/framework/tool-pages.md:25`, `:54`, `:68`, `:79`, `:124`). The matrix includes invalid stored values, failed application and refused declarations.
7. **present:** Action ownership survives Preferences closure. Running state prevents duplicate invocation after reopening; results reach the status surface and log even with Preferences closed (`tool-pages.md:100`). The named lifecycle check is at `:230`.
8. **present:** Confirmation obtains concrete impact before execution, defaults to Cancel, handles empty or unreadable targets, and cancels preparation when Preferences closes (`tool-pages.md:107`). Checks at `:231` cover these paths; missing impact functions are declaration refusals.
9. **present:** Keyboard access, announcements, copyable diagnostics and scaling have specified checks (`language-page.md:175`, `:189`, `:203`; `tool-pages.md:240`). I independently confirmed 30 language rows and 22 tool-page rows, no empty failure entries, and clean document lint.
10. **missing-out-of-scope:** Working implementation and executed behavioral proof. These documents specify tests; they do not demonstrate passing persistence, restart, refusal, accessibility or retained AutoIt parity. Owner: D01 T01 §§4, 7, 10 and D01 T02 §§7, 9. The matrix execution remains unchecked at `todo/01-framework/TODO-01-framework-core.md:227` and `:228`.
11. **missing-out-of-scope:** Final language-pack string audit, including removal of obsolete closing-message keys under both spellings (`language-page.md:243`). Owner: D01 T03 §7.
12. **missing-out-of-scope:** Mirrored layout for right-to-left languages remains an explicitly accepted limitation (`language-page.md:207`). Owner: D01 T02 §7.

Part 2: excellence

Counterpart: AutoIt `_ShowPreferencesDlg` and its handlers, with `DESIGN.md` as the modern quality standard.

1. **out-of-scope:** Responsiveness and recovery are specified but unmeasured in a working dialog. **Target:** execute all 52 matrix checks, including responsive five-second discovery, the ten-second restart timeout, cancellation leaving exactly one instance, and action completion after Preferences closes. Owners: D01 T01 and D01 T02.
2. **out-of-scope:** Arabic, Persian and Hebrew retain left-side navigation and unchanged column order (`language-page.md:207`). **Target:** deliver mirrored layout with correct keyboard order, readable mixed-direction paths and no clipping at minimum width and 200 percent text scaling. Owner: D01 T02 §7; this does not reopen the accepted current-version limit.

Gap list

1. **missing-out-of-scope:** Implement and execute persistence, recovery, accessibility and retained AutoIt parity checks; D01 T01 §§4, 7, 10 and D01 T02 §§7, 9.
2. **missing-out-of-scope:** Complete the pack string audit; D01 T03 §7.
3. **missing-out-of-scope:** Deliver RTL layout mirroring, the accepted deferred limit; D01 T02 §7.
4. **out-of-scope:** Demonstrate the specified responsiveness and recovery targets through all 52 matrix checks; D01 T01 and D01 T02.
5. **out-of-scope:** Verify mirrored RTL navigation, mixed-direction text and scaling; D01 T02 §7.

COMPLETION: gaps

## Writer note: completion gaps

- Filed: D01 T01 §4, §7 and §10 and D01 T02 §7 and §9 (gap 1, the build and its executed proof), D01 T03 §7 (gap 2, the string audit) and D01 T02 §7 (gap 3, layout mirroring), already in the plan with those owners.
