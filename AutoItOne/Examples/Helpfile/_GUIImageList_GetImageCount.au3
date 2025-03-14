#include <GUIConstantsEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>

Example()

Func Example()
	GUICreate("ImageList Get/Set Image Count (v" & @AutoItVersion & ")", 400, 300)
	Local $idListview = GUICtrlCreateListView("", 2, 2, 394, 268, BitOR($LVS_SHOWSELALWAYS, $LVS_NOSORTHEADER, $LVS_REPORT))

	Local $iStylesEx = BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_SUBITEMIMAGES)
	_GUICtrlListView_SetExtendedListViewStyle($idListview, $iStylesEx)
	GUISetState(@SW_SHOW)

	; Load images
	Local $hImage = _GUIImageList_Create(16, 16, 5, 3)
	_GUIImageList_AddIcon($hImage, @SystemDir & "\shell32.dll", 110)
	_GUIImageList_AddIcon($hImage, @SystemDir & "\shell32.dll", 131)
	_GUIImageList_AddIcon($hImage, @SystemDir & "\shell32.dll", 165)
	_GUIImageList_AddIcon($hImage, @SystemDir & "\shell32.dll", 168)
	_GUIImageList_AddIcon($hImage, @SystemDir & "\shell32.dll", 137)
	_GUIImageList_AddIcon($hImage, @SystemDir & "\shell32.dll", 146)
	_GUICtrlListView_SetImageList($idListview, $hImage, 1)

	; Add columns
	_GUICtrlListView_AddColumn($idListview, "Column 0", 100)
	_GUICtrlListView_AddColumn($idListview, "Column 1", 120)
	_GUICtrlListView_AddColumn($idListview, "Column 2", 100)

	; Add items
	_GUICtrlListView_AddItem($idListview, "Row 0: Col 0", 0)
	_GUICtrlListView_AddSubItem($idListview, 0, "Row 0: Col 1", 1, 1)
	_GUICtrlListView_AddSubItem($idListview, 0, "Row 0: Col 2", 2, 2)
	_GUICtrlListView_AddItem($idListview, "Row 1: Col 0", 1)
	_GUICtrlListView_AddSubItem($idListview, 1, "Row 1: Col 1", 1, 2)
	_GUICtrlListView_AddItem($idListview, "Row 2: Col 0", 2)
	_GUICtrlListView_AddItem($idListview, "Row 3: Col 0", 3)
	_GUICtrlListView_AddItem($idListview, "Row 4: Col 0", 4)
	_GUICtrlListView_AddSubItem($idListview, 4, "Row 4: Col 1", 1, 3)
	_GUICtrlListView_AddItem($idListview, "Row 5: Col 0", 5)
	_GUICtrlListView_AddSubItem($idListview, 5, "Row 5: Col 1", 1, 4)
	_GUICtrlListView_AddSubItem($idListview, 5, "Row 5: Col 2", 2, 3)

	MsgBox($MB_SYSTEMMODAL, "Information", "Image Count: " & _GUIImageList_GetImageCount($hImage))

	GUISetState(@SW_LOCK)
	MsgBox($MB_SYSTEMMODAL, "Information", "Setting Image Count")
	_GUIImageList_SetImageCount($hImage, 3)
	GUISetState(@SW_UNLOCK)

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
