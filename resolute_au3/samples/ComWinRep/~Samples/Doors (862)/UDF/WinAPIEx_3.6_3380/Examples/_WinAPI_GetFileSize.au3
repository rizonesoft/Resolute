#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Local $hFile

$hFile = _WinAPI_CreateFile(@ScriptFullPath, 2, 2, 6)

ConsoleWrite(_WinAPI_GetFileSize($hFile) & ' bytes' & @CR)

_WinAPI_CloseHandle($hFile)
