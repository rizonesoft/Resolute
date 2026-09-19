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
> **Current state (verified 2026-09-16):** Measured across the AutoIt tree.
>
> **Language packs per tool:** `Firemin` 35, `ComIntRep` 16, `DVDRepair` 10, `USBRepair` 8, `BiosCodes` 3, `PixRepair` 2, `ReBar` 2, and `MemBoost`, `Ownership`, and `Resolute` 1 each; `Chromin`, `Edgemin`, and `Watermin` have none, and `Distro` has none and needs none, being discontinued. Naming is inconsistent: `DVDRepair` ships `zh-tw` where every other tool ships `zh-TW`, and `USBRepair` ships `sv.ini` among `.lng` files. A translator who translated this suite translated a quarter of it, because the same strings exist in fourteen separate packs.
>
> **Documentation is worse than "missing".** Three shipped tools have no documentation directory at all: `Edgemin`, `Watermin`, and `MemBoost`. `Distro` has none either and is excluded here, being discontinued rather than ported. What the other ten ship has these measured defects:
>
> - **Metadata is hardcoded and stale.** `ComIntRep/Readme.txt` states `Version: 11.1.3.6508` where the source is at `.6509`, `Release Date: 30 OCTOBER, 2023`, `System Requirements: 7, 8, 8.1, 10` which names no Windows 11 and contradicts the C++ floor of Windows 10 1809, and `Disk Space: 0 MB`, which is a placeholder nobody filled.
> - **`Changes.txt` ranges from 10 lines to 632.** `Ownership` and `PixRepair` carry a single entry; `ComIntRep` carries 632 lines and `Firemin` 489. There is no shared idea of what a changelog entry is.
> - **`License.txt` comes in two shapes and neither is the licence.** Seven tools ship a 7-line GPL v3 **notice**; `Firemin`, `Chromin`, and `Resolute` ship a 63 to 64-line structured agreement. Neither contains the GPL v3 text itself, although every one of them says "You should have received a copy of the GNU General Public License along with this program."
> - **Two different copyright holders appear.** The older files say `Copyright (C) 2023 RIZONESOFT`; the newer say `Copyright © 2025 Rizonetech (Pty) Ltd.` and add that Rizonesoft is a trading name of it.
>
> **The repository `README.md` is 2 lines**: a title and a blank.
>
> `resolute_au3/SDK/Concrete/ReBar/Templates/` holds `Changes.tpl`, `License.tpl`, and `Readme.tpl`, which is what a documentation set was meant to be generated from. `Ownership/Changes.txt` records "Upgraded to Resolute Framework 11", confirming that `ReBar` is the framework by its internal name.

## Inputs

- [`resolute_au3/Resolute/Language/Firemin/`](../../resolute_au3/Resolute/Language/Firemin) -- the 35-pack set, the largest translation asset the project has
- [`resolute_au3/SDK/Concrete/ReBar/Templates/`](../../resolute_au3/SDK/Concrete/ReBar/Templates) -- `Changes.tpl`, `License.tpl`, `Readme.tpl`: the documentation set every tool owes
- -> XREF: [`01-framework/TODO-01 §4`](../01-framework/TODO-01-framework-core.md) -- the pack loader these files feed
- -> XREF: [`06-distro-release/TODO-01 §2`](../06-distro-release/TODO-01-build-and-release.md) -- the release that composes and ships these packs

## Outcome

- Shared strings are translated once and composed into every tool's shipped pack.
- Every shipped tool has a documentation set whose metadata is generated, not typed.
- Every shipped tool's documentation is written rather than inherited, and says what the tool actually does today.
- The repository explains itself to somebody arriving cold.
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
|   4   |   §4    | Rewrite the shipped documentation          | §1           |  [ ]   |
|   5   |   §5    | Repository and developer documentation     | --           |  [ ]   |

---

## 1. The Documentation Contract

A documentation set is currently whatever each tool happened to acquire. This section defines what one **is**, and generates every part of it that should never be typed by a human.

The templates already exist at `resolute_au3/SDK/Concrete/ReBar/Templates/`, so this is mostly a matter of deciding what belongs in each file and wiring the generation, rather than designing from nothing.

- [ ] Define the set: `Readme.txt`, `Changes.txt`, and `License.txt` per tool, and state what each is for. Done when: each file has a stated purpose and a stated audience, and the difference between the readme and the user guide is written down so they do not drift into being the same document twice.
- [ ] **Generate every piece of metadata.** Done when: version, release date, system requirements, and disk space are all produced from the build, and no tool's documentation contains a typed version or date. Cheaper substitute that fails the checkpoint: typing them and fixing them at release, which is how `ComIntRep` came to ship a version one build behind its own source and a requirements line that predates Windows 11.
- [ ] Settle the copyright line and use one. Done when: a single form is chosen between `RIZONESOFT` and `Rizonetech (Pty) Ltd.`, recorded with which is the legal entity, and generated into every tool.
- [ ] **Ship the actual licence, not a notice about it.** Done when: every tool's documentation set includes the full GPL v3 text, because the notice every tool already carries says the user should have received a copy and today none of them conveys one. See `D06 T01 §8`.
- [ ] Define what a changelog entry is, so `Changes.txt` stops ranging from 10 lines to 632. Done when: the entry shape is documented, and the rule for what is worth recording is stated.
- [ ] Give every shipped tool a complete set, including the four that have none. Done when: no tool is missing one, proven by the conformance check rather than by inspection.
- [ ] Write the user guide for the surfaces users actually meet. Done when: every shipped tool's main surface has a page, and each page names the tool version it describes.
- [ ] State the same-commit guide rule. Done when: every new user-facing surface ships its guide page in the same commit as the surface, so pages are written in fresh context and reviewed against behavior; `D01 T01 §12` is the first instance and `D01 T01 §13` the second.
- [ ] Commit: `"docs: the documentation contract, with metadata generated"`

**Test checkpoint:** Every shipped tool has a complete set, proven by the conformance check. No documentation file contains a typed version, date, requirement list, or disk figure, proven by search. The full GPL v3 text ships with every tool. One copyright form appears across the suite. The user guide covers every shipped tool's main surface, each naming its version.

-> XREF: D06 T01 §14 -- the pipeline that renders this contract's guide to offline HTML

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

## 4. Rewrite the Shipped Documentation

Generation fixes the metadata. It does not fix the prose, and the prose is what a user actually reads.

The existing readmes are not empty, which is the trap: `ComIntRep`'s is 52 lines of real writing. But it was written for a suite of fourteen tools that behaved differently from the one being shipped, it describes a portable tool that writes nothing to the registry in a suite that now keeps restore records, and its requirements line stops at Windows 10.

**Fidelity:** no surface of its own; this section produces text, and the captures are unaffected.

- [ ] Rewrite each ported tool's readme against what the C++ tool actually does. Done when: every claim in it is checked against the shipped behaviour, and anything no longer true is corrected rather than carried forward.
- [ ] Say what changed in the rewrite. Done when: each tool records which claims were corrected, so the rewrite is reviewable rather than a wholesale replacement nobody can check.
- [ ] Reconcile the readme with the new capabilities. Done when: undo, restore records, logging, and the accessibility floor are described where they apply, because a user who does not know a repair is reversible will not use it.
- [ ] Normalize the changelogs without inventing history. Done when: existing entries are reformatted to the §1 shape, gaps are marked as gaps rather than filled, and `Ownership` and `PixRepair` are not given a fictional past to match `ComIntRep`'s 632 lines.
- [ ] Write documentation for every tool that has none, which is four today and rises with every new tool. Done when: each has a set that meets the contract on its first shipped build.
- [ ] Keep the tone the suite is written for. Done when: the guidance in `DESIGN.md` section 11 is applied, because a user reading this has a broken machine and is not in a mood for marketing copy.
- [ ] Commit: `"docs: rewrite the shipped documentation against what the tools now do"`

**Test checkpoint:** Every ported tool's readme is checked claim by claim against shipped behaviour, with the corrections listed. Reversibility and logging are described wherever they apply. Changelog gaps are marked rather than filled. Every tool has a set meeting the contract, proven by the conformance check.

## 5. Repository and Developer Documentation

The repository `README.md` is two lines. Somebody arriving at this project cold, including a future maintainer, has `AGENTS.md`, `DESIGN.md`, and a 93-section plan, and nothing that tells them what any of it is.

- [ ] Write the repository `README.md`: what Resolute is, what the two trees are, how to bootstrap and build, and where the plan lives. Done when: a reader who has never seen the project can bootstrap the toolchain and build from it alone.
- [ ] Explain the shape, because it is unusual and will otherwise be misread. Done when: the readme states that `resolute_au3/` is a frozen specification rather than a maintenance target, and that `src/`, `shared/`, and `extensions/` are the work.
- [ ] Write the bootstrap document the build actually needs, following `intelligent-notepad/docs/bootstrap.md` in form: from zero to a green build with no improvisation. Done when: a second person follows it on a machine with no toolchain and records the result.
- [ ] Point at the contracts rather than restating them. Done when: the readme links `AGENTS.md`, `DESIGN.md`, and `todo/README.md`, and duplicates none of their content.
- [ ] Commit: `"docs: a repository readme and a bootstrap document"`

**Test checkpoint:** A reader with no prior exposure bootstraps the toolchain and builds from the readme alone, and the run is recorded. The readme states the role of both trees. It links the three contracts and restates none of them.

## Verification

- [ ] Every shipped tool has a complete documentation set, with no typed version, date, requirement, or disk figure
- [ ] The full GPL v3 text ships with every tool, and one copyright form is used across the suite
- [ ] Every ported tool's readme has been checked claim by claim against shipped behaviour
- [ ] A reader with no prior exposure can bootstrap and build from `README.md` alone
- [ ] Every shipped pack is self-contained, with nothing resolved at runtime from a shared location
- [ ] Every pack follows one naming rule and a malformed pack fails the release
- [ ] The coverage matrix is committed and current
- [ ] `python scripts/todo-graph.py validate` clean
