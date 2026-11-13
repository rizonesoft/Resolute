## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T18:13:19Z
- Candidate: 9022b7fe3a78152f2e97f6a72f07868939d57719
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 9022b7fe3a78152f2e97f6a72f07868939d57719
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 5
- Digest: 03829c6ef7b52642

1. **P3**, `todo/00-workspace/TODO-06-reference-data.md:145`: The `Done when:` incorrectly requires all four cases to produce a traceback or lose their reason before the fix. At this commit, staging-write and replacement failures already become `EmbedError` with the original reason when cleanup succeeds. Require before-fix failure demonstrations for destination creation and failed cleanup; retain the other cases as preservation checks. Otherwise, the acceptance condition cannot be met honestly.

HIGHEST: P3
PLAN: gaps
OVERALL: needs-attention

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T18:15:44Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 9022b7fe3a78152f2e97f6a72f07868939d57719
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 3659defd1b6e501f

## adversarial: approve

No in-scope findings. Review included read-only fault injection. Filesystem-writing self-tests were not rerun under the no-modification constraint.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T18:17:30Z
- Candidate: 975e2108c3a1a34f4f469f49979036cd803bfc10
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 9022b7fe3a78152f2e97f6a72f07868939d57719
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 24
- Digest: dc9950bfd4158e06

Part 1: completeness

Reviewed without modifying files. The repair’s behavior is implemented, but one explicit regression requirement remains inadequately checked. Full self-test results below are recorded evidence, not reruns.

1. **present:** Destination creation fails through a named refusal with recovery instructions. Evidence: `scripts/refdata-embed.py:135`, test at `:303`.
2. **present:** Failed staging writes preserve the earlier target and identify an obstructing staging path. Evidence: `scripts/refdata-embed.py:142`, test at `:308`.
3. **present:** Persistence uses staged writing, byte-for-byte read-back and replacement. Evidence: `scripts/refdata-embed.py:155`; successful output and staging cleanup checked at `:286`.
4. **present:** A locked target produces a replacement refusal, preserves its previous bytes and removes staging output. Evidence: `scripts/refdata-embed.py:161`, Windows locked-file test at `:318`.
5. **present:** Retrying after removing the obstruction succeeds. Evidence: test at `scripts/refdata-embed.py:327`, recorded as passing in the Repair item.
6. **present:** Cleanup failures retain the original exception’s reason in the implementation; CLI refusals return exit code 1. Evidence: `scripts/refdata-embed.py:151`, `:153`, `:362`. Recovery documentation: `docs/reference-data.md:187`.
7. **missing-in-scope:** The regression assertion does not verify preservation of the first Windows reason, explicitly required by `todo/00-workspace/TODO-06-reference-data.md:145`. At `scripts/refdata-embed.py:310`, it checks generic wording, staging path and unchanged bytes. An in-memory mutation removing the original reason still passed that assertion. Strengthen this existing case to assert the original reason; no additional test matrix is needed.

Part 2: excellence

Counterparts: AutoIt `_ShowPreferencesDlg` and its handlers, Preferences localization and `[Preferences]`. These describe the separately owned Preferences surface, not this build-time packer. This repair neither establishes nor changes Preferences parity or compliance with `DESIGN.md`; the settled downstream work is not reopened here.

1. **in-scope:** Diagnostic regression protection is weaker than the repair contract. Target: the existing failure test passes with the original Windows reason retained and fails when that reason is omitted or replaced by cleanup information. The read-only mutation demonstrated the current weakness. No additional concrete safety, wording or speed shortfall was established.

Gap list

1. **missing-in-scope:** `scripts/refdata-embed.py:310`: assert the original Windows failure reason, as required by the Repair’s Done when.
2. **in-scope:** The same assertion must reject a mutation that removes or replaces that reason; currently it accepts one.

COMPLETION: gaps

## Writer note: completion gaps

- Planned: the one gap (the staging case does not assert the first Windows reason), as the Repair 2 item in D00 T06 §2, reviewed on `docs/reviews/00-workspace/D00-T06-s2-repair2.md`.
