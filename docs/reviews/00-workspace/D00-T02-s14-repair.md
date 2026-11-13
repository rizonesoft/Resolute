## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T04:59:29Z
- Candidate: 9c9abbe2927faad7544a629c56b8019d194b8fe1
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 9c9abbe2927faad7544a629c56b8019d194b8fe1
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
- Run: 2026-11-13T05:15:22Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 9c9abbe2927faad7544a629c56b8019d194b8fe1
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 8
- Digest: f05ab1a642055679

### adversarial: needs-attention

1. **P2: Cancelling cover startup leaves its always-on-top window running.** `scripts/capture-window.ps1:727-730`: `Start-Cover` starts the child but retains its process object locally until after the polling and sleep finish. Pressing Ctrl+C during that interval prevents assignment to `$script:cover`, so `Stop-Cover` cannot terminate it. The `before` call also occurs outside the cleanup `try`. Reproduce by running a foreground-target capture with `-DrillCoverAt before` and pressing Ctrl+C during cover startup. The capture stops, but the magenta window can remain over the desktop until its 60-second lifetime expires. Register ownership immediately after starting the child and protect startup with cleanup.

Read-only inspection; cancellation was not exercised live.

HIGHEST: P2
OVERALL: needs-attention

- Fixed: finding 1 (P2, a stop during cover startup left the cover running). `Start-Cover` records the cover's process in `$script:cover` the moment it starts, and the `before` cover starts inside the try whose finally ends it. Driven after the operator had been idle 120 s: the writer run in its own PowerShell instance with `-DrillCoverAt before`, stopped the moment the cover's process appeared, then the cover processes counted 4 s later: the fixed writer `cover processes left 4 s later: 0`; the writer at the previous commit, `1`.

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T05:17:26Z
- Effort: low
- Writer model: claude-opus-5-5
- Policy: 9c9abbe2927faad7544a629c56b8019d194b8fe1
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: 11cbe2995e136461

### consistency: approve

No findings in the requested lens. Read-only review; no tests or desktop drills executed.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T05:18:50Z
- Candidate: 951e0ad2a78b9bcf55a3d0743f43f4f388635caa
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 9c9abbe2927faad7544a629c56b8019d194b8fe1
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 26
- Digest: 561d500f1d38ef96

Read-only review of `951e0ad2`. Tests and desktop drills were inspected, not rerun; execution evidence below is recorded in the candidate.

Part 1: completeness

1. **present:** Refuse intersecting foreign windows before and after copying, before publication. Both refusal paths exit 3. Evidence: `scripts/capture-window.ps1:169`, `:739`, `:748`.
2. **present:** Accept adjacent, zero-area and same-process windows; exclude invisible and cloaked windows. Evidence: `scripts/capture-window.ps1:180`, `:477`. The real overlapping-then-adjacent window exercise, including unchanged rectangles, is recorded at `todo/00-workspace/TODO-02-test-backbone.md:774`.
3. **present:** An unreadable covering window produces a refusal naming its handle, available title/PID and failed inspection step. Evidence: `scripts/capture-window.ps1:144`, `:176`; regression assertion at `:485`.
4. **present:** A missing, unreadable, hidden or moved target refuses publication, with gone distinguished from unreadable. Evidence: `scripts/capture-window.ps1:191`; assertions at `:488` and `:492`.
5. **missing-in-scope:** Target inspection refusals omit the target’s handle and available title/PID. `Test-Target` returns only “the target window…”, and `Assert-Uncovered` adds no identity (`scripts/capture-window.ps1:196`, `:205`). Repair 1 explicitly requires the refusal to name the handle and available identity (`todo/00-workspace/TODO-02-test-backbone.md:773`). The target assertion at `scripts/capture-window.ps1:488` does not enforce this requirement.
6. **present:** Refusals preserve the previous capture pair; successful publication uses staged readback, replacement, rollback and next-run recovery. Evidence: `scripts/capture-window.ps1:287`, `:310`, `:330`; recorded byte-for-byte refusal checks at `todo/00-workspace/TODO-02-test-backbone.md:772`. These existing paths also handle file-write failures without publishing a knowingly mismatched pair.
7. **present:** Drill cancellation owns the cover process immediately and performs cleanup in `finally`; the hidden-target drill restores visibility. Evidence: `scripts/capture-window.ps1:726`, `:750`. Cancellation regression evidence is recorded in `docs/reviews/00-workspace/D00-T02-s14-repair.md:45`.
8. **present:** Regression evidence covers overlap, the second inspection, unreadable-window messages and adjacent-window success, including deliberately broken variants. Evidence: `todo/00-workspace/TODO-02-test-backbone.md:772`, `:773`, `:774`.

Controls, tooltips, keyboard focus, dialogs, persistent settings and system-repair undo are not applicable to this repository helper’s declared surface.

Part 2: excellence

Counterpart: **none**. AutoIt behavioral parity and product UI requirements for themes, accessibility and shared controls do not apply. `DESIGN.md:204` supplies the relevant refusal-quality principle.

1. **in-scope:** Target failure diagnostics are less identifiable than covering-window diagnostics. **Target:** every target inspection refusal includes its HWND, available title/PID and failed step, while retaining the gone/unreadable distinction. Extend the existing target regression case to fail when identity is omitted. Evidence: `scripts/capture-window.ps1:196`, `:205`, `:488`.

Gap list

1. **missing-in-scope; in-scope:** Include target identity in inspection refusals and enforce it in the existing regression case, as required by Repair 1 (`scripts/capture-window.ps1:196`; `todo/00-workspace/TODO-02-test-backbone.md:773`).

COMPLETION: gaps
