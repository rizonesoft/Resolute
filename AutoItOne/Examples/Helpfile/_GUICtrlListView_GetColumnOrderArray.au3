#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	GUICreate("ListView Get/Set Column Order Array (v" & @AutoItVersion & ")", 400, 300)
	Local $idListview = GUICtrlCreateListView("Column 0|Column 1|Column 2|Column 3", 2, 2, 394, 268)
	GUISetState(@SW_SHOW)

	; Set ANSI format
;~     _GUICtrlListView_SetUnicodeFormat($idListview, False)

	Local $a_Order[5] = [4, 3, 2, 0, 1]
	; Set column order
	MsgBox($MB_SYSTEMMODAL, "Information", "Changing column order")
	_GUICtrlListView_SetColumnOrderArray($idListview, $a_Order)

	; Show column order
	$a_Order = _GUICtrlListView_GetColumnOrderArray($idListview)
	MsgBox($MB_SYSTEMMODAL, "Information", StringFormat("Column order: [%d, %d, %d, %d]", $a_Order[1], $a_Order[2], $a_Order[3], $a_Order[4]))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE

	GUIDelete()
EndFunc   ;==>Example
