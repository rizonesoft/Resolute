#Region AutoIt3Wrapper Directives
#AutoIt3Wrapper_UseX64=Y
#AutoIt3Wrapper_Version=P
#AutoIt3Wrapper_Icon=..\Resources\Icons\Distro.ico
#AutoIt3Wrapper_OutFile_Type=exe
#AutoIt3Wrapper_OutFile=..\..\..\SDK\DistroCLI.exe
#AutoIt3Wrapper_OutFile_X64=..\..\..\SDK\DistroCLI_X64.exe
#AutoIt3Wrapper_Change2CUI=Y
#AutoIt3Wrapper_Compile_both=Y
#AutoIt3Wrapper_Res_Comment=DistroCLI - Command Line Build Tool
#AutoIt3Wrapper_Res_Description=DistroCLI Command Line Interface
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_ProductVersion=1
#AutoIt3Wrapper_Res_Language=2057
#AutoIt3Wrapper_Res_LegalCopyright=© 2025 Rizonesoft
#AutoIt3Wrapper_Res_Field=CompanyName|Rizonesoft
#AutoIt3Wrapper_Res_Field=ProductName|DistroCLI
#AutoIt3Wrapper_Res_Field=HomePage|https://rizonesoft.com
#EndRegion

; DistroCLI - Command Line Interface for Distro Build System
; Usage: DistroCLI <command> <sni-file> [options]
;
; Commands:
;   build      - Build the program (compile executables)
;   docs       - Generate documentation from templates
;   dist       - Create distribution package
;   installer  - Create installation package
;   update     - Create update files
;   all        - Run all build steps
;
; Options:
;   --verbose  - Show detailed output
;   --help     - Show this help message
;
; Example:
;   DistroCLI all R:\Resolute\SDK\Concrete\Firemin\Firemin.sni

#include <Array.au3>
#include <File.au3>
#include <FileConstants.au3>

Global Const $VERSION = "1.0.0"
Global $g_bVerbose = False
Global $g_sRootDir = @ScriptDir & "\..\..\.."
Global $g_sDistroRoot = @ScriptDir & "\..\.."

; Main entry point
If $CmdLine[0] = 0 Or $CmdLine[1] = "--help" Or $CmdLine[1] = "-h" Then
	_ShowHelp()
	Exit 0
EndIf

; Parse command line arguments
Local $sCommand = $CmdLine[1]
Local $sSniFile = ($CmdLine[0] >= 2) ? $CmdLine[2] : ""

; Check for verbose flag
For $i = 1 To $CmdLine[0]
	If $CmdLine[$i] = "--verbose" Or $CmdLine[$i] = "-v" Then
		$g_bVerbose = True
		ExitLoop
	EndIf
Next

; Validate SNI file if command requires it
If $sCommand <> "help" And $sCommand <> "version" Then
	If $sSniFile = "" Then
		ConsoleWriteError("Error: SNI file path required" & @CRLF)
		_ShowHelp()
		Exit 1
	EndIf

	If Not FileExists($sSniFile) Then
		ConsoleWriteError("Error: SNI file not found: " & $sSniFile & @CRLF)
		Exit 1
	EndIf
EndIf

; Execute command
Select
	Case $sCommand = "version"
		_ShowVersion()

	Case $sCommand = "build"
		_ExecuteBuild($sSniFile)

	Case $sCommand = "docs"
		_ExecuteDocs($sSniFile)

	Case $sCommand = "dist"
		_ExecuteDist($sSniFile)

	Case $sCommand = "installer"
		_ExecuteInstaller($sSniFile)

	Case $sCommand = "update"
		_ExecuteUpdate($sSniFile)

	Case $sCommand = "all"
		_ExecuteAll($sSniFile)

	Case Else
		ConsoleWriteError("Error: Unknown command '" & $sCommand & "'" & @CRLF)
		_ShowHelp()
		Exit 1
EndSelect

Exit 0

#Region "Command Implementations"

Func _ExecuteBuild($sSniFile)
	_Log("Building: " & $sSniFile)
	
	; Load solution configuration
	Local $aEnv = _LoadSolutionConfig($sSniFile)
	If @error Then
		ConsoleWriteError("Error: Failed to load solution configuration" & @CRLF)
		Exit 1
	EndIf
	
	; Execute build
	_Log("Compiling executables...")
	Local $iResult = _BuildProgram($sSniFile, $aEnv)
	
	If $iResult = 0 Then
		ConsoleWrite("[SUCCESS] Build completed" & @CRLF)
	Else
		ConsoleWriteError("[FAILED] Build failed with error code: " & $iResult & @CRLF)
		Exit 1
	EndIf
EndFunc

Func _ExecuteDocs($sSniFile)
	_Log("Generating documentation: " & $sSniFile)
	
	Local $aEnv = _LoadSolutionConfig($sSniFile)
	If @error Then
		ConsoleWriteError("Error: Failed to load solution configuration" & @CRLF)
		Exit 1
	EndIf
	
	_Log("Processing template files...")
	Local $iResult = _GenerateDocs($sSniFile, $aEnv)
	
	If $iResult = 0 Then
		ConsoleWrite("[SUCCESS] Documentation generated" & @CRLF)
	Else
		ConsoleWriteError("[FAILED] Documentation generation failed" & @CRLF)
		Exit 1
	EndIf
EndFunc

Func _ExecuteDist($sSniFile)
	_Log("Creating distribution: " & $sSniFile)
	
	Local $aEnv = _LoadSolutionConfig($sSniFile)
	If @error Then
		ConsoleWriteError("Error: Failed to load solution configuration" & @CRLF)
		Exit 1
	EndIf
	
	_Log("Building distribution package...")
	Local $iResult = _CreateDist($sSniFile, $aEnv)
	
	If $iResult = 0 Then
		ConsoleWrite("[SUCCESS] Distribution created" & @CRLF)
	Else
		ConsoleWriteError("[FAILED] Distribution creation failed" & @CRLF)
		Exit 1
	EndIf
EndFunc

Func _ExecuteInstaller($sSniFile)
	_Log("Creating installer: " & $sSniFile)
	
	Local $aEnv = _LoadSolutionConfig($sSniFile)
	If @error Then
		ConsoleWriteError("Error: Failed to load solution configuration" & @CRLF)
		Exit 1
	EndIf
	
	_Log("Generating installer package...")
	Local $iResult = _CreateInst($sSniFile, $aEnv)
	
	If $iResult = 0 Then
		ConsoleWrite("[SUCCESS] Installer created" & @CRLF)
	Else
		ConsoleWriteError("[FAILED] Installer creation failed" & @CRLF)
		Exit 1
	EndIf
EndFunc

Func _ExecuteUpdate($sSniFile)
	_Log("Creating update files: " & $sSniFile)
	
	Local $aEnv = _LoadSolutionConfig($sSniFile)
	If @error Then
		ConsoleWriteError("Error: Failed to load solution configuration" & @CRLF)
		Exit 1
	EndIf
	
	_Log("Generating update package...")
	Local $iResult = _CreateUpd($sSniFile, $aEnv)
	
	If $iResult = 0 Then
		ConsoleWrite("[SUCCESS] Update files created" & @CRLF)
	Else
		ConsoleWriteError("[FAILED] Update file creation failed" & @CRLF)
		Exit 1
	EndIf
EndFunc

Func _ExecuteAll($sSniFile)
	_Log("=== Running full build pipeline ===" & @CRLF)
	
	; Step 1: Build
	ConsoleWrite("Step 1/5: Building executables..." & @CRLF)
	_ExecuteBuild($sSniFile)
	
	; Step 2: Generate Documentation
	ConsoleWrite("Step 2/5: Generating documentation..." & @CRLF)
	_ExecuteDocs($sSniFile)
	
	; Step 3: Create Distribution
	ConsoleWrite("Step 3/5: Creating distribution..." & @CRLF)
	_ExecuteDist($sSniFile)
	
	; Step 4: Create Installer
	ConsoleWrite("Step 4/5: Creating installer..." & @CRLF)
	_ExecuteInstaller($sSniFile)
	
	; Step 5: Create Update Files
	ConsoleWrite("Step 5/5: Creating update files..." & @CRLF)
	_ExecuteUpdate($sSniFile)
	
	ConsoleWrite(@CRLF & "[SUCCESS] Full build pipeline completed!" & @CRLF)
EndFunc

#EndRegion

#Region "Helper Functions"

Func _LoadSolutionConfig($sSniFile)
	; Load and parse the .sni file
	_Log("Loading configuration from: " & $sSniFile)
	
	Local $aEnv[30][2]
	
	; Parse key fields from SNI
	$aEnv[0][0] = "ScriptPath"
	$aEnv[0][1] = IniRead($sSniFile, "Environment", "ScriptPath", "")
	
	$aEnv[1][0] = "Name"
	$aEnv[1][1] = IniRead($sSniFile, "Environment", "Name", "")
	
	$aEnv[2][0] = "ShortName"
	$aEnv[2][1] = IniRead($sSniFile, "Environment", "ShortName", "")
	
	$aEnv[3][0] = "Version"
	$aEnv[3][1] = IniRead($sSniFile, "Environment", "Version", "0.0.0.0")
	
	$aEnv[4][0] = "DistributionPath"
	$aEnv[4][1] = IniRead($sSniFile, "Environment", "DistributionPath", "")
	
	If $aEnv[0][1] = "" Then
		ConsoleWriteError("Error: ScriptPath not found in SNI file" & @CRLF)
		Return SetError(1, 0, $aEnv)
	EndIf
	
	Return $aEnv
EndFunc

Func _BuildProgram($sSniFile, $aEnv)
	; Build using AutoIt3Wrapper
	Local $sScriptPath = $aEnv[0][1]
	Local $sAutoIt3Wrapper = @ProgramFilesDir & "\AutoIt3\SciTE\AutoIt3Wrapper\AutoIt3Wrapper.au3"
	
	If Not FileExists($sAutoIt3Wrapper) Then
		ConsoleWriteError("Error: AutoIt3Wrapper not found at: " & $sAutoIt3Wrapper & @CRLF)
		Return 1
	EndIf
	
	If Not FileExists($sScriptPath) Then
		ConsoleWriteError("Error: Script not found: " & $sScriptPath & @CRLF)
		Return 1
	EndIf
	
	_Log("Running AutoIt3Wrapper on: " & $sScriptPath)
	
	Local $iPID = Run(@AutoItExe & ' /AutoIt3ExecuteScript "' & $sAutoIt3Wrapper & '" /in "' & $sScriptPath & '"', "", @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	
	If $g_bVerbose Then
		While ProcessExists($iPID)
			Local $sOutput = StdoutRead($iPID)
			If $sOutput <> "" Then ConsoleWrite($sOutput)
			Sleep(10)
		WEnd
	Else
		ProcessWaitClose($iPID)
	EndIf
	
	Local $iExitCode = @error
	Return $iExitCode
EndFunc

Func _GenerateDocs($sSniFile, $aEnv)
	; Generate documentation from templates
	Local $sSourceDir = StringReplace($sSniFile, ".sni", "")
	$sSourceDir = StringLeft($sSourceDir, StringInStr($sSourceDir, "\", 0, -1) - 1) & "\Templates"
	
	Local $sProgName = $aEnv[1][1]
	Local $sOutputDir = $g_sRootDir & "\Resolute\Docs\" & $sProgName
	
	If Not FileExists($sSourceDir) Then
		_Log("No templates directory found, skipping documentation")
		Return 0
	EndIf
	
	DirCreate($sOutputDir)
	
	; Copy template files
	Local $aFiles = _FileListToArray($sSourceDir, "*.tpl")
	If Not @error Then
		For $i = 1 To $aFiles[0]
			Local $sSource = $sSourceDir & "\" & $aFiles[$i]
			Local $sDest = $sOutputDir & "\" & StringReplace($aFiles[$i], ".tpl", ".txt")
			FileCopy($sSource, $sDest, 1)
			_Log("Generated: " & $sDest)
		Next
	EndIf
	
	Return 0
EndFunc

Func _CreateDist($sSniFile, $aEnv)
	; Create distribution folder structure
	Local $sDistPath = $aEnv[4][1]
	
	If $sDistPath = "" Then
		ConsoleWriteError("Error: DistributionPath not set in SNI" & @CRLF)
		Return 1
	EndIf
	
	DirCreate($sDistPath)
	_Log("Distribution path: " & $sDistPath)
	
	; Copy files listed in [Distribute] section
	Local $aDistFiles = IniReadSection($sSniFile, "Distribute")
	If Not @error Then
		For $i = 1 To $aDistFiles[0][0]
			If StringLeft($aDistFiles[$i][0], 4) = "File" Then
				Local $sFilePath = $aDistFiles[$i][1]
				; Process placeholders
				$sFilePath = StringReplace($sFilePath, "%RootDir%", $g_sRootDir & "\Resolute")
				$sFilePath = StringReplace($sFilePath, "%SourceDir%", StringLeft($sSniFile, StringInStr($sSniFile, "\", 0, -1) - 1))
				
				If FileExists($sFilePath) Then
					_Log("Copying: " & $sFilePath)
					; Determine relative structure and copy
					Local $sFileName = StringRight($sFilePath, StringLen($sFilePath) - StringInStr($sFilePath, "\", 0, -1))
					FileCopy($sFilePath, $sDistPath & "\" & $sFileName, 1)
				EndIf
			EndIf
		Next
	EndIf
	
	Return 0
EndFunc

Func _CreateInst($sSniFile, $aEnv)
	; Create installer using Inno Setup
	Local $sDistPath = $aEnv[4][1]
	Local $sSetupScript = $sDistPath & "\" & $aEnv[2][1] & "_Setup.iss"
	
	If Not FileExists($sSetupScript) Then
		_Log("No setup script found, skipping installer creation")
		Return 0
	EndIf
	
	Local $sInnoSetup = @ProgramFilesDir & "\Inno Setup 6\ISCC.exe"
	If Not FileExists($sInnoSetup) Then
		ConsoleWriteError("Error: Inno Setup not found" & @CRLF)
		Return 1
	EndIf
	
	_Log("Compiling installer: " & $sSetupScript)
	RunWait('"' & $sInnoSetup & '" "' & $sSetupScript & '"', "", @SW_HIDE)
	
	Return @error
EndFunc

Func _CreateUpd($sSniFile, $aEnv)
	; Create update files
	Local $sProgName = $aEnv[1][1]
	Local $sVersion = $aEnv[3][1]
	Local $sUpdateDir = $g_sRootDir & "\www\updates\" & $sProgName
	
	DirCreate($sUpdateDir)
	
	_Log("Update files directory: " & $sUpdateDir)
	
	; Create version.txt
	Local $hFile = FileOpen($sUpdateDir & "\version.txt", 2)
	FileWrite($hFile, $sVersion)
	FileClose($hFile)
	
	Return 0
EndFunc

Func _Log($sMessage)
	If $g_bVerbose Then
		ConsoleWrite("[INFO] " & $sMessage & @CRLF)
	EndIf
EndFunc

Func _ShowHelp()
	ConsoleWrite("DistroCLI v" & $VERSION & " - Resolute Build System CLI" & @CRLF)
	ConsoleWrite("Copyright (c) 2025 Rizonesoft" & @CRLF & @CRLF)
	ConsoleWrite("Usage: DistroCLI <command> <sni-file> [options]" & @CRLF & @CRLF)
	ConsoleWrite("Commands:" & @CRLF)
	ConsoleWrite("  build       Build the program (compile executables)" & @CRLF)
	ConsoleWrite("  docs        Generate documentation from templates" & @CRLF)
	ConsoleWrite("  dist        Create distribution package" & @CRLF)
	ConsoleWrite("  installer   Create installation package" & @CRLF)
	ConsoleWrite("  update      Create update files" & @CRLF)
	ConsoleWrite("  all         Run all build steps" & @CRLF)
	ConsoleWrite("  version     Show version information" & @CRLF)
	ConsoleWrite("  help        Show this help message" & @CRLF & @CRLF)
	ConsoleWrite("Options:" & @CRLF)
	ConsoleWrite("  --verbose, -v    Show detailed output" & @CRLF & @CRLF)
	ConsoleWrite("Examples:" & @CRLF)
	ConsoleWrite("  DistroCLI build R:\Resolute\SDK\Concrete\Firemin\Firemin.sni" & @CRLF)
	ConsoleWrite("  DistroCLI all R:\Resolute\SDK\Concrete\Chromin\Chromin.sni --verbose" & @CRLF)
	ConsoleWrite("  DistroCLI docs R:\Resolute\SDK\Concrete\Edgemin\Edgemin.sni" & @CRLF)
EndFunc

Func _ShowVersion()
	ConsoleWrite("DistroCLI version " & $VERSION & @CRLF)
	ConsoleWrite("Resolute SDK Build System" & @CRLF)
	ConsoleWrite("Copyright (c) 2025 Rizonesoft" & @CRLF)
EndFunc

#EndRegion
