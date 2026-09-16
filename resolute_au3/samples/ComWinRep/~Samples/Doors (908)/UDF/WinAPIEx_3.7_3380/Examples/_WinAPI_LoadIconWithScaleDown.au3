#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172

If _WinAPI_GetVersion() < '6.0' Then
	MsgBox(16, 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

Global $Icon, $hIcon, $hPrev

GUICreate('MyGUI', 324, 324)
GUICtrlCreateIcon('', 0, 64, 64, 196, 196)
$Icon = GUICtrlGetHandle(-1)
GUISetState()

$hIcon = _WinAPI_LoadIconWithScaleDown(0, @ScriptDir & '\Extras\Soccer.ico', 196, 196)
$hPrev = _SendMessage($Icon, $STM_SETIMAGE, 1, $hIcon)
If $hPrev Then
	_WinAPI_DestroyIcon($hPrev)
EndIf

Do
Until GUIGetMsg() = -3
