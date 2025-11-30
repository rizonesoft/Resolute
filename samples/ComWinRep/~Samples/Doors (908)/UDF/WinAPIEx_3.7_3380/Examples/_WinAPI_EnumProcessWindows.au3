#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_EnumProcessWindows(0, 0)

_ArrayDisplay($Data, '_WinAPI_EnumProcessWindows')
