#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If Not @Compiled Then
	MsgBox(0, '', 'To run this script, you must first compile it and then run the (.exe) file.')
	Exit
EndIf

Global $hSemaphore = _WinAPI_CreateSemaphore('MySemaphore', 2, 2)

_WinAPI_WaitForSingleObject($hSemaphore)
_MyGUI()
_WinAPI_ReleaseSemaphore($hSemaphore)
_WinAPI_CloseHandle($hSemaphore)

Func _MyGUI()

	Local $Msg

	GUICreate('MyGUI')
	GUISetState()
	While 1
		$Msg = GUIGetMsg()
		Switch $Msg
			Case -3
				ExitLoop
		EndSwitch
	WEnd
EndFunc   ;==>_MyGUI
