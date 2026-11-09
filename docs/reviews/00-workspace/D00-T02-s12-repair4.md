## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T16:41:21Z
- Candidate: 7311f8e860cd1f27de0ddfab886dc174cd387930
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 7311f8e860cd1f27de0ddfab886dc174cd387930
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 7
- Digest: 602579a9964805cf

1. **P2, plan: Two headers still lack partial-glyph clipping proof.** The plan drills only `sidebar-all` and `list-header-name`; the completion target explicitly requires **each header**. Assertions that `list-header-description` and `list-header-version` have `maxEdge < 1.0` cannot prove their thresholds reject truncated glyphs. Extend the real-glyph drills to both omitted headers, requiring each control’s named `clipped` diagnostic under theme exemption while unchanged light and dark baselines pass.

The configuration assertions plus retained between-floors View drill satisfy item 2: reverting shipped View to `skip` fails an assertion, and deficient text produces the 4.5:1 diagnostic in both themes.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

- Planned: the plan gap folded (writer, 2026-11-09): the partial-glyph truncation drills cover sidebar-all and all three list headers, each asserting its own named clipped diagnostic under the theme exemption, with maxEdge thresholds (0.10 on sidebar controls and headers) calibrated against the unchanged baselines (measured 0.0) and the mutations.

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T16:45:23Z
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 7311f8e860cd1f27de0ddfab886dc174cd387930
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 8
- Digest: 94eb5bb75f25e618

### adversarial: approve

No actionable adversarial findings in `7311f8e8..40d11c19`. This range contains only clipping-threshold changes, test additions and a review record; the capture and hook changes predate it.

Static review only. Tests were not rerun, and no files were modified.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T16:46:54Z
- Candidate: 40d11c198b1895a4f71650dbe8a4b039941b3b67
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 7311f8e860cd1f27de0ddfab886dc174cd387930
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 20
- Digest: fc4f9c597acc32c1

Read-only review of `7311f8e8..40d11c19`. No files modified. Findings are static; C++ tests and headful captures were not rerun.

**Part 1: completeness**

- **missing-in-scope: Genuine partial-glyph clipping proof.** `TruncateLabelAtEdge` shifts captured content, then overwrites both detector sampling columns with solid ink from `glyphTop` through `glyphBottom` ([visual_pair_test.cpp:498](D:/GitHub/Resolute/tests/visual_pair_test.cpp:498)). The passing drill therefore proves detection of an added rectangle, not necessarily the clipped glyph. Repair3’s completion gap remains unresolved.
- **missing-in-scope: Dark-theme clipping regression coverage.** The new four-control drill loads only `Baseline150()`, which resolves to the light capture ([visual_pair_test.cpp:517](D:/GitHub/Resolute/tests/visual_pair_test.cpp:517), [visual_pair_util.h:196](D:/GitHub/Resolute/tests/visual_pair_util.h:196)). The separate dark-baseline test does not truncate any glyph.
- **present: Shipped View contrast configuration protection.** The new assertion loads the production spec and checks both `text` and `checkContrast`; reverting View to `skip` now fails ([visual_pair_test.cpp:527](D:/GitHub/Resolute/tests/visual_pair_test.cpp:527)). The between-floors drill covers both themes at line 392.
- **present: Region inventory, named diagnostics and malformed-input refusal.** Covered by `visual_pair_test.cpp:64`, `:77`, `:91`, `:180`, and the captured-glyph mutation at `:341`.
- **present: Fenced invocation, cancellation policy and visible coverage debt.** Defined in [testing.md:5](D:/GitHub/Resolute/docs/testing.md:5) and the pair’s inventory entry at [focus-audit.md:28](D:/GitHub/Resolute/tests/focus-audit.md:28).
- **present: Capture metadata and persisted-image readback.** Sidecar assertions and PNG loading appear at [ui_headful_test.cpp:601](D:/GitHub/Resolute/tests/ui_headful_test.cpp:601).
- **present: Independent hook-failure reporting.** Open-mapping, map-view, dropped-event and blocked-marker cases are covered by `focus_hook_test.cpp:50`, `:66`, `:87`, and `:118`.

This is a test-author workflow, so new application controls, tooltips, keyboard navigation, dialogs, user settings and system-change undo are not applicable. Live AutoIt parity remains the agreed D03 T02 §7 responsibility, not a new gap.

**Part 2: excellence**

- **in-scope: Clipping evidence remains weaker than the promised unclipped-control guarantee.** Remove the artificial ink overlay and test actual partial-glyph truncation. Target: selected All and all three headers each produce their own `clipped` diagnostic under theme exemption, using only shifted/cropped glyph pixels, while unchanged baselines pass.
- **in-scope: Theme coverage is incomplete for that guarantee.** Run those four mutations against both recorded light and dark captures. Target: eight named clipping failures and passing unchanged baselines, without relaxing the [DESIGN.md contrast floors](D:/GitHub/Resolute/DESIGN.md:72).

COMPLETION: gaps

- Implemented: the two Part 2 items are built in the repair5 cycle (record D00-T02-s12-repair5.md): the artificial ink overlay is gone, drills shift real ink until it straddles each control boundary with retained and cropped ink both asserted, on both light and dark captures. The sidebar drill row is System rather than All, because All's count badge occupies the sampled edge rows; see the repair5 record for the measurement evidence.
