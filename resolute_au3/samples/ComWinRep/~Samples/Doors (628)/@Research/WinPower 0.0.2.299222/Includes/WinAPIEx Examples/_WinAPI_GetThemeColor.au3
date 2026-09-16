#Include <GUIConstantsEx.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $Msg, $Tab, $hTab, $Button, $Slider, $Part

$hForm = GUICreate('MyGUI', 400, 400)
GUISetFont(8.5, 400, 0, 'MS Shell Dlg', $hForm)
$Button = GUICtrlCreateButton('Set Theme Color', 140, 368, 115, 23)
$Tab = GUICtrlCreateTab(7, 7, 388, 354)
$hTab = GUICtrlGetHandle($Tab)
GUICtrlCreateTabItem('About')
$Slider = GUICtrlCreateSlider(20, 45, 360, 26)
GUICtrlCreateTabItem('')
GUISetState()

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case $Button
			Switch @OSVersion
				Case 'WIN_2000', 'WIN_XP', 'WIN_2003'
					$Part = 10
				Case Else
					$Part = 11
			EndSwitch
			GUICtrlSetBkColor($Slider, _WinAPI_GetThemeColor($hTab, 'TAB', $Part, 1, 0x0EED))
			GUICtrlSetState($Button, $GUI_DISABLE)
	EndSwitch
WEnd
