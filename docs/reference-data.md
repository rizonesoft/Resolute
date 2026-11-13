# Reference data

Some tools need reference data: tables of facts they look up, such as BiosCodes' beep codes. This page is how that data is authored. It is built by `D00 T06` (`todo/00-workspace/TODO-06-reference-data.md`); section 1 built the database and the authoring workflow, and section 2 adds the export the build embeds.

## Where does reference data live?

It is authored in a MySQL database, one dataset per family of data, and versioned there with a changelog. No tool reads a database at runtime: the build exports each tool's datasets into files that are committed and embedded (section 2). So MySQL is needed only on a machine where somebody edits reference data. It is never needed to build, test or run Resolute, and no CI run installs it.

## Why a database and not edited files?

Reference data is shared work that has to be reviewed: two authors may edit one dataset, a change has to say why it was made, and an approved version must not change after approval. A database with the rules in stored procedures enforces all three for every client, keeps the whole history queryable, and lets several authors work against one shared server. Edited files would need a second tool to do the same checks and would leave the history in commit messages.

**How it is reversed:** the committed export files (section 2) become the source, edited by hand and checked by the same rules in a script, and the server is dropped. Nothing at build time or runtime changes, because the build already reads only those files.

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
- The server's data lives in `%LOCALAPPDATA%\Resolute\refdata\server\`, outside the repository and outside `build/`. Back it up with `refdata.py backup <file>`; `refdata.py restore <file> --database <new name>` loads a backup into a new database and never over an existing one. A dump that selects, creates or drops a database (one taken with `mysqldump --databases`) is refused before anything is restored, because it would write outside the database named.
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
python tools/refdata/refdata.py review fixture 3 --as author-two --reason "checked against the manual"
python tools/refdata/refdata.py reopen fixture 3 --as author-one --reason "one more change"
python tools/refdata/refdata.py stamp  fixture 3 --as author-one --reason "release"
```

`data/refdata/fixtures/fixture-v1.json` and `fixture-v2.json` are worked examples.

## How do I see what a version holds?

```powershell
python tools/refdata/refdata.py list                   # datasets and their versions, with status, author and reviewer
python tools/refdata/refdata.py show fixture [2]       # a version's entries, meanings and sources (default: the latest)
python tools/refdata/refdata.py changes fixture 3      # what version 3 adds or rewords against the last stamped version before it
python tools/refdata/refdata.py history fixture        # the changelog: every change and step, by whom, and why
```

Read `changes` before you review: it is exactly what the approval covers.

## What happens when something is wrong?

Every command exits 1 with a named refusal and writes nothing when the option file is missing (`refused: no option file at ...`), the server does not answer (`refused: the server does not answer ...`), or the option file's user or password is not accepted (`refused: authentication failed ...`). A workflow refusal prints the database's own message. Exit 0 means done.

## How is it tested?

```powershell
python tools/refdata/refdata.py --self-test
```

It runs against the private server in a database of its own, `refdata_selftest_<random>`, which it refuses to reuse and drops when it ends, pass or fail. It records every other database's tables and checksums before and after and fails if any changed, so it never touches real authoring data. In between it creates the schema, proposes, reviews and stamps the fixture's two versions and reads both back exactly (keys, meanings, sources and changelog), proves each refusal, proves a refused proposal leaves nothing, proves reopen and re-review, checks the three connection failures, and reads the stamped data back after stopping and starting the server. `--schema <file>` runs it against another copy of the schema: with one refusal removed, it fails naming that refusal.

Nothing here runs on CI or on a user's machine.
