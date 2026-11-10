#!/usr/bin/env python3
"""Claude Code PreToolUse hook for Bash and PowerShell: every review goes through scripts/review-dispatch.py, and the
pin and recorded rounds are never modified on the way to a review or a stamp.

1. Any command that runs `codex exec` directly is refused; `review-dispatch.py` is the only caller, and it reads the
   model and reasoning effort from `.conclave/reviewers.toml`.
2. Any command that runs `review-dispatch.py` or `todo-graph.py stamp` while `.conclave/reviewers.toml` or anything
   under `docs/reviews/` is modified or staged in the working tree is refused (`stamp` reads both from `HEAD` anyway,
   and refusing here stops a hand-edited pin or round before a reviewer runs).
3. A `review-dispatch.py` call that runs a reviewer must use the shell tool's `run_in_background` option. A review
   takes up to half an hour and the shell tool stops a foreground command at ten minutes, and only a background
   command tells the session when it has finished, so the session can end its turn and be woken by the result.
"""
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]

# Match `codex` or `codex.cmd`/`codex.exe` followed by `exec`, at the start of the command or after a shell separator,
# pipe, subshell or quote, while leaving prose in `git commit -m "..."` or `echo` untouched unless it actually invokes
# the binary. A false positive on a commit message is avoided by ignoring commands whose first word is `git`.
DIRECT_CODEX = re.compile(
    r"(?:^|[;&|()\n`]|&&|\|\|)\s*"
    r"(?:env\s+\S+=\S+\s+)*"
    r"[\"']?(?:[^\s\"']*[/\\])?codex(?:\.(?:cmd|exe|bat|ps1))?[\"']?"
    r"(?:\s+-\S+)*\s+exec\b",
    re.IGNORECASE,
)
FIRST_WORD = re.compile(r"^\s*[\"']?(?:[^\s\"']*[/\\])?([a-z0-9._-]+)", re.IGNORECASE)
DISPATCH_OR_STAMP = re.compile(
    r"\breview-dispatch\.py\b|\btodo-graph\.py\b[^\n;|&]*\bstamp\b",
    re.IGNORECASE,
)


def deny(reason):
    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": reason,
            }
        },
        sys.stdout,
    )
    sys.stdout.write("\n")
    return 0


# The dispatcher run as a command (an interpreter at the start of a command, then the script), not its name inside a
# file being written: quoted blocks (a PowerShell here-string, a shell here-document) are taken out before the
# command is read, so text that mentions a review is not one. Every command on the line is read, whatever the first
# one is: a review that follows `git status;` is still a review. The two read-only inspections start no reviewer.
QUOTED_BLOCK = re.compile(
    r"@'.*?^'@|@\".*?^\"@|<<-?\s*(['\"]?)(\w+)\1.*?^\s*\2\s*$",
    re.DOTALL | re.MULTILINE,
)
RUNS_A_REVIEW = re.compile(
    r"(?:^|[;&|()\n`]|&&|\|\|)\s*(?:&\s*)?"
    r"[\"']?(?:[^\s\"']*[/\\])?(?:python[\d.]*|py)(?:\.exe)?[\"']?\s+(?:-\S+\s+)*"
    r"[\"']?[^\s\"']*review-dispatch\.py\b(?![^\n;|&]*--(?:check-pin|list-rounds)\b)",
    re.IGNORECASE,
)
# A shell that is handed a command as a quoted string runs what the string says: `pwsh -Command "..."`,
# `bash -c '...'`, `cmd /c "..."`. The quoted string is read as commands in its own right. Only after such a flag:
# `echo "python scripts/review-dispatch.py ..."` prints its string and runs nothing.
WRAPPED = re.compile(
    r"\b(?:pwsh|powershell|bash|sh|zsh|cmd)(?:\.exe)?\b[^\n;|&]*?\s(?:-Command|-c|/c)\s+([\"'])(.*?)\1",
    re.IGNORECASE | re.DOTALL,
)


def runs_a_review(command):
    """Whether the command line starts a reviewer, directly or through a shell it hands a quoted command to."""
    text = QUOTED_BLOCK.sub(" ", command or "")
    return bool(RUNS_A_REVIEW.search(text)) or any(RUNS_A_REVIEW.search(inner.group(2)) for inner in WRAPPED.finditer(text))


def check_command(command, repo=ROOT, background=True):
    """Return a refusal reason if `command` violates the dispatch rules, or None."""
    first = FIRST_WORD.match(command or "")
    if not background and runs_a_review(command):
        return (
            "Run `review-dispatch.py` with the shell tool's `run_in_background` option: a review can take half an hour, "
            "a foreground command is stopped at ten minutes, and only a background command wakes this session when "
            "the review returns. Start it in the background, end the turn, and read the record when notified."
        )
    first_word = first.group(1).lower() if first else ""
    if first_word != "git" and DIRECT_CODEX.search(command or ""):
        return (
            "Direct `codex exec` calls are refused. Run reviews through "
            "`python3 scripts/review-dispatch.py --writer claude --prompt <file> --record <findings.md>`, "
            "which reads the model and reasoning effort from `.conclave/reviewers.toml`."
        )
    if DISPATCH_OR_STAMP.search(command or ""):
        status = subprocess.run(
            ["git", "status", "--porcelain", "--", ".conclave/reviewers.toml"],
            cwd=repo, capture_output=True, text=True,
        )
        if status.returncode == 0 and status.stdout.strip():
            return (
                "`.conclave/reviewers.toml` has uncommitted changes in the working tree. "
                "The reviewer pin is set by the owner; restore `.conclave/reviewers.toml` to `HEAD` before "
                "running `review-dispatch.py` or `todo-graph.py stamp`."
            )
    return None


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0
    tool_input = payload.get("tool_input") or {}
    command = tool_input.get("command") or ""
    reason = check_command(command, background=tool_input.get("run_in_background") is True)
    if reason:
        return deny(reason)
    return 0


if __name__ == "__main__":
    sys.exit(main())
