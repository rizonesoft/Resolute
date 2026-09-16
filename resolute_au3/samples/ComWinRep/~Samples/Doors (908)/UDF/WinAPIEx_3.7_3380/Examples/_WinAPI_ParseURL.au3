#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_ParseURL('http://www.microsoft.com')

ConsoleWrite('Protocol: ' & $Data[0] & @CR)
ConsoleWrite('Suffix:   ' & $Data[1] & @CR)
ConsoleWrite('Scheme:   ' & $Data[2] & @CR)
