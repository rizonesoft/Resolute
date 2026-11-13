# Reference data

Some tools need reference data: tables of facts they look up, such as BiosCodes' beep codes. This page is how that data is authored. It is built by `D00 T06` (`todo/00-workspace/TODO-06-reference-data.md`); section 1 built the database and the authoring workflow, and section 2 built the export, its checks, and the embedding of a tool's datasets in its executable.

## Where does reference data live?

It is authored in a MySQL database, one dataset per family of data, and versioned there with a changelog. No tool reads a database at runtime: the build exports each tool's datasets into files that are committed and embedded (section 2). So MySQL is needed only on a machine where somebody edits reference data. It is never needed to build, test or run Resolute, and no CI run installs it.

## Why a database and not edited files?

Reference data is shared work that has to be reviewed: two authors may edit one dataset, a change has to say why it was made, and an approved version must not change after approval. A database with the rules in stored procedures enforces all three for every client, keeps the whole history queryable, and lets several authors work against one shared server. Edited files would need a second tool to do the same checks and would leave the history in commit messages.

**How it is reversed:** the committed export files (section 2) become the source, edited by hand and checked by the same rules in a script, and the server is dropped. The no-server gate then computes a file's digest instead of checking it against the one the database stamped. Nothing at build time or runtime changes, because the build already reads only those files.

This is the one external dependency `AGENTS.md` allows outside the toolchain and the test framework, for the reason above and on authoring machines only.

## How do I get a server?

The private server is MySQL 8.4 LTS, pinned in `tools/refdata/server.json` (version, URL, SHA-256 from a real download, size) and installed on demand. `scripts/bootstrap.ps1` never fetches it.

```powershell
pwsh tools/refdata/server.ps1 -Install    # download, verify the SHA-256, unpack into reskit/mysql (ignored)
pwsh tools/refdata/server.ps1 -Start      # run it on 127.0.0.1:33061; -Port N for another port
pwsh tools/refdata/server.ps1 -Status     # whether the server this script started is running and answering
pwsh tools/refdata/server.ps1 -Stop       # stop it
python tools/refdata/refdata.py init      # create the authoring database 'refdata' from data/refdata/schema.sql
```

- A download whose SHA-256 differs from the pin is refused with nothing installed. `-Install -From <zip>` installs from a local copy under the same check.
- The server's data lives in `%LOCALAPPDATA%\Resolute\refdata\server\`, outside the repository and outside `build/`. A first start initializes it in `data.staging` and makes it `data` only once initialization finished, beside a `data.initialized` mark, so a start cut short leaves nothing the next start mistakes for finished: the next `-Start` discards the staging folder and initializes again. A `data` folder an earlier version of the script made has no mark: it is adopted when its first start had finished (its client file was written), and otherwise refused by name, with nothing deleted; move it aside and `-Start` initializes afresh. A start that cannot write its process record ends the server it launched rather than leave one nothing can stop. Back it up with `refdata.py backup <file>`, which writes the rows only; `refdata.py restore <file> --database <new name>` builds the new database's tables and rules from `data/refdata/schema.sql` and loads the rows as a MySQL user made for that restore alone, allowed only to read, insert and lock tables in the new database. A backup that reaches anywhere else is refused by the server, and the half-made database is dropped; the user is dropped however the restore ends. If a cleanup step itself fails (a file held open, the server gone), the other steps still run and the refusal names what is left and the command that removes it, saying a removal could not be confirmed rather than claiming it. A restore never goes over an existing database, and a dump that selects, creates or drops a database (one taken with `mysqldump --databases`) is refused before anything is touched. A backup writes `<file>.partial` and replaces `<file>` only when the dump finished; a destination that cannot be written, or an earlier backup held open by another program, is refused naming the path, the earlier backup kept byte for byte and the partial dump removed. A backup that cannot be read is refused naming it, and no database is created. A dump that runs past its time is ended and refused by name, its partial file removed. The restore user connects through a short option file written beside yours for the restore alone, which includes yours and then names the restore user and its password, so the client reads every setting of yours exactly as your own connections do (host, port, bind address, TLS mode, CA, certificate and key, relative paths and all) and only the user and password differ; a restore or an upgrade to a shared server therefore verifies the server as you do. The file is removed however the restore ends, or named in the refusal when it cannot be. No option file can make the client go on past an error: every command passes `--skip-force`, so a refused change never commits the ones before it.
- `-Status` and `-Stop` act only on the process `-Start` recorded, by its id and image path, so a MySQL server that belongs to something else is never touched. A start on a port another listener holds is refused, and that listener is left alone.
- The server is started with no handle of its caller's and no console window, so a script that reads `-Start`'s output gets its end.

## Where do the connection details go?

Only into a MySQL option file outside the repository, in `%LOCALAPPDATA%\Resolute\refdata\`, a folder readable by your account and SYSTEM alone:

- `local.cnf` is written by `-Start` when it first initializes the private server, with a generated root password that is never printed. The password is written to `local.cnf.pending` before it is set, and a first start cut short is finished by the next `-Start`; every `-Start` ends only on a server whose root refuses a login without a password.
- `client.cnf` is yours to write for a shared server (`[client]` with `host`, `port`, `user`, `password`). When it exists, `refdata.py` uses it instead of `local.cnf`, and nothing ever overwrites it.

The file is handed to the client as `--defaults-extra-file`. No password is ever an argument, in a tracked file or in a log, and no command prints anything read from it. `--options <file>` names another option file for one command.

## What are the rules?

- **A dataset** is one family of data. **An entry** is one item in it, named by its **key**.
- **A key is stable.** Once used in a dataset it is never reused for another entry and never renamed, whatever the entry's text becomes. A rename is refused by name; add a new key and leave the old one.
- **A meaning** is an entry's text in one version, with its source. Rewording adds a meaning in the new version and keeps the key, so every older version still reads as it was stamped.
- **A version** is proposed, then reviewed, then stamped. It changes only while proposed. A reviewed version is frozen; `reopen` takes it back to proposed and clears its review, so nothing is stamped on an approval given before a change. The reviewer is never the version's author. A dataset has one open version at a time.
- **Every change and every step has a reason**, written to the changelog with who made it.
- **An approval covers exactly what was inspected.** `changes` prints a version's changes and its digest, both read from one snapshot of the database, and `review` names that digest (`--inspected`). The database takes the version's lock, recomputes the digest and refuses the review when it differs, so an edit another author made after you read `changes`, or one still in flight when you review, is never approved unseen: read `changes` again and review what it shows.
- **Every edit stays in the history.** Each add and reword records the text and source it set, so rewording an entry twice in one version leaves both in `history`.
- **A step is one transaction.** Review, reopen and stamp each check the status, change it only from the status they checked, and write their changelog row together, so two authors acting on one version at once cannot both succeed.

The rules live in the database, as stored procedures in `data/refdata/schema.sql`, and each refusal names itself (`refused: the reviewer is the author`). The tables, procedures and view use only what MySQL 8.4 and MariaDB 11 both run, so a shared server may be either.

## How do I change a dataset?

Write a proposal file and propose it. A proposal runs in one transaction: if any change is refused, nothing of it is kept, not even the opened version or a changelog row.

```json
{
  "dataset": "fixture",
  "create": "A description, only when the proposal creates the dataset",
  "author": "author-one",
  "reason": "why this version exists",
  "changes": [
    {"add": "beep-1-long", "text": "One long beep: memory not detected", "source": "Award BIOS 6.0 manual, appendix B", "reason": "first entry"},
    {"reword": "beep-3-short", "text": "...", "source": "...", "reason": "why the text changed"}
  ]
}
```

```powershell
python tools/refdata/refdata.py propose proposal.json                  # opens the next version with these changes
python tools/refdata/refdata.py propose more.json --version 3          # adds changes to proposed version 3
python tools/refdata/refdata.py changes fixture 3                     # read what you approve; note the digest it prints
python tools/refdata/refdata.py review fixture 3 --as author-two --reason "checked against the manual" --inspected <digest>
python tools/refdata/refdata.py reopen fixture 3 --as author-one --reason "one more change"
python tools/refdata/refdata.py stamp  fixture 3 --as author-one --reason "release"
```

`data/refdata/fixtures/fixture-v1.json` and `fixture-v2.json` are worked examples. A proposal whose shape is wrong (not an object, `changes` missing or not a list, a change that is not an object, names no verb or more than one of `add`, `reword` and `rename`, or lacks its `text` or `to`) is refused naming the change and the field before anything is sent to the server.

## How do I see what a version holds?

```powershell
python tools/refdata/refdata.py list                   # datasets and their versions, with status, author and reviewer
python tools/refdata/refdata.py show fixture [2]       # a version's entries, meanings and sources (default: the latest)
python tools/refdata/refdata.py changes fixture 3      # what version 3 adds or rewords against the last stamped version before it
python tools/refdata/refdata.py history fixture        # the changelog: every change and step, by whom, and why
```

Read `changes` before you review: its digest is exactly what the approval covers. Values are read back as text even when they are the word `NULL`, which the client would otherwise print for an empty field.

## How does data get from the database into a tool?

In three steps, and only the first needs the database.

1. **Export**, on an authoring machine: `python tools/refdata/refdata.py export` writes each dataset's latest stamped version to `data/refdata/export/<dataset>.refdata`. The files are committed.
2. **Check**, everywhere: `python scripts/refdata-verify.py` proves each committed file is whole and unedited, with no database. It is a gate of `scripts/check-all.ps1`, so CI runs it on every push.
3. **Embed**, at build: a target names its datasets with one CMake call, and the build compresses each named export and embeds it in that executable and no other.

A builder never needs a server: the committed export files are the build's input.

### What does export write?

Only stamped versions leave the database: a version still proposed or reviewed is not exported, and a dataset with no stamped version is skipped by name and gets no file. A file whose dataset is no longer in the database is removed, and the command says so.

```powershell
python tools/refdata/refdata.py export            # write data/refdata/export/
python tools/refdata/refdata.py export --check    # write nothing; exit 1 naming each file that differs
```

`export --check` is how drift is caught where the database is: it names every file that differs from a fresh export, is missing, or is left over, with its dataset and version. Run it before committing reference-data work.

Every file is written whole beside its target and read back before any is moved into place. So an export that fails (the folder cannot be written, a file is held open, the server cannot be reached) ends non-zero naming the file and the reason, and leaves each earlier file as it was; one that fails after some files were moved names which were.

### What is in an export file?

UTF-8 text with LF line ends, the same bytes on every machine (`.gitattributes` pins the line ends):

```text
resolute-refdata 1
dataset <name>
version <number>
entries <count>
digest <64 hex digits>
<key> TAB <text> TAB <source>
```

- **One line per entry**, in the order the database's own digest reads them. The exporter asks the database for that order and never sorts.
- **A key and a text are escaped:** a backslash as `\\`, a tab as `\t`, a line feed as `\n`, a carriage return as `\r`. Every other character, any Unicode included, is written as it is.
- **A source** is `-` when the entry has none, and `=` followed by the escaped source when it has one. So a source that is the text "-" (written `=-`) and an empty source (written `=`) are both told apart from no source.
- **The digest** is the one the database computes for that version (`rd_version_digest`): a SHA-256 chain over the dataset's name, the version and every entry's key, text and source.

A dataset's name is its file's name, so it is lower-case letters, digits, hyphens and underscores, starting with a letter or digit, at most 63 long, and not a device name Windows reserves (`con`, `nul`, `com1` and the like). The database refuses to create a dataset named otherwise (schema revision 3), and `export` refuses by name, before it touches any file, if a database from an older revision holds one.

**A committed export is never edited by hand.** Change the data in the database, export, review the diff, commit.

### How is a committed export checked without a database?

`scripts/refdata-verify.py` reads every `*.refdata` under `data/refdata/export/` and `data/refdata/fixtures/` and fails, naming the file, the dataset and the version, when a file does not parse, is not in canonical form (written again it must give the same bytes), holds another number of entries than its header says, is not named for its dataset, or carries a digest that is not the digest of its own entries. The last is what catches a hand edit: the digest was stamped by the database, and an edited entry no longer gives it.

What this gate cannot know is whether the database has moved on since the export. That is `export --check`'s job, on the machine that has the database.

### How does a tool get its datasets?

A target names them in its `CMakeLists.txt`, and that is the only place it does:

```cmake
resolute_embed_refdata(BiosCodes beep-codes)
```

`cmake/ResoluteRefdata.cmake` then packs each named export at build time (`scripts/refdata-embed.py pack`) and embeds it in that target as an `RCDATA` resource named `REFDATA_<NAME>`: the dataset's name in capitals, an underscore doubled and a hyphen written `_H`, so no two datasets share a name. A target that names no dataset carries none. A dataset with no export file stops the configure step by name, and an export that fails its check stops the build naming the dataset.

The export file is a declared input of the packed resource, so changing an export rebuilds the resource and relinks the executable; nothing has to be cleaned. `python scripts/refdata-embed.py list <binary>` lists what a built executable carries, reading it as data without running it.

### What is the embedded form?

A header, then the export file's bytes compressed with the Windows Compression API (XPRESS with Huffman, `COMPRESS_ALGORITHM_XPRESS_HUFF`). The same API decompresses it at run time (`compressapi.h`, `cabinet.dll`), so no library is added to the tree. All numbers are little-endian.

| Offset | Size | Holds |
| --- | --- | --- |
| 0 | 8 | The bytes `RSLRDAT1` |
| 8 | 2 | Format, 1 |
| 10 | 2 | Algorithm, 4 |
| 12 | 4 | The dataset's version |
| 16 | 4 | The export's size in bytes, uncompressed |
| 20 | 4 | The compressed size in bytes |
| 24 | 2 | The length of the dataset's name in bytes |
| 26 | name length | The dataset's name, UTF-8 |
| then | 32 | The digest, as raw bytes |
| then | compressed size | The compressed export |

A reader must refuse a dataset, naming it, when the first bytes are not the magic, the format or algorithm is one it does not know, the bytes after the header are not exactly the compressed size, the data does not decompress to exactly the uncompressed size, or the dataset, version and digest in the header are not the ones in the export it holds. It never uses part of a dataset. The framework's loader (`D01 T01 §14`) is written from this table; until it exists, `tests/helpers/refdata_blob.h` is the reader the tests use.

Reference text compresses well: the 244-entry fixture `bulk` is 38,204 bytes exported and 3,499 embedded.

### What do I do when a reference-data gate is red?

| The gate says | What happened | What to do |
| --- | --- | --- |
| `refdata-verify: <file> (dataset X, version N): its entries do not give the digest in its header` | The file was edited after it was exported, or a merge changed it | Restore the file from the commit that exported it, or export again from the database |
| `refdata-verify: ... not in canonical form` or `lines must end in LF` | The file's bytes were changed by a tool (an editor, a line-end conversion) | The same |
| `export: X version N: X.refdata differs from the database` | The database has a newer stamped version than the committed file | Run `export`, review the diff, commit |
| `resolute_embed_refdata(T): the dataset 'X' has no export` | A target names a dataset that was never exported, or its name is misspelled | Export it and commit the file, or correct the name |
| `refdata-embed: refused: <file>: could not be written` or `could not be replaced`, or `the folder could not be created` | The build folder cannot be written, or the packed file is held open by another program | Fix the cause the line gives and build again; the earlier packed file is as it was. If the line names a staging file it could not remove, remove that file by hand |
| `refdata-embed: refused: ...: Windows could not create a compressor` | The Compression API is not available on the build machine | The build needs Windows 8 or later; nothing was embedded |

## How do I move a database to a newer schema?

The schema is at revision 3. Revision 2 recorded what each change set; revision 3 changes no table and makes the database refuse a dataset name that cannot be a file name, because export writes one file per dataset. A database at revision 1 or 2 is moved the same way.

The schema records its revision (`schema_info`). Every command on a database at an older revision is refused, naming the upgrade:

```powershell
python tools/refdata/refdata.py upgrade --database refdata --to refdata_r2
```

`upgrade` backs the old database up, restores the rows into the new name built from the current `data/refdata/schema.sql`, then reads every dataset, version, version text and changelog row back from both and refuses at the first difference, dropping the new database, or naming it with its `DROP DATABASE` command when the drop cannot be confirmed; a copy loaded but never compared is named as unverified. The old database is never changed and keeps every version, but every command refuses it until it is upgraded, so recovery is to fix the cause the refusal names and run `upgrade` again into a new name. An upgrade of a database already at this revision says there is nothing to upgrade. On success, work in the new one (`--database refdata_r2`, or `RESOLUTE_REFDATA_DATABASE=refdata_r2`), and drop the old one once you have checked it. Revision 1 kept only an entry's latest text, so changelog rows written before the upgrade say their contents were not recorded.

## What happens when something is wrong?

Every command exits 1 with a named refusal and writes nothing when, before it writes anything, the option file is missing (`refused: no option file at ...`), the server does not answer (`refused: the server does not answer ...`), or the option file's user or password is not accepted (`refused: authentication failed ...`). A connection lost part way through a restore or an upgrade is reported with what was left and how to remove it. A workflow refusal prints the database's own message. Exit 0 means done.

## How is it tested?

```powershell
python tools/refdata/refdata.py --self-test
```

It runs against the private server in a database of its own, `refdata_selftest_<random>`, which it refuses to reuse and drops when it ends, pass or fail. It records every other database's tables and checksums before and after and fails if any changed, so it never touches real authoring data. In between it creates the schema, proposes, reviews and stamps the fixture's two versions and reads both back exactly (keys, meanings, sources and changelog), proves each refusal, proves a refused proposal leaves nothing, proves reopen and re-review, proves a review is refused on contents changed since they were inspected (one edit made before the review, and one held open in a second session while the review waits), keeps both rewordings of one entry in one version, reads back the word `NULL` as text, refuses each malformed proposal shape with nothing sent, refuses the three file errors with the earlier files kept, upgrades a revision 1 database with nothing lost and refuses an upgrade whose copy lost a row, checks the three connection failures, and reads the stamped data back after stopping and starting the server. `--schema <file>` runs it against another copy of the schema: with one refusal removed, it fails naming that refusal.

Nothing here runs on CI or on a user's machine.
