## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T11:55:35Z
- Candidate: e1345a4777621acd69fb0716e116d289a2c56b22
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: e1345a4777621acd69fb0716e116d289a2c56b22
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 5
- Digest: 925e59b07b975597

1. **P2, plan, line 95:** “Every upgrade refusal” requires incorrect advice for existing refusal paths: a missing source cannot be said to retain every version, and a database already at the current revision needs no retry. Limit preservation and retry guidance to attempted upgrades of an existing older database. Require appropriate next steps for preliminary refusals, with a regression showing that an already-current database is not told to retry. The specified lossy, unverified and rollback tests would miss this error.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

## Writer note: plan findings

- Planned: retry guidance only for attempted upgrades, each preliminary refusal keeping its own next step, with an already-current case (P2), in the corrected first Repair 5 item.

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T12:02:50Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: e1345a4777621acd69fb0716e116d289a2c56b22
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 4ef9722b6d27bfa0

### adversarial: needs-attention

1. **P2, `tools/refdata/refdata.py:695`**: Attempted upgrades still omit preservation and retry guidance when loading the copy fails. Ordinary `Refused` exceptions escape unchanged, and `RestoreLeftovers(loaded=False)` is re-raised at line 700. Reproduce by upgrading an existing revision-1 database and losing the server connection during restore, or using the existing restricted-connection TLS rejection test. Neither path says the old database retains every version or supplies the upgrade retry command, contrary to Repair 5. An in-memory exception-injection probe confirmed both omissions without writes. Append the guidance to these attempted-copy failures while preserving their cleanup details.

HIGHEST: P2
OVERALL: needs-attention
