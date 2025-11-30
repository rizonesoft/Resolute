#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data

$Data = _WinAPI_EnumResourceTypes(@SystemDir & '\shell32.dll')
_ArrayDisplay($Data, '_WinAPI_EnumResourceTypes')
$Data = _WinAPI_EnumResourceNames(@SystemDir & '\shell32.dll', $RT_DIALOG)
_ArrayDisplay($Data, '_WinAPI_EnumResourceNames')
$Data = _WinAPI_EnumResourceLanguages(@SystemDir & '\shell32.dll', $RT_DIALOG, 1003)
_ArrayDisplay($Data, '_WinAPI_EnumResourceLanguages')
