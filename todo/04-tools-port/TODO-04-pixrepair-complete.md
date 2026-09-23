---
schema_version: 1
id: pixrepair-complete
domain: 04-tools-port
status: draft
title: "TODO-04 -- PixRepair: Complete Port and Enhancement"
depends_on: []
track: P2
---

# TODO-04 -- PixRepair: Complete Port and Enhancement

> **Goal:** PixRepair ships as a complete, distribution-ready C++ tool: the dead-pixel locator and the 7-mode exercise engine reproduced exactly, every surface and string accounted for, distribution-complete, plus fenced enhancements that make it the best pixel tool on Windows. The build and parity proof stay in `D04 T01 §2`; this file specifies, completes, and enhances without touching the frozen effect.

> [!IMPORTANT]
> **Current state:** Nothing exists in C++. The AutoIt tool is `resolute_au3/SDK/Concrete/PixRepair/PixRepair.au3` (1,897 lines, 58 functions, 19 net of the framework copy): an 8-color fullscreen locator with arrow-key cycling, a 7-mode color-cycle exercise engine on a 100x100 topmost window with F11 fullscreen and a 100-1000ms speed slider, a warning label linking to the epilepsy page, a YouTube video link, and two language packs (`en`, `ko`). PixRepair is frozen, and its frozen effect is unusual: not registry or files (it writes none) but the exact color sequences and timing it displays. The driven run and hands-on competitor use below could not be done from this host and are owed at build, owned by `D04 T01 §2`'s capture item and the enhancement sections' first items respectively.

<!-- claim: lines resolute_au3/SDK/Concrete/PixRepair/PixRepair.au3 = 1897 -->
<!-- claim: count "^Func " resolute_au3/SDK/Concrete/PixRepair/PixRepair.au3 = 58 -->
<!-- claim: exists resolute_au3/Resolute/Language/PixRepair/en.lng -->
<!-- claim: exists resolute_au3/Resolute/Language/PixRepair/ko.lng -->

## Inputs

- [`resolute_au3/SDK/Concrete/PixRepair/PixRepair.au3`](../../resolute_au3/SDK/Concrete/PixRepair/PixRepair.au3) -- the tool being inventoried and completed
- [`resolute_au3/SDK/Concrete/PixRepair/PixRepair.sni`](../../resolute_au3/SDK/Concrete/PixRepair/PixRepair.sni) -- the build descriptor: what ships with it
- [`resolute_au3/Resolute/Language/PixRepair/en.lng`](../../resolute_au3/Resolute/Language/PixRepair/en.lng) -- the English pack (UTF-16); `[Custom]` carries the tool's strings
- -> XREF: D04 T01 §2 -- the build this file specifies for

## Outcome

- The locator cycle, all 7 exercise sequences, and the timing rule are pinned as the frozen effect with source lines.
- Every PixRepair window, control, string, setting, and shipped file is inventoried with `file:line` and mapped to framework, repair contract, or tool code.
- The tool ships distribution-complete: migrated settings, both packs, docs, icon, installer and update entries, About, F1, guide page, tests, and a green conformance check.
- Three fenced enhancements ship (display corrections, draggable targeted window, session timer), each proven non-interfering by a re-run parity check.
- The frozen sequences and timing are identical, and no enhancement changes a displayed color or interval.

**Adjacency:** list=not-applicable (the tool shows colors, not records; nothing here is browsed); document=applicable @ D04 T04 §3; settings=applicable @ D04 T04 §3; reporting=applicable @ D04 T04 §6; notifications=not-applicable (the tool reports on its surface; completion is a timer, not a notification); permissions=not-applicable (no privilege, no role model; the tool displays pixels); audit=not-applicable (a color sequence leaves no audit trail beyond the log); exchange=not-applicable (nothing is imported or exported here); reverse=not-applicable (displaying colors changes nothing that needs undoing)

**Adjacency rationale:** Almost the whole line stays not-applicable, and that is the point: PixRepair is the one frozen tool whose effect is display rather than system state, so list, permissions, audit, exchange, and reverse have nothing to anchor to. Document and settings pair on §3 as what distribution-complete means. Reporting anchors on §6 where the session timer reports elapsed and remaining. Silence anywhere else would read as oversight; it is the shape of the tool.

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | Sequence and timing inventory | -- |  [ ]   |
|   2   |   §2    | Surface inventory with shared-layer map | -- |  [ ]   |
|   3   |   §3    | Distribution completeness | D04 T01 §2 |  [ ]   |
|   4   |   §4    | Display corrections | D04 T01 §2 |  [ ]   |
|   5   |   §5    | Draggable targeted window | D04 T01 §2 |  [ ]   |
|   6   |   §6    | Session timer with auto-stop | D04 T01 §2 |  [ ]   |

---

## 1. Sequence and Timing Inventory

The frozen effect, pinned. The locator (`_DeadPixelLocatorScreen`, `PixRepair.au3:879-976`): fullscreen topmost popup cycling white, black, red, green, blue, yellow, magenta, cyan forward on Right and backward on Left through hidden Back/Next buttons, close to exit. The exercise engine (`_Go`, `:822-875`): 7 modes with exact color lists (mode 1 RGB; 2 RGBYMC six; 3 YMC; 4 white/black; 5 white/black/RGB; 6 white/black/YMC; 7 all eight), shown on a 100x100 topmost window starting at 100,100, advancing one color per slider interval, close to exit, F11 toggling fullscreen (`_FullScreenMode`, `:807-820`). The timing rule: slider 1-10 default 2, one step per slider × 100ms (`:856`, caption `:799`), so 100-1000ms defaulting to 200ms.

**Fidelity:** no surface of its own; this section is the record parity is measured against.
**Needs:** C++ toolchain (compile)

- [ ] Pin the locator cycle: the 8 colors in order both directions with line numbers, the hidden buttons and accelerators, the close-to-exit rule, and the Esc behavior verified by drive at build (the label promises Esc exits; `:904-970` handles close, Next, and Back only, so the drive decides whether Esc already exits or §4 must make it so). Done when: the cycle is quoted and the Esc verdict is recorded from the drive, not assumed.
- [ ] Pin the 7 exercise sequences verbatim with line numbers, the start position and size, the fullscreen toggle behavior, and the timing rule with its range and default. Done when: every list, the geometry, and the 100-1000ms rule are quoted.
- [ ] Record the preview mismatch as a display bug: the mode-2 radio preview (`:620`) shows 5 swatches (RGBYM) while mode 2 cycles 6 (RGBYMC, `:838`). Done when: the mismatch is quoted both sides and §4 owns the fix; the frozen effect is the 6-color cycle, never the 5-swatch preview.
- [ ] Record the F11 scoping verdict: `HotKeySet("{F11}")` (`:515`) is process-global and fires outside the tool. Done when: the verdict is recorded (app-local F11, fenced correction: a global hotkey escapes the tool's mandate and hijacks other applications) with the FullscreenMode behavior otherwise unchanged.
- [ ] Commit: `"pixrepair: sequence and timing inventory"`

**Test checkpoint:** The 8-color cycle, all 7 sequences, the geometry, and the timing rule are quoted with lines; the Esc verdict comes from a drive; the preview mismatch is quoted both sides; the F11 verdict is recorded. `D04 T01 §2` can state its parity comparison (same colors, same intervals) from this section alone. Cheaper substitute that fails the checkpoint: sequences without the timing rule, which pins what shows but not for how long.

-> XREF: D04 T01 §2 -- the build that proves parity from this inventory

## 2. Surface Inventory With Shared-Layer Map

Every PixRepair window, control, string, setting, and shipped file, with `file:line`, mapped to framework, repair contract, or tool code. The main window (`:525`): locator group with 8 color buttons plus swatch labels (`:591-598`, labels Custom[6-13]) and three numbered step labels (Custom[14-16]), exercise group with 7 radios plus swatch labels (`:627-633`, default radio 1 checked), GO button (Custom[17], `:637`), speed group with slider (`:643-651`) and Faster/Slower labels (Custom[19-20]), status icon plus label (Custom[18]), warning icon plus red clickable warning label (Custom[2], `:653-657`, opens the Wikipedia epilepsy page), YouTube icon plus label (Custom[21], `:659-668`, opens the video URL and names the bit.ly link). File/Help menus standard. Preferences (`:1347`, 450x500, three framework tabs, no tool page). Four windows total: main, prefs, Go form, locator form.

**Fidelity:** no surface of its own; this section is the record the build renders from.
**Needs:** C++ toolchain (compile)

- [ ] Inventory the main window control by control with string sources: all 8 color buttons, all 7 radios with their swatch counts, the GO button, the slider with limits and default, the step labels, the status and warning labels, and the YouTube icon and label with both URLs. Done when: every control names its strings, and the playful texts (Custom[0] necromancer line, Custom[2] dizzying line, F11 "full glam" line) carry keep-or-reword verdicts against `DESIGN.md` §11 with reasons.
- [ ] Inventory the Go form and locator form: sizes, styles, topmost rules, hidden buttons, accelerators, cursor, and exit paths. Done when: every window attribute is recorded and the exit path of each is exact.
- [ ] Inventory settings, logging, and distribution: the framework-only `.ini` keys (no tool-specific key; mode, speed, and session state are unpersisted, kept so for parity), the status-list log lines, the single-instance guard (`:441`), the no-elevation-needed verdict with reason (the tool displays pixels and touches nothing privileged), and the `.sni` ship list (exe pair, ini, three docs, en pack, two `.ani` files cut). Done when: every key and shipped file carries keep, cut, or remapped; note the `ko` pack ships in the language directory but the `.sni` names only `en`, recorded as a ship-list gap §3 closes.
- [ ] Map every inventoried piece to framework, repair contract, or tool code: window, menus, prefs host, log, update, About, crash, singleton, F1 to the framework; nothing to the repair contract (recorded: no diagnose, no system change, no undo; the contract does not apply and forcing it would invent a repair shape around a display); sequences, timing, locator, slider, radios, and links to the tool. Done when: the contract exclusion is stated with reason and no shared piece maps to the tool.
- [ ] Commit: `"pixrepair: surface inventory with shared-layer map"`

**Test checkpoint:** A walk of `PixRepair.au3` finds every control, string, setting, and shipped file recorded with verdict and home; the tone verdicts cite `DESIGN.md` §11; the contract exclusion is stated; the `ko` ship gap is recorded. Cheaper substitute that fails the checkpoint: controls without the tone verdicts, which ports jokes about epilepsy into a medical-adjacent warning.

-> XREF: D04 T01 §2 -- the build that renders from this inventory

## 3. Distribution Completeness

Everything that makes the ported tool shippable: settings migration, both packs, docs, icon, installer and update entries, About, F1, guide page, tests, and conformance. Runs after `D04 T01 §2` proves parity on the core.

**Fidelity:** the tool as shipped: installer entries, docs, and About, against the AutoIt distribution.
**Job:** a user can install, run, update, and remove the tool with nothing missing. Consumer: the installed tool and its docs.
**Treatment:** every AutoIt-shipped artifact has a C++ successor or a recorded cut. Cheaper substitute that fails the checkpoint: a tool that runs from the build tree but was never installed anywhere, which is how missing files ship.
**Chrome:** consume the framework installer entries, About, and help. No tool-side installer logic.
**Needs:** Windows host (build/test)

- [ ] Migrate settings and ship the packs: an existing AutoIt `.ini` migrates its framework keys with a log line; both `en` and `ko` packs ship (closing the §2 ship-list gap) and the pack-hygiene rules from `D08 T01 §3` hold. Done when: a fixture `.ini` migrates and the pack check passes on both, both quoted.
- [ ] Ship the docs set from the three templates: every template renders with generated metadata (no typed version or date) and the set matches the `D08 T01 §1` contract. Done when: all three render and the conformance check agrees.
- [ ] Register installer and update-file entries per `D06 T01 §3` and `D06 T01 §5`: portable and installed modes, the application icon, and the update descriptor. Done when: both modes install and remove cleanly on a fixture machine.
- [ ] Wire About, F1, and the guide page: About from the registry for the PixRepair descriptor, F1 through the surface map, and the user-guide page (carrying the epilepsy warning in full) in the same commit as the behavior it documents. Done when: all three resolve and the guide page shares its commit.
- [ ] Prove tests and conformance: unit tests for the tool-specific logic (sequence tables, timing computation, mode dispatch) run under the harness, and the `D07 T01 §3` check passes for the tool. Done when: `ctest` names the suites green and the conformance report is quoted.
- [ ] Prove first-run and upgrade: a clean machine goes from install to working with no manual step, and a machine carrying the AutoIt PixRepair upgrades with settings preserved and one copy left. Done when: both paths are driven and quoted. Cheaper substitute that fails the checkpoint: testing upgrade by reading the code, which is how two copies ship.
- [ ] Commit: `"pixrepair: distribution completeness"`

**Test checkpoint:** Fixture `.ini` migrates; both packs pass hygiene; three docs render generated; both install modes round-trip; About, F1, and the guide page (warning included) resolve; tests and conformance quote green; first-run and upgrade are driven. Cheaper substitute that fails the checkpoint: a checklist ticked from the build tree, which proves the tool compiles rather than ships.

-> XREF: D04 T01 §2 -- the parity core this section ships

## 4. Display Corrections

**Deliberate new behavior, display only.** Three corrections the inventory fenced: the mode-2 preview shows 6 swatches instead of 5 (matching the frozen cycle), Esc exits the locator if the §1 drive found it broken (the label promises it), and F11 is scoped app-local instead of process-global. No sequence or interval changes.

**Fidelity:** the corrected preview, Esc behavior, and F11 scope; no new surface.
**Job:** what the tool shows matches what it does, and its keys stay inside it. Consumer: the radio preview, the locator exit, and every other application on the machine.
**Treatment:** correct display against effect, never effect against display. Cheaper substitute that fails the checkpoint: "fixing" the cycle to 5 colors to match the preview, which would change the frozen effect to fit a wrong picture.
**Chrome:** consume the existing radio, locator, and hotkey handling. No new control.
**Needs:** Windows host (build/test)

- [ ] Fix the mode-2 preview to 6 swatches and guarantee Esc exits the locator. Done when: the preview shows all six cycle colors in order, and Esc exits from every locator color, both quoted by drive.
- [ ] Scope F11 app-local: fullscreen toggles while the tool is focused and no longer fires in other applications. Done when: F11 toggles in-tool and is inert outside it, both quoted by drive.
- [ ] Cover the finer details: keyboard reachability with tab order, screen-reader names on the radios and buttons, both themes, and the exact texts with pack keys. Done when: each is driven or captured, none deferred.
- [ ] Prove non-interference: the `D04 T01 §2` parity check (same colors, same intervals) re-runs clean with this section shipped. Done when: the comparison is quoted showing no difference.
- [ ] Commit: `"pixrepair: display corrections"`

**Test checkpoint:** Six swatches in cycle order; Esc exits from every color; F11 toggles inside and stays inert outside; finer details driven or captured; the parity comparison re-runs clean. Cheaper substitute that fails the checkpoint: corrections without the parity re-run, which trusts that display-only means effect-identical.

-> XREF: D04 T01 §2 -- the parity check this section must not disturb

## 5. Draggable Targeted Window

**Deliberate new behavior.** The AutoIt Go window sits fixed at 100,100 in 100x100; the stuck pixel is rarely there. This section makes the exercise window draggable and resizable so it can be placed over the stuck pixel, following the JScreenFix/UDPixel shape: the same frozen sequences and timing, positioned by the user. Position is display geometry, not effect.

Competitor context (source-based, hands-on owed at build): JScreenFix (web) flashes a movable square over the stuck pixel in ~10-minute cycles ([source](https://www.slashgear.com/1426307/how-to-fix-stuck-dead-pixels-monitor-tv/)); UDPixel offers draggable flash windows with parameters ([source](https://www.redmondpie.com/how-to-fix-dead-pixels-on-your-lcd-monitor/)); UndeadPixel works user-selected zones. All three target an area; none of the three runs the frozen 7-mode sequences. This tool keeps its sequences and gains their targeting.

**Fidelity:** the draggable exercise window, against `DESIGN.md`; moved and sized by the user, colors unchanged.
**Job:** a user parks the exercise over the stuck pixel instead of beside it. Consumer: the positioned window, and the pixel beneath it.
**Treatment:** drag by the window, resize by the edge, fullscreen still available; the cycle never pauses for a move. Cheaper substitute that fails the checkpoint: preset positions, which park near the pixel on exactly one monitor layout.
**Chrome:** consume the framework window dragging. No custom drag code.
**Needs:** Windows host (build/test)

- [ ] Confirm the competitor table hands-on: run JScreenFix and UDPixel, verify the documented behaviors above against the named versions, and correct the table. Done when: each row names the version used and what was observed, quoted.
- [ ] Make the window draggable and resizable across monitors: drag moves, edge resizes down to a stated minimum, fullscreen toggles from any position, and the color cycle and interval never stutter on move or resize. Done when: a driven move-plus-resize across two monitors shows uninterrupted cycling, quoted.
- [ ] Cover the finer details: keyboard move/resize path, screen-reader announcements of position changes, both themes, and the exact texts with pack keys. Done when: each is driven or captured, none deferred.
- [ ] Prove non-interference: the `D04 T01 §2` parity check re-runs clean with this section shipped. Done when: the comparison is quoted showing no difference.
- [ ] Commit: `"pixrepair: draggable targeted window"`

**Test checkpoint:** Competitor rows name used versions; a cross-monitor move-plus-resize cycles uninterrupted; finer details are driven or captured; the parity comparison re-runs clean. Cheaper substitute that fails the checkpoint: dragging that restarts the cycle, which is a new timing bug wearing an enhancement's clothes.

-> XREF: D04 T01 §2 -- the parity check this section must not disturb

## 6. Session Timer With Auto-Stop

**Deliberate new behavior.** The AutoIt engine runs until the window is closed; nothing suggests a duration or stops one. This section adds a session timer (default 10 minutes per the JScreenFix guidance, adjustable, displayed elapsed/remaining) with auto-stop and a completion notice. Timing of the cycle is untouched; only the session ends.

**Fidelity:** the timer display and the completion notice, through the framework message layer; no new dialog.
**Job:** a user runs a bounded session and learns when it finished. Consumer: the timer display and the notice.
**Treatment:** the default follows published guidance; the user can change or disable it; auto-stop always announces. Cheaper substitute that fails the checkpoint: a timer without auto-stop, which displays elapsed time the user must still watch.
**Chrome:** consume the framework message layer for the notice. No new dialog.
**Needs:** Windows host (build/test)

- [ ] Run bounded sessions: the default 10-minute session counts down visibly, auto-stops the cycle, announces completion with one log line, and offers restart; the duration is adjustable including unlimited with the rule stated. Done when: a short fixture session auto-stops and announces, and unlimited runs past the old default, both quoted.
- [ ] Cover the finer details: keyboard path to the duration, screen-reader names and announcements, both themes, and the exact texts with pack keys. Done when: each is driven or captured, none deferred.
- [ ] Prove non-interference: the `D04 T01 §2` parity check re-runs clean with this section shipped. Done when: the comparison is quoted showing no difference.
- [ ] Commit: `"pixrepair: session timer with auto-stop"`

**Test checkpoint:** A short session auto-stops with notice and log line; unlimited passes the old default; finer details are driven or captured; the parity comparison re-runs clean. Cheaper substitute that fails the checkpoint: auto-stop without the notice, which ends the session silently for a user who looked away.

-> XREF: D04 T01 §2 -- the parity check this section must not disturb

## Verification

- [ ] The locator cycle, all 7 sequences, and the timing rule are pinned and reproduced
- [ ] Every PixRepair line is inventoried with its verdict and home
- [ ] The tool installs, runs, updates, and removes with nothing missing
- [ ] All three enhancements ship fenced with quoted non-interference parity re-runs
- [ ] The frozen sequences and timing are identical
- [ ] `python scripts/todo-graph.py validate` clean
