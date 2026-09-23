---
schema_version: 1
id: docs-and-localization
domain: 08-docs-localization
status: draft
title: "TODO-01 -- Documentation and Localization"
depends_on: []
track: D1
---

# TODO-01 -- Documentation and Localization

> **Goal:** Every tool in the suite ships documentation a user can read and a language pack a translator can complete, and both stay current because a surface change that does not update them fails review. A user who opens any tool can find out what it does, what it changes on their machine, and how to undo it.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** `Resolute/Docs/` holds directories for 10 tools, each with `Changes.txt`, `Readme.txt`, and `License.txt`; `Edgemin`, `MemBoost`, and `Watermin` have none. `Resolute/Language/` holds directories for 11 tools plus `BuildSystem`; `Chromin`, `Edgemin`, and `Watermin` have none. Coverage inside the existing packs is uneven: `BiosCodes` has `de`, `en`, `ko`; `ComIntRep` has eleven packs including `af`, `ar`, `el`, `hu`, and `pt-BR`. `Resolute/Docs/Resolute/Readme.txt` describes the suite at version 23.2.0.856 dated 16 November 2025 and still lists `Rescue` among the included tools, which was removed from this repository in commit `e9b6259`. The launcher hardcodes 41 of its 54 menu strings in English, so a completed translation still renders an English menu. There is no user guide beyond the per-tool `Readme.txt` files.

## Inputs

- [`Resolute/Docs/`](../../Resolute/Docs) -- the per-tool documentation, 10 of 13 tools covered
- [`Resolute/Language/`](../../Resolute/Language) -- the per-tool language packs, 11 directories with uneven coverage
- [`Resolute/Docs/Resolute/Readme.txt`](../../Resolute/Docs/Resolute/Readme.txt) -- the suite overview, stale as of commit `e9b6259`
- -> XREF: [`01-sdk-core/TODO-01 §5`](../01-sdk-core/TODO-01-shared-include-contracts.md) -- the localization contract and the hardcoded-string report this file consumes
- -> XREF: [`04-browser-tools/TODO-01 §6`](../04-browser-tools/TODO-01-browser-tool-consolidation.md) -- the three missing browser-tool language packs, created there
- -> XREF: [`05-memboost/TODO-01 §2`](../05-memboost/TODO-01-memboost-trim-and-surface.md) -- MemBoost's settings, which its missing documentation must describe
- -> XREF: [`06-distro-release/TODO-01 §5`](../06-distro-release/TODO-01-build-and-release.md) -- the release procedure that requires a current changelog

## Outcome

- Every tool has a documentation directory with a current `Readme.txt`, `Changes.txt`, and `License.txt`, and the release build refuses without them.
- The suite overview describes the tools that actually exist.
- A language coverage matrix shows, per tool and per language, what is translated and what is missing, generated rather than maintained.
- A user guide covers the surfaces a user actually meets, and a surface change that does not update it fails review.

**Adjacency:** list=applicable @ D08 T01 §2; document=applicable @ D08 T01 §1; settings=not-applicable (documentation has no tunable value; the language selection is the launcher's setting and it owns it); reporting=applicable @ D08 T01 §2; notifications=not-applicable (nothing here notifies anyone); permissions=not-applicable (documentation is readable by whoever can read the install; there are no roles in this suite); audit=applicable @ D08 T01 §1; exchange=applicable @ D08 T01 §2; reverse=not-applicable (documentation changes are reversed by git, which is the honest answer rather than an in-product undo)

**Adjacency rationale:** Exchange belongs to §2 because a `.lng` file is precisely a format somebody outside this repository authors: a translator produces one, and the loader must handle a pack that is partial, differently encoded, or newer than the tool. That is the single most likely defect in this domain and naming it as exchange is what makes it get tested. List and reporting also land on §2 because the coverage matrix is both the thing a translator browses to pick work and the report over the suite's translation state. Audit is §1: `Changes.txt` is the per-tool record of what a version contained, and the current staleness of the suite overview is what happens when nothing enforces it.

## Implementation Order

| Order | Section | Deliverable                                  | Depends On | Status |
| :---: | :-----: | -------------------------------------------- | ---------- | :----: |
|   1   |   §1    | Per-tool documentation, complete and current | --         |  [ ]   |
|   2   |   §2    | Language coverage matrix and partial packs   | D01 T01 §5 |  [ ]   |
|   3   |   §3    | User guide for the surfaces users meet       | §1, D00 T02 §3 |  [ ]   |

---

## 1. Per-Tool Documentation, Complete and Current

Three tools ship with no documentation at all, and the suite overview still lists a tool that was deleted from this repository. Both are the same failure: nothing checks, so nothing stays true.

- [ ] Create `Resolute/Docs/Edgemin/`, `Resolute/Docs/MemBoost/`, and `Resolute/Docs/Watermin/` with `Readme.txt`, `Changes.txt`, and `License.txt` following the shape of the existing ten. Done when: all three exist and their `Readme.txt` describes what the tool actually does, read from the tool rather than from its name.
- [ ] Correct `Resolute/Docs/Resolute/Readme.txt`: remove `Rescue` from the included-tools list, correct the version and date, and check every other tool it names against `SDK/Concrete/`. Done when: the listed tools match the directories that exist, with a dated correction note. Source: commit `e9b6259` removed Rescue; the file still lists it as of 2026-09-16.
- [ ] Audit the other nine `Readme.txt` files the same way: every feature named exists, every path named is real, every version is current. Done when: each file is either confirmed current or corrected, with the check recorded per tool.
- [ ] State in each `Readme.txt` what the tool changes on the user's machine and what the reverse is, for the tools that change anything. Done when: the seven system tools and MemBoost each carry that statement and it matches what the tool actually does.
- [ ] Add the check: a tool directory under `SDK/Concrete/` with no matching `Resolute/Docs/` directory fails the gate. Done when: removing a docs directory makes `scripts/check-all.ps1` exit 1 naming the tool.
- [ ] Wire the documentation duty into review: a section that changes a surface updates that tool's `Readme.txt` in the same commit. Done when: the rule is in `docs/quality/bar.md` and `todo/README.md` already states it.
- [ ] Commit: `"docs: complete and correct the per-tool documentation"`

**Test checkpoint:** `Resolute/Docs/` holds a directory with all three files for every tool under `SDK/Concrete/`. `grep -c Rescue Resolute/Docs/Resolute/Readme.txt` returns 0. Removing a docs directory makes `scripts/check-all.ps1` exit 1 naming the tool, and restoring it makes the gate pass. All three outputs are quoted in the commit body.

## 2. Language Coverage Matrix and Partial Packs

Translation coverage in this suite ranges from eleven languages to none, and nobody can see that without listing directories by hand. A translator cannot find the gap, and a developer cannot tell whether a pack is complete or merely present.

- [ ] Add `scripts/language-matrix.ps1` producing a tool-by-language table from `Resolute/Language/`, marking each cell present, partial, or missing. Done when: it reports all tools and all languages found, and `ComIntRep`'s eleven packs and `BiosCodes`'s three appear correctly. Cheaper substitute: listing directories, which cannot distinguish a complete pack from one with three keys.
- [ ] Define partial precisely: a pack is partial when it lacks a key the tool's `en.lng` defines. Done when: the definition is written into the script header and the matrix uses it.
- [ ] Commit the matrix as `docs/localization/coverage.md`, regenerated rather than maintained. Done when: running the script twice produces identical output and the committed file matches.
- [ ] Prove the loader handles a partial pack: a missing key falls back to `en.lng` and then to the in-code default, and the missing key is reported. Done when: a fixture pack missing one key is driven against one tool and all three behaviors are observed.
- [ ] Prove the loader handles a pack authored elsewhere: a different encoding, a trailing-whitespace key, and an unexpected extra section each load without crashing and without corrupting the surface. Done when: three fixture packs are driven and the behavior is recorded for each.
- [ ] Record what a translator needs: where packs live, what the key sections mean, and how to test a pack against a built tool. Done when: `docs/localization/contributing.md` exists and names the drive procedure.
- [ ] Commit: `"localization: generate the coverage matrix and prove the partial-pack path"`

**Test checkpoint:** `pwsh scripts/language-matrix.ps1` output matches the committed `docs/localization/coverage.md` byte for byte, and its `ComIntRep` row shows eleven languages. A fixture pack missing one key falls back through `en.lng` to the in-code default and reports the missing key. Three malformed fixture packs each load without crashing, with the behavior recorded per pack. All outputs are quoted in the commit body.

## 3. User Guide for the Surfaces Users Meet

The per-tool `Readme.txt` files describe what a tool is. What a user needs when something has gone wrong is what a surface does, what it will change, and how to get back. That is a guide, and there is not one.

**Fidelity:** the guide's screenshots come from `docs/captures/`, so the guide and the conformance check read from the same artifacts. This section builds no surface of its own.

- [ ] Write `docs/user-guide/` with one page per surface a user meets: the launcher, each tool's main window, the settings, the log view, and the About dialog. Done when: every surface named in a Fidelity block anywhere in this tree has a page.
- [ ] Give each destructive surface a "what this changes and how to undo it" section, matching what the tool actually does. Done when: the seven system tools and MemBoost each have one and it matches their `Readme.txt` statement from §1.
- [ ] Illustrate from the committed captures rather than fresh screenshots, so the guide cannot drift from the conformance baseline. Done when: every image in the guide resolves to a file under `docs/captures/`.
- [ ] Add the check: a Fidelity block naming a surface with no guide page fails the gate. Done when: a scratch section naming an undocumented surface makes `scripts/check-all.ps1` exit 1.
- [ ] Record what the guide does not cover and why, so its silence is not read as completeness. Done when: the exclusions are listed with reasons.
- [ ] Commit: `"docs: write the user guide from the captured surfaces"`

**Test checkpoint:** Every surface named in a Fidelity block in `todo/` has a page under `docs/user-guide/`, proven by a script that extracts the surface names and checks for pages. Every image in the guide resolves to a file under `docs/captures/`. A scratch section naming an undocumented surface makes `scripts/check-all.ps1` exit 1. All three outputs are quoted in the commit body.

## Verification

- [ ] Every tool under `SDK/Concrete/` has a `Resolute/Docs/` directory with all three files, and none of them names a tool that no longer exists
- [ ] `pwsh scripts/language-matrix.ps1` regenerates `docs/localization/coverage.md` identically
- [ ] Every surface named in a Fidelity block has a user-guide page, and every guide image resolves under `docs/captures/`
- [ ] `python scripts/todo-graph.py validate` clean
