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
