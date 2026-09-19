---
name: plan-new-tool
description: Plan a brand-new Resolute tool from an idea to a distribution-ready TODO file -- job definition, competitor survey, full surface and behavior plan, finer details included. Use when a tool needs creating from nothing.
---

# Plan New Tool

A new tool planned as "a window with the feature" ships as a demo with a version number. This skill exists to prevent that: it defines the job, surveys what the competition ships, and plans every surface, behavior, state, and string the tool needs to be whole, down to the tooltips and the empty states.

## Workflow

### 1. Define the job

Write one paragraph: whose problem, in what situation, and what "fixed" looks like to them. Then write the non-goals: the adjacent problems this tool does not solve, so scope has a fence. Then search the tree (`add-todo`) for an existing tool or planned tool that owns any of it; a new tool that duplicates one is a defect at birth.

Record the working name, the one-line purpose (it will be quoted by the launcher, the About dialog, and the guide), and the audience: a tool for a technician and a tool for someone whose machine is broken are specified differently.

### 2. Survey the competition

Find two or three tools that do this job today, use each one, and write the feature table: their surfaces, their behaviors, their finer details (empty states, failure messages, keyboard support, first-run, export), and what each does badly. Every row names the version used. The table is the bar: the plan matches every detail that matters and names what beats each competitor, feature by feature. A plan written without touching the competition invents a market that does not exist.

### 3. Define the surfaces

Specify the tool control by control, following the shape of the launcher and framework surface specs (`D03 T02 §3`, `D01 T03 §1`): main view, toolbar with every button, menus, status bar, dialogs, Preferences page, log usage, and notifications. For each surface name its controls, its strings with pack sources, its states, and its empty, loading, and failure presentations. No placeholder, no hardcoded string, no "details at build time": a builder who must invent a control inherits a gap, not a freedom.

Decide repair-contract membership with a reason: if the tool changes a user's system it consumes the contract (`D02 T01 §1`: diagnose, result list, transcript, restore, undo); if not, say why not.

### 4. Define the behaviors

Every tool, no exceptions, plans its share of: settings keys with defaults through the framework writer, one log line per action, localization with no hardcoded string, update participation, elevation (checked at the action), crash report and single instance, command line with exit codes, About from the registry (`D01 T01 §12`), F1 context help, and the same-commit guide page (`D08 T01 §1`). Anything genuinely not applicable carries a stated reason; silence is not a reason.

### 5. Define acceptance

Each section is born complete per `create-todo`: context, micro-step checklist with Done-when per item, Test checkpoint with a cheaper-substitute-that-fails line, Fidelity/Job/Treatment/Chrome on UI sections, Commit item. New behavior has no parity baseline, so every Test checkpoint drives the behavior and quotes it, including the failure path: corrupted input, missing privilege, unreachable network, full disk. Unit tests run under the harness (`D00 T02 §1`); the tool passes the conformance check (`D07 T01 §3`).

### 6. Finer-details pass

Walk every section and confirm each of these is owned somewhere: tooltips on every icon-only control, accessible names on everything, logical tab order, DPI scalings and both themes, reduced motion and high contrast, first-run, upgrade from a previous version, export formats that match the rendered view, confirmation texts naming what, how many, and how large, and refusal texts naming the action and what it needed. Anything unowned gets an item on its section now, not a wish for later.

### 7. Author, wire, validate, commit

Author the file through `create-todo` in domain `05-new-tools`. Wire the plan rows with Depends On edges so shared-layer dependencies sequence first and distribution items sequence after the behavior they ship. Then:

```bash
python scripts/todo-graph.py validate
python scripts/todo-graph.py plan --sync
python scripts/todo-graph.py plan --check
```

Commit as one `todo:` commit. Report the file, its sections, the competitor table with what beats each rival, and the new plan totals.

## Combined use with plan-tool-port

When the tool builds on an incomplete port or sample, read that skill's inventory first and scope this skill to the gaps: the job paragraph starts from what exists, the competitor survey covers the finished tool, and new sections land in the **same** file after the parity sections. Never re-inventory what the port skill already recorded; cite it.

## Guardrails

- Do not plan without the job paragraph and the non-goals. A tool without a fence grows until it ships nothing.
- Do not skip the competitors. An unbeaten rival the plan never looked at beats it by default.
- Do not plan a second implementation of anything the framework or the repair contract owns.
- Do not leave a surface half-specified. Empty, loading, and failure presentations are part of the surface.
- Do not file a "polish" section. Finer details live as items on the sections that own them.
- Do not invent competitor features. The table comes from using the competitors, and each row names the version used.
