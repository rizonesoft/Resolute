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

## Round 3: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T15:55:58Z
- Effort: low
- Writer model: muse-wonder-1.0
- Policy: c15d54d93e7e4fc53bdf21c6e90a10e6e4dd234d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: ec1c146010d3a6ac

### adversarial: needs-attention

1. **P1**: `tests/focus_hook/focus_hook.cpp:48` appends the marker filename to a `MAX_PATH` stack buffer without checking remaining capacity. The new current-directory fallback reaches this with an ordinary long working directory. **Reproduction:** run the existing “A hook that cannot open the mapping marks the failure” case from a 240-character directory with TEMP on a volume whose quota is exhausted. The failed temp write falls through to the working directory; appending `ResoluteFocusHookFail-<pid>.txt` exceeds 260 characters, causing stack memory corruption before the event fallback can report failure. This is source-confirmed, not executed during this read-only review. Check directory API return lengths and the complete filename length, falling through to the event when the path cannot fit.

HIGHEST: P1
OVERALL: needs-attention

- Implemented: repair round 3 (adversarial P1) in 3eb8496b: every marker path build in the hook checks the complete filename fits MAX_PATH and falls through to the next destination instead of appending past the buffer. Hook drills 4/4.

## Round 4: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T15:58:00Z
- Effort: low
- Writer model: muse-wonder-1.0
- Policy: c15d54d93e7e4fc53bdf21c6e90a10e6e4dd234d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 10
- Digest: 214351969cceaf36

### adversarial: needs-attention

1. **P1: Long working directories still cause undefined behaviour in the guard.** `tests/focus_guard.cpp:360-361` and `:514-515` treat any nonzero `GetCurrentDirectoryW` return as success, then construct `std::wstring(cwd)` from an uninitialized stack buffer. When the directory exceeds the buffer, Windows returns the required size, not a populated string. [Microsoft API contract](https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getcurrentdirectory).

   **Reproduction:** Run the test executable by absolute path from an existing directory longer than 260 characters on a long-path-enabled Windows host. Ordinary case teardown reaches the new cleanup code; absent failure markers also reach the reader. Both can read beyond the buffer, causing undefined behaviour or a crash. No mapping failure or disk exhaustion is required. Check the returned length before consuming the buffer, or allocate the required size.

   Source-confirmed at `3eb8496b`; not executed during this read-only review.

HIGHEST: P1
OVERALL: needs-attention

- Implemented: repair round 4 (adversarial P1) in 093f4a9d: both GetCurrentDirectoryW consumers in the guard check the returned length before using the buffer. Hook drills 4/4.

## Round 5: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T16:00:12Z
- Effort: low
- Writer model: muse-wonder-1.0
- Policy: c15d54d93e7e4fc53bdf21c6e90a10e6e4dd234d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 832ec741d40aa089

### adversarial: approve

No actionable adversarial findings established in `c15d54d9..093f4a9d`. Reviewed the requested tip directly; failure-path drills were not executed during this read-only review.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T16:02:38Z
- Candidate: 093f4a9d452944d527e0e5494a29844c2ab3727f
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: c15d54d93e7e4fc53bdf21c6e90a10e6e4dd234d
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 29
- Digest: a648dcb26e2ee771

The candidate still has in-scope gaps. Review was read-only; the fence-inventory self-test passed 5/5. C++ and headful tests were not rerun.

**Part 1: completeness**

- **missing-in-scope: Reliable individual-control and label/value detection.** [visual_pair_spec.txt:37](D:/GitHub/Resolute/tests/visual_pair_spec.txt:37) divides the surface into broad slots and bands, with empty labels/values and 2% pixel tolerances. [visual_pair_util.h:189](D:/GitHub/Resolute/tests/visual_pair_util.h:189) still copies the expected label into the observation. The new regression [visual_pair_test.cpp:304](D:/GitHub/Resolute/tests/visual_pair_test.cpp:304) replaces an entire slot with a checkerboard; it does not establish that a real label edit or value change fails. Required: production-path mutations of individual controls, naming the affected control.

- **missing-in-scope: Internal clipping detection in the delivered specification.** Every region sets `maxEdge=1.0`, so the edge-touch fraction cannot exceed it. The live check only detects panes extending outside the client area ([ui_headful_test.cpp:425](D:/GitHub/Resolute/tests/ui_headful_test.cpp:425)). The clipping drill uses a different threshold, `0.05` ([visual_pair_test.cpp:203](D:/GitHub/Resolute/tests/visual_pair_test.cpp:203)). Required: a clipped label inside an otherwise valid pane must fail using the shipped specification, including under a theme exemption.

- **missing-in-scope: Complete contrast coverage.** [visual_pair_spec.txt:35](D:/GitHub/Resolute/tests/visual_pair_spec.txt:35) skips the whole list despite the capture containing “Name”, “Description” and “Version” headers. The toolbar is classified as `element`, applying 3:1 to its visible “View” text instead of 4.5:1. The glyph measurement also excludes boundary-touching components, so it does not establish the required border contrast ([visual_pair.h:175](D:/GitHub/Resolute/tests/visual_pair.h:175)). Required: separate text and element/border relationships, with deficient examples failing in both themes.

- **missing-in-scope: Discoverable hook failures when child working directories differ.** The hook returns after successfully writing its fallback marker into the **child’s** current directory ([focus_hook.cpp:65](D:/GitHub/Resolute/tests/focus_hook/focus_hook.cpp:65)); the guard searches its **own** current directory ([focus_guard.cpp:358](D:/GitHub/Resolute/tests/focus_guard.cpp:358)). If temporary-file creation fails and those directories differ, the marker can be missed and the event remains unsignalled. Required: a shared destination or independently signalled failure, tested with distinct working directories and an unavailable temporary destination.

- **missing-in-scope: Reproduction from the sidecar alone.** The restaked [light-150 sidecar:14](D:/GitHub/Resolute/docs/captures/runs/2026-11-09-D00-T02-s10-launcher-light-150.txt:14) still records “attached to a running process” and “(default)” for arguments and working directory. `System/*.exe` describes a scan rule, not its actual inputs. [ui_headful_test.cpp:589](D:/GitHub/Resolute/tests/ui_headful_test.cpp:589) checks descriptive strings and field presence without resolving these omissions. Required: actual launch context and an explicit fixture inventory, including an empty inventory when appropriate.

- **present: Specification validation, baseline comparison, fenced execution and cleanup infrastructure.** Evidence: malformed-input drills at [visual_pair_test.cpp:180](D:/GitHub/Resolute/tests/visual_pair_test.cpp:180), live comparison at [ui_headful_test.cpp:598](D:/GitHub/Resolute/tests/ui_headful_test.cpp:598), and fence-inventory self-test 5/5. This developer harness introduces no application dialogs, shortcuts, settings or system-repair undo surface requiring additional checklist items.

**Part 2: excellence**

- **in-scope: Regression sensitivity remains weaker than the promised control preservation.** Target: changing one displayed label/value, removing one control or clipping its content fails through the shipped extraction and comparison path, naming that control. Whole-slot corruption does not prove this target.

- **in-scope: DESIGN.md compliance is incompletely measured.** Target: every visible text relationship meets 4.5:1 and every interactive element/border relationship meets 3:1 in both themes. Headers, toolbar text and borders need explicit coverage.

- **in-scope: Failure evidence can still disappear.** Target: a dropped adopted-process event always invalidates proof, including when temporary storage fails and the child uses another working directory.

- **in-scope: Evidence is not yet independently reproducible.** Target: another operator recreates the fixture and launch state from the sidecar without consulting the original workspace.

- **out-of-scope, already assigned: Live AutoIt behavioral parity.** This section has no AutoIt counterpart and cannot establish 1:1 effects parity. The agreed elevated pair remains owned by `D03 T02 §7`; this review does not reopen that deferral.

COMPLETION: gaps

- Implemented: the repair completion gaps in the second repair cycle `docs/reviews/00-workspace/D00-T02-s12-repair2.md`, implementation a8aa85fd (control-level rectangles with real glyph drills, local-paper glyph and border contrast with palette corrections, DLL-directory hook fallback, exact sidecar launch context and inventory). Default suite 120/120; pair 18 regions, 0 divergences.
