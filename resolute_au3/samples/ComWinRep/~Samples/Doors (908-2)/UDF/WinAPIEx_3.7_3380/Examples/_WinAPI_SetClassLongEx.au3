#NoTrayIcon

#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $hParent

$hParent = GUICreate('', 0, 0, 0, 0, 0, $WS_EX_TOOLWINDOW)
$hForm = GUICreate('MyGUI', 400, 400, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_SYSMENU), BitOR($WS_EX_DLGMODALFRAME, $WS_EX_TOPMOST), $hParent)

; Remove window icon
_WinAPI_SetClassLongEx($hForm, $GCL_HICONSM, 0)
_WinAPI_SetClassLongEx($hForm, $GCL_HICON, 0)

GUISetState()

Do
Until GUIGetMsg() = -3
