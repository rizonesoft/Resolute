"""Reference-data authoring tool (D00 T06 section 1).

Drives the `mysql` client against the reference-data database. The workflow's rules live in the database as stored
procedures (data/refdata/schema.sql); this tool turns commands and proposal files into calls to them and reports each
refusal by name. Stdlib only, like the rest of scripts/; no database driver is added.

    refdata.py init                                   create the database from the schema
    refdata.py propose <proposal.json> [--version N]  open a version with its changes (or add to proposed version N)
    refdata.py review <dataset> <version> --as NAME --reason TEXT --inspected DIGEST
    refdata.py reopen <dataset> <version> --as NAME --reason TEXT
    refdata.py stamp  <dataset> <version> --as NAME --reason TEXT
    refdata.py list                                   datasets and their versions with status
    refdata.py show <dataset> [<version>]             a version's entries and meanings, with sources
    refdata.py changes <dataset> <version>            what a version changes against the last stamped one before it,
                                                      and the digest a review of what it shows names
    refdata.py history <dataset>                      the changelog
    refdata.py backup <file>                          dump the database (schema, routines, data) to a file
    refdata.py restore <file> --database NAME         load a dump into a new database of that name
    refdata.py upgrade --database OLD --to NEW        copy a database at an older schema revision into NEW at this one
    refdata.py --self-test [--schema FILE]            prove the workflow on a database of its own

Connection details come only from a MySQL option file outside the repository: client.cnf beside local.cnf in
%LOCALAPPDATA%\\Resolute\\refdata when an author has written one for a shared server, otherwise the local.cnf that
`tools/refdata/server.ps1 -Start` writes for the private server. It is passed as --defaults-extra-file; no password is
ever an argument, and nothing this tool prints comes from the option file. Exit codes: 0 done, 1 refused.
"""

from __future__ import annotations

import argparse
import contextlib
import ctypes
import io
import json
import os
import re
import secrets
import ssl
import subprocess
import sys
import tempfile
import time
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
SCHEMA = REPO / "data" / "refdata" / "schema.sql"
FIXTURES = REPO / "data" / "refdata" / "fixtures"
SERVER_SCRIPT = REPO / "tools" / "refdata" / "server.ps1"
HOME = Path(os.environ.get("LOCALAPPDATA", str(Path.home()))) / "Resolute" / "refdata"
LOCAL_CNF = HOME / "local.cnf"
CLIENT_CNF = HOME / "client.cnf"
DEFAULT_DATABASE = "refdata"
SYSTEM_DATABASES = ("mysql", "information_schema", "performance_schema", "sys")
TIMEOUT_SECONDS = 120
# The schema revision this tool and data/refdata/schema.sql are at (its schema_info row). A database without the
# table is at revision 1, the schema before D00 T06 section 1's Repair 1.
SCHEMA_REVISION = 2


class Refused(Exception):
    """A refusal by name: the workflow's, the connection's, or the tool's."""


class RestoreLeftovers(Refused):
    """A restore that created its database and then could not clean up everything. loaded says whether the backup's rows
    were loaded into it, so a caller knows the database is this restore's own and in what state, and never has to
    guess that from whether a database of that name exists, which another author's work can also make true."""

    def __init__(self, message: str, loaded: bool):
        super().__init__(message)
        self.loaded = loaded


SENT = [0]   # client sessions started, so the self-test can show a refusal sent nothing


def client_path(name: str = "mysql") -> Path:
    if name == "mysql" and os.environ.get("RESOLUTE_REFDATA_CLIENT"):
        return Path(os.environ["RESOLUTE_REFDATA_CLIENT"])
    base = Path(os.environ["RESOLUTE_REFDATA_CLIENT"]).parent if os.environ.get("RESOLUTE_REFDATA_CLIENT") else REPO / "reskit" / "mysql" / "bin"
    return base / f"{name}.exe"


def option_file(explicit: str | None = None) -> Path:
    if explicit:
        path = Path(explicit)
    elif CLIENT_CNF.exists():
        path = CLIENT_CNF
    else:
        path = LOCAL_CNF
    if not path.is_file():
        raise Refused(f"refused: no option file at {path}; start the private server (tools/refdata/server.ps1 -Start) or write client.cnf for a shared one")
    return path


def check_name(database: str) -> str:
    if not re.fullmatch(r"[A-Za-z0-9_]{1,64}", database):
        raise Refused(f"refused: '{database}' is not a database name this tool accepts (letters, digits, underscore)")
    return database


def sql_str(value) -> str:
    """A MySQL string literal, or NULL."""
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        raise Refused("refused: a proposal value is true or false where text or a number belongs")
    if isinstance(value, int):
        return str(value)
    text = str(value)
    text = text.replace("\\", "\\\\").replace("'", "''").replace("\0", "\\0").replace("\x1a", "\\Z")
    return f"'{text}'"


def _unescape(field: str):
    if field == "NULL":
        return None
    out, i = [], 0
    while i < len(field):
        c = field[i]
        if c == "\\" and i + 1 < len(field):
            n = field[i + 1]
            out.append({"n": "\n", "t": "\t", "0": "\0", "\\": "\\"}.get(n, n))
            i += 2
        else:
            out.append(c)
            i += 1
    return "".join(out)


def marked(column: str) -> str:
    """A nullable column as the client cannot confuse it with text: 'N' for SQL NULL, 'V' then the value otherwise.
    The batch client prints SQL NULL and the text NULL alike, so an entry whose text is NULL would read back as none."""
    return f"IF({column} IS NULL, 'N', CONCAT('V', {column}))"


def unmark(field: str | None) -> str | None:
    if field is None or field[:1] not in ("N", "V") or (field[:1] == "N" and field != "N"):
        raise Refused(f"refused: a marked value read back as {field!r}, which is neither NULL nor a value")
    return None if field == "N" else field[1:]


def unmark_text(field: str | None) -> str:
    """A marked value from a column that is never NULL (a key, a name): NULL there means the read went wrong."""
    value = unmark(field)
    if value is None:
        raise Refused("refused: a column that is never NULL read back as NULL")
    return value


def _end_tree(proc: subprocess.Popen) -> None:
    subprocess.run(["taskkill", "/T", "/F", "/PID", str(proc.pid)], capture_output=True, check=False)
    proc.wait(timeout=30)


def _classify(stderr: str, database: str | None) -> str:
    match = re.search(r"ERROR (\d+) \(([0-9A-Z]+)\)(?: at line \d+)?: (.*)", stderr)
    code = int(match.group(1)) if match else None
    if code in (2002, 2003, 2005, 2013, 2006):
        return "refused: the server does not answer (start it with tools/refdata/server.ps1 -Start, or check the option file's host and port)"
    if code == 1045:
        return "refused: authentication failed (the option file's user or password is not accepted)"
    if code == 1049:
        return f"refused: the database '{database}' does not exist (create it with refdata.py init)"
    if match and match.group(2) == "45000":
        return match.group(3).strip()
    if match:
        return f"refused: the server said: ERROR {match.group(1)}: {match.group(3).strip()}"
    first = stderr.strip().splitlines()[0] if stderr.strip() else "no message"
    return f"refused: the client failed: {first}"


def run_sql(sql: str, *, options: Path, database: str | None = None, tool: str = "mysql", extra: tuple[str, ...] = ()) -> list[list]:
    """Runs SQL through the client in one session; returns the rows of every result set, or raises Refused."""
    SENT[0] += 1
    exe = client_path(tool)
    if not exe.is_file():
        raise Refused(f"refused: no {tool} client at {exe} (run tools/refdata/server.ps1 -Install, or set RESOLUTE_REFDATA_CLIENT)")
    # The option file by its name, from its own folder: the mysql client could not open a --defaults-extra-file path
    # holding a character such as é (measured 2026-11-13), and a Windows profile folder may hold one.
    args = [str(exe), f"--defaults-extra-file={options.name}", "--connect-timeout=5", "--default-character-set=utf8mb4"]
    if tool == "mysql":
        # --skip-force on the command line outranks any option file: with force, the client goes on past a failed
        # statement and exits 0, so a refused change would commit the ones before it and report success.
        args += ["--batch", "--skip-column-names", "--skip-force"]
    args += list(extra)
    if database:
        args.append(database)
    proc = subprocess.Popen(args, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=str(options.parent))
    try:
        out, err = proc.communicate(input=sql.encode("utf-8"), timeout=TIMEOUT_SECONDS)
    except subprocess.TimeoutExpired:
        _end_tree(proc)
        raise Refused(f"refused: the client did not finish within {TIMEOUT_SECONDS}s and was ended") from None
    stderr = err.decode("utf-8", "replace")
    if proc.returncode != 0:
        raise Refused(_classify(stderr, database))
    text = out.decode("utf-8", "replace")
    return [[_unescape(f) for f in line.split("\t")] for line in text.splitlines() if line != ""]


class Session:
    def __init__(self, options: Path, database: str):
        self.options = options
        self.database = check_name(database)

    def sql(self, statement: str) -> list[list]:
        return run_sql(statement, options=self.options, database=self.database)

    def exists(self) -> bool:
        rows = run_sql(f"SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name = {sql_str(self.database)};", options=self.options)
        return rows[0][0] == "1"


def schema_revision(s: Session) -> int:
    has = s.sql(f"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = {sql_str(s.database)} AND table_name = 'schema_info';")
    if has[0][0] == "0":
        return 1
    rows = s.sql("SELECT MAX(revision) FROM schema_info;")
    return int(rows[0][0]) if rows and rows[0][0] is not None else 1


def require_current(s: Session) -> None:
    revision = schema_revision(s)
    if revision < SCHEMA_REVISION:
        raise Refused(f"refused: the database '{s.database}' is at schema revision {revision}, older than this tool's {SCHEMA_REVISION}; "
                      f"copy it to this revision with refdata.py upgrade --database {s.database} --to <a new name>; nothing was changed")
    if revision > SCHEMA_REVISION:
        raise Refused(f"refused: the database '{s.database}' is at schema revision {revision}, newer than this tool's {SCHEMA_REVISION}; update this checkout")


# ----- commands ---------------------------------------------------------------------------------------------------

def cmd_init(s: Session, schema: Path = SCHEMA) -> int:
    if s.exists():
        raise Refused(f"refused: the database '{s.database}' already exists; nothing was changed")
    run_sql(f"CREATE DATABASE `{s.database}` CHARACTER SET utf8mb4;", options=s.options)
    try:
        run_sql(schema.read_text(encoding="utf-8"), options=s.options, database=s.database)
    except Refused:
        run_sql(f"DROP DATABASE `{s.database}`;", options=s.options)
        raise
    print(f"created '{s.database}' from {schema.name}")
    return 0


VERBS = ("add", "reword", "rename")


def validate_proposal(proposal) -> None:
    """Refuses a proposal whose shape is wrong, naming the change and the field, before any SQL is built or sent."""
    if not isinstance(proposal, dict):
        raise Refused(f"refused: the proposal is {type(proposal).__name__}, not an object; nothing was sent")
    for field in ("dataset", "author"):
        if not isinstance(proposal.get(field), str) or not proposal[field].strip():
            raise Refused(f"refused: the proposal's '{field}' is missing or not text; nothing was sent")
    for field in ("create", "reason"):
        if proposal.get(field) is not None and not isinstance(proposal[field], str):
            raise Refused(f"refused: the proposal's '{field}' is not text; nothing was sent")
    if "changes" not in proposal:
        raise Refused("refused: the proposal has no 'changes'; nothing was sent")
    if not isinstance(proposal["changes"], list):
        raise Refused(f"refused: the proposal's 'changes' is {type(proposal['changes']).__name__}, not a list; nothing was sent")
    for number, change in enumerate(proposal["changes"], 1):
        label = f"change {number}"
        if not isinstance(change, dict):
            raise Refused(f"refused: {label} is {type(change).__name__}, not an object; nothing was sent")
        verbs = [v for v in VERBS if v in change]
        if not verbs:
            raise Refused(f"refused: {label} names none of add, reword, rename; nothing was sent")
        if len(verbs) > 1:
            raise Refused(f"refused: {label} names more than one of add, reword, rename ({', '.join(verbs)}); nothing was sent")
        verb = verbs[0]
        if not isinstance(change[verb], str) or not change[verb].strip():
            raise Refused(f"refused: {label}'s '{verb}' is missing or not a key; nothing was sent")
        label = f"{label} ({verb} {change[verb]})"
        needed = "to" if verb == "rename" else "text"
        if not isinstance(change.get(needed), str) or not change[needed].strip():
            raise Refused(f"refused: {label} has no '{needed}', which a {verb} needs; nothing was sent")
        for field in ("reason", "source"):
            if change.get(field) is not None and not isinstance(change[field], str):
                raise Refused(f"refused: {label}'s '{field}' is not text; nothing was sent")


def proposal_sql(proposal: dict, version: int | None) -> str:
    validate_proposal(proposal)
    ds, author = proposal["dataset"], proposal["author"]
    lines = ["SET autocommit = 0;", "START TRANSACTION;"]
    if proposal.get("create") is not None:
        lines.append(f"CALL rd_create_dataset({sql_str(ds)}, {sql_str(proposal['create'])});")
    if version is None:
        lines.append(f"CALL rd_open_version({sql_str(ds)}, {sql_str(author)}, {sql_str(proposal.get('reason'))});")
        lines.append(f"SET @v = (SELECT MAX(v.number) FROM versions v JOIN datasets d ON d.id = v.dataset_id WHERE d.name = {sql_str(ds)});")
    else:
        lines.append(f"SET @v = {int(version)};")
    for change in proposal["changes"]:
        reason, source = change.get("reason"), change.get("source")
        if "add" in change:
            lines.append(f"CALL rd_add({sql_str(ds)}, @v, {sql_str(change['add'])}, {sql_str(change.get('text'))}, {sql_str(source)}, {sql_str(reason)}, {sql_str(author)});")
        elif "reword" in change:
            lines.append(f"CALL rd_reword({sql_str(ds)}, @v, {sql_str(change['reword'])}, {sql_str(change.get('text'))}, {sql_str(source)}, {sql_str(reason)}, {sql_str(author)});")
        else:
            lines.append(f"CALL rd_rename({sql_str(ds)}, {sql_str(change['rename'])}, {sql_str(change.get('to'))});")
    lines += ["SELECT @v;", "COMMIT;"]
    return "\n".join(lines) + "\n"


def cmd_propose(s: Session, path: str, version: int | None) -> int:
    try:
        proposal = json.loads(Path(path).read_text(encoding="utf-8"))
    except (OSError, ValueError) as exc:
        raise Refused(f"refused: the proposal {path} could not be read: {exc}") from None
    sql = proposal_sql(proposal, version)
    require_current(s)
    rows = s.sql(sql)
    print(f"proposed: {proposal['dataset']} version {rows[-1][0]}, {len(proposal['changes'])} change(s)")
    return 0


def cmd_step(s: Session, step: str, dataset: str, number: int, actor: str | None, reason: str, inspected: str | None = None) -> int:
    require_current(s)
    procedure = {"review": "rd_review", "reopen": "rd_reopen", "stamp": "rd_stamp"}[step]
    arguments = f"{sql_str(dataset)}, {int(number)}, {sql_str(actor)}, {sql_str(reason)}" + (f", {sql_str(inspected)}" if step == "review" else "")
    # One transaction: the check, the status change and the changelog row land together or not at all. READ
    # COMMITTED, so what the procedure reads after the version's lock is what is committed then (rd_review).
    s.sql(f"SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;\nSET autocommit = 0;\nSTART TRANSACTION;\nCALL {procedure}({arguments});\nCOMMIT;\n")
    print(f"{step}: {dataset} version {number} by {actor}")
    return 0


def cmd_list(s: Session) -> int:
    require_current(s)
    rows = s.sql(
        f"SELECT {marked('d.name')}, v.number, v.status, {marked('v.author')}, {marked('v.reviewer')} FROM datasets d LEFT JOIN versions v ON v.dataset_id = d.id ORDER BY d.name, v.number;"
    )
    rows = [[unmark(name), number, status, unmark(author), unmark(reviewer)] for name, number, status, author, reviewer in rows]
    if not rows:
        print("no datasets")
    for name, number, status, author, reviewer in rows:
        if number is None:
            print(f"{name}: no versions")
        else:
            print(f"{name} v{number}: {status}, author {author}" + (f", reviewer {reviewer}" if reviewer else ""))
    return 0


def latest_version(s: Session, dataset: str) -> int:
    rows = s.sql(f"SELECT MAX(v.number) FROM versions v JOIN datasets d ON d.id = v.dataset_id WHERE d.name = {sql_str(dataset)};")
    if not rows or rows[0][0] is None:
        raise Refused(f"refused: the dataset '{dataset}' has no versions")
    return int(rows[0][0])


def version_text(s: Session, dataset: str, number: int) -> list[tuple]:
    rows = s.sql(
        f"SELECT {marked('entry_key')}, {marked('text')}, {marked('source')}, meaning_from FROM rd_version_text "
        f"WHERE dataset = {sql_str(dataset)} AND as_of = {int(number)} ORDER BY entry_key;"
    )
    return [(unmark(k), unmark(t), unmark(src), int(m)) for k, t, src, m in rows]


def require_version(s: Session, dataset: str, number: int) -> str:
    rows = s.sql(f"SELECT v.status FROM versions v JOIN datasets d ON d.id = v.dataset_id WHERE d.name = {sql_str(dataset)} AND v.number = {int(number)};")
    if not rows:
        raise Refused(f"refused: {dataset} has no version {number}")
    return rows[0][0]


def cmd_show(s: Session, dataset: str, number: int | None) -> int:
    require_current(s)
    number = latest_version(s, dataset) if number is None else number
    status = require_version(s, dataset, number)
    print(f"{dataset} v{number} ({status})")
    for key, text, source, since in version_text(s, dataset, number):
        print(f"  {key}: {text}  [source: {source or 'none'}; meaning from v{since}]")
    return 0


def changes_between(s: Session, dataset: str, number: int) -> tuple[int | None, list[str], str]:
    """What a version changes against the last stamped version before it, and the version's digest, all read from one
    snapshot, so the digest a reviewer passes to review is the digest of exactly what was printed."""
    ds, n = sql_str(dataset), int(number)
    text = f"SELECT {marked('entry_key')}, {marked('text')}, {marked('source')} FROM rd_version_text WHERE dataset = {ds} AND as_of ="
    rows = s.sql(
        "SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;\nSTART TRANSACTION WITH CONSISTENT SNAPSHOT, READ ONLY;\n"
        f"SELECT 'status', v.status FROM versions v JOIN datasets d ON d.id = v.dataset_id WHERE d.name = {ds} AND v.number = {n};\n"
        f"SET @rd_base = (SELECT MAX(v.number) FROM versions v JOIN datasets d ON d.id = v.dataset_id WHERE d.name = {ds} AND v.status = 'stamped' AND v.number < {n});\n"
        "SELECT 'base', IFNULL(@rd_base, 0);\n"
        f"SELECT 'before', t.* FROM ({text} @rd_base) t;\n"
        f"SELECT 'after', t.* FROM ({text} {n}) t;\n"
        f"CALL rd_version_digest({ds}, {n}, @rd_digest);\nSELECT 'digest', @rd_digest;\nCOMMIT;\n")
    if not any(r[0] == "status" for r in rows):
        raise Refused(f"refused: {dataset} has no version {number}")
    base = next(int(r[1]) for r in rows if r[0] == "base") or None
    before = {unmark_text(r[1]): (unmark(r[2]), unmark(r[3])) for r in rows if r[0] == "before"}
    after = {unmark_text(r[1]): (unmark(r[2]), unmark(r[3])) for r in rows if r[0] == "after"}
    digest = next(r[1] for r in rows if r[0] == "digest")
    out = []
    for key in sorted(after):
        if key not in before:
            out.append(f"added {key}: {after[key][0]}  [source: {after[key][1] or 'none'}]")
        elif before[key] != after[key]:
            out.append(f"reworded {key}: {before[key][0]}  ->  {after[key][0]}  [source: {after[key][1] or 'none'}]")
    return base, out, digest


def cmd_changes(s: Session, dataset: str, number: int) -> int:
    require_current(s)
    base, lines, digest = changes_between(s, dataset, number)
    print(f"{dataset} v{number} against " + (f"v{base}, the last stamped before it" if base else "nothing stamped before it"))
    for line in lines or ["no changes"]:
        print(f"  {line}")
    print(f"digest: {digest}  (a review of what is shown here names it: review ... --inspected {digest})")
    return 0


def history_detail(s: Session, dataset: str) -> list[tuple]:
    """Every changelog row: version, action, key, actor, reason, whether its contents were recorded, text, source."""
    current = schema_revision(s) >= 2
    recorded = "c.contents_recorded" if current else "0"
    contents = f"{marked('c.text')}, {marked('c.source')}" if current else "'N', 'N'"
    rows = s.sql(
        f"SELECT v.number, c.action, {marked('e.entry_key')}, {marked('c.actor')}, {marked('c.reason')}, {recorded}, {contents} "
        "FROM changelog c JOIN versions v ON v.id = c.version_id "
        f"JOIN datasets d ON d.id = v.dataset_id LEFT JOIN entries e ON e.id = c.entry_id WHERE d.name = {sql_str(dataset)} ORDER BY c.id;"
    )
    return [(int(n), a, unmark(k), unmark(actor), unmark(r), rec == "1", unmark(t), unmark(src)) for n, a, k, actor, r, rec, t, src in rows]


def history_rows(s: Session, dataset: str) -> list[tuple]:
    return [row[:5] for row in history_detail(s, dataset)]


def cmd_history(s: Session, dataset: str) -> int:
    require_current(s)
    rows = history_detail(s, dataset)
    if not rows:
        raise Refused(f"refused: the dataset '{dataset}' has no changelog")
    for number, action, key, actor, reason, recorded, text, source in rows:
        line = f"v{number} {action}" + (f" {key}" if key is not None else "") + f" by {actor}: {reason}"
        if action in ("add", "reword"):
            line += f'  -> "{text}" [source: {source if source is not None else "none"}]' if recorded else "  (contents not recorded: written before schema revision 2)"
        print(line)
    return 0


def cmd_backup(s: Session, path: str, timeout: int = TIMEOUT_SECONDS) -> int:
    if not s.exists():
        raise Refused(f"refused: the database '{s.database}' does not exist")
    target = Path(path)
    exe = client_path("mysqldump")
    if not exe.is_file():
        raise Refused(f"refused: no mysqldump at {exe}")
    partial = target.with_name(target.name + ".partial")
    kept = f"the earlier backup at {target} was kept unchanged" if target.exists() else f"there was no earlier backup at {target}"
    try:
        out = open(partial, "wb")
    except OSError as exc:
        raise Refused(f"refused: backup could not write {partial} ({exc.strerror or exc}); nothing was written and {kept}; "
                      "choose a destination folder this account can write to") from None
    with out:
        proc = subprocess.Popen(
            [str(exe), f"--defaults-extra-file={s.options.name}", "--default-character-set=utf8mb4",
             # The data only: a restore builds the schema from data/refdata/schema.sql, the repository's own, and loads
             # these rows as a user that can do nothing else (cmd_restore).
             "--no-create-info", "--skip-triggers", "--skip-disable-keys", "--complete-insert", "--single-transaction",
             # schema_info is the schema's own row, which a restore's schema.sql writes; a backup carries data alone.
             "--skip-dump-date", f"--ignore-table={s.database}.schema_info",
             # A dump that skipped a table on an error would still exit 0; an option file's force never applies here.
             "--skip-force", s.database],
            stdout=out, stderr=subprocess.PIPE, cwd=str(s.options.parent))
        timed_out, err = False, b""
        try:
            _, err = proc.communicate(timeout=timeout)
        except subprocess.TimeoutExpired:
            _end_tree(proc)
            timed_out = True
    # The partial dump is removed only after this process's own handle to it is closed: Windows refuses to delete a
    # file that is still open.
    if timed_out:
        try:
            partial.unlink()
            left = "the partial dump was removed"
        except OSError as exc:
            left = f"the partial dump is left at {partial} ({exc.strerror or exc})"
        raise Refused(f"refused: the dump did not finish within {timeout}s and was ended; nothing was written, {kept}, and {left}") from None
    if proc.returncode != 0:
        partial.unlink()
        raise Refused(_classify(err.decode("utf-8", "replace"), s.database) + "; nothing was written")
    try:
        os.replace(partial, target)
    except OSError as exc:
        try:
            partial.unlink()
            left = "the new dump was removed"
        except OSError:
            left = f"the new dump is left at {partial}"
        raise Refused(f"refused: backup could not replace {target} ({exc.strerror or exc}); {kept}, and {left}; "
                      f"close whatever holds {target.name} and run backup again") from None
    print(f"backed up '{s.database}' to {target} ({target.stat().st_size} bytes)")
    return 0


DATABASE_STATEMENT = re.compile(r"^\s*(USE\s|CREATE\s+(DATABASE|SCHEMA)\b|DROP\s+(DATABASE|SCHEMA)\b|ALTER\s+(DATABASE|SCHEMA)\b)", re.IGNORECASE)


def dump_reaches_out(text: str) -> str | None:
    """Why a dump would act on a database other than the one it is restored into, or None. mysqldump writes these as
    lines of their own when it was given --databases or --all-databases; refdata.py backup gives it neither."""
    for number, line in enumerate(text.splitlines(), 1):
        if DATABASE_STATEMENT.match(line):
            return f"selects, creates or drops a database (line {number}: {line.strip()[:80]})"
    return None


def grant_pattern(database: str) -> str:
    """A database name as a GRANT reads it exactly: in a database-level grant `_` and `%` are wildcards, so a grant on
    `refdat_` would also cover `refdata`; each is escaped with a backslash."""
    return database.replace("\\", "\\\\").replace("_", "\\_").replace("%", "\\%")


OPTION_CODE_PAGE = "mbcs"   # option files are read in the system's ANSI code page (tools/refdata/server.ps1, Write-OptionFile)


def client_settings(author: Path) -> list[str]:
    """Every option the mysql client reads from the author's option file, in order, as MySQL's own reader gives them
    (my_print_defaults over the [client] and [mysql] groups, `name=value` without the leading dashes, any password
    masked): nothing here parses an option file itself."""
    exe = client_path("my_print_defaults")
    if not exe.is_file():
        raise Refused(f"refused: no my_print_defaults at {exe} (run tools/refdata/server.ps1 -Install, or set RESOLUTE_REFDATA_CLIENT)")
    # From the option file's folder, as run_sql runs the client, so a relative path reads as the client reads it.
    proc = subprocess.run([str(exe), f"--defaults-extra-file={author.name}", "client", "mysql"], capture_output=True,
                          cwd=str(author.parent), timeout=TIMEOUT_SECONDS, check=False)
    if proc.returncode != 0:
        said = proc.stderr.decode(OPTION_CODE_PAGE, "replace").strip().splitlines()
        raise Refused(f"refused: the option file {author} could not be read ({said[0] if said else f'my_print_defaults exit {proc.returncode}'}); nothing was restored")
    settings = []
    for line in proc.stdout.decode(OPTION_CODE_PAGE, "replace").splitlines():
        if not line.startswith("--"):
            continue
        settings.append(line[2:])
    return settings


def restricted_option_bytes(author: Path, user: str, password: str, override: dict | None = None) -> bytes:
    """The restore user's option file, written beside the author's: it includes the author's file, so the client
    reads every setting exactly as the author's own connections read it (host, port, bind address, TLS, comments,
    option modifiers, relative paths, included files and whatever else MySQL adds), and then names the restore user
    and password last, in each group the client reads, so those two alone are replaced. override is the self-test's
    hook for changing a setting the author's file gives, in the restricted file alone; it adds nothing the author's
    file lacks."""
    given = {option.partition("=")[0].lower().replace("_", "-") for option in client_settings(author)}
    changed = [f"{key}={value}" for key, value in (override or {}).items() if key in given]
    lines = [f"!include {author.name}"]
    for group in ("client", "mysql"):
        lines += [f"[{group}]"] + changed + [f"user={user}", f"password={password}"]
    return ("\r\n".join(lines) + "\r\n").encode(OPTION_CODE_PAGE)


def cmd_restore(s: Session, path: str, schema: Path = SCHEMA, restricted_override: dict | None = None, before_cleanup=None) -> int:
    """Loads a backup into a new database, and nowhere else. The schema comes from the repository's own schema.sql;
    the backup's rows are then run as a MySQL user created for this restore alone, whose only privileges are SELECT,
    INSERT and LOCK TABLES on the new database, so a statement that reaches any other database is refused by the
    server whatever it says. The user is dropped however the restore ends, and a failed restore drops the new
    database."""
    dump = Path(path)
    if not dump.is_file():
        raise Refused(f"refused: no backup at {dump}")
    if s.exists():
        raise Refused(f"refused: the database '{s.database}' already exists; restore into a new name")
    try:
        text = dump.read_text(encoding="utf-8")
    except OSError as exc:
        raise Refused(f"refused: restore could not read {dump} ({exc.strerror or exc}); nothing was restored and no database was created; "
                      "close whatever holds the file, or name a backup this account can read") from None
    except UnicodeDecodeError:
        raise Refused(f"refused: restore could not read {dump}: it is not UTF-8 text, so it is not a backup refdata.py wrote; "
                      "nothing was restored and no database was created") from None
    reaches = dump_reaches_out(text)
    if reaches:
        raise Refused(f"refused: the dump {reaches}, so it would write outside '{s.database}'; take the backup with refdata.py backup, which names no database")
    user = f"refdata_restore_{secrets.token_hex(4)}"
    password = secrets.token_urlsafe(24)
    # The account is for the host the server sees this connection come from: 'localhost' for the private server,
    # the workstation's address for a shared one, where an account for 'localhost' could not log in.
    account_host = run_sql("SELECT SUBSTRING_INDEX(USER(), '@', -1);", options=s.options)[0][0]
    run_sql(f"CREATE DATABASE `{s.database}` CHARACTER SET utf8mb4;", options=s.options)
    restored = False
    # Beside the author's option file, which it includes, so the client runs from the same folder and reads every
    # setting as the author's own connections do; it holds the restore user's password and is removed however the
    # restore ends.
    restricted = s.options.with_name(f"refdata-restore-{secrets.token_hex(4)}.cnf")
    try:
        run_sql(schema.read_text(encoding="utf-8"), options=s.options, database=s.database)
        run_sql(f"CREATE USER '{user}'@{sql_str(account_host)} IDENTIFIED BY {sql_str(password)};\n"
                f"GRANT SELECT, INSERT, LOCK TABLES ON `{grant_pattern(s.database)}`.* TO '{user}'@{sql_str(account_host)};", options=s.options)
        try:
            restricted.write_bytes(restricted_option_bytes(s.options, user, password, restricted_override))
        except OSError as exc:
            raise Refused(f"refused: the restore user's option file could not be written beside {s.options} ({exc.strerror or exc}); nothing was restored") from None
        try:
            # The backup is untrusted text, and the client has commands of its own that no database privilege
            # governs (\! runs a shell command as this Windows user): --binary-mode turns them off for the input,
            # and --skip-system-command turns off \! itself.
            run_sql(text, options=restricted, database=s.database, extra=("--binary-mode", "--skip-system-command"))
        except Refused as refusal:
            raise Refused(f"refused: the backup could not be loaded as rows into '{s.database}' alone through the restore user's connection, "
                          f"which uses your option file's settings ({refusal}); nothing outside it was changed") from None
        restored = True
    finally:
        # Each step is attempted whatever the others did, and whatever is left is named: a credential file that cannot
        # be removed never keeps the restore user alive, nor a half-made database.
        failure = sys.exc_info()[1]   # the refusal that ended the restore, if one did: kept in what is reported
        if before_cleanup:
            before_cleanup(restricted)
        left = []
        try:
            restricted.unlink(missing_ok=True)
            file_left = None
        except OSError as exc:
            file_left = f"{exc.strerror or exc}"
        try:
            run_sql(f"DROP USER IF EXISTS '{user}'@{sql_str(account_host)};", options=s.options)
            user_dropped = True
        except Refused as refusal:
            user_dropped = False
            left.append(f"the restore user '{user}'@'{account_host}' could not be confirmed removed ({refusal}); drop it with: DROP USER IF EXISTS '{user}'@'{account_host}';")
        if file_left is not None:
            # What the file's password still opens is said only as far as it is known.
            state = "the user it names was dropped" if user_dropped else "the user it names could not be confirmed removed"
            left.insert(0, f"the restore user's option file {restricted} could not be removed ({file_left}); delete it ({state})")
        if not restored:
            try:
                run_sql(f"DROP DATABASE IF EXISTS `{s.database}`;", options=s.options)
            except Refused as refusal:
                left.append(f"the half-made database '{s.database}' could not be confirmed removed ({refusal}); drop it with: DROP DATABASE IF EXISTS `{s.database}`;")
        if left:
            ended = f"refused: the backup was restored into '{s.database}', but " if restored else f"{failure or 'refused: the restore failed'}; and "
            raise RestoreLeftovers(ended + "; ".join(left), loaded=restored) from None
    print(f"restored {dump} into '{s.database}'")
    return 0


# What an upgrade must carry over unchanged, read the same way from both databases.
UPGRADE_READBACK = {
    "datasets": f"SELECT {marked('name')}, {marked('description')} FROM datasets ORDER BY name;",
    "versions": f"SELECT {marked('d.name')}, v.number, v.status, {marked('v.author')}, {marked('v.reviewer')}, {marked('v.opened_at')}, {marked('v.stamped_at')} "
                "FROM versions v JOIN datasets d ON d.id = v.dataset_id ORDER BY d.name, v.number;",
    "version texts": f"SELECT {marked('dataset')}, as_of, {marked('entry_key')}, {marked('text')}, {marked('source')}, meaning_from "
                     "FROM rd_version_text ORDER BY dataset, as_of, entry_key;",
    "changelog": f"SELECT {marked('d.name')}, v.number, c.action, {marked('e.entry_key')}, {marked('c.actor')}, {marked('c.reason')}, {marked('c.at')} "
                 "FROM changelog c JOIN versions v ON v.id = c.version_id JOIN datasets d ON d.id = v.dataset_id "
                 "LEFT JOIN entries e ON e.id = c.entry_id ORDER BY c.id;",
}


def upgrade_difference(old: Session, new: Session) -> str | None:
    """The first way the new database reads back differently from the old, or None."""
    for name, query in UPGRADE_READBACK.items():
        a, b = old.sql(query), new.sql(query)
        for number, (x, y) in enumerate(zip(a, b), 1):
            if x != y:
                return f"{name} row {number} reads {x} in the old and {y} in the new"
        if len(a) != len(b):
            return f"{name} has {len(a)} rows in the old and {len(b)} in the new"
    return None


def cmd_upgrade(s: Session, to: str, schema: Path = SCHEMA, after_restore=None, restricted_override: dict | None = None,
                before_cleanup=None, before_restore=None) -> int:
    """Copies a database at an older schema revision into a new one at this revision: a backup of the old, restored into
    the new name from the current schema, then every version's text and every changelog row read back from both and
    compared. The old database is never changed; a difference drops the new one. after_restore, before_cleanup and
    before_restore are the self-test's hooks: a restore that lost something, a cleanup that cannot remove its file, and
    another author's work taking the new name between the check and the restore."""
    if not s.exists():
        raise Refused(f"refused: the database '{s.database}' does not exist")
    revision = schema_revision(s)
    if revision >= SCHEMA_REVISION:
        raise Refused(f"refused: the database '{s.database}' is already at schema revision {revision}; there is nothing to upgrade: work in it")
    new = Session(s.options, to)
    if new.exists():
        raise Refused(f"refused: the database '{to}' already exists; upgrade into a new name; nothing was changed")
    # Every command refuses the old database, so the next step is the upgrade again, once the cause is fixed.
    keep_old = (f"'{s.database}' is unchanged and keeps every version; fix the cause named here and run "
                f"refdata.py upgrade --database {s.database} --to <a new name> again")
    with tempfile.TemporaryDirectory(prefix="refdata-upgrade-") as tmp:
        dump = Path(tmp) / "upgrade.sql"
        with contextlib.redirect_stdout(io.StringIO()):
            try:
                cmd_backup(s, str(dump))
                if before_restore:
                    before_restore()
                cmd_restore(new, str(dump), schema, restricted_override, before_cleanup)
            except RestoreLeftovers as refusal:
                # Only a restore that says it loaded its own copy leaves one behind, never compared; any other refusal
                # (a name another author took meanwhile among them) names no database of this upgrade's to drop.
                if not refusal.loaded:
                    raise Refused(f"{refusal}; {keep_old}") from None
                raise Refused(f"{refusal}; the upgrade stopped before comparing, so '{to}' is loaded but unverified: do not use it. "
                              f"{keep_old}, and drop the copy with: DROP DATABASE IF EXISTS `{to}`;") from None
            except Refused as refusal:
                # The copy began and failed: its own refusal says what was left, and the next step is the same.
                raise Refused(f"{refusal}; {keep_old}") from None

    def rolled_back(reason: str) -> Refused:
        # The reason first, then what became of the copy, as far as it is known.
        try:
            run_sql(f"DROP DATABASE IF EXISTS `{to}`;", options=s.options)
            return Refused(f"{reason}; '{to}' was dropped and {keep_old}")
        except Refused as refusal:
            return Refused(f"{reason}; '{to}' could not be confirmed removed ({refusal}): drop it with: DROP DATABASE IF EXISTS `{to}`; and {keep_old}")

    try:
        if after_restore:
            after_restore(new)
        difference = upgrade_difference(s, new)
    except Refused as refusal:
        raise rolled_back(f"refused: the upgraded copy could not be compared with '{s.database}' ({refusal})") from None
    if difference:
        raise rolled_back(f"refused: the upgraded copy differs from '{s.database}': {difference}") from None
    print(f"upgraded '{s.database}' (schema revision {revision}) into '{to}' (revision {SCHEMA_REVISION}); every version and changelog row reads back the same.")
    print(f"'{s.database}' is unchanged. Work in '{to}' from now on (--database {to}, or RESOLUTE_REFDATA_DATABASE={to}); "
          f"once it is checked, drop '{s.database}' with: DROP DATABASE `{s.database}`;")
    print("changelog rows written before the upgrade show their contents as not recorded: revision 1 kept only the latest text.")
    return 0


# ----- the self-test ----------------------------------------------------------------------------------------------

class Checks:
    def __init__(self):
        self.failed: list[str] = []

    def check(self, name: str, ok: bool, detail: str = "") -> None:
        print(("PASS " if ok else "FAIL ") + name + ("" if ok or not detail else f": {detail}"))
        if not ok:
            self.failed.append(name)


def call(argv: list[str]) -> tuple[int, str]:
    buffer = io.StringIO()
    with contextlib.redirect_stdout(buffer):
        code = main(argv)
    return code, buffer.getvalue()


def other_databases(options: Path, own: str) -> dict:
    names = [r[0] for r in run_sql("SELECT schema_name FROM information_schema.schemata ORDER BY schema_name;", options=options)]
    names = [n for n in names if n not in SYSTEM_DATABASES and n != own]
    state = {}
    for name in names:
        tables = [r[0] for r in run_sql(
            f"SELECT table_name FROM information_schema.tables WHERE table_schema = {sql_str(name)} AND table_type = 'BASE TABLE' ORDER BY table_name;",
            options=options)]
        sums = {}
        if tables:
            listing = ", ".join(f"`{name}`.`{t}`" for t in tables)
            sums = {r[0]: r[1] for r in run_sql(f"CHECKSUM TABLE {listing};", options=options)}
        state[name] = sums
    return state


class SelfTestRun:
    """What every phase of the self-test shares: its checks, the database it made, and the helpers its cases use."""

    def __init__(self, checks: Checks, options: Path, database: str, session: Session, tmp: Path):
        self.checks, self.options, self.database, self.session, self.tmp = checks, options, database, session, tmp
        self.base = ["--options", str(options), "--database", database]
        self.kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
        self.kernel32.CreateFileW.restype = ctypes.c_void_p
        self.kernel32.CreateFileW.argtypes = [ctypes.c_wchar_p, ctypes.c_uint32, ctypes.c_uint32, ctypes.c_void_p, ctypes.c_uint32, ctypes.c_uint32, ctypes.c_void_p]
        self.kernel32.CloseHandle.argtypes = [ctypes.c_void_p]
        # Produced by one phase and read by a later one.
        self.v1 = ""
        self.expected_v1: list[tuple] = []
        self.expected_v2: list[tuple] = []
        self.expected_log: list[tuple] = []
        self.read_back = lambda label: None
        self.dump_file = tmp
        self.hostile = tmp
        # The restore accounts there before this run: an interrupted earlier restore may have left one, and the run's
        # checks look only at accounts it made, never deleting or counting one it did not.
        self.accounts_before = self.restore_accounts()

    def restore_accounts(self) -> set[tuple[str, str]]:
        # The underscores escaped, so the pattern matches restore accounts and nothing like them.
        return {(name, host) for name, host in run_sql(r"SELECT user, host FROM mysql.user WHERE user LIKE 'refdata\_restore\_%';", options=self.options)}

    def accounts_left(self) -> str:
        """'0' when every restore account this run made is gone, otherwise the ones left."""
        left = self.restore_accounts() - self.accounts_before
        return "0" if not left else f"left {sorted(left)}"

    def proposal(self, name: str, body: object) -> str:
        path = self.tmp / f"{name}.json"
        path.write_text(json.dumps(body), encoding="utf-8")
        return str(path)

    def refused(self, label: str, argv: list[str], expected: str) -> None:
        code, out = call(argv + self.base)
        self.checks.check(f"refused: {label}", code == 1 and expected in out, f"exit {code}, said {out.strip()!r}")

    @staticmethod
    def safe_call(argv: list[str]) -> tuple[int | None, str]:
        # A refusal that is not handled ends in a traceback; that is reported as a failure, not raised.
        try:
            return call(argv)
        except Exception as exc:  # noqa: BLE001 -- the self-test reports any unhandled error as the failure it is
            return None, f"unhandled {type(exc).__name__}: {exc}"

    def digest_of(self, number: int) -> str:
        _, out = call(["changes", "fixture", str(number)] + self.base)
        found = re.search(r"digest: ([0-9a-f]{64})", out)
        return found.group(1) if found else "no digest printed"

    def review(self, number: int, who: str, reason: str, digest: str | None = None) -> tuple[int, str]:
        return call(["review", "fixture", str(number), "--as", who, "--reason", reason, "--inspected", digest or self.digest_of(number)] + self.base)

    def held(self, path: Path, share: int):
        # GENERIC_READ, OPEN_EXISTING; share 1 lets others read but not replace or delete it, share 0 lets nobody open it.
        handle = self.kernel32.CreateFileW(str(path), 0x80000000, share, None, 3, 0x80, None)
        if handle in (None, ctypes.c_void_p(-1).value):
            raise Refused(f"refused: the self-test could not hold {path} (error {ctypes.get_last_error()})")
        return handle

    @staticmethod
    def server(flag: str) -> str:
        proc = subprocess.Popen(["pwsh", "-NoProfile", "-File", str(SERVER_SCRIPT), flag], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        try:
            said, _ = proc.communicate(timeout=180)
        except subprocess.TimeoutExpired:
            _end_tree(proc)
            said = b"did not finish within 180s and was ended with its children"
        return f"exit {proc.returncode}: " + said.decode("utf-8", "replace").strip()[-200:]


def _phase_workflow(t: SelfTestRun) -> None:
    checks, session, base = t.checks, t.session, t.base
    proposal, refused, digest_of, review = t.proposal, t.refused, t.digest_of, t.review
    # Version 1: proposed, refused review by its author, reviewed, stamped.
    v1 = str(FIXTURES / "fixture-v1.json")
    code, out = call(["propose", v1] + base)
    checks.check("version 1 is proposed from the fixture", code == 0 and "version 1" in out, out.strip())
    refused("a reviewer who is the author", ["review", "fixture", "1", "--as", "author-one", "--reason", "self", "--inspected", digest_of(1)], "the reviewer is the author")
    refused("stamping an unreviewed version", ["stamp", "fixture", "1", "--as", "author-one", "--reason", "early"], "the version is not reviewed")
    code, _ = review(1, "author-two", "checked against both manuals")
    code2, _ = call(["stamp", "fixture", "1", "--as", "author-one", "--reason", "release the first version"] + base)
    checks.check("version 1 is reviewed by another author and stamped", code == 0 and code2 == 0)
    refused("editing a stamped version", ["propose", proposal("stamped", {"dataset": "fixture", "author": "author-one", "changes": [
        {"reword": "beep-3-short", "text": "x", "reason": "late edit"}]}), "--version", "1"], "the version is stamped and cannot change")

    # Version 2: one entry reworded, one unchanged.
    code, out = call(["propose", str(FIXTURES / "fixture-v2.json")] + base)
    checks.check("version 2 is proposed", code == 0 and "version 2" in out, out.strip())
    refused("a change without a reason", ["propose", proposal("noreason", {"dataset": "fixture", "author": "author-one", "changes": [
        {"add": "beep-2-short", "text": "Two short beeps", "reason": ""}]}), "--version", "2"], "a change needs a reason")
    refused("a key reused", ["propose", proposal("reuse", {"dataset": "fixture", "author": "author-one", "changes": [
        {"add": "beep-1-long", "text": "again", "reason": "reuse"}]}), "--version", "2"], "keys are never reused")
    refused("a key renamed", ["propose", proposal("rename", {"dataset": "fixture", "author": "author-one", "changes": [
        {"rename": "beep-1-long", "to": "beep-long", "reason": "rename"}]}), "--version", "2"], "keys are never renamed")
    code, _ = review(2, "author-two", "the rewording matches the revised manual")
    code2, _ = call(["stamp", "fixture", "2", "--as", "author-one", "--reason", "release the second version"] + base)
    checks.check("version 2 is reviewed and stamped", code == 0 and code2 == 0)

    expected_v1 = [
        ("beep-1-long", "One long beep: memory not detected", "Award BIOS 6.0 manual, appendix B", 1),
        ("beep-3-short", "Three short beeps: base memory read or write error", "AMI BIOS 8 manual, table 4", 1),
    ]
    expected_v2 = [
        ("beep-1-long", "One long beep: no memory detected in any slot", "Award BIOS 6.0 manual, appendix B, revised", 2),
        expected_v1[1],
    ]
    expected_log = [
        (1, "open", None, "author-one", "the first version of the fixture"),
        (1, "add", "beep-1-long", "author-one", "first entry"),
        (1, "add", "beep-3-short", "author-one", "second entry"),
        (1, "review", None, "author-two", "checked against both manuals"),
        (1, "stamp", None, "author-one", "release the first version"),
        (2, "open", None, "author-one", "the second version of the fixture: one entry reworded, one left as it was"),
        (2, "reword", "beep-1-long", "author-one", "the manual's later printing names the slots"),
        (2, "review", None, "author-two", "the rewording matches the revised manual"),
        (2, "stamp", None, "author-one", "release the second version"),
    ]

    def read_back(label: str) -> None:
        checks.check(f"version 1 reads back exactly ({label})", version_text(session, "fixture", 1) == expected_v1, repr(version_text(session, "fixture", 1)))
        checks.check(f"version 2 reads back exactly ({label})", version_text(session, "fixture", 2) == expected_v2, repr(version_text(session, "fixture", 2)))
        checks.check(f"the changelog reads back exactly ({label})", history_rows(session, "fixture")[:len(expected_log)] == expected_log, repr(history_rows(session, "fixture")))

    read_back("after stamping")
    _, lines, _ = changes_between(session, "fixture", 2)
    checks.check("changes names the one rewording against version 1", len(lines) == 1 and lines[0].startswith("reworded beep-1-long"), repr(lines))

    # A proposal of three changes whose third is refused leaves nothing behind.
    log_before = len(history_rows(session, "fixture"))
    refused("the third change of a proposal", ["propose", proposal("partial", {"dataset": "fixture", "author": "author-one", "reason": "three changes", "changes": [
        {"add": "beep-a", "text": "A", "reason": "first"}, {"add": "beep-b", "text": "B", "reason": "second"},
        {"add": "beep-3-short", "text": "C", "reason": "third, a reused key"}]})], "keys are never reused")
    leftovers = session.sql("SELECT COUNT(*) FROM entries WHERE entry_key IN ('beep-a', 'beep-b');")[0][0]
    versions = session.sql("SELECT COUNT(*) FROM versions;")[0][0]
    checks.check("a refused proposal leaves no row and no changelog row", leftovers == "0" and versions == "2" and len(history_rows(session, "fixture")) == log_before,
                 f"entries {leftovers}, versions {versions}, changelog {len(history_rows(session, 'fixture'))} against {log_before}")

    # A step whose changelog row cannot be written leaves the version as it was: one transaction.
    refused_step = None
    try:
        cmd_step(session, "review", "fixture", 2, None, "a reviewer the changelog cannot record")
    except Refused as refusal:
        refused_step = str(refusal)
    checks.check("a step whose changelog row fails leaves the version unchanged",
                 refused_step is not None and require_version(session, "fixture", 2) == "stamped",
                 f"refused {refused_step!r}, status {require_version(session, 'fixture', 2)}")

    # A reviewed version is frozen; reopen clears its review, so stamp is refused until it is reviewed again.
    call(["propose", proposal("v3", {"dataset": "fixture", "author": "author-one", "reason": "a third version", "changes": [
        {"add": "beep-a", "text": "A", "reason": "a new entry"}]})] + base)
    review(3, "author-two", "looks right")
    refused("changing a reviewed version", ["propose", proposal("frozen", {"dataset": "fixture", "author": "author-one", "changes": [
        {"reword": "beep-a", "text": "A, reworded", "reason": "after review"}]}), "--version", "3"], "reviewed and frozen")
    code, _ = call(["reopen", "fixture", "3", "--as", "author-one", "--reason", "one more change"] + base)
    code2, _ = call(["propose", proposal("after-reopen", {"dataset": "fixture", "author": "author-one", "changes": [
        {"reword": "beep-a", "text": "A, reworded", "reason": "after reopening"}]}), "--version", "3"] + base)
    checks.check("reopen returns the version to proposed and it changes", code == 0 and code2 == 0)
    refused("stamping a reopened version before it is reviewed again", ["stamp", "fixture", "3", "--as", "author-one", "--reason", "on the old approval"], "the version is not reviewed")
    code, _ = review(3, "author-two", "the change after reopening is right")
    code2, _ = call(["stamp", "fixture", "3", "--as", "author-one", "--reason", "release the third version"] + base)
    checks.check("the reopened version is stamped after a second review", code == 0 and code2 == 0)

    # Someone who changed a version is not its reviewer, whoever opened it (the cases follow the failed review below).
    # A step whose changelog row cannot be written, on a proposed version: still proposed afterwards.
    call(["propose", proposal("v4", {"dataset": "fixture", "author": "author-one", "reason": "a fourth version", "changes": [
        {"add": "beep-d", "text": "D", "reason": "a new entry"}]})] + base)
    refused_step = None
    try:
        cmd_step(session, "review", "fixture", 4, None, "a reviewer the changelog cannot record", digest_of(4))
    except Refused as refusal:
        refused_step = str(refusal)
    log_rows = [r for r in history_rows(session, "fixture") if r[0] == 4]
    checks.check("a review whose changelog row fails leaves the version proposed, with no row of it",
                 refused_step is not None and require_version(session, "fixture", 4) == "proposed" and [r[1] for r in log_rows] == ["open", "add"],
                 f"refused {refused_step!r}, status {require_version(session, 'fixture', 4)}, changelog {log_rows}")
    code, _ = call(["propose", proposal("v4-contribution", {"dataset": "fixture", "author": "author-two", "changes": [
        {"add": "beep-c", "text": "C", "reason": "a contribution to version 4"}]}), "--version", "4"] + base)
    checks.check("a second author can add to a proposed version", code == 0)
    refused("a reviewer who changed the version", ["review", "fixture", "4", "--as", "author-two", "--reason", "my contribution looks right", "--inspected", digest_of(4)], "the reviewer changed this version")
    code, _ = review(4, "author-three", "neither of us wrote it")
    checks.check("a reviewer who changed nothing reviews it", code == 0)
    t.v1 = v1
    t.expected_v1 = expected_v1
    t.expected_v2 = expected_v2
    t.expected_log = expected_log
    t.read_back = read_back


def _phase_restores(t: SelfTestRun) -> None:
    checks, session, options, database, base, tmp = t.checks, t.session, t.options, t.database, t.base, str(t.tmp)
    # A backup round trip: the rows come back in a database of their own, with the schema's rules.
    dump_file = Path(tmp) / "roundtrip.sql"
    code, out = call(["backup", str(dump_file)] + base)
    copy = f"{database}_copy"
    code2, out2 = call(["restore", str(dump_file), "--options", str(options), "--database", copy])
    copied = Session(options, copy)
    same = code == 0 and code2 == 0 and copied.exists() and history_rows(copied, "fixture") == history_rows(session, "fixture")
    refused_copy = None
    if copied.exists():
        try:
            copied.sql("CALL rd_review('fixture', 4, 'author-one', 'the restored rules still hold', NULL);")
        except Refused as refusal:
            refused_copy = str(refusal)
        run_sql(f"DROP DATABASE `{copy}`;", options=options)
    checks.check("a backup restores into a new database with the same changelog and the same rules",
                 same and refused_copy is not None and "only a proposed version can be reviewed" in refused_copy,
                 f"backup {out.strip()!r}; restore {out2.strip()!r}; same changelog {same}; the copy's rules said {refused_copy!r}")

    # A backup that reaches into another database is refused by the server, and that database is untouched.
    hostile = Path(tmp) / "hostile.sql"
    # A harmless first line, so the client reaches the DROP and only the server's privileges can stop it.
    hostile.write_text(f"SELECT 1;\nDROP TABLE `{database}`.`changelog`;\n", encoding="utf-8")
    before_rows = len(history_rows(session, "fixture"))
    target = f"{database}_hostile"
    code, out = call(["restore", str(hostile), "--options", str(options), "--database", target])
    users = t.accounts_left()
    checks.check("a backup that reaches into another database is refused, that database untouched, no target or user left",
                 code == 1 and "could not be loaded as rows" in out and len(history_rows(session, "fixture")) == before_rows
                 and not Session(options, target).exists() and users == "0", out.strip())

    # A restore into a name one underscore away from another database cannot reach it: the grant names it exactly.
    near = database[:-1] + "_"
    reach = Path(tmp) / "reach.sql"
    reach.write_text(f"SELECT 1;\nINSERT INTO `{database}`.`sources` (citation) VALUES ('written from a restore into {near}');\n", encoding="utf-8")
    sources_before = session.sql("SELECT COUNT(*) FROM sources;")[0][0]
    code, out = call(["restore", str(reach), "--options", str(options), "--database", near])
    checks.check("a restore into a name that differs by an underscore cannot write the other database",
                 code == 1 and session.sql("SELECT COUNT(*) FROM sources;")[0][0] == sources_before and not Session(options, near).exists(),
                 f"exit {code}, sources {sources_before} -> {session.sql('SELECT COUNT(*) FROM sources;')[0][0]}, said {out.strip()!r}")

    # A backup that asks the client to run a shell command is refused, and the command never runs.
    marker = Path(tmp) / "shell-ran.txt"
    shell = Path(tmp) / "shell.sql"
    shell.write_text(f"SELECT 1;\n\\! cmd /c echo ran> \"{marker}\"\nSELECT 2;\n", encoding="utf-8")
    target = f"{database}_shell"
    code, out = call(["restore", str(shell), "--options", str(options), "--database", target])
    checks.check("a backup that asks the client to run a shell command is refused, and the command does not run",
                 code == 1 and not marker.exists() and not Session(options, target).exists(), f"exit {code}, marker {marker.exists()}, said {out.strip()!r}")

    # A dump that names a database is refused before anything is restored.
    named = Path(tmp) / "named.sql"
    named.write_text(f"-- a mysqldump --databases dump\nCREATE DATABASE /*!32312 IF NOT EXISTS*/ `{database}`;\nUSE `{database}`;\nDROP TABLE IF EXISTS `changelog`;\n", encoding="utf-8")
    target = f"{database}_restored"
    code, out = call(["restore", str(named), "--options", str(options), "--database", target])
    changelog_after = len(history_rows(session, "fixture"))
    checks.check("a dump that names a database is refused, restoring nothing and leaving that database as it was",
                 code == 1 and "selects, creates or drops a database (line 2" in out and not Session(options, target).exists() and changelog_after == len(history_rows(session, "fixture")),
                 out.strip())
    t.dump_file = dump_file
    t.hostile = hostile


def _phase_review_and_history(t: SelfTestRun) -> None:
    checks, session, options, database, base = t.checks, t.session, t.options, t.database, t.base
    proposal, safe_call, digest_of, review = t.proposal, t.safe_call, t.digest_of, t.review
    # ---- Repair 1: an approval covers exactly what was inspected, and every edit stays in the history.
    call(["stamp", "fixture", "4", "--as", "author-one", "--reason", "release the fourth version"] + base)
    call(["propose", proposal("v5", {"dataset": "fixture", "author": "author-one", "reason": "a fifth version", "changes": [
        {"add": "beep-e", "text": "E", "source": "Manual E, first printing", "reason": "a new entry"},
        {"add": "NULL", "text": "NULL", "source": "NULL", "reason": "an entry whose key, text and source are the word NULL"}]})] + base)
    seen = digest_of(5)
    for printing in ("second", "third"):
        call(["propose", proposal(f"v5-{printing}", {"dataset": "fixture", "author": "author-two", "changes": [
            {"reword": "beep-e", "text": f"E, {printing}", "source": f"Manual E, {printing} printing", "reason": f"the {printing} printing"}]}), "--version", "5"] + base)
    code, out = review(5, "author-three", "approved on what I saw", seen)
    now = digest_of(5)
    checks.check("a review naming the digest of contents another author has since changed is refused, the version staying proposed",
                 code == 1 and "changed since it was inspected" in out and require_version(session, "fixture", 5) == "proposed" and now != seen, out.strip())

    detail = [(r[1], r[4], r[6], r[7]) for r in history_detail(session, "fixture") if r[0] == 5 and r[2] == "beep-e"]
    code, out = call(["history", "fixture"] + base)
    checks.check("two rewordings of one entry in one version both stay in history, each with its text, source and reason",
                 detail == [("add", "a new entry", "E", "Manual E, first printing"),
                            ("reword", "the second printing", "E, second", "Manual E, second printing"),
                            ("reword", "the third printing", "E, third", "Manual E, third printing")]
                 and 'v5 reword beep-e by author-two: the second printing  -> "E, second" [source: Manual E, second printing]' in out
                 and 'v5 reword beep-e by author-two: the third printing  -> "E, third" [source: Manual E, third printing]' in out,
                 f"{detail!r}; history said {out[-500:]!r}")

    texts = version_text(session, "fixture", 5)
    _, lines, _ = changes_between(session, "fixture", 5)
    _, shown = call(["show", "fixture", "5"] + base)
    null_rows = [(r[2], r[6], r[7]) for r in history_detail(session, "fixture") if r[0] == 5 and r[1] == "add" and r[4].startswith("an entry whose")]
    checks.check("an entry whose key, text and source are the word NULL reads back as that text in show, changes and history",
                 ("NULL", "NULL", "NULL", 5) in texts and "added NULL: NULL  [source: NULL]" in lines
                 and "  NULL: NULL  [source: NULL; meaning from v5]" in shown and null_rows == [("NULL", "NULL", "NULL")],
                 f"text {texts!r}; changes {lines!r}; show {shown!r}; history {null_rows!r}")

    code, out = review(5, "author-three", "approved on what is there now", now)
    checks.check("a review naming the digest of the contents as they are passes", code == 0 and require_version(session, "fixture", 5) == "reviewed", out.strip())
    call(["stamp", "fixture", "5", "--as", "author-one", "--reason", "release the fifth version"] + base)

    # A second author's edit in flight when the review is called: the review waits for its lock and is refused.
    call(["propose", proposal("v6", {"dataset": "fixture", "author": "author-one", "reason": "a sixth version", "changes": [
        {"add": "beep-f", "text": "F", "reason": "a new entry"}]})] + base)
    seen = digest_of(6)
    hold = subprocess.Popen([str(client_path()), f"--defaults-extra-file={options.name}", "--batch", database],
                            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=str(options.parent))
    assert hold.stdin is not None   # stdin=PIPE above
    hold.stdin.write(b"SET autocommit = 0;\nSTART TRANSACTION;\n"
                     b"CALL rd_reword('fixture', 6, 'beep-f', 'F, changed while under review', NULL, 'a concurrent edit', 'author-two');\n"
                     b"DO SLEEP(4);\nCOMMIT;\n")
    hold.stdin.close()
    holding, deadline = False, time.monotonic() + 15
    while time.monotonic() < deadline and hold.poll() is None:
        if run_sql("SELECT COUNT(*) FROM information_schema.innodb_trx WHERE trx_rows_locked > 0;", options=options)[0][0] != "0":
            holding = True
            break
        time.sleep(0.1)
    started = time.monotonic()
    code, out = review(6, "author-three", "approved on what I saw", seen)
    waited = time.monotonic() - started
    try:
        _, held_err = hold.communicate(timeout=60)
    except subprocess.TimeoutExpired:
        _end_tree(hold)
        held_err = b"the editing session did not finish within 60s and was ended"
    checks.check("a review called while a second author's edit holds the version waits for it and is refused, the version staying proposed",
                 holding and hold.returncode == 0 and waited > 1 and code == 1 and "changed since it was inspected" in out
                 and require_version(session, "fixture", 6) == "proposed",
                 f"edit holding {holding}, edit exit {hold.returncode} {held_err.decode('utf-8', 'replace').strip()!r}, waited {waited:.1f}s, review said {out.strip()!r}")

    # A malformed proposal is refused naming the change and the field, and no SQL is sent.
    for label, body, expected in (
            ("not an object", [1, 2], "the proposal is list, not an object"),
            ("no changes", {"dataset": "fixture", "author": "author-one"}, "the proposal has no 'changes'"),
            ("changes not a list", {"dataset": "fixture", "author": "author-one", "changes": {"add": "k"}}, "'changes' is dict, not a list"),
            ("a change not an object", {"dataset": "fixture", "author": "author-one", "changes": ["add k"]}, "change 1 is str, not an object"),
            ("a change naming no verb", {"dataset": "fixture", "author": "author-one", "changes": [{"text": "x", "reason": "r"}]}, "change 1 names none of add, reword, rename"),
            ("a change naming two verbs", {"dataset": "fixture", "author": "author-one", "changes": [{"add": "k", "reword": "k", "text": "x", "reason": "r"}]},
             "change 1 names more than one of add, reword, rename (add, reword)"),
            ("an add without text", {"dataset": "fixture", "author": "author-one", "changes": [{"add": "beep-g", "reason": "r"}]}, "change 1 (add beep-g) has no 'text'"),
            ("a rename without a new key", {"dataset": "fixture", "author": "author-one", "changes": [{"rename": "beep-f"}]},
             "change 1 (rename beep-f) has no 'to'")):
        sent = SENT[0]
        code, out = safe_call(["propose", proposal(f"malformed-{label}", body), "--version", "6"] + base)
        checks.check(f"refused before anything runs: {label}", code == 1 and expected in out and "nothing was sent" in out and SENT[0] == sent,
                     f"exit {code}, sessions started {SENT[0] - sent}, said {out.strip()!r}")


def _phase_file_errors_and_cleanup(t: SelfTestRun) -> None:
    checks, options, database, base, tmp = t.checks, t.options, t.database, t.base, str(t.tmp)
    safe_call, held, server, kernel32 = t.safe_call, t.held, t.server, t.kernel32
    dump_file = t.dump_file
    hostile = t.hostile
    # File errors in backup and restore are refused naming the action and the path; earlier files are kept.
    folder = Path(tmp) / "unwritable"
    folder.mkdir()
    earlier = folder / "refdata.sql"
    earlier.write_bytes(b"-- an earlier backup\n")
    (folder / "refdata.sql.partial").mkdir()   # the dump's own file cannot be created there
    code, out = safe_call(["backup", str(earlier)] + base)
    checks.check("a backup whose destination cannot be written is refused by name, the earlier backup kept",
                 code == 1 and "backup could not write" in out and str(earlier) in out and "was kept unchanged" in out
                 and earlier.read_bytes() == b"-- an earlier backup\n", f"exit {code}, said {out.strip()!r}")

    locked = Path(tmp) / "locked.sql"
    locked.write_bytes(b"-- the backup an editor holds open\n")
    handle = held(locked, 1)
    try:
        code, out = safe_call(["backup", str(locked)] + base)
    finally:
        kernel32.CloseHandle(handle)
    checks.check("a backup over an earlier one held open is refused by name, the earlier one byte-identical and no partial dump left",
                 code == 1 and "backup could not replace" in out and "the new dump was removed" in out
                 and locked.read_bytes() == b"-- the backup an editor holds open\n" and not locked.with_name("locked.sql.partial").exists(),
                 f"exit {code}, said {out.strip()!r}")

    unreadable = Path(tmp) / "unreadable.sql"
    unreadable.write_bytes(b"SELECT 1;\n")
    target = f"{database}_unread"
    handle = held(unreadable, 0)
    try:
        code, out = safe_call(["restore", str(unreadable), "--options", str(options), "--database", target])
    finally:
        kernel32.CloseHandle(handle)
    checks.check("a backup that cannot be read is refused by name, no database created",
                 code == 1 and "restore could not read" in out and str(unreadable) in out and not Session(options, target).exists(),
                 f"exit {code}, said {out.strip()!r}")

    # A restore user's option file that cannot be removed stops none of the other cleanup steps.
    outcomes = {}
    for label, dump, target in (("a successful restore", dump_file, f"{database}_heldok"), ("a failed restore", hostile, f"{database}_heldbad")):
        handles = []
        said = None
        try:
            with contextlib.redirect_stdout(io.StringIO()):
                cmd_restore(Session(options, target), str(dump), before_cleanup=lambda path: handles.append((path, held(path, 1))))
        except Refused as refusal:
            said = str(refusal)
        except Exception as exc:  # noqa: BLE001 -- an unhandled error is the failure this case exists to catch
            said = f"unhandled {type(exc).__name__}: {exc}"
        for path, handle in handles:
            kernel32.CloseHandle(handle)
            path.unlink(missing_ok=True)
        users = t.accounts_left()
        outcomes[label] = (said, users, Session(options, target).exists())
        run_sql(f"DROP DATABASE IF EXISTS `{target}`;", options=options)
    ok_said, ok_users, ok_kept = outcomes["a successful restore"]
    bad_said, bad_users, bad_kept = outcomes["a failed restore"]
    checks.check("a restore whose option file cannot be removed still drops its user, names the file, keeps a restored database and drops a failed one",
                 ok_said is not None and "was restored into" in ok_said and "could not be removed" in ok_said and ok_users == "0" and ok_kept
                 and bad_said is not None and "could not be loaded as rows" in bad_said and "could not be removed" in bad_said
                 and bad_users == "0" and not bad_kept and "the user it names was dropped" in ok_said, repr(outcomes))

    # One outage in the cleanup: the file is held and the server stopped, so the user's removal is unknown,
    # and the report says so rather than that it was dropped.
    target, handles = f"{database}_outage", []
    outage_said, started = None, ""

    def hold_and_stop(path: Path) -> None:
        handles.append((path, held(path, 1)))
        server("-Stop")

    try:
        with contextlib.redirect_stdout(io.StringIO()):
            cmd_restore(Session(options, target), str(dump_file), before_cleanup=hold_and_stop)
    except Refused as refusal:
        outage_said = str(refusal)
    except Exception as exc:  # noqa: BLE001 -- an unhandled error is the failure this case exists to catch
        outage_said = f"unhandled {type(exc).__name__}: {exc}"
    finally:
        for path, handle in handles:
            kernel32.CloseHandle(handle)
            path.unlink(missing_ok=True)
        started = server("-Start")
    # Only the account this case's restore made, by the command its refusal gave, run as given.
    for command in re.findall(r"DROP USER IF EXISTS 'refdata_restore_[0-9a-f]+'@'[^']*';", outage_said or ""):
        run_sql(command, options=options)
    run_sql(f"DROP DATABASE IF EXISTS `{target}`;", options=options)
    checks.check("a restore whose cleanup meets an outage says the user's removal could not be confirmed, never that it was dropped",
                 outage_said is not None and "the user it names could not be confirmed removed" in outage_said
                 and "DROP USER IF EXISTS 'refdata_restore_" in outage_said and "was dropped" not in outage_said
                 and started.startswith("exit 0"), f"said {outage_said!r}; restart {started!r}")


def _phase_upgrade_and_tls(t: SelfTestRun) -> None:
    checks, options, database, tmp = t.checks, t.options, t.database, str(t.tmp)
    held, server, kernel32 = t.held, t.server, t.kernel32
    expected_v1 = t.expected_v1
    expected_v2 = t.expected_v2
    # A database at schema revision 1 is upgraded with nothing lost; until then, commands on it are refused.
    old_schema = Path(tmp) / "schema-revision-1.sql"
    old_schema.write_text(subprocess.run(["git", "-C", str(REPO), "show", "61d88277:data/refdata/schema.sql"], capture_output=True,
                                         check=True, encoding="utf-8").stdout, encoding="utf-8")
    old = Session(options, f"{database}_r1")
    upgraded, lossy = f"{database}_r2", f"{database}_r2lossy"
    tls_restored, tls_upgraded, tls_refused, tls_refused_up = (f"{database}_tls", f"{database}_tlsup", f"{database}_tlsno", f"{database}_tlsupno")
    rel_restored, rel_upgraded = f"{database}_rel", f"{database}_relup"
    try:
        with contextlib.redirect_stdout(io.StringIO()):
            cmd_init(old, old_schema)
        for fixture in ("fixture-v1.json", "fixture-v2.json"):
            old.sql(proposal_sql(json.loads((FIXTURES / fixture).read_text(encoding="utf-8")), None))
            if fixture == "fixture-v1.json":
                old.sql("SET autocommit = 0;\nSTART TRANSACTION;\nCALL rd_review('fixture', 1, 'author-two', 'checked against both manuals');\nCOMMIT;\n")
                old.sql("SET autocommit = 0;\nSTART TRANSACTION;\nCALL rd_stamp('fixture', 1, 'author-one', 'release the first version');\nCOMMIT;\n")
        old_state = {name: old.sql(query) for name, query in UPGRADE_READBACK.items()}
        code, out = call(["list", "--options", str(options), "--database", old.database])
        refused_old = code == 1 and f"upgrade --database {old.database}" in out

        lossy_said = None
        try:
            with contextlib.redirect_stdout(io.StringIO()):
                cmd_upgrade(old, lossy, after_restore=lambda new: new.sql("DELETE FROM changelog ORDER BY id DESC LIMIT 1;"))
        except Refused as refusal:
            lossy_said = str(refusal)
        checks.check("an upgrade whose copy lost a changelog row is refused naming it, the copy dropped and the old database unchanged",
                     lossy_said is not None and "changelog has" in lossy_said and f"refdata.py upgrade --database {old.database} --to" in lossy_said and not Session(options, lossy).exists()
                     and {name: old.sql(query) for name, query in UPGRADE_READBACK.items()} == old_state, repr(lossy_said))

        # A database already at this revision is told there is nothing to upgrade and to work in it, never to retry.
        current_said = None
        try:
            with contextlib.redirect_stdout(io.StringIO()):
                cmd_upgrade(Session(options, database), f"{database}_again")
        except Refused as refusal:
            current_said = str(refusal)
        checks.check("an upgrade of a database already at this revision says to work in it, with no retry advice",
                     current_said is not None and "there is nothing to upgrade: work in it" in current_said and "upgrade --database" not in current_said
                     and not Session(options, f"{database}_again").exists(), repr(current_said))

        # An upgrade whose restore could not clean up says its copy is loaded but unverified.
        unverified, handles = f"{database}_unverified", []
        unverified_said = None
        try:
            with contextlib.redirect_stdout(io.StringIO()):
                cmd_upgrade(old, unverified, before_cleanup=lambda path: handles.append((path, held(path, 1))))
        except Refused as refusal:
            unverified_said = str(refusal)
        except Exception as exc:  # noqa: BLE001 -- an unhandled error is the failure this case exists to catch
            unverified_said = f"unhandled {type(exc).__name__}: {exc}"
        for path, handle in handles:
            kernel32.CloseHandle(handle)
            path.unlink(missing_ok=True)
        checks.check("an upgrade whose restore could not clean up names its copy as unverified, with how to drop it, the old database unchanged",
                     unverified_said is not None and f"'{unverified}' is loaded but unverified" in unverified_said and f"refdata.py upgrade --database {old.database} --to" in unverified_said
                     and f"DROP DATABASE IF EXISTS `{unverified}`;" in unverified_said
                     and {name: old.sql(query) for name, query in UPGRADE_READBACK.items()} == old_state, repr(unverified_said))
        run_sql(f"DROP DATABASE IF EXISTS `{unverified}`;", options=options)

        # Another author's upgrade takes the new name after this one's check and before its restore: this one is
        # refused, and never tells anybody to drop the database the other author made.
        taken = f"{database}_taken"
        raced_said = None
        try:
            with contextlib.redirect_stdout(io.StringIO()):
                cmd_upgrade(old, taken, before_restore=lambda: run_sql(f"CREATE DATABASE `{taken}`;", options=options))
        except Refused as refusal:
            raced_said = str(refusal)
        checks.check("an upgrade whose new name another author took meanwhile is refused without advising a drop, that database left alone",
                     raced_said is not None and "already exists" in raced_said and "DROP DATABASE" not in raced_said and f"refdata.py upgrade --database {old.database} --to" in raced_said
                     and Session(options, taken).exists(), repr(raced_said))
        run_sql(f"DROP DATABASE IF EXISTS `{taken}`;", options=options)

        # A comparison that fails keeps its reason; on one outage the drop fails too, and the copy is named.
        def comparison_fails(new: Session) -> None:
            raise Refused("refused: the drill's comparison read failed")

        failed_said = None
        try:
            with contextlib.redirect_stdout(io.StringIO()):
                cmd_upgrade(old, f"{database}_cmpfail", after_restore=comparison_fails)
        except Refused as refusal:
            failed_said = str(refusal)
        outage_copy = f"{database}_cmpoutage"
        outage_up_said, started = None, ""
        try:
            with contextlib.redirect_stdout(io.StringIO()):
                cmd_upgrade(old, outage_copy, after_restore=lambda new: server("-Stop"))
        except Refused as refusal:
            outage_up_said = str(refusal)
        except Exception as exc:  # noqa: BLE001 -- an unhandled error is the failure this case exists to catch
            outage_up_said = f"unhandled {type(exc).__name__}: {exc}"
        finally:
            started = server("-Start")
        left_after_outage = Session(options, outage_copy).exists()
        command = f"DROP DATABASE IF EXISTS `{outage_copy}`;"
        if outage_up_said and command in outage_up_said:
            run_sql(command, options=options)   # the command the refusal gave, run as given
        checks.check("an upgrade's rollback keeps the comparison's reason, and on an outage names the copy it could not remove with the command that removes it",
                     failed_said is not None and "the drill's comparison read failed" in failed_said and "was dropped" in failed_said and f"refdata.py upgrade --database {old.database} --to" in failed_said
                     and not Session(options, f"{database}_cmpfail").exists()
                     and outage_up_said is not None and "could not be compared" in outage_up_said and "could not be confirmed removed" in outage_up_said
                     and command in outage_up_said and started.startswith("exit 0") and left_after_outage and not Session(options, outage_copy).exists(),
                     f"failed {failed_said!r}; outage {outage_up_said!r}; restart {started!r}; copy left {left_after_outage}")

        code, out = call(["upgrade", "--options", str(options), "--database", old.database, "--to", upgraded])
        new = Session(options, upgraded)
        code2, said = call(["history", "fixture", "--options", str(options), "--database", upgraded]) if new.exists() else (None, "")
        checks.check("a revision 1 database with a stamped and a proposed version upgrades with every version and changelog row the same, "
                     "earlier edits named as not recorded, and a command on the old one refused naming the upgrade",
                     refused_old and code == 0 and new.exists() and version_text(new, "fixture", 1) == expected_v1
                     and version_text(new, "fixture", 2) == expected_v2 and require_version(new, "fixture", 2) == "proposed"
                     and code2 == 0 and "v1 add beep-1-long by author-one: first entry  (contents not recorded" in said
                     and {name: old.sql(query) for name, query in UPGRADE_READBACK.items()} == old_state,
                     f"old refused {refused_old}; upgrade exit {code} {out.strip()!r}; history {said.strip()[:400]!r}")

        # A restore and an upgrade connect as the author's own connections do: an option file that verifies the
        # server's certificate is obeyed by the restricted connection too. The private server's own CA verifies;
        # a CA that did not sign its certificate, put into the restricted file alone, is refused there.
        ca = HOME / "server" / "data" / "ca.pem"
        secure = Path(tmp) / "secure.cnf"
        secure.write_bytes(options.read_bytes().rstrip(b"\r\n") + f"\r\nssl-mode=VERIFY_CA\r\nssl-ca={ca.as_posix()}\r\n".encode("ascii"))
        roots = ssl.create_default_context().get_ca_certs(binary_form=True)
        other_ca = Path(tmp) / "other-ca.pem"
        other_ca.write_text(ssl.DER_cert_to_PEM_cert(roots[0]) if roots else "", encoding="ascii")
        cipher = run_sql("SHOW SESSION STATUS LIKE 'Ssl_cipher';", options=secure) if ca.is_file() else []
        tls_dump = Path(tmp) / "tls.sql"
        with contextlib.redirect_stdout(io.StringIO()):
            cmd_backup(Session(secure, database), str(tls_dump))
        code, out = call(["restore", str(tls_dump), "--options", str(secure), "--database", tls_restored])
        code2, out2 = call(["upgrade", "--options", str(secure), "--database", old.database, "--to", tls_upgraded])
        checks.check("a restore and an upgrade through an option file that verifies the server's CA succeed, over TLS",
                     bool(roots) and ca.is_file() and bool(cipher) and bool(cipher[0][1]) and code == 0 and code2 == 0
                     and Session(options, tls_restored).exists() and Session(options, tls_upgraded).exists(),
                     f"CA {ca.is_file()}, roots {len(roots)}, cipher {cipher!r}; restore {code} {out.strip()!r}; upgrade {code2} {out2.strip()!r}")

        wrong = {"ssl-ca": other_ca.as_posix()}
        said_restore = said_upgrade = None
        for target_name, action in ((tls_refused, lambda: cmd_restore(Session(secure, tls_refused), str(tls_dump), restricted_override=wrong)),
                                    (tls_refused_up, lambda: cmd_upgrade(Session(secure, old.database), tls_refused_up, restricted_override=wrong))):
            try:
                with contextlib.redirect_stdout(io.StringIO()):
                    action()
            except Refused as refusal:
                if target_name == tls_refused:
                    said_restore = str(refusal)
                else:
                    said_upgrade = str(refusal)
        users = t.accounts_left()
        checks.check("a restore and an upgrade whose restricted connection is given a CA that did not sign the server's certificate are refused "
                     "naming that connection, no database or restore user left and the source unchanged",
                     said_restore is not None and "restore user's connection" in said_restore and said_upgrade is not None
                     and "restore user's connection" in said_upgrade and f"refdata.py upgrade --database {old.database} --to" in said_upgrade
                     and not Session(options, tls_refused).exists()
                     and not Session(options, tls_refused_up).exists() and users == "0"
                     and {name: old.sql(query) for name, query in UPGRADE_READBACK.items()} == old_state,
                     f"restore said {said_restore!r}; upgrade said {said_upgrade!r}; restore users left {users}")

        # A CA named relative to the author's option file names the same file for the restore's connection.
        beside = Path(tmp) / "relative"
        beside.mkdir()
        (beside / "server-ca.pem").write_bytes(ca.read_bytes())
        relative = beside / "relative.cnf"
        relative.write_bytes(options.read_bytes().rstrip(b"\r\n") + b"\r\nssl-mode=VERIFY_CA\r\nssl-ca=server-ca.pem\r\n")
        code, out = call(["restore", str(tls_dump), "--options", str(relative), "--database", rel_restored])
        code2, out2 = call(["upgrade", "--options", str(relative), "--database", old.database, "--to", rel_upgraded])
        checks.check("a CA named relative to the author's option file verifies the restore's and the upgrade's connection too",
                     code == 0 and code2 == 0 and Session(options, rel_restored).exists() and Session(options, rel_upgraded).exists(),
                     f"restore {code} {out.strip()!r}; upgrade {code2} {out2.strip()!r}")

        # Settings the client reads are the ones the restore carries, however the file writes them: a group header
        # with a comment after it, and settings in an included file. Each is shown carried by the restricted
        # connection's refusal of the CA put into it alone.
        commented = Path(tmp) / "commented.cnf"
        commented.write_bytes(options.read_bytes().rstrip(b"\r\n") + f"\r\n[client] # a shared server\r\nssl-mode=VERIFY_CA\r\nssl-ca={ca.as_posix()}\r\n".encode("ascii"))
        tls_only = Path(tmp) / "tls-only.cnf"
        tls_only.write_bytes(f"[client]\r\nssl-mode=VERIFY_CA\r\nssl-ca={ca.as_posix()}\r\n".encode("ascii"))
        including = Path(tmp) / "including.cnf"
        including.write_bytes(options.read_bytes().rstrip(b"\r\n") + f"\r\n!include {tls_only.as_posix()}\r\n".encode("ascii"))
        carried = {}
        for label, author in (("a group header with a comment after it", commented), ("an included file", including)):
            target_name = f"{database}_carry"
            try:
                with contextlib.redirect_stdout(io.StringIO()):
                    cmd_restore(Session(author, target_name), str(tls_dump), restricted_override=wrong)
                carried[label] = "restored, so the CA was not carried"
            except Refused as refusal:
                carried[label] = str(refusal)
            run_sql(f"DROP DATABASE IF EXISTS `{target_name}`;", options=options)
        checks.check("TLS settings under a group header with a comment, or in an included file, are carried to the restore's connection",
                     all("restore user's connection" in said for said in carried.values()), repr(carried))

        # The restore's option file reads, through MySQL's own reader, as every option of the author's file in
        # its order (modifiers, a bind address, settings in other groups) and then the restore user's own.
        modified = Path(tmp) / "modified.cnf"
        modified.write_bytes(options.read_bytes().rstrip(b"\r\n") + b"\r\n[client] # a shared server\r\nloose-ssl-mode=VERIFY_IDENTITY\r\nloose_ssl_ca=server-ca.pem\r\n"
                             b"bind-address=127.0.0.1\r\nget-server-public-key\r\nskip-get-server-public-key\r\n[mysql]\r\nloose-compression-algorithms=zlib\r\n")
        beside_it = modified.with_name("restore-check.cnf")
        beside_it.write_bytes(restricted_option_bytes(modified, "restore-user", "restore-secret"))
        author_reads, restore_reads = client_settings(modified), client_settings(beside_it)
        checks.check("the restore's option file reads as every option of the author's, in order, then the restore user's alone",
                     restore_reads[:len(author_reads)] == author_reads and "bind-address=127.0.0.1" in author_reads
                     and [o.partition("=")[0] for o in restore_reads[len(author_reads):]] == ["user", "password", "user", "password"]
                     and restore_reads[len(author_reads)] == "user=restore-user",
                     f"author {author_reads!r}; restore {restore_reads!r}")
    finally:
        for name in (old.database, upgraded, lossy, tls_restored, tls_upgraded, tls_refused, tls_refused_up, rel_restored, rel_upgraded, f"{database}_carry"):
            run_sql(f"DROP DATABASE IF EXISTS `{name}`;", options=options)


def _phase_force_list_and_timeout(t: SelfTestRun) -> None:
    checks, session, options, database, base, tmp = t.checks, t.session, t.options, t.database, t.base, str(t.tmp)
    proposal = t.proposal
    # An option file that tells the client to go on past errors cannot make a refused proposal commit.
    forcing = Path(tmp) / "forcing.cnf"
    forcing.write_bytes(options.read_bytes().rstrip(b"\r\n") + b"\r\n[mysql]\r\nforce\r\n")
    versions_before = session.sql("SELECT COUNT(*) FROM versions;")[0][0]
    code, out = call(["propose", proposal("forced", {"dataset": "fixture", "author": "author-one", "reason": "two changes, the second refused", "changes": [
        {"add": "beep-forced", "text": "kept only if force wins", "reason": "first"}, {"add": "beep-1-long", "text": "a reused key", "reason": "second"}]}),
        "--version", "6", "--options", str(forcing), "--database", database])
    forced_left = session.sql("SELECT COUNT(*) FROM entries WHERE entry_key = 'beep-forced';")[0][0]
    checks.check("an option file with force cannot make a refused proposal commit the changes before it",
                 code == 1 and "keys are never reused" in out and forced_left == "0" and session.sql("SELECT COUNT(*) FROM versions;")[0][0] == versions_before,
                 f"exit {code}, entry left {forced_left}, said {out.strip()!r}")

    # A dataset and an author named NULL list as that text.
    call(["propose", proposal("named-null", {"dataset": "NULL", "create": "a dataset named NULL", "author": "NULL",
                                             "reason": "a dataset and author named NULL", "changes": [{"add": "k", "text": "t", "reason": "r"}]})] + base)
    code, out = call(["list"] + base)
    checks.check("list prints a dataset and an author named NULL as that text", code == 0 and "NULL v1: proposed, author NULL" in out, out.strip()[-300:])

    # A backup whose dump outlasts its time is ended and refused by name, with nothing left behind.
    slow = Path(tmp) / "slow.sql"
    slow.write_bytes(b"-- an earlier backup\n")
    locker = subprocess.Popen([str(client_path()), f"--defaults-extra-file={options.name}", "--batch", database],
                              stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=str(options.parent))
    assert locker.stdin is not None   # stdin=PIPE above
    locker.stdin.write(b"LOCK TABLES changelog WRITE;\nDO SLEEP(8);\nUNLOCK TABLES;\n")
    locker.stdin.close()
    locked, deadline = False, time.monotonic() + 15
    while time.monotonic() < deadline and locker.poll() is None:
        if run_sql("SELECT COUNT(*) FROM information_schema.processlist WHERE info LIKE 'DO SLEEP(8)%';", options=options)[0][0] != "0":
            locked = True
            break
        time.sleep(0.1)
    try:
        cmd_backup(session, str(slow), timeout=2)
        said = "the backup finished"
    except Refused as refusal:
        said = str(refusal)
    except Exception as exc:  # noqa: BLE001 -- an unhandled error is the failure this case exists to catch
        said = f"unhandled {type(exc).__name__}: {exc}"
    try:
        locker.communicate(timeout=60)
    except subprocess.TimeoutExpired:
        _end_tree(locker)
    checks.check("a backup whose dump outlasts its time is ended and refused by name, no partial dump left and the earlier backup kept",
                 locked and "did not finish within 2s" in said and "the partial dump was removed" in said
                 and not slow.with_name("slow.sql.partial").exists() and slow.read_bytes() == b"-- an earlier backup\n",
                 f"lock held {locked}; said {said!r}")


def _phase_inspection_connection_restart(t: SelfTestRun) -> None:
    checks, session, options, database, base, tmp = t.checks, t.session, t.options, t.database, t.base, str(t.tmp)
    v1 = t.v1
    read_back = t.read_back
    # The inspection commands read the persisted records.
    for argv, want in ((["list"], "fixture v3: stamped"), (["show", "fixture", "2"], "beep-1-long: One long beep: no memory detected in any slot"),
                       (["changes", "fixture", "3"], "added beep-a: A, reworded"), (["history", "fixture"], "v3 reopen by author-one: one more change")):
        code, out = call(argv + base)
        checks.check(f"{argv[0]} reads the persisted records", code == 0 and want in out, out.strip()[:300])

    # Connection failures: named, non-zero, nothing written, no secret printed.
    versions_before = session.sql("SELECT COUNT(*) FROM versions;")[0][0]
    fake = "wrong-" + secrets.token_hex(6)
    missing = Path(tmp) / "absent.cnf"
    silent = Path(tmp) / "silent.cnf"
    silent.write_text("[client]\nuser=root\nhost=127.0.0.1\nport=1\n", encoding="ascii")
    badauth = Path(tmp) / "badauth.cnf"
    port = [line.split("=", 1)[1] for line in options.read_text(encoding="ascii").splitlines() if line.startswith("port=")][0]
    badauth.write_text(f"[client]\nuser=root\npassword={fake}\nhost=127.0.0.1\nport={port}\n", encoding="ascii")
    for label, path, expected in (("a missing option file", missing, "no option file"), ("a server that does not answer", silent, "does not answer"),
                                  ("failed authentication", badauth, "authentication failed")):
        code, out = call(["propose", v1, "--options", str(path), "--database", database])
        checks.check(f"refused: {label}", code == 1 and expected in out and fake not in out, out.strip())
    checks.check("the connection failures wrote nothing", session.sql("SELECT COUNT(*) FROM versions;")[0][0] == versions_before)

    # The stamped data survives a stop and start of the private server.
    for flag in ("-Stop", "-Start"):
        proc = subprocess.Popen(["pwsh", "-NoProfile", "-File", str(SERVER_SCRIPT), flag], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        try:
            said, _ = proc.communicate(timeout=180)
        except subprocess.TimeoutExpired:
            _end_tree(proc)
            said = f"did not finish within 180s and was ended with its children".encode()
        checks.check(f"server {flag}", proc.returncode == 0, said.decode("utf-8", "replace").strip()[-300:])
    read_back("after a server restart")


def self_test(schema: Path) -> int:
    checks = Checks()
    options = option_file(str(LOCAL_CNF))
    database = f"refdata_selftest_{secrets.token_hex(4)}"
    print(f"self-test database: {database} (private server, {options.name}); schema {schema}")
    before = other_databases(options, database)
    session = Session(options, database)
    if session.exists():
        raise Refused(f"refused: '{database}' already exists; the self-test never uses a database it did not create")
    base = ["--options", str(options), "--database", database]
    created = False
    with tempfile.TemporaryDirectory(prefix="refdata-selftest-") as tmp:
        run = SelfTestRun(checks, options, database, session, Path(tmp))
        try:
            code, out = call(["init", "--schema", str(schema)] + base)
            created = code == 0
            checks.check("the schema creates a fresh database", created, out.strip())
            if not created:
                return 1

            for phase in (_phase_workflow, _phase_restores, _phase_review_and_history, _phase_file_errors_and_cleanup, _phase_upgrade_and_tls, _phase_force_list_and_timeout, _phase_inspection_connection_restart):
                phase(run)
        except Refused as refusal:
            checks.check("the self-test ran to its end", False, str(refusal))
        finally:
            # Drops only the database this run created, and reports rather than raises, so a failure above is never hidden.
            try:
                if created and session.exists():
                    run_sql(f"DROP DATABASE `{database}`;", options=options)
                checks.check("the self-test database is dropped", not session.exists())
                after = other_databases(options, database)
                checks.check("every other database is unchanged", before == after, f"before {before}, after {after}")
            except Refused as refusal:
                checks.check(f"the self-test database {database} is dropped and the others checked", False, str(refusal))
    if checks.failed:
        print(f"self-test: {len(checks.failed)} failed: " + "; ".join(checks.failed))
        return 1
    print("self-test: all pass")
    return 0



# ----- entry ------------------------------------------------------------------------------------------------------

def parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="refdata.py", description="Reference-data authoring (D00 T06 section 1).")
    p.add_argument("--self-test", action="store_true")
    p.add_argument("--schema", default=str(SCHEMA))
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--options", help="the MySQL option file (default: client.cnf if present, else local.cnf)")
    common.add_argument("--database", default=os.environ.get("RESOLUTE_REFDATA_DATABASE", DEFAULT_DATABASE))
    sub = p.add_subparsers(dest="command")
    init = sub.add_parser("init", parents=[common])
    init.add_argument("--schema", dest="init_schema", default=None)
    pr = sub.add_parser("propose", parents=[common])
    pr.add_argument("file")
    pr.add_argument("--version", type=int)
    for step in ("review", "reopen", "stamp"):
        sp = sub.add_parser(step, parents=[common])
        sp.add_argument("dataset")
        sp.add_argument("number", type=int)
        sp.add_argument("--as", dest="actor", required=True)
        sp.add_argument("--reason", required=True)
        if step == "review":
            sp.add_argument("--inspected", required=True, help="the digest refdata.py changes printed for what was reviewed")
    sub.add_parser("list", parents=[common])
    sh = sub.add_parser("show", parents=[common])
    sh.add_argument("dataset")
    sh.add_argument("number", type=int, nargs="?")
    ch = sub.add_parser("changes", parents=[common])
    ch.add_argument("dataset")
    ch.add_argument("number", type=int)
    hi = sub.add_parser("history", parents=[common])
    hi.add_argument("dataset")
    bk = sub.add_parser("backup", parents=[common])
    bk.add_argument("file")
    rs = sub.add_parser("restore", parents=[common])
    rs.add_argument("file")
    up = sub.add_parser("upgrade", parents=[common])
    up.add_argument("--to", required=True)
    return p


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    try:
        if args.self_test:
            return self_test(Path(args.schema))
        if not args.command:
            parser().print_help()
            return 1
        session = Session(option_file(args.options), args.database)
        if args.command == "init":
            return cmd_init(session, Path(args.init_schema) if args.init_schema else SCHEMA)
        if args.command == "propose":
            return cmd_propose(session, args.file, args.version)
        if args.command in ("review", "reopen", "stamp"):
            return cmd_step(session, args.command, args.dataset, args.number, args.actor, args.reason, getattr(args, "inspected", None))
        if args.command == "list":
            return cmd_list(session)
        if args.command == "show":
            return cmd_show(session, args.dataset, args.number)
        if args.command == "changes":
            return cmd_changes(session, args.dataset, args.number)
        if args.command == "history":
            return cmd_history(session, args.dataset)
        if args.command == "backup":
            return cmd_backup(session, args.file)
        if args.command == "restore":
            return cmd_restore(session, args.file)
        if args.command == "upgrade":
            return cmd_upgrade(session, check_name(args.to))
    except Refused as refusal:
        print(refusal)
        return 1
    return 1


if __name__ == "__main__":
    sys.exit(main())
