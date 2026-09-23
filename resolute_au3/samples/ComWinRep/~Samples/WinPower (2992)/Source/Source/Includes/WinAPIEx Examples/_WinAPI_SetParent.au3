#Include <WinAPIEx.au3>
#Include <WindowsConstants.au3>

Opt('MustDeclareVars', 1)

Global $hParent, $hChild

$hParent = GUICreate('Parent', 400, 400, 200, 200)
GUICtrlCreateLabel('', 0, 0, 0, 0)
GUISetState()
$hChild = GUICreate('Child', 200, 200, 0, 0, BitOR($WS_CAPTION, $WS_MAXIMIZEBOX, $WS_MINIMIZEBOX, $WS_POPUP, $WS_SYSMENU))
_WinAPI_SetParent($hChild, $hParent)
GUISetState()

Do
Until GUIGetMsg() = -3
