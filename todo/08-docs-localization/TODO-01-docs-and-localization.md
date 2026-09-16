---
schema_version: 1
id: docs-and-localization
domain: 08-docs-localization
status: draft
title: "TODO-01 -- Documentation and Localization"
depends_on: [framework-core]
track: D1
---

# TODO-01 -- Documentation and Localization

> **Goal:** Every tool ships a complete documentation set and speaks every language the suite speaks. The shared strings are translated once and composed into each tool's pack at build time, so a standalone tool still carries everything it needs.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** Measured across the AutoIt tree. Language packs per tool: `Firemin` 35, `ComIntRep` 16, `DVDRepair` 10, `USBRepair` 8, `BiosCodes` 3, `PixRepair` 2, `ReBar` 2, and `MemBoost`, `Ownership`, and `Resolute` 1 each; `Chromin`, `Edgemin`, `Watermin`, and `Distro` have none. Four tools have no documentation directory at all: `Edgemin`, `Watermin`, `MemBoost`, `Distro`. Naming is inconsistent: `DVDRepair` ships `zh-tw` where every other tool ships `zh-TW`, and `USBRepair` ships `sv.ini` among `.lng` files. A translator who translated this suite translated a quarter of it, because the same strings exist in fourteen separate packs.

## Inputs

- [`resolute_au3/Resolute/Language/Firemin/`](../../resolute_au3/Resolute/Language/Firemin) -- the 35-pack set, the largest translation asset the project has
- [`resolute_au3/SDK/Concrete/ReBar/Templates/`](../../resolute_au3/SDK/Concrete/ReBar/Templates) -- `Changes.tpl`, `License.tpl`, `Readme.tpl`: the documentation set every tool owes
- -> XREF: [`01-framework/TODO-01 §4`](../01-framework/TODO-01-framework-core.md) -- the pack loader these files feed
- -> XREF: [`06-distro-release/TODO-01 §2`](../06-distro-release/TODO-01-build-and-release.md) -- the release that composes and ships these packs

## Outcome

- Shared strings are translated once and composed into every tool's shipped pack.
- Every shipped tool has a documentation set.
- Pack naming is consistent and a malformed pack is caught before release.
- The coverage matrix makes a gap visible if it reopens.

**Adjacency:** list=applicable @ D08 T01 §3; document=applicable @ D08 T01 §1; settings=not-applicable (localization reads the framework's language setting and owns none); reporting=applicable @ D08 T01 §3; notifications=not-applicable (documentation notifies nobody); permissions=not-applicable (no role model in documentation); audit=not-applicable (git history is the audit for a text file); exchange=applicable @ D08 T01 §2; reverse=not-applicable (nothing here changes a user's system)

**Adjacency rationale:** Exchange anchors on §2 because a language pack is the project's main exchange format with people outside it: translators receive files, edit them by hand in unknown editors, and hand them back, which makes encoding and round-tripping a real interface concern rather than an implementation detail. List and reporting pair on §3 because the coverage matrix is both the record somebody browses and the report that makes a reopened gap visible.

## Implementation Order

| Order | Section | Deliverable                                | Depends On   | Status |
| :---: | :-----: | ------------------------------------------ | ------------ | :----: |
|   1   |   §1    | Documentation set for every tool           | --           |  [ ]   |
|   2   |   §2    | Shared string pool and build-time composition | D01 T01 §4 |  [ ]   |
|   3   |   §3    | Coverage matrix and pack hygiene           | §2           |  [ ]   |

---

## 1. Documentation Set for Every Tool

Four tools ship with no documentation at all. The templates for what a set should be already exist in the `ReBar` framework directory, which makes this mostly a matter of doing it rather than designing it.

- [ ] Define the documentation set from the existing templates: changes, licence, and readme per tool. Done when: the set is defined and generated from the templates rather than copied by hand.
- [ ] Give every shipped tool a complete set. Done when: no tool is missing one, proven by the conformance check rather than by inspection.
- [ ] Generate what can be generated: version, copyright year, and the changelog. Done when: none of the three is typed by hand in any tool's set.
- [ ] Keep documentation current with the surface. Done when: the rule is stated that a section changing a user-facing surface updates that tool's readme in the same commit.
- [ ] Write the user guide for the surfaces users actually meet. Done when: every shipped tool's main surface has a page and each page names the tool version it describes.
- [ ] Commit: `"docs: a complete documentation set for every tool"`

**Test checkpoint:** Every shipped tool has a complete documentation set, proven by the conformance check. Version, copyright year, and changelog are generated, with none typed by hand. The user guide covers every shipped tool's main surface, each naming its version.

## 2. Shared String Pool and Build-Time Composition

The change that turns an impossible translation job into a tractable one. Most strings in this suite are identical across every tool, and translating them fourteen times is why three tools have no translations at all.

- [ ] Separate the strings: framework strings shared by every tool, and tool-specific strings. Done when: the split is made and the shared set is named.
- [ ] Port the 35 `Firemin` packs into the shared pool where the string is framework-owned. Done when: every shared key that Firemin already has is translated in every language Firemin has, and what was ported is listed.
- [ ] Compose each tool's shipped pack at build time by merging shared and tool-specific keys. Done when: a shipped pack is a single self-contained file per language per tool, and nothing resolves a shared file at runtime. Cheaper substitute that breaks standalone distribution: a shared language directory the tool reads at runtime, which makes a tool depend on a suite install.
- [ ] Prove the composition. Done when: a composed pack is diffed against a hand-built expected pack and matches.
- [ ] Leave tool-specific strings untranslated rather than guessing. Done when: what was ported and what was left is listed per language.
- [ ] Commit: `"localization: one shared string pool, composed at build time"`

**Test checkpoint:** A composed pack is a single self-contained file matching a hand-built expected pack, diffed. No tool resolves a shared language file at runtime, proven by the standalone check. The ported and left-untranslated sets are listed per language.

## 3. Coverage Matrix and Pack Hygiene

- [ ] Fix the naming inconsistencies: `zh-tw` to `zh-TW` in `DVDRepair`, and `sv.ini` to `sv.lng` in `USBRepair`. Done when: every pack in the tree follows one naming rule, checked rather than eyeballed.
- [ ] Validate every pack at build time: encoding, completeness, and duplicate keys. Done when: a malformed pack fails the release rather than shipping.
- [ ] Build the coverage matrix: every tool by every language, with completeness. Done when: the matrix renders and is committed.
- [ ] Report a tool's missing keys from a driven run rather than by inspection. Done when: every shipped tool is driven with every available pack and its missing keys are reported.
- [ ] Decide and record what happens to a language that is incomplete for a tool. Done when: the policy is dated with its cost of changing.
- [ ] Commit: `"localization: coverage matrix and pack hygiene"`

**Test checkpoint:** Every pack follows one naming rule, checked. A malformed pack fails the release, proven with three malformed fixtures. The coverage matrix renders every tool by every language. Every shipped tool is driven with every pack and missing keys are reported.

## Verification

- [ ] Every shipped tool has a complete documentation set
- [ ] Every shipped pack is self-contained, with nothing resolved at runtime from a shared location
- [ ] Every pack follows one naming rule and a malformed pack fails the release
- [ ] The coverage matrix is committed and current
- [ ] `python scripts/todo-graph.py validate` clean
