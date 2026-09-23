---
schema_version: 1
id: design-system
domain: 01-framework
status: draft
title: "TODO-02 -- Design System"
depends_on: [framework-core]
track: F1
---

# TODO-02 -- Design System

> **Goal:** Every rule in `DESIGN.md` is true of every surface, and provably so. Tokens cannot be bypassed, the layout adapts, the accessibility floor is met rather than aspired to, and the suite stays fast enough that a system utility does not undermine its own claim to be fixing your machine.

> [!IMPORTANT]
> **Current state (verified 2026-09-16):** `TODO-ux.md` at the repository root is the source for this file. **Groomed 2026-09-23:** text truncation is not wholly absent: `shared/resolute-ui/src/controls/listview.cpp` already trims with a trimming sign, so the truncation work extends it beyond the list view and adds the tooltips. **Repointed 2026-09-17 by `D00 T03 §2`:** it read `samples/ExoSuite/TODO-ux.md`, and the intake landed that file at the root before the operator deleted the checkout: 341 lines, **66 items done and 101 open** (**Groomed 2026-09-23:** `TODO-ux.md` is 348 lines after `D00 T03 §4` touched it, the 66 and 101 counts still hold, and a gitignored, untracked copy of the checkout remains under `samples/ExoSuite/`). What exists is the motion system (shared clock, named easings, sidebar and toolbar animation), the colour system (system accent from DWM, semantic tokens, four elevation levels, scrim, high-contrast detection, 300ms crossfade, Mica backdrop), and the type ramp with DirectWrite rendering modes. What does **not** exist is the entire accessibility section (8 open items, including UI Automation for custom-drawn controls, which is all of them), the spacing grid, responsive layout, content virtualization, custom window chrome, the performance work, and text truncation. `DESIGN.md` at the repository root is the contract this file makes true.

## Inputs

- [`DESIGN.md`](../../DESIGN.md) -- the contract; every section here makes one part of it true
- [`TODO-ux.md`](../../TODO-ux.md) -- the 101 open items this file routes, and the record of what the 66 done items already cover
- -> XREF: [`01-framework/TODO-01 §8`](./TODO-01-framework-core.md) -- the controls added for the repair tools, which are held to this file
- -> XREF: [`00-workspace/TODO-02 §3`](../00-workspace/TODO-02-test-backbone.md) -- the capture store these surfaces are compared against
- -> XREF: [`07-quality/TODO-01 §3`](../07-quality/TODO-01-quality-bar.md) -- the conformance check that enforces this contract per tool

## Outcome

- A colour, size, or spacing literal cannot reach a surface, because the check refuses it.
- Every surface works at four DPI scalings, in both appearances, and at any window size down to the enforced minimum.
- Every feature is reachable by keyboard, and every custom control reports itself to a screen reader.
- Reduced motion stops all motion, and high contrast wins over the palette.
- The suite stays responsive during its own main actions.

**Adjacency:** list=applicable @ D01 T02 §3; document=applicable @ D01 T02 §1; settings=applicable @ D01 T02 §2; reporting=not-applicable (the design system renders other sections' reports and produces none of its own); notifications=applicable @ D01 T02 §4; permissions=not-applicable (no role model in a rendering layer); audit=not-applicable (git history is the audit for a style rule); exchange=not-applicable (nothing is imported or exported here); reverse=not-applicable (a visual change alters nothing on a user's system)

**Adjacency rationale:** Document anchors on §1 because `DESIGN.md` is the artifact this whole file serves, and a contract nobody can check is a contract nobody keeps. Settings anchors on §2 because density, appearance, and remembered window geometry are the design system's own user-facing settings, and they are the ones most likely to be set once and expected to persist forever. Notifications anchors on §4 because taskbar progress and toast are how a tool speaks to a user who is no longer looking at it.

## Implementation Order

| Order | Section | Deliverable                                | Depends On     | Status |
| :---: | :-----: | ------------------------------------------ | -------------- | :----: |
|   1   |   §1    | Tokens made unbypassable                   | D01 T01 §7     |  [ ]   |
|   2   |   §2    | Spacing grid, density, and responsive layout | §1           |  [ ]   |
|   3   |   §3    | Content area: virtualization and scrolling | §2             |  [ ]   |
|   4   |   §4    | Window chrome and shell integration        | §1             |  [ ]   |
|   5   |   §5    | The accessibility floor                    | §2             |  [ ]   |
|   6   |   §6    | Performance floor                          | §3             |  [ ]   |
|   7   |   §7    | Text presentation and machine values       | §1             |  [ ]   |

---

## 1. Tokens Made Unbypassable

A style rule that relies on everyone remembering it is a style rule that decays. The AutoIt suite is the evidence: the settings path was typed out fourteen times and went wrong seven times. This section makes the token the only available path.

**Fidelity:** no surface of its own; this section constrains how every other surface is written.
**Needs:** C++ toolchain (compile)

- [ ] Expose the full `DESIGN.md` token set as named constants: colour, type ramp, weights, and spacing. Done when: every token in the contract's tables resolves, and the set is the single source the theme reads from.
- [ ] Add a check that refuses a colour literal, a font size literal, or a spacing literal in tool or control code. Done when: a deliberate `RGB(` and a deliberate hardcoded size each fail the check by name, and the two diagnostics are quoted. Cheaper substitute: documenting the rule and trusting review, which is what produced fourteen drifting About dialogs.
- [ ] Allow the theme implementation itself to hold the literals, and nothing else. Done when: the check's allowlist is exactly the theme source, named here.
- [ ] Verify the contrast floor in code: 4.5:1 for text, 3:1 for interactive elements and borders, in both themes. Done when: the assertion runs over every token pair the surfaces actually use, and a deliberately failing pair is reported by name.
- [ ] Record any token pair that fails today. Done when: each is either corrected in the palette or listed here with a dated exception and its reason.
- [ ] Commit: `"design: make the token set the only path to a colour or a size"`

**Test checkpoint:** A deliberate colour literal and a deliberate size literal each fail the check by name, both diagnostics quoted. The contrast assertion runs over every token pair in use, in both themes, and a deliberately failing pair is named. Any real failing pair is corrected or carries a dated exception.

## 2. Spacing Grid, Density, and Responsive Layout

Three rules from the contract that are currently unimplemented, and they interact: the grid defines the units, density scales them, and the responsive rules decide what happens when there is not enough room.

**Fidelity:** every framework surface, against `docs/captures/house-style/` and `DESIGN.md`, captured at Compact, Normal, and Spacious.
**Job:** a user with a small window, a large monitor, or a preference for tighter rows gets a layout that still works. Consumer: the rendered surfaces at each density and width.
**Treatment:** the grid enforced by the token check from §1, and density applied through the shared layout rather than per control. Cheaper substitute that fails the checkpoint: a density setting that only changes the list, leaving toolbar and sidebar padding fixed.
**Chrome:** consume the shared layout and the spacing tokens. No control computes its own padding.
**Needs:** Windows host (build/test)

- [ ] Apply the 4px grid across every framework surface. Done when: no spacing value off the grid survives the §1 check.
- [ ] Implement Compact, Normal, and Spacious density, adjusting item heights and padding through the shared layout. Done when: all three render, persist through the settings writer, and are captured.
- [ ] Collapse the sidebar to icon-only below roughly 600px width, and add a manual toggle with animation. Done when: both the automatic and the manual path are driven and captured, and the collapsed state persists.
- [ ] Move toolbar overflow into a menu when the window is too narrow. Done when: narrowing the window moves buttons into the overflow and widening restores them, captured.
- [ ] Enforce a minimum window size. Done when: the window cannot be dragged below it and the value is recorded here.
- [ ] Remember window size and position per monitor, and respect Windows 11 snap zones. Done when: geometry survives a restart on each of two monitors, and a snapped window restores snapped.
- [ ] Commit: `"design: spacing grid, density modes, and responsive layout"`

**Test checkpoint:** No off-grid spacing survives the §1 check. Three densities render, persist, and are captured. Sidebar collapse is driven both automatically and manually. Toolbar overflow moves and restores. Window geometry survives a restart on two monitors. All captured under `docs/captures/runs/`.

## 3. Content Area: Virtualization and Scrolling

A list that renders a thousand rows it cannot show is a defect the user experiences as the whole application being slow.

**Fidelity:** the list and content surfaces, against `DESIGN.md`.
**Job:** a user with a large result set can scroll it smoothly and find what they need. Consumer: the rendered list, and the scroll behaviour.
**Treatment:** only visible rows rendered, with scroll indicators that appear on interaction. Cheaper substitute that fails the checkpoint: rendering everything and relying on the machine being fast, which fails exactly on the slow machines this suite exists to repair.
**Chrome:** extend the shared list control. No tool implements its own virtualized list.
**Needs:** C++ toolchain (compile)

- [ ] Virtualize the list so only visible rows render. Done when: a 10,000-row fixture scrolls smoothly and the render cost is measured, with the figure quoted.
- [ ] Implement smooth scrolling with momentum. Done when: it is driven and captured, and respects reduced motion per §5.
- [ ] Add scroll indicators that fade in on interaction and out when idle. Done when: both transitions are driven and captured.
- [ ] Add sticky headers for grouped content. Done when: a grouped fixture keeps its category header pinned while scrolling, captured.
- [ ] Add a grid view with proper reflow for tile layouts. Done when: resizing reflows the grid and is captured at three widths.
- [ ] Commit: `"design: virtualized content area with smooth scrolling"`

**Test checkpoint:** A 10,000-row fixture scrolls smoothly with the render cost quoted. Smooth scrolling and scroll indicators are driven and captured, and scrolling respects reduced motion. Sticky headers stay pinned. Grid reflow captured at three widths.

## 4. Window Chrome and Shell Integration

The difference between an application that looks like it belongs on Windows 11 and one that looks like it was ported to it.

**Fidelity:** the window frame, against `DESIGN.md` section 8. New surface; no AutoIt baseline, because the AutoIt windows use the system caption.
**Job:** a user sees a window that matches the rest of their desktop, and can see progress without switching to it. Consumer: the rendered frame, and the taskbar.
**Treatment:** a Direct2D caption with correct hit-testing, so the frameless look does not cost the drag, snap, and double-click behaviour users rely on. Cheaper substitute that fails the checkpoint: a custom caption that breaks snap assist or window dragging.
**Chrome:** extend the shared window frame. No tool draws its own caption.
**Needs:** Windows host (build/test)

- [ ] Draw the caption with Direct2D, with theme-matched minimize, maximize, and close. Done when: the frame renders in both appearances and is captured.
- [ ] Hit-test the drag regions correctly. Done when: dragging, double-click to maximize, snap assist, and the system menu all behave as on a standard window, each driven.
- [ ] Apply rounded corners, backdrop material, and a theme-matched border. Done when: all three are applied through `DwmSetWindowAttribute` and captured on Windows 11.
- [ ] Degrade honestly below Windows 11. Done when: the surface is driven on the minimum supported Windows and this section records what is not available there.
- [ ] Add taskbar progress for long operations. Done when: a long fixture operation shows progress on the taskbar and clears when it completes.
- [ ] Decide what other shell integration is worth having. Done when: jump lists, thumbnail toolbars, and badge overlays each carry a dated keep-or-drop decision rather than being silently skipped.
- [ ] Commit: `"design: custom window chrome and shell integration"`

**Test checkpoint:** The custom caption renders in both appearances, captured. Drag, double-click maximize, snap assist, and the system menu each behave as standard, all driven. Corners, backdrop, and border colour applied and captured on Windows 11. Behaviour on the minimum supported Windows recorded. Taskbar progress driven.

## 5. The Accessibility Floor

Every custom-drawn control in this suite reports nothing to a screen reader today, and every control in this suite is custom-drawn. That is the largest single accessibility gap the project has, and it is invisible to anyone not using assistive technology.

> [!IMPORTANT]
> **This section carries a second payoff: it is what makes control-level test driving possible.**
> -> XREF: D00 T02 §3 -- the house-style contract, which binds layout and tokens and explicitly cannot answer whether a surface RENDERED what it specified. That question waits on the tree this section builds.
> -> XREF: D00 T02 §4 -- the parity driver, which needs nothing from this section to produce a record, but cannot DRIVE a run that is behind a named control until this tree exists
> Measured 2026-09-16 against the shipped binary and recorded in [`docs/captures/ui-automation-spike.md`](../../docs/captures/ui-automation-spike.md): the UI Automation tree for a running window contains **four unnamed panes and nothing inside them**, because Direct2D draws pixels rather than automation elements.
>
> Until providers exist, a driver can launch the app, read its title, screenshot it, and click at a coordinate, and nothing more. It cannot find a control, read a label, count list rows, or assert a state.
>
> This does **not** block the test strategy. Compile gates, unit tests, fixtures, the parity driver, the freeze checks, and launch-and-close smoke all work without it, and together they are the bulk of early fault catching. What is missing without it is **UI wiring**: whether the right data reached the right control, which a unit test cannot see and a screenshot cannot judge.
>
> The section earns its place on accessibility grounds alone. Control-level driving is the bonus.

**Fidelity:** no new visual surface. This section changes what the surfaces expose, not how they look, except for the focus ring.
**Job:** a user who cannot use a mouse, cannot see the screen, or cannot tolerate motion can use every tool completely. Consumer: the UI Automation tree, the keyboard, and the system accessibility settings.
**Treatment:** a UI Automation provider per control. Cheaper substitute that fails the checkpoint: exposing only the window and treating its contents as one opaque element, which is the same as exposing nothing.
**Chrome:** implement in the shared library, per control. A tool never adds its own accessibility handling.
**Needs:** Windows host (build/test)


**Build order.** One control end to end before all of them, because the provider pattern is what gets repeated thirty times and a wrong pattern is expensive to unpick.

1. **Pick one control and implement its provider fully**, handling `WM_GETOBJECT` and returning `IRawElementProviderSimple`. Done when: Narrator announces that control's name, role, value, and state, quoted.
2. **Re-run the tree walk from `docs/captures/ui-automation-spike.md`.** Done when: the descendant count has risen above 4 and the new element is named in the output.
3. **Extract the pattern** into something the other controls reuse. Done when: a second control gains a provider with no duplicated plumbing, proven by search.
4. **Add stable automation ids** where controls are created, never derived from text or position. Done when: an id survives a language change, proven by walking the tree in two languages.
5. **Apply to every remaining control.** Done when: every control in `shared/resolute-ui/` reports name, role, value, and state.
6. **Add notification events** for status changes. Done when: a completed fixture repair is announced, quoted.
7. **Then the rest of the floor**: focus ring, keyboard reachability, reduced motion, hit targets. Done when: each is driven and captured.

- [ ] Implement a UI Automation provider for every control in the shared library, handling `WM_GETOBJECT` and exposing `IRawElementProviderSimple`. Done when: a screen reader announces every control's name, role, value, and state, verified by driving Narrator over each and quoting what it said.
- [ ] Give every interactive control a **stable automation id**, set where the control is created rather than derived from its position or its text. Done when: the ids survive a layout change and a language change, proven by driving the tree in two languages.
- [ ] Prove the tree is traversable by a driver, not only by a screen reader. Done when: the spike's tree walk is re-run and the descendant count rises from **4** to cover every control on the surface, with the before and after quoted.
- [ ] Raise notification events for status changes. Done when: a completed repair is announced, driven and quoted.
- [ ] Make every feature reachable by keyboard, with a logical tab order. Done when: every surface is driven mouse-free end to end and the path is recorded.
- [ ] Render the focus ring per the contract: 2px accent with 1px offset, always visible. Done when: it renders on every focusable control in both appearances, captured.
- [ ] Honour reduced motion by stopping all motion, not shortening it. Done when: with `SPI_GETCLIENTAREAANIMATION` off, every animation in the suite is absent and state changes still occur, driven.
- [ ] Meet the hit-target floor: 24x24px at 100 percent DPI, 48x48px for touch. Done when: every interactive element is measured and any failure is corrected.
- [ ] Add UI scaling independent of system DPI, on the standard zoom shortcuts. Done when: zoom in, out, and reset are driven and the layout stays correct.
- [ ] Commit: `"design: meet the accessibility floor"`

**Test checkpoint:** Narrator announces name, role, value, and state for every shared control, quoted per control. The UI Automation tree walk from `docs/captures/ui-automation-spike.md` is re-run and the descendant count rises from 4 to cover the surface, with before and after quoted, and a control is found by automation id in two languages. A completed repair raises an announcement, quoted. Every surface is driven mouse-free and the path recorded. The focus ring is captured in both appearances. With reduced motion set, no animation occurs and state still changes. Every hit target is measured against the floor.

## 6. Performance Floor

A system utility that feels slow undermines its own claim to be fixing your machine, and it will be run on the slowest machines its users own.

**Fidelity:** no surface of its own. This section changes cost, not appearance, and the captures must be identical before and after.
**Needs:** Windows host (build/test)

- [ ] Record the baseline first: startup time, frame cost on a large list, and working set. Done when: all three are measured on a named machine and quoted here.
- [ ] Pool brushes and text formats, created once and reused. Done when: the allocation count per frame is measured before and after and both are quoted.
- [ ] Scope repaints to the region that changed. Done when: a single row's hover no longer repaints the whole control, measured.
- [ ] Cache static control content as bitmaps and composite. Done when: the frame cost on a large list is measured against the baseline.
- [ ] Confirm render targets are GPU-backed. Done when: it is verified at runtime and the fallback path is recorded.
- [ ] Keep the UI thread unblocked during a tool's main action. Done when: a long fixture operation leaves the window responsive throughout, driven, and this is asserted rather than observed once.
- [ ] Prove the surfaces did not change. Done when: the captures before and after this section are compared and any difference is explained.
- [ ] Commit: `"design: meet the performance floor"`

**Test checkpoint:** Baseline startup, frame cost, and working set quoted on a named machine, and re-measured after each change. Allocation count per frame quoted before and after pooling. A single row hover no longer repaints the whole control. A long operation leaves the window responsive, asserted. Before and after captures are identical or the differences are explained.

## 7. Text Presentation and Machine Values

Small rules, and the ones a user notices when they are wrong: a path they cannot read, a value they cannot copy, a label cut off with no way to see the rest.

**Fidelity:** every text-bearing surface, against `DESIGN.md` section 4.
**Job:** a user can read a value, compare it, and copy it into a search box. Consumer: the rendered text, and the clipboard.
**Treatment:** monospace for machine values and selectable text wherever a user might copy something. Cheaper substitute that fails the checkpoint: proportional text everywhere, which makes a registry path or a hex code genuinely hard to read.
**Chrome:** consume the type ramp. No control picks its own font.
**Needs:** C++ toolchain (compile)

- [ ] Truncate overflowing text with an ellipsis. Done when: a long fixture value truncates and is captured.
- [ ] Show a tooltip with the full value **only** when text is actually truncated. Done when: a truncated value shows one and an untruncated value does not, both driven.
- [ ] Use monospace for machine values: registry paths, file paths, numbers, and hex codes. Done when: every such surface renders monospace and prose renders proportional, captured.
- [ ] Make machine values selectable and copyable. Done when: a value is selected and copied from the result list and the status bar, both driven.
- [ ] Commit: `"design: text truncation, monospace values, and copyable text"`

**Test checkpoint:** A long value truncates with an ellipsis, captured. A truncated value shows a tooltip and an untruncated one does not, both driven. Machine values render monospace and prose proportional, captured. A value is selected and copied from two surfaces, both driven.

## Verification

- [ ] A colour, size, or spacing literal cannot reach a surface, proven by a deliberate failure
- [ ] Every token pair in use meets the contrast floor in both themes
- [ ] Every framework surface is captured at four DPI scalings, both appearances, and three densities
- [ ] Narrator announces every shared control, and every surface is reachable mouse-free
- [ ] Reduced motion stops all motion and high contrast wins over the palette
- [ ] Every open item in `TODO-ux.md` is shipped here, routed elsewhere, or marked superseded
- [ ] `python scripts/todo-graph.py validate` clean
