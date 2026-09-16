#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_GetCurrentHwProfile()

If IsArray($Data) Then
	ConsoleWrite('State: ' & $Data[0] & @CR)
	ConsoleWrite('GUID:  ' & $Data[1] & @CR)
	ConsoleWrite('Name:  ' & $Data[2] & @CR)
EndIf
