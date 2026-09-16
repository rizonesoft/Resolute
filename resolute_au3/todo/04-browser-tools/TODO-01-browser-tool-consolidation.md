---
schema_version: 1
id: browser-tool-consolidation
domain: 04-browser-tools
status: draft
title: "TODO-01 -- Browser Tool Consolidation"
depends_on: []
track: B1
---

# TODO-01 -- Browser Tool Consolidation

> **Goal:** `Firemin`, `Chromin`, `Edgemin`, and `Watermin` become one shared optimizer core plus four small browser profiles. A bug is fixed once instead of four times, a feature lands in all four at once, and the three tools that today ship with no logging and no translations get both by inheriting them.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** The four scripts are the same 2,389-line file. Normalizing tool and browser names, `Firemin.au3` and `Chromin.au3` differ on **five lines**: two `#AutoIt3Wrapper_Res_` version directives and three occurrences of the default browser path (`@ProgramFilesDir & "\Mozilla Firefox\firefox.exe"` versus `@ProgramFilesDir & "\Google\Chrome\Application\chrome.exe"`, at lines 311, 988, and 1295). `Edgemin.au3` and `Watermin.au3` differ on four. None of the four includes `Logging.au3`, so none of them leaves a trace when it terminates or restarts a user's browser. All four call `IsAdmin()`, which makes them the only tools in the suite that do. `Resolute/Language/` has a `Firemin` directory but none for `Chromin`, `Edgemin`, or `Watermin`. `Resolute/Docs/` has directories for `Firemin` and `Chromin` but none for `Edgemin` or `Watermin`. All four write settings correctly to `.ini`. Au3Check reports 0 errors and 45 unique warnings for each of the four, the same 45 warnings four times over.

## Inputs

- [`SDK/Concrete/Firemin/Firemin.au3`](../../SDK/Concrete/Firemin/Firemin.au3) -- the most current of the four (version 12.2.1.9559); §1 extracts the core from it
- [`SDK/Concrete/Chromin/Chromin.au3`](../../SDK/Concrete/Chromin/Chromin.au3) -- the diff against Firemin is the whole specification of what a browser profile must carry
- [`Resolute/Language/Firemin/`](../../Resolute/Language/Firemin) -- the only language pack any of the four has; §6 extends it to the others
- -> XREF: [`01-sdk-core/TODO-01 §4`](../01-sdk-core/TODO-01-shared-include-contracts.md) -- the logging contract these four tools have never consumed
- -> XREF: [`00-workspace/TODO-01 §3`](../00-workspace/TODO-01-toolchain-and-gates.md) -- the one-command build that proves all four still compile after the extraction
- -> XREF: [`08-docs-localization/TODO-01 §1`](../08-docs-localization/TODO-01-docs-and-localization.md) -- the missing docs directories for Edgemin and Watermin

## Outcome

- One shared optimizer core under `SDK/Includes/`, consumed by four thin tool scripts that differ only in their browser profile.
- A change to the optimizer behavior lands in all four tools in one edit, proven by building all four.
- All four log what they do to a user's browser.
- All four have a language pack and a documentation directory.

**Adjacency:** list=not-applicable (a memory optimizer holds no records a user browses; the process list it acts on is transient and owned by the running browser); document=not-applicable (nothing here produces a document a user carries; the log is the trace and §5 owns it); settings=applicable @ D04 T01 §2; reporting=applicable @ D04 T01 §5; notifications=applicable @ D04 T01 §5; permissions=applicable @ D04 T01 §3; audit=applicable @ D04 T01 §5; exchange=applicable @ D04 T01 §2; reverse=applicable @ D04 T01 §3

**Adjacency rationale:** Settings and exchange both land on §2 because the browser profile is the settings surface here: the browser path is a value the user can change and an `.ini` a user may hand-edit when their browser is installed somewhere unusual, which is the single most likely support case these tools have. Reverse is §3 and is worth stating plainly: the reverse of trimming a browser's working set is that the browser pages memory back in on its own, which is a real answer rather than an undo button, and the section says so instead of pretending a button exists. Audit, reporting, and notifications converge on §5 because all three are the same missing thing: these tools currently act on a user's running browser and say nothing anywhere.

## Implementation Order

| Order | Section | Deliverable                                      | Depends On | Status |
| :---: | :-----: | ------------------------------------------------ | ---------- | :----: |
|   1   |   §1    | Extract the shared optimizer core                | D00 T02 §1, D00 T02 §3 |  [ ]   |
|   2   |   §2    | Browser profile descriptors                      | §1         |  [ ]   |
|   3   |   §3    | Firemin on the shared core                       | §2         |  [ ]   |
|   4   |   §4    | Chromin, Edgemin, Watermin on the shared core    | §3         |  [ ]   |
|   5   |   §5    | Logging across all four                          | §4, D01 T01 §4 |  [ ]   |
|   6   |   §6    | Language packs for the three missing tools       | §4, D01 T01 §5 |  [ ]   |

---

## 1. Extract the Shared Optimizer Core

Four copies of one 2,389-line script is four places to fix every bug and four places to forget. The extraction is mechanical because the diff is five lines, and it is the whole value of this file: everything after it is cheap, and nothing after it is possible without it.

- [ ] Create `SDK/Includes/BrowserOptimizer.au3` holding the logic common to all four scripts, with the browser-specific values taken as parameters rather than read from globals. Done when: the include compiles under Au3Check and names no browser. Cheaper substitute: copying Firemin and adding an `If` per browser, which is four copies with extra steps.
- [ ] Define the seam explicitly: the core owns the optimize loop, the process enumeration, the working-set trim, the timer, and the surface; the profile owns the browser name, the executable name, the default install path, and the product version. Done when: the seam is written into the include header and nothing on the wrong side of it remains.
- [ ] Prove the extraction against the measured diff: every one of the five lines that differ between `Firemin.au3` and `Chromin.au3` is now either in the profile or in the build descriptor, and nothing else moved. Done when: the section records which of the five went where.
- [ ] Keep the existing surface exactly: this section changes structure, not behavior or layout. Done when: a driven run of the rebuilt Firemin produces a window that matches the pre-change capture.
- [ ] Add `tests/browseroptimizer.test.au3` covering the core's decisions without a browser: the trim decision given a process list fixture, the interval calculation, and the skip when no matching process is running. Done when: three assertions run under the harness with no browser installed.
- [ ] Commit: `"browser-tools: extract the shared optimizer core"`

**Test checkpoint:** `AutoIt3.exe tests/run-tests.au3 --filter browseroptimizer` exits 0 with three assertions against a process-list fixture and no browser running. `pwsh scripts/au3check-all.ps1` reports the new include with zero new warnings. A driven run of the rebuilt `Firemin.exe` is captured and compared against the pre-change capture. All three are quoted in the commit body.

## 2. Browser Profile Descriptors

The profile is what makes four tools out of one core. Keeping it small and declarative is what stops the core from growing browser-specific branches later.

- [ ] Define the profile shape: browser display name, process name, default install path, settings short name, and the `.lng` section it reads. Done when: the shape is documented in the core's header and carries no behavior, only values.
- [ ] Write the four profiles from the measured differences: Firefox at `@ProgramFilesDir & "\Mozilla Firefox\firefox.exe"`, Chrome at `@ProgramFilesDir & "\Google\Chrome\Application\chrome.exe"`, and the Edge and Waterfox equivalents read from their current scripts. Done when: all four profiles exist and each default path matches what its script uses today, line for line. Source: `Firemin.au3:311,988,1295` and the corresponding lines in the other three.
- [ ] Keep the user override working: the browser path is read from the tool's `.ini` with the profile default as the fallback, exactly as `Firemin.au3:988` does today. Done when: a fixture `.ini` pointing at a different path is honored and an absent key falls back to the profile default.
- [ ] Treat the `.ini` as a file a user may hand-edit: a path that does not exist produces a named message and a log line, not a silent no-op. Done when: a fixture pointing at a nonexistent executable produces both.
- [ ] Add the profile assertions to the harness: default fallback, user override, and the nonexistent-path message. Done when: three assertions run.
- [ ] Commit: `"browser-tools: declare each browser as a profile over the shared core"`

**Test checkpoint:** `AutoIt3.exe tests/run-tests.au3 --filter browserprofile` exits 0 with three assertions: the default path for each of the four profiles matches the value its current script uses, a fixture `.ini` override is honored, and a nonexistent path produces the named message and one log line. All outputs are quoted in the commit body.

## 3. Firemin on the Shared Core

Firemin is the most current of the four and the one with a language pack and documentation, so it is the proving ground. If the core is wrong, it is wrong here, where the comparison against the old build is cleanest.

**Fidelity:** the Firemin main window, its optimization view, and its settings, against `docs/captures/house-style/` and a pre-change capture of the shipped 12.2.1 build. This section must produce a window indistinguishable from the one it replaces.
**Job:** a user can reduce Firefox's memory footprint and see that it happened. Consumer: the optimization result shown on the surface, and the log added in §5.
**Treatment:** the same optimization behavior as the shipped build, proven by comparing a driven run against a pre-change measurement. Cheaper substitute that fails the checkpoint: a rebuilt tool that renders correctly but optimizes differently, which no screenshot would catch.
**Chrome:** consume `SDK/Includes/BrowserOptimizer.au3`, `SDK/Includes/GDIPlusProgressBar.au3`, `SDK/Includes/About.au3`, and `SDK/Includes/Localization.au3`. Do not keep a private copy of any of them.
**Needs:** Windows host (build/test)

- [ ] Capture the shipped build first: a driven run of the current `Firemin.exe` against a running Firefox, recording the before and after memory figures and a screenshot. Done when: the capture and the figures are committed under `docs/captures/` as the comparison baseline.
- [ ] Reduce `SDK/Concrete/Firemin/Firemin.au3` to its profile plus the core include, keeping its `#AutoIt3Wrapper_Res_` directives and its `.sni`. Done when: the file is under 200 lines and contains no optimizer logic.
- [ ] Prove the behavior matches: a driven run of the rebuilt tool against a running Firefox produces a comparable reduction to the baseline, and the section records both figures. Done when: both numbers are in the commit body and the section states what counts as comparable.
- [ ] Prove the surface matches: the rendered window is compared against the pre-change capture. Done when: the comparison is recorded and any difference is listed and approved.
- [ ] Account for the surface: every control, menu item, and dialog on the Firemin window is working or deferred to a named section. Done when: the account covers the whole window and each deferral resolves.
- [ ] Confirm the language pack still resolves: drive the tool with each pack in `Resolute/Language/Firemin/` and report missing keys. Done when: every pack is driven and its missing keys reported.
- [ ] Commit: `"firemin: run on the shared optimizer core"`

**Test checkpoint:** `pwsh scripts/build.ps1 Firemin` builds both architectures. A driven run against a running Firefox reduces memory comparably to the recorded pre-change baseline, with both figures quoted. The rendered window is compared against the pre-change capture and any difference listed. `Firemin.au3` is under 200 lines. All outputs are quoted in the commit body.

## 4. Chromin, Edgemin, and Watermin on the Shared Core

With Firemin proven, the other three are the same change three times, and the point of this section is that it should be boring. If it is not boring, the seam in §1 was drawn in the wrong place.

**Fidelity:** each tool's main window against its own pre-change capture, and against `docs/captures/house-style/`. Three windows, three comparisons.
**Job:** a user can reduce Chrome's, Edge's, or Waterfox's memory footprint and see that it happened. Consumer: the surface result and the log.
**Treatment:** each tool proven against its own browser, not inferred from Firemin's result. Cheaper substitute that fails the checkpoint: building all three and declaring them proven because Firemin worked.
**Chrome:** consume the same shared includes as §3. Do not let any of the three keep a private copy of the optimizer.
**Needs:** Windows host (build/test)

- [ ] Capture each shipped build first, as §3 did for Firemin: a driven run per tool against its browser, with figures and a screenshot. Done when: three baselines are committed.
- [ ] Reduce each of `Chromin.au3`, `Edgemin.au3`, and `Watermin.au3` to its profile plus the core include. Done when: all three are under 200 lines and contain no optimizer logic.
- [ ] Prove each behavior against its own browser, recording before and after figures per tool. Done when: three pairs of figures are in the commit body.
- [ ] Prove each surface against its own pre-change capture. Done when: three comparisons are recorded and differences listed.
- [ ] Account for the surface on each of the three: every control working or deferred to a named section. Done when: three accounts are written.
- [ ] Record the version story: the three tools sit at 11.8.3 while Firemin is at 12.2.1, and after this change they share one implementation. Decide and record whether the versions converge, with the cost of changing the decision. Done when: the decision is dated and written here, and `D06 T01 §5` is named as its enforcer.
- [ ] Commit: `"chromin, edgemin, watermin: run on the shared optimizer core"`

**Test checkpoint:** `pwsh scripts/build.ps1 -All` builds all four browser tools to both architectures. Driven runs of `Chromin`, `Edgemin`, and `Watermin` against their own browsers each produce a reduction comparable to that tool's recorded baseline, with all three pairs of figures quoted. Each rendered window is compared against its own pre-change capture. All three source files are under 200 lines.

## 5. Logging Across All Four

These four tools terminate and restart a user's browser and currently record nothing anywhere. That is the single largest supportability gap in the suite, and after the consolidation it is one change rather than four.

**Fidelity:** no new surface. The log is written, not displayed, in this section; the display is the shared viewer the rest of the suite already uses.
**Job:** a user or a support reader can find out what the optimizer did to their browser and when. Consumer: `Resolute/Logging/`, read back through the shared log viewer.
**Treatment:** one line per action through `_Logging_Action`, including the actions the user did not ask for explicitly such as an interval-triggered optimization. Cheaper substitute that fails the checkpoint: logging only the button press, which leaves every automatic optimization invisible.
**Chrome:** consume `SDK/Includes/Logging.au3`. Do not add a second log format for these four tools.

- [ ] Include `Logging.au3` in the shared core so all four inherit it, using the single-backslash include form. Done when: all four built tools write to `Resolute/Logging/` and none of the four scripts includes it directly.
- [ ] Log every optimization: the trigger (manual or interval), the browser, the processes acted on, and the memory before and after. Done when: a driven run produces one line carrying all five.
- [ ] Log every refusal and failure: browser not found, browser not running, path invalid, privilege refused. Done when: all four cases are driven and each produces exactly one line.
- [ ] Honor the shared logging settings so a user can turn it off and cap its size, the same way the launcher does. Done when: `LoggingEnabled=0` stops the writes and a small size triggers rotation, both observed.
- [ ] Prove the notification path: whatever the tool shows the user on completion comes from the shared message layer and matches the log line's content. Done when: the message and the line agree, checked on one driven run.
- [ ] Commit: `"browser-tools: log every optimization and every refusal"`

**Test checkpoint:** A driven run of each of the four built tools produces a log line carrying trigger, browser, processes, and the before and after memory, all four quoted. The four refusal cases each produce exactly one line. `LoggingEnabled=0` produces none. The completion message and the log line agree. All outputs are quoted in the commit body.

## 6. Language Packs for the Three Missing Tools

Firemin has a language directory and the other three do not, which means a translator who translated this suite translated a quarter of it. Now that all four render from one core, the packs are a copy plus a review.

- [ ] Create `Resolute/Language/Chromin/`, `Resolute/Language/Edgemin/`, and `Resolute/Language/Watermin/` with an `en.lng` derived from the shared core's keys. Done when: all three exist and each resolves every key the core asks for.
- [ ] Verify against the running tool rather than by inspection: drive each tool and report any key the surface asked for that its pack lacks. Done when: all three report zero missing keys.
- [ ] Port the existing Firemin translations where the string is browser-independent, and leave browser-specific strings untranslated rather than guessing. Done when: each ported file is listed here with which strings were ported and which were left.
- [ ] Record the coverage in the language matrix so the gap is visible if it reopens. Done when: the matrix names all four tools and their packs.
- [ ] Commit: `"browser-tools: give chromin, edgemin, and watermin language packs"`

**Test checkpoint:** Driving each of the four built tools with each available pack reports zero missing keys, and the reports are quoted. `Resolute/Language/` contains a directory for all four tools. The captures of one translated surface per tool are committed under `docs/captures/runs/`.

## Verification

- [ ] `pwsh scripts/au3check-all.ps1` exits 0, and the baseline shrank by roughly the three duplicate copies of the 45 warnings these tools shared
- [ ] `pwsh scripts/build.ps1 -All` builds all four browser tools to both architectures
- [ ] `AutoIt3.exe tests/run-tests.au3` exits 0 with the browseroptimizer and browserprofile suites reporting
- [ ] All four tool scripts are under 200 lines and none contains optimizer logic
- [ ] All four write to `Resolute/Logging/` on a driven run
- [ ] `python scripts/todo-graph.py validate` clean
