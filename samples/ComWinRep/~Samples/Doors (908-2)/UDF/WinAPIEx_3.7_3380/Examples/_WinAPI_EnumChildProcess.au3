#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_EnumChildProcess(_WinAPI_GetParentProcess())

_ArrayDisplay($Data, '_WinAPI_EnumChildProcess')
