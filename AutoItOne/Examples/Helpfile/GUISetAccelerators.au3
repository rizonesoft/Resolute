#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	GUICreate("Custom MsgBox", 225, 80)

	GUICtrlCreateLabel("Please select a button.", 10, 10)
	Local $idButton_Yes = GUICtrlCreateButton("Yes", 10, 50, 65, 25)
	Local $idButton_No = GUICtrlCreateButton("No", 80, 50, 65, 25)
	Local $idButton_Exit = GUICtrlCreateButton("Exit", 150, 50, 65, 25)

	; Set GUIAccelerators for the button controlIDs, these being Ctrl + y and Ctrl + n
	Local $aAccelKeys[2][2] = [["^y", $idButton_Yes], ["^n", $idButton_No]]
	GUISetAccelerators($aAccelKeys)

	GUISetState(@SW_SHOW) ; Display the GUI.

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				MsgBox($MB_SYSTEMMODAL, "You selected", "Close")
				ExitLoop

			Case $idButton_Yes
				MsgBox($MB_SYSTEMMODAL, "You selected", "Yes") ; Displays if the button was selected or the hotkey combination Ctrl + y was pressed.

			Case $idButton_No
				MsgBox($MB_SYSTEMMODAL, "You selected", "No") ; Displays if the button was selected or the hotkey combination Ctrl + n was pressed.

			Case $idButton_Exit
				MsgBox($MB_SYSTEMMODAL, "You selected", "Exit")
				ExitLoop

		EndSwitch
	WEnd
	GUIDelete() ; Delete the GUI.
EndFunc   ;==>Example
