## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T14:38:51Z
- Candidate: 4f3aae5615a48008089efedd8e500540dde2a35c
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 4f3aae5615a48008089efedd8e500540dde2a35c
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 3
- Digest: 5363a394b6e0de2b

HIGHEST: none
PLAN: complete
OVERALL: approve

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T14:40:44Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 4f3aae5615a48008089efedd8e500540dde2a35c
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 96b27ea9be8cb226

### adversarial: approve

No actionable adversarial findings in the four Repair 3 changes. This verdict covers the specification, not runtime implementation.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T14:42:29Z
- Candidate: b03f45574e76919b5d67cee394f3e9d67060a181
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 4f3aae5615a48008089efedd8e500540dde2a35c
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 41
- Digest: c3ddcb813bd66b0b

Repair 3 closes its four specified issues. No new in-scope gap found. The deliverable is a specification, so user-level completeness and demonstrated parity remain dependent on the already-filed work below. No files modified.

Part 1: completeness

1. **present:** Dialog entry, page navigation, sizing, placement and closing behavior are specified at `docs/framework/preferences.md:38`, `:44`, `:70`; behavioral checks at `:284`, `:294`, `:320`.

2. **present:** Validation, atomic persistence, read-back, write refusal, unconfirmed-save retry and informed Discard are specified at `docs/framework/preferences.md:51`, `:57`, `:63`, `:70`; checks at `:288` through `:291`.

3. **present:** Logging controls, legacy byte-value preservation, unavailable size, startup failure and partial clearing have explicit outcomes at `docs/framework/preferences.md:84`, `:91`, `:97`; checks at `:296` through `:302`.

4. **present:** Priority and Keep Realtime form one transaction, including saving `(5,1)` as `(4,0)` when only Keep Realtime is unchecked: `docs/framework/preferences.md:114`, `:127`, `:307`. This matches the persistence rule in `resolute_au3/SDK/Concrete/ReBar/ReBar.au3:1333` and `:1339`.

5. **present:** Priority refusal, session-only Realtime, immediate recovery and subsequent reconciliation are specified at `docs/framework/preferences.md:55`, `:128`, `:129`; checks at `:292`, `:293`, `:305`.

6. **present:** Memory reduction and update scheduling have named consumers and application timing at `docs/framework/preferences.md:144`, `:159`; checks at `:308`, `:309`. Legacy update settings survive unrelated saves without migration at `:157`, checked at `:310`.

7. **present:** Update status, failed attempts, skipped versions and reversible appearance previews are specified at `docs/framework/preferences.md:153`, `:155`, `:170`; checks at `:311` through `:315`.

8. **present:** Narrow-layout focus, keyboard operation, announcements, diagnostic copying and scaling have explicit contracts at `docs/framework/preferences.md:187`, `:200`, `:207`, `:217`, `:221`; checks at `:286`, `:316` through `:319`.

9. **present:** A falsifiable behavioral-check specification exists at `docs/framework/preferences.md:280`. Independently counted: 37 rows, zero empty failure fields. These are required future checks, not passing executable tests.

10. **missing-out-of-scope:** The working dialog and passing persistence, refusal, accessibility, rendering and behavioral evidence remain unproved. Domain 01 owns implementation through `D01 T01 §7` and controls through `D01 T02 §9`; the executable proof remains unchecked at `todo/01-framework/TODO-01-framework-core.md:221`.

11. **missing-out-of-scope:** Language and tool-page completion remains assigned to Domain 01, `D01 T03 §3`, explicitly excluded at `docs/framework/preferences.md:3`. Already filed.

12. **missing-out-of-scope:** Update-dialog integration and shipping-string audit remain assigned to Domain 01, `D01 T03 §5` and `§7`; outstanding items appear at `todo/01-framework/TODO-03-framework-surfaces.md:207` and `:249`. Already filed.

Part 2: excellence

Counterparts: AutoIt `_ShowPreferencesDlg` and its handlers; `DESIGN.md` and `docs/framework/standard-window.md`.

No additional concrete Repair 3 shortfall found. Literal whole-dialog 1:1 equivalence is not claimed: the specification explicitly records behavioral changes, including priority application at Save, Normal as the default and revised update frequency (`docs/framework/preferences.md:26`, `:125`, `:157`). Runtime parity and the modern quality bar remain unverified under item 10. Its measurable acceptance target is passing every specified matrix check and the owned rendered-surface comparisons.

Gap list

1. **missing-out-of-scope:** Implement and prove the dialog and controls, including all 37 behavioral checks, `D01 T01 §7` and `D01 T02 §9`.
2. **missing-out-of-scope:** Complete Language and tool-page contracts, `D01 T03 §3`.
3. **missing-out-of-scope:** Complete update-dialog integration and shipping-string audit, `D01 T03 §5` and `§7`.

COMPLETION: gaps

## Writer note: completion gaps

- Filed: D01 T01 §7 and D01 T02 §9 (gap 1, building the dialog and running its 37 checks), D01 T03 §3 (gap 2, the Language page and tool pages), and D01 T03 §5 and §7 (gap 3, the update dialog and the string audit), already in the plan with those owners; `D01 T01 §7` carries the item that proves the matrix row by row.
