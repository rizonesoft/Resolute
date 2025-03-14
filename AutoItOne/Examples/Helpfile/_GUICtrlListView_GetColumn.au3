#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	GUICreate("ListView Get Column (v" & @AutoItVersion & ")", 400, 300)
	Local $idListview = GUICtrlCreateListView("col0|col1|col2", 2, 2, 394, 268)
	_GUICtrlListView_SetExtendedListViewStyle($idListview, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_CHECKBOXES))
	_GUICtrlListView_SetColumnWidth($idListview, 0, 100)
	GUISetState(@SW_SHOW)

	; Set ANSI format
;~     _GUICtrlListView_SetUnicodeFormat($idListview, False)

	GUICtrlCreateListViewItem("index 0|data0|more0", $idListview)
	GUICtrlCreateListViewItem("index 1|data1|more1", $idListview)
	GUICtrlCreateListViewItem("index 2|data2|more2", $idListview)
	GUICtrlCreateListViewItem("index 3|data3|more3", $idListview)
	GUICtrlCreateListViewItem("index 4|data4|more4", $idListview)

	; Change column
	Local $aInfo = _GUICtrlListView_GetColumn($idListview, 0)
	MsgBox($MB_SYSTEMMODAL, "Information", "Column 0 Width: " & $aInfo[4])
	_GUICtrlListView_SetColumn($idListview, 0, "New Column 0", 150)
	$aInfo = _GUICtrlListView_GetColumn($idListview, 0)
	MsgBox($MB_SYSTEMMODAL, "Information", "Column 0 Width: " & $aInfo[4])

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE

	GUIDelete()
EndFunc   ;==>Example
