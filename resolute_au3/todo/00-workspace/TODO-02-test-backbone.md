---
schema_version: 1
id: test-backbone
domain: 00-workspace
status: draft
title: "TODO-02 -- Test Backbone"
depends_on: []
track: W1
---

# TODO-02 -- Test Backbone

> **Goal:** Every later section in this tree can prove what it claims. That means a test harness that runs AutoIt assertions and reports failures, a fixture store with disposable targets so a destructive path can be exercised without damaging the machine running it, a capture store that pins the house style, and a driver that launches a built tool and records what it did. Without this file, every checkpoint in the plan is limited to "it compiled".

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** There is no `tests/` directory in this repository, no assertion helper, no fixture, and no captured screenshot of any tool. `SDK/Includes/Logging.au3` writes to `Resolute/Logging/` (gitignored) and is the only observable trace any tool leaves today; five tools do not include it at all (`BiosCodes`, `Chromin`, `Edgemin`, `Firemin`, `Watermin`). The six tools with destructive paths (`ReBar`, `Ownership`, `ComIntRep`, `USBRepair`, `DVDRepair`, and `MemBoost`'s trim) have no test target other than the developer's own machine, which is why none of them is tested.

## Inputs

- [`SDK/Includes/Logging.au3`](../../SDK/Includes/Logging.au3) -- the existing trace mechanism; §4 reads its output as driven-run evidence
- [`SDK/Includes/About.au3`](../../SDK/Includes/About.au3) -- the shared About dialog; §3 captures it as the first house-style artifact
- -> XREF: [`00-workspace/TODO-01 §2`](./TODO-01-toolchain-and-gates.md) -- the gate script that will run this harness once it exists
- -> XREF: [`03-system-tools/TODO-01 §2`](../03-system-tools/TODO-01-system-tool-repairs.md) -- the registry fixtures §2 builds are what makes the ReBar freeze check runnable
- -> XREF: [`07-quality/TODO-01 §3`](../07-quality/TODO-01-quality-bar.md) -- the suite-wide smoke run consumes the driver §4 and §5 build

## Outcome

- `AutoIt3.exe tests/run-tests.au3` runs every test file under `tests/`, prints one line per test, and exits non-zero on any failure.
- A destructive path can be exercised against a disposable target (a scratch registry key, a scratch directory tree) with no risk to the host, and the fixture is committed.
- `docs/captures/house-style/` holds a dated capture of the standard tool window and the About dialog, with a documented refresh procedure.
- A built tool can be launched, driven, and observed from a script, producing evidence a section can quote.

**Adjacency:** list=applicable @ D00 T02 §1; document=not-applicable (a test run prints a result, it files nothing a user carries); settings=not-applicable (the harness has no tunable a user changes; its switches are arguments); reporting=applicable @ D00 T02 §5; notifications=not-applicable (a local harness notifies nobody); permissions=applicable @ D00 T02 §2; audit=not-applicable (test output is transient by design; git history records what the tests were); exchange=not-applicable (the harness reads and writes only its own fixtures); reverse=applicable @ D00 T02 §2

**Adjacency rationale:** Three entries carry real weight here. List: a harness nobody can ask "what tests exist" of becomes a harness people stop trusting, so §1 owns `--list`. Permissions and reverse both point at §2 for the same reason: the fixtures exist so a destructive path can be run and then undone, and a fixture that cannot be torn down is a fixture that damages the next run. Elevation is part of that: §2 proves what a fixture-backed test does when it is not admin, because five of the six destructive tools will meet exactly that case on a user's machine. Document and reporting are separated deliberately: the harness files nothing for a user, but its summary over the repo's own data is a report, and §5 owns it.

## Implementation Order

| Order | Section | Deliverable                                  | Depends On | Status |
| :---: | :-----: | -------------------------------------------- | ---------- | :----: |
|   1   |   §1    | AutoIt test harness and assertions           | --         |  [ ]   |
|   2   |   §2    | Fixture store and disposable targets         | §1         |  [ ]   |
|   3   |   §3    | House-style capture store                    | --         |  [ ]   |
|   4   |   §4    | Driven-run driver for a built tool           | §1, §3     |  [ ]   |
|   5   |   §5    | Suite smoke run and its report               | §4         |  [ ]   |

---

## 1. AutoIt Test Harness and Assertions

AutoIt ships no test framework, so the choice is between writing a small one and having no automated proof of anything in this repository forever. Small is the operative word: a runner, an assertion set, a filter, and a summary. Anything more becomes a project of its own and this file is not that project.

**Needs:** AutoIt3 toolchain (compile)

- [ ] Add `tests/assert.au3` with `_Assert_Equal`, `_Assert_True`, `_Assert_StringContains`, and `_Assert_FileExists`, each recording a pass or a failure with the test name, the expected value, and the actual value. Done when: a deliberate mismatch prints all three and does not halt the run. Cheaper substitute: an assertion that prints "failed" without saying what it compared.
- [ ] Add `tests/run-tests.au3` that discovers every `tests/*.test.au3`, runs it, and prints one line per test with a pass or fail marker. Done when: two sample tests, one passing and one failing, produce two lines and the run reports 1 failed.
- [ ] Exit non-zero when any test fails, and zero only when every test passed and at least one test ran. Done when: an empty `tests/` directory exits non-zero rather than reporting success over nothing.
- [ ] Support `--filter <substring>` to select tests by name, and `--list` to print the discovered test names without running them. Done when: `--list` names both sample tests and `--filter` runs only the matching one.
- [ ] Add `tests/self.test.au3` proving the harness itself: an assertion that passes, one that is expected to fail and is marked as such, and a check that the failure count is what the harness reported. Done when: the self-test passes and deliberately breaking `_Assert_Equal` makes it fail.
- [ ] Run the harness through `Au3Check` at the same level as the rest of the repo, and add `tests/` to the sweep in `scripts/au3check-all.ps1`. Done when: the sweep visits `tests/` and reports zero new warnings.
- [ ] Commit: `"workspace: add the AutoIt test harness and its own self-test"`

**Test checkpoint:** `AutoIt3.exe tests/run-tests.au3` runs `tests/self.test.au3` and exits 0; breaking `_Assert_Equal` so it always passes makes the self-test report a failure and the run exit non-zero. `--list` prints the discovered names. All three outputs are quoted in the commit body.

## 2. Fixture Store and Disposable Targets

Six tools in this suite write the registry, take ownership of files, re-register COM components, or repair drives. None of them is tested, and the honest reason is that the only target available is the developer's own machine. This section builds the disposable targets, which is what turns "we cannot test that" into "that test needs a fixture".

- [ ] Create `tests/fixtures/` with a documented layout: one subdirectory per tool that owns fixtures, and a `README.md` saying that a fixture is committed, disposable, and never points at a live system location. Done when: the directory exists with the README and one worked example.
- [ ] Add `tests/fixtures/registry-sandbox.au3` creating and tearing down `HKCU\Software\Rizonesoft\Fixtures\<test-name>`, with known values of each type `ReBar` handles. Done when: setup creates the key, teardown removes it, and a second run finds no residue. Source: the registry paths `SDK/Concrete/ReBar/ReBar.au3` reads and writes. Cheaper substitute: a fixture under `HKLM` or one that writes to a real product key.
- [ ] Add `tests/fixtures/filetree-sandbox.au3` building a throwaway directory tree with mixed ownership and ACLs for `Ownership` to act on, under the user's temp directory. Done when: setup builds it, teardown removes it, and teardown succeeds even when a file was left locked.
- [ ] Guarantee teardown runs even when a test fails mid-way, and prove it. Done when: a test that aborts after setup still leaves no fixture behind on the next run.
- [ ] Exercise the unelevated case: record what each sandbox does when the process is not admin, and make that an explicit skip with a reason rather than a failure. Done when: running the fixtures unelevated reports skips naming the privilege each needs, and the run still exits 0.
- [ ] Add a guard that refuses to run any fixture whose target path resolves outside the sandbox roots, and test the guard with a deliberately wrong path. Done when: the guard aborts the run and names the offending path.
- [ ] Commit: `"workspace: add disposable registry and filesystem fixtures with guaranteed teardown"`

**Test checkpoint:** `AutoIt3.exe tests/run-tests.au3 --filter fixtures` exits 0; after the run, `HKCU\Software\Rizonesoft\Fixtures` does not exist and the temp tree is gone. A fixture pointed at `HKLM\SOFTWARE` is refused by the guard with the path named. An unelevated run reports skips with reasons and exits 0. All four outputs are quoted in the commit body.

## 3. House-Style Capture Store

Fourteen tools are supposed to look like one suite. Nothing in this repository records what that means, so "matches the house style" is currently a matter of memory, and memory is how the fifteenth tool ends up with its own progress bar. A capture is the artifact a later section is checked against.

**Fidelity:** Resolute standard tool window and the shared About dialog, as rendered by `Resolute.exe` and `SDK/Includes/About.au3` on Windows 11 -- this section creates `docs/captures/house-style/`, which is the baseline every other Fidelity block will name. First capture, no prior baseline.
**Job:** a reviewer can compare a tool's rendered surface against the suite's agreed look without opening another tool to remember it. Consumer: every later section's Fidelity block, and `review-todo-section`'s design lens.
**Treatment:** full-window captures at 100% scale on a known Windows 11 theme, each with a sidecar naming the tool, version, OS build, and DPI. Cheaper substitute that fails the checkpoint: a cropped screenshot with no sidecar, which cannot be compared against anything later.
**Chrome:** capture what `SDK/Includes/` already renders (`About.au3`, `GDIPlusProgressBar.au3`, `GuiMenuEx.au3`, `FFLabels.au3`). Do not restyle anything while capturing. This section records the house style; it does not decide it.
**Needs:** Windows host (build/test)

- [ ] Create `docs/captures/house-style/` with a `README.md` stating the capture conditions: display scale, Windows theme, OS build, and that a capture is replaced rather than appended to. Done when: the README exists and names all four conditions.
- [ ] Capture the `Resolute.exe` main window and commit it as `resolute-main-window.png` with a `resolute-main-window.json` sidecar carrying tool, version, OS build, and DPI. Done when: both files exist and the sidecar's version matches `Resolute.sni`.
- [ ] Capture the shared About dialog from one tool and commit it with its sidecar. Done when: the capture shows the dialog `SDK/Includes/About.au3` renders, and the sidecar names which tool rendered it.
- [ ] Capture one progress-bar state from a tool that uses `GDIPlusProgressBar.au3`. Done when: the capture shows the bar mid-progress rather than at 0 or 100, because the mid state is the one a substitute gets wrong.
- [ ] Add `scripts/refresh-captures.ps1` documenting and performing the refresh: it names what to open, waits for the operator, and writes the sidecar automatically. Done when: running it produces a sidecar with the current version and OS build without the operator typing them.
- [ ] Write the deviation rule into the README: a tool may deviate from a capture only against a listed, dated approval, and the list lives in the same README. Done when: the list exists, even if empty, with the rule above it.
- [ ] Commit: `"workspace: capture the house style and document how it is refreshed"`

**Test checkpoint:** `docs/captures/house-style/` holds three captures, each with a sidecar whose version matches the built tool. `pwsh scripts/refresh-captures.ps1` regenerates a sidecar whose OS build matches `[System.Environment]::OSVersion`. Deleting a sidecar and re-running reproduces it. The outputs are quoted in the commit body.

## 4. Driven-Run Driver for a Built Tool

"Driven run with evidence" is one of the four proofs this tree allows, and it currently requires a person with a mouse. This section makes it a script, so a section that claims a surface works can cite what was clicked and what happened.

**Needs:** Windows host (build/test)

- [ ] Add `tests/drive.au3` with helpers to launch a built executable, wait for its main window by title, activate a named control, and shut it down cleanly. Done when: it launches `Resolute.exe`, finds the window, and closes it without leaving a process behind. Cheaper substitute: a fixed `Sleep` instead of waiting on the window, which passes on a fast machine and fails on a slow one.
- [ ] Capture evidence from a driven run: a screenshot written under `docs/captures/runs/<date>/`, plus any log lines the run produced under `Resolute/Logging/`. Done when: a run produces both and the helper returns their paths. Source: `_Logging_Write` in `SDK/Includes/Logging.au3`.
- [ ] Add an `.ini` readback helper so a section can prove a setting was written and survives a restart. Done when: a driven run sets a value, the tool is closed and relaunched, and the helper reads the same value back.
- [ ] Fail loudly when the window never appears, naming the executable, the expected title, and how long it waited. Done when: driving a nonexistent executable produces that message and a non-zero exit rather than a hang.
- [ ] Guarantee the driven process is terminated even when the test fails, and prove no orphan remains. Done when: a test that aborts mid-drive leaves no matching process in `ProcessList`.
- [ ] Commit: `"workspace: drive a built tool from a test and capture what it did"`

**Test checkpoint:** `AutoIt3.exe tests/run-tests.au3 --filter drive` launches the built `Resolute.exe`, captures a screenshot under `docs/captures/runs/`, closes it, and exits 0 with no orphaned process. Driving a nonexistent executable exits non-zero with the named-executable message. Both outputs are quoted in the commit body.

## 5. Suite Smoke Run and Its Report

Fourteen tools, and no way to answer "do they all still start". A smoke run is the cheapest suite-wide signal there is, and it is the one that catches a broken shared include before a user does.

**Needs:** Windows host (build/test)

- [ ] Add `tests/smoke.test.au3` that, for each built tool, launches it, waits for its main window, screenshots it, and closes it. Done when: the test visits all 14 tools and reports one line each. Cheaper substitute: checking the process started, which passes for a tool that opens an error dialog and nothing else.
- [ ] Record per-tool results in `docs/reports/smoke-<date>.md`: tool, version, started, window found, closed cleanly, and the capture path. Done when: the report exists after a run and names every tool, including the ones that failed.
- [ ] Treat a tool that cannot be built as a named skip rather than a failure, so an unbuildable tool does not hide a broken one. Done when: removing one executable produces a skip line naming it, and the run still reports the other 13.
- [ ] Make the exit code reflect real failures only: skips do not fail the run, a tool that starts and shows no window does. Done when: both cases are exercised and the exit codes differ.
- [ ] Commit: `"workspace: smoke every tool in the suite and report what happened"`

**Test checkpoint:** `AutoIt3.exe tests/run-tests.au3 --filter smoke` after `pwsh scripts/build.ps1 -All` visits all 14 tools, writes `docs/reports/smoke-<date>.md` naming each, and exits 0. Deleting one executable produces a skip line for it and still exits 0; making one tool fail to show a window makes the run exit non-zero. All three outcomes are quoted in the commit body.

## Verification

- [ ] `AutoIt3.exe tests/run-tests.au3` runs every test and exits 0
- [ ] `pwsh scripts/au3check-all.ps1` covers `tests/` with zero new warnings
- [ ] Every fixture tears down completely: no residue under `HKCU\Software\Rizonesoft\Fixtures` or the temp tree after a full run
- [ ] `docs/captures/house-style/` holds a current capture with a matching sidecar for each artifact it names
- [ ] `python scripts/todo-graph.py validate` clean
