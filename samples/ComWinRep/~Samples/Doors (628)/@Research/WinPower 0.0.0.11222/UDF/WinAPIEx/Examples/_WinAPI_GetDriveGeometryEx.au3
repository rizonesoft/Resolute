#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tDISK_GEOMETRY_EX, $Drive = 0

While 1
	$tDISK_GEOMETRY_EX = _WinAPI_GetDriveGeometryEx($Drive)
	If @error Then
		ExitLoop
	EndIf
	ConsoleWrite('-------------------------------' & @CR)
	ConsoleWrite('Drive: ' & $Drive & @CR)
	ConsoleWrite('Cylinders: ' & DllStructGetData($tDISK_GEOMETRY_EX, 'Cylinders') & @CR)
	ConsoleWrite('Tracks per Cylinder: ' & DllStructGetData($tDISK_GEOMETRY_EX, 'TracksPerCylinder') & @CR)
	ConsoleWrite('Sectors per Track: ' & DllStructGetData($tDISK_GEOMETRY_EX, 'SectorsPerTrack') & @CR)
	ConsoleWrite('Bytes per Sector: ' & DllStructGetData($tDISK_GEOMETRY_EX, 'BytesPerSector') & ' bytes' & @CR)
	ConsoleWrite('Total Space: ' & DllStructGetData($tDISK_GEOMETRY_EX, 'DiskSize') & ' bytes' & @CR)
	ConsoleWrite('-------------------------------' & @CR)
	$Drive +=1
WEnd
