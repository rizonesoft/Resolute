#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\UUIDGen.ico
#AutoIt3Wrapper_Outfile=UUIDGen.exe
#AutoIt3Wrapper_Res_Description=UUID Generator
#AutoIt3Wrapper_Res_Fileversion=0.2.6.276
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=© 2013, Datum
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Comments|UUID Generator
#AutoIt3Wrapper_Res_Field=Original File Name|UUIDGen.exe
#AutoIt3Wrapper_Res_Field=Product Name|UUID Generator
#AutoIt3Wrapper_Res_Field=Product Version|0.2
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****




Opt("GUICloseOnESC", 1) ; Default tray menu items (Script Paused/Exit) will not be shown.
Opt("MustDeclareVars", 1)
; Opt("TrayIconDebug", 1) ; 0 = no info, 1 = debug line info


#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>

;#include <UDF\Functions.au3>


Global Const $GUUIDTitle = "UUID Generator", $GUUIDVer = FileGetVersion(@ScriptFullPath)
Global Const $GUUIDFTitle = $GUUIDTitle & " " & $GUUIDVer
Global $GUUIDForm, $iUUID, $ChkAutoCopy, $BtnGen, $BtnCopy, $ChkReg, $BtnAbout
Global $GFSm, $Braces, $AutoCopy

Const $ERROR_SUCCESS = 0
Const $RPC_S_OK = $ERROR_SUCCESS
Const $RPC_S_UUID_LOCAL_ONLY = 1824
Const $RPC_S_UUID_NO_ADDRESS = 1739

$GUUIDForm = GUICreate($GUUIDFTitle, 430, 220, Default, Default)
GUISetFont(8.5, 400, 0, "Verdana")
GUICtrlCreateIcon(@ScriptFullPath, 99, 10, 10, 64, 64)

GuiCtrlCreateLabel(	"An Universally Unique Identifier (UUID) is a 128-bit integer number used to identify " & _
					"resources. UUIDs are used in programming as database keys, component identifiers, or " & _
					"just about anywhere else a truly unique identifier is required.", 90, 10, 320, 100)
$BtnGen = GUICtrlCreateButton("&Generate", 10, 110, 100, 30)
$BtnCopy = GUICtrlCreateButton("&Copy", 115, 110, 100, 30)
$BtnAbout = GUICtrlCreateButton("About...", 310, 110, 100, 30)

_LoadSettings()

$iUUID = GUICtrlCreateInput(_GenerateUUID(), 10, 155, 400, 25)
GUICtrlSetFont($iUUID, 10)

$ChkReg = GUICtrlCreateCheckbox("{&Braces}", 230, 115)
$ChkAutoCopy = GUICtrlCreateCheckbox("Copy to clipboard after generating.", 10, 190)

If $Braces = 1 Then
	GuiCtrlSetState($ChkReg, $GUI_CHECKED)
	_ClickBraces()
EndIf
If $AutoCopy = 1 Then
	GuiCtrlSetState($ChkAutoCopy, $GUI_CHECKED)
EndIf

HotKeySet("!G", "_ClickGenerateButton")
HotKeySet("!C", "_ClickCopyButton")
HotKeySet("!B", "_ClickBraces")

GUISetState(@SW_SHOW)


While 1

	Sleep(20) ;~ Idle
	;_ReduceMemory()

	Local $nMsg = GUIGetMsg()
	Switch $nMsg
		Case $BtnGen
			_ClickGenerateButton()
		Case $BtnCopy
			_ClickCopyButton()
		Case $ChkReg
			_ClickBraces()
		Case $BtnAbout
			_AboutDlg($GUUIDForm, $GUUIDTitle, $GUUIDVer)
		Case $GUI_EVENT_CLOSE
			_SaveSettings()
			GUIDelete($GUUIDForm)
			Exit

	EndSwitch
WEnd

Func _ClickGenerateButton()
	If GUICtrlRead($ChkReg) = $GUI_CHECKED Then
		GUICtrlSetData($iUUID, "{" & _GenerateUUID() & "}")
	Else
		GUICtrlSetData($iUUID, _GenerateUUID())
	EndIf
	;GuiCtrlSetState($iUUID, $GUI_FOCUS)
	If GUICtrlRead($ChkAutoCopy) = $GUI_CHECKED Then
		_ClickCopyButton()
	EndIf
EndFunc

Func _ClickCopyButton()
	ClipPut(GUICtrlRead($iUUID))
EndFunc

Func _ClickBraces()
	If GUICtrlRead($ChkReg) = $GUI_CHECKED Then
		GUICtrlSetData($iUUID, "{" & GUICtrlRead($iUUID) & "}")
	Else
		GUICtrlSetData($iUUID, StringReplace(GUICtrlRead($iUUID), "{", ""))
		GUICtrlSetData($iUUID, StringReplace(GUICtrlRead($iUUID), "}", ""))
	EndIf
EndFunc

Func _GenerateUUID()

	Local $_GUID = DllStructCreate("uint;ushort;ushort;ubyte[8]")
	If @error Then Exit

	Local $Return = DllCall("Rpcrt4.dll", "ptr", "UuidCreate", "ptr", DllStructGetPtr($_GUID))
	If Not @error Then
		If $Return[0] = $ERROR_SUCCESS Then
			Local $UUID = 	Hex(DllStructGetData($_GUID, 1), 8) & "-" & _
							Hex(DllStructGetData($_GUID, 2), 4) & "-" & _
							Hex(DllStructGetData($_GUID, 3), 4) & "-" & _
							Hex(DllStructGetData($_GUID, 4, 1), 2) & Hex(DllStructGetData($_GUID, 4, 2), 2) & "-"
			For $x = 3 To 8
				$UUID = $UUID & Hex(DllStructGetData($_GUID, 4, $x), 2)
			Next
		EndIf
	EndIf
	$_GUID = 0
	Return $UUID

EndFunc


Func _LoadSettings()
	$Braces = IniRead(@ScriptDir & "\UUIDGen.ini", "Main", "Braces", 1)
	$AutoCopy = IniRead(@ScriptDir & "\UUIDGen.ini", "Main", "AutoCopy", 1)
EndFunc

Func _SaveSettings()
	IniWrite(@ScriptDir & "\UUIDGen.ini", "Main", "Braces", GuiCtrlRead($ChkReg))
	IniWrite(@ScriptDir & "\UUIDGen.ini", "Main", "AutoCopy", GuiCtrlRead($ChkAutoCopy))
EndFunc


Func _AboutDlg($hParent = 0, $aTitle = "", $aVer = "0.0.0.0")

	Local $hAbout, $aHome, $aSpaceLabel, $aSpaceProg, $aBtnOK, $aMsg
	Local $aScriptDrive = StringSplit(@ScriptDir, "\")
	Local $DrvSpaceUsed = DriveSpaceTotal($aScriptDrive[1]) - DriveSpaceFree($aScriptDrive[1])

	WinSetOnTop($hParent, "", 0)
	GUISetState(@SW_DISABLE, $hParent)

	$hAbout = GUICreate("About : " & $aTitle, 400, 300, Default, Default, BitOR($WS_CAPTION, $WS_POPUP, $WS_SYSMENU), -1, $hParent)
	GUISetFont(8.5, 400, 0, "Verdana")
	GUICtrlCreateIcon(@ScriptFullPath, 99, 8, 8, 64, 64)
	GUICtrlCreateLabel($aTitle, 88, 16, 300, 18)
	GUICtrlSetFont(-1, 9, 800, 0, "Verdana")
	GUICtrlCreateLabel("Version " & $aVer & @CRLF & "Copyright © 2013, Datum", 88, 40, 300, 40)

	GUICtrlCreateLabel(	"Only those who can see the invisible can accomplish the impossible. " & _
						"Thank you to all of you for using our sometimes useless freeware." , 15, 80, 350, 50)
	GuiCtrlSetColor(-1, 0xA0A0A0)

	$aHome = GUICtrlCreateLabel("http://datumza.com", 15, 130, 159, 15)
	GuiCtrlSetFont($aHome, 8.5, -1, 4) ;Underlined
	GuiCtrlSetColor($aHome, 0x0000FF)
	GuiCtrlSetCursor($aHome, 0)

	$aSpaceLabel = 	GUICtrlCreateLabel("(" & $aScriptDrive[1] & ") " & Round(DriveSpaceFree($aScriptDrive[1]) / 1024, 1) & " GB free of " & _
					Round(DriveSpaceTotal($aScriptDrive[1]) / 1024, 1) & " GB", 15, 180, 300, 15)
	$aSpaceProg = GUICtrlCreateProgress(15, 200, 300, 20)
	GUICtrlSetData($aSpaceProg, ($DrvSpaceUsed / DriveSpaceTotal($aScriptDrive[1])) * 100)

	GUICtrlSetCursor(-1, 0)

	$aBtnOK = GUICtrlCreateButton("OK", 250, 250, 123, 33, $BS_DEFPUSHBUTTON)

	GUISetState(@SW_SHOW, $hAbout)

	While 1

		$aMsg = GUIGetMsg()
		Switch $aMsg
			Case $GUI_EVENT_CLOSE, $aBtnOK
				ExitLoop
			Case $aHome
				ShellExecute("http://datumza.com")
		EndSwitch

	WEnd

	GUISetState(@SW_ENABLE, $hParent)
	GUIDelete($hAbout)

EndFunc