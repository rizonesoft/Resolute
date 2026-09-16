#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic, $hPic, $tRECT, $Width, $Height, $hObj, $hFont, $hBitmap, $hSource, $hDC, $hDestDC, $hDestSv, $hSrcDC, $hSrcSv

; Create GUI
$hForm = GUICreate('MyGUI', 400, 100)
$Pic = GUICtrlCreatePic('', 20, 20, 360, 60)
$hPic = GUICtrlGetHandle($Pic)

; Create bitmap
$tRECT = _WinAPI_GetClientRect($hPic)
$Width = DllStructGetData($tRECT, 3) - DllStructGetData($tRECT, 1)
$Height = DllStructGetData($tRECT, 4) - DllStructGetData($tRECT, 2)
$hDC = _WinAPI_GetDC($hPic)
$hDestDC = _WinAPI_CreateCompatibleDC($hDC)
$hBitmap = _WinAPI_CreateCompatibleBitmap($hDC, $Width, $Height)
$hDestSv = _WinAPI_SelectObject($hDestDC, $hBitmap)
$hSrcDC = _WinAPI_CreateCompatibleDC($hDC)
$hSource = _WinAPI_CreateCompatibleBitmapEx($hDC, $Width, $Height, _WinAPI_SwitchColor(_WinAPI_GetSysColor($COLOR_3DFACE)))
$hSrcSv = _WinAPI_SelectObject($hSrcDC, $hSource)
$hFont = _WinAPI_CreateFont(65, 0, 0, 0, $FW_NORMAL , 0, 0, 0, $DEFAULT_CHARSET, $OUT_DEFAULT_PRECIS, $CLIP_DEFAULT_PRECIS, $ANTIALIASED_QUALITY, $DEFAULT_PITCH, 'Arial')
_WinAPI_SelectObject($hSrcDC, $hFont)
_WinAPI_DrawShadowText($hSrcDC, 'Shadow Text', 0xF06000, 0x808080, 3, 3, $tRECT, BitOR($DT_CENTER, $DT_SINGLELINE, $DT_VCENTER))
_WinAPI_BitBlt($hDestDC, 0, 0, $Width, $Height, $hSrcDC, 0, 0, $MERGECOPY)

_WinAPI_ReleaseDC($hPic, $hDC)
_WinAPI_SelectObject($hDestDC, $hDestSv)
_WinAPI_DeleteDC($hDestDC)
_WinAPI_SelectObject($hSrcDC, $hSrcSv)
_WinAPI_DeleteDC($hSrcDC)
_WinAPI_DeleteObject($hSource)
_WinAPI_DeleteObject($hFont)

;Set bitmap to control
_SendMessage($hPic, $STM_SETIMAGE, 0, $hBitmap)
$hObj = _SendMessage($hPic, $STM_GETIMAGE)
If $hObj <> $hBitmap Then
	_WinAPI_DeleteObject($hBitmap)
EndIf

GUISetState()

Do
Until GUIGetMsg() = -3
