#!/usr/bin/env python3
"""Tests for scripts/design-lint.py (two-tier static design token and theme linter)."""
from __future__ import annotations

import json
import os
from pathlib import Path
import shutil
import stat
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "design-lint.py"
CREATION_FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) if os.name == "nt" else 0


def _rmtree(path: Path) -> None:
    def _on_err(func, target, _exc):
        os.chmod(target, stat.S_IWRITE | stat.S_IREAD)
        func(target)

    if path.exists():
        shutil.rmtree(path, onerror=_on_err)


class DesignLintHarness(unittest.TestCase):
    def setUp(self):
        self._tmp = Path(tempfile.mkdtemp()).resolve()
        self.addCleanup(_rmtree, self._tmp)
        self.root = self._tmp / "repo"
        self.root.mkdir()

    def write(self, rel: str, text: str) -> Path:
        p = self.root / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(text, encoding="utf-8", newline="\n")
        return p

    def write_json(self, rel: str, obj: object) -> Path:
        return self.write(rel, json.dumps(obj, indent=2) + "\n")

    def run_lint(self, *args: str, cwd: Path | None = None) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, "-B", str(SCRIPT), *args],
            cwd=str(cwd or self.root),
            stdin=subprocess.DEVNULL,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            creationflags=CREATION_FLAGS,
            timeout=30,
        )

    def git(self, *args: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["git", *args],
            cwd=str(self.root),
            stdin=subprocess.DEVNULL,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            creationflags=CREATION_FLAGS,
            check=True,
            timeout=30,
        )

    def init_git(self) -> None:
        self.git("init", "-q")
        self.git("config", "user.email", "test@example.com")
        self.git("config", "user.name", "Test User")
        self.git("config", "commit.gpgsign", "false")
        self.git("config", "core.autocrlf", "false")


class ModeDetectionAndConfigTests(DesignLintHarness):
    def test_off_when_no_config_and_no_contract(self):
        self.write("src/ui/View.xaml", '<Grid Background="#123456" Margin="12,8" />\n')
        res = self.run_lint()
        self.assertEqual(res.returncode, 0, res.stdout + res.stderr)

    def test_auto_strict_for_token_contract_markers(self):
        for marker in (
            "design/SPEC.md",
            "design/tokens.json",
            "design/tokens/colors.json",
            "docs/design/SPEC.md",
            "docs/design/tokens.json",
            "DESIGN.md",
            "sdk/DESIGN.md",
            "standards/design-contract.md",
        ):
            sub = self._tmp / ("m_" + marker.replace("/", "_").replace(".", "_"))
            sub.mkdir(parents=True)
            mpath = sub / marker
            mpath.parent.mkdir(parents=True, exist_ok=True)
            mpath.write_text("# Design\n", encoding="utf-8")
            xaml = sub / "src/ui/MainView.xaml"
            xaml.parent.mkdir(parents=True, exist_ok=True)
            xaml.write_text('<Grid Margin="12,8" />\n', encoding="utf-8")
            res = self.run_lint(cwd=sub)
            self.assertEqual(res.returncode, 1, f"{marker} should trigger strict mode: {res.stdout} {res.stderr}")
            self.assertIn("spacing-radius-literal", res.stdout)

    def test_auto_theme_only_when_only_design_contract_doc_exists(self):
        self.write("docs/design-contract.md", "# Design contract\n")
        self.write("src/Views/MainPage.xaml", '<Grid Margin="12,8" FontSize="14" Background="{ThemeResource AppBg}" />\n')
        res = self.run_lint()
        self.assertEqual(res.returncode, 0, res.stdout + res.stderr)

        self.write("src/Views/MainPage.xaml", '<Grid Margin="12,8" Background="#1e1e1e" />\n')
        res = self.run_lint()
        self.assertEqual(res.returncode, 1, res.stdout + res.stderr)
        self.assertIn("color-literal", res.stdout)

    def test_explicit_config_overrides_and_refuses_invalid_config(self):
        self.write("DESIGN.md", "# Design\n")
        self.write("src/Views/Panel.xaml", '<Grid Margin="12,8" />\n')
        self.write_json(".conclave/design-lint.json", {
            "schema_version": 1,
            "mode": "theme-only",
            "contract": "DESIGN.md",
            "ui_roots": ["src"],
            "exclude": ["src/legacy/"],
            "generated": ["src/Generated/Theme.xaml"],
            "baseline": ".conclave/custom-baseline.json",
        })
        res = self.run_lint()
        self.assertEqual(res.returncode, 0, res.stdout + res.stderr)

        for label, bad_cfg in (
            ("unknown-key", {"schema_version": 1, "mode": "strict", "extra": True}),
            ("bad-schema", {"schema_version": 2, "mode": "strict"}),
            ("bad-mode", {"schema_version": 1, "mode": "relaxed"}),
            ("bool-schema", {"schema_version": True, "mode": "strict"}),
        ):
            with self.subTest(label):
                self.write_json(".conclave/design-lint.json", bad_cfg)
                bad = self.run_lint()
                self.assertEqual(bad.returncode, 2, bad.stdout + bad.stderr)


class StackRuleTests(DesignLintHarness):
    def test_xaml_and_csharp_theme_only_and_strict(self):
        self.write("docs/design-contract.md", "# Contract\n")
        self.write_json(".conclave/design-lint.json", {
            "schema_version": 1,
            "mode": "theme-only",
            "contract": "docs/design-contract.md",
            "ui_roots": ["src"],
        })
        self.write(
            "src/Shell.xaml",
            '<Grid Margin="12,8" FontSize="14" Background="{ThemeResource LayerFillColorDefaultBrush}" />\n',
        )
        self.write("src/Shell.xaml.cs", "var b = Application.Current.Resources[\"Accent\"];\n")
        self.assertEqual(self.run_lint().returncode, 0)

        self.write("src/BadHex.xaml", '<Border Background="#1e1e1e" />\n')
        r_hex = self.run_lint()
        self.assertEqual(r_hex.returncode, 1)
        self.assertIn("color-literal", r_hex.stdout)

        self.write("src/BadHex.xaml", '<Border Foreground="Red" Background="Transparent" />\n')
        r_named = self.run_lint()
        self.assertEqual(r_named.returncode, 1)
        self.assertIn("color-literal", r_named.stdout)

        self.write("src/BadHex.xaml", '<Border Background="Transparent" />\n')
        self.write(
            "src/BadBrush.cs",
            "var c1 = Color.FromArgb(255, 10, 20, 30);\n"
            "var c2 = ColorHelper.FromArgb(255, 1, 2, 3);\n"
            "var b = new SolidColorBrush(Colors.Red);\n"
            "var ok = new SolidColorBrush(Colors.Transparent);\n",
        )
        r_cs = self.run_lint()
        self.assertEqual(r_cs.returncode, 1)
        self.assertEqual(r_cs.stdout.count(":color-literal:"), 3, r_cs.stdout)

        # Now switch to strict mode
        self.write_json(".conclave/design-lint.json", {
            "schema_version": 1,
            "mode": "strict",
            "contract": "design/SPEC.md",
            "ui_roots": ["src"],
        })
        self.write("src/BadBrush.cs", "// clean\n")
        self.write(
            "src/StrictCheck.xaml",
            '<StackPanel Margin="0" Padding="0,0,0,0">\n'
            '  <Border Margin="12,8" Padding="4" CornerRadius="6">\n'
            '    <TextBlock FontSize="14" FontFamily="Segoe UI" Text="Hi" />\n'
            "  </Border>\n"
            "</StackPanel>\n",
        )
        r_strict = self.run_lint()
        self.assertEqual(r_strict.returncode, 1)
        self.assertIn(":spacing-radius-literal:", r_strict.stdout)
        self.assertIn(":font-size-literal:", r_strict.stdout)
        self.assertIn(":font-family-literal:", r_strict.stdout)
        self.assertNotIn("line 1:", r_strict.stdout.lower())

        self.write("src/StrictCheck.xaml", '<TextBlock Text="\U0001F680" />\n')
        r_emoji = self.run_lint()
        self.assertEqual(r_emoji.returncode, 1)
        self.assertIn(":emoji-icon:", r_emoji.stdout)

    def test_cpp_direct2d_and_win32_strict_rules(self):
        self.write("DESIGN.md", "# Design\n")
        self.write(
            "src/ui/panel.cpp",
            "// RGB(1, 2, 3) in comment is ignored\n"
            "/* D2D1::ColorF(0x112233) in block comment is ignored */\n"
            "COLORREF bg = RGB(10, 20, 30);\n"
            "auto col = D2D1::ColorF(0x2da4de);\n"
            'factory->CreateTextFormat(L"Segoe UI", nullptr, DWRITE_FONT_WEIGHT_NORMAL, '
            "DWRITE_FONT_STYLE_NORMAL, DWRITE_FONT_STRETCH_NORMAL, 14.0f, L\"en-us\", &fmt);\n"
            "auto rr = D2D1::RoundedRect(rect, 6.0f, 6.0f);\n"
            "float corner_radius = 8.0f;\n"
            'const wchar_t* badge = L"\U0001F525";\n',
        )
        res = self.run_lint()
        self.assertEqual(res.returncode, 1, res.stdout + res.stderr)
        out = res.stdout
        self.assertNotIn("line 1", out)
        self.assertNotIn(":1:", out)
        self.assertNotIn(":2:", out)
        self.assertIn(":3:color-literal:", out)
        self.assertIn(":4:color-literal:", out)
        self.assertIn(":5:font-family-literal:", out)
        self.assertIn(":5:font-size-literal:", out)
        self.assertIn(":6:spacing-radius-literal:", out)
        self.assertIn(":7:spacing-radius-literal:", out)
        self.assertIn(":8:emoji-icon:", out)

    def test_web_css_tsx_and_anchor_safe_rules(self):
        self.write("design/SPEC.md", "# Spec\n")
        self.write(
            "src/ui/tokens.css",
            ":root {\n"
            "  --brand-blue: #2da4de;\n"
            "  --ink: #0f3247;\n"
            "}\n"
            ":root { --inline-ink: #123456; }\n",
        )
        self.write(
            "src/ui/good.css",
            ".card {\n"
            "  color: var(--ink);\n"
            "  font-family: var(--font-sans);\n"
            "  font-size: var(--text-sm);\n"
            "  padding: 0;\n"
            "  margin: var(--space-3);\n"
            "}\n",
        )
        self.write(
            "src/ui/Links.tsx",
            'export const link1 = "docs/design.md#abcdef";\n'
            'export const link2 = "https://example.com/#123456";\n'
            "export const cssTpl = `--brand: #abcdef;`;\n",
        )
        self.write(
            "src/ui/token_identifiers.cs",
            "var m = new Thickness(Tokens.Space4 - Tokens.Space2);\nvar r = new CornerRadius(Tokens.Radius2);\n",
        )
        self.write(
            "src/ui/token_identifiers.cpp",
            "auto rr = D2D1::RoundedRect(rect, tokens::radius4, tokens::radius4);\n",
        )
        ok = self.run_lint()
        self.assertEqual(ok.returncode, 0, ok.stdout + ok.stderr)

        self.write(
            "src/ui/bad.css",
            ".bad {\n"
            "  color: #2da4de;\n"
            "  background: rgba(0, 0, 0, 0.5);\n"
            "  font-family: Inter, sans-serif;\n"
            "  font-size: 14px;\n"
            "  padding: 12px;\n"
            "}\n"
            ".compact{color:#123456;}\n"
            ":root { --ok: #abcdef; color: #ff0000; }\n"
            '.escaped { --label: "a\\""; color: #ff0000; --other: "b"; }\n'
            '.unquoted_escape { --label: foo\\"; color: #ff0000; }\n',
        )
        self.write(
            "src/ui/panel.html",
            '<div style="--gap: 0"><span style="color: #ff0000">Text</span></div>\n'
            "<table style=--gap:0 bgcolor=#ff0000><tr><td>Text</td></tr></table>\n",
        )
        self.write(
            "src/ui/BadPanel.cs",
            "var a = new Thickness(1e2);\nvar b = new Thickness(Tokens.Space4-4);\n",
        )
        self.write(
            "src/ui/bad_panel.cpp",
            "auto rr = D2D1::RoundedRect(rect, 1e1f, 1e1f);\n",
        )
        bad = self.run_lint()
        self.assertEqual(bad.returncode, 1, bad.stdout + bad.stderr)
        self.assertEqual(bad.stdout.count(":color-literal:"), 8, bad.stdout)
        self.assertIn("src/ui/bad.css:9:color-literal:", bad.stdout)
        self.assertIn("src/ui/bad.css:10:color-literal:", bad.stdout)
        self.assertIn("src/ui/bad.css:11:color-literal:", bad.stdout)
        self.assertIn("src/ui/panel.html:1:color-literal:", bad.stdout)
        self.assertIn("src/ui/panel.html:2:color-literal:", bad.stdout)
        self.assertIn(":font-family-literal:", bad.stdout)
        self.assertIn(":font-size-literal:", bad.stdout)
        self.assertEqual(bad.stdout.count(":spacing-radius-literal:"), 4, bad.stdout)
        self.assertIn("src/ui/BadPanel.cs:1:spacing-radius-literal:", bad.stdout)
        self.assertIn("src/ui/BadPanel.cs:2:spacing-radius-literal:", bad.stdout)
        self.assertIn("src/ui/bad_panel.cpp:1:spacing-radius-literal:", bad.stdout)


class ScopingAndExemptionTests(DesignLintHarness):
    def test_default_exclusions_and_generated_files_are_skipped(self):
        self.write("DESIGN.md", "# Design\n")
        for rel in (
            "design/prototype/app.html",
            "design/mockups/index.html",
            "brand/logo.svg",
            "resources/brand/banner.html",
            "assets/brand/preview.css",
            "assets/icons/icon.css",
            "reference/old.css",
            "legacy_au3/old.css",
            "tests/ui_test.css",
            "src/tokens/palette.css",
            "Themes/Generic.xaml",
        ):
            self.write(rel, ".x { color: #ff00ff; font-size: 99px; }\n<Border Background=\"#ff00ff\" />\n")
        self.write_json(".conclave/design-lint.json", {
            "schema_version": 1,
            "mode": "strict",
            "contract": "DESIGN.md",
            "exclude": ["legacy_au3/"],
            "generated": ["src/ui/generated-theme.css"],
        })
        self.write("src/ui/generated-theme.css", ".x { color: #112233; }\n")
        res = self.run_lint()
        self.assertEqual(res.returncode, 0, res.stdout + res.stderr)

    def test_workaround_and_allow_comments_require_reason_within_three_lines(self):
        self.write("DESIGN.md", "# Design\n")
        self.write(
            "src/ui/ok.css",
            "/* WORKAROUND: platform fallback brush while theme loads */\n"
            ".a { color: #112233; }\n"
            "/* design-lint: allow font-size-literal -- fixed bitmap glyph */\n"
            ".b { font-size: 12px; }\n",
        )
        self.assertEqual(self.run_lint().returncode, 0)

        self.write("src/ui/empty_reason.css", "/* WORKAROUND: */\n.a { color: #112233; }\n")
        res = self.run_lint()
        self.assertEqual(res.returncode, 1)
        self.assertIn("empty_reason.css:2:color-literal:", res.stdout)


class BaselineAndStagedTests(DesignLintHarness):
    def test_baseline_create_shrink_refuse_growth_and_staged_index(self):
        self.init_git()
        self.write("DESIGN.md", "# Design\n")
        self.write("src/ui/panel.css", ".a {\n  color: #111111;\n  font-size: 14px;\n}\n")
        self.git("add", "-A")
        self.git("commit", "-qm", "seed")

        # Unbaselined fails
        self.assertEqual(self.run_lint().returncode, 1)

        # Updating without allow-add fails
        self.assertEqual(self.run_lint("--update-baseline").returncode, 1)

        # Updating with allow-add + reason creates baseline atomically
        up = self.run_lint("--update-baseline", "--allow-add", "--reason", "Initial baseline")
        self.assertEqual(up.returncode, 0, up.stdout + up.stderr)
        bfile = self.root / ".conclave/design-lint-baseline.json"
        self.assertTrue(bfile.is_file())
        self.assertEqual(self.run_lint().returncode, 0)

        self.git("add", ".conclave/design-lint-baseline.json")
        self.git("commit", "-qm", "baseline")

        # Reducing violations passes and shrinks baseline without --allow-add
        self.write("src/ui/panel.css", ".a {\n  color: var(--ink);\n  font-size: 14px;\n}\n")
        self.assertEqual(self.run_lint().returncode, 0)
        shrink = self.run_lint("--update-baseline")
        self.assertEqual(shrink.returncode, 0, shrink.stdout + shrink.stderr)
        bdata = json.loads(bfile.read_text(encoding="utf-8"))
        self.assertEqual(sum(bdata["counts"]["src/ui/panel.css"].values()), 1)

        # Adding a new violation fails
        self.write("src/ui/panel.css", ".a {\n  color: #111111;\n  background: #222222;\n  font-size: 14px;\n}\n")
        fail = self.run_lint()
        self.assertEqual(fail.returncode, 1)
        self.assertIn("src/ui/panel.css:", fail.stdout)
        self.assertEqual(self.run_lint("--update-baseline").returncode, 1)

        # Hand-editing baseline to inflate count vs HEAD without history entry fails
        self.write("src/ui/panel.css", ".a {\n  color: #111111;\n  font-size: 14px;\n}\n")
        tampered = json.loads(bfile.read_text(encoding="utf-8"))
        tampered["counts"]["src/ui/panel.css"]["color-literal"] = 9
        self.write_json(".conclave/design-lint-baseline.json", tampered)
        base_check = self.run_lint("--base", "HEAD")
        self.assertEqual(base_check.returncode, 1)
        self.assertIn("baseline", (base_check.stdout + base_check.stderr).lower())

        # Restore committed baseline and test --staged reads index, ignoring dirty worktree
        self.git("checkout", "--", ".conclave/design-lint-baseline.json", "src/ui/panel.css")
        self.write("src/ui/panel.css", ".a {\n  color: #111111;\n  background: #222222;\n  font-size: 14px;\n}\n")
        # Nothing staged yet -> --staged passes despite dirty worktree
        staged_clean = self.run_lint("--staged")
        self.assertEqual(staged_clean.returncode, 0, staged_clean.stdout + staged_clean.stderr)
        # Stage the dirty file -> --staged refuses
        self.git("add", "src/ui/panel.css")
        staged_bad = self.run_lint("--staged")
        self.assertEqual(staged_bad.returncode, 1)
        self.assertIn("src/ui/panel.css:", staged_bad.stdout)
        # Fix in worktree only (leaving bad version staged) -> --staged still refuses!
        self.write("src/ui/panel.css", ".a {\n  color: var(--ink);\n  font-size: var(--text-sm);\n}\n")
        staged_still_bad = self.run_lint("--staged")
        self.assertEqual(staged_still_bad.returncode, 1)

        # Unstaged working-tree config/baseline overrides must NEVER bypass --staged
        self.git("reset", "HEAD", "src/ui/panel.css")
        self.write_json(".conclave/design-lint.json", {"schema_version": 1, "mode": "strict", "contract": "DESIGN.md"})
        self.git("add", ".conclave/design-lint.json")
        self.git("commit", "-qm", "commit config")
        self.write("src/ui/panel.css", ".a {\n  color: #111111;\n  background: #222222;\n  font-size: 14px;\n}\n")
        self.git("add", "src/ui/panel.css")
        self.write_json(".conclave/design-lint.json", {"schema_version": 1, "mode": "off"})
        self.write_json(".conclave/design-lint-baseline.json", {
            "schema_version": 1,
            "counts": {"src/ui/panel.css": {"color-literal": 99, "font-size-literal": 99}},
            "history": [{"at": "2026-11-17T00:00:00Z", "reason": "unstaged bypass"}],
        })
        staged_still_strict = self.run_lint("--staged")
        self.assertEqual(staged_still_strict.returncode, 1, staged_still_strict.stdout + staged_still_strict.stderr)


if __name__ == "__main__":
    unittest.main()
