#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <GuiTreeView.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>

Example()

Func Example()
	GUICreate("TreeView Get/Set Children (v" & @AutoItVersion & ")", 400, 300)

	Local $iStyle = BitOR($TVS_EDITLABELS, $TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS, $TVS_CHECKBOXES)
	Local $idTreeView = GUICtrlCreateTreeView(2, 2, 396, 268, $iStyle, $WS_EX_CLIENTEDGE)
	GUISetState(@SW_SHOW)

	; Set ANSI format
;~     _GUICtrlListView_SetUnicodeFormat($idListview, False)

	_GUICtrlTreeView_BeginUpdate($idTreeView)
	Local $aidItem[5], $iY = -1
	For $x = 0 To 3
		$aidItem[$x] = GUICtrlCreateTreeViewItem(StringFormat("[%02d] New Item", $x), $idTreeView)
		For $y = 0 To 2
			$iY += 1
			GUICtrlCreateTreeViewItem(StringFormat("[%02d] New Item", $iY), $aidItem[$x])
		Next
	Next
	$aidItem[4] = GUICtrlCreateTreeViewItem(StringFormat("[%02d] New Item", 4), $idTreeView)
	_GUICtrlTreeView_EndUpdate($idTreeView)

	MsgBox($MB_SYSTEMMODAL, "Information", "Item 0 has Children? " & _GUICtrlTreeView_GetChildren($idTreeView, $aidItem[0]))
	MsgBox($MB_SYSTEMMODAL, "Information", "Item 4 has Children? " & _GUICtrlTreeView_GetChildren($idTreeView, $aidItem[4]))

	MsgBox($MB_SYSTEMMODAL, "Set Children", "Item 0 ? " & _GUICtrlTreeView_SetChildren($idTreeView, $aidItem[0]))
	MsgBox($MB_SYSTEMMODAL, "Set Children", "Item 4 ? " & _GUICtrlTreeView_SetChildren($idTreeView, $aidItem[4]))

	MsgBox($MB_SYSTEMMODAL, "Reset Children", "Item 0 ? " & _GUICtrlTreeView_SetChildren($idTreeView, $aidItem[0], False) & @TAB)
	MsgBox($MB_SYSTEMMODAL, "Reset Children", "Item 4 ? " & _GUICtrlTreeView_SetChildren($idTreeView, $aidItem[4], False) & @TAB)

	MsgBox($MB_SYSTEMMODAL, "Information", "Item 0 has Children? " & _GUICtrlTreeView_GetChildren($idTreeView, $aidItem[0]))
	MsgBox($MB_SYSTEMMODAL, "Information", "Item 4 has Children? " & _GUICtrlTreeView_GetChildren($idTreeView, $aidItem[4]))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
