"""check-all.ps1 gate detail patterns must retain what a developer
needs from a passing gate. Owner: D07 T01 section 3 (repair2
completion): the conformance gate's DetailPattern once retained only
the aggregate summary, so an advisory FAIL under an open owner never
reached the terminal. These tests pin the pattern text in
check-all.ps1 against the exact lines conformance-check.py prints.
"""

import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent


def detail_pattern(gate_name: str) -> str:
    text = (ROOT / "scripts" / "check-all.ps1").read_text(encoding="utf-8")
    m = re.search(
        rf"Invoke-Gate -Name '{re.escape(gate_name)}'.*?-DetailPattern '([^']+)'",
        text,
        re.S,
    )
    assert m, f"no DetailPattern found for gate {gate_name!r}"
    return m.group(1)


class ConformanceGateDetail(unittest.TestCase):
    def test_summary_line_retained(self):
        pat = detail_pattern("conformance check")
        line = (
            "conformance: 33 clause(s) x 2 tool(s), 0 failing, "
            "44 not yet evaluable, 1 advisory failing (owner open): C22 RegStudio"
        )
        self.assertRegex(line, pat)

    def test_advisory_fail_detail_retained(self):
        pat = detail_pattern("conformance check")
        line = (
            "conformance detail: C22 RegStudio: NYE (advisory FAIL: "
            "hardcoded year/version literal at src/main.cpp:3)"
        )
        self.assertRegex(line, pat)

    def test_advisory_pass_detail_not_retained(self):
        pat = detail_pattern("conformance check")
        line = "conformance detail: C22 Resolute: NYE (advisory PASS: clean)"
        self.assertNotRegex(line, pat)


class AdvisoryReportPath(unittest.TestCase):
    """Behavioral: execute check-all.ps1's own report block (extracted
    verbatim from the file, not copied) under pwsh with a passing
    advisory gate result, and require the emitted line to name the
    advisory and the readable full-report path. Commenting out the
    path-appending statement in check-all.ps1 fails this test."""

    def _run_report_block(self, detail: str) -> str:
        import subprocess

        text = (ROOT / "scripts" / "check-all.ps1").read_text(encoding="utf-8")
        start = text.index("foreach ($r in $results) {")
        end = text.index("$failed = @($results")
        block = text[start:end]
        script = (
            "$results = @([pscustomobject]@{ Name='conformance check'; "
            "Status='ok'; Seconds=1.0; Log='D:\\logs\\gate-conformance.log'; "
            f"Detail='{detail}'; Failed=$false }})\n" + block
        )
        proc = subprocess.run(
            ["pwsh", "-NoProfile", "-Command", script],
            capture_output=True, text=True, timeout=120,
        )
        assert proc.returncode == 0, proc.stderr
        return proc.stdout

    def test_successful_advisory_gate_names_its_log(self):
        out = self._run_report_block(
            "conformance detail: C22 RegStudio: NYE (advisory FAIL: x) | "
            "1 advisory failing (owner open): C22 RegStudio"
        )
        self.assertIn("C22 RegStudio", out)
        self.assertIn("advisory", out)
        self.assertIn("gate-conformance.log", out)

    def test_plain_passing_gate_gets_no_report_path(self):
        out = self._run_report_block("33 clause(s) x 2 tool(s), 0 failing")
        self.assertNotIn("gate-conformance.log", out)


if __name__ == "__main__":
    unittest.main()
