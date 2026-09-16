# AGENTS.md

Agent instructions for this repository. Claude Code loads this file through the `CLAUDE.md` import stub.

## What is here

`Resolute` is Rizonesoft's suite of Windows system utilities: a launcher plus thirteen tools, written in AutoIt3, sharing one SDK. Roughly 43,000 lines across `SDK/`.

| Path | Purpose |
| ---- | ------- |
| `SDK/Concrete/<Tool>/` | Each tool's `.au3` source, its `.sni` build descriptor, and its own includes |
| `SDK/Includes/` | The shared library every tool consumes: logging, localization, settings, update, chrome |
| `SDK/Distro.exe` | The SDK builder that turns a `.sni` into signed, distributable executables |
| `Resolute/` | The runtime layout: built tools, per-tool `Docs/`, `Language/`, `Sounds/`, `Logging/` |
| `todo/` | Canonical execution contracts; read `todo/README.md` before authoring or implementing |
| `todo/implementation-plan.md` | Ordered execution plan synchronized through `scripts/todo-graph.py` |
| `scripts/` | Neutral tooling: the TODO graph, validator, adjacency inspector |
| `docs/` | Captures, reviews, phase runs, reports, user guide |
| `build/` | Ignored derived output, never an authoritative record |

Everything here is Windows-only: the tools, the toolchain, and the tests. The TODO tooling (`scripts/`, plan checks) is stdlib Python 3 and runs anywhere.

## The tools

`Resolute` (launcher) · `BiosCodes` · `ComIntRep` · `DVDRepair` · `Ownership` · `PixRepair` · `ReBar` · `USBRepair` (system tools) · `Firemin` · `Chromin` · `Edgemin` · `Watermin` (browser optimizers) · `MemBoost` (system memory) · `Distro` (the builder itself).

Seven of them change a user's system in ways that are hard to undo. Those behaviors are **frozen**: see the frozen set in `todo/README.md`.

## The TODO system

`todo/` is the live execution plan; **format spec: `todo/README.md`.** Markdown is canonical and `build/` holds derived, gitignored projections.

Nine flat-numbered domains `00`-`08`: `00-workspace` (toolchain, gates, test backbone), `01-sdk-core` (shared includes and their contracts), `02-launcher` (the Resolute hub), `03-system-tools` (the seven system tools, frozen), `04-browser-tools` (the four optimizers), `05-memboost` (frozen trim path), `06-distro-release` (build, sign, package, ship), `07-quality` (the bar, the ratchet, conformance), `08-docs-localization` (docs, language packs, user guide). Numbers are stable addresses: a new domain appends after `08`.

Files are `todo/NN-domain/TODO-NN-short-name.md`. The **Implementation Order table is the dependency graph**: every `## N.` section has exactly one row and vice versa, and a row flips to `[x]` only when a `Verified:` stamp covers it. Cross-references use `§N` / `TNN §N` / `DNN TNN §N` and must be bidirectional.

## Choose the work contract

For TODO work, read the target section, `todo/README.md`, its dependencies, and the applicable skill under `.claude/skills/`: capture through `add-todo`, author a file through `create-todo`, build through `process-todo-section`, stamp through `review-todo-section`, close a file through `process-todo-file`, run a phase or the plan through `process-phase` or `process-plan`, harden the tree through `groom-plan`.

The lifecycle is: capture, author, validate the plan and source claims, record `Started:`, implement, run the section's gates, commit, review and stamp, then sync the plan. Each section must be executable with zero conversation context. **One section = one commit.** Preserve section addresses and bidirectional cross-references. A TODO Implementation Order row turns `[x]` only with its `Verified:` stamp through the review skill. Do not rewrite a stamped checklist or transfer evidence across changed candidates. File new work with its own owner and dependency.

## What counts as proof

There is no `dotnet test` here. A Test checkpoint cites one or more of four proofs, spelled out in `todo/README.md`:

1. **Au3Check clean** on every script the section touched. Every code section owes this one.
2. **Compiles both architectures** through the tool's `.sni`.
3. **Driven run with evidence**: a log line, an `.ini` readback, or a capture under `docs/captures/`.
4. **Harness test** in `tests/`, once `D00 T02 §1` ships it. Until then, a checkpoint citing a harness test is unfalsifiable and is not allowed.

## Working rules

- **Output discipline:** bound every command (`Au3Check` on the touched scripts, `tail`/`head` on logs, field extraction on `.ini` readbacks). Keep full logs in ignored scratch.
- **Act, then report:** complete authorized work and report evidence. Explicit operator stop instructions take effect immediately.
- **Writes are serial:** one session owns the working tree. Check `git status` before building over unfamiliar work.
- **User systems first:** atomic writes, readback, skip-and-report, confirmed destructive paths, and a reverse for every system change or an honest statement that there is none. Checkpoints prove the failure path too.
- **One suite, one SDK:** shared behavior is consumed from `SDK/Includes/`, never reimplemented in a tool. A second progress bar, About dialog, settings writer, or log format is a defect.
- **Elevation is checked at the action**, not only by `#RequireAdmin` at startup.
- **No em dashes** in authored prose. One line per paragraph and list item in Markdown.
- **Source of truth:** tool behavior via the `.au3` source and a driven run, the house style via the captures under `docs/captures/`, plan state via `todo/`. Disagreements are recorded decisions, not silent reinterpretations.

## Unknowns and questions

Answer from source first (the script, a driven run, Microsoft's documentation for a Win32 call). When an unanswered question would change implementation, take a justified default, record that it is a default with its cost of changing, and carry on. Do not stall a section waiting for an answer; do not silently reinterpret a section into something buildable.

## Validation

```bash
python scripts/todo-graph.py self-test      # 393 cases, must stay green
python scripts/todo-graph.py validate       # FATAL blocks; new WARN* blocks until fixed or accepted
python scripts/todo-graph.py query ready    # dependency-safe work right now
python scripts/todo-graph.py query blocked  # sections waiting on something
python scripts/todo-graph.py query stats    # tree health
python scripts/todo-graph.py plan --sync    # re-derive the plan projection after TODO edits
python scripts/todo-graph.py plan --check   # fail if the projection went stale
python scripts/todo-graph.py resolve 'D00 T01 §1'   # ref -> file, section, deps, status
```

Build and check commands arrive with `D00 T01`: `scripts/autoit-env.ps1`, `scripts/au3check-all.ps1`, `scripts/build.ps1`, and `scripts/check-all.ps1` as the one command a push owes. The test harness arrives with `D00 T02 §1`. Until they land, `todo-graph.py` is the only thing to run, and `Au3Check.exe` can be invoked directly.

Run checks owed by the task. Report only commands actually run, and distinguish static evidence, driven-run output, and review proof.

Use trunk-based `master` for routine work and concise imperative commits. Respect exact candidate identity and one-section scope. Never bypass hooks with `--no-verify`, amend a recorded candidate, or force-push.

## Credentials

Credentials never enter tracked files, arguments, logs, or handoff prose. The signing certificate and its password are supplied to the build from outside the repository; `SDK/Signing/` holds configuration, never a secret.
