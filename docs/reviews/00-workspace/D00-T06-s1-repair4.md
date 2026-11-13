## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T11:19:19Z
- Candidate: 938d3b0ec43659bb07f0e094520cfb5bdf258a42
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 938d3b0ec43659bb07f0e094520cfb5bdf258a42
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 7
- Digest: d979702dbf600b74

1. **P2, line 94:** The drop-failure test is excluded on an incorrect premise. One server outage during comparison can also prevent the subsequent `DROP DATABASE`; these are not two independent unlikely conditions. The proposed test exercises only successful rollback and would pass with the existing unguarded drop. Add one regression exercising comparison failure followed by cleanup failure, asserting preservation of the original reason, the destination name, its removal command, and a named refusal without traceback. Prove it fails with the old rollback handling.

2. **P3, line 92:** “Otherwise … the user still exists” substitutes another unsupported certainty. A connection loss or timeout can leave the result of `DROP USER` unconfirmed. Require “removal could not be confirmed” unless readback establishes existence, and adjust the message-builder check accordingly. Apply the same distinction to line 94’s “copy left behind” when database removal is unconfirmed.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

## Writer note: plan findings

- Planned: the rollback drop failure is tested through one real outage, the private server stopped inside the comparison (P2), in the corrected third Repair 4 item; the earlier "not taken" on the third repair's record is withdrawn.
- Planned: a failed drop is reported as unconfirmed, never as present or gone (P3), in the first and third Repair 4 items.

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T11:35:29Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 938d3b0ec43659bb07f0e094520cfb5bdf258a42
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 91057e86d1d27a22

### adversarial: needs-attention

1. **P1**: `tools/refdata/refdata.py:691` treats destination existence as proof that this upgrade created it, then recommends deleting it. On the documented shared-server path, run two `upgrade --database refdata --to refdata_r2` commands concurrently. Both can pass the initial existence check; while one backs up, the other creates the destination. The losing restore correctly refuses the existing database, but the new handler appends `drop the copy with: DROP DATABASE IF EXISTS refdata_r2;` (with SQL backticks). Following that advice deletes the other author's database. Reproduced without writes using the actual restore existence guard and mocked existence results. Carry explicit creation and load state from restore; existence alone cannot authorize cleanup advice.

HIGHEST: P1
OVERALL: needs-attention

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T11:45:48Z
- Effort: low
- Writer model: claude-opus-5-5
- Policy: 938d3b0ec43659bb07f0e094520cfb5bdf258a42
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: bbd9f08d4b67acb6

### consistency: needs-attention

1. **P2**: `tools/refdata/refdata.py:1178` deletes every account matching `refdata_restore_%`, rather than only the account created by this self-test. This contradicts the documented isolation of the self-test and `cmd_restore`’s per-restore ownership. Reproduction: run the documented `--self-test` against a private server containing a restore account left by an earlier interrupted restore; the outage case deletes that unrelated account too. Concurrent restores can also lose their accounts. Capture this case’s exact account and host and remove only that account. This finding is from code inspection; no destructive reproduction was run.

HIGHEST: P2
OVERALL: needs-attention
