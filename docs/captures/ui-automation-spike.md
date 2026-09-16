# UI Automation Driver Spike

Driven against the shipped `ExoSuite.exe` (`Bin/Release`, 1,423,872 bytes, built 2026-02-14) on 2026-09-16. Every number below is measured on this machine, not quoted.

Prompted by the equivalent spike in `intelligent-notepad` (`docs/ui-automation-spike.md`, 2026-09-14), which established that the plan's "driven run with evidence" proof type has to be real machinery rather than an intention.

## Toolchain recon

The machine itself has **no CMake and no Clang** on `PATH`. It has `ninja 1.13.2`, `git 2.55.0`, `Python 3.14.4`, and `PowerShell 7.6.6`.

The repository-scoped toolchain under `exokit/` supplies the rest, and it is complete:

| Component | Version |
| --- | --- |
| `cmake` | 4.2.3 |
| `ninja` | 1.13.1 |
| `clang++` | 21.1.8 (llvm-mingw) |

This is the first direct evidence that the decision in `D00 T01 §1` holds: a machine with no system C++ toolchain has everything it needs from the repository.

## Driving the binary: what works today

Launch, attach, interrogate, and close all work with nothing but the Win32 process API.

| Operation | Result |
| --- | --- |
| Launch plus window attach | **471 ms** |
| Window title read back | `ExoSuite` |
| Main window handle | acquired |
| Working set at idle | 49.4 MB |
| Responding | true |
| `CloseMainWindow` | clean, **exit code 0** |

For comparison, the `intelligent-notepad` spike measured 506 ms for launch plus attach through FlaUI against a WinUI 3 stub. The two are the same order, so nothing about this architecture is slow to drive.

## Driving the surface: what does not work

The UI Automation tree was walked with `System.Windows.Automation` against the live window.

```
root name     : 'ExoSuite'
root type     : ControlType.Window
descendants   : 4
  [0] ControlType.Pane  name='' id='100'
  [1] ControlType.Pane  name='' id='101'
  [2] ControlType.Pane  name='' id='103'
  [3] ControlType.Pane  name='' id='102'
```

**Four unnamed panes, and nothing inside them.**

Those four are the child windows created by the 8 `CreateWindowEx` calls across the shell and the controls: the toolbar, sidebar, status bar, and content host. Everything drawn inside them is Direct2D, and Direct2D draws pixels, not automation elements.

Confirmed by search: `shared/exo-ui/` and `src/` contain **no** `WM_GETOBJECT`, no `IRawElementProviderSimple`, and no `IAccessible`.

### What that costs

A driver can currently launch the app, read its title, screenshot it, click at a coordinate, and close it. It **cannot**:

- find a control by name or automation id
- read the text of a label, a status bar, or a list row
- assert that a list has the expected number of rows
- assert a checkbox state, a selection, or an enabled state
- click a named button rather than a guessed position

Coordinate clicking is available but is not a test: it encodes the layout into the test, so every layout change breaks every test, and a click that lands on the wrong control still passes.

## The finding

**UI Automation providers are the prerequisite for the entire driven-test strategy, not only for accessibility.**

`D01 T02 §5` currently frames them as the accessibility floor, which is true and is reason enough on its own. This spike establishes that the same work is also what makes every "driven run with evidence" checkpoint in the plan mean anything at the control level.

One implementation, two payoffs. It also means `D01 T02 §5` is not a Phase 1 polish item that can slip: the parity driver in `D00 T02 §4`, the surface accounts every UI section owes, and the standing smoke run in `D07 T01 §4` all degrade to screenshots and log lines without it.

## Driver choice

**Nothing needs to be chosen yet, and that is the point.** The measurements above used only `System.Diagnostics.Process` and `System.Windows.Automation`, both inbox on Windows, with no package, no install, and no server process.

Once providers exist, the same UIA tree is reachable from any UIA client, so the driver decision stays cheap and reversible. The `intelligent-notepad` spike chose FlaUI over WinAppDriver on measured grounds (maintained, in-process, no install, roughly seven times faster at session start, and WinAppDriver abandoned since 2020); that evaluation transfers, because both are clients of the same tree this suite has yet to expose.

What matters first is having a tree worth traversing.

## Selector convention, adopted in advance

Taken from the `intelligent-notepad` spike so that `D01 T02 §5` implements against it rather than discovering it later:

- **Automation id or name only.** Never `ControlType` conditions, which are flaky on headless runners.
- **Every interactive control gets a stable automation id**, set where the control is created, not derived from its position or its text.
- A failed drive saves a screenshot and prints its path, so a CI failure is diagnosable without reproducing it.

## Reproducing this

Both runs are a single PowerShell invocation with no repository state. Launch and attach uses `Start-Process` plus `MainWindowTitle`; the tree walk uses `[Windows.Automation.AutomationElement]::FromHandle` and `FindAll` over `TreeScope::Descendants`. Re-run after `D01 T02 §5` ships and the descendant count is the measure of whether it worked.
