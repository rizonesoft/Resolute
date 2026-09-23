---
schema_version: 1
id: repo-face
domain: 00-workspace
status: draft
title: "TODO-05 -- Repo Face and Setup-Path CI"
depends_on: []
track: N0
---

# TODO-05 -- Repo Face and Setup-Path CI

> **Goal:** The repository's public face is true: real screenshots with provenance, a full-structure README an operator can follow cold, contributor files, and a CI lane that runs the quick start verbatim so the instructions cannot rot.

> [!IMPORTANT]
> **Current state:** `README.md` exists with a stack table and a Building section but not the full shape. There is no `LICENSE` file (the GPL v3 text lands via `D06 T01 §8`) and no `CONTRIBUTING.md`. `.github/workflows/plan.yml` runs the plan-gates workflow; `.github/ISSUE_TEMPLATE/` carries bug and feature templates but there is no pull-request template. `toolchain.json` pins llvm-mingw with hashes, `scripts/build.ps1` builds any tool from a clean checkout, and `scripts/check-all.ps1` runs every gate. `scripts/capture-window.ps1` writes provenance sidecars per the `D00 T02 §3` convention. **Groomed 2026-09-23:** the README (101 lines) now states four things the tree contradicts: "No tests" (`tests/` holds the Catch2 suite from `D00 T02 §1`-`§5`), "ships `Resolute.exe` plus `System/ResoluteUI.dll` and `System/Lucide.dll`" and "not yet a single file" (both libraries link static since `D00 T01 §2`; Release ships one 2,744,832-byte `Resolute.exe`), and "built both as `ResoluteUI_static` and as `ResoluteUI` (shared)" (the shared target was removed 2026-09-17, `shared/resolute-ui/CMakeLists.txt:38`). It also never mentions the review wiring in `.conclave/panel.toml`. `resources/logos/` carries the Rizonesoft light and dark SVG pair and `resources/icons/` the Resolute icon, so a branded header needs no new asset. This file owns the README alone: `D08 T01 §5`'s README items hand over to §2 below, and `D08 T01 §5` keeps the bootstrap document.

<!-- claim: exists README.md -->
<!-- claim: absent LICENSE -->
<!-- claim: exists .github/workflows/plan.yml -->
<!-- claim: absent .github/PULL_REQUEST_TEMPLATE.md -->
<!-- claim: exists toolchain.json -->

## Inputs

- [`README.md`](../../README.md) -- exists; §2 rewrites it to the full shape
- [`toolchain.json`](../../toolchain.json) -- the pin file; §2 badges it and §3 re-verifies it
- [`.github/workflows/plan.yml`](../../.github/workflows/plan.yml) -- the plan-gates workflow; §3 adds the setup-path lane beside it
- [`scripts/capture-window.ps1`](../../scripts/capture-window.ps1) -- the capture tool with provenance sidecars; §1 drives it

## Outcome

- The README follows the full structure with exact badges, and a cold reader can go from clone to green build following only it.
- The repo carries contributor files: `CONTRIBUTING.md`, a pull-request template, and the existing issue templates.
- A CI lane runs the README quick start verbatim on every push and has been watched green.
- The operator half of the repo-face work is specified in `D10 T01`, with its dependencies on this file wired.

**Adjacency:** list=not-applicable (the repo face holds no records a user browses); document=applicable @ D00 T05 §2; settings=not-applicable (the lane reads the repo configuration and owns none of its own); reporting=applicable @ D00 T05 §3; notifications=not-applicable (CI status is reporting, and no notify channel is added); permissions=not-applicable (protection rules live in D10 T01 §2, not here); audit=applicable @ D00 T05 §1; exchange=applicable @ D00 T05 §2; reverse=not-applicable (published pixels and prose are replaced by the next run, never rolled back)

**Adjacency rationale:** The face is a document and an exchange surface: the README plus templates are what a contributor reads and writes through, which anchors document and exchange on §2. Proof is the audit trail, so provenance sidecars anchor audit on §1. The CI lane's only user-visible output is its verdict, which is reporting on §3 rather than notifications. Nothing here is a setting, a permission, or a reversible change, so those three stay not-applicable with the reason each belongs elsewhere.

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Visual proof capture with provenance | D00 T01 §4, D00 T02 §3 |  [ ]   |
|   2   |   §2    | README rewrite plus repo-face files | §1 |  [ ]   |
|   3   |   §3    | Setup-path CI plus reproducibility record | §2 |  [ ]   |

---

## 1. Visual Proof Capture

The README shows real pixels from the shipped app, never mockups: the suite builds from a clean checkout through the shipped `D00 T01 §4` one-command build, and two screenshots at no less than 1280 px are captured with the `D00 T02 §3` provenance convention (what it proves, what produced it, the machine, the date). The surfaces captured are the ones that exist at build time.

**Needs:** Windows host (build/test)

- [ ] Build the app from a clean checkout. Done when: `scripts/build.ps1` completes on a checkout with no prior `build/` output, quoted.
- [ ] Capture both themes for every README shot (**Groomed 2026-09-23** for the premium README): each shot has a light and a dark capture of the same surface and state, so the README's `<picture>` pairs follow the reader's GitHub theme. Done when: each pair exists at the same size with matching sidecars naming the theme.
- [ ] Capture two README shots at no less than 1280 px. Done when: both shots come from the built app, both meet the width floor, and both are committed under `docs/captures/`. Cheaper substitute that fails the checkpoint: cropping a window capture up past the floor, which ships blur as proof.
- [ ] Record provenance for each shot. Done when: each shot carries a sidecar with date, host, commit, and the command that produced it, per the §3 convention.
- [ ] Commit: `"docs: README screenshots with provenance"`

**Test checkpoint:** A clean checkout builds by one command; two shots at or above 1280 px exist with complete sidecars; every sidecar field names a real value. Cheaper substitute that fails the checkpoint: mockups or undated captures, which prove the layout was imagined rather than shipped.

-> XREF: D00 T05 §2 -- the README these captures illustrate

## 2. README Rewrite Plus Repo-Face Files

The README follows the full shape: purpose, badges, screenshot, audience, quick start, configuration, usage, troubleshooting, docs and contributing, status and license. Badges are exact: workflow badges for the real workflows, a license shields badge reading GPL-3.0, a toolchain badge matching the `toolchain.json` pin (never "latest"), and a platform badge naming Windows. The file also gains `CONTRIBUTING.md` and a pull-request template beside the existing issue templates. **Groomed 2026-09-23 (operator direction: a beautiful, premium README):** the bar is a README that reads as a finished product's front door on GitHub in both themes, with every figure on it generated or claim-checked so the polish cannot rot into fiction, which is exactly what happened to the current one. This section is the README's only owner; the `D08 T01 §5` README items land here word for word.

- [ ] Write the purpose, audience, and screenshot sections. Done when: the one-liner purpose the `D10 T01 §1` About bar will quote is fixed, the audience is stated, and the §1 shots are embedded.
- [ ] Write the exact badge row. Done when: the plan-gates workflow badge, the GPL-3.0 shields badge, the toolchain badge matching the pinned llvm-mingw version, and the Windows platform badge all render; the setup-path badge is skipped until `D00 T05 §3` ships, with its owner named.
- [ ] Write the quick start and configuration. Done when: the quick start runs clone to green build in copy-paste commands, and every configuration knob is named with its default. Cheaper substitute that fails the checkpoint: a quick start the author never ran cold, which is what §3 exists to prevent.
- [ ] Write usage, troubleshooting, docs and contributing, status and license. Done when: each of the four is present, troubleshooting answers the failures the clean-checkout build actually produced, and the license section names GPL v3 with the `D06 T01 §8` file as its landing place.
- [ ] Add `CONTRIBUTING.md` and the pull-request template. Done when: both exist, contributing states the trunk-master and no-force-push rules, and the template asks for the proof the change owes.
- [ ] Run the gates in the quick start, not just the build: the clone-to-green path executes `scripts/check-all.ps1` so the §3 lane and the D10 T01 §2 branch rule gate on tests and analysis rather than on compilation alone. Done when: the quick start's green includes the gate verdict, quoted from a cold run.
- [ ] Correct the four claims the tree now contradicts before anything is added: no tests, the two shipped DLLs, not yet a single file, and a shared `ResoluteUI` target. Done when: each statement reads true against the tree, quoted beside the command that proves it, and the review wiring (`.conclave/panel.toml`, one writer, GPT review with Grok fallback) has one sentence pointing at `AGENTS.md`.
- [ ] Write the repository `README.md`: what Resolute is, what the two trees are, how to bootstrap and build, and where the plan lives. Done when: a reader who has never seen the project can bootstrap the toolchain and build from it alone (arrived from `D08 T01 §5`).
- [ ] Explain the shape, because it is unusual and will otherwise be misread. Done when: the readme states that `resolute_au3/` is a frozen specification rather than a maintenance target, and that `src/`, `shared/`, and `extensions/` are the work (arrived from `D08 T01 §5`).
- [ ] Point at the contracts rather than restating them. Done when: the readme links `AGENTS.md`, `DESIGN.md`, and `todo/README.md`, and duplicates none of their content (arrived from `D08 T01 §5`).
- [ ] Build a branded hero: the Rizonesoft logo through a `<picture>` element switching `resources/logos/rizonesoft-logo-light.svg` and `rizonesoft-logo-dark.svg` on `prefers-color-scheme`, the product name, the one-line purpose, and the badge row, centered. Done when: GitHub's rendering is captured in its light and dark themes with the logo legible in both, committed under `docs/captures/runs/` with sidecars. Cheaper substitute that fails the checkpoint: a single PNG logo that disappears on one theme.
- [ ] Show the product, not a description of it: the §1 light and dark pairs embedded through `<picture>`, each with alt text that says what the surface does, at a width that stays sharp on a high-DPI display. Done when: both GitHub themes show the matching capture, captured as above, and no image is a mockup.
- [ ] Present the tools as a gallery generated from the tree: one row per tool with its icon, name, one-line job, a frozen marker for the six frozen tools, and its state (AutoIt shipping, C++ planned, in progress, or shipped, read from the plan). Done when: a script writes the gallery between marker comments from `resolute_au3/SDK/Concrete/*/*.sni`, `resources/icons/`, and `todo-graph.py`, runs with `--check` inside `scripts/check-all.ps1`, and a hand edit to the gallery fails the gate by name. Cheaper substitute that fails the checkpoint: a hand-written table, which is how the current README came to list DLLs the build no longer makes.
- [ ] Show progress honestly: a generated status block (sections done over total, per phase, and the next phase that runs) between marker comments, from `python scripts/todo-graph.py plan`. Done when: the same `--check` gate fails a stale block by name, quoted.
- [ ] Draw the architecture: a Mermaid diagram of the layers (UI library, framework, repair contract, tools, launcher) and the one rule between them, rendered by GitHub. Done when: the diagram renders on GitHub in both themes, captured, and names only directories that exist or sections that own them.
- [ ] Make it easy to read at length: a short table of contents, one heading level per idea, the long reference parts (WSL, layout, gates) folded into `<details>` blocks, no em dashes, and one line per paragraph as `AGENTS.md` requires. Done when: a markdown lint plus a link and anchor check over `README.md`, `CONTRIBUTING.md`, and the templates runs in `scripts/check-all.ps1` and fails a broken relative link or anchor by name, quoted.
- [ ] Add the trust files a premium project carries: `SECURITY.md` (how to report a vulnerability, which versions get fixes, the signing status from `D06 T01 §3`), a Support section naming where questions and bugs go, and the changelog link `D06 T01 §6` owns. Done when: each exists and the README links each, checked by the link gate.
- [ ] Commit: `"docs: full-structure README plus contributor files"`

**Test checkpoint:** The four stale claims read true, quoted; the hero, screenshots, and diagram render in both GitHub themes, captured; the gallery and progress blocks regenerate clean under `--check` and a hand edit fails the gate by name; the link and lint gate fails a broken link by name; `SECURITY.md` exists and is linked; every one of the ten README sections is present; every badge renders and the toolchain badge matches the pin file; `CONTRIBUTING.md` and the pull-request template exist; the quick start runs check-all with the gate verdict quoted. Cheaper substitute that fails the checkpoint: a README that reads well but whose quick start was never executed, which §3 catches.

-> XREF: D00 T05 §1 -- the captures this README embeds
-> XREF: D00 T05 §3 -- the CI that runs this quick start verbatim
-> XREF: D10 T01 §1 -- the About bar that quotes this one-liner
-> XREF: D10 T01 §3 -- the cold-reader pass that proofs this README
-> SOURCE: gap-phase0-2026-09-19-ci-gates
-> XREF: D08 T01 §5 -- the README items that arrived here on 2026-09-23; that section keeps the bootstrap document
-> XREF: D06 T01 §10 -- the registry the tool gallery re-points at once it ships

## 3. Setup-Path CI Plus Reproducibility Record

A CI lane runs the README quick start verbatim on every push, per build lane, so the instructions cannot rot. The lane re-verifies the `toolchain.json` pins, records the `.env` applicability as a checked fact, and records what seeds the first run. A pushed-but-never-watched-green workflow does not count: the section closes only after a green run is observed.

- [ ] Run the quick start verbatim per lane. Done when: the workflow executes the README commands word for word across the lanes `CMakePresets.json` defines, and any drift between the two fails the lane. Cheaper substitute that fails the checkpoint: a workflow that approximates the quick start, which lets the README rot while CI stays green.
- [ ] Re-verify the toolchain pins. Done when: the lane checks the downloaded toolchain against `toolchain.json` hashes and fails naming the mismatch.
- [ ] Record the `.env` and first-run-seed facts. Done when: `.env` applicability is recorded as a checked fact with the reason, and whatever seeds the first run (or the finding that nothing does) is recorded beside it.
- [ ] Extend the badge row and watch the lane green. Done when: the §2 badge row carries the setup-path badge, and a pushed run is observed green with its run URL recorded.
- [ ] Commit: `"ci: setup-path lane running the quick start verbatim"`

**Test checkpoint:** The lane fails when the quick start drifts, fails on a deliberately wrong pin, carries the recorded `.env` and seed facts, and has an observed green run URL. Cheaper substitute that fails the checkpoint: a workflow that was pushed but never watched green, which proves the YAML parses and nothing else.

-> XREF: D00 T05 §2 -- the quick start this lane executes
-> XREF: D10 T01 §2 -- the rule that guards this workflow

## Verification

- [ ] The README carries all ten sections and every badge renders with the toolchain badge matching the pin
- [ ] `CONTRIBUTING.md` and the pull-request template exist beside the issue templates
- [ ] The setup-path lane has an observed green run URL and fails on drift and on a wrong pin
- [ ] `python scripts/todo-graph.py validate` clean
