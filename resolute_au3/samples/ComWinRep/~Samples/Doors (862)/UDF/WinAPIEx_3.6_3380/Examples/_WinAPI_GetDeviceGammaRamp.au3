#Include <APIConstants.au3>
#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $hPic, $hObj, $hBitmap, $hPen, $hDC, $hMemDC, $hSv1, $hSv2, $Ramp, $Rgb = 0xFF0000

; Create GUI
$hForm = GUICreate('Lookup Table', 256, 256)
GUICtrlCreatePic('', 0, 0, 256, 256)
$hPic = GUICtrlGetHandle(-1)

; Retrieve current gamma ramp and create graph of lookup table (LUT)
$hDC = _WinAPI_GetDC(0)
$hMemDC = _WinAPI_CreateCompatibleDC($hDC)
$hBitmap = _WinAPI_CreateCompatibleBitmapEx($hDC, 256, 256, 0)
$hSv1 = _WinAPI_SelectObject($hMemDC, $hBitmap)
$hPen = _WinAPI_GetStockObject($DC_PEN)
$hSv2 = _WinAPI_SelectObject($hMemDC, $hPen)
_WinAPI_SetROP2($hMemDC, $R2_XORPEN)
_WinAPI_GetDeviceGammaRamp($hDC, $Ramp)
_WinAPI_ReleaseDC(0, $hDC)
If IsArray($Ramp) Then
	For $i = 0 To 2
		_WinAPI_SetDCPenColor($hMemDC, BitShift($Rgb, 8 * $i))
		For $j = 0 To 255
			If $j Then
				_WinAPI_LineTo($hMemDC, $j + 1, Round(255 * (1 - $Ramp[$j][$i] / 65280)) - 1)
			Else
				_WinAPI_MoveTo($hMemDC, 0, Round(255 * (1 - $Ramp[$j][$i] / 65280)))
			EndIf
		Next
	Next
EndIf
_WinAPI_SetDCPenColor($hMemDC, 0x404040)
_WinAPI_SetROP2($hMemDC, $R2_MERGEPEN)
For $i = 64 To 192 Step 64
	_WinAPI_DrawLine($hMemDC, $i - 1, 0, $i - 1, 256)
	_WinAPI_DrawLine($hMemDC, 0, $i, 256, $i)
Next
_WinAPI_SelectObject($hMemDC, $hSv1)
_WinAPI_SelectObject($hMemDC, $hSv2)
_WinAPI_DeleteObject($hPen)
_WinAPI_DeleteDC($hMemDC)

; Set bitmap to control
_SendMessage($hPic, $STM_SETIMAGE, 0, $hBitmap)
$hObj = _SendMessage($hPic, $STM_GETIMAGE)
If $hObj <> $hBitmap Then
	_WinAPI_DeleteObject($hBitmap)
EndIf

GUISetState()

If IsArray($Ramp) Then
	_ArrayDisplay($Ramp, '_WinAPI_GetDeviceGammaRamp')
Else
	MsgBox(16, 'Error', 'Your video board do not support loadable gamma ramps.', 0, $hForm)
EndIf

Do
Until GUIGetMsg() = -3
