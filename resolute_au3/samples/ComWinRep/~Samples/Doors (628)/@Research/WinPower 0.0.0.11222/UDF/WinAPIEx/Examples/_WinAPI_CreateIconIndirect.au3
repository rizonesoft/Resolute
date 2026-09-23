#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172

Global $tRECT, $hBitmap, $hMask, $hIcon, $hBrush, $hDC, $hMemDC, $hSv

; Create color bitmap
$hDC = _WinAPI_GetDC(0)
$hMemDC = _WinAPI_CreateCompatibleDC($hDC)
$hBitmap = _WinAPI_CreateCompatibleBitmapEx($hDC, 32, 32, 0)
$hSv = _WinAPI_SelectObject($hMemDC, $hBitmap)
_WinAPI_SelectObject($hMemDC, _WinAPI_GetStockObject($DC_BRUSH))
_WinAPI_SelectObject($hMemDC, _WinAPI_GetStockObject($NULL_PEN))
$tRECT = _WinAPI_CreateRectEx(0, 1, 22, 22)
_WinAPI_SetDCBrushColor($hMemDC, 0x0000FF)
_WinAPI_Ellipse($hMemDC, $tRECT)
_WinAPI_OffsetRect($tRECT, 11, 0)
_WinAPI_SetDCBrushColor($hMemDC, 0x00FF00)
_WinAPI_Ellipse($hMemDC, $tRECT)
_WinAPI_OffsetRect($tRECT, -6, 9)
_WinAPI_SetDCBrushColor($hMemDC, 0xFF0000)
_WinAPI_Ellipse($hMemDC, $tRECT)
_WinAPI_ReleaseDC(0, $hDC)
_WinAPI_SelectObject($hMemDC, $hSv)
_WinAPI_DeleteDC($hMemDC)

; Create bitmask bitmap
$hDC = _WinAPI_GetDC(0)
$hMemDC = _WinAPI_CreateCompatibleDC($hDC)
$hMask = _WinAPI_CreateCompatibleBitmapEx($hDC, 32, 32, 0xFFFFFF)
$hSv = _WinAPI_SelectObject($hMemDC, $hMask)
_WinAPI_SelectObject($hMemDC, _WinAPI_GetStockObject($BLACK_BRUSH))
_WinAPI_SelectObject($hMemDC, _WinAPI_GetStockObject($NULL_PEN))
$tRECT = _WinAPI_CreateRectEx(0, 1, 22, 22)
_WinAPI_Ellipse($hMemDC, $tRECT)
_WinAPI_OffsetRect($tRECT, 11, 0)
_WinAPI_Ellipse($hMemDC, $tRECT)
_WinAPI_OffsetRect($tRECT, -6, 9)
_WinAPI_Ellipse($hMemDC, $tRECT)
_WinAPI_ReleaseDC(0, $hDC)
_WinAPI_SelectObject($hMemDC, $hSv)
_WinAPI_DeleteDC($hMemDC)

; Create icon
$hIcon = _WinAPI_CreateIconIndirect($hBitmap, $hMask)

; Create GUI
GUICreate('MyGUI', 128, 128)
GUICtrlCreateIcon('', 0, 48, 48, 32, 32)
GUICtrlSendMsg(-1, $STM_SETIMAGE, 1, $hIcon)
GUISetState()

Do
Until GUIGetMsg() = -3
