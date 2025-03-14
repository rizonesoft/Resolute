#include <MsgBoxConstants.au3>

Example()

Func Example()
	; Run Notepad
	Run("notepad.exe")

	; Test if the window is activated and display the results.
	If WinActivate("[CLASS:Notepad]", "") Then
		MsgBox($MB_SYSTEMMODAL + $MB_ICONWARNING, "Warning", "Window activated" & @CRLF & @CRLF & "May be your system is pretty fast.")
	Else
		; Notepad will be displayed as MsgBox introduce a delay and allow it.
		MsgBox($MB_SYSTEMMODAL, "", "Window not activated" & @CRLF & @CRLF & "But notepad in background due to MsgBox.", 5)
	EndIf

	; re Test if the window is now activated and display the results.
	If WinActivate("[CLASS:Notepad]", "") Then
		MsgBox($MB_SYSTEMMODAL, "", "Window NOW activated")
	Else
		MsgBox($MB_SYSTEMMODAL + $MB_ICONERROR, "Error", "Window not activated")
	EndIf

	; Close the Notepad window using the handle returned by WinWait.
	WinClose("[CLASS:Notepad]", "")
EndFunc   ;==>Example
