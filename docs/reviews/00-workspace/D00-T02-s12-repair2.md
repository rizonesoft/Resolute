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
