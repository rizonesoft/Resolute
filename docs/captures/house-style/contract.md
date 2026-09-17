# House-Style Contract

The geometry and typography every shared control draws with, at 96 DPI.

**Derived from source, not written by hand.** Every value below names the class, constant and header it was read out of, so a reader can check it against the code rather than trusting this file. `tests/house_style_test.cpp` parses this file and asserts each row against the real constant, so changing a constant without changing this file fails `scripts/check-all.ps1`.

**These are BASE values, at 96 DPI.** Every one is scaled through `Dpi::Scale` or `Dpi::ScaleF` at draw time, which is why none of them is a pixel count on a particular machine. `tests/dpi_test.cpp` pins that scaling.

**Where this file and [`DESIGN.md`](../../../DESIGN.md) disagree, `DESIGN.md` wins and this file is restaked.** It is the contract; this is a derived record of what the code currently does.

---

## Sidebar

`shared/resolute-ui/include/resolute/controls/sidebar.h`

| Token | Value | Constant |
| --- | ---: | --- |
| Width | 200 | `Sidebar::BASE_WIDTH` |
| Item height | 40 | `Sidebar::BASE_ITEM_HEIGHT` |
| Horizontal padding | 16 | `Sidebar::BASE_PADDING_X` |
| Item font size | 14 | `Sidebar::BASE_FONT_SIZE` |
| Header font size | 11 | `Sidebar::BASE_HEADER_FONT` |
| Icon size | 18 | `Sidebar::BASE_ICON_SIZE` |

## Toolbar

`shared/resolute-ui/include/resolute/controls/toolbar.h`

| Token | Value | Constant |
| --- | ---: | --- |
| Height | 40 | `Toolbar::BASE_HEIGHT` |
| Font size | 13 | `Toolbar::BASE_FONT_SIZE` |
| Icon size | 16 | `Toolbar::BASE_ICON_SIZE` |

## Status bar

`shared/resolute-ui/include/resolute/controls/statusbar.h`

| Token | Value | Constant |
| --- | ---: | --- |
| Height | 26 | `StatusBar::BASE_HEIGHT` |
| Font size | 12 | `StatusBar::BASE_FONT_SIZE` |
| Horizontal padding | 10 | `StatusBar::BASE_PADDING_X` |
| Icon size | 14 | `StatusBar::BASE_ICON_SIZE` |
| Progress bar height | 2 | `StatusBar::PROGRESS_HEIGHT` |

## List view

`shared/resolute-ui/include/resolute/controls/listview.h`

| Token | Value | Constant |
| --- | ---: | --- |
| Row height | 28 | `ListView::BASE_ROW_HEIGHT` |
| Header height | 32 | `ListView::BASE_HEADER_HEIGHT` |
| Large icon | 32 | `ListView::BASE_ICON_LARGE` |
| Small icon | 16 | `ListView::BASE_ICON_SMALL` |
| Font size | 13 | `ListView::BASE_FONT_SIZE` |
| Header font size | 12 | `ListView::BASE_HEADER_FONT` |
| Horizontal padding | 8 | `ListView::BASE_PADDING_X` |
| Large cell width | 96 | `ListView::BASE_LARGE_CELL_W` |
| Large cell height | 80 | `ListView::BASE_LARGE_CELL_H` |
| Scrollbar width | 6 | `ListView::BASE_SCROLLBAR_W` |
| Column resize zone | 4 | `ListView::RESIZE_ZONE` |

---

## What this file does not cover

**Colour.** `Theme::Colors()` returns a `ColorPalette` whose values change with the light and dark themes and with the system accent, so a single number here would be wrong in at least one of those states. The palette's *shape* is the contract, in `shared/resolute-ui/include/resolute/theme.h`, and `DESIGN.md` owns which semantic colour a surface may use.

**Type ramp names.** `TypeStyle` in `typography.h` names the ramp entries, `Caption`, `Body`, `Title`. The per-control font sizes above are what each control actually passes, and where a control passes a raw size rather than a ramp entry that is a defect for `D01 T02` to resolve, not a value to enshrine here.

**Rendering fidelity.** Whether a surface *rendered* what it specified, as opposed to specifying it, is `D01 T02 §5`'s, which builds the automation tree that can answer it. A contract file cannot see a clipped label or a wrong brush.
