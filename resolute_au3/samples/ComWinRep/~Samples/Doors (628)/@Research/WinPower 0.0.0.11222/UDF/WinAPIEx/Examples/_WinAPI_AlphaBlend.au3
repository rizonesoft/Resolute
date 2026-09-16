#Include <Constants.au3>
#Include <SliderConstants.au3>
#Include <WinAPIEx.au3>
#Include <WindowsConstants.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Msg, $Slider, $Pic, $tSIZE, $Width, $Height, $hBitmap

; Load image
$hBitmap = _WinAPI_LoadImage(0, @ScriptDir & '\Extras\Logo.bmp', $IMAGE_BITMAP, 0, 0, $LR_LOADFROMFILE)
$tSIZE = _WinAPI_GetBitmapDimension($hBitmap)
$Width = DllStructGetData($tSIZE, 'X')
$Height = DllStructGetData($tSIZE, 'Y')

; Create GUI
$hForm = GUICreate('MyGUI', $Width, $Height + 61)
$Slider = GUICtrlCreateSlider(10, $Height + 18, $Width - 20, 26, BitOR($TBS_BOTH, $TBS_NOTICKS))
GUICtrlSetLimit(-1, 255, 0)
GUICtrlSetData(-1, 255)
$Pic = GUICtrlCreatePic('', 0, 0, $Width, $Height)

; Set bitmap to control with alpha
_SetBitmapAlpha($Pic, $hBitmap, 255)

GUISetState()

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case -3
			ExitLoop
		Case $Slider
			_SetBitmapAlpha($Pic, $hBitmap, GUICtrlRead($Slider))
	EndSwitch
WEnd

Func _SetBitmapAlpha($hWnd, $hBitmap, $iAlpha)

	Local $tRECT, $tSIZE, $Width, $Height, $Result = 0, $hObj, $hBmp, $hDC, $hDestDC, $hDestSv, $hSrcDC, $hSrcSv

	If Not IsHWnd($hWnd) Then
		$hWnd = GUICtrlGetHandle($hWnd)
		If Not $hWnd Then
			Return 0
		EndIf
	EndIf

	$tRECT = _WinAPI_GetClientRect($hWnd)
	$Width = DllStructGetData($tRECT, 3) - DllStructGetData($tRECT, 1)
	$Height = DllStructGetData($tRECT, 4) - DllStructGetData($tRECT, 2)
	$tSIZE = _WinAPI_GetBitmapDimension($hBitmap)
	$hDC = _WinAPI_GetDC($hWnd)
	$hDestDC = _WinAPI_CreateCompatibleDC($hDC)
	$hBmp = _WinAPI_CreateCompatibleBitmapEx($hDC, $Width, $Height, _WinAPI_SwitchColor(_WinAPI_GetSysColor($COLOR_3DFACE)))
	$hDestSv = _WinAPI_SelectObject($hDestDC, $hBmp)
	$hSrcDC = _WinAPI_CreateCompatibleDC($hDC)
	$hSrcSv = _WinAPI_SelectObject($hSrcDC, $hBitmap)
	$Result = _WinAPI_AlphaBlend($hDestDC, 0, 0, $Width, $Height, $hSrcDC, 0, 0, DllStructGetData($tSIZE, 'X'), DllStructGetData($tSIZE, 'Y'), $iAlpha, 0)

	_WinAPI_ReleaseDC($hWnd, $hDC)
	_WinAPI_SelectObject($hDestDC, $hDestSv)
	_WinAPI_SelectObject($hSrcDC, $hSrcSv)
	_WinAPI_DeleteDC($hDestDC)
	_WinAPI_DeleteDC($hSrcDC)

	If Not $Result Then
		_WinAPI_DeleteObject($hBmp)
	Else
		_WinAPI_DeleteObject(_SendMessage($hWnd, $STM_SETIMAGE, 0, 0))
		_SendMessage($hWnd, $STM_SETIMAGE, 0, $hBmp)
		$hObj = _SendMessage($hWnd, $STM_GETIMAGE)
		If $hObj <> $hBmp Then
			_WinAPI_DeleteObject($hBmp)
		EndIf
	EndIf
	Return $Result
EndFunc   ;==>_SetBitmapAlpha
