## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T14:18:52Z
- Candidate: 164e2012ebe8c2d8bccd2c45652918958703312b
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 164e2012ebe8c2d8bccd2c45652918958703312b
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 11
- Digest: d7ab55304e44f04f

1. **P2, plan, section lines 124 and 127:** Session-only Realtime still contradicts the dirty rule. `docs/framework/preferences.md:118` keeps the combo at Realtime while storing High, but line 46 enables Save whenever those values differ. Define an accepted control baseline separately from persistence, including refusal, reopening and subsequent unrelated saves. Extend the matrix to prove Save becomes disabled and closing immediately after Save produces no unsaved-changes prompt. Also reconcile line 127’s “showing the actual priority” with the page’s requested-priority display.

2. **P2, plan, section lines 125 and 126:** Validation can target a disabled control. Empty the log-size input, uncheck Enable logging, then Save: the input becomes disabled, but validation must reject it and focus it (`preferences.md:50,79-80`). Specify whether disabling logging restores the last valid size or excludes that inactive edit from the transaction. Test this sequence, including re-enabling logging.

3. **P2, plan, section lines 126 and 129:** Logging application failures have no user-facing outcome. Enabling logging or reopening its file after Clear can fail because the log directory is unwritable or the disk is full, even when settings persistence succeeds. `preferences.md:88,168` assumes opening succeeds; the named logging owner does not settle this failure. Specify the persisted/effective state, visible failure and recovery, and add a driven check that prevents reporting successful continued logging when reopening failed.

4. **P2, plan, section lines 124, 135 and checkpoint 138:** Remembered dialog size is promised but incompletely specified and unproven (`preferences.md:44`). Name its settings keys, write timing, interaction with Cancel, and write-failure behavior. Add a resize, close and reopen check with settings read-back. The existing minimum-size check can pass when size persistence is entirely absent.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

## Writer note: plan findings

- Planned: one rule for session-only Realtime and a refused priority alike (after a save every control shows what the file holds; a note says what the tool is running at), with Save disabled, no prompt on closing, and reopening covered (P2).
- Planned: a disabled control is reset to its persisted value and never validated or written, with the empty-size sequence checked (P2).
- Planned: logging that cannot start after a save or restart after a clear: persisted on, writer stopped, `Label_Logging_Not_Running` with the reason, and a check (P2).
- Planned: the dialog's size keys `PreferencesWidth` and `PreferencesHeight`, written at every way out, outside Save and the dirty rule, with its write failure and a resize, close, reopen check (P2).

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T14:21:28Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 164e2012ebe8c2d8bccd2c45652918958703312b
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 8
- Digest: 7242f9edd6d7239e

### adversarial: needs-attention

1. **P2: An unrelated Save cancels session-only Realtime.** `docs/framework/preferences.md:122` applies priority at Save, while line 123 resets the combo to persisted High after granting session-only Realtime. Reproduce: run elevated, save Realtime without Keep Realtime, then change only Reduce memory and save again. Applying the displayed priority now sets High, despite the promise that Realtime lasts until the tool closes. Specify preservation of the session override across unrelated saves, and check this sequence.

2. **P2: Successful persistence followed by an unreadable verification has no defined recovery.** `docs/framework/preferences.md:60` covers a different read-back value but assumes the file can be read. Reproduce through the settings writer: let atomic replacement succeed, then make the verification read return a sharing violation. The file contains the edit, but the runtime has not applied it. Once reading succeeds, line 46's edited-versus-persisted comparison declares the dialog clean, potentially disabling the retry needed to apply it. Define an unverified transaction state, its retry and exit behavior, and check that recovery applies the committed values before reporting success.

HIGHEST: P2
OVERALL: needs-attention

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T14:23:09Z
- Effort: low
- Writer model: claude-fable-5-2
- Policy: 164e2012ebe8c2d8bccd2c45652918958703312b
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 8
- Digest: ad3506a75f9ff03a

### consistency: needs-attention

1. **P2: Logging recovery contradicts the Save transaction.** `docs/framework/preferences.md:89` promises that a stopped log writer retries at the next Save, but line 54 explicitly permits applying only changed settings. Reproduce: enable logging while its directory is unwritable, restore directory access, then change only Reduce memory and Save. Following line 54 leaves logging stopped; following line 89 restarts it. Specify an explicit recovery exception for an enabled but failed writer.

2. **P3: The refused-priority contract still requires reapplying unchanged settings.** `docs/framework/preferences.md:133` says an unrelated save writes the retained priority and applies it again, contradicting line 54. Reproduce: save Realtime with Keep Realtime as a standard user, then change only Reduce memory and Save. The two rules require different writer and process-priority calls. Reconcile this paragraph with the changed-settings-only transaction.

HIGHEST: P2
OVERALL: needs-attention

## Round 3: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T14:24:51Z
- Effort: low
- Writer model: claude-fable-5-2
- Policy: 164e2012ebe8c2d8bccd2c45652918958703312b
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: quality
- Lines: 6
- Digest: 1f28d6fe6e64f122

### quality: approve

No actionable quality findings in the candidate.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T14:27:32Z
- Candidate: a86246dada4aa5e7db835c0efa39a14e0187fec2
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 164e2012ebe8c2d8bccd2c45652918958703312b
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 59
- Digest: 9eaed66790c97727

The specification has gaps. It is not yet a complete user feature, and literal 1:1 parity cannot be claimed: it deliberately changes priority application, defaults, clearing, and update frequency. Those recorded changes are distinct from the unresolved issues below. No files were modified.

Part 1: completeness

Here, `present` means specified in the delivered page, not implemented or proven at runtime.

1. **present: Shared ownership and settings transaction.** Framework ownership, atomic persistence, read-back, validation failures, refused writes, and unconfirmed-write retry are specified at `docs/framework/preferences.md:5`, `:51-64`. Corresponding checks are named at `:277-280`.

2. **present: Basic shell and navigation.** Page order, single-dialog behavior, focus, keyboard operation, scrolling, and clean/dirty exit paths are specified at `preferences.md:35-47`, `:70-76`, `:199-216`; checks at `:275-283`, `:301-303`.

3. **present: Logging controls and operational failures.** Enablement, limit validation, unavailable size, immediate clearing, partial deletion, and failure to restart logging are specified at `preferences.md:84-103`; checks at `:284-289`.

4. **present: Priority selection, refusal, and memory trimming.** Six classes, persistence, session-only Realtime, actual-priority read-back, refusal presentation, and the trim interval/threshold are specified at `preferences.md:113-143`; checks at `:290-294`. The recovery gap below remains.

5. **present: Updates and Appearance controls.** Frequency, manual checking, skipped-version reset, theme/density previews, and preview rollback are specified at `preferences.md:151-182`; checks at `:295-299`.

6. **present: Localization and accessibility contracts.** Pack keys, keyboard paths, announcements, density, and minimum targets are specified at `preferences.md:184-267`; checks at `:300-302`.

7. **missing-in-scope: Directly restore High after session-only Realtime.** After Save, the process runs at Realtime but the combo shows High and Save is disabled (`preferences.md:127`). Selecting High cannot create a persisted-value difference under `:46`, and an unrelated Save deliberately preserves the override (`:55`). The user must save another priority first or restart. Specify an explicit selection of High as ending the override, with a check that Windows reports High after one Save.

8. **missing-in-scope: Preserve an existing log limit without silently editing it.** AutoIt accepts KB values and stores their byte equivalent (`ReBar.au3:1019`, `:1331`). The page rounds/clamps those values to whole MB (`preferences.md:85`), contradicting both the compatibility promise at `:5` and the persisted-value display rule at `:47`. For example, an existing 1536 KB limit becomes 2 MB and can be written during an unrelated Save. Define a lossless representation or an explicit migration decision, and check that opening Preferences and saving another setting preserves the original bytes.

9. **missing-in-scope: Responsive page navigation below 600 base units.** The page list stays 200 wide even at the 560-wide minimum (`preferences.md:38`, `:44`). `DESIGN.md:120` requires sidebar collapse below roughly 600. Specify the collapsed navigation, its accessible names, and its keyboard behavior; check it at the declared minimum.

10. **missing-in-scope: Per-monitor dialog position and geometry recovery.** Only global width and height are specified (`preferences.md:44`, `:303`). `DESIGN.md:122` requires remembered size and position per monitor. Specify position, monitor association, and recovery when that monitor disappears, with a reopen/read-back check.

11. **missing-in-scope: Last-checked semantics and proof.** `preferences.md:152` names the label but does not say whether it represents the last attempt or last successful check, or what happens after failure. Unlike the other displayed controls, it has no dedicated state/check entry in `:275-303`; the Check now row merely says it updates. Define the timestamp’s meaning and check initial, successful, and failed-check presentations.

12. **missing-out-of-scope: Working dialog and executable behavioral proof.** The matrix is a future test contract, not passing tests (`preferences.md:271`). The implementation/proof item remains unchecked at `todo/01-framework/TODO-01-framework-core.md:221`. Domain 01 owns this through `D01 T01 §7` and `D01 T02 §9`, including actual persistence, consumer read-back, accessibility, rendering, and applicable AutoIt parity evidence.

13. **missing-out-of-scope: Language and tool-page completion.** These remain necessary for the complete dialog but explicitly belong to Domain 01, `D01 T03 §3`: language selection, restart/save prompts, malformed packs, and tool-page validation (`TODO-03-framework-surfaces.md:153-157`).

14. **missing-out-of-scope: Installed strings and completed update-dialog integration.** The page hands off the string audit and skipped-version producer (`preferences.md:154`, `:267`). Domain 01 owns these through `D01 T03 §5`, `§7`, and their implementation consumers. Naming their keys does not establish working localized surfaces.

Part 2: excellence

Counterparts: AutoIt `_ShowPreferencesDlg` and its handlers; the mandatory modern-quality counterpart is `DESIGN.md`.

1. **in-scope: “Discard” conceals a consequential recovery exception.** After an unconfirmed write, Discard leaves the possibly changed file intact and those values apply next startup (`preferences.md:57`). Yet the exit prompt only asks “Save your changes?” and offers Discard (`:70-74`); `Save_Unverified` only says confirmation failed (`:263`). **Target:** before this exit, localized text must explicitly explain that the changes may already be stored and may apply next launch. A failed-read-back → Discard → restart check must verify the wording and resulting state.

2. **in-scope: The success table contradicts the page’s principal recovery model.** `preferences.md:61` says successful Save makes persisted and effective values equal to the edits. Successful persistence with refused priority, stopped logging, or session-only Realtime explicitly does not (`:91`, `:127-135`). **Target:** one consistent outcome contract that distinguishes “saved” from “applied,” with all three exceptions represented and no contradictory success assertion.

3. **in-scope: Inline failure details lack the required copy path.** Logging and priority failures are shown as adjacent labels (`preferences.md:91`, `:103`, `:134`). Unlike message dialogs, these labels have no specified selection/copy behavior; paths and filenames therefore lack an explicit implementation contract satisfying `DESIGN.md:97-99`. **Target:** keyboard users can copy the complete displayed diagnostic, including machine values, and the matrix verifies clipboard content.

Gap list

1. **missing-in-scope:** Provide a direct, single-Save transition from session-only Realtime to High.
2. **missing-in-scope:** Preserve existing KB-granularity log limits across unrelated saves.
3. **missing-in-scope:** Specify and check collapsed page navigation below roughly 600 base units.
4. **missing-in-scope:** Specify per-monitor position/size persistence and missing-monitor recovery.
5. **missing-in-scope:** Define and check Last checked after initial state, success, and failure.
6. **missing-out-of-scope:** Build and prove the dialog, owned by `D01 T01 §7` and `D01 T02 §9`.
7. **missing-out-of-scope:** Complete Language and tool-page behavior, owned by `D01 T03 §3`.
8. **missing-out-of-scope:** Complete string deployment/audit and update-dialog integration, owned by `D01 T03 §5`, `§7`, and their implementation consumers.
9. **in-scope:** Explain that Discard after an unconfirmed write can retain settings for next startup.
10. **in-scope:** Reconcile the success-state table with saved-but-not-applied and session-override outcomes.
11. **in-scope:** Specify and verify keyboard-copyable inline diagnostics.

COMPLETION: gaps

## Writer note: completion gaps

- Planned: gaps 1 to 5 and 9 to 11 (ending a session Realtime, unedited controls never rewriting their keys, the collapsed page list, per-monitor placement, Last checked's meaning, the unconfirmed-save prompt, saved against applied, copyable inline notes), as the eight Repair 2 items in D01 T03 §2, reviewed on `docs/reviews/01-framework/D01-T03-s2-repair2.md`.
- Filed: D01 T01 §7 and D01 T02 §9 (gap 6, the build and its proof), D01 T03 §3 (gap 7, the Language page and tool pages), and D01 T03 §5 and §7 (gap 8, the update dialog and the string audit), already in the plan with those owners.
