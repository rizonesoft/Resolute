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

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T13:49:19Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 69c9a232753ba70ba0e9fc8d1beee6137038f923
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 8b713791d34a6986

### adversarial: approve

No actionable adversarial findings in the Repair 1 candidate. This verdict covers the specification, not runtime implementation.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T13:51:35Z
- Candidate: a0c9c226421a1387124cc664beaf3bffd83434b3
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 69c9a232753ba70ba0e9fc8d1beee6137038f923
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 44
- Digest: cdd1afcb6083a2c7

The repair still has specification gaps. It does not establish runtime parity or a finished user experience. No files were modified.

Part 1: completeness

References to `standard-window.md` below mean `docs/framework/standard-window.md`. **present** means specified, not demonstrated by an executable test. Review scope is Repair 1.

1. **present:** Log-opening failures now belong consistently to the log surface, including missing, unreadable and malformed files. Evidence: `standard-window.md:57`, `:65`, `:202`; the named check reads the inline failure state.

2. **present:** AutoIt’s external log-opening capability has an explicit new home. Evidence: `standard-window.md:25`; `todo/01-framework/TODO-03-framework-surfaces.md:146` owns its trigger, availability, association failure and launch refusal. This preserves the capability specified by `resolute_au3/SDK/Includes/Logging.au3:269`, subject to downstream implementation.

3. **present:** Disabled-item reasons are available through keyboard focus, hover and UI Automation, with activation prohibited. Evidence: `standard-window.md:64`, `:124`, `:203`.

4. **missing-in-scope:** The missing-log wording is corrected, but the promised availability check does not explicitly exercise both first use and deletion after a log existed. `standard-window.md:202` describes generic file absence; the deletion case could remain broken through stale enabled state while that check passes. The explicit acceptance criterion is `todo/01-framework/TODO-03-framework-surfaces.md:80`. Add these two triggers to the existing check.

5. **present:** The repair’s new labels, explanations and prompts have pack sections, English values and substitutions. Evidence: `standard-window.md:170` onward, including `Heading_About`, `Status_Also_Running` and `Status_Cannot_Cancel`.

6. **present:** Maximize, restore, snap, geometry persistence and restart read-back have named checks, including disconnected-monitor recovery. Evidence: `standard-window.md:219`, `:220`, `:221`. Shutdown write failure remains explicitly routed at `:61`.

7. **present:** Both message-copy triggers now require clipboard-content verification, including the held-clipboard failure. Evidence: `standard-window.md:216`.

8. **missing-in-scope:** Density geometry is not yet an unambiguous implementation contract. At `standard-window.md:40`, the heading icon remains at `SpacingLG` from the top and left, while the same row specifies outer padding of `SpacingMD`, `SpacingLG` and `SpacingXL` across densities. Compact and Spacious therefore have conflicting placement instructions. Specify which edges change and one authoritative placement rule; make `window: every density fits at the minimum size` verify it.

9. **missing-in-scope:** Taskbar failure presentation assumes a fraction exists. `standard-window.md:164` supports indeterminate tasks, then requires failures and partial completion to retain “the task’s last fraction.” An update check failing before it reports a total has none. Define that case and include it in the existing taskbar check at `:223`.

10. **missing-out-of-scope:** Working controls, executable regression checks, rendered accessibility and behavioral parity remain downstream in Domain 01: `D01 T01 §7`, `D01 T02 §8`, and `D01 T03 §2` through `§6`. `standard-window.md:9` explicitly distinguishes the specification from behavioral proof. This is the settled implementation boundary, not additional repair scope.

11. **missing-out-of-scope:** Context help and the Donate verdict remain with Domain 06, `D06 T01 §18`, and Domain 01, `D01 T03 §7`, respectively (`standard-window.md:74`, `:82`). These remain settled dependencies.

Part 2: excellence

Counterparts: AutoIt `_StartCoreGui`, `_Logging_OpenFile` and the ReBar English pack; modern quality contract `DESIGN.md`.

1. **in-scope:** Compact density specifies a 22 px status bar (`standard-window.md:42`), although its state segment is clickable and its task segment interactive (`:144`, `:166`). A target contained within that bar cannot meet `DESIGN.md:177`’s 24×24 px minimum at 100% DPI. **Target:** every interactive status segment has a non-overlapping hit target at least 24×24 px in every density, verified by the existing density check. Change the owning geometry rather than extending targets over tool content.

Gap list

1. **missing-in-scope:** Explicitly cover first-use absence and deletion of an existing log in the availability check.
2. **missing-in-scope:** Resolve fixed versus density-dependent heading padding into one placement contract.
3. **missing-in-scope:** Define and check taskbar failure presentation when an indeterminate task has no last fraction.
4. **missing-out-of-scope:** Domain 01 owns implementation and executable evidence for the window, menus and adjacent surfaces.
5. **missing-out-of-scope:** Domain 06 owns context help; Domain 01 owns the Donate verdict.
6. **in-scope:** Raise Compact status-bar interaction geometry to satisfy the minimum 24×24 px hit target.

COMPLETION: gaps

## Writer note: completion gaps

- Planned: gaps 1, 2, 3 and 6 (both availability states, one heading placement rule, an indeterminate task's taskbar failure, a 24 px Compact status bar), as the four Repair 2 items in D01 T03 §1, reviewed on `docs/reviews/01-framework/D01-T03-s1-repair2.md`.
- Filed: D01 T01 §7, D01 T02 §8 and D01 T03 §2 to §6 (gap 4), and D06 T01 §18 and D01 T03 §7 (gap 5), already in the plan with those owners.
