#Include <FontConstants.au3>
#Include <WinAPIEx.au3>
#Include <WindowsConstants.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic, $hPic, $tRECT, $aPoint, $hObj, $hBrush, $hFont, $hPen, $hRgn, $hPattern, $hBitmap, $hDev, $hDC, $hSv

Dim $aPoint[6][2] = [[0, 129], [55, 75], [75, 0], [95, 75], [150, 129], [75, 108]]

; Create GUI
$hForm = GUICreate('MyGUI', 400, 400)
$Pic = GUICtrlCreatePic('', 0, 0, 400, 400)
$hPic = GUICtrlGetHandle($Pic)

; Create bitmap
$hDev = _WinAPI_GetDC($hPic)
$hDC = _WinAPI_CreateCompatibleDC($hDev)
$hBitmap = _WinAPI_CreateCompatibleBitmapEx($hDev, 400, 400, _WinAPI_SwitchColor(_WinAPI_GetSysColor($COLOR_3DFACE)))
$hSv = _WinAPI_SelectObject($hDC, $hBitmap)

; Draw objects
_WinAPI_SelectObject($hDC, _WinAPI_GetStockObject($DC_BRUSH))
_WinAPI_SelectObject($hDC, _WinAPI_GetStockObject($DC_PEN))
_WinAPI_SetDCBrushColor($hDC, 0x990404)
_WinAPI_SetDCPenColor($hDC, 0x990404)
$tRECT = _WinAPI_CreateRect(0, 0, 100, 100)
_WinAPI_OffsetRect($tRECT, 30, 30)
_WinAPI_Rectangle($hDC, $tRECT)
_WinAPI_OffsetRect($tRECT, 20, 20)
_WinAPI_InvertRect($hDC, $tRECT)
_WinAPI_OffsetRect($tRECT, 20, 20)
_WinAPI_InvertRect($hDC, $tRECT)
_WinAPI_SetDCPenColor($hDC, 0x00A820)
_WinAPI_SetBkColor($hDC, _WinAPI_SwitchColor(_WinAPI_GetSysColor($COLOR_3DFACE)))
$hBrush = _WinAPI_CreateBrushIndirect($BS_HATCHED, 0x00A820, $HS_DIAGCROSS)
$hObj = _WinAPI_SelectObject($hDC, $hBrush)
$tRECT = _WinAPI_CreateRect(0, 0, 140, 140)
_WinAPI_OffsetRect($tRECT, 220, 70)
_WinAPI_Ellipse($hDC, $tRECT)
_WinAPI_SelectObject($hDC, $hObj)
_WinAPI_FreeObject($hBrush)
_WinAPI_SetTextColor($hDC, 0xCD0091)
_WinAPI_SetBkMode($hDC, $TRANSPARENT)
$hFont = _WinAPI_CreateFont(38, 0, 0, 0, $FW_NORMAL , 0, 0, 0, $DEFAULT_CHARSET, $OUT_DEFAULT_PRECIS, $CLIP_DEFAULT_PRECIS, $ANTIALIASED_QUALITY, BitOR($DEFAULT_PITCH, $FF_DONTCARE), 'Arial Black')
$hObj = _WinAPI_SelectObject($hDC, $hFont)
_WinAPI_TextOut($hDC, 30, 185, 'Simple Text')
_WinAPI_SelectObject($hDC, $hObj)
_WinAPI_FreeObject($hFont)
$hRgn = _WinAPI_CreatePolygonRgn($aPoint)
_WinAPI_SetDCBrushColor($hDC, 0x0060C4)
_WinAPI_OffsetRgn($hRgn, 25, 240)
_WinAPI_PaintRgn($hDC, $hRgn)
_WinAPI_FreeObject($hRgn)
_WinAPI_SetDCPenColor($hDC, 0xFFFFFF)
$hPattern = _WinAPI_LoadBitmap(_WinAPI_GetModuleHandle(@SystemDir & '\shell32.dll'), 138)
$hBrush = _WinAPI_CreateBrushIndirect($BS_PATTERN, 0, $hPattern)
$hObj = _WinAPI_SelectObject($hDC, $hBrush)
$tRECT = _WinAPI_CreateRect(0, 0, 140, 90)
_WinAPI_OffsetRect($tRECT, 220, 250)
_WinAPI_RoundRect($hDC, $tRECT, 20, 20)
_WinAPI_SelectObject($hDC, $hObj)
_WinAPI_FreeObject($hPattern)
_WinAPI_FreeObject($hBrush)

_WinAPI_ReleaseDC($hPic, $hDev)
_WinAPI_SelectObject($hDC, $hSv)
_WinAPI_DeleteDC($hDC)

; Set bitmap to control
_SendMessage($hPic, $STM_SETIMAGE, 0, $hBitmap)
$hObj = _SendMessage($hPic, $STM_GETIMAGE)
If $hObj <> $hBitmap Then
	_WinAPI_FreeObject($hBitmap)
EndIf

GUISetState()

Do
Until GUIGetMsg() = -3
