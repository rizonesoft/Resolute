#Include <Constants.au3>
#Include <WinAPIEx.au3>
#Include <WindowsConstants.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic, $hPic, $tSIZE, $Width, $Height, $hObj, $hFit, $hBitmap

; Load and resize (x2) image
$hBitmap = _WinAPI_LoadImage(0, @ScriptDir & '\Extras\Logo.bmp', $IMAGE_BITMAP, 0, 0, $LR_LOADFROMFILE)
$tSIZE = _WinAPI_GetBitmapDimension($hBitmap)
$Width = 2 * DllStructGetData($tSIZE, 'X')
$Height = 2 * DllStructGetData($tSIZE, 'Y')
$hFit = _WinAPI_ResizeBitmap($hBitmap, $Width, $Height)
_WinAPI_DeleteObject($hBitmap)

; Create GUI
$hForm = GUICreate('MyGUI', $Width, $Height)
$Pic = GUICtrlCreatePic('', 0, 0, $Width, $Height)
$hPic = GUICtrlGetHandle($Pic)

; Set bitmap to control
_SendMessage($hPic, $STM_SETIMAGE, 0, $hFit)
$hObj = _SendMessage($hPic, $STM_GETIMAGE)
If $hObj <> $hFit Then
	_WinAPI_DeleteObject($hFit)
EndIf

GUISetState()

Do
Until GUIGetMsg() = -3
