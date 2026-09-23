#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_VerQueryValue(@SystemDir & '\shell32.dll')

_ArrayDisplay($Data, '_WinAPI_VerQueryValue')
