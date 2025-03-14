#NoTrayIcon
Global Const $VERSION = "19.1127.1402.0"
#RequireAdmin
#AutoIt3Wrapper_AutoIt3Dir=D:\Development\AutoIt3\installer_SciTe4AutoIt3\autoit-v3.3.12.0\install
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=filetype2.ico
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=Script to update the SciTe installation with the correct definitions
#AutoIt3Wrapper_Res_Description=Update the SciTe definitions files
#AutoIt3Wrapper_Res_Fileversion=19.1127.1402.0
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_LegalCopyright=Copyright © 2019 Jos van der Zande
#AutoIt3Wrapper_Res_Field=Created By|Jos van der Zande
#AutoIt3Wrapper_Res_Field=Email|jdeb@autoscript.com
#AutoIt3Wrapper_Run_After=copy "%in%" "..\..\Programs_Updates\Defs\*.*"
#AutoIt3Wrapper_Run_After=copy "%out%" "..\..\Programs_Updates\Defs\*.*"
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/SO
#AutoIt3Wrapper_Versioning_Parameters=/comments "%fileversion% \n"
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include<misc.au3>
#AutoIt3Wrapper_UseAnsi=y
$Debug = 1
Opt("TrayIconDebug", 1)
;
FileChangeDir(@ScriptDir)
$PRODUNCTIONTEXT = IniRead(@ScriptDir & "\versioninfo.ini", "Version", "Production", "Production definitions")
$BetaTEXT = "Beta:" & IniRead(@ScriptDir & "\versioninfo.ini", "Version", "Beta", "Beta definitions")
; get new registry settings for AutoIt3 location
$AutoItDir = RegRead("HKLM\Software\Autoit v3\AutoIt", "InstallDir")
; if wrong.. check for Old registry settings
If @error Or Not FileExists($AutoItDir & "\autoit3.exe") Then
	If $Debug = 1 Then FileWriteLine(@ScriptDir & "\updateDefs.log", "1. $AutoItDir=" & $AutoItDir)
	$AutoItDir = RegRead("HKLM\Software\HiddenSoft\AutoIt3", "InstallDir")
	; if wrong guess ourselfs
	If @error Or Not FileExists($AutoItDir & "\autoit3.exe") Then
		$AutoItDir = @ProgramFilesDir & "\AutoIt3"
		If $Debug = 1 Then FileWriteLine(@ScriptDir & "\updateDefs.log", "2. $AutoItDir=" & $AutoItDir)
	EndIf
EndIf
If $Debug = 1 Then FileWriteLine(@ScriptDir & "\updateDefs.log", "3. $AutoItDir=" & $AutoItDir)
; get new registry settings for AutoIt3 location
$AutoItDirBeta = RegRead("HKLM\Software\Autoit v3\AutoIt", "BetaInstallDir")
; if wrong.. check for Old registry settings
If @error Or Not FileExists($AutoItDirBeta & "\autoit3.exe") Then
	If $Debug = 1 Then FileWriteLine(@ScriptDir & "\updateDefs.log", "1. $AutoItDirBeta=" & $AutoItDirBeta)
	$AutoItDirBeta = @ProgramFilesDir & "\AutoIt3\Beta"
	If $Debug = 1 Then FileWriteLine(@ScriptDir & "\updateDefs.log", "2. $AutoItDirBeta=" & $AutoItDirBeta)
EndIf
If $Debug = 1 Then FileWriteLine(@ScriptDir & "\updateDefs.log", "3. $AutoItDirBeta=" & $AutoItDirBeta)
Dim $I_PRODUCTION, $SELECTION
Global $Silent = 0
For $x = 1 To $CMDLINE[0]
	If StringLeft($CMDLINE[$x], 4) = "Prod" Then $SELECTION = "Production"
	If StringLeft($CMDLINE[$x], 4) = "Unst" Then $SELECTION = "Beta"
	If StringLeft($CMDLINE[$x], 4) = "Beta" Then $SELECTION = "Beta"
	If StringLeft($CMDLINE[$x], 6) = "Latest" Then $SELECTION = "Latest"
	If $CMDLINE[$x] = "/S" Then $Silent = 1
Next
FileDelete(@ScriptDir & "\updateDefs.log")
If $SELECTION = "" Then
	Opt("guicoordmode", 1)
	;Opt("GUINotifyMode", 1)
	GUICreate("SciTE definition selection (" & $Version & ")", 350, 150)
	GUISetFont(10, 600)
	GUICtrlCreateLabel("Select which definitions you want to use for: Scite,Tidy and au3Stripper.", 10, 10, 340, 40)
	GUISetFont(9, 400)
	Global $I_PRODUCTION = GUICtrlCreateRadio($PRODUNCTIONTEXT, 40, 50, 270, 20)
	Global $I_Beta = GUICtrlCreateRadio($BetaTEXT, 40, 75, 270, 20)
	Global $I_OK = GUICtrlCreateButton("&Update", 40, 110, 120, 25)
	Global $I_CANCEL = GUICtrlCreateButton("&Cancel", 170, 110, 120, 25)
	;
	GUICtrlSetState($I_PRODUCTION, 1)
	GUISetState(@SW_SHOW)
	While 1
		$RC = GUIGetMsg()
		; Cancel clicked
		If $RC = 0 Then ContinueLoop
		If $RC = $I_OK Then ExitLoop
		If $RC = $I_CANCEL Then
			$RC = MsgBox(4100, "Update SciTE Definitions", "do you want to stop this update process?")
			If $RC = 6 Then Exit
		EndIf
		If $RC = -3 Then Exit
	WEnd
EndIf
;
If $SELECTION = "Latest" Then
	If Not FileExists($AutoItDirBeta & "\autoit3.exe") Then
		$SELECTION = "Production"
	Else
		$ProdVer = StringSplit(FileGetVersion($AutoItDir & "\autoit3.exe"), ".")
		$BetaVer = StringSplit(FileGetVersion($AutoItDirBeta & "\autoit3.exe"), ".")
		ReDim $ProdVer[5], $BetaVer[5]
		For $x = 1 To 4
			If $ProdVer[$x] = $BetaVer[$x] Then ContinueLoop
			If $ProdVer[$x] > $BetaVer[$x] Then
				$SELECTION = "Production"
			Else
				$SELECTION = "Beta"
			EndIf
			ExitLoop
		Next
	EndIf
EndIf
;
$msgtext = @LF & @LF & "Run program " & @ScriptFullPath & " again when you want to change the definition files."
$SciteDir = StringLeft(@ScriptDir, StringInStr(@ScriptDir, "\", 0, -1) - 1)
GUISetState(@SW_HIDE)
If $Silent = 0 Then ProgressOn("Scite Config files", "Copying Files")
FileChangeDir(@ScriptDir)
If $Silent = 0 Then ProgressSet(30, "Update au3.properties")
If $Debug = 1 Then FileWriteLine(@ScriptDir & "\updateDefs.log", "$SciteDir=" & $SciteDir)
Update_Autoit_Path($SciteDir)
Sleep(500)
If GUICtrlRead($I_PRODUCTION) = 1 Or $SELECTION = "Production" Then
	If $Silent = 0 Then ProgressSet(50, "Copying files version:" & $PRODUNCTIONTEXT)
	CopyFiles(@ScriptDir & '\Production', $SciteDir)
	UpdateAbbr(@ScriptDir & '\Production\au3abbrev.properties')
	Sleep(500)
	If $Silent = 0 Then ProgressOff()
	If $Silent = 0 Then MsgBox(4096, "Scite Config", "Definitions for:" & $PRODUNCTIONTEXT & " copied to Scite." & $msgtext, 10)
Else
	If $Silent = 0 Then ProgressSet(50, "Copying files version:" & $BetaTEXT)
	CopyFiles(@ScriptDir & '\Beta', $SciteDir)
	Sleep(500)
	UpdateAbbr(@ScriptDir & '\Beta\au3abbrev.properties')
	If $Silent = 0 Then ProgressOff()
	If $Silent = 0 Then MsgBox(4096, "Scite Config", "Definitions for:" & $BetaTEXT & " copied to Scite." & $msgtext, 10)
EndIf
GUIDelete()
;update configfile autoit dir
Func Update_Autoit_Path($SciTEPath)
	; if still wrong AutoIt3 Directory then prompt for it.
	While Not FileExists($AutoItDir & "\autoit3.exe")
		$AutoItDir = FileSelectFolder("Select the AutoIt3 programfolder", @ProgramFilesDir)
		If @error = 1 Then
			$RC = MsgBox(4100, "Update SciTE Definitions", "do you want to stop the process?")
			If $RC = 6 Then Exit
		EndIf
	WEnd
	;**** Check The Beta directory
	$BetaAutoItDir = RegRead("HKLM\Software\Autoit v3\AutoIt", "BetaInstallDir")
	If @error Or Not FileExists($BetaAutoItDir & "\autoit3.exe") Then
		$BetaAutoItDir = $AutoItDir & '\Beta'
		If Not FileExists($BetaAutoItDir & "\autoit3.exe") Then
			$BetaAutoItDir = @ProgramFilesDir & '\AutoIt3\Beta'
		EndIf
	EndIf
	;**** Check The SciTE directory
	While Not FileExists($SciTEPath & "\properties\au3.properties")
		$SciTEPath = FileSelectFolder("Select the SciTE programfolder", @ProgramFilesDir)
		If @error = 1 Then
			$RC = MsgBox(4100, "Update SciTE Definitions", "do you want to stop the process?")
			If $RC = 6 Then Exit
		EndIf
	WEnd
	;Process au3.properties
	$H_Out = FileOpen(@TempDir & "\au3.backup", 2)
	$H_in = FileOpen($SciTEPath & "\properties\au3.properties", 0)
	If $H_in = -1 Then
		If $Silent = 0 Then MsgBox(0, "Error", "Unable to open file:" & $SciTEPath & "\properties\au3.properties")
		Exit
	EndIf
	If $Debug = 1 Then
		FileWriteLine(@ScriptDir & "\updateDefs.log", "4. $AutoItDir=" & $AutoItDir)
		FileWriteLine(@ScriptDir & "\updateDefs.log", $SciTEPath & "\properties\au3.properties")
	EndIf
	While 1
		$irec = FileReadLine($H_in)
		If @error = -1 Then ExitLoop
		If StringLeft($irec, 11) = "autoit3dir=" Then
			If $Debug = 1 Then FileWriteLine(@ScriptDir & "\updateDefs.log", "Found autoit3dir=" & $irec)
			$irec = "autoit3dir=" & $AutoItDir
			If $Debug = 1 Then FileWriteLine(@ScriptDir & "\updateDefs.log", "New   autoit3dir=" & $irec)
		EndIf
		FileWriteLine($H_Out, $irec)
	WEnd
	FileClose($H_in)
	FileClose($H_Out)

	; save last version
	FileCopy($SciTEPath & "\properties\au3.properties", $SciTEPath & "\properties\au3_Old.properties", 1)
	; move new file to au3.properties
	$fh = FileOpen($SciTEPath & "\properties\au3.properties", 2)
	FileWrite($fh, FileRead(@TempDir & "\au3.backup"))
	FileClose($fh)
	;
	If $Debug = 1 Then
		FileWriteLine(@ScriptDir & "\updateDefs.log", "*** Start New Au3.properties *****************************************************************")
		FileWriteLine(@ScriptDir & "\updateDefs.log", FileRead($SciTEPath & "\properties\au3.properties"))
		FileWriteLine(@ScriptDir & "\updateDefs.log", "*** END   New Au3.properties *****************************************************************")
	EndIf
	; Reload the properties to ensure the Path is updated when SciTE is already running.
	Reload_Config()
	;

EndFunc   ;==>Update_Autoit_Path
;
Func CopyFiles($fromdir, $todir)
	FileCopy($fromdir & "\*.*", $todir & "\properties\", 1)
	FileCopy($fromdir & "\api\au3.api", $todir & "\api\", 1)
EndFunc   ;==>CopyFiles
;
Func UpdateAbbr($NewAbbrFile)
	Local $UserDir = @UserProfileDir
	Local $AbbrFile, $H_Input, $H_Output, $H_NewInput, $I_Rec
	If @OSType = "WIN32_NT" Then
		$UserDir = @UserProfileDir
	Else
		$UserDir = $SciteDir ; needed for Win9x
	EndIf
	$AbbrFile = $UserDir & "\abbrev.properties"
	$H_Output = FileOpen(@TempDir & "\abbrev.properties", 2)
	; read current abbrev.properties till the end or stuff we put in
	FileWriteLine(@ScriptDir & "\updateDefs.log", "$AbbrFile=" & $AbbrFile)
	FileWriteLine(@ScriptDir & "\updateDefs.log", "@TempDir=" & @TempDir)
	If FileExists($AbbrFile) Then
		$H_Input = FileOpen($AbbrFile, 0)
		If $H_Input <> -1 Then
			FileWriteLine(@ScriptDir & "\updateDefs.log", "* Start writing start section.")
			$I_Rec = FileReadLine($H_Input)
			While @error = 0 And $I_Rec <> "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#"
				FileWriteLine($H_Output, $I_Rec)
				$I_Rec = FileReadLine($H_Input)
			WEnd
			; Now read till the end of our definition
			$I_Rec = FileReadLine($H_Input)
			FileWriteLine(@ScriptDir & "\updateDefs.log", "* Skipping midle section.")
			While Not @error And $I_Rec <> "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#"
				$I_Rec = FileReadLine($H_Input)
			WEnd
			; Now copy records put after our stuff to the new file
			FileWriteLine(@ScriptDir & "\updateDefs.log", "* Start writing our $AbbrFile.")
			$I_Rec = FileReadLine($H_Input)
			While Not @error
				FileWriteLine($H_Output, $I_Rec)
				$I_Rec = FileReadLine($H_Input)
			WEnd
			FileClose($H_Input)
		EndIf
	EndIf
	; write all records to NewAbbrev file
	If FileExists($NewAbbrFile) Then
		; add \ to SciTEpatrh and change each \ to \\
		; get new registry settings for AutoIt3 location
		$AutoItDir = RegRead("HKLM\Software\Autoit v3\AutoIt", "InstallDir")
		; if wrong.. check for Old registry settings
		If @error Or Not FileExists($AutoItDir & "\autoit3.exe") Then
			$AutoItDir = RegRead("HKLM\Software\HiddenSoft\AutoIt3", "InstallDir")
			; if wrong guess ourselfs
			If @error Or Not FileExists($AutoItDir & "\autoit3.exe") Then
				$AutoItDir = @ProgramFilesDir & "\AutoIt3"
			EndIf
		EndIf
		$AutoItDir = StringReplace($AutoItDir & "\", "\", "\\")
		FileWriteLine(@ScriptDir & "\updateDefs.log", "$AutoItDir=" & $AutoItDir)
		$H_NewInput = FileOpen($NewAbbrFile, 0)
		If $H_NewInput <> -1 Then
			FileWriteLine($H_Output, "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#")
			FileWriteLine($H_Output, "Created by UpdateDefs  (don't change anything between the dashed lines)")
			FileWriteLine($H_Output, "#------------------------------------------------------------")
			$I_Rec = FileReadLine($H_NewInput)
			While Not @error
				FileWriteLine($H_Output, StringReplace($I_Rec, "C:\\Program Files\\Autoit3\\", $AutoItDir))
				$I_Rec = FileReadLine($H_NewInput)
			WEnd
			FileWriteLine($H_Output, "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#")
			FileClose($H_NewInput)
		EndIf
	EndIf
	FileClose($H_Output)
	FileCopy($AbbrFile, $AbbrFile & ".bak", 1)
	$RC = FileMove(@TempDir & "\abbrev.properties", $AbbrFile, 1)
	FileWriteLine(@ScriptDir & "\updateDefs.log", "FileReplaced $AbbrFile rc=" & $RC)
EndFunc   ;==>UpdateAbbr
;
Func Reload_Config()
	Opt("WinSearchChildren", 1)
	;Send SciTE Director my GUI handle so it will report info back from SciTE
	Local $SciTE_hwnd = WinGetHandle("DirectorExtension")
	SendSciTE_Command(0, $SciTE_hwnd, "reloadproperties:")
EndFunc   ;==>Reload_Config
;
Func SendSciTE_Command($My_Hwnd, $SciTE_hwnd, $sCmd)
	Local $WM_COPYDATA = 74
	Local $CmdStruct = DllStructCreate('Char[' & StringLen($sCmd) + 1 & ']')
	;ConsoleWrite('-->' & $sCmd & @lf )
	DllStructSetData($CmdStruct, 1, $sCmd)
	Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr')
	DllStructSetData($COPYDATA, 1, 1)
	DllStructSetData($COPYDATA, 2, StringLen($sCmd) + 1)
	DllStructSetData($COPYDATA, 3, DllStructGetPtr($CmdStruct))
	DllCall('User32.dll', 'None', 'SendMessage', 'HWnd', $SciTE_hwnd, _
			'Int', $WM_COPYDATA, 'HWnd', $My_Hwnd, _
			'Ptr', DllStructGetPtr($COPYDATA))
EndFunc   ;==>SendSciTE_Command
