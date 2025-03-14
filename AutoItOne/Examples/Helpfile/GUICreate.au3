#include <GUIConstantsEx.au3>

Example()

Func Example()
	; Create a GUI with various controls.
	Local $hGUI = GUICreate("Example", 400, 400)
	Local $idOK = GUICtrlCreateButton("OK", 310, 370, 85, 25)

	Local $aWindow_Size = WinGetPos($hGUI)
	ConsoleWrite('Window Width  = ' & $aWindow_Size[2] & @CRLF)
	ConsoleWrite('Window Height = ' & $aWindow_Size[3] & @CRLF)
	Local $aWindowClientArea_Size = WinGetClientSize($hGUI)
	ConsoleWrite('Window Client Area Width  = ' & $aWindowClientArea_Size[0] & @CRLF)
	ConsoleWrite('Window Client Area Height = ' & $aWindowClientArea_Size[1] & @CRLF)

	; Display the GUI.
	GUISetState(@SW_SHOW, $hGUI)

	; Loop until the user exits.
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE, $idOK
				ExitLoop

		EndSwitch
	WEnd

	; Delete the previous GUI and all controls.
	GUIDelete($hGUI)
EndFunc   ;==>Example
