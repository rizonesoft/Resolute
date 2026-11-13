## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T03:26:49Z
- Candidate: a2ac53cb4840935e2f4ac6c56de7842f07dae193
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: a2ac53cb4840935e2f4ac6c56de7842f07dae193
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 9
- Digest: 035a58751ceb7ab2

1. **P1, line 77:** Removing the staging folder even when an old file cannot be restored deletes its recovery copy. Moving live files aside also leaves publication vulnerable to driver termination, which line 79 explicitly anticipates: no rollback runs, and the live set remains missing or partial. Preserve unrecovered originals, report their recovery location, and define recovery after interrupted publication. Prove recovery with one interrupted-publication case.

2. **P2, line 77:** The locked-destination test fails during the initial move-aside phase, before any new file is published. It cannot prove removal of partially installed files or rollback after failed readback. Add one failure case after installation begins, asserting restoration of the complete earlier set and non-zero exit.

3. **P2, line 79:** Killing the driver merely “while its launcher is open” can happen before the capture child starts. The test could pass while capture-child containment is broken. Require the same drill to wait until both owned processes are alive, kill only the driver, and verify both disappear while the pre-existing launcher survives.

HIGHEST: P1
PLAN: gaps
OVERALL: needs-attention

- Planned: finding 1 (P1), a journal written before anything moves, kept staging when a put-back fails, and recovery at the next start of a staging folder whose run is gone, proven by a case stopped after two files moved in, in the section-correction commit that follows this record
- Planned: finding 2 (P2), a case that fails after new files were moved in (a readback that differs), restoring the whole earlier set, in the same commit
- Planned: finding 3 (P2), the kill drill waits until the launcher and the capture child are both running, ends only the driver, and checks both are gone while a launcher started beforehand survives, in the same commit
