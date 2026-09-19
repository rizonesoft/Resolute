---
name: plan-tool-port
description: Plan the full conversion of an AutoIt tool into a Resolute C++ tool -- complete inventory, shared-layer mapping, 1:1 parity plan, then fenced enhancements that make it the ultimate tool. Use when a tool needs porting from resolute_au3/.
---

# Plan Tool Port

A port planned from memory ships without the parts nobody remembered. This skill exists to prevent that: it inventories the AutoIt tool completely, maps every piece to the framework, the repair contract, or tool-specific code, plans the parity work that proves 1:1 behavior, and only then plans the enhancements that beat the original and the competition.

Two phases, in order, never mixed: **parity first** (the same effect on a system, proven against the same fixture), **enhancements after** (new behavior, fenced as new, each with its own acceptance). A section that ports and improves at once proves neither.

## Workflow

### 1. Identify the source

Find everything the tool is, not just its script:

```bash
ls resolute_au3/SDK/Concrete/<Tool>/
ls resolute_au3/Resolute/Language/<Tool>/ 2>/dev/null
find resolute_au3 -iname '<Tool>.sni' -o -iname '<Tool>.au3' | head
```

Read the `.au3` main script, the `.sni` build descriptor, the English language pack (UTF-16: decode with `iconv -f UTF-16 -t UTF-8`), the documentation set, and the update file. For a sample rather than a Concrete tool, read the sample directory the same way and record what a sample lacks (descriptor, packs, docs) as scope, not as an excuse.

Check whether the tool is frozen: `Ownership`, `ComIntRep`, `USBRepair`, `DVDRepair`, `PixRepair`, `BiosCodes` (AGENTS.md). A frozen tool's computed effect is reproduced exactly; enhancements to a frozen tool add surfaces and conveniences around the effect, never change the effect.

### 2. Inventory everything

Walk the source and write down every one of these. Cite `file:line` for each; a plan that says "the dialogs" without naming them is not an inventory.

- **Windows and dialogs:** every `GUICreate`, with its size, style flags, and purpose.
- **Controls:** every control-creation call per window, grouped by window: buttons, lists, tabs, menus and their items, inputs, combos, checkboxes, status elements, tray icon and its items.
- **Strings:** every language-pack section the tool reads, and every hardcoded string (each hardcoded one is a localization defect the port fixes).
- **Behaviors:** every registry key, file, service, process, driver, scheduled task, firewall rule, or network call the tool touches, with read versus write marked.
- **Settings:** every key, its default, its file, and the portable-versus-installed distinction.
- **Logging:** what it logs, what it does not (a tool that logs nothing owes the log surface, not an exemption).
- **Elevation, CLI, and exit codes:** what needs privilege, what arguments exist, what codes return.
- **Update, About, and help:** how it checks, what its About shows, what documents it.
- **Installer and distribution:** what ships with it (packs, docs, drivers, icons), and any install-time special case.

Then run the shipped tool once and confirm the inventory against the running surface. Source that never executes is still scope until proven dead; dead code is cut with a stated reason, never silently dropped.

### 3. Map to the shared layers

For every inventoried piece, name its new home:

- **Framework** (`D01 T01 §1`): settings, logging, localization, update, elevation, preferences host, About (`D01 T01 §12`), crash, single instance, CLI, F1 help. Anything here is consumed, never reimplemented.
- **Repair contract** (`D02 T01 §1`): only if the tool changes a user's system. Diagnose pass, result list, transcript, restore record, undo, one log line per action.
- **Tool-specific:** what is left. If nothing is left, say so; a tool that is pure framework plus a descriptor is a valid outcome.

A second settings writer, log format, About dialog, progress bar, or message box anywhere in the plan is a defect in the plan. Name the reuse per item so the builder never has to guess.

### 4. Plan parity

One section per surface or behavior cluster, each born complete per `create-todo`: context, micro-step checklist with Done-when per item, Test checkpoint with a cheaper-substitute-that-fails line, Fidelity/Job/Treatment/Chrome on UI sections, Commit item.

Every parity section owes the parity proof: the C++ tool and its `resolute_au3/` counterpart run against the same fixture and produce the same effect, compared field by field. Frozen tools prove byte-for-byte effect on registry, ACLs, or drive contents; the section names the fixture and the comparison.

### 5. Plan enhancements (the ultimate tool)

Only after parity is fully planned. Survey two or three competing tools, use each one, and write the feature table: what they do that this tool does not, what they do worse, and what nobody does. Every enhancement becomes its own section **after** the parity sections, each fenced as deliberate new behavior with:

- What it does and which competitor gap (or original gap) it closes.
- Its acceptance: driven behavior, quoted, with failure states.
- Its non-interference proof on frozen tools: the frozen effect is unchanged, proven by re-running the parity fixture.

Then the finer-details pass, as checklist items on the owning sections, never as a vague "polish" section: every empty state, every failure state, every tooltip, keyboard reachability with tab order, screen-reader names, DPI scalings and both themes, reduced motion, first-run, upgrade from the AutoIt version, and the exact texts with pack sources.

### 6. Distribution-ready checklist

The plan is not complete until every section that needs one owns its share of: settings migration from the AutoIt file, language-pack coverage, the documentation set (`D08 T01 §1`), the application icon, installer and update-file entries (`D06 T01 §3`, `D06 T01 §5`), About and F1 and the same-commit guide page, unit tests (`D00 T02 §1`), and the conformance check (`D07 T01 §3`).

### 7. Author, wire, validate, commit

Author the file through `create-todo` in domain `04-tools-port` (a port) or `05-new-tools` (a sample becoming a product). Wire the plan rows with Depends On edges so parity sequences before enhancements and distribution items sequence after the behavior they ship. Then:

```bash
python scripts/todo-graph.py validate
python scripts/todo-graph.py plan --sync
python scripts/todo-graph.py plan --check
```

Commit as one `todo:` commit. Report the file, its sections, the enhancement list with the competitor gaps each closes, and the new plan totals.

## Guardrails

- Do not plan from memory. Every inventoried piece cites `file:line`.
- Do not plan a second implementation of anything the framework or the repair contract owns.
- Do not mix enhancement into parity. A section proves sameness or newness, never both.
- Do not change a frozen effect. Enhancements to a frozen tool surround the effect; the parity fixture re-runs after each one.
- Do not file a "polish" section. Finer details live as items on the sections that own them.
- Do not invent competitor features. The table comes from using the competitors, and each row names the version used.
