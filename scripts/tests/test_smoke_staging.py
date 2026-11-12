"""The elevated smoke never launches an executable its run manifest does not vouch for (D07 T01 section 7).

`stage_tool()` has its own cases in `scripts/smoke-run.py --self-test`. This goes through the path that consumes it:
`main()` in task mode, with a manifest that names another hash. The run must launch nothing, give the tool its five
`refused` rows, and end without a `pass`. It lives here and not in the driver's self-test because the driver is
pinned by hash for the consented task, and a test added to it would cost the operator a new consent prompt."""

from __future__ import annotations

import contextlib
import importlib.util
import io
import os
import tempfile
import unittest
from pathlib import Path
from unittest import mock

SCRIPTS = Path(__file__).resolve().parents[1]
DRIVER = SCRIPTS / "smoke-run.py"


def load_driver():
    spec = importlib.util.spec_from_file_location("smoke_run_under_test", DRIVER)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class RefusedToolIsNeverLaunched(unittest.TestCase):
    def run_task(self, recorded_hash_of):
        """main() as the elevated task runs it, with drive_tool counting launches. Returns (exit code, report, launches)."""
        smoke = load_driver()
        with tempfile.TemporaryDirectory() as td:
            base = Path(td)
            exe = base / "Bin" / "Tool.exe"
            exe.parent.mkdir()
            exe.write_bytes(b"MZ the bytes that were built")
            manifest = base / "manifest.txt"
            manifest.write_text(f"{recorded_hash_of(smoke, exe)}  Resolute\n", encoding="utf-8")
            launches = []

            def drive(run, *args, **kwargs):
                launches.append(run.exe)
                for step, _expected in smoke.step_table(run.name):
                    run.record(step, "pass", "stub")
                return False

            patches = {
                "SMOKE_DIR": base / "smoke", "PREV_DIR": base / "smoke" / "prev", "STAGE_DIR": base / "stage",
                "admission": lambda visible, now, elevated: (True, "visible (test)", False),
                "last_input_tick": lambda: 100,
                "tool_paths": lambda only=None, flavor="Release": [("Resolute", exe)],
                "drive_tool": drive,
            }
            env = {"RESOLUTE_SMOKE_ROOT": str(base), "RESOLUTE_SMOKE_MANIFEST": str(manifest)}
            with mock.patch.multiple(smoke, **patches), mock.patch.dict(os.environ, env), \
                    contextlib.redirect_stdout(io.StringIO()):
                code = smoke.main(["--visible"])
            report = (base / "smoke" / "smoke-report.md").read_text(encoding="utf-8")
            staged = [str(path) for path in launches if str(path).startswith(str(base / "stage"))]
            return code, report, launches, staged

    def test_a_changed_executable_gets_five_refused_rows_and_no_launch(self):
        code, report, launches, _staged = self.run_task(lambda smoke, exe: "0" * 64)
        self.assertEqual(launches, [], "a tool the manifest does not vouch for was launched")
        self.assertEqual(report.count("| Resolute |"), 5)
        self.assertEqual(report.count("| refused | refused: Tool.exe changed after the run manifest recorded it |"),
                         sum(1 for _step, expected in load_driver().step_table("Resolute")))
        self.assertNotIn("Suite verdict: **pass**", report)
        self.assertEqual(code, 2)

    def test_a_recorded_executable_is_launched_from_the_staged_copy(self):
        code, report, launches, staged = self.run_task(lambda smoke, exe: smoke.file_sha256(exe))
        self.assertEqual(len(launches), 1)
        self.assertEqual(len(staged), 1, "the launch was not from the staging directory")
        self.assertIn("Suite verdict: **pass**", report)
        self.assertEqual(code, 0)


if __name__ == "__main__":
    unittest.main()
