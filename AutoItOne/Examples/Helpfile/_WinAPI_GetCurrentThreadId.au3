#include <MsgBoxConstants.au3>
#include <WinAPIProc.au3>

MsgBox($MB_SYSTEMMODAL, "ID", "Get Current Thread: " & _WinAPI_GetCurrentThreadId())
