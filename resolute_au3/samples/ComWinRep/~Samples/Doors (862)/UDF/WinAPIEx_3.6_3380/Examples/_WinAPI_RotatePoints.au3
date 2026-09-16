#Include <APIConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <SliderConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Msg, $Pic, $Slider, $tSIZE, $W, $H, $hBitmap

; Load image
$hBitmap = _WinAPI_LoadImage(0, @ScriptDir & '\Extras\Compass.bmp', $IMAGE_BITMAP, 0, 0, $LR_LOADFROMFILE)
$tSIZE = _WinAPI_GetBitmapDimension($hBitmap)
$W = DllStructGetData($tSIZE, 'X')
$H = DllStructGetData($tSIZE, 'Y')

; Create GUI
$hForm = GUICreate('MyGUI', $W, $H + 26)
$Pic = GUICtrlCreatePic('', 0, 0, $W, $H)
GUICtrlCreateGraphic(0, $H, $W, 1)
GUICtrlSetBkColor(-1, 0xDFDFDF)
$Slider = GUICtrlCreateSlider(0, $H + 1, $W, 25, BitOR($TBS_BOTH, $TBS_NOTICKS))
GUICtrlSetLimit(-1, 360, 0)
GUICtrlSetData(-1, 0)

; Set bitmap to control with rotate
_SetBitmapRotate($Pic, $hBitmap, 0)

; Register WM_HSCROLL message for live scrolling and show GUI
GUIRegisterMsg($WM_HSCROLL, 'WM_HSCROLL')
GUISetState()

Do
Until GUIGetMsg() = $GUI_EVENT_CLOSE

Func _SetBitmapRotate($hWnd, $hBitmap, $iAngle)

	Local $tRECT, $tSIZE, $W[2], $H[2], $hDC, $hDestDC, $hDestSv, $hSrcDC, $hSrcSv, $hBrush, $hPen, $hMask, $hBmp, $hObj
	Local $aPoint[3][2]

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
	$aPoint[0][0] = ($W[0] - $W[1]) / 2
	$aPoint[0][1] = ($H[0] - $H[1]) / 2
	$aPoint[1][0] = $aPoint[0][0] + $W[1]
	$aPoint[1][1] = $aPoint[0][1]
	$aPoint[2][0] = $aPoint[0][0]
	$aPoint[2][1] = $aPoint[0][1] + $H[1]
	$hDC = _WinAPI_GetDC($hWnd)
	$hDestDC = _WinAPI_CreateCompatibleDC($hDC)
	$hMask = _WinAPI_CreateBitmap($W[0], $H[0], 1, 1)
	$hDestSv = _WinAPI_SelectObject($hDestDC, $hMask)
	$hBrush = _WinAPI_SelectObject($hDestDC, _WinAPI_GetStockObject($DC_BRUSH))
	$hPen = _WinAPI_SelectObject($hDestDC, _WinAPI_GetStockObject($DC_PEN))
	_WinAPI_SetDCBrushColor($hDestDC, 0xFFFFFF)
	_WinAPI_SetDCPenColor($hDestDC, 0xFFFFFF)
	_WinAPI_Ellipse($hDestDC, _WinAPI_CreateRectEx($aPoint[0][0] + 43, $aPoint[0][1] + 43, $aPoint[1][0] - 86, $aPoint[2][1] - 86))
	$hBmp = _WinAPI_CreateCompatibleBitmapEx($hDC, $W[0], $H[0], 0xFFFFFF)
	_WinAPI_SelectObject($hDestDC, $hBrush)
	_WinAPI_SelectObject($hDestDC, $hPen)
	_WinAPI_SelectObject($hDestDC, $hBmp)
	$hSrcDC = _WinAPI_CreateCompatibleDC($hDC)
	$hSrcSv = _WinAPI_SelectObject($hSrcDC, $hBitmap)
	_WinAPI_RotatePoints($aPoint, $W[0] / 2, $H[0] / 2, $iAngle)
	_WinAPI_PlgBlt($hDestDC, $aPoint, $hSrcDC, 0, 0, $W[1], $H[1])
	_WinAPI_RotatePoints($aPoint, $W[0] / 2, $H[0] / 2, -2 * $iAngle)
	_WinAPI_PlgBlt($hDestDC, $aPoint, $hSrcDC, 0, 0, $W[1], $H[1], $hMask)
	_WinAPI_SelectObject($hDestDC, $hDestSv)
	_WinAPI_DeleteDC($hDestDC)
	_WinAPI_SelectObject($hSrcDC, $hSrcSv)
	_WinAPI_DeleteDC($hSrcDC)
	_WinAPI_DeleteObject($hMask)
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
EndFunc   ;==>_SetBitmapRotate

Func WM_HSCROLL($hWnd, $iMsg, $wParam, $lParam)
	Switch _WinAPI_GetDlgCtrlID($lParam)
		Case $Slider
			_SetBitmapRotate($Pic, $hBitmap, GUICtrlRead($Slider))
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_HSCROLL
