from __future__ import annotations

import importlib.util
import json
import os
import shutil
import subprocess
import sys
import tempfile
import threading
import time
import unittest
from pathlib import Path
from unittest import mock

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lib"))

import run_guard as guard  # noqa: E402


class World:
    """Stands in for the machine: rows, the tree, sessions, the launcher and the processes ended."""

    def __init__(self, rows=("D01 T02 §4",), signature="one", alive=(), live=(), launcher=False, reviewing=False):
        self.rows, self.sig, self.live, self.launcher, self.reviewing = rows, signature, list(live), launcher, reviewing
        self.alive = set(alive)
        self.ended = []
        self.contained, self.uncontainable = [], None  # sessions tied to their window, and why one could not be

    def contain(self, session):
        if self.uncontainable is None:
            self.contained.append(session)
        return self.uncontainable

    def env(self):
        return guard.Env(
            rows=lambda: None if self.rows is None else list(self.rows),
            signature=lambda: self.sig,
            alive=lambda s: s in self.alive,
            live_here=lambda: self.live,
            process_alive=lambda record: self.launcher,
            reviewing=lambda: self.reviewing,
            end=self.ended.append,
            contain=self.contain,
        )


def no_window() -> int:
    """The creation flag for a process a launcher test starts: no console window on Windows, nothing elsewhere."""
    return subprocess.CREATE_NO_WINDOW if sys.platform == "win32" else 0


def active(**extra):
    return {"active": True, "status": "active", "session_id": "me", **extra}


class Prompts(unittest.TestCase):
    def test_process_plan_switches_the_run_on_in_each_spelling(self):
        for prompt in ("process plan", "/process-plan", "Process the plan", "process plan."):
            state = {}
            note = guard.on_prompt(state, {"prompt": prompt, "session_id": "me", "permission_mode": "acceptEdits"}, World().env())
            self.assertTrue(state.get("active"), prompt)
            self.assertEqual(state["session_id"], "me")
            self.assertIn("CronCreate", note)

    def test_please_also_starts_it(self):
        state = {}
        guard.on_prompt(state, {"prompt": "please process the plan", "session_id": "me"}, World().env())
        self.assertTrue(state["active"])

    def test_an_audit_a_named_phase_or_talk_about_the_plan_does_not(self):
        for prompt in ("process plan --audit", "process-plan 2", "why did process plan stop", "I see we stopped"):
            state = {}
            self.assertIsNone(guard.on_prompt(state, {"prompt": prompt, "session_id": "me"}, World().env()))
            self.assertFalse(state.get("active"), prompt)

    def test_an_operator_stop_ends_the_run(self):
        for prompt in ("stop", "Stop cleanly and safely", "pause the run", "please halt", "stop.", "stop the process plan now"):
            state = active()
            guard.on_prompt(state, {"prompt": prompt, "session_id": "me"}, World().env())
            self.assertFalse(state["active"], prompt)
            self.assertEqual(state["status"], "stopped")

    def test_words_about_stopping_do_not_end_the_run(self):
        for prompt in ("I see we stopped", "stop hooks for this repo need work", "The other Windows repo also stopped.", "stop using subagents"):
            state = active()
            guard.on_prompt(state, {"prompt": prompt, "session_id": "me"}, World().env())
            self.assertTrue(state["active"], prompt)

    def test_a_less_plain_stop_goes_to_the_model_with_the_way_to_halt(self):
        for prompt in ("Please stop the run after the current section", "can you cancel this for now"):
            state = active()
            note = guard.on_prompt(state, {"prompt": prompt, "session_id": "me"}, World().env())
            self.assertIn("halt --ground operator", note, prompt)
            self.assertTrue(state["active"])
        self.assertIsNone(guard.on_prompt(active(), {"prompt": "what is next", "session_id": "me"}, World().env()))
        for machine in ("<task-notification>the agent can stop</task-notification>", "Run heartbeat: if it prints anything else stop"):
            self.assertIsNone(guard.on_prompt(active(), {"prompt": machine, "session_id": "me"}, World().env()))
        self.assertIsNone(guard.on_prompt(active(), {"prompt": "stop the build", "session_id": "someone else"}, World().env()))

    def test_a_second_session_cannot_take_a_live_run(self):
        state = active()
        note = guard.on_prompt(state, {"prompt": "process plan", "session_id": "other"}, World(alive=["me"]).env())
        self.assertIn("two writers", note)
        self.assertEqual(state["session_id"], "me")

    def test_a_session_can_take_a_run_whose_owner_died_and_keeps_its_counters(self):
        state = active(yields=2)
        guard.on_prompt(state, {"prompt": "process plan", "session_id": "new"}, World().env())
        self.assertEqual(state["session_id"], "new")
        self.assertEqual(state["yields"], 2)


class Stops(unittest.TestCase):
    def test_nothing_is_held_when_no_run_is_active(self):
        self.assertIsNone(guard.on_stop({}, {"session_id": "me"}, World().env()))
        self.assertIsNone(guard.on_stop({"active": False, "session_id": "me"}, {"session_id": "me"}, World().env()))

    def test_another_session_is_never_held(self):
        self.assertIsNone(guard.on_stop(active(), {"session_id": "other"}, World().env()))

    def test_runnable_rows_send_the_turn_back_naming_the_next(self):
        reason = guard.on_stop(active(), {"session_id": "me", "stop_hook_active": True}, World().env())
        self.assertIn("D01 T02 §4", reason)
        self.assertIn("Do not stop", reason)

    def test_no_runnable_rows_finishes_the_run(self):
        state = active()
        self.assertIsNone(guard.on_stop(state, {"session_id": "me"}, World(rows=()).env()))
        self.assertEqual((state["active"], state["status"]), (False, "drained"))
        self.assertIn("not the plan being done", state["why"])

    def test_rows_that_cannot_be_read_never_end_a_run(self):
        state = active()
        self.assertIsNotNone(guard.on_stop(state, {"session_id": "me"}, World(rows=None).env()))
        self.assertTrue(state["active"])

    def test_no_change_yields_after_the_ceiling_then_stalls(self):
        state, world, data = active(), World(), {"session_id": "me"}
        allowed = 0
        for _ in range(200):
            if guard.on_stop(state, data, world.env()) is None:
                allowed += 1
            if not state["active"]:
                break
        self.assertEqual(allowed, guard.MAX_YIELDS)
        self.assertEqual(state["status"], "stalled")

    def test_progress_resets_the_ceiling(self):
        state, world, data = active(), World(), {"session_id": "me"}
        for turn in range(100):
            world.sig = f"commit {turn}"
            self.assertIsNotNone(guard.on_stop(state, data, world.env()))
        self.assertTrue(state["active"])


class SessionEvents(unittest.TestCase):
    def test_a_normal_exit_ends_the_run_and_a_crash_reason_does_not(self):
        for reason in sorted(guard.USER_EXITS):
            state = active()
            guard.on_session_end(state, {"session_id": "me", "reason": reason})
            self.assertFalse(state["active"], reason)
        for reason in ("other", None):
            state = active()
            guard.on_session_end(state, {"session_id": "me", "reason": reason})
            self.assertTrue(state["active"], reason)

    def test_another_session_exiting_does_not_end_the_run(self):
        state = active()
        guard.on_session_end(state, {"session_id": "other", "reason": "prompt_input_exit"})
        self.assertTrue(state["active"])

    def test_only_the_runs_own_session_is_told_to_continue(self):
        self.assertIn("Continue process-plan", guard.on_session_start(active(), {"session_id": "me"}))
        state = active()
        self.assertIsNone(guard.on_session_start(state, {"session_id": "new"}))
        self.assertEqual(state["session_id"], "me")

    def test_a_heartbeat_about_to_expire_is_said(self):
        state = active(heartbeat_epoch=1000.0)
        self.assertTrue(guard.heartbeat_current(state, now=1000.0 + 5 * 86400))
        self.assertFalse(guard.heartbeat_current(state, now=1000.0 + guard.HEARTBEAT_RENEW_DAYS * 86400))

    def test_an_api_failure_is_kept_for_status(self):
        state = active()
        guard.on_stop_failure(state, {"session_id": "me", "error": "rate_limit"})
        self.assertIn("rate_limit", state["last_api_failure"])
        other = active()
        guard.on_stop_failure(other, {"session_id": "other", "error": "rate_limit"})
        self.assertNotIn("last_api_failure", other)

    def test_start_will_not_take_a_live_run(self):
        state = active()
        with self.assertRaises(ValueError):
            guard.start(state, "other", World(alive=["me"]).env())
        self.assertEqual(state["session_id"], "me")
        guard.start(state, "other", World().env())
        self.assertEqual(state["session_id"], "other")

    def test_start_keeps_the_launcher_and_a_start_without_one_forgets_it(self):
        state = {}
        guard.start(state, "me", World().env(), {"pid": 7, "started": 8})
        self.assertEqual(state["launcher"], {"pid": 7, "started": 8})
        guard.start(state, "me", World().env())
        self.assertNotIn("launcher", state)

    def test_a_review_in_flight_lets_the_turn_end_and_is_not_an_idle_attempt(self):
        state = active(signature="one", idle=guard.MAX_IDLE_BLOCKS - 1, yields=guard.MAX_YIELDS - 1)
        before = dict(state)
        self.assertIsNone(guard.on_stop(state, {"session_id": "me"}, World(reviewing=True).env()))
        self.assertEqual(state, before)
        self.assertIn("Do not stop", guard.on_stop(active(), {"session_id": "me"}, World().env()))

    def test_the_heartbeat_is_recorded_and_its_absence_is_said(self):
        state = active()
        self.assertIn("not armed", guard.on_stop(state, {"session_id": "me"}, World().env()))
        guard.on_cron_created(state, {"session_id": "other"})
        self.assertNotIn("heartbeat_at", state)
        guard.on_cron_created(state, {"session_id": "me"})
        self.assertNotIn("not armed", guard.on_stop(state, {"session_id": "me"}, World(signature="two").env()))


class Admission(unittest.TestCase):
    """`start` is the one way a launcher's session gets to write."""

    def test_a_second_launcher_is_refused_while_the_first_is_alive(self):
        state = {}
        guard.start(state, "one", World().env(), {"pid": 7, "started": 8})
        with self.assertRaises(ValueError) as refused:
            guard.start(state, "two", World(launcher=True).env(), {"pid": 9, "started": 10})
        self.assertIn("a launcher (process 7) holds this run", str(refused.exception))
        self.assertEqual(state["session_id"], "one")
        guard.start(state, "two", World().env(), {"pid": 9, "started": 10})  # the first launcher has gone
        self.assertEqual(state["launcher"], {"pid": 9, "started": 10})

    def test_a_review_in_flight_refuses_a_start(self):
        with self.assertRaises(ValueError) as refused:
            guard.start({}, "me", World(reviewing=True).env())
        self.assertIn("review is in flight", str(refused.exception))

    def test_another_open_session_refuses_a_start_unless_the_operator_accepted_it(self):
        state = {}
        with self.assertRaises(ValueError) as refused:
            guard.start(state, "me", World(live=["other"]).env())
        self.assertIn("other", str(refused.exception))
        self.assertEqual(state, {})
        guard.start(state, "me", World(live=["other"]).env(), open_ok=True)
        self.assertTrue(state["active"])
        guard.start(state, "me", World(live=["me"]).env())  # the session itself is not another session

    def test_a_prompt_in_another_session_cannot_take_a_run_a_launcher_has_reserved(self):
        # The launcher has been admitted and its Claude process has not registered yet, so the owner is not "alive".
        state = {}
        guard.start(state, "reserved", World().env(), {"pid": 7, "started": 8})
        world = World(launcher=True)  # the launcher is alive
        note = guard.on_prompt(state, {"prompt": "process plan", "session_id": "intruder"}, world.env())
        self.assertIn("launcher", note)
        self.assertEqual(state["session_id"], "reserved")
        self.assertIn("Unattended run guard is active", guard.on_prompt(state, {"prompt": "process plan", "session_id": "reserved"}, world.env()))

    def test_a_prompt_cannot_take_a_run_while_a_review_is_in_flight(self):
        state = active()
        note = guard.on_prompt(state, {"prompt": "process plan", "session_id": "intruder"}, World(reviewing=True).env())
        self.assertIn("review", note)
        self.assertEqual(state["session_id"], "me")
        fresh = {}
        self.assertIn("review", guard.on_prompt(fresh, {"prompt": "process plan", "session_id": "me"}, World(reviewing=True).env()))
        self.assertEqual(fresh, {})


class Gone(unittest.TestCase):
    """A run starts only when the operator starts it: a session that dies ends its run, and nothing resumes it."""

    def test_a_dead_session_is_recorded_as_ended_and_is_not_resumed(self):
        world, state = World(), active(launcher={"pid": 7, "started": 8})  # the session and its launcher are both gone
        self.assertTrue(guard.record_gone(state, world.env()))
        self.assertEqual((state["active"], state["status"]), (False, "ended"))
        self.assertIn("nothing resumes it", state["why"])
        # Nothing is left that could carry the run on: the dead session coming back is not told to continue, its
        # turns are not sent back, and the guard has no way to start a process of its own.
        self.assertIsNone(guard.on_session_start(state, {"session_id": "me"}))
        self.assertIsNone(guard.on_stop(state, {"session_id": "me"}, world.env()))
        self.assertEqual(world.ended, [])
        for name in ("watch", "watch_tick", "real_spawn", "resume_command", "replace_stuck"):
            self.assertFalse(hasattr(guard, name), name)
        self.assertNotIn("spawn", guard.Env.__dataclass_fields__)

    def test_a_live_session_is_never_ended_however_quiet_it_is(self):
        # A usage limit, a review or a long tool call all look like silence: only the session's death ends a run.
        state = active(heartbeat_epoch=1.0, changed_at=1.0)
        self.assertFalse(guard.record_gone(state, World(alive=["me"]).env()))
        self.assertTrue(state["active"])

    def test_a_run_its_launcher_still_holds_is_left_to_the_launcher(self):
        # Between the admission and the session appearing in Claude Code's records the owner is not "alive" yet.
        state = {}
        guard.start(state, "reserved", World().env(), {"pid": 7, "started": 8})
        self.assertFalse(guard.record_gone(state, World(launcher=True).env()))
        self.assertTrue(state["active"])

    def test_not_knowing_who_is_alive_ends_nothing(self):
        env = World().env()

        def unknown(_session):
            raise OSError("cannot tell")

        env.alive = unknown
        state = active()
        with self.assertRaises(OSError):
            guard.record_gone(state, env)
        self.assertTrue(state["active"])

    def test_the_launcher_says_when_its_session_ended_and_an_earlier_ending_stands(self):
        state = active()
        guard.session_ended(state, "another", "its session ended (exit 1)")
        self.assertTrue(state["active"])
        guard.session_ended(state, "me", "its session ended (exit 1)")
        self.assertEqual((state["active"], state["status"], state["why"]), (False, "ended", "its session ended (exit 1)"))
        stopped = active()
        guard.halt(stopped, "operator", "stopped from the launcher (-Stop)")
        guard.session_ended(stopped, "me", "its session ended (exit 0)")
        self.assertEqual(stopped["status"], "halted")


class CommandLine(unittest.TestCase):
    """scripts/run-guard.py as the launcher and the heartbeat run it, against a state file of the test's own."""

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.path = Path(self.temp.name) / "state.json"

    def guard(self, *args):
        script = Path(__file__).resolve().parents[1] / "run-guard.py"
        return subprocess.run([sys.executable, str(script), *args], capture_output=True, text=True, timeout=120,
                              env={**os.environ, "RUN_GUARD_STATE": str(self.path)}, creationflags=no_window())

    def test_status_records_a_run_whose_session_is_gone_as_ended_and_says_so(self):
        self.path.write_text(json.dumps(active(session_id="a-session-that-never-ran")), encoding="utf-8")
        said = self.guard("status").stdout.splitlines()
        self.assertEqual(said[0], "ended")
        self.assertIn("nothing resumes it", json.loads(said[1])["why"])
        state = guard.load(self.path)
        self.assertEqual((state["active"], state["status"]), (False, "ended"))
        self.assertEqual(self.guard("status").stdout.splitlines()[0], "ended")  # and it stays ended

    def test_there_is_no_command_that_resumes_a_run_or_schedules_one(self):
        self.path.write_text(json.dumps(active(session_id="a-session-that-never-ran")), encoding="utf-8")
        before = self.path.read_text(encoding="utf-8")
        for command in ("watch", "install", "uninstall", "replace-stuck"):
            self.assertEqual(self.guard(command).returncode, 2, command)
        self.assertEqual(self.path.read_text(encoding="utf-8"), before)

    @unittest.skipUnless(sys.platform == "win32", "the job object is the Windows half")
    def test_a_session_that_ends_takes_everything_it_started_with_it(self):
        # What the launcher runs: `session -- <the runner's command>`. The stand-in session starts a process that
        # would outlive it, says which, and ends. Closing the window ends the wrapper the same way, so this is the
        # proof for both: nothing a run started keeps running.
        code = (
            "import subprocess, sys\n"
            "left = subprocess.Popen([sys.executable, '-c', 'import time; time.sleep(120)'])\n"
            "print(left.pid, flush=True); sys.exit(7)\n"
        )
        ran = self.guard("session", "--", sys.executable, "-c", code)
        self.assertEqual(ran.returncode, 7, ran.stderr)
        left = int(ran.stdout.strip())
        deadline = time.monotonic() + 10
        while guard.process_started(left) is not None and time.monotonic() < deadline:
            time.sleep(0.1)
        self.assertIsNone(guard.process_started(left))


class Contained(unittest.TestCase):
    """Closing a run's window ends what the run started, for a run started by the prompt as for a launcher's."""

    def test_a_session_that_takes_the_run_by_the_prompt_is_tied_to_its_window_once(self):
        world, state = World(), {}
        guard.on_prompt(state, {"prompt": "process plan", "session_id": "me"}, world.env())
        guard.on_prompt(state, {"prompt": "process plan", "session_id": "me"}, world.env())
        self.assertEqual(world.contained, ["me"])
        guard.on_prompt(state, {"prompt": "process plan", "session_id": "new"}, world.env())  # the first has died
        self.assertEqual(world.contained, ["me", "new"])

    def test_a_launchers_session_is_left_to_the_launchers_own_job(self):
        world, state = World(launcher=True), {}
        guard.start(state, "me", World().env(), {"pid": 7, "started": 8})
        guard.on_prompt(state, {"prompt": "process plan", "session_id": "me"}, world.env())
        self.assertEqual(world.contained, [])

    def test_a_session_that_could_not_be_tied_is_said_and_tried_again(self):
        world, state = World(), {}
        world.uncontainable = "could not open process 41 (error 5)"
        note = guard.on_prompt(state, {"prompt": "process plan", "session_id": "me"}, world.env())
        self.assertIn("could not open process 41", note)
        self.assertTrue(state["active"])  # the guard fails open: the run is held all the same
        world.uncontainable = None
        guard.on_prompt(state, {"prompt": "process plan", "session_id": "me"}, world.env())
        self.assertEqual(world.contained, ["me"])

    @unittest.skipUnless(sys.platform == "win32", "the job object is the Windows half")
    def test_what_a_running_process_starts_afterwards_ends_with_it(self):
        # The stand-in session is already running when it is tied, as a Claude Code session is when `process plan`
        # is typed into it. It then starts a process, and is killed as a closed window kills it.
        import win_job

        code = (
            "import subprocess, sys, time\n"
            "sys.stdin.readline()\n"
            "left = subprocess.Popen([sys.executable, '-c', 'import time; time.sleep(120)'])\n"
            "print(left.pid, flush=True); time.sleep(120)\n"
        )
        session = subprocess.Popen([sys.executable, "-c", code], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                   text=True, creationflags=no_window())
        left = None
        try:
            win_job.end_children_with(session.pid)
            session.stdin.write("\n")
            session.stdin.flush()
            left = int(session.stdout.readline())
            self.assertIsNotNone(guard.process_started(left))
        finally:
            session.kill()
            session.wait()
            session.stdin.close()
            session.stdout.close()
            deadline = time.monotonic() + 10
            while left and guard.process_started(left) is not None and time.monotonic() < deadline:
                time.sleep(0.1)
            if left and guard.process_started(left) is not None:
                guard.end_tree(left)  # never left behind by a failing test
                self.fail("the process the session started outlived it")


class OutsideStop(unittest.TestCase):
    """A stop given from outside the session ends the session: a halted guard alone leaves a goal-driven one working."""

    def test_the_sessions_process_is_ended(self):
        world = World(launcher=True)
        state = active(launcher={"pid": 7, "started": 8})
        guard.halt(state, "operator", "stopped from the launcher (-Stop)")
        self.assertEqual(guard.end_sessions(state, world.env(), process=lambda session: 41 if session == "me" else None), [41])
        self.assertEqual(world.ended, [41])

    def test_a_session_claude_code_has_no_record_of_is_ended_through_its_launcher(self):
        # Another runner's session (Antigravity) is held under the launcher's own name for it.
        world = World(launcher=True)
        state = active(session_id="agy-1", launcher={"pid": 7, "started": 8})
        self.assertEqual(guard.end_sessions(state, world.env(), process=lambda session: None), [7])
        self.assertEqual(world.ended, [7])

    def test_nothing_is_ended_when_nothing_of_this_run_is_running(self):
        world = World()
        self.assertEqual(guard.end_sessions(active(launcher={"pid": 7, "started": 8}), world.env(), process=lambda session: None), [])
        self.assertEqual(world.ended, [])


class Quiet(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.projects = Path(self.temp.name)
        (self.projects / "D--Resolute").mkdir()

    def test_quiet_is_measured_from_the_sessions_transcript(self):
        self.assertIsNone(guard.owner_quiet_minutes(active(), projects=self.projects))
        transcript = self.projects / "D--Resolute" / "me.jsonl"
        transcript.write_text("{}\n", encoding="utf-8")
        self.assertEqual(guard.owner_quiet_minutes(active(), now=transcript.stat().st_mtime + 600, projects=self.projects), 10.0)


class SignIn(unittest.TestCase):
    TOKEN = "sk-ant-oat01-" + "a" * 60

    @unittest.skipUnless(sys.platform == "win32", "DPAPI is a Windows facility")
    def test_the_cache_round_trips_and_never_holds_the_token_in_the_clear(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "nested" / "token.dpapi"
            self.assertIsNone(guard.cached_token(path))
            guard.cache_token(self.TOKEN + "\n", path)
            self.assertNotIn(self.TOKEN.encode(), path.read_bytes())
            self.assertEqual(guard.cached_token(path), self.TOKEN)
            with self.assertRaises(ValueError):
                guard.cache_token("not a token", path)
            self.assertEqual(guard.cached_token(path), self.TOKEN)
            path.write_bytes(b"not something DPAPI wrote")
            self.assertIsNone(guard.cached_token(path))

    @unittest.skipUnless(sys.platform == "win32" and shutil.which("pwsh"), "the launcher is PowerShell on Windows")
    def test_the_launcher_can_read_the_cache_the_guard_wrote(self):
        # start-unattended-run.ps1 falls back to this cache when 1Password is locked, through .NET's ProtectedData:
        # the two must agree on the format, or that fallback is silently empty.
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "token.dpapi"
            guard.cache_token(self.TOKEN, path)
            with mock.patch.object(subprocess, "run", wraps=subprocess.run) as started:
                read = subprocess.run(
                    ["pwsh", "-NoProfile", "-Command",
                     "[Text.Encoding]::UTF8.GetString([System.Security.Cryptography.ProtectedData]::Unprotect("
                     f"[IO.File]::ReadAllBytes('{path}'), $null, 'CurrentUser'))"],
                    capture_output=True, text=True, timeout=60, creationflags=no_window())
            self.assertEqual(read.stdout.strip(), self.TOKEN, read.stderr)
            # A launcher test never opens a console window over the operator's work: every process it starts
            # carries the flag.
            self.assertTrue(started.call_args_list)
            for call in started.call_args_list:
                self.assertEqual(call.kwargs.get("creationflags"), subprocess.CREATE_NO_WINDOW, call.args[0][0])


class InFlight(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.folder = Path(self.temp.name) / "review-in-flight"
        spec = importlib.util.spec_from_file_location("review_dispatch", Path(__file__).resolve().parents[1] / "review-dispatch.py")
        self.dispatch = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(self.dispatch)

    def test_the_dispatcher_and_the_guard_agree_where_the_lock_and_the_markers_are(self):
        self.assertEqual(self.dispatch.LOCK_AT, guard.REVIEW_LOCK_AT)
        self.assertEqual(self.dispatch.IN_FLIGHT, guard.IN_FLIGHT)

    def test_a_marker_stands_exactly_while_the_review_runs(self):
        self.assertEqual(guard.reviews_in_flight(self.folder), [])
        with self.dispatch.in_flight("docs/reviews/x.md", "round", self.folder):
            (marker,) = guard.reviews_in_flight(self.folder)
            self.assertEqual(json.loads((self.folder / marker).read_text(encoding="utf-8"))["record"], "docs/reviews/x.md")
        self.assertEqual(guard.reviews_in_flight(self.folder), [])
        with self.assertRaises(RuntimeError):
            with self.dispatch.in_flight(None, "plan", self.folder):
                raise RuntimeError("the reviewer failed")
        self.assertEqual(list(self.folder.iterdir()), [])

    def test_a_marker_just_made_or_one_that_cannot_be_opened_counts_as_a_review(self):
        self.folder.mkdir()
        fresh = self.folder / "1.json"
        fresh.write_text("{}", encoding="utf-8")  # its dispatcher is between creating it and locking it
        self.assertTrue(guard.review_running(fresh))
        self.assertEqual(guard.reviews_in_flight(self.folder), ["1.json"])
        old = time.time() - guard.REVIEW_SETTLE - 1
        os.utime(fresh, (old, old))
        self.assertFalse(guard.review_running(fresh))  # nobody holds its lock
        blocked = self.folder / "2.json"
        blocked.mkdir()  # a marker that exists and cannot be opened as a file
        os.utime(blocked, (old, old))
        self.assertTrue(guard.review_running(blocked))

    def test_a_killed_dispatcher_takes_its_reviewer_with_it(self):
        # The dispatcher joins a kill-on-close job before it starts a reviewer, so killing it ends the reviewer too:
        # otherwise the marker would go while a reviewer still read the tree.
        if os.name != "nt":
            self.skipTest("the job object is the Windows half; elsewhere the reviewer's process group is ended")
        code = (
            "import subprocess, sys, time\n"
            f"sys.path.insert(0, {str(Path(__file__).resolve().parents[1] / 'lib')!r})\n"
            "import win_job\nwin_job.end_children_with_this_process()\n"
            "child = subprocess.Popen([sys.executable, '-c', 'import time; time.sleep(120)'])\n"
            "print(child.pid, flush=True); time.sleep(120)\n"
        )
        parent = subprocess.Popen([sys.executable, "-c", code], stdout=subprocess.PIPE)
        try:
            reviewer = int(parent.stdout.readline())
            self.assertIsNotNone(guard.process_started(reviewer))
        finally:
            parent.kill()
            parent.wait()
            parent.stdout.close()
        deadline = time.monotonic() + 10
        while guard.process_started(reviewer) is not None and time.monotonic() < deadline:
            time.sleep(0.1)
        self.assertIsNone(guard.process_started(reviewer))

    def test_a_marker_left_by_a_killed_dispatcher_is_not_a_review_and_is_removed(self):
        # A real dispatcher process holds the marker, is killed without a chance to clean up, and its lock goes with it.
        code = (
            "import importlib.util, sys, time; from pathlib import Path\n"
            "spec = importlib.util.spec_from_file_location('d', sys.argv[1]); d = importlib.util.module_from_spec(spec); spec.loader.exec_module(d)\n"
            "with d.in_flight('x.md', 'round', Path(sys.argv[2])):\n    print('held', flush=True); time.sleep(60)\n"
        )
        child = subprocess.Popen([sys.executable, "-c", code, self.dispatch.__file__, str(self.folder)], stdout=subprocess.PIPE)
        try:
            self.assertEqual(child.stdout.readline().strip(), b"held")
            # Aged past its settling time while its holder lives, so what keeps it counted is the lock itself: with
            # a probe that always found the lock free, this would read as no review and the marker would be removed.
            (held,) = self.folder.iterdir()
            old = time.time() - guard.REVIEW_SETTLE - 1
            os.utime(held, (old, old))
            self.assertTrue(guard.review_running(held))
            self.assertEqual(guard.reviews_in_flight(self.folder), [held.name])
            self.assertTrue(held.is_file())
        finally:
            child.kill()
            child.wait()
            child.stdout.close()
        (marker,) = self.folder.iterdir()
        old = time.time() - guard.REVIEW_SETTLE - 1
        os.utime(marker, (old, old))
        self.assertEqual(guard.reviews_in_flight(self.folder), [])
        self.assertEqual(list(self.folder.iterdir()), [])


class Rows(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.reviews = Path(self.temp.name)
        (self.reviews / "01-x").mkdir()

    def findings(self, name, text):
        (self.reviews / "01-x" / name).write_text(text, encoding="utf-8")

    def test_a_section_stranded_by_gaps_is_passed_over(self):
        self.findings("D01-T02-s1.md", "## Completion\nCOMPLETION: gaps\n")
        self.findings("D01-T02-s2.md", "## Completion\nCOMPLETION: complete\n")
        rows = [{"ref": f"D01 T02 §{n}"} for n in (1, 2, 3, 10)]
        self.assertEqual(guard.runnable(rows, self.reviews), ["D01 T02 §2", "D01 T02 §3", "D01 T02 §10"])

    def test_section_one_is_not_stranded_by_section_ten(self):
        self.findings("D01-T02-s10.md", "COMPLETION: gaps\n")
        self.assertEqual(guard.runnable([{"ref": "D01 T02 §1"}], self.reviews), ["D01 T02 §1"])

    def test_a_later_cycle_decides_over_a_returned_gap(self):
        self.findings("D01-T02-s1.md", "COMPLETION: gaps\n")
        self.findings("D01-T02-s1-cycle2.md", "COMPLETION: complete\n")
        self.assertEqual(guard.runnable([{"ref": "D01 T02 §1"}], self.reviews), ["D01 T02 §1"])

    def test_cycle_ten_is_later_than_cycle_nine(self):
        self.findings("D01-T02-s1-cycle9.md", "COMPLETION: gaps\n")
        self.findings("D01-T02-s1-cycle10.md", "COMPLETION: complete\n")
        self.assertEqual(guard.runnable([{"ref": "D01 T02 §1"}], self.reviews), ["D01 T02 §1"])

    def test_the_last_completion_decides_so_a_repair_cycle_clears_it(self):
        self.findings("D01-T02-s1.md", "COMPLETION: gaps\n\nCOMPLETION: complete\n")
        self.assertEqual(guard.runnable([{"ref": "D01 T02 §1"}], self.reviews), ["D01 T02 §1"])

    def test_a_row_needing_a_host_this_session_lacks_is_a_leftover(self):
        rows = [
            {"ref": "D01 T03 §1", "needs": ["arm64-host"]},
            {"ref": "D01 T03 §2", "needs": ["USB device (drive test)"]},
            {"ref": "D01 T03 §3", "needs": []},
        ]
        self.assertEqual(guard.runnable(rows, self.reviews), ["D01 T03 §3"])


class Halts(unittest.TestCase):
    def test_a_halt_needs_a_named_ground_and_a_reason(self):
        with self.assertRaises(ValueError):
            guard.halt(active(), "too many gaps", "because")
        with self.assertRaises(ValueError):
            guard.halt(active(), "credentials", "  ")
        state = active()
        guard.halt(state, "credentials", "token rejected")
        self.assertEqual((state["active"], state["status"]), (False, "halted"))
        self.assertIn("token rejected", state["why"])


class HookEntry(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.path = Path(self.temp.name) / "state.json"

    def event(self, world=None, **data):
        return guard.hook(json.dumps(data), (world or World()).env(), self.path)

    def test_a_whole_run_from_the_prompt_to_a_block_to_the_finish(self):
        started = json.loads(self.event(hook_event_name="UserPromptSubmit", prompt="process plan", session_id="me"))
        self.assertIn("CronCreate", started["hookSpecificOutput"]["additionalContext"])
        blocked = json.loads(self.event(hook_event_name="Stop", session_id="me"))
        self.assertEqual(blocked["decision"], "block")
        finished = json.loads(self.event(World(rows=()), hook_event_name="Stop", session_id="me"))
        self.assertIn("drained", finished["systemMessage"])
        self.assertFalse(guard.load(self.path)["active"])

    def test_an_ordinary_stop_prints_nothing_and_writes_nothing(self):
        self.assertEqual(self.event(hook_event_name="Stop", session_id="me"), "")
        self.assertFalse(self.path.exists())

    def test_a_corrupt_state_file_is_not_taken_for_no_run(self):
        self.path.write_text("{not json", encoding="utf-8")
        with self.assertRaises(ValueError):
            self.event(hook_event_name="Stop", session_id="me")

    def test_a_held_lock_refuses_rather_than_overwrites(self):
        code = (
            "import sys,time; sys.path.insert(0, sys.argv[1]); import run_guard as g, pathlib; "
            "p=pathlib.Path(sys.argv[2]); l=g.locked(p); l.__enter__(); print('held', flush=True); time.sleep(20)"
        )
        holder = subprocess.Popen([sys.executable, "-c", code, str(Path(guard.__file__).parent), str(self.path)], stdout=subprocess.PIPE)
        self.addCleanup(holder.stdout.close)
        self.addCleanup(holder.wait)
        self.addCleanup(holder.kill)
        self.assertIn(b"held", holder.stdout.readline())
        with self.assertRaises(TimeoutError):
            with guard.locked(self.path, wait=0.2):
                self.fail("two holders of the state lock")
        holder.kill()
        holder.wait()
        with guard.locked(self.path, wait=5):
            pass

    def test_the_cron_tool_records_the_heartbeat(self):
        self.path.write_text(json.dumps(active()), encoding="utf-8")
        self.event(hook_event_name="PostToolUse", tool_name="CronCreate", session_id="me")
        self.assertIn("heartbeat_at", guard.load(self.path))


class Signature(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for command in (["init", "-q"], ["-c", "user.name=t", "-c", "user.email=t@example.com", "commit", "-q", "--allow-empty", "-m", "start"]):
            subprocess.run(["git", *command], cwd=self.root, check=True, capture_output=True)

    def test_work_in_an_untracked_file_or_a_new_folder_changes_it(self):
        first = guard.real_signature(self.root)
        (self.root / "new").mkdir()
        (self.root / "new" / "a.txt").write_text("one", encoding="utf-8")
        second = guard.real_signature(self.root)
        self.assertNotEqual(first, second)
        (self.root / "new" / "a.txt").write_text("one and two", encoding="utf-8")
        third = guard.real_signature(self.root)
        self.assertNotEqual(second, third)
        (self.root / "new" / "b.txt").write_text("more", encoding="utf-8")
        self.assertNotEqual(third, guard.real_signature(self.root))

    def test_nothing_changing_leaves_it_alone(self):
        (self.root / "a.txt").write_text("one", encoding="utf-8")
        self.assertEqual(guard.real_signature(self.root), guard.real_signature(self.root))


if __name__ == "__main__":
    unittest.main()
