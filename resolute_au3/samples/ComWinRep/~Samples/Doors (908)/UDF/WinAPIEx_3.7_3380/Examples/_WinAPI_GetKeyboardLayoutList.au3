#Include <APIConstants.au3>
#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_GetKeyboardLayoutList()

If IsArray($Data) Then
	For $i = 1 To $Data[0]
		$Data[$i] = '0x' & Hex($Data[$i])  & ' (' & _WinAPI_GetLocaleInfo(BitAND($Data[$i], 0xFFFF), $LOCALE_SENGLANGUAGE) & ')'
	Next
EndIf

_ArrayDisplay($Data, '_WinAPI_GetKeyboardLayoutList')
