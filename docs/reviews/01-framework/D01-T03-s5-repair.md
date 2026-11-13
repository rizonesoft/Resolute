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

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T16:12:27Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: b1d8610e419ebb5a7eec7ab9efae65909495526f
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 6d65bd3debe26ec5

### adversarial: approve

No findings within the three Repair items. This verdict covers the specification, not runtime implementation.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T16:14:22Z
- Candidate: b5515425434f811bf8427679bfae8b0e17bb9e84
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: b1d8610e419ebb5a7eec7ab9efae65909495526f
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 28
- Digest: 9daac9963ef8344c

Part 1: completeness

The three repairs are complete as specifications. I found no remaining in-scope gap in this repair. User-facing completeness, behavioral parity and rendered quality remain unproven until implementation.

1. **present:** Legacy behavior and intentional departures are accounted for in `docs/framework/update-notices.md:13`. The settled message-layer and skip-button rulings introduce no outstanding parity defect.
2. **present:** Manual and scheduled entry points, suppression, single-flight operation, timeout and request privacy are specified at `docs/framework/update-notices.md:35` and `:44`.
3. **present:** Cancellation remains reachable during overlapping tool work and inside modal Preferences, preserving the other action and unsaved edits. Evidence: `docs/framework/update-notices.md:47`, `docs/framework/preferences.md:154`, and named checks at `docs/framework/update-notices.md:226`.
4. **present:** Available, latest, failed and successor notices define content, actions and defaults. Evidence: `docs/framework/update-notices.md:60`, `:79`, `:89` and `:143`.
5. **present:** Connection, server, malformed-file, certificate and timeout failures have distinct presentations and recovery actions. Evidence: `docs/framework/update-notices.md:92` and `:95`; matrix checks start at `:239`.
6. **present:** Link refusal, safe fallback, unelevated launch and copyable browser-failure recovery are specified at `docs/framework/update-notices.md:117`; corresponding checks at `:232`.
7. **present:** Persistence includes read-back, refused writes and uncertain outcomes. The repaired skip message makes no false guarantee; restart and Preferences read-back are explicitly checked. Evidence: `docs/framework/update-notices.md:68`, `:131` and `:237`. Unskip is specified in `docs/framework/preferences.md:155`.
8. **present:** Successor acknowledgment now has one consistent rule: dismissal or successful page opening records it; failed opening does not. Evidence: `docs/framework/update-notices.md:121`, `:150` and `:250`.
9. **present:** Localization, keyboard access, focus, announcements, scaling and logging have specified contracts. Evidence: `docs/framework/update-notices.md:155`, `:166` and `:182`, consuming `docs/framework/standard-window.md:98`.
10. **present:** Acceptance checks cover the repaired behaviors, including failure paths. Independently counted **32 matrix rows, zero missing failure/check entries**; the three pages returned **`[]`** from the documentation checker. These are specified checks, not executed regression tests.
11. **missing-out-of-scope:** Working implementation and executed evidence remain necessary before users can trust these behaviors. Domain 01 owns atomic persistence (`todo/01-framework/TODO-01-framework-core.md:105`), the check (`:180`) and driven notice tests (`:233`), all still unchecked. Required evidence includes restart read-back, cancellation isolation, browser refusal, behavioral comparison and rendered accessibility.

Part 2: excellence

Counterpart: AutoIt `_SoftwareUpdateCheck` and its handlers in `resolute_au3/SDK/Includes/Update.au3`, with Preferences integration assessed against `_ShowPreferencesDlg`, its handlers and `DESIGN.md`.

1. **out-of-scope:** Actual safety, recovery, responsiveness and accessibility are unmeasured. Target: execute all 32 notice checks and affected Preferences/window checks; demonstrate cancellation preserves edits and tool work, persistence survives restart, failed browser launch remains recoverable, checks terminate within the specified 15 seconds, and rendered notices satisfy `DESIGN.md`. Owner: Domain 01, `D01 T01 §2`, `§5` and `§7`. No additional specification shortfall found in the three repairs.

Gap list

1. **missing-out-of-scope:** Domain 01 must implement and execute persistence, notice, restart, parity and rendered-accessibility checks.
2. **out-of-scope:** Domain 01 must demonstrate the specified safety, recovery, cancellation and responsiveness targets in the running product.

COMPLETION: gaps

## Writer note: completion gaps

- Filed: D01 T01 §2, §5 and §7 (the one gap: atomic persistence, the check, and the driven notice checks), already in the plan with those owners.
