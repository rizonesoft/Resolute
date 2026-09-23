#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $List[10], $Drive = DriveGetDrive('FIXED')
Global $tSTORAGE_DEVICE_NUMBER

For $i = 0 To UBound($Drive) - 1
	$List[$i] = ''
Next
If IsArray($Drive) Then
	For $i = 1 To $Drive[0]
		$tSTORAGE_DEVICE_NUMBER = _WinAPI_GetDriveNumber($Drive[$i])
		If Not @error Then
			$List[DllStructGetData($tSTORAGE_DEVICE_NUMBER, 'DeviceNumber')] &= StringUpper($Drive[$i]) & ' '
		EndIf
	Next
EndIf
For $i = 0 To UBound($Drive) - 1
	If $List[$i] > '' Then
		ConsoleWrite('Drive' & $i & ' => ' & $List[$i] & @CR)
	EndIf
Next
