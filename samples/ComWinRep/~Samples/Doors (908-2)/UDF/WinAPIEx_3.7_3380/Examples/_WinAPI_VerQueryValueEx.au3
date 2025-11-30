#Include <APIConstants.au3>
#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_VerQueryValueEx(@ScriptDir & '\Extras\Resources.dll', 'FileDescription|FileVersion|OriginalFilename', -1)

If IsArray($Data) Then
	For $i = 1 To $Data[0][0]
		$Data[$i][0] = _WinAPI_GetLocaleInfo($Data[$i][0], $LOCALE_SLANGUAGE)
	Next
EndIf

_ArrayDisplay($Data, '_WinAPI_VerQueryValueEx')
