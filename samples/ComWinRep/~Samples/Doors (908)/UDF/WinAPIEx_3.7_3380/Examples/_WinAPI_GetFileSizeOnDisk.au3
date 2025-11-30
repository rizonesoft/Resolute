#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $sFile = @ScriptFullPath

ConsoleWrite('Localtion:    ' & $sFile & @CR)
ConsoleWrite('Size:         ' & FileGetSize($sFile) & @CR)
ConsoleWrite('Size on disk: ' & _WinAPI_GetFileSizeOnDisk($sFile) & @CR)
