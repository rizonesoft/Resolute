---
name: process-todo-section
description: Process exactly one TODO section end to end -- resolve it, validate and fact-check the plan against the repository, correct every drifted claim, build it, run the gates, hand to review, and commit. Use whenever asked to process, implement, ship, continue, or finish a TODO section.
---

# Process TODO Section

One section. One commit. The section is the contract: **and a contract is checked before it is signed.**

Processing a section is two jobs, in order. First establish that the plan is sound: internally consistent, still true of the code, buildable as written, and verifiable when built. Then implement it. A section written weeks ago against a codebase that has since moved is a plan with a bug in it, and building it faithfully ships that bug with full ceremony.

So: **do not improvise around the plan, and do not implement a plan you have found to be wrong.** Correct it in the file, visibly, then build the corrected version.

## Use this skill when

- The user names a section **in any form**: a path and a section, a `DNN TNN §N` reference, or a row pasted straight out of `todo/implementation-plan.md`. Step 0 turns all of them into the same thing.
- An attended runner picks the next `[ ]` row from the plan.
- Do NOT use to audit already-shipped work: that is `review-todo-section` in audit stance.

## Step 0 -- resolve the argument before anything else

**Never hand-translate a reference into a filename.** Ask the graph:

```bash
python scripts/todo-graph.py resolve "$ARGUMENTS"
```

It accepts whatever the caller had in front of them:

| Input | Works |
| --- | :-: |
| `D01 T01 §3` | yes |
| <code>&#124; [ ] &#124; \`D01 T01 §3\` &#124; Logging contract … &#124; 5 &#124;</code> (a plan row, pasted whole) | yes |
| `01-sdk-core/TODO-01-shared-include-contracts.md §3` | yes |
| Any prose containing one of the above | yes |

It prints the path, the section title, the item count, whether the TODO is frozen, and **which dependencies are unmet**. Its exit code is the instruction:

| Exit | Meaning | Do this |
| :-: | --- | --- |
| `0` | Resolved, open, dependencies met | Proceed to step 1 |
| `1` | No such TODO or no such section | Stop. Report the reference as unresolvable rather than guessing a near match. |
| `2` | No section reference in the input | Stop and ask which section. |
| `3` | The section is already `[x]` | Do **not** process it. This is `review-todo-section` in audit stance; say so and hand over. |
| `4` | Unmet dependencies | Stop at the dependency gate and name the unmet sections. |
| `5` | The section moved out of the tree (`> **Moved:**` under its heading) | Stop. Its open work is worked from the file the `moved` line names, by that file's own rules. |

Use the `skill arg` line it prints as the canonical form for the rest of the run, so the commit message and the review call name the section the same way.

**If `resolve` printed a `needs` line, the section needs a Windows host.** Confirm the host is reachable before writing `Started:`. If it is not, stop and say which host the section waits on: starting a host-bound section with no host is how a run burns a session producing nothing committable.

**Write `Started:` now, at the first resolve.** If the section body carries no `> **Started:**` line, add one with the current UTC instant (`date -u +%Y-%m-%dT%H:%M:%SZ`). Do **not** overwrite an existing one on resume: review subtracts it from stamp time for `Duration:`, which is the whole working interval. A section resumed after a session death would otherwise report the wrong half of its own cost.

**Stop here if another writer holds the tree.** Check `git status` for unfamiliar uncommitted work you do not understand, and ask before building over it. Two writers on one tree is how a call ships without its interface.

## Execution discipline

- **Validate before building.** Step 2 is a gate, not a formality. A section that cannot pass it gets fixed first.
- **Follow the corrected contract.** The checklist items define the scope. Do not widen because something adjacent looks wrong; file it instead with `add-todo`. Correcting a defect *in* the section is not widening; adding work the section never asked for is.
- **One section = one commit.** If you cannot describe the change in one commit message, the section was mis-sized. Plan corrections may ride in that commit, or land as their own `todo:` commit first when they are substantial.
- **Commits are free; pushes are not.** Commit locally as often as you like. Push twice per section: the SHIP push, then the STAMP push. While iterating, run the affected checks only (`cmake --build` on the touched target, `ctest --tests-regex '<names>'`), not the whole sweep. A third push is allowed when it is named and the reason recorded.
- **Never mark `[x]` without evidence.** The Implementation Order row flips only after the review stamp exists.
- **User data first.** A section that writes files, syncs rows, numbers a document, or records consent is built to: atomic writes, read back what was written, skip and report rather than drop or duplicate, and every destructive path confirmed. Its Test checkpoint exercises the failure path, not only the happy path.
- **Server-side authority, adapted.** Any value the user trusts (file bytes, a permission decision, a diff hunk) is computed or verified in exactly one place, and the UI reflects it rather than deciding it. A UI calculation nothing verifies is a bug.
- **House style is the bar on surfaces.** A section that builds a surface proves it against the capture under `docs/captures/`, not against memory of what the other tools look like. Fourteen tools share one SDK: a second progress bar, About dialog, or settings writer is a defect, not a shortcut.
- **Destructive paths are proven in both directions.** A section that writes the registry, takes ownership, re-registers a component, or repairs a drive proves the undo as well as the do, and proves what happens without elevation.

## The session does every step

One session validates, builds, gates, commits, obtains an independent review, and hands to stamping. It dispatches nobody to implement, gate, or keep records, and the one reviewer it invokes is external and advisory. Output discipline is load-bearing: bound every command (build output filtered to the touched target, `tail`/`head` on logs, field extraction on `.ini` readbacks), because an unbounded dump lands in the one context that must carry it for the rest of the run.

## Workflow

### 1. Read the whole contract

Step 0 gave you the path, the section, and the dependency verdict. Read the entire TODO file, not just the section. The Goal, Current state, and Inputs carry context the section assumes. Read the sections this one depends on: their `Verified:` stamps tell you what actually shipped versus what was planned.

Confirm every dependency in the `Depends On` column is `[x]`. If one is not, stop and say so.

### 2. Validate the plan before building it

The section was written before the code existed. Check it still holds. Seven questions, each answered against the repository rather than from memory:

| Check | What you are asking | The failure it catches |
| ----- | ------------------- | ---------------------- |
| **Legitimacy** | Does a real source demand this: an observed defect, a Win32 contract, a user need? Or was it inferred? | Work invented by the plan, built faithfully, wanted by nobody |
| **Currency** | Do the scripts, functions, includes, ini keys, and versions it names still exist and still behave that way? | A section pinned to a path or count that moved |
| **Consistency** | Do its own items agree with each other, with the file's Current state block, and with the sections it depends on? | Two items specifying different things; the later one silently wins |
| **Correctness** | Are the behaviors, function names, and Win32 details it states actually what the source says? | A stale behavior ported confidently into code |
| **Sufficiency** | Is there enough here to build without inventing? Are the decisions made, or deferred into the implementer's lap? | A section that becomes a design session for an unattended executor |
| **Verifiability** | Can the `Test checkpoint` be executed and can it fail? Does a `Freeze check` name fixtures that exist? | A checkpoint that passes by being unfalsifiable |
| **Accuracy** | Is every concrete claim still literally true: every reference, path, count, ID, and deferral? | A section that reads as authoritative while quietly citing things that moved |

Ground each answer:

```bash
python scripts/todo-graph.py validate          # graph integrity, XREF reciprocity
grep -rn "<class/file the section names>" src/ tests/
git log --oneline -5 -- <the paths the section touches>
```

#### Fact-check the section, claim by claim

`validate` proves the graph is well-formed. It cannot tell you whether a sentence is *true*. Walk the section (prose, items, checkpoint) and check every concrete assertion against the thing it describes. A TODO's authority comes from being accurate; one confidently wrong line costs more than ten vague ones, because nobody re-checks a statement that reads as settled.

| Claim in the section | Check it against |
| --- | --- |
| A script, function, include, command, or ini key | It exists, spelled that way, at that path |
| A count, size, version, or measurement | Re-derive it; these age fastest and are quoted most confidently |
| A commit SHA or run ID | It resolves |
| An `-> XREF:` reference | The target section exists, and points back |
| "Nothing exists yet" / "there is still no X" | X really does not exist |
| A quotation from the source or spec | It says that, verbatim, at that location |

#### Deferrals in both directions

```bash
python scripts/todo-graph.py query deferred
```

**Deferrals this section owns**: another section handed you this work, and it is part of your scope whether or not the checklist mentions it. It turns FATAL the moment this row flips, so it is not optional.

**Deferrals this section wrote**: re-read each one against today's repository, not the day it was written. Three things can be wrong with an open deferral, and only the first is caught by tooling:

- **The owner shipped it.** `validate` already makes this FATAL. Close it with `> **Resolved:**`.
- **The description has drifted.** The owner is still legitimately open, but the deferral describes a state that has since changed. Correct the text in place, or close it if the *reason* for deferring is gone even though the owner has not shipped.
- **The work was quietly done by someone else.** The owner never ticked its box, so it is not formally stale, but the thing is fixed. Verify it, then close the deferral **and** tick the owner's item: leaving the owner's box unticked recreates the same rot one level up.

Read the `Verified:` stamps on the sections this one depends on. They record what actually shipped, which is frequently narrower than what was planned: and a section built on the plan rather than on the stamp inherits the gap.

**Anything unclear at this point becomes a question you answer from the source, not a decision you defer.** Where the source is silent, take the industry-standard option, record that it is a default, and carry on with the cost of changing it noted. A section that stalls waiting for an answer is worse than one built on a recorded assumption.

### 3. Correct the section when validation fails

Findings from step 2 are fixed **in the TODO file**, before implementation, so the plan and the build never disagree in the record.

| Finding | Do this |
| ------- | ------- |
| Stale fact: a name, count, version, or path that moved | Correct it in place. Mark it `**Corrected YYYY-MM-DD:**` with what it said before and what the source says now. |
| Two items contradict | Resolve toward the source and the later decision. Say which one lost and why, in the item itself. |
| Item is unbuildable as written | Rewrite it to be concrete: name the file, class, or command. Vagueness is the defect. |
| Item is already true | Tick it and note that it shipped elsewhere, with the XREF. Do not rebuild it. |
| Item is genuinely wrong work | Do **not** silently drop it. Strike it with a stated reason, and if something must replace it, add that item. |
| `Test checkpoint` cannot fail | Rewrite it so it can. An unfalsifiable checkpoint is how a section gets stamped without being verified. |
| The whole section is wrong | Stop. Do not implement. Report what is wrong and what you propose, and let the user decide. |
| A **frozen** behavior looks wrong | Do **not** change it, in code or in the plan. Record the question for the operator with the proposed fix, and continue around it. |
| A reference, path, count, or ID is wrong | Correct it to what the source says, marked `**Corrected YYYY-MM-DD:**`. Never delete a wrong figure silently: the next reader needs to know it moved. |
| A deferral's owner has shipped it | Close it: replace `> **Deferred:**` with `> **Resolved:**` in place, keeping the text and XREF, adding the date and the commit. |
| A deferral's description has drifted | Correct the text in place. If the *reason* for deferring is gone, close it and say so, even though the owner has not shipped. |
| A deferral's work was done without its owner ticking it | Verify it, close the deferral, **and** tick the owner's item. Leaving the owner unticked moves the rot rather than fixing it. |

Two rules keep this honest:

- **Correct the plan, never the goalpost.** Narrowing a section so the code you were about to write happens to satisfy it is not validation, it is fitting the contract to the implementation. If the section demands more than you can deliver, the section wins.
- **Say what you changed.** The plan correction is reported alongside the implementation and appears in the commit body. A silent edit to the contract is indistinguishable from scope drift.

If step 2 finds nothing, say so in one line and move on: that is the expected outcome for a freshly written section, and the check costs little.

### 4. Build the corrected contract

Work the checklist top to bottom. Tick each item as its Done-when becomes true, in the file, as you go: the file is the record of progress, not a form filled in at the end.

- Build the cheaper substitute's failure into the work: the checkpoint must be able to catch the wrong thing, so build the test that distinguishes them.
- Keep the diff to the section. Adjacent wrongness gets filed with `add-todo`, not fixed in passing.
- UI sections: consume the shared includes named in `**Chrome:**`. A second progress bar, About dialog, or localization loader is a defect, not a shortcut.

### 5. Surface completeness (UI sections)

Before the checkpoint, account for **every control, menu item, dialog, and state** the section's Fidelity counterpart has, each resolved to working (proven on the rendered surface) or deferred to a named, resolving section. A control disabled with a reason that names no section is missing, not deferred. `review-todo-section` refuses the stamp for an unaccounted control; decide here, not there.

### 6. Run the Test checkpoint, for real

Execute the checkpoint command and read the output. Quote the result in the commit body. If the checkpoint cannot run (no Windows host, no C++ toolchain, no optical drive or USB device, missing fixture), the section is not done: record what ran, what did not, and why, and stop without a stamp. A checkpoint half-run is not evidence.

Then run **every gate the section owes**, not only the checkpoint:

```bash
pwsh scripts/check-all.ps1          # build both architectures, clang-tidy, tests, validate
ctest --preset x64-debug            # the whole suite, not only the new tests
python scripts/todo-graph.py validate
python scripts/todo-claims.py       # the TODOs' measured claims still hold
```

**If a claim went stale, the section changed something a TODO had measured.** That is not a nuisance to silence: fix the claim *and* re-read the sentence it supports, in this commit, because the prose around a changed figure is usually wrong too.

While iterating, narrow with `ctest --tests-regex`. Before committing, run the full sweep once: a section that passes its own filter and breaks another suite has not passed.

### 7. Commit and push the ship

Commit as one section commit with the evidence in the body:

```
<area>: <what now works> (<ref>)

<checkpoint output, quoted>
<plan corrections, if any>
```

Push the SHIP push. The commit must exist on the remote before the next step, because the independent reviewer reads the commit.

### 8. Independent review, before the stamp

**An outside reviewer reads the commit before this session stamps its own work.** The session that built a section is the worst judge of whether it is right, and this step exists to break that.

```bash
codex review --commit <SHIP_SHA>
```

Codex is configured here with `gpt-6-astra` at high reasoning effort, so no model flag is needed. It reviews read-only and changes nothing.

**`--commit` takes no review instructions.** Verified 2026-09-17 while processing `D00 T03 §1`: the usage line prints `codex review --commit <SHA> [PROMPT]`, but supplying either a prompt string or `-` for stdin fails with `the argument '--commit <SHA>' cannot be used with '[PROMPT]'`. An earlier version of this skill documented a long prompt here, and it could never have run. Do not reintroduce one.

What replaces it: Codex reads `AGENTS.md` from the repository root on its own, so the contract it needs is already in front of it. That file carries the source layout table, the five proof types, and the shared-layer rules, which is exactly what the deleted prompt was asking the reviewer to consult. **When a section needs review guidance the reviewer would not otherwise have, put it in the section's own `Test checkpoint` rather than in the command**, because the reviewer reads the section.

Then act on what it returns:

- **A finding that is right** gets fixed in a follow-up commit on the same section, and the fix is quoted in the stamp. Do not argue with a correct finding to avoid a second commit.
- **A finding that is wrong** gets one line in the stamp saying so and why. Record it; do not silently discard it.
- **A finding that is right but out of scope** gets filed with its own owner and dependency, per the guardrail below. Do not widen the section to absorb it.

If `codex` is unavailable on this machine, say so plainly in the report and in the stamp. A missing reviewer is a recorded gap, never a silent pass.

### 9. Stamp, then push the stamp

Invoke `review-todo-section` on the same ref. Review writes the stamp and flips the row; this skill never flips a row itself. The stamp records the independent review's outcome alongside the checkpoint evidence.

After the stamp lands, push the STAMP push and sync the plan:

```bash
python scripts/todo-graph.py plan --sync
git push
```

### 10. Report

Tell the user plainly: what was built, what the checkpoint proved (quoted), what the independent review found and what was done about each finding, what plan corrections were made, what was filed rather than fixed, and where the stamp stands.

## Guardrails

- Do not implement a section you judged wrong. Correct it or stop.
- Do not widen the section. File adjacent work.
- Do not flip the Implementation Order row. Review owns that.
- Do not claim a checkpoint passed without running it: quote the output.
- Do not build a UI surface whose named baseline artifact does not exist. The capture ships first.
- Do not end with the plan unsynced.
- Do not stamp before the independent review has run, or without recording that it could not.
- Do not discard a review finding silently. Fix it, refute it in the stamp, or file it.
