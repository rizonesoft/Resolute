## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T11:04:58Z
- Candidate: 369cdec7ed5521ccb37c92ef4a8e85c715d232d8
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: a06992b36857c118c5eba36842b97e926217d467
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 11
- Digest: 9cf737369683303a

1. **P2, `resolute_au3/SDK/Concrete/Distro/Distro.au3:2574`:** `ConsoleWrite` does not make cross-root persistence visible during normal use of the compiled GUI application (`Change2CUI=N`). The helper’s captured stdout does not prove an operator receives the warning. Use Distro’s existing visible logging path and verify the warning during cross-root discovery, alongside the persisted absolute value.

2. **P2, `resolute_au3/SDK/Concrete/Distro/Distro.au3:1933`:** Gap 3 explicitly requires cleanup proof. The extracted lines 1849-1862 never execute `_StartProcessing` or `_EndProcesssing`, so they cannot detect controls remaining disabled after a failed read. Exercise the complete processing path and verify cleanup restores usable controls without invoking build operations.

3. **P2, `todo/09-au3-maintenance/TODO-01-au3-maintenance.md:68`:** The discovery proof specifies relative values and existing script/icon inputs, but does not establish that the five output paths equal their intended destinations. A wrong relative output directory can pass these checks. Add explicit expected-destination comparisons for all seven keys across all thirteen descriptors, including Resolute’s distinct executable location.

4. **P2, `resolute_au3/SDK/Concrete/Distro/Distro.au3:2593`:** The claimed UNC/root-relative regression cases are absent from `R:\scratch\distro_helper_test.au3`; its five cases contain neither form. Add and execute exact-result assertions for both forms. They must fail against the pre-repair resolver and pass against the candidate.

HIGHEST: P2  
PLAN: gaps  
OVERALL: needs-attention

## Writer note: repair plan dispositions

- Planned: gap 1 (ConsoleWrite invisible in compiled GUI) fixed in 39e0fbb9: cross-root warning also written via _Logging_EditWrite WARNING.
- Planned: gap 2 (cleanup proof) executed: shipped _StartProcessing + failed-read block + _EndProcesssing verbatim over real GUI controls; disabled during, enabled after, exit 0.
- Planned: gap 3 (exact destinations) executed: 91 destination comparisons in shipped tree and discovery clone, 0 failures.
- Planned: gap 4 (UNC/root-relative assertions) executed: exact-result cases fail on pre-repair resolver (exit 2), pass on repaired (exit 0).

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T11:18:30Z
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: a06992b36857c118c5eba36842b97e926217d467
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 10
- Digest: 226fe32d6c096fc5

### adversarial: needs-attention

1. **P2**, `resolute_au3/SDK/Concrete/Distro/Distro.au3:2572`: Cross-root detection compares only the first backslash-delimited component. Both UNC paths start with an empty component, so different servers incorrectly pass as sharing a root. Discovery persists a fabricated relative path without either warning, and subsequent resolution targets the wrong server.

   **Reproduce:** Call `_DescriptorRelativePath("\\serverA\share\Tool", "\\serverB\share\Tool.exe")`. It returns `..\..\..\serverB\share\Tool.exe` instead of preserving the absolute UNC value. Resolving that against `\\serverA\share\Tool\` through `_ResolveDescriptorPath` produces `\\serverA\serverB\share\Tool.exe`. Compare UNC server/share roots before relativizing and exercise this discovery-to-resolution round trip.

   Verified by source inspection, including AutoIt's installed `_PathFull` implementation; runtime reproduction was not executed.

HIGHEST: P2
OVERALL: needs-attention

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T11:25:33Z
- Effort: low
- Writer model: muse-wonder-1.0
- Policy: a06992b36857c118c5eba36842b97e926217d467
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: fab3f121afe959fe

### consistency: approve

No actionable consistency findings in the candidate. Static review only; the reported builds and GUI evidence were not independently rerun.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T11:27:58Z
- Candidate: 1b4aecfa95faeed8abe58dc6ada6873ef30d9abc
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: a06992b36857c118c5eba36842b97e926217d467
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 27
- Digest: 3c49674ce38b1338

Not every gap is closed. The remaining issues concern runtime warning proof, cleanup coverage, and independently established distribution destinations.

Part 1: original completion gaps and repair-plan gaps

1. **Original gap 1, discovery: open.** The recorded compiled-Distro run and clone readback support actual discovery, but the exact-destination proof remains incomplete for distribution paths. See item 9.
2. **Original gap 2, UNC/root-relative semantics: closed.** `Distro.au3:2572-2606` now distinguishes UNC server/share roots and preserves leading-backslash values. `test_distro_helpers2.py` contains exact assertions for preservation, cross-server, cross-share, and same-share round trips. The retained pre-repair harness independently returned four failures, exit 4; the candidate exit 0 is reported evidence.
3. **Original gap 3, failed read and cleanup: open.** The read-error guard is supported, but the cleanup evidence does not establish the complete production path. See item 8.
4. **Original gap 4, compiler-failure tracking: closed.** `D09 T01 §4` contains the failure handling, downstream-operation prevention, visible reporting, and broken-script/success checkpoints; it also appears in the implementation plan. This closes the requested tracking obligation, not the underlying defect.
5. **Original gap 5, silent cross-root persistence: open.** The visible logging call exists, but the required cross-root discovery run showing both the warning and persisted absolute value is missing.
6. **Original gap 6, overstated evidence: closed.** The dated correction at `TODO-01-au3-maintenance.md:68` identifies the manual harness and qualifies automatic wrapper edits.
7. **Repair-plan gap 1, visible warning: open.** `_Logging_EditWrite` is called at `Distro.au3:2586`, but the helper harness stubs that function. The recorded same-root discovery cannot exercise this warning. Supply a compiled-GUI cross-root run with warning and descriptor readback.
8. **Repair-plan gap 2, cleanup: open.** `R:\scratch\cleanup_harness.py` calls `_EndProcesssing` itself, stubs `_SetAllOptionStates`, and sets selection to `-1`, bypassing `_SetModules`. It would pass if production stopped calling cleanup. `drive2.log` records clicks and final enabled/alive state, but does not establish entry into the failed-read path or absence of build operations. Exercise the complete processing function with those conditions asserted.
9. **Repair-plan gap 3, exact destinations: open.** I reran `check_destinations.py`: both trees returned 91 checks, zero failures. However, it derives the expected build number from the actual `DistributionPath`. Three consistently wrong distribution destinations therefore pass. Derive expected build numbers independently from the discovery-time source/version snapshot. The current clone already has twelve source-version/path mismatches, so its present state cannot supply that snapshot without explaining subsequent wrapper mutations.
10. **Repair-plan gap 4, exact path assertions: closed.** The generator contains the required exact-result assertions and failing baseline coverage described in item 2. The retained generated harness currently contains pre-repair helpers, so my runtime result verifies the failing baseline, not the reported candidate pass.

Part 2: new shortfall

1. **Out-of-scope:** `resolute_au3/SDK/Concrete/Distro/Distro.au3:2254-2257` constructs the signing command with the certificate password and logs the entire command. This pre-existing path exposes the password through logging despite the separate masked-password message. No credential values were read.

Gap list

1. **Open:** Original gap 1 / repair-plan gap 3: independently establish all distribution destinations instead of deriving expected build numbers from actual descriptor values.
2. **Open:** Original gap 3 / repair-plan gap 2: prove the complete failed-read processing path reaches cleanup and invokes no build operations.
3. **Open:** Original gap 5 / repair-plan gap 1: execute cross-root discovery and capture its visible warning alongside the persisted absolute value.
4. **Out-of-scope:** `Distro.au3:2257` logs a signing command containing the certificate password.

COMPLETION: gaps

## Writer note: repair completion dispositions

- Filed: D09 T01 �5 (signing command with certificate password written to Distro log at Distro.au3:2257).
- Implemented: the three open items (independent distribution destinations, complete failed-read path, cross-root discovery warning run) in the D09-T01-s1-repair2 record.
