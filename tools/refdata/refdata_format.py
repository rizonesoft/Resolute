"""The reference-data export format and the embedded form (D00 T06 section 2). One reader and one writer, used by the
exporter (tools/refdata/refdata.py export), the no-server gate (scripts/refdata-verify.py) and the build's packer
(scripts/refdata-embed.py), so the three cannot disagree about a byte. Stdlib only. docs/reference-data.md specifies
both forms; this file is their implementation.

An export file is UTF-8 text with LF line ends and a final LF:

    resolute-refdata 1
    dataset <name>
    version <number>
    entries <count>
    digest <64 hex digits>
    <key> TAB <text> TAB <source>        one line per entry, in the order the database's digest read them

A key and a text are escaped: a backslash as two, a tab as backslash-t, a line feed as backslash-n, a carriage
return as backslash-r. A source is "-" when the entry has none, and "=" followed by the escaped source when it has
one, so a source that is the text "-" (written "=-") and an empty source (written "=") are both told apart from none.

The digest is the one the database computes (rd_version_digest in data/refdata/schema.sql): a SHA-256 chain over the
dataset's name, the version, and each entry's key, text and source in that order. It is recomputed here from a file's
own entries, which is how a hand edit to a committed export is caught on a machine with no database.
"""

from __future__ import annotations

import hashlib
import re
import struct
from dataclasses import dataclass

FORMAT_LINE = "resolute-refdata 1"
SUFFIX = ".refdata"
# A dataset's name becomes a file name and a resource name, so it is held to what both accept everywhere: lower-case
# ASCII letters, digits, hyphens and underscores, starting with a letter or digit, and not a name Windows reserves.
NAME_RULE = re.compile(r"^[a-z0-9][a-z0-9_-]{0,62}$")
RESERVED_NAMES = frozenset(["con", "prn", "aux", "nul"] + [f"com{i}" for i in range(1, 10)] + [f"lpt{i}" for i in range(1, 10)])

BLOB_MAGIC = b"RSLRDAT1"
BLOB_FORMAT = 1
ALGORITHM_XPRESS_HUFF = 4   # COMPRESS_ALGORITHM_XPRESS_HUFF of the Windows Compression API (compressapi.h)
_BLOB_FIXED = struct.Struct("<8sHHIIIH")   # magic, format, algorithm, version, raw size, packed size, name length


class FormatError(Exception):
    """A file or blob that is not in the form this module writes. The message names what is wrong."""


@dataclass(frozen=True)
class Export:
    dataset: str
    version: int
    digest: str
    entries: tuple[tuple[str, str, str | None], ...]   # (key, text, source or None), in the database's order


def name_problem(name: str) -> str | None:
    """Why a dataset's name cannot be used as a file name, or None when it can."""
    if not NAME_RULE.match(name):
        return "a dataset's name must be lower-case letters, digits, hyphens and underscores, starting with a letter or digit, at most 63 long"
    if name in RESERVED_NAMES:
        return "Windows reserves that name for a device"
    return None


def _escape(value: str) -> str:
    return value.replace("\\", "\\\\").replace("\t", "\\t").replace("\n", "\\n").replace("\r", "\\r")


def _unescape(value: str, where: str) -> str:
    out, i = [], 0
    while i < len(value):
        ch = value[i]
        if ch != "\\":
            out.append(ch)
            i += 1
            continue
        nxt = value[i + 1: i + 2]
        if nxt not in ("\\", "t", "n", "r"):
            raise FormatError(f"{where}: a backslash is followed by {nxt!r}, which is not an escape this format has")
        out.append({"\\": "\\", "t": "\t", "n": "\n", "r": "\r"}[nxt])
        i += 2
    return "".join(out)


def digest_of(dataset: str, version: int, entries) -> str:
    """rd_version_digest, step for step: CHAR_LENGTH counts characters, as len() does, and SHA2 hashes the UTF-8."""
    digest = hashlib.sha256(f"refdata digest 1:{len(dataset)}:{dataset}:{version}".encode("utf-8")).hexdigest()
    for key, text, source in entries:
        tail = "-" if source is None else f"{len(source)}:{source}"
        digest = hashlib.sha256(f"{digest}{len(key)}:{key}{len(text)}:{text}{tail}".encode("utf-8")).hexdigest()
    return digest


def emit(export: Export) -> bytes:
    lines = [FORMAT_LINE, f"dataset {export.dataset}", f"version {export.version}", f"entries {len(export.entries)}", f"digest {export.digest}"]
    for key, text, source in export.entries:
        lines.append(f"{_escape(key)}\t{_escape(text)}\t" + ("-" if source is None else "=" + _escape(source)))
    return ("\n".join(lines) + "\n").encode("utf-8")


def parse(data: bytes, where: str = "the export") -> Export:
    """Reads an export and checks all of it: its form, its count, that writing it again gives the same bytes, and that
    its digest is the digest of its own entries. Any failure is a FormatError naming the dataset and version once the
    header has given them."""
    try:
        text = data.decode("utf-8")
    except UnicodeDecodeError as error:
        raise FormatError(f"{where}: not UTF-8 ({error.reason} at byte {error.start})") from None
    if not text.endswith("\n") or "\r\n" in text:
        raise FormatError(f"{where}: lines must end in LF, the last one included, and never in CR LF")
    lines = text[:-1].split("\n")
    if len(lines) < 5 or lines[0] != FORMAT_LINE:
        raise FormatError(f"{where}: does not begin with '{FORMAT_LINE}' and its four header lines")
    header = {}
    for label, line in zip(("dataset", "version", "entries", "digest"), lines[1:5]):
        if not line.startswith(label + " "):
            raise FormatError(f"{where}: header line '{line}' should be '{label} ...'")
        header[label] = line[len(label) + 1:]
    name = header["dataset"]
    if not header["version"].isdigit() or not header["entries"].isdigit():
        raise FormatError(f"{where} (dataset {name}): the version and the entry count must be whole numbers")
    version, count = int(header["version"]), int(header["entries"])
    named = f"{where} (dataset {name}, version {version})"
    problem = name_problem(name)
    if problem:
        raise FormatError(f"{named}: {problem}")
    if not re.fullmatch(r"[0-9a-f]{64}", header["digest"]):
        raise FormatError(f"{named}: the digest must be 64 lower-case hex digits")
    entries = []
    for number, line in enumerate(lines[5:], start=6):
        fields = line.split("\t")
        if len(fields) != 3 or fields[2][:1] not in ("-", "="):
            raise FormatError(f"{named}: line {number} is not key, text and source separated by tabs")
        if fields[2][:1] == "-" and len(fields[2]) != 1:
            raise FormatError(f"{named}: line {number} marks its source absent and then gives one")
        source = None if fields[2] == "-" else _unescape(fields[2][1:], f"{named}, line {number}")
        entries.append((_unescape(fields[0], f"{named}, line {number}"), _unescape(fields[1], f"{named}, line {number}"), source))
    if len(entries) != count:
        raise FormatError(f"{named}: the header says {count} entries and the file holds {len(entries)}")
    export = Export(name, version, header["digest"], tuple(entries))
    if emit(export) != data:
        raise FormatError(f"{named}: not in canonical form: writing it again gives different bytes")
    actual = digest_of(name, version, entries)
    if actual != export.digest:
        raise FormatError(f"{named}: its entries do not give the digest in its header, so it was edited after it was exported "
                          f"(header {export.digest[:12]}..., entries {actual[:12]}...)")
    return export


# ----- the embedded form ------------------------------------------------------------------------------------------

def blob_header(dataset: str, version: int, digest: str, raw_size: int, packed_size: int) -> bytes:
    """The header the build puts before a dataset's compressed export: magic, format 1, the algorithm, the version,
    both sizes, the name's length, the name in UTF-8, then the digest as 32 raw bytes. Little-endian."""
    name = dataset.encode("utf-8")
    return _BLOB_FIXED.pack(BLOB_MAGIC, BLOB_FORMAT, ALGORITHM_XPRESS_HUFF, version, raw_size, packed_size, len(name)) + name + bytes.fromhex(digest)


@dataclass(frozen=True)
class Blob:
    dataset: str
    version: int
    digest: str
    raw_size: int
    payload: bytes


def read_blob(data: bytes, where: str = "the embedded dataset") -> Blob:
    if len(data) < _BLOB_FIXED.size or data[:8] != BLOB_MAGIC:
        raise FormatError(f"{where}: not an embedded dataset (its first bytes are not {BLOB_MAGIC.decode()})")
    _, fmt, algorithm, version, raw_size, packed_size, name_length = _BLOB_FIXED.unpack_from(data)
    if fmt != BLOB_FORMAT or algorithm != ALGORITHM_XPRESS_HUFF:
        raise FormatError(f"{where}: format {fmt}, algorithm {algorithm}; this reader knows format {BLOB_FORMAT}, algorithm {ALGORITHM_XPRESS_HUFF}")
    start = _BLOB_FIXED.size + name_length + 32
    if len(data) != start + packed_size:
        raise FormatError(f"{where}: its header promises {packed_size} compressed bytes and {len(data) - start} follow")
    name = data[_BLOB_FIXED.size:_BLOB_FIXED.size + name_length].decode("utf-8")
    return Blob(name, version, data[_BLOB_FIXED.size + name_length:start].hex(), raw_size, data[start:])
