#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	GUICreate("ListView Get/Set Column Width (v" & @AutoItVersion & ")", 400, 300)
	Local $idListview = GUICtrlCreateListView("Column 0|Column 1|Column 2", 2, 2, 394, 268)
	GUISetState(@SW_SHOW)

	_GUICtrlListView_SetColumnWidth($idListview, 0, 100)

	; Change column 0 width
	MsgBox($MB_SYSTEMMODAL, "Information", "Column 0 Width: " & _GUICtrlListView_GetColumnWidth($idListview, 0))
	_GUICtrlListView_SetColumnWidth($idListview, 0, 150)
	MsgBox($MB_SYSTEMMODAL, "Information", "Column 0 Width: " & _GUICtrlListView_GetColumnWidth($idListview, 0))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
