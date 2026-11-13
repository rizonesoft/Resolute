## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T03:51:13Z
- Candidate: ff5a26445c9e803de5652ab66b2b8da4ebc2ac34
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: ff5a26445c9e803de5652ab66b2b8da4ebc2ac34
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 7
- Digest: 743d74a0195cbaa6

1. **P1, plan, line 87 (Repair 6, `Done when:`):** The negative test exercises only the fit rule. It would still pass if the driver omitted either the pre-launch check or the actual-window check; capturing four shots on a large desktop would also pass. Require one failure case through each production check: insufficient work area must launch nothing and preserve existing output; an out-of-bounds positioned window must stop before capture, clean up owned processes and publish nothing. Removing either check must fail its case.

2. **P2, plan, line 87 (“this machine’s work area … accepts”):** This makes the self-test fail on a correctly rejected small desktop, precisely the operating condition Repair 6 addresses. Use a fixed sufficient work-area rectangle for the positive rule test. Keep actual display suitability as a prerequisite for the driven capture.

HIGHEST: P1
PLAN: gaps
OVERALL: needs-attention

- Planned: finding 1 (P1), `-DrillWorkArea` and `-DrillMoveOffscreen` drive the pre-launch and post-position checks as they run, each into a folder holding an earlier set, and each is shown to fail with its check removed, in the section-correction commit that follows this record
- Planned: finding 2 (P2), the fit rule's positive case uses a fixed 2560 x 1392 work area; the display's own fitness is the driven run's prerequisite, in the same commit

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T04:01:55Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: ff5a26445c9e803de5652ab66b2b8da4ebc2ac34
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 10
- Digest: ebb8873e4c7aaba8

### adversarial: needs-attention

1. **P1, `scripts/capture-launcher-readme.ps1:677`: Display bounds become stale during admission.** The work area is read once before the idle wait, which can last 600 seconds. The post-position check at line 626 compares against that cached rectangle, so both checks can accept a window outside the current display.

   **Reproduce:** Start `pwsh scripts/capture-launcher-readme.ps1 -Visible` on a 2560 × 1440 desktop while active. During its admission wait, change the display resolution to 1366 × 768 through Windows Settings, confirm it, then leave input idle for 120 seconds. Admission clears earlier input events and proceeds using the old bounds. A 1600 × 1000 window passes the cached containment check despite exceeding the actual display. The capture consumer performs no display-coverage check before `CopyFromScreen`, allowing incomplete screenshots to replace the previous set.

   Refresh display bounds after admission and validate current coverage immediately before capture. This finding follows from source inspection; I did not change the display or run the capture driver.

HIGHEST: P1
OVERALL: needs-attention

- Fixed: finding 1 (the display was read once, before a long admission wait). ecf69206: `Read-WorkArea` runs at the start, before each launch, after positioning, before the capture child starts and after it exits, and `-DrillShrinkAt launch|capture` shrinks the display at that point. Driven, each into a folder holding an earlier set: shrinking at launch printed `stood down during the launch of ...-details-dark: the display's work area is 1366 x 728, too small for a 1600 x 1000 window`, exit 3, earlier set unchanged, no process left; shrinking at capture printed `stood down during the capture of ...-details-dark: the display's work area is 1366 x 728 ...`, exit 3, unchanged; the same with the before-capture check removed printed `published 4 shots`, exit 0, set replaced. The README shots are restaked at ecf69206.

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T04:13:38Z
- Effort: low
- Writer model: claude-opus-5-5
- Policy: ff5a26445c9e803de5652ab66b2b8da4ebc2ac34
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: 2291529e4ac60549

### consistency: approve

No actionable consistency findings in the candidate diff. Review limited to source inspection; capture drills were not run.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T04:15:20Z
- Candidate: b9909cba3f12bf1abb72346ef735d40717d0877d
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: ff5a26445c9e803de5652ab66b2b8da4ebc2ac34
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 29
- Digest: f322b5e25dc3f6a8

The feature has one remaining gap: being inside the display and owning the foreground does not prove the launcher is unobscured.

Reviewed the candidate diff, source, recorded evidence and all four PNGs. No files changed. Tests and desktop drills were not rerun because they write files.

**Part 1: completeness**

1. **present**: Reproducible build and capture entry point. Commands are documented at `scripts/capture-launcher-readme.ps1:13`; the clean-checkout build evidence is at `todo/00-workspace/TODO-05-repo-face.md:61`.
2. **present**: Two views, each captured in light and dark. All four committed `2026-11-13-D00-T05-s1-launcher-*.png` images were visually inspected and measure 1582 × 991 pixels. Capture sequencing is at `scripts/capture-launcher-readme.ps1:755`.
3. **present**: Provenance and reproduction commands. The four sidecars record binary hash, revision, date, host, geometry, DPI, appearance and launch context. Command quoting has regression checks at `scripts/capture-launcher-readme.ps1:452`.
4. **present**: Explicit desktop admission and cancellation on resumed input. Enforcement is at `scripts/capture-launcher-readme.ps1:563`, `:738` and `:693`; interruption and failed-query runs are recorded at `todo/00-workspace/TODO-05-repo-face.md:82`.
5. **present**: Insufficient-display refusal and refreshed bounds checks. Checks run before admission, before launch, after positioning and around capture at `scripts/capture-launcher-readme.ps1:643`, `:661`, `:688`, `:698` and `:717`. Fit tests are at `:486`; production-check drills are recorded at `todo/00-workspace/TODO-05-repo-face.md:89`.
6. **present**: Bounded launcher interaction and capture waits. Positioning has a five-second deadline at `scripts/capture-launcher-readme.ps1:330`; capture has a configurable deadline at `:691`. Hung-window regression cases are at `:474`.
7. **present**: Owned-process cleanup, including abrupt driver termination. Job binding is at `scripts/capture-launcher-readme.ps1:727`, cleanup at `:702`, and the recorded termination drill at `todo/00-workspace/TODO-05-repo-face.md:87`.
8. **present**: File publication, readback and recovery. Staging, journalled replacement, hash verification and rollback are implemented at `scripts/capture-launcher-readme.ps1:346`; next-start recovery is at `:407`. Locked-file, readback-failure and interrupted-publication tests begin at `:492`. Capture failures prevent publication.
9. **missing-in-scope**: Refusal when another window obscures the launcher. `scripts/capture-window.ps1:203` checks foreground ownership, then `:233` copies screen pixels. An existing always-on-top window can overlap the launcher while the launcher owns the foreground and the operator remains idle. Bounds checks still pass, so unrelated application pixels can be published as launcher evidence. No regression case covers this condition.

GUI controls, focus order, application settings, elevation and system-state undo are not surfaces this repository tool introduces.

**Part 2: excellence**

Counterpart: none in `resolute_au3/`; behavioral parity is not applicable. `DESIGN.md` supplies the visual-proof standard, but this section does not implement the launcher's controls or accessibility.

1. **in-scope**: Capture integrity remains weaker than the promised whole-window proof. The foreground-only check cannot exclude always-on-top overlap (`scripts/capture-window.ps1:203`, `:233`). **Target:** with an overlapping always-on-top window, either capture only the complete launcher or refuse with a clear reason, preserve the earlier output set and leave the operator's window untouched. Add one regression case for that ordinary desktop condition. This is a source-derived finding, not a reproduced failure.

**Gap list**

1. **missing-in-scope; in-scope**: Detect or exclude overlapping always-on-top windows before publishing screen captures, with one regression case proving that unrelated pixels cannot become launcher evidence. Owning layer: capture helper, consumed by D00 T05 §1.

COMPLETION: gaps
