#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	Local $aItem, $idListview

	GUICreate("ListView Get/Set Item (v" & @AutoItVersion & ")", 400, 300)

	$idListview = GUICtrlCreateListView("", 2, 2, 394, 268)
	GUISetState(@SW_SHOW)

	; Add column
	_GUICtrlListView_AddColumn($idListview, "Items", 100)

	; Add items
	GUICtrlCreateListViewItem("Row 0", $idListview)
	GUICtrlCreateListViewItem("Row 1", $idListview)
	GUICtrlCreateListViewItem("Row 2", $idListview)

	; Show item 1 text
	$aItem = _GUICtrlListView_GetItem($idListview, 1)
	MsgBox($MB_SYSTEMMODAL, "Information", "Item 1 Text: " & $aItem[3])

	; Change item 1
	MsgBox($MB_SYSTEMMODAL, "Information", "Changing item 1")
	_GUICtrlListView_SetItem($idListview, "New Item 1", 1)

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE

	GUIDelete()
EndFunc   ;==>Example
