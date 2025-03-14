#include <WinAPIGdi.au3>
#include <WinAPIMisc.au3>

_Example()

Func _Example()
	Local $aPos = _WinAPI_GetPosFromRect(_WinAPI_CreateRectEx(10, 10, 100, 100))

	ConsoleWrite('Left:   ' & $aPos[0] & @CRLF)
	ConsoleWrite('Top:    ' & $aPos[1] & @CRLF)
	ConsoleWrite('Width:  ' & $aPos[2] & @CRLF)
	ConsoleWrite('Height: ' & $aPos[3] & @CRLF)
EndFunc   ;==>_Example
