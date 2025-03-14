#include <MsgBoxConstants.au3>
#include <WinAPISysWin.au3>

MsgBox($MB_SYSTEMMODAL, "Handle", "Get Foreground Window: " & _WinAPI_GetForegroundWindow())
