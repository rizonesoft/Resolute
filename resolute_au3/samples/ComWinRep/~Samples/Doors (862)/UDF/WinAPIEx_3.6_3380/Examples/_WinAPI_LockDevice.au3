#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Drive = DriveGetDrive('CDROM')

If IsArray($Drive) Then
	_WinAPI_LockDevice($Drive[1], 1)
	MsgBox(0, '', 'The drive (' & StringUpper($Drive[1]) & ') is locked.')
	_WinAPI_LockDevice($Drive[1], 0)
	MsgBox(0, '', 'The drive (' & StringUpper($Drive[1]) & ') is unlocked.')
EndIf
