"""Regression test for D09 T01 S5: Distro must not log the signing password.

Part 1 extracts _RunSignCommand verbatim from a Distro.au3 source, runs it
in a harness with logging captured and the runner functions stubbed to
record what they receive, and checks:

- the captured log contains the complete masked Command: line,
- the captured log does not contain the dummy password,
- exactly one runner invocation happened,
- the executed command is the expected one: the full signtool path with
  the password carried as one escaped argument, shell-free (the
  pre-change command apart from how the password argument is carried),
  and the working directory matches the pre-change one.

Part 2 exercises the process layer for real: _RunSignCommand runs with
the runner it actually calls, extracted from SDK/Includes/ProcessEx.au3
(the shell _ProcessEx_RunCommand before the fix, the shell-free
_ProcessEx_RunCommandDirect after it), a fake signtool.exe in a path
containing spaces, which records its parsed arguments. Passwords tried:
a shell-metacharacter one, a quote-breakout one, a %VAR% one, one with a
trailing backslash, and one with a backslash before an embedded quote.
After the fix the argument after /p equals the password exactly and the
log contains neither the password nor any fragment of it; the pre-change
function leaks a fragment through the logged child output. A final case
points signtool at a missing executable: the log must carry only the
launch error, never the command.

Usage:
    python run_test.py --candidate <Distro.au3> [--base <Distro.au3>]

The pre-change source can be produced from git (binary-safe):
    python -c "import subprocess,sys; sys.stdout.buffer.write(subprocess.run(['git','show','<base>:resolute_au3/SDK/Concrete/Distro/Distro.au3'], capture_output=True).stdout)" > base.au3
"""

import argparse
import pathlib
import subprocess
import sys
import tempfile

AUTOIT = r"C:\Program Files (x86)\AutoIt3\AutoIt3.exe"
AUT2EXE = r"C:\Program Files (x86)\AutoIt3\Aut2Exe\Aut2Exe.exe"
REPO = pathlib.Path(__file__).resolve().parents[3]
PROCESS_EX = REPO / "resolute_au3" / "SDK" / "Includes" / "ProcessEx.au3"
DUMMY = "DUMMY6"  # six characters, so the expected mask is ******
PASSWORDS = [
    "DUMMY6&SECRETTAIL",
    'DUMMY"&echo SECRETTAIL&rem "',
    "%COMSPEC%SECRETTAIL",
    "DUMMY6\\",
    'DUMMY\\"SECRETTAIL',
]
EXPECTED_MASKED = (
    'Command: signtool.exe sign /f "C:\cert\test.pfx" /p ****** '
    '/t http://timestamp.example "C:\out\Test.exe"'
)
EXPECTED_EXECUTED = (
    '"C:\signdir\signtool.exe" sign /f "C:\cert\test.pfx" /p "DUMMY6" '
    '/t http://timestamp.example "C:\out\Test.exe"'
)

HARNESS_HEAD = """
#include <Constants.au3>
#include <StringConstants.au3>
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

Func _ProcessEx_RunCommandDirect($sCommand, $sWorkingDir = "")
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

Func _Logging_SetLevel($sMessage, $sLevel = "")
    Return $sLevel & ": " & $sMessage
EndFunc

Func _FileEx_PathSplit($sPath, $iPart)
    Return "FAKE_DIR"
EndFunc

"""

META_TAIL = """
_RunSignCommand("C:\out\Test.exe", "C:\cert\test.pfx", "Desc", _
    "https://example.invalid", "PASSWORD_HERE", "http://timestamp.example")
; Give the fake signtool time to record its arguments before exiting.
For $iWait = 1 To 100
    If FileExists("ARGV_PATH") Then ExitLoop
    Sleep(100)
Next
Sleep(500)
FileWrite("RESULT_PATH", $g_sLog)
"""

# The fake signtool is a native program (compiled with the repo toolchain's
# mingw gcc), because the real signtool parses its command line with the
# native CRT rules; an AutoIt-compiled fake would parse it with AutoIt's
# own rules and could not prove the escaping right or wrong.
FAKE_SIGNTOOL_C = r"""
#include <stdio.h>
int main(int argc, char **argv) {
    FILE *f = fopen("ARGV_PATH", "wb");
    if (!f) return 1;
    fprintf(f, "%d\r\n", argc - 1);
    for (int i = 1; i < argc; i++) fprintf(f, "%s\r\n", argv[i]);
    fclose(f);
    return 0;
}
"""


def extract(source: str, name: str) -> str:
    start = source.index(f"Func {name}(")
    end = source.index("EndFunc", start) + len("EndFunc")
    return source[start:end]


def read(path) -> str:
    return pathlib.Path(path).read_bytes().decode("cp1252")


def run_au3(script: pathlib.Path) -> None:
    subprocess.run([AUTOIT, str(script)], check=True, timeout=300)


def au3_string(value: str) -> str:
    return '"' + value.replace('"', '" & Chr(34) & "') + '"'


def run_harness(distro_path, workdir: pathlib.Path, tag: str) -> str:
    result_path = workdir / f"{tag}.txt"
    harness = (HARNESS_HEAD + extract(read(PROCESS_EX), "_ProcessEx_QuoteArgument") + "\n\n" +
               extract(read(distro_path), "_RunSignCommand") + "\n" +
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
    fake_dir = workdir / "fake bin"
    fake_dir.mkdir()
    src = workdir / "fake_signtool.c"
    argv_path = str(workdir / "argv.txt").replace("\\", "\\\\")
    src.write_bytes(FAKE_SIGNTOOL_C.replace("ARGV_PATH", argv_path).encode("utf-8"))
    out = fake_dir / "signtool.exe"
    gcc = REPO / "reskit" / "llvm-mingw" / "bin" / "x86_64-w64-mingw32-gcc.exe"
    subprocess.run([str(gcc), str(src), "-o", str(out)], check=True, timeout=300, capture_output=True)
    assert out.exists(), "fake signtool was not compiled"
    return out


def runner_funcs(distro_source: str) -> str:
    process_ex = read(PROCESS_EX)
    func = extract(distro_source, "_RunSignCommand")
    names = ["__HasOutput", "__FormatRunOutput"]
    if "_ProcessEx_RunCommandDirect" in func:
        names += ["_ProcessEx_RunCommandDirect", "_ProcessEx_QuoteArgument"]
    else:
        names += ["_ProcessEx_RunCommand"]
    return "\n\n".join(extract(process_ex, n) for n in names)


def run_meta(distro_path, signtool: pathlib.Path, password: str, workdir: pathlib.Path, tag: str):
    result_path = workdir / f"meta_{tag}.txt"
    argv = workdir / "argv.txt"
    head = META_HEAD.replace("FAKE_SIGNTOOL", str(signtool)).replace("FAKE_DIR", str(signtool.parent) + "\\")
    tail = (META_TAIL.replace("RESULT_PATH", str(result_path))
            .replace("ARGV_PATH", str(argv))
            .replace(au3_string("PASSWORD_HERE"), au3_string(password))
            .replace('"PASSWORD_HERE"', au3_string(password)))
    harness = head + extract(read(distro_path), "_RunSignCommand") + "\n\n" + runner_funcs(read(distro_path)) + "\n" + tail
    harness_path = workdir / f"meta_{tag}.au3"
    harness_path.write_bytes(harness.encode("cp1252"))
    if argv.exists():
        argv.unlink()
    run_au3(harness_path)
    log = result_path.read_bytes().decode("cp1252") if result_path.exists() else ""
    argv_text = argv.read_bytes().decode("cp1252") if argv.exists() else ""
    args = argv_text.splitlines()[1:] if argv_text else []
    return log, args


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
        if cand_cmd != EXPECTED_EXECUTED or cand_wd != "C:\signdir":
            failures.append(f"candidate executed command/working directory not as expected: {cand_runs}")
        if args.base:
            base_log, base_count, base_runs = parse(run_harness(args.base, tmp, "base"))
            print(f"base log contains dummy password: {DUMMY in base_log} (expected True before the fix)")
            if base_count != 1:
                failures.append(f"base runner invocations: {base_count}, expected 1")
            if not base_runs or not cand_runs or base_runs[0].split("|", 1)[1] != cand_runs[0].split("|", 1)[1]:
                failures.append("working directory differs from the pre-change function")

        fake = build_fake_signtool(tmp)
        for i, password in enumerate(PASSWORDS):
            log, p_args = run_meta(args.candidate, fake, password, tmp, f"cand{i}")
            if password in log or "SECRETTAIL" in log:
                failures.append(f"password case {i} leaked into the log through the process layer")
            if "/p" not in p_args or p_args[p_args.index("/p") + 1] != password:
                failures.append(f"password case {i} did not arrive as exactly one argument: {p_args}")
        if args.base:
            base_meta_log, _ = run_meta(args.base, fake, PASSWORDS[0], tmp, "base0")
            leaked = "SECRETTAIL" in base_meta_log
            print(f"base metachar leak through shell layer: {leaked} (expected True before the fix)")
            if not leaked:
                failures.append("base function did not leak as expected; the metachar proof cannot discriminate")

        missing = tmp / "no such dir" / "signtool.exe"
        log, _ = run_meta(args.candidate, missing, PASSWORDS[0], tmp, "missing")
        if "Could not start the command (launch error" not in log:
            failures.append(f"missing executable did not produce the launch-error line: {log!r}")
        if PASSWORDS[0] in log or "SECRETTAIL" in log:
            failures.append("missing-executable case leaked the password into the log")

    print("masked Command: line:", EXPECTED_MASKED)
    if failures:
        for f in failures:
            print("FAIL:", f)
        return 1
    print("PASS: log masked, dummy absent, one shell-free invocation, executed command as expected, all password shapes safe through the process layer, launch failure logged without the command")
    return 0


if __name__ == "__main__":
    sys.exit(main())
