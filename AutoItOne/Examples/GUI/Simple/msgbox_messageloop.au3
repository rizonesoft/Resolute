; A simple custom messagebox that uses the MessageLoop mode

#include <Constants.au3>
#include <GUIConstantsEx.au3>

_Main()
Exit

Func _Main()
	GUICreate("Custom MsgBox", 210, 80)

	GUICtrlCreateLabel("Please click a button!", 10, 10)
	Local $idButton_Yes = GUICtrlCreateButton("Yes", 10, 50, 50, 20)
	Local $idButton_No = GUICtrlCreateButton("No", 80, 50, 50, 20)
	Local $idButton_Exit = GUICtrlCreateButton("Exit", 150, 50, 50, 20)

	GUISetState() ; display the GUI

	Local $iMsg
	Do
		$iMsg = GUIGetMsg()

		Select
			Case $iMsg = $idButton_Yes
				MsgBox($MB_SYSTEMMODAL, "You clicked on", "Yes")
			Case $iMsg = $idButton_No
				MsgBox($MB_SYSTEMMODAL, "You clicked on", "No")
			Case $iMsg = $idButton_Exit
				MsgBox($MB_SYSTEMMODAL, "You clicked on", "Exit")
			Case $iMsg = $GUI_EVENT_CLOSE
				MsgBox($MB_SYSTEMMODAL, "You clicked on", "Close")
		EndSelect
	Until $iMsg = $GUI_EVENT_CLOSE Or $iMsg = $idButton_Exit
EndFunc   ;==>_Main
