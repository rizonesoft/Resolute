#include <WinAPIConv.au3>
#include <WinAPISys.au3>

ConsoleWrite(_WinAPI_StrFromTimeInterval(_WinAPI_GetTickCount()) & @CRLF)
