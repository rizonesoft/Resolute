# DistroCLI Reference Documentation

## Overview

DistroCLI is a command-line build tool for the Resolute SDK framework. It provides automated building, documentation generation, distribution packaging, installer creation, and update file management.

## Architecture

DistroCLI reads `.sni` (Solution INI) files which contain build configuration and metadata for each Resolute program. It orchestrates the build process by:

1. Parsing the .sni file for configuration
2. Invoking AutoIt3Wrapper for compilation
3. Processing template files to generate documentation
4. Copying files to distribution folders
5. Creating installers via Inno Setup
6. Generating update metadata

## Solution INI (.sni) File Format

Each Resolute program has a `.sni` file that defines its build configuration:

```ini
[Rizonesoft SDK]
Script = ProgramName.au3

[Modules]
Build = 1
Documentation = 1
Distribute = 1
Installation = 1
UpdateFile = 1

[Environment]
ScriptPath = R:\Resolute\SDK\Concrete\ProgramName\ProgramName.au3
Company = Rizonesoft
Name = ProgramName
ShortName = ProgramName
Version = 11.8.3.8535
DistributionPath = R:\Resolute\SDK\Concrete\ProgramName\Distribution\8535

[Distribute]
File = %RootDir%\ProgramName.exe
File = %RootDir%\ProgramName_X64.exe
File = %RootDir%\Docs\ProgramName\Changes.txt
File = %RootDir%\Docs\ProgramName\Readme.txt
File = %RootDir%\Docs\ProgramName\License.txt
```

### Placeholders in .sni Files

- `%RootDir%` - Resolves to `R:\Resolute\Resolute`
- `%SourceDir%` - Resolves to the directory containing the .sni file

## Command Reference

### build

Compiles the AutoIt3 script using AutoIt3Wrapper.

**Usage:**
```
DistroCLI build <sni-file> [--verbose]
```

**Process:**
1. Reads `ScriptPath` from .sni [Environment] section
2. Locates AutoIt3Wrapper at `C:\Program Files\AutoIt3\SciTE\AutoIt3Wrapper\`
3. Executes compilation for both x86 and x64 if configured
4. Outputs executables to paths specified in AutoIt3Wrapper directives

**AutoIt3Wrapper Directives:**
The script itself contains directives that control compilation:
- `#AutoIt3Wrapper_Compile_both=Y` - Compile both architectures
- `#AutoIt3Wrapper_OutFile` - x86 output path
- `#AutoIt3Wrapper_OutFile_X64` - x64 output path

### docs

Generates documentation by copying template files from `Templates/` to `Resolute/Docs/<ProgramName>/`.

**Usage:**
```
DistroCLI docs <sni-file> [--verbose]
```

**Process:**
1. Locates `Templates/` folder relative to .sni file
2. Finds all `.tpl` files (Changes.tpl, Readme.tpl, License.tpl, Setup.iss.tpl)
3. Copies to `Resolute/Docs/<ProgramName>/` with `.txt` extension
4. Template placeholders should be pre-processed by Distro.au3

**Template Files:**
- `Changes.tpl` → `Changes.txt` - Version history and changelog
- `Readme.tpl` → `Readme.txt` - Program description and instructions
- `License.tpl` → `License.txt` - License and privacy policy
- `Setup.iss.tpl` → Used for installer, not copied to Docs

### dist

Creates the distribution folder and copies files listed in [Distribute] section.

**Usage:**
```
DistroCLI dist <sni-file> [--verbose]
```

**Process:**
1. Creates directory at `DistributionPath` from .sni
2. Reads all `File=` entries from [Distribute] section
3. Resolves placeholders (%RootDir%, %SourceDir%)
4. Copies each file to distribution folder
5. Maintains relative structure for Language/ and other subdirectories

**Distribution Structure:**
```
SDK/Concrete/ProgramName/Distribution/8535/
├── ProgramName_8535/
│   ├── ProgramName.exe
│   ├── ProgramName_X64.exe
│   ├── Docs/
│   │   ├── Changes.txt
│   │   ├── Readme.txt
│   │   └── License.txt
│   └── Language/
│       └── Firemin/
│           ├── en.lng
│           ├── es.lng
│           └── ...
├── ProgramName_8535_Setup.iss
└── ProgramName_8535_Setup.exe
```

### installer

Creates an Inno Setup installer executable.

**Usage:**
```
DistroCLI installer <sni-file> [--verbose]
```

**Process:**
1. Locates setup script at `<DistributionPath>/<ShortName>_Setup.iss`
2. Finds Inno Setup compiler at `C:\Program Files\Inno Setup 6\ISCC.exe`
3. Compiles installer script
4. Outputs `<ShortName>_<Build>_Setup.exe` in distribution folder

**Requirements:**
- Inno Setup 6.x must be installed
- Setup.iss.tpl must be processed by Distro first
- All distribution files must exist

### update

Creates update metadata files for the auto-update system.

**Usage:**
```
DistroCLI update <sni-file> [--verbose]
```

**Process:**
1. Creates `www/updates/<ProgramName>/` directory
2. Writes `version.txt` with current version number
3. Additional update files can be added here

**Update File Structure:**
```
www/updates/ProgramName/
└── version.txt (contains: 11.8.3.8535)
```

### all

Runs the complete build pipeline in sequence.

**Usage:**
```
DistroCLI all <sni-file> [--verbose]
```

**Execution Order:**
1. build
2. docs
3. dist
4. installer
5. update

**Stops on first error** - If any step fails, the pipeline halts and returns the error code.

## Exit Codes

- **0** - Success
- **1** - Error (details written to console/stderr)

## Verbose Mode

Add `--verbose` or `-v` flag to any command for detailed output:

```
DistroCLI build Firemin.sni --verbose
```

Shows:
- Configuration being loaded
- Files being processed
- AutoIt3Wrapper output
- File copy operations
- Inno Setup compiler output

## Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| SNI file not found | Invalid path or file doesn't exist | Check path to .sni file |
| ScriptPath not found in SNI | Missing [Environment] section | Add ScriptPath to .sni |
| AutoIt3Wrapper not found | AutoIt3 not installed | Install AutoIt3 with SciTE |
| Script not found | .au3 file missing | Check ScriptPath in .sni |
| Inno Setup not found | Inno Setup not installed | Install Inno Setup 6.x |
| DistributionPath not set | Missing in [Environment] | Add DistributionPath to .sni |

## Best Practices

1. **Always use full paths** in .sni files to avoid ambiguity
2. **Test individual commands** before running `all`
3. **Use --verbose** when debugging build issues
4. **Keep .sni files synchronized** with actual file locations
5. **Version control .sni files** along with source code

## Integration Examples

### PowerShell Script
```powershell
$programs = @("Firemin", "Chromin", "Edgemin", "Watermin")
foreach ($prog in $programs) {
    $sni = "R:\Resolute\SDK\Concrete\$prog\$prog.sni"
    Write-Host "Building $prog..."
    & "R:\Resolute\SDK\DistroCLI.exe" all $sni --verbose
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Build failed for $prog"
        exit 1
    }
}
```

### Batch File
```batch
@echo off
SET SDK_PATH=R:\Resolute\SDK
%SDK_PATH%\DistroCLI.exe all %SDK_PATH%\Concrete\Firemin\Firemin.sni --verbose
if %ERRORLEVEL% neq 0 (
    echo Build failed
    exit /b 1
)
echo Build successful
```

## See Also

- `.windsurf/workflows/build-with-distrocli.md` - Step-by-step workflow
- `.windsurf/docs/resolute-framework-distro.md` - Resolute SDK documentation
- `SDK/Concrete/Distro/Distro.au3` - GUI version of build system
