#NoTrayIcon
#Region AutoIt3Wrapper Directives
#AutoIt3Wrapper_Change2CUI=Y
#AutoIt3Wrapper_UseX64=Y
#EndRegion

; Distro Bootstrap Build Script
; This script builds Distro without requiring Distro itself
; Solves the circular dependency problem

#include <File.au3>
#include <FileConstants.au3>

Global Const $VERSION = "1.0.0"
Global $g_sScriptDir = @ScriptDir
Global $g_sRootDir = $g_sScriptDir & "\..\..\.."
Global $g_sSniFile = $g_sScriptDir & "\Distro.sni"

ConsoleWrite("==================================================" & @CRLF)
ConsoleWrite("Distro Bootstrap Build Script v" & $VERSION & @CRLF)
ConsoleWrite("==================================================" & @CRLF & @CRLF)

; Step 1: Build Distro.exe
ConsoleWrite("[Step 1/3] Building Distro executables..." & @CRLF)
If _BuildDistro() Then
	ConsoleWrite("[SUCCESS] Build completed" & @CRLF & @CRLF)
Else
	ConsoleWrite("[FAILED] Build failed" & @CRLF)
	Exit 1
EndIf

; Step 2: Generate Documentation
ConsoleWrite("[Step 2/3] Generating documentation..." & @CRLF)
If _GenerateDocs() Then
	ConsoleWrite("[SUCCESS] Documentation generated" & @CRLF & @CRLF)
Else
	ConsoleWrite("[FAILED] Documentation generation failed" & @CRLF)
	Exit 1
EndIf

; Step 3: Create Distribution
ConsoleWrite("[Step 3/3] Creating distribution..." & @CRLF)
If _CreateDist() Then
	ConsoleWrite("[SUCCESS] Distribution created" & @CRLF & @CRLF)
Else
	ConsoleWrite("[FAILED] Distribution creation failed" & @CRLF)
	Exit 1
EndIf

ConsoleWrite("==================================================" & @CRLF)
ConsoleWrite("[SUCCESS] Distro bootstrap build completed!" & @CRLF)
ConsoleWrite("==================================================" & @CRLF)

Exit 0

Func _BuildDistro()
	; Build using AutoIt3Wrapper
	Local $sScriptPath = $g_sScriptDir & "\Distro.au3"
	Local $sAutoIt3Wrapper = @ProgramFilesDir & "\AutoIt3\SciTE\AutoIt3Wrapper\AutoIt3Wrapper.au3"
	
	If Not FileExists($sAutoIt3Wrapper) Then
		ConsoleWriteError("Error: AutoIt3Wrapper not found at: " & $sAutoIt3Wrapper & @CRLF)
		Return False
	EndIf
	
	If Not FileExists($sScriptPath) Then
		ConsoleWriteError("Error: Distro.au3 not found" & @CRLF)
		Return False
	EndIf
	
	ConsoleWrite("  Compiling: " & $sScriptPath & @CRLF)
	Local $iPID = Run(@AutoItExe & ' /AutoIt3ExecuteScript "' & $sAutoIt3Wrapper & '" /in "' & $sScriptPath & '"', "", @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	
	ProcessWaitClose($iPID)
	Local $iExitCode = @error
	
	If $iExitCode = 0 Then
		If FileExists($g_sRootDir & "\SDK\Distro.exe") And FileExists($g_sRootDir & "\SDK\Distro_X64.exe") Then
			Return True
		EndIf
	EndIf
	
	Return False
EndFunc

Func _GenerateDocs()
	; Generate documentation from templates
	Local $sTemplateDir = $g_sScriptDir & "\Templates"
	Local $sDocsDir = $g_sRootDir & "\Resolute\Docs\Distro"
	
	If Not FileExists($sTemplateDir) Then
		ConsoleWrite("  No templates directory found, skipping" & @CRLF)
		Return True
	EndIf
	
	DirCreate($sDocsDir)
	
	; Copy template files
	Local $aTemplates = ["Changes.tpl", "Readme.tpl", "License.tpl"]
	
	For $i = 0 To UBound($aTemplates) - 1
		Local $sSource = $sTemplateDir & "\" & $aTemplates[$i]
		Local $sDest = $sDocsDir & "\" & StringReplace($aTemplates[$i], ".tpl", ".txt")
		
		If FileExists($sSource) Then
			; Simple copy for now - Distro will process placeholders later
			If FileCopy($sSource, $sDest, 1) Then
				ConsoleWrite("  Generated: " & $sDest & @CRLF)
			Else
				ConsoleWrite("  Warning: Failed to copy " & $aTemplates[$i] & @CRLF)
			EndIf
		EndIf
	Next
	
	Return True
EndFunc

Func _CreateDist()
	; Create distribution folder and copy files
	Local $sDistPath = $g_sRootDir & "\SDK\Concrete\Distro\Distribution\3684"
	Local $sDistName = "Distro_3684"
	Local $sFullDistPath = $sDistPath & "\" & $sDistName
	
	DirCreate($sFullDistPath)
	ConsoleWrite("  Distribution path: " & $sFullDistPath & @CRLF)
	
	; Copy executables
	FileCopy($g_sRootDir & "\SDK\Distro.exe", $sFullDistPath & "\Distro.exe", 1)
	FileCopy($g_sRootDir & "\SDK\Distro_X64.exe", $sFullDistPath & "\Distro_X64.exe", 1)
	
	; Copy documentation
	Local $sDocsDir = $g_sRootDir & "\Resolute\Docs\Distro"
	Local $aDocs = ["Changes.txt", "Readme.txt", "License.txt"]
	
	For $i = 0 To UBound($aDocs) - 1
		Local $sDocFile = $sDocsDir & "\" & $aDocs[$i]
		If FileExists($sDocFile) Then
			FileCopy($sDocFile, $sFullDistPath & "\" & $aDocs[$i], 1)
			ConsoleWrite("  Copied: " & $aDocs[$i] & @CRLF)
		EndIf
	Next
	
	Return True
EndFunc
