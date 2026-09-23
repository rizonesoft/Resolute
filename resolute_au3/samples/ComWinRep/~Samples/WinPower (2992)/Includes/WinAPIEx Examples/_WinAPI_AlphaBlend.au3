#Include <GUIConstantsEx.au3>
#Include <GUISlider.au3>
#Include <SliderConstants.au3>
#Include <WinAPIEx.au3>
#Include <WindowsConstants.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Msg, $Slider, $Pic, $tSIZE, $hBitmap

$hBitmap = _WinAPI_LoadBitmap(_WinAPI_GetModuleHandle(@SystemDir & '\shell32.dll'), 131)
$tSIZE = _WinAPI_GetBitmapDimension($hBitmap)

$hForm = GUICreate('MyGUI', DllStructGetData($tSIZE, 'X'), DllStructGetData($tSIZE, 'Y') + 61)
$Slider = GUICtrlCreateSlider(10, DllStructGetData($tSIZE, 'Y') + 18, DllStructGetData($tSIZE, 'X') - 20, 26, $TBS_AUTOTICKS)
GUICtrlSetLimit(-1, 255, 0)
GUICtrlSetData(-1, 255)
_GUICtrlSlider_SetTicFreq(-1, 5)
$Pic = GUICtrlCreatePic('', 0, 0, DllStructGetData($tSIZE, 'X'), DllStructGetData($tSIZE, 'Y'))

_SetBitmapAlpha($Pic, $hBitmap, 255)

GUISetState()

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case $Slider
			_SetBitmapAlpha($Pic, $hBitmap, GUICtrlRead($Slider))
	EndSwitch
WEnd

Func _SetBitmapAlpha($hWnd, $hBitmap, $iAlpha)

	Local $tRECT, $tSIZE, $tObj, $Width, $Height, $Result = 0, $hObj, $hBmp, $hPrev, $hDC, $hDestDC, $hDestSv, $hSrcDC, $hSrcSv

	If Not IsHWnd($hWnd) Then
		$hWnd = GUICtrlGetHandle($hWnd)
		If $hWnd = 0 Then
			Return 0
		EndIf
	EndIf
	
	$tRECT = _WinAPI_GetClientRect($hWnd)
	$Width = DllStructGetData($tRECT, 3) - DllStructGetData($tRECT, 1)
	$Height = DllStructGetData($tRECT, 4) - DllStructGetData($tRECT, 2)
	$tObj = DllStructCreate($tagBITMAP)
	_WinAPI_GetObject($hBitmap, DllStructGetSize($tObj), DllStructGetPtr($tObj))
	$hDC = _WinAPI_GetDC($hWnd)
	$hDestDC = _WinAPI_CreateCompatibleDC($hDC)
	$hBmp = _WinAPI_CreateCompatibleBitmapEx($hDC, $Width, $Height, _WinAPI_SwitchColor(_WinAPI_GetSysColor($COLOR_3DFACE)))
	$hDestSv = _WinAPI_SelectObject($hDestDC, $hBmp)
	$hSrcDC = _WinAPI_CreateCompatibleDC($hDC)
	$hSrcSv = _WinAPI_SelectObject($hSrcDC, $hBitmap)
	$Result = _WinAPI_AlphaBlend($hDestDC, 0, 0, $Width, $Height, $hSrcDC, 0, 0, DllStructGetData($tObj, 'Width'), DllStructGetData($tObj, 'Height'), $iAlpha, 0)
	
	_WinAPI_ReleaseDC($hWnd, $hDC)
	_WinAPI_SelectObject($hDestDC, $hDestSv)
	_WinAPI_SelectObject($hSrcDC, $hSrcSv)
	_WinAPI_DeleteDC($hDestDC)
	_WinAPI_DeleteDC($hSrcDC)
	
	If Not $Result Then
		_WinAPI_FreeObject($hBmp)
	Else
		_WinAPI_FreeObject(_SendMessage($hWnd, $STM_SETIMAGE, 0, 0))
		_SendMessage($hWnd, $STM_SETIMAGE, 0, $hBmp)
		$hObj = _SendMessage($hWnd, $STM_GETIMAGE)
		If $hObj <> $hBmp Then
			_WinAPI_FreeObject($hBmp)
		EndIf
	EndIf
	Return $Result
EndFunc   ;==>_SetBitmapAlpha
