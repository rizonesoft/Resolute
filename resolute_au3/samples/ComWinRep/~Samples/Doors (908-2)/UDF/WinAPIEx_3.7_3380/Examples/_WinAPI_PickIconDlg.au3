#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Last[2] = [@SystemDir & '\shell32.dll', 3]
Global $hForm, $Msg, $Button, $Icon, $Data

$hForm = GUICreate('MyGUI', 160, 160)
$Button = GUICtrlCreateButton('Change Icon...', 25, 130, 110, 23)
$Icon = GUICtrlCreateIcon($Last[0], -(1 + $Last[1]), 64, 54, 32, 32)
GUISetState()

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case -3
			ExitLoop
		Case $Button
			$Data = _WinAPI_PickIconDlg($Last[0], $Last[1], $hForm)
			If IsArray($Data) Then
				GUICtrlSetImage($Icon, $Data[0], -(1 + $Data[1]))
				$Last = $Data
			EndIf
	EndSwitch
WEnd
