==================================================
DISTROCLI CHANGES
==================================================

--------------------------------------------------
Version %{VERSION} (%{MONTH} %{DAY}, %{YEAR})
--------------------------------------------------

Bug Fixes:
- Fixed: Icon configuration - now correctly uses Distro.ico

Platform and Toolchain:
- Updated: AutoIt to version 3.3.18.0

==================================================

--------------------------------------------------
Version 1.0.0.0 (NOVEMBER 16, 2025)
--------------------------------------------------

Initial Release:
- Command-line interface for Resolute SDK build system
- Designed for AI coding assistants and automation tools
- Full build pipeline automation

Build Commands:
- build      - Compile executables via AutoIt3Wrapper
- docs       - Generate documentation from templates
- dist       - Create distribution packages
- installer  - Create Inno Setup installers
- update     - Create update files
- all        - Run complete build pipeline

Features:
- SNI file parsing and configuration loading
- AutoIt3Wrapper integration for compilation
- Template processing for documentation
- Distribution folder management
- Inno Setup installer generation
- Update file creation
- Verbose output mode for debugging
- Exit codes for automation (0=success, 1=error)

Documentation:
- Comprehensive workflow guide (.windsurf/workflows/build-with-distrocli.md)
- Complete reference documentation (.windsurf/docs/distrocli-reference.md)
- AI usage rules (.windsurf/rules/distrocli-usage.md)

Supported Programs:
- All 13 Resolute programs can be built via DistroCLI
- Firemin, Chromin, Edgemin, Watermin (browser optimizers)
- BiosCodes, ComIntRep, DVDRepair, MemBoost, Ownership
- PixRepair, ReBar, Rescue, USBRepair (system utilities)

Usage Examples:
- DistroCLI build <sni-file>
- DistroCLI all <sni-file> --verbose
- DistroCLI docs <sni-file>

Integration:
- Designed for Windsurf and other AI coding assistants
- Enables automated building from AI tools
- Consistent, reproducible builds
- Full pipeline automation

==================================================
