#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic, $hPic, $tSIZE, $W, $H, $hObj, $hBitmap, $hSource, $hDC, $hDestDC, $hDestSv

; Load image
$hSource = _WinAPI_LoadImage(0, @ScriptDir & '\Extras\Hatch.bmp', $IMAGE_BITMAP, 0, 0, $LR_LOADFROMFILE)
$tSIZE = _WinAPI_GetBitmapDimension($hSource)
$W = DllStructGetData($tSIZE, 'X')
$H = DllStructGetData($tSIZE, 'Y')

; Create GUI
$hForm = GUICreate('MyGUI', @DesktopWidth, @DesktopHeight, 0, 0, $WS_POPUP, $WS_EX_TOPMOST)
$Pic = GUICtrlCreatePic('', 0, 0, @DesktopWidth, @DesktopHeight)
$hPic = GUICtrlGetHandle($Pic)

; Create bitmap
$hDC = _WinAPI_GetDC($hPic)
$hDestDC = _WinAPI_CreateCompatibleDC($hDC)
$hBitmap = _WinAPI_CreateCompatibleBitmap($hDC, @DesktopWidth, @DesktopHeight)
$hDestSv = _WinAPI_SelectObject($hDestDC, $hBitmap)
For $i = 0 To Ceiling(@DesktopWidth / $W) - 1
	For $j = 0 To Ceiling(@DesktopHeight / $W) - 1
		_WinAPI_DrawBitmap($hDestDC, $i * $W, $j * $H, $hSource)
	Next
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
