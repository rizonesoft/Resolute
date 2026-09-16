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
> **Current state (verified 2026-09-16):** What exists is real but partial. `validate` proves the tree is **internally consistent**: every section has a row, every reference resolves, every stamp covers what it claims, and a stale deferral is FATAL. `plan --check` keeps the projection honest. `self-test` guards the tooling with 393 cases. A warning ratchet is planned in `D07 T01 §2`. `scripts/todo-claims.py` exists and re-measures the factual claims TODOs make, with 11 claims live and 13 self-test cases.
>
> What does **not** exist: nothing notices that a `Current state` block has gone stale when it carries no claim; nothing records what a section actually cost against what it was estimated to; nothing categorises what reviews find, so the same class of defect can be found five times without ever becoming a check; and nothing re-sequences the plan when evidence says the order was wrong.
>
> The evidence this is needed: on 2026-09-16 the tree carried a section describing registry backup behaviour `ReBar` has never had, a submodule recorded as vendored source, one repair declared in two tools, and four skills instructing an executor to run `Au3Check` over C++. **Every one was caught by a human reading the tree.** That is not a process.

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
|   1   |   §1    | Staleness detection for every claim-free block | --     |  [ ]   |
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

- [ ] Report claim coverage per `Current state` block. Done when: `--coverage` names every block with no claim, and the count is recorded here as the starting point.
- [ ] Detect a block whose cited files have changed since its stated verification date. Done when: a deliberately aged block is reported and a current one is not, both driven.
- [ ] Distinguish suspect from wrong. Done when: the output says a block **may** be stale because its sources moved, rather than asserting it is, because the check cannot read prose.
- [ ] Make coverage ratchet rather than threshold. Done when: coverage may not fall below its recorded value, and raising the floor is a recorded decision. Cheaper substitute that fails the checkpoint: requiring full coverage immediately, which produces a hundred claims written to satisfy a check rather than to record a measurement.
- [ ] Wire into `scripts/check-all.ps1`. Done when: a stale claim or a fallen coverage floor fails the combined gate.
- [ ] Commit: `"self-correction: report a current-state block whose sources moved"`

**Test checkpoint:** `--coverage` names every claim-free block and records the starting count. A deliberately aged block is reported as suspect and a current one is not, both driven. Coverage cannot fall below its recorded floor. A stale claim fails `check-all.ps1`.

## 2. The Review-Finding Ledger

Both reviewers, the independent `codex review` and `review-todo-section`, produce findings that vanish once the section is stamped. A defect class found five times across five sections should have become a check after the second.

- [ ] Record every review finding in `docs/reviews/findings.md` with its section, its category, and what was done about it: fixed, refuted, or filed. Done when: a section's findings are recorded as part of its stamp rather than in prose that scrolls away.
- [ ] Use a small closed category set, and record it. Done when: the categories exist, and anything that does not fit gets a new one by decision rather than by invention at the point of writing.
- [ ] **Make a repeat a trigger.** Done when: the second finding in one category raises the question of what check would have caught it, and the answer is recorded even when the answer is that no cheap check exists.
- [ ] Report the pattern. Done when: `scripts/todo-claims.py --findings` or an equivalent prints counts per category, so the shape is visible without reading every stamp.
- [ ] Record what the ledger cannot do. Done when: it states that a category count is a signal rather than a verdict, because an early category is often just the first section touching that area.
- [ ] Commit: `"self-correction: a ledger of what review keeps finding"`

**Test checkpoint:** A fixture set of findings is recorded with section, category, and disposition. A second finding in one category triggers the recorded question and the answer is present. The per-category report prints counts. The ledger's stated limits are written.

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
