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

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T03:39:12Z
- Effort: low
- Writer model: claude-opus-5-5
- Policy: a2ac53cb4840935e2f4ac6c56de7842f07dae193
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: 484609e425db9747

### consistency: approve

No actionable consistency findings in the candidate diff. Review limited to the scheduled consistency lens; no files modified.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T03:41:13Z
- Candidate: f3d3d9a10a2be095f11a25fc9aa1a0753dd90def
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: a2ac53cb4840935e2f4ac6c56de7842f07dae193
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 28
- Digest: e0f0c5f881b67bd1

Part 1: completeness

Reviewed the candidate diff and all four images without modifying files. Test results below are recorded evidence, not tests rerun during this review. References use candidate line numbers.

1. **present:** Clean-checkout build proof is recorded in `todo/00-workspace/TODO-05-repo-face.md:61`.
2. **present:** Two views, each in light and dark, exist under `docs/captures/2026-11-13-D00-T05-s1-launcher-*`. All four PNGs measure 1582×991, exceeding the width requirement.
3. **present:** Provenance includes host, date, revision, binary hash, DPI, appearance and reproduction command. Evidence: `docs/captures/2026-11-13-D00-T05-s1-launcher-details-dark.txt:1`.
4. **present:** Reproduction handles quoted paths and stable filenames. Evidence: `scripts/capture-launcher-readme.ps1:225`; successful unedited replay recorded in `todo/00-workspace/TODO-05-repo-face.md:77`.
5. **present:** Explicit desktop consent, idle admission, input monitoring and refusal messages exist. Evidence: `scripts/capture-launcher-readme.ps1:459`, `:479`, `:629`; interruption drills recorded in `todo/00-workspace/TODO-05-repo-face.md:76`.
6. **present:** Theme/view commands and capture-child waits have deadlines and failure reporting. Evidence: `scripts/capture-launcher-readme.ps1:235`, `:595`; hung-command regression at `:380`.
7. **missing-in-scope, P2:** Positioning remains unbounded. `scripts/capture-launcher-readme.ps1:566` calls synchronous `SetWindowPos` with only `SWP_SHOWWINDOW`. If the launcher stops processing messages after exposing its window, this call can block before subsequent input checks and cleanup. The hung-window test exercises `Send-Command`, not positioning. Microsoft documents `SWP_ASYNCWINDOWPOS` specifically as avoiding this cross-thread blocking. [SetWindowPos documentation](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowpos)
8. **present:** Publication stages the set, hashes installed files, rolls back failures, and preserves originals when rollback encounters a lock. Evidence: `scripts/capture-launcher-readme.ps1:249`; locked-file and failed-readback cases at `:390`.
9. **present:** Interrupted publication is recovered on the next invocation. Evidence: `scripts/capture-launcher-readme.ps1:317`, `:542`; recovery case at `:420`.
10. **present:** Owned processes are lifetime-bound, with normal cleanup and preservation of pre-existing processes. Evidence: `scripts/capture-launcher-readme.ps1:129`, `:605`, `:615`; termination drill recorded in `todo/00-workspace/TODO-05-repo-face.md:81`.

GUI controls, focus order, persistent preferences, elevation, registry changes and system undo are not applicable to this tooling section. README embedding belongs to §2.

Part 2: excellence

Counterpart: none in `resolute_au3/`. Behavioral parity is not applicable. This section adds no product surface requiring a separate `DESIGN.md` accessibility or layout implementation.

1. **in-scope, P2:** Responsiveness and recovery remain weaker during positioning. A blocked `SetWindowPos` leaves the driver alive, so its lifetime job does not trigger cleanup. **Target:** positioning succeeds with verified geometry or refuses within five seconds, continues checking operator input while waiting, publishes nothing on refusal, and ends owned processes. Add one regression using an unresponsive window at the positioning step.

Gap list

1. **missing-in-scope / in-scope, P2:** `scripts/capture-launcher-readme.ps1:566`: bound and verify positioning, with one hung-window regression proving refusal and cleanup.

COMPLETION: gaps
