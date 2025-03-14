#include <WinAPIMisc.au3>
#include <WinAPIRes.au3>

_Example()

Func _Example()
	_WinAPI_ClipCursor(_WinAPI_CreateRectEx(0, 0, 400, 400))
	Sleep(5000)
	_WinAPI_ClipCursor(0)
EndFunc   ;==>_Example
