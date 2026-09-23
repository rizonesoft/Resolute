#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Ext = '.wav'
Global $Data = _WinAPI_AssocGetPerceivedType($Ext)

If IsArray($Data) Then
	ConsoleWrite('(' & $Ext & ')' & @CR)
	ConsoleWrite('--------------------' & @CR)
	ConsoleWrite('Type:   ' & $Data[0] & @CR)
	ConsoleWrite('Source: ' & $Data[1] & @CR)
	ConsoleWrite('String: ' & $Data[2] & @CR)
EndIf
