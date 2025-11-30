#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

ConsoleWrite('Internet connected: ' & (_WinAPI_IsNetworkAlive() <> 0) & @CR)
