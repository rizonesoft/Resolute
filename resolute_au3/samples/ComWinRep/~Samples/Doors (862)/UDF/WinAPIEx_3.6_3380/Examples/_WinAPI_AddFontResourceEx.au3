#Include <APIConstants.au3>
#Include <StaticConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

_WinAPI_AddFontResourceEx(@ScriptDir & '\Extras\SF Square Head Bold.ttf', $FR_PRIVATE)

GUICreate('MyGUI', 400, 100)
GUICtrlCreateLabel('Simple Text', 10, 25, 380, 50, $SS_CENTER)
GUICtrlSetFont(-1, 38, -1, -1, 'SF Square Head Bold')
GUICtrlSetColor(-1, 0xF06000)
GUISetState()

Do
Until GUIGetMsg() = -3
