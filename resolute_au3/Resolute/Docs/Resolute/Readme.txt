==================================================
RESOLUTE POWER TOOLS
Copyright (c) 2025 RIZONESOFT
==================================================

Version: 23.2.0.856
Release Date: 16 NOVEMBER, 2025
System Requirements: Windows 7, 8, 8.1, 10, 11
Disk Space: 0 MB
==================================================

Description
--------------------------------------------------

Resolute is the central hub for Rizonesoft's suite of system utilities and browser optimization tools. It provides a unified interface for accessing and managing all Rizonesoft power tools.

Purpose:
Resolute serves as a launcher and manager for the complete Resolute SDK ecosystem, including system repair tools, browser memory optimizers, and utility applications.

Key Features:
- Centralized access to all Rizonesoft utilities
- System repair and diagnostic tools
- Browser optimization suite (Firemin, Chromin, Edgemin, Watermin)
- Hardware information and monitoring
- System extension management
- Comprehensive logging subsystem
- Portable and installer versions available
- Multi-language support

Included Tools:
- BiosCodes - BIOS error code reference
- ComIntRep - COM interface repair utility
- DVDRepair - DVD drive diagnostic and repair
- MemBoost - System memory optimizer
- Ownership - File ownership management
- PixRepair - Pixel repair utility
- ReBar - Registry backup and restore
- Rescue - System rescue tools
- USBRepair - USB drive repair utility
- Firemin - Firefox memory optimizer
- Chromin - Chrome memory optimizer
- Edgemin - Microsoft Edge memory optimizer
- Watermin - Waterfox memory optimizer

Usage:
Simply launch Resolute.exe and select the utility you need from the main interface. Each tool can be accessed directly from the categorized menu system.

Build System - Distro:
Resolute includes the Distro Building Environment, a comprehensive GUI tool
for building and distributing all Resolute programs.

Distro Features:
- Compile executables for x86 and x64 architectures
- Generate documentation from templates with placeholder replacement
- Create distribution packages with all required files
- Build Inno Setup installers for easy deployment
- Create update files for auto-update system
- Code signing support for trusted executables
- UPX compression for smaller file sizes
- Multi-program solution management
- Build progress monitoring and logging

Build Modules:
- Build: Compile programs using AutoIt3Wrapper
- Documentation: Process templates (Changes, Readme, License) into final docs
- Distribution: Copy files to distribution folders per .sni configuration
- Installation: Generate and compile Inno Setup installers
- Update Files: Create version metadata for auto-update system
- Compression: UPX compression for executables
- Signing: Code signing with digital certificates

Template System:
Distro uses templates with placeholders for automated documentation:
- 23.2.0.856 - Version number from build configuration
- RIZONESOFT - Company name (Rizonesoft)
- https://www.rizonesoft.com - Company website
- 16, NOVEMBER, 2025 - Current date components
- 0 MB - Installation size
- RESOLUTE POWER TOOLS - Full release name

Solution INI Files:
Each program has a .sni file defining build configuration:
- Build settings and module selection
- Environment metadata (version, paths, etc.)
- Distribution file lists
- Signing configuration
- Located in SDK/Concrete/<Program>/<Program>.sni

Distro Location:
- Executable: R:\Resolute\SDK\Distro.exe
- Source: R:\Resolute\SDK\Concrete\Distro\Distro.au3
- Note: Distro builds other programs, not itself

For Developers:
The Resolute SDK provides a complete framework for building, documenting,
and distributing Windows utilities. All programs follow the same structure
with Templates/, .sni files, and standardized build processes.

==================================================
https://www.rizonesoft.com
