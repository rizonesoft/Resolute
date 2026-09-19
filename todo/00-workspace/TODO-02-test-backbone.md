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
|   2   |   §2    | Fixture store and disposable targets       | §1             |  [x]   |
|   3   |   §3    | House-style contract, checked against source | --            |  [x]   |
|   4   |   §4    | Parity driver for a built tool             | §1, §2         |  [x]   |
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
> **Resolved:** 2026-09-17 in `2536f52`. The read-back rule's first real exercise waited on a disposable target for destructive code. `§2` built it, and every fixture assertion now reads the effect back out of the registry or the filesystem rather than trusting a helper's return. -> XREF: D00 T02 §2 -- the fixture store that gives it one

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

> **Verified:** 2026-09-17 | §2 | the destructive half of the suite has somewhere safe to point: **19 tests, all passing, in a session where `IsInRole(Administrator)` is False** · every assertion **reads the effect back** from the registry or the filesystem rather than trusting a helper, which is the rule `§1` wrote and could not exercise because its first tests were pure · the owner is read back as a SID and the DACL entry count after a grant, the exact values `D04 T01 §1` compares · **the registry root was moved off the product key**: the section named `HKCU\\Software\\Rizonesoft\\Fixtures` and that parent holds this user's real `ClassicPanel` and `Office`, one arithmetic mistake from a recursive teardown · **cleanup on failure is two failures and RAII solves one**: a throw unwinds, but `std::abort` runs no destructors and a probe left residue in both stores while every in-test assertion passed, so both roots are now swept at run **start** as well as end, driven against the residue an abort actually left · the boundary guard refuses absolute, traversing, drive-qualified and root-relative names and **allows** `a\\b\\..\\c`, which is what makes it a boundary check rather than a spelling check · the fixture store lives under `<build>/fixtures` with the path supplied by CMake, so no absolute path enters a tracked build file · `HKCU\\Software\\Rizonesoft` still holds exactly `ClassicPanel, Office` after every run
> **Review:** round 2, candidate `2536f52` `339bfd9` -- `adversarial` approve after fixes (3) · `consistency` approve after fix (1) · `integration` approve · `source-defect` approve after fix (1) · `design` approve · `record` approve. Raw findings: docs/reviews/00-workspace/D00-T02-s2.md
> **Independent:** `codex review --commit 2536f52` (gpt-6-astra, high) returned **one P1 and two P2, all three right**. The P1 is this section's central safety property failing in the one place a mistake costs a real directory: the **members** used the careful resolve-then-compare guard and the **constructor**, whose destructor calls `remove_all` on the root it chooses, used a weaker hand-rolled one. It tested `is_absolute()`, and on Windows a root-relative `\escape` is not absolute, while `base / "\escape"` keeps the base's drive and discards its directories. The fixture landed outside the store and deleted it. **Two checks for one boundary is what allowed it**, and there is now one. Eighth section running where the reviewer found something by constructing a state I had not, and the first where that state was an input to my own safety check.
> **CRUD:** applicable | this section IS the data path: it creates, seeds, reads back and deletes registry keys and file trees. Every failure path is driven rather than reasoned about, including the two the checkpoint could not see: a process death leaving residue, and a sweep that reported success while leaving it. The reverse is the whole point and is asserted from outside the objects, by asking the registry and the filesystem after the scope closes.
> **Duration:** 18
> **Implementer:** Claude Opus 5 (claude-opus-5[1m])
> **Deferred:** two concurrent test processes would sweep each other's roots. One process today and `ctest` is not configured for parallelism, so it is a limitation rather than a bug, recorded where somebody adding `-j` will meet it. Elevated fixtures are also out of scope: taking ownership of an object owned by somebody else needs `SeTakeOwnershipPrivilege` and its own arrangement. -> XREF: D04 T01 §1 -- the ownership port that needs the elevated half

**Test checkpoint:** The fixture suite runs green unelevated. A deliberately aborted run leaves `HKCU\Software\ResoluteTestFixtures` absent and the fixture tree removed, both asserted. A helper handed an out-of-root path fails by name. All three are quoted.

## 3. House-Style Contract, Checked Against Source

> **Started:** 2026-09-17T16:28:45Z

> [!IMPORTANT]
> **Rewritten 2026-09-17 on operator instruction, after the operator asked why a visual capture was needed at all. The answer was that it is not, and the question is the finding.**
>
> This section was "House-Style Capture Store": screenshot five shipped AutoIt surfaces and commit the PNGs. **The geometry is already in source, exactly and diffably, on both sides:**
>
> ```
> AutoIt   GUICtrlCreateLabel($g_sProgName, $g_iSizeIcon + 22, 15, 300, 35)
> C++      BASE_WIDTH = 200   BASE_ITEM_HEIGHT = 40   BASE_FONT_SIZE = 14
> ```
>
> **What a PNG costs.** It is a binary blob, so review sees that something changed and never what. It is machine-dependent: the one capture taken before this rewrite needed a sidecar recording `96 dpi` and `Windows 10.0.26200` precisely because the image does not travel. Reaching anything behind a menu needs input automation, which on this machine sent keystrokes into an unrelated application. And it goes stale silently, because nobody re-stakes a screenshot after a padding change.
>
> **What it buys that source does not** is proof that the code *rendered*, as opposed to being specified: correct coordinates with the wrong brush, clipped text, or bad z-order all read fine in source. That is real, and `docs/captures/ui-automation-spike.md` already assigned it to `D01 T02 §5`, observing that a screenshot "proves something rendered rather than that it rendered the truth". It is not this section's job.
>
> **And for the AutoIt captures specifically the premise was already dead.** `AGENTS.md` says the UI is "rebuilt rather than reproduced, because the AutoIt windows are not DPI-aware and have no dark mode". A screenshot of a surface the suite has decided not to copy is not a baseline for anything.
>
> **The path does not change.** 29 `Fidelity:` citations across 15 files point at `docs/captures/house-style/`, and they need something to point at. What changes is what lives there: a derived contract a test enforces, rather than images a human compares by eye. `docs/captures/` stays correctly named because `runs/` below still holds real captures.

Every UI section in this plan carries a `Fidelity:` line naming an artifact it must match. Those artifacts have to exist before anything cites them, or the fidelity rule is a rule about a file nobody has.

**Needs:** C++ toolchain (compile)

- [x] Derive the house-style contract from source into `docs/captures/house-style/contract.md`: the geometry, typography, spacing and colour tokens every shared control uses, each value naming the symbol it came from. Done when: every number in the file cites the header and constant it was read out of, so a reader can check it without trusting this file. Cheaper substitute that fails the checkpoint: writing the numbers by hand, which produces a second source of truth that drifts from the first.

  **Done 2026-09-17. 25 tokens across four controls**, each row naming the class, constant and header it came from:

  ```
  Sidebar     6 tokens   Toolbar    3 tokens
  StatusBar   5 tokens   ListView  11 tokens
  ```

  **What the contract deliberately does not cover, stated in the file:** colour, because `Theme::Colors()` changes with theme and system accent so a single number would be wrong in at least one state; and the type ramp, because where a control passes a raw size rather than a `TypeStyle` entry that is a defect for `D01 T02` rather than a value to enshrine.
- [x] Make drift fail the gate rather than fail to be noticed. Done when: a Catch2 test asserts the contract's values against the constants themselves, changing a constant without changing the contract fails `check-all.ps1`, and both the failing and passing outputs are quoted. Cheaper substitute: comparing two images by eye, which is what this section stopped doing and why.

  **Driven both ways 2026-09-17.** `Sidebar::BASE_WIDTH` changed from 200 to 220 without touching the contract:

  ```
  house_style_test.cpp:121: FAILED:
    CHECK( found->second == actual )
  with expansion:
    200 == 220
  with messages:
    symbol := "Sidebar::BASE_WIDTH"

  The following tests FAILED:
    1 - Every contract value matches the constant it names (Failed)  housestyle ui
  check-all: tests FAILED
  ```

  Reverting returns the suite to 22 passing. **The test carries no numbers of its own**: its table maps a contract row to its constant, the expected value is read from `contract.md` at run time, so there is no third copy to drift. Three tests, and the other two matter: one asserts the contract parses to something, because a contract parsing to nothing would let every other assertion pass vacuously, and one checks the reverse direction so a row naming a renamed constant cannot sit in the file unchecked.
- [x] Write `docs/captures/house-style/README.md` describing what the directory is authoritative for and what it is not. Done when: it states that the contract binds layout and tokens, that rendering fidelity is `D01 T02 §5`'s, and that a `Fidelity:` citation means the contract plus [`DESIGN.md`](../../DESIGN.md). **Done**, and it also records why the directory is not a screenshot store, so the next person to ask the question this section was rewritten by finds the answer rather than re-deriving it.
- [x] State what the C++ suite deliberately changes, by naming [`DESIGN.md`](../../DESIGN.md) as the authority. Done when: the README records that where the contract and `DESIGN.md` disagree the contract file is wrong and is restaked, and that **DPI awareness and dark mode are the approved deviations** from the AutoIt suite, which had neither.

  **Both are recorded with what makes them real rather than aspirational.** DPI awareness is pinned by `tests/dpi_test.cpp` and every contract value is a base at 96 scaled through `Dpi::Scale` at draw time; the example run capture below is taken at **144 dpi** and the launcher renders correctly, which is the deviation visible rather than asserted. Dark mode is `Theme::Colors()` returning a palette per theme, which is also why colour is deliberately absent from the contract.

  **`DESIGN.md` was updated in the same change**, because its "How it binds" paragraph said a `Fidelity:` block names "this file and the captures". It now names the contract, and records why a contract replaced screenshots so the reasoning sits with the rule rather than only in this section.
- [x] Set the convention for run captures under `docs/captures/runs/`, which driven-run checkpoints commit to. Done when: the convention is written, it says what a run capture must carry to be evidence rather than a screenshot, and one example capture exists.

  **Four things, and a capture missing any of them is a picture of a moment nobody can place:** what it proves, what produced it, the machine it came from, and its date. `scripts/capture-window.ps1` writes a sidecar carrying all four.

  **The convention says prefer text**, because a log line or an `.ini` readback is diffable, travels between machines, and can be asserted in a test, and an image is none of those. An image is for something genuinely visual with no textual form.

  **The example is the C++ launcher, not an AutoIt tool**, which is the point of the rewrite: it is the one real surface of the thing being built.

  ```
  2026-09-17-D00-T02-s3-launcher-window.png   1100x720, monitor 144 dpi, aware=True
  ```

  > [!WARNING]
  > **The independent review found four defects in the capture helper, two of them P1, and the first is one I had already written about. Corrected 2026-09-17.**
  >
  > **P1, and it is the worse for being known.** The helper still called `SetForegroundWindow` and ignored the result, then sent keystrokes. Windows refuses that call from a background process, so the input went wherever focus happened to be. I described that exact failure in the commit message and left the code path enabled: documenting a hazard is not removing it. Synthetic input is now **gone from the script**, not gated. A surface behind a menu is opened by the operator and this attaches to the result.
  >
  > **And it now fails closed.** If the target does not own the foreground at the moment of capture it refuses rather than copying whatever is on top of it, because a capture of an overlapping window filed as the target's evidence is worse than no capture. Driven: with a window of mine deliberately in front, the run exits **3** and writes nothing.
  >
  > **P1, second.** When the launched stub exited, the fallback matched a process by name and the cleanup then force-killed it, so an instance **the operator already had open** could be captured and then terminated. Matching processes are now recorded **before** launching and only one that appeared afterwards is ever eligible or stopped. Driven with a pre-existing launcher running: it survives, `pid still alive? True`.
  >
  > **P2.** Called with neither `-Path` nor `-WindowTitle` it enumerated every window and took the first, which could foreground and save an unrelated application. Refused now, exit **2**, before anything is enumerated.
  >
  > **P2, and it made a committed sidecar untrue.** `GetDpiForWindow` returns a DPI-**unaware** window's *logical* dpi, which is 96 even on a 150 percent display, so the AutoIt capture's sidecar read `96 (100% scaling)` while the image was bitmap-stretched by Windows at 144. The sidecar now carries both figures, and the pair is better evidence than either alone:
  >
  > ```
  > AutoIt tool     monitor 144 dpi   window  96 dpi   aware=False
  > C++ launcher    monitor 144 dpi   window 144 dpi   aware=True
  > ```
  >
  > That is the DPI deviation this section names, visible in the metadata rather than asserted in prose.
- [x] Commit: `"workspace: house-style contract, checked against source"`

<!-- claim: exists docs/captures/house-style/contract.md -->
<!-- claim: exists docs/captures/house-style/README.md -->
<!-- claim: exists docs/captures/runs/README.md -->
<!-- claim: exists tests/house_style_test.cpp -->
<!-- claim: count "BASE_WIDTH" docs/captures/house-style/contract.md = 1 -->

> **Verified:** 2026-09-17 | §3 | **the section was rewritten before it was built**, on operator instruction, after the operator asked what a screenshot proved that the source did not · `docs/captures/house-style/contract.md` carries **25 tokens across four controls**, each row naming the class, constant and header it came from · `tests/house_style_test.cpp` parses the contract and asserts every value against the constant it names, so **drift fails the gate**: `Sidebar::BASE_WIDTH` 200 to 220 with the contract untouched produces `200 == 220` naming the symbol and `check-all: tests FAILED`, and reverting returns 22 passing · **the test carries no numbers of its own**, its table maps a row to a constant and the expected value is read from the file at run time, so there is no third copy to drift · two supporting tests matter: one asserts the contract parses to something, because a contract parsing to nothing would let every other assertion pass vacuously, and one checks the reverse so a row naming a renamed constant cannot sit unchecked · colour, the type ramp and rendering fidelity are excluded **in the file, with reasons** · the path did not move, so 29 `Fidelity:` citations across 15 files still resolve, and `DESIGN.md` was updated in the same change so the rule and its reasoning sit together · the `runs/` convention says what makes a capture evidence rather than a screenshot and says prefer text · the two sidecars show the DPI deviation as metadata rather than prose: AutoIt `monitor 144, window 96, aware=False` against the C++ launcher `monitor 144, window 144, aware=True`
> **Review:** round 2, candidate `0ea2877` `f8cc708` `f577fc9` -- `adversarial` approve after fixes (3) · `consistency` approve after fix (1) · `integration` approve · `source-defect` approve after fix (1) · `design` approve · `record` approve after fixes (2). Raw findings: docs/reviews/00-workspace/D00-T02-s3.md
> **Independent:** `codex review --commit 0ea2877` (gpt-6-astra, high) returned **two P1 and two P2, all four right**, and two of them were hazards **I had already written down**. The capture helper still called `SetForegroundWindow`, ignored the refusal Windows returns to a background process, and sent keystrokes to whatever owned the foreground; I described that exact failure in the previous commit message and left the code path enabled. Its cleanup matched a process by name and force-killed it, which could terminate an instance the operator already had open. Synthetic input is removed rather than gated, the capture fails closed when the target is not in front, and only a process that appeared after the launch is ever eligible or stopped. **A hazard I have written a paragraph about is not a hazard I have fixed**, and the paragraph makes it feel handled.
> **CRUD:** applicable | driven: every refusal path was **run**, not reasoned about. No target given exits 2 before anything is enumerated. A target not in the foreground exits 3 and writes no file, driven with a window deliberately placed in front. A pre-existing launcher survives a capture run, checked by pid. And the contract's own failure path is driven in both directions, which is the section's actual deliverable.
> **Duration:** 40
> **Implementer:** Claude Opus 5 (claude-opus-5[1m])
> **Deferred:** rendering fidelity, whether a surface drew what it specified rather than merely specifying it, is not provable from a contract file and is not attempted here. -> XREF: D01 T02 §5 -- the automation tree that can answer it

**Test checkpoint:** `docs/captures/house-style/contract.md` exists and every value in it names the symbol it was derived from. A Catch2 test asserts the contract against the constants; changing a constant without the contract fails `pwsh scripts/check-all.ps1`, and reverting passes, both quoted. The README states the directory's scope, names `DESIGN.md` as the authority, and names DPI and dark mode as the approved deviations. One example run capture exists under `docs/captures/runs/` with the convention written.


## 4. Parity Driver for a Built Tool

> **Started:** 2026-09-17T18:13:50Z

The fifth proof type of this project rests entirely on this section. Without it, 1:1 with the AutoIt version is an intention rather than a gate.

**Needs:** Windows host (build/test)

> [!IMPORTANT]
> **Validated 2026-09-17 before implementation. Three blockers and one factual correction that reaches past this section. Operator agreed the basis below on 2026-09-17.**
>
> **`Ownership` does not do what the plan says it does.** It never calls `takeown` or `icacls`. Its entire system effect is writing four registry trees, `HKCR\*\shell\runas`, `HKCR\dllfile\shell\runas`, `HKCR\Directory\shell\runas` and `HKCR\Drive\shell\runas`, whose `\command` value is `cmd.exe /c takeown /f "%1" /r /d y && icacls "%1" /grant administrators:F /t`. **It is a context-menu installer.** The `takeown` runs later, when a user right-clicks something. The only `Run`/`ShellExecute` calls in the tool open URLs and relaunch the 64-bit build.
>
> The measurement already said so and nobody asked what it implied: `D04 T01 §2` records `Ownership` at **2 net functions and 77 net lines**, which is a registry writer, not an ACL engine. `D04 T01 §1` is corrected in the same commit, because it describes "the filesystem ACLs, read back by the verify step" and a reverse that "restores every path's owner and ACL".
>
> **Blocker 1, circular.** Items below say "the first ported tool" and "both implementations of `Ownership`". No C++ `Ownership` exists, and `D04 T01 §1` lists **`D00 T02 §4`** among its own unmet dependencies. Each waits on the other.
>
> **Blocker 2, not drivable.** `grep` finds no `$CmdLine` handling in `Ownership.au3` or in `ReBar.au3`, so every tool in the AutoIt suite is GUI-only. Driving one's action today needs coordinate clicking, which item 3 below names as the cheaper substitute that **fails** this checkpoint.
>
> **Blocker 3, destructive to the developer's machine.** Those writes go to `HKCR`, which needs elevation and would add a "Take Ownership" entry to Explorer's context menu. `AGENTS.md` requires a destructive path be confirmed rather than trusted, and running one for a test is not a confirmation.
>
> **So this section builds the instrument and not the first pair.** The driver, the record format and the field-by-field comparison are all provable today against real system state using `§2`'s fixtures. The first cross-implementation pair belongs to the section that creates the second implementation, which breaks the circle in the honest direction.
>
> **The driver snapshots around the run rather than asking the tool to report.** That is what makes it work for both implementations identically: an AutoIt binary cannot be instrumented and does not need to be, because the record is the difference between a before and an after taken from outside.

- [x] Define the parity record: a declarative file listing the system state a run touched, keyed by target, with values and types. Done when: the format is documented and one hand-written example parses.
  **Done 2026-09-17.** The format is `tests/parity/parity.h`, line-oriented and tab-separated: one operation character (`+` added, `-` removed, `~` changed), then kind, target, field, type and value, with `#` header lines. Chosen over a structured format because it is diffable in git, greppable, and parseable by anything, including a future AutoIt-side emitter that will not have this library. The hand-written example parses: `A hand-written parity record parses`, and it found two defects doing so, both recorded below.
- [x] Emit a parity record for a run, by snapshotting the declared scope before and after it. **Corrected 2026-09-17:** this said "the driver runs the first ported tool", and there is no ported tool; `D04 T01 §1` is blocked on this very section. Done when: a change made to a fixture between two snapshots produces a record naming it, proven against both a registry scope and a filesystem scope. The driver takes the record from **outside** the run, so it needs no cooperation from the thing it measures, which is the only way an uninstrumentable AutoIt binary can be compared at all.
  **Done 2026-09-17.** Proven against both scopes: `A registry change between snapshots appears in the record` and `A filesystem change between snapshots appears in the record`, each using `§2`'s disposable fixtures so the assertions are against real system state rather than a mock.
- [x] Record what the driver can and cannot reach **today**, and what unblocks the rest. Done when: this section cites [`docs/captures/ui-automation-spike.md`](../../docs/captures/ui-automation-spike.md), states that launch, title, screenshot, coordinate click, and close work now while control-level driving needs `D01 T02 §5`, and states which parity records can therefore be produced before that section ships. Cheaper substitute that fails the checkpoint: coordinate clicking presented as control-level driving, which encodes the layout into every test and still passes when the click lands on the wrong control.

  **What the driver reaches today, recorded 2026-09-17** from [`docs/captures/ui-automation-spike.md`](../../docs/captures/ui-automation-spike.md), which measured it against the shipped binary rather than reasoning about it.

  **Works now:** launch and window attach (471 ms measured), window title read back, screenshot, coordinate click, and `CloseMainWindow` with a clean exit code 0.

  **Does not work, and needs `D01 T02 §5`:** finding a control by name or automation id, reading the text of a label, a status bar or a list row, asserting a row count, a checkbox state, a selection or an enabled state, and clicking a named button rather than a guessed position. The cause is measured, not assumed: the UI Automation tree exposes four unnamed panes with nothing inside them, because everything within them is drawn in Direct2D, and `shared/resolute-ui/` and `src/` contain no `WM_GETOBJECT`, no `IRawElementProviderSimple` and no `IAccessible`.

  **So which parity records can be produced before `D01 T02 §5` ships?** All of them, and this is the reason the instrument is built this way. A parity record is the difference between two snapshots taken from **outside** the process, so producing one needs launch and close and nothing else. What control-level driving is required for is **reaching a surface that is behind a control**: a tool whose effect happens only after the user clicks a named button cannot have that effect driven today, and its parity record must be taken around a run the operator drove by hand. Nothing about the record, the format or the comparison waits on `D01 T02 §5`.
  -> XREF: D01 T02 §5 -- the automation providers that would let a run be driven rather than performed
- [ ] ~~Run the AutoIt counterpart from `resolute_au3/` against the same fixture and emit the same record format.~~ **Deferred 2026-09-17 to the section that creates the second implementation.** Three reasons, each sufficient: no C++ `Ownership` exists and `D04 T01 §1` depends on this section; no AutoIt tool has a command line, so driving one needs the coordinate clicking item 3 forbids; and `Ownership` writes `HKCR`, which needs elevation and would alter the developer's Explorer context menu. The record format and the comparison are proven here without it, so the port inherits a working instrument rather than building one.
  -> XREF: D04 T01 §1 (item: "Prove parity: both implementations run against the same fixture tree and the parity driver reports no difference") -- the item that inherits this work, named so closure is detectable rather than asserted
- [x] Compare two records field by field and report the differences, not a boolean. Done when: two deliberately different records produce a named per-field diff, and two identical ones report parity. Cheaper substitute that fails the checkpoint: comparing exit codes, which is how two tools that did completely different things both report success.
  **Done 2026-09-17.** `Compare` returns a list of `Difference`, never a boolean: `Two different records name every differing field` asserts the differing field is named with **both** sides' values, `Two identical records report parity` asserts the empty case, and `A field present on one side only is named, not ignored` covers the asymmetric case, because a comparison that ignored a field one side never wrote would pass two tools that did different amounts of work.
- [x] State plainly what parity does not cover. Done when: this section records that the rendered surface is excluded, with the reason, so no later section claims a pixel comparison as parity.

  **Parity does not cover the rendered surface, recorded 2026-09-17.** It compares system **effects**: registry values, file content, file ownership. It says nothing about what the tool looked like while producing them.

  The reason is that the two are independent in both directions. **Two tools can produce identical system state and look nothing alike**, which is the expected outcome here, because `AGENTS.md` decides the UI is rebuilt rather than reproduced and the AutoIt windows are neither DPI-aware nor dark-mode capable. **And two tools can look identical and do different things**, which is the dangerous direction: a screenshot comparison passing would be positive evidence for a claim it cannot support.

  So appearance is owned elsewhere and a pixel comparison is never parity evidence: `DESIGN.md` and `§3`'s contract own what a surface must specify, and `D01 T02 §5` owns whether it rendered what it specified. The statement is repeated at the top of `tests/parity/parity.h`, where somebody about to extend the instrument will read it.
- [ ] Commit: `"workspace: parity driver comparing a C++ tool against its AutoIt counterpart"`

**Test checkpoint:** The driver emits a parity record from a before-and-after snapshot of a declared scope, proven against a registry scope and a filesystem scope, and a change made between the snapshots is named in the record. Two deliberately different records produce a per-field diff naming each difference; two identical records report parity. A hand-written record parses. The exclusion of the rendered surface is stated in this section. All outputs are quoted.

**Corrected 2026-09-17:** this required "records for **both implementations** of one tool", which cannot be satisfied while the second implementation does not exist, and this section is what `D04 T01 §1` waits on to build it. The requirement is not dropped: it moves to that section with an XREF, and what remains here is falsifiable on its own, because a differ that reported parity between two different records would fail it.

> **Verified:** 2026-09-17 | §4 | **the instrument, not the first pair**, because the pair was circular, undrivable and destructive and the section said otherwise · the record is taken from **outside** the run, which is the property that lets an AutoIt binary with no command line and four unnamed automation panes be measured at all · proven against a registry scope and a filesystem scope using `§2`'s disposable fixtures, so every assertion is real system state · **a diff is a list of fields, never a boolean**: two deliberately different records produce `1 differing field(s)` naming `registry|HKCR\Directory\shell\runas\command|(default)` with `cpp: + REG_SZ cmd.exe /c takeown` against `autoit: + REG_SZ cmd.exe /c DIFFERENT`, and two identical ones report `PARITY` · **the checkpoint was driven to FAIL**, by breaking one assertion deliberately, so it is falsifiable rather than asserted to be · a field present on one side only is named `absent` rather than ignored · **failing to observe is not observing no difference**: after the independent review, an unreadable scope, an empty key, a malformed row and a byte-collision could each make two different runs compare equal, and each is now closed with its own test · an incomplete record reports `NOT COMPARABLE` naming both sides and cannot reach the word PARITY · the rendered surface is excluded in the section and at the top of `tests/parity/parity.h`, with the reason, so no later section can claim a pixel comparison as parity · `All tests passed (57 assertions in 14 test cases)`, whole suite `100% tests passed out of 36`, tidy `169 finding(s), baseline 169, over 21 TU(s)`, `check-all: 11 gate(s) ok`
> **Review:** round 2, candidate `18a9c6a` `7a70eb7` -- `adversarial` approve after fixes (2) · `consistency` approve · `integration` approve after fix (2) · `source-defect` approve after fixes (3) · `design` approve · `record` approve after fixes (2). Raw findings: docs/reviews/00-workspace/D00-T02-s4.md
>
> **CRUD:** applicable | this section IS a reader of system state, so its failure paths are what matter and every one is driven. A scope it cannot open, a key it cannot enumerate, a value it cannot read, a tree walk that stops early, a file whose owner or content is unreadable: each becomes an observation failure that travels with the record through serialisation and makes a parity claim impossible. The create and delete directions are covered by the fixtures it reads, including an **empty** key, which is the shape an undo leaves behind. The instrument writes nothing to a user's system; that is the point of taking the record from outside.
> **Duration:** 33
> **Implementer:** Claude Opus 5 (claude-opus-5[1m])
> **Deferred:** the first cross-implementation parity record, because no C++ `Ownership` exists, no AutoIt tool parses a command line, and the writes land in `HKCR` on the developer's machine. The format, the driver and the comparison are proven here without it, so the port inherits a working instrument rather than building one. -> XREF: D04 T01 §1 (item: "Prove parity: both implementations run against the same fixture tree and the parity driver reports no difference") -- the item that produces it

## 5. Cover the Inherited UI Library

The library that fourteen tools are about to depend on has **no tests at all**. It renders the launcher correctly today, which is evidence that it works, not evidence that it keeps working. This section buys the right to change it.

**Needs:** Windows host (build/test)

- [x] Cover the theme system: token resolution in both appearances, the system accent derivation, high-contrast override, and the crossfade reaching its endpoint. Done when: four assertions run and a deliberately wrong token mapping fails one. **Corrected 2026-09-19:** two of the four named behaviors have no coverable form. There is no high-contrast override in the library: `Theme::IsHighContrast()` has no caller in `shared/resolute-ui/src/`, so the suite pins the query's live agreement, and enabling high contrast to test an override would change the operator's machine. The crossfade's endpoint is covered as the blend math (`LerpColor` at t=0, 0.5, 1); delivery across frames needs the manager's timer, a message loop. What headless can cover is covered; the remainder sits in Uncovered with its reason rather than claimed.
- [x] Cover the DPI layer: a layout computed at 100, 125, 150, and 200 percent produces the expected metrics. Done when: four assertions run without a display attached, or this section records why a display is required.
- [x] Cover the animation system: each named easing at its endpoints and midpoint, and the shared clock delivering ticks to subscribers. Done when: the easings are asserted against known values and a subscriber count is verified. **Corrected 2026-09-19:** tick delivery needs the manager's timer, a message loop, so headless cannot advance the shared clock; what is verified is subscribe and cancel accounting, including single-cancel routing by id and the animating flag at both ends. Delivery across frames is uncovered with the reason.
- [x] Cover icon resolution: a known Lucide glyph resolves, an unknown name fails by name rather than rendering nothing. Done when: both assertions run.
- [x] Cover the controls' non-visual logic: list selection and filtering, toolbar overflow decisions, and sidebar collapse thresholds. Done when: each is asserted against fixture state with no window created. **Corrected 2026-09-19:** the item named three behaviors headless cannot observe. ListView exposes no filter API and the sidebar's `ApplyFilter` is private with no visible-count accessor; toolbar overflow lives in the private `m_overflowStart` with no accessor; sidebar `TargetWidth()` rides the collapse animation, so settled widths need the manager's timer. Covered instead: selection, sort, badges, collapse toggling, empty states, and scaled sizes. The three sit in Uncovered with the reason, not claimed.
- [x] Record what is not covered and why. Done when: the untested surface is listed, with rendering correctness named as the part the captures cover instead.
- [x] Commit: `"workspace: cover the inherited ui library"`

Thirty-three cases in `tests/ui_test.cpp` (tags `[ui][theme]`, `[ui][anim]`, `[ui][icons]`, `[ui][controls]`), auto-wired by the existing glob. DPI rode the pre-existing `dpi_test.cpp` (D00 T02 §1); high-contrast override and system-accent derivation read live OS state, so the suite asserts the live agreement (`IsDarkMode` versus the value key) and the icon-color packing rather than fixed values. The crossfade item rests on LerpColor at both endpoints and the midpoint; AnimateToggle itself and the Lucide pre-Load guards are uncovered (see Uncovered). Toolbar overflow decisions and list filtering are private layout with no observable headless (see Uncovered). Gates, run 2026-09-19 after the order-coupling fix: `check-all: 13 gate(s) ok` with `100% tests passed out of 69`; the checkpoint command itself, `ctest --preset debug -L ui`, exits 0 with `100% tests passed out of 42`, which proves the label wiring the correction rests on (42 selected, not zero); the direct binary run `./Bin/Debug/resolute_tests.exe '[ui]'` reports `All tests passed (264 assertions in 42 test cases)`, and repeats it under `--order rand` with seeds 1 and 42, which is what proves no case depends on another's leftovers: every controls case drains the manager through an RAII guard before its control unwinds, so no armed animation survives its case. The tidy gate caught one new finding in the new TU (`bugprone-signed-bitwise` on `abgr & 0x00FFFFFF` at `tests/ui_test.cpp:109`), fixed with an unsigned suffix; the count is back at baseline 169 with zero findings in the touched TU.

Uncovered, with reasons: the render pipeline and every Paint path (need a D2D device and pixels; the captures cover rendering correctness instead); the animation manager's timer, content-view hide/error completion, and settled sidebar collapse widths (`TargetWidth()` rides the collapse animation; need a message loop); `Theme::AnimateToggle` start and completion (it opens a transition only the manager timer can close, which would poison `Colors()` for every later case in the process); `Theme::Init` and the `ReadSystemAccent` lightness math (live-machine registry dependents that mutate shared globals; the accent wiring itself is covered, and `IsHighContrast` is a covered read, not a write); `ApplyToWindow` and `ApplyBackdrop` (need an HWND); control hit-testing, drag, scroll, and column resize (need windows and pixels); `PopupMenu::Show` (modal, needs a window); typography (DWrite factory plus font files; its contract is rendered glyphs); the Lucide DLL-load failure path (dead under `LUCIDE_STATIC`); the Lucide pre-Load fail-closed guards (`Load()` is sticky with no reset seam, so no execution order guarantees a pre-Load state); toolbar overflow decisions and list filtering (private layout, no headless observable).

**Test checkpoint:** `ctest --preset debug -L ui` exits 0. A deliberately wrong token mapping, a wrong easing value, and an unknown icon name each fail by name, all three quoted. The uncovered surface is listed with its reason. **Corrected 2026-09-19:** the checkpoint read `ctest --preset x64-debug --tests-regex ui`; no `x64-debug` preset exists (the presets are `debug`/`release`), and `--tests-regex` matches test names, none of which contain `ui` -- the label flag `-L ui` is the selector the suite wires via `ADD_TAGS_AS_LABELS`. **Driven to fail 2026-09-19, all three quoted:** a token mapping of `RGB(31, 30, 30)` fails `Theme colors follow the dark flag` with `1973790 (0x1e1e1e) == 1973791 (0x1e1e1f)`; an easing midpoint of `0.126f` fails `Every easing pins its midpoint` with `0.125f is within 0.00000999999974738 of 0.12600000202655792`; a flipped unknown-name guard fails `Unknown icon names resolve to null, never crash` with `nullptr != nullptr`. Each break was reverted after capture; the tree carries only the passing suite.

> **Started:** 2026-09-19T05:15:00Z

## Verification

- [ ] `ctest --preset x64-debug` exits 0 with the fixture, parity, and ui suites reporting
- [ ] A deliberately aborted run leaves no fixture residue in registry or filesystem
- [ ] `docs/captures/house-style/` holds the derived contract and its README, and a test fails when the code drifts from it
- [ ] The parity driver produces comparable records from both implementations of one tool
- [ ] The inherited UI library has coverage, and what is uncovered is listed with its reason
- [ ] `python scripts/todo-graph.py validate` clean
