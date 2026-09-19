---
schema_version: 1
id: framework-core
domain: 01-framework
status: draft
title: "TODO-01 -- Framework Core"
depends_on: [cpp-toolchain-and-gates, cpp-test-backbone]
track: F1
---

# TODO-01 -- Framework Core

> **Goal:** One framework that every tool consumes, owning everything a Resolute tool does before it does anything specific: startup, settings, logging, localization, update, elevation, preferences, About, DPI, and theme. Written once, so a correction lands once.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** None of this exists in C++. In the AutoIt tree it exists fourteen times. `ReBar.au3` is 1,556 lines of pure framework and every tool carries a near-copy of it: all fourteen privately define `_SetWorkingDirectories`, `_GenerateIniFile`, `_LoadConfiguration`, and `_SaveConfiguration`; thirteen privately define `_ShowPreferencesDlg` and `_SetProcessPriority`; thirteen carry a private `Includes/Localization.au3` of 122 to 491 lines. Roughly 21,000 of that tree's 43,000 lines are those copies. The measurable consequence is that seven tools write settings into a `.lng` file and seven into `.ini`, because the path was typed out fourteen separate times. Every script also carries `#AutoIt3Wrapper_Res_HiDpi=N`, so the whole suite renders bitmap-scaled on a high-resolution display.
>
> <!-- claim: exists resolute_au3/SDK/Concrete/ReBar/ReBar.au3 -->
> <!-- claim: lines resolute_au3/SDK/Concrete/ReBar/ReBar.au3 = 1556 -->
> <!-- claim: count "ReBar Framework" resolute_au3/SDK/Concrete/ReBar/ReBar.au3 = 4 -->
> <!-- claim: count "Res_HiDpi=N" resolute_au3/SDK/Concrete/*/*.au3 = 14 -->

## Inputs

- [`resolute_au3/SDK/Concrete/ReBar/ReBar.au3`](../../resolute_au3/SDK/Concrete/ReBar/ReBar.au3) -- the framework being ported, and the closest thing to a specification this file has
- [`resolute_au3/SDK/Includes/`](../../resolute_au3/SDK/Includes) -- the shared includes `ReBar` consumes: `About.au3`, `Update.au3`, `Logging.au3`, `Localization.au3`, `Versioning.au3`
- -> XREF: [`00-workspace/TODO-01 §4`](../00-workspace/TODO-01-toolchain-and-gates.md) -- the build this framework is the first real consumer of
- -> XREF: [`00-workspace/TODO-02 §1`](../00-workspace/TODO-02-test-backbone.md) -- the harness these assertions run under
- -> XREF: [`00-workspace/TODO-03 §3`](../00-workspace/TODO-03-codebase-intake.md) -- the UI library this framework adopts, renamed by that section
- -> XREF: [`01-framework/TODO-02 §1`](./TODO-02-design-system.md) -- the design contract every surface here is held to
- -> XREF: [`02-repair-contract/TODO-01 §1`](../02-repair-contract/TODO-01-repair-contract.md) -- the second layer, which sits on this one
- -> XREF: [`03-launcher/TODO-01 §1`](../03-launcher/TODO-01-launcher.md) -- the launcher, this framework's first product consumer
- -> XREF: [`04-tools-port/TODO-01 §1`](../04-tools-port/TODO-01-tool-ports.md) -- the ports, every one of which consumes this
- -> XREF: [`07-quality/TODO-01 §1`](../07-quality/TODO-01-quality-bar.md) -- the conformance profile, which is largely "consumes this framework correctly"
- -> XREF: [`08-docs-localization/TODO-01 §2`](../08-docs-localization/TODO-01-docs-and-localization.md) -- the language packs the localization layer loads
- -> XREF: D01 T03 §1 -- the surface specification this framework builds from ([TODO-03](./TODO-03-framework-surfaces.md))

## Outcome

- A tool is the framework plus its own logic, and its own logic is the only thing in its source file.
- Settings live in one place, written by one writer, and survive a restart.
- Every tool logs, in one format, to one place.
- Every surface string resolves from a pack, and a missing key is reported rather than rendered blank.
- The update check works, and can announce a consolidation in the user's language.
- A privileged action is refused by name when the privilege is absent.
- Every window is DPI-correct and follows the system theme.
- A tool placed alone in an empty folder still does all of the above.
- A tool that crashes says so, leaves a report, and leaves its repair undoable.
- Two copies of a tool cannot change the same thing at the same time.
- Every tool can be run unattended from a script and branched on by its exit code.

**Adjacency:** list=not-applicable (the framework holds no records a user browses; the tools built on it do); document=applicable @ D01 T01 §7; settings=applicable @ D01 T01 §2; reporting=applicable @ D01 T01 §3; notifications=applicable @ D01 T01 §5; permissions=applicable @ D01 T01 §6; audit=applicable @ D01 T01 §3; exchange=applicable @ D01 T01 §4; reverse=not-applicable (the framework changes nothing on a user's system; the repair contract owns undo)

**Adjacency rationale:** Settings anchors on §2 because the settings writer is the single defect this framework exists to stop recurring, and it is the surface every other section reads through. Exchange anchors on §4 because a language pack is a file a translator edits by hand and hands back, which makes it untrusted input with an encoding and a missing-key story rather than a lookup table. Audit and reporting pair on §3 because the log is both, and the AutoIt suite demonstrated what happens when six tools skip it.

## Implementation Order

| Order | Section | Deliverable                                     | Depends On             | Status |
| :---: | :-----: | ----------------------------------------------- | ---------------------- | :----: |
|   1   |   §1    | Application shell and lifecycle                 | D00 T01 §4, D00 T02 §1 |  [ ]   |
|   2   |   §2    | Settings: one writer, one path                  | §1                     |  [ ]   |
|   3   |   §3    | Logging and the log surface                     | §1, D01 T03 §4         |  [ ]   |
|   4   |   §4    | Localization and the pack loader                | §2                     |  [ ]   |
|   5   |   §5    | Update check and consolidation announcement     | §2, §4, D01 T03 §5     |  [ ]   |
|   6   |   §6    | Elevation and its refusal path                  | §3, §4, D01 T03 §6     |  [ ]   |
|   7   |   §7    | Adopt the UI library and its surfaces           | §4, D00 T03 §3, D01 T03 §1, D01 T03 §2, D01 T03 §3 |  [ ]   |
|   8   |   §8    | Extend the UI library for the tools             | §7                     |  [ ]   |
|   9   |   §9    | Standalone proof in an empty folder             | §2, §4, §5, §7         |  [ ]   |
|  10   |   §10   | Crash handling and single instance              | §1, §3, D01 T03 §6     |  [ ]   |
|  11   |   §11   | Command line and exit codes                     | §1, §3, §6             |  [ ]   |
|  12   |   §12   | About dialog, from the registry                 | §7, D06 T01 §10, D01 T03 §7 |  [ ]   |
|  13   |   §13   | F1 context help through the surface map         | §7, D06 T01 §14        |  [ ]   |

---

## 1. Application Shell and Lifecycle

Everything else in this file hangs off the shell. It decides what a tool is structurally, and getting the seam wrong here is what produced fourteen copies last time.

**Fidelity:** no surface of its own. The shell constructs windows; the surfaces live in §7.
**Needs:** C++ toolchain (compile)

- [ ] Create the source layout exactly as `AGENTS.md` declares it, before writing any framework code. Done when: every directory in that table exists and every later section can name its target file without inventing one. Cheaper substitute that fails the checkpoint: letting each section choose its own file, which is how fourteen tools came to hold fourteen settings paths.
- [ ] Define the tool descriptor in `src/framework/ToolDescriptor.h`: display name, short name, version, product URL, update short name, and icon. Done when: the type carries values only and no behavior, and a tool supplies one to start.
- [ ] Implement startup: resolve working directories, load configuration, initialize logging, resolve the language, construct the main window, in a documented order. Done when: the order is written in the header and a tool with a minimal descriptor starts.
- [ ] Implement shutdown: persist configuration, flush the log, release resources. Done when: a forced close still writes the configuration, proven by a readback.
- [ ] Draw the seam explicitly: the framework owns lifecycle and shared surface, the tool owns its own logic and its own window contents. Done when: the seam is documented and nothing tool-specific exists on the framework side.
- [ ] Add assertions for the lifecycle order and the shutdown persist. Done when: both run under Catch2.
- [ ] Commit: `"framework: application shell and lifecycle"`

**Test checkpoint:** A minimal tool built on the shell starts and exits cleanly for both architectures. The documented startup order matches the asserted order. A forced close persists configuration, proven by readback. All three quoted.

## 2. Settings: One Writer, One Path

This section exists because the AutoIt suite typed its settings path fourteen times and got it wrong seven times. One writer, one resolver, and no tool ever computes a settings path again.

**Fidelity:** no surface of its own; the preferences dialog in §7 is the surface.
**Needs:** C++ toolchain (compile)

- [ ] Implement the settings path resolver from the tool descriptor, producing exactly one path per tool. Done when: no tool can compute its own path, because the framework exposes no way to. Cheaper substitute: a helper that returns a directory and lets each tool append its own filename, which is precisely the AutoIt failure.
- [ ] Implement typed read and write with defaults, backed by an `.ini` matching the format the AutoIt tools use. Done when: a file written by the AutoIt tool reads back identically through the new reader, proven on a committed fixture.
- [ ] Write atomically and read back before reporting success. Done when: a write to a read-only location reports failure rather than claiming success, and the original file is intact afterwards.
- [ ] Carry the portable and installed distinction the AutoIt tools support, resolving to the correct location for each. Done when: both modes resolve and this section records how a tool learns which it is in.
- [ ] Migrate an existing `<Tool>.lng` settings file to `<Tool>.ini` on first start, with a log line. Done when: a fixture `.lng` taken from the AutoIt tree migrates and the line is written.
- [ ] Add assertions for round trip, defaults, atomic-write failure, and migration. Done when: four assertions run.
- [ ] Commit: `"framework: one settings writer and one settings path"`

**Test checkpoint:** `ctest` runs four settings assertions green. An `.ini` written by the shipped AutoIt tool reads back identically. A write to a read-only target reports failure with the original intact. A fixture `.lng` migrates with its log line. All quoted.

## 3. Logging and the Log Surface

Six of fourteen AutoIt tools write no log at all, including every browser optimizer, which terminates and restarts a user's browser silently. In the framework this is one implementation no tool can opt out of by forgetting.

**Fidelity:** the shared log viewer, against `docs/captures/house-style/`.
**Job:** a user or a support reader can find out what a tool did to their machine and when. Consumer: the log files, read back by the viewer.
**Treatment:** one line per action, written through a single call no tool can bypass, including actions the user did not trigger explicitly. Cheaper substitute that fails the checkpoint: logging only user-initiated actions, which leaves every scheduled or automatic operation invisible.
**Chrome:** consume the framework's standard window and list surface. Do not build a second log format.
**Needs:** C++ toolchain (compile)

- [ ] Implement the log writer with the AutoIt log format preserved, so existing readers and support habits still work. Done when: a line written by the new writer matches the shape of one from the AutoIt tool, compared on a fixture.
- [ ] Implement the action log call every destructive or notable operation uses. Done when: it is the only way to write a log line and takes the action and its target as arguments.
- [ ] Honor the enable switch and the size cap, with rotation. Done when: disabling stops the writes and a small cap triggers rotation, both observed.
- [ ] Guarantee a log line cannot be lost for an action already performed. Done when: an action followed by forced termination still leaves its line, proven by a driven run.
- [ ] Add assertions for format, rotation, and the disable switch. Done when: three assertions run.
- [ ] Commit: `"framework: one log format, one log writer"`

**Test checkpoint:** Three logging assertions run green. A line from the new writer matches the AutoIt shape on a fixture. Disabling produces no writes; a small cap rotates. An action followed by forced termination still leaves its line. All quoted.

## 4. Localization and the Pack Loader

`Firemin` has 35 language packs and three browser tools built from the same source have none. In the framework a tool cannot have fewer languages than the framework does, because it does not own the loader.

**Fidelity:** no surface of its own; every surface in §7 renders through it.
**Needs:** C++ toolchain (compile)

- [ ] Implement the pack loader reading the existing `.lng` format, so the 35 packs in `resolute_au3/Resolute/Language/Firemin/` load unchanged. Done when: all 35 load and their key counts are reported.
- [ ] Resolve a key through tool pack, then common pack, then the built-in English fallback. Done when: the order is asserted and a key present only in the common pack resolves.
- [ ] Report missing keys rather than rendering blank. Done when: driving a tool with a deliberately incomplete pack lists every key the surface asked for and did not get.
- [ ] Treat a pack as untrusted input: wrong encoding, truncated file, or duplicate key produces a named message and a log line, not a crash. Done when: three malformed fixture packs are handled and each produces its message.
- [ ] Support the language list in preferences, resolving display names without hardcoding them per tool. Done when: the list renders for every pack present.
- [ ] Add assertions for resolution order, missing-key reporting, and the three malformed cases. Done when: five assertions run.
- [ ] Commit: `"framework: localization and the pack loader"`

**Test checkpoint:** All 35 Firemin packs load with key counts reported. Resolution order is asserted. An incomplete pack produces a missing-key list. Three malformed packs each produce a named message and a log line. All quoted.

## 5. Update Check and Consolidation Announcement

The update mechanism already works and its file format is already deployed to users. What it cannot do is tell somebody their product has been consolidated into another one, which four retiring products need it to do.

**Fidelity:** the update notice, against `docs/captures/house-style/`.
**Job:** a user learns a newer version exists, or that their product has been consolidated into another one, in their own language. Consumer: the update file on the server, and the notice on screen.
**Treatment:** the server supplies a successor name only, and the language pack supplies the sentence around it. Cheaper substitute that fails the checkpoint: a free-text message from the server, which reaches every user in one language regardless of their own.
**Chrome:** consume the framework's message layer and localization loader. Do not build a second notice dialog.
**Needs:** C++ toolchain (compile)

- [ ] Implement the check against `<UpdateServer>/<ShortName>.ru`, with `.ruz` on a beta build, matching the AutoIt behavior. Done when: both resolve correctly for a descriptor and the AutoIt URLs are reproduced exactly.
- [ ] Parse the update file's `[Update]` section with `LatestBuild` and `UpdateURL`, ignoring unknown keys. Done when: a file carrying extra keys parses without error, which is what keeps already-shipped builds compatible.
- [ ] Add the optional `Successor` key carrying a display name only, rendered through a language-pack template. Done when: a fixture update file naming a successor produces the announcement in the pack's language. Cheaper substitute that fails the checkpoint: a free-text message from the server, which arrives in one language regardless of the user's.
- [ ] Handle the offline and malformed cases without blocking startup. Done when: an unreachable server and a truncated file each produce one log line and no dialog, both observed.
- [ ] Honor the check frequency setting, including never. Done when: each setting is driven and the observed behavior matches.
- [ ] Add assertions for URL derivation, unknown-key tolerance, the successor template, and the offline path. Done when: four assertions run.
- [ ] Commit: `"framework: update check and the consolidation announcement"`

**Test checkpoint:** Four update assertions run green. A fixture naming a successor renders the announcement from the language pack, quoted in two languages. A file with unknown keys parses. An unreachable server produces one log line and no dialog. All quoted.

## 6. Elevation and Its Refusal Path

Every AutoIt tool requests elevation at startup and then assumes it holds for the session. None re-checks at the action. This section puts the check where the damage would happen.

**Fidelity:** the refusal notice, reusing the shared message dialog in `docs/captures/house-style/`. No new dialog.
**Job:** a user without the privilege a tool needs is told which action needs what, before anything is changed. Consumer: the log, and the action path that does not run.
**Treatment:** the check sits immediately before the privileged call, not at startup. Cheaper substitute that fails the checkpoint: checking once at startup and treating the answer as true for the session, which is what all fourteen AutoIt tools do.
**Chrome:** consume the framework's message layer and logging. Do not build a second refusal dialog.
**Needs:** C++ toolchain (compile)

- [ ] Implement the elevation check as a guard taking the action name and returning whether it may proceed. Done when: it is the only elevation primitive the framework exposes.
- [ ] Refuse by name: the message states which action needs what privilege, before anything is attempted. Done when: an unelevated session produces the named refusal and nothing is changed.
- [ ] Log every refusal exactly once. Done when: a refused action writes one line naming the tool and the action, asserted.
- [ ] Support the case where a tool can still do something useful unelevated. Done when: the framework exposes the distinction and this section records that each tool declares its own answer.
- [ ] Add assertions for the guard, the refusal message, and the single log line. Done when: three assertions run unelevated.
- [ ] Commit: `"framework: gate privileged actions at the call site"`

**Test checkpoint:** Three elevation assertions run green in an unelevated session, each proving the action was refused by name, nothing changed, and exactly one log line was written. The refusal message is quoted.

## 7. Adopt the UI Library and Its Surfaces

Most of this section already exists. `shared/resolute-ui` is 6,865 lines of Direct2D and DirectWrite carrying theme, typography, DPI, animation, icons, and six controls, and it renders the launcher today at 1.39 MB fully static. What it does **not** have is an About dialog, a preferences host, or any binding to the settings and localization layers built in §2 and §4.

This section connects the two, and it is adoption rather than construction. DPI and dark mode are not built here: Direct2D is vector-crisp by construction and the theme system already carries a semantic palette with four elevation levels, animated crossfade, DWM accent reading, and high-contrast detection.

**Fidelity:** the standard tool window, the About dialog, and the preferences dialog, against `docs/captures/house-style/`. Layout and terminology match the captures; DPI and theme are the approved deviations.
**Job:** a user recognizes any tool in the suite as part of one product, and changes a shared setting in the place they already know. Consumer: the rendered surfaces, and the settings writer behind preferences.
**Treatment:** one implementation of each surface, parameterized by the tool descriptor. Cheaper substitute that fails the checkpoint: a base surface each tool is free to override, which is how fourteen About dialogs drifted apart.
**Chrome:** consume the framework's own settings writer and localization loader. A tool may add a preferences page; it may not fork the dialog.
**Needs:** C++ toolchain (compile)

- [ ] Bind the UI library's text rendering to the localization loader from §4, so every string on every control resolves from a pack. Done when: driving with an incomplete pack lists the missing keys and nothing renders as bare English.
- [ ] Bind the theme mode to the settings writer from §2, so light, dark, and follow-system persist. Done when: each is driven and survives a restart, proven by readback.
- [ ] Build the About dialog on the library's controls, from the §12 identity registry, with no per-tool copy. Done when: two different tools render correct About dialogs with no tool-side code.
- [ ] Build the preferences host covering language, logging, update frequency, and process priority. Done when: every control persists through the §2 writer and survives a restart.
- [ ] Let a tool add its own preferences page without forking the host. Done when: a tool contributes a page and the framework's pages are unchanged.
- [ ] Account for the surface: every control on all three surfaces is working or deferred to a named section. Done when: the account is written and each deferral resolves.
- [ ] Compare each rendered surface against its house-style capture and list every difference. Done when: three comparisons are recorded and each difference is either approved or fixed.
- [ ] Commit: `"framework: standard window, about, and preferences"`

**Test checkpoint:** Two different tools render correct About dialogs with no tool-side code. Every preferences control persists and survives a restart, proven by readback. The three rendered surfaces are compared against their captures with differences listed. Captures committed under `docs/captures/runs/`.

-> XREF: D01 T01 §12 -- the About dialog specified in full, rendered from the registry

## 8. Extend the UI Library for the Tools

The library has six controls, built for a launcher that browses and launches things. The repair tools need surfaces it does not have: a per-item result list that reconciles, a progress surface, and the standard message and confirmation dialogs every destructive action goes through.

This section is where those are added **to the library**, not to a tool. Getting that wrong is how the AutoIt suite grew fourteen private progress bars.

**Fidelity:** the new controls against the existing library's visual language and `TODO-ux.md`, captured at four scalings and in both appearances.
**Job:** a repair tool can show what it did, how far along it is, and what it is about to destroy, using controls the whole suite shares. Consumer: the rendered surfaces, and the repair contract that drives them.
**Treatment:** every new surface added to the shared library. Cheaper substitute that fails the checkpoint: adding a result list to the first tool that needs one, which is how fourteen private progress bars happen.
**Chrome:** extend `shared/resolute-ui`. No tool defines its own control. Every new control is held to [`DESIGN.md`](../../DESIGN.md).
**Needs:** Windows host (build/test)

- [ ] Add the result list control: one row per item with an outcome, a reason, and reconciling counts. Done when: a fixture set of mixed outcomes renders and the counts add up, captured.
- [ ] Add the progress surface, covering both determinate and indeterminate work. Done when: both render and a long operation remains responsive, captured.
- [ ] Add the message and confirmation dialogs, including the destructive confirmation that names what will be changed. Done when: every dialog the plan calls for exists in the library and no tool defines its own.
- [ ] Verify the new controls at 100, 125, 150, and 200 percent, and in both appearances. Done when: all four scalings and both appearances are captured with nothing clipped.
- [ ] Extend the Lucide icon set as the new controls require, keeping application icons out of it. Done when: every glyph a control needs resolves, and application icons remain per-tool Rizonesoft assets.
- [ ] Hold the new controls to the existing UX standard. Done when: `TODO-ux.md` is named as the standard and each new control's animation and focus behavior is checked against it.
- [ ] Commit: `"framework: extend the ui library for the repair tools"`

**Test checkpoint:** The result list renders a mixed fixture set with reconciling counts. Both progress modes render and stay responsive. Every dialog the plan calls for exists in the library, proven by search showing no tool-side dialog. All new controls captured at four scalings and in both appearances. Captures committed under `docs/captures/runs/`.

## 9. Standalone Proof in an Empty Folder

Every tool is distributed on its own. This section proves the framework did not quietly introduce a dependency on a suite install, which is the failure that would otherwise surface only after shipping.

**Fidelity:** no surface of its own; this section re-drives the surfaces from §7 in a different environment.
**Needs:** Windows host (build/test)

- [ ] Define the standalone layout: exactly what files a single tool ships with and where it finds each. Done when: the layout is documented and reconciled against the `Doors/` convention used by Complete Windows Repair. Cheaper substitute: assuming the suite layout and discovering the gap at release.
  -> XREF: D07 T01 §1 -- the conformance profile, which states standalone-ness as BEHAVIOUR and deliberately names no paths, waiting on this item for the layout

  **This item owns a decision another section was told to wait for, recorded 2026-09-17 when `D07 T01 §1` shipped.** The brainstorm record says the layout "needs reconciling before the conformance profile is written". The profile was written anyway, by stating the requirement as behaviour: a tool alone in an empty directory starts, localizes, shows About, and checks for updates. That clause is true under the shipped suite's `Language/<Tool>/` plus shared `Logging/` and `Docs/<Tool>/` root **and** under Complete Windows Repair's one-folder `Doors/` convention, so this item is free to choose either without invalidating the profile. What the profile therefore cannot check is whether a tool put its files in the **agreed** place, only that it needs nothing outside its folder. Closing that gap is this item's, and `D07 T01 §3` turns the chosen layout into a check.
- [ ] Place one built tool alone in an empty directory with only its own files and start it. Done when: it starts, localizes, shows About, opens preferences, and checks for updates, all captured.
- [ ] Prove it writes its settings and its log in that directory and nowhere else. Done when: a file-system trace shows no write outside the tool's own folder, quoted.
- [ ] Prove no shared root is required. Done when: the tool runs on a machine with no `Resolute/` directory anywhere.
- [ ] Add the standalone check to the harness so a later change cannot silently break it. Done when: the assertion runs and fails if a framework surface reaches outside the tool folder.
- [ ] Commit: `"framework: prove a tool runs standalone in an empty folder"`

**Test checkpoint:** A built tool alone in an empty directory starts, localizes, shows About, opens preferences, and checks for updates, all captured. A file-system trace shows no write outside its own folder. The machine has no `Resolute/` directory during the run. The harness assertion fails when a surface reaches outside. All quoted.

## 10. Crash Handling and Single Instance

Two lifecycle guarantees the plan assumed and never assigned. Both matter more here than in ordinary software, because these tools are running on a machine that is **already broken** and several of them are mid-way through changing a registry or an ACL when something goes wrong.

**Fidelity:** the crash notice, reusing the framework's message dialog. No new dialog.
**Job:** a tool that fails does so visibly and recoverably, and a user cannot accidentally run two copies of a tool that is changing their system. Consumer: the crash report on disk, and the second instance that does not start.
**Treatment:** the restore record flushed before the process dies, so an interrupted repair is still undoable. Cheaper substitute that fails the checkpoint: a crash handler that writes a report and exits, leaving a half-applied repair with no record of what was already done.
**Chrome:** consume the framework's logging, message layer, and the repair contract's restore record.
**Needs:** Windows host (build/test)

- [ ] Install an unhandled-exception and structured-exception handler in the framework startup, so every tool gets one. Done when: a deliberately faulted fixture tool produces a report rather than the Windows crash dialog, and no tool installs its own handler, proven by search.
- [ ] Write a crash report naming the tool, its version, the action in progress, and the fault. Done when: a faulted run writes one to the log directory and its path is shown to the user.
- [ ] **Flush the repair contract's restore record before the process dies.** Done when: a tool faulted mid-repair still leaves a record covering what it had already changed, and `Repair History` can undo it, proven by driving `D05 T04 §2` against the wreckage.
- [ ] Say something useful to the user rather than nothing. Done when: the notice names the tool, states whether the machine was changed, and points at the report, captured.
- [ ] Enforce a single instance per tool, keyed by tool and by installation. Done when: launching a second copy focuses the first rather than starting, proven by driving it twice.
- [ ] Decide and record the portable exception. Done when: this section states whether a portable copy on a USB stick may run alongside an installed copy, dated, with the cost of changing it. Cheaper substitute that fails the checkpoint: a global mutex that silently blocks a technician's portable copy because the machine has the suite installed.
- [ ] Prove the guard holds where it matters. Done when: two copies of a repair tool cannot run a repair simultaneously against the same target, asserted.
- [ ] Commit: `"framework: crash handling and single instance"`

**Test checkpoint:** A deliberately faulted fixture tool produces a report, not the Windows crash dialog, and no tool installs its own handler, proven by search. A tool faulted mid-repair leaves a usable restore record, proven by undoing it from `Repair History`. The notice names the tool and whether the machine changed, captured. A second launch focuses the first. Two copies cannot repair the same target simultaneously, asserted.

## 11. Command Line and Exit Codes

Every tool in this suite is something an IT administrator would want to run across fifty machines from a script, and today the plan gives them no way to. A repair tool that can only be driven by a human is half a product for that audience.

**Fidelity:** no surface of its own; the command line is the surface, and `--help` is its documentation.
**Job:** an administrator can run any tool unattended, capture what it did, and branch on whether it worked. Consumer: the exit code, the log, and the transcript.
**Treatment:** one argument grammar across every tool, defined in the framework, so learning one tool teaches all of them. Cheaper substitute that fails the checkpoint: per-tool argument parsing, which is the settings-path defect in a new place.
**Chrome:** consume the framework's logging and the repair contract's transcript. No tool parses its own arguments.
**Needs:** C++ toolchain (compile)

- [ ] Define the shared grammar in the framework: the verbs every tool understands, and the options every tool accepts. Done when: the grammar is documented, and a tool adds its own verbs without touching the parser.
- [ ] Support unattended operation. Done when: a tool runs its main action with no window and no prompt, writes its transcript to a given path, and returns, proven by driving a fixture repair from a script.
- [ ] **Define the exit codes once**, so a script can branch. Done when: success, nothing-to-do, partial, refused-for-privilege, and failed are distinct documented values, and a fixture run of each returns the expected one.
- [ ] Never perform a destructive action unattended without an explicit flag. Done when: an unattended destructive run without the flag refuses and returns the refusal code, and the flag's name states what it authorises.
- [ ] Implement `--help` and `--version` for every tool, generated from the tool descriptor and the registered verbs. Done when: both work on two different tools with no tool-side code.
- [ ] Honour the elevation contract on the command line. Done when: an unattended run without the required privilege refuses by name, returns the refusal code, and changes nothing.
- [ ] Record what the command line deliberately cannot do. Done when: anything reachable only through the window is listed, so an administrator is not left guessing.
- [ ] Commit: `"framework: one command-line grammar and one set of exit codes"`

**Test checkpoint:** A fixture repair runs unattended from a script with no window, writes its transcript, and returns. Each of the five exit codes is produced by a fixture run and matches its documented value. An unattended destructive run without the authorising flag refuses with the refusal code. `--help` and `--version` work on two tools with no tool-side code. An unelevated unattended run refuses by name and changes nothing.

## 12. About Dialog, From the Registry

The suite gets one traditional modal About dialog, Help menu > About, owned by the framework and rendered from the `D06 T01 §10` identity registry: no per-tool copy, no pasted string, no settings sidebar panel. Operator-confirmed 2026-09-19: the logo renders at 80px, and every tool window plus the launcher shell gains a Help menu entry. The tool descriptor selects which registry entry a tool shows; the registry holds every string the dialog draws.

**Fidelity:** the modal dialog, centered with its rows, against `docs/captures/house-style/`. Layout and terminology match the captures; DPI and theme are the approved deviations.
**Job:** a user opens Help > About and learns exactly what they run, who publishes it, and where to go next. Consumer: the dialog rows, each traced to the registry.
**Treatment:** one dialog implementation in the framework, parameterized by registry entry. Cheaper substitute that fails the checkpoint: a settings sidebar panel instead of a modal, or a per-tool About copy, which is how fourteen dialogs drifted apart.
**Chrome:** consume the framework's own controls, theme, and localization loader. No tool draws its own row.
**Needs:** C++ toolchain (compile)

- [ ] Build the modal shell: centered on the parent, OK button with Enter accepting and Esc cancelling, single instance with re-invoking focusing instead of stacking. Done when: a double open shows one dialog focused, and Enter and Esc are each driven and quoted.
- [ ] Render every row from the registry: app logo at 80px from the `resources/logos/` theme pair linked to `https://rizonesoft.com`, app name, version with channel where applicable, the verbatim copyright line, publisher `Rizonetech (Pty) Ltd.`, clickable project/corporate/social links with brand icons, the `GPL-3.0-or-later` line linking the full license text, third-party notices link. Done when: a UI drive proves every row from registry values with launcher URIs matched and the launcher seam mocked.
- [ ] Render light and dark themes with the theme-correct assets. Done when: both themes are driven and the logo and icons match the declared theme assets.
- [ ] Keep the dialog keyboard navigable with screen-reader names on links and buttons. Done when: the tab order runs end to end by drive, and every link and button exposes its asserted name.
- [ ] Add Help menu entries everywhere: the launcher shell and every tool window. Done when: the launcher entry opens the dialog, and the framework harness opens it for two tool descriptors with no tool-side code.
- [ ] Compare golden captures for both themes. Done when: captures are committed and the comparison passes with differences listed.
- [ ] Write the user-guide page for the dialog in the same commit as the implementation. Done when: the page exists, describes every row, and shares the implementation commit.
- [ ] Commit: `"framework: about dialog from the identity registry"`

**Test checkpoint:** One dialog focuses on double open; Enter and Esc quoted. Every row traces to the registry with URIs matched. Both themes render their declared assets. Tab order and screen-reader names asserted by drive. Launcher entry plus two harness descriptors open it with no tool-side code. Golden captures pass for both themes. The user-guide page shares the implementation commit. Cheaper substitute that fails the checkpoint: a sidebar panel instead of a modal, which the operator explicitly rejected.

-> XREF: D06 T01 §10 -- the identity registry this dialog renders
-> XREF: D01 T01 §7 -- the UI surfaces this dialog builds on

## 13. F1 Context Help

F1 opens context help: the guide page for the focused surface through the `D06 T01 §14` map, help-home for unmapped surfaces and no-focus. F1 is unbound today (no `VK_F1` handler and no URL launcher anywhere in `src/` or the UI library), and the AutoIt suite has no F1 help either, so this section is a deliberate addition fenced as new behavior: it changes no cloned surface, it adds a key the originals never had. Operator-confirmed 2026-09-19: a Help menu entry ships alongside F1, matching the §12 About pattern of one framework entry in the launcher shell and every tool window.

**Fidelity:** no surface of its own; the default browser showing the guide page is the surface, rendered from §14 HTML.
**Job:** a user stuck on any surface presses F1 and lands on the page that explains it. Consumer: the focused surface, resolved through the map.
**Treatment:** window-level F1 through the map, opened in the default browser with local fallback, plus a Help menu entry on every window. Cheaper substitute that fails the checkpoint: a Help menu entry alone with no F1 binding, which leaves keyboard users with no path to the page they stand on.
**Chrome Needs:** a Help menu entry per window, following the §12 entries; no other visible control.

- [ ] Route window-level F1 through the surface map. Done when: F1 on a mapped surface opens its guide page, F1 on an unmapped surface or with no focus opens help-home, quoted by drive.
- [ ] Invoke the default browser with local fallback. Done when: the first real URL launcher seam ships here (the §12 drive mocks it), web-unreachable falls back to the local pages, and no tool carries its own launcher. Cheaper substitute that fails the checkpoint: shelling the URL from each window, which is how fourteen launchers drift apart.
- [ ] Add the Help menu entry alongside F1. Done when: the launcher shell and every tool window carry it, and each entry opens help-home, quoted by drive with no tool-side code.
- [ ] Write the guide page documenting the behavior in the same commit as the implementation. Done when: the page exists under the `D08 T01 §1` same-commit rule, documents F1 plus the fallback, and shares the implementation commit.
- [ ] Commit: `"framework: F1 context help through the surface map"`

**Test checkpoint:** F1 opens the mapped page and help-home covers unmapped and no-focus; every window's Help entry opens help-home with no tool-side code; the launcher falls back offline; the guide page shares the implementation commit. Cheaper substitute that fails the checkpoint: testing F1 by hand on one window, which proves nothing about the map default.

-> XREF: D06 T01 §14 -- the pipeline and map this behavior reads

## Verification

- [ ] `pwsh scripts/check-all.ps1` exits 0 with the framework suites reporting
- [ ] All 35 Firemin language packs load through the framework loader
- [ ] Framework surfaces captured at four DPI scalings and in both appearances
- [ ] A tool runs standalone in an empty folder, writing nothing outside it
- [ ] No tool-side code computes a settings path, a log path, a language path, or parses its own arguments
- [ ] A tool faulted mid-repair still leaves a restore record that `Repair History` can undo
- [ ] Every tool runs unattended and returns a documented exit code
- [ ] `python scripts/todo-graph.py validate` clean
