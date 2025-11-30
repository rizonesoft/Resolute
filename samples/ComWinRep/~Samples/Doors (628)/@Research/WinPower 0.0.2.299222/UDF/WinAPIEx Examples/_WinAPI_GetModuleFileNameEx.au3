#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Id = ProcessExists('SciTE.exe')

If $Id > 0 Then
	ConsoleWrite(_WinAPI_GetModuleFileNameEx($Id) & @CR)
EndIf
