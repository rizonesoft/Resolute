#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Label, $hLabel

GUICreate('MyGUI', 260, 60)
$Label = GUICtrlCreateLabel('', 10, 22, 240, 16)
$hLabel = GUICtrlGetHandle($Label)
GUICtrlSetData(-1, _WinAPI_PathCompactPath($hLabel, @ScriptFullPath))
GUISetState()

Do
Until GUIGetMsg() = -3
