#Include <APIConstants.au3>
#Include <GUIListView.au3>
#Include <GUIImageList.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $Msg, $Button, $ListView, $hImageList, $hIcon, $Key, $Count = 1, $First = False
Global $tSHFILEINFO = DllStructCreate($tagSHFILEINFO)

Dim $Ext[101] = [0]

RegRead('HKCR\.x', '')

While 1
	$Key = RegEnumKey('HKCR', $Count)
	If @error Then
		ExitLoop
	EndIf
	If StringLeft($Key, 1) = '.' Then
		RegRead('HKCR\' & $Key, '')
		If Abs(@error) <> 1 Then
			$Ext[0] += 1
			If $Ext[0] > UBound($Ext) - 1 Then
				ReDim $Ext[UBound($Ext) + 100]
			EndIf
			$Ext[$Ext[0]] = $Key
		EndIf
		$First = 1
	Else
		If $First Then
			ExitLoop
		EndIf
	EndIf
	$Count += 1
WEnd

$hForm = GUICreate('MyGUI', 280, 391)

$ListView = GUICtrlCreateListView('', 10, 10, 260, 344, BitOR($LVS_DEFAULT, $LVS_NOCOLUMNHEADER), $WS_EX_CLIENTEDGE)
_GUICtrlListView_SetExtendedListViewStyle($ListView, BitOR($LVS_EX_DOUBLEBUFFER, $LVS_EX_INFOTIP))
_GUICtrlListView_InsertColumn($ListView, 0, '', 238)
$hImageList = _GUIImageList_Create(16, 16, 5, 1)
_GUICtrlListView_SetImageList($ListView, $hImageList, 1)
$Button = GUICtrlCreateButton('OK', 105, 361, 70, 23)

For $i = 1 To $Ext[0]
	$hIcon = _WinAPI_ShellExtractAssociatedIcon($Ext[$i], 1)
	_GUIImageList_ReplaceIcon($hImageList, -1, $hIcon)
	_GUICtrlListView_AddItem($ListView, $Ext[$i], $i - 1)
	_WinAPI_DestroyIcon($hIcon)
Next

GUISetState()

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case -3, $Button
			ExitLoop
	EndSwitch
WEnd
