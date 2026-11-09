# AGENTS.md

Agent instructions for this repository. Every agent harness, Claude Code included, loads this file directly: Claude Code reads `AGENTS.md` in place of `CLAUDE.md` since v2.1.277, so no `CLAUDE.md` stub is kept.

## What this project is

`Resolute` is Rizonesoft's suite of Windows system utilities: a launcher plus thirteen tools.

It is being **rewritten in C++** from a mature AutoIt3 implementation. The AutoIt suite still ships and still works; the C++ suite is what replaces it, one framework first and then the tools.

| Path | Purpose |
| ---- | ------- |
| `src/` | The launcher shell |
| `shared/` | The framework and the UI library. Every tool consumes these |
| `extensions/` | The tools, each building as a standalone executable |
| `reskit/` | The portable toolchain: llvm-mingw, CMake, Ninja, downloaded into it and gitignored, plus the tracked environment and build helpers. Renamed from `exokit/` by `D00 T03 §3` |
| `scripts/bootstrap.ps1` | The one entry point that downloads the toolchain into `reskit/`. `D00 T01 §1` hardens it |
| `resources/` | Application icons and embedded resources |
| `resolute_au3/` | The frozen AutoIt suite. **The executable specification**, not a maintenance target |
| `resolute_au3/todo/` | The archived AutoIt plan, superseded 2026-09-16, kept for its per-tool analysis |
| `DESIGN.md` | **The design contract.** Every user-facing surface is held to it |
| `todo/` | The live execution plan; read `todo/README.md` before authoring or implementing |
| `todo/implementation-plan.md` | Ordered execution plan synchronized through `scripts/todo-graph.py` |
| `scripts/` | Neutral tooling: the TODO graph, validator, adjacency inspector |
| `docs/` | Captures, reviews, phase runs, reports, the brainstorm record |
| `build/` | Ignored derived output, never an authoritative record |

Everything here is Windows-only, the TODO tooling (`scripts/`, plan checks) included: it is stdlib Python 3, run on the Windows development host and on CI's `windows-2025` runner, and nothing tests it elsewhere (D00 T01 §9).

## The decisions this project runs on

Recorded in `docs/brainstorm/2026-09-16-completion-brainstorm.md`. Read it before proposing anything that contradicts one.

- **C++23 on MSVC 2022**, built with CMake and vcpkg.
- **wxWidgets, statically linked.** One self-contained executable per tool. Chosen over WinUI 3, Qt 6, and raw Win32; the rationale is in the brainstorm record and the deciding constraint was standalone distribution.
- **Catch2 v3** for tests.
- **1:1 on behavior, not on pixels.** The C++ tool must have the same effect on a system as its AutoIt counterpart, proven by running both against the same fixture. The UI is rebuilt rather than reproduced, because the AutoIt windows are not DPI-aware and have no dark mode.
- **Framework first, then the tools.** One vertical slice through `Ownership` proves the framework end to end before the remaining tools port.
- **Every tool is distributed independently.** Its own download, update file, language packs, documentation, and About page. A tool may never depend at runtime on another tool, on the launcher, or on a suite-wide file. "Shared" always means shared at author time or build time.

## The two shared layers

This is the architecture. A defect is anything that reimplements either layer privately.

| Layer | Consumed by | Owns |
| ----- | ----------- | ----- |
| Framework | every tool | startup, working directories, settings, configuration load and save, preferences dialog, language list, update check, logging, process priority, About, shutdown, DPI, dark mode |
| Repair contract | the repair tools only | diagnose pass, result list with per-item status, transcript export, restore record, undo, one log line per action |

The AutoIt suite failed this test: `ReBar` was a framework people copied rather than included, so fourteen tools carry fourteen copies of it, roughly 21,000 of the AutoIt tree's 43,000 lines. Seven tools ended up writing settings to `.lng` and seven to `.ini` because the path was typed out fourteen times. Do not recreate that.

## The source layout

**Declared here so no section has to invent it.** A checklist item that changes code and does not name a file targets the file its section owns below. Where a section adds a file, it goes in the directory its layer owns.

```
src/
  framework/            consumed by EVERY tool
    App.h/.cpp                lifecycle and startup order      D01 T01 S1
    ToolDescriptor.h          the per-tool values, no behaviour D01 T01 S1
    Settings.h/.cpp           one writer, one path             D01 T01 S2
    Logging.h/.cpp            one format, one writer           D01 T01 S3
    Localization.h/.cpp       pack loader and key resolution   D01 T01 S4
    Update.h/.cpp             check, and the Successor notice  D01 T01 S5
    Elevation.h/.cpp          the guard and its refusal        D01 T01 S6
    Crash.h/.cpp              handler and report               D01 T01 S10
    SingleInstance.h/.cpp     the per-tool guard               D01 T01 S10
    CommandLine.h/.cpp        grammar and exit codes           D01 T01 S11
    ui/
      AboutDialog.h/.cpp      built from the descriptor        D01 T01 S7
      Preferences.h/.cpp      the host, and tool pages         D01 T01 S7
  repair/               consumed by the REPAIR tools only
    RepairItem.h              the declared item shape          D02 T01 S1
    RepairRun.h/.cpp          the shared loop, and pre-flight  D02 T01 S1, S2
    ResultList.h/.cpp         per-item outcome and counts      D02 T01 S3
    RestoreRecord.h/.cpp      prior state, and undo            D02 T01 S4
    Transcript.h/.cpp         the carryable result             D02 T01 S5
shared/
  resolute-ui/          the Direct2D UI library, from the intake. Namespace `rui::`, include prefix `resolute/`, export macro `RESUI_API`
  lucide/               icon set
extensions/<Tool>/      one directory per tool, one standalone executable
tests/                  Catch2 suites, fixtures, and the parity driver
```

**The rule this encodes:** a tool never adds a file under `src/framework/` or `src/repair/`. If a tool needs something shared, it goes in the shared layer with a section that says so, which is what stops the fourteen-copies failure from recurring.

## Specify a tool before building it

A tool is **never** built from a single checklist item. Anything larger than a one-surface utility gets its own TODO file first, enumerating its features as micro-steps, and that file is what gets built.

So a tool appears in the plan twice, and that is deliberate:

1. **A specification step** in the domain that owns it: *author `TODO-NN-<Tool>.md` covering this tool's features*. One item, and its `Done when:` is that the file exists and validates.
2. **The file's own sections**, which appear in the plan once it is authored and synced.

**This is why the plan's total grows, and the growth is correct rather than alarming.** A tool's detailed specification is written when somebody is looking at that tool, against the real Windows surface it has to work with, rather than guessed at months ahead. A lower completion percentage after adding real scope is more truthful than a false one.

The exception is a genuinely single-surface tool, such as a hash verifier or a long-path toggle, where one section is the honest size of the work. If in doubt, specify first: a tool spec that turns out to be short costs an hour, and a tool built from one line costs a rewrite.

## The TODO system

`todo/` is the live execution plan; **format spec: `todo/README.md`.** Markdown is canonical and `build/` holds derived, gitignored projections.

Eleven flat-numbered domains `00`-`10`. Numbers are stable addresses: a new domain appends after the last one.

Files are `todo/NN-domain/TODO-NN-short-name.md`. The **Implementation Order table is the dependency graph**: every `## N.` section has exactly one row and vice versa, and a row flips to `[x]` only when a `Verified:` stamp covers it. Cross-references use section marks in the forms `SN`, `TNN SN`, and `DNN TNN SN` as spelled out in `todo/README.md`, and must be bidirectional.

## Choose the work contract

For TODO work, read the target section, `todo/README.md`, its dependencies, and the applicable skill under `.claude/skills/`: capture through `add-todo`, author a file through `create-todo`, build through `process-todo-section`, stamp through `review-todo-section`, close a file through `process-todo-file`, run a phase or the plan through `process-phase` or `process-plan`, harden the tree through `groom-plan`.

The lifecycle is: capture, author, validate the plan and source claims, record `Started:`, implement, run the section's gates, commit, review and stamp, then sync the plan. Each section must be executable with zero conversation context. **One section = one commit.** Preserve section addresses and bidirectional cross-references. A TODO Implementation Order row turns `[x]` only with its `Verified:` stamp through the review skill. Do not rewrite a stamped checklist or transfer evidence across changed candidates. File new work with its own owner and dependency.

## What counts as proof

A Test checkpoint cites one or more of five proofs, spelled out in `todo/README.md`:

1. **Builds clean** at the project warning level, both architectures, warnings as errors.
2. **Static analysis clean**: `clang-tidy` reports nothing new on the touched translation units.
3. **Unit test** under Catch2 in `tests/`.
4. **Driven run with evidence**: a log line, an `.ini` readback, or a capture under `docs/captures/`.
5. **Parity proof**: the C++ tool and its `resolute_au3/` counterpart run against the same fixture and produce the same effect, compared field by field. Every ported tool owes this one.

A checkpoint citing a gate that does not exist yet is unfalsifiable and is not allowed.

## Working rules

- **Output discipline:** bound every command (build output filtered to the touched targets, `tail` or `head` on logs, field extraction on `.ini` readbacks). Keep full logs in ignored scratch.
- **Act, then report:** complete authorized work and report evidence. Explicit operator stop instructions take effect immediately.
- **One writer per session, and it never reviews itself:** all five writers (`claude`, `codex`, `gemini` for `agy`, `muse`, `meta`) are configured in `.conclave/reviewers.toml` and `scripts/review-dispatch.py` (`codex` routes to `argon` on `agy`; `claude`, `gemini`, `muse`, and `meta` route to `astra` on `codex`). Pass `--writer <claude|codex|gemini|muse|meta> --writer-model <exact-model-version>` on every `scripts/review-dispatch.py` call (with `scripts/dispatch_hook.py` enforcing `run_in_background` in Claude Code). There are no fallback reviewers; a failed pass exits 1 and is re-run or waits for the operator. **Reviewer effort never goes past `medium`**: `.conclave/reviewers.toml` schedules `plan` at `medium`, `completion` at `medium`, `rounds` 1 at `medium`, `rotation` at `low` (up to `max_low_rounds = 32`, round cap 33), and `escalation` at `low`, and `scripts/review-dispatch.py` refuses any effort above `medium` (`EFFORTS = {"codex": ("low", "medium"), "claude": ("low", "medium")}`, and `models_by_effort = { low = "gemini-4-argon-low", medium = "gemini-4-argon-medium" }` on `agy`). **Review order is fixed:** on every findings record the passes run plan first, then rounds to a clean terminal round, then completion last, and a returned completion closes the record so its gaps open a new repair cycle on a `-repair` record; `scripts/review-dispatch.py` `check_sequence` enforces this order and refuses any other.
- **Run guard, heartbeat, and watchdog (`scripts/run-guard.py`):** `scripts/run-guard.py` and `scripts/lib/run_guard.py` (wired in `.claude/settings.json`) hold `process-plan` loops open across turns, compactions, rate limits, and session exits: `UserPromptSubmit` activates the guard on `process plan` and clears it on an operator `stop`/`pause`/`cancel`/`abort`; `Stop` blocks premature exit while runnable rows remain in `todo-graph.py query ready --json` (and yields while `build/review-in-flight/` holds a live review dispatcher or after 3 consecutive unprogressed stalls); `PostToolUse` on `CronCreate` records the session's 5-minute heartbeat; and the Windows Scheduled Task watchdog (`Resolute-Claude-RunGuard`) resumes dead sessions when no live Claude process holds the workspace.
- **One lead, Sonnet delegates (operator decision 2026-10-01, D00 T04 §43; updated 2026-10-17):** the writer (`claude`) is the lead. It owns architecture, implementation, tests, documentation, integration, commits, stamps, and final acceptance, makes every change, and hands bounded read-only research and routine review to the subagents in `.claude/agents/` (`delegate-research`, `delegate-check`), which run the `sonnet` alias at `high` effort with an explicit read-only `tools:` list enforced by `python scripts/verify-agent-tiers.py`. Subagents read and run; they never write, and the main loop makes every change and verifies what subagents return. Each brief names one bounded read-only task and its acceptance criteria. The lead verifies every delegate return and decides anything touching architecture, security, privacy, data integrity, frozen behavior, elevation, or restore and undo itself. A delegate that misses its acceptance gets one re-brief, then the lead does the work or asks the operator; failed checks and unresolved findings escalate, never pass. Delegates are the writer's family: they never act as the independent reviewer, never write, commit, push, or stamp, and a `delegate-check` pass is self-review input, never a lens verdict.
- **Writes are serial:** one lead session owns the working tree and makes every write; subagents are read-only and never write files. Check `git status` before building over unfamiliar work.
- **Disposable checkouts:** a clean-checkout proof uses `git worktree`, or one clone under `R:\scratch\` named for its purpose, never a new top-level folder on a drive (no more `R:\resolute-<name>check` trees). One such tree per purpose, reused across sections, and deleted by the session that created it once its evidence is recorded. Nine abandoned clones on 2026-11-09 held about 8 GB and several carried uncommitted changes nobody could safely delete, which is the failure this rule exists to stop.
- **User systems first:** atomic writes, readback, skip-and-report, confirmed destructive paths, and a reverse for every system change or an honest statement that there is none. Checkpoints prove the failure path too.
- **One suite, one framework:** shared behavior is consumed from the framework or the repair contract, never reimplemented in a tool. A second progress bar, About dialog, settings writer, or log format is a defect.
- **Elevation is checked at the action**, not only at startup.
- **`resolute_au3/` is read-only** except under the maintenance domain. It is the specification. Changing it changes what the port is measured against.
- **Every tool lives at `extensions/<Tool>/`** and builds as its own standalone executable linking the shared library statically. `src/` is the launcher shell and nothing else.
- **The tree has no external dependencies** beyond the bootstrapped toolchain and the test framework. Adding one is a decision with a recorded reason, not a convenience.
- **Every surface answers to [`DESIGN.md`](./DESIGN.md).** A tool never draws a control the shared library provides, and never hardcodes a colour, a size, or a spacing value. Application icons are the one deliberate exception.
- **No em dashes** in authored prose. One line per paragraph and list item in Markdown.
- **Source of truth:** target behavior via the `resolute_au3/` source and a driven run of the shipped tool, the design rules via `DESIGN.md` with the captures under `docs/captures/` as its visual reference, plan state via `todo/`. Disagreements are recorded decisions, not silent reinterpretations.
- **Completion-first, no partial ships:** a runner finishes what it starts: a section, tool, or feature is complete only when every micro-step is `[x]`, its checkpoint is quoted from a real run, and review stamped it. Anything genuinely unshippable now files through `add-todo` with an owner (debt with a collector, never a silent drop), and waiting is never a strategy. Reviewers refuse stamps on partial scope.

## Subagents

- Subagents read and run; they never write. Every Claude subagent declares an explicit `tools:` list without Edit, Write, MultiEdit, NotebookEdit or `*`. The main loop makes every change and verifies what subagents return.
- Run `python scripts/verify-agent-tiers.py` after adding or changing an agent definition; it enforces these rules.

## Frozen behavior

Six tools change a user's system in ways that are hard to undo: `Ownership`, `ComIntRep`, `USBRepair`, `DVDRepair`, `PixRepair`, `BiosCodes`.

What they compute and write is **frozen**. The C++ port reproduces the effect exactly and proves it with a parity check. Restructuring is allowed, changing the effect is not, because the effect lands on somebody's registry, ACLs, or drive.

`ReBar` is not in this set. It is the framework, it changes nothing on a user's system, and it is internal tooling rather than a product. The archived AutoIt plan says otherwise and is wrong.

## A measurement recorded is a measurement re-checked

`validate` proves the tree is internally consistent. It cannot tell whether a `Current state` block is still **true**, because a stale figure and a correct one look identical as prose. Every factual drift found on 2026-09-16 was caught by a human reading the tree, which does not scale and did not catch everything.

So **a TODO that measures something records it as a claim**, and `scripts/todo-claims.py` re-measures it:

```
<!-- claim: exists resolute_au3/SDK/Concrete/ReBar/ReBar.au3 -->
<!-- claim: absent resolute_au3/SDK/Concrete/Rescue/Rescue.au3 -->
<!-- claim: lines resolute_au3/SDK/Concrete/ReBar/ReBar.au3 = 1556 -->
<!-- claim: count "Res_HiDpi=N" resolute_au3/SDK/Concrete/*/*.au3 = 14 -->
```

Claims are HTML comments, so they are invisible in rendered Markdown and inert to every other parser.

**When a claim goes stale the TODO is wrong, not the repository.** The figure changed because the code changed, which is the moment the surrounding prose needs re-reading. Fix the claim and the sentence it supports in the same commit, and if the change invalidates the section's reasoning, say so rather than quietly updating a number.

Write a claim for anything a later reader would otherwise have to trust: a line count, a file's presence or absence, a count of occurrences that an argument rests on. Do not claim what does not matter.

## Unknowns and questions

Answer from source first: the `resolute_au3/` script, a driven run of the shipped tool, Microsoft's documentation for a Win32 call, or the wxWidgets documentation. When an unanswered question would change implementation, take a justified default, record that it is a default with its cost of changing, and carry on. Do not stall a section waiting for an answer; do not silently reinterpret a section into something buildable.

## Validation

```bash
python scripts/review-dispatch.py --check-pin     # verify .conclave/reviewers.toml pin and medium effort cap
python -m unittest discover -s scripts/tests      # unit tests for review-dispatch, dispatch_hook, and run-guard
python scripts/todo-claims.py                     # re-measure what the TODOs claim about the repo
python scripts/todo-claims.py --coverage          # name every Current state block nothing re-measures
python scripts/todo-claims.py --self-test         # must stay green; the count is the suite's, not this file's
python scripts/todo-graph.py self-test            # must stay green; the count is the suite's, not this file's
python scripts/todo-graph.py validate             # structural + graph integrity checks
python scripts/todo-graph.py query ready          # dependency-safe work right now
python scripts/todo-graph.py query blocked        # sections waiting on something
python scripts/todo-graph.py query stats          # tree health
python scripts/todo-graph.py query adjacency      # feature adjacency obligations
python scripts/todo-graph.py query night-debt     # open night-owed test debt
python scripts/todo-graph.py plan --sync          # re-derive the plan projection after TODO edits
python scripts/todo-graph.py plan --check         # fail if the projection went stale
```

`python scripts/todo-graph.py resolve` takes a reference and reports its file, section, dependencies, and status.

Build and check commands arrive with `D00 T01`. Until they land, `todo-graph.py` is the only thing to run.

Run checks owed by the task. Report only commands actually run, and distinguish static evidence, driven-run output, parity output, and review proof.

Use trunk-based `master` for routine work and concise imperative commits. Respect exact candidate identity and one-section scope. Never bypass hooks with `--no-verify`, amend a recorded candidate, or force-push.

## Credentials

Credentials never enter tracked files, arguments, logs, or handoff prose. The signing certificate and its password are supplied to the build from outside the repository, and signing already happens through an existing external procedure that `06-distro-release` documents rather than replaces.
