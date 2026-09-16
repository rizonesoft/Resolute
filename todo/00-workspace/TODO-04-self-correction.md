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
|   2   |   §2    | The review-finding ledger                  | --         |  [ ]   |
|   3   |   §3    | Section calibration                        | §2         |  [ ]   |
|   4   |   §4    | Re-sequencing on evidence                  | §3         |  [ ]   |

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

  **Answered 2026-09-17 against the real ledger.** Three categories are already past two:

  **`consistency`, 6 findings.** The shared shape is *a fact declared in one place and never reconciled with the other place that depends on it*: four claims citing a gitignored tree, `AGENTS.md` not listing directories the merge landed, a resource id defined twice, identifiers surviving a rename because the search pattern was narrower than the rule.

  One cheap check exists and is **built here**: a claim may not cite a path this repository ignores. That is the `§1` F1 case exactly, it costs one `git check-ignore` call per claim, and it would have failed on the day those four claims were written instead of surviving until a reviewer read them. The rest of the category has no single cheap check, and saying so is the honest half of this answer: "two things that should agree do not" is the definition of a defect, not a pattern a tool can recognise. What replaces a check is narrower rules, and `§3` adopted one when its rename pattern missed three identifier families: search for the old name in **any** spelling rather than the spellings somebody enumerated.

  **`record`, 5 findings.** The shape is *a figure or reference in prose that nothing re-measures*. This one already has its check and it is `§1`: claims re-measure figures, and `--coverage` names the blocks carrying none. Two of the five findings are specifically a figure describing the file it sits in, which no re-measurement can fix because writing the figure changes it. The rule that replaces a check is recorded in both places it bit: **do not state a count of a file inside that file**, and `todo/00-workspace/TODO-03-codebase-intake.md` and `TODO.md` both now say why no such count appears.

  **`correctness`, 2 findings.** Both are the same inversion: *a check that reports success for its own absence*. The claims checker dropped an unparseable claim and still printed "all hold"; the coverage floor passed when every claim was deleted. The check is a discipline rather than a script, and it is now in this file: **a new check ships with a self-test that constructs its failing case**, not merely one that confirms the passing case. `codex` found the second instance precisely by writing probes that built the failure, which is the same technique.

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

## 3. Section Calibration

The plan estimates effort as an item count. Nothing has ever checked whether that number predicts anything, and after a hundred sections it either does or it does not.

- [ ] Record per section what it actually cost: commits, elapsed sessions, and whether it needed a follow-up commit after review. Done when: the record exists for each stamped section and is derived from git rather than typed.
- [ ] Compare against the item count. Done when: a report shows estimated items against actual cost, and the correlation is stated rather than assumed.
- [ ] Identify the sections that were badly wrong in either direction. Done when: outliers are named, because a section that took five times its estimate usually means the section was really several.
- [ ] Feed it back into sizing. Done when: the item-count guidance in `todo/README.md` is either confirmed by the data or revised, and the revision cites the data.
- [ ] Record what calibration cannot tell you. Done when: it states that a slow section may have been slow for reasons outside the plan, so an outlier is a question rather than a conclusion.
- [ ] Commit: `"self-correction: measure what a section actually cost"`

**Test checkpoint:** Actual cost is derived from git for every stamped section, not typed. The estimate-versus-actual report prints and states a correlation. Outliers are named. The sizing guidance is confirmed or revised against the data.

## 4. Re-Sequencing on Evidence

`query ready` answers what is dependency-safe. It does not answer what is **wise**, and the plan's order otherwise reflects the order things were written in.

- [ ] Report the critical path: the longest dependency chain to a shippable product. Done when: it prints, and the sections on it are identified as the ones whose delay costs most.
- [ ] Surface a dependency that evidence contradicts. Done when: a section repeatedly blocked, or one whose review findings show it needed something not in its dependencies, is reported as a candidate for re-sequencing.
- [ ] Keep re-sequencing a decision, never automatic. Done when: the tool proposes and a human disposes, and this section records why: a dependency exists for a reason the graph cannot see, and an automatic reorder would discard that reason silently.
- [ ] Route a proposed change through `groom-plan`. Done when: re-sequencing happens through the existing skill rather than a second mechanism.
- [ ] Commit: `"self-correction: propose a better order, and let a human take it"`

**Test checkpoint:** The critical path prints and its sections are named. A fixture section blocked repeatedly is reported as a re-sequencing candidate. The tool proposes and does not act, proven by there being no write path. A proposed change routes through `groom-plan`.

## Verification

- [ ] `python scripts/todo-claims.py` exits 0 and its self-test stays green
- [ ] Claim coverage cannot fall below its recorded floor
- [ ] Every stamped section has its review findings recorded with a disposition
- [ ] Estimated items are compared against actual cost, with the correlation stated
- [ ] The critical path prints, and nothing re-sequences the plan automatically
- [ ] `python scripts/todo-graph.py validate` clean
