#Include <GUIConstantsEx.au3>
#Include <WinAPIEx.au3>
#Include <WindowsConstants.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $Msg, $Button

$hForm = GUICreate('MyGUI', 400, 400, -1, -1, -1, $WS_EX_LAYERED)
GUISetBkColor(0xABABAB)
$Button = GUICtrlCreateButton('OK', 165, 370, 70, 23)
GUISetState()

_WinAPI_SetLayeredWindowAttributes($hForm, 0xABABAB, 255, BitOR($LWA_COLORKEY, $LWA_ALPHA))

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case $GUI_EVENT_CLOSE
			ExitLoop
	EndSwitch
WEnd
