#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $ID = ProcessExists('SciTE.exe')

If $ID > 0 Then
	ConsoleWrite(_WinAPI_GetProcessFileName($ID) & @CR)
EndIf
