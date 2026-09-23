#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hFile

$hFile = _WinAPI_CreateFile(@ScriptFullPath, 2, 0, 6)

ConsoleWrite('Handle: ' & $hFile & @CR)
ConsoleWrite('ID:     ' & _WinAPI_GetFileID($hFile) & @CR)

_WinAPI_CloseHandle($hFile)
