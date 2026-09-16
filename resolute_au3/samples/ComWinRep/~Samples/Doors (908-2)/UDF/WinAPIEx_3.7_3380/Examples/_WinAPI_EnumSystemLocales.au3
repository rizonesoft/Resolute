#Include <APIConstants.au3>
#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_EnumSystemLocales($LCID_INSTALLED)

_ArrayDisplay($Data, '_WinAPI_EnumSystemLocales')
