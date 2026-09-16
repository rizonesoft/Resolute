#Include <WinAPIEx.au3>

For $i = 0 To 2
	ConsoleWrite(_WinAPI_PathBuildRoot($i) & @CR)
Next
