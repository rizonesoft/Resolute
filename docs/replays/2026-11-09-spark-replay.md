# Spark replay, 2026-11-09

Known-answer replay for the Spark route: dummy-work briefs run on `muse-spark-1.3` at medium effort through the saved workflow at `.agents/workflows/spark.js`, checked against answers computed by command before the run.
True mechanical work (counts, claim re-measurement, plan stats, validation) is not part of this route: the lead runs the repository scripts for those and gives them to no model.
The first run below was recorded at low effort; the medium re-run that follows it is the qualifying replay for the current pin, and `scripts/verify-agent-tiers.py` requires this file to record medium effort.

## The briefs and what came back

Inventory brief: how many top-level `*.py` files are in `scripts/`, what version is pinned for ninja in `toolchain.json`, and what files are in `.claude/agents/`.

Expected, computed first: 15 Python files; ninja 1.13.2; `delegate-check.md` and `delegate-research.md`.

Spark returned all three exactly, with `toolchain.json:46` cited for the version.

Extract brief: the python component's name and version values in `toolchain.json`, exactly as written, with the reference.

Expected: `"name": "python"` and `"version": "3.14.10"`.

Spark returned `name: python @ toolchain.json:59` and `version: 3.14.10 @ toolchain.json:60`. Exact.

Runner brief: the first line of `git log --oneline -1`, and the output of `reskit\python\python.exe --version`.

Expected: `2c9f761b tooling: pin the interpreters, cap the build, share the deps`, and `Python 3.14.10`.

Spark returned both exactly, each with the command that produced it.

## Medium re-run, 2026-11-09

A fresh low-effort test earlier the same day returned a wrong recursive count (5 for `todo/*/TODO-*.md`, true value 30) while reporting complete, so the contract was changed before the re-run: a spark never computes a count itself, it runs a command and quotes that command in the evidence string.
Three fresh briefs then ran at medium effort, with ground truth computed by command first.

Count brief: how many files match `todo/*/TODO-*.md`, produced only by running a command quoted in the evidence.

Expected: 30, computed by Python `glob` and corroborated by PowerShell and by `todo-graph.py query stats`.

Spark returned `30 files via Get-ChildItem -Path todo/*/TODO-*.md | Measure-Object | Select-Object -ExpandProperty Count`. Exact, with the producing command named.

Extract brief: the cmake name and version and the ninja version in `toolchain.json`, exactly as written.

Expected: `"name": "cmake"` at line 31, `"version": "4.4.3"` at line 32, `"version": "1.13.2"` at line 46.

Spark returned all three exactly, each with its line.

Locate-and-run brief: the line of `class Section:` in `scripts/todo-graph.py`, and the output of `git log --oneline -1`.

Expected: line 142, and `2c9f761b tooling: pin the interpreters, cap the build, share the deps`.

Spark returned both exactly, and the workflow report itself recorded `"effort": "medium"`.

## Routing hardening re-run, 2026-11-09

Two routing failures were then closed in `spark.js` itself, rather than left as prose: a judgment screen (`isJudgmentBrief`) refuses a judgment-bearing brief before any agent spawns, and a cited-source check (`isCitedSource`) drops evidence whose source is not a `file:line` or a `command:` citation and reports the task incomplete.
A test run at medium effort carried two dummy briefs and one judgment probe in a single call.

Dummy briefs: extract `SPARK_MODEL_PIN` and `SPARK_EFFORT_PIN` from `scripts/verify-agent-tiers.py`, and run `git log --oneline -1`.

Spark returned `SPARK_MODEL_PIN = "muse-spark-1.3"` at line 89, `SPARK_EFFORT_PIN = "medium"` at line 90, and `9727a8fd workspace: route dummy work to Spark at medium effort` with source `command: git log --oneline -1`.
The lead verified each by opening the cited lines and re-running the quoted command, as the routing gate requires. All exact.

Judgment probe: find the relevant code for settings loading and assess whether it is correct.

No agent spawned for it (two agents ran, not three). The workflow returned it with `ref: null`, no evidence, and the unresolved item `judgment-bearing brief refused before spawn`, and reported the whole run `partial` rather than complete.

## Verdict

Three briefs at low effort, seven facts, no errors; then three fresh briefs at medium effort, six facts, no errors, no unresolved items, and no prose beyond the evidence strings.
That is the no-loss showing for the dummy-work classes Spark exists for: locating, extracting, and running named read-only commands, with any count produced by a quoted command rather than by the model.
It says nothing about judgment work, which stays off Spark by contract: sparks never write, never review, and never decide, and the lead verifies every returned fact it acts on.
True mechanical work stays off every model: the lead runs `scripts/todo-graph.py`, `scripts/todo-claims.py`, and the other gates directly.

## Cost shape

The point of the route is where the tokens land.
A spark child starts from a short brief and returns a bounded evidence list, so the expensive model's context carries a few lines instead of the raw file reads and command output the brief took to produce.
Batching matters as much as the model: one brief carrying three related questions cost one spawn, and the three briefs above ran in parallel in about 25 seconds of wall time.
