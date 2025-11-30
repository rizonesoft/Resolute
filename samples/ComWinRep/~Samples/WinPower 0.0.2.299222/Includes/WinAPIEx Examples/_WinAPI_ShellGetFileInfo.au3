#Include <GUIConstantsEx.au3>
#Include <GUIListView.au3>
#Include <GUIImageList.au3>
#Include <WinAPIEx.au3>
#Include <WindowsConstants.au3>

Opt('MustDeclareVars', 1)

Global $Msg, $Button, $ListView, $hImageList, $hIcon, $tSHFILEINFO, $i = 1, $Key, $First = False

Dim $Ext[101] = [0]

While 1
	$Key = RegEnumKey('HKCR', $i)
	If @error Then
		ExitLoop
	EndIf
	If StringLeft($Key, 1) = '.' Then
		$Ext[0] += 1
		If $Ext[0] > UBound($Ext) - 1 Then
			ReDim $Ext[UBound($Ext) + 100]
		EndIf
		$Ext[$Ext[0]] = $Key
		$First = 1
	Else
		If $First Then
			ExitLoop
		EndIf
	EndIf
	$i += 1
WEnd

GUICreate('MyGUI', 280, 391)

$ListView = GUICtrlCreateListView('', 10, 10, 260, 344, BitOR($LVS_DEFAULT, $LVS_NOCOLUMNHEADER), $WS_EX_CLIENTEDGE)
_GUICtrlListView_SetExtendedListViewStyle($ListView, BitOR($LVS_EX_DOUBLEBUFFER, $LVS_EX_INFOTIP))
_GUICtrlListView_InsertColumn($ListView, 0, '', 234)
$hImageList = _GUIImageList_Create(16, 16, 6)
_GUICtrlListView_SetImageList($ListView, $hImageList, 1)
$Button = GUICtrlCreateButton('OK', 105, 361, 70, 23)

For $i = 1 To $Ext[0]
	$tSHFILEINFO = _WinAPI_ShellGetFileInfo($Ext[$i], BitOR($SHGFI_ICON, $SHGFI_SMALLICON, $SHGFI_USEFILEATTRIBUTES))
	$hIcon = DllStructGetData($tSHFILEINFO, 'hIcon')
	_GUIImageList_ReplaceIcon($hImageList, -1, $hIcon)
	_GUICtrlListView_AddItem($ListView, $Ext[$i], $i - 1)
	_WinAPI_FreeIcon($hIcon)
Next

GUISetState()

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case $GUI_EVENT_CLOSE, $Button
			ExitLoop
	EndSwitch
WEnd
