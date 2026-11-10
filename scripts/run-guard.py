#!/usr/bin/env python3
"""Keeps an unattended `process plan` run going; see scripts/lib/run_guard.py for the rules.

  hook                       one Claude Code hook event on stdin (.claude/settings.json)
  watch                      one scheduled tick: resume a dead run, never beside a live session
  status                     prints "active" or why not, then the detail
  start --session <id>       switch the run on for a session (--launcher-pid names the process that restarts it)
  halt --ground G --reason R record a halt (data-loss, credentials, shared-infrastructure, wrong-calculation, operator)
  install | uninstall        add or remove the Windows scheduled task for `watch`
  replace-stuck --started T  the launcher's look at its session: end one that has written nothing for 45 minutes
  cache-token                keep the sign-in token read from stdin, encrypted for this Windows account, for a resume
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

sys.dont_write_bytecode = True  # the guard's own cache files must not read as progress in the tree it watches
sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))

import run_guard as guard  # noqa: E402


def say(text: str) -> None:
    if sys.stdout is not None:  # pythonw, as the scheduled task runs it, has no stdout
        print(text)


def install() -> int:
    python = Path(sys.executable)
    windowless = python.with_name("pythonw.exe")
    runner = windowless if windowless.exists() else python
    action = f'"{runner}" "{Path(__file__).resolve()}" watch'
    done = subprocess.run(["schtasks", "/Create", "/F", "/TN", guard.TASK_NAME, "/SC", "MINUTE", "/MO", str(guard.WATCH_MINUTES), "/IT", "/TR", action], capture_output=True, text=True)
    say((done.stdout or done.stderr).strip())
    return done.returncode


def uninstall() -> int:
    done = subprocess.run(["schtasks", "/Delete", "/F", "/TN", guard.TASK_NAME], capture_output=True, text=True)
    say((done.stdout or done.stderr).strip())
    return done.returncode


def watch() -> int:
    try:
        result = guard.watch_tick()
    except Exception as error:
        guard.log(f"watch failed: {error!r}")
        guard.record_tick(repr(error), False)
        return 1
    guard.log(f"watch: {result}")
    guard.record_tick(result, True)
    say(result)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    commands = parser.add_subparsers(dest="command", required=True)
    for name in ("hook", "watch", "status", "install", "uninstall", "cache-token"):
        commands.add_parser(name)
    start = commands.add_parser("start")
    start.add_argument("--session", required=True)
    start.add_argument("--permission-mode")
    start.add_argument("--launcher-pid", type=int, help="the process that restarts this session when it dies, so `watch` leaves the run to it")
    start.add_argument("--restart", action="store_true", help="replace a session that died: refused unless the run is still active")
    start.add_argument("--open-ok", action="store_true", help="the operator accepted the other sessions open in this clone")
    start.add_argument("--model", help="the session's model, kept for a session the watchdog starts")
    start.add_argument("--disallowed", help="tools switched off for the session, comma-separated, kept the same way")
    start.add_argument("--goal-file", help="a file holding the session's first prompt, kept the same way")
    stuck = commands.add_parser("replace-stuck")
    stuck.add_argument("--started", type=float, required=True, help="when the launcher started the session, as epoch seconds")
    stop = commands.add_parser("halt")
    stop.add_argument("--ground", required=True, choices=guard.GROUNDS)
    stop.add_argument("--reason", required=True)
    args = parser.parse_args()

    if args.command == "hook":
        try:
            output = guard.hook(sys.stdin.buffer.read().decode("utf-8", "replace"))
        except Exception as error:  # fail open, and say so: a broken guard must never wedge a session or pass unseen
            guard.log(f"hook failed open: {error!r}")
            say(json.dumps({"systemMessage": f"Run guard failed and is not holding this run: {error}"}))
            return 0
        if output:
            say(output)
        return 0
    if args.command == "cache-token":
        # The token arrives on stdin, never as an argument, and is not echoed: only the outcome is said.
        try:
            guard.cache_token(sys.stdin.read())
        except (ValueError, OSError) as error:
            say(f"not cached: {error}")
            return 1
        say("cached")
        return 0
    if args.command == "install":
        return install()
    if args.command == "uninstall":
        return uninstall()

    if args.command == "status":
        state = guard.load()
        say("active" if state.get("active") else (state.get("status") or "inactive"))
        detail = {k: state.get(k) for k in ("session_id", "why", "started", "ended", "restarts", "yields", "last_restart", "last_error", "heartbeat_at", "last_api_failure") if state.get(k) is not None}
        say(json.dumps({**detail, **guard.health(state)}))
        return 0
    if args.command == "watch":
        return watch()
    if args.command == "replace-stuck":
        result = guard.replace_stuck(guard.load(), guard.REAL, args.started)
        if result.startswith("replaced"):
            guard.log(f"launcher: {result}")
        say(result)
        return 0
    with guard.locked():
        state = guard.load()
        if args.command == "start":
            try:
                launcher = None
                if args.launcher_pid:
                    launcher = {"pid": args.launcher_pid, "started": guard.process_started(args.launcher_pid)}
                    if launcher["started"] is None:
                        raise ValueError(f"launcher process {args.launcher_pid} is not running")
                launch = None
                if args.model or args.disallowed or args.goal_file:
                    launch = {"model": args.model, "disallowed": [t for t in (args.disallowed or "").split(",") if t],
                              "goal": Path(args.goal_file).read_text(encoding="utf-8").strip() if args.goal_file else None}
                guard.start(state, args.session, args.permission_mode, guard.REAL, launcher, restart=args.restart, open_ok=args.open_ok, launch=launch)
            except (ValueError, OSError) as error:
                say(str(error))
                return 1
        else:
            guard.halt(state, args.ground, args.reason)
        guard.save(state)
    say(state.get("status", ""))
    child = state.get("child")
    if args.command == "halt" and child and guard.real_child_alive(child):
        say(f"Resumed session {child['pid']} is still working and will stop at the end of its turn. To end it now: taskkill /PID {child['pid']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
