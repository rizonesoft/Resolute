#include <GUIConstantsEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	Local $iStylesEx = BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_SUBITEMIMAGES)

	GUICreate("ListView Get/Set Item Image (v" & @AutoItVersion & ")", 400, 300)
	Local $idListview = GUICtrlCreateListView("", 2, 2, 394, 268)
	_GUICtrlListView_SetExtendedListViewStyle($idListview, $iStylesEx)
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
	_GUICtrlListView_AddSubItem($idListview, 0, "Row 0: Col 1", 1, 1)
	_GUICtrlListView_AddSubItem($idListview, 0, "Row 0: Col 2", 2, 2)
	_GUICtrlListView_AddItem($idListview, "Row 1: Col 0", 1)
	_GUICtrlListView_AddSubItem($idListview, 1, "Row 1: Col 1", 1, 2)
	_GUICtrlListView_AddItem($idListview, "Row 2: Col 0", 2)

	; Set item 1, subitem 1 image
	_GUICtrlListView_SetItemImage($idListview, 1, 1, 1)
	MsgBox($MB_SYSTEMMODAL, "Information", "Item 1, SubItem 1 Image: " & _GUICtrlListView_GetItemImage($idListview, 1, 1))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
