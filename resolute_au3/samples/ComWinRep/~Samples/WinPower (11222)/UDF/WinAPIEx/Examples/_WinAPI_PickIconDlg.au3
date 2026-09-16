#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $Msg, $Button, $Icon, $Data[2] = [@SystemDir & '\shell32.dll', 130]

$hForm = GUICreate('MyGUI', 160, 160)
$Button = GUICtrlCreateButton('Change Icon...', 30, 130, 110, 23)
$Icon = GUICtrlCreateIcon($Data[0], - (1 + $Data[1]), 64, 54, 32, 32)
GUISetState()

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case -3
			ExitLoop
		Case $Button
			$Data = _WinAPI_PickIconDlg($Data[0], $Data[1], $hForm)
			If Not @error Then
				GUICtrlSetImage($Icon, $Data[0], - (1 + $Data[1]))
			EndIf
	EndSwitch
WEnd
