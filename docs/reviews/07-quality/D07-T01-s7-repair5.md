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
