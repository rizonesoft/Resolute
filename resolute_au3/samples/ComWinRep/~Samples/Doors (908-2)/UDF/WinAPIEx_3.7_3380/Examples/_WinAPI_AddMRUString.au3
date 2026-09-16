#Include <APIConstants.au3>
#Include <ComboConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $hMRU, $Msg, $Button, $Combo, $Count, $Data = ''

$hMRU = _WinAPI_CreateMRUList($HKEY_CURRENT_USER, 'Software\MyProg\MRU', 5)

; Create MRU list in the registry (only at first start example)
RegRead('HKCU\Software\MyProg\MRU', 'MRUList')
If @error Then
	For $i = 5 To 1 Step -1
		_WinAPI_AddMRUString($hMRU, 'String' & $i)
	Next
EndIf

GUICreate('MyGUI', 320, 92)
$Combo = GUICtrlCreateCombo(_WinAPI_EnumMRUList($hMRU, 0), 10, 20, 300, 21, $CBS_DROPDOWNLIST)
$Count = _WinAPI_EnumMRUList($hMRU, -1)
For $i = 1 To $Count - 1
	$Data &= _WinAPI_EnumMRUList($hMRU, $i) & '|'
Next
GUICtrlSetData(-1, $Data)
$Button = GUICtrlCreateButton('OK', 125, 58, 70, 23)
GUISetState()

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case -3
			ExitLoop
		Case $Button
			_WinAPI_AddMRUString($hMRU, GUICtrlRead($Combo))
			ExitLoop
	EndSwitch
WEnd

_WinAPI_FreeMRUList($hMRU)
