#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.1' Then
	MsgBox(16, 'Error', 'Require Windows 7 or later.')
	Exit
EndIf

Global $hForm, $Msg, $Button

$hForm = GUICreate('MyGUI', 400, 400)
$Button = GUICtrlCreateButton('New Window', 145, 366, 110, 23)
GUISetState()

While 1
    $Msg = GUIGetMsg()
    Switch $Msg
        Case -3
            ExitLoop
        Case $Button
			_PopupDlg($hForm)
    EndSwitch
WEnd

Func _PopupDlg($hParent)

	GUISetState(@SW_DISABLE, $hParent)

	Local $hDlg, $Msg, $Button, $tRECT, $tPOINT = DLLStructCreate($tagPOINT)

	For $i = 1 To 2
		DllStructSetData($tPOINT, $i, 0)
	Next
	_WinAPI_ClientToScreen($hParent, $tPOINT)
	$hDlg = GUICreate('New Window', 400, 400)
	$Button = GUICtrlCreateButton('Close', 165, 366, 70, 23)
	$tRECT = _WinAPI_CalculatePopupWindowPosition(DllStructGetData($tPOINT, 1), DllStructGetData($tPOINT, 2), _WinAPI_GetWindowWidth($hDlg), _WinAPI_GetWindowHeight($hDlg))
	WinMove($hDlg, '', DllStructGetData($tRECT, 1), DllStructGetData($tRECT, 2))
	GUISetState(@SW_SHOW, $hDlg)

	While 1
		$Msg = GUIGetMsg()
		Switch $Msg
			Case -3, $Button
				ExitLoop
		EndSwitch
	WEnd

	GUISetState(@SW_ENABLE, $hParent)
	GUIDelete($hDlg)

EndFunc   ;==>_PopupDlg
