#include <GUIConstantsEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	GUICreate("ListView Get/Set Item Group ID (v" & @AutoItVersion & ")", 400, 300)
	Local $idListview = GUICtrlCreateListView("", 2, 2, 394, 268)
	GUISetState(@SW_SHOW)

	; Set ANSI format
;~     _GUICtrlListView_SetUnicodeFormat($idListview, False)

	; Load images
	Local $hImage = _GUIImageList_Create()
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($idListview, 0xFF0000, 16, 16))
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($idListview, 0x00FF00, 16, 16))
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($idListview, 0x0000FF, 16, 16))
	_GUICtrlListView_SetImageList($idListview, $hImage, 1)

	; Add columns
	_GUICtrlListView_AddColumn($idListview, "Column 0", 100)
	_GUICtrlListView_AddColumn($idListview, "Column 1", 100)
	_GUICtrlListView_AddColumn($idListview, "Column 2", 100)

	; Add items
	_GUICtrlListView_AddItem($idListview, "Row 0: Col 0", 0)
	_GUICtrlListView_AddSubItem($idListview, 0, "Row 0: Col 1", 1)
	_GUICtrlListView_AddSubItem($idListview, 0, "Row 0: Col 2", 2)
	_GUICtrlListView_AddItem($idListview, "Row 1: Col 0", 1)
	_GUICtrlListView_AddSubItem($idListview, 1, "Row 1: Col 1", 1)
	_GUICtrlListView_AddItem($idListview, "Row 2: Col 0", 2)

	; Build groups
	_GUICtrlListView_EnableGroupView($idListview)
	_GUICtrlListView_InsertGroup($idListview, -1, 1, "Group 1")
	_GUICtrlListView_InsertGroup($idListview, -1, 2, "Group 2")
	_GUICtrlListView_SetItemGroupID($idListview, 0, 1)
	_GUICtrlListView_SetItemGroupID($idListview, 1, 2)
	_GUICtrlListView_SetItemGroupID($idListview, 2, 2)

	; Display Item 3 group ID
	MsgBox($MB_SYSTEMMODAL, "Information", "Item 3 Group ID: " & _GUICtrlListView_GetItemGroupID($idListview, 2))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
