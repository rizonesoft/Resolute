---
schema_version: 1
id: toolchain-and-gates
domain: 00-workspace
status: draft
title: "TODO-01 -- Toolchain and Gates"
depends_on: []
track: W1
---

# TODO-01 -- Toolchain and Gates

> **Goal:** A fresh clone of this repository can locate the AutoIt3 toolchain, check every tracked script, and build any tool to both architectures with one command, on a machine that has never seen this project. Nothing downstream is trustworthy until that is true, because today every gate in this repo is a thing somebody remembers to do by hand.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** There is no build script, no check script, and no CI in this repository. AutoIt3 is installed at `C:\Program Files (x86)\AutoIt3` with `Au3Check.exe` and `Aut2Exe\Aut2exe.exe`, but nothing in the repo names that path. All 13 `.sni` build descriptors under `SDK/Concrete/*/` hardcode `ScriptPath=R:\Workspace\Resolute\...`, a root that does not exist on this machine (the repo is at `R:\conclave\projects\Resolute`), so `SDK/Distro.exe` cannot build any tool from a clean checkout without hand-editing 13 files. `Au3Check.exe -q -d -w 1..7` over the 14 concrete scripts reports **0 errors and 847 unique warnings** (610 `already declared/assigned`, 178 `declared, but not used in func`, 54 `'Local' specifier in global scope`, 4 deprecated `Dim`, 1 `declared global in function only`). `SDK/Concrete/Distro/` holds `Distro.au3` but no `.sni` of its own.

## Inputs

- [`SDK/Concrete/Resolute/Resolute.sni`](../../SDK/Concrete/Resolute/Resolute.sni) -- the build descriptor shape every tool repeats; §1 reads it, §3 drives it, §4 repairs its hardcoded root
- [`SDK/Distro.exe`](../../SDK/Distro.exe) -- the SDK builder that consumes a `.sni`; §3 wraps it
- [`Resolute_setup.iss`](../../Resolute_setup.iss) -- the Inno Setup script; not built here, owned by `D06 T01 §4`
- -> XREF: [`00-workspace/TODO-02 §1`](./TODO-02-test-backbone.md) -- the harness that §2's gate script will also run once it exists
- -> XREF: [`06-distro-release/TODO-01 §1`](../06-distro-release/TODO-01-build-and-release.md) -- the release build consumes the one-command build §3 writes
- -> XREF: [`07-quality/TODO-01 §2`](../07-quality/TODO-01-quality-bar.md) -- the warning ratchet §2 seeds is driven to zero there

## Outcome

- `pwsh scripts/autoit-env.ps1` prints the resolved `Au3Check.exe`, `Aut2Exe.exe`, and AutoIt3 version, and exits non-zero with a named remedy when the toolchain is absent.
- `pwsh scripts/au3check-all.ps1` checks every tracked `.au3` and fails on any error, or on any warning not in the committed baseline.
- `pwsh scripts/build.ps1 <Tool>` produces the x86 and x64 executables for any tool from a clean checkout, with no file hand-edited first.
- Every `.sni` resolves its paths from the repository root rather than one developer's drive layout.
- `pwsh scripts/check-all.ps1` runs the whole gate set, so a contributor has one command to answer "is this repo green".

**Adjacency:** list=not-applicable (gate scripts hold no records a user browses); document=not-applicable (a gate prints to a console, it files nothing); settings=applicable @ D00 T01 §1; reporting=applicable @ D00 T01 §2; notifications=not-applicable (a local gate notifies nobody; CI notification is out of scope until a runner exists); permissions=not-applicable (the gates run unelevated by design, and §3 proves it); audit=not-applicable (git history is the audit trail for a script); exchange=not-applicable (nothing here reads or writes a third-party file format); reverse=applicable @ D00 T01 §3

**Adjacency rationale:** The two applicable-with-owner entries are the ones a reader would otherwise assume are missing. Settings: the toolchain location is the one tunable value in this file, and §1 owns it as `scripts/toolchain.json` with `autoit-env.ps1` as the named consumer, so nobody hardcodes an install path a second time. Reporting: the Au3Check baseline in §2 is a report over the repo's own data, and the ratchet only works if the report is committed and diffable. Reverse: a build writes executables into the working tree, so §3 owns `-Clean` as the reverse of a build; without it the only way back is `git clean`, which also destroys untracked work. Permissions is declared not-applicable rather than skipped because every tool in this suite carries `#RequireAdmin`, which makes "do the gates need elevation" a real question: they do not, and §3 proves it by building without it.

## Implementation Order

| Order | Section | Deliverable                                     | Depends On | Status |
| :---: | :-----: | ----------------------------------------------- | ---------- | :----: |
|   1   |   §1    | AutoIt3 toolchain pin and locator               | --         |  [ ]   |
|   2   |   §2    | Au3Check gate and warning baseline              | §1         |  [ ]   |
|   3   |   §3    | One-command build for any tool                  | §1         |  [ ]   |
|   4   |   §4    | Repository-relative `.sni` paths                | §3         |  [ ]   |
|   5   |   §5    | One command that runs every gate                | §2, §4     |  [ ]   |

---

## 1. AutoIt3 Toolchain Pin

Every later gate shells out to `Au3Check.exe` or `Aut2Exe.exe`, and today nothing in the repository knows where either lives. The failure this section prevents is the one where each script grows its own copy of an install path, and the repo stops building the day somebody installs AutoIt3 somewhere else. One locator, one pinned version, one remedy message.

**Needs:** AutoIt3 toolchain (compile)

- [ ] Add `scripts/toolchain.json` recording the expected AutoIt3 version and the search order for its install directory (the `AutoIt3` registry key under `HKLM\SOFTWARE\WOW6432Node\AutoIt v3\AutoIt`, then `%ProgramFiles(x86)%\AutoIt3`, then an `AUTOIT3_HOME` override). Done when: the file exists, is valid JSON, and names no path that is specific to one machine. Source: `Au3Check.exe` and `Aut2Exe\` observed at `C:\Program Files (x86)\AutoIt3` on the build host, 2026-09-16.
- [ ] Add `scripts/autoit-env.ps1` that reads `toolchain.json`, resolves `Au3Check.exe` and `Aut2Exe.exe` in that search order, and writes both paths plus the reported AutoIt3 version to stdout. Done when: it prints three lines and exits 0 on this host. Cheaper substitute: a script that returns the first path it guesses without confirming the executable exists.
- [ ] Make the failure path explicit: when either executable is missing, exit 1 with one line naming what was looked for, where, and the remedy ("install AutoIt3, or set AUTOIT3_HOME"). Done when: pointing `AUTOIT3_HOME` at an empty directory produces exit 1 and that line, not a PowerShell stack trace.
- [ ] Have `autoit-env.ps1` emit its results as a dot-sourceable object (`$Au3Check`, `$Aut2Exe`, `$AutoItVersion`) so §2 and §3 consume it rather than re-resolving. Done when: `. ./scripts/autoit-env.ps1` leaves those three variables set in the caller's scope.
- [ ] Record the version actually found against the version pinned in `toolchain.json`, and warn (do not fail) on a mismatch. Done when: a pinned version of `0.0.0.0` produces a warning line naming both versions and still exits 0.
- [ ] Commit: `"workspace: pin the AutoIt3 toolchain and resolve it from one place"`

**Test checkpoint:** `pwsh scripts/autoit-env.ps1` exits 0 and prints the `Au3Check.exe` path, the `Aut2Exe.exe` path, and the AutoIt3 version on this host. With `AUTOIT3_HOME` pointed at an empty temporary directory it exits 1 and prints the remedy line. Both runs are quoted in the commit body.

## 2. Au3Check Gate and Warning Baseline

`Au3Check` is the cheapest gate this repository has and it is not wired to anything. The measured state is 0 errors and 847 unique warnings, which is too many to fix in this section and exactly the reason a ratchet exists: the baseline is committed, new warnings fail the gate, and `D07 T01 §2` drives the number down. A gate that fails on day one gets disabled on day two, so this one starts at the number the repo is actually at.

- [ ] Add `scripts/au3check-all.ps1` that dot-sources `autoit-env.ps1` and runs `Au3Check.exe -q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7` over every tracked `.au3` under `SDK/Concrete/` and `SDK/Includes/`. Done when: it visits all 14 concrete scripts and reports a per-file count. Cheaper substitute: checking only the file the author happens to be editing.
- [ ] Any `error:` fails the run immediately, with the file, line, and message echoed. Done when: introducing a deliberate syntax error in a scratch copy makes the script exit 1 and name that file.
- [ ] Normalize each warning to a stable key (`<file-relative-path>|<message-with-variable-name>`), dropping the absolute path prefix and the source-echo lines, so the baseline is diffable and machine-independent. Done when: running the script from two different checkout locations produces byte-identical keys.
- [ ] Write the current set to `scripts/au3check-baseline.txt`, sorted, one key per line, and commit it. Done when: the file holds the measured unique warning keys and `git diff` is empty on a second run.
- [ ] Fail the gate on any warning whose key is not in the baseline, and print the new ones only. Done when: adding an unused `Local` to a scratch copy of a tracked script makes the script exit 1 and print exactly that one warning.
- [ ] Support `-UpdateBaseline` to rewrite the file deliberately, and say in the script header that shrinking the baseline is the point and growing it is a decision. Done when: the switch rewrites the file and the header says so.
- [ ] Commit: `"workspace: gate every tracked script on Au3Check with a committed baseline"`

**Test checkpoint:** `pwsh scripts/au3check-all.ps1` exits 0 against the committed baseline and reports 0 errors. A scratch copy of `SDK/Concrete/BiosCodes/BiosCodes.au3` with one added unused `Local` makes it exit 1 and print that single new warning key and nothing else. Both outputs are quoted in the commit body.

## 3. One-Command Build for Any Tool

Building a tool today means opening the SDK builder and pointing it at a `.sni` whose paths are wrong. This section makes the build a command, which is what lets every later section cite "compiles both architectures" as proof rather than as an intention.

**Needs:** AutoIt3 toolchain (compile)

- [ ] Add `scripts/build.ps1` taking a tool name (`Resolute`, `Firemin`, and so on), resolving `SDK/Concrete/<Tool>/<Tool>.sni`, and invoking `SDK/Distro.exe` against it. Done when: `pwsh scripts/build.ps1 Resolute` produces `Resolute.exe` and `Resolute_X64.exe` at the repository root. Cheaper substitute: a script that compiles only the x86 target and reports success.
- [ ] Fall back to `Aut2Exe.exe` directly when `Distro.exe` is unavailable, driving both architectures from the `.au3` and its `#AutoIt3Wrapper_` directives. Done when: the fallback path is exercised with `-NoDistro` and produces both executables. Source: `#AutoIt3Wrapper_Res_*` directives at the head of every concrete script.
- [ ] Validate the tool name against the directories under `SDK/Concrete/` and exit 1 listing the valid names on a miss. Done when: `pwsh scripts/build.ps1 Nonsense` exits 1 and prints the 14 available names.
- [ ] Add `-All` to build every tool in sequence, reporting one line per tool and a final pass/fail tally. Done when: the tally counts 14 attempts and names any that failed.
- [ ] Add `-Clean` as the reverse of a build: remove the executables and `Distribution/` output this script produced, and nothing else. Done when: `-Clean` after a build leaves `git status` exactly as it was before the build, and a dry-run switch lists what it would remove first.
- [ ] Prove the build needs no elevation: run it from a non-elevated shell and record that it succeeds. Done when: the checkpoint output is captured from an unelevated session. Note that `#RequireAdmin` in the scripts affects the built executable at runtime, not the compile.
- [ ] Commit: `"workspace: build any tool to both architectures with one command"`

**Test checkpoint:** From an unelevated shell on a clean checkout, `pwsh scripts/build.ps1 Resolute` exits 0 and both `Resolute.exe` and `Resolute_X64.exe` appear with a current timestamp; `pwsh scripts/build.ps1 Nonsense` exits 1 and lists the valid tool names; `-Clean` restores `git status` to its pre-build state. All three are quoted in the commit body.

## 4. Repository-Relative `.sni` Paths

All 13 `.sni` files carry absolute paths under `R:\Workspace\Resolute`, which is not where this repository lives. Anyone cloning it gets a build system pointing at a directory that does not exist, and the current workaround is that one machine happens to match. This section removes the developer's drive layout from the build descriptors.

- [ ] Inventory every absolute path key across `SDK/Concrete/*/*.sni` (`ScriptPath`, `Icon`, `OutFilePath`, `OutFileX64Path`, `DistributionPath`, `FullDistributionPath`, `DistroSourceFullPath`) and record the list in the commit body. Done when: the inventory names all 13 files and every key that carries an absolute path. Source: `grep -h "R:\\\\Workspace" SDK/Concrete/*/*.sni`, 2026-09-16.
- [ ] Decide and record the substitution: a `%RootDir%`-style token already used by the `[Distribute]` section of these files, resolved by the build wrapper. Done when: the decision and its cost of changing are written into this section as a dated note, and the token chosen is one `Distro.exe` already understands or the wrapper expands before invoking it.
- [ ] Rewrite the 13 `.sni` files to the repository-relative form, one commit, no other change. Done when: no `.sni` under `SDK/Concrete/` contains `R:\Workspace`, and `git diff` shows only path lines.
- [ ] Teach `scripts/build.ps1` to expand the token against the repository root before handing the descriptor to the builder. Done when: a build from a checkout at a different absolute path succeeds without editing a `.sni`.
- [ ] Prove it from a second location: copy the checkout to a temporary directory and build one tool there. Done when: the build succeeds at the copied path and the output executables land inside the copy, not in the original. Cheaper substitute: rebuilding in place and concluding the paths are fine.
- [ ] Commit: `"workspace: resolve .sni build paths from the repository root"`

**Test checkpoint:** `grep -rn "R:\\\\Workspace" SDK/Concrete/` returns nothing. A copy of the checkout at a different absolute path builds `Firemin` successfully with `scripts/build.ps1`, and the resulting executable is inside the copy. Both are quoted in the commit body.

## 5. One Command That Runs Every Gate

A contributor should not have to know which four scripts to run in which order. This section is the front door: one command, every gate, one verdict. It is also what a future CI job will call, so the gate set lives in the repository rather than in a workflow file.

- [ ] Add `scripts/check-all.ps1` running, in order: `autoit-env.ps1`, `au3check-all.ps1`, `python scripts/todo-graph.py self-test`, `python scripts/todo-graph.py validate`, and `python scripts/todo-graph.py plan --check`. Done when: each step prints a labeled pass or fail line and the script exits non-zero if any failed. Cheaper substitute: stopping at the first failure so the author only ever sees one problem per run.
- [ ] Run every gate even after one fails, and summarize at the end. Done when: with two gates deliberately broken, both appear in the summary.
- [ ] Add `-Quick` to skip the Au3Check sweep for a fast plan-only check, and say in the header that `-Quick` is not the gate a push owes. Done when: `-Quick` completes without invoking `Au3Check.exe`.
- [ ] Document the command in `AGENTS.md` under Validation as the one a contributor runs before pushing. Done when: the file names `scripts/check-all.ps1` and the docs and the script agree on what it runs.
- [ ] Commit: `"workspace: one command runs every gate this repo owes"`

**Test checkpoint:** `pwsh scripts/check-all.ps1` exits 0 on a green tree and prints one labeled line per gate. With a deliberate new Au3Check warning present, it exits 1, the Au3Check line reads fail, and the TODO-graph lines still ran and read pass. Both outputs are quoted in the commit body.

## Verification

- [ ] `pwsh scripts/check-all.ps1` exits 0 with every gate reporting pass
- [ ] `pwsh scripts/build.ps1 -All` builds all 14 tools to both architectures from a clean checkout
- [ ] No `.sni` under `SDK/Concrete/` contains an absolute path outside the repository
- [ ] `python scripts/todo-graph.py validate` clean
