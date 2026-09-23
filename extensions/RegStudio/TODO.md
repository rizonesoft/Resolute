# RegStudio TODO

> A bare-metal Windows Registry Editor built with C++23 and Native Win32 API.

---

## Phase 0: GitHub Repository Setup

- [x] Create GitHub repository `rizonesoft/RegStudio`
- [x] Add `.gitignore` for C++/CMake projects
- [x] Add `LICENSE` file (MIT or your preferred license)
- [x] Create initial `README.md` with project overview
- [x] Push initial commit

---

## Phase 1: Project Structure

- [x] Create `CMakeLists.txt` (root)
- [x] Create `src/` directory
- [x] Create `src/main.cpp` (empty entry point stub)
- [x] Create `src/ui/` directory
- [x] Create `src/core/` directory
- [x] Create `resources/` directory
- [x] Create `resources/resource.rc` (empty stub)
- [x] Create `resources/app.manifest`
- [x] Add placeholder `resources/icon.ico`

---

## Phase 2: Build System (CMake + Ninja)

- [x] Configure CMake minimum version (3.25+)
- [x] Set C++23 standard
- [x] Add source file globbing
- [x] Configure resource compilation (.rc)
- [x] Add `-municode` compile flag (Unicode entry point)
- [x] Add `-O3 -Wall` compile flags
- [x] Add static linking flags (`-static -static-libgcc -static-libstdc++`)
- [x] Link `comctl32` (Common Controls)
- [x] Link `shlwapi` (Shell helpers)
- [x] Link `dwmapi` (DWM API)
- [x] Link `uxtheme` (Visual Styles)
- [x] Link `advapi32` (Registry API)
- [x] Verify clean build with Ninja
- [x] Verify output `.exe` runs without MinGW DLL dependencies

---

## Phase 3: Application Manifest

- [x] Add Common Controls v6 dependency
- [x] Add `requireAdministrator` execution level
- [x] Embed manifest in `resource.rc`
- [x] Verify UAC prompt appears on launch
- [x] Verify visual styles are active (non-Win95 look)

---

## Phase 4: Entry Point & Message Loop

- [x] Implement `wWinMain` entry point
- [x] Initialize Common Controls (`InitCommonControlsEx`)
- [x] Create main window class (`WNDCLASSEXW`)
- [x] Register window class
- [x] Create main window (`CreateWindowExW`)
- [x] Implement message loop (`GetMessage`, `TranslateMessage`, `DispatchMessage`)
- [x] Handle `WM_DESTROY` → `PostQuitMessage`
- [x] Verify empty window appears

---

## Phase 5: Main Window UI

### Window Chrome
- [x] Set window title to "RegStudio"
- [x] Set window icon (from resources)
- [x] Apply dark title bar (`DwmSetWindowAttribute` DWMWA_USE_IMMERSIVE_DARK_MODE)

### Layout
- [x] Create splitter/resizable panes (left/right)
- [x] Handle `WM_SIZE` for child window resizing
- [x] Store pane width ratio on resize

### Menu Bar
- [x] Create menu resource (`IDR_MAINMENU`)
- [x] File menu: Exit
- [x] Edit menu: Find, Copy, Paste
- [x] View menu: Refresh
- [x] Help menu: About

---

## Phase 6: TreeView (Registry Hive Browser)

### Control Setup
- [x] Create `SysTreeView32` control
- [x] Apply `SetWindowTheme(hTree, L"Explorer", NULL)`
- [x] Enable double-buffering (`TVS_EX_DOUBLEBUFFER`)
- [x] Add `TVS_HASBUTTONS | TVS_HASLINES | TVS_LINESATROOT`

### Root Nodes
- [x] Add `HKEY_CLASSES_ROOT` node
- [x] Add `HKEY_CURRENT_USER` node
- [x] Add `HKEY_LOCAL_MACHINE` node
- [x] Add `HKEY_USERS` node
- [x] Add `HKEY_CURRENT_CONFIG` node

### Lazy Loading
- [x] Handle `TVN_ITEMEXPANDING` notification
- [x] Enumerate subkeys on expand (`RegEnumKeyExW`)
- [x] Insert child nodes dynamically
- [x] Add dummy child for expandable nodes
- [x] Remove dummy child after real children loaded

---

## Phase 7: ListView (Value Display)

### Control Setup
- [x] Create `SysListView32` control
- [x] Apply `SetWindowTheme(hList, L"Explorer", NULL)`
- [x] Set `LVS_REPORT` style (owner data deferred)
- [x] Enable double-buffering (`LVS_EX_DOUBLEBUFFER`)
- [x] Enable full-row select (`LVS_EX_FULLROWSELECT`)

### Columns
- [x] Add "Name" column
- [x] Add "Type" column (REG_SZ, REG_DWORD, etc.)
- [x] Add "Data" column

### Virtual Mode
- [x] Handle `LVN_GETDISPINFO` notification
- [x] Implement value cache/backend vector
- [x] Set item count with `ListView_SetItemCount`

---

## Phase 8: Registry Core Engine

### RAII Wrappers
- [ ] Create `ScopedHKey` smart pointer
- [ ] Implement `KeyDeleter` for `RegCloseKey`
- [ ] Create `OpenKey()` helper function

### Key Operations
- [ ] Implement `EnumerateSubKeys(HKEY, path)` → `std::vector<std::wstring>`
- [ ] Implement `EnumerateValues(HKEY, path)` → value info structs
- [ ] Implement `ReadValue(HKEY, path, name)` → variant data
- [ ] Handle key access errors gracefully

### Value Types
- [x] Parse `REG_SZ` (string)
- [x] Parse `REG_EXPAND_SZ` (expandable string)
- [x] Parse `REG_MULTI_SZ` (multi-string)
- [x] Parse `REG_DWORD` (32-bit integer)
- [x] Parse `REG_QWORD` (64-bit integer)
- [x] Parse `REG_BINARY` (binary data)

---

## Phase 9: Tree ↔ List Integration

- [x] Handle `TVN_SELCHANGED` notification
- [x] Get selected key path from tree
- [x] Call `EnumerateValues()` for selected key
- [x] Populate ListView with values
- [x] Clear ListView on tree selection change

---

## Phase 10: Value Editing

### String Editor
- [ ] Create edit dialog for REG_SZ
- [ ] Handle REG_EXPAND_SZ editing
- [ ] Handle REG_MULTI_SZ (multiline editor)

### DWORD Editor
- [ ] Create edit dialog for REG_DWORD
- [ ] Support decimal input
- [ ] Support hexadecimal input
- [ ] Toggle between dec/hex display

### Binary/Hex Editor
- [ ] Create `IDD_HEX` dialog resource
- [ ] Implement hex byte grid display
- [ ] Implement ASCII sidebar
- [ ] Handle byte editing
- [ ] Handle copy/paste

---

## Phase 11: Key/Value Operations

### Create
- [ ] Create new key dialog
- [ ] Create new string value
- [ ] Create new DWORD value
- [ ] Create new binary value

### Delete
- [ ] Delete selected value
- [ ] Delete selected key (recursive)
- [ ] Add confirmation dialog

### Rename
- [ ] Rename selected key
- [ ] Rename selected value

### Copy/Paste
- [ ] Copy key path to clipboard
- [ ] Copy value data to clipboard

---

## Phase 12: Search

- [ ] Create search dialog (`IDD_SEARCH`)
- [ ] Search by key name
- [ ] Search by value name
- [ ] Search by value data
- [ ] Run search in `std::jthread` (background)
- [ ] Display progress indicator
- [ ] Navigate to result on selection
- [ ] Find next functionality (F3)

---

## Phase 13: Security & Privileges

### Backup Privilege
- [ ] Implement `EnablePrivilege(SE_BACKUP_NAME)`
- [ ] Use `OpenProcessToken`
- [ ] Use `LookupPrivilegeValue`
- [ ] Use `AdjustTokenPrivileges`

### Restore Privilege
- [ ] Implement `EnablePrivilege(SE_RESTORE_NAME)`

### Permission Display
- [ ] Show key permissions in status bar
- [ ] Handle access denied gracefully

---

## Phase 14: Backup & Restore

### Export
- [ ] Export key to `.reg` file (text format)
- [ ] Export key to binary hive format
- [ ] Save file dialog integration

### Import
- [ ] Import `.reg` file
- [ ] Parse REG file format
- [ ] Open file dialog integration

---

## Phase 15: Polish & UX

### Status Bar
- [x] Create status bar control
- [x] Show current key path
- [x] Show value count
- [ ] Show last error message

### Keyboard Shortcuts
- [x] F5 → Refresh
- [ ] F3 → Find Next
- [x] Ctrl+F → Find
- [ ] Delete → Delete selected
- [ ] F2 → Rename

### Context Menus
- [x] TreeView right-click menu
- [x] ListView right-click menu

### Dark Mode
- [ ] Detect system dark mode preference
- [ ] Apply dark colors to client area
- [ ] Apply dark title bar
- [ ] Handle `WM_SETTINGCHANGE` for theme switch

---

## Phase 16: Testing

- [ ] Test on Windows 10 (21H2+)
- [ ] Test on Windows 11
- [ ] Test without admin rights (verify UAC prompt)
- [ ] Test large key enumeration (HKCR\CLSID)
- [ ] Test binary value editing
- [ ] Test search across large hives
- [ ] Test export/import round-trip

---

## Phase 17: Release Preparation

- [ ] Update `README.md` with features
- [ ] Add screenshots to README
- [ ] Create `CHANGELOG.md`
- [ ] Configure GitHub Actions for CI build
- [ ] Create release build configuration
- [ ] Sign executable (optional: code signing cert)
- [ ] Create GitHub Release with `.exe`

---

## Phase 18: Production

- [ ] Tag `v1.0.0` release
- [ ] Upload release binary
- [ ] Announce release
- [ ] Monitor issues for critical bugs

---

## Future Enhancements (Backlog)

### Enhanced Search
- [ ] Search results panel (display all matches at once)
- [ ] Double-click result to jump to that key/value
- [ ] Search in key names, value names, and value data
- [ ] Search filter options (keys only, values only, data only)
- [ ] Regex search support

### Registry Compare
- [ ] Compare two registry keys in detail
- [ ] Show matching, missing, and different items
- [ ] Compare local vs remote registries
- [ ] Compare registry vs .reg file
- [ ] Visual diff view

### Registry Backup & Restore
- [ ] Full registry backup
- [ ] Selective key backup
- [ ] Scheduled backups
- [ ] Restore from backup
- [ ] Backup browser/manager

### Registry Monitor
- [ ] Real-time registry access monitoring
- [ ] Filter by process name
- [ ] Filter by operation type (read/write/delete)
- [ ] Log registry changes
- [ ] Include/exclude filters on logged items

### Security & Permissions
- [ ] View key security/permissions
- [ ] Edit access control lists (ACLs)
- [ ] Take ownership of keys
- [ ] Security audit logging

### Multi-Level Undo
- [ ] Undo any registry change (Ctrl+Z)
- [ ] Undo history list
- [ ] Redo support
- [ ] Persistent undo across sessions

### CLSID Lookup Utility
- [ ] Find COM objects by CLSID
- [ ] Display object names and servers
- [ ] Show responsible company/product
- [ ] Auto-description for CLSID keys

### File Reference Finder
- [ ] Search for file path references in registry
- [ ] Find references to non-existent files
- [ ] Batch cleanup of broken references

### Hidden Key Detection
- [ ] Search for keys with embedded NULL characters
- [ ] Detect malware-style hidden entries
- [ ] Display hidden key warnings

### Advanced Data Editor
- [ ] Hex editor for binary values
- [ ] Multi-string editor with line-by-line editing
- [ ] DWORD editor with decimal/hex toggle
- [ ] QWORD (64-bit) value support

### Key Properties Panel
- [ ] Detailed key statistics
- [ ] Last write timestamp
- [ ] Subkey and value counts
- [ ] Security descriptor info

### Customizable UI
- [ ] Tabbed interface for multiple keys
- [ ] Dockable panels
- [ ] Custom color schemes
- [ ] Layout presets
- [ ] Key coloring/highlighting

### Build & Platform
- [ ] ARM64 native build
- [ ] Command-line edition
- [ ] Remote registry editing (network)
- [ ] Registry file (.reg) editing window

### Favorites System
- [ ] Add current key to favorites
- [ ] Favorites menu/panel with categories
- [ ] Export/import favorites list
- [ ] Print favorites list
- [ ] Quick jump to favorite
- [ ] Favorite key coloring

### Address Bar & Navigation
- [ ] Address bar for direct path entry
- [ ] Paste registry paths from websites/manuals
- [ ] Auto-complete for key paths
- [ ] Breadcrumb navigation display
- [ ] Back/Forward navigation buttons
- [ ] Navigation history dropdown
- [ ] Clear history option

### Inline Editing Panel
- [ ] Edit panel (no modal dialogs)
- [ ] Keep edited value accessible while browsing
- [ ] Side-by-side comparison while editing
- [ ] Cancel/Apply buttons in edit panel

### Export Enhancements
- [ ] Export as XML format (in addition to .reg)
- [ ] Export selected keys only
- [ ] Export with timestamps
- [ ] Export multiple selected keys

### Copy & Paste Support
- [ ] Copy keys (including all subkeys) to clipboard
- [ ] Paste keys to another location
- [ ] Copy value name to clipboard
- [ ] Copy value data to clipboard
- [ ] Paste value data from clipboard

### Multi-Select Operations
- [ ] Select multiple values in ListView
- [ ] Delete multiple values at once
- [ ] Bulk operations on search results

### Portability & Settings
- [ ] Fully portable (no installation required)
- [ ] Store settings in app directory (not registry)
- [ ] 32-bit and 64-bit builds
- [ ] Settings import/export

### Registry Defragmentation
- [ ] Analyze registry fragmentation
- [ ] Defragment registry hives
- [ ] Reclaim wasted space
- [ ] Pre-defrag backup

### Printing
- [ ] Print registry keys
- [ ] Print search results
- [ ] Print favorites list
- [ ] Print comparison results

### Real Registry View (TotalRegistry)
- [ ] Show real Registry (not just standard view)
- [ ] Access hidden/internal registry keys
- [ ] Display Registry hive structure
- [ ] Show inaccessible key indicators

### Open Key Handles
- [ ] View open registry key handles
- [ ] Show which process has key open
- [ ] Force close handles (admin)

### Value Display Enhancements
- [ ] Display MUI (localized) string values
- [ ] Show REG_EXPAND_SZ expanded values
- [ ] Toggle between raw and expanded view

### ListView Enhancements
- [ ] Sort by any column (name, type, data, size)
- [ ] Column width persistence
- [ ] Custom column order

### RegEdit Replacement
- [ ] Option to replace built-in RegEdit
- [ ] Register as default .reg file handler
- [ ] Command-line compatibility with regedit.exe

### Key Visual Indicators
- [ ] Different icons for hives
- [ ] Icons for inaccessible keys
- [ ] Icons for symbolic links
- [ ] Icons for volatile keys

---

## Game-Changing Features (Innovation)

### Registry Snapshots & Timeline
- [ ] Create named registry snapshots
- [ ] Compare any two snapshots
- [ ] Timeline view of all changes
- [ ] Rollback to any snapshot
- [ ] Auto-snapshot before installations
- [ ] Snapshot scheduling (hourly/daily)

### Application Registry Profiler
- [ ] Monitor app's registry activity during install/run
- [ ] Generate complete registry footprint report
- [ ] One-click uninstall all app's registry entries
- [ ] Export app profile for documentation
- [ ] Compare before/after app installation

### Smart Registry Cleaner
- [ ] Detect orphaned software entries
- [ ] Find broken file references
- [ ] Identify invalid CLSID entries
- [ ] Detect duplicate entries
- [ ] Safe cleanup with undo support
- [ ] Scheduled automatic cleaning

### Malware & Security Scanner
- [ ] Scan for known malware registry signatures
- [ ] Detect suspicious autorun entries
- [ ] Find hidden/obfuscated keys
- [ ] Quarantine suspicious entries
- [ ] Integration with VirusTotal API
- [ ] Real-time protection mode

### PowerShell Integration
- [ ] Built-in PowerShell console
- [ ] Execute PS scripts on selected keys
- [ ] Generate PS scripts from GUI actions
- [ ] Script library/snippets manager
- [ ] Record actions as PS script

### Registry Virtualization
- [ ] Sandbox mode for safe testing
- [ ] Virtual registry layers
- [ ] Apply/discard virtual changes
- [ ] Export virtual changes to .reg
- [ ] Per-application virtual registry

### Cloud Sync & Backup
- [ ] Sync favorites across devices
- [ ] Cloud backup of registry snapshots
- [ ] Share registry snippets via link
- [ ] Team collaboration features
- [ ] Version control for registry changes

### Advanced Scripting Engine
- [ ] Built-in scripting language
- [ ] Batch operations via scripts
- [ ] Conditional logic (if key exists...)
- [ ] Loop through keys/values
- [ ] Schedule script execution
- [ ] Script debugging/breakpoints

### Registry Documentation System
- [ ] Add notes/comments to any key
- [ ] Tag keys with custom labels
- [ ] Generate documentation reports
- [ ] Link keys to external docs/URLs
- [ ] Searchable annotation database

### Performance Analytics
- [ ] Registry size analytics by hive
- [ ] Growth tracking over time
- [ ] Identify bloated keys
- [ ] Fragmentation analysis
- [ ] Performance impact scoring

### Startup Manager
- [ ] View all autorun locations
- [ ] Enable/disable startup items
- [ ] Delay startup entries
- [ ] Startup time impact analysis
- [ ] One-click optimization

### Service Manager Integration
- [ ] View service registry entries
- [ ] Start/stop services from registry
- [ ] Edit service configurations
- [ ] Service dependency mapping

### File Association Manager
- [ ] View/edit all file associations
- [ ] Bulk change associations
- [ ] Reset to Windows defaults
- [ ] Export/import associations

### Context Menu Editor
- [ ] View all context menu entries
- [ ] Add/remove/edit menu items
- [ ] Reorder context menu
- [ ] Create custom context menus

### Shell Extension Manager
- [ ] List all shell extensions
- [ ] Enable/disable extensions
- [ ] Identify problematic extensions
- [ ] Performance impact per extension

### COM/ActiveX Browser
- [ ] Browse all registered COM objects
- [ ] View type libraries
- [ ] Test COM instantiation
- [ ] Unregister broken COM objects

### Font Registry Manager
- [ ] View installed fonts via registry
- [ ] Install/uninstall fonts
- [ ] Detect font conflicts
- [ ] Font preview integration

### Environment Variables Editor
- [ ] Edit system/user env variables
- [ ] Path editor with validation
- [ ] Detect broken path entries
- [ ] Import/export variables

### Network & Firewall Registry
- [ ] View network adapter settings
- [ ] Firewall rule registry entries
- [ ] TCP/IP configuration view
- [ ] Network troubleshooting tools

### User Profile Manager
- [ ] View all user profiles
- [ ] Load/unload user hives
- [ ] Migrate user settings
- [ ] Clean orphaned profiles

### Group Policy Registry View
- [ ] Show policy-applied keys
- [ ] Indicate GPO source
- [ ] Conflict detection
- [ ] Policy documentation

### WMI Registry Browser
- [ ] Browse registry via WMI
- [ ] Cross-machine registry access
- [ ] WMI query builder

### Event Log Integration
- [ ] Link registry changes to events
- [ ] View related security events
- [ ] Audit trail for changes

### Installer Integration
- [ ] Parse MSI for registry changes
- [ ] Preview install impact
- [ ] Rollback MSI registry changes

### REST API Server
- [ ] Built-in REST API for automation
- [ ] Remote registry management
- [ ] Integration with CI/CD pipelines
- [ ] Swagger documentation

### Plugin System
- [ ] Extensible plugin architecture
- [ ] Community plugin marketplace
- [ ] Custom tool integration
- [ ] API for third-party developers

### AI-Powered Features
- [ ] Natural language registry search
- [ ] AI explanation of key purposes
- [ ] Smart cleanup recommendations
- [ ] Anomaly detection
- [ ] Predictive issue warnings

### Accessibility
- [ ] Full keyboard navigation
- [ ] Screen reader support
- [ ] High contrast themes
- [ ] Scalable UI elements
- [ ] Voice commands

### Localization
- [ ] Multi-language UI
- [ ] RTL language support
- [ ] Community translation system
- [ ] Locale-specific registry tips
