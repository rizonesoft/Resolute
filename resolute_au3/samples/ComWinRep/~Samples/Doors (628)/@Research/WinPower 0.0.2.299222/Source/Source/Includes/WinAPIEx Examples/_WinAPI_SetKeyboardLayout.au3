#Include <Array.au3>
#Include <GUIConstantsEx.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $Msg, $Button, $Index, $Label, $Layout, $List = _WinAPI_GetKeyboardLayoutList()
Global $hAutoIt = WinGetHandle(AutoItWinGetTitle())

$hForm = GUICreate('MyGUI', 250, 120)
$Layout = _WinAPI_GetKeyboardLayout($hAutoIt)
$Index = _ArraySearch($List, $Layout, 1)
$Label = GUICtrlCreateLabel('0x' & Hex($Layout, 4), 20, 34, 210, 30, 0x01)
GUICtrlSetFont(-1, 18, 800, 0, 'Tahoma')
$Button = GUICtrlCreateButton('Next Layout', 75, 90, 100, 23)
GUISetState()

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case $Button
			$Index += 1
			If $Index > $List[0] Then
				$Index = 1
			EndIf
			_WinAPI_SetKeyboardLayout($hAutoIt, $List[$Index])
			GUICtrlSetData($Label, '0x' & Hex($List[$Index], 4))
	EndSwitch
WEnd
