#Include <Array.au3>
#Include <ComboConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $Msg, $Drive, $Combo, $Button

$hForm = GUICreate('MyGUI', 200, 100)
$Drive = DriveGetDrive('ALL')
$Drive = StringUpper(_ArrayToString($Drive, '|', 1))
GUICtrlCreateLabel('Select drive:', 15, 29, 62, 14)
$Combo = GUICtrlCreateCombo('', 79, 25, 40, 21, $CBS_DROPDOWNLIST)
GUICtrlSetData(-1, $Drive, StringLeft($Drive, 2))
$Button = GUICtrlCreateButton('Format...', 65, 70, 70, 23)
GUISetState()

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case -3
			ExitLoop
		Case $Button
			_WinAPI_FormatDriveDlg(GUICtrlRead($Combo), 0, $hForm)
	EndSwitch
WEnd
