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
<!-- claim: count "gpt-5.6-sol" .claude/skills/process-todo-section/SKILL.md = 2 -->
<!-- claim: count "model_reasoning_effort" .claude/skills/process-todo-section/SKILL.md = 1 -->

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

**Adjacency:** list=not-applicable (D00 T04 §5, 2026-09-17: this anchored on Section Calibration, whose table is already claimed by `reporting` below. One behaviour, one kind: repository tooling holds no records a user browses); document=not-applicable (D00 T04 §5, 2026-09-17: this anchored on Re-Sequencing on Evidence, which prints a critical chain to a terminal. Nothing here produces a document a user carries); settings=not-applicable (this tooling owns no user-facing settings); reporting=applicable @ D00 T04 §3; notifications=not-applicable (a local check notifies nobody); permissions=not-applicable (no role model in repository tooling); audit=applicable @ D00 T04 §2; exchange=not-applicable (nothing is imported or exported); reverse=not-applicable (a check changes nothing that needs undoing)

**Adjacency rationale:** Audit anchors on §2 because the review ledger **is** the project's memory of its own defects, and a finding that is not recorded is a finding that recurs. List and reporting pair on §3 because calibration is only useful when somebody can see the pattern across many sections rather than one at a time.

## Implementation Order

| Order | Section | Deliverable                                | Depends On | Status |
| :---: | :-----: | ------------------------------------------ | ---------- | :----: |
|   1   |   §1    | Staleness detection for every claim-free block | --     |  [x]   |
|   2   |   §2    | The review-finding ledger                  | --         |  [x]   |
|   3   |   §3    | Section calibration                        | §2         |  [x]   |
|   4   |   §4    | Re-sequencing on evidence                  | §3         |  [x]   |
|   5   |   §5    | Make the adjacency advisory actionable     | §2         |  [x]   |
|   6   |   §6    | The adversarial reviewer                   | §2         |  [x]   |
|   7   |   §7    | Review-run records                         | §6         |  [x]   |
|   8   |   §8    | Revisit the two-model decision             | §6, §7     |  [x]   |
|   9   |   §9    | Review-input integrity                     | §6         |  [x]   |
|  10   |   §10   | Run-record follow-ups                      | §7         |  [x]   |
|  11   |   §11   | Bind the rename scan to the diff header    | §9         |  [ ]   |
|  12   |   §12   | Prove the manifest, not just emit it       | §9         |  [ ]   |
|  13   |   §13   | Bind the stamp to the push                 | §9         |  [ ]   |
|  14   |   §14   | Bar bool versions from the export gate     | §10        |  [ ]   |
|  15   |   §15   | Run-record vocabulary and evidence follow-ups | §10     |  [ ]   |
|  16   |   §16   | Blinded-run checker defects                   | §10     |  [ ]   |
|  17   |   §17   | Report without walking the corpus twice       | §10     |  [ ]   |
|  18   |   §18   | Second two-model revisit, independently rated | §8      |  [ ]   |

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

  <!-- claim: exists scripts/check-all.ps1 -->

  **Updated 2026-09-17 by `D00 T01 §5`, which built it.** The claim above read `absent scripts/check-all.ps1` and was filed into `§5` of this file, which is about the adjacency advisory and says nothing about this script; it belongs here, on the sentence it supports. The script now exists and surfaces both conditions this item registered. Nothing else in this item changes: its tick, its `Done when:` and its reasoning stand, and that reasoning was right, because what it required of `D00 T01 §5` is exactly what that section did.
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

## 5. Make the Adjacency Advisory Actionable

> **Started:** 2026-09-17T09:03:25Z

`scripts/todo-adjacency.py` emits **72** advisory diagnostics, every one of them the same message: `applicable kind has no implementing owner`. A signal that never clears is a signal nobody reads, and this file exists because the tree has to be able to tell the truth about itself.

**Measured 2026-09-17 during a groom pass.** The mechanism is keyword matching. When an `**Adjacency:**` declaration carries an `@` reference, `owners()` narrows to that one section and tests its prose against a per-kind regex from `KEYWORDS`. The declaration is then reported unowned when the anchored section's **wording** misses the vocabulary, which is not the same question as whether the section delivers the capability.

> [!IMPORTANT]
> **Validated 2026-09-17 before implementation. Three corrections, and the first one inverts this section's premise.**
>
> **The advisory is mostly right and the declarations are mostly wrong.** This section was filed assuming the matcher was at fault in all four shipped cases. Judging each against what the kind actually means, three of the four are **bad anchors**, not matcher misses:
>
> | anchor | kind | verdict |
> | --- | --- | --- |
> | `D00 T03 §4` | `document` | that section corrects **repository documentation**; the `document` kind is a user-carried artifact, a PDF or a print or an attachment. Wrong anchor. |
> | `D00 T04 §4` | `document` | that section prints the critical chain. Not a document a user carries. Wrong anchor. |
> | `D00 T04 §3` | `list` | that section renders the calibration table, and `reporting @ §3` is **already owned**. Duplicate anchor for the same behaviour. |
> | `D00 T04 §2` | `audit` | a review-finding ledger genuinely **is** an audit record, and the prose never says "audit", "history" or "record". A real matcher miss. |
>
> So the compound `document` rule, which this section called "the sharpest case", is **doing its job**: it declined to classify repository documentation as a user-facing document, correctly.
>
> **And the declarations are file-level, which removes the constraint this section was built around.** They sit at `TODO-03:44` and `TODO-04:50`, above the Implementation Order and outside every section body. Correcting an anchor touches no stamped section, so "clear the four without editing a `[x]` section" is not the hard problem it was filed as.
>
> **The counts were wrong.** This said "of the six kind-anchors pointing at shipped sections, two are owned and four are not", which conflated distinct anchors with kind-anchors. Measured from `--json`: **120** anchored applicable kinds, 50 owned and **70 unowned**, across **78** distinct anchors of which **6** are shipped. Those 6 carry **7** kind-anchors, **3 owned and 4 unowned**. The 72 diagnostics are those 70 plus 2 `stated-step-unowned`.
>
> **The harm was overstated.** This said 72 advisories "train the reader to ignore the tree's own health signal". The tool's own docstring says these are advisory by design and stay outside the structural validator's ratchet, escalating only under `--require-owned` or `--require-conformance`, and `validate` reports them on their own line as `adjacency advisory` rather than among fatals and warnings. The defensible defect is narrower and sharper, and it survives: **the message says "applicable kind has no implementing owner" when what it measured is "the anchored section's prose does not match a keyword regex".** A diagnostic that misdescribes its own measurement is what sent this section looking for a matcher bug when three quarters of the evidence was pointing at the declarations.
>
> **A stale citation, found while reading the source.** `scripts/todo-adjacency.py:5` and `scripts/todo-validate.py:468` both cite "D00 T03 section 19" as the decision that keeps semantic warnings out of the ratchet. `TODO-03` has **4** sections and **no TODO in this tree has 15 or more**, so the citation resolves to nothing. It arrived with the tooling in `abc84fa` and does not appear in the archived AutoIt plan either.

**The wrong fix is available and tempting.** Rewording a shipped section so a matcher recognises it is gaming the check, and `AGENTS.md` forbids rewriting a stamped checklist. Any solution that requires editing a `[x]` section body is the wrong one, and after the correction above no solution needs to.

- [x] Establish what the advisory should mean before changing how it is computed. **It is a claim about the prose, and it should stay one.** The tool's own docstring already says it is "a source matcher, not proof that a business feature works", and that is the honest description of what a regex over a Markdown body can know. What was wrong was not the measurement but the reporting of it: a matcher that says "has no implementing owner" is asserting something it never tested. The answer is now written at the emission site in `scripts/todo-adjacency.py`, where the next person to change this code will read it before they change it.
- [x] Separate "not owned" from "not recognised". **Three defects shared one message and the message named none of them.** They are now three codes:

  | code | means | what to do |
  | --- | --- | --- |
  | `anchor-unresolved` | the `@` reference names no section that exists | fix the reference |
  | `anchor-unmatched` | the anchored section exists and its prose does not read as the kind | wrong anchor, or the section delivers it without the words |
  | `unowned` | applicable, and the declaration names no anchor at all | add `@ <ref>` |

  Each message now also names **what was searched for**, which is the part that would have saved this section a wrong turn:

  ```
  audit: anchored section does not read as 'audit': D00 T04 §1 -- either it is
  the wrong anchor, or the section delivers audit without using the words
  audit/ledgers/history/timeline/actor/per/...
  ```
- [x] Make the four shipped cases above clear without touching a stamped section. **Three were bad anchors and one was a real matcher miss**, which is the correction in the block above and the reason this was easier than filed:

  - `D00 T03 §4` `document` and `D00 T04 §4` `document` are now `not-applicable`, each with its reason: one anchored on repository prose, the other on a critical chain printed to a terminal, and neither is an artifact a user carries.
  - `D00 T04 §3` `list` is now `not-applicable`: its table is already claimed by `reporting @ §3`, so it was one behaviour declared twice.
  - `D00 T04 §2` `audit` stays, and the **instrument** changed: `ledgers?` joined the `audit` vocabulary, because a ledger is an audit record. `ledger` appears 17 times in that section's body, so this recognises what was already written rather than requiring anything to be written.

  All four shipped anchors now report as owned. **Proven rather than asserted:** every changed line in both files was checked against the line ranges of every `[x]` section, and the count inside a stamped body is **0**. Cheaper substitute that would have failed: adding the missing words to those four sections.
- [x] Decide the compound `document` rule explicitly. **Kept, 2026-09-17, and the case this section filed against it is the case for keeping it.**

  The rule requires a second match beyond the word "documents", from `pdf|print|preview|signature|photo|attachment` or from `render|download|upload|display|template|layout`. This section was filed calling that "the sharpest case", because a section titled "Correct the Stale Documentation" using the word six times did not clear it.

  On inspection that is the rule working. `document` means an artifact a user carries away. Repository documentation is prose about the project, and if the bare word were enough, every TODO that mentions its own documentation would claim a user-facing document it does not have. **"Correct the Stale Documentation" is now classified correctly**, as `not-applicable`, by fixing the declaration rather than by loosening the rule.
- [x] Re-measure the advisory count and record it.

  | | before | after |
  | --- | ---: | ---: |
  | advisory diagnostics | 72 | **68** |
  | anchored applicable kinds | 120 | 117 |
  | of those, unowned | 70 | 66 |
  | kind-anchors on shipped sections | 7 | 4 |
  | of those, unowned | **4** | **0** |

  **The headline number moved by four and that is the honest result.** Three anchors became `not-applicable` and one match was recognised, so 72 became 68. The number that mattered is the last row: every anchor pointing at a section that has actually shipped now resolves. The remaining 66 all point at **open** sections, which is the expected state for work not yet written, and each now names its anchor and the vocabulary it wanted, so it is a thing a reader can act on rather than a thing to scroll past.
- [x] Prove the check can still fail. **Driven both ways, because a count that falls is exactly what a blinded check looks like.**

  ```
  probe A  audit=applicable @ D07 T01 §99   (no such section)
           -> anchor names no section that exists: D07 T01 §99
  probe B  audit=applicable @ D00 T04 §1    (real section, not an audit trail)
           -> anchored section does not read as 'audit': D00 T04 §1
           -> count 68 rises to 69
  ```

  Probe B is the one that matters: it re-points a **resolvable** anchor at a section that does not deliver the kind, and the count goes up. Both probes were reverted and the count returned to 68. `--require-owned` still exits 1 while diagnostics exist, so the opt-in escalation path is intact.
- [x] Commit: `"todo: make the adjacency advisory actionable"`

-> XREF: D00 T04 §2 -- the ledger whose `audit` anchor this section has to clear without editing it
-> SOURCE: groom-2026-09-17-adjacency-unowned

<!-- claim: count "anchor-unresolved" scripts/todo-adjacency.py = 1 -->
<!-- claim: count "anchor-unmatched" scripts/todo-adjacency.py = 1 -->
<!-- claim: count "section 19" scripts/todo-adjacency.py = 0 -->

> **Verified:** 2026-09-17 | §5 | the advisory was mostly right and this section's filed premise was wrong, which is the finding worth keeping · of the four shipped anchors that failed, **three were bad anchors and one was a real matcher miss**: `document` anchored on repository prose, `document` anchored on a critical chain printed to a terminal, `list` duplicating a table `reporting` already claimed, and `audit` on a ledger whose body says "ledger" 17 times · so the compound `document` rule this section called "the sharpest case" was **doing its job** and is kept, dated, with its reason · the defect that survives is the reporting rather than the measurement: one message covered three different defects and asserted ownership it never tested, and is now `anchor-unresolved`, `anchor-unmatched` and `unowned`, each naming what to do and each naming **the vocabulary it searched for** · advisory diagnostics **72 to 68**, anchored applicable kinds 120 to 117, and the row that matters, kind-anchors on shipped sections unowned **4 to 0** · the remaining 66 all point at **open** sections, the expected state for unwritten work, and they are left rather than suppressed because each now names its anchor and the vocabulary it wanted, which is what makes it actionable when that section is built. This is deliberately **not** a deferral: no section owns them, they clear as the sections they name get written · **no stamped section body was edited**, proven by checking every changed line against the line ranges of every `[x]` section: 0 · the check is not blind, driven both ways · a citation to "D00 T03 section 19" in two source files resolved to nothing and is corrected
> **Review:** round 1, candidate `625f3dc` -- `adversarial` approve · `consistency` approve after fix (1) · `integration` approve · `source-defect` approve after fix (1) · `design` approve after fix (1) · `record` approve after fixes (1). Raw findings: docs/reviews/00-workspace/D00-T04-s5.md
> **Independent:** `codex review --commit 625f3dc` (gpt-6-astra, high) returned **no actionable regressions**, confirming the ownership checks and escalation behaviour are preserved. First clean sweep in five sections, and the reason looks structural rather than lucky: this candidate changed a diagnostic's wording and three declarations, with the behaviour-changing part limited to one added regex alternative, where the four before it each changed how something was built. Its transcript did surface a stale `build/todo-progress.json`, a derived gitignored artifact, before my own sweep did, because I ran `plan --check` before ticking the items rather than after. Synced.
> **CRUD:** not-applicable | this reads the plan and writes no user data. The behavioural evidence is the pair of probes: **A** re-anchors at a section that does not exist and is reported as `anchor-unresolved`; **B** re-anchors a **resolvable** reference at a section that does not deliver the kind and the count rises 68 to 69. B is the load-bearing one, because only a resolvable anchor can distinguish a fixed check from a blinded one. Both reverted, and `--require-owned` still exits 1 while diagnostics exist.
> **Duration:** 7
> **Implementer:** Claude Opus 5 (claude-opus-5[1m])

**Test checkpoint:** `python scripts/todo-graph.py validate` reports an advisory count recorded in this section, down from 72, with every remaining advisory naming something a reader can act on. The four shipped anchors above report as owned and `git diff` shows no change inside any `[x]` section body. A deliberately wrong anchor is still reported, driven, so the fall in count is not the check going blind. `python scripts/todo-graph.py self-test` stays green.

## 6. The Adversarial Reviewer

Every other section in this file makes the plan notice something about **itself**. This one is about the only check in the process that is not run by the party being checked.

**Measured 2026-09-17 from the findings ledger**, which is `§2`'s output and the reason that section exists:

| | count |
| --- | ---: |
| findings in the ledger | 121 |
| raised by an independent party, across 22 review engagements | 52 |
| of those, later refuted | 0 |
| engagements that found nothing actionable | 5 of 22 |
| findings categorised `adversarial`, the lens the authoring session runs on itself | 13 |
| findings categorised `record`, the lens that session is good at | 40 |

**Corrected 2026-09-19:** the table read 101 / 37 / 0 / 5-of-20 / 12 / 31, hand-counted with three greps in two phrasings. The findings total, the split, and the category counts are now a query (`python scripts/todo-findings.py`), which is what item 2 built; engagements, empty engagements, and refuted stay hand-counted, because no run records exist as data to query. Two methodology differences explain the jump beyond the twenty new findings: a range heading (`F1-F4`) counts as one finding, where the hand-count expanded it; and the operator's question (D00 T02 §3 F1) counts as independent (raised by someone other than the implementing session), where the hand-count read it as self. A review engagement is one section's independent review however many rounds it took, so the §5 panel is one engagement, not five.

**The split is the argument.** Self-review is good at stale facts and internal contradiction, which is what `record` at 40 measures. It is weak at imagining hostile input against its own design, because the same imagination drew the design. `D07 T01 §1` put a number on that: five failure modes driven by hand, and the sixth found by the reviewer, missed because the author does not think of Markdown table rows as indentable.

`review-todo-section` names an `adversarial` lens and is explicit that the authoring session running it is a stand-in:

> Until the external review panel is wired (see Deferred in the repo README), the session performs the lenses itself

**That pointer resolves to nothing.** `README.md` has no Deferred section, and no file in `todo/` or `docs/` mentions a review panel. So the one thing that would own a real adversarial reviewer has been cited by a skill and owned by nobody, which is an unfalsifiable deferral with no address: the exact defect `§2` was built to stop recurring, sitting inside the review system itself. **Corrected 2026-09-19:** the port rewrote the skill around a real mixed panel (Sol early rounds, Opus sign-off) and the stale pointer is gone from it; the skill's adversarial lens now cites this section, which owns the reviewer and its measurement. The quoted sentence stays as the record of what the pointer said.

**What changed on 2026-09-17, and why this is now cheap.** The reviewer was repointed at `gpt-5.6-sol` at high effort, **pinned in the command** rather than read from the machine's codex config, because a stamp that names its reviewer is only true if the command fixed it. In the same run two facts were established by driving them:

- **A stamp commit is worth reviewing.** Its first run read the stamp for `D07 T01 §1` and returned three P2 and one P3, all correct, while every runtime gate was green. The convention recorded in `D00 T03 §1`, that a stamp commit "carries only this stamp" and is left unreviewed by design, is falsified by its own counter-example.
- **An instructed pass is possible after all.** `--commit`, `--base` and `--uncommitted` each refuse a `[PROMPT]`, which an earlier skill generalised into "do not reintroduce one". A **bare** prompt with no scope flag is legal, reviews the latest commit on a clean tree, and obeys its instructions, driven with a sentinel phrase that came back.

So this section is mostly wiring and measurement rather than construction, and it must not become a project.

**Build order.** Wire the cheap catch first, then measure whether more is warranted, and only then decide whether to spend anything. The trap is building a review panel because it sounds thorough; the evidence for a second model has to come from the ledger, not from taste.

1. **Review the stamp before it is pushed.** The staged stamp, not the pushed commit, so there is no circularity. Done when: `review-todo-section` runs it and a deliberately wrong figure in a staged stamp is named before the push.
2. **Record who raised each finding**, so the split above is a query rather than three greps in two phrasings. Done when: `todo-findings.py` reports it and a finding with no source is reported rather than bucketed.
3. **Add the instructed pass**, with its scope caveat written down. Done when: it runs, obeys, and the caveat is recorded.
4. **Repair the stale pointer**, in the same commit as the section that replaces it.
5. **Decide on a second model from the data**, or record that the sample is too small and name the threshold.

- [x] Wire the stamp review into `review-todo-section` step 8, before the STAMP push, reviewing the **staged** stamp with the pinned model. **Corrected 2026-09-19:** step 7 was the old skill's stamp step; the ported skill writes the stamp at step 8. **Done 2026-09-19.** The skill carries the command (pinned `gpt-5.6-sol` at high effort, blocking until `STAMP HOLDS`). Driven both directions at the shipped effort against §5's stamp: `272 assertions` staged was named as `271 assertions`, checked against both direct binary runs under Live proof, and the correct stamp returned `STAMP HOLDS.` Done when: the skill carries the command, and a staged stamp containing a deliberately wrong figure is **named by the reviewer before the push**, quoted. Cheaper substitute that fails the checkpoint: reviewing the stamp commit after pushing it, which is the current state and means the wrong figure is already published while being discussed.
- [x] Record the source of every finding, `independent` or `self`, and teach `scripts/todo-findings.py` to report the split beside category and disposition. **Done 2026-09-19.** The marker is a trailing parenthetical on the disposition (`FIXED (self)`), parsed by `SOURCE_RE`, with the closed set and the independent/self rule in the script. All 121 findings across 21 files carry one; the split prints `self 69` and `independent 52`. Missing reports as `no source marker; end the disposition with (independent) or (self)` and unknown as `unknown source 'codex'; expected one of ['independent', 'self']`, both quoted from a driven fixture, and the self-test covers both (14 cases green). Done when: the split prints, a finding whose source is missing or outside the closed set is **reported rather than bucketed**, in the same way an unknown category already is, and the self-test covers both. Cheaper substitute that fails the checkpoint: inferring the source by grepping review prose for the reviewer's name, which is how the 37 above were counted and took two different phrasings across twenty files to find.
- [x] Add the instructed adversarial pass as a second, advisory run, with a prompt that asks for constructed hostile states rather than a diff read. Done when: a driven run shows the instructions obeyed, and the skill records that a bare prompt **cannot pin a SHA** so the pass is only trustworthy on a clean tree immediately after the SHIP push, with the summary checked to name the right work. **Superseded 2026-09-19:** the ported panel's adversarial lens IS the instructed pass (constructed hostile states, every round: §5's F7 built control-destroyed-plus-timer-fires, a state the author never constructed), and it blocks rather than advises, which is stronger than this item asked. The SHA caveat is moot because the candidate diff rides inline rather than by reference, so there is no SHA to pin. Satisfied by the panel with the evidence cited, not re-driven.
- [x] Repair the stale pointer at `.claude/skills/review-todo-section/SKILL.md`, which cites a Deferred record in the repository README that does not exist. Done when: it cites this section, and a search for "review panel" across `todo/`, `docs/` and `README.md` either resolves or returns nothing because the phrase is gone. **Done 2026-09-19.** The port had already removed the citation; the skill's adversarial lens now cites this section as the reviewer's owner, and the remaining "review panel" hits are this section's own historical record of the pointer, which resolves.
- [x] Decide whether a **second reviewer model** is worth its cost, from the recorded split rather than from taste. Done when: the decision is dated and cites the measured independent-versus-self numbers; if the sample is too small to decide, **that is the recorded answer**, with the sample size needed to revisit it named. **Decided 2026-09-19: keep both models.** The ledger split is 69 self against 52 independent with 0 refuted, and the §5 panel is the only two-model data point: Sol's two rounds found 9 findings, Opus's three found 7, refuted zero. The second family added 7 real finds its first two rounds never raised, which is the keep argument; the overlap argument is withdrawn (round 2 caught it): the models reviewed sequential candidates, so Opus never had the chance to find Sol's fixed findings, and neither "would have shipped the other's" direction is established. What is established: Sol caught the worst defect (the dangling manager-held `[this]`) and the structural overclaims, and Opus added stale comments, RAII gaps, the unquoted checkpoint, includes, the lifetime inversion, the rotted citation, and the tautology. The sample is one panel review, so this is provisional: revisit after 5 panel-reviewed sections with at least one same-candidate comparison (both rungs on one candidate), and cut to one model if either rung goes 3 consecutive sections without a unique find or same-candidate overlap exceeds half. Cheaper substitute that fails the checkpoint: adding a second model because two reviewers sound better than one, which doubles the cost of every section for an unmeasured gain.
- [x] State what the independent reviewer has repeatedly **failed** to catch, from the ledger. **Done 2026-09-19.** All three verified against the review records: (1) legal-but-duplicate definitions: T03-s2's reviewer returned no actionable regressions and missed the twice-defined `IDI_APPFALLBACK`; (2) surviving identifiers on internally consistent lines: T03-s3's record states plainly "It did not find F1", and only a prefix search in any shape finds them; (3) performance regressions: T04-s1's record states "It did not find F5", invisible to any probe that only asks whether the output is correct. The pattern across all three: the reviewer reads diffs and constructs input states, and what it misses is what neither shows (legality, cross-file residue, timing). Done when: this section names the classes, so nobody reads `0 refuted` as `nothing missed`. Three are already recorded in stamps: a duplicate resource id that is legal and therefore invisible to a diff reader, surviving identifiers on lines that are internally consistent, and a performance regression invisible to any probe that only asks whether the output is correct.
- [x] Commit: `"workspace: the adversarial reviewer, wired and measured"`

**Test checkpoint:** A staged stamp carrying a deliberately wrong figure is named by the independent reviewer **before** the STAMP push, quoted. `python scripts/todo-findings.py` prints the independent-versus-self split, and a finding with a missing or unknown source is reported by name rather than bucketed, both quoted, with the self-test covering both. The instructed pass is driven and its instructions are shown to have been obeyed. A search for "review panel" across `todo/`, `docs/` and `README.md` resolves or is empty. The second-model decision is dated and cites the split, or records the sample as insufficient and names the threshold. This section names at least three defect classes the independent reviewer has missed.

> **Filed 2026-09-17 by the operator**, from a question asked during `D07 T01 §1`: "do we have an adversarial reviewer?" The measurement above is the answer, and it is *partly*. The evidence is `§2`'s ledger, which is what that section was for.
> -> SOURCE: docs/reviews/findings.md

> **Started:** 2026-09-19T04:55:00Z

> **Verified:** 2026-09-19 | §6 | the split is a query now: source markers (`independent` or `self`) on all 121 findings across 21 files, `todo-findings: 121 parsed, 0 unreadable`, split `self 69` and `independent 52`, self-test 14 cases green, missing and unknown both quoted from a driven fixture · the stamp review is wired into the skill at high effort and driven both directions at the shipped effort: `272 assertions` staged was named as `271 assertions` against Live proof, and the correct stamp returned `STAMP HOLDS.` · the measurements read 121 / 52 / 0 / 5-of-22 / 13 / 40 with the hand-count methodology differences recorded (ranges count once, the operator counts as independent) · the second-model decision is keep, provisional, resting on 7 added real finds with the complementarity inference withdrawn and a blinded comparison owed at revisit · the three blind-spot classes verified against the review records that state the misses · the instructed pass stands superseded by the panel's adversarial lens with §5's F7 as the driven evidence · panel: 4 rounds, 6 findings (5 fixed or corrected, the /tmp race refuted with the single-writer reason and the refutation accepted at sign-off) · plan review: 16 findings into D00 T04 §7, §8, §9 and the D07 T01 §2 item
> **Review:** round 4, candidate `5689e3b` `6cd4676` `11e6de7` `f0c3db3` `79979a6` -- `adversarial` approve after refutation (1) · `consistency` approve after fixes (2) · `integration` approve after fix (1) · `source-defect` approve · `design` approve · `record` approve after fixes (3). Raw findings: docs/reviews/00-workspace/D00-T04-s6.md
> **Plan review:** gpt (run 20260919-D00-T04-S6-gpt) -- filed: D00 T04 §7, D00 T04 §8, D00 T04 §9, D07 T01 §2 item; 2 rejected and 2 duplicate with reasons in the ledger
> **CRUD:** this section writes plan record, derived ledger, and review tooling. It reads 21 findings files and the git history; it writes source markers into the headings, the skill's stamp-review command, and the regenerated ledger. The only behavioral surface it adds is the findings gate failing on a missing or unknown source. It touches no user system, no C++, and no shipped behavior; the library and the gates it does not own are byte-identical.
> **Duration:** 37
> **Implementer:** Muse Code

## 7. Review-Run Records

§6 made the finding split a query, but everything around it is still hand-maintained: engagements, empty engagements, and refuted have no records to query, per-model attribution does not exist (the marker says `independent`, never which rung), and the source itself is self-attested by the session being measured. The §8 revisit cannot run on hand counts. This section adds one structured record per review run (reviewer, model, run id, candidate, rounds, findings raised by ref and number, empty and refuted flags) and derives the split, the engagement counts, and the outcome queries from it.


- [x] Record every review run structurally: reviewer, model, run id, candidate, rounds, and findings raised by ref and number. Done when: the §6 review has a record, and the split, engagements, empty engagements, and refuted all derive from records rather than prose. Done: `docs/reviews/run-records.md` carries 22 runs over 31 independent rounds, `scripts/todo-runs.py --check` cross-reads every ref against the review files, and `--report` derives the split (independent 64, self 69, agreeing with the ledger's by-source counts exactly), 22 engagements, 4 empty, 1 refuted.
- [x] Expand range headings so each finding counts. Done when: `F1-F4` parses as four findings, the ledger total moves from 127 to 133, and the §6 table's methodology note is superseded by the query. Done: `RANGE_RE` expands the three range headings (127 + 6 = 133, `todo-findings: 133 parsed, 0 unreadable`), which supersedes the first methodology difference on line 384 (ranges count once); the second (the operator counts as independent) stands, and the runs file records the tension on D00-T02-S3-F1 in a comment.
- [x] Define refuted, withdrawn, duplicate, routed, and non-defect as outcome queries and report them. Done when: each has a definition beside the dispositions, the report prints the counts, and `1 refuted` is a query result rather than a hand count. Done: `OUTCOMES` beside `DISPOSITIONS` defines all five, the report prints `refuted 1, withdrawn 0, duplicate 0, routed 2, non-defect 5`. Corrected 2026-09-19: the item said `0 refuted`, but D00-T04-S6-F3 is refuted in the tree, so the query reads 1; a definition that predicted its own count would be the hand-count habit this item exists to end.
- [ ] Commit: `"workspace: review-run records"`

**Test checkpoint:** The run records cover every engagement §6 counted, quoted; the split, engagement, and outcome queries agree with the §6 table after the range expansion; a record with a missing field is reported rather than bucketed, quoted, with the self-test covering it.

-> SOURCE: plan-D00-T04-s6-2026-09-19-PR1 D00-T04-S6-PR1
-> SOURCE: plan-D00-T04-s6-2026-09-19-PR3 D00-T04-S6-PR3
-> SOURCE: plan-D00-T04-s6-2026-09-19-PR7 D00-T04-S6-PR7
-> XREF: D00 T04 §10 -- the follow-ups this section's plan review filed

> **Started:** 2026-09-19T05:38:00Z

> **Verified:** 2026-09-19 | §7 | the runs are records now: 22 backfilled engagements over 31 independent rounds in `docs/reviews/run-records.md`, `todo-runs.py --check` cross-reading every ref against the review files, `--report` deriving 22 engagements, 4 empty, 1 refuted, and the split (independent 64, self 69) agreeing exactly with the ledger's by-source counts · ranges expand (127 + 6 = 133, the §6 methodology note's first difference superseded, the second standing) · the five outcome queries print `refuted 1, withdrawn 0, duplicate 0, routed 2, non-defect 5`, and the item's `0 refuted` corrected to the measured 1 · self-test 20 cases green, a missing field reported not defaulted, an unreadable file reported not crashed · panel: 4 rounds, 7 findings, all fixed in-round · plan review: 23 findings into D00 T04 §10 and the §8 severity item
> **Review:** round 4, candidate `e44b137` `2a184a9` `091262f` -- `adversarial` approve after fixes (3) · `consistency` approve after fixes (2) · `integration` approve after fix (1) · `source-defect` approve · `design` approve · `record` approve after fix (1). Raw findings: docs/reviews/00-workspace/D00-T04-s7.md
> **Plan review:** gpt (run 20260919-D00-T04-S7-gpt) -- filed: D00 T04 §10, D00 T04 §8 severity item; 7 rejected and 3 duplicate with reasons in the ledger
> **CRUD:** this section writes review-run records, a runs checker, and the ledger's range and outcome queries. It reads 22 findings files and the git history; it writes the run records, per-round attribution the checker verifies, and the regenerated ledger at 133. The only behavioral surfaces it adds are the runs gate failing on an unresolving ref, an uncovered mark, a runless file, or a miscounted total, and the findings gate expanding ranges. It touches no user system, no C++, and no shipped behavior.
> **Duration:** 43
> **Implementer:** Muse Code

## 8. Revisit the Two-Model Decision

§6 kept both models provisionally on a sample of one panel review, with revisit owed after five. A prose promise with no owner rots, so this section is the owner: after five panel-reviewed sections exist in the run records, it decides again with data, blinded where §6 was confounded.

**Trigger met 2026-09-19:** five `runner: panel` blocks exist: D00-T02-S5, D00-T04-S6, D00-T04-S7, D00-T04-S9, D00-T04-S10. The explicit block is lifted.


- [x] Compare both rungs on shared candidates, blinded: each rung reviews one frozen candidate without seeing the other's output or its fixes. Done when: at least one blinded comparison exists and the overlap is measured on shared input. Done: frozen candidate `f118e30` (diff plus period §10 contract), both rungs in a detached worktree at the candidate so the fix commits are unreadable, separate invocations, both outputs `PASS four lenses, one verdict each`. Sol found 4, Opus 7; same-defect matches 2 (panel-shape terminology, round_lines type crash), union 9, Jaccard 0.22. Sol-only: presence-only generality, pre-change-commit binding (Opus approved record). Opus-only: number crash, dead-ref dupe gap, em dash, flag conflict, double schema message. Four live defects filed (§15 terminology item, §16); the fixed five confirm the panel's F1-F4 class re-finds blinded.
- [x] Specify the cut threshold before deciding: the rolling window, the overlap denominator, severity weighting, and the cost measure. Done when: the rule names all four, and a worked example shows a cut and a keep. Done: the rule is WINDOW the last 5 panel-reviewed sections; OVERLAP the mean blinded Jaccard (intersection over union of same-candidate accepted finds) in the window; WEIGHTS critical 9 / major 3 / minor 1 (3x steps, a judgment: re-running the analysis reprices any change); COST recorded tokens per rung when both rungs have recorded costs in the window, else rounds as proxy, with value-per-cost reading value-per-token or value-per-round accordingly. CUT a rung when over the window it contributes zero weighted value in 3 consecutive full-scope sections, or mean Jaccard exceeds 0.5 while its value-per-cost trails; otherwise KEEP. The zero leg counts full-scope sections only: zeros on fix-loop reviews of already-fixed candidates reflect opportunity, not capability, and before any cut on zeros a blinded comparison arbitrates (finds on shared input void the zeros). Missing observations: sections without a blinded comparison contribute no Jaccard; if the window holds none, the overlap leg is DORMANT and cannot cut, and every revisit runs a fresh blinded comparison before deciding, so a decision never rests on a dormant leg. (Round 1: the first text left the empty-window overlap undefined and compared value/round unconditionally.) Worked KEEP (real): Sol clears the zero leg at full scope (finds per section 5/2/5/3/4, never zero, counted from the round lines); Opus has no full-scope observation in the window (all 11 Opus rounds on record are delta-plus-regressions sign-offs, so the per-section 7/1/2/6/1 are fix-loop finds the amended zero leg excludes), so the leg is inconclusive for Opus and the arbitrating blinded comparison decides it: 7 Opus finds on shared input void any zeros. Overlap leg: blinded Jaccard 0.22, below 0.5. No trigger fires. (Re-review round 1: the first text read the 7/1/2/6/1 as zero-leg evidence; the round-2 amendment excludes fix-loop opportunities, which is every Opus observation.) Worked CUT (hypothetical, marked): Opus zeroed three straight full-scope sections while Sol held 15+ weighted each, and the arbitrating blinded rerun read Jaccard 0.7 with Opus finding nothing Sol missed, so Opus cuts and Sol round 3 takes the sign-off. (Round 2: the first zero leg counted fix-loop zeros, which the sequential-candidate confound §6 named can produce without any capability gap.)
- [x] Compare lens and prompt diversity against model diversity on shared candidates. Done when: same-candidate adversarial, integration, record, and performance passes are measured against the second model, and the decision says which diversity carries the finds. Done: four Sol single-lens passes on the frozen `f118e30` input (all `PASS`, 16 lines, 9 unique defects) measured against the blinded Opus pass (7 finds). Prompt diversity recovered 2 of 7 (both crash shapes); it missed the dead-ref dupe, the em dash, the terminology contradiction, the flag conflict, and the double message, while finding 5 Opus missed (as-of binding, presence-only generality, transition content, provider labels, double traversal). Verdict for the decision: model diversity carries unique finds in both directions and prompt diversity does not converge on them; the extra passes multiply single-model yield but do not substitute for the second model. Caveat recorded: no consistency pass ran, so the two prose finds may be lens coverage rather than model difference. Three filings (§15 items, §17); transition-content noted duplicate of the §15 evidence item, cost wording rejected as documented, the manifest misread and the sort note below bar with reasons in the review.
- [x] Decide keep or cut from the run-record export, not the prose. Done when: the decision is dated, cites the measured numbers from `todo-runs.py --export` (version asserted by `--check-export`), and either keeps with the next revisit named or cuts with the losing rung's duties reassigned. Done: **Decided 2026-09-19: keep both models.** From the asserted export (25 runs) joined to the severity ledger, panel rounds only (the one stamp-review round excluded; reproduced the join both ways and panel-only gives exactly these figures): Sol 11 rounds, 31 accepted, value 79 (1 critical, 20 major, 10 minor), 7.18/round; Opus 11 rounds, 17 accepted, value 31 (7 major, 10 minor), 2.82/round; per-section finds 7/1/2/6/1 for Opus (all fix-loop sign-offs, excluded from the zero leg) with Sol 5/2/5/3/4 at full scope, never zero. The panel-history gap is opportunity, not capability: Sol reviews first at full scope while Opus signs off on fixed candidates, and blinded on shared input Opus found 7 to Sol's 4 with Jaccard 0.22, so the rungs find different defects. Prompt diversity recovers only 2 of 7, so no cheaper substitute exists. Cost unmeasured (44/44 unresolved; rounds proxy equal 11/11), so the decision rests on value with cost recording as the named gap. Next revisit: after 5 more panel-reviewed sections, or immediately if either cut trigger fires.
- [x] Record severity per finding and compare weighted value per cost, not raw counts. Done when: the severity scale is stated beside the dispositions, every finding carries one, and the keep-or-cut comparison weights unique accepted finds by severity against the §10 cost fields. Done: `SEVERITIES` (critical/major/minor, mirroring the plan-review ledger) beside `DISPOSITIONS` in `scripts/todo-findings.py`, headings close with `[severity]`, missing/unknown reported never bucketed (self-test 29 green), report and ledger carry by-severity views, and all 160 findings across 25 files then present carry one (`critical 6, major 77, minor 77` at rollout; the ledger grows as reviews file and the live query owns current counts; never-defects rate minor, cleared rates as raised like fixed, plan-stage corrections rate by impact: minor when ordinary execution would have caught them, major when the defect would have survived it, which re-rates D07-T01-S1-F3 back to major. Re-review round 1: the first text said minor without exception, but the scale rates wrong behavior in a plan as major, and a checkpoint that cannot fail stamps without verifying. Swept all 35 CORRECTED rows for the survives-execution bar; only F3 moves.). The skill's heading contract updated. Weighting applied in the item-4 decision.
- [x] Decide from a fresh export, never a carried file: regenerate `--export` from the live records at decision time and assert it with `--check-export`, since a stale export stays internally sound. Done when: the decision cites the regeneration and the assertion, quoted. Done: regenerated at decision time (`/tmp/s8-export.json: export version 1, 25 runs, internally sound`, as-of `97d9ced105b9748f10aedf4e93294463cbba27fa 2026-09-19T09:49:33Z`); the analysis above read that file, not a carried copy.
- [x] Commit: `"workspace: revisit the two-model decision"`

**Test checkpoint:** The decision cites the run-record export, quoted; the blinded comparison exists with its overlap measured; the threshold names window, denominator, severity, and cost. Starts after five panel-reviewed sections exist in the run records; blocked until then, explicitly.

-> SOURCE: plan-D00-T04-s6-2026-09-19-PR5 D00-T04-S6-PR5
-> SOURCE: plan-D00-T04-s6-2026-09-19-PR4 D00-T04-S6-PR4
-> SOURCE: plan-D00-T04-s6-2026-09-19-PR6 D00-T04-S6-PR6
-> SOURCE: plan-D00-T04-s6-2026-09-19-PR16 D00-T04-S6-PR16
-> XREF: D00 T04 §10 -- the enriched records this decision consumes
-> XREF: D00 T04 §16 -- the checker defects this section's blinded runs filed
-> XREF: D00 T04 §17 -- the double traversal this section's diversity runs filed
-> SOURCE: plan-D00-T04-s7-2026-09-19-PR20 D00-T04-S7-PR20
-> SOURCE: plan-D00-T04-s10-2026-09-19-PR7 D00-T04-S10-PR7

> **Started:** 2026-09-19T09:05:00Z

> **Verified:** 2026-09-19 | §8 | keep both models, decided from the asserted export (version 1, 25 runs) joined to the severity ledger: Sol 11 panel rounds, 31 accepted, value 79 (1 critical, 20 major, 10 minor); Opus 11 rounds, 17 accepted, value 31 (7 major, 10 minor); the join reproduced both ways with panel-only giving exactly these figures (the stamp-review round excluded) · the blinded comparison on frozen `f118e30` reads Jaccard 0.22 over 9 union finds with 2 same-defect matches, and voids any Opus zeros since Opus holds no full-scope observation (all 11 rounds delta-plus-regressions) while Sol clears the zero leg at full scope (5/2/5/3/4, never zero) · the cut rule names window, overlap, weights, and cost with worked keep and cut, the zero leg counting full-scope sections only with blinded arbitration · prompt diversity recovers 2 of 7 blinded Opus finds, so no cheaper substitute exists · severity rollout tags every finding with the gate enforcing it (rollout 160: 6/77/77; ledger 170: 6/85/79 with this review's ten) · cost unmeasured (44/44 unresolved at decision) with recording filed to §15 · panel: 3 usable rounds plus 1 void attempt, 10 findings (8 fixed, 2 filed to §16 and §18) · plan review: 21 findings, 14 filed (§18 carries 10, §16 two, §17 and §15 one each), 5 rejected, 2 duplicate
> **Review:** re-review round 3 sign-off plus 1 void attempt, candidate `d72afe0` `2dde74b` `a27e296` `296a838` `de3f66a` -- `adversarial` approve (F1 filed to §16) · `consistency` approve after fix (F2, F4 fixed outside the candidate) · `integration` approve after fixes (F7, F9) · `source-defect`/`design` not owed · `record` advisory at close (F10 filed to §18) after fixes (F3, F8). The void round's F4-F6 verified in-session and fixed outside the candidate. Raw findings: docs/reviews/00-workspace/D00-T04-s8.md
> **Plan review:** gpt (run 20260919-D00-T04-S8-gpt) -- filed: D00 T04 §18 (3 new items, item 2 and context extended), D00 T04 §16 (scope plus semantic), D00 T04 §17 (pins), D00 T04 §15 (trigger item); 5 rejected and 2 duplicate with reasons in the ledger
> **CRUD:** this section writes plan record (the keep decision with its numbers), the derived ledger (severity views), review tooling (SEVERITIES, the severity report, the never-defect rule it states but does not enforce), and run records (the S8 block with its void noted). It reads the review files, the run records, and the git history. The behavioral surfaces it adds are the findings gate failing on a missing or unknown severity and the runs gate failing on unclaimed refs and runless files. It touches no user system, no C++, and no shipped behavior.
> **Duration:** 2026-09-19T09:05:00Z to 2026-09-19T17:39:37Z
> **Implementer:** Muse Code

## 9. Review-Input Integrity

Three soundness holes share one theme: the reviewer may not have reviewed what the record claims. A stamp approved staged becomes pushed unstaged (time-of-check gap); the wrong-figure probe covers one defect shape; and an inline diff is never proven complete, so a truncation approves falsely. This section closes all three.


- [x] Bind stamp approval to the staged tree: record the index identity at review time and recheck it before the push. Done when: an edit after approval forces re-review, quoted, and the skill carries the commands. Done: the skill captures `TREE=$(git write-tree)` before the patch, verifies patch against tree immediately, and rechecks before committing with `BLOCKED` on mismatch; driven both directions on the real index (success prints nothing; an edit draws `BLOCKED: the staged tree moved since STAMP HOLDS; re-stage and re-review`, and the capture-window drill draws `BLOCKED: the index moved while capturing the stamp patch`). Round 1 caught the first shape reviewing one tree while recording another; the capture order is the fix, with the check-then-commit instant named as the single-writer residual. Scoped by the plan review: the recheck binds the commit, not the push, and hook mutation after the last check is unhandled; both file to D00 T04 §13.
- [x] Add stamp-review regression cases: wrong candidate identity, unsupported evidence, stale references, and contradictory stamps. Done when: each is driven against a staged stamp and named, all quoted. Done: a seeded stamp drew `` `31 findings` should be `2 findings` `` (unsupported evidence), `` `round 4` should be `round 2` `` (the contradictory side), and `` `aaaaaaa` should be `bbbbbbb` `` (wrong candidate); the stale path drew `STAMP HOLDS` twice, which sharpened the prompt to verify every file path exists, after which it named `` `todo/00-workspace/TODO-09-seeded.md` should exist ... where it is absent ``. All at high effort with receipts. Scoped by the plan review: the contradiction evidence names the wrong side rather than two live conflicting stamps, the stale evidence covers absent paths rather than dead anchors in live files, and the candidate match compares text rather than resolving OIDs; all three file to D00 T04 §13.
- [x] Prove inline diffs complete: byte count, file list, base and head identities, and reviewer receipt. Done when: the fence subcommand emits the manifest and every review prompt requires the receipt, with a truncated input proven to fail rather than approve. Done: `fence` emits `MANIFEST bytes/files/sha/titles` plus `diff-files` scanned from diff-titled chunks and `base/head` when given, all four skill prompts require the opening `RECEIPT sha/end` line, and both checkers take `--manifest`; `review-prompt self-test` 29 cases green (including a prose `diff --git` line the title gate refuses, the adversarial rename split, and the poisoned preamble), and live a correct receipt passes while the receiptless (truncated) output fails as `FAIL line 1 is not a receipt`. Round 1 caught `files=2` counting chunks instead of the candidate's changed files; round 2 caught the first scan missing git's real quoting (bare spaces, whole-token quotes, mixed rename sides). The sign-off round caught the bare-split rule fabricating a path when both sides carry ` b/`; the fix reads git's `rename from/to` pair as authoritative, proven against a live ambiguous rename resolving to `diff-files=old b/x.md|new b/y.md`, and the residual is combined diffs only. Round 4 caught the rename branch firing without a `diff --git` line (prose injection through commit messages); the guard now leads, with a poisoned-preamble case pinning it. Scoped by the plan review: the drill proves receiptless truncation fails, while a truncation past the manifest still receipts validly from the preamble; the closing nonce, mandatory base/head, combined-diff handling, the NUL cross-check, and the attestation file to D00 T04 §12.
- [x] Check skill-to-plan citations resolve. Done when: the validator names an unresolvable citation by file and line, quoted, with the self-test covering it. Done: check 26 with class `skill-citation-unresolved` (FATAL, README-mirrored) scans full D-refs in every `SKILL.md`; a planted `D00 T04 §99` fails as `SKILL.md:3: skill cites D00 T04 §99, which resolves to no live section`, removal returns to 0 fatal; self-test 507 cases green including the two fixture cases. Scoped by the plan review: only full D-refs are checked, and short forms in skills stay unchecked; filed to D00 T04 §13.
- [ ] Commit: `"workspace: review-input integrity"`

**Test checkpoint:** The time-of-check gap is driven shut, all four regression cases are named, a truncated diff fails loudly, and an unresolvable citation is reported by file and line. All quoted.

-> SOURCE: plan-D00-T04-s6-2026-09-19-PR9 D00-T04-S6-PR9
-> SOURCE: plan-D00-T04-s6-2026-09-19-PR10 D00-T04-S6-PR10
-> SOURCE: plan-D00-T04-s6-2026-09-19-PR11 D00-T04-S6-PR11
-> SOURCE: plan-D00-T04-s6-2026-09-19-PR13 D00-T04-S6-PR13
-> XREF: D00 T04 §11 -- the round-5 advisories this section's panel filed
-> XREF: D00 T04 §12 -- the manifest gaps this section's plan review filed
-> XREF: D00 T04 §13 -- the binding gaps this section's plan review filed

> **Started:** 2026-09-19T06:25:00Z

> **Verified:** 2026-09-19 | §9 | the index binding captures the tree before the patch, verifies the patch against it immediately, and rechecks before committing, drilled both directions on the real index · the four regression probes each drew a naming at high effort, with the stale path sharpening the prompt to verify file existence · the fence emits byte count, file list, sha, and base/head with the file list proven against live git output in every quoting shape, both checkers take `--manifest`, and receiptless truncation fails · skill citations resolve or fail by file and line · panel: 5 rounds at the hard cap plus one voided attempt (another session's contract rode the shared `/tmp` path; the skill now mints per-run directories), 11 findings, 9 fixed in-round, 2 filed to §11 · plan review: 17 findings into §12 and §13 with the Done notes scoped to the proven
> **Review:** round 5 at the hard cap, candidate `2b4b493` `e8ee5e8` `965df5f` `41bdbc1` `bbaaad5` `9495dab` -- `adversarial` advisory at close (F10 filed) after fixes (4) · `consistency` approve after fix (1) · `integration` approve after fix (1) · `source-defect` approve · `design` approve · `record` advisory at close (F11 filed) after fixes (3). Raw findings: docs/reviews/00-workspace/D00-T04-s9.md
> **Plan review:** gpt (run 20260919-D00-T04-S9-gpt) -- filed: D00 T04 §12, D00 T04 §13; 5 rejected with reasons in the ledger
> **CRUD:** this section writes the index-binding skill commands, four driven regression probes, the fence manifest with reviewer receipts, and the skill-citation check. It reads the git index, the staged patch, and the skills; it writes the manifest lines, the receipt rules, and the validator's check 26 (`skill-citation-unresolved`). The only behavioral surfaces it adds are the stamp-time `BLOCKED` rechecks, the `--manifest` receipt verification failing truncated rounds, and the citation FATAL. It touches no user system, no C++, and no shipped behavior.
> **Duration:** 98
> **Implementer:** Muse Code

## 10. Run-Record Follow-Ups

§7 made the runs queryable, and its plan review found the queries §8 will need that the records cannot yet answer: which model version ran, what it cost, what each round had the opportunity to find, and what the review was for. It also found the schema unfinished (no version, no terminology block, `empty` undefined for refuted-only runs, self coverage unstated) and the report unbound to any commit. This section closes those gaps before §8 decides on the records.

- [x] Pin the schema: one terminology block (run, round, engagement, panel), a schema version beside the parser, `empty` defined for refuted-only runs, and the self side stated as ledger-derived with its validation named. Done when: the runs file header carries all four, and a prose-only round still reports through the existing comment rule. Done: the header carries the terminology paragraph, `schema: 1`, the outcome-based `empty` rule, and the ledger-derived self side with its coverage check; the parser asserts it (`SCHEMA_VERSION = 1`, anything else fails as `schema N is not 1; this parser reads 1 only`); the prose-only round D00-T03-S1 round 1 still reports, refs counted (0) and prose explained (`# round 1 raised two P2s recorded in prose only ... They are not counted in the dimensions`), showing as `2 round(s), gpt-6-astra, 0 finding(s), 1 empty`.
- [x] Enrich each round with what §8 must query: provider and exact model version, normalized cost and latency, opportunity-to-find metadata, review purpose, and provenance confidence with unresolved fields marked rather than guessed. Done when: every field is on the round line or in a named sidecar the checker reads, and the backfilled Opus versions read unresolved. Done: all 41 round lines carry `provider/version/cost/latency/opportunity/purpose/provenance`, the checker reads every field (`24 runs, 41 rounds: all resolve, all covered, counts agree`), and the backfilled Opus rounds read `provider: claude version: unresolved cost: unresolved latency: unresolved` (e.g. D00-T02-S5 rounds 3-5), while pinned codex rounds keep their exact versions (`version: gpt-6-astra`).
- [x] Bind every report to its commit and timestamp, and expose a versioned machine export §8 consumes directly. Done when: `--report` prints its as-of, the export has a version the checker asserts, and §8 reads the export rather than the prose. Done: `--report` opens with its as-of, bound by content identity (round 1: the first binding labeled any file with the checkout's HEAD, so the proof quoted a commit older than the data; now the file's hash must equal HEAD's copy). Driven: committed-identical records bind `as-of: f118e300be5ebcc5edc0c1a91a1f66201fd1be44 2026-09-19T08:37:51Z`, while a foreign file and a dirty tree both read `as-of: unresolved` (round 2: the first quote omitted the timestamp the checkpoint requires). `--export` emits `export_version: 1` with the as-of binding, `--check-export` asserts version, schema, as-of shape, run metadata, round values, and internal counts (`export version 1, 24 runs, internally sound`; a tampered copy fails, e.g. `export_version is 99, this checker asserts 1`); §8 now decides `from the run-record export, not the prose` with the version asserted by `--check-export`.
- [x] Preserve dated outcome transitions with their deciding evidence instead of final states only. Done when: a refuted, withdrawn, duplicate, or routed finding keeps its when, why, and evidence, quoted from the record. Done: `docs/reviews/transitions.md` holds one block per non-final row (date/from/to/why/evidence, `to` agreeing with the ledger), `todo-findings.py --check` enforces exactly-one-block completeness (`ledger current, 151 finding(s), transitions complete`, 26 self-test cases green), e.g. `transition: D00-T04-S6-F3 / date: 2026-09-19 / from: raised / to: refuted` with its why and evidence quoted from the §6 record.
- [ ] Commit: `"workspace: run-record follow-ups"`

**Test checkpoint:** The schema block, the enriched fields, the as-of binding, and one transition are quoted from a driven `--report` and `--check`; the export version is asserted, not described.

-> XREF: D00 T04 §7 -- the records this section hardens
-> XREF: D00 T04 §8 -- the decision that consumes the enriched records
-> XREF: D00 T04 §14 -- the sign-off advisory this section's panel filed
-> XREF: D00 T04 §15 -- the plan-review minors this section's review filed
-> SOURCE: plan-D00-T04-s7-2026-09-19-PR4 D00-T04-S7-PR4
-> SOURCE: plan-D00-T04-s7-2026-09-19-PR7 D00-T04-S7-PR7
-> SOURCE: plan-D00-T04-s7-2026-09-19-PR8 D00-T04-S7-PR8
-> SOURCE: plan-D00-T04-s7-2026-09-19-PR9 D00-T04-S7-PR9
-> SOURCE: plan-D00-T04-s7-2026-09-19-PR11 D00-T04-S7-PR11
-> SOURCE: plan-D00-T04-s7-2026-09-19-PR13 D00-T04-S7-PR13
-> SOURCE: plan-D00-T04-s7-2026-09-19-PR14 D00-T04-S7-PR14
-> SOURCE: plan-D00-T04-s7-2026-09-19-PR15 D00-T04-S7-PR15
-> SOURCE: plan-D00-T04-s7-2026-09-19-PR18 D00-T04-S7-PR18
-> SOURCE: plan-D00-T04-s7-2026-09-19-PR21 D00-T04-S7-PR21
-> SOURCE: plan-D00-T04-s7-2026-09-19-PR22 D00-T04-S7-PR22
-> SOURCE: plan-D00-T04-s7-2026-09-19-PR23 D00-T04-S7-PR23

> **Started:** 2026-09-19T08:08:00Z
> **Verified:** 2026-09-19 | §10 | the runs file header pins terminology, `schema: 1`, the outcome-based `empty` rule, and the ledger-derived self side, all asserted by the parser · all 41 round lines carry provider, version, cost, latency, opportunity, purpose, and provenance, backfilled Opus versions reading `unresolved` · the report binds its commit by content identity, driven all three legs (committed-identical records bind `f118e30`, foreign and dirty read `unresolved`) · the export carries version 1 with as-of, asserted field by field including ref homing and uniqueness, and §8 decides from the regenerated export · every non-final finding keeps its transition (3 blocks), enforced exactly-one by `--check` · panel: 3 rounds, 9 findings, 8 fixed in-round, 1 filed to §14 · plan review: 16 findings into §15 and the §8 regenerate-at-decision item
> **Review:** round 3 sign-off, candidate `f118e30` `986d912` `0ab7076` -- `adversarial` advisory at close (F9 filed) after fixes (2) · `consistency` approve after fix (1) · `integration` approve after fixes (3) · `source-defect` approve · `design` approve · `record` approve after fixes (2). Raw findings: docs/reviews/00-workspace/D00-T04-s10.md
> **Plan review:** gpt (run 20260919-D00-T04-S10-gpt) -- filed: D00 T04 §15, D00 T04 §8 item; 12 rejected with reasons in the ledger
> **CRUD:** this section writes the runs-file header (terminology, schema version, empty rule, self side), seven new round-line fields across 41 lines, the content-identity as-of, the versioned JSON export with its asserting checker, and the transitions file with its completeness gate. It reads the review files, the findings ledger, and the git object store; it writes records, never user systems. The only behavioral surfaces it adds are the `--export`/`--check-export` round-trip, the as-of line on `--report`, and the transitions gate inside `--check`. It touches no user system, no C++, and no shipped behavior.
> **Duration:** 2026-09-19T08:08:00Z to 2026-09-19T09:01:00Z
> **Implementer:** Muse Code

## 11. Bind the Rename Scan to the Diff Header

Round 5 of the §9 panel left two advisories at the hard cap: rename lines past the hunk body hijack the block's file list, and the residual clause does not name that shape. The scan only ever fences `git show` output, whose rename lines sit in the header, so pasted input is the only route; still, a manifest that can list files from prose is a manifest that can lie, and the fix is small.

- [x] Stop the rename scan at the hunk body: `--- `, `+++ `, or `@@`. Done when: a post-hunk `rename from/to` pair is ignored, quoted, with the self-test covering it. Done: `_scan_diff_block` breaks at the first `--- `/`+++ `/`@@` line; the self-test's `manifest-rename-stops-at-hunk` case passes with the suite at 30 cases green; the driven `fence` probe resolves to `MANIFEST bytes=310 files=2 titles=SECTION CONTRACT|CANDIDATE DIFF diff-files=real.md` (tag and sha per-run), quoted verbatim. (Round 1: recorded the verdict fragment only; the full manifest line now reads in the section.)
- [x] Confirm the residual: with the scan bound, combined diffs stand as the sole residual. Done when: the comment, the docstring, and the proof quote agree, quoted from the driven run. Done: the module comment, the `_scan_diff_block` docstring, and the driven probe quote agree combined diffs stand sole. (Round 2: the residual sentence was comment-only; added to the docstring.)
- [x] Commit: `"workspace: bind the rename scan to the diff header"`

**Test checkpoint:** The post-hunk probe resolves to the real path, quoted; the residual clause reads the same in code, comment, and quote.

-> XREF: D00 T04 §9 -- the panel that left these at the hard cap
-> SOURCE: panel-D00-T04-s9-2026-09-19 D00-T04-S9-F10
-> SOURCE: panel-D00-T04-s9-2026-09-19 D00-T04-S9-F11

> **Started:** 2026-09-19T18:02:46Z

## 12. Prove the Manifest, Not Just Emit It

§9's plan review broke the manifest's core claim: sha and tag both sit in the preamble, so a truncation past the manifest still receipts validly, and the drill only proved receiptless output fails. Base and head float optional, combined diffs stay an admitted residual, the parse trusts hand-rolled quoting, and no attestation survives the terminal. This section makes the manifest prove what §9 says it proves.

- [ ] Close the preamble hole: the receipt must quote a closing nonce (or equivalent tail-only evidence) verified against a session-side value the prompt never carries. Done when: a truncation past the manifest fails, quoted, and the full receipt still passes.
- [ ] Require base and head on every candidate manifest, and reject a manifest that floats free. Done when: a candidate review without both fails closed, quoted.
- [ ] Parse combined diffs or refuse them explicitly. Done when: a merge candidate either lists every changed file or fails naming the shape, quoted.
- [ ] Cross-check the parsed file set against a NUL-delimited `git diff` file list. Done when: a divergence fails closed, quoted, with the self-test covering it.
- [ ] Emit a machine-readable review attestation: manifest hash, candidate and tree OIDs, reviewer and model identity, verdict, timestamp, and checker result. Done when: one attestation per review exists beside the findings file and the skill reads it back.
- [ ] Commit: `"workspace: prove the manifest"`

**Test checkpoint:** The preamble truncation fails, the full receipt passes, a baseless manifest fails, a merge candidate lists or refuses, the cross-check diverges loudly, and one attestation reads back. All quoted.

-> XREF: D00 T04 §9 -- the manifest this section hardens
-> SOURCE: plan-D00-T04-s9-2026-09-19-PR1 D00-T04-S9-PR1
-> SOURCE: plan-D00-T04-s9-2026-09-19-PR2 D00-T04-S9-PR2
-> SOURCE: plan-D00-T04-s9-2026-09-19-PR3 D00-T04-S9-PR3
-> SOURCE: plan-D00-T04-s9-2026-09-19-PR6 D00-T04-S9-PR6
-> SOURCE: plan-D00-T04-s9-2026-09-19-PR7 D00-T04-S9-PR7
-> SOURCE: plan-D00-T04-s9-2026-09-19-PR17 D00-T04-S9-PR17

## 13. Bind the Stamp to the Push

§9 binds approval to the staged tree at commit time; its plan review found the binding ends too early and trusts too much. The push is unverified, a pre-commit hook can rewrite the tree after the last check, the candidate identity is compared as text rather than resolved, the contradiction and stale-anchor shapes were only half-probed, and short citation forms bypass the validator. This section carries the binding from the index to the push.

- [ ] Recheck at push time: verify the created commit's tree and expected parent, and that the same commit remains at HEAD immediately before push. Done when: a post-review replacement fails closed, quoted, and the skill carries the commands.
- [ ] Fail closed on hook mutation: compare the resulting commit tree with the reviewed tree. Done when: a hook that rewrites the tree forces re-review, quoted.
- [ ] Resolve the candidate mechanically: OID exists, tree matches the reviewed tree, before any stamp is accepted. Done when: an unresolving or mismatched candidate fails closed, quoted.
- [ ] Probe the contradiction shape with conflicting live stamps, and the stale-anchor shape with an existing file behind a dead section, line, or candidate anchor. Done when: each is driven against a staged stamp and named, both quoted.
- [ ] Validate every citation form in skills, or ban ambiguous shorthand there. Done when: the validator names short-form violations by file and line, quoted, with the self-test covering it.
- [ ] Commit: `"workspace: bind the stamp to the push"`

**Test checkpoint:** The push recheck, the hook check, the OID resolution, both probes, and the short-form report are quoted from driven runs.

-> XREF: D00 T04 §9 -- the binding this section extends
-> SOURCE: plan-D00-T04-s9-2026-09-19-PR4 D00-T04-S9-PR4
-> SOURCE: plan-D00-T04-s9-2026-09-19-PR5 D00-T04-S9-PR5
-> SOURCE: plan-D00-T04-s9-2026-09-19-PR8 D00-T04-S9-PR8
-> SOURCE: plan-D00-T04-s9-2026-09-19-PR9 D00-T04-S9-PR9
-> SOURCE: plan-D00-T04-s9-2026-09-19-PR10 D00-T04-S9-PR10
-> SOURCE: plan-D00-T04-s9-2026-09-19-PR11 D00-T04-S9-PR11

## 14. Bar Bool Versions from the Export Gate

The §10 sign-off round proved `check_export` accepts `"export_version": true, "schema": true` as internally sound: the two version gates compare with `!=` against ints, and `True == 1` in Python, while every other integer field in the same checker bars bools through `_is_int`. The exporter never emits bools, so this bites only a hand-crafted export, which is why it filed as an advisory rather than a fix-loop round; still, a gate that asserts versions should assert their type too.

- [ ] Reject bool versions and schemas in `check_export`. Done when: an export carrying `"export_version": true` fails naming the type, quoted, and the live export still passes.
- [ ] Commit: `"workspace: bar bool versions from the export gate"`

**Test checkpoint:** The bool-versioned export fails, quoted from a driven `--check-export`; the self-test covers both gates.

-> XREF: D00 T04 §10 -- the gate this section hardens
-> SOURCE: panel-D00-T04-s10-2026-09-19 D00-T04-S10-F9

## 15. Run-Record Vocabulary and Evidence Follow-Ups

The §10 plan review accepted three minors the enriched records leave open: latency carries a unit (`<int>s`) but no measurement boundary, unresolved-field coverage is reported for cost only, and transition evidence is quoted without a commit binding the quote to the record it came from. All three are small, all three lack an owner, and none blocks §8, which decides from regenerated exports with cost in tokens.

- [ ] Define the latency boundary: what interval a round's `<int>s` measures, stated in the records header beside the unit. Done when: the header names the boundary, quoted, and mixed-boundary values have nowhere to hide.
- [ ] Report unresolved-field coverage per field and model in `--report`, extending the existing cost line. Done when: version, latency, and cost each show recorded-vs-unresolved counts, quoted from a driven report.
- [ ] Bind each transition's evidence to the commit whose tree holds the quoted record. Done when: every block carries the binding, the checker asserts it resolves, and one rebinding failure is quoted.
- [ ] Pin the panel shape against voided rounds: the terminology block states Sol rounds 1-2 with the Opus sign-off at round 3 unconditionally, while the S9 block numbers a voided Sol round 2 and signs off at round 4. Done when: the header admits voids consuming numbers, quoted, and the S9 block reads consistent with it.
- [ ] Carry per-finding dispositions in the export, so a snapshot consumer can compute accepted yield without rejoining live records that may postdate the as-of. Done when: the export asserts dispositions per ref, quoted, and the live round-trip passes.
- [ ] Settle the provider vocabulary: round lines record runner names (`codex`, `claude`) where provider-level queries want the serving provider. Done when: the header defines what `provider` names, quoted, and the closed set matches the definition.
- [ ] Record cost and latency at record time: the review skill writes measured cost in tokens and latency on every new round line, so the §8 value-per-cost comparison stops reading `unresolved`. Done when: the skill carries the recording step, and a round line written by following it resolves both fields, quoted from a driven record.
- [ ] Report the revisit-trigger state in `--report`: panel-reviewed sections counted past the §8 window of five, so the §18 trigger reads from the query rather than a hand count. Done when: the report prints the count with the window named, quoted from a driven report.
- [ ] Give stamp-review rounds a record shape the panel mapping skips, so the STAMP HOLDS verdict survives the session: today a stamp round in a panel block would demand four-lens verdicts it cannot have, and outside one it has no home. Done when: this review's stamp round is recorded, quoted, and `--check` passes.
- [ ] Commit: `"workspace: run-record vocabulary and evidence follow-ups"`

**Test checkpoint:** The boundary reads in the header, the coverage counts read in the report, and the evidence bindings resolve; a fresh round line resolves cost and latency; the report prints the revisit-trigger count; the §8 stamp round reads in the records; all quoted from driven runs.

-> XREF: D00 T04 §10 -- the records this section tightens
-> SOURCE: plan-D00-T04-s10-2026-09-19-PR3 D00-T04-S10-PR3
-> SOURCE: plan-D00-T04-s10-2026-09-19-PR6 D00-T04-S10-PR6
-> SOURCE: plan-D00-T04-s10-2026-09-19-PR10 D00-T04-S10-PR10
-> SOURCE: blind-D00-T04-s8-2026-09-19-term D00-T04-S8-B1
-> SOURCE: div-D00-T04-s8-2026-09-19-I4 D00-T04-S8-D1
-> SOURCE: div-D00-T04-s8-2026-09-19-R4 D00-T04-S8-D2
-> SOURCE: gap-phase0-2026-09-19-cost
-> SOURCE: plan-D00-T04-s8-2026-09-19-PR15 D00-T04-S8-PR15
-> SOURCE: self-2026-09-19-stamp-rounds

## 16. Blinded-Run Checker Defects

The §8 blinded runs re-reviewed `f118e30` with the fixes hidden and found three refusal-shape defects that survive in the shipped checkers, all driven: a duplicate transition block for a dead ref reports "names no live finding" twice without ever reporting the duplicate, `--report --export` silently prints only the report, and `schema: 99` emits the true version error plus a false "no schema declaration". (A fourth find, the panel-shape terminology contradicting the S9 block's voided round 2, filed as a §15 item.) A fifth, the never-defect severity loophole (the parser accepts a refuted finding carrying critical against the stated minor rule), filed from this review's sign-off as the fourth fix item. Each is a five-line fix with a refusal test; none blocks the §8 decision.

- [ ] Report duplicate transition blocks even when the ref is dead. Done when: two blocks for one dead ref draw the duplicate message, quoted, and the live transitions still pass.
- [ ] Reject conflicting `--report --export` flags with a usage error instead of silently printing the report. Done when: the combination fails naming the conflict, quoted, and each flag alone still works.
- [ ] Emit only the version error for a wrong schema declaration, not a false "no schema declaration" beside it. Done when: `schema: 99` draws exactly one message, quoted.
- [ ] Enforce the never-defect severity rule in the parser: a refuted, withdrawn, or duplicate finding carrying anything but minor fails the gate by name. Severity rates surviving contribution, not alleged impact: a duplicate of a critical is minor because it contributes nothing new. Done when: `REFUTED (self) [critical]` is reported naming the rule, quoted, the SEVERITIES comment states the semantic, and the live ledger still passes.
- [ ] Commit: `"workspace: blinded-run checker defects"`

**Test checkpoint:** The duplicate, the flag conflict, and the double message are each quoted from driven runs; a never-defect carrying major or critical fails naming the rule; the self-tests cover all four refusals.

-> XREF: D00 T04 §8 -- the blinded runs that found these
-> SOURCE: blind-D00-T04-s8-2026-09-19-OA3 D00-T04-S8-B2
-> SOURCE: blind-D00-T04-s8-2026-09-19-OI1 D00-T04-S8-B3
-> SOURCE: blind-D00-T04-s8-2026-09-19-OI2 D00-T04-S8-B4
-> SOURCE: panel-D00-T04-s8-2026-09-19 D00-T04-S8-F1
-> SOURCE: plan-D00-T04-s8-2026-09-19-PR18 D00-T04-S8-PR18
-> SOURCE: plan-D00-T04-s8-2026-09-19-PR19 D00-T04-S8-PR19

## 17. Report Without Walking the Corpus Twice

The §8 diversity runs found `report()` calls `TF.collect()` after `run_check()` already collected the same corpus through `cross_check`, doubling repository-wide file reads and parsing on every `--report`. True and cheap to fix by threading the collected findings through; unnoticed because the corpus is 25 files and the report runs in milliseconds, which is also why this is a single-item section rather than a performance project.

- [ ] Thread the collected findings from `run_check` through `report` so `--report` walks the review corpus once. Done when: one `TF.collect()` serves the check and the report, quoted from the code path, the report output is byte-identical before and after, and `--check` and `--export` outputs and exit codes are pinned unchanged, quoted.
- [ ] Commit: `"workspace: report without walking the corpus twice"`

**Test checkpoint:** The report output is byte-identical across the change, quoted; the self-test pins the single collection.

-> XREF: D00 T04 §8 -- the diversity runs that found this
-> SOURCE: div-D00-T04-s8-2026-09-19-P1 D00-T04-S8-D3
-> SOURCE: plan-D00-T04-s8-2026-09-19-PR20 D00-T04-S8-PR20

## 18. Second Two-Model Revisit, Independently Rated

D00 T04 §8 kept both models on a value margin (79 vs 31) computed from severities the implementing session assigned in bulk after every outcome was known, then used to decide. That self-attestation confound is the same one D00 T04 §7 removed for the source split by deriving it from run records; the keep stands on the blinded Jaccard 0.22 corroboration, but the next revisit must not repeat the methodology. This section re-decides after five more panel-reviewed sections with severities assigned independently of the decision. Reading note: where D00 T04 §8 item 1 says both blinded outputs returned PASS, PASS means well-formed four-lens output, not approval.

**Trigger: starts after five more panel-reviewed sections exist in the run records past the §8 window of five.** Counted by query, not by prose. Until the trigger is met this section waits, however its dependencies read: a revisit decided on the same window is a second opinion from the same data.

- [ ] Re-rate severity independently: every finding in the new window carries a severity assigned by a party other than the deciding session (a blinded re-rating pass, or the panel's own rating at finding time), with the rater recorded per finding. Done when: no severity in the window is decider-attested, quoted from the records.
- [ ] Re-apply the §8 cut rule on the new window: rolling five sections, mean blinded Jaccard with a fresh comparison, 9/3/1 weights, recorded cost where available. Done when: each leg reads from regenerated exports, quoted, with the overlap leg dormant rather than cut when the window holds no comparison, and the fresh comparison runs as a controlled crossover: object-isolated snapshots with no future objects, identical prompts, lenses, effort, token limits, tool access, and pinned versions per rung, matched passes per lens per rung, recorded matched pairs with disagreements and rationale, and persisted inputs (export, ledger snapshot, join logic) with hashes.
- [ ] Decide keep or cut with the losing rung's duties reassigned on a cut, and name the third revisit. Done when: the decision is dated, cites the export, and either keeps with the next trigger named or cuts with duties reassigned.
- [ ] Close the cut-rule holes before applying it: directional tie-handling when overlap is high (which rung the trailing clause names on ties, with the margin), and minimum activation (how many blinded comparisons over how diverse a candidate set before the overlap leg can cut). Done when: both rules are stated with worked ties, quoted.
- [ ] Mark the §6 provisional cut rule superseded with a pointer to §8, so one threshold is authoritative (post-stamp prose pointer, following the §1 "Updated by §5" precedent; checklist and stamp untouched). Done when: the §6 rule carries the pointer and no second threshold reads as live.
- [ ] Render the decision inputs as a compact dashboard: matched unique weighted value, cost, latency, outcomes, and confidence by model and candidate class. Done when: the next decision reads the dashboard rather than bespoke prose.
- [ ] Commit: `"workspace: second two-model revisit, independently rated"`

**Test checkpoint:** The window counts five new panel sections by query; no severity in it is decider-attested; the cut rule reads from fresh exports with Jaccard measured; the decision cites the export and names the next trigger. Blocked on the trigger until it is met, explicitly.

-> SOURCE: panel-D00-T04-s8-2026-09-19-signoff D00-T04-S8-F10
-> SOURCE: plan-D00-T04-s8-2026-09-19-PR4 D00-T04-S8-PR4
-> SOURCE: plan-D00-T04-s8-2026-09-19-PR5 D00-T04-S8-PR5
-> SOURCE: plan-D00-T04-s8-2026-09-19-PR6 D00-T04-S8-PR6
-> SOURCE: plan-D00-T04-s8-2026-09-19-PR7 D00-T04-S8-PR7
-> SOURCE: plan-D00-T04-s8-2026-09-19-PR9 D00-T04-S8-PR9
-> SOURCE: plan-D00-T04-s8-2026-09-19-PR10 D00-T04-S8-PR10
-> SOURCE: plan-D00-T04-s8-2026-09-19-PR11 D00-T04-S8-PR11
-> SOURCE: plan-D00-T04-s8-2026-09-19-PR12 D00-T04-S8-PR12
-> SOURCE: plan-D00-T04-s8-2026-09-19-PR16 D00-T04-S8-PR16
-> SOURCE: plan-D00-T04-s8-2026-09-19-PR21 D00-T04-S8-PR21

## Verification

- [ ] `python scripts/todo-claims.py` exits 0 and its self-test stays green
- [ ] Claim coverage cannot fall below its recorded floor
- [ ] Every stamped section has its review findings recorded with a disposition
- [ ] Estimated items are compared against actual cost, with the correlation stated
- [ ] The critical path prints, and nothing re-sequences the plan automatically
- [ ] `python scripts/todo-graph.py validate` clean
