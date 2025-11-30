#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $PID = _WinAPI_GetParentProcess()
Global $Data = _WinAPI_EnumChildProcess($PID)

ConsoleWrite(_WinAPI_GetCurrentProcessID() & ' - ' & _WinAPI_GetProcessName() & @CR)
ConsoleWrite($PID & ' - ' & _WinAPI_GetProcessName($PID) & @CR)

_ArrayDisplay($Data, '_WinAPI_EnumChildProcess')
