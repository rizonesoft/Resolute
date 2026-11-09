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
