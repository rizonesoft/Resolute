"""Check the committed reference-data exports with no database (D00 T06 section 2).

    python scripts/refdata-verify.py              check data/refdata/export/ and data/refdata/fixtures/
    python scripts/refdata-verify.py <dir>...     check these directories instead
    python scripts/refdata-verify.py --self-test

The database stays on authoring machines; a build and CI have only the committed files. So this gate proves each
committed export is whole and unedited from what the file itself carries: it parses, it is in canonical form (written
again it gives the same bytes), its entry count is right, its file name is its dataset's, and the digest recomputed
from its entries is the one the database stamped into its header. Any failure names the file, the dataset and the
version. Whether the files are what the database holds now is the authoring machine's check: refdata.py export --check.
Stdlib only; the format lives in tools/refdata/refdata_format.py, shared with the exporter and the packer.
"""

from __future__ import annotations

import argparse
import sys
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO / "tools" / "refdata"))
import refdata_format as fmt   # after the path line above, which is what makes it importable

DEFAULT_DIRS = (REPO / "data" / "refdata" / "export", REPO / "data" / "refdata" / "fixtures")


def check_file(path: Path) -> str | None:
    """None when the export is sound, else one line saying what is wrong, naming the file."""
    try:
        export = fmt.parse(path.read_bytes(), path.name)
    except fmt.FormatError as error:
        return str(error)
    except OSError as error:
        return f"{path.name}: could not be read ({error.strerror or error})"
    if path.name != export.dataset + fmt.SUFFIX:
        return f"{path.name} (dataset {export.dataset}, version {export.version}): the file must be named {export.dataset}{fmt.SUFFIX}"
    return None


def check_dirs(dirs) -> tuple[list[str], int]:
    problems, count = [], 0
    for directory in dirs:
        if not directory.is_dir():
            continue   # no export yet is not a fault: the first dataset arrives with D00 T06 section 3
        for path in sorted(directory.glob("*" + fmt.SUFFIX)):
            count += 1
            problem = check_file(path)
            if problem:
                problems.append(problem)
    return problems, count


def self_test() -> int:
    failed = []

    def check(name: str, ok: bool, detail: str = "") -> None:
        print(("PASS " if ok else "FAIL ") + name + ("" if ok or not detail else f": {detail}"))
        if not ok:
            failed.append(name)

    entries = (("alpha", "first", "a book"), ("beta", "tab\there, line\nbreak, back\\slash, café 日本", None),
               ("gamma", "source is a hyphen", "-"), ("delta", "source is empty", ""))
    good = fmt.Export("sample", 3, fmt.digest_of("sample", 3, entries), entries)
    data = fmt.emit(good)
    with tempfile.TemporaryDirectory(prefix="refdata-verify-") as tmp:
        root = Path(tmp)

        def verdict(content: bytes, name: str = "sample.refdata") -> str | None:
            (root / name).write_bytes(content)
            result = check_file(root / name)
            (root / name).unlink()
            return result

        back = fmt.parse(data)
        check("a sound export passes, every awkward value read back as it was written",
              verdict(data) is None and back.entries == entries and back.entries[1][2] is None and back.entries[2][2] == "-" and back.entries[3][2] == "",
              repr(verdict(data)))
        edited = data.replace(b"first", b"FIRST")
        check("an edited entry fails naming the dataset and version",
              "dataset sample, version 3" in (verdict(edited) or "") and "edited after it was exported" in (verdict(edited) or ""), repr(verdict(edited)))
        lines = data.decode("utf-8").split("\n")
        reordered = "\n".join(lines[:5] + [lines[6], lines[5]] + lines[7:]).encode("utf-8")
        check("a reordered file fails naming the dataset", "dataset sample, version 3" in (verdict(reordered) or ""), repr(verdict(reordered)))
        miscounted = data.replace(b"entries 4", b"entries 5")
        check("a wrong count fails naming the dataset", "says 5 entries and the file holds 4" in (verdict(miscounted) or ""), repr(verdict(miscounted)))
        superscript = data.replace(b"version 3", "version ³".encode("utf-8"))
        check("a version that is a digit only to Unicode is refused by name, not a crash",
              "must be whole numbers" in (verdict(superscript) or ""), repr(verdict(superscript)))
        check("CR LF line ends fail", "LF" in (verdict(data.replace(b"\n", b"\r\n")) or ""))
        check("a file named for another dataset fails", "must be named sample.refdata" in (verdict(data, "other.refdata") or ""), repr(verdict(data, "other.refdata")))
        bad_name = fmt.emit(fmt.Export("Con", 1, fmt.digest_of("Con", 1, ()), ()))
        check("a dataset name that cannot be a file name fails", "lower-case" in (verdict(bad_name, "Con.refdata") or ""), repr(verdict(bad_name, "Con.refdata")))
        check("a name Windows reserves is refused", fmt.name_problem("con") is not None and fmt.name_problem("lpt3") is not None and fmt.name_problem("beep-codes_1") is None)
        check("a path separator in a name is refused", fmt.name_problem("a/b") is not None and fmt.name_problem("..") is not None and fmt.name_problem("a\\b") is not None)
        check("an unknown escape fails", "not an escape" in (verdict(data.replace(b"back\\\\slash", b"back\\qslash")) or ""))
        (root / "sample.refdata").write_bytes(data)
        (root / "broken.refdata").write_bytes(edited.replace(b"dataset sample", b"dataset broken"))
        problems, count = check_dirs([root, root / "absent"])
        check("a directory is checked whole, a missing one is not a fault", count == 2 and len(problems) == 1 and "broken" in problems[0], repr(problems))
    if failed:
        print(f"self-test: {len(failed)} failed: " + "; ".join(failed))
        return 1
    print("self-test: all pass")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="refdata-verify.py", description="Check the committed reference-data exports with no database.")
    parser.add_argument("dirs", nargs="*", type=Path)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args(argv)
    if args.self_test:
        return self_test()
    problems, count = check_dirs(args.dirs or DEFAULT_DIRS)
    for problem in problems:
        print(f"refdata-verify: {problem}")
    if problems:
        print(f"refdata-verify: {len(problems)} of {count} export(s) failed; a committed export is never edited by hand: "
              "change the data in the database and run python tools/refdata/refdata.py export")
        return 1
    print(f"refdata-verify: {count} export(s) sound")
    return 0


if __name__ == "__main__":
    sys.exit(main())
