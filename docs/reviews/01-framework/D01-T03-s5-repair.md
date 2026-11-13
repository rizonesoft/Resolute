## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T16:09:45Z
- Candidate: b1d8610e419ebb5a7eec7ab9efae65909495526f
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: b1d8610e419ebb5a7eec7ab9efae65909495526f
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 5
- Digest: cfb0043f896963a4

1. **P2, `todo/01-framework/TODO-03-framework-surfaces.md:313`: cancellation remains inaccessible from Preferences.** Preferences is modal (`docs/framework/preferences.md:15`) and its Check now button starts a check, then becomes disabled (`:154`). The proposed Help-menu cancellation and existing status-bar cancellation are both on the disabled parent window. A user must leave Preferences, potentially resolving unsaved edits, to cancel. Specify a keyboard-accessible cancellation action inside Preferences, with its label, state transitions and strings. Extend the matrix to start and cancel a check there while retaining unsaved edits and leaving any overlapping tool action unaffected. The proposed checkpoint exercises only the main-window menu and would pass with this gap.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

## Writer note: plan gaps

- Planned: the one gap, folded before the build: Check now on the Updates page cancels a running check too, since Preferences is modal, with its row, matrix row and string amended in `docs/framework/preferences.md` and a matrix case that keeps an unsaved edit.
