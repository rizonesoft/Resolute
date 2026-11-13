## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T11:10:46Z
- Candidate: 5db77416e30f36bb8c1d7eb0933d31f98b0cad9a
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 5db77416e30f36bb8c1d7eb0933d31f98b0cad9a
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
- Run: 2026-11-13T11:15:57Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 5db77416e30f36bb8c1d7eb0933d31f98b0cad9a
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: d39a3f9696267029

### adversarial: needs-attention

1. **P3** `tools/refdata/refdata.py:611-612`: The leftover-file warning claims “the user it names no longer exists” before `DROP USER` runs. If that operation fails, the final message contradicts itself and incorrectly reassures the operator about credentials still belonging to an existing account. Reproduce using the held-file restore case with the server disconnected before cleanup: file removal and `DROP USER` both fail, yet the message still asserts the user is gone. Emit that assurance only after successful user removal, or omit it.

HIGHEST: P3
OVERALL: needs-attention

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T11:17:44Z
- Candidate: 9b920e03fd925d686e074b31a93869006a774d4d
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 5db77416e30f36bb8c1d7eb0933d31f98b0cad9a
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 35
- Digest: f6153be98e885cb4

The locked-file repair is implemented, but the restore/upgrade recovery experience still has gaps. Review was read-only; I inspected the regression and supplied evidence without rerunning the database-mutating self-test.

Part 1: completeness

1. **present:** Refuse missing, unreadable or unsuitable backups and existing destinations before loading. Evidence: `tools/refdata/refdata.py:557-572`; unreadable-backup regression at `:1062`.

2. **present:** Attempt credential-file removal, account removal and failed-database removal independently for the handled filesystem and SQL refusals. Evidence: `tools/refdata/refdata.py:608-621`. The locked-file regression at `:1066-1089`, with the supplied failing mutation, demonstrates the repaired behavior.

3. **present:** Preserve a successfully loaded database when file cleanup fails, and remove a failed load’s database. Evidence: `tools/refdata/refdata.py:600-623`. The regression reads back account counts and destination existence at `:1081-1089`.

4. **present:** Preserve the original load refusal, identify remaining resources, provide deletion instructions and return nonzero without a traceback for handled cleanup failures. Evidence: `tools/refdata/refdata.py:611-624` and `:1392-1394`.

5. **missing-in-scope, G1:** Report account removal truthfully. The file-removal message says the account no longer exists before `DROP USER` runs; if that operation fails, the final message contradicts itself. Evidence: `tools/refdata/refdata.py:611-616`. This is the settled P3, carried forward under the agreed disposition, not a request to reconsider it.

6. **missing-in-scope, G2:** Distinguish an upgraded copy that was loaded from one that passed upgrade verification. A successful restore followed by cleanup refusal escapes `cmd_upgrade` at `tools/refdata/refdata.py:671`, before the read-back comparison at `:675`. The retained database is described as restored, but the author is not told that upgrade verification never ran or how to recover safely. The locked-file regression exercises direct restore only (`:1073`).

7. **missing-in-scope, G3:** Identify an upgrade destination left behind when its removal fails. During comparison failure or mismatch, `cmd_upgrade` calls `DROP DATABASE` without preserving the original failure or adding destination-specific recovery instructions. A server outage during read-back can also prevent deletion, leaving only a generic connection refusal. Evidence: `tools/refdata/refdata.py:675-681`. This belongs to D00 T06 §1’s upgrade recovery behavior; it is not additional product scope.

Part 2: excellence

Counterpart: **none in `resolute_au3/`**. Behavioral parity is not applicable to this authoring-machine tooling. With `Fidelity: none`, the relevant modern-quality requirements are truthful outcomes and actionable refusals in `DESIGN.md:201` and `:204`.

1. **in-scope, G1:** Premature reassurance about credentials. **Target:** claim account removal only after successful removal; otherwise report that it remains or its state is unconfirmed. A failure-path regression must reject contradictory account-status messages.

2. **in-scope, G2:** An interrupted upgrade leaves an ambiguous retained copy. **Target:** every exit before comparison completion explicitly says the destination is unverified, names it, directs the author to keep using the unchanged source, and provides recovery instructions. Exercise upgrade with restore cleanup failure and verify those outcomes.

3. **in-scope, G3:** Upgrade rollback failure hides the actionable context. **Target:** retain the original comparison failure, name the destination whose removal could not be confirmed, provide its exact removal command, and exit 1 without a traceback. One regression for a connection failure during comparison and cleanup should prove this.

Gap list

1. **missing-in-scope / in-scope, G1:** Correct the premature account-removal assurance at `tools/refdata/refdata.py:611`; settled P3, retain the agreed disposition.
2. **missing-in-scope / in-scope, G2:** Explain and test recovery from a retained, unverified upgrade destination when restore cleanup fails at `tools/refdata/refdata.py:671`.
3. **missing-in-scope / in-scope, G3:** Preserve the original failure and identify the leftover destination when upgrade cleanup fails at `tools/refdata/refdata.py:677-680`.

COMPLETION: gaps

## Writer note: completion gaps

- Planned: G1 (round 1's P3, the premature account-removal wording), G2 (an upgrade's unverified copy after a restore cleanup refusal) and G3 (an upgrade rollback keeps its reason and names a copy it could not drop), as the three Repair 4 items in D00 T06 §1, reviewed on `docs/reviews/00-workspace/D00-T06-s1-repair4.md`.
- Not taken: a driven test of G3's drop-failure leg (needs the server to fail between the comparison and the drop; two unlikely conditions at once, a P3 by the test-cadence rule in AGENTS.md); the code path is built.
