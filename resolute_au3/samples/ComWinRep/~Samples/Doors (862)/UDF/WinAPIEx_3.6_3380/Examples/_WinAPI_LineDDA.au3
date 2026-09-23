#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic, $hPic, $hObj, $hBitmap, $hPen, $hDC, $hMemDC, $hMemSv, $Count = 0, $Color = True
Global $hLineProc = DllCallbackRegister('_LineProc', 'none', 'int;int;lparam')
Global $pLineProc = DllCallBackGetPtr($hLineProc)

; Create GUI
$hForm = GUICreate('MyGUI', 280, 280)
$Pic = GUICtrlCreatePic('', 0, 0, 281, 281)
$hPic = GUICtrlGetHandle($Pic)

; Create bitmap
$hDC = _WinAPI_GetDC($hPic)
$hMemDC = _WinAPI_CreateCompatibleDC($hDC)
$hBitmap = _WinAPI_CreateCompatibleBitmapEx($hDC, 280, 280, _WinAPI_SwitchColor(_WinAPI_GetSysColor($COLOR_3DFACE)))
$hMemSv = _WinAPI_SelectObject($hMemDC, $hBitmap)
_WinAPI_LineDDA(40, 40, 240, 40, $pLineProc, $hMemDC)
_WinAPI_LineDDA(240, 40, 240, 240, $pLineProc, $hMemDC)
_WinAPI_LineDDA(240, 240, 40, 240, $pLineProc, $hMemDC)
_WinAPI_LineDDA(40, 240, 40, 40, $pLineProc, $hMemDC)
_WinAPI_ReleaseDC($hPic, $hDC)
_WinAPI_SelectObject($hMemDC, $hMemSv)
_WinAPI_DeleteDC($hMemDC)

; Set bitmap to control
_SendMessage($hPic, $STM_SETIMAGE, 0, $hBitmap)
$hObj = _SendMessage($hPic, $STM_GETIMAGE)
If $hObj <> $hBitmap Then
	_WinAPI_DeleteObject($hBitmap)
EndIf

GUISetState()

Do
Until GUIGetMsg() = -3

DllCallbackFree($hLineProc)

Func _LineProc($iX, $iY, $hDC)
	If Not Mod($Count, 10) Then
		$Color = Not $Color
	EndIf
	If $Color Then
		_WinAPI_SetPixel($hDC, $iX, $iY, 0xFF0000)
	Else
		_WinAPI_SetPixel($hDC, $iX, $iY, 0xFFFFFF)
	EndIf
	$Count += 1
EndFunc   ;==>_LineProc
