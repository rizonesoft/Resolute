#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172

Global $tRECT, $hXOR, $hAND, $hIcon, $hBrush, $hDC, $hMemDC, $hSv

; Create XOR bitmap
$hDC = _WinAPI_GetDC(0)
$hMemDC = _WinAPI_CreateCompatibleDC($hDC)
$hXOR = _WinAPI_CreateCompatibleBitmapEx($hDC, 32, 32, 0)
$hSv = _WinAPI_SelectObject($hMemDC, $hXOR)
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

; Create AND bitmap
$hDC = _WinAPI_GetDC(0)
$hMemDC = _WinAPI_CreateCompatibleDC($hDC)
$hAND = _WinAPI_CreateBitmap(32, 32, 1, 1)
$hSv = _WinAPI_SelectObject($hMemDC, $hAND)
_WinAPI_SelectObject($hMemDC, _WinAPI_GetStockObject($DC_BRUSH))
_WinAPI_SelectObject($hMemDC, _WinAPI_GetStockObject($NULL_PEN))
_WinAPI_SetDCBrushColor($hMemDC, 0xFFFFFF)
$tRECT = _WinAPI_CreateRectEx(0, 0, 33, 33)
_WinAPI_Rectangle($hMemDC, $tRECT)
_WinAPI_SetDCBrushColor($hMemDC, 0)
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
$hIcon = _WinAPI_CreateIconIndirect($hXOR, $hAND)

; Free bitmaps
_WinAPI_DeleteObject($hXOR)
_WinAPI_DeleteObject($hAND)

; Create GUI
GUICreate('MyGUI', 128, 128)
GUICtrlCreateIcon('', 0, 48, 48, 32, 32)
GUICtrlSendMsg(-1, $STM_SETIMAGE, 1, $hIcon)
GUISetState()

Do
Until GUIGetMsg() = -3
