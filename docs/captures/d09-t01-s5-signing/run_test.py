"""Regression test for D09 T01 S5: Distro must not log the signing password.

Extracts _RunSignCommand verbatim from a Distro.au3 source, runs it in a
harness with logging captured and _ProcessEx_RunCommand stubbed to record
what it receives, and checks:

- the captured log contains the complete masked Command: line,
- the captured log does not contain the dummy password,
- exactly one runner invocation happened,
- the executed command and working directory are byte-for-byte identical
  between the candidate source and the pre-change source (given with
  --base), under identical dummy inputs.

Run before the fix (candidate = pre-change source) the mask checks fail;
after the fix they pass. Usage:

    python run_test.py --candidate <Distro.au3> [--base <Distro.au3>]

The pre-change source can be produced with:
    git show <base-commit>:resolute_au3/SDK/Concrete/Distro/Distro.au3
"""

import argparse
import pathlib
import subprocess
import sys
import tempfile

AUTOIT = r"C:\Program Files (x86)\AutoIt3\AutoIt3.exe"
DUMMY = "DUMMY6"  # six characters, so the expected mask is ******
EXPECTED_MASKED = (
    'Command: signtool.exe sign /f "C:\\cert\\test.pfx" /p ****** '
    '/t http://timestamp.example "C:\\out\\Test.exe"'
)

HARNESS_HEAD = """
Global $g_cSignTool = "C:\\signdir\\signtool.exe"
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
    Return "C:\\signdir\\"
EndFunc

"""

HARNESS_TAIL = """
_RunSignCommand("C:\\out\\Test.exe", "C:\\cert\\test.pfx", "Desc", _
    "https://example.invalid", "DUMMY6", "http://timestamp.example")
FileWrite("RESULT_PATH", "LOG<BEGIN>" & @CRLF & $g_sLog & "LOG<END>" & @CRLF & _
    "RUNS=" & $g_iRunCount & @CRLF & $g_sRuns)
"""


def extract_function(source: str) -> str:
    start = source.index("Func _RunSignCommand(")
    end = source.index("EndFunc", start) + len("EndFunc")
    return source[start:end]


def run_harness(distro_path: pathlib.Path, workdir: pathlib.Path, tag: str = "result") -> str:
    source = distro_path.read_bytes().decode("cp1252")
    result_path = workdir / f"{tag}.txt"
    harness = (HARNESS_HEAD + extract_function(source) + "\n" +
               HARNESS_TAIL.replace("RESULT_PATH", str(result_path).replace("\\", "\\\\")))
    harness_path = workdir / f"harness_{tag}.au3"
    harness_path.write_bytes(harness.encode("cp1252"))
    subprocess.run([AUTOIT, str(harness_path)], check=True, timeout=120)
    return result_path.read_bytes().decode("cp1252")


def parse(result: str):
    log = result.split("LOG<BEGIN>\r\n", 1)[1].split("LOG<END>", 1)[0]
    runs_line = [ln for ln in result.splitlines() if ln.startswith("RUNS=")][0]
    count = int(runs_line.split("=", 1)[1])
    runs = [ln for ln in result.splitlines() if "|" in ln and not ln.startswith("RUNS=")]
    return log, count, runs


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--candidate", required=True)
    ap.add_argument("--base")
    args = ap.parse_args()

    failures = []
    with tempfile.TemporaryDirectory(dir=r"R:\scratch") as tmp:
        tmp = pathlib.Path(tmp)
        cand_log, cand_count, cand_runs = parse(run_harness(pathlib.Path(args.candidate), tmp, "candidate"))
        if DUMMY in cand_log:
            failures.append("candidate log contains the dummy password")
        if EXPECTED_MASKED not in cand_log:
            failures.append("candidate log lacks the complete masked Command: line")
        if "Password: ******" not in cand_log:
            failures.append("candidate log lacks the Password: mask line")
        if cand_count != 1:
            failures.append(f"candidate runner invocations: {cand_count}, expected 1")
        if args.base:
            base_log, base_count, base_runs = parse(run_harness(pathlib.Path(args.base), tmp, "base"))
            if base_count != 1:
                failures.append(f"base runner invocations: {base_count}, expected 1")
            if cand_runs != base_runs:
                failures.append("executed command/working directory differ from the pre-change function")
            print(f"base log contains dummy password: {DUMMY in base_log} (expected True before the fix)")

    print("masked Command: line:", EXPECTED_MASKED)
    if failures:
        for f in failures:
            print("FAIL:", f)
        return 1
    print("PASS: log masked, dummy absent, one invocation, executed command unchanged")
    return 0


if __name__ == "__main__":
    sys.exit(main())
