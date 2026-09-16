---
schema_version: 1
id: cpp-test-backbone
domain: 00-workspace
status: draft
title: "TODO-02 -- Test Backbone"
depends_on: [cpp-toolchain-and-gates]
track: W1
---

# TODO-02 -- Test Backbone

> **Goal:** A section can prove something. Catch2 runs, fixtures give destructive code a disposable target, captures record what the house style actually looks like, and the parity driver runs a C++ tool and its AutoIt counterpart against the same fixture and compares what they did.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** No tests exist anywhere in this repository, in either tree. The AutoIt suite has never had a test, which is the stated reason its most destructive code was never exercised: there was no safe target to run it against. `tests/` does not exist. `docs/captures/` does not exist. The parity driver, which this project's fifth proof type depends on entirely, does not exist and has no precedent to copy.

## Inputs

- [`resolute_au3/SDK/Concrete/Ownership/Ownership.au3`](../../resolute_au3/SDK/Concrete/Ownership/Ownership.au3) -- the vertical-slice tool, and the first thing the parity driver runs against
- -> XREF: [`00-workspace/TODO-01 §5`](./TODO-01-toolchain-and-gates.md) -- the combined gate that runs this harness once it exists
- -> XREF: [`01-framework/TODO-01 §1`](../01-framework/TODO-01-framework-core.md) -- the framework whose behavior these assertions cover
- -> XREF: [`04-tools-port/TODO-01 §1`](../04-tools-port/TODO-01-tool-ports.md) -- every port cites the parity driver this file builds

## Outcome

- Catch2 runs from the build, and a failing assertion fails the gate.
- Destructive code has a disposable registry key and a disposable file tree to act on, and neither leaves residue.
- The house style is recorded as committed artifacts rather than as somebody's memory of it.
- A parity run produces a machine-comparable record of what a tool did, for both implementations.

**Adjacency:** list=not-applicable (a test harness holds no records a user browses); document=applicable @ D00 T02 §3; settings=not-applicable (the harness reads the build configuration and owns none of its own); reporting=applicable @ D00 T02 §4; notifications=not-applicable (a local harness notifies nobody); permissions=applicable @ D00 T02 §2; audit=not-applicable (git history is the audit for a test); exchange=applicable @ D00 T02 §4; reverse=applicable @ D00 T02 §2

**Adjacency rationale:** Permissions and reverse both anchor on §2 because a fixture is exactly where privilege and undo become concrete: a disposable target that cannot be cleaned up is worse than no fixture, and a fixture that silently needs administrator rights fails differently on every machine. Reporting and exchange anchor on §4 because a parity record is a file that gets compared, diffed, and carried between runs, which makes its format a real interface rather than console output.

## Implementation Order

| Order | Section | Deliverable                                | Depends On     | Status |
| :---: | :-----: | ------------------------------------------ | -------------- | :----: |
|   1   |   §1    | Catch2 harness and assertion conventions   | D00 T01 §2     |  [ ]   |
|   2   |   §2    | Fixture store and disposable targets       | §1             |  [ ]   |
|   3   |   §3    | House-style capture store                  | --             |  [ ]   |
|   4   |   §4    | Parity driver for a built tool             | §1, §2         |  [ ]   |

---

## 1. Catch2 Harness and Assertion Conventions

Catch2 is a dependency, not a design. What this section decides is the shape of an assertion, because fourteen tools written against three different assertion styles is the same drift problem in a new place.

**Needs:** C++ toolchain (compile)

- [ ] Add a `tests/` target built by the same preset set, linking Catch2 from the vcpkg manifest. Done when: `ctest --preset x64-debug` discovers and runs at least one test.
- [ ] Write the conventions into `tests/README.md`: naming, tagging by tool, and the rule that a test asserting a system effect reads the effect back rather than trusting a return value. Done when: the file exists and the first tests follow it.
- [ ] Prove a failure is legible. Done when: a deliberately failing assertion prints the tool tag, the expected value, and the actual value, and the output is quoted here.
- [ ] Wire the suite into `scripts/check-all.ps1`, replacing the not-present branch that section left. Done when: the branch is gone and a failing test fails the combined gate.
- [ ] Commit: `"workspace: catch2 harness and assertion conventions"`

**Test checkpoint:** `ctest --preset x64-debug` runs and exits 0. A deliberately failing assertion exits non-zero and prints tool tag, expected, and actual; both outputs are quoted. `pwsh scripts/check-all.ps1` fails when a test fails.

## 2. Fixture Store and Disposable Targets

This is the section that makes the destructive half of the suite testable. The AutoIt tools went years without a test on their most dangerous paths for one reason: there was nothing safe to point them at.

**Needs:** Windows host (build/test)

- [ ] Create the disposable registry target under `HKCU\Software\Rizonesoft\Fixtures`, with helpers to seed it from a declared state and tear it down. Done when: seeding and teardown are assertable, and teardown leaves the key absent.
- [ ] Create the disposable file tree under the build directory, with declared owners and ACLs so the ownership tests have something real to change. Done when: a fixture tree is created, its ACLs read back as declared, and teardown removes it.
- [ ] Use `HKCU` and a user-writable path so the fixtures need no elevation. Done when: the full fixture suite runs green in an unelevated session, and this section states which fixtures genuinely need elevation and why.
- [ ] Guarantee cleanup on failure. Done when: a test that throws mid-run still leaves no fixture residue, proven by asserting the key and tree are absent after a deliberately aborted run.
- [ ] Refuse to run against anything outside the fixture roots. Done when: a fixture helper handed a path outside its root fails with a named message rather than acting. Cheaper substitute: trusting every caller, which is how a test suite eventually deletes somebody's documents.
- [ ] Commit: `"workspace: disposable registry and filesystem fixtures"`

**Test checkpoint:** The fixture suite runs green unelevated. A deliberately aborted run leaves `HKCU\Software\Rizonesoft\Fixtures` absent and the fixture tree removed, both asserted. A helper handed an out-of-root path fails by name. All three are quoted.

## 3. House-Style Capture Store

Every UI section in this plan carries a `Fidelity:` line naming an artifact it must match. Those artifacts have to exist before anything cites them, or the fidelity rule is a rule about a file nobody has.

**Needs:** Windows host (build/test)

- [ ] Capture the shipped AutoIt surfaces that define the house style: the standard tool window, the About dialog, the preferences dialog, the update notice, and a result list. Done when: five captures are committed under `docs/captures/house-style/` and each names the tool and build it came from.
- [ ] Write `docs/captures/house-style/README.md` describing what each capture is authoritative for. Done when: each of the five has a stated scope and a named successor surface in the C++ suite.
- [ ] State what the C++ suite deliberately changes: DPI awareness and dark mode. Done when: this section lists the approved deviations so a reviewer does not flag them as regressions.
- [ ] Set the convention for run captures under `docs/captures/runs/`, which driven-run checkpoints commit to. Done when: the convention is written and one example capture exists.
- [ ] Commit: `"workspace: house-style capture store"`

**Test checkpoint:** `docs/captures/house-style/` holds five captures, each naming its source tool and build, with a README giving each a scope and a successor. The approved-deviation list names DPI and dark mode. One example run capture exists under `docs/captures/runs/`.

## 4. Parity Driver for a Built Tool

The fifth proof type of this project rests entirely on this section. Without it, 1:1 with the AutoIt version is an intention rather than a gate.

**Needs:** Windows host (build/test)

- [ ] Define the parity record: a declarative file listing the system state a run touched, keyed by target, with values and types. Done when: the format is documented and one hand-written example parses.
- [ ] Drive a built executable far enough to run its main action against a fixture, and emit a parity record. Done when: the driver runs the first ported tool and writes a record.
- [ ] Run the AutoIt counterpart from `resolute_au3/` against the same fixture and emit the same record format. Done when: both implementations produce records for `Ownership` on the same fixture tree.
- [ ] Compare two records field by field and report the differences, not a boolean. Done when: two deliberately different records produce a named per-field diff, and two identical ones report parity. Cheaper substitute that fails the checkpoint: comparing exit codes, which is how two tools that did completely different things both report success.
- [ ] State plainly what parity does not cover. Done when: this section records that the rendered surface is excluded, with the reason, so no later section claims a pixel comparison as parity.
- [ ] Commit: `"workspace: parity driver comparing a C++ tool against its AutoIt counterpart"`

**Test checkpoint:** The driver produces parity records for both implementations of one tool against one fixture. Two deliberately different records produce a per-field diff naming each difference; two identical records report parity. The exclusion of the rendered surface is stated in this section. All outputs are quoted.

## Verification

- [ ] `ctest --preset x64-debug` exits 0 with the fixture and parity suites reporting
- [ ] A deliberately aborted run leaves no fixture residue in registry or filesystem
- [ ] `docs/captures/house-style/` holds the five authoritative captures with their README
- [ ] The parity driver produces comparable records from both implementations of one tool
- [ ] `python scripts/todo-graph.py validate` clean
