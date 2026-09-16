#Include <APIConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $Msg, $Button, $Slider

$hForm = GUICreate('MyGUI', 400, 400)
GUISetFont(8.5, 400, 0, 'MS Shell Dlg', $hForm)
$Button = GUICtrlCreateButton('Set Theme Color', 140, 368, 115, 23)
GUICtrlCreateTab(7, 7, 388, 354)
GUICtrlCreateTabItem('About')
$Slider = GUICtrlCreateSlider(20, 45, 360, 26)
GUICtrlCreateTabItem('')
GUISetState()

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case -3
			ExitLoop
		Case $Button
			GUICtrlSetBkColor($Slider, _GetTabBodyColor($hForm))
			GUICtrlSetState($Button, $GUI_DISABLE)
	EndSwitch
WEnd

Func _GetTabBodyColor($hForm)

	Local $hTheme, $Color, $Part, $Default = _WinAPI_SwitchColor(_WinAPI_GetSysColor($COLOR_3DFACE))

	$hTheme = _WinAPI_OpenThemeData($hForm, 'TAB')
	If @error Then
		Return $Default
	EndIf
	Switch @OSVersion
		Case 'WIN_XP', 'WIN_2003'
			$Part = 10 ; TABP_BODY
		Case Else
			$Part = 11 ; TABP_AEROWIZARDBODY
	EndSwitch
	$Color = _WinAPI_GetThemeColor($hTheme, $Part, 1, $TMT_FILLCOLORHINT)
	_WinAPI_CloseThemeData($hTheme)
	If $Color < 0 Then
		Return $Default
	EndIf
	Return $Color
EndFunc   ;==>_GetTabBodyColor
