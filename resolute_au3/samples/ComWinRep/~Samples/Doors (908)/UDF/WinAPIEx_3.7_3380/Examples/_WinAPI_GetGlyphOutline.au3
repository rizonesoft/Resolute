#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic, $hPic, $tGM, $W, $H, $hDC, $hSv, $hBmp, $hDib, $hFont, $pData = 0
Global $aColorTable[2] = [0xFFFFFF, 0xC00000]

; Creates logical font ("Times") and retrieve bitmap bits for a random character
$hDC = _WinAPI_CreateCompatibleDC(0)
$hFont = _WinAPI_CreateFont(512, 0, 0, 0, 400, False, False, False, $DEFAULT_CHARSET, $OUT_DEFAULT_PRECIS,$CLIP_DEFAULT_PRECIS, $DEFAULT_QUALITY, 0, 'Times')
$hSv = _WinAPI_SelectObject($hDC, $hFont)
$tGM = _WinAPI_GetGlyphOutline($hDC, ChrW(Random(65, 90, 1)), $GGO_BITMAP, $pData)
$W = DllStructGetData($tGM, 'BlackBoxX')
$H = DllStructGetData($tGM, 'BlackBoxY')
_WinAPI_SelectObject($hDC, $hSv)
_WinAPI_DeleteObject($hFont)

; Create 1 bits-per-pixel bitmap
$hBmp = _WinAPI_CreateBitmap(32 * Ceiling($W / 32), $H, 1, 1, $pData)

; Crop bitmap to the required size and colorize it
$hDib = _WinAPI_CreateDIB($W, $H, 1, _WinAPI_CreateDIBColorTable($aColorTable), 2)
$hSv = _WinAPI_SelectObject($hDC, $hDib)
_WinAPI_DrawBitmap($hDC, 0, 0, $hBmp, $MERGEPAINT)
_WinAPI_SelectObject($hDC, $hSv)
_WinAPI_DeleteObject($hBmp)

; Free unnecessary resources
_WinAPI_FreeMemory($pData)
_WinAPI_DeleteDC($hDC)

; Create GUI
$hForm = GUICreate('MyGUI', $W, $H)
$Pic = GUICtrlCreatePic('', 0, 0, $W, $H)
$hPic = GUICtrlGetHandle($Pic)

; Set bitmap to control
_SendMessage($hPic, $STM_SETIMAGE, 0, $hDib)
$hBmp = _SendMessage($hPic, $STM_GETIMAGE)
If $hBmp <> $hDib Then
	_WinAPI_DeleteObject($hDib)
EndIf

; Show GUI
GUISetState()

Do
Until GUIGetMsg() = -3
