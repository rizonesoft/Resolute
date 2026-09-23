#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Result = _WinAPI_MessageBoxCheck($MB_ICONINFORMATION, 'MyProg', '_WinAPI_MessageBoxCheck()', 'MyProg')

ConsoleWrite('Return: ' & $Result & @CR)
