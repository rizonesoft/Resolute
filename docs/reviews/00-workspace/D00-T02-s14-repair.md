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
