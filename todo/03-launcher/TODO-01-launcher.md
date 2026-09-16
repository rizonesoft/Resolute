---
schema_version: 1
id: launcher
domain: 03-launcher
status: draft
title: "TODO-01 -- Resolute Launcher"
depends_on: [framework-core]
track: P1
---

# TODO-01 -- Resolute Launcher

> **Goal:** The hub that finds every installed tool, launches it, reports honestly when it cannot, and gives the suite one place for settings, logs, and the Windows system locations a power user wants.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** Nothing exists in C++. The AutoIt launcher is `resolute_au3/SDK/Concrete/Resolute/Resolute.au3` at 2,663 lines, version 23.2.0.858, which is the only tool whose version is in the 23 series. It writes its settings to `Resolute.lng` (`Resolute.au3:435,1889`), the same language-pack extension defect six other tools have. It ships exactly one language pack, English, against `ComIntRep`'s sixteen and `Firemin`'s thirty-five. Its menu strings are not localized. `WinPower`, whose shell-location features belong here, is at `resolute_au3/samples/WinPower 0.0.3.325922/` and the 151-entry CLSID catalog that feeds them is in git history at `8d7469a^`.

## Inputs

- [`resolute_au3/SDK/Concrete/Resolute/Resolute.au3`](../../resolute_au3/SDK/Concrete/Resolute/Resolute.au3) -- the launcher being ported
- [`resolute_au3/samples/WinPower 0.0.3.325922/`](../../resolute_au3/samples) -- the shell-location features being imported; `Resolute` is WinPower's replacement
- -> XREF: [`01-framework/TODO-01 §1`](../01-framework/TODO-01-framework-core.md) -- the framework this launcher is the first product consumer of
- -> XREF: [`04-tools-port/TODO-01 §1`](../04-tools-port/TODO-01-tool-ports.md) -- the tools this launcher discovers and starts
- -> XREF: [`05-new-tools/TODO-06 §1`](../05-new-tools/TODO-06-system-inspection.md) -- the inspection tools, which take the suite past the point where a list is browsable
- -> XREF: [`05-new-tools/TODO-07 §1`](../05-new-tools/TODO-07-system-control.md) -- the configuration tools, routed by the same symptom search

## Outcome

- Every installed tool is found, listed, and launchable, and a missing one is reported by name.
- The launcher's own settings live in an `.ini` through the framework writer, and an existing `.lng` is migrated.
- Every menu item and every surface string is localized.
- A user can reach the Windows system locations a repair session needs without hunting.
- A launch that fails says why.
- A user who can describe their problem reaches the right tool without knowing its name.

**Adjacency:** list=applicable @ D03 T01 §2; document=not-applicable (the launcher produces no document a user carries; the tools do); settings=applicable @ D03 T01 §1; reporting=applicable @ D03 T01 §3; notifications=applicable @ D03 T01 §3; permissions=applicable @ D03 T01 §3; audit=applicable @ D03 T01 §3; exchange=not-applicable (nothing is imported or exported here); reverse=not-applicable (launching a tool changes nothing that needs undoing)

**Adjacency rationale:** List anchors on §2 because tool discovery is the launcher's whole record surface: the list of what is installed is the thing a user browses. Reporting, notifications, permissions, and audit converge on §3 because they are one behavior seen from four sides: a launch that fails, for a reason that may be a missing file or a declined elevation, must say so, and say so once, in the log and on the surface.

## Implementation Order

| Order | Section | Deliverable                               | Depends On   | Status |
| :---: | :-----: | ----------------------------------------- | ------------ | :----: |
|   1   |   §1    | Launcher on the framework                 | D01 T01 §1   |  [ ]   |
|   2   |   §2    | Tool discovery and the tool list          | §1           |  [ ]   |
|   3   |   §3    | Launch, failure reporting, and elevation  | §2           |  [ ]   |
|   4   |   §4    | Windows system locations                  | §2           |  [ ]   |
|   5   |   §5    | Suite log viewer                          | §1           |  [ ]   |
|   6   |   §6    | Symptom routing                           | §2, D01 T01 §4 |  [ ]   |

---

## 1. Launcher on the Framework

The launcher is the first product built on the framework, so it is where the framework's seam is proven against something real rather than a fixture.

**Fidelity:** the launcher main window, against `docs/captures/house-style/` and a pre-change capture of the shipped 23.2 build.
**Job:** a user opens one place and reaches every tool they have installed. Consumer: the rendered hub, and the launch path in §3.
**Treatment:** the launcher is framework plus its own logic, with nothing shared reimplemented. Cheaper substitute that fails the checkpoint: porting the AutoIt launcher's 2,663 lines wholesale, which carries a fifteenth copy of the framework into the new tree.
**Chrome:** consume the framework's standard window, settings writer, logging, and localization loader.
**Needs:** C++ toolchain (compile)

- [ ] Capture the shipped launcher first: a driven run of the current `Resolute.exe` with its window and menu recorded. Done when: the capture is committed as the comparison baseline.
- [ ] Build the launcher as framework plus its own logic, with no private settings writer, log writer, or localization loader. Done when: its source contains none of those and the file is a fraction of the AutoIt 2,663 lines.
- [ ] Migrate an existing `Resolute.lng` settings file to `Resolute.ini` on first start. Done when: a fixture `.lng` migrates with its log line and every value survives.
- [ ] Localize every menu item and surface string, none hardcoded. Done when: driving with a deliberately incomplete pack lists every key and none renders as bare English.
- [ ] Account for the surface: every control and menu item is working or deferred to a named section. Done when: the account is written and each deferral resolves.
- [ ] Commit: `"launcher: rebuild on the shared framework"`

**Test checkpoint:** The launcher builds for both architectures. A fixture `Resolute.lng` migrates to `.ini` with every value surviving, quoted. An incomplete pack produces a missing-key list with no bare English. The rendered window is compared against the pre-change capture with differences listed.

## 2. Tool Discovery and the Tool List

A launcher that lists tools it cannot start, or omits tools that are there, is worse than no launcher. Discovery has to be honest about what it found.

**Fidelity:** the tool list, against `docs/captures/house-style/`.
**Job:** a user sees what is installed and can start any of it. Consumer: the rendered list, and the launch path in §3.
**Treatment:** discovery probes for the executable and reports what is missing, rather than rendering a fixed list. Cheaper substitute that fails the checkpoint: a hardcoded list of fourteen tools, which is how a launcher comes to offer a tool that was never installed.
**Chrome:** consume the framework's standard window and list surface.
**Needs:** C++ toolchain (compile)

- [ ] Discover installed tools by probing for each known tool's executable, recording found and not-found. Done when: removing one tool's executable moves it to not-found rather than removing it silently.
- [ ] Render the list with each tool's name, version, and state. Done when: version is read from the executable rather than from a table, proven by changing one.
- [ ] Handle the consolidations: a retired product that is still installed is shown with its successor. Done when: a fixture install of a retired tool renders the successor relationship.
- [ ] Make the list findable: filter by name so a user with twenty tools can reach one. Done when: a driven filter narrows the list and clearing it restores the full list.
- [ ] Commit: `"launcher: discover installed tools and report what is missing"`

**Test checkpoint:** Removing a tool's executable moves it to not-found. Versions are read from the executables, proven by changing one. A retired product renders its successor. The filter narrows and restores. The list is captured under `docs/captures/runs/`.

## 3. Launch, Failure Reporting, and Elevation

The launcher starts tools that need administrator rights. What it does when that is declined is the whole of this section, and the AutoIt launcher does not handle it.

**Fidelity:** the failure notice, reusing the framework's message dialog. No new dialog.
**Job:** a user whose tool did not start is told why, in terms that suggest what to do. Consumer: the notice on screen, and one log line.
**Treatment:** each failure cause carries its own named message, and a declined elevation is an outcome rather than an error. Cheaper substitute that fails the checkpoint: one generic "could not start" message covering every cause.
**Chrome:** consume the framework's message layer and logging.
**Needs:** Windows host (build/test)

- [ ] Launch a tool and report a failed launch by name and reason. Done when: a corrupted executable, a missing file, and a declined elevation each produce their own named message.
- [ ] Handle declined elevation as a first-class outcome, not an error. Done when: declining the prompt returns the user to the launcher with a stated message and one log line, and nothing is left running.
- [ ] Log every launch and every launch failure. Done when: each produces exactly one line naming the tool.
- [ ] Do not block the launcher while a tool runs. Done when: launching two tools in succession works and the launcher stays responsive, captured.
- [ ] Commit: `"launcher: launch tools and report failure honestly"`

**Test checkpoint:** Corrupted executable, missing file, and declined elevation each produce their own named message and exactly one log line. Declining elevation leaves nothing running. Two tools launch in succession with the launcher responsive, captured.

## 4. Windows System Locations

The importable half of `WinPower`. A repair session constantly needs Device Manager, Control Panel items, and the all-tasks view, and hunting for them through a redesigned Settings app is a real cost.

**Fidelity:** new surface, no baseline in the C++ suite; match the framework's list surface.
**Job:** a user can reach a Windows system location without knowing its CLSID or its current Settings path. Consumer: the launched shell location.
**Treatment:** a curated, named catalog with each entry verified to open on the supported Windows versions. Cheaper substitute that fails the checkpoint: shipping all 151 CLSIDs unfiltered, including the ones that do nothing on a supported Windows.
**Chrome:** consume the framework's list surface and message layer.
**Needs:** Windows host (build/test)

- [ ] Restore the CLSID catalog from git history at `8d7469a^` and record which of its 151 entries are worth shipping. Done when: the kept set is listed here with a reason for the cuts.
- [ ] Verify every kept entry opens on the minimum supported Windows and on current Windows. Done when: each is driven on both and the results are recorded; entries that fail either are cut or marked.
- [ ] Render the catalog as a searchable list with localized display names. Done when: a driven search narrows it and every name resolves from a pack.
- [ ] Report a location that will not open rather than failing silently. Done when: a deliberately broken entry produces a named message and one log line.
- [ ] Decide whether Resolute **hosts** Control Panel applets, as opposed to opening them. **Filed 2026-09-17 by `D00 T03 §4`, which found it uncovered while superseding `TODO.md`:** that file devotes three phases and 51 mentions to CPL interop, a CPL loader, and applet execution, and the Resolute plan contains **zero** references to `.cpl` anywhere. The items above open a Control Panel item by CLSID through the shell, which is a different thing: hosting means loading a `.cpl` DLL into the launcher's own process and calling `CPlApplet`. Done when: the decision is dated and states whether hosting is wanted. If it is not, say why, because the reason is the valuable part: a `.cpl` is an arbitrary third-party DLL, loading it in-process puts its faults and its lifetime inside the launcher, and the launcher runs elevated. If it is wanted, it gets its own TODO file rather than items here. Cheaper substitute that fails the checkpoint: leaving it undecided, which is what quietly discarded it once already.
- [ ] Commit: `"launcher: windows system locations from the winpower catalog"`

**Test checkpoint:** The kept catalog set is listed with reasons for the cuts. Every kept entry is driven on the minimum supported Windows and on current Windows, with results recorded. Search narrows the list. A broken entry produces a named message and one log line. The surface is captured.

## 5. Suite Log Viewer

Fourteen tools write logs. One place to read them is the difference between a support conversation that takes five minutes and one that takes an hour.

**Fidelity:** the log viewer, against `docs/captures/house-style/`.
**Job:** a user or support reader can read every tool's log in one place, filtered to the question they are asking. Consumer: the log files on disk, and the exported view.
**Treatment:** the viewer reads the shared log format, so a new tool appears without the viewer changing. Cheaper substitute that fails the checkpoint: a per-tool parser, which makes the viewer a second place every new tool must be registered.
**Chrome:** consume the framework's standard window and list surface.
**Needs:** C++ toolchain (compile)

- [ ] Read and render logs from every installed tool through the framework's log format. Done when: logs from three different tools render in one view.
- [ ] Filter by tool, by severity, and by date. Done when: each filter narrows and clearing restores.
- [ ] Handle a missing, empty, or malformed log without failing. Done when: all three are driven and each produces a stated result rather than an error.
- [ ] Let a user export the filtered view. Done when: the export is written atomically, read back, and matches what is rendered.
- [ ] Commit: `"launcher: one viewer for every tool's log"`

**Test checkpoint:** Logs from three tools render in one view. Each filter narrows and restores. Missing, empty, and malformed logs each produce a stated result. An export matches the rendered view, quoted.

## 6. Symptom Routing

Fifty tools is past the point where anyone browses a list. The question a user actually arrives with is never "which tool?", it is **"my machine does X"**, and an alphabetical grid answers the wrong question.

This is what makes fifty tools feel like one product rather than a directory, and it is cheap because tool discovery already exists.

**Fidelity:** the search and results surface, against `DESIGN.md` and `docs/captures/house-style/`.
**Job:** a user who can describe their problem in their own words reaches the right tool without knowing its name. Consumer: the launched tool, and the search result that led there.
**Treatment:** symptoms declared by each tool alongside its descriptor, so a new tool arrives searchable. Cheaper substitute that fails the checkpoint: a keyword table maintained in the launcher, which goes stale the day a tool is added and nobody remembers it exists.
**Chrome:** consume the framework and the shared list surface, and the tool discovery from `§2`.
**Needs:** C++ toolchain (compile)

- [ ] Extend the tool descriptor so each tool declares the symptoms it addresses, in `src/framework/ToolDescriptor.h`. Done when: a tool declares its symptoms beside its name and version, and adding a tool makes it searchable with no launcher change.
- [ ] Match on plain words rather than exact terms. Done when: "no sound", "sound not working", and "audio broken" all reach the same tool, driven and quoted.
- [ ] Localize the symptoms, because a user searches in their own language. Done when: symptom strings resolve from the language pack and a search in a second language reaches the same tool.
- [ ] Rank results so the most likely tool is first. Done when: a symptom matching three tools orders them and this section records what the ordering is based on.
- [ ] Say something useful when nothing matches. Done when: an unmatched search offers the diagnostic tools that narrow a problem rather than rendering an empty list.
- [ ] Route a symptom to a repair **item** where no whole tool owns it. Done when: "printer not working" reaches the Complete Windows Repair item rather than failing, since most repairs are items rather than products.
- [ ] Account for the surface. Done when: every control is working or deferred to a named section.
- [ ] Commit: `"launcher: route a symptom to the tool that fixes it"`

**Test checkpoint:** Three phrasings of one symptom reach the same tool, all driven and quoted. A newly added fixture tool is searchable with no launcher change. A search in a second language reaches the same tool. A symptom matching three tools is ordered by the recorded rule. An unmatched search offers the diagnostics. "Printer not working" reaches a Complete Windows Repair item.

## Verification

- [ ] `pwsh scripts/check-all.ps1` exits 0 with the launcher suites reporting
- [ ] The launcher runs standalone with no other tool installed
- [ ] Every menu item and surface string resolves from a language pack
- [ ] A declined elevation leaves nothing running and writes one log line
- [ ] `python scripts/todo-graph.py validate` clean
