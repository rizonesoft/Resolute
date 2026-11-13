## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T09:32:50Z
- Candidate: 50e31cd49d8c663276252bd13cda82d72bd21e05
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 50e31cd49d8c663276252bd13cda82d72bd21e05
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 11
- Digest: 312bff5f5b447717

1. **P1, line 77: The digest proof permits a race-prone implementation.** A client-side digest check followed by `rd_review` would pass the specified sequential test, but another author could edit between those operations. Require the displayed changes and digest to describe the same snapshot, and validate the digest inside the database transaction that locks and approves the version. Add a controlled concurrent-edit test proving unseen contents cannot be approved.

2. **P1, lines 77-78: Existing databases have no upgrade path.** These repairs change stored procedures and changelog storage, but `init` refuses existing databases and the checkpoint creates only fresh ones. Add a documented, data-preserving upgrade or backup-and-restore procedure, with recovery instructions and persisted readback. Test it against the candidate’s schema containing stamped and proposed versions. Explicitly identify historical edit contents that were already overwritten as unavailable.

3. **P2, line 81: Staging protects future initialization but does not handle an existing partial data directory.** The candidate can already leave that directory after interruption. Require detection and a named, actionable refusal or safe recovery without deleting established data. Add a drill starting with the previous script’s interrupted state; the proposed fresh-home drill alone does not prove this.

4. **P2, line 82: The tests omit locked-file replacement.** An unwritable destination can fail before dumping begins, leaving the later `os.replace` failure untested. Add a Windows drill with an existing backup locked against replacement. Require a named refusal without a traceback, byte-identical preservation of the previous backup, and explicit handling of the temporary dump.

HIGHEST: P1
PLAN: gaps
OVERALL: needs-attention

## Writer note: plan findings

- Planned: the digest is compared inside the locking transaction, with a concurrent-edit case (finding 1) in the corrected Repair 1 digest item.
- Planned: an upgrade that preserves every version, with a schema revision and the overwritten contents named as not recorded (finding 2), as a new Repair 1 item.
- Planned: an unmarked data folder from the previous script is adopted when it answers and otherwise refused by name, nothing deleted (finding 3), in the Repair 1 first-start item.
- Planned: a backup over an existing locked backup, the earlier one byte-identical and no `.partial` left (finding 4), in the Repair 1 file-error item.

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T10:03:55Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 50e31cd49d8c663276252bd13cda82d72bd21e05
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 486dc35ef349dbdc

### adversarial: needs-attention

1. **P2**: `tools/refdata/server.ps1:376` publishes the initialized data folder before writing `local.cnf`, but retries cannot recover if interrupted between those operations. Reproduce in an isolated `-HomeDir`: interrupt the first `-Start` after `Move-Item` completes and before line 378 writes the option file, then run `-Start` again. Both `data` and `data.initialized` exist, so initialization is skipped. `Complete-Credentials` then attempts passwordless authentication through the missing `local.cnf` at line 315 and refuses. Subsequent retries repeat the failure. Complete the bootstrap option file before publishing the data directory, or explicitly recover this pending-credentials state. This finding is based on static control-flow inspection; no files were modified or interruption drill run.

HIGHEST: P2
OVERALL: needs-attention

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T10:09:44Z
- Effort: low
- Writer model: claude-opus-5-5
- Policy: 50e31cd49d8c663276252bd13cda82d72bd21e05
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: ee7d79fddf582281

### consistency: approve

No actionable consistency findings in the Repair 1 changes. Review was static; no database or server drills were run.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T10:12:30Z
- Candidate: 0a294e37366f8f1387a99df961fab744c0cd7f8a
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 50e31cd49d8c663276252bd13cda82d72bd21e05
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 52
- Digest: c6f5db52caca36cd

The candidate still has gaps in failure handling and shared-server recovery. I inspected the committed candidate and ran an in-memory readback probe. No files were modified; database tests and server drills were not rerun.

**Part 1: completeness**

1. **present:** Authoring-only installation, connection configuration and server lifecycle. Evidence: `tools/refdata/server.ps1:128`, `:337`, `:447`, `:456`; installation and occupied-port checkpoint in `todo/00-workspace/TODO-06-reference-data.md:88`.

2. **present:** Transactional proposals, stable keys, review separation, freezing, reopening and stamping. Evidence: `tools/refdata/refdata.py:264`, `:299`; database procedures in `data/refdata/schema.sql`. The recorded self-test covers workflow refusals and rollback.

3. **present:** Approval bound to inspected contents, including concurrent edits. Inspection uses one snapshot at `tools/refdata/refdata.py:358`; comparison occurs under the version lock in `data/refdata/schema.sql:239`. Sequential, concurrent and mutation evidence is recorded at `todo/00-workspace/TODO-06-reference-data.md:79`.

4. **present:** Intermediate edit contents retained and readable. Evidence: `data/refdata/schema.sql:84`, `tools/refdata/refdata.py:396`. The repeated-rewording test and mutation failure are recorded at `todo/00-workspace/TODO-06-reference-data.md:80`.

5. **present:** Malformed proposal shapes refused before SQL execution. Evidence: `tools/refdata/refdata.py:229`; eight cases and their mutation failures at `todo/00-workspace/TODO-06-reference-data.md:81`.

6. **present:** Entry keys, meanings and sources distinguish literal `NULL` from SQL NULL in `show`, `changes` and `history`. Evidence: `tools/refdata/refdata.py:333`, `:358`, `:396`; regression evidence at `todo/00-workspace/TODO-06-reference-data.md:82`.

7. **missing-in-scope, G1:** The readback correction is incomplete in `list`. Its dataset name and author remain unmarked (`tools/refdata/refdata.py:313`), while `_unescape` converts literal `NULL` to `None` (`:104`). An in-memory probe produced `None v1: proposed, author None` from those literal values. The new regression covers entries, not these listing fields.

8. **present:** Interrupted initialization recovery, legacy-folder refusal/adoption and cleanup after process-record failure. Evidence: `tools/refdata/server.ps1:355`, `:385`, `:397`. Comparative drills, including interruption immediately after publication, are recorded at `todo/00-workspace/TODO-06-reference-data.md:83`.

9. **present:** Persistent storage, restart readback, backup and restricted restore into a new database. Evidence: `tools/refdata/refdata.py:426`, `:497`, `:1049`. Restore isolation and restart checks are part of the recorded self-test.

10. **present:** Named handling of unwritable backup destinations, locked replacement and unreadable restore files. Evidence: `tools/refdata/refdata.py:435`, `:458`, `:508`; real Windows failure and mutation evidence at `todo/00-workspace/TODO-06-reference-data.md:84`.

11. **missing-in-scope, G2:** Backup timeout cleanup deletes the partial file while its parent-process handle remains open. `tools/refdata/refdata.py:440` enters `with out`; the timeout branch calls `partial.unlink()` at `:453` before leaving it. On Windows, that open handle prevents deletion, replacing the intended named refusal with an uncaught `PermissionError` and leaving the partial dump. A slow or stalled shared-server backup is an ordinary operational failure. No recorded test exercises this branch.

12. **present:** Revision detection and nondestructive revision-1 upgrade, with comparison and explicit historical limitations. Evidence: `tools/refdata/refdata.py:194`, `:563`, `:575`. Successful migration and deliberately lossy-copy refusal are recorded at `todo/00-workspace/TODO-06-reference-data.md:85`.

13. **missing-in-scope, G3:** Restore, and therefore upgrade, does not preserve shared-server connection security settings. `tools/refdata/refdata.py:532` constructs the restricted account’s option file with only user, password, host and port. Configured TLS verification, CA and client-certificate settings are discarded. Recovery consequently does not use the connection policy under which normal authoring works. The private-server tests do not cover this boundary.

14. **missing-out-of-scope, G4:** The platform’s downstream delivery remains unfinished: deterministic export, embedding and drift detection, BiosCodes migration and expansion, and the shared consumer loader. These are explicitly owned by **D00 T06 §§2-5**, with BiosCodes integration in **D04 T05**, rather than this authoring repair. Evidence: `todo/00-workspace/TODO-06-reference-data.md:16`, `:33`, `:47`.

**Part 2: excellence**

Counterpart: **none in `resolute_au3/`**. Behavioral parity is not applicable. GUI layout, DPI and control requirements do not require a GUI for this authoring tool; `DESIGN.md:201` and `:204` remain relevant to truthful outcomes and actionable refusals.

1. **in-scope, G1:** Listing can misidentify stored records. **Target:** every accepted textual listing field reads back byte-for-byte, including literal `NULL`; a focused regression fails with the field marking removed.

2. **in-scope, G2:** Backup timeout falls below the actionable-refusal and recovery standard. **Target:** after timeout, terminate the child tree, close the output handle, remove the partial dump or explicitly name any cleanup failure, preserve the previous backup, and exit with a named refusal without a traceback. Prove this branch on Windows.

3. **in-scope, G3:** Shared-server recovery loses the configured connection policy. **Target:** restricted restore connections retain applicable transport and certificate-verification settings while replacing only account credentials; demonstrate a restore and upgrade using those settings, including refusal when verification fails.

No additional speed shortfall is established by the available evidence.

**Gap list**

1. **missing-in-scope / in-scope, G1:** Preserve literal textual values in dataset and author listing fields.
2. **missing-in-scope / in-scope, G2:** Close the backup output handle before timeout cleanup and provide a tested, named refusal.
3. **missing-in-scope / in-scope, G3:** Preserve shared-server transport security settings through restore and upgrade.
4. **missing-out-of-scope, G4:** Deliver export, embedding, consumer integration and BiosCodes migration under D00 T06 §§2-5 and D04 T05.

COMPLETION: gaps

## Writer note: completion gaps

- Planned: G1 `list` fields read unmarked, G2 backup timeout cleanup with the handle open, G3 restore drops the connection's TLS settings, as the Repair 2 items in D00 T06 §1, reviewed on `docs/reviews/00-workspace/D00-T06-s1-repair2.md`.
- Filed: D00 T06 §2 to §5 and D04 T05 (G4, export, embedding, consumer loader and BiosCodes migration), already in the plan with those owners.
