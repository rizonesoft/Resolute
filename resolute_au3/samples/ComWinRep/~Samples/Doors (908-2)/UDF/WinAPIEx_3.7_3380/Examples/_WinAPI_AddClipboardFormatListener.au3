#Include <APIConstants.au3>
#Include <Clipboard.au3>
#Include <EditConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.0' Then
	MsgBox(16, 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

Global $hForm, $Msg, $Edit

$hForm = GUICreate('MyGUI', 400, 400, 10, 10, BitOR($GUI_SS_DEFAULT_GUI, $WS_MAXIMIZEBOX, $WS_SIZEBOX), $WS_EX_TOPMOST)
$Edit = GUICtrlCreateEdit('', 0, 0, 400, 400, BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY))
GUIRegisterMsg($WM_CLIPBOARDUPDATE, 'WM_CLIPBOARDUPDATE')
GUISetState()

_WinAPI_AddClipboardFormatListener($hForm)
_SendMessage($hForm, $WM_CLIPBOARDUPDATE)

Do
Until GUIGetMsg() = -3

Func WM_CLIPBOARDUPDATE($hWnd, $Msg, $wParam, $lParam)
	_ClipBoard_Open(0)
	GUICtrlSetData($Edit, _ClipBoard_GetData($CF_TEXT))
	_ClipBoard_Close()
	Return 0
EndFunc   ;==>WM_CLIPBOARDUPDATE
