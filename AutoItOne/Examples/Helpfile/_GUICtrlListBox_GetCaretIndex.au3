#include <GUIConstantsEx.au3>
#include <GuiListBox.au3>

Example()

Func Example()
	; Create GUI
	GUICreate("List Box Get/Set Caret Index (v" & @AutoItVersion & ")", 400, 296)
	Local $idListBox = GUICtrlCreateList("", 2, 2, 396, 296)

	GUISetState(@SW_SHOW)

	; Add strings
	_GUICtrlListBox_BeginUpdate($idListBox)
	For $iI = 0 To 9
		_GUICtrlListBox_AddString($idListBox, StringFormat("%03d : Random string", $iI))
	Next
	_GUICtrlListBox_EndUpdate($idListBox)

	; Set caret index
	_GUICtrlListBox_SetCaretIndex($idListBox, 2)

	; Read caret index
	Local $iIndex = _GUICtrlListBox_GetCaretIndex($idListBox)
	_GUICtrlListBox_SetCurSel($idListBox, $iIndex)

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
