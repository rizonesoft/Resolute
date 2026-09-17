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
> **Current state (verified 2026-09-16):** No tests exist anywhere in this repository, in either tree. The AutoIt suite has never had a test, which is the stated reason its most destructive code was never exercised: there was no safe target to run it against. The C++ codebase arriving through `D00 T03` has none either: `test_font.cpp` is a scratch file, and the 6,865-line UI library that fourteen tools will depend on is entirely uncovered. `tests/` does not exist. **Groomed 2026-09-17: `docs/captures/` now does exist**, holding a single tracked file, `ui-automation-spike.md`. The correction is worth making precisely rather than deleting the sentence: the directory is present and the capture store this section needs is still empty, so nothing here is satisfied by its existence. The parity driver, which this project's fifth proof type depends on entirely, does not exist and has no precedent to copy.

## Inputs

- [`resolute_au3/SDK/Concrete/Ownership/Ownership.au3`](../../resolute_au3/SDK/Concrete/Ownership/Ownership.au3) -- the vertical-slice tool, and the first thing the parity driver runs against
- -> XREF: [`00-workspace/TODO-01 §5`](./TODO-01-toolchain-and-gates.md) -- the combined gate that runs this harness once it exists
- -> XREF: [`01-framework/TODO-01 §1`](../01-framework/TODO-01-framework-core.md) -- the framework whose behavior these assertions cover
- -> XREF: [`04-tools-port/TODO-01 §1`](../04-tools-port/TODO-01-tool-ports.md) -- every port cites the parity driver this file builds
- -> XREF: [`00-workspace/TODO-03 §3`](./TODO-03-codebase-intake.md) -- the intake that renames the library §5 covers
- -> XREF: [`01-framework/TODO-02 §1`](../01-framework/TODO-02-design-system.md) -- the design system whose surfaces the capture store compares
- -> XREF: [`01-framework/TODO-02 §5`](../01-framework/TODO-02-design-system.md) -- the UI Automation providers that make control-level driving possible at all
- [`docs/captures/ui-automation-spike.md`](../../docs/captures/ui-automation-spike.md) -- what the driver can reach today, measured

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
|   1   |   §1    | Catch2 harness and assertion conventions   | D00 T01 §2     |  [x]   |
|   2   |   §2    | Fixture store and disposable targets       | §1             |  [ ]   |
|   3   |   §3    | House-style capture store                  | --             |  [ ]   |
|   4   |   §4    | Parity driver for a built tool             | §1, §2         |  [ ]   |
|   5   |   §5    | Cover the inherited UI library             | §1, D00 T03 §3 |  [ ]   |

---

## 1. Catch2 Harness and Assertion Conventions

> **Started:** 2026-09-17T15:06:21Z

Catch2 is a dependency, not a design. What this section decides is the shape of an assertion, because fourteen tools written against three different assertion styles is the same drift problem in a new place.

**Needs:** C++ toolchain (compile)

> [!IMPORTANT]
> **Validated 2026-09-17 before implementation. Three findings.**
>
> **The checkpoint still named the preset the first item had already corrected.** `D00 T01 §5` fixed `x64-debug` in the item while wiring the test gate and did not reach the `Test checkpoint` six lines below, so this section carried the correction and the error simultaneously. Corrected.
>
> **`test_font.cpp` is not a test and cannot become one.** It is 30 lines, tracked at the repository root, and it `printf`s DirectWrite metrics for Cascadia Mono. It contains no assertion of any kind. The item offers to keep it "as a real test if it still proves something", and it does not: a test asserting that a font has a particular height would pin a machine's installed font version rather than this suite's behaviour. It is deleted, and the reason is recorded rather than the file being quietly dropped.
>
> **Catch2 arrives the way `D00 T01 §2` settled it**, by `FetchContent` pinned to a **commit** rather than a tag, for the reason recorded there: a tag can be repointed at different code while the version string stays the same. `v3.16.0` is an annotated tag, so the tag object `fd79eadb` is not the commit; the commit it resolves to is `317ac1ed4c0bb6e6b91eafc817e05c488feffcb3`, and that is what is pinned.

- [x] Add a `tests/` target built by the same preset set, linking Catch2 through whatever mechanism `D00 T01 §2` settled. **Corrected 2026-09-17 by `D00 T01 §5`, which read this while wiring the test gate:** there is no `x64-debug` preset. `CMakePresets.json` declares `debug` and `release`, and **no `testPresets` block at all**, so `ctest --preset` cannot work until this section adds one. Done when: a `testPresets` entry exists and `ctest --preset debug` discovers and runs at least one test.

  **Done 2026-09-17.** `testPresets` added for both configurations, and `catch_discover_tests` registers each `TEST_CASE` with ctest individually so a failure names the case rather than the executable:

  ```
  6/6 Test #6: ScaleF keeps the fraction that Scale rounds away ... Passed
  100% tests passed out of 6                                        exit 0
  ```

  **`noTestsAction: error` is set deliberately.** A suite that discovers nothing would otherwise report success over zero tests, which is the quiet form of the defect `D00 T01 §5` was built to prevent.

  **The link failed first, and the reason is worth keeping.** `ResoluteUI_static` defines `UNICODE` and `_UNICODE` **publicly**, so Catch2 compiled its entry point as `wmain` rather than `main`. Without `-municode` the CRT looked for `main` or `WinMain`, found neither, and pulled mingw's GUI startup stub:

  ```
  ld.lld: error: undefined symbol: WinMain
  >>> referenced by ../crt/crtexewin.c:62
  ```

  Diagnosed by reading the archive rather than guessing: `llvm-nm` on `libCatch2Maind.a` shows it defines `wmain`, not `main`. The test target now sets `-municode` and deliberately **not** `-mwindows`, because a test runner is a console program.
- [x] Write the conventions into `tests/README.md`: naming, tagging by tool, and the rule that a test asserting a system effect reads the effect back rather than trusting a return value. Done when: the file exists and the first tests follow it.

  **The load-bearing convention is the read-back rule**, and it is not a style preference: six tools in this suite change a user's registry, ACLs or drive, and `AGENTS.md` freezes what they write. A test asserting `TakeOwnership() == true` proves a function's opinion of itself. Reading the owner back off the path proves the thing the user cares about.

  **The first tests follow it by being chosen for it.** `Dpi::Scale` and `ScaleF` are pure, so there is nothing to read back and the rule is not yet exercised; it is written for `D00 T02 §2`'s fixtures, which is where destructive code first gets a disposable target.
- [x] Prove a failure is legible. **All three appear in one log, quoted from a real failing run:**

  ```
  tests/gatefail_probe_test.cpp:9: FAILED:
    REQUIRE( rui::Dpi::Scale(value, dpi) == 99 )
  with expansion:
    4 == 99
    value := 3
    dpi := 120
  ...
  The following tests FAILED:
      1 - PROBE: this test fails on purpose (Failed)        dpi ui
  ```

  Expected and actual come from Catch2's expansion. **The tool tag took a second attempt.** Catch2's console reporter does not print tags at any verbosity, checked at `--verbosity high`. `catch_discover_tests(... ADD_TAGS_AS_LABELS)` carries each case's tags through as **ctest labels**, and ctest prints labels in its failure summary, which is the `dpi ui` above. That is strictly more useful than a printed string, because a label can also be filtered: `ctest --preset debug -L ui`.
- [x] Wire the suite into `scripts/check-all.ps1`, replacing the not-present branch that section left. **The branch now exists and has a known shape, recorded 2026-09-17 when `D00 T01 §5` shipped it:** the gate tests `Test-Path tests/`, and while that is false it reports `not present` in yellow, counts separately in the summary as `10 gate(s) ok, 1 not present`, and does not fail the run. Done when: the branch is gone and a failing test fails the combined gate.

  **Both done 2026-09-17.** The branch is deleted, and the summary line changed with it:

  ```
  before   tests  not present  0.0s  tests/ does not exist
           check-all: 10 gate(s) ok, 1 not present
  after    tests  ok           0.2s
           check-all: 11 gate(s) ok
  ```

  A failing test fails the gate, driven: `tests FAILED`, run exits non-zero, and the excerpt carries the tag, the expansion and the captures.

  > [!WARNING]
  > **The independent review found I had reintroduced a defect `D00 T01 §5`'s review already caught. Corrected 2026-09-17.**
  >
  > `ctest --preset` reads `CMakePresets.json` from the **current** directory. Run from `scripts/`, the gate failed with `Could not read presets` while the tree was perfectly healthy. `§5`'s review found exactly this for `cmake --preset`, and the fix there was applied to the launcher build **alone**, so the class stayed open and this section walked into it two sections later.
  >
  > **Fixing it per-invocation is what allowed the recurrence**, so it is fixed once for the whole script: `check-all.ps1` now runs from the repository root. That also caught a second instance nobody had reported, `plan --check`, which resolves its derived JSON under `build/` the same way.
  >
  > ```
  > before   from scripts/   tests FAILED, plan --check FAILED, 2 of 8
  > after    from scripts/   8 gate(s) ok
  >          from the root   11 gate(s) ok
  > ```
  >
  > A command whose whole promise is that it can always be run should not care where it is run from.

  > [!WARNING]
  > **Adding our own tests put 37 findings from a dependency into the tidy baseline, and the cause is a regex that meant something narrower than it said.**
  >
  > The first gate run after the suite landed reported `206 finding(s), above the baseline of 169`. The 169 were unchanged and **zero** were in `tests/`: all 37 were in `_deps/catch2-src/src/catch2/`.
  >
  > `.clang-tidy` carried `HeaderFilterRegex: '.*[/\](src|shared)[/\].*'`, intended as "this repository's `src` and `shared`". It matches **any** directory called `src` anywhere, and Catch2 keeps its headers in one. The tidy gate filtered translation units by path and not findings, which was invisible while every TU of ours included only our headers.
  >
  > Fixed where the number is computed: `scripts/check-all.ps1` now drops any finding whose path contains `/_deps/`, whichever TU surfaced it. That is the same by-construction exemption the warning policy states. `llvm::Regex` has no negative lookahead so the header filter cannot express "not under `_deps`", and the limitation is now written into `.clang-tidy` rather than left to be rediscovered.
  >
  > Back to `169 finding(s), baseline 169, over 15 TU(s)`: one more translation unit, no more findings, because the test code is clean.
  -> XREF: D00 T01 §5 -- the combined gate, and the tolerance this item removes
- [x] Remove the root scratch file `test_font.cpp`, or move it under `tests/` as a real test if it still proves something. **Filed 2026-09-17 by the review of `D00 T03 §1`:** the intake left it tracked at the repository root, where it is built by nothing and named in no layout. Its `.exe` and `.obj` were gitignored during the intake, but the source itself travelled. Done when: `git ls-files test_font.cpp` is empty, or the file lives under `tests/` and `ctest` runs it. Cheaper substitute that fails the checkpoint: gitignoring it while leaving it tracked, which changes nothing because git keeps tracking what it already tracks.

  **Deleted 2026-09-17, with the reasoning rather than quietly.** It is 30 lines that `printf` DirectWrite metrics for Cascadia Mono and contain **no assertion of any kind**. The item offered to keep it as a real test "if it still proves something", and it does not: a test asserting a font has a particular height would pin the machine's installed font version rather than this suite's behaviour, and would fail on a machine with a different Cascadia build.

  `git rm` rather than gitignore, which is the cheaper substitute this item names. The claim above is flipped from `exists` to `absent`, so the deletion is now re-measured rather than asserted.
<!-- claim: absent test_font.cpp -->
- [x] Commit: `"workspace: catch2 harness and assertion conventions"`

<!-- claim: exists tests/README.md -->
<!-- claim: exists tests/CMakeLists.txt -->
<!-- claim: count "testPresets" CMakePresets.json = 1 -->
<!-- claim: count "--preset debug --output-on-failure" scripts/check-all.ps1 = 1 -->

> **Verified:** 2026-09-17 | §1 | the suite exists, runs, and gates: `ctest --preset debug` reports **6 tests, 100 percent passed, exit 0**, and `check-all` reads **`11 gate(s) ok`** with no `1 not present`, the first time every gate in this repository has actually run · Catch2 v3.16.0 through `FetchContent` pinned to the **commit** `317ac1ed`, not the annotated tag object `fd79eadb`, per `D00 T01 §2`'s recorded policy · `testPresets` added for both configurations, which `CMakePresets.json` had never carried, with `noTestsAction: error` so a suite discovering nothing fails rather than reporting success over zero tests · **the link failed first and was diagnosed by reading the archive**: `ResoluteUI_static` defines `UNICODE` publicly so Catch2 compiled `wmain`, `llvm-nm` on `libCatch2Maind.a` shows `T wmain` and no `main`, and without `-municode` the CRT pulled mingw's GUI stub `crtexewin.o` and failed on `WinMain` · a failing test fails the gate, and the failure carries all three things the item asked for in one log: the tag `dpi ui`, the expansion `4 == 99`, and the captures · `test_font.cpp` deleted with `git rm` and its claim flipped `exists` to `absent`, because 30 lines that print font metrics and assert nothing is not a test and could not become one · the first tests were chosen to be worth having, pinning `MulDiv`'s round-to-nearest, invisible at 100 percent scaling and visible on every odd value at 125
> **Review:** round 2, candidate `35b0ef8` `c195629` -- `adversarial` approve after fix (1) · `consistency` approve after fixes (2) · `integration` approve after fix (1) · `source-defect` approve · `design` approve · `record` approve. Raw findings: docs/reviews/00-workspace/D00-T02-s1.md
> **Independent:** `codex review --commit 35b0ef8` (gpt-6-astra, high) returned **one P2 and it was right**, and it is a defect **its own review of `D00 T01 §5` already found once**. `ctest --preset` reads `CMakePresets.json` from the current directory; run from `scripts/` the gate failed while the tree was healthy. `§5`'s review found the same thing for `cmake --preset` and I fixed the **instance** rather than the class, so this section rebuilt it two sections later. The reviewer proposed wrapping the `ctest` call, which would have closed instance two and left the class open; `check-all.ps1` now runs from the repository root once for every gate, which immediately caught a third instance nobody had reported, `plan --check`. **A defect the reviewer already found once is the cheapest probe available, and I did not re-run it.**
> **CRUD:** applicable | driven: the suite was **run** rather than inspected in six states, which is how the `wmain` link failure, the tag's absence from Catch2's reporter, and the dependency findings were each seen. The failure path is exercised directly: a deliberately failing assertion fails the gate and the run exits non-zero. **The read-back convention this section decides is written and not yet exercised**, because `Dpi` is pure and has nothing to read back; it is written for `D00 T02 §2`'s fixtures, and saying so is better than implying it is proven.
> **Duration:** 19
> **Implementer:** Claude Opus 5 (claude-opus-5[1m])
> **Deferred:** the read-back rule's first real exercise waits on a disposable target for destructive code. -> XREF: D00 T02 §2 -- the fixture store that gives it one

**Test checkpoint:** `ctest --preset debug` runs and exits 0. A deliberately failing assertion exits non-zero and prints tool tag, expected, and actual; both outputs are quoted. `pwsh scripts/check-all.ps1` fails when a test fails.

**Corrected 2026-09-17:** the checkpoint said `ctest --preset x64-debug`. `D00 T01 §5` corrected the same stale name in the first item above and did not reach the checkpoint, so the section carried the correction and the error at once. There is no `x64-debug` preset and there is no `testPresets` block at all; this section adds one.

## 2. Fixture Store and Disposable Targets

> **Started:** 2026-09-17T15:33:04Z

This is the section that makes the destructive half of the suite testable. The AutoIt tools went years without a test on their most dangerous paths for one reason: there was nothing safe to point them at.

**Needs:** Windows host (build/test)

> [!IMPORTANT]
> **Validated 2026-09-17 before implementation. One correction, and it is about where a delete lands.**
>
> **`HKCU\Software\Rizonesoft` exists on this machine and holds real product settings.** It has two subkeys, `ClassicPanel` and `Office`. The section proposes creating a **deletable** fixture root as a sibling of live user data, under the same parent, and teardown's whole job is recursive deletion.
>
> The guard in the fifth item defends against a caller passing a bad path. It does not defend against the root itself being one level away from settings a user would miss, and `AGENTS.md` is explicit that a destructive path is confirmed rather than trusted. Moved to `HKCU\Software\ResoluteTestFixtures`, which is unambiguously test-only, shares no parent with product data except `HKCU\Software` itself, and needs no elevation. A key named for the test suite cannot be mistaken for a key holding somebody's preferences.
>
> **The unelevated requirement was checked rather than assumed.** Setting a DACL on a file this process owns succeeds in a session where `IsInRole(Administrator)` is **False**, verified directly. So the ownership fixtures can carry declared ACLs without elevation, which is what the third item needs and what would otherwise have been discovered halfway through.

- [x] Create the disposable registry target under `HKCU\Software\ResoluteTestFixtures`, with helpers to seed it from a declared state and tear it down. **Corrected 2026-09-17:** this named `HKCU\Software\Rizonesoft\Fixtures`, and that key's parent holds this user's real `ClassicPanel` and `Office` settings. A recursive teardown one level too high would take them. Done when: seeding and teardown are assertable, and teardown leaves the key absent.

  **Done 2026-09-17.** `RegistryFixture` in `tests/fixtures/` seeds strings, dwords and nested subkeys, and every assertion **reads the value back out of the registry** rather than trusting the setter, which is the rule `§1` wrote and could not yet exercise. Teardown is asserted from outside the object: `RegistryFixture::Exists()` is false after the scope closes.
- [x] Create the disposable file tree under the build directory, with declared owners and ACLs so the ownership tests have something real to change. **Done 2026-09-17.** `FileTreeFixture` creates a tree under `<build>/fixtures/<name>`, and the path comes from CMake as a compile definition so **no absolute path is written into a tracked build file**, which is what `D00 T01 §4` requires.

  The owner is read back as a SID string off the filesystem and the DACL entry count is read back after a grant, because those are exactly the values `D04 T01 §1`'s ownership port has to compare before and after. A helper that reported its own success would prove nothing there.
- [x] Use `HKCU` and a user-writable path so the fixtures need no elevation. **Verified 2026-09-17 in a session where `IsInRole(Administrator)` is False:**

  ```
  100% tests passed out of 16
    fixtures = 10 tests      registry = 5      files = 5
  ```

  **Which fixtures genuinely need elevation: none of these, and that is a statement about scope rather than a clean bill.** Everything here writes under `HKCU` and into a directory this process owns, and setting a DACL on a file you own needs no privilege. What *does* need elevation is taking ownership of an object owned by somebody else, which requires `SeTakeOwnershipPrivilege`, and repairing anything under `HKLM`. `D04 T01 §1` meets the first of those, and the honest position is that these fixtures give it a target for the unprivileged half and that the elevated half needs its own arrangement rather than being quietly assumed to work here.
- [x] Guarantee cleanup on failure. **Two different failures, and only one of them is solved by RAII.**

  **A test that throws** is handled by the destructor: both fixtures seed state, throw mid-test, and the key and tree are asserted absent afterwards from outside the object. Two tests do exactly that.

  **A process that dies is not**, and this was measured rather than assumed. A probe that seeded both fixtures and then called `std::abort()`:

  ```
  process exit=-1073740791          destructors do NOT run
  registry leftover: abort-residue
  tree leftover    : abort-residue, seeded.txt
  ```

  So RAII alone leaves residue on a crash, which is a real hole and the checkpoint would not have caught it: every in-test assertion passed the whole time.

  **Closed by sweeping at run start as well as end.** The suite listener removes both roots before the first test, so a previous run's crash cannot outlive the next run. Driven against the residue the abort left:

  ```
  before   registry: abort-residue    tree: abort-residue
  run      All tests passed
  after    registry: absent           tree: absent
  ```

  **What this still does not cover, stated plainly:** two test processes running concurrently would sweep each other's roots. The suite runs as one process here and `ctest` is not configured for parallelism, so it is a limitation rather than a bug today, and it is written down so it is not discovered by somebody adding `-j`.
- [x] Refuse to run against anything outside the fixture roots. **Both helpers refuse, and the refusal is asserted to be a refusal rather than just a throw.**

  ```
  registry   \Software\Rizonesoft     refused, absolute
             ..\..\Rizonesoft          refused, traversal
             HKLM:\Software            refused, qualified
  files      ..\escaped.txt            refused, resolves outside the root
             C:\Windows\escaped.txt    refused, absolute
  ```

  **The filesystem guard resolves before it judges**, using `weakly_canonical` and then comparing against the root component by component. A guard that pattern-matched on `..` would refuse `a\b\..\c`, which stays inside and is legitimate, and would miss anything that escapes without the characters it looks for. A test asserts that `a\b\..\c` is **allowed** and lands at `<root>/a/c`, which is what makes this a boundary check rather than a spelling check.

  **The messages name what was refused and where the boundary is**, asserted by a test that reads the message rather than only catching the type, because a refusal nobody can act on sends the reader to the fixture source.

  > [!WARNING]
  > **The guard was not applied to the one path that mattered most, and the independent review found it. P1, corrected 2026-09-17.**
  >
  > The **members** used the careful resolve-then-compare check. The **constructor**, which decides where the fixture's own root lives and whose destructor recursively deletes it, used a weaker hand-rolled check. That check tested `is_absolute()`, and on Windows a **root-relative** name like `\escape` is not absolute: `is_absolute()` wants a root name *and* a root directory. Worse, `base / "\escape"` keeps the base's drive and **discards its directories**, so the fixture landed at `R:\escape` and its destructor deleted it.
  >
  > So the section's central safety property held everywhere except the place where a mistake deletes a real directory. Two checks for one boundary is what let that happen, and there is now **one** function: the constructor and every member call the same `ResolveUnder`, which refuses absolute, drive-qualified and root-relative names, and refuses a path that resolves to the root itself. Five regression tests cover the exact names that escaped.
  >
  > **Two more, both the same shape as defects this file has found in its own tooling.** The startup sweep discarded its `error_code`, so a read-only leftover meant the sweep **reported success while leaving residue** and the next test ran against contaminated state. Both sweeps now check the status *and* verify the outcome, and fail the run naming the path. And `GetString` used a fixed 1,024-character buffer, so `SetString` accepted a valid string that `GetString` could not read back, which makes a seeded state unverifiable and quietly disables the one rule `tests/README.md` insists on. It now asks the registry for the size first, proven with a 4,096-character round trip.
- [x] Commit: `"workspace: disposable registry and filesystem fixtures"`

<!-- claim: exists tests/fixtures/fixtures.h -->
<!-- claim: exists tests/fixtures/suite_teardown.cpp -->
<!-- claim: count "ResoluteTestFixtures" tests/fixtures/fixtures.h = 3 -->
<!-- claim: count "Rizonesoft" tests/fixtures/fixtures.h = 1 -->

**Test checkpoint:** The fixture suite runs green unelevated. A deliberately aborted run leaves `HKCU\Software\ResoluteTestFixtures` absent and the fixture tree removed, both asserted. A helper handed an out-of-root path fails by name. All three are quoted.

## 3. House-Style Capture Store

Every UI section in this plan carries a `Fidelity:` line naming an artifact it must match. Those artifacts have to exist before anything cites them, or the fidelity rule is a rule about a file nobody has.

**Needs:** Windows host (build/test)

- [ ] Capture the shipped AutoIt surfaces that define the house style: the standard tool window, the About dialog, the preferences dialog, the update notice, and a result list. Done when: five captures are committed under `docs/captures/house-style/` and each names the tool and build it came from.
- [ ] Write `docs/captures/house-style/README.md` describing what each capture is authoritative for. Done when: each of the five has a stated scope and a named successor surface in the C++ suite.
- [ ] State what the C++ suite deliberately changes, by naming [`DESIGN.md`](../../DESIGN.md) as the authority. Done when: the capture README records that where a capture and the contract disagree, the contract wins and the capture is restaked.
- [ ] Set the convention for run captures under `docs/captures/runs/`, which driven-run checkpoints commit to. Done when: the convention is written and one example capture exists.
- [ ] Commit: `"workspace: house-style capture store"`

**Test checkpoint:** `docs/captures/house-style/` holds five captures, each naming its source tool and build, with a README giving each a scope and a successor. The approved-deviation list names DPI and dark mode. One example run capture exists under `docs/captures/runs/`.

## 4. Parity Driver for a Built Tool

The fifth proof type of this project rests entirely on this section. Without it, 1:1 with the AutoIt version is an intention rather than a gate.

**Needs:** Windows host (build/test)

- [ ] Define the parity record: a declarative file listing the system state a run touched, keyed by target, with values and types. Done when: the format is documented and one hand-written example parses.
- [ ] Drive a built executable far enough to run its main action against a fixture, and emit a parity record. Done when: the driver runs the first ported tool and writes a record.
- [ ] Record what the driver can and cannot reach **today**, and what unblocks the rest. Done when: this section cites [`docs/captures/ui-automation-spike.md`](../../docs/captures/ui-automation-spike.md), states that launch, title, screenshot, coordinate click, and close work now while control-level driving needs `D01 T02 §5`, and states which parity records can therefore be produced before that section ships. Cheaper substitute that fails the checkpoint: coordinate clicking presented as control-level driving, which encodes the layout into every test and still passes when the click lands on the wrong control.
- [ ] Run the AutoIt counterpart from `resolute_au3/` against the same fixture and emit the same record format. Done when: both implementations produce records for `Ownership` on the same fixture tree.
- [ ] Compare two records field by field and report the differences, not a boolean. Done when: two deliberately different records produce a named per-field diff, and two identical ones report parity. Cheaper substitute that fails the checkpoint: comparing exit codes, which is how two tools that did completely different things both report success.
- [ ] State plainly what parity does not cover. Done when: this section records that the rendered surface is excluded, with the reason, so no later section claims a pixel comparison as parity.
- [ ] Commit: `"workspace: parity driver comparing a C++ tool against its AutoIt counterpart"`

**Test checkpoint:** The driver produces parity records for both implementations of one tool against one fixture. Two deliberately different records produce a per-field diff naming each difference; two identical records report parity. The exclusion of the rendered surface is stated in this section. All outputs are quoted.

## 5. Cover the Inherited UI Library

The library that fourteen tools are about to depend on has **no tests at all**. It renders the launcher correctly today, which is evidence that it works, not evidence that it keeps working. This section buys the right to change it.

**Needs:** Windows host (build/test)

- [ ] Cover the theme system: token resolution in both appearances, the system accent derivation, high-contrast override, and the crossfade reaching its endpoint. Done when: four assertions run and a deliberately wrong token mapping fails one.
- [ ] Cover the DPI layer: a layout computed at 100, 125, 150, and 200 percent produces the expected metrics. Done when: four assertions run without a display attached, or this section records why a display is required.
- [ ] Cover the animation system: each named easing at its endpoints and midpoint, and the shared clock delivering ticks to subscribers. Done when: the easings are asserted against known values and a subscriber count is verified.
- [ ] Cover icon resolution: a known Lucide glyph resolves, an unknown name fails by name rather than rendering nothing. Done when: both assertions run.
- [ ] Cover the controls' non-visual logic: list selection and filtering, toolbar overflow decisions, and sidebar collapse thresholds. Done when: each is asserted against fixture state with no window created.
- [ ] Record what is not covered and why. Done when: the untested surface is listed, with rendering correctness named as the part the captures cover instead.
- [ ] Commit: `"workspace: cover the inherited ui library"`

**Test checkpoint:** `ctest --preset x64-debug --tests-regex ui` exits 0. A deliberately wrong token mapping, a wrong easing value, and an unknown icon name each fail by name, all three quoted. The uncovered surface is listed with its reason.

## Verification

- [ ] `ctest --preset x64-debug` exits 0 with the fixture, parity, and ui suites reporting
- [ ] A deliberately aborted run leaves no fixture residue in registry or filesystem
- [ ] `docs/captures/house-style/` holds the five authoritative captures with their README
- [ ] The parity driver produces comparable records from both implementations of one tool
- [ ] The inherited UI library has coverage, and what is uncovered is listed with its reason
- [ ] `python scripts/todo-graph.py validate` clean
