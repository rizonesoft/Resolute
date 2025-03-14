#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	GUICreate("ListView Get/Set Item Param (v" & @AutoItVersion & ")", 400, 300)
	Local $idListView = GUICtrlCreateListView("", 2, 2, 394, 268)
	GUISetState(@SW_SHOW)

	; Add columns
	_GUICtrlListView_AddColumn($idListView, "Items", 100)

	; Add items
	_GUICtrlListView_AddItem($idListView, "Item 0")
	_GUICtrlListView_AddItem($idListView, "Item 1")
	_GUICtrlListView_AddItem($idListView, "Item 2")

	; Set item 1 parameter
	_GUICtrlListView_SetItemParam($idListView, 1, 1234)
	MsgBox($MB_SYSTEMMODAL, "Information", "Item 1 Parameter: " & _GUICtrlListView_GetItemParam($idListView, 1))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
