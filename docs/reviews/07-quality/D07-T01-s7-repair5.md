## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T00:13:08Z
- Candidate: 90bc5732fd285d39a3c1423d85f76de9ed877c8e
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 90bc5732fd285d39a3c1423d85f76de9ed877c8e
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 5
- Digest: 946871c19dd36c79

1. **P2, plan, lines 297, 302 and 375:** Interactive logon and 120 seconds without input do not establish that the desktop is unlocked. The unattended task can launch while the operator remains logged on with Windows locked. Neither the wrapper nor the consumed smoke admission checks this, although `tools/nightly.ps1:229` explicitly skips locked-session captures because they cannot prove visible windows. Require a named refusal before launching tools when the desktop is locked or its availability cannot be established. Add one admission test proving no tool launches in that state, and require an unlocked session for the checkpoint.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

- Planned: finding 1 (a locked desktop is not refused), as a dated correction in the section that states the limit and the conditions of the quoted runs, and as the item "Refuse a locked desktop" of D07 T01 §10, because the refusal changes what the registered task executes and so needs the consent prompt that section already owes, in the section-correction commit that follows this record
- Filed: D07 T01 §10 (refuse a locked desktop before any tool is launched)

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T00:15:21Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 90bc5732fd285d39a3c1423d85f76de9ed877c8e
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 8
- Digest: b0720c283af06cd4

### adversarial: approve

No actionable findings in the candidate diff. The injected move preserves production behavior and exercises rollback after the second rename fails.

Review was read-only; I did not rerun `-SelfTest`, which creates files and a scheduled task.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T00:16:54Z
- Candidate: 450d377732c65f500461d5dc861eb85b14c680b3
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 90bc5732fd285d39a3c1423d85f76de9ed877c8e
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 22
- Digest: bebc5d6a32e1e855

Part 1: completeness

Complete for the candidate’s stated scope. This was a read-only review; tests were inspected, not rerun because they create files and scheduled tasks. The already-filed §§10 and 11 work is excluded as requested.

1. **present**: Operator commands and usage remain available, including registration, replacement, readiness, run, readback and removal. `tools/elevated-smoke.ps1:3`, `tools/elevated-smoke.ps1:1227`. No GUI controls, focus order, tooltips or user settings apply.
2. **present**: Runtime and pinned hashes use the same replacement function, so the repaired test covers the shared behavior rather than a private runtime implementation. `tools/elevated-smoke.ps1:374`, `tools/elevated-smoke.ps1:974`.
3. **present**: A refused second rename restores the previous copy to the live path and propagates failure. The test verifies the old contents, absence of `.old`, preservation of the staged replacement and an exception. `tools/elevated-smoke.ps1:384`, `tools/elevated-smoke.ps1:640`.
4. **present**: Preparation failures, including copy/write failures, occur inside the registration transaction. Existing live files remain available until switching; subsequent failures invoke rollback. `tools/elevated-smoke.ps1:907`, `tools/elevated-smoke.ps1:960`, `tools/elevated-smoke.ps1:986`.
5. **present**: Rollback restores the task, hashes, runtime and applicable directory permissions. Independent restore steps continue after another fails, and incomplete restoration is reported. `tools/elevated-smoke.ps1:452`, `tools/elevated-smoke.ps1:990`.
6. **present**: Persistence includes staged hash readback, readiness before commit, and fresh readiness checks on subsequent runs. `tools/elevated-smoke.ps1:968`, `tools/elevated-smoke.ps1:981`, `tools/elevated-smoke.ps1:1120`.
7. **present**: Successful replacement removes retained copies; a cleanup refusal becomes a named note without undoing the committed registration. `tools/elevated-smoke.ps1:404`, `tools/elevated-smoke.ps1:1034`; regression case at `tools/elevated-smoke.ps1:653`.
8. **present**: Regression evidence demonstrates failure sensitivity: 51 passing checks, followed by exit 1 and the named failed assertion when restoration is removed. `todo/07-quality/TODO-01-quality-bar.md:375`. Surrounding transaction tests compare restored state after each failure point. `tools/elevated-smoke.ps1:706`.

Part 2: excellence

Counterpart: **none**, repository tooling with no AutoIt behavioral counterpart or rendered product surface. AutoIt parity, DPI, themes and screen-reader layout are not applicable.

No additional concrete shortfalls found within this candidate. Its guarantee is restoration after a caught rename refusal, not continuous availability across process termination; that separate limitation already belongs to §11. The other explicitly excluded operational limitations remain owned by §10.

Gap list: empty for this candidate.

COMPLETION: complete
