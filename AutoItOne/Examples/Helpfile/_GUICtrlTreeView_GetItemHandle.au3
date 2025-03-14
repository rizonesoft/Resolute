#AutoIt3Wrapper_UseX64=y
#include <GUIConstantsEx.au3>
#include <GuiTreeView.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>

Example()

Func Example()
	GUICreate("TreeView Get Item Handle (v" & @AutoItVersion & ")", 400, 300)

	Local $iStyle = BitOR($TVS_EDITLABELS, $TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS, $TVS_CHECKBOXES)
	Local $idTreeView = GUICtrlCreateTreeView(2, 2, 396, 268, $iStyle, $WS_EX_CLIENTEDGE)
	Local $vTreeview = $idTreeView
;~ 	$vTreeview = GUICtrlGetHandle($idTreeView) ; to work with Handle's
	GUISetState(@SW_SHOW)

	; Set ANSI format
;~     _GUICtrlTreeView_SetUnicodeFormat($vTreeview, False)

	_GUICtrlTreeView_BeginUpdate($vTreeview)
	Local $ahItem[10], $ahItemChild[30], $iYIndex = 0
	For $x = 0 To 9
		$ahItem[$x] = _GUICtrlTreeView_Add($vTreeview, 0, StringFormat("[%02d] New Item", $x))
		For $y = $iYIndex To $iYIndex + 2
			$ahItemChild[$y] = _GUICtrlTreeView_AddChild($vTreeview, $ahItem[$x], StringFormat("[%02d] New Child Item", $y))
		Next
		$iYIndex += 3
	Next
	_GUICtrlTreeView_EndUpdate($vTreeview)

	Local $iRand = Random(0, 9, 1)
	MsgBox($MB_SYSTEMMODAL, "Information", StringFormat("Item handle for index %d: %s\r\nIsPtr = %d IsHWnd = %d", $iRand, _GUICtrlTreeView_GetItemHandle($vTreeview, $ahItem[$iRand]), _
			IsPtr(_GUICtrlTreeView_GetItemHandle($vTreeview, $ahItem[$iRand])), IsHWnd(_GUICtrlTreeView_GetItemHandle($vTreeview, $ahItem[$iRand]))))
	$iRand = Random(0, 29, 1)
	MsgBox($MB_SYSTEMMODAL, "Information", StringFormat("Item handle for child index %d: %s", $iRand, _GUICtrlTreeView_GetItemHandle($vTreeview, $ahItemChild[$iRand])))
	_GUICtrlTreeView_SelectItem($vTreeview, $ahItemChild[$iRand])
	Sleep(1000)
	MsgBox($MB_SYSTEMMODAL, "Information", StringFormat("Item handle for Root index: %s", _GUICtrlTreeView_GetItemHandle($vTreeview, Null)))
	_GUICtrlTreeView_SelectItem($vTreeview, Null)

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
