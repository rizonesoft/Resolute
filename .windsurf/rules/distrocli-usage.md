# DistroCLI Usage Rules for AI Assistants

When building or updating Resolute programs, use DistroCLI for automated builds.

## When to Use DistroCLI

Use DistroCLI when:
- Building a Resolute program for the first time
- Updating an existing program and needing to rebuild
- Creating distribution packages for release
- Generating documentation from templates
- Creating installers for distribution
- Testing build configurations

## Command Selection

### For Quick Iteration (Development)
```bash
# Build only - fastest for testing code changes
DistroCLI build R:\Resolute\SDK\Concrete\<Program>\<Program>.sni

# Docs only - when updating templates
DistroCLI docs R:\Resolute\SDK\Concrete\<Program>\<Program>.sni
```

### For Release Preparation
```bash
# Full pipeline - everything needed for release
DistroCLI all R:\Resolute\SDK\Concrete\<Program>\<Program>.sni --verbose
```

### For Specific Steps
```bash
# Distribution package only
DistroCLI dist R:\Resolute\SDK\Concrete\<Program>\<Program>.sni

# Installer only (after dist has been created)
DistroCLI installer R:\Resolute\SDK\Concrete\<Program>\<Program>.sni

# Update files only
DistroCLI update R:\Resolute\SDK\Concrete\<Program>\<Program>.sni
```

## Standard Workflow

When a user asks to "build" a Resolute program:

1. **Locate the .sni file**
   ```
   Path pattern: R:\Resolute\SDK\Concrete\<ProgramName>\<ProgramName>.sni
   ```

2. **Run DistroCLI**
   ```bash
   DistroCLI all R:\Resolute\SDK\Concrete\<ProgramName>\<ProgramName>.sni --verbose
   ```

3. **Monitor output**
   - Watch for SUCCESS/FAILED messages
   - Check exit code (0 = success, 1 = failure)

4. **Report results**
   - Confirm successful build steps
   - Report any errors encountered
   - Note output locations (Distribution/, Docs/, etc.)

## Program Locations

Available Resolute programs and their .sni files:

| Program | Path |
|---------|------|
| Firemin | `R:\Resolute\SDK\Concrete\Firemin\Firemin.sni` |
| Chromin | `R:\Resolute\SDK\Concrete\Chromin\Chromin.sni` |
| Edgemin | `R:\Resolute\SDK\Concrete\Edgemin\Edgemin.sni` |
| Watermin | `R:\Resolute\SDK\Concrete\Watermin\Watermin.sni` |
| BiosCodes | `R:\Resolute\SDK\Concrete\BiosCodes\BiosCodes.sni` |
| ComIntRep | `R:\Resolute\SDK\Concrete\ComIntRep\ComIntRep.sni` |
| DVDRepair | `R:\Resolute\SDK\Concrete\DVDRepair\DVDRepair.sni` |
| MemBoost | `R:\Resolute\SDK\Concrete\MemBoost\MemBoost.sni` |
| Ownership | `R:\Resolute\SDK\Concrete\Ownership\Ownership.sni` |
| PixRepair | `R:\Resolute\SDK\Concrete\PixRepair\PixRepair.sni` |
| ReBar | `R:\Resolute\SDK\Concrete\ReBar\ReBar.sni` |
| Rescue | `R:\Resolute\SDK\Concrete\Rescue\Rescue.sni` |
| USBRepair | `R:\Resolute\SDK\Concrete\USBRepair\USBRepair.sni` |

## Error Handling

If DistroCLI fails:

1. **Check prerequisites**
   - AutoIt3 installed with SciTE/AutoIt3Wrapper
   - Inno Setup 6.x installed (for installer step)
   - .sni file exists and is valid

2. **Common fixes**
   - Missing ScriptPath: Add to [Environment] section in .sni
   - AutoIt3Wrapper not found: Install AutoIt3
   - Inno Setup not found: Install Inno Setup 6.x
   - File not found: Check paths in [Distribute] section

3. **Use verbose mode**
   ```bash
   DistroCLI <command> <sni-file> --verbose
   ```

4. **Report the specific error** to the user with suggested fixes

## Output Locations

After successful build:

- **Executables**: `R:\Resolute\Resolute\<Program>.exe` and `<Program>_X64.exe`
- **Documentation**: `R:\Resolute\Resolute\Docs\<Program>\*.txt`
- **Distribution**: `R:\Resolute\SDK\Concrete\<Program>\Distribution\<Build>\`
- **Installer**: `R:\Resolute\SDK\Concrete\<Program>\Distribution\<Build>\<Program>_<Build>_Setup.exe`
- **Updates**: `R:\Resolute\www\updates\<Program>\version.txt`

## Best Practices

1. **Always use --verbose** when running builds for users to provide full visibility
2. **Run `all` command** for releases to ensure complete build
3. **Test with `build` first** during development to catch compilation errors quickly
4. **Check .sni file** before building to ensure paths are correct
5. **Verify prerequisites** exist before attempting build

## Integration with Other Tools

DistroCLI complements but does not replace:

- **Distro.au3** (GUI) - For interactive building and testing
- **Manual compilation** - For debugging specific build issues
- **Template editing** - Always edit .tpl files, not generated .txt files

## Example Responses

### When user asks: "Build Chromin"
```
Building Chromin using DistroCLI...

Running: DistroCLI all R:\Resolute\SDK\Concrete\Chromin\Chromin.sni --verbose

✅ Step 1/5: Build completed
✅ Step 2/5: Documentation generated
✅ Step 3/5: Distribution created
✅ Step 4/5: Installer created
✅ Step 5/5: Update files created

Build successful! Files located at:
- Executables: R:\Resolute\Resolute\Chromin.exe, Chromin_X64.exe
- Distribution: R:\Resolute\SDK\Concrete\Chromin\Distribution\8535\
- Installer: Chromin_8535_Setup.exe
```

### When build fails
```
Build failed at step 2/5: Documentation generation

Error: Templates directory not found

Suggested fix: Create R:\Resolute\SDK\Concrete\<Program>\Templates\ 
and add required template files (Changes.tpl, Readme.tpl, License.tpl)
```

## Remember

- DistroCLI is the **preferred method** for AI-assisted building
- It provides **consistent, reproducible** builds
- **Always use full paths** to avoid ambiguity
- **Report both success and failure** clearly to the user
- **Suggest next steps** based on build results
