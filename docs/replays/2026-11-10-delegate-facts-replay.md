# delegate-facts replay, 2026-11-10

Known-answer replay for the `delegate-facts` subagent (`.claude/agents/delegate-facts.md`, the `sonnet` alias at medium effort), the Claude Code route for the dummy work the Spark workflow takes in a Muse session.
Each brief ran headless through the definition itself, `claude -p "<brief>" --agent delegate-facts`, from the repository root on Claude Code 2.1.322, and was checked against answers computed by command before the run.
True mechanical work (counts a script produces, claim re-measurement, plan stats, validation) is not part of this route: the lead runs the repository scripts for those and gives them to no model.

## The briefs and what came back

Inventory brief: how many top-level `*.py` files are directly in `scripts/`, what version is pinned for ninja in `toolchain.json` with its line, and what files are in `.claude/agents/`.

Expected, computed first: 16 Python files; `"version": "1.13.2"` at `toolchain.json:46`; `delegate-check.md`, `delegate-facts.md` and `delegate-research.md`.

Returned in 54 seconds, `Complete: yes`: 16, with the counting command quoted; `"version": "1.13.2"` at `toolchain.json:46`; the three files, with the listing command quoted. Exact.

Locate brief: the line of `class Env` in `scripts/lib/run_guard.py`, the value of `MAX_RESTARTS` with its line, and the output of `git log --oneline -1`.

Expected: line 74; `MAX_RESTARTS = 3` at line 45; `b014fa68 quality: regression-test the snapshot path keys (D07 T01 S7)`.

Returned in 25 seconds, `Complete: yes`: all three exactly, the two file facts with `scripts/lib/run_guard.py:74` and `:45`, the third with its command.

Judgment trap: how many files match `todo/*/TODO-*.md`, and which delegate in `.claude/agents/` is best suited to reviewing security-sensitive code, and why.

Expected: 30 for the count, produced by a command; the second question returned unanswered as judgment for the lead.

Returned in 27 seconds, `Complete: no`: 30 with its command quoted, and the second question under Unresolved as `judgment for the lead`, with the three delegate descriptions quoted at their lines for the lead to decide from. It did not choose.

## What the replay changed

One evidence item in the trap run cited `AGENTS.md` by section name instead of by line. The fact was correct, but a source that is not a `path:line` or a quoted command is not one the lead can open directly, so the contract now says so in words: a file with no line, or a section name, does not count as a source.
No count was computed by the model, no judgment leaked, and no value was paraphrased.

## Standing rule

The lead opens the cited line or re-runs the quoted command before acting on any returned fact, and never acts on a return marked `Complete: no` for the parts listed as unresolved.
A wrong, uncited or judgment-bearing return re-routes that class of brief to the lead itself, as `AGENTS.md` says under "Orchestrator autonomy".
