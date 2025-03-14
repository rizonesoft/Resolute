#include <WinAPISysWin.au3>

_Example()
Func _Example()
	Run("notepad.exe")
	Local $hWnd = WinWait("[CLASS:Notepad]", "")
	ConsoleWrite("! " & _WinAPI_GetWindowText($hWnd) & @CRLF)
EndFunc   ;==>_Example
