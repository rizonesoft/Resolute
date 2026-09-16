#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Result = _WinAPI_MessageBoxCheck(64, 'MyProg', '_WinAPI_MessageBoxCheck()', 'MyProg')

ConsoleWrite('Return: ' & $Result & @CR)
