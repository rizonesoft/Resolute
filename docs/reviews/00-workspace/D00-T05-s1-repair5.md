## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T03:42:57Z
- Candidate: 55e32d0fda4310bb1cb2c11c38b501bbc85375c2
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 55e32d0fda4310bb1cb2c11c38b501bbc85375c2
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 3
- Digest: 5363a394b6e0de2b

HIGHEST: none
PLAN: complete
OVERALL: approve

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T03:47:34Z
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 55e32d0fda4310bb1cb2c11c38b501bbc85375c2
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: eadad03879dc7490

### adversarial: approve

No actionable findings in the candidate diff. Static review only; desktop drills and self-tests were not rerun. Checked asynchronous positioning semantics against [Microsoft’s documentation](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowpos).

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T03:49:33Z
- Candidate: cc7931f9dd4e080330b6768aca3d6595c679c6d3
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 55e32d0fda4310bb1cb2c11c38b501bbc85375c2
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 26
- Digest: 22626547821dde6e

The feature has one completeness gap: retaking the screenshots does not verify that the requested window fits on the display. Review was read-only; I inspected the diff, source, recorded test evidence and all four images. I did not rerun tests that write files.

**Part 1: completeness**

1. **present:** Reproducible build and capture instructions. Clean-checkout build evidence is recorded in `todo/00-workspace/TODO-05-repo-face.md:61`; the invocation is documented in `scripts/capture-launcher-readme.ps1:13`.
2. **present:** Two views, each in light and dark, with matching dimensions and provenance. All four committed `2026-11-13-D00-T05-s1-launcher-*` PNGs are 1582 × 991; their sidecars record the executable hash, revision, date, host, appearance and reproduction command. Visually inspected all four.
3. **present:** Explicit desktop admission and cancellation when operator input resumes. `scripts/capture-launcher-readme.ps1:496` refuses execution without `-Visible`; input checking is implemented at line 260. Interruption and failed-query drills are recorded in `todo/00-workspace/TODO-05-repo-face.md:78`.
4. **present:** Bounded launcher operations and capture execution. Window commands use a timeout at `scripts/capture-launcher-readme.ps1:238`; asynchronous positioning and its deadline are at line 272; capture timeout handling is at line 623. The hung-window regression and its failing synchronous variant are recorded in `todo/00-workspace/TODO-05-repo-face.md:84`.
5. **present:** Process cleanup on failure, cancellation and driver termination. Lifetime containment is implemented at `scripts/capture-launcher-readme.ps1:130`, with per-shot cleanup at line 636. The driver-termination drill is recorded in `todo/00-workspace/TODO-05-repo-face.md:83`.
6. **present:** Staged publication, readback and recovery from failed writes or interrupted replacement. `scripts/capture-launcher-readme.ps1:287` journals replacements and verifies hashes; line 348 restores interrupted publication on the next start. Self-tests cover locked destinations, failed readback, interrupted publication and temporarily blocked restoration.
7. **present:** Replayable arguments and regression coverage for quoting and input classification. `scripts/capture-launcher-readme.ps1:232` constructs the command; `Invoke-SelfTest` checks it. An unedited replay through a directory containing spaces is recorded in `todo/00-workspace/TODO-05-repo-face.md:79`.
8. **missing-in-scope:** **G1: Display-fit validation before accepting a capture.** `scripts/capture-launcher-readme.ps1:590` always requests 1600 × 1000 at `(40,40)`. The positioning check verifies dimensions only; `scripts/capture-window.ps1:223` checks positive area, then copies the whole rectangle at line 233 without checking display coverage. On a normal 1366 × 768 desktop, this requests pixels outside the display and can publish incomplete visual proof. Require a fully visible capture meeting the width floor, or an explicit refusal leaving the previous set unchanged. Add one regression for insufficient display bounds.

GUI controls, tooltips, focus order, persistent preferences, elevation, registry changes and repair undo are not applicable to this repository-tooling section.

**Part 2: excellence**

Counterpart: **none**. AutoIt behavioral parity and frozen repair behavior do not apply. `DESIGN.md` applies to the photographed launcher; these captures do not establish its keyboard or screen-reader conformance.

1. **in-scope, G1:** Capture defaults assume a sufficiently large desktop. **Target:** every accepted image covers the entire requested window on actual display pixels; unsupported display geometry produces a named refusal and publishes nothing. This is the same gap as Part 1 item 8, not an additional requirement.

**Gap list**

1. **G1, missing-in-scope / in-scope:** Validate display coverage before capturing or publishing; refuse insufficient geometry without replacing existing evidence, with one regression covering a smaller display. Owner: D00 T05 §1.

COMPLETION: gaps
