#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tDISKGEOMETRYEX, $Drive = 0

While 1
	$tDISKGEOMETRYEX = _WinAPI_GetDriveGeometryEx($Drive)
	If @error Then
		ExitLoop
	EndIf
	ConsoleWrite('-------------------------------' & @CR)
	ConsoleWrite('Drive: ' & $Drive & @CR)
	ConsoleWrite('Cylinders: ' & DllStructGetData($tDISKGEOMETRYEX, 'Cylinders') & @CR)
	ConsoleWrite('Tracks per Cylinder: ' & DllStructGetData($tDISKGEOMETRYEX, 'TracksPerCylinder') & @CR)
	ConsoleWrite('Sectors per Track: ' & DllStructGetData($tDISKGEOMETRYEX, 'SectorsPerTrack') & @CR)
	ConsoleWrite('Bytes per Sector: ' & DllStructGetData($tDISKGEOMETRYEX, 'BytesPerSector') & ' bytes' & @CR)
	ConsoleWrite('Total Space: ' & DllStructGetData($tDISKGEOMETRYEX, 'DiskSize') & ' bytes' & @CR)
	ConsoleWrite('-------------------------------' & @CR)
	$Drive +=1
WEnd
