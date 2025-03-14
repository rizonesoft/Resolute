#include <WinAPISys.au3>

Local $Hwnd = _WinAPI_GetCapture()
MsgBox(0, "Mouse capture Handle", $Hwnd)
