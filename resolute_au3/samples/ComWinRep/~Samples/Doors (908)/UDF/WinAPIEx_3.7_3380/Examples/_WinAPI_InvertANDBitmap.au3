#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic[2], $hPic[2], $aInfo, $hIcon, $hObj

; Extracts icon and create AND bitmask bitmap
$hIcon = _WinAPI_ShellExtractIcon(@ScriptDir & '\Extras\Script.ico', 0, 128, 128)
$aInfo = _WinAPI_GetIconInfo($hIcon)
_WinAPI_DeleteObject($aInfo[5])
_WinAPI_DestroyIcon($hIcon)

; Create inverted bitmask bitmap
$aInfo[5] = _WinAPI_InvertANDBitmap($aInfo[4])

; Create GUI
$hForm = GUICreate('MyGUI', 256, 128)
$Pic[0] = GUICtrlCreatePic('', 0, 0, 128, 128)
$Pic[1] = GUICtrlCreatePic('', 128, 0, 128, 128)
For $i = 0 To 1
	$hPic[$i] = GUICtrlGetHandle($Pic[$i])
Next

; Set both bitmaps to controls
For $i = 0 To 1
	_SendMessage($hPic[$i], $STM_SETIMAGE, 0, $aInfo[$i + 4])
	$hObj = _SendMessage($hPic[$i], $STM_GETIMAGE)
	If $hObj <> $aInfo[$i + 4] Then
		_WinAPI_DeleteObject($aInfo[$i + 4])
	EndIf
Next

GUISetState()

Do
Until GUIGetMsg() = -3
