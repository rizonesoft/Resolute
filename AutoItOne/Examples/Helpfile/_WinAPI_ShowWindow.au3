#include <WinAPISysWin.au3>

_Example()
Func _Example()
	Run("notepad.exe")
	Local $hWnd = WinWait("[CLASS:Notepad]", "")
	_WinAPI_ShowWindow($hWnd,@SW_HIDE)
	Sleep(1000)
	_WinAPI_ShowWindow($hWnd,@SW_SHOW)
EndFunc   ;==>_Example
