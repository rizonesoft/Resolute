#Include <APIConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

GUICreate('MyGUI')
GUIRegisterMsg($WM_KEYDOWN, 'WM_KEYDOWN')
GUISetState()

Do
Until GUIGetMsg() = -3

Func WM_KEYDOWN($hWnd, $iMsg, $wParam, $lParam)
	ConsoleWrite(_WinAPI_GetKeyNameText($lParam) & @CR)
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_KEYDOWN
