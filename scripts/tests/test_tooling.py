"""Proofs for the tooling an unattended run leans on: the moved-clone cleanup in build.ps1, the parallel tidy
ratchet, and a language server that ends with the session that started it."""

from __future__ import annotations

import importlib.util
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
import unittest
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS / "lib"))

import run_guard as guard  # noqa: E402


def load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


@unittest.skipUnless(sys.platform == "win32" and shutil.which("pwsh"), "build.ps1 is PowerShell on Windows")
class MovedClone(unittest.TestCase):
    """A clone that moved cannot configure until its build trees go: build.ps1 removes those, and only those."""

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve() / "clone"
        (self.root / "scripts").mkdir(parents=True)
        shutil.copy(SCRIPTS / "build.ps1", self.root / "scripts" / "build.ps1")

    def tree(self, relative: str, made_for: str) -> Path:
        folder = self.root / relative
        folder.mkdir(parents=True)
        (folder / "CMakeCache.txt").write_text(f"X:STRING=1\nCMAKE_HOME_DIRECTORY:INTERNAL={made_for}\n", encoding="utf-8")
        (folder / "build.ninja").write_text("rule x\n", encoding="utf-8")
        return folder

    def keep(self, relative: str) -> Path:
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("kept", encoding="utf-8")
        return path

    def reset(self) -> str:
        done = subprocess.run(["pwsh", "-NoProfile", "-File", str(self.root / "scripts" / "build.ps1"), "-ResetMovedTrees"],
                              capture_output=True, text=True, timeout=120)
        self.assertEqual(done.returncode, 0, done.stdout + done.stderr)
        return done.stdout

    def test_trees_made_at_another_path_go_with_the_fetched_dependencies_and_nothing_else_does(self):
        (self.root / "extensions" / "Tool").mkdir(parents=True)
        (self.root / "extensions" / "Tool" / "CMakeLists.txt").write_text("project(Tool)\n", encoding="utf-8")
        stale = [self.tree("build/debug", "D:/GitHub/Elsewhere"), self.tree("build/release", "D:/GitHub/Elsewhere"),
                 self.tree("extensions/Tool/build/Release", "D:/GitHub/Elsewhere/extensions/Tool")]
        deps = self.keep("build/deps/debug/catch2-src/catch.hpp")
        kept = [self.keep("build/sccache/0/a/entry"), self.keep("build/logs/build-record.json"), self.keep("src/main.cpp"),
                self.keep("extensions/Tool/src/main.cpp"), self.keep("todo/README.md"), self.keep("Bin/Release/Resolute.exe")]
        said = self.reset()
        for folder in stale:
            self.assertFalse(folder.exists(), folder)
            self.assertIn(str(folder), said)
        self.assertFalse(deps.exists())
        for path in kept:
            self.assertTrue(path.is_file(), path)

    def test_trees_made_here_are_left_alone_whatever_the_case_or_slashes(self):
        here = str(self.root).replace("\\", "/")
        ours = [self.tree("build/debug", here.upper()), self.tree("build/release", here + "/")]
        deps = self.keep("build/deps/debug/catch2-src/catch.hpp")
        self.assertEqual(self.reset().strip(), "")
        for folder in ours:
            self.assertTrue((folder / "build.ninja").is_file(), folder)
        self.assertTrue(deps.is_file())

    def test_a_tree_with_no_cache_is_not_guessed_at(self):
        (self.root / "build" / "debug").mkdir(parents=True)
        note = self.keep("build/debug/notes.txt")
        self.reset()
        self.assertTrue(note.is_file())


class ParallelRatchet(unittest.TestCase):
    """Analysing several units at once must give what one at a time gave: the findings, the log and the refusal."""

    FAKE = (
        "import sys, time\n"
        "tu = sys.argv[-1].replace('\\\\', '/')\n"
        "index = int(tu.rsplit('unit', 1)[1].split('.')[0])\n"
        "time.sleep(0.05 * (9 - index))  # the last unit finishes first\n"
        "print(f'{tu}:{index + 1}:2: warning: something [bugprone-fake]')\n"
        "if 'bad' in tu:\n"
        "    print(f'{tu}: stopped'); sys.exit(3)\n"
    )

    def setUp(self):
        self.ratchet = load("tidy_ratchet_under_test", SCRIPTS / "tidy-ratchet.py")
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        (self.root / "fake.py").write_text(self.FAKE, encoding="utf-8")
        if os.name == "nt":
            self.tidy = self.root / "fake-tidy.cmd"
            self.tidy.write_text(f'@"{sys.executable}" "{self.root / "fake.py"}" %*\r\n', encoding="utf-8")
        else:
            self.tidy = self.root / "fake-tidy"
            self.tidy.write_text(f'#!/bin/sh\nexec "{sys.executable}" "{self.root / "fake.py"}" "$@"\n', encoding="utf-8")
            self.tidy.chmod(0o755)
        self.addCleanup(os.environ.pop, "RESOLUTE_TIDY_JOBS", None)

    def database(self, names: list[str]) -> dict:
        build = self.root / "build" / "release"
        build.mkdir(parents=True, exist_ok=True)
        (self.root / "src").mkdir(exist_ok=True)
        entries = []
        for name in names:
            (self.root / "src" / name).write_text("int x;\n", encoding="utf-8")
            entries.append({"directory": str(build), "file": str(self.root / "src" / name), "command": "clang++ -c"})
        (build / "compile_commands.json").write_text(json.dumps(entries), encoding="utf-8")
        return {"root": build / "compile_commands.json"}

    def analyse(self, targets: dict, jobs: int):
        os.environ["RESOLUTE_TIDY_JOBS"] = str(jobs)
        log = self.root / f"log-{jobs}.txt"
        try:
            result = self.ratchet.run_analysis(self.root, self.tidy, targets, log)
            return result[0], result[1], result[2], log.read_text(encoding="utf-8"), None
        except self.ratchet.Refusal as refusal:
            return None, None, None, log.read_text(encoding="utf-8"), str(refusal)

    def test_four_at_a_time_gives_the_findings_and_the_log_of_one_at_a_time(self):
        targets = self.database([f"unit{i}.cpp" for i in range(8)])
        serial, together = self.analyse(targets, 1), self.analyse(targets, 4)
        self.assertIsNone(serial[4])
        self.assertEqual(len(serial[1]), 8)
        self.assertEqual(serial[2], 8)
        self.assertEqual(serial, together)
        order = [line.split(":")[-4] for line in together[3].splitlines()]  # the line number each unit printed
        self.assertEqual(order, [str(i + 1) for i in range(8)])

    def test_the_refusal_names_the_first_failing_unit_in_database_order_and_the_log_stops_there(self):
        names = ["unit0.cpp", "unit1.cpp", "bad-unit2.cpp", "unit3.cpp", "bad-unit4.cpp", "unit5.cpp"]
        targets = self.database(names)
        serial, together = self.analyse(targets, 1), self.analyse(targets, 4)
        self.assertIn("bad-unit2.cpp", serial[4])
        self.assertNotIn("bad-unit4.cpp", serial[4])
        self.assertEqual(serial[4].replace("log-1.txt", "log"), together[4].replace("log-4.txt", "log"))
        self.assertEqual(serial[3], together[3])
        self.assertTrue(together[3].rstrip().endswith("stopped"))
        self.assertNotIn("unit3.cpp", together[3])

    def test_the_number_at_once_is_bounded_and_can_be_set_for_a_runner(self):
        os.environ.pop("RESOLUTE_TIDY_JOBS", None)
        self.assertTrue(1 <= self.ratchet.tidy_jobs() <= 4)
        for value, expected in (("7", 7), ("1", 1)):
            os.environ["RESOLUTE_TIDY_JOBS"] = value
            self.assertEqual(self.ratchet.tidy_jobs(), expected)
        for value in ("0", "many", ""):
            os.environ["RESOLUTE_TIDY_JOBS"] = value
            self.assertTrue(1 <= self.ratchet.tidy_jobs() <= 4, value)


@unittest.skipUnless(sys.platform == "win32" and shutil.which("pyright-langserver"), "needs Windows and pyright-langserver on PATH")
class LanguageServerLifetime(unittest.TestCase):
    """A language server never outlives the session that started it, even when that session is killed."""

    def children(self, pid: int) -> list[int]:
        out = subprocess.run(["pwsh", "-NoProfile", "-Command", f"(Get-CimInstance Win32_Process -Filter 'ParentProcessId={pid}').ProcessId"],
                             capture_output=True, text=True, timeout=60).stdout
        return [int(line) for line in out.split() if line.strip().isdigit()]

    def test_killing_the_session_ends_the_launcher_and_the_server_it_started(self):
        # A stand-in for Claude Code: it starts the launcher the way the plugin does, says who that is, and waits.
        code = (
            "import subprocess, sys, time\n"
            f"p = subprocess.Popen([sys.executable, {str(SCRIPTS / 'lsp-launch.py')!r}, 'pyright'], stdin=subprocess.PIPE, stdout=subprocess.DEVNULL)\n"
            "print(p.pid, flush=True); time.sleep(120)\n"
        )
        session = subprocess.Popen([sys.executable, "-c", code], stdout=subprocess.PIPE)
        launcher, servers = None, []
        try:
            launcher = int(session.stdout.readline())
            deadline = time.monotonic() + 30
            while not servers and time.monotonic() < deadline:
                time.sleep(0.5)
                servers = self.children(launcher)
            self.assertTrue(servers, "the launcher started no server")
        finally:
            session.kill()
            session.wait()
            session.stdout.close()
        deadline = time.monotonic() + 20
        left = [launcher, *servers]
        while left and time.monotonic() < deadline:
            time.sleep(0.25)
            left = [pid for pid in left if guard.process_started(pid) is not None]
        self.assertEqual(left, [], "these outlived the session")

    def test_a_server_that_cannot_start_says_why_and_exits_1(self):
        done = subprocess.run([sys.executable, str(SCRIPTS / "lsp-launch.py"), "pyright"], capture_output=True, text=True,
                              env={**os.environ, "PATH": os.path.dirname(sys.executable)}, timeout=60)
        self.assertEqual(done.returncode, 1)
        self.assertIn("pyright-langserver is not on PATH", done.stderr)


class LauncherWriterModel(unittest.TestCase):
    """The Claude campaign starts on the latest Opus at medium effort (operator decision 2026-11-12), and says so."""

    def setUp(self):
        self.text = (SCRIPTS / "start-unattended-run.ps1").read_text(encoding="utf-8")

    def test_the_pin_is_opus_at_medium(self):
        self.assertIn("$model = 'claude-opus-5-5'", self.text)
        self.assertIn("$effort = 'medium'", self.text)

    def test_the_session_is_started_with_both(self):
        line = next(l for l in self.text.splitlines() if "'--session-id', $session" in l)
        self.assertIn("'--model', $model, '--effort', $effort, $goal)", line)

    def test_the_session_is_named_for_the_window_title(self):
        line = next(l for l in self.text.splitlines() if "'--session-id', $session" in l)
        self.assertIn("'--name', $windowTitle", line)


if __name__ == "__main__":
    unittest.main()
