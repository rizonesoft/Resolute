#Include <WinAPIEx.au3>

ConsoleWrite('Internet connected: ' & (_WinAPI_IsNetworkAlive() <> 0) & @CR)
