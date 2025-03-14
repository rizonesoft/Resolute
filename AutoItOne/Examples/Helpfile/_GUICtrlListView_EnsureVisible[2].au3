#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	Local $hGUI = GUICreate("ListView Ensure Visible (v" & @AutoItVersion & ")", 400, 300)
	Local $idListview = _GUICtrlListView_Create($hGUI, "Items", 2, 2, 394, 268)
	_GUICtrlListView_SetColumnWidth($idListview, 0, 100)
	_GUICtrlListView_SetExtendedListViewStyle($idListview, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT))
	GUISetState(@SW_SHOW)

	_GUICtrlListView_BeginUpdate($idListview)
	For $i = 0 To 100
		_GUICtrlListView_AddItem($idListview, "Item " & $i)
	Next
	_GUICtrlListView_EndUpdate($idListview)

	MsgBox($MB_SYSTEMMODAL, "Information", "Making item 50 visible")
	_GUICtrlListView_EnsureVisible($idListview, 50)

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
