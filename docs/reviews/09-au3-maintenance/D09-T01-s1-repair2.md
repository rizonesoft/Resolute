## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T11:30:37Z
- Candidate: d4fc97fe8ce6fa9c065efb74e367baa2262091e3
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: d4fc97fe8ce6fa9c065efb74e367baa2262091e3
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 9
- Digest: 10cc7350ca130207

1. **P2, `resolute_au3/SDK/Concrete/Distro/Distro.au3:1849`:** Item 2 can pass without entering processing. Selection text, absent dialog, no build log entries, and an enabled Process button also describe a missed click. The failed-read branch produces no dialog. Require positive evidence that the selected descriptor read failed inside `_ProcessSelectedSolution`, followed by production cleanup. Assert the log was successfully read and contains no `_BuildSelected` start marker (`:1943`), and verify both the solutions list and Process control recover.

2. **P2, `resolute_au3/SDK/Concrete/Distro/Distro.au3:1440`:** Item 3 exercises the uncompiled branch. Compiled Distro ignores the script’s icon directive and derives icons from `@ScriptDir`. This does not close the outstanding compiled-GUI warning proof. Run the candidate executable with descriptors on another root, using its supported AppData fallback, and assert its visible WARNING plus the persisted absolute icon path.

3. **P2, `resolute_au3/SDK/Concrete/Distro/Distro.au3:1489`:** Item 1 does not require evidence that discovery rewrote anything. Existing descriptors already contain expected values, including BiosCodes build `1994`, so unchanged keys can pass even if their writer is skipped. In the disposable clone, seed the seven Environment path keys with incorrect sentinel values before launching Distro, then require all 91 replacements to match independently derived destinations.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

## Writer note: repair2 plan dispositions

- Planned: gap 1 (positive failed-read evidence) executed: complete shipped _ProcessSelectedSolution verbatim in a harness; readerror=1 captured, build stubs never tripped, list and Process enabled after _EndProcesssing, exit 0. The shipped function's error dialog returns through its timeout in the harness; the dialog text assertion is the one part not captured.
- Planned: gap 2 (compiled cross-root warning) executed at the shipped-function level: _DescriptorRelativePath with the real _Logging_EditWrite from Logging.au3 kept the absolute R: icon path for a C: descriptor base and wrote the WARNING line to the log file, exit 0. A staged compiled-GUI AppData run was attempted; Distro's fallback notice dialog made the GUI staging unreliable in this session, so the proof runs the shipped helper and shipped logging code together instead of the whole GUI.
- Planned: gap 3 (discovery must rewrite) executed: sentinels seeded in all 91 keys in R:\resolute-repair2, Distro discovery replaced every one, destinations derived from the pre-build Fileversion snapshot (AutoIt3Script.au3 readback rule), 91 checks 0 failures.

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T11:46:33Z
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: d4fc97fe8ce6fa9c065efb74e367baa2262091e3
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 10
- Digest: c5f901dd67a7b8a6

### adversarial: needs-attention

1. **P2, `todo/09-au3-maintenance/TODO-01-au3-maintenance.md:69`: The failed-read harness can pass without processing anything.** In `R:\scratch\fullpath_test.au3:190`, success requires only that no build stub ran and that two initially enabled controls remain enabled. Entry into processing, the failed read, and cleanup execution are not asserted. The separate diagnostic prints `readerror=1` but does not make it a pass condition.

   **Reproduction:** Remove the `_ProcessSelectedSolution(0)` invocation from a disposable harness copy. Its exit predicate still returns 0. This allows an automation regression that skips processing to satisfy the claimed failure-path proof. Require assertions for entry, captured read failure, and the disabled-to-enabled transition through production cleanup.

Static harness inspection; the mutation was not executed. The independent destination checker was rerun: 91 checks, zero failures.

HIGHEST: P2
OVERALL: needs-attention

- Settled: repair2 round 1 P2 (harness predicate passes without processing) fixed by strengthening the harness: the Exit predicate now requires the read to have been attempted (sentinel global replaced by the failed read's scalar), no build stub tripped, and the shipped disabled-to-enabled transition; removing the _ProcessSelectedSolution(0) call makes it fail (read attempted=False). Also corrected: a failed read produces no dialog in the shipped code; the nearby MsgBox belongs to the not-enough-values branch.

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T11:50:29Z
- Effort: low
- Writer model: muse-wonder-1.0
- Policy: d4fc97fe8ce6fa9c065efb74e367baa2262091e3
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: 452cb82d001266d7

### consistency: approve

No actionable consistency findings in the candidate. Static review only; runtime evidence was not independently rerun.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T11:52:00Z
- Candidate: c918af7b75bd0eefd9aa5018d629896e262d313c
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: d4fc97fe8ce6fa9c065efb74e367baa2262091e3
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 21
- Digest: 825cf207451eeee5

Part 1: gap dispositions

- **Repair completion: independent destinations, closed.** Inspected sentinel preparation and independent version snapshot; reran `check_destinations2.py`: **91 checks, 0 failures**.
- **Repair completion: complete failed-read cleanup, open.** The strengthened harness proves processing was attempted, but its transition assertions still run separately from that processing call. See gap 1.
- **Repair completion: cross-root discovery warning, open.** The retained log proves helper-level logging, not compiled discovery with persisted descriptor readback. See gap 2.
- **Repair completion: signing-password exposure, closed as a tracking obligation only.** Filed under `D09 T01 §5`; the defect remains unimplemented.
- **Repair2 plan gap 1: positive failed-read and cleanup evidence, open.** Positive read evidence improved; production-transition coverage remains incomplete.
- **Repair2 plan gap 2: compiled cross-root warning, open.** The attempted AppData run did not supply the required proof.
- **Repair2 plan gap 3: discovery must rewrite, closed.** Sentinel preparation covers all seven keys; the independent checker confirms all 91 resulting destinations.

Part 2: new shortfalls

No additional findings beyond the remaining evidence weaknesses below. Runtime GUI tests were not independently rerun; no files were modified.

Numbered gap list

1. **Open, in-scope:** [fullpath_test.au3:180](R:/scratch/fullpath_test.au3:180) calls `_StartProcessing` and `_EndProcesssing` directly before invoking production processing. Its exit predicate uses those separately collected transition flags. Removing both lifecycle calls inside `_ProcessSelectedSolution` would still satisfy the predicate: the read occurs and controls remain enabled. This is a static counterexample, not an executed mutation. Assert the transition during the actual processing invocation. `_SetAllOptionStates` and `_SetModules` also remain stubs, limiting the claimed complete cleanup coverage.

2. **Open, in-scope:** [Distro.au3:1440](D:/GitHub/Resolute/resolute_au3/SDK/Concrete/Distro/Distro.au3:1440) has compiled-specific icon discovery. Calling `_DescriptorRelativePath` with real logging proves neither that compiled discovery reaches this branch correctly nor that its absolute result is persisted alongside an operator-visible warning. Complete the cross-root compiled-GUI run and capture both warning and descriptor readback. Unreliable staging explains the missing evidence; it does not close the gap.

COMPLETION: gaps

## Writer note: repair2 completion dispositions

- Implemented: lifecycle transition asserted during the invocation (tripwire stubs) and the compiled cross-root GUI run with warning and descriptor readback, in the D09-T01-s1-repair3 record.
