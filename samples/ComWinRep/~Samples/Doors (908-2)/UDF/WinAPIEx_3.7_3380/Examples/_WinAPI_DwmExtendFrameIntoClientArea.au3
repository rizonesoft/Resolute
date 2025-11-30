#Include <APIConstants.au3>
#Include <GUITab.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)
Opt('TrayAutoPause', 0)

If Not _WinAPI_DwmIsCompositionEnabled() Then
	MsgBox(16, 'Error', 'Require Windows Vista or later with enabled Aero theme.')
	Exit
EndIf

Global Const $PRF_CLIENT = 0x04

Global $hForm, $hTab, $hDll, $pDll, $hProc

OnAutoItExitRegister('OnAutoItExit')

; Create GUI
$hForm = GUICreate('MyGUI', 400, 400)
GUICtrlCreateTab(0, 60, 402, 341, $WS_CLIPCHILDREN)
$hTab = GUICtrlGetHandle(-1)
GUICtrlCreateTabItem('Tab 1')
GUICtrlCreateButton('Button', 150, 167, 100, 26)
_WinAPI_SetParent(GUICtrlGetHandle(-1), $hTab)
GUICtrlCreateTabItem('Tab 2')
GUICtrlCreateEdit('', 14, 34, 372, 292)
_WinAPI_SetParent(GUICtrlGetHandle(-1), $hTab)
GUICtrlCreateTabItem('Tab 3')
GUICtrlCreateTabItem('')
GUISetBkColor(0)

; Register Tab window proc
$hDll = DllCallbackRegister('_WinProc', 'ptr', 'hwnd;uint;wparam;lparam')
$pDll = DllCallbackGetPtr($hDll)
$hProc = _WinAPI_SetWindowLongEx($hTab, $GWL_WNDPROC, $pDll)

; Create the "sheet of glass" effect for the Tab client area. You must call this function whenever DWM composition is toggled.
_WinAPI_DwmExtendFrameIntoClientArea($hForm, _WinAPI_CreateMargins(2, 2, 82, 2))

GUISetState()

Do
Until GUIGetMsg() = -3

Func _CreateClipRgn($hWnd)

	Local $tRECT, $hTmp, $hRgn, $Ht, $Count, $Sel

	$Count = _GUICtrlTab_GetItemCount($hWnd)
	$Sel = _GUICtrlTab_GetCurSel($hWnd)
	$hRgn = _WinAPI_CreateNullRgn()
	For $i = 0 To $Count - 1
		$tRECT = _GUICtrlTab_GetItemRectEx($hWnd, $i)
		If $i = $Sel Then
			$hTmp = _WinAPI_CreateRectRgn(DllStructGetData($tRECT, 1) - 2, DllStructGetData($tRECT, 2) - 2, DllStructGetData($tRECT, 3) + 2, DllStructGetData($tRECT, 4))
			$Ht = DllStructGetData($tRECT, 4) - DllStructGetData($tRECT, 2) + 2
		Else
			If $i = $Count - 1 Then
				$hTmp = _WinAPI_CreateRectRgn(DllStructGetData($tRECT, 1), DllStructGetData($tRECT, 2), DllStructGetData($tRECT, 3) - 2, DllStructGetData($tRECT, 4))
			Else
				$hTmp = _WinAPI_CreateRectRgn(DllStructGetData($tRECT, 1), DllStructGetData($tRECT, 2), DllStructGetData($tRECT, 3), DllStructGetData($tRECT, 4))
			EndIf
		EndIf
		_WinAPI_CombineRgn($hRgn, $hRgn, $hTmp, $RGN_OR)
		_WinAPI_DeleteObject($hTmp)
	Next
	$tRECT = _WinAPI_GetClientRect($hWnd)
	$hTmp = _WinAPI_CreateRectRgn(DllStructGetData($tRECT, 1), DllStructGetData($tRECT, 2) + $Ht, DllStructGetData($tRECT, 3) - 2, DllStructGetData($tRECT, 4) - 1)
	_WinAPI_CombineRgn($hRgn, $hRgn, $hTmp, $RGN_OR)
	_WinAPI_DeleteObject($hTmp)
	Return $hRgn
EndFunc   ;==>_CreateClipRgn

Func _WinProc($hWnd, $iMsg, $wParam, $lParam)
	If _WinAPI_IsThemeActive() Then
		Switch $iMsg
			Case $WM_ERASEBKGND

				Local $tRECT, $hBrush, $hRgn, $hPrev

				$hPrev = _WinAPI_GetClipRgn($wParam)
				$hRgn = _CreateClipRgn($hWnd)
				_WinAPI_ExtSelectClipRgn($wParam, $hRgn, $RGN_DIFF)
				$tRECT = _WinAPI_GetClientRect($hWnd)
				$hBrush = _WinAPI_CreateSolidBrush(0)
				_WinAPI_FillRect($wParam, DllStructGetPtr($tRECT), $hBrush)
				_WinAPI_SelectClipRgn($wParam, $hPrev)
				_WinAPI_DeleteObject($hBrush)
				_WinAPI_DeleteObject($hRgn)
				Return 1
			Case $WM_PAINT

				Local $tPAINTSTRUCT, $hDC, $hRgn

				$hDC = _WinAPI_BeginPaint($hWnd, $tPAINTSTRUCT)
				$hRgn = _CreateClipRgn($hWnd)
				_WinAPI_ExtSelectClipRgn($hDC, $hRgn, $RGN_AND)
				_WinAPI_CallWindowProc($hProc, $hWnd, $WM_PRINTCLIENT, $hDC, $PRF_CLIENT)
				_WinAPI_DeleteObject($hRgn)
				_WinAPI_EndPaint($hWnd, $tPAINTSTRUCT)
				Return 0
		EndSwitch
	EndIf
	Return _WinAPI_CallWindowProc($hProc, $hWnd, $iMsg, $wParam, $lParam)
EndFunc   ;==>_WinProc

Func OnAutoItExit()
	_WinAPI_SetWindowLongEx($hTab, $GWL_WNDPROC, $hProc)
	DllCallbackFree($hDll)
EndFunc   ;==>OnAutoItExit
