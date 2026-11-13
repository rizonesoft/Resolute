"""Pack a reference-data export for embedding, and read embedded datasets back out of a built binary (D00 T06 section 2).

    python scripts/refdata-embed.py pack <export.refdata> <out.rdz>     compress one export into its embedded form
    python scripts/refdata-embed.py list <binary>                      list the datasets a built executable carries
    python scripts/refdata-embed.py resource-name <dataset>            the resource name a dataset is embedded under
    python scripts/refdata-embed.py --self-test

The build calls `pack` for each dataset a target names (cmake/ResoluteRefdata.cmake). The export is checked whole
before it is packed, so a bad file stops the build by name. Compression is the Windows Compression API (cabinet.dll,
XPRESS with Huffman), which the loader reads back through compressapi.h, so no library is added to the tree. A
compression call that fails stops the build naming the dataset: raw or empty bytes are never embedded.

`list` loads a built binary as data, never running it, and for each REFDATA_* resource decompresses it, checks it as an
export, and checks that the header's dataset, version and digest are the export's own. It exits 1 naming the dataset on
any disagreement. Stdlib only; the two forms live in tools/refdata/refdata_format.py.
"""

from __future__ import annotations

import argparse
import ctypes
import os
import sys
import tempfile
from ctypes import wintypes
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO / "tools" / "refdata"))
import refdata_format as fmt   # after the path line above, which is what makes it importable

RESOURCE_PREFIX = "REFDATA_"
RT_RCDATA = 10
ERROR_INSUFFICIENT_BUFFER = 122


class EmbedError(Exception):
    """A refusal by name."""


def resource_name(dataset: str) -> str:
    """REFDATA_ and the dataset's name in capitals, an underscore doubled and a hyphen written _H, so two datasets
    never share a resource name and the name is one a resource script accepts."""
    return RESOURCE_PREFIX + dataset.replace("_", "__").replace("-", "_h").upper()


def _cabinet():
    cabinet = ctypes.WinDLL("cabinet", use_last_error=True)
    for name in ("CreateCompressor", "CreateDecompressor"):
        getattr(cabinet, name).argtypes = [wintypes.DWORD, ctypes.c_void_p, ctypes.POINTER(ctypes.c_void_p)]
        getattr(cabinet, name).restype = wintypes.BOOL
    for name in ("Compress", "Decompress"):
        getattr(cabinet, name).argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t, ctypes.c_void_p, ctypes.c_size_t, ctypes.POINTER(ctypes.c_size_t)]
        getattr(cabinet, name).restype = wintypes.BOOL
    for name in ("CloseCompressor", "CloseDecompressor"):
        getattr(cabinet, name).argtypes = [ctypes.c_void_p]
        getattr(cabinet, name).restype = wintypes.BOOL
    return cabinet


def compress(data: bytes, what: str) -> bytes:
    cabinet = _cabinet()
    handle = ctypes.c_void_p()
    if not cabinet.CreateCompressor(fmt.ALGORITHM_XPRESS_HUFF, None, ctypes.byref(handle)):
        raise EmbedError(f"{what}: Windows could not create a compressor (error {ctypes.get_last_error()}); nothing was embedded")
    try:
        needed = ctypes.c_size_t()
        cabinet.Compress(handle, data, len(data), None, 0, ctypes.byref(needed))
        if ctypes.get_last_error() != ERROR_INSUFFICIENT_BUFFER or not needed.value:
            raise EmbedError(f"{what}: Windows could not size the compressed data (error {ctypes.get_last_error()}); nothing was embedded")
        buffer = ctypes.create_string_buffer(needed.value)
        written = ctypes.c_size_t()
        if not cabinet.Compress(handle, data, len(data), buffer, needed.value, ctypes.byref(written)):
            raise EmbedError(f"{what}: Windows could not compress the data (error {ctypes.get_last_error()}); nothing was embedded")
        packed = buffer.raw[:written.value]
    finally:
        cabinet.CloseCompressor(handle)
    if decompress(packed, len(data), what) != data:
        raise EmbedError(f"{what}: the compressed data does not decompress to what was compressed; nothing was embedded")
    return packed


def decompress(packed: bytes, raw_size: int, what: str) -> bytes:
    cabinet = _cabinet()
    handle = ctypes.c_void_p()
    if not cabinet.CreateDecompressor(fmt.ALGORITHM_XPRESS_HUFF, None, ctypes.byref(handle)):
        raise EmbedError(f"{what}: Windows could not create a decompressor (error {ctypes.get_last_error()})")
    try:
        buffer = ctypes.create_string_buffer(max(raw_size, 1))
        written = ctypes.c_size_t()
        if not cabinet.Decompress(handle, packed, len(packed), buffer, raw_size, ctypes.byref(written)) or written.value != raw_size:
            raise EmbedError(f"{what}: the embedded data does not decompress to the {raw_size} bytes its header promises (error {ctypes.get_last_error()})")
        return buffer.raw[:raw_size]
    finally:
        cabinet.CloseDecompressor(handle)


def pack_bytes(export_bytes: bytes, what: str, stamp_version: int | None = None) -> bytes:
    """An export's embedded form. stamp_version is the self-test's way to make a blob whose header disagrees with what
    it holds; the command line has no way to pass it."""
    try:
        export = fmt.parse(export_bytes, what)
    except fmt.FormatError as error:
        raise EmbedError(f"{error}; nothing was embedded") from None
    packed = compress(export_bytes, f"{what} (dataset {export.dataset}, version {export.version})")
    return fmt.blob_header(export.dataset, export.version if stamp_version is None else stamp_version, export.digest, len(export_bytes), len(packed)) + packed


def unpack_bytes(blob_bytes: bytes, what: str) -> tuple[fmt.Blob, fmt.Export, bytes]:
    """An embedded dataset opened and checked: the header, the export inside it, and the export's bytes. The header's
    dataset, version and digest must be the export's own, or the dataset is refused by name."""
    try:
        blob = fmt.read_blob(blob_bytes, what)
        raw = decompress(blob.payload, blob.raw_size, f"{what} (dataset {blob.dataset})")
        export = fmt.parse(raw, f"{what} (dataset {blob.dataset})")
    except fmt.FormatError as error:
        raise EmbedError(str(error)) from None
    if (blob.dataset, blob.version, blob.digest) != (export.dataset, export.version, export.digest):
        raise EmbedError(f"{what}: the dataset {blob.dataset} is stamped version {blob.version} and holds "
                         f"{export.dataset} version {export.version}; the stamp and the data disagree")
    return blob, export, raw


def cmd_pack(source: Path, target: Path) -> int:
    """Packs one export into its embedded form at target. The blob is written whole beside the target and read back
    before it is moved into place, so an earlier packed file is never left half replaced. Every step that can fail
    (reading the export, creating the folder, writing, reading back, moving, removing the staging file) ends in a
    refusal by name that keeps the first failure's reason; a staging file that could not be removed is named."""
    try:
        data = source.read_bytes()
    except OSError as error:
        raise EmbedError(f"{source}: could not be read ({error.strerror or error}); nothing was embedded") from None
    blob = pack_bytes(data, source.name)
    kept = "the earlier packed file is as it was" if target.exists() else "no packed file was written"
    try:
        target.parent.mkdir(parents=True, exist_ok=True)
    except OSError as error:
        raise EmbedError(f"{target.parent}: the folder could not be created ({error.strerror or error}); nothing was embedded; "
                         "check the build folder is writable and build again") from None
    partial = target.with_name(target.name + ".partial")

    def refuse(step: str, error: OSError) -> EmbedError:
        # The first failure is the one reported. Removing the staging file is tried, and its own failure is added
        # to the refusal, never put in the first one's place.
        left = ""
        try:
            if partial.is_file():
                partial.unlink()
            elif partial.exists():
                left = f"; the staging path {partial} is in the way and could not be removed: remove it by hand"
        except OSError as cleanup:
            left = f"; the staging file {partial} could not be removed ({cleanup.strerror or cleanup}): remove it by hand"
        return EmbedError(f"{target}: could not be {step} ({error.strerror or error}); {kept}, nothing was embedded{left}; build again once the cause is fixed")

    try:
        partial.write_bytes(blob)
        if partial.read_bytes() != blob:
            raise OSError("it did not read back as written")
    except OSError as error:
        raise refuse("written", error) from None
    try:
        os.replace(partial, target)
    except OSError as error:
        raise refuse("replaced", error) from None
    print(f"refdata-embed: packed {source.name}: {len(data)} bytes to {len(blob)} embedded")
    return 0


def embedded(binary: Path) -> dict[str, bytes]:
    """Every REFDATA_* resource of a built binary, read with the file loaded as data: nothing in it runs."""
    kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
    kernel32.LoadLibraryExW.argtypes = [wintypes.LPCWSTR, wintypes.HANDLE, wintypes.DWORD]
    kernel32.LoadLibraryExW.restype = ctypes.c_void_p
    kernel32.FreeLibrary.argtypes = [ctypes.c_void_p]
    proc = ctypes.WINFUNCTYPE(wintypes.BOOL, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p)
    kernel32.EnumResourceNamesW.argtypes = [ctypes.c_void_p, ctypes.c_void_p, proc, ctypes.c_void_p]
    kernel32.EnumResourceNamesW.restype = wintypes.BOOL
    kernel32.FindResourceW.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p]
    kernel32.FindResourceW.restype = ctypes.c_void_p
    kernel32.LoadResource.argtypes = [ctypes.c_void_p, ctypes.c_void_p]
    kernel32.LoadResource.restype = ctypes.c_void_p
    kernel32.LockResource.argtypes = [ctypes.c_void_p]
    kernel32.LockResource.restype = ctypes.c_void_p
    kernel32.SizeofResource.argtypes = [ctypes.c_void_p, ctypes.c_void_p]
    kernel32.SizeofResource.restype = wintypes.DWORD
    if not binary.is_file():
        raise EmbedError(f"{binary}: no such file")
    module = kernel32.LoadLibraryExW(str(binary), None, 0x00000002 | 0x00000020)   # as a data file and an image resource
    if not module:
        raise EmbedError(f"{binary}: Windows could not open it as a binary (error {ctypes.get_last_error()})")
    names: list[str] = []

    def each(_module, _kind, name, _param) -> bool:
        if name and name >> 16:   # a string name, not an ordinal
            names.append(ctypes.wstring_at(name))
        return True

    callback = proc(each)
    try:
        kernel32.EnumResourceNamesW(module, RT_RCDATA, callback, None)
        found = {}
        for name in names:
            if not name.startswith(RESOURCE_PREFIX):
                continue
            resource = kernel32.FindResourceW(module, ctypes.c_wchar_p(name), RT_RCDATA)
            data = kernel32.LockResource(kernel32.LoadResource(module, resource)) if resource else None
            if not data:
                raise EmbedError(f"{binary.name}: the resource {name} could not be read (error {ctypes.get_last_error()})")
            found[name] = ctypes.string_at(data, kernel32.SizeofResource(module, resource))
        return found
    finally:
        kernel32.FreeLibrary(module)


def cmd_list(binary: Path) -> int:
    found = embedded(binary)
    if not found:
        print(f"refdata-embed: {binary.name}: no dataset resources")
        return 0
    for name in sorted(found):
        blob, export, raw = unpack_bytes(found[name], f"{binary.name}, {name}")
        if name != resource_name(export.dataset):
            raise EmbedError(f"{binary.name}: the resource {name} holds the dataset {export.dataset}, which belongs under {resource_name(export.dataset)}")
        print(f"refdata-embed: {binary.name}: {name}: dataset {export.dataset} version {blob.version}, {len(export.entries)} entries, "
              f"{len(found[name])} bytes embedded, {len(raw)} bytes exported, digest {export.digest[:12]}")
    return 0


def self_test() -> int:
    failed = []

    def check(name: str, ok: bool, detail: str = "") -> None:
        print(("PASS " if ok else "FAIL ") + name + ("" if ok or not detail else f": {detail}"))
        if not ok:
            failed.append(name)

    def refusal(action) -> str:
        try:
            action()
            return ""
        except EmbedError as error:
            return str(error)

    entries = tuple((f"key-{i:03d}", f"Beep pattern {i}: check the memory modules and reseat them, then test again", "a manual") for i in range(200))
    data = fmt.emit(fmt.Export("sample", 4, fmt.digest_of("sample", 4, entries), entries))
    blob = pack_bytes(data, "sample.refdata")
    header, export, raw = unpack_bytes(blob, "the blob")
    check("a packed export unpacks to the same bytes, with its dataset, version and digest in the header",
          raw == data and (header.dataset, header.version, header.digest) == ("sample", 4, export.digest))
    check("a dataset of realistic size is smaller embedded than exported", len(blob) < len(data) // 2, f"{len(data)} bytes exported, {len(blob)} embedded")
    check("a header stamped with another version is refused naming the dataset",
          "the dataset sample is stamped version 9 and holds sample version 4" in refusal(lambda: unpack_bytes(pack_bytes(data, "sample.refdata", 9), "the blob")))
    check("an edited export is refused before it is packed, naming the dataset",
          "dataset sample, version 4" in refusal(lambda: pack_bytes(data.replace(b"reseat", b"RESEAT", 1), "sample.refdata")))
    check("a truncated blob is refused", "compressed bytes" in refusal(lambda: unpack_bytes(blob[:-7], "the blob")))
    check("corrupted compressed bytes are refused, never read as data",
          refusal(lambda: unpack_bytes(blob[:-40] + bytes(40), "the blob")) != "")
    bad_name = bytearray(blob)
    bad_name[26] = 0xFF
    check("a name that is not text is refused by name, not a crash", "name is not UTF-8" in refusal(lambda: unpack_bytes(bytes(bad_name), "the blob")),
          refusal(lambda: unpack_bytes(bytes(bad_name), "the blob")))
    check("bytes that are not an embedded dataset are refused", "not an embedded dataset" in refusal(lambda: unpack_bytes(b"MZ" + bytes(60), "the blob")))
    # A machine where the compression call fails: the build stops naming the dataset, with nothing embedded.
    real = globals()["_cabinet"]

    class _NoCompressor:
        def __getattr__(self, name):
            if name == "CreateCompressor":
                return lambda *_: 0
            return getattr(real(), name)

    globals()["_cabinet"] = _NoCompressor
    try:
        failed_compress = refusal(lambda: pack_bytes(data, "sample.refdata"))
    finally:
        globals()["_cabinet"] = real
    check("a compression call that fails stops the pack naming the dataset, never embedding raw bytes",
          "dataset sample, version 4" in failed_compress and "could not create a compressor" in failed_compress and "nothing was embedded" in failed_compress,
          failed_compress)
    check("resource names never collide", len({resource_name(n) for n in ("a-b", "a_b", "a_h", "a__b", "ab", "a-_", "a_-")}) == 7
          and resource_name("beep-codes_1") == "REFDATA_BEEP_HCODES__1")
    with tempfile.TemporaryDirectory(prefix="refdata-embed-") as tmp:
        root = Path(tmp)
        (root / "sample.refdata").write_bytes(data)
        cmd_pack(root / "sample.refdata", root / "out" / "sample.rdz")
        check("pack writes the blob whole and leaves no staging file",
              (root / "out" / "sample.rdz").read_bytes() == blob and not list((root / "out").glob("*.partial")))
        check("a missing export is refused by name", "could not be read" in refusal(lambda: cmd_pack(root / "absent.refdata", root / "out" / "x.rdz")))
        # The packer's own writes: every failure is a refusal by name that keeps the first reason.
        target = root / "out" / "sample.rdz"
        earlier = target.read_bytes()

        def outcome(action) -> str:
            # A failure the packer does not turn into a refusal is reported as what it is, not raised.
            try:
                action()
                return "no refusal"
            except EmbedError as error:
                return str(error)
            except OSError as error:
                return f"UNHANDLED {type(error).__name__}: {error}"

        def reason(action) -> str:
            # The reason Windows gives for the same operation made directly: what a refusal has to carry.
            try:
                action()
            except OSError as error:
                return str(error.strerror or error)
            return "the operation did not fail"

        (root / "afile").write_bytes(b"a file where a folder is needed")
        why = reason(lambda: (root / "afile" / "out").mkdir(parents=True))
        said = outcome(lambda: cmd_pack(root / "sample.refdata", root / "afile" / "out" / "sample.rdz"))
        check("a destination folder that cannot be created is refused by name",
              "UNHANDLED" not in said and f"could not be created ({why})" in said and "nothing was embedded" in said, said)
        partial = target.with_name(target.name + ".partial")
        partial.mkdir()   # the staging path is taken by a folder: the write fails, and so does removing it as a file
        why = reason(lambda: partial.write_bytes(b""))
        said = outcome(lambda: cmd_pack(root / "sample.refdata", target))
        check("a staging file that cannot be written or removed is refused with the first reason kept and the staging path named",
              "UNHANDLED" not in said and f"could not be written ({why})" in said and "could not be removed" in said and str(partial) in said
              and target.read_bytes() == earlier, said)
        partial.rmdir()
        kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
        kernel32.CreateFileW.restype = ctypes.c_void_p
        kernel32.CreateFileW.argtypes = [wintypes.LPCWSTR, wintypes.DWORD, wintypes.DWORD, ctypes.c_void_p, wintypes.DWORD, wintypes.DWORD, ctypes.c_void_p]
        kernel32.CloseHandle.argtypes = [ctypes.c_void_p]
        held = kernel32.CreateFileW(str(target), 0x80000000, 1, None, 3, 0x80, None)   # readable; it cannot be replaced while held
        try:
            (root / "sample.refdata").write_bytes(fmt.emit(fmt.Export("sample", 5, fmt.digest_of("sample", 5, entries), entries)))
            (root / "other").write_bytes(b"another file")
            why = reason(lambda: os.replace(root / "other", target))
            said = outcome(lambda: cmd_pack(root / "sample.refdata", target))
        finally:
            kernel32.CloseHandle(held)
        check("a packed file that cannot be replaced is refused by name, left as it was, with no staging file behind",
              "UNHANDLED" not in said and f"could not be replaced ({why})" in said and "is as it was" in said
              and target.read_bytes() == earlier and not partial.exists(), said)
        said = outcome(lambda: cmd_pack(root / "sample.refdata", target))
        check("the pack completes once nothing is in its way", said == "no refusal" and target.read_bytes() != earlier, said)
        check("a file that is not a binary is refused by name", "could not open it as a binary" in refusal(lambda: embedded(root / "sample.refdata")))
    if failed:
        print(f"self-test: {len(failed)} failed: " + "; ".join(failed))
        return 1
    print("self-test: all pass")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="refdata-embed.py", description="Pack reference-data exports for embedding, and list what a binary carries.")
    parser.add_argument("--self-test", action="store_true")
    sub = parser.add_subparsers(dest="command")
    pack = sub.add_parser("pack")
    pack.add_argument("export", type=Path)
    pack.add_argument("out", type=Path)
    listing = sub.add_parser("list")
    listing.add_argument("binary", type=Path)
    name = sub.add_parser("resource-name")
    name.add_argument("dataset")
    args = parser.parse_args(argv)
    try:
        if args.self_test:
            return self_test()
        if args.command == "pack":
            return cmd_pack(args.export, args.out)
        if args.command == "list":
            return cmd_list(args.binary)
        if args.command == "resource-name":
            problem = fmt.name_problem(args.dataset)
            if problem:
                raise EmbedError(f"{args.dataset}: {problem}")
            print(resource_name(args.dataset))
            return 0
    except EmbedError as error:
        print(f"refdata-embed: refused: {error}")
        return 1
    parser.print_help()
    return 1


if __name__ == "__main__":
    sys.exit(main())
