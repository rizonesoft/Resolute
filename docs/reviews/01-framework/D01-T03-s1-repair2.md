## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T13:53:20Z
- Candidate: 4757a8427588914ab527db300386e82361535eee
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 4757a8427588914ab527db300386e82361535eee
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 7
- Digest: 0e31c7699bdfc222

1. **P2, line 86:** Disabling both log items when the file is absent conflicts with `docs/framework/standard-window.md:58`, which enables “Open log folder” whenever the folder exists. Deleting a log normally leaves its folder intact. Specify and check independent availability: disable file opening, keep folder opening enabled when its directory exists, and open that directory without selecting the missing file. Give a missing directory its own accurate disabled reason.

2. **P2, line 87:** The heading repair changes placement but requires only updating the regions table. The existing density check verifies heights and clipping, so incorrect icon offsets or title spacing could still pass. Require that same matrix check to measure the icon’s left/top offsets and its gap to the title against `SpacingMD`, `SpacingLG` and `SpacingXL` at the respective densities.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

## Writer note: plan findings

- Planned: independent availability for the two log items, a missing folder's own reason, and checks for a first run, a deleted log and a missing folder (P2), in the corrected first Repair 2 item.
- Planned: the density check measures the heading's icon offsets and title gap (P2), in the corrected second Repair 2 item.

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T13:55:38Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 4757a8427588914ab527db300386e82361535eee
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 93c5598d2278620f

### adversarial: approve

No actionable adversarial findings in the four Repair 2 changes. This review covers the specification, not runtime implementation.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T13:57:06Z
- Candidate: dc0d8e6ae122317bdb1b667ed0beb41c24054f10
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 4757a8427588914ab527db300386e82361535eee
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 38
- Digest: 9d89d18fc7a08d37

Part 1: completeness

Review scope: Repair 2. `present` means specified, not proven at runtime. References below to `standard-window.md` mean `docs/framework/standard-window.md`.

1. **present:** Independent log-file and folder availability, including first use, deleted file with retained folder, and removed folder. The matrix names `window: the log items follow the file and the folder`. Evidence: `standard-window.md:58`, `:206`.

2. **present:** Folder-opening failure and recovery: a failed launch or vanished folder produces `Log_Folder_Failed` with a selectable path. Evidence: `standard-window.md:58`, `:205`.

3. **missing-in-scope:** The new folder-disabled explanation is false after deletion. `standard-window.md:64` and `:178` say the folder does not exist “yet” and describe its first creation, but `:206` explicitly requires that same explanation after removal. The availability check can pass while displaying misleading history.

4. **present:** Heading placement now has one density-dependent rule, with measured left offset, top offset and icon-to-title gap. Evidence: `standard-window.md:40`, `:223`.

5. **present:** Compact status-bar height now permits the required target size; the density check explicitly measures every acting segment at least 24 × 24. Evidence: `standard-window.md:42`, `:223`; requirement: `DESIGN.md:177`.

6. **present:** Indeterminate failure and partial completion now specify a full taskbar bar, error or paused state, activation clearing and running-task handoff. The named taskbar check covers these transitions. Evidence: `standard-window.md:165`, `:224`.

7. **present:** Persistence and read-back remain specified: geometry restores after reopening, missing-monitor recovery is defined, and shutdown routes failed settings writes to its notice. Evidence: `standard-window.md:46`, `:61`, `:222`. Repair 2 introduces no additional persisted value.

8. **missing-out-of-scope:** A working user experience, executable regression checks, rendered accessibility and behavioral parity remain downstream in Domain 01: `D01 T01 §7`, `D01 T02 §8`, and `D01 T03 §2` through `§6`. The document explicitly acknowledges this boundary at `standard-window.md:9`; the build obligation remains unchecked at `todo/01-framework/TODO-01-framework-core.md:220`.

9. **missing-out-of-scope:** Context help and the Donate decision remain settled dependencies: Domain 06, `D06 T01 §18`, and Domain 01, `D01 T03 §7`. Evidence: `standard-window.md:74`, `:82`.

Part 2: excellence

Counterparts: AutoIt `_StartCoreGui`, `_Logging_OpenDirectory`, and the ReBar English language pack; modern quality contract: `DESIGN.md`.

1. **in-scope:** The folder-disabled wording repeats the earlier missing-file wording defect for a newly distinguished resource. It does not accurately explain an ordinary deletion state, contrary to `DESIGN.md:201`. **Target:** one explanation truthful for both never-created and subsequently removed folders, with the existing availability check asserting its visible and UI Automation text in both states. Evidence: `standard-window.md:64`, `:178`, `:206`.

No additional Repair 2 shortfall in safety, recovery or speed was established. Runtime parity and modern accessibility compliance remain unproven until the downstream implementation runs.

Gap list

1. **missing-in-scope:** Correct the folder-disabled explanation so it remains truthful after folder deletion.
2. **missing-out-of-scope:** Domain 01 owns working controls, executable regression checks, rendered accessibility and behavioral parity evidence.
3. **missing-out-of-scope:** Domain 06 owns context help; Domain 01 owns the Donate verdict.
4. **in-scope:** Verify truthful folder-disabled wording through visible and UI Automation text for both first-use absence and subsequent deletion.

COMPLETION: gaps

## Writer note: completion gaps

- Planned: gaps 1 and 4 (a missing folder's reason true after deletion, read visibly and through UI Automation in both states), as the Repair 3 item in D01 T03 §1, reviewed on `docs/reviews/01-framework/D01-T03-s1-repair3.md`.
- Filed: D01 T01 §7, D01 T02 §8 and D01 T03 §2 to §6 (gap 2), and D06 T01 §18 and D01 T03 §7 (gap 3), already in the plan with those owners.
