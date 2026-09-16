#Include <APIConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If Not _WinAPI_DwmIsCompositionEnabled() Then
	MsgBox(16, 'Error', 'Require Windows Vista or later with enabled Aero theme.')
	Exit
EndIf

Global $hForm, $hLabel, $hDll, $pDll, $hProc

OnAutoItExitRegister('OnAutoItExit')

; Create GUI
$hForm = GUICreate('MyGUI', 240, 240)
GUICtrlCreateIcon(@ScriptDir & '\Extras\Soccer.ico', 0, 88, 68, 64, 64)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlCreateLabel('', 70, 130, 100, 30)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetState(-1, $GUI_DISABLE)
$hLabel = GUICtrlGetHandle(-1)
GUISetBkColor(0)

; Register label window proc
$hDll = DllCallbackRegister('_WinProc', 'ptr', 'hwnd;uint;wparam;lparam')
$pDll = DllCallbackGetPtr($hDll)
$hProc = _WinAPI_SetWindowLongEx($hLabel, $GWL_WNDPROC, $pDll)

; Create the "sheet of glass" effect for the entire window. You must call this function whenever DWM composition is toggled.
_WinAPI_DwmExtendFrameIntoClientArea($hForm)

GUISetState()

Do
Until GUIGetMsg() = $GUI_EVENT_CLOSE

Func _DrawText($hDC, $sText, $tRECT)

	; Original idea by Authenticity

	Local $tDTTOPTS, $Width, $Height, $pBits, $hBitmap, $hFont, $hTheme, $hMemDC, $hSv1, $hSv2

	$Width = DllStructGetData($tRECT, 3) - DllStructGetData($tRECT, 1)
	$Height = DllStructGetData($tRECT, 4) - DllStructGetData($tRECT, 2)

	$tDTTOPTS = DllStructCreate($tagDTTOPTS)
	DllStructSetData($tDTTOPTS, 'Size', DllStructGetSize($tDTTOPTS))
	DllStructSetData($tDTTOPTS, 'Flags', BitOR($DTT_TEXTCOLOR, $DTT_GLOWSIZE, $DTT_COMPOSITED))
	DllStructSetData($tDTTOPTS, 'clrText', 0x0000C0)
	DllStructSetData($tDTTOPTS, 'GlowSize', 12)

	$hMemDC = _WinAPI_CreateCompatibleDC($hDC)
	$hBitmap = _WinAPI_CreateDIB($Width, -$Height)
	$hSv1 = _WinAPI_SelectObject($hMemDC, $hBitmap)
	$hFont = _WinAPI_CreateFont(26, 0, 0, 0, $FW_NORMAL, 0, 0, 0, $DEFAULT_CHARSET, $OUT_DEFAULT_PRECIS, $CLIP_DEFAULT_PRECIS, $DEFAULT_QUALITY, $DEFAULT_PITCH, 'Segoe Script')
	$hSv2 = _WinAPI_SelectObject($hMemDC, $hFont)
	$tRECT = _WinAPI_CreateRect(0, 0, $Width, $Height)
	$hTheme = _WinAPI_OpenThemeData($hForm, 'Globals')

	_WinAPI_DrawThemeTextEx($hTheme, 0, 0, $hMemDC, $sText, $tRECT, BitOR($DT_CENTER, $DT_SINGLELINE, $DT_VCENTER), $tDTTOPTS)
	_WinAPI_BitBlt($hDC, 0, 0, $Width, $Height, $hMemDC, 0, 0, $SRCCOPY)

	_WinAPI_CloseThemeData($hTheme)
	_WinAPI_SelectObject($hMemDC, $hSv1)
	_WinAPI_DeleteObject($hBitmap)
	_WinAPI_SelectObject($hMemDC, $hSv2)
	_WinAPI_DeleteObject($hFont)
	_WinAPI_DeleteDC($hMemDC)
EndFunc   ;==>_DrawText

Func _WinProc($hWnd, $iMsg, $wParam, $lParam)
	Switch $iMsg
		Case $WM_PAINT

			Local $tPAINTSTRUCT, $hDC

			$hDC = _WinAPI_BeginPaint($hWnd, $tPAINTSTRUCT)
			_DrawText($hDC, 'Soccer', _WinAPI_GetClientRect($hWnd))
			_WinAPI_EndPaint($hWnd, $tPAINTSTRUCT)
			Return 0
	EndSwitch
	Return _WinAPI_CallWindowProc($hProc, $hWnd, $iMsg, $wParam, $lParam)
EndFunc   ;==>_WinProc

Func OnAutoItExit()
	_WinAPI_SetWindowLongEx($hLabel, $GWL_WNDPROC, $hProc)
	DllCallbackFree($hDll)
EndFunc   ;==>OnAutoItExit
