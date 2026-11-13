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

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T03:36:31Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: a2ac53cb4840935e2f4ac6c56de7842f07dae193
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 10
- Digest: c550c636bcd56bc1

### adversarial: needs-attention

1. **P1, `scripts/capture-launcher-readme.ps1:286` (cleanup at `:629`): Failed rollback deletion destroys the earlier set.** With `$ErrorActionPreference = 'Stop'`, a failure removing any newly installed file escapes the rollback before `$script:KeepStaging` is set. The caller then recursively deletes staging, including `aside` and its original files.

   **Reproduction:** Publish over an existing capture set in `docs/captures`. After installation, hold a newly published PNG open with `FileShare.None`, representing a concurrent file consumer. The existing `PublishHook` can reproduce this deterministically without changing file contents. Hash readback fails, rollback deletion hits the same lock, and the caller deletes the unlocked originals in `aside`. The earlier set is lost and next-start recovery has no journal.

   Preserve staging from the moment originals move aside until publication or rollback is conclusively complete. Handle rollback deletion failures without bypassing preservation.

HIGHEST: P1
OVERALL: needs-attention

- Fixed: finding 1 (a failed undo let the caller delete the earlier set). The staging folder is marked kept from the moment the first earlier file moves aside, and the mark clears only when publication or its undo has finished; each undo step reports instead of throwing, so a new file another handle holds is named, the earlier file stays in the kept staging folder, and the next start puts the whole set back. Self-test: `PASS an undo that cannot remove a held file names it and keeps the staging folder with the earlier file`, `PASS the next start then puts the whole earlier set back`, 15 PASS in all; with the early mark removed, that first case fails by name.
