#!/usr/bin/env python3
"""Keeps an unattended `process plan` run going; see scripts/lib/run_guard.py for the rules.

  hook                       one Claude Code hook event on stdin (.claude/settings.json)
  status                     prints "active" or why not, then the detail; a run whose session is gone is recorded as ended
  start --session <id>       switch the run on for a session (--launcher-pid names the launcher that is starting it)
  session -- <command...>    run the session's CLI in this console, inside a job object that ends its whole tree with it
  ended --session <id>       the launcher's word that its session ended: an active run is recorded as ended
  halt --ground G --reason R record a halt (data-loss, credentials, shared-infrastructure, wrong-calculation, operator)
  cache-token                keep the sign-in token read from stdin, encrypted for this Windows account, for a later start

Nothing here starts or resumes a session that is dead: a run starts only when the operator starts it.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True  # the guard's own cache files must not read as progress in the tree it watches
sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))

import run_guard as guard  # noqa: E402


def say(text: str) -> None:
    print(text)


def main() -> int:
    if sys.argv[1:2] == ["session"]:
        # Everything after `session` is the session's own command line, passed on untouched.
        command = sys.argv[3:] if sys.argv[2:3] == ["--"] else sys.argv[2:]
        if not command:
            say("session needs the command to run")
            return 2
        try:
            return guard.run_session(command)
        except OSError as error:
            say(f"The session was not started: {error}")
            return 1
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    commands = parser.add_subparsers(dest="command", required=True)
    for name in ("hook", "status", "cache-token"):
        commands.add_parser(name)
    start = commands.add_parser("start")
    start.add_argument("--session", required=True)
    start.add_argument("--launcher-pid", type=int, help="the launcher that is starting this session and holds the run until it exists")
    start.add_argument("--open-ok", action="store_true", help="the operator accepted the other sessions open in this clone")
    ended = commands.add_parser("ended")
    ended.add_argument("--session", required=True)
    ended.add_argument("--reason", required=True, help="how the session ended, in the launcher's words")
    stop = commands.add_parser("halt")
    stop.add_argument("--ground", required=True, choices=guard.GROUNDS)
    stop.add_argument("--reason", required=True)
    stop.add_argument("--end-session", action="store_true", help="also end the session's process, for a stop given from outside it")
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
    if args.command == "status":
        state = guard.look()
        say("active" if state.get("active") else (state.get("status") or "inactive"))
        detail = {k: state.get(k) for k in ("session_id", "why", "started", "ended", "yields", "heartbeat_at", "last_api_failure") if state.get(k) is not None}
        say(json.dumps({**detail, **guard.health(state)}))
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
                guard.start(state, args.session, guard.REAL, launcher, open_ok=args.open_ok)
            except (ValueError, OSError) as error:
                say(str(error))
                return 1
        elif args.command == "ended":
            guard.session_ended(state, args.session, args.reason)
        else:
            guard.halt(state, args.ground, args.reason)
        guard.save(state)
    say(state.get("status", ""))
    if args.command == "halt":
        # Said as it is: the guard no longer holds the run open, and whether the session itself has stopped.
        if args.end_session:
            ended = guard.end_sessions(state, guard.REAL)
            say(f"The session was ended (process {', '.join(map(str, ended))})." if ended else "No session of this run was found running.")
        else:
            working = guard.owner_process(state.get("session_id"))
            if working:
                say(f"The guard no longer holds the run open, but its session (process {working}) is still running and a session with a goal set keeps working. To end it: `run-guard.py halt --ground operator --reason <why> --end-session`.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
