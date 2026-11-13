## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T10:14:15Z
- Candidate: f2b50b8b7eb98c36012fef72c7708d340606ae06
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: f2b50b8b7eb98c36012fef72c7708d340606ae06
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 5
- Digest: 5bb9bbff91c67773

1. **P1, `todo/00-workspace/TODO-06-reference-data.md:90`: The TLS refusal test fails before reaching the connection it must prove.** Giving the author’s option file an unrelated CA makes restore fail at `s.exists()` and upgrade fail at its initial source connection. Neither reaches the restricted option file, so removing TLS settings from that file cannot make this refusal test fail as required. Keep the author connection valid and introduce the invalid CA specifically into the restricted connection during the test. Prove restore and upgrade reach that connection, refuse certificate verification, remove the temporary account and destination database, and preserve the source. Require this test to fail when restricted-connection TLS settings are dropped.

HIGHEST: P1
PLAN: gaps
OVERALL: needs-attention

## Writer note: plan findings

- Planned: the TLS refusal is driven through the restricted connection alone, the author's connection staying valid (P1), in the corrected Repair 2 restore item.

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T10:38:48Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: f2b50b8b7eb98c36012fef72c7708d340606ae06
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 8
- Digest: 5723152dc55c87a7

## adversarial: needs-attention

1. **P1, `tools/refdata/refdata.py:560`: Copying `[mysql] force` allows a failed restore to report success.** The restricted connection inherits this option, while `run_sql` checks only the exit code. Reproduce with an author option file containing `[mysql]` followed by `force`, then restore a dump containing an invalid INSERT followed by valid statements. Failed rows are skipped, `restored` becomes true, and the incomplete database is retained as successful. Confirmed with a read-only SQL error probe: without `--force`, `run_sql` refused; with it, it returned the subsequent SELECT result successfully. Explicitly disable force for restore execution.

2. **P2, `tools/refdata/refdata.py:560`: Relative TLS paths change meaning in the copied option file.** `run_sql` uses the option file’s parent as its working directory (line 177), but the restricted file lives in a temporary directory. Reproduce using `client.cnf` with `ssl-mode=VERIFY_CA` and `ssl-ca=ca.pem`, with the CA beside the original file. Author connections resolve the CA correctly; restore and upgrade resolve it inside `refdata-restore-*` and fail. The copy preserves the relative string, not the connection setting’s effective location. Preserve the original path resolution for CA, certificate, key and included files.

HIGHEST: P1
OVERALL: needs-attention
