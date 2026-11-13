## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T13:59:05Z
- Candidate: e06603bae7cb5de0613e0e47a59c719b6c7b2966
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: e06603bae7cb5de0613e0e47a59c719b6c7b2966
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 5
- Digest: ac2447c3820a0b84

1. **P2, line 90:** Repair 3 promises automatic folder recreation on the next log write, but its check only reads tooltip and UI Automation text. `D01 T01 §3` specifies no recreation check, so a writer that creates the directory only at startup could pass. Either use the factual wording “The log folder does not exist.” or assign recreation and its verification to `D01 T01 §3`, covering deletion followed by another write and a creation failure such as denied permission.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

## Writer note: plan findings

- Planned: the factual wording "The log folder does not exist." in place of a promise of recreation no section builds (P2), in the corrected Repair 3 item.

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T14:00:49Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: e06603bae7cb5de0613e0e47a59c719b6c7b2966
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 6f707e438756a41f

### adversarial: approve

No actionable findings within Repair 3’s scope.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T14:02:50Z
- Candidate: 5f76b4aa51f6868ccd8e1b72062f0553fc4d9069
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: e06603bae7cb5de0613e0e47a59c719b6c7b2966
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 23
- Digest: 5fa81115b4b80862

Part 1: completeness

Scope: Repair 3 only. `present` means specified in the deliverable, not demonstrated in a running window. References to `standard-window.md` mean `docs/framework/standard-window.md`.

1. **present:** A truthful explanation for both never-created and deleted folders: “The log folder does not exist.” The behavior rule and pack-key table agree. Evidence: `standard-window.md:64`, `:178`.
2. **present:** Visible and accessible refusal: disabled items remain reachable by arrow keys, show their reason on hover and keyboard focus, expose that reason through UI Automation, and cannot be invoked. Evidence: `standard-window.md:64`, `:205`.
3. **present:** Independent file and folder availability, refreshed when the menu opens. Deleting only the file leaves its folder accessible. Evidence: `standard-window.md:58`, `:207`.
4. **present:** Failure and recovery when opening an available folder fails: `Log_Folder_Failed` names the selectable path. Evidence: `standard-window.md:58`, `:206`.
5. **present:** A regression-check contract that would reject the previous wording: `window: the log items follow the file and the folder` requires the exact tooltip and UI Automation text before the first log and after folder deletion. Evidence: `standard-window.md:199`, `:207`.
6. **present:** Persistence remains covered by shutdown and geometry read-back checks. Repair 3 adds no persisted state; availability is derived from the filesystem. Evidence: `standard-window.md:207`, `:209`, `:222`.
7. **missing-out-of-scope:** The working controls and executable checks remain downstream in Domain 01, `D01 T01 §7` and `D01 T02 §8`. Consequently, actual tooltip rendering, UI Automation output and runtime behavioral parity are not yet proven. Evidence: `standard-window.md:9`; `todo/01-framework/TODO-01-framework-core.md:220`.

Part 2: excellence

Counterparts: AutoIt `_StartCoreGui` (`ReBar.au3:532-534`, `:550-551`), `_Logging_OpenDirectory` (`Logging.au3:245-260`), and the ReBar English pack (`en.lng:103-105`). Modern quality contract: `DESIGN.md`, particularly accessibility and wording at `:172-175`, `:201-206`.

No concrete Repair 3 specification shortfall remains in wording, safety, recovery or speed. The correction meets its documented acceptance criteria. Runtime parity and modern accessibility compliance remain unproven under item 7, rather than established by this documentation change.

Gap list

1. **missing-out-of-scope:** Domain 01, `D01 T01 §7` and `D01 T02 §8`: implement and run the specified checks, proving exact visible and UI Automation wording in both absence states, disabled-action refusal and folder-opening behavior.

COMPLETION: gaps

## Writer note: completion gaps

- Filed: D01 T01 §7 and D01 T02 §8 (gap 1, implementing and running the specified checks), already in the plan with those owners: `D01 T01 §7` carries the item that proves the matrix row by row, and `D01 T02 §8` the menu's disabled-reason items.
