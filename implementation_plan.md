# Resolute .NET 10 Migration Plan

## Overview
The goal is to port the existing Resolute system (currently written in AutoIt) to .NET 10. The system acts as a dashboard/launcher for various system utilities and provides system monitoring capabilities.

## Technology Stack
- **Framework**: .NET 10
- **UI Framework**: WPF (Windows Presentation Foundation)
  - *Reasoning*: WPF offers superior styling capabilities, better high-DPI support, and a more modern architecture (MVVM) compared to WinForms. It is better suited for a "premium" dashboard application.
- **Language**: C#

## Architecture
We will structure the solution as follows:

## Architecture
We will structure the solution to allow for both a unified dashboard and separately distributable tools.

## Architecture
We will structure the solution to allow for both a unified dashboard and separately distributable tools.

### 1. ResoluteX3.Solution
The main Visual Studio solution.

### 2. Projects
- **ResoluteX3.Core (Class Library)**
  - Shared logic, business rules, and common UI components.
  - **Services**: Logging, Configuration, Localization, System Utilities.
  - Used by both the Dashboard and individual tools.
- **ResoluteX3.Dashboard (WPF App)**
  - The main launcher/dashboard application.
  - Monitors system status (CPU/RAM).
  - Launches the individual tools.
  - Manages the suite.
- **ResoluteX3.Tools.[ToolName] (WPF Apps)**
  - Separate projects for each tool (e.g., `ResoluteX3.Tools.Firemin`, `ResoluteX3.Tools.DVDRepair`).
  - Each tool is a standalone executable.
  - References `ResoluteX3.Core` for shared functionality.

## Features to Port
### Phase 1: Foundation & Dashboard
1.  **Core Library**: Implement shared services (Logging, Config, etc.).
2.  **Dashboard UI**: Recreate the main launcher interface.
3.  **System Monitoring**: Real-time CPU/RAM usage in the dashboard.

### Phase 2: Porting Tools
We will port each tool one by one as a separate project.
- **Firemin**: Memory optimization tool.
- **DVDRepair**: Drive repair utility.
- **BiosCodes**: BIOS beep code viewer.
- ... and others.

### Phase 3: Integration
- Ensure the Dashboard can detect and launch the ported tools.
- Ensure each tool can run independently (standalone mode).

## Migration Steps
1.  Initialize the .NET 10 WPF solution (ResoluteX3).
2.  Create `ResoluteX3.Core` library.
3.  Create `ResoluteX3.Dashboard` project.
4.  Create the first tool project (e.g., `ResoluteX3.Tools.Firemin`) to validate the shared architecture.
