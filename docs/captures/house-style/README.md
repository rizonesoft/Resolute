# House Style

What a `Fidelity:` citation points at. 29 sections across the plan name this directory, so this file says what they are actually citing.

## What is here

| File | What it is authoritative for |
| --- | --- |
| [`contract.md`](./contract.md) | The geometry and typography every shared control draws with, at 96 DPI, derived from the constants in `shared/resolute-ui/include/resolute/`. |
| `tool-window.png` and its `.txt` | The shipped AutoIt tool window, as a record of **what is being replaced**. Not a target. See below. |

`tests/house_style_test.cpp` parses `contract.md` and asserts every value against the constant it names. Changing a constant without changing the contract **fails `scripts/check-all.ps1`**. That is the whole point: drift is a failing gate rather than something somebody notices while comparing two images.

## A Fidelity citation means the contract plus DESIGN.md

`DESIGN.md` is the contract. `contract.md` is a derived record of what the code currently does. **Where they disagree, `DESIGN.md` wins and `contract.md` is restaked** in the same commit as the change, which is what `DESIGN.md`'s own "How to change it" requires.

## The approved deviations from the AutoIt suite

Two, and they are deliberate rather than tolerated:

- **DPI awareness.** The AutoIt windows are not DPI-aware, so Windows bitmap-stretches them above 100 percent. Every value in `contract.md` is a base at 96 DPI scaled through `Dpi::Scale` at draw time, and `tests/dpi_test.cpp` pins that scaling.
- **Dark mode.** The AutoIt suite has none. `Theme::Colors()` returns a palette per theme, and `DESIGN.md` owns which semantic colour a surface may use.

`AGENTS.md` states the rule these come from: the UI is "rebuilt rather than reproduced".

## What this directory does not cover

**Rendering fidelity.** Whether a surface *rendered* what it specified, as opposed to specifying it, is `D01 T02 §5`'s. A contract file cannot see a clipped label, a wrong brush, or bad z-order. `docs/captures/ui-automation-spike.md` measured why: these windows expose four unnamed panes and nothing inside them, because Direct2D draws pixels rather than automation elements.

**Colour values.** The palette changes with theme and system accent, so a single number here would be wrong in at least one state. The palette's shape is in `theme.h` and its rules are in `DESIGN.md`.

## Why this is not a screenshot store

`D00 T02 §3` was written to capture five shipped AutoIt surfaces as PNGs. It was rewritten on 2026-09-17 when the operator asked what a screenshot proved that the source did not.

It does not. The geometry is already constants, on both sides:

```
AutoIt   GUICtrlCreateLabel($g_sProgName, $g_iSizeIcon + 22, 15, 300, 35)
C++      BASE_WIDTH = 200   BASE_ITEM_HEIGHT = 40   BASE_FONT_SIZE = 14
```

A PNG is a binary blob review cannot diff, it varies with the capturing machine's DPI and installed fonts, and nobody re-stakes one after a padding change. `tool-window.png` is kept because a record of the surface being replaced is worth having for the ports in `D04 T01`; it is explicitly **not** a target, because the suite decided not to reproduce that UI.
