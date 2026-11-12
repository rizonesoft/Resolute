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
| `scripts/start-unattended-run.ps1` | The unattended run's launcher, behind the two Desktop shortcuts. See "The unattended run" |
| `scripts/campaign-icon.py` | Renders a launcher shortcut's icon for this machine: the suite icon with its runner's badge |
| `tools/claude-plugins/` | The Claude Code plugins this repository ships for its own sessions: `resolute-lsp`, the language servers |
| `docs/` | Captures, reviews, phase runs, reports, the brainstorm record |
| `build/` | Ignored derived output, never an authoritative record |

Everything here is Windows-only, the TODO tooling (`scripts/`, plan checks) included: it is stdlib Python 3, run on the Windows development host and on CI's `windows-2025` runner, and nothing tests it elsewhere (D00 T01 §9).

## The decisions this project runs on

Recorded in `docs/brainstorm/2026-09-16-completion-brainstorm.md`. Read it before proposing anything that contradicts one.

- **C++23 on llvm-mingw** (clang targeting MinGW-w64 on UCRT), built with CMake and Ninja through `scripts/build.ps1`, with `sccache` as the compile cache. No vcpkg and no package manager: the toolchain is pinned in `toolchain.json` and bootstrapped into `reskit/`. This is the brainstorm's decision 18 as `D00 T01 §1` built it; decision 13 (MSVC 2022 and vcpkg) is superseded.
- **`resolute-ui`, statically linked.** The suite's own Direct2D UI library under `shared/resolute-ui/` (ExoUI at intake), one self-contained executable per tool. It replaced wxWidgets by the brainstorm's decision 24, which records why; the deciding constraints were standalone distribution and size.
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
- **Run guard and heartbeat (`scripts/run-guard.py`):** `scripts/run-guard.py` and `scripts/lib/run_guard.py` (wired in `.claude/settings.json`) hold a `process-plan` loop open for as long as its session lives in its open window, across turns, compactions and usage limits: `UserPromptSubmit` activates the guard on `process plan` and ends it on a plain operator `stop`, `pause`, or `halt` (the launcher activates it with `run-guard.py start` instead); `Stop` blocks premature exit while runnable rows remain in `todo-graph.py query ready --json`, lets the turn end while `build/review-in-flight/` holds a live review dispatcher, and yields after 5 sends back that changed nothing (3 such yields end the run as stalled); and `PostToolUse` on `CronCreate` records the session's heartbeat (cron `7,22,37,52 * * * *`), which wakes an idle session from inside it. **A run starts only when the operator starts it (operator decision 2026-11-12).** Nothing starts or resumes a session that is dead: there is no scheduled task, no watchdog and no restart loop, and none may be added. A run whose session is gone (a crash, a closed window, a reboot) is recorded as `ended`, and `run-guard.py status` says so.
- **One lead, Sonnet delegates (operator decision 2026-10-01, D00 T04 §43; updated 2026-10-17 and 2026-11-10):** the writer (`claude`) is the lead. It owns architecture, implementation, tests, documentation, integration, commits, stamps, and final acceptance, makes every change, and hands bounded read-only work to the subagents in `.claude/agents/`: research to `delegate-research` and routine review to `delegate-check` (the `sonnet` alias at `high` effort), and fetching (locating, extracting, running named read-only commands) to `delegate-facts` (the `sonnet` alias at `medium` effort). Each has an explicit read-only `tools:` list enforced by `python scripts/verify-agent-tiers.py`. Subagents read and run; they never write, and the main loop makes every change and verifies what subagents return. Each brief names one bounded read-only task and its acceptance criteria. The lead verifies every delegate return and decides anything touching architecture, security, privacy, data integrity, frozen behavior, elevation, or restore and undo itself. A delegate that misses its acceptance gets one re-brief, then the lead does the work or asks the operator; failed checks and unresolved findings escalate, never pass. Delegates are the writer's family: they never act as the independent reviewer, never write, commit, push, or stamp, and a `delegate-check` pass is self-review input, never a lens verdict.
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
- **Scripts for true mechanical work, Spark for dummy work in Muse sessions:** anything a script can produce exactly (counts, file existence, line counts, claim re-measurement, plan stats, validation) is run as a script by the lead and never given to a model: `scripts/todo-graph.py`, `scripts/todo-claims.py`, `scripts/verify-agent-tiers.py`, and the other gates in Validation below. Dummy work around those scripts goes to the `spark` workflow at `.agents/workflows/spark.js` (run through the workflow tool with that scriptPath), which serves two tiers at medium effort under one compact evidence contract: the narrow classes (a single named read-only command, or extraction from a single named file) go to `muse-ember-1.0` by setting `route: "ember"` with `kind: "command"` or `kind: "extract"`, and everything wider (batched briefs, multi-file locating) goes to `muse-spark-1.3`. Batch related questions into one brief instead of one spawn per question (a batched brief is Spark work by definition, never Ember). These agents never write and never judge; the lead verifies what they return and keeps every decision. The known-answer replays that qualify these routes are recorded at `docs/replays/2026-11-09-spark-replay.md` and `docs/replays/2026-11-09-ember-replay.md`, and `scripts/verify-agent-tiers.py` checks the workflow still pins both models and efforts. The Spark workflow is the Muse sessions' route and stays in the tree for them. **In a Claude Code session, which is how this project is now developed (operator decision 2026-11-10), the same dummy work goes to the `delegate-facts` subagent** (`.claude/agents/delegate-facts.md`, Sonnet at medium effort) under the same evidence contract: one fact per item, each with a `path:line` or the exact command that produced it, counts produced by a command and never by the model, and anything needing judgment returned unanswered as `judgment for the lead`. Scripts still take the truly mechanical work, and the routing gate and the lead's verification below apply to `delegate-facts` exactly as they do to Spark. Its known-answer replay is recorded at `docs/replays/2026-11-10-delegate-facts-replay.md`. Haiku routing stays dropped.
- **Orchestrator autonomy: the lead improves the routing when evidence says to.** The lead watches every subagent return, and misbehaviour is acted on in the same session, not merely reported: a wrong, dropped, or judgment-leaking result is never acted on; that brief's class is re-routed upward at once (Ember work to Spark, Spark work to the lead itself); and when a failure repeats, or a single failure touches quality or safety, the lead autonomously tightens the mechanics that allowed it (brief contract, judgment screen, evidence schema, narrow-class scope, verifier check, replay record), re-runs the qualifying replay for the changed mechanic, and reports what it changed and why. `spark.js` already does the in-run rung of this itself: an incomplete Ember attempt is retried once on Spark and reported with `escalatedFrom` set. Autonomy stops at the same boundaries as all other work: it never lowers a quality gate, never routes judgment to a cheaper tier, never touches frozen behaviour or the review pin, and a change that would do any of those is an operator decision, not an autonomous one.
- **Spark routing gate, both sides enforced:** before a spawn, a brief must pass three questions: the answer is a quotable fact, it can carry a cited source (a `file:line` or the exact command that produced it), and it needs no choosing, weighing, assessing, recommending, or deciding what is relevant. If any answer is no, the brief is judgment and stays with the lead; rewording it to slip past is a routing failure, and `spark.js` screens judgment-bearing briefs out before any agent spawns as the second line of defence. After a run, the lead acts on a returned fact only after opening its cited line or re-running its quoted command, and never acts on evidence from a task reported incomplete or partial: `spark.js` drops uncited evidence before it can reach the lead, and the verification step is what makes the cited source count as evidence at all.

## The unattended run

Claude Code is the writer for this project (operator decision 2026-11-10). The Muse, Codex and Antigravity tooling (`.agents/`, `.codex/`, the Spark workflow, the `muse`, `meta`, `codex` and `gemini` writer routes) stays in the tree and stays valid; it is not the default.

- **Start it** from a Desktop shortcut, each of which runs `scripts/start-unattended-run.ps1`: "Resolute Claude campaign" (`-Runner claude`, the default: an interactive Claude Code session with permission prompts off, questions off because `AskUserQuestion` is disallowed, the writer model pinned to the latest Opus (`claude-opus-5-5`) at `medium` effort, and a `/goal` of the plan at 100 percent) or "Resolute Carbon campaign" (`-Runner agy`: the same goal in Google Antigravity on Gemini 4 Carbon, `gemini-4-carbon-medium`, the `gemini` writer route). `-PrintOnly` shows the checks and the goal and starts nothing, `-InstallShortcut` writes both shortcuts for where the clone is, each with the suite icon and its runner's badge (`scripts/campaign-icon.py`, rendered into `%LOCALAPPDATA%\Resolute`), and `-Stop` ends the active run from another window: it halts the guard and ends the session's process, because a session with a goal set keeps working by itself.
- **One session, started by the operator, and nothing after it.** The launcher starts one session and no other. Typing `stop` in the session, leaving it with `/exit`, or closing the window ends the run; so does a crash or a reboot. The session runs through `run-guard.py session`, inside a job object that ends with the window, so closing it stops the session's whole process tree: nothing a run started keeps running. A session the operator typed `process plan` into is put in a job object of its own when it takes the run, so what it starts from then on ends with its window too. `status` shows `window_bound` for whether that holds. One exception stands until `D07 T01 §10` is built: an elevated smoke run already started through `\Resolute\ElevatedSmoke` belongs to Task Scheduler and finishes by itself. A typed `stop` ends the guard's hold and tells the session to stop working and end its background work; `-Stop` reports the session ended only once its process is gone. When the session ends the launcher records how (`run-guard.py ended`) and says so. The Stop hook and the heartbeat are Claude Code hooks: an Antigravity session is kept working by its goal alone, and the guard only reserves the tree for it.
- **It heals rather than refuses.** The launcher bootstraps a missing toolchain and names the session to the run guard before it starts. `scripts/build.ps1` rebuilds a build tree made at another path. Low memory, a dirty tree and an earlier run's state are printed, not refused.
- **One admission.** `run-guard.py start` is the only way a launcher's session gets to write, taken under the guard's lock: it refuses while another session, another launcher or a review holds the tree. Another session open in the clone is accepted only by the operator at the keyboard.
- **Elevated tests run through one consented task.** A tool whose manifest is `requireAdministrator` (RegStudio) cannot be started by a session nobody watches, so its elevated smoke runs through `\Resolute\ElevatedSmoke` (`tools/elevated-smoke.ps1`, `D07 T01 §7`): one UAC consent at registration, then `-Run` with no prompt. The task runs only the driver bytes that were consented to, pinned by hash, and it holds the clone's path, so the launcher asks the script at every start whether a run would be refused (`tools/elevated-smoke.ps1 -Check`: the task's definition for this clone and the pinned hashes) and offers to register it while the operator is at the keyboard. A section that changes the pinned driver cannot prove its elevated checkpoint unattended: it records that and is left for the operator, and the run carries on.
- **Sign-in is the one-year token** (`claude setup-token`) kept in 1Password, vault `Conclave`, item `Claude Code OAuth token (1 year, setup-token)`. The launcher reads it into the Claude Code session's environment as `CLAUDE_CODE_OAUTH_TOKEN`. It leaves, and falls back to, one copy encrypted by Windows for the operator's account (DPAPI, `%LOCALAPPDATA%\Resolute\claude-token.dpapi`, operator decision 2026-11-10), for a start at which 1Password cannot be read; 1Password is asked first and stays the source of truth. With neither, it says so and uses the stored login, which expires within weeks. Antigravity signs in with its own account and is never handed the token.
- **A review is waited for, never worked beside.** `scripts/review-dispatch.py` runs through the shell tool's `run_in_background` option (`scripts/dispatch_hook.py` refuses a foreground run) and holds a marker under `build/review-in-flight/` while its reviewer runs; the session ends its turn and the result wakes it.
- **Language servers.** `.claude/settings.json` enables `resolute-lsp` from `tools/claude-plugins/`: the pinned clangd (reading `build/debug/compile_commands.json`, with clang-tidy on) and pyright, both started through `scripts/lsp-launch.py`. Use them: find definitions and callers by symbol, and read the diagnostics after an edit before running a gate.
- **Trunk only.** All work lands on `main`, the trunk, directly (renamed from `master` on 2026-11-10; records written before then name `master`): no feature branches and no pull requests for routine work.

## The standard

The aim is the best Windows system utility suite in its class, and the best-run repository behind it: nothing is treated as impossible because it is hard or because no competitor has done it. Every session, attended or not, works to that:

- **Decide, do not ask.** Where the answer can be worked out from the source, the specification or the documentation, work it out. Otherwise take the justified default, record it with its cost of reversing, and carry on. Stop only for data loss, credentials, shared infrastructure, or a calculation that looks wrong.
- **Self-improve.** When a tool, a skill, an agent, a gate or a method could be better, make it better in the same run, with the evidence that it is, and say what changed. The limits are the ones under "Orchestrator autonomy": never lower a quality gate, never route judgment to a cheaper tier, never touch frozen behavior or the review pin.
- **Self-heal.** A failure of the run itself (a stale path, a dead session, a broken build tree, a red gate) is repaired at its cause, in the layer that owns it, with a regression test where it is code. It is never worked around and never left for the next run to trip over.
- **Measure against the best.** Before building a surface or a feature, look at how the strongest competitor does it, then make Resolute faster, with fewer steps, smarter defaults, better recovery from errors and better accessibility, and prove it with a measurement.

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

Answer from source first: the `resolute_au3/` script, a driven run of the shipped tool, Microsoft's documentation for a Win32 or Direct2D call, or the `shared/resolute-ui/` headers. When an unanswered question would change implementation, take a justified default, record that it is a default with its cost of changing, and carry on. Do not stall a section waiting for an answer; do not silently reinterpret a section into something buildable.

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

Build and gates, landed by `D00 T01`:

```powershell
pwsh scripts/bootstrap.ps1                        # download the pinned toolchain into reskit/
pwsh scripts/build.ps1 Resolute -Config Debug     # one target; -All builds the launcher and every extension
bosun run -- pwsh scripts/check-all.ps1           # every gate; -SkipBuild for a documentation-only change
```

`scripts/build.ps1` removes and rebuilds a build tree that a clone made at another path, because CMake refuses one whose cache names a different source directory. Full builds and full test suites go through `bosun run --` so repositories on this machine take turns for memory.

Run checks owed by the task. Report only commands actually run, and distinguish static evidence, driven-run output, parity output, and review proof.

Use trunk-based `main` for routine work and concise imperative commits. Respect exact candidate identity and one-section scope. Never bypass hooks with `--no-verify`, amend a recorded candidate, or force-push.

## Credentials

Credentials never enter tracked files, arguments, logs, or handoff prose. The signing certificate and its password are supplied to the build from outside the repository, and signing already happens through an existing external procedure that `06-distro-release` documents rather than replaces.
