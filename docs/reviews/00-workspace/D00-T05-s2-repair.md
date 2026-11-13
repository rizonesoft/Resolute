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
