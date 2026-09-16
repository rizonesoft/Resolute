#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_EnumFiles(@SystemDir, 1, '*.ax;*.cpl;*.dll;*.drv;*.exe;*.ocx;*.scr')

_ArrayDisplay($Data, '_WinAPI_EnumFiles')
