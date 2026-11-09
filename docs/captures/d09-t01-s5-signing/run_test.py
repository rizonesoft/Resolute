"""Regression test for D09 T01 S5: Distro must not log the signing password.

Part 1 extracts _RunSignCommand verbatim from a Distro.au3 source, runs it
in a harness with logging captured and _ProcessEx_RunCommand stubbed to
record what it receives, and checks:

- the captured log contains the complete masked Command: line,
- the captured log does not contain the dummy password,
- exactly one runner invocation happened,
- the executed command is the expected one (the password carried as one
  quoted argument; identical to the pre-change command apart from those
  quotes) and the working directory matches the pre-change one.

Part 2 exercises the shell layer: _RunSignCommand is run with the real
_ProcessEx_RunCommand (extracted from SDK/Includes/ProcessEx.au3) and a
fake signtool.exe that records its arguments, with the password
DUMMY6&SECRETTAIL. Before the fix the shell split the command at &, ran
SECRETTAIL as a command, and its error output (which _ProcessEx_RunCommand
logs) leaked the fragment into the log. After the fix the fake signtool
receives the whole password as one argument and the log stays clean. The
base (pre-change) function is run the same way and must show the leak.

Usage:
    python run_test.py --candidate <Distro.au3> [--base <Distro.au3>]

The pre-change source can be produced with:
    git show <base-commit>:resolute_au3/SDK/Concrete/Distro/Distro.au3 > base.au3
(binary-safe: write it with Python or git show --output, not a shell
redirect that re-encodes).
"""

import argparse
import pathlib
import subprocess
import sys
import tempfile

AUTOIT = r"C:\Program Files (x86)\AutoIt3\AutoIt3.exe"
AUT2EXE = r"C:\Program Files (x86)\AutoIt3\Aut2Exe\Aut2Exe.exe"
PROCESS_EX = pathlib.Path(__file__).resolve().parents[3] / "resolute_au3" / "SDK" / "Includes" / "ProcessEx.au3"
DUMMY = "DUMMY6"  # six characters, so the expected mask is ******
META = "DUMMY6&SECRETTAIL"
EXPECTED_MASKED = (
    'Command: signtool.exe sign /f "C:\cert\test.pfx" /p ****** '
    '/t http://timestamp.example "C:\out\Test.exe"'
)
EXPECTED_EXECUTED = (
    'signtool.exe sign /f "C:\cert\test.pfx" /p "DUMMY6" '
    '/t http://timestamp.example "C:\out\Test.exe"'
)

HARNESS_HEAD = """
Global $g_cSignTool = "C:\signdir\signtool.exe"
Global $g_sLog = ""
Global $g_sRuns = ""
Global $g_iRunCount = 0

Func _Logging_EditWrite($sMessage)
    $g_sLog &= $sMessage & @CRLF
EndFunc

Func _ProcessEx_RunCommand($sCommand, $sWorkingDir = "")
    $g_iRunCount += 1
    $g_sRuns &= $sCommand & "|" & $sWorkingDir & @CRLF
EndFunc

Func _FileEx_PathSplit($sPath, $iPart)
    Return "C:\signdir\"
EndFunc

"""

HARNESS_TAIL = """
_RunSignCommand("C:\out\Test.exe", "C:\cert\test.pfx", "Desc", _
    "https://example.invalid", "DUMMY6", "http://timestamp.example")
FileWrite("RESULT_PATH", "LOG<BEGIN>" & @CRLF & $g_sLog & "LOG<END>" & @CRLF & _
    "RUNS=" & $g_iRunCount & @CRLF & $g_sRuns)
"""

META_HEAD = """
#include <Constants.au3>
#include <StringConstants.au3>
Global $g_cSignTool = "FAKE_SIGNTOOL"
Global $g_sLog = ""

Func _Logging_EditWrite($sMessage)
    $g_sLog &= $sMessage & @CRLF
EndFunc

Func _FileEx_PathSplit($sPath, $iPart)
    Return "FAKE_DIR"
EndFunc

"""

META_TAIL = """
_RunSignCommand("C:\out\Test.exe", "C:\cert\test.pfx", "Desc", _
    "https://example.invalid", "DUMMY6&SECRETTAIL", "http://timestamp.example")
; The fake signtool is a GUI-subsystem exe, so cmd does not wait for it:
; give it time to record its arguments before the harness exits.
For $iWait = 1 To 100
    If FileExists("ARGV_PATH") Then ExitLoop
    Sleep(100)
Next
Sleep(500)
FileWrite("RESULT_PATH", $g_sLog)
"""

FAKE_SIGNTOOL = """
#AutoIt3Wrapper_Change2CUI=y
Local $sArgs = $CmdLine[0] & @CRLF
For $iArg = 1 To $CmdLine[0]
    $sArgs &= $CmdLine[$iArg] & @CRLF
Next
FileWrite("ARGV_PATH", $sArgs)
"""


def extract(source: str, name: str) -> str:
    start = source.index(f"Func {name}(")
    end = source.index("EndFunc", start) + len("EndFunc")
    return source[start:end]


def read(path) -> str:
    return pathlib.Path(path).read_bytes().decode("cp1252")


def run_au3(script: pathlib.Path) -> None:
    subprocess.run([AUTOIT, str(script)], check=True, timeout=300)


def run_harness(distro_path, workdir: pathlib.Path, tag: str) -> str:
    result_path = workdir / f"{tag}.txt"
    harness = (HARNESS_HEAD + extract(read(distro_path), "_RunSignCommand") + "\n" +
               HARNESS_TAIL.replace("RESULT_PATH", str(result_path)))
    harness_path = workdir / f"harness_{tag}.au3"
    harness_path.write_bytes(harness.encode("cp1252"))
    run_au3(harness_path)
    return result_path.read_bytes().decode("cp1252")


def parse(result: str):
    log = result.split("LOG<BEGIN>\r\n", 1)[1].split("LOG<END>", 1)[0]
    count = int([ln for ln in result.splitlines() if ln.startswith("RUNS=")][0].split("=", 1)[1])
    runs = [ln for ln in result.splitlines() if "|" in ln and not ln.startswith("RUNS=")]
    return log, count, runs


def build_fake_signtool(workdir: pathlib.Path) -> pathlib.Path:
    fake_dir = workdir / "fakebin"
    fake_dir.mkdir()
    src = workdir / "fake_signtool.au3"
    src.write_bytes(FAKE_SIGNTOOL.replace("ARGV_PATH", str(workdir / "argv.txt")).encode("cp1252"))
    out = fake_dir / "signtool.exe"
    subprocess.run([AUT2EXE, "/in", str(src), "/out", str(out), "/nopack"],
                   check=True, timeout=300, capture_output=True)
    assert out.exists(), "fake signtool was not compiled"
    return out


def run_meta(distro_path, fake_exe: pathlib.Path, workdir: pathlib.Path, tag: str) -> str:
    process_ex = read(PROCESS_EX)
    funcs = "\n\n".join(extract(process_ex, n) for n in
                        ("_ProcessEx_RunCommand", "__HasOutput", "__FormatRunOutput"))
    result_path = workdir / f"meta_{tag}.txt"
    argv = workdir / "argv.txt"
    head = META_HEAD.replace("FAKE_SIGNTOOL", str(fake_exe)).replace("FAKE_DIR", str(fake_exe.parent) + "\\")
    harness = (head + extract(read(distro_path), "_RunSignCommand") + "\n\n" + funcs + "\n" +
               META_TAIL.replace("RESULT_PATH", str(result_path)).replace("ARGV_PATH", str(argv)))
    harness_path = workdir / f"meta_{tag}.au3"
    harness_path.write_bytes(harness.encode("cp1252"))
    if argv.exists():
        argv.unlink()
    run_au3(harness_path)
    log = result_path.read_bytes().decode("cp1252") if result_path.exists() else ""
    argv_text = argv.read_bytes().decode("cp1252") if argv.exists() else ""
    return log, argv_text


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--candidate", required=True)
    ap.add_argument("--base")
    args = ap.parse_args()
    failures = []

    with tempfile.TemporaryDirectory(dir=r"R:\scratch") as tmp:
        tmp = pathlib.Path(tmp)
        cand_log, cand_count, cand_runs = parse(run_harness(args.candidate, tmp, "candidate"))
        if DUMMY in cand_log:
            failures.append("candidate log contains the dummy password")
        if EXPECTED_MASKED not in cand_log:
            failures.append("candidate log lacks the complete masked Command: line")
        if "Password: ******" not in cand_log:
            failures.append("candidate log lacks the Password: mask line")
        if cand_count != 1:
            failures.append(f"candidate runner invocations: {cand_count}, expected 1")
        cand_cmd = cand_runs[0].split("|", 1)[0] if cand_runs else ""
        cand_wd = cand_runs[0].split("|", 1)[1].rstrip("\\") if cand_runs and "|" in cand_runs[0] else ""
        if cand_cmd != EXPECTED_EXECUTED or cand_wd != "C:\\signdir":
            failures.append(f"candidate executed command/working directory not as expected: {cand_runs}")
        if args.base:
            base_log, base_count, base_runs = parse(run_harness(args.base, tmp, "base"))
            print(f"base log contains dummy password: {DUMMY in base_log} (expected True before the fix)")
            if base_count != 1:
                failures.append(f"base runner invocations: {base_count}, expected 1")
            if not base_runs or not cand_runs or base_runs[0].split("|", 1)[1] != cand_runs[0].split("|", 1)[1]:
                failures.append("working directory differs from the pre-change function")

        fake = build_fake_signtool(tmp)
        cand_meta_log, cand_argv = run_meta(args.candidate, fake, tmp, "candidate")
        if META in cand_meta_log or "SECRETTAIL" in cand_meta_log:
            failures.append("metachar password leaked into the log through the shell layer")
        cand_args = cand_argv.splitlines()[1:] if cand_argv else []
        if "/p" not in cand_args or cand_args[cand_args.index("/p") + 1] != META:
            failures.append(f"fake signtool did not receive the metachar password as one argument: {cand_argv!r}")
        if args.base:
            base_meta_log, _ = run_meta(args.base, fake, tmp, "base")
            leaked = "SECRETTAIL" in base_meta_log
            print(f"base metachar leak through shell layer: {leaked} (expected True before the fix)")
            if not leaked:
                failures.append("base function did not leak as expected; the metachar proof cannot discriminate")

    print("masked Command: line:", EXPECTED_MASKED)
    if failures:
        for f in failures:
            print("FAIL:", f)
        return 1
    print("PASS: log masked, dummy absent, one invocation, executed command as expected, metachar password safe through the shell layer")
    return 0


if __name__ == "__main__":
    sys.exit(main())
