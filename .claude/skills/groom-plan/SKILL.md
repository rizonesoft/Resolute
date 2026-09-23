---
name: groom-plan
description: Harden the todo tree for a weaker executor -- sequence check, drift sweep, gap scan, complete-feature pass -- without moving rows between phases, ticking boxes, or starting a campaign. Use before a long run, or when the plan feels stale.
---

# Groom Plan

## Evidence before reordering

```bash
python scripts/todo-graph.py query sequence
```

It prints the longest dependency chain, which is where delay costs most, and every coupling the review findings recorded: a section that filed a finding to another section ran into work that section owns, which the dependency graph does not carry.

Read what it says about direction before acting on it. **A filing is not proof the order is wrong.** Most filings are work discovered early rather than work needed first, and nothing in the data separates those. `D00 T04 §4` records the case in this plan where acting on the signal would have inverted a correct order.

The command proposes and cannot act: it opens no file for writing. Reordering happens here, by hand, with the addresses and cross-references kept consistent as below.

Hardening the tree so a weaker executor can run it. Grooming adds prerequisites and fills gaps; it never moves a row out of its phase, never ticks a box, and never starts a campaign.

## Workflow

### 1. Sequence check

For every dependency edge (section-level `Depends On` and file-level `depends_on`), confirm the prerequisite sits no later than its consumer in phase/row order. Where an edge points later:

- Prefer adding or splitting the prerequisite under the consumer's phase (a small new section with a dated note), so the consumer's row can run in order.
- Never move the consumer's row: phase membership is stable, and moving rows rewrites the plan's history.
- Record each fix with `**Corrected YYYY-MM-DD:**` or `**Groomed YYYY-MM-DD:**`.

Run `python scripts/todo-graph.py validate` after every structural edit. Cycles are FATAL: break them at authoring time.

### 2. Drift sweep

Walk every open section's concrete claims against today's repository: scripts, functions, includes, paths, counts, versions, ini keys. Correct drift in place with dated notes, exactly as `process-todo-section` steps 2-3 do, but tree-wide and without building anything.

Pay special attention to:

- "Nothing exists yet" claims that are no longer true.
- Counts and versions quoted confidently (these age fastest).
- Deferrals whose descriptions drifted while their owners stayed open.
- XREFs whose targets moved or shipped (reciprocity still holds, or the line is corrected).

### 3. Gap scan

Read the plan as the user will use the finished product, domain by domain, and ask what has no owner: surfaces, controls, handoffs, error paths, settings without consumers, writes without readback. File each gap with `add-todo` (evidence, owner, dependency), place the new rows in their phases, and sync the plan.

Check the Adjacency declarations while here: `python scripts/todo-graph.py query adjacency` advisories that name real gaps become sections; ones that are already covered get their anchors sharpened.

### 4. Complete-feature pass

For every UI surface in the plan, confirm the feature is whole: list, find, create, edit, delete (or the honest not-applicable), settings with consumers, elevation exercised both ways, and the reverse of every create. For every destructive system action, confirm the backup, the restore, the refusal path, and the log line. For every shared include, confirm every tool that should consume it does. File what is missing; do not redesign what exists.

### 5. Report and commit

Write the groom record: what was sequenced, what drifted and was corrected, what gaps were filed and where they landed, what the totals now say. Commit as `todo: groom <scope> (<date>)` after a final `validate` plus `plan --sync` plus `plan --check`.

## Guardrails

- Do not move a row out of its phase. Add or split prerequisites instead.
- Do not tick a box. Grooming never ships.
- Do not start a campaign. Grooming prepares one.
- Do not redesign sections. Harden them.
- Do not leave the tree unvalidated. `validate` plus `plan --check` pass before the commit.
