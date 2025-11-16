# Resolute SDK & Distro Framework Overview

This document summarizes how the **Resolute SDK** and the **Distro Building Environment** (`SDK/Concrete/Distro/Distro.au3`) work together to build, package, sign, and document all Resolute programs (Firemin, ComIntRep, DVDRepair, USBRepair, BiosCodes, etc.).

It is intended as a reference for:

- Understanding how releases are produced.
- Knowing **where to edit** when updating versions, AutoIt toolchains, or documentation.
- Guiding automated agents (like this one) to make safe, consistent changes.

---

## 1. High-Level Architecture

### 1.1 Repos and roots

At runtime the Distro tool establishes two important roots:

- **Distribution root (`g_sRootDir`)**
  - Compiled: `@ScriptDir ..\..\Resolute`
  - Uncompiled (development): near `Resolute` under the repo tree.
  - Contains the runtime tree:
    - `Resolute\` – shipped binaries, language INIs, documents.
    - `Resolute\Docs\<Program>` – generated docs (`Changes.txt`, `Readme.txt`, `License.txt`).
    - `Resolute\Documents\<Program>` – CHM help, license, readme used by the application.
    - `Resolute\Processing`, `Resolute\Logging`, etc.

- **SDK root (`g_sDistroRoot`)**
  - Compiled: `@ScriptDir` (the `SDK` folder containing `Concrete`, `Resources`, `Templates`, `Signing`, `www`, etc.).
  - Key subfolders:
    - `SDK\Concrete\<Program>` – per-program sources & solution files.
    - `SDK\Concrete\Distro` – Distro itself.
    - `SDK\Signing` – certificate and signing configuration.
    - `SDK\www` – website/update payloads, with `SDK\www\update` for `.ru` / update files.

Distro uses these roots to navigate between **sources**, **build artifacts**, **docs**, and **web/update packages**.

### 1.2 Included shared modules

`Distro.au3` includes a set of shared SDK helpers:

- UI & Infrastructure:
  - `Includes\About.au3`, `Donate.au3`, `GuiMenuEx.au3`, `ImageListEx.au3`, `Splash.au3`.
  - `Includes\Logging.au3`, `Messages.au3`, `ProcessEx.au3`, `FileEx.au3`, `StringEx.au3`, `Update.au3`, `Versioning.au3`.
- Localization:
  - `UDF\Localization.au3` – Distro-specific localization on top of the SDK localization engine.

These provide logging (`_Logging_Start`, `_Logging_EditWrite`, `_Logging_FinalMessage`), splash and GUI helpers, and localized text arrays such as:

- `g_aLangMessages`, `g_aLangMessages2` – generic and Distro-specific messages.
- `g_aLangSolutions` – UI strings related to solutions and prerequisites.
- `g_aLangMenus` – menu labels.

---

## 2. Environment and configuration

### 2.1 Environment arrays

Distro centralizes build configuration into several global arrays:

- **`g_aEnvironment`** – per-solution environment data, populated from the selected solution INI.
  - Known indices (from usage):
    - `[1][1]` – main `.au3` script path (source to compile).
    - `[2][1]` – company name.
    - `[4][1]` – release name (e.g. `Firemin` / `Complete Internet Repair`).
    - `[5][1]` – short name (used as directory under `Docs`, e.g. `Firemin`, `ComIntRep`).
    - `[6][1]` – release description text.
    - `[9][1]` – version string (e.g. `11.1.3.6508`).
    - `[18][1]` – main EXE output path (x86).
    - `[19][1]` – X64 EXE output path.
    - `[22][1]` – install size in bytes.

- **Tool/prerequisite arrays** (paths & metadata):
  - `g_aAutoIt3` – AutoIt3 executable and related tools.
  - `g_aAutoIt3Beta` – beta AutoIt, if applicable.
  - `g_aUPX` – UPX compressor (`upx.exe`).
  - `g_aSigntool` / `g_cSignTool` – `signtool.exe` from Windows SDK.
  - `g_a7Zip` – 7-Zip CLI.
  - `g_aInnoSetup` – Inno Setup compiler (`ISCC.exe`).

- **Build grid state**:
  - `g_aBuild[$CNT_DISTRIBUTE][2][8]` – build/distribute options and their controls.
  - `g_aBuildState[$CNT_DISTRIBUTE][2][3]` – flags per option (prerequisites, module state, checked).

Distro computes these from a **solution INI file** specified by the user (one per program) and from environment detection functions (e.g. scanning registry/program files for tools like AutoIt, UPX, Inno, 7-Zip).

### 2.2 Paths derived from roots

Key path variables in Distro:

- `g_sDocsDir      = g_sRootDir & "\Documents\" & g_sProgShortName`
- `g_sDocHelpFile  = g_sDocsDir & "\" & g_sProgShortName & ".chm"`
- `g_sDocChanges   = g_sDocsDir & "\Changes.txt"`
- `g_sDocLicense   = g_sDocsDir & "\License.txt"`
- `g_sDocReadme    = g_sDocsDir & "\Readme.txt"`
- `g_sConcreteRoot = g_sDistroRoot & "\Concrete"`
- `g_sCertificateRoot = g_sDistroRoot & "\Signing"`
- `g_sWebRoot      = g_sDistroRoot & "\www"`
- `g_sUpdateRoot   = g_sWebRoot & "\update"`

These drive where Distro finds:

- Program source and solution files (`Concrete`).
- Signing material (`Signing`).
- Web/update payloads for publishing (`www`, `update`).
- Docs and help output (`Documents` and `Docs`).

---

## 3. Solutions, build actions, and the GUI

### 3.1 Solutions and actions

In the GUI, the user selects a **solution** (a program like Firemin or ComIntRep) and chooses one or more **actions**:

- Build
- Compress
- Sign
- Generate documentation
- Create distribution directory
- Create zip package
- Create installer
- Sign installer
- Create update files

These actions correspond to cases in `_ProcessSelectedSolution($sSolutionIniPath, $iAction)`:

```autoit
Switch $iAction
    Case 0  ; Build
        _BuildSelected($sSolutionIniPath, 0, 0)
    Case 1  ; Compress
        _CompressExecutables($sSolutionIniPath, 1, 0)
    Case 2  ; Sign EXEs
        _SignExecutables($sSolutionIniPath, 2, 0)
    Case 3  ; Generate docs
        _GenerateDocumentation($sSolutionIniPath, 3, 0)
    ; Case 4 reserved
    Case 5  ; Create distribution tree
        _CreateDistribution($sSolutionIniPath, 1, 1)
    Case 6  ; Create Zip package
        _CreateZipPackage($sSolutionIniPath, 2, 1)
    Case 7  ; Create installer
        _CreateInstall($sSolutionIniPath, 3, 1)
    Case 8  ; Sign installer
        _SignExecutables($sSolutionIniPath, 4, 1, True)
    Case 9  ; Create update files
        _CreateUpdateFiles($sSolutionIniPath, 5, 1)
    Case 99 ; Process all checked
        ; Executes a combination of the above based on the GUI checkbox grid.
EndSwitch
```

The **GUI** is built in `_StartCoreGui()` and includes:

- A solutions list (`g_hListSolutions`) that the user selects from.
- Build/distribute option grid backed by `g_aBuild`.
- Menu options to open logs, check for updates, and access help/about.

### 3.2 Logging and splash

Distro uses the SDK logging subsystem to provide consistent output:

- `_Logging_Start("...")`
- `_Logging_EditWrite(...)`
- `_Logging_FinalMessage("...")`

and a splash screen sequence during startup using `_Splash_Start`, `_Splash_Update` and localized messages (`g_aLangMessages[...]`).

---

## 4. Build step details

### 4.1 Compiling – `_BuildSelected`

```autoit
Func _BuildSelected($sSolutionIniPath, $iRow, $iCol)
    Local $sReleaseName = $g_aEnvironment[4][1]
    _Logging_Start(StringFormat($g_aLangMessages2[6], $sReleaseName))
    _StartSoloProcess($iRow, $iCol)

    Local $sAu3ScriptIn = $g_aEnvironment[1][1]

    If FileExists($sAu3ScriptIn) Then
        If FileExists($g_aAutoIt3[9]) And FileExists($g_cAutoItWrapper) Then
            Local $iWrapPID = Run(Chr(34) & $g_aAutoIt3[9] & Chr(34) & Chr(32) & Chr(34) & $g_cAutoItWrapper & Chr(34) & _
                " /NoStatus /prod /in " & Chr(34) & $sAu3ScriptIn & Chr(34), _FileEx_RemoveFileName($sAu3ScriptIn), @SW_SHOW, $STDOUT_CHILD)
            ; Read console output and update progress until AutoIt3Wrapper completes.
        Else
            ; Log missing AutoIt3 or wrapper.
        EndIf
    Else
        ; Log missing source script.
    EndIf

    ; Refresh solution list, log final message, set progress to 100%.
EndFunc
```

Key points:

- Uses **AutoIt3** and **AutoIt3Wrapper** CLI (`g_aAutoIt3[9]` and `g_cAutoItWrapper`) to compile the main script (`g_aEnvironment[1][1]`).
- Reads wrapper output via `StdoutRead` and feeds it through `_AutoIt3Script_WrapperOutPut`, which:
  - Cleans up output lines, strips timestamps and unused hints.
  - Writes meaningful lines into the log UI.
- `_AutoIt3Script_GetBuildProgress` simulates progress by stepping a percentage counter (`g_iau2exeSimPos`).

### 4.2 Compressing executables – `_CompressExecutables`

```autoit
Func _CompressExecutables($sSolutionIniPath, $iRow, $iCol)
    Local $sReleaseName = $g_aEnvironment[4][1]
    _Logging_Start(StringFormat($g_aLangMessages2[11], $sReleaseName))
    _StartSoloProcess($iRow, $iCol)

    Local $sOutFile   = $g_aEnvironment[18][1]
    Local $sOutFileX64 = $g_aEnvironment[19][1]

    If FileExists($sOutFile)   Then _CompressExecutable($sOutFile)
    _UpdateSoloProcess($iRow, $iCol, 50)
    If FileExists($sOutFileX64) Then _CompressExecutable($sOutFileX64)

    _Logging_FinalMessage(StringFormat($g_aLangMessages2[12], $sReleaseName))
    _UpdateSoloProcess($iRow, $iCol, 100)
EndFunc
```

`_CompressExecutable` uses **UPX** (`g_aUPX[9]`) with specific parameters to compress EXEs, logs command and output, and handles errors if UPX or the target file is missing.

### 4.3 Signing – `_SignExecutables` and `_RunSignCommand`

Signing requires:

- `g_cSignTool` – path to `signtool.exe` (from the Windows SDK).
- `Signing` configuration:
  - Distro reads `CertificateSet` from the solution INI (`[Signing]` section), defaulting to something like `Signing\Signing.ini` under the `SDK\Signing` root.
  - That INI defines:
    - `CertificateName` – `.pfx` file name.
    - `Password` – certificate password.
    - `Timestamp` – timestamp server URL.

`_SignExecutables`:

- Checks internet connectivity (pings 8.8.8.8).
- Loads certificate config.
- If `iSignInstall=True`, signs the installer EXE (path from `Environment\InstallOutputPath`).
- Otherwise, signs the main EXEs at `[18][1]` and `[19][1]`.

`_RunSignCommand` constructs and logs a `signtool.exe sign` command:

```autoit
Local $sSignCommand = "signtool.exe sign /f " & '"' & $sCertPath & '"' & _
    " /p " & $sPassword & " /t " & $sCertTimeServer & ' "' & $sOutputFile & '"'
_ProcessEx_RunCommand($sSignCommand, $sSignWorkingDir)
```

### 4.4 Documentation generation – `_GenerateDocumentation` & `_ProcessTemplateFile`

This is the key part for documentation and templates.

```autoit
Func _GenerateDocumentation($sSolutionIniPath, $iRow, $iCol)
    Local $sReleaseName = $g_aEnvironment[4][1]
    Local $sRelShortName = $g_aEnvironment[5][1]

    _Logging_Start(StringFormat($g_aLangMessages2[32], $sReleaseName))
    _StartSoloProcess($iRow, $iCol)

    Local $sHelpNDocOut = @MyDocumentsDir & "\HelpNDoc\Output\chm\" & $sReleaseName & ".chm"
    Local $sDocumentsRoot = _FileEx_PathSplit($sSolutionIniPath, 2)
    Local $sDocsTplRoot = $sDocumentsRoot & "Templates"

    If @Compiled Then
        Local $sDocOutputRoot = _PathFull("..\Resolute\Docs\" & $sRelShortName)
    EndIf

    Local $iSolInstallSize = _GetInstallSize($sSolutionIniPath, _FileEx_PathSplit($sSolutionIniPath, 2))
    Local $iSolInstSizeMB = Round($iSolInstallSize / 1024^2)

    ; Ensure Docs output directory exists.
    ; Read all .tpl templates from the Templates folder.
    ; For each .tpl, call _ProcessTemplateFile to produce a .txt doc.

    ; If a HelpNDoc CHM exists, copy it to the Docs output folder.
    ; Finally, IniWrite InstallSize back into the solution INI.
EndFunc
```

`_ProcessTemplateFile` performs the actual template substitution:

```autoit
Func _ProcessTemplateFile($sSolutionIniPath, $sDocTemplateIn, $sDocOutput, $iReleaseInstSize)
    Local $sReleaseCompany = $g_aEnvironment[2][1]
    Local $sReleaseURL     = IniRead($sSolutionIniPath, "Links", "CompanyURL", "https://www.rizonesoft.com")
    Local $sReleaseName    = $g_aEnvironment[4][1]
    Local $sReleaseDesc    = $g_aEnvironment[6][1]
    Local $sReleaseVersion = $g_aEnvironment[9][1]
    Local $sReleaseInstSize = Round($g_aEnvironment[22][1] / 1024^2)

    Local $sReleaseDocDay   = @MDAY
    Local $sReleaseDocMonth = _DateToMonth(@MON)
    Local $sReleaseDocYear  = @YEAR

    Local $sTemplateRead = FileRead($hTemplateOpen)
    $sTemplateRead = StringReplace($sTemplateRead, "%{RELEASE}",     StringUpper($sReleaseName))
    $sTemplateRead = StringReplace($sTemplateRead, "%{DESCRIPTION}", $sReleaseDesc)
    $sTemplateRead = StringReplace($sTemplateRead, "%{COMPANY}",     StringUpper($sReleaseCompany))
    $sTemplateRead = StringReplace($sTemplateRead, "%{COMPANYURL}",  $sReleaseURL)
    $sTemplateRead = StringReplace($sTemplateRead, "%{VERSION}",     $sReleaseVersion)
    $sTemplateRead = StringReplace($sTemplateRead, "%{DAY}",         $sReleaseDocDay)
    $sTemplateRead = StringReplace($sTemplateRead, "%{MONTH}",       StringUpper($sReleaseDocMonth))
    $sTemplateRead = StringReplace($sTemplateRead, "%{YEAR}",        $sReleaseDocYear)
    $sTemplateRead = StringReplace($sTemplateRead, "%{INSTSIZE}",    $iReleaseInstSize & " MB")

    ; Then writes the replaced content to $sDocOutput.
EndFunc
```

**Implications for documentation work:**

- Per-program docs are **templated** under:
  - `SDK/Concrete/<Program>/Templates/*.tpl`.
- Distro reads these templates and outputs `.txt` docs to:
  - `Resolute/Resolute/Docs/<Program>/<Name>.txt` when compiled.
- To change `Readme.txt`, `Changes.txt`, or `License.txt` for a program:
  - **Edit the `.tpl` file** under that program’s `Templates` folder.
  - Then use Distro’s **Generate Documentation** action for that solution.

This is the mechanism we use for documenting AutoIt upgrades and other meta-changes across the suite.

---

## 5. Packaging & distribution (high level)

While not shown in detail above, Distro contains functions:

- `_CreateDistribution($sSolutionIniPath, $iRow, $iCol)`
- `_CreateZipPackage($sSolutionIniPath, $iRow, $iCol)`
- `_CreateInstall($sSolutionIniPath, $iRow, $iCol)`
- `_CreateUpdateFiles($sSolutionIniPath, $iRow, $iCol)`

These roughly:

- Copy compiled binaries and docs into a versioned distribution folder under the relevant `Concrete` solution directory.
- Use **7-Zip** to create zip archives.
- Use **Inno Setup** to build installer EXEs.
- Generate versioned update packages under `SDK\www\update` for consumption by the in-app update system.

The exact behavior for each program is controlled by its **solution INI file**, which typically includes sections like:

- `[Environment]` – names, versions, main script path, output paths, install size.
- `[Links]` – company URL and related links.
- `[Signing]` – certificate set, description, and website for signtool signing.

---

## 6. How to perform common tasks

### 6.1 Add or update documentation for a program

1. Identify the program’s solution folder: `SDK/Concrete/<Program>/`.
2. Edit the templates in `SDK/Concrete/<Program>/Templates/`:
   - `Changes.tpl` – change log entries.
   - `Readme.tpl` – readme header and description.
   - `License.tpl` – license and privacy sections (if present).
3. In Distro, select the corresponding solution and run **Generate Documentation**.
4. Confirm the new `Changes.txt`, `Readme.txt`, etc. in `Resolute/Resolute/Docs/<Program>/`.

### 6.2 Run a full release pipeline for a solution

1. Ensure prerequisites are installed and detected:
   - AutoIt, AutoIt3Wrapper, UPX, Windows SDK (signtool), 7-Zip, Inno Setup.
2. Open Distro and select the desired solution.
3. Choose the desired actions:
   - Build, Compress, Sign, Generate documentation, Create distribution, Create zip, Create installer, Sign installer, Create update files.
4. Run **Process** (which maps to `_ProcessSelectedSolution` with the appropriate action(s)).
5. Monitor progress and log output via the logging pane.

---

## 7. Key takeaways for automated changes

- **Never edit generated docs directly** (under `Resolute/Resolute/Docs`, `Distribution` or `updates`). Instead, edit the corresponding templates under `SDK/Concrete/<Program>/Templates/` and let Distro regenerate them.
- Use `Distro.au3` as the authoritative reference for:
  - Where docs are generated to.
  - How release metadata (`g_aEnvironment`) is filled.
  - How prerequisite tools are invoked (AutoIt3, UPX, signtool, 7-Zip, Inno Setup).
- When updating cross-cutting items (like AutoIt version used across all programs):
  - Document the change in each program’s `Changes.tpl` (top `%{VERSION}` block).
  - Update any relevant header comments (e.g. `; AutoIt Version:`) in source files, not in wrappers.
  - Let Distro regenerate docs and distribution artifacts.
- For **shared resources** (especially icons) across multiple programs:
  - Prefer placing common assets under `SDK/Resources/Icons/...` and referencing them from program sources/solution INIs.
  - Use unique filenames per product (e.g. `Firemin.ico`, `Chromin.ico`) in the shared tree instead of duplicating trees like `SDK/Concrete/<Program>/Resources/Icons`.
  - Only keep per-program `Resources` content under `SDK/Concrete/<Program>` when it is truly specific to that program and cannot live in the shared tree.

This document should be treated as the main reference when performing framework-level tasks on the Resolute SDK and Distro.
