#Include <APIConstants.au3>
#Include <EditConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $Msg, $Input, $Button, $Duration = Default, $hBitmap = _WinAPI_CreateSolidBitmap(0, 0x00AEFF, 10, 14)

OnAutoItExitRegister('OnAutoItExit')

$hForm = GUICreate('MyGUI', 400, 93)
$Input = GUICtrlCreateInput('', 20, 20, 360, 20)
$Button = GUICtrlCreateButton('Exit', 165, 59, 70, 23)
GUIRegisterMsg($WM_COMMAND, 'WM_COMMAND')
GUISetState()

While 1
    $Msg = GUIGetMsg()
    Switch $Msg
        Case $GUI_EVENT_CLOSE, $Button
            ExitLoop
    EndSwitch
WEnd

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	Switch $hWnd
		Case $hForm
			Switch _WinAPI_LoWord($wParam)
				Case $Input
					Switch _WinAPI_HiWord($wParam)
						Case $EN_KILLFOCUS
							_WinAPI_HideCaret($lParam)
							_WinAPI_DestroyCaret()
							_WinAPI_SetCaretBlinkTime($Duration)
							$Duration = Default
						Case $EN_SETFOCUS
							$Duration = _WinAPI_SetCaretBlinkTime(-1)
							_WinAPI_CreateCaret($lParam, $hBitmap)
							_WinAPI_ShowCaret($lParam)
					EndSwitch
			EndSwitch
	EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND

Func OnAutoItExit()
	_WinAPI_DeleteObject($hBitmap)
	If $Duration <> Default Then
		_WinAPI_SetCaretBlinkTime($Duration)
	EndIf
EndFunc   ;==>OnAutoItExit
