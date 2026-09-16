#Include <APIConstants.au3>
#Include <StaticConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.0' Then
	MsgBox(16, 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

Global $hForm, $Label, $Count = 60

$hForm = GUICreate('MyGUI', 300, 100)
$Label = GUICtrlCreateLabel('The application will be crashes after 60 seconds.', 10, 43, 280, 14, $SS_CENTER)
GUISetState()

If ($CmdLine[0]) And ($CmdLine[1] = '/crash') Then
	MsgBox(48, 'Attention', 'The application has been restarted after an abnormal exit.', 0, $hForm)
EndIf

If Not @compiled Then
	_WinAPI_RegisterApplicationRestart(BitOR($RESTART_NO_PATCH, $RESTART_NO_REBOOT), '"' & @ScriptFullPath & '" /crash')
Else
	_WinAPI_RegisterApplicationRestart(BitOR($RESTART_NO_PATCH, $RESTART_NO_REBOOT), '/crash')
EndIf

AdlibRegister('_Countdown', 1000)

Do
Until GUIGetMsg() = -3

Func _Countdown()

	Local $tData, $iData

	$Count -= 1
	If $Count Then
		GUICtrlSetData($Label, 'The application will be crashes after ' & $Count & ' seconds.')
	Else
		; Forced script crash due to a memory access violation
		$tData = DllStructCreate('int', 0x12345678)
		$iData = DllStructGetData($tData, 1)
	EndIf
EndFunc   ;==>_Countdown
