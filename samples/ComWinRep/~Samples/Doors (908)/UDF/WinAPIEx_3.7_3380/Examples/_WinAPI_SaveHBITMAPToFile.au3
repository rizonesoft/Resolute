#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic, $hPic, $hDC, $hMemDC, $hMemSv, $hBitmap, $pBits, $hDev, $hObj, $Path
Global $aColorTable, $tColorTable

; Create array of colors of 256 entries required for 8 bits-per-pixel bitmap
Dim $aColorTable[256]
For $i = 0 To 255
	$aColorTable[$i] = _WinAPI_RGB(0, $i, 255 - $i)
Next

; Create color table from an array of colors
$tColorTable = _WinAPI_CreateDIBColorTable($aColorTable)

; Create 8 bits-per-pixel device-independent bitmap (DIB) and retrieve a pointer to the location of its bit values
$hBitmap = _WinAPI_CreateDIB(256, 256, 8, $tColorTable, 256)
$pBits = _WinAPI_GetExtended()

; Fill bitmap color indexes
For $i = 0 To 255
	_WinAPI_FillMemory($pBits + 256 * $i, 256, $i)
Next

; Create GUI
$hForm = GUICreate('MyGUI', 256, 256)
$Pic = GUICtrlCreatePic('', 0, 0, 256, 256)
$hPic = GUICtrlGetHandle($Pic)

; Create DDB from DIB to correct display in control
$hDC = _WinAPI_GetDC($hPic)
$hDev = _WinAPI_CreateCompatibleBitmap($hDC, 256, 256)
$hMemDC = _WinAPI_CreateCompatibleDC($hDC)
$hMemSv = _WinAPI_SelectObject($hMemDC, $hDev)
_WinAPI_DrawBitmap($hMemDC, 0, 0, $hBitmap)
_WinAPI_ReleaseDC($hPic, $hDC)
_WinAPI_SelectObject($hMemDC, $hMemSv)
_WinAPI_DeleteDC($hMemDC)

; Set bitmap to control
_SendMessage($hPic, $STM_SETIMAGE, 0, $hDev)
$hObj = _SendMessage($hPic, $STM_GETIMAGE)
If $hObj <> $hDev Then
	_WinAPI_DeleteObject($hDev)
EndIf

; Show GUI
GUISetState()

; Save 8 bits-per-pixel bitmap to .bmp file
$Path = FileSaveDialog('Save Image', @ScriptDir, 'Bitmap Image Files (*.bmp)', 2 + 16, @ScriptDir & '\MyImage.bmp', $hForm)
If $Path Then
	_WinAPI_SaveHBITMAPToFile($Path, $hBitmap, 2834, 2834)
EndIf

Do
Until GUIGetMsg() = -3
