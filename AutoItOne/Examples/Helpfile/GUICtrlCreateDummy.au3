#include <GUIConstantsEx.au3>

Example()

Func Example()

	GUICreate("GUICtrlCreateDummy", 250, 200, 100, 200)
	GUISetBkColor(0x00E0FFFF) ; will change background color

	Local $idUser = GUICtrlCreateDummy()
	Local $idButton_Event = GUICtrlCreateButton("event", 75, 170, 70, 20)
	Local $idButton_Cancel = GUICtrlCreateButton("Cancel", 150, 170, 70, 20)
	GUISetState(@SW_SHOW)

	Local $idMsg
	; Loop until the user exits.
	Do
		$idMsg = GUIGetMsg()

		Select
			Case $idMsg = $idButton_Event
				GUICtrlSendToDummy($idUser)
			Case $idMsg = $idButton_Cancel
				GUICtrlSendToDummy($idUser)
			Case $idMsg = $idUser
				; special action before closing
				; ...
				Exit
		EndSelect
	Until $idMsg = $GUI_EVENT_CLOSE
EndFunc   ;==>Example
