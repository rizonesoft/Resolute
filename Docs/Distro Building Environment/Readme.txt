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

Distro is the graphical build environment for the Resolute SDK. It provides a comprehensive GUI for building, documenting, and distributing all Resolute programs.

Purpose:
Distro serves as the central build tool for the entire Resolute ecosystem, managing compilation, documentation generation, distribution packaging, installer creation, and update file management for all programs in the SDK.

Key Features:
- Graphical build interface with solution management
- Multi-program build support
- AutoIt3Wrapper integration for compilation
- Template-based documentation generation
- Distribution package creation
- Inno Setup installer generation
- Update file management
- Comprehensive logging subsystem
- Build progress monitoring
- Prerequisite checking
- Solution INI (.sni) file management

Build Modules:
- Build - Compile executables using AutoIt3Wrapper
- Compress - UPX compression for executables
- Sign - Code signing with digital certificates
- Documentation - Generate docs from templates
- Distribute - Create distribution packages
- Portable - Build portable versions
- Installation - Create installers with Inno Setup
- Update Files - Generate update metadata

Supported Programs:
Distro can build all 13 Resolute programs:

Browser Memory Optimizers:
- Firemin - Firefox memory optimizer
- Chromin - Chrome memory optimizer
- Edgemin - Microsoft Edge memory optimizer
- Watermin - Waterfox memory optimizer

System Utilities:
- BiosCodes - BIOS error code reference
- ComIntRep - COM interface repair utility
- DVDRepair - DVD drive diagnostic and repair
- MemBoost - System memory optimizer
- Ownership - File ownership management
- PixRepair - Pixel repair utility
- ReBar - Registry backup and restore
- Rescue - System rescue tools
- USBRepair - USB drive repair utility

Build System Tools:
- Resolute - Program launcher and SDK host
- DistroCLI - Command-line build automation

Template System:
Distro processes template files (.tpl) with placeholders:
- %{RELEASE} - Program release name
- %{VERSION} - Version number
- %{COMPANY} - Company name
- %{COMPANYURL} - Company website
- %{DAY}, %{MONTH}, %{YEAR} - Date components
- %{INSTSIZE} - Installation size

Solution INI Files:
Each program has a .sni file defining:
- Build configuration and modules
- Environment metadata (version, paths, etc.)
- Distribution file lists
- Signing configuration

Usage:
1. Launch Distro.exe
2. Select a solution (.sni file) from the list
3. Choose build modules to execute
4. Click Run to start the build process
5. Monitor progress in the logging window

Requirements:
- AutoIt3 with AutoIt3Wrapper (for Build module)
- Inno Setup 6.x (for Installation module)
- Code signing certificate (optional, for Sign module)
- UPX (optional, for Compress module)

Build Output:
- Executables: Resolute/<Program>.exe, <Program>_X64.exe
- Documentation: Resolute/Docs/<Program>/*.txt
- Distribution: SDK/Concrete/<Program>/Distribution/<Build>/
- Installers: Distribution folder with _Setup.exe suffix
- Updates: www/updates/<Program>/version.txt

Command-Line Alternative:
For automation and AI integration, use DistroCLI:
- DistroCLI all <sni-file> --verbose
- See DistroCLI documentation for details

For Developers:
The Distro source code demonstrates:
- GUI development with AutoIt
- Build system architecture
- Template processing
- Solution management
- Process orchestration
- Logging subsystems

Documentation:
- SDK Framework: .windsurf/docs/resolute-framework-distro.md
- DistroCLI Reference: .windsurf/docs/distrocli-reference.md
- Build Workflows: .windsurf/workflows/

==================================================
%{COMPANYURL}
