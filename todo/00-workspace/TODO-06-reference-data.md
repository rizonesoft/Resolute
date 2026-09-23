---
schema_version: 1
id: reference-data
domain: 00-workspace
status: draft
title: "TODO-06 -- Reference Data Platform"
depends_on: []
track: N0
---

# TODO-06 -- Reference Data Platform

> **Goal:** Tools that need reference data get it from one platform: a MySQL database authors and versions the datasets, the build exports each tool's dataset into its executable, and no tool ever touches a database server at runtime. BiosCodes is the first consumer; the platform is built for every tool that requires it.

> [!IMPORTANT]
> **Current state:** Nothing exists. BiosCodes carries its 244-key beep database inside language packs (`D04 T05 §1`); no other shipped tool carries reference data (verified by source walk: USBRepair, DVDRepair, MemBoost, and ComIntRep hold no lookup tables). MySQL is a new external dependency, allowed here with a recorded reason: it runs on authoring machines only, never on build machines, CI, or user machines. The build exports datasets to committed generated files, and CI verifies committed output matches a fresh export exactly as it does the plan projection, so nobody needs a server to build.

<!-- claim: exists todo/04-tools-port/TODO-05-bioscodes-complete.md -->

## Inputs

- [`D04 T05 §1`](../04-tools-port/TODO-05-bioscodes-complete.md) -- the beep database this platform absorbs first
- [`D06 T01 §2`](../06-distro-release/TODO-01-build-and-release.md) -- the one-command build the export step plugs into
- [`D08 T01 §3`](../08-docs-localization/TODO-01-docs-and-localization.md) -- the pack-hygiene rules the remaining UI strings still follow

## Outcome

- A MySQL schema versions reference datasets with changelogs, and a documented workflow authors them.
- The build exports each tool's declared datasets to committed files and embeds them; CI fails on drift.
- The beep database migrates from packs to the platform with zero lookup changes, then grows: more manufacturers, blink codes, more codes.
- Every tool declares the datasets it embeds through one consumer contract, and the framework loader reads them.

**Adjacency:** list=applicable @ D00 T06 §1; document=applicable @ D00 T06 §2; settings=not-applicable (connection details live outside the repo as authoring-machine configuration, never in a tracked file); reporting=applicable @ D00 T06 §2; notifications=not-applicable (no notify channel is added); permissions=not-applicable (one authoring role; the database grants are outside the repo); audit=applicable @ D00 T06 §1; exchange=applicable @ D00 T06 §2; reverse=not-applicable (a bad dataset is replaced by re-export, never rolled back in the tool)

**Adjacency rationale:** List and audit anchor on §1 because the dataset tables are browsed records with a changelog as their trail. Document, reporting, and exchange converge on §2 because the export produces the carried artifact, reports drift, and hands data to the build. Settings, notifications, permissions, and reverse stay not-applicable: server configuration is untracked authoring setup, and datasets move forward by re-export.

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | MySQL schema and authoring workflow | -- |  [ ]   |
|   2   |   §2    | Build-time export, embedding, versioning | §1 |  [ ]   |
|   3   |   §3    | Beep database migration off packs | §2 |  [ ]   |
|   4   |   §4    | Data extension: vendors, blink, more codes | §3 |  [ ]   |
|   5   |   §5    | Consumer contract for tools | §2 |  [ ]   |

---

## 1. MySQL Schema and Authoring Workflow

The database that owns reference data: datasets (one per data family), entries with stable IDs, meanings, sources, versions, and a changelog per change. Plus the workflow a data author follows: connect, edit, review, stamp a version. Server and credentials stay outside the repo exactly like the signing certificate: supplied from the environment, never in a tracked file, argument, or log.

- [ ] Define the schema: datasets, entries, meanings, sources, and versions, with stable entry IDs that survive rewording and the foreign keys between them. Done when: the schema file creates a fresh database and the ID-stability rule is stated.
- [ ] Define the authoring workflow: how an author proposes, reviews, and stamps a dataset version, and what the changelog entry must say. Done when: the workflow is documented and a trial version stamps cleanly.
- [ ] Record the dependency decision: MySQL on authoring machines only, why a server (shared authoring, reviewable history) rather than edited files, and what changes if it ever had to go (export files are the fallback source). Done when: the decision names its reason and its reversal path.
- [ ] Seed the schema empty with one fixture dataset proving the workflow end to end. Done when: the fixture versions, changelogs, and exports. Cheaper substitute that fails the checkpoint: a schema never instantiated, which is a diagram rather than a database.
- [ ] Commit: `"data: MySQL schema and authoring workflow"`

**Test checkpoint:** A fresh database builds from the schema file; the fixture dataset versions with a changelog; the dependency decision names reason and reversal. Nothing here runs on CI or ships to users. Cheaper substitute that fails the checkpoint: a schema without the workflow, which stores data nobody can change safely.

## 2. Build-Time Export, Embedding, Versioning

The pipeline from database to executable: export each tool's declared datasets to committed generated files, embed them in the build, stamp versions, and fail CI on drift between committed files and a fresh export. The committed files are the build's input, so a builder without MySQL builds identically.

**Needs:** C++ toolchain (compile)

- [ ] Export datasets to committed files: one command dumps every declared dataset to its generated file in a fixed format with stable ordering. Done when: two consecutive exports are byte-identical, quoted.
- [ ] Fail CI on drift: the gate re-exports and compares, failing with the dataset and version on any difference. Done when: a deliberately edited export fails naming the dataset, quoted. Cheaper substitute that fails the checkpoint: exporting at build time without committing, which makes every build need a server.
- [ ] Embed per tool at build: each tool embeds exactly the datasets it declares through the §5 contract, no more. Done when: a tool's binary contains its datasets and no other's, proven by inspection.
- [ ] Compress embedded datasets: the export compresses each dataset and the loader decompresses on open, so reference text costs roughly a third of its raw size. Done when: a shipped dataset measures smaller embedded than raw with loads verified, quoted.
- [ ] Stamp and verify versions: every embedded dataset carries its version, readable at runtime, and the stamped-surface agreement test covers it. Done when: the version reads back and a mismatched stamp fails naming the dataset.
- [ ] Plug into the one-command build: the export and drift check run inside `D06 T01 §2` with no new command to remember. Done when: the §2 build runs them, quoted.
- [ ] Commit: `"data: build-time export, embedding, versioning"`

**Test checkpoint:** Exports are byte-stable; drift fails naming the dataset; tools embed exactly their declared sets; versions read back with mismatch failing; the one-command build runs it all. Cheaper substitute that fails the checkpoint: embedding every dataset in every tool, which ships beep codes in a memory trimmer.

-> XREF: D01 T01 §14 -- the loader that reads what this pipeline embeds

## 3. Beep Database Migration Off Packs

The 244-key `[BeepInformation]` database moves from language packs to the platform: every key becomes an entry with a stable ID, every vendor table keeps its composition rule, and the packs keep UI strings only. Zero lookup changes: the migration moves bytes, not answers.

- [ ] Model the beep dataset: vendors, patterns, meanings, footers, and the composition rules from `D04 T05 §1` as schema rows. Done when: every one of the 244 keys maps to an entry and every composition rule maps to a relation.
- [ ] Migrate and verify equality: export the dataset and diff every lookup answer against the pack-driven answers on a fixture. Done when: zero differing answers across all vendors, quoted.
- [ ] Strip the packs: `[BeepInformation]` leaves the packs once the dataset verifies, and pack hygiene passes on what remains. Done when: no pack carries a beep key and the hygiene check is quoted green. Cheaper substitute that fails the checkpoint: leaving the keys in the packs "just in case", which ships two databases that drift.
- [ ] Version the dataset at 1.0 with a changelog recording the migration. Done when: the version stamps and the changelog names the source.
- [ ] Commit: `"data: beep database migration off packs"`

**Test checkpoint:** All 244 keys map to entries; the lookup diff shows zero differences; packs carry no beep key with hygiene green; version 1.0 stamps with a changelog. Cheaper substitute that fails the checkpoint: a migrated dataset without the lookup diff, which trusts the move rather than proving it.

-> XREF: D04 T05 §6 -- the tool migration this dataset enables

## 4. Data Extension: Vendors, Blink, More Codes

The database grows past the AutoIt set: more manufacturers (Lenovo, HP, ASUS, Acer, MSI, Insyde as a full vendor), blink and LED codes (Dell blink patterns, HP blink codes, Lenovo beep-plus-blink), and POST card hex codes for the covered vendors. Every addition cites its vendor documentation; nothing enters from memory.

- [ ] Add the manufacturers: each new vendor gets its pattern table with meanings, following the §3 model. Done when: every new entry cites its vendor document and the per-vendor counts are recorded.
- [ ] Add blink and LED codes as a distinct family (patterns of blinks, not beeps) with its own composition rules. Done when: the family is modeled, populated for Dell and HP at minimum, and distinguishable from beep entries by type. Cheaper substitute that fails the checkpoint: stuffing blink patterns into beep tables, which answers "3 blinks" with a beep meaning.
- [ ] Add POST hex codes for the covered vendors with their checkpoint meanings. Done when: every code cites its vendor document.
- [ ] Version the dataset minor-by-minor with a changelog per addition, and re-verify the §3 equality diff still shows zero differences on the original vendors. Done when: versions stamp, changelogs name sources, and the original answers are untouched, quoted.
- [ ] Commit: `"data: extended vendors, blink, and POST codes"`

**Test checkpoint:** New vendors cite documents; blink is a distinct typed family; POST codes cite documents; versions and changelogs record each addition; the original 244 answers are unchanged. Cheaper substitute that fails the checkpoint: additions without cited sources, which grow the database with folklore.

-> XREF: D04 T05 §6 -- the tool that ships this extended data

## 5. Consumer Contract for Tools

How a tool declares and consumes datasets: the declaration file naming dataset plus minimum version, the loader API the framework provides, the failure presentation when a dataset is missing or too old, and the rule for adding a dataset (new tools file it here with their plan). BiosCodes is the first consumer; the named next candidate is a USB ID database for a future USBRepair need, recorded as a candidate, not a promise.

- [ ] Define the declaration: file, format, dataset names, and minimum versions, with the validation that fails the build on an unknown dataset or an unmet version. Done when: a bad declaration fails naming the dataset, quoted.
- [ ] Define the loader API the framework implements (`D01 T01 §14`): open by name, query entries, read version, with exact failure rules. Done when: the API is specified and the failure texts name their pack keys.
- [ ] Define the missing-or-stale presentation: what the user sees and what the log carries when a dataset fails its check. Done when: both name their texts and the tool never renders half a dataset. Cheaper substitute that fails the checkpoint: silently running on a stale dataset, which answers from old data without saying so.
- [ ] Commit: `"data: consumer contract for tools"`

**Test checkpoint:** Bad declarations fail naming the dataset; the loader API is specified with failure rules; missing-or-stale names its texts and never renders partial data. Cheaper substitute that fails the checkpoint: a contract without the stale rule, which is a declaration file rather than a guarantee.

-> XREF: D01 T01 §14 -- the loader implementing this contract

## Verification

- [ ] The schema builds fresh and the fixture dataset versions with a changelog
- [ ] Exports are byte-stable, drift fails CI, tools embed exactly their declared sets
- [ ] All 244 beep answers are unchanged with the packs carrying no beep key
- [ ] Every added entry cites its vendor document and versions stamp
- [ ] `python scripts/todo-graph.py validate` clean
