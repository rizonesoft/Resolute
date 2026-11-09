# Ember head-to-head replay, 2026-11-09

Head-to-head replay for the Ember tier: identical expanded briefs run on `muse-ember-1.0` at medium effort and on `muse-spark-1.3` at medium effort, checked against answers computed by command before the run.
The brief set includes the count-with-quoted-command brief that caught Spark at low effort in the Spark replay.
Ground truth, computed first: 30 files match `todo/*/TODO-*.md`; `toolchain.json` holds `"name": "cmake"` at line 31, `"version": "4.4.3"` at line 32, `"name": "ninja"` at line 45, `"version": "1.13.2"` at line 46; `python scripts/verify-agent-tiers.py --self-test` prints `verify-agent-tiers self-test: 22 cases, 0 failed`; `git log --oneline -1` prints `e34b6c74 workspace: harden Spark routing, drop Haiku route for now`; `SPARK_MODEL_PIN = "muse-spark-1.3"` sits at `scripts/verify-agent-tiers.py:89`, `class Section:` at `scripts/todo-graph.py:142`, and the `EFFORTS` assignment at `scripts/review-dispatch.py:38`.

## Results

Count brief (produce the number only by running a command, cited as the source): Ember returned 30 with a quoted command; Spark returned 30 with a quoted command. Both exact.

Single-file extract brief (`toolchain.json` only, cmake and ninja name and version): Ember returned all four values at lines 31, 32, 45, 46; Spark returned all four at the same lines. Both exact.

Named-command brief (run the verifier self-test and `git log --oneline -1`, report exact output): Ember returned both output lines exactly with `command:` citations; Spark returned both exactly. Both exact.

Multi-file locate brief (one named assignment or definition in each of three files): Ember returned all three at lines 89, 142, and 38; Spark returned all three at the same lines. Both exact.

Ten facts per model, ten exact per model, no errors and no unresolved items on either side.
Ember was also the faster side on this set (about 9 to 10 seconds per brief against about 10 to 16 for Spark), which is noted but is not the basis for adoption; exactness is.

## Adoption scope

Ember is adopted for the narrow classes only: a single named read-only command (`kind: "command"`), and extraction from a single named file (`kind: "extract"` with exactly one file named in the brief).
It earned those classes here; it did not earn batched or multi-file work, even though it passed the multi-file brief in this run, because one run is a thinner record than Spark holds.
Batched briefs and multi-file locating stay on Spark until Ember has a longer record.
The routing lives in `.agents/workflows/spark.js`: a task sets `route: "ember"` with its kind, `isNarrowEmberTask` refuses Ember anything wider, and `scripts/verify-agent-tiers.py` pins `EMBER_MODEL` and `EMBER_EFFORT` and requires this replay.

## Auto-escalation

An Ember task that comes back incomplete, with dropped evidence, or with anything unresolved is retried once on Spark inside the same workflow run and reported with `escalatedFrom` set, so a misbehaving cheap attempt upgrades the route in the run rather than returning subpar evidence to the lead.
The lead still verifies every returned fact against its cited source before acting on it, whichever tier produced it.

## Wired test, 2026-11-09

One run of the wired workflow carried five tasks.
An Ember command task and an Ember single-file extract task both completed on `muse-ember-1.0` with exact facts and cited sources.
An Ember extract task naming a file that does not exist came back incomplete and was auto-escalated: the final entry shows model `muse-spark-1.3` with `escalatedFrom: muse-ember-1.0` and the Spark attempt correctly reporting the file absent.
A task routed to Ember but naming two files was served by Spark directly, never by Ember, and completed exactly.
The fifth task exposed a defect in the workflow itself: a batched Spark brief naming `scripts/review-dispatch.py` was refused by the judgment screen, because the file name contains the word review.
The lead treated that as a misbehaving mechanic under the orchestrator autonomy rule, tightened `isJudgmentBrief` in the same session to screen the brief's prose rather than its path tokens, and retested: the same batched brief then completed on Spark with both facts exact, while the judgment probe in the same run was still refused with no agent spawned.
