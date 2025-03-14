#include <MsgBoxConstants.au3>

Example()

Func Example()
	; Run Notepad
	Run("notepad.exe")

	; Wait for 2 seconds to display the Notepad window.
	Sleep(2000)

	; Close the Notepad window using the classname of Notepad.
	If WinClose("[CLASS:Notepad]", "") Then
		MsgBox($MB_SYSTEMMODAL, "", "Window closed")
	Else
		MsgBox($MB_SYSTEMMODAL + $MB_ICONERROR, "Error", "Window not Found")
	EndIf
EndFunc   ;==>Example
