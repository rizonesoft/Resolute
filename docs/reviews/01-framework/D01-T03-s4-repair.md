## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T15:47:30Z
- Candidate: 57d065bb33c6c6f1edaff85cb11b89cabab8c952
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 57d065bb33c6c6f1edaff85cb11b89cabab8c952
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
- Run: 2026-11-13T15:49:50Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 57d065bb33c6c6f1edaff85cb11b89cabab8c952
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 0b9caf1a201caff2

### adversarial: needs-attention

1. **P2: The minimum-height calculation omits error banners.** `docs/framework/log-surface.md:54` reserves height for the toolbar, three list rows and footer only, but lines 138-145 require a persistent banner above those rows when logging fails. Reproduce by opening an existing log at 480 wide and 200 percent text scaling, shrinking to the calculated minimum, then making the writer fail through a file lock. The required warning, path, Windows reason and Try again control need additional height. The specified minimum cannot preserve both three visible rows and the complete footer. Include visible banners in the height calculation and exercise this failure state in the scaling check.

HIGHEST: P2
OVERALL: needs-attention

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T15:51:17Z
- Effort: low
- Writer model: claude-fable-5-2
- Policy: 57d065bb33c6c6f1edaff85cb11b89cabab8c952
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: bb2a9d176ed55ed7

### consistency: needs-attention

1. **P2**: `docs/framework/log-surface.md:206` says Esc closes the surface whenever focus is outside the find box, including the newly added More menu and its filter submenu. This conflicts with the menu dismissal order in `docs/framework/standard-window.md`. Reproduce at 480 wide: open More, enter the level-filter submenu, then press Esc. The specified action closes the log window instead of dismissing the submenu. Give open menus precedence over the surface’s Esc handling, including the closing rule at line 43.

HIGHEST: P2
OVERALL: needs-attention

## Round 3: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T15:52:29Z
- Effort: low
- Writer model: claude-fable-5-2
- Policy: 57d065bb33c6c6f1edaff85cb11b89cabab8c952
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: quality
- Lines: 6
- Digest: e80008b1d249f273

### quality: approve

No actionable quality findings in the scoped specification changes.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T15:54:31Z
- Candidate: f25f830e4342a178ebb4a3e13c4368c095a492be
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 57d065bb33c6c6f1edaff85cb11b89cabab8c952
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 37
- Digest: 06f57940197a30d0

Part 1: completeness

The candidate is the **log-surface specification**, not the Preferences dialog described elsewhere in the brief. Both repair items are specified. `present` below means documented with a named downstream check, not demonstrated in a running product. I independently counted **34 matrix rows, with zero missing failure or check entries**.

1. **present: Window lifecycle.** Entry points, single instance, ownership, opening focus and closing behavior: `docs/framework/log-surface.md:40`; checks at lines 289 and 290.
2. **present: Persistence and read-back.** Placement uses the settings writer, survives restart, recovers from monitor removal and preserves the earlier placement after a failed save: `docs/framework/log-surface.md:44`; read-back and refusal check at line 291.
3. **present: AutoIt behavior accounting.** Kept, changed and cut behaviors have explicit dispositions: `docs/framework/log-surface.md:15`. Parity is subject to those accepted rulings, not literal reproduction of every AutoIt behavior.
4. **present: Levels and faithful content.** Five statuses, prefix recognition, unknown-level fallback and historical-language limitations: `docs/framework/log-surface.md:58`; checks at lines 292 through 295.
5. **present: Selection and copying.** Multiple selection, filtered selection, exact text, clipboard refusal and retained selection for retry: `docs/framework/log-surface.md:93`; checks at lines 296, 297 and 303.
6. **present: Uninterrupted reading.** Following, pause, resume and filtered arrival counts: `docs/framework/log-surface.md:103`; checks at lines 298 through 300.
7. **present: Search repair.** Latest-query ownership explicitly covers text and level changes on the same file. The delayed-A, completed-B, released-A check verifies rows, count and clipboard: `docs/framework/log-surface.md:120` and line 302.
8. **present: Clear log and reconciliation.** Shared operation, irreversible-deletion warning, partial failure and read-back from disk, including clearing through Preferences: `docs/framework/log-surface.md:124`; checks at lines 304 and 305.
9. **present: Empty and stopped-recording states.** No history, logging disabled, writer failure and recovery have explanations and appropriate next actions: `docs/framework/log-surface.md:132`; checks at lines 306 through 308.
10. **present: File failures and recovery.** Missing, unreadable and malformed files have copyable explanations, recovery actions and specified handling of damaged or oversized lines: `docs/framework/log-surface.md:153`; checks at lines 309 through 311.
11. **present: Responsiveness and live consistency.** Background reading, virtualization, retained large-file limits, incremental updates and invalidation across rotation or clearing: `docs/framework/log-surface.md:161`; checks at lines 312 through 316.
12. **present: External opening and refusal.** The associated-program action preserves the AutoIt capability at `resolute_au3/SDK/Includes/Logging.au3:269`. Missing associations, launch refusal and disappearance before activation are specified at `docs/framework/log-surface.md:186`; checks at lines 317 and 318.
13. **present: Keyboard and assistive access.** Focus order, copyable failure details, announcements and nested Escape handling: `docs/framework/log-surface.md:200`; checks at lines 319, 320 and 322.
14. **present: Narrow-layout repair.** Ordered toolbar overflow, preserved control behavior, wrapping deletion warning and a content-dependent minimum height including banners: `docs/framework/log-surface.md:52`; scaling and overflow checks at lines 321 and 322.
15. **present: String contract.** The new overflow label has a key, alongside the surface’s other strings: `docs/framework/log-surface.md:239` and line 273.
16. **missing-out-of-scope: Working implementation and behavioral proof.** Named checks are specifications, not passing tests. Writer integration, the built surface and its matrix remain unchecked in `todo/01-framework/TODO-01-framework-core.md:133`, line 224 and line 231. Owner: **D01 T01 §3 and §7**, with persistence supplied by §2.
17. **missing-out-of-scope: Completed string audit.** Keys are specified, but this candidate does not deliver the file-wide audit required by `todo/01-framework/TODO-03-framework-surfaces.md:34`. Owner: **D01 T03 §7**.

Part 2: excellence

Counterpart: **AutoIt’s ReBar log list and logging handlers**, with Preferences supplying Clear log. Quality standard: **DESIGN.md**, particularly adaptive layout, accessibility and responsiveness.

1. **out-of-scope: Right-to-left layout remains unmirrored.** `docs/framework/log-surface.md:235` explicitly limits support to text shaping and reading direction. **Target:** mirrored layout and corresponding visual and keyboard order, with timestamps and embedded paths retaining their specified direction, verified at enlarged text sizes. Owner: **D01 T02 §7**.

No additional in-scope shortfall established in the two repaired behaviors. Runtime parity and modern-quality compliance remain unproven until the owned implementation checks run.

Gap list

1. **missing-out-of-scope:** Build the writer integration and surface, then pass all 34 behavioral checks, including persistence read-back and refusal paths. Owner: D01 T01 §2, §3 and §7.
2. **missing-out-of-scope:** Complete the framework string audit. Owner: D01 T03 §7.
3. **out-of-scope:** Deliver and verify mirrored right-to-left layout. Owner: D01 T02 §7.

COMPLETION: gaps

## Writer note: completion gaps

- Filed: D01 T01 §2, §3 and §7 (gap 1, the writer's integration, the built surface and its 34 executed checks) and D01 T03 §7 (gap 2, the string audit), already in the plan with those owners.
