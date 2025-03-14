#include <GUIConstantsEx.au3>

Example()

Func Example()
	; Create a GUI with various controls.
	Local $hGUI = GUICreate("Example", 300, 200)

	; Create a button control.
	Local $idButton_Notepad = GUICtrlCreateButton("Run Notepad", 120, 170, 85, 25)
	Local $idButton_Close = GUICtrlCreateButton("Close", 210, 170, 85, 25)

	; Display the GUI.
	GUISetState(@SW_SHOW, $hGUI)

	Local $iPID = 0

	; Loop until the user exits.
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE, $idButton_Close
				ExitLoop

			Case $idButton_Notepad
				; Run Notepad with the window maximized.
				$iPID = Run("notepad.exe", "", @SW_SHOWMAXIMIZED)

		EndSwitch
	WEnd

	; Delete the previous GUI and all controls.
	GUIDelete($hGUI)

	; Close the Notepad process using the PID returned by Run.
	If $iPID Then ProcessClose($iPID)
EndFunc   ;==>Example
