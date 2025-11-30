#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.0' Then
	MsgBox(16, 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

Global Const $sDll = @ScriptDir & '\Extras\Resources.dll'
Global Const $sDir = @ScriptDir & '\Temporary Folder'

If Not FileExists($sDll) Then
	MsgBox(16, 'Error', $sDll & ' not found.')
	Exit
EndIf

If Not DirCreate($sDir) Then
	MsgBox(16, 'Error', 'Unable to create folder.')
	Exit
EndIf

_WinAPI_ShellOpenFolderAndSelectItems($sDir)
MsgBox(0x00040040, '', 'Press OK to set localized name for "' & _WinAPI_PathStripPath($sDir) & '".')
_WinAPI_ShellSetLocalizedName($sDir, $sDll, 6000)
MsgBox(0x00040040, '', 'Press OK to remove localized name.')
_WinAPI_ShellRemoveLocalizedName($sDir)
MsgBox(0x00040040, '', 'Press OK to exit.')

DirRemove($sDir, 1)
