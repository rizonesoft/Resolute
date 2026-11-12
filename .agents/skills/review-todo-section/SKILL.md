---
name: review-todo-section
description: Quality-gate a just-implemented TODO section with self-review, independent review lenses and a bounded fix loop, then write the Verified stamp and sync the plan. Also runs in audit stance on shipped sections. Use after process-todo-section or when asked whether a section is really done.
---

# Review TODO Section

The gate between "code exists" and "the row says `[x]`". Nothing else may flip that row, and the flip happens only when a section has no unticked items, no open prerequisite, no waiting Need, and full review evidence recorded in `docs/reviews/<NN-domain>/D<NN>-T<NN>-s<N>.md`.

Review is mandatory and independent: the implementing session self-reviews, and every review pass comes from the reviewer pinned in `.conclave/reviewers.toml` (a different model family from the writer: `argon` on `agy` when `--writer codex`, and `astra` on `codex` when `--writer claude|gemini|muse|meta`), run through `scripts/review-dispatch.py` with `--writer <claude|codex|gemini|muse|meta> --writer-model <exact-model-version>`. Reviewer effort is strictly capped at `medium` (`low` or `medium` only; `scripts/review-dispatch.py` refuses any effort above `medium`). The pin's `[schedule]` owns each pass's reasoning effort and lenses, so the writer never picks them: the plan review (`process-todo-section` step 3a) runs at `medium` with the `plan` lens, round 1 at `medium` with `adversarial` alone, every later round at `low` rotating through the pin's `rotation` lenses (up to `max_low_rounds = 32`; a low round that declares `HIGHEST: P1` escalates to `adversarial` at `low`), and final completion review at `medium`. Record the writer's decisions as settled items in the findings files (`- Filed: DNN TNN §N (...)` and `- Not taken: <item> (<reason>)` under the completion review or a `## Writer note: settled` heading): the dispatcher gives them to every reviewer, so a repeated one never keeps a loop running. A verdict with no record is an opinion.

## Use this skill when

- A section was just implemented (`process-todo-section` ends by invoking this).
- The user asks "is §N really done?", "re-verify §N", "audit §N": run in audit stance (below).
- Before closing a TODO file with `process-todo-file`.

## Step 0: resolve the argument

Same front door as `process-todo-section`: `python scripts/todo-graph.py resolve "$ARGUMENTS"`. Exit 3 means the row is already `[x]`: that is the signal for audit stance, not an error.

## The three questions

Every review answers these with code and behavior evidence, never assertion:

1. **Does it make sense?** Does the implementation produce the exact outcome the section asked for, without unnecessary scope?
2. **Is it logical?** Do the contracts agree: threading rules, error paths, settings consumers, UI states, failure behavior, restore/undo paths?
3. **Did it break anything else?** Inspect callers, consumers, tests and adjacent workflows that read what changed.

## Workflow

### 1. Fix the candidate

Name the candidate: the implementation commit, or the commit range (`<BASE_SHA>..<TIP_SHA>`) when the section landed across multiple logical step commits or when fix-loop commits append (commits are never amended once review starts). Record the full SHA(s) in the findings file at `docs/reviews/<NN-domain>/D<NN>-T<NN>-s<N>.md`. For an audit, the candidate is the section's own stamped commit plus every later change to the files it owns, up to today's tip (`<STAMPED_SHA>..HEAD -- <owned paths>`): a regression lives in those later changes. Read the actual diff (`git show` or `git diff <BASE_SHA>..<TIP_SHA>`), not memory of writing it. Map each ticked micro-step checklist item (its `Done when:` and `Cheaper substitute that fails the checkpoint:`) to the code and test that satisfy it; an item with no corresponding change or a partially met `Done when:` (`partial-flip-shipped`) is not done (untick it) or was already true (note where).

### 2. Self-review

Work the three questions across the diff and its blast radius. You may also run the read-only `delegate-check` subagent as self-review input (never as a lens verdict). Fix what you find, then re-ask them. Route the fetching, never the judging: stale-claim and count checks are true mechanical work, so run `scripts/todo-claims.py` and `scripts/todo-graph.py` directly and give them to no model; dummy work around them (locating callers, extracting a quoted value, batched small lookups) goes to the `spark` workflow (`.agents/workflows/spark.js`) in Muse sessions: a single named command or a single-file extraction sets `route: "ember"` with its `kind` for `muse-ember-1.0` at medium effort, and batched or multi-file briefs go to `muse-spark-1.3` at medium effort in one batched brief. Before spawning, apply the routing gate in `AGENTS.md`: the brief must ask for a quotable fact that can carry a cited source (`file:line` or the exact producing command) and must need no choosing, assessing, or deciding what is relevant; a brief that fails is judgment, stays with the lead, and is never reworded past the `spark.js` judgment screen. Spark output is self-review input only, never a lens verdict: act on a fact only after opening its cited line or re-running its quoted command, and never use evidence from an incomplete or partial task. On a partial or failed run, do not relaunch from scratch: resume the Spark run so completed briefs replay, and pass the prior result references into one follow-up brief covering only the unresolved items. If a return is wrong, dropped, or leaks judgment, apply the orchestrator autonomy rule in `AGENTS.md`: re-route that class upward at once, tighten the mechanic that allowed the failure in the same session, and report the change. Look specifically for the failure modes this codebase invites:

- The failure modes `AGENTS.md` and `DESIGN.md` call out for the area you touched: list them in the findings file and check each one.
- Reimplementing shared framework (`src/framework/`) or repair contract (`src/repair/`) behavior privately in a tool.
- A file or registry write without atomic replacement and readback, or a system mutation without a `RestoreRecord` or explicit non-reversibility notice.
- Missing action-time elevation check on an administrative operation.
- A hard-coded colour, size or spacing where `DESIGN.md` tokens or `shared/resolute-ui` own it, or a control without an accessible name.
- A test that passes without exercising the behavior.

### 3. Independent review rounds (the pinned reviewer)

The order on every record is fixed by `scripts/review-dispatch.py` `check_sequence`: one plan pass, then rounds until a clean terminal round, then the completion pass (step 4) last. No other order dispatches.

The dispatcher picks each round's lenses and effort (capped at `medium`) from the pin's schedule, at least one round by the pinned independent reviewer. Write the prompt to a scratch file from `docs/review-round-prompt.md` (candidate SHA, section contract, governing documents, lenses), then run it, naming your own agent as the writer (with `run_in_background` when in Claude Code):

```bash
python scripts/review-dispatch.py --writer <claude|codex|gemini|muse|meta> --writer-model <exact-model-version> --prompt <scratch-review-prompt.md> --record docs/reviews/<NN-domain>/D<NN>-T<NN>-s<N>.md
```

The dispatcher appends a `## Round N` section naming the reviewer, its model, effort and lenses, or `none` with the reason when the reviewer returned no review. Pass `--surface` on every round of a section that builds a user-facing surface so the `design` lens joins the later `low` rotation rounds (round 1 is `adversarial` alone, and a clean round ends the loop, so `design` is admitted but not guaranteed to run). Headings that start `## Round`, `## Completion review` or `## Plan review` are reserved for what `--record` writes: a writer's own note in a findings file uses another heading (for example `## Writer note: ...`), or the file stops being readable and the next review is refused with the offending line named.

| Lens | Asks |
| ---- | ---- |
| `plan` | Will the section as written produce a 100% complete feature? (plan review only) |
| `plan-delivery` | Does the build deliver every item the plan promised, with nothing quietly narrowed? |
| `adversarial` | How does this fail on hostile input, races, aborts, missing elevation, or unsafe writes? |
| `consistency` | Does it match the module rules (`src/framework/`, `src/repair/`, `shared/resolute-ui`), naming, and settings? |
| `integration` | Do callers and consumers still hold, with every contract kept? |
| `source-defect` | Is the upstream spec (`resolute_au3/`, `DESIGN.md`, Win32/wxWidgets docs) read accurately with deviations noted? |
| `quality` | Is the code clear, tested where it can fail, and free of dead or duplicated logic? |
| `design` | Does the rendered UI match `DESIGN.md` and `docs/captures/`? |
| `optimization` | Is there avoidable work, allocation, latency or step count on a hot path? |
| `record` | Does evidence match what ran, with owned deferrals and earned flip? |

The loop is bounded: at most `1 + max_low_rounds` rounds (thirty-three under the current pin: one `medium` round plus up to thirty-two `low` rounds; a round that returns no review does not count). Exhausting that budget with findings open is operator recovery, never approval: the dispatcher refuses the next round and no stamp follows from exhaustion. and it ends early on severity: the first clean round stops the loop: a round is clean only when it carries exactly one standalone `HIGHEST: P3` or `HIGHEST: none` declaration, which is all the dispatcher checks (a missing, duplicate, or contradictory declaration is never clean); the declaration must truthfully report that no `P1` or `P2` finding stands, a duty the dispatcher does not scan findings to enforce, and its `P3` findings are filed through `add-todo`. Findings are fixed in new commits appended to the candidate, gates re-run, and the next round runs against the new tip. A unit patched three rounds running is stopped and re-thought instead of patched again. When the dispatcher exits 1 (the reviewer returned no review), record the outage in the findings file and re-run or stop without a stamp: a session-only pass is not a substitute.

### 4. Completion and excellence review (one pass)

Last, once per section and only after a clean terminal round (step 3), the pinned reviewer reviews the built feature as a user meets it and against `resolute_au3/` and `DESIGN.md`. The dispatcher refuses this pass any earlier (`completion requires a clean terminal round`), and refuses rounds after a clean terminal round, so this pass is always the final dispatch on its record. Write the prompt to a scratch file from `docs/completion-review-prompt.md` (the candidate SHA, the section contract, the TODO file's Goal and Outcome, the `DESIGN.md` sections and `resolute_au3/` counterpart, the delivered diff), then run it (with `run_in_background` as enforced by `scripts/dispatch_hook.py`):

```bash
python scripts/review-dispatch.py --kind completion --candidate <full candidate SHA> --writer <claude|codex|gemini|muse|meta> --writer-model <exact-model-version> --prompt <scratch-completion-prompt.md> --record docs/reviews/<NN-domain>/D<NN>-T<NN>-s<N>.md
```

The dispatcher appends a `## Completion review` section (reviewer, model, candidate SHA), not a round: it is not counted against the cap, and a findings file takes one returned completion review. The review ends `COMPLETION: complete` or `COMPLETION: gaps`.

Then implement every `missing-in-scope` gap and every `in-scope` excellence item in this section (new commits appended to the candidate, the section's checklist and gates covering them), and file every `missing-out-of-scope` gap and `out-of-scope` item through `add-todo` as a new section. Under the completion review in the findings file, add one line per gap (an implemented gap names the repair record that reviewed it): `- Implemented: <gap> in <commit>`, or `- Filed: DNN TNN §N (<gap>)` for each section filed, and add a `> **Deferred:** <what> -- > XREF: DNN TNN §N` line to the section when its surface shows the filed item. When the dispatcher exits 1 (the reviewer returned no completion review), run the pass again. A returned completion closes the record: the dispatcher refuses every later pass on it, so gaps from a returned completion are implemented and reviewed as a new repair cycle on a `-repair` record (`docs/reviews/<NN-domain>/D<NN>-T<NN>-s<N>-repair.md`, then `-repair2` and so on), which takes its own plan pass, rounds to a clean terminal round, and completion last, exactly as the first record did.

### 5. Re-run the gates

After the last fix, on the final candidate and once, re-run the section's Test checkpoint and its owed gates under the test cadence in `AGENTS.md` (the affected tests, what only this machine can run, and `python scripts/ci-status.py` green for the final candidate when the section changed code, recorded in the stamp: CI runs `check-all` whole on every push, so a full local `pwsh scripts/check-all.ps1` is for phase closeout, a release or reproducing a red run; fix-loop commits before that re-run the touched tests alone, build warnings clean, `python scripts/todo-graph.py validate`, `python scripts/todo-claims.py`, and the Freeze check in frozen files). Quote the outputs in the findings file. A fix verified by reasoning is not verified. A red gate reopens the candidate: fix, re-run to green, and re-review, because earlier verdicts rested on the broken candidate. The re-review follows the dispatcher's order, never a bare round rerun: while no clean terminal round exists, run the next round; once a clean terminal round exists and the candidate is unchanged since it, the next pass is completion (a further round is refused); any candidate change after that round, like any returned completion, opens a new `-repair` record and runs its plan pass, rounds, and completion there, because verdicts never transfer across candidates.

### 6. Surface, feature, and frozen checks

Surface and feature completeness: 100% of every control, menu item, dialog and state on the Fidelity counterpart is working (proven on the rendered surface with real data and read-back in this review) or deferred to a named, resolving section, and every required refusal/error/undo path is exercised. Refuse the stamp for an unaccounted control or a `Cheaper substitute` shortcut. Frozen files: every `**Freeze check:**` ran and passed with the result quoted; a frozen behavior that moved without a recorded operator approval means no stamp and a question for the operator.

### 7. Stamp

Confirm every checklist item in the section is `[x]`, then record the stamp block at the end of the section in the TODO file (per `todo/README.md`), flip the section's row in the Implementation Order table to `[x]`, and run:

```powershell
python scripts/todo-graph.py plan --sync
python scripts/todo-graph.py validate
python scripts/todo-graph.py plan --check
```

The stamp block records:
- `> **Verified:** <YYYY-MM-DD> | §<N> | <quoted checkpoint and gate outputs>`
- `> **Review:** round <N> <reviewer from the round record> (<effort>), candidates <sha>(round 1) ... -- <lens verdicts> · Raw findings: docs/reviews/<NN-domain>/D<NN>-T<NN>-s<N>.md`
- `> **Completion:** <reviewer from the completion record> (medium), candidate <sha> -- COMPLETION: complete · Repair records: <none, or each -repair record with its final candidate>`
- `> **Plan review:** <reviewer from the plan record> -- <outcome>`
- `> **CRUD:** <applicable or not applicable (...)>`
- `> **Duration:** <start UTC> to <end UTC>`
- `> **Implementer:** <writer and exact writer model from the records>`

Commit the stamp, findings file, and regenerated plan together as `todo: stamp <ref>`.

### 8. Audit stance

On an already-`[x]` section: run steps 1, 2 and 3 to 6 against the section's own candidate, recording the audit in `docs/reviews/<NN-domain>/audit-d<NN>-t<NN>-s<N>.md` (`--record` that path). That fresh record takes its own plan pass first (step 3a's dispatch with `--kind plan` on the audit candidate), then its rounds, then completion last: the dispatcher refuses a round on a record with no returned plan review. Confirm the stamp's evidence still holds (re-run the checkpoint) or find the regression. If a regression is found, reopen the section by replacing its `> **Verified:**` line with `> **Reopened:** <YYYY-MM-DD> -- <reason>; prior stamp <date> superseded`, unticking the affected checklist items and the Implementation Order row, and running `python scripts/todo-graph.py plan --sync`. A re-confirmed row keeps its stamp; say so in one line.

## Guardrails

- Do not stamp without a findings file, its plan review, its completion review, and at least one independent round.
- Do not stamp an unaccounted control on a surface section, or a moved frozen behavior.
- Do not review the working tree when the candidate is a commit or range. Name the hashes.
- Do not transfer evidence across changed candidates: a new tip re-runs its gates.
