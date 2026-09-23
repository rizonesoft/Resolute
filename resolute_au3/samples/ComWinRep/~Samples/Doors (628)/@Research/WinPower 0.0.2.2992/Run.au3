#AutoIt3Wrapper_icon=Resources\Run.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=Rizone's Run
#AutoIt3Wrapper_Res_Fileversion=0.0.0.76
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=© 2009 Rizone Technologies

#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <GUIConstants.au3>
#include <GUIComboBox.au3>

Opt("TrayMenuMode", 1)

Global Const $RunTitle = "Rizone's Run", $RunVer = FileGetVersion(@ScriptDir & "\" & @ScriptName)
Global Const $GPowerRes = @ScriptDir & "\WinPower.dll"
Global $HelpTips[1][1]
Global $sRunList = "", $LastRunList = ""

; Read the current FileRun list
For $i = 97 To 122
	$CurrentRunVal = RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU", Chr($i))
	If StringRegExp(StringRight($CurrentRunVal, 2), "\\[0-9]") Then $CurrentRunVal = StringTrimRight($CurrentRunVal, 2)
	$sRunList &= $CurrentRunVal & "|"
Next
If StringRight($sRunList, 1) = "|" Then StringTrimRight($sRunList, 1)
;Local $LastRunArr = StringSplit($RunList, "|")
;If IsArray($LastRunArr) Then $LastRun = $LastRunArr[$LastRunArr[0]]


$RunGUI = GUICreate($RunTitle & " " & $RunVer, 380, 210, -1, -1, 0x00080000, BitOR($WS_EX_CONTEXTHELP, $WS_EX_TOPMOST))
GUISetFont(8.5, 400, 0, "Verdana")
$RunLabel = GUICtrlCreateLabel("Type the name of program, folder, document, or internet " & _
									 "resource (Url), that you wish to run:", 75, 25, 290, 60)
$RunIcon = GUICtrlCreateIcon($GPowerRes, 10, 10, 10, 48, 48)
_GUICtrlSetHelpTipText($RunIcon, "Nothing special here. Just an icon.")
GUICtrlCreateLabel("Open:", 15, 83, 60)
$RunCombo = GUICtrlCreateCombo("", 65, 80, 295, 18)
GUICtrlSetData($RunCombo, $sRunList, $LastRunList)
	;GUICtrlSetState($hFR_ComboBox, 256)

$RunButton = GUICtrlCreateButton("Run", 50, 120, 100, 30, BitOr($GUI_SS_DEFAULT_BUTTON, $BS_DEFPUSHBUTTON))
GUICtrlSetFont(-1, 8.5, 800, 0)
$CancelButton = GUICtrlCreateButton("Cancel", 155, 120, 100, 30)
$BrowseButton = GUICtrlCreateButton("Browse...", 260, 120, 100, 30)

;GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
GUIRegisterMsg($WM_HELP, "WM_HELP")
GUIRegisterMsg($WM_WINDOWPOSCHANGED, "WM_WINDOWPOSCHANGED")
GUISetState(@SW_SHOW, $RunGUI)

While 1

	$TIPTimer = TimerInit()
	$aCursorInfo = GUIGetCursorInfo($RunGUI)

		If $aCursorInfo[2] = 1 Or TimerDiff($TIPTimer) >= 5000 Then
			ToolTip("")
			$TIPTimer = TimerInit()
		EndIf

	$iMsg = GUIGetMsg()

	Switch $iMsg
		Case $GUI_EVENT_CLOSE, $CancelButton
			ExitLoop
		Case $RunButton
			Local $sComboRead = StringStripWS(GUICtrlRead($RunCombo), 3)
			Local $sWorkDir = StringRegExpReplace($sComboRead, '\\[^\\]', '')

			If Not @error And $sWorkDir <> $sComboRead Then FileChangeDir($sWorkDir)

			GUISetState(@SW_HIDE, $RunGUI)
			_ExecuteProc($sComboRead)

			If @error Or $sComboRead = "" Then
				GUISetState(@SW_SHOW, $RunGUI)
				ContinueLoop
			EndIf

			ExitLoop
	EndSwitch
WEnd

Func _ExecuteProc($sCommand, $sArgs = "", $sFolder = "", $sVerb = "", $vState = @SW_SHOWNORMAL)

	Local $sCmdPid = Run($sCommand, $sFolder, $vState)
	Local $iRunError = @error

	If Not $iRunError Then Return SetError(0, 0, 1)
	ShellExecute($sCommand, $sArgs, $sFolder, $sVerb, $vState)

	Return SetError(@error)

EndFunc

Func _GUICtrlSetHelpTipText($iCtrlID, $sText, $sTitle="")
	$HelpTips[0][0] += 1

	ReDim $HelpTips[$HelpTips[0][0]+1][3]

	$HelpTips[$HelpTips[0][0]][0] = GUICtrlGetHandle($iCtrlID)
	$HelpTips[$HelpTips[0][0]][1] = $sText
	$HelpTips[$HelpTips[0][0]][2] = $sTitle
EndFunc

Func WM_HELP($hWnd, $MsgID, $WParam, $LParam)
	Local $sTipText = "", $sTitle = "Help..."

	Local $stHELPINFO = DllStructCreate("int cbSize;int iContextType;int iCtrlId;hwnd hItemHandle;" & _
		"dword dwContextId;long MousePos[2]", $lParam)

    Local $hControl = DllStructGetData($stHELPINFO, "hItemHandle")
	Local $iX_Mouse = DllStructGetData($stHELPINFO, "MousePos", 1)
	Local $iY_Mouse = DllStructGetData($stHELPINFO, "MousePos", 2)

	For $i = 1 To $HelpTips[0][0]
		If $hControl = $HelpTips[$i][0] Then
			$sTipText = $HelpTips[$i][1]
			$sTitle = $HelpTips[$i][2]
			ExitLoop
		EndIf
	Next
	$TIPTimer = TimerInit()
	ToolTip($sTipText, $iX_Mouse, $iY_Mouse, $sTitle, 1, 1)
	Sleep(500)
EndFunc

Func WM_WINDOWPOSCHANGED($hWnd, $MsgID, $WParam, $LParam)
	ToolTip("")
	$TIPTimer = TimerInit()
EndFunc
