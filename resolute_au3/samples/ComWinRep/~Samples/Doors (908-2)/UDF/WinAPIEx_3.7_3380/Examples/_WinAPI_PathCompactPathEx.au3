#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Path = @ScriptFullPath

ConsoleWrite('Before: ' & $Path & @CR)
ConsoleWrite('After : ' & _WinAPI_PathCompactPathEx($Path, 40) & @CR)
