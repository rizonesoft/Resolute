#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Drive = DriveGetDrive('ALL')

If IsArray($Drive) Then
	For $i = 1 To $Drive[0]
		ConsoleWrite(StringUpper($Drive[$i]) & ' => ' & _WinAPI_QueryDosDevice($Drive[$i]) & @CR)
	Next
EndIf
