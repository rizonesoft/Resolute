#Include <APIConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <SliderConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Msg, $Pic, $Slider, $tSIZE, $W, $H, $hBitmap

; Load image
$hBitmap = _WinAPI_LoadImage(0, @ScriptDir & '\Extras\Logo.bmp', $IMAGE_BITMAP, 0, 0, $LR_LOADFROMFILE)
$tSIZE = _WinAPI_GetBitmapDimension($hBitmap)
$W = DllStructGetData($tSIZE, 'X')
$H = DllStructGetData($tSIZE, 'Y')

; Create GUI
$hForm = GUICreate('MyGUI', $W, $H + 26)
$Pic = GUICtrlCreatePic('', 0, 0, $W, $H)
GUICtrlCreateGraphic(0, $H, $W, 1)
GUICtrlSetBkColor(-1, 0xDFDFDF)
$Slider = GUICtrlCreateSlider(0, $H + 1, $W, 25, BitOR($TBS_BOTH, $TBS_NOTICKS))
GUICtrlSetLimit(-1, 255, 0)
GUICtrlSetData(-1, 255)

; Set bitmap to control with alpha
_SetBitmapAlpha($Pic, $hBitmap, 255)

; Register WM_HSCROLL message for live scrolling and show GUI
GUIRegisterMsg($WM_HSCROLL, 'WM_HSCROLL')
GUISetState()

Do
Until GUIGetMsg() = $GUI_EVENT_CLOSE

Func _SetBitmapAlpha($hWnd, $hBitmap, $iAlpha)

	Local $tRECT, $tSIZE, $W[2], $H[2], $hDC, $hDestDC, $hDestSv, $hSrcDC, $hSrcSv, $hBmp, $hObj

	If Not IsHWnd($hWnd) Then
		$hWnd = GUICtrlGetHandle($hWnd)
		If Not $hWnd Then
			Return 0
		EndIf
	EndIf

	$tRECT = _WinAPI_GetClientRect($hWnd)
	$W[0] = DllStructGetData($tRECT, 3) - DllStructGetData($tRECT, 1)
	$H[0] = DllStructGetData($tRECT, 4) - DllStructGetData($tRECT, 2)
	$tSIZE = _WinAPI_GetBitmapDimension($hBitmap)
	$W[1] = DllStructGetData($tSIZE, 1)
	$H[1] = DllStructGetData($tSIZE, 2)
	$hDC = _WinAPI_GetDC($hWnd)
	$hDestDC = _WinAPI_CreateCompatibleDC($hDC)
	$hBmp = _WinAPI_CreateCompatibleBitmapEx($hDC, $W[0], $H[0], 0xFFFFFF)
	$hDestSv = _WinAPI_SelectObject($hDestDC, $hBmp)
	$hSrcDC = _WinAPI_CreateCompatibleDC($hDC)
	$hSrcSv = _WinAPI_SelectObject($hSrcDC, $hBitmap)
	_WinAPI_AlphaBlend($hDestDC, 0, 0, $W[0], $H[0], $hSrcDC, 0, 0, $W[1], $H[1], $iAlpha, 0)
	_WinAPI_SelectObject($hDestDC, $hDestSv)
	_WinAPI_DeleteDC($hDestDC)
	_WinAPI_SelectObject($hSrcDC, $hSrcSv)
	_WinAPI_DeleteDC($hSrcDC)
	_WinAPI_ReleaseDC($hWnd, $hDC)
	$hObj = _SendMessage($hWnd, $STM_SETIMAGE, $IMAGE_BITMAP, $hBmp)
	If $hObj Then
		_WinAPI_DeleteObject($hObj)
	EndIf
	$hObj = _SendMessage($hWnd, $STM_GETIMAGE)
	If $hObj <> $hBmp Then
		_WinAPI_DeleteObject($hBmp)
	EndIf
	Return 1
EndFunc   ;==>_SetBitmapAlpha

Func WM_HSCROLL($hWnd, $iMsg, $wParam, $lParam)
	Switch _WinAPI_GetDlgCtrlID($lParam)
		Case $Slider
			_SetBitmapAlpha($Pic, $hBitmap, GUICtrlRead($Slider))
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_HSCROLL
