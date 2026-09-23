#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic, $hPic, $hObj, $hBitmap, $hDC, $hDestDC, $hDestSv
Global $aVertex[6][3] = [[0, 0, 0xFF0000], [400, 400, 0x00FF00], [  0, 400, 0x0000FF], [0, 0, 0xFF0000], [400,   0, 0xFFFF00], [400, 400, 0x00FF00]]

; Create GUI
$hForm = GUICreate('MyGUI', 400, 400)
$Pic = GUICtrlCreatePic('', 0, 0, 400, 400)
$hPic = GUICtrlGetHandle($Pic)

; Create gradient
$hDC = _WinAPI_GetDC($hPic)
$hDestDC = _WinAPI_CreateCompatibleDC($hDC)
$hBitmap = _WinAPI_CreateCompatibleBitmap($hDC, 400, 400)
$hDestSv = _WinAPI_SelectObject($hDestDC, $hBitmap)
_WinAPI_GradientFill($hDestDC, $aVertex, 0, 2)
_WinAPI_GradientFill($hDestDC, $aVertex, 3, 5)

_WinAPI_ReleaseDC($hPic, $hDC)
_WinAPI_SelectObject($hDestDC, $hDestSv)
_WinAPI_DeleteDC($hDestDC)

; Set gradient to control
_SendMessage($hPic, $STM_SETIMAGE, 0, $hBitmap)
$hObj = _SendMessage($hPic, $STM_GETIMAGE)
If $hObj <> $hBitmap Then
	_WinAPI_DeleteObject($hBitmap)
EndIf

GUISetState()

Do
Until GUIGetMsg() = -3
