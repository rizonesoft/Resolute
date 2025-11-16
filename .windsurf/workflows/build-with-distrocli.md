---
description: How to build a Resolute program using DistroCLI
---

# Building Resolute Programs with DistroCLI

DistroCLI is a command-line interface for the Distro build system, designed for use by AI coding assistants and automation tools.

## Prerequisites

1. AutoIt3 with AutoIt3Wrapper installed
2. Inno Setup 6.x (for installer creation)
3. DistroCLI compiled and available at `R:\Resolute\SDK\DistroCLI.exe`

## Basic Usage

### Build a single program
```cmd
DistroCLI build R:\Resolute\SDK\Concrete\Firemin\Firemin.sni
```

### Generate documentation only
```cmd
DistroCLI docs R:\Resolute\SDK\Concrete\Chromin\Chromin.sni
```

### Create distribution package
```cmd
DistroCLI dist R:\Resolute\SDK\Concrete\Edgemin\Edgemin.sni
```

### Run full build pipeline
```cmd
DistroCLI all R:\Resolute\SDK\Concrete\Watermin\Watermin.sni --verbose
```

## Available Commands

- **build** - Compile executables using AutoIt3Wrapper
- **docs** - Generate documentation from .tpl templates
- **dist** - Create distribution package from [Distribute] section in .sni
- **installer** - Create Inno Setup installer
- **update** - Create update files (version.txt, etc.)
- **all** - Run complete build pipeline (build → docs → dist → installer → update)

## Build Pipeline Steps

When you run `DistroCLI all <sni-file>`, it executes these steps in order:

1. **Build** - Compiles both x86 and x64 executables
2. **Documentation** - Processes template files (Changes.tpl, Readme.tpl, License.tpl)
3. **Distribution** - Copies files to distribution folder per .sni [Distribute] section
4. **Installer** - Generates Inno Setup installer executable
5. **Update** - Creates update files for auto-update system

## Example Workflow: Building Chromin

```bash
# Navigate to SDK directory
cd R:\Resolute\SDK

# Run full build with verbose output
DistroCLI all R:\Resolute\SDK\Concrete\Chromin\Chromin.sni --verbose
```

**Expected Output:**
```
Step 1/5: Building executables...
[INFO] Running AutoIt3Wrapper on: R:\Resolute\SDK\Concrete\Chromin\Chromin.au3
[SUCCESS] Build completed

Step 2/5: Generating documentation...
[INFO] Generated: R:\Resolute\Resolute\Docs\Chromin\Changes.txt
[INFO] Generated: R:\Resolute\Resolute\Docs\Chromin\Readme.txt
[SUCCESS] Documentation generated

Step 3/5: Creating distribution...
[INFO] Distribution path: R:\Resolute\SDK\Concrete\Chromin\Distribution\8535
[SUCCESS] Distribution created

Step 4/5: Creating installer...
[INFO] Compiling installer: R:\Resolute\SDK\Concrete\Chromin\Distribution\8535\Chromin_8535_Setup.iss
[SUCCESS] Installer created

Step 5/5: Creating update files...
[INFO] Update files directory: R:\Resolute\www\updates\Chromin
[SUCCESS] Update files created

[SUCCESS] Full build pipeline completed!
```

## Error Handling

DistroCLI returns:
- **Exit code 0** - Success
- **Exit code 1** - Error (check console output for details)

Common errors:
- **SNI file not found** - Verify the path to the .sni file
- **AutoIt3Wrapper not found** - Install AutoIt3 with SciTE
- **Inno Setup not found** - Install Inno Setup 6.x
- **ScriptPath not found** - Check [Environment] section in .sni file

## Integration with AI Tools

DistroCLI is designed for AI coding assistants like Cascade/Windsurf:

```
When asked to build a Resolute program:
1. Locate the .sni file in SDK/Concrete/<ProgramName>/
2. Run: DistroCLI all <path-to-sni> --verbose
3. Monitor console output for success/failure
4. Report results to user
```

## Tips

- Use `--verbose` flag to see detailed build progress
- Run individual commands for faster iteration during development
- Check generated files in `SDK/Concrete/<Program>/Distribution/<Build>/`
- Update files go to `www/updates/<Program>/` for auto-update system
