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
