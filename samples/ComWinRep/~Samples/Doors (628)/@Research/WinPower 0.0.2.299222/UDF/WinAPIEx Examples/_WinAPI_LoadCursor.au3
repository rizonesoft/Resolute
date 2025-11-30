#Include <GUIConstantsEx.au3>
#Include <WinAPIEx.au3>
#Include <WindowsConstants.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $hCursor

;$hCursor = _WinAPI_LoadCursor(0, 32649) ; IDC_HAND
$hCursor = _WinAPI_LoadCursor(_WinAPI_GetModuleHandle(@SystemDir & '\user32.dll'), 116)

$hForm = GUICreate('MyGUI')
GUIRegisterMsg($WM_SETCURSOR, 'WM_SETCURSOR')
GUISetState()

Do
Until GUIGetMsg() = $GUI_EVENT_CLOSE

Func WM_SETCURSOR($hWnd, $iMsg, $wParam, $lParam)
	Switch $hWnd
		Case $hForm
			_WinAPI_SetCursor($hCursor)
			Return 0
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_SETCURSOR
