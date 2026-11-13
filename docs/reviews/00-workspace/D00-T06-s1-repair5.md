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

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T12:10:43Z
- Effort: low
- Writer model: claude-opus-5-5
- Policy: e1345a4777621acd69fb0716e116d289a2c56b22
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: a39eeb8a7e429caa

### consistency: needs-attention

1. **P3, `tools/refdata/refdata.py:681`**: The new “work in it” advice also applies to a database newer than this checkout because the condition uses `>=`. This contradicts `require_current()` at lines 228-229, which refuses that database and requires updating the checkout. Reproduce with an older authoring checkout connected to a shared database upgraded by another author: `upgrade` recommends working in it, but authoring commands refuse. Limit this advice to equal revisions and use the existing update-checkout guidance for newer revisions.

HIGHEST: P3
OVERALL: needs-attention

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T12:12:17Z
- Candidate: d4928203e60219fde450ee99c6b0c20800117982
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: e1345a4777621acd69fb0716e116d289a2c56b22
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 32
- Digest: e14db2fbbd9e39dd

Read-only review. I inspected the candidate and regression assertions; I did not rerun the database self-test because it writes files and restarts the server.

Part 1: completeness

1. **present:** Attempted backup, load and comparison failures retain their cause and append source-preservation and retry guidance. Evidence: `tools/refdata/refdata.py:686`, `:696`, `:703`, `:707`. Lossy, unverified, race, rollback and TLS assertions cover these paths at `:1236`, `:1264`, `:1278`, `:1309`, `:1360`.

2. **present:** Preliminary refusals distinguish missing databases, current revisions and occupied destinations. Evidence: `tools/refdata/refdata.py:677`, `:680`, `:683`; the current-revision regression at `:1247` checks that retry advice is absent. The newer-revision exception is listed below.

3. **present:** Recovery distinguishes unverified copies, uncertain removal and another author’s destination. Evidence: `tools/refdata/refdata.py:699`, `:701`, `:713`; regressions at `:1264`, `:1278`, `:1309` check ownership, leftovers and removal readback.

4. **present:** Source preservation and successful recovery have persisted-data checks. Evidence: unchanged-source comparison at `tools/refdata/refdata.py:1238`, successful subsequent upgrade and version readback at `:1316`, and restart readback at `:1507`.

5. **present:** Documentation qualifies cleanup failures and distinguishes connection failures before writes from partial completion. Evidence: `docs/reference-data.md:30`, `:103`, `:107`, consistent with cleanup handling at `tools/refdata/refdata.py:617`.

6. **missing-in-scope, G1:** Retry guidance loses an explicitly selected connection. `tools/refdata/refdata.py:687` omits `--options`; following it selects `client.cnf` or `local.cnf` instead (`:84`). An author using the documented custom option file can therefore retry against a different server or with different TLS settings. The successful-retry test manually supplies `--options` at `:1316`, so it does not prove the displayed instruction works for that supported usage.

7. **missing-in-scope, G2, settled P3:** A newer database is told to “work in it” by `tools/refdata/refdata.py:680`, although `require_current` refuses it and requires updating the checkout at `:228`. This remains incomplete in this candidate; retain the agreed next-repair-or-file disposition.

Part 2: excellence

Counterpart: none, authoring-machine tooling. AutoIt behavioral parity is not applicable. The remaining weaknesses concern actionable refusals under `DESIGN.md:201` and `:204`; no concrete speed shortfall was established.

1. **in-scope, G1:** Recovery instructions can change the connection context. **Target:** preserve the selected option-file path, safely quoted without exposing its contents, or explicitly instruct authors to retain their original `--options`. One regression must verify that the advised retry retains that connection.

2. **in-scope, G2, settled P3:** “Work in it” contradicts the next command’s revision refusal. **Target:** only equal revisions receive that advice; newer revisions direct the author to update the checkout, with one regression covering that distinction.

Gap list

1. **missing-in-scope / in-scope, G1:** Preserve the original connection in retry guidance and verify that guidance, `tools/refdata/refdata.py:687`.
2. **missing-in-scope / in-scope, G2, settled P3:** Give newer-schema databases the checkout-update instruction, under the agreed disposition, `tools/refdata/refdata.py:680`.

COMPLETION: gaps

## Writer note: completion gaps

- Planned: G1 (the retry command keeps the option file) and G2 (round 2's P3, a newer database told to update the checkout), as the two Repair 6 items in D00 T06 §1, reviewed on `docs/reviews/00-workspace/D00-T06-s1-repair6.md`.
