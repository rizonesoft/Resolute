#include <GUIConstantsEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>

Global $g_idMemo

Example()

Func Example()
	Local $hGUI = GUICreate("(UDF Created) ListView Create Drag Image (v" & @AutoItVersion & ")", 500, 300)

	Local $hListView = _GUICtrlListView_Create($hGUI, "", 2, 2, 494, 118)
	$g_idMemo = GUICtrlCreateEdit("", 2, 124, 496, 174, 0)
	GUISetState(@SW_SHOW)

	; Set ANSI format
;~     _GUICtrlListView_SetUnicodeFormat($hListView, False)

	; Load images
	Local $hImage = _GUIImageList_Create()
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($hListView, 0xFF0000, 16, 16))
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($hListView, 0x00FF00, 16, 16))
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($hListView, 0x0000FF, 16, 16))
	_GUICtrlListView_SetImageList($hListView, $hImage, 1)

	; Add columns
	_GUICtrlListView_InsertColumn($hListView, 0, "Column 1", 100)
	_GUICtrlListView_InsertColumn($hListView, 1, "Column 2", 100)
	_GUICtrlListView_InsertColumn($hListView, 2, "Column 3", 100)

	; Add items
	_GUICtrlListView_AddItem($hListView, "Red", 0)
	_GUICtrlListView_AddItem($hListView, "Green", 1)
	_GUICtrlListView_AddItem($hListView, "Blue", 2)

	; Create drag image
	Local $aDrag = _GUICtrlListView_CreateDragImage($hListView, 0)
	_GUICtrlListView_DrawDragImage($hListView, $aDrag)

	MemoWrite("Drag Image Handle = 0x" & Hex($aDrag[0]) & " IsPtr = " & IsPtr($aDrag[0]) & " IsHWnd = " & IsHWnd($aDrag[0]))

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_MOUSEMOVE
				_GUICtrlListView_DrawDragImage($hListView, $aDrag)
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	; Destory image list
	_GUIImageList_Destroy($aDrag[0])

	GUIDelete()
EndFunc   ;==>Example

; Write a line to the memo control
Func MemoWrite($sMessage)
	GUICtrlSetData($g_idMemo, $sMessage & @CRLF, 1)
EndFunc   ;==>MemoWrite
