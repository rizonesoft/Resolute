#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hFile = FileOpen(@ScriptFullPath)

ConsoleWrite(@ScriptName & ' in use: ' & _WinAPI_FileInUse(@ScriptFullPath) & @CR)
FileClose($hFile)
ConsoleWrite(@ScriptName & ' in use: ' & _WinAPI_FileInUse(@ScriptFullPath) & @CR)
