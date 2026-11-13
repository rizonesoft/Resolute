"""Reference-data authoring tool (D00 T06 section 1).

Drives the `mysql` client against the reference-data database. The workflow's rules live in the database as stored
procedures (data/refdata/schema.sql); this tool turns commands and proposal files into calls to them and reports each
refusal by name. Stdlib only, like the rest of scripts/; no database driver is added.

    refdata.py init                                   create the database from the schema
    refdata.py propose <proposal.json> [--version N]  open a version with its changes (or add to proposed version N)
    refdata.py review <dataset> <version> --as NAME --reason TEXT
    refdata.py reopen <dataset> <version> --as NAME --reason TEXT
    refdata.py stamp  <dataset> <version> --as NAME --reason TEXT
    refdata.py list                                   datasets and their versions with status
    refdata.py show <dataset> [<version>]             a version's entries and meanings, with sources
    refdata.py changes <dataset> <version>            what a version changes against the last stamped one before it
    refdata.py history <dataset>                      the changelog
    refdata.py backup <file>                          dump the database (schema, routines, data) to a file
    refdata.py restore <file> --database NAME         load a dump into a new database of that name
    refdata.py --self-test [--schema FILE]            prove the workflow on a database of its own

Connection details come only from a MySQL option file outside the repository: client.cnf beside local.cnf in
%LOCALAPPDATA%\\Resolute\\refdata when an author has written one for a shared server, otherwise the local.cnf that
`tools/refdata/server.ps1 -Start` writes for the private server. It is passed as --defaults-extra-file; no password is
ever an argument, and nothing this tool prints comes from the option file. Exit codes: 0 done, 1 refused.
"""

from __future__ import annotations

import argparse
import contextlib
import io
import json
import os
import re
import secrets
import subprocess
import sys
import tempfile
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


class Refused(Exception):
    """A refusal by name: the workflow's, the connection's, or the tool's."""


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
    exe = client_path(tool)
    if not exe.is_file():
        raise Refused(f"refused: no {tool} client at {exe} (run tools/refdata/server.ps1 -Install, or set RESOLUTE_REFDATA_CLIENT)")
    args = [str(exe), f"--defaults-extra-file={options}", "--connect-timeout=5", "--default-character-set=utf8mb4"]
    if tool == "mysql":
        args += ["--batch", "--skip-column-names"]
    args += list(extra)
    if database:
        args.append(database)
    proc = subprocess.Popen(args, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
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


def proposal_sql(proposal: dict, version: int | None) -> str:
    for field in ("dataset", "author", "changes"):
        if field not in proposal:
            raise Refused(f"refused: the proposal has no '{field}'")
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
        elif "rename" in change:
            lines.append(f"CALL rd_rename({sql_str(ds)}, {sql_str(change['rename'])}, {sql_str(change.get('to'))});")
        else:
            raise Refused("refused: a change names none of add, reword, rename")
    lines += ["SELECT @v;", "COMMIT;"]
    return "\n".join(lines) + "\n"


def cmd_propose(s: Session, path: str, version: int | None) -> int:
    try:
        proposal = json.loads(Path(path).read_text(encoding="utf-8"))
    except (OSError, ValueError) as exc:
        raise Refused(f"refused: the proposal {path} could not be read: {exc}") from None
    rows = s.sql(proposal_sql(proposal, version))
    print(f"proposed: {proposal['dataset']} version {rows[-1][0]}, {len(proposal['changes'])} change(s)")
    return 0


def cmd_step(s: Session, step: str, dataset: str, number: int, actor: str | None, reason: str) -> int:
    procedure = {"review": "rd_review", "reopen": "rd_reopen", "stamp": "rd_stamp"}[step]
    # One transaction: the check, the status change and the changelog row land together or not at all.
    s.sql(f"SET autocommit = 0;\nSTART TRANSACTION;\nCALL {procedure}({sql_str(dataset)}, {int(number)}, {sql_str(actor)}, {sql_str(reason)});\nCOMMIT;\n")
    print(f"{step}: {dataset} version {number} by {actor}")
    return 0


def cmd_list(s: Session) -> int:
    rows = s.sql(
        "SELECT d.name, v.number, v.status, v.author, v.reviewer FROM datasets d LEFT JOIN versions v ON v.dataset_id = d.id ORDER BY d.name, v.number;"
    )
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
        f"SELECT entry_key, text, source, meaning_from FROM rd_version_text WHERE dataset = {sql_str(dataset)} AND as_of = {int(number)} ORDER BY entry_key;"
    )
    return [(k, t, src, int(m)) for k, t, src, m in rows]


def require_version(s: Session, dataset: str, number: int) -> str:
    rows = s.sql(f"SELECT v.status FROM versions v JOIN datasets d ON d.id = v.dataset_id WHERE d.name = {sql_str(dataset)} AND v.number = {int(number)};")
    if not rows:
        raise Refused(f"refused: {dataset} has no version {number}")
    return rows[0][0]


def cmd_show(s: Session, dataset: str, number: int | None) -> int:
    number = latest_version(s, dataset) if number is None else number
    status = require_version(s, dataset, number)
    print(f"{dataset} v{number} ({status})")
    for key, text, source, since in version_text(s, dataset, number):
        print(f"  {key}: {text}  [source: {source or 'none'}; meaning from v{since}]")
    return 0


def changes_between(s: Session, dataset: str, number: int) -> tuple[int | None, list[str]]:
    require_version(s, dataset, number)
    rows = s.sql(
        f"SELECT MAX(v.number) FROM versions v JOIN datasets d ON d.id = v.dataset_id WHERE d.name = {sql_str(dataset)} AND v.status = 'stamped' AND v.number < {int(number)};"
    )
    base = int(rows[0][0]) if rows and rows[0][0] is not None else None
    before = {k: (t, src) for k, t, src, _ in version_text(s, dataset, base)} if base else {}
    after = {k: (t, src) for k, t, src, _ in version_text(s, dataset, number)}
    out = []
    for key in sorted(after):
        if key not in before:
            out.append(f"added {key}: {after[key][0]}  [source: {after[key][1] or 'none'}]")
        elif before[key] != after[key]:
            out.append(f"reworded {key}: {before[key][0]}  ->  {after[key][0]}  [source: {after[key][1] or 'none'}]")
    return base, out


def cmd_changes(s: Session, dataset: str, number: int) -> int:
    base, lines = changes_between(s, dataset, number)
    print(f"{dataset} v{number} against " + (f"v{base}, the last stamped before it" if base else "nothing stamped before it"))
    for line in lines or ["no changes"]:
        print(f"  {line}")
    return 0


def history_rows(s: Session, dataset: str) -> list[tuple]:
    rows = s.sql(
        "SELECT v.number, c.action, e.entry_key, c.actor, c.reason FROM changelog c JOIN versions v ON v.id = c.version_id "
        f"JOIN datasets d ON d.id = v.dataset_id LEFT JOIN entries e ON e.id = c.entry_id WHERE d.name = {sql_str(dataset)} ORDER BY c.id;"
    )
    return [(int(n), a, k, actor, r) for n, a, k, actor, r in rows]


def cmd_history(s: Session, dataset: str) -> int:
    rows = history_rows(s, dataset)
    if not rows:
        raise Refused(f"refused: the dataset '{dataset}' has no changelog")
    for number, action, key, actor, reason in rows:
        print(f"v{number} {action}" + (f" {key}" if key else "") + f" by {actor}: {reason}")
    return 0


def cmd_backup(s: Session, path: str) -> int:
    if not s.exists():
        raise Refused(f"refused: the database '{s.database}' does not exist")
    target = Path(path)
    exe = client_path("mysqldump")
    if not exe.is_file():
        raise Refused(f"refused: no mysqldump at {exe}")
    partial = target.with_name(target.name + ".partial")
    with open(partial, "wb") as out:
        proc = subprocess.Popen(
            [str(exe), f"--defaults-extra-file={s.options}", "--default-character-set=utf8mb4",
             # The data only: a restore builds the schema from data/refdata/schema.sql, the repository's own, and loads
             # these rows as a user that can do nothing else (cmd_restore).
             "--no-create-info", "--skip-triggers", "--skip-disable-keys", "--complete-insert", "--single-transaction",
             "--skip-dump-date", s.database],
            stdout=out, stderr=subprocess.PIPE)
        try:
            _, err = proc.communicate(timeout=TIMEOUT_SECONDS)
        except subprocess.TimeoutExpired:
            _end_tree(proc)
            partial.unlink()
            raise Refused(f"refused: the dump did not finish within {TIMEOUT_SECONDS}s and was ended; nothing was written") from None
    if proc.returncode != 0:
        partial.unlink()
        raise Refused(_classify(err.decode("utf-8", "replace"), s.database) + "; nothing was written")
    os.replace(partial, target)
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


def option_value(options: Path, key: str) -> str | None:
    for line in options.read_text(encoding="ascii", errors="replace").splitlines():
        if line.strip().startswith(f"{key}="):
            return line.split("=", 1)[1].strip()
    return None


def cmd_restore(s: Session, path: str, schema: Path = SCHEMA) -> int:
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
    text = dump.read_text(encoding="utf-8")
    reaches = dump_reaches_out(text)
    if reaches:
        raise Refused(f"refused: the dump {reaches}, so it would write outside '{s.database}'; take the backup with refdata.py backup, which names no database")
    user = f"refdata_restore_{secrets.token_hex(4)}"
    password = secrets.token_urlsafe(24)
    run_sql(f"CREATE DATABASE `{s.database}` CHARACTER SET utf8mb4;", options=s.options)
    restored = False
    with tempfile.TemporaryDirectory(prefix="refdata-restore-") as tmp:
        restricted = Path(tmp) / "restore.cnf"
        try:
            run_sql(schema.read_text(encoding="utf-8"), options=s.options, database=s.database)
            run_sql(f"CREATE USER '{user}'@'localhost' IDENTIFIED BY {sql_str(password)};\n"
                    f"GRANT SELECT, INSERT, LOCK TABLES ON `{s.database}`.* TO '{user}'@'localhost';", options=s.options)
            restricted.write_text(f"[client]\nuser={user}\npassword={password}\nhost={option_value(s.options, 'host') or '127.0.0.1'}\n"
                                  f"port={option_value(s.options, 'port') or '3306'}\n", encoding="ascii")
            try:
                run_sql(text, options=restricted, database=s.database)
            except Refused as refusal:
                raise Refused(f"refused: the backup could not be loaded as rows into '{s.database}' alone ({refusal}); nothing outside it was changed") from None
            restored = True
        finally:
            run_sql(f"DROP USER IF EXISTS '{user}'@'localhost';", options=s.options)
            if not restored:
                run_sql(f"DROP DATABASE IF EXISTS `{s.database}`;", options=s.options)
    print(f"restored {dump} into '{s.database}'")
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
        def proposal(name: str, body: dict) -> str:
            path = Path(tmp) / f"{name}.json"
            path.write_text(json.dumps(body), encoding="utf-8")
            return str(path)

        def refused(label: str, argv: list[str], expected: str) -> None:
            code, out = call(argv + base)
            checks.check(f"refused: {label}", code == 1 and expected in out, f"exit {code}, said {out.strip()!r}")

        try:
            code, out = call(["init", "--schema", str(schema)] + base)
            created = code == 0
            checks.check("the schema creates a fresh database", created, out.strip())
            if not created:
                return 1

            # Version 1: proposed, refused review by its author, reviewed, stamped.
            v1 = str(FIXTURES / "fixture-v1.json")
            code, out = call(["propose", v1] + base)
            checks.check("version 1 is proposed from the fixture", code == 0 and "version 1" in out, out.strip())
            refused("a reviewer who is the author", ["review", "fixture", "1", "--as", "author-one", "--reason", "self"], "the reviewer is the author")
            refused("stamping an unreviewed version", ["stamp", "fixture", "1", "--as", "author-one", "--reason", "early"], "the version is not reviewed")
            code, _ = call(["review", "fixture", "1", "--as", "author-two", "--reason", "checked against both manuals"] + base)
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
            code, _ = call(["review", "fixture", "2", "--as", "author-two", "--reason", "the rewording matches the revised manual"] + base)
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
            _, lines = changes_between(session, "fixture", 2)
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
            call(["review", "fixture", "3", "--as", "author-two", "--reason", "looks right"] + base)
            refused("changing a reviewed version", ["propose", proposal("frozen", {"dataset": "fixture", "author": "author-one", "changes": [
                {"reword": "beep-a", "text": "A, reworded", "reason": "after review"}]}), "--version", "3"], "reviewed and frozen")
            code, _ = call(["reopen", "fixture", "3", "--as", "author-one", "--reason", "one more change"] + base)
            code2, _ = call(["propose", proposal("after-reopen", {"dataset": "fixture", "author": "author-one", "changes": [
                {"reword": "beep-a", "text": "A, reworded", "reason": "after reopening"}]}), "--version", "3"] + base)
            checks.check("reopen returns the version to proposed and it changes", code == 0 and code2 == 0)
            refused("stamping a reopened version before it is reviewed again", ["stamp", "fixture", "3", "--as", "author-one", "--reason", "on the old approval"], "the version is not reviewed")
            code, _ = call(["review", "fixture", "3", "--as", "author-two", "--reason", "the change after reopening is right"] + base)
            code2, _ = call(["stamp", "fixture", "3", "--as", "author-one", "--reason", "release the third version"] + base)
            checks.check("the reopened version is stamped after a second review", code == 0 and code2 == 0)

            # Someone who changed a version is not its reviewer, whoever opened it (the cases follow the failed review below).
            # A step whose changelog row cannot be written, on a proposed version: still proposed afterwards.
            call(["propose", proposal("v4", {"dataset": "fixture", "author": "author-one", "reason": "a fourth version", "changes": [
                {"add": "beep-d", "text": "D", "reason": "a new entry"}]})] + base)
            refused_step = None
            try:
                cmd_step(session, "review", "fixture", 4, None, "a reviewer the changelog cannot record")
            except Refused as refusal:
                refused_step = str(refusal)
            log_rows = [r for r in history_rows(session, "fixture") if r[0] == 4]
            checks.check("a review whose changelog row fails leaves the version proposed, with no row of it",
                         refused_step is not None and require_version(session, "fixture", 4) == "proposed" and [r[1] for r in log_rows] == ["open", "add"],
                         f"refused {refused_step!r}, status {require_version(session, 'fixture', 4)}, changelog {log_rows}")
            code, _ = call(["propose", proposal("v4-contribution", {"dataset": "fixture", "author": "author-two", "changes": [
                {"add": "beep-c", "text": "C", "reason": "a contribution to version 4"}]}), "--version", "4"] + base)
            checks.check("a second author can add to a proposed version", code == 0)
            refused("a reviewer who changed the version", ["review", "fixture", "4", "--as", "author-two", "--reason", "my contribution looks right"], "the reviewer changed this version")
            code, _ = call(["review", "fixture", "4", "--as", "author-three", "--reason", "neither of us wrote it"] + base)
            checks.check("a reviewer who changed nothing reviews it", code == 0)

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
                    copied.sql("CALL rd_review('fixture', 4, 'author-one', 'the restored rules still hold');")
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
            users = run_sql("SELECT COUNT(*) FROM mysql.user WHERE user LIKE 'refdata_restore_%';", options=options)[0][0]
            checks.check("a backup that reaches into another database is refused, that database untouched, no target or user left",
                         code == 1 and "could not be loaded as rows" in out and len(history_rows(session, "fixture")) == before_rows
                         and not Session(options, target).exists() and users == "0", out.strip())

            # A dump that names a database is refused before anything is restored.
            named = Path(tmp) / "named.sql"
            named.write_text(f"-- a mysqldump --databases dump\nCREATE DATABASE /*!32312 IF NOT EXISTS*/ `{database}`;\nUSE `{database}`;\nDROP TABLE IF EXISTS `changelog`;\n", encoding="utf-8")
            target = f"{database}_restored"
            code, out = call(["restore", str(named), "--options", str(options), "--database", target])
            changelog_after = len(history_rows(session, "fixture"))
            checks.check("a dump that names a database is refused, restoring nothing and leaving that database as it was",
                         code == 1 and "selects, creates or drops a database (line 2" in out and not Session(options, target).exists() and changelog_after == len(history_rows(session, "fixture")),
                         out.strip())

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
            return cmd_step(session, args.command, args.dataset, args.number, args.actor, args.reason)
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
    except Refused as refusal:
        print(refusal)
        return 1
    return 1


if __name__ == "__main__":
    sys.exit(main())
