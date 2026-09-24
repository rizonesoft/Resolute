"""Driven self-test for the campaign Stop hook (D00 T04 §32).

`.claude/hooks/campaign-stop.ps1` blocks the campaign session's end of
turn while its run is open. This drives the real hook with Stop payloads
against a throwaway workspace (a git repository, a guard file, a run
file, and a fake `scripts/todo-graph.py` whose runnable count the test
controls) and asserts every allow and block case plus the stall breaker.

    python scripts/campaign_guard.py --self-test
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
HOOK = os.path.normpath(os.path.join(HERE, "..", ".claude", "hooks", "campaign-stop.ps1"))
SESSION = "11111111-2222-3333-4444-555555555555"
RUN_FILE = "docs/phase-runs/2099-01-01-phase-0.md"


def _powershell() -> str | None:
    for name in ("powershell.exe", "powershell", "pwsh"):
        found = shutil.which(name)
        if found:
            return found
    return None


def run_hook(root: str, session: str) -> tuple[int, dict | None, str]:
    """Feed the hook one Stop payload; return (exit, parsed stdout JSON or
    None when it allowed silently, stderr)."""
    shell = _powershell()
    env = dict(os.environ, CLAUDE_PROJECT_DIR=root)
    payload = json.dumps({"session_id": session, "cwd": root, "hook_event_name": "Stop"})
    proc = subprocess.run([shell, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", HOOK],
                          input=payload, capture_output=True, text=True, encoding="utf-8",
                          errors="replace", env=env, timeout=120)
    out = proc.stdout.strip()
    try:
        parsed = json.loads(out) if out else None
    except ValueError:
        parsed = {"unparsed": out}
    return proc.returncode, parsed, proc.stderr


def _workspace(tmpd: str) -> str:
    root = os.path.join(tmpd, "ws")
    os.makedirs(os.path.join(root, "scripts"))
    os.makedirs(os.path.join(root, "build"))
    os.makedirs(os.path.join(root, "docs", "phase-runs"))
    with open(os.path.join(root, ".gitignore"), "w", encoding="utf-8") as fh:
        fh.write("build/\n")
    # The fake graph prints the runnable count the test writes to ready.txt.
    with open(os.path.join(root, "scripts", "todo-graph.py"), "w", encoding="utf-8") as fh:
        fh.write("import os\n"
                 "n = open(os.path.join(os.path.dirname(__file__), 'ready.txt')).read().strip()\n"
                 "if n != '0':\n"
                 "    print('00-workspace/TODO-04-self-correction.md §31  Red CI repaired, not waited on')\n"
                 "print()\n"
                 "print(f'{n} runnable now, 0 runnable elsewhere')\n")
    _set_ready(root, 3)
    with open(os.path.join(root, RUN_FILE), "w", encoding="utf-8") as fh:
        fh.write("# Phase run: Phase 0\n\n## Sections log\n")
    for args in (["init", "-q"], ["config", "user.email", "t@t"], ["config", "user.name", "t"],
                 ["config", "commit.gpgsign", "false"], ["add", "-A"], ["commit", "-qm", "seed"]):
        subprocess.run(["git", *args], cwd=root, capture_output=True, check=True)
    return root


def _set_ready(root: str, n: int) -> None:
    with open(os.path.join(root, "scripts", "ready.txt"), "w", encoding="utf-8") as fh:
        fh.write(str(n))


def _guard(root: str, session: str = SESSION, run_file: str = RUN_FILE) -> None:
    with open(os.path.join(root, "build", "claude-campaign-guard.json"), "w", encoding="utf-8") as fh:
        json.dump({"runner": "claude", "workspace": root, "phase": 0, "run_file": run_file,
                   "session_id": session, "cron_id": "job-1"}, fh)


def _state(root: str) -> dict:
    path = os.path.join(root, "build", "claude-campaign-state.json")
    if not os.path.exists(path):
        return {}
    with open(path, encoding="utf-8-sig") as fh:
        return json.load(fh)


def _self_test() -> int:
    passed = failed = 0

    def check(name: str, ok: bool, detail: str = "") -> None:
        nonlocal passed, failed
        if ok:
            passed += 1
        else:
            failed += 1
            print(f"FAIL {name} {detail}")

    if _powershell() is None:
        print("campaign_guard self-test: SKIP (no PowerShell on this host)")
        return 0
    if not os.path.isfile(HOOK):
        print(f"FAIL hook-present {HOOK}")
        return 1
    with tempfile.TemporaryDirectory(prefix="campaign-guard-") as tmpd:
        root = _workspace(tmpd)

        code, out, err = run_hook(root, SESSION)
        check("allow-without-guard", code == 0 and out is None, f"{code} {out} {err}")

        _guard(root)
        code, out, err = run_hook(root, "99999999-0000-0000-0000-000000000000")
        check("allow-another-session", code == 0 and out is None, f"{code} {out} {err}")

        code, out, err = run_hook(root, SESSION)
        check("block-open-run-naming-next-row",
              code == 0 and isinstance(out, dict) and out.get("decision") == "block"
              and "Next ready row: 00-workspace/TODO-04-self-correction.md §31" in out.get("reason", "")
              and "repair it: D00 T04 section 31" in out.get("reason", ""), f"{code} {out} {err}")

        # Stall breaker: blocks 2 and 3 with no tree change, then the trip.
        run_hook(root, SESSION)
        code, out, _ = run_hook(root, SESSION)
        check("third-block-still-blocks", isinstance(out, dict) and out.get("decision") == "block", str(out))
        code, out, err = run_hook(root, SESSION)
        st = _state(root)
        check("breaker-trips-after-three-unchanged-blocks",
              code == 0 and out is None and st.get("trips") == 1 and st.get("stalled") is True
              and "stall breaker tripped (1)" in err, f"{code} {out} {st} {err}")
        with open(os.path.join(root, "progress.txt"), "w", encoding="utf-8") as fh:
            fh.write("moved\n")
        code, out, _ = run_hook(root, SESSION)
        st = _state(root)
        check("progress-resets-the-breaker",
              isinstance(out, dict) and out.get("decision") == "block"
              and st.get("blocks") == 1 and st.get("trips") == 0, f"{out} {st}")

        _set_ready(root, 0)
        code, out, _ = run_hook(root, SESSION)
        check("allow-when-nothing-is-runnable", code == 0 and out is None, str(out))
        _set_ready(root, 3)

        run_path = os.path.join(root, RUN_FILE)
        with open(run_path, "a", encoding="utf-8") as fh:
            fh.write("\nPARKED 2099-01-01T00:00:00Z every leftover row is blocked\n")
        code, out, _ = run_hook(root, SESSION)
        check("allow-when-parked", code == 0 and out is None, str(out))
        with open(run_path, "w", encoding="utf-8") as fh:
            fh.write("# Phase run: Phase 0\n\n## Closeout\n\nshipped\n")
        code, out, _ = run_hook(root, SESSION)
        check("allow-after-closeout", code == 0 and out is None, str(out))

        with open(run_path, "w", encoding="utf-8") as fh:
            fh.write("# Phase run: Phase 0\n\nThe word PARKED mid-line is not a marker\n")
        code, out, _ = run_hook(root, SESSION)
        check("mid-line-parked-still-blocks", isinstance(out, dict) and out.get("decision") == "block", str(out))

        _guard(root, run_file="../outside.md")
        code, out, _ = run_hook(root, SESSION)
        check("allow-when-run-file-escapes-the-workspace", code == 0 and out is None, str(out))

        with open(os.path.join(root, "build", "claude-campaign-guard.json"), "w", encoding="utf-8") as fh:
            fh.write("{not json")
        code, out, err = run_hook(root, SESSION)
        check("fail-open-on-a-bad-guard", code == 0 and out is None and "campaign-stop:" in err, f"{code} {out} {err}")

    print(f"campaign_guard self-test: {passed + failed} cases, {failed} failed")
    return 1 if failed else 0


def main(argv: list[str]) -> int:
    if argv == ["--self-test"]:
        return _self_test()
    print("usage: campaign_guard.py --self-test", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
