#Include <APIConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $Label, $hInstance, $hCursor = _WinAPI_LoadCursorFromFile(@ScriptDir & '\Extras\Lens.cur')

OnAutoItExitRegister('OnAutoItExit')

$hForm = GUICreate('MyGUI', 400, 400)
$Label = GUICtrlCreateLabel('', 100, 100, 200, 200)
GUICtrlSetBkColor(-1, 0xD3D8EF)
GUICtrlSetState(-1, $GUI_DISABLE)
GUIRegisterMsg($WM_SETCURSOR, 'WM_SETCURSOR')
GUISetState()

Do
Until GUIGetMsg() = -3

Func WM_SETCURSOR($hWnd, $iMsg, $wParam, $lParam)
	Switch $hWnd
		Case $hForm

			Local $Cursor = GUIGetCursorInfo($hForm)

			If (Not @error) And ($Cursor[4] = $Label) Then
				_WinAPI_SetCursor($hCursor)
				Return 0
			EndIf
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_SETCURSOR

Func OnAutoItExit()
	_WinAPI_DestroyCursor($hCursor)
EndFunc   ;==>OnAutoItExit
