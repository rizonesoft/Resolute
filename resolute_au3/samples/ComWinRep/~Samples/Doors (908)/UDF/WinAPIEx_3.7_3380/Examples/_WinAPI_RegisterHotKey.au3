#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)
Opt('TrayAutoPause', 0)

Global $hWnd

OnAutoItExitRegister('OnAutoItExit')

$hWnd = GUICreate('')
GUIRegisterMsg($WM_HOTKEY, 'WM_HOTKEY')

; Set ALT-D
_WinAPI_RegisterHotKey($hWnd, 0x0144, $MOD_ALT, 0x44)
; Set ESC
_WinAPI_RegisterHotKey($hWnd, 0x011B, 0, 0x1B)

While 1
    Sleep(1000)
WEnd

Func WM_HOTKEY($hWnd, $iMsg, $wParam, $lParam)
	Switch _WinAPI_HiWord($lParam)
		Case 0x44
			MsgBox(0, '', 'You pressed ALT-D')
		Case 0x1B
			Exit
	EndSwitch
EndFunc   ;==>WM_HOTKEY

Func OnAutoItExit()
	_WinAPI_UnregisterHotKey($hWnd, 0x0144)
EndFunc   ;==>OnAutoItExit
