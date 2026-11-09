## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T16:04:54Z
- Candidate: 9cc85f7f1e9d0b3cc464c2c807d3e3a834a498a6
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 9cc85f7f1e9d0b3cc464c2c807d3e3a834a498a6
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 11
- Digest: a9c1cf0ad3db80dd

1. **P1, plan: Border contrast remains deferred.** `tests/visual_pair.h:175` excludes boundary-touching and thin components, so element-kind glyph measurements do not measure borders. Recording deficient separator ratios against D01 T02 §1 for a future exception decision does not close this section’s explicit requirement. Add separate border measurements, deficient-border failure drills in both themes, and corrections at the owning palette layer. A pending exception cannot support the stamp.

2. **P1, plan: Two glyph-erasure drills do not establish individual-control and label/value detection.** The plan leaves broad bands, empty labels/values, and 2% pixel tolerances in `tests/visual_pair_spec.txt:37` onward unchanged. `tests/visual_pair_util.h:189` still copies expected labels into observations. A small glyph edit can remain below that tolerance, and naming a band containing several controls does not identify the affected control. Specify control-level extraction/comparison and demonstrate actual label replacement, value change, and individual-control removal through the production path. Erasing two selected glyphs alone does not meet the section’s renamed-label requirement.

3. **P2, plan: Baseline edge-touch plus 0.25 does not reliably detect internal clipping.** `tests/visual_pair.h:193` measures painted pixels over the entire region perimeter. A clipped label touching a few edge pixels can remain far below the proposed 25-percentage-point allowance; baselines at or above 0.75 still produce an inert ceiling of 1.0. Extending text to an arbitrary band boundary also need not reproduce clipping at its actual control boundary. Define control-content boundaries and thresholds sensitive to real truncation. Require the clipping diagnostic itself to fail under the theme exemption, independently of pixel-difference failure.

4. **P2, plan: Sidecar assertions still do not prove reproduction.** Checking that launch context contains the executable name and that a fixture-files line exists accepts a missing working directory, incorrect arguments, or an empty inventory field. The reproduced-half requirement at `todo/00-workspace/TODO-02-test-backbone.md:698` remains unproven. Assert exact recorded command line, resolved working directory, and actual inventory, including explicit emptiness. For nonempty fixtures, identify reproducible executable inputs, since the launcher reads their embedded resources (`src/main.cpp:28`). Include the sidecar-only reproduction check before publishing the captures.

HIGHEST: P1
PLAN: gaps
OVERALL: needs-attention

- Planned: the four plan gaps folded (writer, 2026-11-09). (1) Border contrast is measured in the raster: long border-touching components against their local paper at the 3:1 floor for the main regions, with deficient-border drills in synthetic light and dark, and the palette border tokens corrected at their owning layer (light RGB(210) toward 140, dark RGB(60) toward 108, exact values set by the measure) with goldens and captures restaked. (2) The spec's grid slots become named control rectangles from the library layout (toolbar View/Refresh/Settings/Theme from kItems, sidebar All/System/Network/Security/Display/Programs from kCategories, list headers Name/Description/Version from the launcher's AddColumn calls), each carrying its label from the same table and a 0.005 moved-pixel tolerance, so one erased or repainted glyph fails naming the control; glyph erasure and repaint drills run on the real baseline. (3) Edge-touch becomes the painted fraction of the control's right two columns (the truncation side), calibrated per control from the baseline plus 0.25, and the clipping drill extends a real sidebar label to its control's right edge and asserts the clipped line itself under the theme exemption. (4) The pair case asserts the sidecar's launch context exactly (the command line it built and its working directory) and compares the recorded fixture inventory against the System/*.exe files it enumerates itself, empty inventory included.

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T16:22:07Z
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 9cc85f7f1e9d0b3cc464c2c807d3e3a834a498a6
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 10
- Digest: c28ae4b06689c52e

### adversarial: needs-attention

1. **P1: The border check accepts an existing below-floor border.** `tests/visual_pair.h:288` accepts `borderContrast == 0`, although the detector can discard real borders through its luminance threshold (`:144`) and component-shape restriction (`:211`).

   **Reproduction:** Read the committed `docs/captures/runs/2026-11-09-D00-T02-s10-launcher-light-150.png`. Pixel `(200,670)` is the RGB(140) status-bar border, between RGB(235) at `(200,669)` and RGB(230) at `(200,671)`. Its contrast is **2.82:1 and 2.69:1**, below the required 3:1. A read-only reproduction of the candidate’s calculation returns `borderContrast = 0` for both sidebar and status-bar regions, which `Compare` accepts. The dark capture likewise yields zero border measurements across all five main regions.

   This is a check passing what it must refuse on the repository’s actual captured surface. Measure borders independently of glyph eligibility, reject missing required measurements, and correct the deficient palette relationship.

HIGHEST: P1
OVERALL: needs-attention

- Implemented: repair2 round 1 (adversarial P1) in 835016cf: border lines are measured in dedicated strip regions, Compare refuses an unmeasured border, thinness is average thickness, the dark border clears the ink threshold, and the light border token darkens 140 to 128 (2.82:1 measured at 140). Suite 120/120; pair 0 divergences.

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T16:30:10Z
- Effort: low
- Writer model: muse-wonder-1.0
- Policy: 9cc85f7f1e9d0b3cc464c2c807d3e3a834a498a6
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: d94c8bd637614fb5

### consistency: approve

No actionable consistency findings in `9cc85f7f..835016cf`. Review was read-only; tests were not rerun.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T16:32:00Z
- Candidate: 835016cf3eee4f4047d21594fdbe534864fb5a32
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 9cc85f7f1e9d0b3cc464c2c807d3e3a834a498a6
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 18
- Digest: 91d7067a9197f734

Read-only review of `9cc85f7f..835016cf`. No files changed; C++ and headful tests were not rerun.

**Part 1: completeness**

- **missing-in-scope: Enforce 4.5:1 for toolbar text.** [visual_pair_spec.txt:38](D:/GitHub/Resolute/tests/visual_pair_spec.txt:38) classifies the toolbar as `element`, while its `toolbar-view` text region skips contrast checking at line 42. Consequently, [visual_pair.h:298](D:/GitHub/Resolute/tests/visual_pair.h:298) applies only 3:1 to “View”. The border repair does not close this text-coverage gap. Add a rendered “View” regression between 3:1 and 4.5:1 that fails in both themes, including under the theme exemption.
- **missing-in-scope: Detect clipping for every declared control.** `sidebar-all` and all three list headers still have `maxEdge=1.0` in [visual_pair_spec.txt:46](D:/GitHub/Resolute/tests/visual_pair_spec.txt:46) and [line 52](D:/GitHub/Resolute/tests/visual_pair_spec.txt:52). Their measured edge fraction cannot exceed that threshold, so the clipping condition at [visual_pair.h:273](D:/GitHub/Resolute/tests/visual_pair.h:273) cannot detect internal truncation. The new `sidebar-system` drill proves that control only. Add actual header and selected-item truncation drills that fail specifically as clipped, including under the theme exemption.
- **present: Region comparison, malformed-input refusal and regression diagnostics.** Evidence: [visual_pair_test.cpp:77](D:/GitHub/Resolute/tests/visual_pair_test.cpp:77), [line 180](D:/GitHub/Resolute/tests/visual_pair_test.cpp:180), and glyph mutation drills at [line 341](D:/GitHub/Resolute/tests/visual_pair_test.cpp:341).
- **present: Fenced execution, cancellation cleanup and capture readback.** Evidence: child cleanup at [ui_headful_test.cpp:283](D:/GitHub/Resolute/tests/ui_headful_test.cpp:283), interruption handling at [line 488](D:/GitHub/Resolute/tests/ui_headful_test.cpp:488), and pair comparison at [line 643](D:/GitHub/Resolute/tests/ui_headful_test.cpp:643).
- **present: Independent hook-failure reporting and storage-failure fallback.** Open/map/drop drills and blocked-file fallback are covered by [focus_hook_test.cpp:50](D:/GitHub/Resolute/tests/focus_hook_test.cpp:50) through its named event-fallback test at line 118.
- **missing-out-of-scope, already assigned: Live AutoIt comparison.** Owned by `D03 T02 §7` under the agreed elevated-session requirement. This is not a new completion blocker. The harness introduces no application dialogs, settings, keyboard controls or system-repair undo surface requiring additional implementation here.

**Part 2: excellence**

- **in-scope: Contrast certification remains weaker than DESIGN.md.** Target: every text region rejects measured contrast below 4.5:1; interactive elements and borders reject below 3:1. “View” currently lacks the required text-floor enforcement.
- **in-scope: Clipping certification remains incomplete.** Target: truncating any declared control’s content produces a diagnostic naming that control as clipped, independently of pixel-difference failures and despite theme exemptions. Selected “All” and the list headers currently have inert clipping thresholds.
- **out-of-scope, already assigned: Behavioral parity proof.** This infrastructure has no AutoIt counterpart, and its C++ baseline checks do not establish 1:1 system-effects parity. The deferred live pair remains with `D03 T02 §7`.

COMPLETION: gaps
