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

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T15:46:06Z
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: c15d54d93e7e4fc53bdf21c6e90a10e6e4dd234d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 10
- Digest: e39ded287c72bd84

## adversarial: needs-attention

1. **P1: The third failure channel vanishes before inspection.** `tests/focus_hook/focus_hook.cpp:70` keeps the failure mutex only in the adopted child. `CaptureLauncher` terminates that child before returning (`tests/ui_headful_test.cpp:331`), while `HookFailures` probes the mutex afterward, at case end (`tests/focus_guard.cpp:483`). Windows destroys the mutex when its last handle closes. **Reproduction:** exercise an adopted child’s mapping failure with both marker creations denied, then let the child exit before calling `HookFailures`. This models unavailable filesystem destinations during resource or access failures. The failure evidence disappears, allowing the guard to accept incomplete observations. The added drill checks a still-running process, so it misses this lifecycle. The parent must retain an independently observable failure state through child teardown.

2. **P3: Malformed tolerances silently disable checks.** `tests/visual_pair_util.h:131-132` parses `maxEdge` and `maxMoved` without checking finiteness, complete consumption, or bounds. **Reproduction:** pass `region|a|||0|0|1|1|0|0|text|nan|nan|check` to `ParseSpec`. It reports no errors; subsequent comparisons against those NaNs always return false, disabling edge and pixel-difference rejection. Values such as `0.02junk` also pass. Apply the validation already used for the other numeric fields. Severity is P3 because exploitation requires malformed repository-controlled spec content.

These findings are based on candidate source inspection; failure drills were not executed.

HIGHEST: P1
OVERALL: needs-attention

- Implemented: repair round 1 findings in 3ee6090b: the failure channel's third destination is now a named event the guard creates at adoption and holds through case end (the mutex died with the child), and ParseSpec validates maxEdge/maxMoved for finiteness, full consumption, and sign, with drills. Default suite 119/119.

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T15:49:05Z
- Effort: low
- Writer model: muse-wonder-1.0
- Policy: c15d54d93e7e4fc53bdf21c6e90a10e6e4dd234d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 8
- Digest: 47b3ba48ffa0934e

### consistency: needs-attention

1. **P1, `tests/visual_pair.h:294`: The real pair comparison bypasses the shared contrast rule.** `ComparePair` calls `Compare(..., false)`, disabling both absolute contrast floors and unmeasured-contrast rejection, then accepts contrast within 90% of the baseline. This contradicts `DESIGN.md:72-74`, the region spec, and §12’s requirement that every control remain above the floor. Recording palette defects elsewhere does not authorize weakening this check.

   **Reproduction:** Use the committed light-150 capture in “The baseline compared with itself passes the pair comparison.” Its status-bar contrast is recorded as 2.78:1 in `todo/01-framework/TODO-02-design-system.md`, below the required 4.5:1, yet self-comparison passes. The headful launcher case uses this same bypass. This is a check accepting what its contract requires it to refuse. Keep the absolute checks enabled and correct the palette at its owning layer.

HIGHEST: P1
OVERALL: needs-attention

- Implemented: repair round 2 (consistency P1) in 4c39c361 and 9a595635: ComparePair again enforces the absolute DESIGN.md floor (no bypass); components thinner than 3px in either dimension (separators, grips, rules) are not glyphs; the one real failure, light status text at 4.47:1, is corrected at its owning layer (LightPalette statusBarText RGB(100) to RGB(90)), the section 9 light status goldens are restaked (131 differing pixels, all the darkened text), and the captures of record are restaked. Default suite 119/119; pair 0 divergences.
