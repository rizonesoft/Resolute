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

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lib"))

import run_guard as guard  # noqa: E402


class World:
    """Stands in for the machine: rows, the tree, sessions and what gets spawned."""

    def __init__(self, rows=("D01 T02 §4",), signature="one", alive=(), live=(), child=False, reviewing=False):
        self.rows, self.sig, self.live, self.child, self.reviewing = rows, signature, list(live), child, reviewing
        self.alive = set(alive)
        self.spawned = []

    def env(self):
        return guard.Env(
            rows=lambda: None if self.rows is None else list(self.rows),
            signature=lambda: self.sig,
            alive=lambda s: s in self.alive,
            live_here=lambda: self.live,
            child_alive=lambda c: self.child,
            spawn=lambda s: self.spawned.append(dict(s)) or {"pid": 1, "started": 2},
            reviewing=lambda: self.reviewing,
        )


def active(**extra):
    return {"active": True, "status": "active", "session_id": "me", **extra}


class Prompts(unittest.TestCase):
    def test_process_plan_switches_the_run_on_in_each_spelling(self):
        for prompt in ("process plan", "/process-plan", "Process the plan", "process plan."):
            state = {}
            note = guard.on_prompt(state, {"prompt": prompt, "session_id": "me", "permission_mode": "acceptEdits"}, World().env())
            self.assertTrue(state.get("active"), prompt)
            self.assertEqual(state["permission_mode"], "acceptEdits")
            self.assertIn("CronCreate", note)

    def test_please_also_starts_it(self):
        state = {}
        guard.on_prompt(state, {"prompt": "please process the plan", "session_id": "me"}, World().env())
        self.assertTrue(state["active"])

    def test_a_missing_watchdog_is_said_when_the_run_starts(self):
        env = World().env()
        env.task_installed = lambda: False
        self.assertIn("run-guard.py install", guard.on_prompt({}, {"prompt": "process plan", "session_id": "me"}, env))

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
        state = active(restarts=2)
        guard.on_prompt(state, {"prompt": "process plan", "session_id": "new"}, World().env())
        self.assertEqual(state["session_id"], "new")
        self.assertEqual(state["restarts"], 2)


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
            guard.start(state, "other", None, World(alive=["me"]).env())
        self.assertEqual(state["session_id"], "me")
        guard.start(state, "other", "acceptEdits", World().env())
        self.assertEqual((state["session_id"], state["permission_mode"]), ("other", "acceptEdits"))

    def test_start_will_not_take_a_run_the_watchdog_resumed(self):
        state = active(child={"pid": 1, "started": 2})
        with self.assertRaises(ValueError):
            guard.start(state, "other", None, World(child=True).env())
        self.assertEqual(state["session_id"], "me")

    def test_start_keeps_the_launcher_and_a_start_without_one_forgets_it(self):
        state = {}
        guard.start(state, "me", "bypassPermissions", World().env(), {"pid": 7, "started": 8})
        self.assertEqual(state["launcher"], {"pid": 7, "started": 8})
        guard.start(state, "me", "bypassPermissions", World().env())
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


class Watch(unittest.TestCase):
    def test_nothing_starts_without_an_active_run(self):
        world = World()
        self.assertEqual(guard.watch({}, world.env()), "inactive")
        self.assertEqual(world.spawned, [])

    def test_never_beside_a_live_session_even_an_unrelated_one(self):
        world = World(live=["someone"])
        self.assertIn("someone", guard.watch(active(), world.env()))
        self.assertEqual(world.spawned, [])

    def test_never_beside_the_session_it_already_resumed(self):
        world = World(child=True)
        guard.watch(active(child={"pid": 1, "started": 2}), world.env())
        self.assertEqual(world.spawned, [])

    def test_never_while_the_launcher_that_restarts_the_session_is_alive(self):
        world = World(child=True)
        state = active(launcher={"pid": 7, "started": 8})
        self.assertIn("launcher", guard.watch(state, world.env()))
        self.assertEqual(world.spawned, [])
        world.child = False
        self.assertIn("attempt 1", guard.watch(state, world.env()))

    def test_never_while_a_review_is_in_flight(self):
        world = World(reviewing=True)
        state = active()
        self.assertEqual(guard.watch(state, world.env()), "review in flight")
        self.assertEqual((world.spawned, state.get("restarts", 0)), ([], 0))

    def test_a_dead_session_resumes_once_a_tick(self):
        world, state = World(), active()
        self.assertIn("attempt 1", guard.watch(state, world.env()))
        self.assertEqual(len(world.spawned), 1)
        self.assertEqual(state["child"], {"pid": 1, "started": 2})

    def test_resumes_that_change_nothing_stall_and_progress_resets_them(self):
        world, state = World(), active()
        for _ in range(guard.MAX_RESTARTS):
            guard.watch(state, world.env())
        self.assertEqual(guard.watch(state, world.env()), "stalled")
        self.assertEqual(len(world.spawned), guard.MAX_RESTARTS)
        self.assertFalse(state["active"])
        world, state = World(), active()
        for turn in range(guard.MAX_RESTARTS * 3):
            world.sig = str(turn)
            guard.watch(state, world.env())
        self.assertTrue(state["active"])

    def test_a_plan_with_nothing_left_finishes_instead_of_resuming(self):
        world, state = World(rows=()), active()
        self.assertEqual(guard.watch(state, world.env()), "drained")
        self.assertEqual(world.spawned, [])

    def test_a_run_walked_away_from_expires_instead_of_resuming(self):
        world, state = World(), active(restart_signature="one", changed_at=1000.0)
        self.assertEqual(guard.watch(state, world.env(), now=1000.0 + guard.MAX_QUIET_HOURS * 3600), "expired")
        self.assertEqual(world.spawned, [])
        self.assertFalse(state["active"])

    def test_a_change_keeps_a_run_from_expiring(self):
        world, state = World(signature="two"), active(restart_signature="one", changed_at=1000.0)
        self.assertIn("attempt 1", guard.watch(state, world.env(), now=1000.0 + guard.MAX_QUIET_HOURS * 3600))

    def test_a_hung_resumed_session_is_reported_and_left_alone(self):
        world, state = World(child=True), active(child={"pid": 7, "started": 2}, restart_signature="one", changed_at=1000.0)
        self.assertEqual(guard.watch(state, world.env(), now=1000.0 + guard.CHILD_HANG_HOURS * 3600), "stalled")
        self.assertIn("left running", state["why"])
        self.assertEqual(world.spawned, [])

    def test_a_quiet_session_that_crashed_does_not_condemn_its_replacement(self):
        world, state = World(), active(restart_signature="one", changed_at=1000.0)
        launched = 1000.0 + guard.CHILD_HANG_HOURS * 3600 + 60
        self.assertIn("attempt 1", guard.watch(state, world.env(), now=launched))
        world.child = True
        self.assertEqual(guard.watch(state, world.env(), now=launched + 600), "resumed session still running")
        self.assertTrue(state["active"])
        self.assertEqual(guard.watch(state, world.env(), now=launched + guard.CHILD_HANG_HOURS * 3600), "stalled")

    def test_not_knowing_who_is_alive_starts_nothing(self):
        world, state = World(), active()
        env = world.env()

        def unknown():
            raise OSError("cannot tell")

        env.live_here = unknown
        with self.assertRaises(OSError):
            guard.watch(state, env)
        self.assertEqual(world.spawned, [])

    def test_the_resume_uses_the_operators_own_mode_and_no_wider(self):
        command = guard.resume_command(active(permission_mode="acceptEdits"), "claude")
        self.assertEqual(command, ["claude", "-p", "process plan", "--resume", "me", "--permission-mode", "acceptEdits"])
        self.assertNotIn("--permission-mode", guard.resume_command(active(), "claude"))
        self.assertNotIn("--dangerously-skip-permissions", " ".join(command))

    def test_a_resume_that_changed_nothing_is_followed_by_a_fresh_session(self):
        self.assertFalse(guard.wants_fresh(active()))
        self.assertTrue(guard.wants_fresh(active(restarts=1)))
        self.assertTrue(guard.wants_fresh({"active": True}))
        fresh = guard.resume_command(active(permission_mode="bypassPermissions", restarts=1), "claude", "new-id")
        self.assertEqual(fresh, ["claude", "-p", "process plan", "--session-id", "new-id", "--permission-mode", "bypassPermissions"])

    def test_a_fresh_session_owns_the_run_under_the_id_it_was_started_with(self):
        world, state = World(), active(restarts=1)
        env = world.env()
        env.spawn = lambda s: {"pid": 1, "started": 2, "session_id": "new-id"}
        guard.watch(state, env)
        self.assertEqual(state["session_id"], "new-id")
        self.assertIn("Do not stop", guard.on_stop(state, {"session_id": "new-id"}, world.env()))

    def test_a_resumed_or_fresh_session_keeps_what_the_launcher_started_the_run_with(self):
        launch = {"model": "claude-fable-5-2", "disallowed": ["AskUserQuestion"], "goal": "/goal finish the plan"}
        state = active(permission_mode="bypassPermissions", launch=launch)
        tail = ["--permission-mode", "bypassPermissions", "--model", "claude-fable-5-2", "--disallowedTools", "AskUserQuestion"]
        self.assertEqual(guard.resume_command(state, "claude"), ["claude", "-p", "process plan", "--resume", "me", *tail])
        self.assertEqual(guard.resume_command(state, "claude", "new-id"), ["claude", "-p", "/goal finish the plan", "--session-id", "new-id", *tail])


class Admission(unittest.TestCase):
    """`start` is the one way a launcher's session gets to write."""

    def test_a_stop_given_while_the_launcher_waited_is_not_undone_by_its_restart(self):
        state = active()
        guard.halt(state, "operator", "stopped from the launcher (-Stop)")
        with self.assertRaises(ValueError) as refused:
            guard.start(state, "next", "bypassPermissions", World().env(), {"pid": 7, "started": 8}, restart=True)
        self.assertIn("no longer active", str(refused.exception))
        self.assertEqual((state["status"], state["session_id"]), ("halted", "me"))
        guard.start(state, "next", "bypassPermissions", World().env(), {"pid": 7, "started": 8})  # the operator starting again
        self.assertTrue(state["active"])

    def test_a_restart_continues_a_run_that_is_still_active(self):
        state = active(restarts=1, restart_signature="one", launcher={"pid": 7, "started": 8})
        guard.start(state, "next", "bypassPermissions", World(child=True).env(), {"pid": 7, "started": 8}, restart=True)
        self.assertEqual((state["session_id"], state["restarts"]), ("next", 2))  # counted as an attempt, like the watchdog's

    def test_a_second_launcher_is_refused_while_the_first_is_alive(self):
        state = {}
        guard.start(state, "one", None, World().env(), {"pid": 7, "started": 8})
        with self.assertRaises(ValueError) as refused:
            guard.start(state, "two", None, World(child=True).env(), {"pid": 9, "started": 10})
        self.assertIn("a launcher (process 7) holds this run", str(refused.exception))
        self.assertEqual(state["session_id"], "one")
        guard.start(state, "two", None, World().env(), {"pid": 9, "started": 10})  # the first launcher has gone
        self.assertEqual(state["launcher"], {"pid": 9, "started": 10})

    def test_a_review_in_flight_refuses_a_start(self):
        with self.assertRaises(ValueError) as refused:
            guard.start({}, "me", None, World(reviewing=True).env())
        self.assertIn("review is in flight", str(refused.exception))

    def test_another_open_session_refuses_a_start_unless_the_operator_accepted_it(self):
        state = {}
        with self.assertRaises(ValueError) as refused:
            guard.start(state, "me", None, World(live=["other"]).env())
        self.assertIn("other", str(refused.exception))
        self.assertEqual(state, {})
        guard.start(state, "me", None, World(live=["other"]).env(), open_ok=True)
        self.assertTrue(state["active"])
        with self.assertRaises(ValueError):  # a restart is nobody at the keyboard, so it never carries the acceptance
            guard.start(state, "next", None, World(live=["other"]).env(), restart=True)
        guard.start(state, "me", None, World(live=["me"]).env())  # the session itself is not another session

    def test_a_prompt_in_another_session_cannot_take_a_run_a_launcher_has_reserved(self):
        # The launcher has been admitted and its Claude process has not registered yet, so the owner is not "alive".
        state = {}
        guard.start(state, "reserved", "bypassPermissions", World().env(), {"pid": 7, "started": 8})
        world = World(child=True)  # the launcher is alive
        note = guard.on_prompt(state, {"prompt": "process plan", "session_id": "intruder"}, world.env())
        self.assertIn("launcher", note)
        self.assertEqual(state["session_id"], "reserved")
        self.assertIn("Unattended run guard is active", guard.on_prompt(state, {"prompt": "process plan", "session_id": "reserved"}, world.env()))

    def test_a_prompt_cannot_take_a_run_while_a_review_is_in_flight_or_the_watchdogs_session_works(self):
        for world, state, word in ((World(reviewing=True), active(), "review"), (World(child=True), active(child={"pid": 1, "started": 2}), "watchdog")):
            note = guard.on_prompt(state, {"prompt": "process plan", "session_id": "intruder"}, world.env())
            self.assertIn(word, note)
            self.assertEqual(state["session_id"], "me")
        fresh = {}
        self.assertIn("review", guard.on_prompt(fresh, {"prompt": "process plan", "session_id": "me"}, World(reviewing=True).env()))
        self.assertEqual(fresh, {})

    def test_restarts_that_change_nothing_end_the_run_however_far_apart_they_are(self):
        state = {}
        launcher = {"pid": 7, "started": 8}
        guard.start(state, "s0", None, World().env(), launcher)
        for attempt in range(1, guard.MAX_RESTARTS + 1):
            guard.start(state, f"s{attempt}", None, World(child=True).env(), launcher, restart=True)
            self.assertEqual(state["restarts"], attempt)
        with self.assertRaises(ValueError) as refused:
            guard.start(state, "one-too-many", None, World(child=True).env(), launcher, restart=True)
        self.assertIn("stalled", str(refused.exception))
        self.assertEqual((state["active"], state["status"]), (False, "stalled"))

    def test_a_restart_after_progress_starts_the_count_again(self):
        state = {}
        launcher = {"pid": 7, "started": 8}
        guard.start(state, "s0", None, World().env(), launcher)
        for _ in range(guard.MAX_RESTARTS):
            guard.start(state, "again", None, World(child=True).env(), launcher, restart=True)
        guard.start(state, "after-work", None, World(child=True, signature="a commit landed").env(), launcher, restart=True)
        self.assertEqual((state["active"], state["restarts"]), (True, 1))

    def test_what_the_session_was_started_with_is_kept(self):
        state = {}
        guard.start(state, "me", None, World().env(), launch={"model": "m", "disallowed": ["AskUserQuestion"], "goal": "g"})
        guard.start(state, "next", None, World().env(), restart=True)
        self.assertEqual(state["launch"], {"model": "m", "disallowed": ["AskUserQuestion"], "goal": "g"})


class SlowSignIn(unittest.TestCase):
    """The sign-in can take a minute. It is fetched before the lock, so a stop never waits behind it."""

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.path = Path(self.temp.name) / "state.json"
        self.path.write_text(json.dumps(active()), encoding="utf-8")

    def env(self, world, prepare):
        env = world.env()
        env.spawn = lambda state, prepared=None: world.spawned.append(prepared) or {"pid": 1, "started": 2}
        env.prepare = prepare
        return env

    def test_a_stop_gets_in_while_the_sign_in_is_fetched_and_then_nothing_is_started(self):
        world = World()

        def prepare():
            with guard.locked(self.path, wait=1):  # the lock is free while this runs
                state = guard.load(self.path)
                guard.halt(state, "operator", "stopped while 1Password was asked")
                guard.save(state, self.path)
            return ({"CLAUDE_CODE_OAUTH_TOKEN": "x"}, "the one-year token from 1Password")

        self.assertEqual(guard.watch_tick(self.env(world, prepare), self.path), "inactive")
        self.assertEqual(world.spawned, [])
        self.assertEqual(guard.load(self.path)["status"], "halted")

    def test_the_session_is_started_with_what_was_fetched(self):
        world = World()
        fetched = ({"CLAUDE_CODE_OAUTH_TOKEN": "x"}, "the one-year token from 1Password")
        self.assertIn("resumed", guard.watch_tick(self.env(world, lambda: fetched), self.path))
        self.assertEqual(world.spawned, [fetched])

    def test_the_vault_is_not_asked_on_a_tick_that_starts_nothing(self):
        asked = []
        for world in (World(live=["someone"]), World(reviewing=True), World(rows=())):
            self.path.write_text(json.dumps(active()), encoding="utf-8")
            guard.watch_tick(self.env(world, lambda: asked.append(1)), self.path)
        self.assertEqual(asked, [])


class Stuck(unittest.TestCase):
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

    def test_only_a_silent_session_of_an_active_run_with_no_review_is_stuck(self):
        env = World().env()
        self.assertTrue(guard.owner_stuck(active(), env, guard.QUIET_LIMIT))
        self.assertFalse(guard.owner_stuck(active(), env, guard.QUIET_LIMIT - 1))
        self.assertFalse(guard.owner_stuck(active(), env, None))
        self.assertFalse(guard.owner_stuck(active(), World(reviewing=True).env(), 500))
        self.assertFalse(guard.owner_stuck({"active": False, "session_id": "me"}, env, 500))

    def test_a_stuck_session_is_ended_and_a_working_one_is_left_alone(self):
        ended = []
        long_ago = time.time() - (guard.QUIET_LIMIT + 5) * 60
        said = guard.replace_stuck(active(session_id="never-wrote"), World().env(), long_ago, kill=ended.append, process=lambda s: 4242)
        self.assertEqual(ended, [4242])
        self.assertIn("replaced", said)
        said = guard.replace_stuck(active(session_id="never-wrote"), World().env(), time.time(), kill=ended.append, process=lambda s: 4242)
        self.assertEqual((ended, said.startswith("working")), ([4242], True))
        said = guard.replace_stuck(active(session_id="never-wrote"), World(reviewing=True).env(), long_ago, kill=ended.append, process=lambda s: 4242)
        self.assertEqual(ended, [4242])


class SignIn(unittest.TestCase):
    TOKEN = "sk-ant-oat01-" + "a" * 60

    def test_the_resumed_session_gets_the_token_when_the_vault_gives_it(self):
        env, how = guard.sign_in({"PATH": "x"}, lambda: self.TOKEN, lambda: None)
        self.assertEqual(env, {"PATH": "x", "CLAUDE_CODE_OAUTH_TOKEN": self.TOKEN})
        self.assertIn("1Password", how)
        self.assertNotIn(self.TOKEN, how)

    def test_a_locked_vault_falls_back_to_the_cache_and_the_vault_wins_when_both_answer(self):
        other = "sk-ant-oat01-" + "b" * 60
        env, how = guard.sign_in({}, lambda: None, lambda: self.TOKEN)
        self.assertEqual(env["CLAUDE_CODE_OAUTH_TOKEN"], self.TOKEN)
        self.assertIn("cache", how)
        self.assertEqual(guard.sign_in({}, lambda: other, lambda: self.TOKEN)[0]["CLAUDE_CODE_OAUTH_TOKEN"], other)

    def test_no_token_or_a_value_of_the_wrong_shape_leaves_the_stored_login(self):
        for value in (None, "", "ERROR: not signed in", self.TOKEN + " trailing words"):
            env, how = guard.sign_in({"PATH": "x"}, lambda: value, lambda: value)
            self.assertEqual(env, {"PATH": "x"}, value)
            self.assertIn("stored login", how)

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
            read = subprocess.run(
                ["pwsh", "-NoProfile", "-Command",
                 "[Text.Encoding]::UTF8.GetString([System.Security.Cryptography.ProtectedData]::Unprotect("
                 f"[IO.File]::ReadAllBytes('{path}'), $null, 'CurrentUser'))"],
                capture_output=True, text=True, timeout=60)
            self.assertEqual(read.stdout.strip(), self.TOKEN, read.stderr)


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
            self.assertEqual(len(guard.reviews_in_flight(self.folder)), 1)
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

    def test_status_says_when_a_tick_failed_or_has_gone_quiet(self):
        env = World().env()
        unseen = guard.health(active(), self.path, env, now=1000.0)
        self.assertTrue(unseen["last_tick_stale"])
        guard.record_tick("OSError('no')", False, self.path)
        failed = guard.health(active(), self.path, env)
        self.assertFalse(failed["last_tick"]["ok"])
        self.assertTrue(failed["last_tick_stale"])
        guard.record_tick("inactive", True, self.path)
        self.assertFalse(guard.health(active(), self.path, env)["last_tick_stale"])
        self.assertTrue(guard.health(active(), self.path, env, now=time.time() + guard.WATCH_MINUTES * 60 * 4)["last_tick_stale"])

    def test_the_cron_tool_records_the_heartbeat(self):
        self.path.write_text(json.dumps(active()), encoding="utf-8")
        self.event(hook_event_name="PostToolUse", tool_name="CronCreate", session_id="me")
        self.assertIn("heartbeat_at", guard.load(self.path))

    def test_a_stop_gets_in_while_a_tick_does_its_slow_reads(self):
        self.path.write_text(json.dumps(active()), encoding="utf-8")
        reading, release = threading.Event(), threading.Event()
        world = World()
        env = world.env()

        def slow_rows():
            reading.set()
            release.wait(10)
            return ["D01 T02 §4"]

        env.rows = slow_rows
        results = []
        tick = threading.Thread(target=lambda: results.append(guard.watch_tick(env, self.path)))
        tick.start()
        self.assertTrue(reading.wait(5))
        self.event(hook_event_name="UserPromptSubmit", prompt="stop", session_id="me")
        release.set()
        tick.join(10)
        self.assertEqual(results, ["inactive"])
        self.assertEqual(world.spawned, [])
        self.assertEqual(guard.load(self.path)["status"], "stopped")

    def test_a_failed_launch_uses_no_attempt_and_its_error_stays_until_one_works(self):
        self.path.write_text(json.dumps(active()), encoding="utf-8")
        world = World()
        env = world.env()

        def fails(_state):
            raise OSError("claude is not on PATH")

        broken = guard.replace(env, spawn=fails)
        for _ in range(guard.MAX_RESTARTS + 2):
            with self.assertRaises(OSError):
                guard.watch_tick(broken, self.path)
        state = guard.load(self.path)
        self.assertTrue(state["active"])
        self.assertEqual(state.get("restarts", 0), 0)
        self.assertIn("not on PATH", state["last_error"])
        self.assertIn("attempt 1", guard.watch_tick(env, self.path))
        self.assertNotIn("last_error", guard.load(self.path))


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
