#Include <APIConstants.au3>
#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_EnumSystemGeoID()

If IsArray($Data) Then
	For $i = 1 To $Data[0]
		$Data[$i] = _WinAPI_GetGeoInfo($Data[$i], $GEO_FRIENDLYNAME)
	Next
EndIf

_ArrayDisplay($Data, '_WinAPI_EnumSystemGeoID')
