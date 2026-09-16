#Include <APIConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <StaticConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.0' Then
	MsgBox(16, 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

Global Const $STM_SETIMAGE = 0x0172

Global $Msg, $Icon, $Label, $Prev, $Next, $tSHSTOCKICONINFO, $hIcon, $hOld, $Count = 0, $Update = True

GUICreate('MyGUI', 200, 236)
GUICtrlCreateIcon('', 0, 36, 36, 128, 128)
$Icon = GUICtrlGetHandle(-1)
GUICtrlSetState(-1, $GUI_DISABLE)
$Label = GUICtrlCreateLabel('', 70, 174, 60, 14, $SS_CENTER)
$Prev = GUICtrlCreateButton('<', 32, 200, 60, 24)
$Next = GUICtrlCreateButton('>', 108, 200, 60, 24)
GUISetState()

While 1
	If $Update Then
		GUICtrlSetData($Label, 'SIID: ' & $Count)
		$tSHSTOCKICONINFO = _WinAPI_ShellGetStockIconInfo($Count, $SHGSI_ICONLOCATION)
		$hIcon = _WinAPI_ShellExtractIcon(DllStructGetData($tSHSTOCKICONINFO, 'Path'), DllStructGetData($tSHSTOCKICONINFO, 'iIcon'), 128, 128)
		$hOld = _SendMessage($Icon, $STM_SETIMAGE, 1, $hIcon)
		If $hOld Then
			_WinAPI_DestroyIcon($hOld)
		EndIf
		$Update = 0
	EndIf
	$Msg = GUIGetMsg()
	Switch $Msg
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case $Prev
			$Count -= 1
			If $Count < 0 Then
				$Count = $SIID_MAX_ICONS - 1
			EndIf
			$Update = 1
		Case $Next
			$Count += 1
			If $Count > $SIID_MAX_ICONS - 1 Then
				$Count = 0
			EndIf
			$Update = 1
	EndSwitch
WEnd
