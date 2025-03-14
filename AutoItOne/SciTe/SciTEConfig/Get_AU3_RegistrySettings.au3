#include <WindowsConstants.au3>
#include <EditConstants.au3>
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=C:\Program Files (x86)\AutoIt3\Icons\au3.ico
#AutoIt3Wrapper_Add_Constants=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;***********************************************************
; Scriptname: Get_AU3_Settings.au3
; Script to display Registry setting for SciTE & AutoIt3
; reporting possible issues with these settings
;***********************************************************
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
_Check_Au3_Registry()
;
Func _Check_Au3_Registry()
	Local $TotalMsg,$UserData
	Display_Console("******************************************************************************************************************************************" & @CRLF, $TotalMsg)
	Local $FixedOpen = RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.au3", "Application")
	Local $FixedOpenW7 = RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.au3\Userchoice", "ProgId")
	If $FixedOpen <> "" Then
		Display_Console("!*  Found always open with         :" & $FixedOpen & @CRLF, $TotalMsg)
		Display_Console('!*  Fixed by removing Registry Hyve: "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.au3" Key:"Application"' & @CRLF, $TotalMsg)
	EndIf
	If $FixedOpenW7 <> "" Then
		Display_Console("!*  Found always open with Win7    :" & $FixedOpenW7 & @CRLF, $TotalMsg)
		Display_Console('!*  Fixed by removing Registry key : "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.au3\Userchoice"' & @CRLF, $TotalMsg)
	EndIf
	Local $au3prof = RegRead("HKCR\.au3", "")
	If $au3prof <> "AutoIt3Script" And $au3prof <> "AutoIt3ScriptBeta" Then
		Display_Console('!*  Registry key: "HKCR\.au3" - "Default" is currently set to ' & $au3prof, $TotalMsg)
		Display_Console('   ==> This should be changed to "AutoIt3Script" (or "AutoIt3ScriptBeta")' & @CRLF, $TotalMsg)
;~ 	RegWrite("HKCR\.au3","","REG_SZ","AutoIt3Script")
	Else
		Display_Console("* HKCR\.au3 Default                  : " & $au3prof & @CRLF, $TotalMsg)
	EndIf

;~ 	$ShellNewWinDir = RegRead("HKEY_USERS\.default\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders", "Filename")

	Local $RegKeyBase = "HKLM\SOFTWARE\Classes\.au3\ShellNew"
	Display_Console("* " & $RegKeyBase & ": " & @WindowsDir & "\SHELLNEW\" & RegRead($RegKeyBase, "Filename"), $TotalMsg)
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : RegRead($RegKeyBase, "Filename") = ' & RegRead($RegKeyBase, "Filename") & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
	If FileExists(@WindowsDir & "\SHELLNEW\" & RegRead($RegKeyBase, "Filename")) Then
		Display_Console(" (File Exists)" & @CRLF, $TotalMsg)
	Else
		Display_Console(" (*** File is Misssing!)" & @CRLF, $TotalMsg)
	EndIf
	Display_Console("* HKCR\.au3 ShellNew                 : " & @WindowsDir & "\SHELLNEW\" & RegRead("HKCR\.au3\Shellnew", "Filename"), $TotalMsg)
	If FileExists(@WindowsDir & "\SHELLNEW\" & RegRead("HKCR\.au3\Shellnew", "Filename")) Then
		Display_Console(" (File Exists)" & @CRLF, $TotalMsg)
	Else
		Display_Console(" (*** File is Misssing!)" & @CRLF, $TotalMsg)
	EndIf
	$RegKeyBase = "HKCR\" & $au3prof & "\shell"
	Display_Console("******************************************************************************************************************************************" & @CRLF, $TotalMsg)
	Display_Console("* Explorer shell options:" & @CRLF, $TotalMsg)
	Display_Console("* " & $RegKeyBase & ": " & @CRLF, $TotalMsg)
	Display_Console("*  => Default Action:" & RegRead($RegKeyBase, "") & @CRLF, $TotalMsg)
	Local  $var, $var2
	For $i = 1 To 30
		$var = RegEnumKey($RegKeyBase, $i)
		If @error <> 0 Then ExitLoop
		Display_Console("*     " & StringLeft($var & "                       ", 22), $TotalMsg)
		$var2 = RegEnumKey($RegKeyBase & "\" & $var, 1)
		Display_Console(" => " & $var2, $TotalMsg)
		Display_Console(":" & RegRead($RegKeyBase & "\" & $var & "\" & $var2, "") & @CRLF, $TotalMsg)
	Next
	Display_Console("******************************************************************************************************************************************" & @CRLF, $TotalMsg)
	Display_Console("* User SciTE info:" & @CRLF, $TotalMsg)
	If EnvGet("SCITE_USERHOME") <> "" Then
		$UserData = EnvGet("SCITE_USERHOME")
		Display_Console("*    SCITE_USERHOME:" & $UserData & ": " & @CRLF, $TotalMsg)
	ElseIf EnvGet("SCITE_HOME") <> "" Then
		$UserData = EnvGet("SCITE_HOME")
		Display_Console("*    SCITE_HOME:" & $UserData & ": " & @CRLF, $TotalMsg)
	Else
		$UserData = @ScriptDir
		Display_Console("*    Portable:" & $UserData & ": " & @CRLF, $TotalMsg)
	EndIf
	If Not FileExists($UserData) Then
		Display_Console("*    Directory missing: " & $UserData, $TotalMsg)
	Else
		; Check directory structure
		If Not FileExists($UserData & "\Au3Stripper") Then Display_Console("*    Directory missing: " & $UserData & "\Au3Stripper" & @CRLF, $TotalMsg)
		If Not FileExists($UserData & "\AutoIt3Wrapper") Then Display_Console("*    Directory missing: " & $UserData & "\AutoIt3Wrapper" & @CRLF, $TotalMsg)
		If Not FileExists($UserData & "\CodeWizard") Then Display_Console("*    Directory missing: " & $UserData & "\CodeWizard" & @CRLF, $TotalMsg)
		If Not FileExists($UserData & "\SciTE Jump") Then Display_Console("*    Directory missing: " & $UserData & "\SciTE Jump" & @CRLF, $TotalMsg)
		If Not FileExists($UserData & "\SciTEConfig") Then Display_Console("*    Directory missing: " & $UserData & "\SciTEConfig" & @CRLF, $TotalMsg)
		If Not FileExists($UserData & "\Tidy") Then Display_Console("*    Directory missing: " & $UserData & "\Tidy" & @CRLF, $TotalMsg)
		; check key files
		If Not FileExists($UserData & "\abbrev.properties") Then
			Display_Console("*    File missing: " & $UserData & "\Aabbrev.properties" & @CRLF, $TotalMsg)
		Else
			If Not FileGetSize($UserData & "\abbrev.properties") Then Display_Console("*    File empty: " & $UserData & "\Abbrev.properties" & @CRLF, $TotalMsg)
		EndIf
		If Not FileExists($UserData & "\au3abbrev.properties") Then
			Display_Console("*    File missing: " & $UserData & "\au3abbrev.properties" & @CRLF, $TotalMsg)
		Else
			If Not FileGetSize($UserData & "\au3abbrev.properties") Then Display_Console("*    File empty: " & $UserData & "\au3abbrev.properties" & @CRLF, $TotalMsg)
		EndIf
		If Not FileExists($UserData & "\SciTEUSer.properties") Then
			Display_Console("*    No SciTEUSer.properties yet" & @CRLF, $TotalMsg)
		Else
			Display_Console("*    SciTEUSer.Properties: " & @CRLF, $TotalMsg)
			Display_Console("*-----------------------------------------------------------------------------------------" & @CRLF, $TotalMsg)
			Display_Console(FileRead($UserData & "\SciTEUSer.properties") & @CRLF, $TotalMsg)
		EndIf
	EndIf
	Display_Console("******************************************************************************************************************************************" & @CRLF, $TotalMsg)
	ClipPut($TotalMsg)
	GUICreate(".au3 registry settings", 1000, 600)
	GUICtrlCreateEdit($TotalMsg, 1, 1, 998, 560,$ES_READONLY+$WS_VSCROLL+$ES_AUTOVSCROLL)
	GUICtrlSetFont(-1, Default, Default, Default, "Courier New")
	Local $HReg_Exit = GUICtrlCreateButton("Exit", 450, 570, 50, 25)
	GUICtrlCreateLabel("* information is stored on the clipboard.", 10, 575)
	GUISetState(@SW_SHOW)
	Do
		$msg = GUIGetMsg()
	Until $msg = $GUI_EVENT_CLOSE Or $msg = $HReg_Exit
	GUIDelete()
EndFunc   ;==>_Check_Au3_Registry
;
Func Display_Console($msg, ByRef $TotalMsg)
;~ 	ConsoleWrite($msg)
	$TotalMsg &= $msg
EndFunc   ;==>Display_Console
