#include <GUIConstantsEx.au3>
#include <GuiListView.au3>

Example()

Func Example()
	Local $idListview

	GUICreate("ListView Get/Set Item Count (v" & @AutoItVersion & ")", 400, 300)
	$idListview = GUICtrlCreateListView("", 2, 2, 394, 268)
	GUISetState(@SW_SHOW)

	; Add columns
	_GUICtrlListView_AddColumn($idListview, "Items", 100)

	; Add items
	_GUICtrlListView_SetItemCount($idListview, 100)
	_GUICtrlListView_BeginUpdate($idListview)
	For $x = 0 To 4
		GUICtrlCreateListViewItem("Item " & $x, $idListview)
	Next
	_GUICtrlListView_EndUpdate($idListview)

	MsgBox($MB_SYSTEMMODAL, "Information", "Item Count: " & _GUICtrlListView_GetItemCount($idListview))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
