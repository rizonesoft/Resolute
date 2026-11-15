# Brief: drafting one app's spec

You are drafting ONE JSON spec file that `tools/app-split/finish-app.py` turns into a Windows tool's README, design guide and implementation plan. The session that sent you here names the app, its fixed values and its sources. Work only on that app's spec and folder. Do not run git commands that change anything, do not commit, do not touch any other app.

## Read first

1. `D:\Resolute\tools\app-split\specs\Ownership.json`: a finished spec. Yours has exactly the same keys and the same style. For an app with a memory graph or several source tools, `MemBoost.json` and `DriveRepair.json` are further examples.
2. `D:\Resolute\tools\app-split\finish-app.py`: the generator. Read `design_md`, `readme_md`, `reference_md` and `plan_md` to see how every field is used.
3. The app's `docs\origin\` folder: its plan section as it stood in the Resolute repository. This is the main source of known information. Where a file covers two tools, take only what concerns this one.
4. The app's source material under `reference\au3\` (see `MOVED-FROM.tsv` there for what exists). Read enough to confirm what the origin text says and to cite real `file:line` references. Use Grep to find functions. Never guess a line number.

## Rules for everything you write

- No em dashes and no en dashes anywhere. Use commas, colons, parentheses or full stops.
- Plain, concrete English. No marketing words. No invented statistics or figures: only numbers read in the sources.
- Paths are relative to the app repository. New C++ files go under `src/core/` and `src/ui/`, tests under `tests/`.
- Every plan item (in `baseline_items`, `inventory_items`, `engine.items`, `parity_items` and enhancement `items`) is ONE string with: one action; at least one path, symbol or command in backticks; the words "Done when:" followed by an observable end state; and, on items that write to the system or build UI, "Cheaper substitute:" followed by the shortcut that must fail. Cite `<file>:<line>` when describing behaviour taken from the source material.
- Section titles (`engine.title` and each enhancement `title`) are noun phrases of at most 34 characters.
- `plan.scope` is at most 60 characters.
- The top-level `"job"` is one sentence starting with "it" and ending with a full stop, saying what the tool does (see Ownership.json).
- The window is the suite's Sidebar tool window. `window.sections` lists the tool's own sections first (the session names them), then exactly `["Activity", "<one sentence>"]`, `["Settings", "The suite's settings pages from the framework"]`, `["About", "The framework's About page for this tool"]`.
- `icon.large` and `icon.small` stay empty strings: the session fills them.

## The fields

- `window`: `rows` (4 or 5 `[name, state words]` pairs for the first section, from the source material), `primary`, `secondary`, `status`, `job`, `notes` (5 to 7 bullets on the first screen's behaviour: row states shown with an icon and a word, the primary action, undo where there is one, options, the status bar, confirmations, refusal when not elevated where that applies), `cut` (one paragraph naming what the source material's window had that this one does not, such as menus, a splash, animations or a donate strip, saying they are cut and recorded in the plan).
- `readme`: `lead` (one sentence), `what` (2 short paragraphs), `new_intro` (one sentence), `new` (3 to 5 `[bold phrase ending with a full stop, sentence]` pairs).
- `reference.note`: one or two sentences a reader of `reference/au3` should know, from the sources, including how the folder is laid out when it is not the usual `src/`, `shipped/`, `dist/` shape.
- `plan`: `goal` (one paragraph), `current_state` (one paragraph of measured facts: line counts, what the source material does, what exists; say the SDK's framework, repair contract and chart control are planned in Resolute-SDK and not built), `inputs` (3 bullets with backticked paths), `outcome` (3 bullets), `adjacency_rationale` (one paragraph: the list is the first screen, reporting and audit are Activity, settings are the framework's pages, where permissions anchor or why they do not apply, and what reverse means here), `baseline_items` (2 or 3: how to record what the source material does, into `docs/baseline/`), `inventory_items` (3 or 4: windows and controls, strings, behaviours, settings and ship list, into `docs/inventory.md`), `parity_items` (2), `verification` (3 bullets).
- `plan.engine`: the tool's core, independent of any window. `title`, `intro`, `needs` (`"windows-host"`), `build` (exactly 2 strings, each with a backticked path and "Done when:"), `items` (6 to 9), `checkpoint` (one sentence with a runnable command in backticks: `sdk\\reskit\\cmake\\bin\\ctest.exe --preset debug -L <label>`), `commit` (a short imperative message with a scope prefix such as `core: ...`).
- `plan.enhancements`: 2 to 4 entries, each with `title`, `intro`, `build` (2 strings), `items` (3 to 6), `checkpoint`, `commit`, and for anything a user sees a `surface` object with `fidelity`, `job` and `treatment` strings. At most one enhancement has `"reverse": true` (the one that provides undo), and that one also has `"needs": "sdk-framework"`. An enhancement that needs the SDK's chart control or framework has `"needs": "sdk-framework"`. Do not include `depends`.
- `plan.no_reverse`: empty when one enhancement has `"reverse": true`; otherwise a short reason in lower case with no full stop.

## Validate, and iterate until it passes

```
cd D:\Resolute ; python tools\app-split\finish-app.py tools\app-split\specs\<App>.json --replace todo/00-<slug>/TODO-01-<slug>.md
cd D:\Resolute_Bin\<App> ; python scripts\todo-graph.py validate --all
```

The first command must end by listing the plan sections; the second must print `valid: N sections`. If the validator refuses something (a title too long, a table row over 120 characters), fix the spec and run both again. The generator also writes `README.md`, `DESIGN.md`, `brand/build.py` and the reference README in the app folder: that is expected. Check the JSON holds no em or en dash.

## Report back

The path of the spec, the validator's final line, the list of plan section titles, and anything in the sources that was unclear or that you could not confirm, with `file:line`. Do not paste the spec.
