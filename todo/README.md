# TODO System -- Format Spec

The `todo/` tree is the live execution plan for Resolute Power Tools. Markdown is canonical; the graph cache is a derived read-only projection rebuilt by `scripts/todo-graph.py`.

One rule governs everything below: **a TODO section must be implementable by someone with zero conversation context.** A fresh session starts with none, and a session that hits the usage limit resumes cold. If a section only makes sense to someone who was in the room, it is not done.

This system is a port of the Intelligent Notepad TODO system, which was itself a port of the JMR Online one. Its history comments name sections from those repos (`D00 T01 §21` and the like); those are provenance for why a rule exists, not live references here.

## Tree shape

```
todo/
├── README.md               this file
├── TODO-00-INDEX.md        root index -- domain order + active work
├── implementation-plan.md  derived phase plan, the front door for a run
├── 00-workspace/
│   ├── INDEX.md            domain index -- every TODO in this domain
│   ├── TODO-01-<short-name>.md
│   └── TODO-02-<short-name>.md
├── 01-sdk-core/
└── …
```

Domains are flat-numbered and ordered by allocation sequence. Each maps to a build area; the mapping lives in `TODO-00-INDEX.md` and in each domain's `INDEX.md`. Numbers are stable addresses: a new domain appends after the last one, because `DNN` cross-references encode them.

**Naming:** `TODO-NN-short-name.md`, where `NN` is the next free number *within that domain*. Numbers are local to the domain and never reused. Renaming a file is safe: the stable `id` in frontmatter is what cross-references resolve against.

## Frontmatter

Every TODO file opens with YAML frontmatter. Five required fields, four optional. That is the whole schema: resist adding more.

```yaml
---
schema_version: 1
id: shared-include-contracts         # stable, kebab-case, globally unique, survives renames
domain: 01-sdk-core                  # must match the containing directory
status: draft                        # draft | active | blocked | done | superseded
title: "TODO-01 -- Shared Include Contracts"
depends_on: []                       # optional -- whole-TODO edges; prefer section edges
frozen: false                        # optional -- true when the file touches a frozen behavior
track: N1                            # optional -- build-area reference
superseded_by: other-todo-id         # optional -- set with status: superseded
---
```

`id` rules: lowercase `a-z0-9-`, 2-60 chars, starts with a letter, no trailing dash. It is the key every cross-reference and the graph cache resolve against, so it must not change once other files point at it.

## File anatomy

```markdown
---
(frontmatter)
---

# TODO-01 -- Toolchain and Gates

> **Goal:** One paragraph. What is true when this file is finished, in plain terms.

> [!IMPORTANT]
> **Current state:** What exists RIGHT NOW, before this TODO runs. Without this the implementer has to grep the repo to find the starting line. Name real files and real gaps. The `## Current state` heading is optional and exists for addressability: sections that must cite the block name the heading, and files that need no citation keep the unheaded shape.

## Inputs

- [`src/framework/Logging.h`](…) -- exists; §2 extends it
- [`resolute_au3/SDK/Concrete/Resolute/Resolute.au3`](…) -- the specification this section ports
- -> XREF: [`02-launcher/TODO-01 §4`](…) -- consumes the gate this section builds

## Outcome

- Bullet list. Each bullet is an observable end state, not an activity.
- "Every target builds with warnings as errors on both architectures" -- good.
- "Improve code quality" -- bad.

**Adjacency:** list=not-applicable (a gate script has no records to browse); document=not-applicable (no printed output in this file); settings=applicable @ D00 T01 §4; reporting=applicable @ D00 T01 §5; notifications=not-applicable (a local gate notifies nobody); permissions=not-applicable (single-user desktop toolchain, no roles); audit=not-applicable (git history is the audit for a script); exchange=not-applicable (nothing imports or exports here); reverse=applicable @ D00 T01 §6

## Implementation Order

| Order | Section | Deliverable                              | Depends On   | Status |
| :---: | :-----: | ---------------------------------------- | ------------ | :----: |
|   1   |   §1    | Toolchain pin: MSVC, CMake, vcpkg        | --           |  [x]   |
|   2   |   §2    | Warnings-as-errors gate over every target| §1           |  [ ]   |
|   3   |   §3    | One-command build for any tool           | §1           |  [ ]   |

---

## 1. Toolchain Pin

One paragraph of context: why this section exists and what it must not break.

- [ ] `scripts/cpp-env.ps1` resolves the MSVC toolset, CMake, and the vcpkg root from pinned versions. Done when: the script prints all three versions and exits 1 with a named remedy when any is missing. Cheaper substitute: hardcoding one developer's install path.
- [ ] Another concrete item. Max 30 per section. See Work items below.
- [ ] Commit: `"workspace: pin the C++ toolchain and locate it from one place"`

**Test checkpoint:** `pwsh scripts/cpp-env.ps1` exits 0 and prints the MSVC, CMake, and vcpkg versions on a configured machine; renaming the pinned toolset directory makes it exit 1 with the remedy line.

> **Verified:** 2026-09-16 | §1 | cpp-env 0 · MSVC 19.44 · CMake 3.30 · negative probe exit 1

## 2. …

## Verification

- [ ] `pwsh scripts/check-all.ps1` -- zero findings across every target
- [ ] Both architectures build without warning
- [ ] `python scripts/todo-graph.py validate` clean
```

### Sections appear in numerical order, and `## Verification` comes last

`## 1.` through `## N.` run in order down the file, with `## Verification` after all of them. New sections go in numerical position, not appended after `## Verification`: appending is what strands a section where no top-to-bottom reader finds it. The validator does not check this yet, so check it by eye when you add a section.

### The Implementation Order table IS the dependency graph

Every `## N.` body section has exactly one table row, and every row has exactly one body section. The graph script enforces both directions. `Depends On` uses the cross-reference notation below; `--` means no dependency.

`Status` is the section's own completion state and flips to `[x]` **only** when a `Verified:` stamp covering that section exists. The two are checked together.

## Cross-reference notation

| Form         | Means                                 | Example      |
| ------------ | ------------------------------------- | ------------ |
| `§N`         | Section N of this same file           | `§3`         |
| `TNN §N`     | TODO-NN in the same domain, section N | `T02 §1`     |
| `DNN TNN §N` | Domain NN, TODO-NN, section N         | `D03 T01 §4` |

Never a bare number, and never a cross-TODO reference without a section. `D03 T01` alone is not a dependency: it is a vague gesture at one.

**Cross-references are bidirectional.** If this file's Inputs point at `D03 T01 §4`, then `03-system-tools/TODO-01.md` must point back at this file. One-sided XREFs are broken XREFs, and the validator flags them FATAL.

## Proof: what a Test checkpoint may cite

Resolute is C++23 on Windows, built with CMake and vcpkg, linked against a static wxWidgets. A checkpoint cites one or more of these five, and **it must be able to fail**:

| Proof | What it is | What it cannot prove |
| ----- | ---------- | -------------------- |
| **Builds clean** | The touched targets build at the project warning level with warnings as errors, for both architectures. The baseline gate every code section owes. | That the code does the right thing. It is a compile gate, nothing more. |
| **Static analysis clean** | `clang-tidy` reports nothing new on the translation units the section touched, measured against the ratchet baseline. | Runtime behavior. Clean analysis over wrong logic is still wrong logic. |
| **Unit test** | A Catch2 test in `tests/` asserting a named behavior. Cite the test name. | Anything on the rendered surface. A unit test over a UI section is a supplement, not a substitute. |
| **Driven run with evidence** | Launch the built executable, drive the surface, and record the observable result: a log line, an `.ini` value read back, or a screenshot committed under `docs/captures/`. | Repeatability. A driven run is evidence of one run, so the section says what was driven and what it produced. |
| **Parity proof** | The C++ tool and its `resolute_au3/` counterpart run against the same fixture, and their effects are compared field by field. **Every ported tool owes this one.** | Anything about a surface that has no AutoIt counterpart. New work cites the other four and says so. |

Until `D00 T01` ships the build and `D00 T02` ships the harness, a section says which gates do not exist yet. A checkpoint that cites a gate which does not exist is unfalsifiable, which is the one thing a checkpoint may never be.

**Every code section owes a clean build.** A section that changes a `.cpp` and cites only a screenshot has skipped the cheapest gate it had.

### Parity is the load-bearing proof of this project

The rewrite is 1:1 on behavior. `resolute_au3/` is not legacy to be cleaned up: it is the specification, and a port is finished when it demonstrably does the same thing.

A parity proof names the fixture, runs both builds against it, and compares the resulting state rather than the exit codes. "Both returned success" is not parity. For a frozen tool the comparison is the freeze check, and the two are satisfied by the same run.

Parity does **not** extend to the rendered surface. The C++ windows are DPI-aware and theme-aware; the AutoIt windows are neither. Comparing them pixel to pixel would freeze the defects the rewrite exists to fix.

## Stamps

A stamp is a blockquote recording verified work, written **at the end of the section it covers**: after the test checkpoint, with that section's deferrals beneath it. It is the section's conclusion: you read what was asked, then what was actually proven.

```
## 3. Memory Trim Loop

One paragraph of context, then the checklist.

**Test checkpoint:** …

> **Verified:** 2026-09-16 | §3 | build clean both arches · clang-tidy 0 new · driven run trimmed 412 MB, log line quoted
> **Deferred:** per-process exclusion list -> XREF: D05 T01 §6 -- needs the settings store first
> **Review:** round 1, fingerprint `a3f91c2e5b04` -- `adversarial` approve · `consistency` approve · `integration` needs-attention (1). Raw findings: docs/reviews/05-memboost/D05-T01-s3.md
> **Plan review:** sol high, no findings (run 20260919-D05-T01-S3-sol)
> **CRUD:** applicable | driven run: set the interval in Settings, readback from `MemBoost.ini`, restart, value survived
> **Implementer:** assistant name (model-id)
```

Stamp prose cites full `DNN TNN §N` refs on stamps dated after 2026-09-20, including the section's own: no same-section exemption, and multi-commit Review lines tag every candidate `` `oid`(round N) ``. Ownership pointers (`Deferred:`, `Resolved:`, `Depends On`, `-> XREF:`) keep their short XREF grammar; records stamped on or before 2026-09-20 stand as history.

Alternative markers, one per stamp (the last marker line governs, so these never stack):

```md
> **Plan review:** sol high, filed D00 T01 §16 (run 20260919-D00-T01-S16-sol)
> **Plan review:** sol outage then Opus auth failure, outage: both rungs (owner ann, due 2026-09-25)
> **Plan review:** sol high, filed D00 T01 §16 (run 20260919-D00-T01-S16-sol-r2, supersedes 20260919-D00-T01-S16-sol)
> **Plan review:** sol high, partial: opus rung, filed D00 T01 §16 (run 20260919-D00-T01-S16-sol)
```

- `Verified:` -- date, sections covered, and the *evidence*: real command output, not "it works".
- `Deferred:` -- one line per deferral, each naming a concrete owner via XREF. A deferral without an owner is an abandonment.
- `Review:` -- the independent review's cost and outcome: rounds, each lens's verdict with its finding count, then a link to the raw findings under `docs/reviews/`. A `Review:` line names its round and its candidate fingerprint, so a stale record cannot satisfy a freshness check for a different candidate.
- `Plan review:` -- the second-family round's completion marker: which family ran it and the filings it produced, `no findings`, `outage: <rung> (owner <name>, due <YYYY-MM-DD>)` when both runners failed, `retry-owed (owner <name>, due <YYYY-MM-DD>)` on a same-family fallback run, or `partial: <rung>` when one rung failed and the other's findings stand (filings beside `partial:` are the survivor's; the failed rung is `gpt rung` or `opus rung`: a fallback survivor owes `retry-owed (owner, due)`, a primary survivor carries no retry and no accountability fields). Lineage: every marker over a review record carries `(run <YYYYMMDD-DNN-TNN-SN-family[-rN]>)` minted by the `run-id` subcommand, the run's date prefix is its timestamp; within one date base the bare base is run 1 and `-rN` is run N for N >= 2 (numbering restarts per day, the date keeps runs distinct) (`-r1` is run 1's synonym and reads as the base in every comparison, `-r0` is outside the shape); genesis is a singleton marker (run, no supersedes), and a rerun marker chains with `supersedes <prior-run>` or with `follows-outage` when the immediately preceding marker is an outage marker; runs never repeat within a section and the last run is one the manifest carries. A rerun opens a new `Plan review` record (rows number past the file max across records). Grammar: the last marker line governs; `no findings` never sits beside filings; `outage:` never sits beside filings, `no findings`, `retry-owed`, or `partial:`; `partial:` composes with `retry-owed` exactly when the survivor is the fallback. Counts read in accepted findings (triaged ledger rows) versus implementation items (checklist lines); a merge states both numbers. Required on stamps dated after 2026-09-19; earlier stamps predate the rule.
- `Reopened:` -- `<YYYY-MM-DD> | <finding ref> | <reason>`, naming the audit locus whose finding voids the stamp. A reopened section reads as unverified everywhere downstream: its row must be `[ ]` and its stamped dependents park until it re-stamps.
- `Retired:` -- `<YYYY-MM-DD> | <section ref> | <reason>`, migrating a grandfathered stamp without asserting a review that never ran. Validator-silent prose by design (no validator class reads it, so it owns no rule-table row); plan-health drains stamps carrying a well-formed note (real date, ref naming the section, non-empty reason) out of grandfathered, and malformed notes read as absent so the stamp stays listed.
- `CRUD:` -- behavioral evidence for the section: the write path exercised and read back, not just checked for syntax. Either `applicable | <what ran and what it proved>` or `not applicable (<reason>)`. A section with a `**Job:**` cannot claim not applicable.
- `Started:` -- optional UTC instant written when implementation starts. Do not overwrite on resume.
- `Duration:` -- optional minutes or instant range from `Started:` to stamp (implement, review, and stamp): either integer minutes (`7`, `45m`) or `<start> to <end>` Zulu instants (`2026-09-19T14:54:33Z to 2026-09-19T16:35:19Z`). The range end orders clearance: when both reviews carry ends the target must complete strictly after the finding's review, else day stamps rule and same-day fails closed.
- Clearance tokens -- a section clearing a filed critical names `fix <sha>` (or `fix <base>..<tip>` for a multi-commit loop, base excluded) and `proof <finding-id> <path>[::<test>]` in its own text; the query proves the fix against git and the proof against the fix tree, and a clearance missing either stays listed.
- `Implementer:` -- optional `Name (model-id)` recording who built the section.
- `Resolved:` -- a deferral that has been closed. Replaces the `Deferred:` marker **in place**, keeping the original text and XREF and adding the date and what closed it. Closure is a state change, not a deletion: what was owed, and who paid it, both stay on the record.

### A deferral cannot be left to rot

A deferral hands work to another section, and the parser resolves the owner and notices when the owner ships. Four rules close the loop, and the important one is **fatal**:

| Condition                                                                                                   | Severity    |
| ----------------------------------------------------------------------------------------------------------- | ----------- |
| The `-> XREF:` owner does not resolve to a real section                                                     | `FATAL`     |
| The `(item: "…")` names a checklist item the owner does not have                                            | `FATAL`     |
| **The owner has shipped it -- item `[x]`, or the section's row `[x]` -- and the line still says `Deferred:`** | **`FATAL`** |
| Marked `Resolved:` while the owner has *not* shipped it                                                     | `WARN`      |
| No `-> XREF:` owner at all                                                                                  | `FATAL`     |

The stale case is fatal because advisory is what lets rot happen. The moment a section ships, any deferral waiting on it turns the build red until someone closes it: so **the section that resolves a deferral is the section that closes it**, which is also the only moment anyone has the information to write the closure line.

A deferral whose owner has *not* shipped is not stale; it is pending, and it stays open silently. Name the `(item: "…")` always: the contract below makes it required, because without it closure can only be detected when the whole target section completes, which is much later and much coarser.

Write a closure as:

```
> **Resolved:** 2026-09-16 | <the original text> -> XREF: D05 T01 §6 (item: "…") | closed by `ac90135`
```

`query deferred` lists open and resolved separately. Staleness is not reported there, because a stale deferral cannot reach that list: `validate` fails first.

### The struck-item deferral contract

A struck checklist item (`- [ ] ~~…~~`) hands its work to an owner section, and three rules make the handoff checkable, all FATAL under the partial-flip family. They diverge from the stamp-line lifecycle's containment on purpose: a stamp line matches by containment, but a deferred item must match word for word, because a containment match would bless a reworded item as the same debt. The reason for the divergence is that the stamp lifecycle answers "is this section's work recorded" while the deferral contract answers "is this exact debt still owed", and only the second question needs the words.

1. The forward `-> XREF:` names the item: `(item: "…")` rides the XREF line (rule: untyped forward, `names no item`; self-test fixture §29). A bare XREF fails: the handoff names no debt.
2. The owner carries those exact words in order and consecutively, as whole words (rule: item carry, `carries no such item`; self-test fixtures §33 for substring, §35 for reorder). `net` inside `network`, or the same words shuffled, fails: the item was reworded or removed.
3. A shipped owner records the debt done: `> **Resolved:**` citing the deferrer with `(item: ...)` matching the deferred item verbatim after stripping (rule: shipped proof, `without recording the debt done`; self-test fixtures §23 no-proof, §37/§38 section-only, §39/§40 item-citing pass, §41/§42 wrong-item; passing twin §25/§26 now item-citing). The closure lives in the owner, beside the shipped work, in the shape above.

**Two kinds of rot the validator cannot see**, both owned by `process-todo-section`'s fact-check: a deferral whose *description* has drifted while its owner is still legitimately open, and one whose work was quietly done by someone who never ticked the owning box. Neither is stale by the rule above, so both need a human reading the line against today's repository. Closing the second means ticking the owner's item too; leaving it unticked moves the rot up a level rather than removing it.

**The stamp lives with its section, not in a block at the top of the file.** The stamp belongs where the question gets asked: at the end of the section it covers.

The parser finds stamps anywhere in the file and maps each to its section by the `§N` in the body, so the `§N` stays in the text even though the heading above it already says so. That redundancy is what lets one stamp cover a range (`§1-§3`) and what keeps the format position-independent.

For the whole file at a glance, read the Implementation Order table: `[x]` cannot exist without a stamp covering it, and the validator makes that a FATAL.

Re-verification replaces the stamp line in place. Never accumulate duplicates.

## Frozen behavior

Some behaviors are dangerous to get wrong: they write to the registry, take ownership of files, re-register system components, or repair a drive on a machine that is not a test rig. A tool that computes the wrong value there does not fail a test, it damages a user's system.

Any TODO touching one sets `frozen: true` in frontmatter, and every section that changes a frozen behavior carries a freeze check alongside its test checkpoint:

```
**Freeze check:** Registry backup and restore round-trips `HKCU\Software\Rizonesoft\Fixtures` value for value, and the restore path refuses a backup whose hive header does not match. Fixture source: tests/fixtures/rebar/.
```

Restructuring frozen code is allowed. Changing what it *writes* requires operator approval logged in the Freeze Register: the TODO records the approval, it does not grant it.

The frozen set as of this file: registry write and restore paths (`ReBar`), ownership and ACL takeover (`Ownership`), COM re-registration (`ComIntRep`), drive-level repair actions (`USBRepair`, `DVDRepair`), and the working-set trim path (`MemBoost`). A tool joins the set by being listed here and setting the flag in the same commit.

## Surface fidelity

The freeze check has a visual twin. Resolute is not a clone of somebody else's product, so fidelity here means the **house style**: every tool in the suite looks and behaves like the rest of the suite, because they share one SDK.

**Every section that builds or changes a user-facing surface carries a `Fidelity:` block** naming the house-style source it must match and the captured artifact(s) under `docs/captures/`.

The binding rules live in [`DESIGN.md`](../DESIGN.md) at the repository root; the captures are its visual reference. Where a capture and the contract disagree, **the contract wins** and the capture is restaked. A `Fidelity:` block never restates a rule from the contract, it points at it:

```
**Fidelity:** Resolute standard tool window (title band, GDI+ progress bar, status strip, About dialog) -- docs/captures/house-style/. Control order, spacing, font, and terminology match the capture; deviations only from the approved list.
```

**The same sections carry the documentation duty:** shipping or changing a user-facing surface updates `Resolute/Docs/<Tool>/Readme.txt` and the user-guide page for that surface in the same commit; review checks it before stamping. `process-todo-section` refuses to build a surface whose named artifact does not exist: that means the capture has not shipped for it, and building from a one-line description freezes a guess instead of the real thing. `review-todo-section` compares the rendered surface against the artifact before stamping. A genuinely new surface with no counterpart anywhere in the suite says so explicitly: `**Fidelity:** new build, no baseline` -- so silence is never ambiguous.

### Surface completeness: what a UI section owes beyond looking right

A `Fidelity:` block governs how a surface **looks and is laid out**. It says nothing about whether the surface **works**. So a section that builds a user-facing surface owes an account of **every control, menu item, dialog, and permission** on it, each resolved to one of two states:

- **Working** -- proven on the rendered surface, with real data. For anything that lists data, the evidence is the **content beside the source it was read from**.
- **Deferred to a named section** -- and the name must resolve. `python scripts/todo-graph.py resolve '<ref>'` must not exit 1 or 2. **A control disabled with a reason that names no section is not deferred, it is missing.**

Deferral is legitimate and expected. What is not legitimate is deferral that names nobody, because it is indistinguishable from an oversight. `review-todo-section` refuses the stamp for an unaccounted control, and `process-todo-section` requires the decision at build time so it is not discovered at review.

### The second layer the runner reads

Every section that builds or changes a user-facing surface carries three blocks next to `Fidelity:`:

```
**Job:** <the user> can <the verb this surface exists for>. Consumer: <what reads the write, or "none: this surface is the consumer">.
**Treatment:** <the asked treatment, named so a substitute can fail>. Cheaper substitute that fails the checkpoint: <the wrong thing>.
**Chrome:** consume <named shared headers from the framework or the repair contract>. Do not invent a second <pattern>.
```

`Chrome:` is load-bearing in this repo. Fourteen tools share one framework, and the failure mode this suite has already lived through is a tool growing its own progress bar, its own About dialog, or its own settings writer instead of consuming the shared layer. The AutoIt suite ended up carrying fourteen copies of its framework exactly that way. A second implementation of a shared control is a defect, not a shortcut.

A section whose Fidelity line says the work has no surface of its own ("no surface of its own", "not a surface", "the library is not a surface") skips these three.

A section that cannot run without a live host or device the plan cannot otherwise see carries one more line, anywhere in its body:

```
**Needs:** Windows host (build/test)
```

The value comes from a closed list (`todo-graph.py` `NEEDS_ALLOWED`; `validate` refuses any other): `Windows host (build/test)`, `C++ toolchain (compile)`, `Optical drive (drive test)`, `USB device (drive test)`, `Signing certificate (release)`, `Clean Windows machine (no Visual Studio)`. `resolve` prints it as `needs`, so a future runner can skip the row while the device is not attached and take the next unblocked row instead.

A section that cannot run without an environment capability the plan cannot otherwise see carries one more line, anywhere in its body:

`**Requires:** display-session -- convicted by <measurement pointer>`

Values are comma-separated closed vocabulary (`todo-graph.py` `REQUIRES_ALLOWED`); the reason after ` -- ` is required and cites the measurement that convicted the section. `validate` refuses an unknown value (`requires-unknown`) and a mark without its reason (`requires-no-reason`), both FATAL. `query ready` splits dependency-ready rows into runnable-now (requirements met by the runner's context) versus runnable-elsewhere (requirements named per row); `resolve` prints the line with the local verdict. The runner's local context is detected (`display-session` holds on Windows with `SESSIONNAME` naming an interactive session -- never session 0 (`Services`), never elsewhere); `query ready --context` evaluates a declared set instead, for planning. Shipped sections are grandfathered: no retroactive marking, and a mark added later needs its reason like any other. `Needs:` (host) keeps its own closed list and its pre-start host check; the two lines compose, never merge.

| Value | Means | Detected how (local context) |
| ----- | ----- | ---------------------------- |
| `display-session` | A Windows interactive session able to show windows: driven runs of the built tools, eyeball checks, captures instead of black frames | `sys.platform == "win32"` with `SESSIONNAME` naming an interactive session (not `Services`, never empty); every other context evaluates False |

A section whose open work is worked OUTSIDE this tree carries a `Moved:` marker under its heading:

```
> **Moved:** 2026-09-16 to docs/plans/<plan>.md (operator instruction); worked there by its named owner.
```

The section keeps its Implementation Order row (`[ ]`, never ticked without a stamp) and every cross-reference, so addresses stay stable and `validate`'s reciprocity still holds. What changes is what the graph does with it: `query ready` and `query blocked` skip it, `query stats` counts it on its own `moved` line, `resolve` prints a `moved` line and exits 5, a dependency ON a moved section counts as met (section edges and whole-TODO edges alike: its row can never flip here, so a dependent waiting on it would wait forever), and `plan --sync` replaces its plan row with one `> **Moved:** \`DNN TNN §N\` -- ...` line at the end of the table the row sat in, which `plan --check` requires and the progress arithmetic never counts. The body's first `path/to/file.md` must exist, or `validate` is FATAL (`moved-target-missing`). Its remaining open items are struck in place with the same pointer so nobody reads them as work owed here.

The Job line is what completion measures. The Treatment line is what a cheaper substitute fails against. The Chrome line is what shared-style review gates. Naming them on the section is how the runner does not have to reconstruct them from a Goal paragraph.

## Section sizing

Max 30 checklist items per section. The validator warns above that; it is a ceiling, not a target.

Size a section by what holds together, not by a number. Two forces pull in opposite directions and both are real:

- **Too large** exhausts a fresh worker's context halfway through, and gives review more surface than it can cover well in one pass.
- **Too small** multiplies cost. A section is the unit the review contract prices, so three thin sections cost three review cycles where one coherent section costs one.

Split where the work genuinely divides: a different tool, a different include, a dependency boundary, the shared library separate from the tool that consumes it. Split at **authoring** time, not during implementation: splitting mid-flight costs a wasted context.

> **This guidance is unconfirmed, and deliberately unchanged. Checked 2026-09-17 by `D00 T04 §3`.**
>
> Nothing above is derived from measurement. `python scripts/todo-graph.py query calibration` compares each stamped section's item count against what it actually cost, and at the time of writing the sample was **6 stamped sections of 120**, far below the 30 that section records as the threshold for quoting a correlation.
>
> So the question was asked and the answer is "not yet". The guidance stays as written rather than being tuned to six observations, which would dress a guess in the authority of measurement. Run `query calibration` for the current count; when it stops refusing to report a correlation, this block is the thing to revisit.

### Feature adjacency: the surfaces a domain owes beyond its record

Section sizing above decides how work is split. This decides whether the work is *all there*, and it is answered **before the Implementation Order table is final**, not at review.

So a TODO file's `## Outcome` carries an **Adjacency** line naming which of these apply to the domain, and which do not, with a one-line reason:

- **List and filters** (`list`) -- can somebody find one of these records without knowing its identifier?
- **Document or print** (`document`) -- what does a user carry, send, or file? A saved report, an exported log.
- **Settings with a named consumer** (`settings`) -- every tunable value. A value that needs a reinstall to change is a defect, and a setting nothing reads is worse than none.
- **Reporting** (`reporting`) -- summaries and exports over the domain's own data.
- **Lifecycle notifications** (`notifications`) -- registered with recipient rules, not an address list. In a desktop tool this is the tray balloon, the sound, and the completion dialog.
- **Permissions, exercised on refusal** (`permissions`) -- for this suite, elevation. A tool that needs admin proves what it does when it does not have it. A hidden button is not a refusal.
- **Audit and history** (`audit`) -- who changed what, with the reason where one is required. The framework's logging layer is the suite's audit trail; a destructive action that writes no log line is unaudited.
- **Import or export** (`exchange`) -- wherever the tool reads or writes a file somebody else authored: an `.ini`, a `.lng`, a registry backup.
- **The reverse of every create** (`reverse`) -- cancel, reopen, delete, undo. An irreversible system change nobody can roll back is a support call, and in this suite it is the most expensive defect class there is.

**"Not applicable" is a declaration, not silence.** A gate script has no list; both say so in one line. The check is advisory (`query adjacency`), because the tool cannot know which kinds a domain genuinely lacks: but a file that stays silent and a file that decided are not the same thing, and only one of them is a plan.

**Executable declaration:** place one `**Adjacency:**` line inside `## Outcome`. Write every key exactly once, separated by semicolons: `key=applicable`, `key=applicable @ DNN TNN §N` for an explicit cross-domain owner, or `key=not-applicable (source-backed reason)`. A narrow non-feature file may instead declare `all=not-applicable (reason covering its entire scope)`. It cannot mix the blanket form with individual entries. Preserve substantive decisions in an `**Adjacency rationale:**` paragraph; that prose is evidence for human review, not a second machine declaration. A missing/unknown/duplicate key, missing NA reason or declaration outside Outcome remains visible and prevents explicit closeout.

`python scripts/todo-graph.py query adjacency --json` derives owner candidates from positive Job, checklist and Build-order clauses, retaining source anchors. A reference must uniquely identify a real, non-Moved section with the claimed capability. These semantic matches require source review and do not prove runtime completeness.

Ordinary query and `validate` print `WARN [adjacency advisory]` without entering the existing structural warning ratchet. Before closing a file, run `python scripts/todo-graph.py query adjacency --file 'todo/NN-domain/TODO-NN-name.md' --require-owned`; refuse closure on missing/undeclared/unowned obligations and name the diagnostic.

## Work items: one checkbox is one buildable step

A section that only names an outcome ("clean up Firemin") leaves a cold agent to invent the function, the include, the ini key, and the cheaper substitute. That is how four browser tools end up with four copies of one bug, and how a setting ships that nothing reads.

Each checklist item except `Commit:` is a **micro-step**. Required on new work:

1. **One action.** One file, function, include, command, or control. If you need "and then" to describe it, it is two items, or one item with numbered sub-steps.
2. **A named path** in backticks (`src/framework/Logging.h`, `MemBoost::TrimWorkingSet()`, `clang-tidy`). A verb with no object ("improve logging") is not an item.
3. **Done when.** The observable end state in the same bullet. Example: "Done when: the restore path refuses a backup whose header does not match, and logs the refusal."
4. **The cheaper substitute** on any UI or write item, so the Test checkpoint can fail on it.
5. **A source cite** when behavior is copied: a file and line, an existing tool that already does it, a Microsoft docs URL for a Win32 call.

Numbered sub-steps (`1.` `2.` `3.`) under an item are the **procedure** for that one checkbox. They are not extra Implementation Order rows and they do not get their own review cycle. Use them when the action has a fixed order (include, then implementation, then check, then wiring).

**Build order** (a numbered list of files above the checklist) is the allowed retrofit on an already-written open section: it directs a cold agent without rewriting item text a deferral may name. Every numbered Build-order stage carries the same two non-negotiable anchors as a new micro-step: at least one intended implementation path, function, include, runnable command, or concrete source/evidence artifact in backticks, plus a literal observable `Done when:` in that stage. Put the cheaper substitute in the relevant UI/write stage. Prefer micro-step items on new work.

Split into a new `## N.` when the work has a different dependency, a different tool, or would push the parent past 30 items. **Split into a new FILE at 55 sections**, which `validate` enforces as FATAL: a section number is a permanent address, so a file only ever grows and can never be renumbered to tidy up. Split by subject, and leave every existing section exactly where it is. Do not split a stamped section.

**Do not rewrite a `[x]` section's checklist.** That is the contract the stamp covers. New granularity on shipped work is a new section.

## Completion-first

A section ships whole or it does not ship. Complete means every micro-step `[x]`, the Test checkpoint quoted from a real run, and a `Verified:` stamp written by `review-todo-section`: a `[x]` row with an open checklist reads as done while work remains, so it is a defect, not a head start. The `Commit:` micro-step is the one exception to the ticked rule: it is ticked in the implementation commit, and the row determines the reading of an unticked one (`[ ]` means doing, `[x]` means excused by syntax, the commit being proven by history rather than by the checkbox).

What cannot ship now is filed, not dropped: through `add-todo` with an owner, as a new section, an item on an open section, or a deferral the owner closes. Night-owed test debt (`D00 T02 §10`) is the same shape with a collector instead of an owner: recorded on the stamp, collected by the nightly run plus idle-unlocked daytime runs, with hardware-absent debt re-probing nightly until it can collect. Age is report information, and collection never waits for a decision. Waiting is never a strategy: a blocked row parks with its blocker named, and work that can proceed does.

Reviewers refuse stamps on partial scope. The mechanical check (a `[x]` row with an open checklist fails `validate`) is owned by `D00 T04 §19`.

## Tooling

```bash
python scripts/todo-graph.py build      # parse todo/ -> build/todo-cache.json
python scripts/todo-graph.py validate   # structural + graph integrity checks
python scripts/todo-graph.py self-test  # the script's own suite; must stay green
python scripts/todo-graph.py query ready        # sections with all deps met, split into runnable-now versus runnable-elsewhere by the runner's context
python scripts/todo-graph.py query blocked      # sections waiting on something
python scripts/todo-graph.py query stats        # tree health
python scripts/todo-graph.py query plan-health  # review-loop governance: --json emits schema plan-health/4 (total sort keys, exits 0); --check/--fail-on gate automation
python scripts/todo-graph.py query summary      # operator digest: incomplete runs, blocked clearances, overdue owners, next action, gate verdict (text-only; exits 1 when the gate fails)
python scripts/todo-graph.py query run <id>     # one run ID resolves to candidate, scope, findings, lineage, outage, artifacts
python scripts/todo-graph.py render             # mermaid dependency graph
python scripts/todo-graph.py plan --sync        # re-derive the checkboxes AND re-align every table
python scripts/todo-graph.py plan --check       # fail if the boxes are stale
python scripts/todo-graph.py resolve 'D03 T01 §3'   # ref -> file, section, deps, status
```

The scripts are stdlib-only by design: no install step stands between a fresh clone and validating the plan. Use `python3` instead of `python` where that is what your shell has.

`resolve` is the front door for the two section skills, and it takes whatever you already had in front of you: a `DNN TNN §N` reference, a `<path> §N` pair, or a row pasted straight out of `implementation-plan.md`, backticks, pipes and all. Its exit code carries the verdict: `3` means the section is already `[x]` (audit stance, not implementation), `4` means a dependency is unmet, `5` means the section moved out of the tree. So

```
process todo section: | [ ] | `D00 T01 §2` | Warnings-as-errors gate over every target | 6 |
```

is a complete instruction: nobody has to translate domain `00` and TODO `01` into a filename, which is the step that gets done wrong at 3am.

`build/` is gitignored: the cache is always reproducible from the markdown.

[`implementation-plan.md`](./implementation-plan.md) is the second derived artefact, and the only one that is committed: it is prose a person reads, so it cannot live in `build/`. Its boxes are a projection of the Implementation Order tables and **are never ticked by hand**; `plan --check` runs in CI so a stale projection fails the build instead of quietly misinforming whoever reads it next. Run `plan --sync` after any row flips.

**CI enforces exactly this contract and nothing more.** The todo workflow runs `validate` on every push touching `todo/`, `scripts/todo-graph.py`, or the workflow itself, so a FATAL (or a NEW warning) fails the build like any other defect.

### FATAL blocks; WARN is ratcheted

`validate` reports two severities under a **two-layer contract**: a FATAL always exits `1` and is never ackable; a WARN is ratchet-managed, so one already in `todo/.warning-baseline` or the ack ledger exits `0`, while a NEW one prints as `WARN*` and exits `1` until it is fixed or deliberately accepted with `warnings --accept`. "Advisory" therefore describes only warnings that are already baselined or acked, never a new one.

| Severity | Exit code | Meaning |
| -------- | :-------: | ------- |
| `FATAL`  |    `1`    | The graph or the format is broken: a `Depends On` that does not resolve, a section without its Implementation Order row, a row without its section, a one-sided XREF, a deferral with no owner, a `superseded` TODO with no successor, and every other structural class in the per-class table below. Fix it before doing anything else. |
| `WARN`   | see below | Ratchet-managed: a warning already in `todo/.warning-baseline` or the ack ledger exits `0`; a NEW one prints as `WARN*` and exits `1` until fixed or deliberately accepted with `warnings --accept`. |

**The per-class map, mirrored from `SEVERITY_MAP` in `scripts/todo-graph.py`: the self-test compares this table to the map row-for-row, so editing one without the other fails `self-test`.** The rule is push-time actionability: FATAL where the fix is mechanical and the defect is a structural-integrity break; WARN where the fix is a judgement call a red build cannot resolve.

| Class | Severity | Why |
| ----- | -------- | --- |
| `over-section-cap` | FATAL | A TODO file may hold at most **55** sections. Past that the next work opens a NEW file in the same domain, split by subject. Section numbers are permanent addresses, so a file can never be renumbered or made smaller. |
| `duplicate-source-key` | FATAL | Two sections claim the same `-> SOURCE: <key>`. An automated filer stamps what it filed FROM, so a scanner that runs twice a day cannot open a second row for one build failure. |
| `evidence-citation-short-form` | FATAL | New evidence cites full `DNN TNN §N` refs on stamps, findings files, and attestations; pre-cutoff records stand as history. |
| `review-citation-role-less` | FATAL | A multi-commit Review line tags every candidate with its round; round-to-commit mapping must be mechanical. |
| `review-citation-role-mismatch` | FATAL | A round tag matching no recorded panel round, or two candidates sharing one round; the mapping must correspond, not merely exist. |
| `superseded-no-successor` | FATAL | A superseded TODO must name where its work went; mechanical. |
| `filter-overclaim-open` | FATAL | An open checkpoint that cannot detect its promised regression; naming the tests or scripts is a two-minute fix. |
| `filter-overclaim-stamped` | WARN | The stamp must not be reopened; the fix-forward channel owns it. |
| `no-commit-item` | FATAL | One section = one commit is the format's core contract. |
| `partial-flip-shipped` | FATAL | An unticked micro-step outside the exemptions inside a `[x]` section breaks the shipped claim itself. |
| `commit-history-unreadable` | WARN | History the `Commit:` binding cannot read is unverified, not broken; a bare-tree export must still validate. |
| `fidelity-missing-lines-open` | FATAL | A Fidelity surface with no Job/Treatment/Chrome is unimplementable in house style. |
| `fidelity-missing-lines-stamped` | WARN | Fix-forward: the gap is real, the stamp stays. |
| `no-checklist-items` | FATAL | An empty section is unimplementable (co-emits `no-commit-item`). |
| `over-30-items` | WARN | Sizing is a judgement call; a red build cannot split a section. |
| `frozen-no-freeze-check` | FATAL | A frozen TODO without its check is a safety-marker mismatch; mechanical either way. |
| `freeze-check-not-frozen` | FATAL | A Freeze check in a TODO whose frontmatter does not say `frozen: true` is the same safety-marker mismatch in the other direction; mechanical fix. |
| `bare-todo-ref` | WARN | Prose legitimately mentions a TODO file without a section. |
| `one-sided-xref` | FATAL | This spec calls it broken; the validator agrees. |
| `deferral-no-owner` | FATAL | A deferral with no owner is an abandonment. |
| `resolved-owner-unshipped` | WARN | Recording early resolution is evidence, not a defect. |
| `missing-from-index` | FATAL | Two-line mechanical fix; discoverability is structural. |
| `malformed-stamp` | FATAL | A `Verified:` line the parser refused. It reads as evidence while verifying nothing, so it is worse than a missing stamp; the fix is to write the line correctly. |
| `needs-unknown` | FATAL | A `**Needs:**` value outside the closed list in `todo-graph.py` (`NEEDS_ALLOWED`). The list is closed so a misspelt host cannot silently unmark a section that cannot run without it. |
| `moved-target-missing` | FATAL | A `> **Moved:**` marker that names no file, or a file that does not exist. The marker takes the section out of `query ready`, the plan and the progress totals on the strength of that pointer, so a dead pointer would hide work. |
| `pending-control-contract` | FATAL | Reserved: the coming-soon inspector is not ported yet, so this class cannot fire until it lands. |
| `stamp-no-opus-panel` | FATAL | A stamp dated after the Opus-panel rule landed whose findings carry no panel verdicts. It reads as reviewed evidence while verifying nothing. |
| `requires-unknown` | FATAL | A `**Requires:**` value outside the closed list in `todo-graph.py` (`REQUIRES_ALLOWED`). The list is closed so a misspelt capability cannot silently unmark a section. |
| `requires-no-reason` | FATAL | A `**Requires:**` mark without its `-- reason`. The citation is what makes the mark auditable instead of vibes. |
| `stamp-no-plan-review` | FATAL | A stamp dated after the plan-review rule landed that carries no `Plan review:` completion marker. The second-family round is required procedure. |
| `plan-review-malformed` | FATAL | A post-cutoff plan-review record the query cannot parse: a `Plan review` section without its Manifest line or its Ledger block, a non-row line inside the block, or a content-illegal row. |
| `filed-target-no-backlink` | FATAL | A filed ledger row whose target file carries no back-link. The filing is untraceable from the target side, so remediation cannot be attributed to the finding. |
| `stamp-reopened` | FATAL | A `> **Reopened:**` line outside its shape, on a still-checked row, or with a still-stamped dependent. A reopen that does not void proof downstream lets work continue on invalid evidence. |
| `plan-review-duplicate-id` | FATAL | A finding ID appearing twice in one ledger. Multi-target findings ride one row with every target, never split rows. |
| `plan-review-no-lineage` | FATAL | A `Plan review:` marker without run lineage: no run ID, a reused run ID, a rerun marker naming no superseded run, or a run the manifest does not carry. |
| `ledger-history-violation` | FATAL | A ledger row whose disposition moved the forbidden way against the committed record, or a row that vanished. Later evidence amends via a new row, never by rewriting the old one. |
| `provenance-malformed` | FATAL | A post-cutoff findings file without a well-formed `Provenance:` line, or a provenance line outside the field shape, without a shaped run ID, with an unresolving candidate, a missing path, or a run no marker of its section carries. |
| `ledger-supersession-broken` | FATAL | A ledger row whose `supersedes` link names no row of its block, crosses review namespaces, or closes a cycle. |
| `risk-acceptance-malformed` | FATAL | A `Risk accepted:` line outside the record shape, with an uncoverable target, expiring before it is recorded, or reviewed outside its record-expiry window. |
| `risk-acceptance-silent-edit` | FATAL | A risk acceptance whose owning record changed after the evidence commit without a superseding record. |
| `risk-acceptance-chain-broken` | FATAL | A `supersedes <date>` link that names no earlier record on its target, points forward, branches, or cycles. |
| `skill-citation-unresolved` | FATAL | A skill citing a full section ref (`D00 T04 §6`) that resolves to no live section. |
| `skill-citation-short-form` | FATAL | A skill citing a short section form (bare `§6`, `T04 §6`, or `file.md §6`) instead of a full `DNN TNN §N` ref. |

Treat a warning as a decision to make rather than noise to clear. The tree starts at zero FATAL and zero non-baselined warnings, and it is worth keeping there.

## Skills

| Skill                   | Use                                                                              |
| ----------------------- | -------------------------------------------------------------------------------- |
| `add-todo`              | **Front door.** Route new work to the right domain, file, and section            |
| `create-todo`           | Author a whole new TODO file, wire XREFs, update indexes                         |
| `groom-plan`            | Harden the tree for a weaker executor: sequence, drift, gaps, complete features  |
| `process-todo-section`  | **Fact-check the plan, correct what has drifted, then ship exactly one section** |
| `review-todo-section`   | Quality gate after implementation; writes the stamp                              |
| `process-todo-file`     | Loose-end sweep and closure when every section is `[x]`                          |
| `process-phase`         | Attended phase runner: repair + gap-audit the phase, then ship it to 100%        |
| `process-plan`          | Front door for `implementation-plan.md`; chains ready phases                     |

When something needs doing, start at `add-todo`: it decides whether the work belongs in an existing section, needs a new one, warrants a whole new file (delegating to `create-todo`), or is already covered. Reaching for `create-todo` directly tends to produce a second TODO over an existing one.

