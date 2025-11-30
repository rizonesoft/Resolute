#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

For $i = 0 To 2
	ConsoleWrite(_WinAPI_PathBuildRoot($i) & @CR)
Next
