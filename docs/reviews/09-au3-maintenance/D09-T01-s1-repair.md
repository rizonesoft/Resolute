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
