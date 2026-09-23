#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic, $hPic, $tRECT, $hObj, $hBrush, $hOldBrush, $hPen, $hOldPen, $hFont, $hRgn, $hPattern, $hBitmap, $hSource, $hDev, $hDC, $hSv
Global $aPoint1[19][2] = [[50, 20], [70, 0], [70, 0], [90, 20], [100, 30], [110, 40], [120, 50], [130, 60], [130, 70], [120, 70], [110, 70], [30, 70], [20, 70], [10, 70], [10, 60], [20, 50], [30, 40], [40, 30], [50, 20]]
Global $aPoint2[6][2] = [[0, 129], [55, 75], [75, 0], [95, 75], [150, 129], [75, 108]]

; Create GUI
$hForm = GUICreate('MyGUI', 400, 400)
$Pic = GUICtrlCreatePic('', 0, 0, 400, 400)
$hPic = GUICtrlGetHandle($Pic)

; Create bitmap
$hDev = _WinAPI_GetDC($hPic)
$hDC = _WinAPI_CreateCompatibleDC($hDev)
$hSource = _WinAPI_CreateCompatibleBitmapEx($hDev, 400, 400, _WinAPI_SwitchColor(_WinAPI_GetSysColor($COLOR_3DFACE)))
$hSv = _WinAPI_SelectObject($hDC, $hSource)

; Draw objects
$hOldBrush = _WinAPI_SelectObject($hDC, _WinAPI_GetStockObject($DC_BRUSH))
$hOldPen = _WinAPI_SelectObject($hDC, _WinAPI_GetStockObject($DC_PEN))
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
_WinAPI_OffsetRect($tRECT, 220, 118)
_WinAPI_Ellipse($hDC, $tRECT)
_WinAPI_SelectObject($hDC, $hObj)
_WinAPI_DeleteObject($hBrush)
_WinAPI_SetTextColor($hDC, 0xCD0091)
_WinAPI_SetBkMode($hDC, $TRANSPARENT)
$hFont = _WinAPI_CreateFont(38, 0, 0, 0, $FW_NORMAL , 0, 0, 0, $DEFAULT_CHARSET, $OUT_DEFAULT_PRECIS, $CLIP_DEFAULT_PRECIS, $ANTIALIASED_QUALITY, $DEFAULT_PITCH, 'Arial Black')
$hObj = _WinAPI_SelectObject($hDC, $hFont)
_WinAPI_TextOut($hDC, 30, 185, 'Simple Text')
_WinAPI_SelectObject($hDC, $hObj)
_WinAPI_DeleteObject($hFont)
$hRgn = _WinAPI_CreatePolygonRgn($aPoint2)
_WinAPI_SetDCBrushColor($hDC, 0x0060C4)
_WinAPI_OffsetRgn($hRgn, 25, 240)
_WinAPI_PaintRgn($hDC, $hRgn)
_WinAPI_DeleteObject($hRgn)
_WinAPI_SetDCPenColor($hDC, 0xFF8000)
_WinAPI_OffsetPoints($aPoint1, 219, 25)
_WinAPI_PolyBezier($hDC, $aPoint1)
$hBrush = _WinAPI_CreateBrushIndirect($BS_SOLID, 0xFF8000)
$hObj = _WinAPI_SelectObject($hDC, $hBrush)
_WinAPI_ExtFloodFill($hDC, 70 + 219, 40 + 25, 0xFF8000, 0)
_WinAPI_SelectObject($hDC, $hObj)
_WinAPI_SelectObject($hDC, $hObj)
_WinAPI_DeleteObject($hBrush)
_WinAPI_SetDCPenColor($hDC, 0xFFFFFF)
$hPattern = _WinAPI_LoadImage(0, @ScriptDir & '\Extras\Pattern.bmp', $IMAGE_BITMAP, 0, 0, $LR_LOADFROMFILE)
;$hPattern = _WinAPI_LoadBitmap(_WinAPI_GetModuleHandle(@SystemDir & '\shell32.dll'), 138)
$hBrush = _WinAPI_CreateBrushIndirect($BS_PATTERN, 0, $hPattern)
$hObj = _WinAPI_SelectObject($hDC, $hBrush)
$tRECT = _WinAPI_CreateRect(0, 0, 140, 90)
_WinAPI_OffsetRect($tRECT, 220, 279)
_WinAPI_RoundRect($hDC, $tRECT, 20, 20)
_WinAPI_SelectObject($hDC, $hObj)
_WinAPI_DeleteObject($hPattern)
_WinAPI_DeleteObject($hBrush)

; Merge bitmap
$hBitmap = _WinAPI_CreateCompatibleBitmap($hDev, 400, 400)
$hBrush = _WinAPI_SelectObject($hDC, $hOldBrush)
_WinAPI_DeleteObject($hBrush)
$hPen = _WinAPI_SelectObject($hDC, $hOldPen)
_WinAPI_DeleteObject($hPen)
_WinAPI_SelectObject($hDC, $hBitmap)
_WinAPI_DrawBitmap($hDC, 0, 0, $hSource, $MERGECOPY)
_WinAPI_ReleaseDC($hPic, $hDev)
_WinAPI_SelectObject($hDC, $hSv)
_WinAPI_DeleteObject($hSource)
_WinAPI_DeleteDC($hDC)

; Set bitmap to control
_SendMessage($hPic, $STM_SETIMAGE, 0, $hBitmap)
$hObj = _SendMessage($hPic, $STM_GETIMAGE)
If $hObj <> $hBitmap Then
	_WinAPI_DeleteObject($hBitmap)
EndIf

GUISetState()

Do
Until GUIGetMsg() = -3
