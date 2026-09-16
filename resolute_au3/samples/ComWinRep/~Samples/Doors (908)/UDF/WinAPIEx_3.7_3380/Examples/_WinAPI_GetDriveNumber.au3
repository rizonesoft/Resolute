#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data, $Drive = DriveGetDrive('FIXED')
Global $List[10]

For $i = 0 To UBound($Drive) - 1
	$List[$i] = ''
Next
If IsArray($Drive) Then
	For $i = 1 To $Drive[0]
		$Data = _WinAPI_GetDriveNumber($Drive[$i])
		If IsArray($Data) Then
			$List[$Data[1]] &= StringUpper($Drive[$i]) & ' '
		EndIf
	Next
EndIf
For $i = 0 To UBound($Drive) - 1
	If $List[$i] Then
		ConsoleWrite('Drive' & $i & ' => ' & $List[$i] & @CR)
	EndIf
Next
