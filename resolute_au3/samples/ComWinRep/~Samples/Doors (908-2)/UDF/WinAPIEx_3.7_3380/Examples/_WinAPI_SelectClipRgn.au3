#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic, $hPic, $hObj, $hRgn, $hBitmap, $hDC, $hMemDC, $hMemSv
Global $aVertex[3][3] = [[140, -50, 0xFFFF00], [-50, 244, 0x00F0FF], [331, 244, 0xFF00FF]]

; Create GUI
$hForm = GUICreate('MyGUI', 281, 281)
$Pic = GUICtrlCreatePic('', 0, 0, 281, 281)
$hPic = GUICtrlGetHandle($Pic)

; Create bitmap
$hDC = _WinAPI_GetDC($hPic)
$hMemDC = _WinAPI_CreateCompatibleDC($hDC)
$hBitmap = _WinAPI_CreateCompatibleBitmapEx($hDC, 281, 281, _WinAPI_SwitchColor(_WinAPI_GetSysColor($COLOR_3DFACE)))
$hMemSv = _WinAPI_SelectObject($hMemDC, $hBitmap)
$hRgn = _WinAPI_CreateEllipticRgn(_WinAPI_CreateRectEx(40, 40, 201, 201))
_WinAPI_SelectClipRgn($hMemDC, $hRgn)
_WinAPI_GradientFill($hMemDC, $aVertex)
_WinAPI_DeleteObject($hRgn)
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
