## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T11:55:02Z
- Candidate: 7176a594a6371ee83be6a11ef45d011e0c6c7b2a
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 7176a594a6371ee83be6a11ef45d011e0c6c7b2a
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 5
- Digest: cfba5f7fb2f7cedf

1. **P2, plan:** Item 1 proves lifecycle calls, but still does not assert the claimed disabled-to-enabled transition. In `R:\scratch\fullpath_test.au3`, both tripwires merely set flags; `$g_iStartState` is never checked. Removing the two `GUI_DISABLE` operations from `_StartProcessing` leaves the predicate passing with controls enabled throughout. Assert both controls are disabled inside the start tripwire, then enabled after the production invocation. This closes the remaining transition-proof gap without adding another harness.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

## Writer note: repair3 plan disposition

- Planned: plan P2 (assert the transition, not only lifecycle calls) fixed: the _SetAllOptionStates tripwire records both controls disabled at that point inside _StartProcessing (list via IsWindowEnabled, since GUICtrlGetState returns -1 for a listview), and the _SetModules tripwire records both enabled inside _EndProcesssing. Predicate requires all of: start tripwire, cleanup tripwire, disabled-inside-start, enabled-inside-cleanup, read attempted, no build, enabled after. Harness exit 0; removing the list disable from a copy makes disabled-inside-start=False and the predicate fail.

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T11:57:37Z
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 7176a594a6371ee83be6a11ef45d011e0c6c7b2a
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: ffe28272fa487ea1

### adversarial: needs-attention

1. **P2:** `docs/reviews/09-au3-maintenance/D09-T01-s1-repair3.md:25` relies on a harness that launches unsafe desktop automation. `R:\scratch\fullpath_test.au3:191` starts `dismiss_dialog.au3`, which waits for any `#32770` dialog and clicks its first button without checking process ownership (`dismiss_dialog.au3:1-4`). The failed-read path produces no dialog, leaving this helper waiting after the harness exits. Reproduction: run the harness while another application's confirmation dialog is open; the helper can accept that unrelated prompt. Remove the unnecessary helper invocation. This is a static reproduction, not executed against the user's desktop.

HIGHEST: P2
OVERALL: needs-attention

- Settled: repair3 round 1 P2 (unneeded dialog helper in the harness) fixed by removing the helper invocation from the harness; the failed-read path shows no dialog, and the strengthened predicate passes without it (exit 0).

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T11:58:44Z
- Effort: low
- Writer model: muse-wonder-1.0
- Policy: 7176a594a6371ee83be6a11ef45d011e0c6c7b2a
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 8
- Digest: e7866cafaf9edf7b

### consistency: approve

No actionable consistency findings. The recorded transition assertions match the lifecycle call order, and the cross-root behavior matches compiled discovery and `PortableEdition=0` handling.

Verification limit: inspected source and the retained harness without rerunning GUI tests. The recorded AppData directory was absent, so its descriptor readback and logs could not be independently verified.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T12:00:16Z
- Candidate: 611d3e85430f1c6fb9288ead78f0720434b083c7
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: 7176a594a6371ee83be6a11ef45d011e0c6c7b2a
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 14
- Digest: f78f4988b74a0c52

Part 1: the two open gaps

- **closed: transition during processing.** The retained `R:\scratch\fullpath_test.au3` requires both lifecycle tripwires, both controls disabled inside start, both enabled inside cleanup, a read attempt, and no build call. Removing the processing call, lifecycle calls, or list disable defeats those predicates. Static inspection only; I did not rerun the GUI harness.
- **open: compiled cross-root proof.** The retained driver log confirms the AppData notice and main window, but does not establish the thirteen persisted icon values or their warnings. See gap 1.

Part 2: new shortfalls

No additional findings. Previously filed §4 and §5 remain outside this repair’s scope.

Numbered gap list

1. **Open, in-scope:** [TODO build record, line 69](D:/GitHub/Resolute/todo/09-au3-maintenance/TODO-01-au3-maintenance.md:69) claims thirteen compiled-discovery readbacks and warnings without retained, independently checkable results. The recorded AppData `Concrete` directory is absent. `appdata2.log` ends with a timed discovery wait; its driver exits successfully without checking descriptors or warnings. `crossroot_warn.log` contains only the earlier helper-level BiosCodes warning, and the retained clone’s Distro log contains no matching cross-root warnings. Preserve the compiled run’s thirteen descriptor readbacks and corresponding warning lines, with a checker that fails on missing or incorrect results. The current evidence verifies staging, not the claimed discovery outcome.

COMPLETION: gaps

## Writer note: repair3 completion disposition

- Implemented: retained compiled cross-root evidence in the D09-T01-s1-repair4 record: the run was repeated and its descriptor readbacks, warning lines, driver log, and a checker are retained under docs/captures/d09-t01-s1-crossroot/.
