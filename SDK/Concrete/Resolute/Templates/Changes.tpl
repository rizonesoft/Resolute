==================================================
RIZONESOFT RESOLUTE CHANGES
==================================================

--------------------------------------------------
Version %{VERSION} (%{MONTH} %{DAY}, %{YEAR})
--------------------------------------------------

Build System Tools:
- Added: DistroCLI - Command-line build automation tool for AI assistants
- Enhanced: Distro with improved solution management and build pipeline
- Improved: Template-based documentation generation system

==================================================

--------------------------------------------------
Version 11.0.0.0 (NOVEMBER 16, 2025)
--------------------------------------------------

Browser Variants:
- Added: Chromin - Chrome browser memory optimizer
- Added: Edgemin - Microsoft Edge browser memory optimizer
- Added: Watermin - Waterfox browser memory optimizer
- All variants share Firemin language files using %{Program.Name} placeholders
- All variants use centralized icons from SDK/Resources/Icons

SDK Framework Improvements:
- Enhanced: Distro build system with dynamic [Files] section generation from .sni files
- Added: Portable installer support with distinct x86/x64 executable names
- Centralized: Icon resources in SDK/Resources/Icons (shared across all programs)
- Added: SDK/Resources/Source/Icons for design source files (.ai, PNG exports)
- Updated: All programs with SDK language system improvements:
  - Enhanced language system with improved string handling, caching, and RTL support
  - Fixed Unicode encoding and line break handling in language files
  - Added automatic language file formatting and consistency checks
  - Optimized memory usage in localization system

Platform and Toolchain (All Programs):
- Updated: AutoIt to version 3.3.18.0

Build System:
- Added: Comprehensive .gitignore for build artifacts and distribution folders
- Removed: Obsolete top-level Distribution folder
- Removed: samples/Firemin directory (all resources migrated to SDK)
- Enhanced: Template-based installer script generation

URL Standardization:
- Updated: All Rizonesoft URLs from https://www.rizonesoft.com to https://rizonesoft.com
- Applied: URL updates across all .sni files, .au3 files, and templates

Documentation:
- Updated: Changes.tpl templates for all programs with SDK improvements
- Added: Windsurf workflows and documentation for Resolute framework
- Maintained: Version placeholders for unreleased changes

Programs Updated:
- BiosCodes, ComIntRep, DVDRepair, Firemin, MemBoost, Ownership
- PixRepair, ReBar, Rescue, USBRepair, Chromin, Edgemin, Watermin

--------------------------------------------------
Version 0.0.0.0
--------------------------------------------------

- Improved the Resolute tool execution process and implemented comprehensive logging mechanisms.
- Resolved issues pertaining to the functionality of the System Repair buttons.
- Introduced Hardware, System, and Extension menus.

==================================================
