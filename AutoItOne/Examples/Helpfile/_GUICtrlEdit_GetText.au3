#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	; Create GUI
	GUICreate("Edit Get/Set Text (v" & @AutoItVersion & ")", 400, 300)
	Local $idEdit = GUICtrlCreateEdit("", 2, 2, 394, 268)
	GUISetState(@SW_SHOW)

	; Set Text
	_GUICtrlEdit_SetText($idEdit, "This is a test" & @CRLF & "Another Line" & @CRLF & "Append to the end?")

	; Get Text
	MsgBox($MB_SYSTEMMODAL, "Information", _GUICtrlEdit_GetText($idEdit))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
