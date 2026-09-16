# DESIGN.md

The design contract for Resolute. Every surface in every tool is held to this.

This is a **contract, not a roadmap.** It says what is true of a finished surface. Work that makes it true lives in `todo/`, primarily `D01 T01 §7`-`§8` and `D01 T02`. If a rule here is not yet implemented everywhere, that is a gap in the plan, not permission to deviate.

**How it binds.** `todo/README.md` requires every user-facing section to carry a `Fidelity:` block. That block names this file and the captures under `docs/captures/house-style/`. `review-todo-section` compares a rendered surface against both before stamping, and `D07 T01 §3` checks it per tool.

**How to change it.** Edit this file in a commit that says what changed and why, and update the affected captures in the same commit. A deviation that is agreed becomes a rule here; a deviation that is not agreed is a defect. Never fork a rule into a tool.

---

## 1. The premise

Resolute is fourteen separately distributed tools that must read as one product.

A user who learns one tool has learned all of them. That is only true if the shared layer owns every surface a user recognizes, and if no tool is allowed to draw its own version of something the library already provides.

The suite this replaces failed exactly here: fourteen copies of one framework produced fourteen About dialogs that drifted, seven tools storing settings in the wrong file, and six that logged nothing. The contract exists so that cannot recur by accident.

**Three rules that override everything else in this file:**

1. **A tool never draws a control the shared library provides.** A second progress bar, result list, About dialog, or message box is a defect, not a shortcut.
2. **A tool never hardcodes a colour, a font size, or a spacing value.** It names a token. Tokens live in the theme; literals do not appear in tool code.
3. **Application icons are the one deliberate exception.** Each tool keeps its own Rizonesoft application icon and its own identity in the launcher, on the desktop, and in the taskbar. Everything else is shared.

---

## 2. Rendering

**Direct2D and DirectWrite.** Every surface is vector-rendered. No bitmap-scaled UI, no GDI fallback path for anything a user sees.

This is not an implementation preference: it is what makes the next rule achievable.

**Every surface is correct at every scale.** 100, 125, 150, 200 percent, and whatever comes next. Per-monitor DPI v2 is declared in the manifest, and a window dragged between differently scaled monitors re-lays out rather than re-scales.

Layout is expressed in scalable units. A hardcoded pixel coordinate is a defect, because it produces clipped controls at 150 percent instead of blurry ones.

**Minimum target: Windows 10 1809.** That floor is set by dark mode, per-monitor DPI v2, and Direct2D SVG rendering. Lowering it means giving up all three.

---

## 3. Colour

Colour is never a literal. It is a token resolved from the active theme.

### Token set

| Group | Tokens |
| --- | --- |
| Core | `background`, `surface`, `surfaceHover`, `surfaceActive`, `toolbar`, `text`, `textSecondary`, `border`, `accent`, `statusBar`, `statusBarText` |
| Accent variants | `accentHover`, `accentPressed`, `accentSubtle` |
| Semantic | `success`, `warning`, `error`, `info` |
| Elevation | `surfaceBase`, `surfaceLow`, `surfaceMid`, `surfaceHigh` |
| Overlay | `scrim` |

**Elevation is four levels**, base through high, and it carries meaning: a surface nearer the user sits higher. A dialog is above a panel is above the background.

### Rules

- **Light and dark are both first-class.** Neither is a derived afterthought. Every surface is designed and captured in both.
- **The default is follow-system**, with explicit light and dark available as a setting.
- **Theme changes crossfade** over roughly 300ms. An instant flip is jarring and looks broken.
- **The accent colour comes from the system**, read from DWM, with hover, pressed, and subtle variants derived from it. A user who set their accent expects to see it.
- **High contrast is honoured.** When Windows high contrast is active, system colours win over the palette entirely.
- **Semantic colour is never the only signal.** Success and error carry an icon or a label as well, because red and green alone fail for a meaningful share of users.

### Contrast floor

- **4.5:1 minimum** for all text (WCAG AA).
- **3:1 minimum** for interactive elements and borders.
- Both themes are checked against these, and a token pair that fails is a defect in the palette, not in the surface using it.

---

## 4. Typography

### Type ramp

| Role | Size |
| --- | ---: |
| Caption | 11px |
| Body | 13px |
| Subtitle | 16px |
| Title | 20px |
| Display | 28px |

Weights: Regular 400, Medium 500, SemiBold 600, Bold 700.

A size outside the ramp is a defect. If a surface needs one, the ramp changes here first.

### Rules

- **`DWRITE_RENDERING_MODE_NATURAL_SYMMETRIC`** for text rendering. ClearType antialiasing where it is appropriate to the surface.
- **Monospace for machine values.** Registry paths, file paths, numbers, hex codes, and anything a user might copy or compare character by character use Cascadia Mono or Consolas. Proportional text for prose.
- **Overflow truncates with an ellipsis**, and truncated text carries a tooltip with the full value. A tooltip on text that is *not* truncated is noise.
- **Machine values are selectable and copyable.** A user reading an error they need to search for should not have to retype it.

---

## 5. Spacing and layout

**A 4px grid.** Every spacing value is a multiple of 4.

| Token | Value |
| --- | ---: |
| `SpacingXS` | 4 |
| `SpacingSM` | 8 |
| `SpacingMD` | 12 |
| `SpacingLG` | 16 |
| `SpacingXL` | 24 |

Larger steps continue the grid: 32, 40, 48.

### Rules

- **Density is a user choice**: Compact, Normal, Spacious, adjusting item heights and padding. Normal is the default.
- **The layout adapts rather than breaking.** The sidebar collapses to icons below roughly 600px width; the toolbar moves overflow into a menu when it cannot fit.
- **A minimum window size is enforced** so no surface can be dragged into incoherence.
- **Window size and position are remembered, per monitor.**
- **Windows 11 snap zones are respected.**
- **Long lists virtualize.** A list that renders a thousand rows it cannot show is a performance defect.
- **Scrolling is smooth**, with scroll indicators that fade in on interaction and out when idle.

---

## 6. Motion

Motion exists to explain a change, never to decorate one.

### Rules

- **One shared animation clock.** Every control subscribes to it. A control running its own timer is a defect.
- **Easing is named, not ad hoc**: `EaseOutCubic`, `EaseOutQuart`, `EaseOutBack`, `EaseInOutQuad`, `Spring`.
- **Durations stay short.** Hover transitions around 120ms, state changes around 150ms, theme crossfade around 300ms. Anything a user waits for is too slow.
- **Selection moves, it does not teleport.** An active indicator slides between positions.
- **Feedback is immediate.** A press responds on mousedown, not on mouseup.
- **Staggering is subtle.** Where items animate in sequence, offsets are around 30ms.

### Reduced motion is not optional

When `SPI_GETCLIENTAREAANIMATION` reports that animation is disabled, **all motion stops.** Not shortened: stopped. States still change, they change instantly.

This is an accessibility requirement, not a preference. Motion sensitivity is real and the system setting is the user telling you directly.

---

## 7. Iconography

- **Lucide for interface glyphs**, rendered as SVG through Direct2D so they are sharp at every scale. Never a bitmap icon set per size.
- **Icons take their colour from the theme**, through the icon colour tokens. An icon with a baked-in colour breaks in the other theme.
- **An icon is never the only label** for a destructive or ambiguous action. Pair it with text.
- **Application icons are per-tool Rizonesoft assets** and are explicitly outside this rule. That is the identity users recognize.

---

## 8. Window chrome

- **Rounded corners** on Windows 11, via `DWMWA_WINDOW_CORNER_PREFERENCE`.
- **Backdrop material** via `DWMWA_SYSTEMBACKDROP_TYPE`, and a border colour matched to the theme.
- **A custom caption** drawn with Direct2D, so the title bar is part of the window rather than a system-coloured strip above it. Drag regions are hit-tested properly, and the window controls match the theme.
- **Taskbar integration is used where it means something**: progress on long operations, and nothing decorative.

---

## 9. Accessibility

This section is a floor, not an aspiration. A surface that fails it is not finished.

- **Every feature is reachable by keyboard.** No mouse-only action exists anywhere in the suite.
- **Tab order is logical and predictable**, following visual order.
- **Focus is always visible**: a 2px accent ring with 1px offset on the keyboard-focused element. Focus that cannot be seen is focus that does not exist.
- **Custom controls expose UI Automation.** A custom-drawn control that reports nothing to a screen reader is invisible to the people who most need it, and every control in this suite is custom-drawn.
- **Status changes are announced** through `UiaRaiseNotificationEvent`. A repair that finished silently did not finish for a screen reader user.
- **Hit targets are at least 24x24px** at 100 percent DPI, and 48x48px where touch is supported.
- **Reduced motion is honoured**, per section 6.
- **High contrast is honoured**, per section 3.
- **Colour is never the sole carrier of meaning**, per section 3.

---

## 10. Performance

A system utility that feels slow undermines its own claim to be fixing your machine.

- **Startup is fast enough to feel instant.** A tool the user launched from a launcher should not make them wait twice.
- **Brushes and text formats are pooled**, created once and reused across frames.
- **Repaints are scoped** to the region that actually changed.
- **Static control content is cached** as bitmaps and composited.
- **Render targets are GPU-backed.**
- **The UI thread never blocks.** Long work reports progress and stays responsive, and a surface that freezes during its own main action is a defect regardless of how fast the work is.

---

## 11. Content and tone

The interface is read as much as it is looked at.

- **Say what happened, per item.** "Done" tells a user nothing. Repaired, already correct, skipped, refused, or failed, each with a reason, tells them everything.
- **Name what a destructive action will affect** before asking for confirmation: what, how many, and how large. A generic "are you sure" is not a confirmation.
- **State plainly when something cannot be undone**, on the surface, before the user commits, not in the documentation afterwards.
- **A refusal names the action and what it needed.** "Access denied" is not a message; "Cannot take ownership of C:\Windows\System32: this action needs administrator rights" is.
- **Every string resolves from a language pack.** A hardcoded user-facing string is a defect, because this suite ships in up to 35 languages.
- **Write for someone whose machine is broken.** They are not in a mood for cleverness.

---

## 12. What this contract does not specify

Saying so keeps silence from reading as an oversight.

- **The content of any individual tool's main view.** The contract governs shared surfaces, tokens, and behaviour. What `ComIntRep` puts in its content area is `ComIntRep`'s business.
- **Application icons**, per section 7.
- **Exact palette values.** Those live in the theme implementation, which is the single source. This file governs the token set and the contrast floor, not the hex codes.
- **Pixel-level layout.** The captures under `docs/captures/house-style/` are the visual reference. Where this file and a capture disagree, this file wins and the capture is restaked.

---

## 13. Relationship to the AutoIt suite

`resolute_au3/` is the behavioural specification for the port and is **not** a visual reference.

Those windows are not DPI-aware, have no dark mode, and predate every rule in this file. Ports are 1:1 on behaviour and deliberately not on pixels. Reproducing an AutoIt window faithfully would freeze the defects this contract exists to remove.
