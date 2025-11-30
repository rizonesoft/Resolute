#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic, $hPic, $hObj, $hBitmap, $hPen, $hSv, $hPattern, $hDC, $hMemDC, $hMemSv
Global $aStyle[6] = [1, 7, 1, 7, 1, 25]

; Create GUI
$hForm = GUICreate('MyGUI', 310, 300)
$Pic = GUICtrlCreatePic('', 0, 0, 310, 300)
$hPic = GUICtrlGetHandle($Pic)

; Create bitmap
$hDC = _WinAPI_GetDC($hPic)
$hMemDC = _WinAPI_CreateCompatibleDC($hDC)
$hBitmap = _WinAPI_CreateCompatibleBitmapEx($hDC, 310, 300, _WinAPI_SwitchColor(_WinAPI_GetSysColor($COLOR_3DFACE)))
$hMemSv = _WinAPI_SelectObject($hMemDC, $hBitmap)

; Draw a lines with a variety of type, style, end cap, and join attributes
$hPen = _WinAPI_ExtCreatePen(BitOR($PS_GEOMETRIC, $PS_SOLID, $PS_ENDCAP_ROUND), 5, $BS_SOLID, 0)
$hSv = _WinAPI_SelectObject($hMemDC, $hPen)
_WinAPI_DrawLine($hMemDC, 20, 30, 289, 30)
_WinAPI_SelectObject($hMemDC, $hSv)
_WinAPI_DeleteObject($hPen)

$hPen = _WinAPI_ExtCreatePen(BitOR($PS_GEOMETRIC, $PS_DASH, $PS_ENDCAP_ROUND), 5, $BS_SOLID, 0)
$hSv = _WinAPI_SelectObject($hMemDC, $hPen)
_WinAPI_DrawLine($hMemDC, 20, 70, 289, 70)
_WinAPI_SelectObject($hMemDC, $hSv)
_WinAPI_DeleteObject($hPen)

$hPen = _WinAPI_ExtCreatePen(BitOR($PS_GEOMETRIC, $PS_DOT, $PS_ENDCAP_ROUND), 5, $BS_SOLID, 0)
$hSv = _WinAPI_SelectObject($hMemDC, $hPen)
_WinAPI_DrawLine($hMemDC, 20, 110, 289, 110)
_WinAPI_SelectObject($hMemDC, $hSv)
_WinAPI_DeleteObject($hPen)

$hPen = _WinAPI_ExtCreatePen(BitOR($PS_GEOMETRIC, $PS_DASHDOT, $PS_ENDCAP_SQUARE), 5, $BS_SOLID, 0)
$hSv = _WinAPI_SelectObject($hMemDC, $hPen)
_WinAPI_DrawLine($hMemDC, 20, 150, 289, 150)
_WinAPI_SelectObject($hMemDC, $hSv)
_WinAPI_DeleteObject($hPen)

$hPen = _WinAPI_ExtCreatePen(BitOR($PS_GEOMETRIC, $PS_DASHDOTDOT, $PS_ENDCAP_SQUARE), 5, $BS_SOLID, 0)
$hSv = _WinAPI_SelectObject($hMemDC, $hPen)
_WinAPI_DrawLine($hMemDC, 20, 190, 289, 190)
_WinAPI_SelectObject($hMemDC, $hSv)
_WinAPI_DeleteObject($hPen)

$hPen = _WinAPI_ExtCreatePen(BitOR($PS_GEOMETRIC, $PS_USERSTYLE, $PS_ENDCAP_ROUND), 5, $BS_SOLID, 0, 0, $aStyle)
$hSv = _WinAPI_SelectObject($hMemDC, $hPen)
_WinAPI_DrawLine($hMemDC, 20, 230, 289, 230)
_WinAPI_SelectObject($hMemDC, $hSv)
_WinAPI_DeleteObject($hPen)

$hPattern = _WinAPI_LoadImage(0, @ScriptDir & '\Extras\Pen.bmp', $IMAGE_BITMAP, 0, 0, $LR_LOADFROMFILE)
$hPen = _WinAPI_ExtCreatePen(BitOR($PS_GEOMETRIC, $PS_SOLID, $PS_ENDCAP_ROUND), 5, $BS_PATTERN, 0, $hPattern, $aStyle)
$hSv = _WinAPI_SelectObject($hMemDC, $hPen)
_WinAPI_DrawLine($hMemDC, 20, 270, 289, 270)
_WinAPI_SelectObject($hMemDC, $hSv)
_WinAPI_DeleteObject($hPattern)
_WinAPI_DeleteObject($hPen)

; Release objects
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
