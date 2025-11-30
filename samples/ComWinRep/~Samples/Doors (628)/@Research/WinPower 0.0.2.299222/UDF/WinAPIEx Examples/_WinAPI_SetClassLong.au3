#NoTrayIcon

Opt('MustDeclareVars', 1)

#Include <WinAPIEx.au3>
#Include <WindowsConstants.au3>

Global $hParent, $hForm, $hIcon

$hParent = GUICreate('', 0, 0, 0, 0, 0, $WS_EX_TOOLWINDOW)
$hForm = GUICreate('MyGUI', 400, 400, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_SYSMENU), $WS_EX_DLGMODALFRAME, $hParent)

 $hIcon = _WinAPI_GetClassLong($hForm, $GCL_HICON)
_WinAPI_FreeIcon($hIcon)
_WinAPI_SetClassLong($hForm, $GCL_HICON, 0)
_WinAPI_SetClassLong($hForm, $GCL_HICONSM, 0)

GUISetState()

Do
Until GUIGetMsg() = -3
