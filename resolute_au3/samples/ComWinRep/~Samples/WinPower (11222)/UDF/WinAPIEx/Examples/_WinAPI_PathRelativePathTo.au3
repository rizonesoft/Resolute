#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Path = _WinAPI_PathRelativePathTo(@ScriptDir, 1, @MyDocumentsDir, 1)

ConsoleWrite('Relative path: ' & $Path & @CR)

If $Path Then
	ShellExecute($Path)
EndIf
