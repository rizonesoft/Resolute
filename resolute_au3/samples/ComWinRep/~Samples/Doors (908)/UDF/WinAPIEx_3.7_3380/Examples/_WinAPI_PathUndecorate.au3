#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Path[4] = ['C:\Path\File[5].txt', 'C:\Path\File[12]', 'C:\Path\File.txt', 'C:\Path\[3].txt']

For $i = 0 To 3
	ConsoleWrite(StringFormat('%-22s' & _WinAPI_PathUndecorate($Path[$i]), $Path[$i]) & @CR)
Next
