#Include <Constants.au3>
#Include <WinAPIEx.au3>
#Include <WindowsConstants.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic, $hPic, $tSIZE, $Width, $Height, $hObj, $hBitmap, $hSource, $hDC, $hDestDC, $hDestSv

; Load image
$hSource = _WinAPI_LoadImage(0, @ScriptDir & '\Extras\Logo.bmp', $IMAGE_BITMAP, 0, 0, $LR_LOADFROMFILE)
$tSIZE = _WinAPI_GetBitmapDimension($hSource)
$Width = DllStructGetData($tSIZE, 'X')
$Height = DllStructGetData($tSIZE, 'Y')

; Create GUI
$hForm = GUICreate('MyGUI', $Width, 4 * $Height)
$Pic = GUICtrlCreatePic('', 0, 0, $Width, 4 * $Height)
$hPic = GUICtrlGetHandle($Pic)

; Create bitmap
$hDC = _WinAPI_GetDC($hPic)
$hDestDC = _WinAPI_CreateCompatibleDC($hDC)
$hBitmap = _WinAPI_CreateCompatibleBitmap($hDC, $Width, 4 * $Height)
$hDestSv = _WinAPI_SelectObject($hDestDC, $hBitmap)
For $i = 0 To 3
	_WinAPI_DrawBitmap($hDestDC, 0, $i * $Height, $hSource)
Next

_WinAPI_ReleaseDC($hPic, $hDC)
_WinAPI_SelectObject($hDestDC, $hDestSv)
_WinAPI_DeleteObject($hSource)
_WinAPI_DeleteDC($hDestDC)

; Set bitmap to control
_SendMessage($hPic, $STM_SETIMAGE, 0, $hBitmap)
$hObj = _SendMessage($hPic, $STM_GETIMAGE)
If $hObj <> $hBitmap Then
	_WinAPI_DeleteObject($hBitmap)
EndIf

GUISetState()

Do
Until GUIGetMsg() = -3
