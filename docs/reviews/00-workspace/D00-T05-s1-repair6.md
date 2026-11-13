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
