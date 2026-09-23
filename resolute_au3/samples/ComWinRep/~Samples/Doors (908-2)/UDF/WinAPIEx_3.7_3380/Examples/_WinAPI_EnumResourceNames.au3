#Include <APIConstants.au3>
#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_EnumResourceNames(@SystemDir & '\shell32.dll', $RT_DIALOG)

_ArrayDisplay($Data, '_WinAPI_EnumResourceNames')
