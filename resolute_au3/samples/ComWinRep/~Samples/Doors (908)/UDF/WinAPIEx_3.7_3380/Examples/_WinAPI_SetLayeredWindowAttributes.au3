#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $Button

$hForm = GUICreate('MyGUI', 400, 400, -1, -1, -1, $WS_EX_LAYERED)
GUISetBkColor(0xABABAB)
$Button = GUICtrlCreateButton('OK', 165, 370, 70, 23)
GUISetState()

_WinAPI_SetLayeredWindowAttributes($hForm, 0xABABAB, 255, BitOR($LWA_COLORKEY, $LWA_ALPHA))

Do
Until GUIGetMsg() = -3
