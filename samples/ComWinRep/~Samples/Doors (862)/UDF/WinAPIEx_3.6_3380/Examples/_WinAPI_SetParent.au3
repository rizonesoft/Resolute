#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hParent = WinGetHandle('[CLASS:Progman;TITLE:Program Manager]')
Global $hForm

$hForm = GUICreate('MyGUI', 400, 400, 100, 100, -1, $WS_EX_TOOLWINDOW)

; Attach window to the desktop (always on bottom)
_WinAPI_SetParent($hForm, $hParent)

GUISetState(@SW_SHOWNOACTIVATE)

Do
Until GUIGetMsg() = -3
