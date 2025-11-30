#Include <APIConstants.au3>
#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_EnumResourceLanguages(@SystemDir & '\shell32.dll', $RT_DIALOG, 1003)

_ArrayDisplay($Data, '_WinAPI_EnumResourceLanguages')
