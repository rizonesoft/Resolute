## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T01:29:07Z
- Candidate: 6a80b66a6537fb139b5e2407b9b0f8fa3f4a071c
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 6a80b66a6537fb139b5e2407b9b0f8fa3f4a071c
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 5
- Digest: 5f501c6025ef7e80

1. **P2, plan: line 496** (`todo/07-quality/TODO-01-quality-bar.md`): The busy refusal must reach the operator’s original `-Register` process. At this candidate, `Invoke-RegisterElevated` prints it only with `Write-Host`; the consent-launched child exits, and its parent reads `register-log.txt`, then reports only a generic exit-code failure. The proposed direct sandbox assertions can pass while that normal registration route loses the explanation and retry instruction. Require the registration refusal to use the parent-readable reporting channel, and one test proving that the parent receives it.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

- Planned: finding 1 (the registration's busy refusal never reached the operator's `-Register`), every elevated refusal through `Write-Registration` and the parent's log read through `Read-RegistrationLog`, with a case that reads the busy refusal back from the log, in the section-correction commit that follows this record

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T01:35:29Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 6a80b66a6537fb139b5e2407b9b0f8fa3f4a071c
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 5573b1a6756f23e2

### adversarial: advisory

1. **P3**, `tools/elevated-smoke.ps1:1272`: First-registration refusals can still disappear with the elevated console. Reproduction: on a machine without `C:\ProgramData\Resolute\ElevatedSmoke`, run `-Register` from a standard account and supply another administrator’s credentials. `Write-Registration` skips persistence when that directory is absent (line 1151), so `Read-RegistrationLog` returns nothing. The caller receives only the generic exit-code refusal, losing the explanation and remedy. This is a diagnostic gap; registration still refuses safely. Source-traced, not executed.

HIGHEST: P3
OVERALL: approve

## Writer note: settled

- Filed: D07 T01 §10 (round 1's P3: a refusal the elevated copy gives before the protected directory exists, such as consent given as another account on a first registration, is not kept for `-Register` to read; it belongs to that section's console-window item, whose registration copy runs hidden and "reads its outcome from a file", and is now named there)

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T01:38:11Z
- Candidate: 494c9163a521c41922f1ac7991dc361734163062
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 6a80b66a6537fb139b5e2407b9b0f8fa3f4a071c
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 27
- Digest: d855b472d3cb5eba

Part 1: completeness

1. **present:** One actionable busy message identifies the refused operation, explains that another elevated smoke operation holds the lock, and tells the operator to retry. Evidence: `tools/elevated-smoke.ps1:1214`, with callers at lines 1248, 1557 and 1652.

2. **present:** Contention refuses immediately, before entering the registration transaction, run or removal. Evidence: `tools/elevated-smoke.ps1:1235`; refusal and unchanged-state assertions at lines 961, 986 and 1029.

3. **present:** With an existing, writable registration directory, the elevated copy records its refusal and the original window prints it. Evidence: `tools/elevated-smoke.ps1:1140`, `:1147`, `:1502`, `:1510`; readback assertion at line 963.

4. **missing-in-scope (G1):** Refusal delivery still depends on the registration directory already existing. `Write-Registration` silently skips persistence when it is absent (`tools/elevated-smoke.ps1:1151`). On a first registration, missing pinned Python or consent under another account refuses before directory creation (`:1272`, `:1277`, `:1316`). The originating window consequently receives only the generic exit-code message (`:1512`), losing the reason and remedy. The section explicitly includes these refusals (`todo/07-quality/TODO-01-quality-bar.md:496`). The held-lock test uses an existing registration and does not catch this (`tools/elevated-smoke.ps1:930`, `:952`).

5. **present:** Declining elevation or failing to start the elevated process produces an explanation in the originating window and returns nonzero. Evidence: `tools/elevated-smoke.ps1:1503`.

6. **present:** Regression coverage checks shared wording, lock refusal without changing registration state, and log readback. Commit `494c9163` records 75 passing self-tests and a failing console-only mutation. I inspected that evidence; I did not rerun the self-test because it creates files and a scheduled task.

No additional controls, focus order, settings, product styling or undo surface applies to this diagnostic-only change. The refused operation does not enter its mutation body.

Part 2: excellence

Counterpart: **none**, as declared. AutoIt parity and product DPI/theme requirements are not applicable to this repository script.

1. **in-scope (G1):** Feedback is incomplete on first-registration refusals. The generic exit-code result falls below the actionable-refusal principle in `DESIGN.md:204`. **Target:** the originating window displays the actual refusal and remedy even when the registration directory does not exist, while preserving nonzero exit and leaving registration state unchanged. One regression covering an early refusal with no directory should fail against this candidate.

Gap list

1. **missing-in-scope / in-scope (G1):** Deliver early registration refusals to the originating window without depending on an existing registration directory; verify that behavior with one regression case.

COMPLETION: gaps

- Implemented: gap 1 (an early refusal on a first registration reached `-Register` as a bare exit code), on the repair record `docs/reviews/07-quality/D07-T01-s11-repair3.md`; the filing in D07 T01 §10 above is withdrawn from that section in the same commit
