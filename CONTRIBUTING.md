# Contributing to Resolute

Thank you for wanting to help. This page says how a change gets in and what it has to prove; [`AGENTS.md`](AGENTS.md) is the full contract, and it wins where the two differ.

## Before you start

- Read [`AGENTS.md`](AGENTS.md) for the architecture rule (a tool never reimplements the framework or the repair contract), and [`DESIGN.md`](DESIGN.md) for how every surface must look and behave.
- Find the work in the plan: [`todo/implementation-plan.md`](todo/implementation-plan.md) lists every section, and [`todo/README.md`](todo/README.md) explains how one is written. A change that no section owns starts as a new section, so its scope and its proof are agreed before the code.
- The contributor licence position is not decided yet (`D06 T01 §8` decides it before the first outside contribution is taken), so open an issue to discuss a change before you spend time on it.

## How does a change get in?

- **Trunk only.** Work lands on `main`. Keep your branch rebased on it; history on `main` is never rewritten.
- **No force-push** to `main`, and no `--no-verify`: a hook that fails is telling you something.
- **One section, one commit**, with a message in the imperative that names the section, for example `docs: README rewrite plus repo-face files (D00 T05 §2)`.
- **Run the gates** before you ask for review: `pwsh scripts/check-all.ps1`. The `gates` workflow runs the same command on every push and a red run blocks the merge.

## What proof does a change owe?

At least one of these, quoted from a real run in the pull request:

1. **Builds clean** at the project warning level, warnings as errors.
2. **Static analysis clean**: `clang-tidy` reports nothing new on the files you touched.
3. **A unit test** under Catch2 in `tests/`, shown failing without your change.
4. **A driven run with evidence**: a log line, a settings read-back, or a capture under `docs/captures/` with its provenance file.
5. **Parity**: for a ported tool, the C++ tool and its AutoIt original run against the same fixture and change the system the same way. The six tools that change a system in ways hard to undo (`Ownership`, `ComIntRep`, `USBRepair`, `DVDRepair`, `PixRepair`, `BiosCodes`) are frozen: their effect may not change, only their structure.

## How should prose read?

No em dashes, and one line per paragraph and per list item, in every Markdown file. `scripts/readme-check.py` checks the README, this file, the security policy and the GitHub templates on every push.
