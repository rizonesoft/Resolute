#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $GUID = _WinAPI_GetVolumeNameForVolumeMountPoint(@HomeDrive & '\')
Global $sPath = @ScriptDir & '\Mount\'

DirCreate($sPath)
_WinAPI_SetVolumeMountPoint($sPath, $GUID)
MsgBox(0, '', 'The drive (' & StringUpper(@HomeDrive) & ') has been associated with "' & $sPath & '".')
_WinAPI_DeleteVolumeMountPoint($sPath)
;DirRemove($sPath)
