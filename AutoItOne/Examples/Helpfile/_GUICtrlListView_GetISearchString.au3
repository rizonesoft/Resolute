#include <GUIConstantsEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	GUICreate("ListView Get ISearch (v" & @AutoItVersion & ")", 400, 300)

	Local $idListview = GUICtrlCreateListView("", 2, 2, 394, 268)
	GUICtrlSetStyle($idListview, $LVS_ICON)
	GUISetState(@SW_SHOW)

	; Set ANSI format
;~     _GUICtrlListView_SetUnicodeFormat($idListview, False)

	; Load images
	Local $hImage = _GUIImageList_Create()
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($idListview, 0xFF0000, 16, 16))
	_GUICtrlListView_SetImageList($idListview, $hImage, 0)

	_GUICtrlListView_BeginUpdate($idListview)
	For $x = 1 To 10
		_GUICtrlListView_InsertItem($idListview, "Item " & $x, -1, 0)
	Next
	_GUICtrlListView_EndUpdate($idListview)

	Send("Item 2")

	; Get incremental search string
	MsgBox($MB_SYSTEMMODAL, "Information", "Incremental Search String: " & _GUICtrlListView_GetISearchString($idListview))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE

	GUIDelete()
EndFunc   ;==>Example
