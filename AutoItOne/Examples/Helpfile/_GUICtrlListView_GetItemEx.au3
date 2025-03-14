#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	GUICreate("ListView Get/Set Item Ex (v" & @AutoItVersion & ")S", 400, 300)
	Local $idListview = GUICtrlCreateListView("", 2, 2, 394, 268)
	GUISetState(@SW_SHOW)

	; Set ANSI format
;~     _GUICtrlListView_SetUnicodeFormat($idListview, False)

	; Add columns
	_GUICtrlListView_AddColumn($idListview, "Items", 100)

	; Add items
	GUICtrlCreateListViewItem("Item 0", $idListview)
	GUICtrlCreateListViewItem("Item 1", $idListview)
	GUICtrlCreateListViewItem("Item 2", $idListview)

	; Show item 1 raw state
	Local $tItem = DllStructCreate($tagLVITEM)
	DllStructSetData($tItem, "Mask", $LVIF_STATE)
	DllStructSetData($tItem, "Item", 1)
	DllStructSetData($tItem, "StateMask", -1)
	_GUICtrlListView_GetItemEx($idListview, $tItem)
	MsgBox($MB_SYSTEMMODAL, "Information", "Item 1 State: " & DllStructGetData($tItem, "State"))

	; Change item 1
	MsgBox($MB_SYSTEMMODAL, "Information", "Changing item 1")
	Local $tText
	If _GUICtrlListView_GetUnicodeFormat($idListview) Then
		$tText = DllStructCreate("wchar Text[11]")
	Else
		$tText = DllStructCreate("char Text[11]")
	EndIf
	$tItem = DllStructCreate($tagLVITEM)
	DllStructSetData($tText, "Text", "New Item 1")
	DllStructSetData($tItem, "Mask", $LVIF_TEXT)
	DllStructSetData($tItem, "Item", 1)
	DllStructSetData($tItem, "Text", DllStructGetPtr($tText))
	_GUICtrlListView_SetItemEx($idListview, $tItem)

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
