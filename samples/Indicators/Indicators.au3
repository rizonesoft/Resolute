#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\Indicators.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_Description=Indicators
#AutoIt3Wrapper_Res_Fileversion=0.0.8.81
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=© 2014 Rizonesoft
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Res_Icon_Add=Resources\Gear.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Facebook.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Twitter.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\LinkedIn.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Google.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\RSS.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\PP.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Info.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\00.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\01.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\02.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\03.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\04.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\05.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\06.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\07.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <WinAPISys.au3>

#include <UDF\CoreFunctions.au3>


Opt("GUICloseOnESC", 0)         	;1=ESC  closes, 0=ESC won't close
Opt("GUIOnEventMode", 0)        	;0=disabled, 1=OnEvent mode enabled
Opt("TrayOnEventMode", 1)
Opt("MustDeclareVars", 1)       	;0=no, 1=require pre-declare
Opt("TrayAutoPause", 0)
Opt("TrayMenuMode", 3)


Global $STR_APPNAME = "Indicators", $SET_STARTWIND
Global $TRAYMNU_PREFS, $TRAYMNU_CLOSE, $TRAYMNU_ABOUT
Global $KEYSTATE_DIFF = 0, $DLG_OPTIONS, $DLG_ABOUT, $LBL_ABOUTANNOUNCE
Global $BTN_OPOK, $BTN_OPCANCEL, $BTN_OPAPPLY
Global $CHK_OPAUTOSTART


TrayCreateItem(_GUIGetTitle($STR_APPNAME))
TrayItemSetState(-1, $GUI_DISABLE)
TrayCreateItem("")
$TRAYMNU_PREFS = TrayCreateItem("&Preferences", -1, -1, 0)
$TRAYMNU_ABOUT = TrayCreateItem("&About Indicators", -1, -1, 0)
TrayCreateItem("")
$TRAYMNU_CLOSE = TrayCreateItem("&Close")  ;incase u wanted to close the app

TrayItemSetOnEvent($TRAYMNU_PREFS, "_OptionsDlg")
TrayItemSetOnEvent($TRAYMNU_ABOUT, "_AboutDlg")
TrayItemSetOnEvent($TRAYMNU_CLOSE, "_CloseIndicators")

TraySetIcon(@ScriptFullPath, 201)
TraySetToolTip(_GUIGetTitle($STR_APPNAME))

_toggleKeysState()
AdlibRegister("_toggleKeysState", 250)


While 1
	Sleep(80)
WEnd


Func _CloseIndicators()

	TraySetState(2)
	Exit

EndFunc


Func _toggleKeysState()

	Local $KeyState = 0

	If _GetNumLockState() <> 0 then
		$KeyState += 1
	EndIf

	If _GetScrollLockState() <> 0 Then
		$KeyState += 2
	EndIf

	If _GetCapsLockState() <> 0 Then
		$KeyState += 4
	EndIf

	If $KEYSTATE_DIFF <> $KeyState Then

	Select
		Case $KeyState = 1
			TraySetIcon(@ScriptFullPath, 210)
			TraySetToolTip("Num")
		Case $KeyState = 2
			TraySetIcon(@ScriptFullPath, 211)
			TraySetToolTip("Scroll")
		Case $KeyState = 3
			TraySetIcon(@ScriptFullPath, 212)
			TraySetToolTip("Num - Scroll")
		Case $KeyState = 4
			TraySetIcon(@ScriptFullPath, 213)
			TraySetToolTip("Caps")
		Case $KeyState = 5
			TraySetIcon(@ScriptFullPath, 214)
			TraySetToolTip("Num - Caps")
		Case $KeyState = 6
			TraySetIcon(@ScriptFullPath, 215)
			TraySetToolTip("Caps - Scroll")
		Case $KeyState = 7
			TraySetIcon(@ScriptFullPath, 216)
			TraySetToolTip("Num - Caps - Scroll")
		Case Else
			TraySetIcon(@ScriptFullPath, 217)
			TraySetToolTip("Rizonesoft Indicators " & FileGetVersion(@ScriptFullPath))
	EndSelect

	$KEYSTATE_DIFF = $KeyState
	EndIf

EndFunc


Func _OptionsDlg()

	Opt("GUIOnEventMode", 1)

	$DLG_OPTIONS = GUICreate(	"Indicators ( " & FileGetVersion(@ScriptFullPath) & " ) Preferences", 500, 400, -1, -1, _
								BitOr($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST)
	GUISetFont(9, 400, 0, "Tahoma", $DLG_OPTIONS, 5)

	GUICtrlCreateGroup("", 15, 10, 470, 100)
	$CHK_OPAUTOSTART = GUICtrlCreateCheckbox(" Start 'Indicators' when Windows starts", 25, 30, 300, 15)
	GUICtrlSetState($CHK_OPAUTOSTART, FileExists(@StartupDir & "\Indicators.lnk"))
	$SET_STARTWIND = FileExists(@StartupDir & "\Indicators.lnk")
	GUICtrlSetOnEvent($CHK_OPAUTOSTART, "_OptionsSelectWinStart")
	GUICtrlCreateGroup("", -99, -99, 1, 1)  ;~ Close group

	TrayItemSetState($TRAYMNU_PREFS, $GUI_DISABLE)

	$BTN_OPOK = GUICtrlCreateButton("OK", 170, 350, 100, 30)
	$BTN_OPCANCEL = GUICtrlCreateButton("Cancel", 270, 350, 100, 30)
	$BTN_OPAPPLY = GUICtrlCreateButton("Apply", 370, 350, 100, 30)

	GUICtrlSetState($BTN_OPAPPLY, $GUI_DISABLE)

	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseOptionsDlg", $DLG_OPTIONS)

	GUICtrlSetOnEvent($BTN_OPOK, "_OptionsOK")
	GUICtrlSetOnEvent($BTN_OPCANCEL, "_CloseOptionsDlg")
	GUICtrlSetOnEvent($BTN_OPAPPLY, "_OptionsApply")

	GUISetState(@SW_SHOW, $DLG_OPTIONS)

EndFunc


Func _OptionsSelectWinStart()

	If $SET_STARTWIND = FileExists(@StartupDir & "\Indicators.lnk") Then
		GUICtrlSetState($BTN_OPAPPLY, $GUI_ENABLE)
	Else
		GUICtrlSetState($BTN_OPAPPLY, $GUI_DISABLE)
	EndIf

EndFunc


Func _OptionsOK()

	_OptionsApply()
	_CloseOptionsDlg()

EndFunc


Func _CloseOptionsDlg()

	Opt("GUIOnEventMode", 0)

	TrayItemSetState($TRAYMNU_PREFS, $GUI_ENABLE)
	GUISetState(@SW_HIDE, @GUI_WinHandle)

EndFunc


Func _OptionsApply()

	If GUICtrlRead($CHK_OPAUTOSTART) = $GUI_CHECKED Then
		FileDelete(@StartupDir & "\Indicators.lnk")
		FileCreateShortcut(@ScriptFullPath, @StartupDir & "\Indicators.lnk", @ScriptDir)
	ElseIf GUICtrlRead($CHK_OPAUTOSTART) = $GUI_UNCHECKED Then
		FileDelete(@StartupDir & "\Indicators.lnk")
	EndIf

	$SET_STARTWIND = FileExists(@StartupDir & "\Indicators.lnk")
	GUICtrlSetState($BTN_OPAPPLY, $GUI_DISABLE)

EndFunc


Func _GetNumLockState()
    Return _WinAPI_GetKeyState(0x90)
EndFunc

Func _GetScrollLockState()
    Return _WinAPI_GetKeyState(0x91)
EndFunc

Func _GetCapsLockState()
    Return _WinAPI_GetKeyState(0x14)
EndFunc


Func _AboutDlg()

	TrayItemSetState($TRAYMNU_ABOUT, $GUI_DISABLE)

	Local $abTitle, $abVersion, $abCopyright
	Local $abHome, $abGNU
	Local $abSpaceLabel, $abSpaceProg, $abBtnOK
	Local $abPayPal, $abFacebook, $abTwittter, $abRSS
	Local $abLinkedIn, $abGoogle

	$DLG_ABOUT = GUICreate("About " & $STR_APPNAME, 400, 450, -1, -1, BitOr($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST)
	GUISetFont(8.5, 400, 0, "Verdana", $DLG_ABOUT, 5)
	GUISetIcon(@ScriptFullPath, 208)

	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseAboutDlg", $DLG_ABOUT)

	GUICtrlCreateIcon(@ScriptFullPath, 99, 10, 10, 64, 64)
	$abPayPal = GUICtrlCreateIcon(@ScriptFullPath, 207, 320, 0, 64, 64)
	GUICtrlSetTip($abPayPal, "Help us keep our software free.")
	GUICtrlSetCursor($abPayPal, 0)
	$abTitle = GUICtrlCreateLabel($STR_APPNAME, 88, 16, 220, 18)
	GUICtrlSetFont($abTitle, 11)
	$abVersion = GUICtrlCreateLabel("Version " & FileGetVersion(@ScriptFullPath), 88, 40, 220, 20)
	$abCopyright = GUICtrlCreateLabel("Copyright © 2015 Rizonesoft", 88, 55, 220, 20)
	GUICtrlSetColor($abCopyright, 0x888888)
	$abHome = GUICtrlCreateLabel("www.rizonesoft.com", 88, 80, 200, 20)
	GUICtrlSetColor($abHome, 0x0000FF)
	GUICtrlSetCursor($abHome, 0)

	GUICtrlCreateLabel("", 10, 110, 380, 1)
	GUICtrlSetBkColor(-1, 0xA0A0A0)
	GUICtrlCreateLabel("", 10, 111, 380, 1)
	GUICtrlSetBkColor(-1, 0xFFFFFF)

	$abGNU = GUICtrlCreateLabel("This program is free software: you can redistribute it and/or modify " & _
								"it under the terms of the GNU General Public License as published by " & _
								"the Free Software Foundation, either version 3 of the License, or " & _
								"(at your option) any later version." & @CRLF & @CRLF & _
								"This program is distributed in the hope that it will be useful, " & _
								"but WITHOUT ANY WARRANTY; without even the implied warranty of " & _
								"MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the " & _
								"GNU General Public License for more details.", 20, 125, 350, 180)
	GUICtrlSetColor($abGNU, 0x888888)
	GUICtrlCreateLabel(	"Contributors: Derick Payne (Rizonesoft).", 20, 280, 350, 50)
	$LBL_ABOUTANNOUNCE = GUICtrlCreateLabel(	$STR_APPNAME & " can now be Integrated into the Doors suite. " & _
												"Click here to find out how.", 20, 330, 350, 35)
	GUICtrlSetColor($LBL_ABOUTANNOUNCE, 0x0000FF)
	GUICtrlSetCursor($LBL_ABOUTANNOUNCE, 0)


	Local $ScriptDirSplt = StringSplit(@ScriptDir, "\")
	Local $ScriptDrive  = $ScriptDirSplt[1]
	Local $drvSpaceUsed = DriveSpaceTotal($ScriptDrive) - DriveSpaceFree($ScriptDrive)

;~ 	$abSpaceLabel = GUICtrlCreateLabel("(" & $ScriptDrive & ") " & Round(DriveSpaceFree($ScriptDrive) / 1024, 1) & " GB free of " & _
;~ 					Round(DriveSpaceTotal($ScriptDrive) / 1024, 1) & " GB", 15, 380, 300, 15)
;~ 	$abSpaceProg = GUICtrlCreateProgress(15, 400, 350, 15)
;~ 	GUICtrlSetData($abSpaceProg, ($drvSpaceUsed / DriveSpaceTotal($ScriptDrive)) * 100)
	$abBtnOK = GUICtrlCreateButton("OK", 250, 400, 123, 33, $BS_DEFPUSHBUTTON)

	$abFacebook = GUICtrlCreateIcon(@ScriptFullPath, 202, 20, 400, 32, 32)
	GUICtrlSetTip($abFacebook, "Like us on Facebook and stay updated.")
	GUICtrlSetCursor($abFacebook, 0)
	$abTwittter = GUICtrlCreateIcon(@ScriptFullPath, 203, 55, 400, 32, 32)
	GUICtrlSetTip($abTwittter, "Follow us on Twitter for the latest updates.")
	GUICtrlSetCursor($abTwittter, 0)
	$abLinkedIn = GUICtrlCreateIcon(@ScriptFullPath, 204, 90, 400, 32, 32)
	GUICtrlSetTip($abLinkedIn, "Find us on LinkedIn.")
	GUICtrlSetCursor($abLinkedIn, 0)
	$abGoogle = GUICtrlCreateIcon(@ScriptFullPath, 205, 125, 400, 32, 32)
	GUICtrlSetTip($abGoogle, "Find us on Google.")
	GUICtrlSetCursor($abGoogle, 0)
	$abRSS = GUICtrlCreateIcon(@ScriptFullPath, 206, 160, 400, 32, 32)
	GUICtrlSetTip($abRSS, "Find us on Google.")
	GUICtrlSetCursor($abRSS, 0)

	GUICtrlSetOnEvent($abHome, "_HomePageClicked")
	GUICtrlSetOnEvent($abFacebook, "_OpenFacebook")
	GUICtrlSetOnEvent($abTwittter, "_FollowOnTwitter")
	GUICtrlSetOnEvent($abLinkedIn, "_OpenLinkedIn")
	GUICtrlSetOnEvent($abGoogle, "_OpenGoogle")
	GUICtrlSetOnEvent($abBtnOK, "_CloseAboutDlg")
	GUICtrlSetOnEvent($abPayPal, "_DonateSomething")

	GUISetState(@SW_SHOW, $DLG_ABOUT)


EndFunc

Func _CloseAboutDlg()

	TrayItemSetState($TRAYMNU_ABOUT, $GUI_ENABLE)
	GUIDelete($DLG_ABOUT)

EndFunc

Func _HomePageClicked()
	ShellExecute("http://www.rizonesoft.com")
EndFunc


Func _OpenFacebook()
	ShellExecute("https://www.facebook.com/rizonesoft")
EndFunc


Func _FollowOnTwitter()
	ShellExecute("https://twitter.com/rizonesoft")
EndFunc


Func _OpenLinkedIn()
	ShellExecute("http://www.linkedin.com/in/rizonesoft")
EndFunc


Func _OpenGoogle()
	ShellExecute("https://plus.google.com/+Rizonesoftsa/posts")
EndFunc


Func _DonateSomething()
	ShellExecute("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7UGGCSDUZJPFE")
EndFunc