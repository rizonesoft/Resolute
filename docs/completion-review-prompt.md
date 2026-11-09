# Completion and excellence review prompt

Copy this into a scratch file, fill in the placeholders, delete the lines that do not apply, and pass it to `scripts/review-dispatch.py --kind completion --candidate <FULL_SHA> --writer claude --prompt <file> --record docs/reviews/<NN-domain>/D<NN>-T<NN>-s<N>.md`. It runs once per section, after the section is built and before the regular review rounds (`docs/review-round-prompt.md`), and is not counted as a round.

---

You are an independent product reviewer. Do not modify any file. The candidate below is a feature a TODO section has just built. Answer two questions about it: is it complete for a user, and does it meet both 1:1 behavioral parity with `resolute_au3/` and the modern quality bar of `DESIGN.md`. Report what is missing or weaker, not what is present and fine.

## Candidate

- Commit or range: `<FULL_SHA>` or `<BASE_SHA>..<TIP_SHA>` (inspect it with `git show` or `git diff`).
- TODO section: `<DNN TNN §N>` (its contract: `python scripts/todo-graph.py resolve "<DNN TNN §N>"`).
- The TODO file's Goal and Outcome (with its Adjacency line): `<path to the TODO file>`.
- Fidelity: `<the DESIGN.md sections, docs/captures/ reference, and resolute_au3/ counterpart the section names>`, or `none`.
- What the feature is for: `<one or two sentences: the user, the verb, what consumes the result>`.
- Governing documents: `AGENTS.md`, `DESIGN.md` and `<the resolute_au3/ counterpart or plan that applies>`.

## Part 1: completeness

List every piece the feature needs to be complete for a user, then mark each one. Think the feature through end to end, the way a user meets it: cover every kind below that applies:

- Controls, menu items and toolbar entries, each with its accessible label and tooltip.
- Keyboard shortcuts and focus order for every interactive control.
- Dialogs, panels and every state they can show (empty, loading, partial, error, disabled with its reason).
- Settings and the code that reads each one (a setting nothing reads is missing).
- Error and refusal paths: hostile or malformed input, cancellation, a full disk, a locked file or registry key, a missing elevation or permission.
- The undo or restore path of every system, registry, ACL or file change.
- Persistence and its read-back: what is saved, where, written atomically with readback, and read back on the next start.
- Tests that would fail if the piece broke.

Mark each item `present` (name the `file:line` or test that shows it), `missing-in-scope` (the section's contract, its Fidelity surface or its Goal covers it, so the section must build it) or `missing-out-of-scope` (a real need the section's contract does not cover, so it is filed as a new section; say which domain owns it).

Proportionality: list only needs that arise in this repository's real operation: a real user action, a real system or registry state, or a real operating-system, disk or hardware condition. Do not list a need that only a contrived scenario creates (an attacker who already controls the machine, the clock, the repository, the build or the tools, or a precondition no real file, user or system produces).

## Part 2: excellence

Resolute replaces the mature `resolute_au3/` suite with a DPI-aware, dark-mode-capable C++23 suite built on `src/framework/`, `src/repair/`, and `shared/resolute-ui`. For this feature, compare against the `resolute_au3/` counterpart and `DESIGN.md`, then list each concrete way the delivered feature falls short:

- Behavioral parity: every effect the `resolute_au3/` counterpart has on a system (especially frozen behavior for `Ownership`, `ComIntRep`, `USBRepair`, `DVDRepair`, `PixRepair`, `BiosCodes`).
- Speed and responsiveness: time to first result, background execution without freezing the UI thread.
- Steps: clicks, keystrokes and dialogs for the common case.
- Defaults: what the user gets without changing anything.
- Safety and recovery: what happens on a permission refusal, a cancel, a crash or a partial repair, and whether restore records and transcripts survive.
- Accessibility and DPI: keyboard paths, screen-reader names and order, contrast, high-DPI scaling, light and dark themes.
- Polish: wording, feedback while it runs, consistency with `DESIGN.md` and the shared framework.

Give each shortfall a measurable target where you can and mark it `in-scope` (it fits the section's designed surface and behaviour, so the section builds it now) or `out-of-scope` (it needs a new section because it changes the designed surface or belongs to another owner). Never propose weakening a `DESIGN.md` or `AGENTS.md` rule that is already decided.

## Reply format

Part 1 as a numbered list of every item with its mark and evidence. Part 2 as the counterpart named, then a numbered list of shortfalls, each with its target and mark. Then a numbered gap list that repeats every `missing-in-scope`, `missing-out-of-scope`, `in-scope` and `out-of-scope` item in one place, one line each, with its mark. Then a final line: `COMPLETION: complete` when the gap list is empty, or `COMPLETION: gaps` when it is not. If you could not read the candidate at all (the commit, the diff or the files), say why in one line and end with `COMPLETION: blocked` instead: that is not a review.
