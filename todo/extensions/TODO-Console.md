# Console — Standalone Terminal Emulator

> **Extension**: `extensions/Console/`
> **Output**: `Bin/Release/System/Console.exe`
> **Stack**: C++23 · Win32 ConPTY · libvterm · Direct2D · ExoUI

A production-ready, standalone multi-tab terminal emulator for Windows. Hosts shells natively via the ConPTY API — no dependency on external terminals, `conhost.exe` wrappers, or hidden console windows. Tab interface provided by ExoUI (new `TabBar` control).

---

## Phase 0: Project Scaffold

- [ ] `CMakeLists.txt` — C++23, Ninja, LLVM-MinGW, output to `System/`
- [ ] Application manifest — Per-Monitor V2 DPI, SegmentHeap, long paths, common controls v6
- [ ] Resource script — embed `Console.ico` (`IDI_CONSOLE`)
- [ ] `main.cpp` entry point stub (wWinMain, ExoUI init)
- [ ] Add `add_subdirectory(extensions/Console)` to root CMakeLists.txt
- [ ] Verify clean build → `Bin/Release/System/Console.exe`

---

## Phase 1: ConPTY Backend

### 1.1 PTY Session

- [ ] `PtySession` class — RAII wrapper around `CreatePseudoConsole`
- [ ] Synchronous pipe pair creation (read/write, only ConPTY-facing ends inheritable)
- [ ] Process spawning via `PROC_THREAD_ATTRIBUTE_PSEUDOCONSOLE` + `CreateProcessW`
- [ ] Handle management via `wil::unique_hfile` / custom `unique_hpcon`
- [ ] `Resize(cols, rows)` → `ResizePseudoConsole`
- [ ] `Write(data, len)` → feed user input to PTY stdin
- [ ] Graceful shutdown — close HPCON → terminate shell

### 1.2 Shell Detection

- [ ] `ShellDetector` — automatic CLI environment discovery
- [ ] Windows shells: `cmd.exe` via `%ComSpec%`, PowerShell (Windows/Core)
- [ ] WSL distributions via `HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss`
- [ ] Git Bash — common `Program Files` paths
- [ ] Default shell selection (prefer PowerShell Core → Windows PowerShell → cmd.exe)

### 1.3 I/O Thread & Ring Buffer

- [ ] SPSC lock-free `RingBuffer` — power-of-two sizing, `alignas(64)` for cache isolation
- [ ] `IoThread` — dedicated background thread, blocking `ReadFile` on PTY output pipe
- [ ] Backpressure: yield/sleep when buffer full
- [ ] Graceful stop via `CancelIoEx`

---

## Phase 2: Terminal Emulation (libvterm)

### 2.1 VTerm Integration

- [ ] Build `libvterm` as static library (C89, bundled in `third_party/`)
- [ ] `VTermWrapper` class — modern C++ interface over libvterm
- [ ] Screen callbacks: `damage`, `movecursor`, `settermprop`, `sb_pushline`
- [ ] `GetCell(row, col)` direct access for rendering
- [ ] `GetSize(rows, cols)` for layout queries

### 2.2 Data Types

- [ ] `TermColor` — tagged union: Default, Indexed (256), RGB (24-bit)
- [ ] `CellAttrs` — bitfield: Bold, Italic, Underline (Single/Double/Curly)
- [ ] `TermCell` — UTF-32 codepoints, up to 3 combining characters

### 2.3 Scrollback Buffer

- [ ] `TerminalBuffer` for historical lines pushed via `sb_pushline`
- [ ] Configurable scrollback limit (default: 10,000 lines)
- [ ] Text extraction: UTF-32 → UTF-8 for clipboard/search

---

## Phase 3: Direct2D Terminal Rendering

### 3.1 Renderer

- [ ] `TerminalRenderer` — hardware-accelerated cell grid rendering
- [ ] `HwndRenderTarget` bound to terminal view (BGRA8 pixel format)
- [ ] Brush caching — hash RGBA → `ID2D1SolidColorBrush`
- [ ] Device-lost recovery — `D2DERR_RECREATE_TARGET` → recreate resources
- [ ] DPI-aware render target (Per-Monitor V2)

### 3.2 Font & Cell Metrics (DirectWrite)

- [ ] Monospace cell measurement — measure "M" width/height
- [ ] Baseline alignment extraction for vertical centering
- [ ] Configurable font family + size (default: Cascadia Mono 14pt)
- [ ] DirectWrite system font collection fallback

### 3.3 Cell Rendering

- [ ] Background fill per-cell with `TermColor` → D2D brush
- [ ] Foreground text rendering — single `DrawText` call per styled run
- [ ] Bold/Italic/Underline attribute rendering
- [ ] 256-color palette + 24-bit true color support
- [ ] Row-level dirty tracking — only repaint damaged rows

### 3.4 Cursor

- [ ] Block, Underline, Bar styles
- [ ] High-precision blink timer
- [ ] Cursor color contrast (invert cell color)

### 3.5 Selection

- [ ] Click-and-drag text selection (per-cell state)
- [ ] Selection highlight rendering (inverted or translucent overlay)
- [ ] Double-click word selection, triple-click line selection

---

## Phase 4: ExoUI Tab Bar (New Control)

> This is a new `exo::TabBar` control in `shared/exo-ui/` — reusable across extensions.

### 4.1 TabBar Control Implementation

- [ ] `TabBar` class — HWND child window, D2D-rendered
- [ ] Tab data model: label, icon (HICON), closeable flag, user data
- [ ] Horizontal tab layout with overflow scrolling
- [ ] Active/inactive tab visual states
- [ ] Tab hover + pressed states with smooth color transitions
- [ ] Close button per tab (`×`) with hover highlight
- [ ] New Tab button (`+`) at the end of the tab strip
- [ ] DPI-aware scaling (font, padding, heights)

### 4.2 Tab Interaction

- [ ] Click to select tab → callback to host
- [ ] Close button → callback with tab index
- [ ] Drag-and-drop tab reordering
- [ ] Middle-click to close
- [ ] Double-click empty space → new tab callback
- [ ] Context menu (right-click): Close, Close Others, Close to Right, Duplicate

### 4.3 Integration API

- [ ] `AddTab(label, icon)` → returns tab index
- [ ] `RemoveTab(index)`
- [ ] `SetActiveTab(index)`
- [ ] `SetTabLabel(index, label)`
- [ ] `SetTabIcon(index, HICON)`
- [ ] Event callback: `OnTabSelected`, `OnTabClosed`, `OnNewTab`

---

## Phase 5: Window & Session Management

### 5.1 MainFrame

- [ ] Top-level window — `WS_OVERLAPPEDWINDOW`, DPI-aware
- [ ] Layout: TabBar at top → TerminalView fills remaining area
- [ ] Focus management: forward focus to active TerminalView
- [ ] Title bar: active tab label + shell name

### 5.2 Session Coordinator

- [ ] `Session` class — binds PTY ↔ VTerm ↔ TerminalView
- [ ] Output flow: PTY IoThread → RingBuffer → VTerm → Renderer
- [ ] Input flow: keyboard/mouse → TerminalView → PTY Write
- [ ] `ProcessOutput()` — drain ring buffer, feed VTerm parser
- [ ] Title change callback (OSC sequences → tab label update)
- [ ] Shell exit detection → tab status update / close prompt

### 5.3 Multi-Session

- [ ] New Tab → spawn new PTY session with default shell
- [ ] Tab switching → swap active TerminalView
- [ ] Close Tab → graceful PTY shutdown, remove tab
- [ ] Last tab closed → close window (or show "new tab" prompt)

---

## Phase 6: Input Handling

### 6.1 Keyboard

- [ ] Virtual-Key → ANSI escape sequence mapping (arrows, F-keys, Home/End, PgUp/PgDn)
- [ ] Ctrl+Key → control characters (0x01–0x1A)
- [ ] Alt+Key → ESC prefix (Meta key)
- [ ] CSI modifier encoding: `\x1b[1;<mod>A` for Shift/Ctrl/Alt combos
- [ ] Unicode input via `WM_CHAR` — UTF-16 → UTF-8 conversion

### 6.2 Mouse

- [ ] Mouse mode detection: X10, Normal, SGR (extended coordinates)
- [ ] `WM_LBUTTONDOWN/UP/MOVE` → click/drag selection or mouse report
- [ ] `WM_MOUSEWHEEL` → scrollback navigation or SGR wheel report (button 64/65)

### 6.3 Clipboard

- [ ] Copy: selected text → `CF_UNICODETEXT` clipboard
- [ ] Paste: clipboard → PTY Write (with bracketed paste `\x1b[200~`…`\x1b[201~`)
- [ ] Ctrl+Shift+C / Ctrl+Shift+V shortcuts

### 6.4 IME Support

- [ ] `WM_IME_STARTCOMPOSITION` / `WM_IME_COMPOSITION` / `WM_IME_ENDCOMPOSITION`
- [ ] Position composition window at cursor via `ImmSetCompositionWindow`
- [ ] Font synchronization via `ImmSetCompositionFontW`
- [ ] Result string injection to PTY via `GCS_RESULTSTR`

---

## Phase 7: Configuration & Profiles

### 7.1 Shell Profiles

- [ ] JSON configuration file: `Console.json` in app directory
- [ ] Default profile: PowerShell Core (or fallback chain)
- [ ] Custom profiles: name, shell path, arguments, starting directory, icon
- [ ] Profile selection on new tab (dropdown or default)

### 7.2 Appearance Settings

- [ ] Font family, size, weight
- [ ] Color scheme (ANSI 16 + background/foreground)
- [ ] Built-in schemes: Campbell, One Dark, Solarized, Dracula
- [ ] Window opacity / acrylic transparency (DWM)
- [ ] Cursor style and blink rate

### 7.3 Behavior Settings

- [ ] Scrollback buffer size
- [ ] Copy-on-select toggle
- [ ] Close confirmation dialog
- [ ] Bell action: visual flash / taskbar flash / none

---

## Phase 8: Session Persistence

- [ ] Save/restore session state on exit/launch
- [ ] `SessionConfig`: shell path, arguments, working directory, tab index, title
- [ ] JSON serialization (manual, no external deps)
- [ ] Batch save/load for all tabs
- [ ] Graceful re-hydration with fallback defaults

---

## Phase 9: Polish & Production

### 9.1 Visual Polish

- [ ] Theme integration — ExoUI dark/light theme colors
- [ ] Animated theme transitions (D2D)
- [ ] Window title: `Console — [shell name]`
- [ ] Taskbar icon badge for bell events

### 9.2 Performance

- [ ] Lock-free I/O path — zero allocations in hot loop
- [ ] Row-level dirty tracking — skip unchanged rows
- [ ] Bitmap glyph cache for repeated characters
- [ ] Target: 60fps rendering at 4K resolution

### 9.3 Accessibility

- [ ] Keyboard navigation (Ctrl+Tab for tab switching)
- [ ] Ctrl+PgUp/PgDn for scrollback
- [ ] Ctrl+Shift+T — new tab, Ctrl+Shift+W — close tab
- [ ] Font scaling: Ctrl+= / Ctrl+- / Ctrl+0

### 9.4 Distribution

- [ ] Standalone executable — static C++ runtime, no external DLLs (except ExoUI.dll)
- [ ] Application manifest embedded
- [ ] Console.ico embedded as application icon
- [ ] Build to `Bin/Release/System/Console.exe`

---

## Architecture Diagram

```
┌─────────────────────────────────────────────┐
│                  MainFrame                  │
│  ┌────────────────────────────────────────┐ │
│  │        ExoUI TabBar (D2D)              │ │
│  │  [PowerShell ×] [cmd.exe ×] [+ New]    │ │
│  └────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────┐ │
│  │          TerminalView (D2D)            │ │
│  │  ┌──────────────────────────────────┐  │ │
│  │  │  Cell Grid Renderer              │  │ │
│  │  │  (DirectWrite monospace font)    │  │ │
│  │  │  (Per-cell color, attributes)    │  │ │
│  │  │  (Cursor blink, selection)       │  │ │
│  │  └──────────────────────────────────┘  │ │
│  └─────────────┬──────────────────────────┘ │
│                │                            │
│  ┌─────────────▼──────────────────────────┐ │
│  │            Session                     │ │
│  │  VTermWrapper ←── RingBuffer ←── IoThread│
│  │       │                          ↑     │ │
│  │       ▼                          │     │ │
│  │  libvterm screen    PtySession ──┘     │ │
│  │  (damage → repaint) (ConPTY + shell)   │ │
│  └────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

## Dependencies

| Component    | Source                                                               | License  |
| ------------ | -------------------------------------------------------------------- | -------- |
| **libvterm** | [libvterm](https://www.leonerd.org.uk/code/libvterm/)                | MIT      |
| **ExoUI**    | `shared/exo-ui/` (D2D, DWrite, TabBar)                               | Internal |
| **ConPTY**   | Windows 10 1809+ (`CreatePseudoConsole`)                             | System   |
| **WIL**      | [Windows Implementation Libraries](https://github.com/microsoft/wil) | MIT      |

## Build Requirements

- Windows 10 1809+ (ConPTY API: `NTDDI_VERSION >= 0x0A000007`)
- LLVM-MinGW (C++23)
- CMake 3.25+ / Ninja
- Links: `d2d1`, `dwrite`, `shell32`, `ExoUI.dll`
