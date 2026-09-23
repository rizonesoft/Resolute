# ExoSuite Development Roadmap

> [!IMPORTANT]
> **Superseded 2026-09-17 by `todo/`, and kept for the record rather than deleted.**
>
> This is the ExoSuite development roadmap: **348 open items** and 35 done, describing a Control Panel replacement built from CPL applets. No line count is given, because a figure describing the file it sits in is changed by being written: the first draft of this header said 728 and made itself wrong. Resolute is a suite of system utilities, and its plan is `todo/`, which carries 120 sections across ten domains. The two describe different products, so this is not a plan that fell behind; it is a plan for something else.
>
> **Nothing here is a live work item.** Do not tick, route, or implement from this file. `todo/implementation-plan.md` is the live plan.
>
> **What was checked before superseding it.** `D00 T03 §4` compared this file's phases against the Resolute plan rather than assuming coverage. One idea was genuinely uncovered:
>
> | Idea | Where it lives here | Status |
> | --- | --- | --- |
> | **Hosting Control Panel applets**: loading `.cpl` DLLs in-process and calling `CPlApplet` | Phases 2, 3 and 11, 51 mentions | **Routed.** `git grep -i "\.cpl"` over `todo/` returned nothing, so it was filed as a decision on `D03 T01 §4`. The launcher already plans to *open* Control Panel items by CLSID, which is a different thing from hosting them |
>
> Everything else here is either covered by `todo/` or belongs to the ExoSuite product direction that Resolute does not follow.

This document outlines the complete development roadmap from initial structure to production-ready release.

**Tech Stack**: C++23, Native Win32 API, CMake + Ninja (LLVM-MinGW) — No .NET Framework Required

---

## Why C++ / Win32?

| Feature                 | Benefit                                               |
| ----------------------- | ----------------------------------------------------- |
| **Zero Dependencies**   | No runtime needed — runs on any Windows 10/11 machine |
| **Maximum Performance** | Direct hardware access, no GC, no JIT                 |
| **Tiny Binaries**       | Single .exe per extension, < 1 MB typical             |
| **Full Win32 Access**   | Complete access to all Windows APIs                   |
| **SVG Icons**           | Modern icon system via Direct2D or nanosvg            |
| **ExoKit Toolchain**    | Portable build (LLVM-MinGW, CMake, Ninja)             |

---

## Phase 0.0: UI Shell Setup (PRIORITY)

> **This is the first thing to implement** — Get a working window on screen before anything else.

### 0.0.1: Development Environment

- [x] Set up ExoKit portable toolchain (LLVM-MinGW, CMake, Ninja)
- [x] Verify LLVM-MinGW: `clang++ --version` (21.1.8 ✓)
- [x] Verify CMake: `cmake --version` (4.2.3 ✓)
- [x] Verify Ninja: `ninja --version` (1.13.1 ✓)

### 0.0.2: C++ Project Setup

- [x] Create root `CMakeLists.txt` for monorepo workspace
- [x] Create project directory structure:
  ```
  ExoSuite/
  ├── src/
  │   ├── CMakeLists.txt
  │   ├── main.cpp
  │   └── resources/
  ├── extensions/
  ├── shared/exo-ui/
  └── exokit/
  ```
- [x] Create minimal `src/main.cpp` (Win32 entry point)
- [x] Create `src/CMakeLists.txt`
- [x] Add CMakePresets.json for Debug/Release configurations

### 0.0.3: Test Compile & Run

- [x] Build: `.\exokit\Build-ExoSuite.ps1 -Release`
- [x] Run: `Bin\Release\ExoSuite.exe`
- [x] Verify window appears (WS_OVERLAPPEDWINDOW)

### 0.0.4: Basic UI Shell Layout

- [x] Add NavigationView/sidebar (owner-draw or custom control)
- [x] Add content area (ListView placeholder)
- [x] Add toolbar with SVG icon buttons
- [x] Add status bar
- [x] Verify dark/light theme switching works

---

## Phase 0: Project Foundation & Setup

### 0.1: Repository Setup

- [x] Create directory structure (extensions, shared, exokit, installers)
- [x] Create GitHub repository
- [x] Create .gitignore for C++ projects
- [x] Create README.md with project overview
- [x] Initialize Git repository and push
- [x] Set up issue templates
- [x] Create initial commit with shell skeleton

### 0.2: Build System Configuration

- [x] Create ExoKit bootstrap (LLVM-MinGW, CMake, Ninja)
- [x] Create ExoKit init script (PATH setup)
- [x] Create Build-All.ps1 (shell + extensions)
- [x] Create Build-Extension.ps1 (single extension)
- [x] Create Build-ExoSuite.ps1 (main app)
- [ ] **Target Platform Requirements**:
  - [ ] Set target OS to Windows 10 and Windows 11 only (no Windows 7/8 support)
  - [ ] Configure build for 64-bit (x64) only (no 32-bit support - future standard)
  - [ ] Set platform to x64 in all projects
  - [ ] Update CMake to enforce Windows 10+ requirement
  - [ ] Add platform validation on startup (check OS version, architecture)
- [ ] Configure build configurations (Debug, Release)
- [ ] Set up single executable configuration
- [x] Configure extension projects to output to `Bin/Release/System/` folder
- [x] Set up CMake targets for extension compilation
- [ ] Create solution structure for main app + extensions
- [ ] Test Release compilation (64-bit only)
- [ ] Verify standalone executable creation (64-bit)
- [ ] Verify extension compilation output to system folder

### 0.3: Project Structure & Scaffolding

- [ ] Create Core namespace structure (CplInterop, CplLoader, CplItem)
- [ ] Create UI namespace structure (MainWindow)
- [ ] Create Resources folder structure
- [ ] Add application icon (Graphics/ExoSuite.ico)
- [ ] **Dual-Mode Extension Architecture** (Monorepo):
  - [ ] Design extensions to run both standalone and integrated into ExoSuite
  - [ ] All extensions live in `extensions/` directory (monorepo approach)
  - [ ] Extensions link against shared libraries in `shared/`
  - [ ] Standalone mode: compile as independent executable (.exe)
  - [ ] Integrated mode: compile as plugin DLL for ExoSuite host
  - [ ] Create extension manifest format (JSON) for metadata and capabilities
  - [ ] See `docs/dev/extension-architecture.md` for details
- [ ] **Shared Library Infrastructure** (in `shared/`):
  - [ ] Create `ExoSuite.Core` shared library (common types, interfaces)
  - [ ] Create `ExoSuite.UI` shared library (common controls, themes, SVG icons)
  - [ ] Create `ExoSuite.Interop` shared library (Win32 API helpers)
  - [ ] Version shared libraries with semantic versioning
- [ ] **Extension System**:
  - [ ] Extensions built alongside main app in monorepo
  - [ ] Extension executables output to `Bin/Release/System/` folder
  - [ ] Create extension template in `extensions/_template/`
  - [ ] CMake configuration for extension builds
  - [ ] Documentation and examples
- [ ] Create application manifest
- [ ] Set up version numbering system
- [ ] Create constants/configuration class
- [ ] Create Category enumeration and management system
- [ ] Set up localization/internationalization infrastructure
- [ ] Create theme system architecture (light/dark/system mode support, accent colors from Windows)
- [ ] Design performance monitoring infrastructure
- [ ] **Design UI with Win32 Custom Controls**:
  - [ ] Set up UI component library structure
  - [ ] Create main window layout (NavigationView, sidebar, toolbar)
  - [ ] Define UI components (custom ListView, sidebar, toolbar)
  - [ ] Design plugin host system for loading integrated extensions
  - [ ] Create extension discovery and registration system
  - [ ] Implement extension lifecycle management (load/unload/reload)

---

## Phase 1: Core Architecture

### 1.0: Platform & Architecture Requirements

- [ ] **Windows 10/11 Only**: Implement OS version checking
  - [ ] Check minimum Windows version (Windows 10 build 10240 or later)
  - [ ] Display friendly error message if running on unsupported OS
  - [ ] Block execution on Windows 7/8/8.1 (explicitly rejected with version-specific messages)
- [ ] **64-bit Only**: Enforce 64-bit architecture requirement
  - [ ] Check CPU architecture at runtime
  - [ ] Display friendly error message if running on 32-bit system
  - [ ] Configure all projects for x64 only
- [ ] Document platform requirements in README and installer

### 1.1: Error Handling System

- [ ] Create ErrorInfo class/struct
- [ ] Implement error logging system
- [ ] Create LogError function with debug output
- [ ] Create ShowError function for user-facing errors
- [ ] Add try-catch blocks throughout codebase
- [ ] Implement graceful error recovery

### 1.2: Configuration Management

- [ ] Create Settings class
- [ ] Implement settings file (JSON)
- [ ] Create LoadSettings function
- [ ] Create SaveSettings function
- [ ] Implement default settings
- [ ] Add settings for view mode, icon size, window position
- [ ] Implement portable mode detection (settings in root folder)
- [ ] Implement installed mode (settings in registry for faster access)
- [ ] Create SettingsProvider abstraction (file-based vs registry-based)
- [ ] Auto-detect mode on startup (check registry first, fallback to file)
- [ ] Implement settings export/import functionality
- [ ] Add settings backup and restore
- [ ] Create settings validation system
- [ ] Support settings migration between versions

### 1.3: Versioning System

- [ ] Create VersionInfo class
- [ ] Implement semantic versioning (MAJOR.MINOR.PATCH)
- [ ] Add version display in About dialog
- [ ] Create version file generation
- [ ] Integrate version into build process

### 1.4: Exception Handling System

- [ ] Create global unhandled exception handler
- [ ] Implement ExceptionDialog with Win32 dialog
- [ ] Add exception details viewer (expandable sections)
- [ ] Implement troubleshooting suggestions based on exception type
- [ ] Add copy-to-clipboard functionality for exception details
- [ ] Add option to save exception report to file
- [ ] Include stack trace, inner exceptions, and system info
- [ ] Handle structured exception handling (SEH)
- [ ] Create ExceptionReport class for structured exception data
- [ ] Implement crash reporting (optional, user-configurable)
- [ ] Add "Send Error Report" option with privacy notice

### 1.5: Performance Monitoring & Optimization

- [ ] Create PerformanceMonitor class
- [ ] Implement startup time tracking
- [ ] Monitor memory usage
- [ ] Track CPU usage during operations
- [ ] Measure applet loading times
- [ ] Create performance metrics dashboard (dev mode)
- [ ] Implement performance benchmarks
- [ ] Add slow operation warnings
- [ ] Optimize first-run experience
- [ ] Implement lazy loading strategies
- [ ] Create memory pool for frequently allocated objects

---

## Phase 2: CPL Interop Implementation

### 2.1: Complete Win32 API Definitions

- [ ] Define CPL message constants
- [ ] Define CPlApplet function pointer
- [ ] Define CPLINFO struct
- [ ] Define NEWCPLINFO struct
- [ ] Add LoadIcon/LoadImage definitions
- [ ] Add resource loading functions
- [ ] Test definitions with sample .cpl

### 2.2: CPL Marshaling Implementation

- [ ] Implement CPL_INQUIRE handling
- [ ] Implement CPL_NEWINQUIRE handling
- [ ] Handle both ANSI and Unicode paths
- [ ] Test with various .cpl files
- [ ] Add error handling for failures

### 2.3: Icon Resource Extraction

- [ ] Implement LoadIconFromResource function
- [ ] Extract icon from hModule using idIcon
- [ ] Handle multiple icon sizes (16, 24, 32, 48, 64, 128, 256)
- [ ] Create icon cache to prevent reloading
- [ ] Test icon extraction with sample .cpl files

### 2.4: String Resource Extraction

- [ ] Implement LoadStringFromResource function
- [ ] Extract name string using idName
- [ ] Extract description string using idInfo
- [ ] Handle both ANSI and Unicode strings
- [ ] Add fallback to file name if resource missing

### 2.5: Administrator Privilege Detection

- [ ] Implement function to detect if current process has admin privileges
- [ ] Implement function to detect if a CPL requires admin privileges
- [ ] Check CPL manifest or metadata for admin requirement
- [ ] Add `RequiresAdministrator` property to `CplItem` class
- [ ] Test privilege detection with various CPL files
- [ ] Handle privilege escalation gracefully (request elevation when needed)

---

## Phase 3: CPL Loader Implementation

### 3.1: Dynamic Library Loading

- [ ] Implement LoadCplFile method
- [ ] Use LoadLibraryEx for dynamic loading
- [ ] Find CPlApplet export with GetProcAddress
- [ ] Call CPL_INIT
- [ ] Call CPL_GETCOUNT
- [ ] Add proper error handling for loading failures
- [ ] Handle locked/unloadable .cpl files

### 3.2: Applet Enumeration

- [ ] Iterate through applets in each .cpl
- [ ] Implement CPL_INQUIRE for each applet
- [ ] Extract applet name and description
- [ ] Extract applet icon
- [ ] Create CplItem for each applet
- [ ] Test with multiple .cpl files

### 3.3: System Folder Management

- [ ] Create system folder if missing
- [ ] Scan for .cpl files
- [ ] Add file watching for new .cpl additions (ReadDirectoryChangesW)
- [ ] Handle .cpl file removal
- [ ] Add refresh functionality
- [ ] Create default .cpl collection documentation
- [ ] Implement category detection/assignment for CPL files
- [ ] Support category metadata in CPL files or external config
- [ ] **Detect admin requirements for each CPL**:
  - [ ] Query each CPL for admin requirement during enumeration
  - [ ] Store admin requirement flag in CplItem
  - [ ] Handle privilege detection failures gracefully

### 3.4: Category Management System

- [ ] Create Category enum/class (System, Network, Security, Display, Programs, etc.)
- [ ] Implement category assignment for CplItem
- [ ] Create category metadata storage (JSON/XML)
- [ ] Support custom categories
- [ ] Implement category icons for sidebar
- [ ] Add category filtering logic
- [ ] Persist user category preferences
- [ ] Support "Uncategorized" for applets without category

---

## Phase 4: User Interface Components (Win32)

### 4.1: Main Window Layout

- [ ] Create MainWindow (WS_OVERLAPPEDWINDOW)
- [ ] Set window properties (title, size, icon)
- [ ] Add MenuBar (File, View, Help, Tools)
- [ ] Add CommandBar/Toolbar (view mode buttons with SVG icons)
- [ ] Add SplitView for sidebar and main content area
- [ ] Add Category Sidebar (TreeView or custom owner-draw)
- [ ] Implement category filtering (All, System, Network, Security, etc.)
- [ ] Add ListView/GridView control for applet display
- [ ] Implement sidebar collapse/expand functionality
- [ ] Implement window resize handling
- [ ] Add status bar for information
- [ ] Design sidebar for scalability (100+ settings/utilities)
- [ ] Implement smooth animations
- [ ] Add multi-monitor support (remember position per monitor)
- [ ] Support window minimizing to system tray
- [ ] Implement Mica/Acrylic-like backdrop effects (DWM)
- [ ] Add customizable window chrome (dark title bar via DwmSetWindowAttribute)

### 4.2: ListView/GridView Setup

- [ ] Configure GridView for Large Icon view
- [ ] Set up ImageSource for icons (HICON-based)
- [ ] Add columns for Details view (Name, Category, Description)
- [ ] Implement item population from CplLoader
- [ ] Implement category-based filtering
- [ ] Add double-click event handler
- [ ] Add right-click context menu
- [ ] Update view when category selection changes
- [ ] Implement virtual list for performance (1000+ items)
- [ ] Add smooth scrolling
- [ ] Implement drag-and-drop support (reorder favorites)
- [ ] Add selection highlighting
- [ ] Support multi-select mode
- [ ] Implement keyboard navigation

### 4.3: View Mode Implementation

- [ ] Implement Large Icons view
- [ ] Implement Small Icons view
- [ ] Implement List view
- [ ] Implement Details view (report mode)
- [ ] Add view mode switching logic
- [ ] Persist view mode in settings
- [ ] Update toolbar toggle states

### 4.4: Icon Display

- [ ] Create icon loading (HICON/HBITMAP)
- [ ] Populate icons from CplItem
- [ ] Assign icons to view items
- [ ] Handle missing icons gracefully
- [ ] Support icon size selection (16, 24, 32, 48)
- [ ] **Admin Privilege Shield Icon Overlay**:
  - [ ] Load Windows shield icon overlay
  - [ ] Create function to composite shield overlay on CPL icons
  - [ ] Overlay shield icon in bottom-right corner
  - [ ] Apply overlay only to CPL items that require admin privileges
  - [ ] Support shield overlay at all icon sizes
  - [ ] Test shield overlay rendering in all view modes

### 4.5: Menu System

- [ ] Implement File menu (Refresh, Exit)
- [ ] Implement View menu (Large Icons, Small Icons, List, Details)
- [ ] Implement Tools menu (Settings)
- [ ] Implement Help menu (About)
- [ ] Implement Tools menu with Troubleshooting options:
  - [ ] System File Checker (SFC /scannow)
  - [ ] Check Disk (CHKDSK)
  - [ ] Disk Cleanup
  - [ ] System Restore
  - [ ] Event Viewer
  - [ ] Task Manager
  - [ ] System Information
  - [ ] Separator
  - [ ] Run as Administrator (restart elevated)
- [ ] Implement Help menu with:
  - [ ] Check for Updates
  - [ ] Report an Issue (opens GitHub/issues URL)
  - [ ] Home Page (opens https://rizonesoft.com)
  - [ ] ExoSuite Page (opens project-specific URL)
  - [ ] Separator
  - [ ] About ExoSuite...
- [ ] Add keyboard accelerators
- [ ] Implement menu state updates
- [ ] **Admin Privilege Handling**:
  - [ ] Detect current process admin status on startup
  - [ ] Display status indicator if running as admin vs non-admin
  - [ ] Handle UAC elevation requests gracefully
  - [ ] Provide option to restart as administrator when needed
  - [ ] Show informative tooltip for admin-required CPL items
  - [ ] Handle privilege escalation failures gracefully
  - [ ] Test both admin and non-admin scenarios

### 4.6: About Dialog

- [ ] Create AboutDialog (Win32 DialogBox)
- [ ] Add application icon/branding
- [ ] Display version information from VersionInfo
- [ ] Include copyright information (Rizonetech (Pty) Ltd)
- [ ] Add developer credit (Derick Payne)
- [ ] Add website link (https://rizonesoft.com)
- [ ] Implement donate link/button
- [ ] Style with modern look
- [ ] Make responsive to dialog sizing

### 4.7: Update Check System

- [ ] Create UpdateChecker class
- [ ] Implement XML-based version manifest download
- [ ] Parse version information from XML file
- [ ] Compare installed version with latest version
- [ ] Create update notification dialog
- [ ] Display update information (version, release notes, download link)
- [ ] Add "Check for Updates" menu item handler
- [ ] Implement background update check on startup (optional)
- [ ] Handle network errors gracefully
- [ ] Cache update check results

### 4.8: SVG Icon Toolbar

- [ ] Design SVG icon storage system (embedded resources or files)
- [ ] Implement SVG rendering engine (nanosvg or Direct2D SVG)
- [ ] Create toolbar with SVG icon buttons
- [ ] Implement icon caching for performance
- [ ] Support icon theming (light/dark mode colorization)
- [ ] Add icon scaling support
- [ ] Integrate icon library with toolbar

### 4.9: CommandBar / Toolbar Implementation

- [ ] Add view mode toggle buttons
- [ ] Add refresh button
- [ ] Implement button state management
- [ ] Add tooltips
- [ ] Style toolbar appropriately
- [ ] Use SVG icons from icon library
- [ ] Add theme toggle button (only visible when system theme disabled)
- [ ] Update icons on theme change

### 4.10: Context Menu

- [ ] Add "Open" option
- [ ] Add view mode options
- [ ] Add separator
- [ ] Position menu correctly
- [ ] Handle keyboard navigation
- [ ] Add "Add to Favorites" option
- [ ] Add "Pin to Quick Access" option
- [ ] Add "Properties" option (show applet details)

### 4.11: Search & Filter System

- [ ] Create search bar in toolbar area
- [ ] Implement real-time search filtering
- [ ] Support fuzzy search
- [ ] Add search suggestions/autocomplete
- [ ] Highlight search matches in results
- [ ] Save recent searches
- [ ] Add advanced search filters:
  - [ ] Filter by category
  - [ ] Filter by keyword tags
  - [ ] Filter by recently used
  - [ ] Filter by favorites only
- [ ] Implement search keyboard shortcut (Ctrl+F)
- [ ] Add clear search button
- [ ] Show search result count

### 4.12: Favorites & Quick Access

- [ ] Create Favorites system
- [ ] Add "Favorites" category to sidebar
- [ ] Implement add/remove from favorites
- [ ] Persist favorites in settings
- [ ] Create Quick Access widget
- [ ] Support pinned items (always visible)
- [ ] Implement drag-and-drop to favorites
- [ ] Add favorites badge/indicator
- [ ] Support favorites groups/categories
- [ ] Export/import favorites

### 4.13: Recent Items & History

- [ ] Track recently opened applets
- [ ] Display "Recently Used" category
- [ ] Show usage frequency
- [ ] Implement history persistence
- [ ] Add "Clear History" option
- [ ] Limit history size (configurable)
- [ ] Show last used timestamp

### 4.14: Command Palette / Quick Actions

- [ ] Implement command palette (Ctrl+K or Ctrl+Shift+P)
- [ ] Quick access to all applets via typing
- [ ] Support keyboard shortcuts for common actions
- [ ] Add command suggestions
- [ ] Implement fuzzy matching for commands
- [ ] Support command aliases
- [ ] Customizable keyboard shortcuts

### 4.15: Themes & Customization

- [ ] Implement light theme (default)
- [ ] Implement dark theme (DWM dark mode APIs)
- [ ] Implement system mode (follows Windows theme preference)
- [ ] Use Windows accent colors
- [ ] Persist theme preference
- [ ] Auto-detect Windows theme preference
- [ ] Implement smooth theme transitions

### 4.16: Animations & Transitions

- [ ] Implement smooth fade-in/fade-out
- [ ] Add slide transitions between views
- [ ] Smooth icon loading animations
- [ ] Hover effects on interactive elements
- [ ] Smooth category switching animations
- [ ] Loading progress indicators
- [ ] Minimize animation performance impact
- [ ] Respect user preference for reduced motion (SPI_GETCLIENTAREAANIMATION)

### 4.17: Accessibility Features

- [ ] Implement keyboard navigation throughout UI
- [ ] Add screen reader support (MSAA / UI Automation)
- [ ] Support high contrast mode
- [ ] Implement font scaling (DPI-aware)
- [ ] Add colorblind-friendly color schemes
- [ ] Support Windows Narrator
- [ ] Keyboard shortcuts for all actions
- [ ] Focus indicators for keyboard navigation
- [ ] Respect Windows accessibility settings
- [ ] Add accessibility settings panel

---

## Phase 5: Core Extensions/Utilities Implementation

> **Extension Architecture**: Each extension lives in `extensions/` within the monorepo. Extensions can run standalone or integrated into ExoSuite via shared libraries.

### 5.0: Extension Infrastructure Setup

- [ ] Create `shared/ExoSuite.Core/` (shared static library)
- [ ] Create `shared/ExoSuite.UI/` (shared UI components, SVG icons)
- [ ] Create `extensions/_template/` extension template
- [ ] Implement extension host in ExoSuite main application
- [ ] Create extension installer/manager UI
- [ ] Document extension development workflow

### 5.1: RegStudio (Registry Editor) — `extensions/RegStudio/`

- [x] Create CMakeLists.txt (C++23, Ninja, LLVM-MinGW)
- [x] Create main.cpp entry point stub
- [x] Application manifest (DPI-aware, admin rights)
- [x] Resource compilation (.rc, icon.ico)
- [ ] Implement registry tree view (left panel)
- [ ] Implement value list view (right panel)
- [ ] Implement registry enumeration (RegEnumKeyExW, RegEnumValueW)
- [ ] Implement value editing dialogs
- [ ] Implement key operations (create, delete, rename, export)
- [ ] Implement search functionality
- [ ] SVG toolbar with RegStudio-specific actions

### 5.2: System Properties Utility — `extensions/sysprops/`

- [ ] Create project structure
- [ ] Design System Properties dialog layout
- [ ] Create main window with tabs:
  - [ ] Computer Name tab
  - [ ] Hardware tab
  - [ ] Advanced tab
  - [ ] System Protection tab
  - [ ] Remote tab
- [ ] Implement Win32 API calls for system changes
- [ ] Handle UAC elevation for privileged operations

### 5.3: System Information — `extensions/sysinfo/`

- [ ] Display Windows edition and version
- [ ] Display processor information
- [ ] Display installed memory (RAM)
- [ ] Display system type (32-bit/64-bit)
- [ ] Display computer name and domain
- [ ] Display product ID and activation status
- [ ] Integrate WMI via COM

---

## Phase 6-10: Additional Extensions

> Same extension items as above, all C++23/Win32, built with CMake+Ninja.
> Each extension outputs to `Bin/Release/System/` via ExoKit build scripts.

---

## Phase 11: Applet Execution (Core Functionality)

### 11.0: Administrator Privilege Management

- [ ] **Check Admin Requirements Before Execution**:
  - [ ] Verify if selected CPL requires admin privileges
  - [ ] Check if current process has admin privileges
  - [ ] Compare requirements vs current privileges
- [ ] **Graceful Privilege Handling**:
  - [ ] If admin required but not running as admin:
    - [ ] Display user-friendly dialog explaining need for elevation
    - [ ] Offer option to restart ExoSuite as administrator
    - [ ] Offer option to launch CPL directly with elevation (via rundll32)
    - [ ] Provide "Cancel" option
    - [ ] Remember user preference for similar items
  - [ ] If admin required and already running as admin:
    - [ ] Execute CPL normally
  - [ ] If no admin required:
    - [ ] Execute CPL normally regardless of privilege level
- [ ] **Error Handling**:
  - [ ] Handle UAC cancellation gracefully
  - [ ] Handle privilege escalation failures
  - [ ] Display clear error messages
  - [ ] Log privilege-related issues for debugging
- [ ] **User Experience**:
  - [ ] Show shield icon overlay on admin-required items
  - [ ] Add tooltip explaining admin requirement
  - [ ] Update context menu to indicate admin requirement
  - [ ] Provide keyboard shortcut to restart as admin

### 11.1: Double-Click Handling

- [ ] Implement item double-click event
- [ ] Get selected CplItem
- [ ] Check admin requirements before execution
- [ ] Execute applet using rundll32.exe (for external .cpl)
- [ ] Execute internal applets directly
- [ ] Handle execution errors
- [ ] Show error message if execution fails

### 11.2: Execution Methods

- [ ] Implement rundll32.exe method (Control_RunDLL) for external .cpl
- [ ] Pass correct .cpl path and index
- [ ] Implement direct execution for internal applets
- [ ] Check admin requirements before execution
- [ ] Handle UAC elevation if needed
- [ ] Launch processes with appropriate privilege level (CreateProcess/ShellExecuteEx)
- [ ] Monitor process execution
- [ ] Add alternative execution methods if needed

### 11.3: Error Handling for Execution

- [ ] Catch execution failures
- [ ] Display user-friendly error messages
- [ ] Log execution errors
- [ ] Handle missing .cpl files
- [ ] Handle permission denied errors

---

## Phase 12-18: Polish, Distribution & Release

### 12: Testing & QA

- [ ] Unit testing framework setup
- [ ] Integration tests for CPL loading
- [ ] UI automation tests
- [ ] Performance benchmarks
- [ ] Memory leak detection (AddressSanitizer)

### 13: Distribution

- [ ] Inno Setup installer script
- [ ] Portable mode support (settings in app directory)
- [ ] Update checker (XML version manifest)
- [ ] About dialog with version info
- [ ] GitHub Release automation

### 14: Final Polish

- [ ] Code signing (optional)
- [ ] Documentation
- [ ] README with screenshots
- [ ] Changelog generation
- [ ] License compliance

---

## Build Output Structure

```
Bin/
└── Release/
    ├── ExoSuite.exe          ← Main application (from src/)
    └── System/
        ├── RegStudio.exe     ← Registry Editor (from extensions/RegStudio/)
        ├── SysProps.exe      ← System Properties (from extensions/sysprops/)
        └── SysInfo.exe       ← System Info (from extensions/sysinfo/)
```

---

## Notes

- **Tech Stack**: C++23, Win32 API, CMake + Ninja (LLVM-MinGW)
- **No dependencies**: No .NET, no WinUI3, no Rust, no web technologies
- **ExoKit**: Portable toolchain — `.\exokit\Bootstrap-ExoKit.ps1` to install tools
- **Build**: `.\exokit\Build-All.ps1 -Release` builds everything
- Each phase should be completed before moving to the next
- After completing each task, build, test, commit, and push
- Follow bare metal engineering standards (zero-dependency Win32)
