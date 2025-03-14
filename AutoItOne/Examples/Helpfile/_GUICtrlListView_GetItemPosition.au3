#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	GUICreate("ListView Get Item Position (v" & @AutoItVersion & ")", 400, 300)
	Local $idListview = GUICtrlCreateListView("", 2, 2, 394, 268)
	GUISetState(@SW_SHOW)

	; Set ANSI format
;~     _GUICtrlListView_SetUnicodeFormat($idListview, False)

	; Add columns
	_GUICtrlListView_AddColumn($idListview, "Items", 100)

	; Add items
	_GUICtrlListView_AddItem($idListview, "Item 0")
	_GUICtrlListView_AddItem($idListview, "Item 1")
	_GUICtrlListView_AddItem($idListview, "Item 2")

	; Get item 1 position
	Local $aPos = _GUICtrlListView_GetItemPosition($idListview, 1)
	MsgBox($MB_SYSTEMMODAL, "Information", StringFormat("Item 1 Position : [%d, %d]", $aPos[0], $aPos[1]))

	; Set icon view
	_GUICtrlListView_SetView($idListview, 3)
	MsgBox($MB_SYSTEMMODAL, "Information", "Moving item 1")
	_GUICtrlListView_SetItemPosition($idListview, 1, 100, 100)

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
