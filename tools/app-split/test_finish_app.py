"""A frozen tool's freeze checks name things its own plan has. Run: python -m unittest tools/app-split/test_finish_app.py"""
import importlib.util
import json
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
loaded = importlib.util.spec_from_file_location("finish_app", HERE / "finish-app.py")
assert loaded and loaded.loader, "finish-app.py is beside this test"
finish_app = importlib.util.module_from_spec(loaded)
loaded.loader.exec_module(finish_app)


def spec(name: str) -> dict:
    return json.loads((HERE / "specs" / f"{name}.json").read_text(encoding="utf-8"))


def freeze_checks(name: str) -> list[str]:
    return [line for line in finish_app.plan_md(spec(name))[0].splitlines() if line.startswith("**Freeze check:**")]


class FreezeChecks(unittest.TestCase):
    def test_frozen_new_tool_is_held_to_its_fixtures(self):
        checks = freeze_checks("BootManager")
        self.assertTrue(checks)
        for line in checks:
            self.assertNotIn("reference/au3", line)
            self.assertNotIn("parity check", line)
            self.assertIn("tests/fixtures", line)
        self.assertNotIn("AutoIt original computes", finish_app.agents_section(spec("BootManager")))

    def test_frozen_port_is_still_held_to_its_original(self):
        checks = " ".join(freeze_checks("Ownership"))
        self.assertIn("Nothing under `reference/au3/` changes", checks)
        self.assertIn("The parity check of", checks)

    def test_unfrozen_tool_has_no_freeze_check(self):
        self.assertEqual(freeze_checks("HashVerifier"), [])


if __name__ == "__main__":
    unittest.main()
