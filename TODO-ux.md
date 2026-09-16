# ExoSuite — UX Enhancement Roadmap

> Modern, premium, native Windows UI — every pixel intentional.

---

## 1. Animation & Motion System

### 1.1 Transition Engine

- [x] Implement a lightweight animation timer (`AnimationManager`) using `SetTimer` or `timeSetEvent`
- [x] Easing functions: `EaseOutCubic`, `EaseOutQuart`, `EaseOutBack`, `EaseInOutQuad`, `Spring`
- [x] Centralized animation tick — all controls subscribe to a shared 60fps timer
- [x] Property animation: any float property (opacity, position, size, color) can be animated
- [x] Staggered animations — items animate in sequence with configurable delay offsets

### 1.2 Sidebar Animations

- [x] **Selection slide**: active indicator slides smoothly between items (vertical translation)
- [x] **Hover fade**: background fades in/out over ~120ms instead of instant snap
- [x] **Icon pulse**: subtle scale-up on hover (1.0 → 1.08 → 1.0 spring)
- [x] **Collapse/expand**: sidebar width animates when toggling collapsed state
- [x] **Item enter**: staggered fade-in on first render (each item 30ms delayed)
- [x] **Ripple effect**: subtle radial highlight expanding from click point

### 1.3 Toolbar Animations

- [x] **Button press**: scale-down to 0.96 on mousedown, spring back on mouseup
- [x] **Hover glow**: border/background color transitions over ~100ms
- [x] **Active indicator**: small dot or bar under the active view mode, slides between positions
- [x] **Tooltip fade**: tooltips fade in after 400ms hover delay with 150ms transition
- [x] **Icon rotation**: refresh button icon rotates 360° during refresh action

### 1.4 StatusBar Animations

- [x] **Text crossfade**: old text fades out, new text fades in when status changes
- [x] **Progress pulse**: animated gradient sweep for "working" states
- [x] **Notification slide**: temporary messages slide in from right, auto-dismiss after 3s

---

## 2. Visual Feedback & Micro-Interactions

### 2.1 Focus & Selection

- [x] **Focus ring**: 2px accent-colored ring with 1px offset on keyboard-focused elements
- [x] **Selection glow**: subtle box-shadow / outer glow on selected sidebar items
- [x] **Active state depth**: slightly darker/lighter shade on active press (not just color swap)
- [x] **Drag feedback**: cursor change + ghost preview when items support reordering

### 2.2 Hover States

- [x] **Cursor proximity / Hover border**: faint border appears on hover (60% border color, animated)
- [x] **Selection border**: faint accent border on selected items (25% accent)
- [x] **Icon colorize**: icons shift from muted to full color on hover (brightness pulse)
- [x] **Elevation change**: hovered items gain subtle shadow (faint border + background fill)

### 2.3 State Transitions

- [x] **Empty state**: friendly illustration + message when a category has no items
- [x] **Error state**: red-tinted banner with icon for failed operations
- [x] **Success flash**: brief green tint on successful operations

### 2.4 Keyboard Navigation

- [x] Full keyboard navigation with visible focus indicators
- [x] `Tab` cycles between sidebar → toolbar → content
- [x] `↑/↓` navigates sidebar items with animated selection
- [x] `Enter` activates the focused item
- [x] `Escape` returns focus to content area
- [x] Accelerator keys (underlined letters) for toolbar buttons

---

## 3. Typography & Text Rendering

### 3.1 Font System

- [x] **Font scale**: define a type ramp — `Caption (11px)`, `Body (13px)`, `Subtitle (16px)`, `Title (20px)`, `Display (28px)`
- [x] **Font weight system**: Regular (400), Medium (500), SemiBold (600), Bold (700)
- [x] **Text antialiasing**: `DWRITE_RENDERING_MODE_NATURAL_SYMMETRIC` for crispest rendering
- [x] **Subpixel positioning**: enable `DWRITE_TEXT_ANTIALIASING_MODE_CLEARTYPE` where appropriate
- [x] **Dynamic font loading**: support loading custom fonts from `Resources/Fonts/`

### 3.2 Text Presentation

- [ ] **Truncation with ellipsis**: `…` for text that overflows container bounds
- [ ] **Tooltip on truncation**: show full text in tooltip only when text is actually truncated
- [ ] **Monospace for values**: use `Cascadia Mono` or `Consolas` for registry values, paths, numbers
- [ ] **Text selection**: allow copy-to-clipboard on status bar and info panels

---

## 4. Color & Theming

### 4.1 Advanced Palette

- [x] **Accent color from system**: read `HKCU\Software\Microsoft\Windows\DWM\AccentColor` and derive palette
- [x] **Accent variants**: auto-generate Hover, Pressed, Subtle from the accent base
- [x] **Semantic colors**: Success (green), Warning (amber), Error (red), Info (blue) tokens
- [x] **Surface elevation**: 3-4 surface levels with progressively lighter/darker shades
- [x] **Scrim/overlay**: semi-transparent overlay for modals and dialogs
- [x] **High contrast mode**: detect `SystemParametersInfo(SPI_GETHIGHCONTRAST)` and use system colors

### 4.2 Theme Transitions

- [x] **Smooth theme switch**: crossfade between dark/light over ~300ms instead of instant flip
- [x] **Per-control repaint cascade**: theme change triggers ordered repaint (background → surfaces → text)
- [x] **Mica/Acrylic effect**: use `DwmSetWindowAttribute` with `DWMWA_SYSTEMBACKDROP_TYPE` for backdrop material
- [x] **Vibrancy**: translucent sidebar with blurred background (Windows 11 Mica Alt)

### 4.3 Color Accessibility

- [ ] Minimum 4.5:1 contrast ratio for all text (WCAG AA)
- [ ] 3:1 contrast for interactive elements and borders
- [ ] Color-blind safe palette — no red/green-only distinctions
- [ ] Test all themes against WCAG contrast checker

---

## 5. Layout & Spacing

### 5.1 Spacing System

- [ ] **4px grid**: all spacing values are multiples of 4 (4, 8, 12, 16, 20, 24, 32, 40, 48)
- [ ] **Consistent padding**: define and enforce `SpacingXS (4)`, `SpacingSM (8)`, `SpacingMD (12)`, `SpacingLG (16)`, `SpacingXL (24)`
- [ ] **Content density modes**: Compact / Normal / Spacious (adjust item heights and padding)

### 5.2 Responsive Layout

- [ ] **Sidebar collapse**: auto-collapse to icon-only mode when window width < 600px
- [ ] **Sidebar toggle**: button to manually collapse/expand with smooth animation
- [ ] **Adaptive toolbar**: overflow menu (`⋯`) when window is too narrow for all buttons
- [ ] **Minimum window size**: enforce sensible minimum (e.g., 480×360)
- [ ] **Snap layouts**: respect Windows 11 snap assist zones
- [ ] **Remember window position**: save/restore size and position per monitor

### 5.3 Content Area

- [ ] **Grid view**: CSS Grid-like layout for icon/tile views with proper reflow
- [ ] **Virtual scrolling**: only render visible items for 1000+ item lists
- [ ] **Smooth scrolling**: animated scroll with momentum/inertia
- [ ] **Scroll indicators**: fade-in scrollbar that appears on hover, hides when idle
- [ ] **Sticky headers**: category headers stay pinned while scrolling through grouped items

---

## 6. Custom Controls — Enhancements

### 6.1 Enhanced Sidebar

- [x] **Search/filter**: inline search box at top that filters categories in real-time
- [x] **Badge counts**: small number pills showing item counts per category
- [ ] **Collapsible groups**: sidebar sections can collapse/expand with chevron
- [x] **Drag-to-reorder**: allow users to reorder categories
- [x] **Context menu**: right-click for category-specific actions
- [x] **Icon-only mode**: collapsed state showing only icons (with tooltips)
- [x] **Active indicator bar**: 3px rounded accent bar on the left edge of selected item

### 6.2 Enhanced Toolbar

- [x] **Separator lines**: thin vertical dividers between button groups
- [x] **Dropdown buttons**: buttons with chevron that open popup menus
- [x] **Icon + text toggle**: show text labels in spacious mode, icons-only when compact
- [x] **Overflow menu**: `⋯` button that houses buttons that don't fit

### 6.3 Enhanced StatusBar

- [x] **Multi-part status**: left (status text) + center (item count) + right (zoom/view slider)
- [x] **Progress bar**: thin accent-colored bar at top of status bar for operations
- [x] **Clickable segments**: segments that open settings or show details
- [x] **Notification area**: icons for background tasks (spinner, checkmark, warning)

### 6.4 New Controls

- [x] **ListView (Custom D2D)**: replace Win32 ListView with full D2D rendering
  - Virtual scrolling, smooth selection, animated item transitions
  - Column resizing with drag handles
  - Inline editing with animated text cursor
  - Row striping with alternating subtle background
  - Sort indicators (animated chevron rotation)
- [ ] **TabControl**: D2D tab bar for multi-panel content areas
- [ ] **TreeView**: D2D tree with animated expand/collapse, indent guides
- [ ] **SplitView**: resizable panel divider with drag handle and double-click reset
- [ ] **Dialog/Modal**: themed modal dialogs with backdrop blur and slide-in animation
- [ ] **Toast/Notification**: corner popups that slide in, auto-dismiss, stack
- [ ] **ContextMenu**: D2D-rendered popup menu with hover animation and icons
- [ ] **Tooltip**: custom themed tooltips with arrow pointer and rich content support
- [ ] **CommandPalette**: `Ctrl+K` universal command launcher (search-based navigation)

---

## 7. Iconography

### 7.1 Icon Rendering Enhancements

- [ ] **Icon caching by theme**: maintain separate dark/light icon bitmap caches
- [ ] **Multi-size cache**: pre-render 16, 20, 24, 32, 48px variants per icon
- [ ] **Icon tinting**: runtime color tinting without re-rendering SVG
- [ ] **Disabled state**: 40% opacity + desaturated for disabled controls
- [ ] **Animated icons**: frame-by-frame SVG animation for loading spinners
- [ ] **Badge overlays**: small status dot (green/red/yellow) overlaid on base icons

### 7.2 Icon Library Expansion

- [ ] Audit all Lucide icons and pre-embed the most common ~200 icons
- [ ] Add domain-specific icons: registry, services, hardware, network adapters
- [ ] Support loading custom icon packs from extensions

---

## 8. Window Chrome & Shell Integration

### 8.1 Custom Title Bar

- [ ] **Custom caption**: draw title bar with D2D for seamless theme integration
- [ ] **Window controls**: custom minimize/maximize/close buttons matching theme
- [ ] **Title bar content**: embed breadcrumb, search, or tab bar in the title area
- [ ] **Draggable regions**: proper hit-testing for custom title bar drag areas
- [ ] **Extend client area**: use `DwmExtendFrameIntoClientArea` for frameless look

### 8.2 Window Effects

- [ ] **Corner rounding**: `DwmSetWindowAttribute(DWMWA_WINDOW_CORNER_PREFERENCE, DWMWCP_ROUND)` on Win11
- [ ] **Shadow**: native drop shadow via `CS_DROPSHADOW` or DWM
- [ ] **Backdrop material**: Mica, Mica Alt, or Acrylic via `DWMWA_SYSTEMBACKDROP_TYPE`
- [ ] **Window border color**: match theme via `DWMWA_BORDER_COLOR`

### 8.3 Taskbar Integration

- [ ] **Jump list**: recent documents and frequent actions
- [ ] **Taskbar progress**: `ITaskbarList3::SetProgressValue` for long operations
- [ ] **Thumbnail toolbar**: mini action buttons in the taskbar thumbnail preview
- [ ] **Badge overlay**: notification count on the taskbar icon

---

## 9. Accessibility

- [ ] **Screen reader**: proper `WM_GETOBJECT` / UI Automation provider for all custom controls
- [ ] **Narrator announcements**: `UiaRaiseNotificationEvent` for status changes
- [ ] **Reduced motion**: respect `SystemParametersInfo(SPI_GETCLIENTAREAANIMATION)` — disable all motion
- [ ] **Large cursor**: ensure all hit targets are minimum 24×24px at 100% DPI
- [ ] **Keyboard-only mode**: all features accessible without mouse
- [ ] **Touch support**: proper touch target sizes (48×48px minimum) and gesture handling
- [ ] **Zoom**: `Ctrl+/- / Ctrl+0` to adjust UI scale factor independent of system DPI
- [ ] **Tab order**: logical, predictable tab sequence through all interactive elements

---

## 10. Performance & Optimization

### 10.1 Rendering Pipeline

- [ ] **Dirty rect tracking**: only repaint the region that actually changed (not full control)
- [ ] **Bitmap caching**: cache static parts of controls as D2D bitmaps, composite on paint
- [ ] **Brush/format pooling**: create brushes and text formats once, reuse across frames
- [ ] **Batch draw calls**: minimize `BeginDraw/EndDraw` pairs — one per control per frame
- [ ] **Deferred rendering**: queue state changes and batch into a single repaint
- [ ] **Hardware acceleration**: ensure D2D is using GPU-backed render targets
- [ ] **Atlas texture**: pack all icons into a single texture atlas to reduce draw calls

### 10.2 Memory

- [ ] **Lazy control creation**: don't create D2D resources until the control is first visible
- [ ] **Resource release on minimize**: release D2D render targets when window is minimized
- [ ] **Icon cache eviction**: LRU eviction for icon bitmaps when memory exceeds threshold
- [ ] **String interning**: avoid repeated `wstring` allocations for known labels
- [ ] **Pool allocators**: for transient objects created during paint cycles

### 10.3 Startup

- [ ] **Deferred init**: load Lucide.dll and render icons on a background thread
- [ ] **Show window first**: display the shell immediately, populate content asynchronously
- [ ] **Precomputed layout**: cache layout measurements and only recalculate on resize/DPI change
- [ ] **Fast path detection**: skip D2D init if running headless or in a service context

### 10.4 Input Handling

- [ ] **Coalesce mouse moves**: skip intermediate `WM_MOUSEMOVE` when behind on processing
- [ ] **Debounce resize**: don't relayout on every pixel of a window drag, debounce to 16ms
- [ ] **Double-buffer all controls**: eliminate flicker during resize via `WS_CLIPCHILDREN` + `WS_EX_COMPOSITED`
- [ ] **Asynchronous loading**: enumerate control panel items on background thread, post results to UI thread

---

## 11. Polish & Details

### 11.1 Cursor Refinements

- [ ] **Resize cursor**: proper `IDC_SIZEWE` on sidebar/splitter edges
- [ ] **Hand cursor**: `IDC_HAND` on clickable text links
- [ ] **Wait cursor**: `IDC_WAIT` / `IDC_APPSTARTING` during blocking operations
- [ ] **Custom cursors**: themed cursors matching the application style

### 11.2 Sound & Haptics

- [ ] **System sounds**: play `MessageBeep` for errors and warnings
- [ ] **Navigation sounds**: subtle click sounds on sidebar/toolbar interaction (optional)

### 11.3 Persistence

- [ ] **User preferences**: save sidebar width, selected category, view mode, theme to registry/JSON
- [ ] **Window state**: remember maximized/normal state and restore on next launch
- [ ] **Per-category view**: each category remembers its last view mode (list/details/icons)
- [ ] **Column widths**: remember details-view column sizes

### 11.4 Error Resilience

- [ ] **Graceful D2D fallback**: if GPU render target fails, fall back to software rendering
- [ ] **Icon fallback**: show a generic placeholder icon if SVG render fails
- [ ] **DLL load failure**: show a clear error if ExoUI.dll or Lucide.dll fails to load
- [ ] **Crash recovery**: save state before operations, restore on restart

---

## 12. Developer Experience

- [ ] **Debug overlay**: `F12` toggles FPS counter, draw-call count, dirty-rect visualization
- [ ] **Theme preview**: `F5` cycles through all theme variants for testing
- [ ] **Layout grid**: debug mode showing 4px grid overlay and control bounds
- [ ] **Hot-reload icons**: re-render SVGs without restarting when icon files change
- [ ] **Performance profiling**: log frame render times, flag >16ms frames
- [ ] **Control inspector**: hover-to-inspect showing control name, DPI, bounds, state

---

## Priority Order

1. **Animation system** (foundation for everything else)
2. **Sidebar selection animation + hover transitions**
3. **Brush/format pooling** (performance baseline)
4. **System accent color** integration
5. **Mica/Acrylic backdrop**
6. **Custom title bar**
7. **Keyboard navigation**
8. **Content density modes**
9. **Sidebar collapse/expand**
10. **Custom ListView** (biggest visual impact)
11. **Toast notifications**
12. **Command palette**
