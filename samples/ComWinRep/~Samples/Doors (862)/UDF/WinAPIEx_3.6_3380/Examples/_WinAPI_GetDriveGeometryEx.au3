#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data, $Drive = 0

While 1
	$Data = _WinAPI_GetDriveGeometryEx($Drive)
	If @error Then
		ExitLoop
	EndIf
	If Not $Drive Then
		ConsoleWrite('-------------------------------' & @CR)
	EndIf
	ConsoleWrite('Drive: ' & $Drive & @CR)
	ConsoleWrite('Cylinders: ' & $Data[0] & @CR)
	ConsoleWrite('Tracks per Cylinder: ' & $Data[2] & @CR)
	ConsoleWrite('Sectors per Track: ' & $Data[3] & @CR)
	ConsoleWrite('Bytes per Sector: ' & $Data[4] & @CR)
	ConsoleWrite('Total Space: ' & $Data[5] & ' bytes' & @CR)
	ConsoleWrite('-------------------------------' & @CR)
	$Drive +=1
WEnd
