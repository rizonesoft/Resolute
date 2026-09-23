#Include <APIConstants.au3>
#Include <StaticConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Msg, $Label, $Next, $Prev, $Update = True

GUICreate('MyGUI', 300, 200)
$Label = GUICtrlCreateLabel('', 10, 66, 280, 40, $SS_CENTER)
GUICtrlSetFont(-1, 12, 800, 0, 'Tahoma')
$Prev = GUICtrlCreateButton('<', 82, 164, 60, 24)
$Next = GUICtrlCreateButton('>', 158, 164, 60, 24)
GUISetState()

While 1
	If $Update Then
		GUICtrlSetData($Label, '0x' & StringRight(@KBLayout, 4) & @CR & _WinAPI_GetLocaleInfo(Number('0x' & @KBLayout), $LOCALE_SLANGUAGE))
		$Update = 0
	EndIf
	$Msg = GUIGetMsg()
	Switch $Msg
		Case -3
			ExitLoop
		Case $Next
			_WinAPI_ActivateKeyboardLayout($HKL_NEXT)
			$Update = 1
		Case $Prev
			_WinAPI_ActivateKeyboardLayout($HKL_PREV)
			$Update = 1
	EndSwitch
WEnd
