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
