---
name: review-todo-section
description: Quality-gate a just-implemented TODO section -- self-review, independent review lenses, fix loop, then the Verified stamp and the row flip. Also runs in audit stance on shipped sections. Use after process-todo-section or when asked whether a section is really done.
---

# Review TODO Section

The gate between "code exists" and "the row says `[x]`". Nothing else may flip that row.

**Review is mandatory.** A `Verified:` stamp whose `Review:` line does not record real review work, with a committed findings file, is not a valid stamp. Until the external review panel is wired (see Deferred in the repo README), the session performs the lenses itself, in separate passes, against the recorded candidate: and the findings file is what makes that honest.

## Use this skill when

- A section was just implemented (`process-todo-section` ends by invoking this).
- The user asks "is §N really done?", "re-verify §N", "audit §N": run in **audit stance** (below).
- Before closing out a TODO file with `process-todo-file`.

## Step 0 -- resolve the argument

Same front door as `process-todo-section`. Never hand-translate a reference into a filename:

```bash
python scripts/todo-graph.py resolve "$ARGUMENTS"
```

Exit `3` means the row is already `[x]`. That is not an error here: it is the signal to run in **audit stance**, where the only permitted row change is `[x]` to `[ ]` on regression evidence.

## The three questions

Every review answers these with code and behavior evidence, never with assertion:

1. **Does it make sense?** Does the implementation produce the exact outcome the section asked for, without unnecessary scope?
2. **Is it logical?** Do the domain relationships, validation, calculations, permissions, UI behavior, and failure paths agree with each other?
3. **Did it break anything else?** Inspect callers, consumers, tests, and any adjacent workflow that reads what you changed.

Answer each by naming files and behavior. "Reviewed the changes, looks correct" is not an answer.

## Workflow

### 1. Map the evidence, then fix the candidate

For each checklist item marked `[x]` in this session, find the code that satisfies it. An item with no corresponding change is either not done (un-tick it) or was already true (worth a note).

Read the actual diff (`git diff`, `git show`), not your memory of writing it.

Then fix the **candidate**: the commit (or commit range) under review, recorded verbatim in the findings file with its hashes. A candidate nobody wrote down cannot be re-derived, and a review of an unknown candidate proves nothing. For an audit of shipped work, the candidate is the section's own commit(s), not the current tree: the tree has moved on.

### 2. Self-review

Work the three questions across the diff and its blast radius. Fix what you find, then re-ask them: a fix changes the answers. Self-review runs before the lenses, and it costs no round.

Look specifically for the failure modes this codebase is prone to:

- A trusted value decided in the UI with nothing verifying it.
- A file or `.ini` write that is not atomic, or a settings value the UI shows that nothing reads back.
- A destructive system action (registry write, ownership takeover, COM re-registration, drive repair) with no rollback and no log line.
- An elevation check the UI performs but the action path does not re-check, or a path that assumes it is already admin.
- A raw owning pointer where the layer uses RAII, a handle or resource released on one path but not another, or a global left mutated after the call returns.
- A shared behavior copied into a tool instead of consumed from `src/framework/` or `src/repair/`, or a file added to a shared layer by a tool, which the source layout in `AGENTS.md` forbids.
- A hardcoded English string on a surface that has a `.lng` entry, or a `.lng` key nothing reads.
- A frozen behavior that moved.
- A checkpoint that passes by being unfalsifiable (a build of a target the section did not touch, a screenshot of the wrong window, a parity run against a fixture the change cannot affect).
- A surface compared against memory instead of the capture under `docs/captures/`.

Cheap defects caught here cost nothing; the same defect caught by a lens costs a whole round.

### 3. The lenses

Run each lens as a separate pass over the candidate, recording findings in the findings file (`docs/reviews/<domain>/D<NN>-T<NN>-s<N>.md`). Commit the findings file with the review.

| Lens | Asks |
| ---- | ---- |
| `adversarial` | How would this fail in hostile hands? Malformed input, races, injection, revoked consent mid-flow. |
| `consistency` | Does this agree with the rest of the suite: naming, the source layout in `AGENTS.md`, `DESIGN.md`, the settings writer, the logging call? |
| `integration` | Do the callers and consumers still hold: every tool that includes the changed header, the launcher that starts it, the release descriptor that ships it, the language pack that names it? |
| `source-defect` | When owed (a Win32 contract, a registry layout, or another tool's behavior is at stake): is the source read correctly, and is the deviation declared? |
| `design` | On a surface: judge the RENDERED surface against the baseline or contract, never source alone. Screenshots or driven captures, not impressions. |
| `record` | Is the record honest: does the stamp's evidence match what ran, do deferrals name owners, is the row flip earned? |

Each lens ends in a verdict: `approve`, `needs-attention` (with findings), or `advisory` (noted, not blocking). Findings are fixed in the candidate and the affected lens re-runs: iterate until no lens reports anything the plan would fix, with a cap of 4 rounds. A unit patched three rounds running is stopped and re-thought instead of patched again.

### 4. Re-run the gates

After the last fix, re-run the section's Test checkpoint and the owed gates (affected suites, warnings, analysis, `validate`). Quote the outputs. A fix verified by reasoning is not verified.

### 5. Surface check (UI sections)

Every control, menu item, dialog, and state on the Fidelity counterpart is working (proven on the rendered surface in this review) or deferred to a named, resolving section. Refuse the stamp for an unaccounted control. Compare the rendered surface against the baseline artifact or design contract before stamping, and confirm the user-guide update shipped in the same commit.

### 6. Frozen check (frozen TODOs)

Every `**Freeze check:**` in the section ran and passed, with the result quoted. No frozen behavior moved without a recorded operator approval. If one did, there is no stamp: there is a question for the operator.

### 7. Write the stamp and flip the row

Append the stamp block at the end of the section: `Verified:` (date, coverage, quoted evidence), `Review:` (rounds, candidate fingerprint or hashes, per-lens verdicts, findings-file link), `CRUD:` (behavioral evidence or an honest not-applicable), plus `Duration:` and carried `Deferred:` lines. Then flip the Implementation Order row to `[x]`.

Re-verification replaces the stamp in place. Never accumulate duplicates, and never edit a stamp to fit new code: the fix goes forward in a new commit and the stamp is rewritten by review.

### 8. Audit stance

On an already-`[x]` section: run steps 1-6 against the section's own candidate. Confirm the stamp's evidence still holds (re-run the checkpoint), or find the regression. The only permitted row change is `[x]` to `[ ]`, with the reason written into the section as a blocking note. A re-confirmed row keeps its stamp; say so in one line.

## Guardrails

- Do not stamp without a findings file. A verdict with no record is an opinion.
- Do not stamp an unaccounted control on a UI section.
- Do not stamp a frozen behavior that moved without approval.
- Do not flip a row this review did not earn.
- Do not review the working tree when the candidate is a commit. Name the hashes.
