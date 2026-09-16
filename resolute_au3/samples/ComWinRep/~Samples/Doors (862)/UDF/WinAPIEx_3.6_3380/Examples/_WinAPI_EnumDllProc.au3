#Include <APIConstants.au3>
#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data, $Lenght

$Data = _WinAPI_EnumDllProc('ntdll.dll', 'Rtl*', $SYMOPT_CASE_INSENSITIVE)

If IsArray($Data) Then
	For $i = 1 To $Data[0][0]
		$Data[$i][0] = '0x' & Hex($Data[$i][0])
	Next
EndIf

_ArrayDisplay($Data, _WinAPI_GetExtended())
