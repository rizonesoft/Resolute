# Rendered-output goldens

D00 T02 §9. `tests/ui_render_test.cpp` paints every shared control offscreen, through the same `RenderTo` path its window paints with, and diffs the result against the PNG here. A failure names the golden, counts the differing pixels, and writes `<name>-actual.png` and `<name>-diff.png` (differing pixels in red) under `build/<preset>/render-out/`.

## Naming

`<control>[-<state>]-<appearance>-<dpi>.png`: `appearance` is `light` or `dark`, `dpi` is `96` (100 percent) or `144` (150 percent). Every control in `shared/resolute-ui/src/controls/` has its four; `glyphs-*` shows the eight glyphs D00 T02 §8 and §9 added (the seven restored names and the `square-dashed` fallback) at their drawn size.

## How they are made

- A software WIC bitmap render target at 96 DIPs per inch with grayscale text anti-aliasing; each control is scaled by its own DPI, as in the window. The popup menu paints with GDI into a 32-bit DIB through `PopupMenu::RenderTo`.
- Animations are run to their end (`AnimationManager::Flush`), so a golden shows the settled state.
- The built-in palettes, never the system accent.

## Tolerance

A pixel differs when any channel differs by more than 8 levels. Renders on one host match exactly; the tolerance only absorbs anti-aliasing rounding should the D2D software rasterizer change between Windows builds. A one-pixel shift moves edges by tens to hundreds of levels, so it still fails (the suite's own shift leg counts thousands of differing pixels).

## Restaking

Run `resolute_tests "[render]"` with `RESOLUTE_UPDATE_GOLDENS=1` set, look at every changed image before committing, and commit them with the layout change that moved them.

## Host

The goldens are pinned to their host: the fonts and the GDI popup's ClearType text come from the machine. Staked on Windows 10.0.26200 (Windows 11) with the system's Segoe UI. A different Windows build or font set may need a restake, which is a reviewed change like any other.
