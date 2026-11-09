## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T16:33:36Z
- Candidate: fa2de8e3a5db8e074481bdc737287a430fb94268
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: fa2de8e3a5db8e074481bdc737287a430fb94268
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 7
- Digest: f78b288910bdaaee

1. **P2, plan: View lacks the required regression proof.** Switching `toolbar-view` to `contrast=check` is appropriate, but the plan omits the completion review’s rendered View drill between 3:1 and 4.5:1. Require it in both themes, including under the theme exemption, asserting the named text-floor diagnostic. A passing fresh capture cannot prove deficient text is rejected.

2. **P2, plan: Selected-item clipping remains unproven.** The retained drill targets `sidebar-system`, not selected `sidebar-all` (`tests/visual_pair_test.cpp:370`). It paints the outermost two columns, which the proposed measurement stops sampling. Explicitly replace this with actual selected-All truncation and header truncation, requiring each named `clipped` diagnostic under the theme exemption. Calibrate thresholds against both passing baselines and these failing mutations; merely choosing values below 1.0 does not establish sensitivity.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

- Planned: both plan gaps folded (writer, 2026-11-09). (1) A rendered View drill in both themes: a synthetic toolbar-view region whose glyph core measures between 3:1 and 4.5:1 fails with the named 4.5:1 text diagnostic under the theme exemption, proving the floor the fresh capture cannot. (2) The clipping drills target the selected sidebar-all control and list-header-name with the shipped thresholds, asserting their own named clipped diagnostics under the theme exemption; thresholds are calibrated against both passing baselines and these mutations.
