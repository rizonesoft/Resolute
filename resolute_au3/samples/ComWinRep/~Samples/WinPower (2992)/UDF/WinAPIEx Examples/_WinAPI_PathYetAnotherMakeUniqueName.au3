#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

DirCreate('Temp')
For $i = 1 To 4
	FileClose(FileOpen(_WinAPI_PathYetAnotherMakeUniqueName(@ScriptDir & '\Temp\My File.txt'), 2))
Next
ShellExecute(@ScriptDir & '\Temp')
