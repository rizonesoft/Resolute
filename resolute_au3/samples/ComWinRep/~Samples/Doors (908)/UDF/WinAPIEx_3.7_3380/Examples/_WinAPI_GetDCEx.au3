#Include <APIConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hFont = _WinAPI_CreateFont(16, 0, 0, 0, $FW_BOLD, 0, 0, 0, $DEFAULT_CHARSET, $OUT_DEFAULT_PRECIS, $CLIP_DEFAULT_PRECIS, $DEFAULT_PITCH, $ANTIALIASED_QUALITY, 'Arial')
Global $hForm, $hDll, $pDll, $hProc, $Dwm = False

If (_WinAPI_GetVersion() > '5.2') And (_WinAPI_DwmIsCompositionEnabled()) Then
	If MsgBox(35, 'DWM', 'This example works only if a Desktop Window Manager (DWM) composition is disabled.' & @CR & @CR & 'Do you want to disable DWM?') = 6 Then
		_WinAPI_DwmEnableComposition(0)
		$Dwm = True
	Else
		Exit
	EndIf
EndIf

OnAutoItExitRegister('OnAutoItExit')

; Create GUI
$hForm = GUICreate('', 400, 400)

; Register window proc
$hDll = DllCallbackRegister('_WinProc', 'ptr', 'hwnd;uint;long;ptr')
$pDll = DllCallbackGetPtr($hDll)
$hProc = _WinAPI_SetWindowLongEx($hForm, $GWL_WNDPROC, $pDll)

GUISetState()

Do
Until GUIGetMsg() = $GUI_EVENT_CLOSE

Func _WinProc($hWnd, $iMsg, $wParam, $lParam)

	Local $Res = _WinAPI_CallWindowProc($hProc, $hWnd, $iMsg, $wParam, $lParam)

	Switch $iMsg
		Case $WM_NCACTIVATE, $WM_NCPAINT

			Local $hDC, $hSv

			Switch $iMsg
				Case $WM_NCACTIVATE
					$hDC = _WinAPI_GetWindowDC($hWnd)
				Case $WM_NCPAINT
					$hDC = _WinAPI_GetDCEx($hWnd, $wParam, BitOR($DCX_WINDOW, $DCX_INTERSECTRGN))
			EndSwitch
			$hSv = _WinAPI_SelectObject($hDC, $hFont)
			_WinAPI_SetTextColor($hDC, 0x00FFFF)
			_WinAPI_SetBkMode($hDC, $TRANSPARENT)
			_WinAPI_TextOut($hDC, 25, 8, 'MyGUI')
			_WinAPI_SelectObject($hDC, $hSv)
			_WinAPI_ReleaseDC($hWnd, $hDC)
	EndSwitch
	Return $Res
EndFunc   ;==>_WinProc

Func OnAutoItExit()
	_WinAPI_SetWindowLongEx($hForm, $GWL_WNDPROC, $hProc)
	DllCallbackFree($hDll)
	If $Dwm Then
		_WinAPI_DwmEnableComposition(1)
	EndIf
EndFunc   ;==>OnAutoItExit
