#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Drive = DriveGetDrive('CDROM')

If IsArray($Drive) Then
	ConsoleWrite('Open...' & @CR)
	_WinAPI_EjectMedia($Drive[1])
	ConsoleWrite('Tray is open: ' & _WinAPI_IsDoorOpen($Drive[1]) & @CR)
	Sleep(1000)
	ConsoleWrite('Close...' & @CR)
	_WinAPI_LoadMedia($Drive[1])
	ConsoleWrite('Tray is open: ' & _WinAPI_IsDoorOpen($Drive[1]) & @CR)
EndIf
