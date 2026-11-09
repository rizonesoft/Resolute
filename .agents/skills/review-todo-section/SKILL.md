---
name: review-todo-section
description: Quality-gate a just-implemented TODO section with self-review, independent review lenses and a bounded fix loop, then write the Verified stamp and sync the plan. Also runs in audit stance on shipped sections. Use after process-todo-section or when asked whether a section is really done.
---

# Review TODO Section

The gate between "code exists" and "the row says `[x]`". Nothing else may flip that row, and the flip happens only when a section has no unticked items, no open prerequisite, no waiting Need, and full review evidence recorded in `docs/reviews/<NN-domain>/D<NN>-T<NN>-s<N>.md`.

Review is mandatory and independent: the implementing session self-reviews, and every review pass comes from the reviewer pinned in `.conclave/reviewers.toml` (a different model family from the writer: `argon` on `agy` when `--writer codex`, and `astra` on `codex` when `--writer claude|gemini|muse|meta`), run through `scripts/review-dispatch.py` with `--writer <claude|codex|gemini|muse|meta> --writer-model <exact-model-version>`. Reviewer effort is strictly capped at `medium` (`low` or `medium` only; `scripts/review-dispatch.py` refuses any effort above `medium`). The pin's `[schedule]` owns each pass's reasoning effort and lenses, so the writer never picks them: the plan review (`process-todo-section` step 3a) runs at `medium`, round 1 at `medium` (adversarial, integration, source-defect, plan-delivery, and design when `--surface` is passed), every later round at `low` (adversarial, up to `max_low_rounds = 8`), and final completion review at `medium`. Record the writer's decisions as settled items in the findings files (`- Filed: DNN TNN §N (...)` and `- Not taken: <item> (<reason>)` under the completion review or a `## Writer note: settled` heading): the dispatcher gives them to every reviewer, so a repeated one never keeps a loop running. A verdict with no record is an opinion.

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

Work the three questions across the diff and its blast radius. You may also run the read-only `delegate-check` subagent as self-review input (never as a lens verdict). Fix what you find, then re-ask them. Look specifically for the failure modes this codebase invites:

- The failure modes `AGENTS.md` and `DESIGN.md` call out for the area you touched: list them in the findings file and check each one.
- Reimplementing shared framework (`src/framework/`) or repair contract (`src/repair/`) behavior privately in a tool.
- A file or registry write without atomic replacement and readback, or a system mutation without a `RestoreRecord` or explicit non-reversibility notice.
- Missing action-time elevation check on an administrative operation.
- A hard-coded colour, size or spacing where `DESIGN.md` tokens or `shared/resolute-ui` own it, or a control without an accessible name.
- A test that passes without exercising the behavior.

### 3. Completion and excellence review (one pass)

Before the regular rounds, once per section, the pinned reviewer reviews the built feature as a user meets it and against `resolute_au3/` and `DESIGN.md`. Write the prompt to a scratch file from `docs/completion-review-prompt.md` (the candidate SHA, the section contract, the TODO file's Goal and Outcome, the `DESIGN.md` sections and `resolute_au3/` counterpart, the delivered diff), then run it (with `run_in_background` as enforced by `scripts/dispatch_hook.py`):

```bash
python scripts/review-dispatch.py --kind completion --candidate <full candidate SHA> --writer <claude|codex|gemini|muse|meta> --writer-model <exact-model-version> --prompt <scratch-completion-prompt.md> --record docs/reviews/<NN-domain>/D<NN>-T<NN>-s<N>.md
```

The dispatcher appends a `## Completion review` section (reviewer, model, candidate SHA), not a round: it is not counted against the cap, and a findings file takes one returned completion review. The review ends `COMPLETION: complete` or `COMPLETION: gaps`.

Then, before any regular round, implement every `missing-in-scope` gap and every `in-scope` excellence item in this section (new commits appended to the candidate, the section's checklist and gates covering them), and file every `missing-out-of-scope` gap and `out-of-scope` item through `add-todo` as a new section. Under the completion review in the findings file, add one line per gap: `- Implemented: <gap> in <commit>`, or `- Filed: DNN TNN §N (<gap>)` for each section filed, and add a `> **Deferred:** <what> -- > XREF: DNN TNN §N` line to the section when its surface shows the filed item. When the dispatcher exits 1 (the reviewer returned no completion review), run the pass again; the regular rounds wait for it.

### 4. Independent review rounds (the pinned reviewer)

The dispatcher picks each round's lenses and effort (capped at `medium`) from the pin's schedule, at least one round by the pinned independent reviewer. Write the prompt to a scratch file from `docs/review-round-prompt.md` (candidate SHA, section contract, governing documents, lenses), then run it, naming your own agent as the writer (with `run_in_background` when in Claude Code):

```bash
python scripts/review-dispatch.py --writer <claude|codex|gemini|muse|meta> --writer-model <exact-model-version> --prompt <scratch-review-prompt.md> --record docs/reviews/<NN-domain>/D<NN>-T<NN>-s<N>.md
```

The dispatcher appends a `## Round N` section naming the reviewer, its model, effort and lenses, or `none` with the reason when the reviewer returned no review. Pass `--surface` on every round of a section that builds a user-facing surface so round 1 includes the `design` lens. Headings that start `## Round`, `## Completion review` or `## Plan review` are reserved for what `--record` writes: a writer's own note in a findings file uses another heading (for example `## Writer note: ...`), or the file stops being readable and the next review is refused with the offending line named.

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

The loop is bounded: at most 33 rounds (a round that returns no review does not count), and it ends early on severity: the first round whose findings are all `P3` or advisory (one with no `P1` or `P2`, `HIGHEST: P3` or `HIGHEST: none`) stops the loop, and its `P3` findings are filed through `add-todo`. Findings are fixed in new commits appended to the candidate, gates re-run, and the next round runs against the new tip. A unit patched three rounds running is stopped and re-thought instead of patched again. When the dispatcher exits 1 (the reviewer returned no review), record the outage in the findings file and re-run or stop without a stamp: a session-only pass is not a substitute.

### 5. Re-run the gates

After the last fix, re-run the section's Test checkpoint and its owed gates (`pwsh scripts/check-all.ps1` or the affected test suites, build warnings clean, `python scripts/todo-graph.py validate`, `python scripts/todo-claims.py`, and the Freeze check in frozen files). Quote the outputs in the findings file. A fix verified by reasoning is not verified. A red gate reopens the candidate: fix, re-run to green, and re-run the review round, because earlier verdicts rested on the broken candidate.

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
- `> **Review:** round <N> Astra (<effort>), candidates <sha>(round 1) ... -- <lens verdicts> · Raw findings: docs/reviews/<NN-domain>/D<NN>-T<NN>-s<N>.md`
- `> **Plan review:** astra -- <outcome>`
- `> **CRUD:** <applicable or not applicable (...)>`
- `> **Duration:** <start UTC> to <end UTC>`
- `> **Implementer:** Claude Opus 5.5`

Commit the stamp, findings file, and regenerated plan together as `todo: stamp <ref>`.

### 8. Audit stance

On an already-`[x]` section: run steps 1, 2 and 4 to 6 against the section's own candidate, recording the audit's rounds in `docs/reviews/<NN-domain>/audit-d<NN>-t<NN>-s<N>.md` (`--record` that path). Confirm the stamp's evidence still holds (re-run the checkpoint) or find the regression. If a regression is found, reopen the section by replacing its `> **Verified:**` line with `> **Reopened:** <YYYY-MM-DD> -- <reason>; prior stamp <date> superseded`, unticking the affected checklist items and the Implementation Order row, and running `python scripts/todo-graph.py plan --sync`. A re-confirmed row keeps its stamp; say so in one line.

## Guardrails

- Do not stamp without a findings file, its plan review, its completion review, and at least one independent round.
- Do not stamp an unaccounted control on a surface section, or a moved frozen behavior.
- Do not review the working tree when the candidate is a commit or range. Name the hashes.
- Do not transfer evidence across changed candidates: a new tip re-runs its gates.
