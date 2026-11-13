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

## Round 3: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T11:51:15Z
- Effort: low
- Writer model: claude-opus-5-5
- Policy: 938d3b0ec43659bb07f0e094520cfb5bdf258a42
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: quality
- Lines: 6
- Digest: 8caecad9bb56db71

### quality: approve

No actionable findings. Review was static; the database self-test was not run because it writes files and restarts the server.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T11:54:06Z
- Candidate: 06f166eef76bcc0e5efe94080413862390e7379f
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 938d3b0ec43659bb07f0e094520cfb5bdf258a42
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 36
- Digest: b17747f572f4ed0b

The repair paths are implemented, but recovery guidance and documentation still leave two gaps. Review was read-only; the supplied database tests were inspected, not rerun.

Part 1: completeness

1. **present:** Reject unreadable backups and occupied destinations before loading. Evidence: `tools/refdata/refdata.py:567`, `:570`, `:574`; unreadable-backup regression at `:1140` and competing-author regression at `:1263`.

2. **present:** Attempt each cleanup independently, preserve the original failure, and distinguish confirmed account removal from unknown removal. Evidence: `tools/refdata/refdata.py:614`, `:623`, `:631`, `:638`; held-file and outage checks at `:1164` and `:1194`.

3. **present:** Preserve a successful restore and remove a failed restore’s database, with actionable SQL when removal cannot be confirmed. Evidence: `tools/refdata/refdata.py:633`; database-existence and account readbacks at `:1159` and `:1164`.

4. **present:** Identify a loaded but unverified upgrade copy without treating another author’s database as its own. Evidence: `RestoreLeftovers` at `tools/refdata/refdata.py:64` and handling at `:694`; unverified-copy and competing-author regressions at `:1248` and `:1263`.

5. **present:** Preserve comparison failures through rollback and identify a copy whose removal is unconfirmed. Evidence: `tools/refdata/refdata.py:702`; regression at `:1293` checks successful rollback, outage leftovers, execution of the advertised removal command, and absence afterward.

6. **present:** Check persisted data and source preservation. Evidence: upgrade readback at `tools/refdata/refdata.py:646`, unchanged-source assertions at `:1251` and `:1308`, and restart readback at `:1490`. These checks detect data loss rather than merely accepting successful exit codes.

7. **present:** Return a named, nonzero refusal for the handled cleanup failures and preserve unrelated restore accounts. Evidence: `tools/refdata/refdata.py:1605`, baseline account inventory at `:780`, and cleanup restricted to the refusal’s named account at `:1190`. The supplied planted-account run supports preservation.

8. **missing-in-scope, G1:** Give an executable recovery path after failed upgrade. `tools/refdata/refdata.py:685` tells authors to “keep working” in the old database, but `require_current` at `:223` rejects that revision; proposing, reviewing and listing call it at `:314`, `:321` and `:332`. The regression at `:1303` explicitly expects the old database to be refused. Explain whether to resolve the failure and retry the upgrade or use a compatible earlier client. Current tests verify source preservation, not that the recommended next action works.

9. **missing-in-scope, G2:** Document partial completion and uncertain cleanup accurately. `docs/reference-data.md:30` guarantees removal of the restore account and option file; `:103` describes dropping the failed upgrade copy without the failure qualification; `:107` says server failures write nothing. The candidate specifically handles outages after writes and unsuccessful cleanup. These statements contradict its demonstrated behavior.

Part 2: excellence

Counterpart: **none in `resolute_au3/` for this authoring workflow**. Behavioral parity is not applicable. With `Fidelity: none`, the relevant quality requirements are truthful outcomes and actionable refusals in `DESIGN.md:201` and `:204`.

1. **in-scope, G1:** Recovery advice leads back to a revision refusal. **Target:** every failed-upgrade message recommends a next action supported by the named client; a regression verifies that guidance without weakening the schema-revision guard.

2. **in-scope, G2:** Documentation overstates cleanup and failure atomicity. **Target:** distinguish failures before writes from partial completion, describe unconfirmed removal and unverified copies, and make no unconditional deletion guarantee where cleanup can fail.

Gap list

1. **missing-in-scope / in-scope, G1:** Replace the unusable “keep working” instruction with supported recovery guidance and verify it (`tools/refdata/refdata.py:685`).
2. **missing-in-scope / in-scope, G2:** Correct cleanup and no-write guarantees to match partial-failure behavior (`docs/reference-data.md:30`, `:103`, `:107`).

COMPLETION: gaps

## Writer note: completion gaps

- Planned: G1 (a failed upgrade's next step) and G2 (the page's cleanup and no-write promises), as the two Repair 5 items in D00 T06 §1, reviewed on `docs/reviews/00-workspace/D00-T06-s1-repair5.md`.
