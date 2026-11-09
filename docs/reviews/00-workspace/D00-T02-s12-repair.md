## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T15:31:39Z
- Candidate: c15d54d93e7e4fc53bdf21c6e90a10e6e4dd234d
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: c15d54d93e7e4fc53bdf21c6e90a10e6e4dd234d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 17
- Digest: 977185f401c2dfb5

1. **P1 [plan]: Slots do not observe labels or values.** Painted extent and detail can remain acceptable after a label changes, an icon is replaced, or a different control occupies the slot. Row-band counts cannot detect changed row text or values with the same count. `tests/visual_pair_util.h:88` currently copies the expected label into the observation; the plan supplies no replacement extraction mechanism. Specify actual label/value extraction and drills that rename a real label and change a value through the production path, naming the affected control.

2. **P1 [plan]: Grid contrast does not establish per-relationship compliance.** A high-contrast icon and deficient text can occupy the same grid block, preserving the masking problem. Low-contrast content could also be excluded by the “both ink and paper” classification while other blocks yield a nonzero result. Define how each text/background and control/border relationship is identified and measured, applying 4.5:1 and 3:1 respectively. Require failures for mixed content within one block and unmeasurable individual relationships, plus real light and dark passes. Restaking dark captures alone does not validate their contrast.

3. **P1 [plan]: Two marker destinations still permit silent failure.** Checking writes and trying a current-directory fallback does not specify what happens when both destinations fail creation or writing. No marker then exists for the guard to reject. The fallback also needs a destination known to both processes despite differing working directories. Specify an independently observable refusal when reporting is unavailable, and drill both destinations failing, short/failed writes, and a lost transient event between successful events. This remains required by §12’s “every failure path must void the case’s proof.”

4. **P2 [plan]: Pane bounds miss clipping inside a pane.** Four child-window rectangles and window-edge detection cannot identify a toolbar label clipped by its own drawing rectangle, or sidebar text cut at an internal pane boundary while every pane remains inside the client area. Specify control-level clipping observation, coordinate alignment with the captured image, and refusal when required panes cannot be extracted. Add a production-path drill clipping one control internally under the theme exemption.

5. **P2 [plan]: The baseline drill does not prove relative comparison works.** Clearing a slot already violates the proposed absolute painted/detail floors, so that drill could pass even if fresh-versus-baseline comparison were disconnected. State numeric tolerances and zero-baseline handling, then require a mutation that passes absolute checks but fails the relative comparison against the unchanged real baseline. Retain the real unchanged pass and blurred-capture failure.

6. **P2 [plan]: Reproduction metadata remains incomplete.** Adding startup, scan and theme descriptions to `-Fixture` does not explicitly replace the placeholder launch arguments and working directory, identify the extension-scan inputs, or verify usable metadata contents. `tests/ui_headful_test.cpp:551-555` only checks field-name presence. Record the actual launch context and reproducible fixture contents, reject placeholders, and demonstrate the section’s required reproduction from the sidecar alone.

7. **P2 [plan]: Field counts alone do not validate specifications.** Correct-length rows can contain invalid numbers, non-finite coordinates, reversed bounds, unknown kinds or duplicate region names. Specify semantic validation with file/line diagnostics and regression cases, ensuring invalid rows cannot silently disable or weaken checks.

HIGHEST: P1
PLAN: gaps
OVERALL: needs-attention

- Planned: all seven repair-plan gaps folded into the revised repair plan below (writer, 2026-11-09). (1) Label/value observation on the C++ leg is per-slot pixel comparison against the baseline (section 9 DiffCount-style tolerance per slot), so a renamed label or changed row value changes its slot's pixels and fails naming the slot; the spec record remains the AutoIt half's extraction, deferred to D03 T02 section 7. (2) Contrast relationships are measured in 12-pixel blocks (ink/paper extremes per block, region floor is the minimum qualifying block), with mixed-block and unmeasurable-relationship failures drilled and real light and dark passes. (3) The hook's failure channel gains a third, filesystem-independent destination: a named mutex the guard probes at case end; short writes count as failures and move to the next destination; drills block both file destinations. (4) Clipping is also observed inside panes: painted content touching a slot's inner edge beyond a stated margin fails under the theme exemption through the production measurement; pane extraction failure refuses the case. (5) Relative tolerances are numeric (painted ratio and detail fraction, with zero-baseline handling), and the mutation drill reduces a slot's painting above its absolute floor so only the relative comparison can fail it. (6) Sidecars record the actual launch context (target process and path, fixture contents naming the scan root and theme presses), the pair case rejects placeholder values, and the restaked sidecars are the reproduction record. (7) Spec validation is semantic: finite numbers, ordered bounds inside [0,1], known kinds, unique names, non-negative floors, each with file/line diagnostics and drills.
