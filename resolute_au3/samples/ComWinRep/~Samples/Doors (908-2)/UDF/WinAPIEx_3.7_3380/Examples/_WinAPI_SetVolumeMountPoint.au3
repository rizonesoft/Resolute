#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $sPath = @ScriptDir & '\Mount\'

Global $GUID = _WinAPI_GetVolumeNameForVolumeMountPoint(@HomeDrive & '\')

DirCreate($sPath)
_WinAPI_SetVolumeMountPoint($sPath, $GUID)
MsgBox(0, '', 'The drive (' & StringUpper(@HomeDrive) & ') has been associated with "' & $sPath & '".')
_WinAPI_DeleteVolumeMountPoint($sPath)
;DirRemove($sPath)
