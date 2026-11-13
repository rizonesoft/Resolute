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
> **Current state:** **Corrected 2026-11-13 (§1 built):** the authoring side exists: the pinned private server (`tools/refdata/server.json`, `tools/refdata/server.ps1`), the schema with the workflow's rules as stored procedures (`data/refdata/schema.sql`), the authoring tool and its self-test (`tools/refdata/refdata.py`), the fixture proposals (`data/refdata/fixtures/`), and `docs/reference-data.md`. Nothing is exported or embedded yet (§2), and no tool reads a dataset. Before §1, nothing existed. BiosCodes carries its 244-key beep database inside language packs (`D04 T05 §1`); no other shipped tool carries reference data (verified by source walk: USBRepair, DVDRepair, MemBoost, and ComIntRep hold no lookup tables). MySQL is a new external dependency, allowed here with a recorded reason: it runs on authoring machines only, never on build machines, CI, or user machines. The build exports datasets to committed generated files, and CI verifies committed output matches a fresh export exactly as it does the plan projection, so nobody needs a server to build.

<!-- claim: exists todo/04-tools-port/TODO-05-bioscodes-complete.md -->
<!-- claim: exists tools/refdata/server.json -->
<!-- claim: exists tools/refdata/server.ps1 -->
<!-- claim: exists tools/refdata/refdata.py -->
<!-- claim: exists data/refdata/schema.sql -->
<!-- claim: exists docs/reference-data.md -->

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

> **Started:** 2026-11-13T02:40:20Z

The database that owns reference data: datasets (one per data family), entries with stable IDs, meanings, sources, versions, and a changelog per change. Plus the workflow a data author follows: connect, edit, review, stamp a version. Server and credentials stay outside the repo exactly like the signing certificate: supplied from the environment, never in a tracked file, argument, or log.

**Corrected 2026-11-13 (fact-check before building):** the section names a database it never says how to get. This machine has no MySQL or MariaDB server or client (`where mysql`, the service list and the program folders are all empty), and the toolchain pins in `toolchain.json` are downloaded by every `scripts/bootstrap.ps1` run, CI's included, so a 250 MB database server there would be fetched by every build that never uses it. The items below decide it, each default recorded with what reversing it costs:

- **The engine is MySQL 8.4 LTS**, the long-term release, as the file's Goal names MySQL. The SQL is kept to what MySQL 8.4 and MariaDB 11 both run (no JSON columns, no generated columns, InnoDB), so a shared authoring server may be either. Reversing costs a schema port.
- **It is an authoring-only component**, pinned in `tools/refdata/server.json` (version, URL, SHA-256 taken from a real download, size) and installed on demand by `tools/refdata/server.ps1 -Install` into `reskit/mysql/`, which is ignored; `scripts/bootstrap.ps1` never fetches it, so no build and no CI run needs it. Reversing costs one manifest and one script.
- **The server an author uses by default is private and local**: `tools/refdata/server.ps1 -Start` runs it on 127.0.0.1 with its data in `%LOCALAPPDATA%\Resolute\refdata\server\`, outside the repository and outside `build/`, which is derived and may be wiped; it is backed up and restored with `refdata.py backup` and `restore`. Connection details, for that server or a shared one, live only in MySQL option files outside the repository, readable by the operator alone, passed to the client as `--defaults-extra-file`, never as an argument or in a log: `local.cnf`, which `-Start` writes when it initializes the private server with a generated root password, and `client.cnf`, which an author writes for a shared server and which, when present, is used instead and never overwritten. Reversing costs nothing: point the option file elsewhere.
- **The tool is stdlib Python driving the `mysql` client** (`tools/refdata/refdata.py`), like the rest of `scripts/`: no database driver is added. The client is the one `-Install` put in `reskit/mysql/bin/`, or the one `RESOLUTE_REFDATA_CLIENT` names.
- **The rules live in the database**: the workflow's steps are stored procedures in `data/refdata/schema.sql`, each refusal a `SIGNAL` naming it, and a proposal of several changes runs in one transaction in one client session, so a refused change leaves no partial data and no partial changelog. Reversing costs moving the checks into the tool.

**Corrected 2026-11-13 (plan review, `docs/reviews/00-workspace/D00-T06-s1.md`, eight findings):** a reviewed version could change and still be stamped on the old approval; a proposal had no transaction; the proof never made a second version; the data sat in `build/`; there was no way to inspect a version before approving it; the server's start and stop did not check what they were acting on; connection failures were unspecified; and the self-test had no boundary against a real authoring database. The items below now require all of these.

**Corrected 2026-11-13 (completion review, `docs/reviews/00-workspace/D00-T06-s1.md`, six gaps; the record went through eight rounds, each finding fixed at its cause):** an approval is not tied to the contents the reviewer inspected; a second rewording of an entry in one proposed version overwrites the first, so the history cannot show what each change was; malformed proposals end in a Python traceback rather than a named refusal; readback cannot tell SQL NULL from the text `NULL`; a first start cut short before initialization finished, or one that cannot write its process record, leaves the server unusable or unowned; and file errors in backup and restore end in a traceback. The Repair 1 items below close each one.

- [x] Pin and install the authoring server: `tools/refdata/server.json` and `tools/refdata/server.ps1` (`-Install`, `-Start`, `-Stop`, `-Status`), the download verified against the pinned hash and refused by name on a mismatch, `reskit/mysql/` and `build/refdata/` ignored. `-Start` records the process it started and its port; `-Status` and `-Stop` act only on a process whose id and image path match that record, so a server that belongs to something else is never touched; a second `-Start` says the server is already running; a port already taken by another listener is refused by name and that listener is left alone; startup that does not answer inside its bound ends the process it started. Done when: `-Install` on this machine installs the pinned version and a second run says it is already pinned, `-Start` then `-Status` report the private server answering on 127.0.0.1, a second `-Start` says it is already running, `-Stop` ends it and a second `-Stop` says it was not running, a start on a port another listener holds is refused with that listener still answering, and a deliberately wrong hash in a copy of the manifest is refused with nothing installed. **Done 2026-11-13:** MySQL 8.4.13, the LTS release MySQL's download page lists, pinned with the SHA-256 of a real download whose MD5 matched the page's (`7b94489d5524dea9b27097068bea25a8`). A copy of the manifest with a zeroed hash: `refused: the download's SHA-256 is e9cd98b1..., the pin says 0000...; nothing was installed`, exit 2, `reskit/mysql` absent. Then `-Install`: `hash verified; unpacking` / `installed: ... Ver 8.4.13 for Win64 on x86_64`, exit 0; again: `already pinned`, exit 0. `-Start`: `initializing the data directory` / `a generated root password was written to ...\local.cnf (not shown)` / `running: pid 96344 on 127.0.0.1:33061`; a second `-Start`: `already running: pid 96344`; `-Status`: `running ... answering`, exit 0. `-Stop`: `stopped`; a second `-Stop`: `was not running`. With a listener on 127.0.0.1:20066: `-Start -Port 20066` exit 2, `refused: port 20066 on 127.0.0.1 is held by another listener; it was left alone`, and `the other listener on 20066 still answers: True`. Driving it found three faults, fixed here: MySQL's download redirector answers PowerShell's web client with an error page, so the download uses the system's curl (`-From <zip>` installs a local copy under the same hash check); `Set-Acl` needs SeSecurityPrivilege once the folder exists, so only the access list is written; and `Get-NetTCPConnection` listed nothing for a listener that held the port, so the port is checked by binding it exclusively. The server is started through `CreateProcess` with no inherited handle and no console window, because `Process.Start` handed it the caller's output pipes and a caller reading `-Start`'s output waited forever (found when the self-test hung); a start on a new port changes `local.cnf` only once the server answers on it.
- [x] Define the schema in `data/refdata/schema.sql`: `datasets`, `entries` (a stable key per entry within its dataset, never reused and never renamed, separate from the row id), `meanings` (the text of an entry in one version, so rewording makes a new meaning and keeps the key), `sources`, `versions` (per dataset: proposed, reviewed, stamped, with author and reviewer; a version is changed only while proposed, a reviewed version is frozen, and `reopen` returns it to proposed and clears its review, so no change can be stamped on an approval given before it), and `changelog` (one row per change, with its reason), with the foreign keys between them. Done when: the schema file creates a fresh database on the private server, and the key-stability rule is stated in `docs/reference-data.md`. **Done 2026-11-13:** `refdata.py init` printed `created 'refdata' from schema.sql`, exit 0, and a second `init` `refused: the database 'refdata' already exists; nothing was changed`; the self-test's first check, `PASS the schema creates a fresh database`. The key rule is the page's "What are the rules?" section. Its first load found a unique key and a foreign key sharing the name `meanings_version`; the key is `meanings_entry_version`.
- [x] Define the authoring workflow in `tools/refdata/refdata.py` and `docs/reference-data.md`: `propose` opens a version with its changes, `review` records a reviewer who is not the author, `stamp` freezes a reviewed version, and every change carries a changelog reason. Refusals by name: stamping an unreviewed version, a reviewer who is the author, a change without a reason, a key reused or renamed, and editing a stamped version. The inspection path is part of the workflow: `list` (datasets and their versions with status), `show <dataset> [<version>]` (the entries and meanings of a version, with sources), `changes <version>` (what a proposed version changes against the last stamped one) and `history <dataset>` (the changelog). Every command fails by name and non-zero, with nothing written and no secret printed, when the option file is missing, the server does not answer, or authentication fails. Done when: the workflow is documented, a trial version is proposed, reviewed and stamped on the private server and then inspected with all four commands against the persisted records, and each refusal is shown. **Done 2026-11-13:** documented in `docs/reference-data.md`. Two choices the item left open, each with its reversal cost: a proposal is a JSON file the tool turns into procedure calls, not SQL an author writes, so no proposal can step around the procedures (reversing costs nothing in the database); and `changes` takes the dataset as well as the version, `changes <dataset> <version>`, because version numbers count per dataset. Trial in its own database, `refdata_trial`: `propose fixture-v1.json` -> `proposed: fixture version 1, 2 change(s)`; `review fixture 1 --as author-one` -> `refused: the reviewer is the author`, exit 1; reviewed by author-two and stamped; `propose fixture-v2.json`; `stamp fixture 2` -> `refused: the version is not reviewed`, exit 1; `changes fixture 2` -> `reworded beep-1-long: One long beep: memory not detected  ->  One long beep: no memory detected in any slot`; reviewed and stamped; `list` -> `fixture v1: stamped, author author-one, reviewer author-two` / `fixture v2: stamped, ...`; `show fixture 1` and `show fixture` print each version's text with `meaning from v1` or `v2`; `history fixture` printed the nine changelog rows with actors and reasons. `backup` wrote 31339 bytes with no `password` in them; `restore` into `refdata_restored` kept the history and the rules (a second `create` of the dataset there was refused), and a second restore into the same name was refused. The other refusals and the three connection failures are in the self-test's output below. Both trial databases were dropped.
- [x] Record the dependency decision in `docs/reference-data.md` and in the dependency note of `AGENTS.md`: MySQL on authoring machines only, why a server (shared authoring with reviewable history) rather than edited files, and the reversal path (the committed export files become the source and the server is dropped). Done when: the decision names its reason and its reversal path. **Done 2026-11-13:** `docs/reference-data.md` "Why a database and not edited files?" names the reason (reviewed, versioned data shared by several authors needs rules every client obeys and a queryable history) and the reversal (the committed export files become the source, checked by a script, and the server is dropped); the dependency rule in `AGENTS.md` records it as the one allowed so far, on authoring machines only.
- [x] Seed one fixture dataset proving the workflow end to end: `python tools/refdata/refdata.py --self-test` creates a database of its own with a unique name (`refdata_selftest_<random>`), refuses if that name exists, and drops only that database when it ends, pass or fail; it notes every other database and their table checksums before and after and fails if any changed. In it: the schema, the fixture `data/refdata/fixtures/fixture.sql`, version 1 proposed, reviewed and stamped; version 2 rewording one entry's meaning and leaving another unchanged, with both versions read back exactly (keys, meanings and changelog rows for each); a proposal of three changes whose third is refused, leaving no row of the first two and no changelog row; a reviewed version changed through `reopen` and refused at `stamp` until reviewed again; the connection failures; and the stamped data surviving a `-Stop` and `-Start` of the private server. Done when: the self-test passes on this machine, quoted, and fails by name with one refusal removed. Cheaper substitute that fails the checkpoint: a schema never instantiated, which is a diagram rather than a database. **Done 2026-11-13:** `python tools/refdata/refdata.py --self-test`: `self-test database: refdata_selftest_94af0ed6 (private server, local.cnf)`, 36 `PASS` lines, among them `refused: a reviewer who is the author`, `refused: stamping an unreviewed version`, `refused: editing a stamped version`, `refused: a change without a reason`, `refused: a key reused`, `refused: a key renamed`, `version 1 reads back exactly`, `version 2 reads back exactly`, `the changelog reads back exactly`, `refused: the third change of a proposal` / `a refused proposal leaves no row and no changelog row`, `refused: changing a reviewed version`, `refused: stamping a reopened version before it is reviewed again`, `refused: a missing option file`, `refused: a server that does not answer`, `refused: failed authentication`, `server -Stop`, `server -Start`, the three read-backs `(after a server restart)`, `the self-test database is dropped`, `every other database is unchanged`, then `self-test: all pass`, exit 0. Against a copy of the schema with the reviewer-is-author check removed: exit 1, first failure `FAIL refused: a reviewer who is the author: exit 0, said 'review: fixture version 1 by author-one'`, and no self-test database left behind. The fixture is two proposals, `data/refdata/fixtures/fixture-v1.json` and `fixture-v2.json`.
- [ ] Repair 1, an approval covers exactly what was inspected: `changes` prints a digest of the version's contents (keys, meanings, sources) and `review` takes it (`--inspected <digest>`), refusing by name when the version changed since. Done when: a self-test case inspects a version, lets a second author reword it, and the review with the earlier digest is refused while one with the new digest passes; the case fails with the digest check removed; and `docs/reference-data.md` says approval covers the digest reviewed.
- [ ] Repair 1, every edit's contents stay in the history: each `add` and `reword` changelog row records the text and source it set, so a second rewording in the same proposed version leaves the first readable in `history`. Done when: a self-test case rewords one entry twice in one version and `history` shows both texts with their sources and reasons, failing with the recorded contents removed.
- [ ] Repair 1, a malformed proposal is refused before anything runs: a proposal that is not an object, has no or a non-list `changes`, holds a change that is not an object, names none or more than one of `add`, `reword` and `rename`, or lacks the text a change needs, is refused naming the change and the field, with no SQL sent. Done when: self-test cases for each shape are refused by name with nothing written, and fail with the validation removed.
- [ ] Repair 1, readback tells NULL from the text NULL: the inspection queries return a value the client cannot confuse with text (a flag column, or a marked encoding), so an entry whose text, key or source is the literal `NULL` reads back as that text. Done when: a self-test case adds an entry with text and source `NULL` and `show`, `changes` and `history` read them back as text, failing with the old readback.
- [ ] Repair 1, a first start cut short is recovered or refused by name: initialization runs into a staging folder and becomes the data folder only when it finished, so a data folder left by an initialization cut short is never taken for a finished one; and a start that cannot write its process record ends the server it launched. Done when: a drill in a home of its own stops initialization part way and the next `-Start` initializes cleanly, and a drill whose process record cannot be written leaves no server running; each fails against the previous script.
- [ ] Repair 1, a file error names the action and the path: backup and restore catch file-system errors (a destination that cannot be written, a file that is locked, a backup that cannot be read) and refuse naming the action, the path, what was kept, and what to do, exiting 1 without a traceback. Done when: self-test cases for an unwritable backup destination and an unreadable backup are refused by name with nothing written and the earlier files kept, and fail with the handling removed.
- [x] Commit: `"data: MySQL schema and authoring workflow"`

**Test checkpoint:** `tools/refdata/server.ps1 -Install`, `-Start` and `-Status` on this machine, and the start refused on an occupied port, quoted; `python tools/refdata/refdata.py --self-test` passes against the private server (a fresh database from the schema, the fixture versioned and stamped with its changelog, every refusal shown), quoted, and fails by name with one refusal removed; the dependency decision names its reason and reversal. Nothing here runs on CI or ships to users. Cheaper substitute that fails the checkpoint: a schema without the workflow, which stores data nobody can change safely.


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
