"""The README's quick start, run as written (D00 T05 section 3).

    python scripts/quickstart.py run --work <empty folder> [--expect-commit <sha>] [--timeout <seconds>]
    python scripts/quickstart.py facts
    python scripts/quickstart.py --self-test

`run` takes the first fenced `powershell` block under "## Quick start" in README.md and runs its lines, word for
word and in order, in one PowerShell 7 session started in the empty folder. No command is typed anywhere else, so
the README and what CI proves cannot drift apart: a README whose heading or block is gone fails here by name, and
a command that no longer works fails at that command. Once the session stands in a clone it compares the clone's
commit with --expect-commit and refuses, before the next command, when they differ. When the last command has
passed it reads CMakePresets.json in the clone and fails naming any configure preset the quick start left unbuilt.

The session runs inside a job object this script owns (scripts/lib/win_job.py): everything it starts is ended
before `run` returns, whether the session finished, failed or timed out.

`facts` works out two things from the tree and fails by name when either stops being true: that no `.env` file
applies to this repository, and what the first run takes from outside the clone.

Windows only, stdlib only. The lane is .github/workflows/quick-start.yml.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))

HEADING = "## Quick start"
DEFAULT_TIMEOUT = 3 * 60 * 60.0
EXIT_COMMAND = 90     # a quick start command failed
EXIT_COMMIT = 91      # the clone is not the expected commit
EXIT_TIMEOUT = 124
NO_WINDOW = 0x08000000  # CREATE_NO_WINDOW


class Refused(Exception):
    """The quick start could not be run, or a fact is no longer true. The message says which and why."""


# ----- the block ---------------------------------------------------------------------------------------------------

def block(readme: str) -> list[str]:
    """The quick start's command lines, exactly as the README has them."""
    lines = readme.splitlines()
    try:
        start = next(i for i, line in enumerate(lines) if line.strip() == HEADING)
    except StopIteration:
        raise Refused(f"README.md has no '{HEADING}' heading") from None
    end = next((i for i in range(start + 1, len(lines)) if lines[i].startswith("## ")), len(lines))
    section = lines[start + 1:end]
    try:
        opened = next(i for i, line in enumerate(section) if line.strip() == "```powershell")
    except StopIteration:
        raise Refused(f"README.md's '{HEADING}' section has no ```powershell block") from None
    try:
        closed = next(i for i in range(opened + 1, len(section)) if section[i].strip() == "```")
    except StopIteration:
        raise Refused(f"README.md's '{HEADING}' block is never closed") from None
    commands = [line for line in section[opened + 1:closed] if line.strip()]
    if not commands:
        raise Refused(f"README.md's '{HEADING}' block holds no command")
    return commands


def _quoted(text: str) -> str:
    return "'" + text.replace("'", "''") + "'"


def session_script(commands: list[str], expect: str, state: Path, after_clone: str = "") -> str:
    """The PowerShell the session runs: each command as written, a stop at the first that fails, and one check of
    the clone's commit the first time the session stands in a work tree."""
    out = ["$ErrorActionPreference = 'Continue'", "$quickstartConfirmed = $false", f"$quickstartExpect = {_quoted(expect)}",
           f"$quickstartState = {_quoted(str(state))}"]
    for number, command in enumerate(commands, start=1):
        out += [
            f"Set-Content -LiteralPath $quickstartState -Value @('command', '{number}')",
            f"Write-Host {_quoted('quickstart> ' + command)}",
            "$global:LASTEXITCODE = 0",
            command,
            f"if (-not $? -or $LASTEXITCODE -ne 0) {{ Write-Host \"quickstart: the command above failed (exit $LASTEXITCODE)\"; exit {EXIT_COMMAND} }}",
            "if (-not $quickstartConfirmed -and (Test-Path -LiteralPath '.git')) {",
            "    $quickstartGot = (git rev-parse HEAD | Out-String).Trim()",
            "    Set-Content -LiteralPath ($quickstartState + '.clone') -Value @($quickstartGot, (Get-Location).Path)",
            f"    if ($quickstartExpect -and $quickstartGot -ne $quickstartExpect) {{ exit {EXIT_COMMIT} }}",
            "    $quickstartConfirmed = $true",
            *([f"    {after_clone}", f"    if ($LASTEXITCODE -ne 0) {{ exit {EXIT_COMMAND} }}"] if after_clone else []),
            "}",
        ]
    out += ["Set-Content -LiteralPath $quickstartState -Value @('done', (Get-Location).Path)", "exit 0"]
    return "\r\n".join(out) + "\r\n"


# ----- the lanes ---------------------------------------------------------------------------------------------------

def unbuilt_presets(clone: Path) -> list[str]:
    """Each configure preset of CMakePresets.json whose build tree holds no build."""
    presets = json.loads((clone / "CMakePresets.json").read_text(encoding="utf-8")).get("configurePresets", [])
    missing = []
    for preset in presets:
        if preset.get("hidden"):
            continue
        where = str(preset.get("binaryDir", "")).replace("${sourceDir}", str(clone)).replace("${presetName}", preset["name"])
        if not where or not (Path(where) / ".ninja_log").is_file():
            missing.append(f"{preset['name']} ({where or 'no binaryDir'})")
    return missing


# ----- the run -----------------------------------------------------------------------------------------------------

def run(readme: Path, work: Path, expect: str = "", timeout: float = DEFAULT_TIMEOUT, after_clone: str = "",
        check_lanes: bool = True, say=print) -> int:
    import win_job

    try:
        commands = block(readme.read_text(encoding="utf-8"))
    except OSError as error:
        raise Refused(f"{readme} could not be read ({error.strerror or error})") from None
    pwsh = shutil.which("pwsh")
    if not pwsh:
        raise Refused("PowerShell 7 (pwsh) is not on PATH, and the quick start needs it")
    if not work.is_dir() or any(work.iterdir()):
        raise Refused(f"{work} must be an existing empty folder: the quick start starts from one")
    control = Path(tempfile.mkdtemp(prefix="quickstart-"))
    state = control / "state"
    script = control / "session.ps1"
    script.write_text(session_script(commands, expect, state, after_clone), encoding="utf-8-sig")
    job = win_job.OwnedJob()   # refuses before anything is started
    child = None
    code = EXIT_TIMEOUT
    stuck = False
    try:
        child = subprocess.Popen([pwsh, "-NoLogo", "-NoProfile", "-NonInteractive", "-File", str(script)], cwd=work, creationflags=NO_WINDOW)
        job.take(child)
        try:
            code = child.wait(timeout)
        except subprocess.TimeoutExpired:
            code = EXIT_TIMEOUT
    finally:
        left = job.end()   # the session and everything it started, on every way out of here
        if child is not None:
            try:
                child.wait(10)
            except subprocess.TimeoutExpired:
                stuck = True   # reported below as a refusal: Windows did not end a process this run owns
    at = state.read_text(encoding="utf-8-sig").split() if state.is_file() else []
    clone_note = Path(str(state) + ".clone")
    clone = clone_note.read_text(encoding="utf-8-sig").splitlines() if clone_note.is_file() else []
    shutil.rmtree(control, ignore_errors=True)
    if stuck:
        say(f"quickstart: refused: the session's process {child.pid if child else '?'} was still running 10 seconds after its job was ended")
        return EXIT_TIMEOUT
    if code == 0 and left:
        say(f"quickstart: ended {left} process(es) the quick start left running")
    if code == EXIT_TIMEOUT:
        say(f"quickstart: refused: the quick start did not finish in {timeout:g} seconds; its {left} process(es) were ended")
        return EXIT_TIMEOUT
    if code == EXIT_COMMIT:
        say(f"quickstart: refused: the clone is at {clone[0] if clone else 'an unknown commit'} and the expected commit is {expect}; nothing further was run")
        return EXIT_COMMIT
    if code != 0:
        number = int(at[1]) if len(at) > 1 and at[0] == "command" and at[1].isdigit() else 0
        which = f"command {number} of {len(commands)}: {commands[number - 1].strip()}" if 0 < number <= len(commands) else "the session"
        say(f"quickstart: refused: {which} failed; the commands after it were not run")
        return EXIT_COMMAND
    if expect and not clone:
        say(f"quickstart: refused: the quick start never stood in a clone, so the commit {expect} was not proven")
        return EXIT_COMMIT
    if check_lanes and clone:
        missing = unbuilt_presets(Path(clone[1]))
        if missing:
            say("quickstart: refused: the quick start left a CMakePresets.json preset unbuilt: " + ", ".join(missing))
            return EXIT_COMMAND
    say(f"quickstart: {len(commands)} command(s) ran as the README has them" + (f", on commit {clone[0]}" if clone else ""))
    return 0


def break_pin(pins: Path) -> int:
    """The wrong-pin proof: change the first component's hash in a clone's toolchain.json. Never run on a tree that is kept."""
    data = json.loads(pins.read_text(encoding="utf-8"))
    first = data["components"][0]
    first["sha256"] = ("0" if first["sha256"][0] != "0" else "1") + first["sha256"][1:]
    pins.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print(f"quickstart: proof: the pinned hash of {first['name']} was changed in {pins}")
    return 0


# ----- the facts ---------------------------------------------------------------------------------------------------

# What the quick start can run: the tracked scripts and build files, outside the frozen AutoIt suite, the samples
# and the documents.
RUNNABLE = re.compile(r"(\.(ps1|py|cmake)$|(^|/)CMakeLists\.txt$|(^|/)CMakePresets\.json$)")
NOT_RUNNABLE = ("resolute_au3/", "samples/", "docs/")
DOTENV_FILE = re.compile(r"(^|/)\.env(\.[^/]+)?$")
DOTENV_USE = re.compile(r"""(['"/\\ ]\.env(\.\w+)?['"\s)]|dotenv)""", re.IGNORECASE)
FETCH = re.compile(r"Invoke-WebRequest|Invoke-RestMethod|WebClient|urlretrieve|urlopen|DownloadFile|Start-BitsTransfer|FetchContent_Declare|"
                   r"file\(DOWNLOAD|ExternalProject_Add|git clone|curl(\.exe)? |gh (api|run|repo)|\"gh\"")
# Every tracked file that reaches the network, and what it is to the first run. A new one fails `facts` until it is
# recorded here, which is the moment somebody decides whether a first run now depends on it.
FETCHERS = {
    "scripts/bootstrap.ps1": "first run: downloads each component toolchain.json pins, and checks its SHA-256",
    "tests/CMakeLists.txt": "first run: Catch2, pinned by commit",
    "shared/lucide/CMakeLists.txt": "first run: the Lucide icon set, pinned by commit",
    "scripts/toolchain-latest.ps1": "advisory: asks whether a pin has fallen behind; check-all never fails on it",
    "scripts/ci-status.py": "not the first run: reads this repository's CI results",
    "tools/refdata/server.ps1": "not the first run: reference-data authoring machines only",
    "scripts/quickstart.py": "not the first run: holds these patterns",
}
FULL_HASH = re.compile(r"GIT_TAG\s+([0-9a-f]{40})\b")


def facts(repo: Path, fetchers: dict[str, str] = FETCHERS) -> tuple[list[str], list[str]]:
    """(the facts, the problems). The facts are true only when the problems are empty."""
    listed = subprocess.run(["git", "-C", str(repo), "ls-files", "-z"], capture_output=True, timeout=60, check=False, creationflags=NO_WINDOW)
    if listed.returncode != 0:
        raise Refused(f"git could not list {repo}'s files: {listed.stderr.decode('utf-8', 'replace').strip()}")
    tracked = [name for name in listed.stdout.decode("utf-8").split("\0") if name]
    problems = [f"{name}: a tracked .env file" for name in tracked if DOTENV_FILE.search(name)]
    found: set[str] = set()
    for name in tracked:
        if not RUNNABLE.search(name) or name.startswith(NOT_RUNNABLE):
            continue
        try:
            text = (repo / name).read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue   # tracked and deleted in the working tree: nothing to run
        code = "\n".join(line for line in text.splitlines() if not line.lstrip().startswith("#"))   # a comment may talk about one
        if name != "scripts/quickstart.py" and DOTENV_USE.search(code):
            problems.append(f"{name}: names a .env file or a dotenv loader")
        if FETCH.search(text):
            found.add(name)
            if name not in fetchers:
                problems.append(f"{name}: fetches from the network and is not recorded in FETCHERS (scripts/quickstart.py)")
        if "FetchContent_Declare" in text and name.endswith(("CMakeLists.txt", ".cmake")):
            declared = text.count("FetchContent_Declare(")
            if len(FULL_HASH.findall(text)) < declared:
                problems.append(f"{name}: a FetchContent_Declare is not pinned by a full commit hash in GIT_TAG")
    problems += [f"{name}: recorded in FETCHERS and no longer fetches or no longer exists" for name in fetchers if name not in found]
    pins = repo / "toolchain.json"
    components = json.loads(pins.read_text(encoding="utf-8")).get("components", []) if pins.is_file() else []
    unhashed = [c.get("name", "?") for c in components if not re.fullmatch(r"[0-9a-fA-F]{64}", str(c.get("sha256", "")))]
    problems += [f"toolchain.json: {name} has no SHA-256 pin" for name in unhashed]
    first = [name for name, role in fetchers.items() if role.startswith("first run")]
    said = [
        ".env: does not apply. No .env file is tracked, and no script or build file names one or loads one; every setting is a script parameter.",
        f"first run: takes from outside the clone only the {len(components)} component(s) toolchain.json pins by SHA-256 "
        f"({', '.join(c.get('name', '?') for c in components)}) and the commit-pinned sources fetched by {', '.join(sorted(first))}. "
        "Nothing else seeds it: no data, account, service or earlier build.",
    ]
    return said, problems


def cmd_facts(repo: Path) -> int:
    said, problems = facts(repo)
    if problems:
        for problem in problems:
            print(f"quickstart: fact no longer true: {problem}")
        return 1
    for line in said:
        print(f"quickstart: fact: {line}")
    return 0


# ----- self-test ---------------------------------------------------------------------------------------------------

def _alive(pid: int) -> bool:
    import ctypes
    from ctypes import wintypes

    kernel = ctypes.WinDLL("kernel32", use_last_error=True)
    kernel.OpenProcess.restype = wintypes.HANDLE
    kernel.OpenProcess.argtypes = (wintypes.DWORD, wintypes.BOOL, wintypes.DWORD)
    kernel.WaitForSingleObject.argtypes = (wintypes.HANDLE, wintypes.DWORD)
    kernel.CloseHandle.argtypes = (wintypes.HANDLE,)
    handle = kernel.OpenProcess(0x00100000, False, pid)   # SYNCHRONIZE
    if not handle:
        return False
    try:
        return kernel.WaitForSingleObject(handle, 0) == 0x102   # WAIT_TIMEOUT: still running
    finally:
        kernel.CloseHandle(handle)


def _gone(pid: int, within: float = 10.0) -> bool:
    deadline = time.monotonic() + within
    while time.monotonic() < deadline:
        if not _alive(pid):
            return True
        time.sleep(0.2)
    return False


def self_test() -> int:
    failures: list[str] = []

    def check(name: str, ok: bool, detail: str = "") -> None:
        print(("PASS " if ok else "FAIL ") + name + ("" if ok else f": {detail}"))
        if not ok:
            failures.append(name)

    def refusal(action) -> str:
        try:
            action()
        except Refused as error:
            return str(error)
        return ""

    def readme(*commands: str) -> str:
        return "# Project\n\n## Quick start\n\nFrom an empty folder:\n\n```powershell\n" + "\n".join(commands) + "\n```\n\n## Next\n\n```powershell\nnever-run\n```\n"

    check("the block is the lines as written, comments included",
          block(readme("git clone x", "pwsh a.ps1   # why")) == ["git clone x", "pwsh a.ps1   # why"], repr(block(readme("git clone x", "pwsh a.ps1   # why"))))
    check("a README with no quick start heading is refused by name", "no '## Quick start' heading" in refusal(lambda: block("# Project\n\n## Start\n")))
    check("a quick start with no block is refused by name", "no ```powershell block" in refusal(lambda: block("## Quick start\n\nwords\n\n## Next\n\n```powershell\nx\n```\n")))
    check("an empty block is refused by name", "holds no command" in refusal(lambda: block("## Quick start\n\n```powershell\n\n```\n")))
    check("this repository's quick start reads", len(block((REPO / "README.md").read_text(encoding="utf-8"))) >= 3)

    git = ["git", "-c", "user.name=quickstart self-test", "-c", "user.email=self-test@example.invalid", "-c", "commit.gpgsign=false"]

    def sh(*args: str, cwd: Path) -> str:
        done = subprocess.run(list(args), cwd=cwd, capture_output=True, text=True, timeout=60, check=False, creationflags=NO_WINDOW)
        if done.returncode != 0:
            raise AssertionError(f"{args}: {done.stderr.strip()}")
        return done.stdout.strip()

    root = Path(tempfile.mkdtemp(prefix="quickstart-selftest-"))
    try:
        said: list[str] = []

        def attempt(name: str, commands: tuple[str, ...], **options) -> int:
            said.clear()
            work = root / name
            work.mkdir()
            (root / f"{name}.md").write_text(readme(*commands), encoding="utf-8")
            return run(root / f"{name}.md", work, say=said.append, **{"check_lanes": False, **options})

        # A child the session starts and does not wait for: `Start-Sleep 300` in its own process, its id written down.
        stray = "(Start-Process pwsh -NoNewWindow -PassThru -ArgumentList '-NoProfile','-Command','Start-Sleep 300').Id | Set-Content child.pid"

        def child_of(name: str) -> int:
            return int((root / name / "child.pid").read_text(encoding="utf-8-sig").strip())

        started = time.monotonic()
        code = attempt("finish", (stray, "Set-Content ran.txt done"))
        check("a quick start that finishes returns 0, each command run in one session", code == 0 and (root / "finish" / "ran.txt").is_file(), f"{code} {said}")
        check("a process it left running is ended when it finishes", _gone(child_of("finish")) and any("ended" in line for line in said), repr(said))
        code = attempt("fail", (stray, "cmd /c exit 3", "Set-Content ran.txt done"))
        check("a failed command stops the run naming the command, the next one not run",
              code == EXIT_COMMAND and not (root / "fail" / "ran.txt").exists() and any("command 2 of 3: cmd /c exit 3" in line for line in said), f"{code} {said}")
        check("a process it left running is ended when a command fails", _gone(child_of("fail")))
        code = attempt("slow", (stray, "Start-Sleep 300"), timeout=6.0)
        check("a quick start that does not finish is refused at its timeout", code == EXIT_TIMEOUT and any("did not finish" in line for line in said), f"{code} {said}")
        check("a process it left running is ended at the timeout", _gone(child_of("slow")))
        check("the three runs were bounded to seconds", time.monotonic() - started < 90, f"{time.monotonic() - started:.0f}s")
        check("a folder that is not empty is refused", "must be an existing empty folder" in refusal(lambda: run(root / "finish.md", root / "finish", say=said.append)))

        # Two commits that carry the same quick start: the clone has to be the expected one, not only read the same.
        source = root / "source"
        source.mkdir()
        sh(*git, "init", "-q", "-b", "main", cwd=source)
        (source / "README.md").write_text(readme("git clone x"), encoding="utf-8")
        sh(*git, "add", "-A", cwd=source)
        sh(*git, "commit", "-q", "-m", "one", cwd=source)
        first = sh("git", "rev-parse", "HEAD", cwd=source)
        (source / "other.txt").write_text("changed elsewhere\n", encoding="utf-8")
        sh(*git, "add", "-A", cwd=source)
        sh(*git, "commit", "-q", "-m", "two", cwd=source)
        second = sh("git", "rev-parse", "HEAD", cwd=source)
        steps = (f"git clone -q {_quoted(str(source))} clone", "cd clone", "Set-Content ran.txt done")
        code = attempt("newer", steps, expect=first)
        check("a clone that is not the expected commit is refused before the next command, naming both commits",
              code == EXIT_COMMIT and not (root / "newer" / "clone" / "ran.txt").exists() and any(first in line and second in line for line in said), f"{code} {said}")
        code = attempt("same", steps, expect=second)
        check("a clone that is the expected commit runs on", code == 0 and (root / "same" / "clone" / "ran.txt").is_file() and any(second in line for line in said), f"{code} {said}")
        code = attempt("noclone", ("Set-Content ran.txt done",), expect=second)
        check("an expected commit that was never cloned is refused", code == EXIT_COMMIT, f"{code} {said}")

        # The lanes.
        lanes = root / "lanes"
        (lanes / "build" / "debug").mkdir(parents=True)
        (lanes / "build" / "debug" / ".ninja_log").write_text("# ninja log v6\n", encoding="utf-8")
        (lanes / "CMakePresets.json").write_text(json.dumps({"configurePresets": [
            {"name": "debug", "binaryDir": "${sourceDir}/build/debug"}, {"name": "release", "binaryDir": "${sourceDir}/build/release"}]}), encoding="utf-8")
        missing = unbuilt_presets(lanes)
        check("a preset the quick start left unbuilt is named", len(missing) == 1 and missing[0].startswith("release ("), repr(missing))
        (lanes / "build" / "release").mkdir()
        (lanes / "build" / "release" / ".ninja_log").write_text("# ninja log v6\n", encoding="utf-8")
        check("every preset built is clean", unbuilt_presets(lanes) == [])

        # The wrong-pin proof changes a hash and nothing else.
        pins = root / "toolchain.json"
        pins.write_text(json.dumps({"components": [{"name": "one", "sha256": "ab" * 32}, {"name": "two", "sha256": "cd" * 32}]}), encoding="utf-8")
        break_pin(pins)
        after = json.loads(pins.read_text(encoding="utf-8"))["components"]
        check("the wrong-pin proof changes one hash", after[0]["sha256"] != "ab" * 32 and len(after[0]["sha256"]) == 64 and after[1]["sha256"] == "cd" * 32)

        # The facts, on a tree where each can be made false.
        tree = root / "tree"
        (tree / "scripts").mkdir(parents=True)
        (tree / "tests").mkdir()
        sh(*git, "init", "-q", "-b", "main", cwd=tree)
        (tree / "toolchain.json").write_text(json.dumps({"components": [{"name": "one", "sha256": "ab" * 32}]}), encoding="utf-8")
        (tree / "scripts" / "bootstrap.ps1").write_text("Invoke-WebRequest $url -OutFile $zip\n", encoding="utf-8")
        (tree / "tests" / "CMakeLists.txt").write_text("FetchContent_Declare(\n  Catch2\n  GIT_TAG " + "a1" * 20 + "\n)\n", encoding="utf-8")
        known = {"scripts/bootstrap.ps1": "first run: the pinned components", "tests/CMakeLists.txt": "first run: Catch2"}

        def problems() -> list[str]:
            sh(*git, "add", "-A", cwd=tree)
            return facts(tree, known)[1]

        check("the facts hold on a clean tree", problems() == [], repr(problems()))
        (tree / ".env").write_text("KEY=value\n", encoding="utf-8")
        check("a tracked .env file fails by name", problems() == [".env: a tracked .env file"], repr(problems()))
        (tree / ".env").unlink()
        (tree / "scripts" / "build.ps1").write_text("Get-Content (Join-Path $root '.env') | ForEach-Object { }\n", encoding="utf-8")
        check("a script that reads a .env file fails by name", problems() == ["scripts/build.ps1: names a .env file or a dotenv loader"], repr(problems()))
        (tree / "scripts" / "build.ps1").write_text("$env:PATH = \"$root;$env:PATH\"\n[System.Environment]::GetEnvironmentVariable('X')\n", encoding="utf-8")
        (tree / "scripts" / "build.ps1").write_text("# no .env file applies here\n$env:PATH = \"$root;$env:PATH\"\n[System.Environment]::GetEnvironmentVariable('X')\n", encoding="utf-8")
        check("reading an environment variable, or naming a .env file in a comment, is not a .env file", problems() == [], repr(problems()))
        (tree / "scripts" / "fetch.py").write_text("from urllib.request import urlopen\n", encoding="utf-8")
        check("a new file that fetches fails by name", len(problems()) == 1 and problems()[0].startswith("scripts/fetch.py: fetches from the network"), repr(problems()))
        (tree / "scripts" / "fetch.py").unlink()
        (tree / "tests" / "CMakeLists.txt").write_text("FetchContent_Declare(\n  Catch2\n  GIT_TAG v3.16.0\n)\n", encoding="utf-8")
        check("a FetchContent pinned to a tag fails by name", problems() == ["tests/CMakeLists.txt: a FetchContent_Declare is not pinned by a full commit hash in GIT_TAG"], repr(problems()))
        (tree / "tests" / "CMakeLists.txt").write_text("add_executable(t t.cpp)\n", encoding="utf-8")
        check("a recorded fetcher that no longer fetches fails by name", problems() == ["tests/CMakeLists.txt: recorded in FETCHERS and no longer fetches or no longer exists"], repr(problems()))
        said_here, wrong = facts(REPO)
        check("the facts hold on this repository", wrong == [] and len(said_here) == 2, repr(wrong))
    finally:
        shutil.rmtree(root, ignore_errors=True)
    if failures:
        print(f"self-test: {len(failures)} failed: " + "; ".join(failures))
        return 1
    print("self-test: all pass")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Run the README's quick start as written, and check the facts about a first run.")
    parser.add_argument("--self-test", action="store_true")
    commands = parser.add_subparsers(dest="command")
    runner = commands.add_parser("run", help="run README.md's quick start in an empty folder")
    runner.add_argument("--work", type=Path, required=True, help="an existing empty folder")
    runner.add_argument("--readme", type=Path, default=REPO / "README.md")
    runner.add_argument("--expect-commit", default="", help="refuse unless the clone is at this commit")
    runner.add_argument("--timeout", type=float, default=DEFAULT_TIMEOUT)
    runner.add_argument("--prove-wrong-pin", action="store_true", help="proof run only: change one pinned hash in the clone before bootstrap")
    commands.add_parser("facts", help="check and print the .env and first-run facts")
    breaker = commands.add_parser("break-pin", help="proof run only: change the first pinned hash in a clone's toolchain.json")
    breaker.add_argument("pins", type=Path)
    args = parser.parse_args()
    if os.name != "nt":
        print("quickstart: refused: Windows only, as the quick start is")
        return 2
    try:
        if args.self_test:
            return self_test()
        if args.command == "run":
            after = f"& {_quoted(sys.executable)} {_quoted(str(Path(__file__).resolve()))} break-pin toolchain.json" if args.prove_wrong_pin else ""
            return run(args.readme, args.work, args.expect_commit, args.timeout, after)
        if args.command == "facts":
            return cmd_facts(REPO)
        if args.command == "break-pin":
            return break_pin(args.pins)
    except (Refused, OSError) as error:
        print(f"quickstart: refused: {error}")
        return 1
    parser.print_help()
    return 2


if __name__ == "__main__":
    sys.exit(main())
