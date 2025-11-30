#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hFile

$hFile = _WinAPI_CreateFile(@ScriptFullPath, 2, 0, 6)

ConsoleWrite('Handle: ' & $hFile & @CR)
ConsoleWrite('Type:   ' & _WinAPI_GetObjectNameByHandle($hFile) & @CR)

_WinAPI_CloseHandle($hFile)
