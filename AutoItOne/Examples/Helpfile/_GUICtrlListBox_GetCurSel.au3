#include <GUIConstantsEx.au3>
#include <GuiListBox.au3>
#include <WinAPIError.au3>

Example()

Func Example()
	; Create GUI
	GUICreate("List Box Get/Set Cur Sel (v" & @AutoItVersion & ")", 400, 296)
	Local $idListBox = GUICtrlCreateList("", 2, 2, 396, 296)
	GUISetState(@SW_SHOW)

	; Add strings
	_GUICtrlListBox_BeginUpdate($idListBox)
	For $iI = 0 To 9
		_GUICtrlListBox_AddString($idListBox, StringFormat("%03d : Random string", $iI))
	Next
	_GUICtrlListBox_EndUpdate($idListBox)

	; Select an item
	_GUICtrlListBox_SetCurSel($idListBox, 4)

	; Get currently selected item
	_WinAPI_ShowMsg("Current selection: " & _GUICtrlListBox_GetCurSel($idListBox))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
