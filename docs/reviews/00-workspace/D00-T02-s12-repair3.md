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

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T16:38:20Z
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: fa2de8e3a5db8e074481bdc737287a430fb94268
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 2149d895f56e37c5

### adversarial: approve

No actionable adversarial defect found in `fa2de8e3..8ba71a34`. Review covered the actual four-file diff and relevant callers. Verification was static; I did not rerun tests or headful captures.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T16:40:07Z
- Candidate: 8ba71a34054ad50b70b8b1ad4b29d2b088e414f9
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: fa2de8e3a5db8e074481bdc737287a430fb94268
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 19
- Digest: 709fdeaf9a67acf5

Read-only review of `fa2de8e3..8ba71a34`. No files changed; C++ tests and headful captures were not rerun.

**Part 1: completeness**

- **missing-in-scope: Real text-truncation proof.** The new selected-All and Name-header drills paint nearly full-height, six-pixel-wide rectangles, rather than clipped glyphs ([visual_pair_test.cpp:434](D:/GitHub/Resolute/tests/visual_pair_test.cpp:434), [line 451](D:/GitHub/Resolute/tests/visual_pair_test.cpp:451)). The detector divides painted edge pixels by the entire control height ([visual_pair.h:234](D:/GitHub/Resolute/tests/visual_pair.h:234)). For the approximately 60-pixel All row, up to 15 painted rows in both sampled columns still pass its 0.25 threshold. Consequently, these drills do not establish sensitivity to ordinary partial-glyph truncation. Require actual clipped text, with the named `clipped` diagnostic under the theme exemption.
- **missing-in-scope: Regression protection for the shipped View contrast setting.** The new test constructs its own region and explicitly enables text contrast ([visual_pair_test.cpp:405](D:/GitHub/Resolute/tests/visual_pair_test.cpp:405)). Restoring the production `toolbar-view` setting to `skip` would leave this test passing. Load the shipped region and use it for the deficient-text drill in both themes.
- **present: Region inventory, comparison diagnostics and malformed-input refusal.** Evidence: [visual_pair_test.cpp:64](D:/GitHub/Resolute/tests/visual_pair_test.cpp:64), [line 180](D:/GitHub/Resolute/tests/visual_pair_test.cpp:180), and real-baseline glyph mutations at [line 341](D:/GitHub/Resolute/tests/visual_pair_test.cpp:341).
- **present: Fenced execution, interruption cleanup and process recovery.** Evidence: [ui_headful_test.cpp:283](D:/GitHub/Resolute/tests/ui_headful_test.cpp:283), [line 483](D:/GitHub/Resolute/tests/ui_headful_test.cpp:483), and the declared pair case in [focus-audit.md:28](D:/GitHub/Resolute/tests/focus-audit.md:28).
- **present: Capture persistence, reproduction metadata and readback.** Scratch capture publication is documented in [testing.md:38](D:/GitHub/Resolute/docs/testing.md:38); sidecar assertions and PNG readback are implemented at [ui_headful_test.cpp:601](D:/GitHub/Resolute/tests/ui_headful_test.cpp:601).
- **present: Independent hook-failure reporting, including blocked marker files.** Evidence: [focus_hook_test.cpp:50](D:/GitHub/Resolute/tests/focus_hook_test.cpp:50), [line 87](D:/GitHub/Resolute/tests/focus_hook_test.cpp:87), and [line 118](D:/GitHub/Resolute/tests/focus_hook_test.cpp:118).

This section adds a test-author workflow, so new application controls, dialogs, keyboard navigation, settings and system-change undo are not applicable. Live AutoIt parity remains the agreed D03 T02 §7 responsibility, not a new finding.

**Part 2: excellence**

- **in-scope: Clipping confidence remains weaker than the promised “every control unclipped” guarantee.** Replace the solid-strip proof with rendered text clipped at actual control boundaries. Target: selected All and each header reject partial-glyph truncation specifically as `clipped`, including under theme exemption, while unchanged light and dark baselines pass.
- **in-scope: The text-floor regression does not protect the configuration that caused the previous defect.** Target: changing the shipped View region back to `skip` must fail the regression; text between 3:1 and 4.5:1 must produce the named 4.5:1 diagnostic in both themes. This preserves [DESIGN.md:72](D:/GitHub/Resolute/DESIGN.md:72).

COMPLETION: gaps
