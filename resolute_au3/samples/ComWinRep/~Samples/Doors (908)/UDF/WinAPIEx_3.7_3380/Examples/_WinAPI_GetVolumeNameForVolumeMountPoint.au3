#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $sPath = @ScriptDir & '\Mount'
Global $GUID, $Count = 0

While FileExists($sPath & $Count)
	$Count += 1
WEnd

$sPath &= $Count & '\'

If Not DirCreate($sPath) Then
	MsgBox(16, 'Error', 'Unable to create folder.')
	Exit
EndIf

$GUID = _WinAPI_GetVolumeNameForVolumeMountPoint(@HomeDrive & '\')
If _WinAPI_SetVolumeMountPoint($sPath, $GUID) Then
	MsgBox(64, '', 'The drive "' & StringUpper(@HomeDrive) & '" has been associated with "' & $sPath & '".' & @CR & @CR & 'Press OK to unmount folder.')
	_WinAPI_DeleteVolumeMountPoint($sPath)
Else
	MsgBox(16, 'Error', 'Unable to mount folder.')
EndIf

DirRemove($sPath)
