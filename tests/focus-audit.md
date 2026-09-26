# Focus audit

D00 T02 §10. Every place the suite can put a window on the desktop, take the foreground, or hold input, with its disposition. `scripts/fence-debt.py` reads the fenced rows below: each named case must end a fenced run green or on the `Night-owed:` list.

The two tiers:

- **default**: background-safe. Windows are hidden and disabled (`tests/ui_host.h`), input arrives through `SendMessageW`, and the focus guard (`tests/focus_guard.cpp`) fails any case that shows a window, takes the foreground, holds the capture, or leaves a window behind. `ctest --preset debug` and `ctest --preset release` run this tier, any time.
- **fenced**: headful. The case needs the desktop, carries `[headful]` (excluded from the default presets), opens with the fence's gate (`tests/fence.h`), and declares its placement in a `[place:...]` tag the guard checks. `ctest --preset headful` runs it in the quiet-hours window or on the night runner's idle signal; `ctest --preset headful-visible` runs it on demand.

Synthetic input: none. No test calls `SendInput`, `keybd_event`, or `mouse_event`; every input is a message sent to a window the test owns.

## Test-side sites

| Site | Cases | Disposition | Tier | Placement intent |
| --- | --- | --- | --- | --- |
| `tests/ui_host.h` `HiddenHost` (`CreateWindowExW`, never shown, disabled) | every UI case that needs a window | keep: a real window for message dispatch, never on the desktop | default | none: never visible |
| `tests/ui_driven_test.cpp` clicks and drags through `SendMessageW` | the five D00 T02 §7 cases | converted: the host is disabled, so the list view's `SetFocus` on a click can no longer activate it (the guard's first run caught the hidden host taking the foreground) | default | none |
| `tests/ui_coverage_test.cpp` clicks, keys, and pumps | `Every animated control torn down mid-animation cancels its animations`, `Rapid reversals settle on the last request`, `Hit targets and resize boundaries hold at every DPI scale`, `Toolbar overflow hides commands in order and the keyboard still reaches them` | converted: the toolbar's overflow and dropdown are reached through `BuildOverflowMenu` and the keyboard, never through their modal menus | default | none |
| `tests/ui_render_test.cpp` offscreen renders | every `[render]` case | keep: `RenderTo` paints a WIC bitmap, no window is painted | default | none |
| `tests/ui_test.cpp` controls without `Create` | every `[controls]` case | keep: no window exists | default | none |
| `tests/fence_test.cpp` census probe | `The census sees the windows the suite owns` | keep: one hidden host, created and destroyed | default | none |
| `tests/fence_test.cpp` transient show | `A window shown and gone at once is still seen` | keep, the one deliberate show in the default tier: a 1 x 1 window at (-32000, -32000), on no monitor, without activation, shown, hidden, and destroyed at once to prove the guard records it; the case drains its own events, so that show is not held against it, and nothing reaches the operator's screen | default | none: on no monitor |
| `rui::PopupMenu::Show` (`ShowWindow`, `SetForegroundWindow`, `SetFocus`, its own modal loop) | `The popup menu returns the command the keyboard chooses`, `The popup menu dismissed with Escape returns no command`, `The popup menu ends when its owner is torn down under it` | fence: the popup is a visible top-most window that takes the foreground by design | fenced | `[place:primary]`: the popup opens at a point in the primary monitor's work area; its behaviour, not a DPI, is under test |
| `TrackPopupMenu` behind the toolbar's overflow button | `The toolbar's overflow button offers the hidden commands` | fence: the system menu is visible and modal | fenced | `[place:primary]`: the host sits at the primary monitor's origin, so the menu opens there |
| `scripts/capture-window.ps1` over the launcher | `Launcher capture, light at 100 percent`, `Launcher capture, dark at 100 percent` | fence: a capture needs the window on screen and in the foreground (the script fails closed otherwise) | fenced | `[place:dpi96]`: the capture proves rendering at 100 percent, so the window sits on the monitor at 96 DPI |
| `scripts/capture-window.ps1` over the launcher | `Launcher capture, light at 150 percent`, `Launcher capture, dark at 150 percent` | fence: as above | fenced | `[place:dpi144]`: the capture proves rendering at 150 percent, so the window sits on the monitor at 144 DPI |

## Library sites the suite can reach

| Site | Reached by | Disposition |
| --- | --- | --- |
| `listview.cpp` `SetFocus` and `SetCapture` on a click | default clicks | keep: harmless under a disabled host, proven by the guard on every run |
| `sidebar.cpp` `SetFocus` and `SetCapture` on a click | default clicks | keep: as above |
| `sidebar.cpp` `TrackPopupMenu` on a right click | no test sends a right click | keep with reason: a right-click case would be fenced like the overflow menu |
| `sidebar.cpp` tooltip (`WS_POPUP`, top-most) | created hidden; no test hovers the sidebar long enough to show it | keep: the guard would name it if a case showed it |
| `toolbar.cpp` `PopupMenu::Show` on a dropdown click | no default case clicks a dropdown | fence: reached only through the fenced popup cases' contract |
| `toolbar.cpp` `TrackPopupMenu` on the overflow click | the fenced overflow case | fence |
| `statusbar.cpp` `SetCapture` on a click | no test clicks the status bar | keep: harmless under a disabled host |
| `popupmenu.cpp` modal loop | the fenced popup cases | fixed in D00 T02 §10: the loop now ends when the popup is destroyed under it, and passes a `WM_QUIT` on |
