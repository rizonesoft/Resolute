#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_ParseUserName('ALX\Alexander')

ConsoleWrite('Domain: ' & $Data[0] & @CR)
ConsoleWrite('User:   ' & $Data[1] & @CR)
