#include <WinAPIFiles.au3>
#include <WinAPIHObj.au3>

Local $hFile = _WinAPI_CreateFile(@ScriptFullPath, 2, 0, 6)

ConsoleWrite(_WinAPI_GetFinalPathNameByHandle($hFile) & @CRLF)

_WinAPI_CloseHandle($hFile)
