## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T17:05:37Z
- Candidate: e8b906daa9506dcc5b59865ae7b0f6f04c641721
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: e8b906daa9506dcc5b59865ae7b0f6f04c641721
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 11
- Digest: 7796355b25dff70d

1. **P2, plan, line 139:** The gallery cannot show “in progress” for the six tools mapped through section references. `readme-blocks.py:126` searches `resolve` output for `Started:`, but `todo-graph.py:716–763` never emits it. Require reading the referenced section’s actual start/progress state and testing that path. The existing self-test exercises only file mappings.

2. **P2, plan, lines 139–140:** Generator publication has no failure-safety requirement. `readme-blocks.py:240–248` deletes icons and overwrites files directly, including the entire README. A failed write can truncate authored content or leave incomplete output. Require atomic replacement, readback, and a failed-write test proving existing content survives.

3. **P2, plan, line 128:** “Every configuration knob” omits the existing `build.ps1 -ResetMovedTrees` parameter (`scripts/build.ps1:65–66`). Add its default, cleanup-only effect, and usage, or explicitly narrow the configuration contract.

4. **P2, plan, lines 131–132:** Contributor instructions contradict the governing workflow. `CONTRIBUTING.md:13–16` prescribes a rebased branch and full local gates before review; the PR template repeats the full-gate requirement. `AGENTS.md:147–148,171` requires direct routine work on `main`, focused local checks, and observed CI results. Require the contributor files to distinguish routine trunk work from outside contributions and document the actual testing cadence, including `ci-status.py`.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

## Writer note: plan gaps

- Planned: all four, fixed in the section's own files before the first round: a tool mapped to one plan section reads that section's own Started line (gap 1, `scripts/readme-blocks.py`, two self-test cases); the generator stages, reads back and then moves each file into place, the README last (gap 2, one self-test case with a seeded failure); the README's settings table gains `build.ps1 -ResetMovedTrees` (gap 3); `CONTRIBUTING.md` and the pull-request template tell routine trunk work from an outside contribution and describe the real testing cadence with `ci-status.py` (gap 4).

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T17:13:46Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: e8b906daa9506dcc5b59865ae7b0f6f04c641721
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 8
- Digest: f05f7f5f65d38729

## adversarial: needs-attention

1. **P1: Broken links with incorrect filename casing pass the gate.** `scripts/readme-check.py:120` relies on Windows filesystem resolution, which accepts `design.md` for `DESIGN.md`. GitHub repository paths require the tracked casing. Reproduction: change the README link target `(DESIGN.md)` to `(design.md)` and run the checker on Windows. I reproduced this in memory: the complete checker returned `[]`, while `git ls-tree` lists only `DESIGN.md`. Both development and CI run on Windows, so neither catches this broken link. Validate path-component casing against the tracked paths.

2. **P2: The documented outside-contribution path promises automation that never starts.** `CONTRIBUTING.md:26` and `.github/PULL_REQUEST_TEMPLATE.md:21` say the full `gates` workflow runs on pull requests. `.github/workflows/gates.yml:17` configures only pushes to `main` and manual dispatch; no other workflow supplies the promised PR run. Reproduction: open or update the documented fork PR against `main`. No full gate run starts for that candidate. Contributors relying on these instructions receive no promised pre-merge verification. Align the instructions with actual automation or implement the promised trigger.

HIGHEST: P1
OVERALL: needs-attention

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T17:18:39Z
- Effort: low
- Writer model: claude-fable-5-2
- Policy: e8b906daa9506dcc5b59865ae7b0f6f04c641721
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 8
- Digest: fd7ecd96e68023b0

## consistency: needs-attention

1. **P3, README.md:79:** “only for seeing what would go” implies a preview, but `-ResetMovedTrees` performs deletion. Reproduce on a relocated checkout with existing build trees: the documented command calls `Reset-MovedBuildTrees` at `scripts/build.ps1:336`, which recursively removes those trees and `build/deps` at lines 204 and 209. Describe it as cleanup without rebuilding.

2. **P3, README.md:137:** “Every tool consumes two shared layers” contradicts AGENTS.md’s architecture contract and the README’s own later clarification: only repair tools consume the repair contract. Reproduce by comparing this sentence and the unconditional `tools --> repair` diagram edge with AGENTS.md’s “The two shared layers” table. Qualify both the sentence and diagram to distinguish repair tools.

HIGHEST: P3
OVERALL: needs-attention

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T17:32:37Z
- Candidate: ded1ad7e61596175986205bf8c1c3d8bf6220b3a
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: e8b906daa9506dcc5b59865ae7b0f6f04c641721
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 34
- Digest: 4709cba2e14230dc

The candidate has gaps as a repository-facing feature. It cannot establish Preferences parity: `D00 T05 §2` owns the README, while the supplied Preferences criteria belong to `D01 T03 §2` and its implementation consumer, `D01 T01 §7`.

I reviewed `ded1ad7e`, changed no files, and reran both read-only README checks successfully. All six capture hashes match their sidecars. Self-test and cold-build results below are supplied evidence, not rerun results.

**Part 1: completeness**

1. **present:** Purpose, audience, navigation, configuration defaults and launch instructions. Evidence: `README.md:16`, `:19`, `:36`, `:54`, `:68`, `:84`.
2. **present:** A reproducible clone-to-green path and recognizable success result. Evidence: `README.md:58`; the cold-run record at `todo/00-workspace/TODO-05-repo-face.md:138` reports `check-all: 28 gate(s) ok`.
3. **present:** Current launcher limitations and direct tool execution are disclosed. Evidence: `README.md:92` explains the empty list, missing `RESEXT` declaration and RegStudio elevation.
4. **present:** Theme-aware branding and real launcher imagery with provenance. Evidence: `README.md:3`, `:44`, `:49`; inspected all six supplied captures and verified their hashes.
5. **present:** Generated tool inventory, frozen markers, folding decisions and plan progress. Evidence: `scripts/readme-blocks.py:153`, `:191`; live `--check` passes. Regression cases cover omitted tools, changed plan state and stale generated text at `:334`, `:344`, `:355`, `:369`.
6. **present:** Generated-file persistence protects individual files from partial writes and reads staged bytes back. Evidence: `scripts/readme-blocks.py:261`; failure coverage at `:387` preserves the old README when replacement fails. This is document publication, not application-setting persistence.
7. **present:** Contributor workflow, proof requirements, PR checks, support routing and explicit licence status. Evidence: `CONTRIBUTING.md:15`, `:23`, `:31`; `.github/PULL_REQUEST_TEMPLATE.md:5`; `.github/workflows/gates.yml:22`; `SECURITY.md:5`; `README.md:200`, `:206`.
8. **present:** Automated drift and document checks, including negative cases. Evidence: `scripts/check-all.ps1:295`; `scripts/readme-check.py:201` covers broken links, anchors, images, path casing and prose violations. Live result: `readme-check: 6 files clean`.
9. **missing-in-scope:** Correctly rendered architecture paths. `README.md:141` intends `extensions/<Tool>/`, but both diagram captures display `extensions//`. The required GitHub rendering review missed a visible loss of information.
10. **missing-in-scope:** Accurate partial-bootstrap failure guidance. `README.md:186` says “Nothing was installed.” Bootstrap installs each component inside its loop (`scripts/bootstrap.ps1:148`, `:233`), so a later hash refusal can leave earlier components installed.
11. **missing-out-of-scope:** Continuous proof that the published quick start itself remains executable verbatim. Existing gates execute the gate script, not a checked extraction of the README sequence. Owner: workspace domain, `D00 T05 §3`, explicitly still open at `todo/00-workspace/TODO-05-repo-face.md:166`.
12. **missing-out-of-scope:** The requested user-facing Preferences implementation and behavioral proof are absent from this candidate. Controls, Save/Cancel, validation, refused writes, persisted read-back and reopening tests belong to framework domain `D01 T01 §7`, supported by settings `§2` and specification `D01 T03 §2`. README checks cannot establish their AutoIt parity or `DESIGN.md` compliance.

**Part 2: excellence**

Counterpart: the repository-facing contract in `D00 T05 §2`. `_ShowPreferencesDlg` is the counterpart for the separate Preferences feature, not for these README files.

1. **in-scope:** Architecture wording loses the tool placeholder during rendering (`README.md:141`). **Target:** both GitHub themes visibly show an unambiguous directory such as `extensions/ToolName/`; replacement captures include every diagram node, including the currently cropped UI-library node.
2. **in-scope:** Recovery guidance overstates what a hash refusal leaves unchanged (`README.md:186`). **Target:** explicitly distinguish the refused component from previously installed components and explain retry behavior, with no claim that the entire bootstrap made zero changes.

**Gap list**

1. **missing-in-scope / in-scope:** Repair the swallowed tool-directory placeholder and provide complete diagram captures in both themes.
2. **missing-in-scope / in-scope:** Correct bootstrap failure guidance to acknowledge earlier successfully installed components.
3. **missing-out-of-scope:** Add and observe the verbatim quick-start CI lane, owned by `D00 T05 §3`.
4. **missing-out-of-scope:** Deliver and verify Preferences behavior, persistence, refusal paths and accessibility through `D01 T01 §7`; this candidate provides no Preferences parity proof.

COMPLETION: gaps

## Writer note: completion gaps

- Planned: the two in-scope gaps (the swallowed tool-directory placeholder with a diagram captured whole; the bootstrap row's claim that nothing was installed), as the two Repair items in D00 T05 §2, reviewed on `docs/reviews/00-workspace/D00-T05-s2-repair2.md`.
- Filed: D00 T05 §3 (gap 3, the quick start run verbatim on CI), already in the plan with that owner.
- Not taken: gap 4 (the Preferences dialog's behaviour and persistence). It is not part of this section, which is the repository's README; it is owned by D01 T01 §7 with D01 T03 §2's specification, already in the plan.
