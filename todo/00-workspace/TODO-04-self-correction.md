---
schema_version: 1
id: self-correction
domain: 00-workspace
status: draft
title: "TODO-04 -- Self-Correction and Feedback"
depends_on: []
track: W1
---

# TODO-04 -- Self-Correction and Feedback

> **Goal:** The plan notices when it is wrong, repairs itself rather than accumulating drift, learns from what each section costs and what each review finds, and reorders itself as evidence arrives. Four properties, and none of them is automatic today.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** What exists is real but partial. `validate` proves the tree is **internally consistent**: every section has a row, every reference resolves, every stamp covers what it claims, and a stale deferral is FATAL. `plan --check` keeps the projection honest. `self-test` guards the tooling; the suite reports its own case count and this block deliberately does not repeat it. A warning ratchet is planned in `D07 T01 §2`. `scripts/todo-claims.py` exists and re-measures the factual claims TODOs make. **Corrected 2026-09-17:** this block said "11 claims live"; there are **30** today. No number is written here any more, because `--coverage` reports it and a figure duplicated in prose is a second source of truth that drifts. This block having gone stale while describing staleness detection is the argument for this section, not an embarrassment to hide.
>
> What does **not** exist: nothing notices that a `Current state` block has gone stale when it carries no claim; nothing records what a section actually cost against what it was estimated to; nothing categorises what reviews find, so the same class of defect can be found five times without ever becoming a check; and nothing re-sequences the plan when evidence says the order was wrong.
>
> The evidence this is needed: on 2026-09-16 the tree carried a section describing registry backup behaviour `ReBar` has never had, a submodule recorded as vendored source, one repair declared in two tools, and four skills instructing an executor to run `Au3Check` over C++. **Every one was caught by a human reading the tree.** That is not a process.

<!-- claim: count "COVERAGE_FLOOR = 3" scripts/todo-claims.py = 1 -->
<!-- claim: count "re.MULTILINE" scripts/todo-claims.py = 2 -->
<!-- claim: count "def collect_unterminated" scripts/todo-claims.py = 1 -->
<!-- claim: count "def _sync_items_cell" scripts/todo-graph.py = 1 -->
<!-- claim: count "def _plan_items" scripts/todo-graph.py = 1 -->
<!-- claim: exists scripts/todo-findings.py -->
<!-- claim: count "def render_ledger" scripts/todo-findings.py = 1 -->
<!-- claim: count "def _ignored" scripts/todo-claims.py = 1 -->
<!-- claim: count "def _calibration_rows" scripts/todo-graph.py = 1 -->
<!-- claim: count "CALIBRATION_MIN_SAMPLE = 30" scripts/todo-graph.py = 1 -->
<!-- claim: count "def _longest_chain" scripts/todo-graph.py = 1 -->
<!-- claim: count "def _filing_couplings" scripts/todo-graph.py = 1 -->
<!-- claim: count "FILED_TO_RE" scripts/todo-findings.py = 2 -->

## Inputs

- [`scripts/todo-claims.py`](../../scripts/todo-claims.py) -- the claim checker this file extends
- [`docs/reviews/2026-09-16-plan-audit.md`](../../docs/reviews/2026-09-16-plan-audit.md) -- the eight faults a manual audit found, and the argument for automating the search
- -> XREF: [`00-workspace/TODO-01 §5`](./TODO-01-toolchain-and-gates.md) -- the combined gate these checks join
- -> XREF: [`07-quality/TODO-01 §2`](../07-quality/TODO-01-quality-bar.md) -- the ratchet, which is the same idea applied to code quality

## Outcome

- A `Current state` block that has gone stale is reported, not discovered.
- A defect class found twice by review becomes a check, so it cannot be found a third time.
- What a section cost is recorded against what it was estimated, and the estimates improve.
- The plan's sequencing answers to evidence rather than to the order things were written in.

**Adjacency:** list=applicable @ D00 T04 §3; document=applicable @ D00 T04 §4; settings=not-applicable (this tooling owns no user-facing settings); reporting=applicable @ D00 T04 §3; notifications=not-applicable (a local check notifies nobody); permissions=not-applicable (no role model in repository tooling); audit=applicable @ D00 T04 §2; exchange=not-applicable (nothing is imported or exported); reverse=not-applicable (a check changes nothing that needs undoing)

**Adjacency rationale:** Audit anchors on §2 because the review ledger **is** the project's memory of its own defects, and a finding that is not recorded is a finding that recurs. List and reporting pair on §3 because calibration is only useful when somebody can see the pattern across many sections rather than one at a time.

## Implementation Order

| Order | Section | Deliverable                                | Depends On | Status |
| :---: | :-----: | ------------------------------------------ | ---------- | :----: |
|   1   |   §1    | Staleness detection for every claim-free block | --     |  [x]   |
|   2   |   §2    | The review-finding ledger                  | --         |  [x]   |
|   3   |   §3    | Section calibration                        | §2         |  [x]   |
|   4   |   §4    | Re-sequencing on evidence                  | §3         |  [x]   |

---

## 1. Staleness Detection for Every Claim-Free Block

A claim protects a figure somebody thought to record. Nothing protects the rest, and the rest is most of it.

**Build order.** Detect before enforcing; a check that fires on a hundred existing blocks on its first run gets disabled rather than fixed.

1. **Report coverage first.** Count `Current state` blocks and how many carry at least one claim. Done when: `scripts/todo-claims.py --coverage` prints both and names the blocks with none.
2. **Add the date comparison.** A block states a verification date; compare it against the last commit touching the files it cites. Done when: a block whose cited files changed after its date is reported as suspect.
3. **Only then make it a gate.** Done when: the coverage threshold is set from the measured starting point and ratchets upward, exactly as the warning baseline does.

- [x] Report claim coverage per `Current state` block. Done when: `--coverage` names every block with no claim, and the count is recorded here as the starting point. **Measured 2026-09-17: 3 of 20 blocks carry a claim.** The seventeen that do not are named by `--coverage`, one per line with its file, line, and stated verification date. That 3 is the recorded floor, deliberately set to what was measured rather than to what would be respectable: a floor above the real number fails on its first run and gets deleted instead of met.
- [x] Detect a block whose cited files have changed since its stated verification date. Done when: a deliberately aged block is reported and a current one is not, both driven.
- [x] Distinguish suspect from wrong. Done when: the output says a block **may** be stale because its sources moved, rather than asserting it is, because the check cannot read prose.
- [x] Make coverage ratchet rather than threshold. Done when: coverage may not fall below its recorded value, and raising the floor is a recorded decision. Cheaper substitute that fails the checkpoint: requiring full coverage immediately, which produces a hundred claims written to satisfy a check rather than to record a measurement.
- [x] Sync the plan's **Items** column, which `plan --sync` does not touch today. Found 2026-09-16 while processing `D00 T03 §1`: the row read 6 items against an actual 11, and `plan --check` passed, because parity is enforced on boxes and status but not on counts.

  **Measured 2026-09-17, and it is not one row.** Comparing every plan row against `resolve`'s own item count: **28 of 121 rows disagree, 23 percent**, and `plan --check` reports the plan current. The largest gaps are `D07 T01 §3` (6 against 12), `D05 T01 §3` (8 against 14), and `D05 T05 §4` (9 against 15). A column that is wrong on a quarter of its rows is not a stale figure, it is a column nobody can use, and the plan's totals are what an operator reads to decide what to pick up next.

  Done when: the count is derived rather than typed, `plan --sync` rewrites it, and a stale count fails `plan --check` like any other parity failure, proven by editing one row's count by hand and watching the check fail. Cheaper substitute that fails the checkpoint: correcting the 28 rows by hand, which fixes today's numbers and leaves the next 28 to accumulate silently.
- [x] Register these checks for the combined gate, and prove them standalone today. **Corrected 2026-09-17:** the item said "wire into `scripts/check-all.ps1`", and that script **does not exist**: `D00 T01 §5` builds it. `AGENTS.md` rules that a checkpoint citing a gate that does not exist yet is unfalsifiable and not allowed, so this item cannot be satisfied as written and must not be ticked on a promise. Done when: `todo-claims.py` exits non-zero on a stale claim and on a fallen coverage floor, proven by running it directly on a deliberately broken fixture, **and** `D00 T01 §5` carries an item naming these two exit conditions as things its combined gate must surface. The wiring itself belongs to that section, which owns the script.
- [x] **Report a claim the parser could not see, rather than skipping it.** Filed 2026-09-17 by `D00 T03 §4`, which hit it: `CLAIM_RE` matches within a single line, so a claim whose pattern contains a real newline is split across two lines and matched by nothing. It is not reported malformed; the claim count simply drops. The failure is silent and inverted: a claim that should have failed loudly instead vanishes, and the total still reads "all hold". Done when: a claim comment opened with `<!-- claim:` and not closed on the same line is reported, proven by a fixture containing one. Cheaper substitute that fails the checkpoint: trusting the total, which is exactly what concealed it.
- [x] **Anchor line-oriented patterns without `^`.** Filed 2026-09-17, same section: `_check_count` compiles the pattern without `re.MULTILINE`, so `^` matches only at the start of the file and a claim using it silently counts 0. Done when: either `MULTILINE` is set and `^` means line start, or the limitation is documented next to the claim grammar with the working alternative, which today is a literal `
` prefix.
- [x] Commit: `"self-correction: report a current-state block whose sources moved"`

**Test checkpoint:** `python scripts/todo-claims.py --coverage` names every `Current state` block carrying no claim and prints the covered and total counts, and the starting figure is recorded in this section. A block whose cited files changed after its stated verification date is reported as **suspect**, and a current one is not, both driven against real files rather than described. The output says a block *may* be stale, never that it is. Coverage cannot fall below its recorded floor, proven by lowering it artificially and watching the check fail. `plan --sync` rewrites the Items column and `plan --check` fails on a hand-edited count, both driven. `todo-claims.py` exits non-zero on a stale claim and on a fallen floor. `--self-test` stays green and its case count rises, because every behaviour added here is a case.

> **Verified:** 2026-09-17 | §1 | `--coverage` names every claim-free `Current state` block and prints **4/20, floor 3**; the floor is the measured starting figure, not an aspiration · date staleness flags 13 cited files across **7** blocks as **suspect**, wording that says *may* be stale and never asserts · the live tree proves it: `D00 T03`'s block is flagged on `exokit/` and `shared/exo-ui`, paths `§3` renamed out of existence · the plan's Items column is derived, synced in place with alignment preserved, and **28 of 121 rows were wrong** while `plan --check` passed; hand-editing a count now exits 1 naming the row · a claim split across lines is reported malformed instead of vanishing · patterns compile with `re.MULTILINE` · `todo-claims --self-test` 13 to 24 cases, `todo-graph self-test` 393 to 400, both green
> **Review:** round 2, candidate `f875758` `6cb2e1b` plus the follow-up fix -- `adversarial` approve after fixes (4) · `consistency` approve · `integration` approve · `source-defect` approve · `design` not-applicable · `record` approve. Raw findings: docs/reviews/00-workspace/D00-T04-s1.md
> **Independent:** `codex review --commit f875758` (gpt-6-astra, high) returned **four findings, all correct**, and is why this review has two rounds. It did not treat green self-tests as sufficient: it wrote probes that constructed the failing cases, which found a coverage-gate bypass when no claims remain, a whole-plan floor applied to a subtree, deleted sources filtered out before the git check, and a malformed claim counted as holding. All four fixed in `6cb2e1b`. It did not find F5, a performance regression invisible to any probe that only asks whether the output is correct.
> **CRUD:** not applicable (this tooling reads the plan and writes only the plan's own derived column)
> **Duration:** 11
> **Implementer:** Claude Opus 5 (claude-opus-5[1m])

## 2. The Review-Finding Ledger

> **Started:** 2026-09-16T23:17:19Z

A defect class found five times across five sections should have become a check after the second.

> [!IMPORTANT]
> **Validated 2026-09-17 before implementation. Three corrections.**
>
> **The premise is half stale.** This section said findings "vanish once the section is stamped". They did when it was written; they do not now. `review-todo-section` writes a findings file per section, and five exist under `docs/reviews/00-workspace/` carrying **16 finding headings**. What is missing is not the record, it is the **aggregation**: nothing reads across those files, so a category repeating is still invisible.
>
> **`docs/reviews/findings.md` as a hand-maintained file would be the defect this project keeps hitting.** A second place to write a finding is a second source of truth, and it drifts exactly like a figure duplicated in prose. **Decided 2026-09-17: the ledger is derived, never typed.** The per-section findings files stay authoritative and a tool reads across them. Cost of changing: the tool parses one heading format, so a different format means rewriting the parser rather than the data.
>
> **The heading format is emergent and not yet a convention.** Measured across the five files: 16 headings, of which **3 carry no category** (`F2 -- the build is not reproducible -- FILED to D07 T01`, `F1-F4 -- raised by the independent review ...`, `F3 -- ... -- routed, not a defect`). A derived ledger has to report a heading it cannot parse rather than skip it, or the same silence that hid the split claims in `§1` returns here.
>
> **The tool is a new script, not a flag on an existing one.** `todo-claims.py` re-measures claims and `todo-graph.py` owns the plan graph; a findings ledger is neither. `scripts/todo-findings.py`, which this section's item allows as "an equivalent".

- [x] **Derive** the ledger from the per-section findings files rather than maintaining a second copy. **Corrected 2026-09-17:** the item named `docs/reviews/findings.md` as a place to *record* findings, which would make two homes for one fact. Done when: `scripts/todo-findings.py` reads every `docs/reviews/**/D*-T*-s*.md`, extracts each finding's section, number, summary, category, and disposition, and writes `docs/reviews/findings.md` as **generated output carrying a do-not-edit header**. Cheaper substitute that fails the checkpoint: a hand-written ledger, which is correct on the day it is written and wrong by the next stamp.
- [x] Use a small closed category set, and record it. Done when: the categories exist in one place the tool reads, and a heading using an unknown category is **reported**, not silently bucketed. Anything that does not fit gets a new category by decision rather than by invention at the point of writing.

- [x] Report a heading the parser cannot read. **Added 2026-09-17:** measured today, 3 of 16 existing headings carry no category. A ledger that skips what it cannot parse repeats the defect `§1` just fixed in the claims checker, where a split claim vanished and the total still said everything held. Done when: a malformed heading is listed with its file and line and the tool exits non-zero, proven against one of the three real cases.
- [x] **Make a repeat a trigger.** Done when: the second finding in one category raises the question of what check would have caught it, and the answer is recorded even when the answer is that no cheap check exists.

  **Answered 2026-09-17 against the real ledger.** Three categories are past two. **No counts are given below**, and that is the third time this file has learned it: writing this section added findings of its own, which moved `record` and `correctness` within the same session. The answers are about each category's *shape*, which is stable; `todo-findings.py` reports the counts, which are not.

  **`consistency`.** The shared shape is *a fact declared in one place and never reconciled with the other place that depends on it*: four claims citing a gitignored tree, `AGENTS.md` not listing directories the merge landed, a resource id defined twice, identifiers surviving a rename because the search pattern was narrower than the rule.

  One cheap check exists and is **built here**: a claim may not cite a path this repository ignores. That is the `§1` F1 case exactly, it costs one `git check-ignore` call per claim, and it would have failed on the day those four claims were written instead of surviving until a reviewer read them. The rest of the category has no single cheap check, and saying so is the honest half of this answer: "two things that should agree do not" is the definition of a defect, not a pattern a tool can recognise. What replaces a check is narrower rules, and `§3` adopted one when its rename pattern missed three identifier families: search for the old name in **any** spelling rather than the spellings somebody enumerated.

  **`record`.** The shape is *a figure or reference in prose that nothing re-measures*. This one already has its check and it is `§1`: claims re-measure figures, and `--coverage` names the blocks carrying none. Two of the five findings are specifically a figure describing the file it sits in, which no re-measurement can fix because writing the figure changes it. The rule that replaces a check is recorded in both places it bit: **do not state a count of a file inside that file**, and `todo/00-workspace/TODO-03-codebase-intake.md` and `TODO.md` both now say why no such count appears.

  **`correctness`.** Every one is the same inversion: *a check that reports success for its own absence*. The claims checker dropped an unparseable claim and still printed "all hold"; the coverage floor passed when every claim was deleted. The check is a discipline rather than a script, and it is now in this file: **a new check ships with a self-test that constructs its failing case**, not merely one that confirms the passing case. `codex` found two instances precisely by writing probes that built the failure, and `§2`'s own review found a third the same way. The category keeps growing because the discipline keeps finding things, which is the intended behaviour rather than a worsening score.

- [x] Build the one check the `consistency` repeat produced: a claim may not cite a gitignored path. **Added 2026-09-17** by the answer above. Done when: `todo-claims.py` reports a claim whose target is ignored by this repository, proven against a deliberately added claim citing a gitignored path, and the live tree passes. Cheaper substitute that fails the checkpoint: checking only that the path exists, which is what let four claims cite `samples/` for a day, because they did exist on the one machine that mattered.
- [x] Report the pattern. Done when: `scripts/todo-findings.py` prints counts per category and per disposition, so the shape is visible without reading every stamp. The tool is a new script rather than a flag on `todo-claims.py`, which re-measures claims and has nothing to do with review findings.
- [x] Record what the ledger cannot do. Done when: it states that a category count is a signal rather than a verdict, because an early category is often just the first section touching that area.

  **Written 2026-09-17.** Four limits, each one a way to read this ledger wrongly:

  1. **A count is a signal, not a verdict.** Every finding so far comes from five sections in one domain, all of them intake and tooling work. `consistency` leading is partly a fact about those sections and partly a fact about this project; the ledger cannot tell you which.
  2. **It counts what reviews found, not what exists.** A defect class nobody looks for scores zero, and scores zero most convincingly when no reviewer knows to look. The `record` category exists only because these reviews were told to check the record.
  3. **Category is assigned by the reviewer who wrote the heading**, which is the session that did the work. That is the same conflict the independent review exists to break, and the ledger does not break it.
  4. **It cannot see a finding nobody wrote down.** Findings caught and fixed mid-implementation, before review, never reach a findings file. The ledger measures the review process, not the work.
- [x] Commit: `"self-correction: a ledger of what review keeps finding"`

**Test checkpoint:** `python scripts/todo-findings.py` reads the real findings files and prints counts per category and per disposition, and the totals match the number of finding headings actually present, counted independently with `grep -c '^### F'`. `--write` regenerates `docs/reviews/findings.md` with a do-not-edit header, and running it twice produces no diff, proving the output is derived rather than accumulated. A heading with an unknown or missing category is listed with its file and line and the tool exits non-zero, proven against a real case rather than a fixture. A category reaching two occurrences prints the recorded question, and the answer for every such category is present in this section. `--self-test` covers parsing, the repeat trigger, and the unknown-category path, and stays green. The ledger's stated limits are written here.

> **Verified:** 2026-09-17 | §2 | `scripts/todo-findings.py` reads every per-section findings file and reports **19 findings across 6 sections**, with three categories past the repeat threshold · the ledger is **derived**: `docs/reviews/findings.md` carries a do-not-edit header, `--check` catches staleness, and `--write` twice produces no diff · a heading it cannot read is named with file, line, and reason in **every** mode, and `--write` refuses to publish while any remain, both driven · 6 of the 16 original headings carried no category and were corrected, after which the total matched an independent `grep -c '^### F'` · the repeat trigger is answered against real data for all three categories, and the one cheap check it produced is **built and proven to fire**: a claim citing `extensions/*/build/result.txt` is rejected, one citing `AGENTS.md` is not · the ledger's four limits are written down
> **Review:** round 2, candidate `43a299a` `e44995a` plus the follow-up fix -- `adversarial` approve after fixes (3) · `consistency` approve · `integration` approve · `source-defect` approve · `design` not-applicable · `record` approve after fix (1). Raw findings: docs/reviews/00-workspace/D00-T04-s2.md
> **Independent:** `codex review --commit 43a299a` (gpt-6-astra, high) returned **two P2 findings, both correct**, both probed before being accepted, both fixed in `e44995a`. The sharper one: the gitignored-path check this section had just built was bypassable by writing the same claim with a glob. It did not find F3, the heading pattern matching ordinary headings, which produces no false positive on today's files and so is invisible to any probe against the real tree.
> **CRUD:** not applicable (this tooling reads review records and writes only its own derived ledger)
> **Duration:** 9
> **Implementer:** Claude Opus 5 (claude-opus-5[1m])

## 3. Section Calibration

> **Started:** 2026-09-16T23:33:19Z

The plan estimates effort as an item count. Nothing has ever checked whether that number predicts anything, and after a hundred sections it either does or it does not.

> [!IMPORTANT]
> **Validated 2026-09-17 before implementation. Three corrections, and one of them decides what this section can honestly deliver.**
>
> **There are six stamped sections, not a hundred.** Measured today: `query stats` reports 6 done of 120. The whole dataset is:
>
> | Section | Items | Commits |
> | --- | ---: | ---: |
> | `D00 T03 §1` | 11 | 9 |
> | `D00 T03 §2` | 7 | 2 |
> | `D00 T03 §3` | 5 | 3 |
> | `D00 T03 §4` | 10 | 5 |
> | `D00 T04 §1` | 9 | 5 |
> | `D00 T04 §2` | 8 | 4 |
>
> **So the measurement can be built and the conclusion cannot be drawn.** A correlation over six points is noise with a number attached, and quoting one would be the most dangerous thing this section could produce: a figure that looks like evidence, gets cited, and was never evidence. This section therefore ships the instrument, prints the data, and **refuses to state a correlation**, saying so in the output rather than in a footnote.
>
> **Dated default 2026-09-17: thirty stamped sections before a correlation is quoted.** That is a judgement, not a derivation. Below about thirty paired observations a single outlier moves a correlation coefficient more than the underlying relationship does, and this plan already contains one obvious outlier: `D00 T03 §1` took nine commits because it was blocked mid-flight on an operator decision, which has nothing to do with its item count. Cost of changing: one constant, and the tool prints the threshold alongside the count so the gap is visible.
>
> **"Elapsed sessions" is not derivable from git.** The item asked for it. Git knows commits and their timestamps; it does not know what a session was. What **is** recorded and derivable is `Duration:`, the minutes from `Started:` to the stamp, which `review-todo-section` already writes. The item is corrected to name it.

- [x] Record per section what it actually cost: commits, `Duration:` minutes, and whether it needed a follow-up commit after review. **Corrected 2026-09-17:** the item said "elapsed sessions", which git cannot answer, because git records commits and timestamps and has no notion of a session. `Duration:` is the recorded equivalent and `review-todo-section` already writes it. Done when: `python scripts/todo-graph.py query calibration` prints the record for every stamped section, every figure derived from git or from the stamp rather than typed anywhere, **including whether the section needed a commit between its ship and its stamp**, which is review finding something and which a raw commit count cannot distinguish from ordinary implementation.

  **Two corrections after the independent review of `6fb88f3`, both about what "derived" has to mean.** The first version counted commits with `git log --grep=<ref>`, which matches the reference **anywhere in a message**. The commit introducing this very report tabulated all six stamped sections in its body, so it counted as a commit of every one of them: each row rose by one and the outlier vanished. A measurement its own documentation changes is not a measurement. Ownership is now the repository's commit convention, a subject line ending in `(<ref>)`.

  The second: git failing returned zero, and a non-zero exit was ignored entirely, so a broken repository produced a confident observation of a section that cost nothing and fed it to the outlier maths. A failure now raises and the report prints nothing, because an unanswerable question is not an answer of zero.
- [x] Compare against the item count. Done when: the report shows estimated items against actual cost for every stamped section, **and states whether the sample is large enough to support a correlation at all**. Cheaper substitute that fails the checkpoint: printing a correlation coefficient over six sections, which is noise with a number attached and is worse than printing nothing, because a figure that looks like evidence gets cited as evidence.
- [x] Identify the sections that were badly wrong in either direction. Done when: outliers are named, because a section that took five times its estimate usually means the section was really several.
- [x] Feed it back into sizing. **Corrected 2026-09-17:** the item required the `todo/README.md` guidance to be "confirmed by the data or revised", and at six sections neither is honest. Done when: the guidance is left **unchanged** with a dated note recording that the data is not yet sufficient, naming the threshold and where the current count is read from, so a later reader knows the question was asked rather than skipped. Cheaper substitute that fails the checkpoint: revising the guidance to match six sections, which dresses a guess in the authority of measurement.
- [x] Record what calibration cannot tell you. Done when: it states that a slow section may have been slow for reasons outside the plan, so an outlier is a question rather than a conclusion.

  **Written 2026-09-17.** Five limits, each a way to read this report wrongly:

  1. **An outlier is a question, not a conclusion.** `D00 T03 §1` cost 9 commits against 11 items, the furthest from the mean of any section. The reason is recorded and has nothing to do with sizing: it was blocked mid-flight on an operator decision about an unpushed upstream commit. Nothing in the item count could have predicted that, and nothing in the report can see it.
  2. **Commits are a proxy, not a cost.** A section that commits often is not necessarily expensive; it may simply have been worked in smaller steps. The independent review adds a commit to any section it finds something in, so `commits` partly measures how thoroughly a section was reviewed.
  3. **`Duration:` is wall-clock from `Started:` to the stamp**, so it counts interruptions, waiting on a build, and an operator answering a question. It is not time spent.
  4. **A correlation would not be a cause.** Item count and cost may both follow from something the plan never records, most obviously how well understood the work was when the section was authored. The report says this even above the threshold.
  5. **Only stamped sections appear.** A section abandoned, re-scoped, or still open contributes nothing, and those are exactly the sections whose estimates were most likely wrong. The sample is biased toward work that went well enough to finish.
- [x] Commit: `"self-correction: measure what a section actually cost"`

**Test checkpoint:** `python scripts/todo-graph.py query calibration` prints one row per stamped section with its item count, commit count, and `Duration:`, every figure derived rather than typed: proven by changing a section's item count and watching the row move. The report states the sample size against the threshold and **prints no correlation while the sample is below it**, proven by reading the output. Outliers are named with the reason they are outliers where it is known. `todo/README.md` carries a dated note that the data is insufficient, naming the threshold. `self-test` covers the derivation and the below-threshold refusal, and stays green.

> **Verified:** 2026-09-17 | §3 | `query calibration` prints one row per stamped section with items, commits, `Duration:` minutes, and **rework**, every figure derived: proven by adding one checklist item to `D00 T04 §2` and watching its row move 8 to 9, then back · it **refuses to state a correlation**, printing sample 6 against threshold 30 and the full reason, which is the section's actual deliverable · the outlier is named at 0.82 commits per item against a mean of 0.54, with its cause recorded as an operator block mid-flight that no item count could have predicted · a git failure raises and reports nothing, driven by pointing `REPO` at a non-repository, because an unanswerable question is not an answer of zero · `todo/README.md` keeps its sizing guidance **unchanged** with a dated note naming the threshold · five limits written
> **Review:** round 2, candidate `6fb88f3` `e6a9eda` `951e70a` plus the follow-up fix -- `adversarial` approve after fixes (3) · `consistency` approve · `integration` approve · `source-defect` approve · `design` not-applicable · `record` approve after fix (1). Raw findings: docs/reviews/00-workspace/D00-T04-s3.md
> **Independent:** `codex review --commit 6fb88f3` (gpt-6-astra, high) returned **three P2 findings, all correct**. The sharpest: commits were counted by mention, so the commit introducing this report tabulated all six stamped sections in its body and counted as a commit of each, raising every row and erasing the outlier. A measurement its own documentation changes is not one. It also caught a ticked item the implementation did not satisfy. It noted the 406 self-tests passed and covered none of the three, which is the more useful observation.
> **CRUD:** not applicable (this reads the plan and git history and writes nothing)
> **Duration:** 8
> **Implementer:** Claude Opus 5 (claude-opus-5[1m])

## 4. Re-Sequencing on Evidence

> **Started:** 2026-09-16T23:43:46Z

`query ready` answers what is dependency-safe. It does not answer what is **wise**, and the plan's order otherwise reflects the order things were written in.

> [!IMPORTANT]
> **Validated 2026-09-17 before implementation. Two corrections and one confirmation.**
>
> **"A section repeatedly blocked" is not derivable, because nothing records blocking over time.** `query blocked` is a snapshot: it reports 108 sections blocked right now and has no memory of what was blocked yesterday. No file in `scripts/` tracks a block count or a blocked-since date, checked by search. An item asking for a section "repeatedly blocked" therefore asks for a measurement this repository cannot make, and building it would mean inventing a history store that nothing else needs.
>
> **The other half of that item is derivable, and `§2` is what makes it so.** A finding filed from one section to another is recorded evidence that the first section ran into work the second one owns. Four exist today:
>
> | Filed from | To | About |
> | --- | --- | --- |
> | `D00 T03 §1` | `D00 T01 §2` | the build resolving its toolchain through a gitignored tree |
> | `D00 T03 §1` | `D00 T02 §1` | a scratch file tracked at the repository root |
> | `D00 T03 §4` | `D00 T04 §1` | the claims checker dropping an unparseable claim |
> | `D00 T03 §4` | `D06 T01 §8` | there being no `LICENSE` file |
>
> That is a real coupling signal the dependency graph does not carry, and it is exactly what this section asked for in its second clause. The first clause is dropped with its reason recorded rather than faked.
>
> **Confirmed: `groom-plan` exists** at `.claude/skills/groom-plan/SKILL.md`, so item 4 routes through a skill that is really there.

- [x] Report the critical path: the longest dependency chain to a shippable product. Done when: it prints, and the sections on it are identified as the ones whose delay costs most.

  **Corrected 2026-09-17 after the independent review of `390b560`, and the correction changed the answer.** The first version walked only the `Depends On` column and ignored the frontmatter `depends_on`, of which **fifteen are declared**. The reported chain was 17 sections deep against an actual **30**, and it ended somewhere else entirely: `D05 T02 §5` rather than `D05 T07 §4`. A report whose whole purpose is naming where delay costs most was naming the wrong path.

  A second defect in the same helper: a dependency written in the `TNN §N` form, which `AGENTS.md` documents alongside the other two, matched no node and silently truncated the chain there. Both are now resolved through `resolve_ref`, which already handled all three forms, rather than through pattern-matching the two somebody thought of.
- [x] Surface a dependency that evidence contradicts. **Corrected 2026-09-17:** the first half, "a section repeatedly blocked", is struck. Nothing in this repository records blocking over time; `query blocked` is a snapshot with no memory, and no block count or blocked-since date is stored anywhere, checked by search. Building it would mean adding a history store nothing else needs, to answer a question the second half already answers better. Done when: a section that filed a review finding to another section is reported as a coupling the dependency graph does not carry, with the direction and the finding named, derived from the ledger `§2` generates rather than from a new record.
- [x] Keep re-sequencing a decision, never automatic. Done when: the tool proposes and a human disposes, and this section records why. Proven by there being **no write path**: the `sequence` branch contains no `open(`, no `.write(`, no `write_text`, no `mkdir`, no `rename`, shown by search over the branch.

  **Recorded 2026-09-17, with the concrete case this plan already contains.** A dependency exists for reasons the graph cannot see, and the four couplings the tool reports are the proof. Every one of them points **backwards**: `D00 T03 §1`, the very first section, filed work to `D00 T01 §2`, `D00 T02 §1` and, through `§4`, to `D00 T04 §1` and `D06 T01 §8`. A tool acting on that signal would conclude the intake sections should come *after* the toolchain and test sections they filed to.

  That would be exactly wrong. The intake had to run first, because there was no C++ tree to build a toolchain around until it landed. The filings are work **discovered** early, not work **needed** first, and nothing in the data distinguishes those two. A human reading the finding knows the difference in a sentence; a tool reading the graph cannot recover it at all.

- [x] Distinguish unreadable evidence from absent evidence. **Added 2026-09-17 after the independent review:** `_filing_couplings` discarded the ledger's list of headings it could not parse and swallowed every exception, so a broken findings file produced an empty list and the report then stated that no review had filed a finding. "No evidence" and "the evidence could not be read" are opposite claims and it made them identical. **Third occurrence in this file** of a failure turned into a benign result, after the claims checker dropping a split claim and the coverage floor passing with no claims. Done when: an unreadable heading is named with its file and line and the coupling list is described as a floor, proven by breaking one category and watching couplings fall from 4 to 3 with the reason printed.

- [x] Say which direction a coupling points, since the tool cannot judge it. **Added 2026-09-17:** the report states for each filing whether the target is already a dependency, and says in its own output that a filing is not proof the order is wrong. Done when: the output carries that sentence and a section with no filings produces no candidates rather than an empty ceremony.
- [x] Route a proposed change through `groom-plan`. Done when: the report names that skill as where a change goes, and `groom-plan` names this command as where the evidence comes from, so the loop is closed from both ends rather than one.
- [x] Commit: `"self-correction: propose a better order, and let a human take it"`

**Test checkpoint:** `python scripts/todo-graph.py query sequence` prints the longest dependency chain to a shippable product, naming every section on it, and the chain is verified by walking it by hand against `resolve` for at least its first three links. It reports every cross-section filing as a coupling candidate, naming direction and finding, and the count matches an independent `grep` of the findings files. **The tool proposes and cannot act**, proven by there being no write path: the command opens no file for writing, shown by search, and the output names `groom-plan` as where a change goes. A section with no filings produces no candidates, so the report is not merely always-on noise. `self-test` covers the chain computation including a cycle, and stays green.

> **Verified:** 2026-09-17 | §4 | `query sequence` prints the longest dependency chain, **30 sections deep, 27 still open**, verified by hand against `resolve` for its first links · it reports 4 couplings from review findings, matching an independent `grep` of the findings files, each labelled as already a dependency or not · **it proposes and cannot act**, proven structurally: the branch contains no `open(`, no `.write(`, no `write_text`, no `mkdir`, no `rename`, shown by search · a `TNN §N` dependency keeps the chain at 30, driven · breaking one finding's category drops couplings to 3 **and** names the file, line and reason rather than reporting absence · `groom-plan` names this command and this command names `groom-plan`
> **Review:** round 2, candidate `390b560` `b541b9a` plus the follow-up fix -- `adversarial` approve after fixes (3) · `consistency` approve · `integration` approve · `source-defect` approve · `design` not-applicable · `record` approve after fix (1). Raw findings: docs/reviews/00-workspace/D00-T04-s4.md
> **Independent:** `codex review --commit 390b560` (gpt-6-astra, high) returned **three P2 findings, all correct**, and one made this feature's central output wrong: the chain ignored fifteen declared whole-TODO dependencies, reading 17 deep against an actual 30 and ending elsewhere. It predicted both the corrected depth and the changed endpoint before the fix and both matched. It noted again that the passing self-tests covered none of its findings.
> **CRUD:** not applicable (this reads the plan and the findings ledger and writes nothing)
> **Duration:** 8
> **Implementer:** Claude Opus 5 (claude-opus-5[1m])

## Verification

- [ ] `python scripts/todo-claims.py` exits 0 and its self-test stays green
- [ ] Claim coverage cannot fall below its recorded floor
- [ ] Every stamped section has its review findings recorded with a disposition
- [ ] Estimated items are compared against actual cost, with the correlation stated
- [ ] The critical path prints, and nothing re-sequences the plan automatically
- [ ] `python scripts/todo-graph.py validate` clean
