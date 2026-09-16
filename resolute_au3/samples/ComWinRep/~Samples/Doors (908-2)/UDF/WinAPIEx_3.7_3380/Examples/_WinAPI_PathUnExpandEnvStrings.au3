#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Path = @MyDocumentsDir

ConsoleWrite('Before: ' & $Path & @CR)
ConsoleWrite('After : ' & _WinAPI_PathUnExpandEnvStrings($Path) & @CR)
