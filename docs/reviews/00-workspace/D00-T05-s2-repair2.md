## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T17:35:05Z
- Candidate: 2bce2d369181f204bfd50a4b9c12b0d8a437f915
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 2bce2d369181f204bfd50a4b9c12b0d8a437f915
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

## Writer note: built

- Planned: both Repair items are built in `README.md` (the diagram laid out left to right with `extensions/ToolName/`; the bootstrap row), and the refusal line in `scripts/bootstrap.ps1` that made the same claim is corrected at its source. The diagram's two captures are retaken at this commit before the round.

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T17:47:04Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 2bce2d369181f204bfd50a4b9c12b0d8a437f915
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 5c7745bb7af827ed

### adversarial: needs-attention

1. **P3, `scripts/bootstrap.ps1:211`:** The hash-refusal path still ends with `reskit/ is unchanged.`, contradicting the corrected message at line 205 when earlier components were installed. Reproduce in a disposable checkout with an empty `reskit/`: let the first component install successfully and give the second component an incorrect SHA256 pin, then run `pwsh scripts/bootstrap.ps1`. The refusal reports both that an earlier installation remains and that `reskit/` is unchanged. Remove the latter claim or scope it to the refused component.

HIGHEST: P3
OVERALL: needs-attention

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T17:49:06Z
- Candidate: cef309308f1cb912394e52302eafdd57ead089b2
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 2bce2d369181f204bfd50a4b9c12b0d8a437f915
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 25
- Digest: b57b4d98b7fe2d83

The two-item repair is complete. No new in-scope shortfall found. Preferences parity is not established by this README repair.

**Part 1: completeness**

1. **present:** An unambiguous tool directory and correct layer relationships. `README.md:141` names `extensions/ToolName/`; `README.md:146` restricts the repair-contract edge to repair tools.
2. **present:** Complete, readable diagram captures in both themes. I inspected both supplied PNGs: all five nodes and their labels are visible. Their hashes match the `.txt` sidecars. The captured revision’s README is unchanged in the candidate.
3. **present:** Accurate hash-refusal reporting. `scripts/bootstrap.ps1:205` identifies the refused component and counts earlier installations retained; `:211` limits the no-write statement to that component. Refusal exits before extraction and installation (`:212`, `:215`, `:233`).
4. **present:** Recovery guidance consistent with persisted installation state. `README.md:186` explains partial installation and retry; `scripts/bootstrap.ps1:154` checks existing pinned versions, `:158` skips them, and `:237` records a successful installation’s version.
5. **present:** Proportionate verification of this repair. Both README checks passed live. The captures prove rendering; reading the loop verifies the corrected refusal wording. No driven refusal was performed. The supplied parser result was not independently reproduced because this session’s PowerShell language restrictions blocked the parser API.
6. **present:** Existing document persistence and regression coverage remain intact. `scripts/readme-blocks.py:275` reads staged bytes back before replacement; `:394` injects replacement failure and `:406` checks preservation. These tests were inspected, not rerun.
7. **missing-out-of-scope:** Continuous verification that the README quick start executes verbatim remains owned by workspace section `D00 T05 §3`, already recorded at `docs/reviews/00-workspace/D00-T05-s2-repair.md:134`.
8. **missing-out-of-scope:** Working Preferences controls, Save/Cancel behavior, refused-write recovery, persisted read-back, reopening tests and AutoIt parity proof are outside this candidate. Framework sections `D01 T01 §2` and `§7` own them, consuming `D01 T03`’s specifications. This boundary is recorded at `docs/reviews/00-workspace/D00-T05-s2-repair.md:135`.

**Part 2: excellence**

Counterpart: the repository-facing repair contract in `D00 T05 §2`. `_ShowPreferencesDlg` is the counterpart for the separate Preferences implementation. The repaired diagram accurately describes the shared ownership required by `DESIGN.md`; it does not prove dialog compliance.

No additional concrete safety, recovery, wording or speed shortfall found within this repair.

**Gap list**

1. **missing-out-of-scope:** Run and observe the README quick-start sequence verbatim in CI; owner `D00 T05 §3`.
2. **missing-out-of-scope:** Deliver Preferences behavior, persistence, refusal recovery and driven parity/design proof; owners `D01 T01 §2` and `§7`.

COMPLETION: gaps

## Writer note: completion gaps

- Filed: D00 T05 §3 (gap 1, the quick start run verbatim on CI), already in the plan with that owner.
- Not taken: gap 2 (the Preferences dialog's behaviour and persistence). It is no part of this section, which is the repository's README; D01 T01 §2 and §7 own it with D01 T03's specifications, already in the plan.
