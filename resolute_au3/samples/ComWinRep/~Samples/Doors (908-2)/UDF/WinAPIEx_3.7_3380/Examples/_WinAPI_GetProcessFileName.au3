#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $ID = ProcessExists('SciTE.exe')

If $ID Then
	ConsoleWrite(_WinAPI_GetProcessFileName($ID) & @CR)
EndIf
