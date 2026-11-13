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
