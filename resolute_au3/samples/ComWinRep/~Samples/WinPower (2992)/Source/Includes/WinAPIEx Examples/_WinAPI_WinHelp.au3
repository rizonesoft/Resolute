#Include <WinAPIEx.au3>
#Include <WindowsConstants.au3>

Opt('MustDeclareVars', 1)

Global $hForm

$hForm = GUICreate('MyGUI', 400, 400, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_SYSMENU), $WS_EX_CONTEXTHELP)
GUIRegisterMsg($WM_NCLBUTTONDOWN, 'WM_NCLBUTTONDOWN')
GUISetState()

Do
Until GUIGetMsg() = -3

_WinAPI_WinHelp($hForm, $HELP_QUIT)
GUIDelete($hForm)

Func WM_NCLBUTTONDOWN($hWnd, $iMsg, $wParam, $lParam)
	Switch $wParam
		Case 0x15 ; HTHELP
			_WinAPI_WinHelp($hForm, $HELP_FORCEFILE, @SystemDir & '\winhelp.hlp')
	EndSwitch
	Return 'GUI_RUNDEFMSG'
EndFunc   ;==>WM_NCLBUTTONDOWN
