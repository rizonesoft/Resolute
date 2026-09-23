#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic, $hPic, $tSIZE, $W, $H, $hObj, $hBitmap, $hResize

; Load and resize (x2) image
$hBitmap = _WinAPI_LoadImage(0, @ScriptDir & '\Extras\AutoIt.bmp', $IMAGE_BITMAP, 0, 0, $LR_LOADFROMFILE)
$tSIZE = _WinAPI_GetBitmapDimension($hBitmap)
$W = 2 * DllStructGetData($tSIZE, 'X')
$H = 2 * DllStructGetData($tSIZE, 'Y')
$hResize = _WinAPI_AdjustBitmap($hBitmap, $W, $H)
_WinAPI_DeleteObject($hBitmap)

; Create GUI
$hForm = GUICreate('MyGUI', $W, $H)
$Pic = GUICtrlCreatePic('', 0, 0, $W, $H)
$hPic = GUICtrlGetHandle($Pic)

; Set bitmap to control
_SendMessage($hPic, $STM_SETIMAGE, 0, $hResize)
$hObj = _SendMessage($hPic, $STM_GETIMAGE)
If $hObj <> $hResize Then
	_WinAPI_DeleteObject($hResize)
EndIf

GUISetState()

Do
Until GUIGetMsg() = -3
