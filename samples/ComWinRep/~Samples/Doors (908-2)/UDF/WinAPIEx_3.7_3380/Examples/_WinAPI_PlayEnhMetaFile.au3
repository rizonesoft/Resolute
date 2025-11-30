#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic, $hPic, $tSIZE, $tRECT, $Width, $Height, $hEmf, $hObj, $hBitmap, $hDC, $hMemDC, $hMemSv

; Load enhanced metafile (.emf) and retrieve it's dimension (x6)
$hEmf = _WinAPI_GetEnhMetaFile(@ScriptDir & '\Extras\Flag.emf')
$tSIZE = _WinAPI_GetEnhMetaFileDimension($hEmf)
$Width = 6 * DllStructGetData($tSIZE, 'X')
$Height = 6 * DllStructGetData($tSIZE, 'Y')

; Create GUI
$hForm = GUICreate('MyGUI', $Width, $Height)
$Pic = GUICtrlCreatePic('', 0, 0, $Width, $Height)
$hPic = GUICtrlGetHandle($Pic)

; Create bitmap from enhanced metafile
$hDC = _WinAPI_GetDC($hPic)
$hMemDC = _WinAPI_CreateCompatibleDC($hDC)
$hBitmap = _WinAPI_CreateCompatibleBitmapEx($hDC, $Width, $Height, _WinAPI_SwitchColor(_WinAPI_GetSysColor($COLOR_3DFACE)))
$hMemSv = _WinAPI_SelectObject($hMemDC, $hBitmap)
$tRECT = _WinAPI_CreateRectEx(0, 0, $Width, $Height)
_WinAPI_PlayEnhMetaFile($hMemDC, $hEmf, $tRECT)

_WinAPI_ReleaseDC($hPic, $hDC)
_WinAPI_SelectObject($hMemDC, $hMemSv)
_WinAPI_DeleteDC($hMemDC)

; Release enhanced metafile
_WinAPI_DeleteEnhMetaFile($hEmf)

; Set bitmap to control
_SendMessage($hPic, $STM_SETIMAGE, 0, $hBitmap)
$hObj = _SendMessage($hPic, $STM_GETIMAGE)
If $hObj <> $hBitmap Then
	_WinAPI_DeleteObject($hBitmap)
EndIf

GUISetState()

Do
Until GUIGetMsg() = -3
