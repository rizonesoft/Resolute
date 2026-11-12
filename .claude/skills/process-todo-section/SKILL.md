---
name: process-todo-section
description: Process exactly one TODO section end to end. Resolve it, validate and fact-check the plan against the repository, correct every drifted claim, build it, run the gates, hand to review, and commit. Use whenever asked to process, implement, ship, continue, or finish a TODO section.
---

# Process TODO Section

The section is the contract, and a contract is checked before it is signed.

Processing a section is two jobs, in order. First establish that the plan is sound: internally consistent, still true of the code and of its governing documents, buildable as written, and verifiable when built. Then implement it. Do not improvise around the plan, and do not implement a plan you have found to be wrong. Correct it in the file, visibly, then build the corrected version.

## Use this skill when

- The user names a section in any form: a `DNN TNN §N` reference, a path plus section, or a row pasted straight out of `todo/implementation-plan.md`. Step 0 turns all of them into the same thing.
- A runner picks the next ready row from the plan.
- Do not use it to audit shipped work: that is `review-todo-section` in audit stance.

## Step 0: resolve the argument before anything else

Never hand-translate a reference into a filename. Ask the graph:

```powershell
python scripts/todo-graph.py resolve "$ARGUMENTS"
```

It prints the path, title, phase, needs, dependencies (met and unmet) and the section body. Its exit code is the instruction:

| Exit | Meaning | Do this |
| :-: | --- | --- |
| 0 | Open, dependencies met, no waiting Need | Proceed to step 1. |
| 1 | No such section | Stop; report the reference as unresolvable. |
| 2 | No section reference in the input | Stop and ask which section. |
| 3 | The section is already `[x]` | Hand to `review-todo-section` in audit stance. |
| 4 | Waiting on deps, file status, or person Need | Stop at the gate and name what it waits on. |

Use the printed `skill_arg` (`DNN TNN §N`) as the canonical form for the rest of the run, including the commit message and the review call.

If the section carries `Windows host (build/test)`, `Signing certificate`, `External device`, `Live service`, `Operator decision`, or `Upstream release` in Needs, confirm that environment or prerequisite is actually reachable before writing `Started:`. If it is not, stop and say what the section waits on: starting an environment-bound section without the environment burns a session producing nothing committable.

Before the first edit in a session, read `todo/README.md` (the format every TODO edit must keep). Before any write, stop here if another writer holds the tree. Check `git status` for unfamiliar uncommitted work you do not understand, and ask before building over it.

## Execution discipline

- **Validate before building.** Step 2 is a gate, not a formality.
- **Follow the corrected contract.** The checklist items define the scope. Adjacent wrongness gets filed with `add-todo`, not fixed in passing inside this section's work.
- **Commits follow logical steps.** A section may be committed in one or more commits as steps complete; review fix-loop commits append to the candidate range, never amend. Plan corrections ride with the section commits or land as their own `todo:` commit first when substantial.
- **Never mark `[x]` without evidence.** The Implementation Order row flips only when the `Verified:` stamp is written in `review-todo-section`. This skill never flips a row itself.
- **User systems first.** Atomic writes, readback, skip-and-report, confirmed destructive paths, and a reverse for every system change or an honest statement that there is none. The checkpoint exercises a failure path, not only the happy path.
- **One suite, one framework.** Shared behavior is consumed from `src/framework/` or `src/repair/`, never reimplemented in a tool. Every surface answers to `DESIGN.md` and `shared/resolute-ui`.

## Workflow

### 1. Read the whole contract

Read the entire TODO file, not just the section: Goal, Current state, Inputs and Adjacency carry context the section assumes. Read the sections this one depends on: their `Verified:` stamps tell you what actually shipped versus what was planned. Read the governing excerpts named in Inputs (`DESIGN.md`, `resolute_au3/` scripts, brainstorm records).

### 2. Validate the plan before building it

Eight questions, each answered against the repository and the governing documents rather than from memory:

| Check | What you are asking | The failure it catches |
| ----- | ------------------- | ---------------------- |
| Legitimacy | Does `DESIGN.md`, `resolute_au3/`, or the plan demand this? | Unwanted work invented by the plan |
| Currency | Do named files, classes, and APIs match? | Section pinned to a moved path |
| Consistency | Do items agree with Current state and deps? | Contradictory items in one file |
| Correctness | Do stated behaviors match `resolute_au3/` and `DESIGN.md`? | Stale behavior ported into code |
| Sufficiency | Can this build without inventing decisions? | Section becomes a design session |
| Verifiability | Can the checkpoint run and fail on fixtures? | Unfalsifiable checkpoint passes |
| Accuracy | Are paths, counts, refs, and deferrals true? | Authority citing moved facts |
| Excellence | Does it meet 1:1 behavioral parity and the `DESIGN.md` bar? | A port that drops behavior or quality |

Ground each answer: `python scripts/todo-graph.py validate`, `python scripts/todo-claims.py`, searches over `src/`, `shared/`, `extensions/`, and `tests/` for the named symbols, `git log --oneline -5 -- <touched paths>`. Check deferrals in both directions with `python scripts/todo-graph.py query deferred`: deferrals this section owns are part of its scope; deferrals this section wrote get re-read against today's tree.

Route the fetching, never the judging: counts, claim re-measurement, and plan stats are true mechanical work, so run the scripts above directly and give them to no model. Dummy work around them (locating a named symbol or file, extracting a quoted value, running a named read-only command, batched small lookups) goes to the `spark` workflow (`.agents/workflows/spark.js`) in Muse sessions: a single named command or a single-file extraction sets `route: "ember"` with its `kind` for `muse-ember-1.0` at medium effort, and batched or multi-file briefs go to `muse-spark-1.3` at medium effort in one batched brief. Before spawning, apply the routing gate in `AGENTS.md`: the brief must ask for a quotable fact that can carry a cited source (`file:line` or the exact producing command) and must need no choosing, assessing, or deciding what is relevant; a brief that fails is judgment, stays with the lead, and is never reworded past the `spark.js` judgment screen. After the run, act on a fact only after opening its cited line or re-running its quoted command, and never act on evidence from an incomplete or partial task. On a partial or failed run, do not relaunch from scratch: resume the Spark run so completed briefs replay, and pass the prior result references into one follow-up brief covering only the unresolved items. If a return is wrong, dropped, or leaks judgment, apply the orchestrator autonomy rule in `AGENTS.md`: re-route that class upward at once, tighten the mechanic that allowed the failure in the same session, and report the change.

Anything unclear becomes a question answered from the source (`resolute_au3/`, `DESIGN.md`, Win32 or wxWidgets documentation). Where the source is silent, take a justified default, record that it is a default with the cost of changing it, and carry on.

### 3. Correct the section when validation fails

Fix findings in the TODO file, before implementation, so plan and build never disagree in the record. Stale facts are corrected in place and marked `**Corrected YYYY-MM-DD:**` with what they said before. Contradictions resolve toward the source and the later decision. Unbuildable or coarse summary items are decomposed into concrete micro-steps with `Done when:` and `Cheaper substitute that fails the checkpoint:`. Items already 100% implemented in the codebase are ticked with the XREF, `file:line`, or commit SHA that shipped them; half-implemented items stay `[ ]` and are rewritten to name the exact missing pieces. Genuinely wrong work is struck with a stated reason, never silently dropped. An unfalsifiable checkpoint is rewritten so it can fail. A **frozen** behavior (`Ownership`, `ComIntRep`, `USBRepair`, `DVDRepair`, `PixRepair`, `BiosCodes`) that looks wrong is not changed in code or plan: record the question for the operator and continue around it. If the whole section is wrong, stop and report instead of implementing.

Correct the plan, never the goalpost: narrowing a section so the code you were about to write happens to satisfy it is fitting the contract to the implementation. Report every plan correction alongside the implementation. If step 2 finds nothing, say so in one line and move on.

### 3a. Plan review by the pinned reviewer (one pass, before any code)

Once the section is corrected, commit it (with `plan --sync`) so the reviewer reads the exact contract you will build, then have the pinned reviewer judge whether that contract produces a 100% complete feature. Write the prompt to a scratch file from `docs/plan-review-prompt.md`, then run (using `run_in_background`, which `scripts/dispatch_hook.py` enforces):

```powershell
python scripts/review-dispatch.py --kind plan --candidate <full SHA of that commit> --writer <claude|codex|gemini|muse|meta> --writer-model <exact-model-version> --prompt <scratch-plan-prompt.md> --record docs/reviews/<NN-domain>/D<NN>-T<NN>-s<N>.md
```

The dispatcher sets the effort (`medium`, never past `medium`) and the `plan` lens from the pin's `[schedule] plan` step and appends a `## Plan review` section; it is not a round and does not move the round schedule. Fix every `P1` and `P2` gap in the section the same way as step 3 (corrected in place, dated), and file a `P3` you do not take through `add-todo`. Under the plan review in the findings file, add one line per gap: `- Planned: <gap> in <commit>` or `- Filed: DNN TNN §N (<gap>)`. When the dispatcher exits 1, run the pass again before building.

Then write `Started:`: add `> **Started:** <current UTC instant>` directly under the section heading and commit it (with `plan --sync`) before the first line of the build.

### 4. Build the corrected contract

Work the micro-step checklist top to bottom. Tick each micro-step item as its `Done when:` becomes true, in the file, as you go; never tick a partially finished item (`partial-flip-shipped` is fatal). Write the failing test first where the section names one. Build the cheaper substitute's failure into the checkpoint so the wrong thing cannot pass. UI sections consume the shared controls from `shared/resolute-ui` and `src/framework/ui/` as specified in `DESIGN.md`.

Run gates while iterating, bounded to the touched area: the build for the touched targets, the affected test cases, and `clang-tidy` on the touched translation units. Warnings are errors at the configured level. Keep to the test cadence in `AGENTS.md`: no full suite while iterating, and one test case per behaviour that can really fail, not a matrix.

### 5. Surface and feature completeness

Before the checkpoint, account for 100% of every control, menu item, dialog and state on the Fidelity surface and `DESIGN.md` section: each is working (proven on the rendered surface with real data and read-back) or deferred to a named, resolving section (`python scripts/todo-graph.py resolve '<ref>'` must not exit 1 or 2). Confirm the refusal/error/recovery path and undo/restore path required by the section hold. After the commit, `review-todo-section` runs its rounds to a clean terminal round and then step 4 has the pinned reviewer run the one-pass completion and excellence review last on the built feature; every in-scope gap it finds is built in this section as a new repair cycle on a `-repair` record with its own plan pass, rounds, and completion.

### 6. Run the Test checkpoint, for real

Execute the checkpoint command and read the output. Quote the result in the commit body. If the checkpoint cannot run (no host, no fixture), the section is not done: record what ran, what did not and why, and stop without a stamp. Then run the section's other owed gates: affected tests green, build warnings clean, `python scripts/todo-graph.py validate` clean, `python scripts/todo-claims.py` clean, and the `**Freeze check:**` in frozen files.

### 7. Commit, then hand to review

Commit the section work (in one or more commits as steps complete), recording the checkpoint evidence in the final implementation commit body:

```text
<area>: <what now works> (<DNN TNN §N>)

<checkpoint output, quoted>
<plan corrections, if any>
```

Then invoke `review-todo-section` on the same ref. It runs the dispatcher's order: rounds to a clean terminal round first, then the one-pass completion and excellence review last (`scripts/review-dispatch.py --kind completion`): implement every in-scope gap and excellence item it lists in this section as a new repair cycle on a `-repair` record, and file the rest through `add-todo`. Review writes the `Verified:` and `Review:` stamp lines, flips the row, and syncs the plan. Commit the stamp and the regenerated plan as the stamp commit (`todo: stamp <ref>`).

### 8. Report

Tell the user plainly: what was built, what the checkpoint proved (quoted), what plan corrections were made, what was filed rather than fixed, and where the stamp stands.

## Guardrails

- Do not implement a section you judged wrong. Correct it or stop.
- Do not widen the section. File adjacent work through `add-todo`.
- Do not flip the Implementation Order row or write `Verified:` lines before `review-todo-section` completes.
- Do not claim a checkpoint passed without running it: quote the output.
- Do not build a UI surface that violates `DESIGN.md`.
- Do not end with the plan unsynced.
