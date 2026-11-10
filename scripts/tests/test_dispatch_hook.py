import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import dispatch_hook as hook  # noqa: E402

REVIEW = "python scripts/review-dispatch.py --writer claude --writer-model claude-fable-5-2 --prompt p.md --record docs/reviews/x.md"


class Background(unittest.TestCase):
    def test_a_review_in_the_foreground_is_refused_and_one_in_the_background_is_not(self):
        for command in (REVIEW, f"cd D:/Resolute; {REVIEW}", REVIEW.replace("python ", "reskit\\python\\python.exe ")):
            self.assertIn("run_in_background", hook.check_command(command, background=False), command)
            self.assertIsNone(hook.check_command(command, background=True), command)

    def test_the_read_only_inspections_run_anywhere(self):
        for flag in ("--check-pin", "--list-rounds --json"):
            self.assertIsNone(hook.check_command(f"python scripts/review-dispatch.py {flag}", background=False), flag)

    def test_a_review_after_another_command_is_still_a_review(self):
        for command in (f"git status; {REVIEW}", f"git status && {REVIEW}", f"git log -1\n{REVIEW}"):
            self.assertIn("run_in_background", hook.check_command(command, background=False), command)

    def test_naming_the_dispatcher_in_a_message_or_a_file_being_written_is_not_a_review(self):
        for command in (
            'git commit -m "run review-dispatch.py in the background"',
            f"@'\nREVIEW = \"{REVIEW}\"\n'@ | Set-Content scripts/tests/x.py",
            f"@'\n{REVIEW}\n'@ | Set-Content notes.txt",
            f"@\"\n{REVIEW}\n\"@ | Set-Content notes.txt",
            f"cat > notes.txt <<'EOF'\n{REVIEW}\nEOF",
            "Select-String -Path scripts/review-dispatch.py -Pattern astra",
        ):
            self.assertIsNone(hook.check_command(command, background=False), command)

    def test_a_direct_codex_exec_is_still_refused(self):
        self.assertIn("codex exec", hook.check_command("codex exec -m gpt-6-astra -", background=True))


if __name__ == "__main__":
    unittest.main()
