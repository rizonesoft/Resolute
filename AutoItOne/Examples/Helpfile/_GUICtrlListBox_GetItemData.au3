#include <GUIConstantsEx.au3>
#include <GuiListBox.au3>
#include <MsgBoxConstants.au3>

; Warning this should not be used on items created using built-in functions
; Item data is the controlID for each string

Example()

Func Example()
	; Create GUI
	GUICreate("List Box Get/set Item Data (v" & @AutoItVersion & ")", 400, 296)
	Local $idListBox = GUICtrlCreateList("", 2, 2, 396, 296)
	GUISetState(@SW_SHOW)

	; Add strings
	_GUICtrlListBox_BeginUpdate($idListBox)
	For $iI = 0 To 9
		_GUICtrlListBox_AddString($idListBox, StringFormat("%03d : string", $iI))
	Next
	_GUICtrlListBox_EndUpdate($idListBox)

	; Set item data
	_GUICtrlListBox_SetItemData($idListBox, 4, 1234)

	; Get item data
	MsgBox($MB_SYSTEMMODAL, "Information", "Item 5 Data: " & _GUICtrlListBox_GetItemData($idListBox, 4))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
