#Include <APIConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <ScreenCapture.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If (_WinAPI_GetVersion() < '6.1') Or (Not _WinAPI_DwmIsCompositionEnabled()) Then
	MsgBox(16, 'Error', 'Require Windows 7 or later with enabled Aero theme.')
	Exit
EndIf

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $Widht = @DesktopWidth / 2, $Height = @DesktopHeight / 2
Global $hForm, $hPic, $Msg, $Button, $Check

$hForm = GUICreate('MyGUI', $Widht + 116, $Height + 51)
GUICtrlCreatePic('', 14, 14, $Widht + 2, $Height + 2, -1, $WS_EX_STATICEDGE)
GUICtrlSetState(-1, $GUI_DISABLE)
$hPic = GUICtrlGetHandle(-1)
$Check = GUICtrlCreateCheckbox('Protect against capture of window', 14, $Height + 23, 182, 21)
$Button = GUICtrlCreateButton('Capture', $Widht + 29, 13, 74, 25)
GUICtrlSetState(-1, BitOR($GUI_DEFBUTTON, $GUI_FOCUS))
GUISetState()

While 1
	$Msg = GUiGetMsg()
	Switch $Msg
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case $Button
			_Capture()
		Case $Check
			If GUICtrlRead($Check) = $GUI_CHECKED Then
				_WinAPI_SetWindowDisplayAffinity($hForm, $WDA_MONITOR)
			Else
				_WinAPI_SetWindowDisplayAffinity($hForm, 0)
			EndIf
	EndSwitch
WEnd

Func _Capture()

	Local $hDC, $hSrcDC, $hSrcSv, $hDestDC, $hDestSv, $hObj, $hBitmap

	$hObj = _SendMessage($hPic, $STM_SETIMAGE, 0, 0)
	If $hObj Then
		_WinAPI_DeleteObject($hObj)
	EndIf
	$hDC = _WinAPI_GetDC($hPic)
	$hDestDC = _WinAPI_CreateCompatibleDC($hDC)
	$hBitmap = _WinAPI_CreateCompatibleBitmap($hDC, $Widht, $Height)
	$hDestSv = _WinAPI_SelectObject($hDestDC, $hBitmap)
	$hSrcDC = _WinAPI_CreateCompatibleDC($hDC)
	$hObj = _ScreenCapture_Capture('', 0, 0, -1, -1, 0)
	$hSrcSv = _WinAPI_SelectObject($hSrcDC, $hObj)
	_WinAPI_SetStretchBltMode($hDestDC, $HALFTONE)
	_WinAPI_StretchBlt($hDestDC, 0, 0, $Widht, $Height, $hSrcDC, 0, 0, @DesktopWidth, @DesktopHeight, $SRCCOPY)
	_WinAPI_ReleaseDC($hPic, $hDC)
	_WinAPI_SelectObject($hDestDC, $hDestSv)
	_WinAPI_DeleteDC($hDestDC)
	_WinAPI_SelectObject($hSrcDC, $hSrcSv)
	_WinAPI_DeleteObject($hObj)
	_WinAPI_DeleteDC($hSrcDC)
	_SendMessage($hPic, $STM_SETIMAGE, 0, $hBitmap)
	$hObj = _SendMessage($hPic, $STM_GETIMAGE)
	If $hObj <> $hBitmap Then
		_WinAPI_DeleteObject($hBitmap)
	EndIf
EndFunc   ;==>_Capture
