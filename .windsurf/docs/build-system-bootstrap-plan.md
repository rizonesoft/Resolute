# Build System Bootstrap Plan

## Problem Statement

The Resolute build system consists of three core tools that need proper documentation, language support, and build automation:

1. **Distro** - GUI build tool for compiling programs
2. **DistroCLI** - CLI build tool for automation
3. **Resolute** - Main program launcher/manager

**Challenge:** These tools build other programs, but they also need to be built themselves. Distro has a circular dependency - it would need to build itself.

## Current State

| Tool | Templates | .sni | Docs | Languages | Notes |
|------|-----------|------|------|-----------|-------|
| Distro | ❌ | ❌ | ❌ | ❌ | No structure exists |
| DistroCLI | ❌ | ❌ | ❌ | ❌ | Just created, minimal |
| Resolute | ❌ | ❌ | ✅ Partial | ✅ en.ini | Has Changes.txt, License.txt |

### Existing Files

**Resolute:**
- `Resolute/Docs/Resolute/Changes.txt` ✅
- `Resolute/Docs/Resolute/License.txt` ✅
- `Resolute/Language/Resolute/en.ini` ✅
- Missing: Readme.txt, Templates/

**Distro:**
- No documentation structure
- No language files
- No templates

**DistroCLI:**
- No documentation structure
- No language files  
- No templates
- Has .windsurf docs for user reference

## Proposed Solution

### Phase 1: Create Template Structures

Create standard SDK structure for all three tools:

```
SDK/Concrete/Distro/
├── Distro.au3 (exists)
├── Distro.sni (new)
├── Distro.ini (new)
└── Templates/
    ├── Changes.tpl (new)
    ├── Readme.tpl (new)
    ├── License.tpl (new)
    └── Setup.iss.tpl (optional)

SDK/Concrete/DistroCLI/
├── DistroCLI.au3 (exists)
├── DistroCLI.sni (new)
├── DistroCLI.ini (new)
└── Templates/
    ├── Changes.tpl (new)
    ├── Readme.tpl (new)
    ├── License.tpl (new)
    └── Setup.iss.tpl (optional)

SDK/Concrete/Resolute/
├── Resolute.au3 (exists)
├── Resolute.sni (new)
├── Resolute.ini (new - if needed)
└── Templates/
    ├── Changes.tpl (new - migrate from existing)
    ├── Readme.tpl (new)
    ├── License.tpl (new - migrate from existing)
    └── Setup.iss.tpl (optional)
```

### Phase 2: Language File Strategy

**Option A: Shared Language Files (Recommended)**
- Create `Language/BuildSystem/` for shared strings
- All three tools reference same language files
- Reduces duplication
- Consistent terminology

**Option B: Separate Language Files**
- `Language/Distro/`
- `Language/DistroCLI/`
- `Language/Resolute/` (exists)
- More granular control
- More maintenance

**Recommendation:** Use shared `Language/BuildSystem/` with program-specific overrides where needed.

### Phase 3: Build Automation Strategies

#### For Resolute & DistroCLI

These can be built FROM Distro since they're not self-referential:

1. Create `.sni` files
2. Add to Distro's solution list
3. Build via Distro GUI or DistroCLI

```bash
# Build Resolute
DistroCLI all R:\Resolute\SDK\Concrete\Resolute\Resolute.sni

# Build DistroCLI
DistroCLI all R:\Resolute\SDK\Concrete\DistroCLI\DistroCLI.sni
```

#### For Distro (Circular Dependency)

**Option 1: Bootstrap Script**
Create `SDK/Concrete/Distro/Build.au3` - a minimal script that:
1. Compiles Distro.au3 directly
2. Generates docs from templates
3. Creates distribution
4. Doesn't require Distro itself

**Option 2: Manual Build**
Keep Distro's build directives in the .au3 file:
```autoit
#AutoIt3Wrapper_OutFile=..\..\..\SDK\Distro.exe
```
Compile manually via AutoIt3Wrapper when needed.

**Option 3: Two-Stage Build**
1. Compile initial Distro.exe manually
2. Use that version to build itself via .sni
3. Replace with newly built version

**Recommendation:** Use Option 1 (Bootstrap Script) for clean separation.

### Phase 4: Documentation Content

#### Changes.tpl Structure

For all three tools, use standard format:

```
==================================================
[PROGRAM NAME] CHANGES
==================================================

--------------------------------------------------
Version %{VERSION} (%{MONTH} %{DAY}, %{YEAR})
--------------------------------------------------

[Recent changes - parameterized for current version]

--------------------------------------------------
Version [X.X.X.X] ([Previous Date])
--------------------------------------------------

[Historical changes - static]

==================================================
```

#### Readme.tpl Structure

```
==================================================
[PROGRAM NAME]
Copyright (c) %{YEAR} %{COMPANY}
==================================================

Version: %{VERSION}
Release Date: %{DAY} %{MONTH}, %{YEAR}
System Requirements: Windows 7, 8, 8.1, 10, 11

==================================================

Description
--------------------------------------------------

[Tool-specific description]

Purpose:
[What it does]

Key Features:
[Bullet points]

Usage:
[Basic usage instructions]

==================================================
%{COMPANYURL}
```

#### License.tpl

Use standard Rizonesoft GPL template (same across all tools).

### Phase 5: .sni File Configuration

#### Distro.sni Example

```ini
[Rizonesoft SDK]
Compatibilty = Rizonesoft SDK 11
Script = Distro.au3

[Modules]
Build = 1
Compress = 0
Sign = 0
Documentation = 1
Import = 0
Distribute = 1
Portable = 0
Installation = 0
UpdateFile = 1

[Signing]
CertificateSet = Signing\Signing.ini
Website = https://rizonesoft.com

[Distribute]
File=%RootDir%\SDK\Distro.exe
File=%RootDir%\SDK\Distro_X64.exe
File=%RootDir%\Docs\Distro\Changes.txt
File=%RootDir%\Docs\Distro\Readme.txt
File=%RootDir%\Docs\Distro\License.txt

[Environment]
ScriptPath=R:\Resolute\SDK\Concrete\Distro\Distro.au3
Company=Rizonesoft
CompanyURL=https://rizonesoft.com
Name=Distro
ShortName=Distro
Description=Distro Building Environment
Type=N
Icon=R:\Resolute\SDK\Resources\Icons\Distro.ico
Version=11.1.1.3684
DistributionPath=R:\Resolute\SDK\Concrete\Distro\Distribution\3684
```

Similar structures for DistroCLI.sni and Resolute.sni.

### Phase 6: Language File Structure

#### BuildSystem/en.lng (or .ini)

```ini
[Program]
Name=Build System
Company=Rizonesoft

[Distro]
Name=Distro Building Environment
Description=GUI tool for building Resolute programs
; ... Distro-specific strings

[DistroCLI]
Name=DistroCLI
Description=Command-line build automation tool
; ... DistroCLI-specific strings

[Resolute]
Name=Resolute
Description=Resolute program launcher and manager
; ... Resolute-specific strings

[Common]
; Shared strings across all build tools
BuildSuccess=Build completed successfully
BuildFailed=Build failed
Processing=Processing...
; ... etc
```

## Implementation Order

### Step 1: Resolute (Easiest - Has Most Structure)
1. Create `SDK/Concrete/Resolute/Templates/`
2. Migrate existing Changes.txt → Changes.tpl
3. Migrate existing License.txt → License.tpl
4. Create new Readme.tpl
5. Create Resolute.sni
6. Test build via Distro or DistroCLI

### Step 2: DistroCLI (Medium - New Tool)
1. Create `SDK/Concrete/DistroCLI/Templates/`
2. Write Changes.tpl (documenting v1.0.0 initial release)
3. Write Readme.tpl (command-line usage)
4. Copy License.tpl from Resolute
5. Create DistroCLI.sni
6. Test build via Distro

### Step 3: Distro (Hardest - Self-Referential)
1. Create `SDK/Concrete/Distro/Templates/`
2. Write Changes.tpl (documenting current version 11.1.1.3684)
3. Write Readme.tpl (GUI usage guide)
4. Copy License.tpl
5. Create Distro.sni
6. Create Build.au3 bootstrap script
7. Test bootstrap build

### Step 4: Language Files
1. Create `Resolute/Language/BuildSystem/` directory
2. Create en.lng with all strings for three tools
3. Update programs to use shared language files
4. Test localization system

### Step 5: Integration & Testing
1. Test building all three via DistroCLI
2. Verify docs generation
3. Confirm language loading
4. Update .gitignore for new Distribution/ folders

## File Count Estimate

**Per Tool:**
- 1 .sni file
- 3-4 .tpl files
- 1 .ini file (optional)

**Total New Files:**
- 9-12 template files
- 3 .sni files
- 1-3 language files (depending on strategy)
- 1 bootstrap script (for Distro)

**Total:** ~15-20 new files

## Benefits

1. **Consistency** - All tools follow same documentation structure
2. **Automation** - Can build/update docs automatically
3. **Localization** - Can translate build tools
4. **Professional** - Proper documentation for all components
5. **Maintainable** - Templates are source of truth
6. **Self-Documenting** - Build system documents itself

## Risks & Mitigation

| Risk | Mitigation |
|------|------------|
| Circular dependency for Distro | Use bootstrap script |
| Language file complexity | Start with English only, expand later |
| Breaking existing workflows | Keep backwards compatibility |
| Documentation drift | Make templates authoritative source |

## Success Criteria

- ✅ All three tools have complete template sets
- ✅ All three tools have .sni files
- ✅ Can build Resolute via DistroCLI
- ✅ Can build DistroCLI via DistroCLI
- ✅ Can build Distro via bootstrap script
- ✅ Generated docs match template format
- ✅ Language files load correctly
- ✅ No disruption to existing program builds

## Next Steps

1. **Approve this plan** - Review and confirm approach
2. **Start with Resolute** - Lowest risk, fastest value
3. **Iterate to DistroCLI** - Build on Resolute patterns
4. **Tackle Distro last** - Most complex, needs bootstrap
5. **Add languages** - After core structure is stable

## Questions to Resolve

1. **Language file format?** - .lng vs .ini for build tools?
2. **Shared vs separate?** - One BuildSystem folder or three separate?
3. **Bootstrap complexity?** - How sophisticated should Distro bootstrap be?
4. **Installation support?** - Do build tools need installers or stay portable?
5. **Update system?** - Should build tools auto-update like other programs?
