#Include <APIConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $Msg, $Button, $Label[4], $Data[4]

$hForm = GUICreate('MyGUI', 180, 135, -1, -1, -1, $WS_EX_TOPMOST)
$Button = GUICtrlCreateButton('OK', 55, 101, 70, 23)
GUICtrlCreateLabel('AC power:', 10, 14, 90, 14)
GUICtrlCreateLabel('Status:', 10, 34, 70, 14)
GUICtrlCreateLabel('Charge:', 10, 54, 90, 14)
GUICtrlCreateLabel('Time remaining:', 10, 74, 90, 14)
For $i = 0 To 3
	$Label[$i] = GUICtrlCreateLabel('Unknown', 110, 14 + 20 * $i, 60, 14)
Next
GUISetState()

AdlibRegister('_BatteryStatus', 1000)

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case $GUI_EVENT_CLOSE, $Button
			ExitLoop
	EndSwitch
WEnd

Func _BatteryStatus()

	Local $Data = _WinAPI_GetSystemPowerStatus()

	If Not IsArray($Data) Then
		Return
	EndIf

	Local $H, $M

	If BitAND($Data[1], 128) Then
		$Data[0] = 'Not present'
		For $i = 1 To 3
			$Data[$i] = 'Unknown'
		Next
	Else
		Switch $Data[0]
			Case 0
				$Data[0] = 'Offline'
			Case 1
				$Data[0] = 'Online'
			Case Else
				$Data[0] = 'Unknown'
		EndSwitch
		Switch $Data[2]
			Case 0 To 100
				$Data[2] &= '%'
		Case Else
				$Data[2] = 'Unknown'
		EndSwitch
		Switch $Data[3]
			Case -1
				$Data[3] = 'Unknown'
			Case Else
				$H = ($Data[3] - Mod($Data[3], 3600)) / 3600
				$M = ($Data[3] - Mod($Data[3], 60)) / 60 - $H * 60
				$Data[3] = StringFormat($H & ':%02d', $M)
		EndSwitch
		If BitAND($Data[1], 8) Then
			$Data[1] = 'Charging'
		Else
			Switch BitAND($Data[1], 0xF)
				Case 1
					$Data[1] = 'High'
				Case 2
					$Data[1] = 'Low'
				Case 4
					$Data[1] = 'Critical'
				Case Else
					$Data[1] = 'Unknown'
			EndSwitch
		EndIf
	EndIf
	For $i = 0 To 3
		GUICtrlSetData($Label[$i], $Data[$i])
	Next
EndFunc   ;==>_BatteryStatus
