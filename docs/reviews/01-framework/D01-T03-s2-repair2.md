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

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T14:34:29Z
- Effort: low
- Writer model: claude-fable-5-2
- Policy: e09b2ef204151cbaf69d3ed594f5c4b99f8257d6
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 8
- Digest: 3e53207f23091d25

### consistency: needs-attention

1. **P3: The reconciliation rule excludes the new immediate action.** `docs/framework/preferences.md:55` says only startup and confirmed saves apply settings, and the override lasts until exit or another priority is saved. Line 127 now requires “Return to High now” to apply immediately and clear that override. Reproduce the contradiction by following the elevated session-Realtime flow and pressing that button without saving. Update the central rule to name this exception.

2. **P3: Keyboard focus still targets the collapsed page list.** `docs/framework/preferences.md:205` requires Ctrl+Tab to keep focus in the page list, and line 216 starts focus there. At the newly supported 560-wide size, line 38 replaces that list with a picker. Reproduce by reopening at 560 wide and pressing Ctrl+Tab: the specified focus destination is absent. Both rules should target the picker when collapsed.

HIGHEST: P3
OVERALL: needs-attention

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T14:36:50Z
- Candidate: 2eecae9532e3c036ea26df31803e8f76c9ed0ab4
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: e09b2ef204151cbaf69d3ed594f5c4b99f8257d6
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 51
- Digest: 045230f0894ae41b

The specification still has gaps. Repair 2 introduces a conflict between “write only edited controls” and dependent settings. Literal 1:1 parity is also not claimed by the page: it records deliberate changes to priority timing, defaults, log clearing and update frequency.

No files modified. The candidate matches the working copy of `preferences.md`; lint returned `[]`; the matrix contains 35 rows with no empty failure entries. These are specification checks, not runtime proof.

Part 1: completeness

Here, `present` means specified, with a named future check.

1. **present: Shell, navigation and exit behavior.** Page order, modality, singleton behavior, dirty state, Save/Discard/Cancel and preview rollback: `docs/framework/preferences.md:35`, `:45`, `:70`, `:76`. Matrix covers opening, switching pages and clean/dirty exits at `:282`.

2. **present: Persistence and recovery.** Atomic write, read-back, validation failure, refused write, unconfirmed save, retry and the warning before Discard: `preferences.md:51`, `:57`, `:63`, `:70`. Failure and restart checks are specified at `:285`.

3. **present: Logging and legacy limits.** Enablement, exact preservation of unedited byte limits, size-read failure, clearing, partial deletion and writer-start failure: `preferences.md:84`, `:91`, `:97`. Checks include 1536 KB and 200 MB preservation at `:298`.

4. **present: Priority and memory behavior.** Six classes, Windows read-back, refusal, session-only Realtime, immediate return to High and memory-timer changes: `preferences.md:113`, `:127`, `:128`, `:143`. Corresponding checks include recovery surviving another Save and reopening at `:290`.

5. **missing-in-scope: Saving dependent priority keys consistently.** `preferences.md:52` forbids rewriting an unedited control’s key, but `:127` requires storing High whenever Realtime is selected without Keep Realtime. Start with `ProcessPriority=5`, `SaveRealtime=1`; uncheck only Keep Realtime and Save. The new rule permits writing only `SaveRealtime=0`, leaving the stored priority at 5. AutoIt explicitly writes priority 4 in this case (`resolute_au3/SDK/Concrete/ReBar/ReBar.au3:1333`). Specify the dependent-key transaction and a check asserting both keys, current-session behavior and High after restart.

6. **present: Updates and Appearance.** Frequency, manual checking, skipped-version reset, completed-check timestamp, failed-check presentation and reversible theme/density previews: `preferences.md:151`, `:152`, `:154`, `:169`. Named checks start at `:307`.

7. **missing-in-scope: First-save update migration agrees with the transaction rule.** `preferences.md:156` promises the first Save writes `UpdateFrequency` for an AutoIt-only file; `:52` prohibits writing its key unless that control was edited. Changing only Reduce memory produces contradictory requirements. Define migration as an explicit transaction exception, with a check that reads back the promised migrated value while preserving unrelated legacy settings.

8. **present: Responsive layout and placement recovery.** Narrow page picker, per-monitor placement, close-time persistence, write failure and geometry recovery: `preferences.md:38`, `:44`. Checks cover narrow navigation and remembered placement at `:284`, `:317`. The settled focus correction remains below.

9. **present: Localization, announcements and diagnostic copying.** Pack keys, UI Automation notifications, selectable notes, Ctrl+C and clipboard refusal: `preferences.md:184`, `:199`, `:224`, `:314`. Scaling and target-size checks are specified at `:316`.

10. **missing-out-of-scope: Executable dialog and behavioral evidence.** The matrix names future tests; it does not demonstrate passing persistence, refusal, rendering, accessibility or parity tests. Already owned by Domain 01, `D01 T01 §7` and `D01 T02 §9`; the proof item remains unchecked at `todo/01-framework/TODO-01-framework-core.md:221`.

11. **missing-out-of-scope: Language and tool-page completion.** Already assigned to Domain 01, `D01 T03 §3`, explicitly excluded at `preferences.md:3`.

12. **missing-out-of-scope: Update-dialog integration and audited shipping strings.** Already assigned to Domain 01, `D01 T03 §5`, `§7` and their implementation consumers; handoffs appear at `preferences.md:154`, `:275`.

Part 2: excellence

Counterparts: AutoIt `_ShowPreferencesDlg` and its handlers; `DESIGN.md` and `docs/framework/standard-window.md` for modern quality.

1. **in-scope: Central reconciliation wording contradicts immediate recovery.** Settled P3, not a new finding: `preferences.md:55` excludes the action specified at `:127`. **Target:** explicitly name Return to High now and successful override clearing in the central rule; no contradictory application rule remains.

2. **in-scope: Narrow-layout focus names an absent control.** Settled P3, not a new finding: `preferences.md:206`, `:216` target the page list after `:38` replaces it. **Target:** at width 560, initial focus and both Ctrl+Tab directions target the visible picker, with visible keyboard focus.

Gap list

1. **missing-in-scope:** Define and check dependent priority writes when Keep Realtime is unchecked.
2. **missing-in-scope:** Reconcile first-save `UpdateFrequency` migration with edited-controls-only writes.
3. **missing-out-of-scope:** Implement and prove the dialog, `D01 T01 §7` and `D01 T02 §9`.
4. **missing-out-of-scope:** Complete Language and tool-page contracts, `D01 T03 §3`.
5. **missing-out-of-scope:** Complete update integration and shipping-string audit, `D01 T03 §5`, `§7` and implementation consumers.
6. **in-scope:** Apply the settled reconciliation wording correction.
7. **in-scope:** Apply the settled narrow-layout focus correction.

COMPLETION: gaps

## Writer note: completion gaps

- Planned: gaps 1 and 2 (the priority pair saved as one; the AutoIt update switch read and never migrated) and gaps 6 and 7 (round 2's two P3: the reconcile rule naming the immediate actions, focus on the page picker when collapsed), as the four Repair 3 items in D01 T03 §2, reviewed on `docs/reviews/01-framework/D01-T03-s2-repair3.md`.
- Filed: D01 T01 §7 and D01 T02 §9 (gap 3), D01 T03 §3 (gap 4), and D01 T03 §5 and §7 (gap 5), already in the plan with those owners.
