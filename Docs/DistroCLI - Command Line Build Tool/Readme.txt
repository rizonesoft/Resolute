==================================================
%{RELEASE}
Copyright (c) %{YEAR} %{COMPANY}
==================================================

Version: %{VERSION}
Release Date: %{DAY} %{MONTH}, %{YEAR}
System Requirements: Windows 7, 8, 8.1, 10, 11
Disk Space: %{INSTSIZE}
==================================================

Description
--------------------------------------------------

DistroCLI is a command-line interface for the Resolute SDK build system, designed specifically for AI coding assistants and automation tools. It provides programmatic access to the complete build pipeline used by all Resolute programs.

Purpose:
Enable automated building, documentation generation, distribution packaging, installer creation, and update file management through a simple command-line interface. Perfect for integration with AI assistants like Windsurf/Cascade, CI/CD pipelines, and build automation scripts.

Key Features:
- Command-line build automation
- SNI file parsing and configuration
- AutoIt3Wrapper integration
- Template-based documentation generation
- Distribution package creation
- Inno Setup installer generation
- Update file management
- Verbose output mode
- Clear exit codes for automation
- Designed for AI assistant integration

Available Commands:
- build      - Compile executables using AutoIt3Wrapper
- docs       - Generate documentation from .tpl templates
- dist       - Create distribution packages from [Distribute] section
- installer  - Build Inno Setup installers
- update     - Create update files (version.txt, etc.)
- all        - Run complete build pipeline (build → docs → dist → installer → update)
- version    - Show version information
- help       - Display usage help

Usage Examples:
# Build a single program
DistroCLI build R:\Resolute\SDK\Concrete\Firemin\Firemin.sni

# Generate documentation only
DistroCLI docs R:\Resolute\SDK\Concrete\Chromin\Chromin.sni

# Run full build pipeline with verbose output
DistroCLI all R:\Resolute\SDK\Concrete\Edgemin\Edgemin.sni --verbose

# Create distribution package
DistroCLI dist R:\Resolute\SDK\Concrete\Watermin\Watermin.sni

Options:
--verbose, -v    Show detailed build output
--help, -h       Display help message

Exit Codes:
0 - Success
1 - Error (details written to console)

Requirements:
- AutoIt3 with AutoIt3Wrapper (for build command)
- Inno Setup 6.x (for installer command)
- Valid .sni file with [Environment] section

Supported Programs:
DistroCLI can build all 13 Resolute programs:
- Firemin, Chromin, Edgemin, Watermin (browser memory optimizers)
- BiosCodes, ComIntRep, DVDRepair, MemBoost, Ownership
- PixRepair, ReBar, Rescue, USBRepair (system utilities)

AI Assistant Integration:
DistroCLI is specifically designed for AI coding assistants:
- Simple command-line interface
- Clear success/failure reporting
- Verbose mode for detailed feedback
- Consistent exit codes
- Full pipeline automation

When an AI assistant needs to build a Resolute program:
1. Locate the .sni file in SDK/Concrete/<Program>/
2. Run: DistroCLI all <sni-file> --verbose
3. Monitor console output for results
4. Report success or errors to user

Documentation:
- Workflow Guide: .windsurf/workflows/build-with-distrocli.md
- Reference Docs: .windsurf/docs/distrocli-reference.md
- AI Usage Rules: .windsurf/rules/distrocli-usage.md

For More Information:
See the comprehensive documentation in the .windsurf directory or visit the Rizonesoft website for SDK documentation and support.

==================================================
%{COMPANYURL}
