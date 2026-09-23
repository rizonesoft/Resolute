#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic, $hPic, $hObj, $hBitmap, $hDC, $hDestDC, $hDestSv

; Create GUI
$hForm = GUICreate('MyGUI', 400, 400)
$Pic = GUICtrlCreatePic('', 0, 0, 400, 400)
$hPic = GUICtrlGetHandle($Pic)

; Create gradient
$hDC = _WinAPI_GetDC($hPic)
$hDestDC = _WinAPI_CreateCompatibleDC($hDC)
$hBitmap = _WinAPI_CreateCompatibleBitmapEx($hDC, 400, 400, 0xFFFFFF)
$hDestSv = _WinAPI_SelectObject($hDestDC, $hBitmap)
For $i = 0 To 315 Step 45
	_WinAPI_RadialGradientFill($hDestDC, 200, 200, 180, Random(0, 0xFFFFFF, 1), 0xFFFFFF, $i, $i + 45)
Next
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
