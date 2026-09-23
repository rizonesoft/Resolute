#Include <GUIConstantsEx.au3>
#Include <WinAPIEx.au3>
#Include <WindowsConstants.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $Msg, $Button

$hForm = GUICreate('MyGUI', 400, 400, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_SYSMENU))
$Button = GUICtrlCreateButton('About', 165, 370, 70, 23)
GUISetState()

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case $Button
			_AboutDlg($hForm)
	EndSwitch
WEnd

Func _AboutDlg($hWnd)

	Local $hDlg, $Msg, $Button

	GUISetState(@SW_DISABLE, $hWnd)
	$hDlg = GUICreate('About', 300, 300, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_SYSMENU), -1, $hWnd)
	$Button = GUICtrlCreateButton('OK', 115, 270, 70, 23)
	GUISetState()

	While 1
		$Msg = GUIGetMsg()
		Switch $Msg
			Case $GUI_EVENT_CLOSE
				ExitLoop
			Case $Button
				ExitLoop
		EndSwitch
	WEnd

	_WinAPI_SetActiveWindow($hWnd)
	GUIDelete($hDlg)
	GUISetState(@SW_ENABLE, $hWnd)
EndFunc   ;==>_AboutDlg
