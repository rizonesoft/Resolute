#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	Local $idListview

	GUICreate("ListView Get/Set Selected Column (v" & @AutoItVersion & ")", 400, 300)
	$idListview = GUICtrlCreateListView("Column 0|Column 1|Column 2", 2, 2, 394, 268)
	GUICtrlCreateListViewItem("line0|data0|more0", $idListview)
	GUICtrlCreateListViewItem("line1|data1|more1", $idListview)
	GUICtrlCreateListViewItem("line2|data2|more2", $idListview)
	GUICtrlCreateListViewItem("line3|data3|more3", $idListview)
	GUICtrlCreateListViewItem("line4|data4|more4", $idListview)
	GUISetState(@SW_SHOW)

	; Select column 1
	_GUICtrlListView_SetSelectedColumn($idListview, 1)
	MsgBox($MB_SYSTEMMODAL, "Information", "Selected Column: " & _GUICtrlListView_GetSelectedColumn($idListview))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
