#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172

Global $hIcon = _WinAPI_Create32BitHICON(_WinAPI_ShellExtractIcon(@SystemDir & '\shell32.dll', 1, 32, 32), 1)

GUICreate('MyGUI', 262, 108)
For $i = 0 To 3
	GUICtrlCreateIcon('', 0, 30 + 58 * $i, 38, 32, 32)
	GUICtrlSendMsg(-1, $STM_SETIMAGE, 1, _WinAPI_AddIconTransparency($hIcon, 100 - 25 * $i))
Next
_WinAPI_DestroyIcon($hIcon)
GUISetState()

Do
Until GUIGetMsg() = -3
