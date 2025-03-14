#include <MsgBoxConstants.au3>
#include <WinAPIShellEx.au3>
#include <WinAPIShPath.au3>
#include <WinAPISys.au3>

If Number(_WinAPI_GetVersion()) < 6.0 Then
	MsgBox(($MB_ICONERROR + $MB_SYSTEMMODAL), 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

Local Const $sDll = @ScriptDir & '\Extras\Resources.dll'
Local Const $sDir = @TempDir & '\Temporary Folder'

If Not FileExists($sDll) Then
	MsgBox(($MB_ICONERROR + $MB_SYSTEMMODAL), 'Error', $sDll & ' not found.')
	Exit
EndIf

If Not DirCreate($sDir) Then
	MsgBox(($MB_ICONERROR + $MB_SYSTEMMODAL), 'Error', 'Unable to create folder.')
	Exit
EndIf

_WinAPI_ShellOpenFolderAndSelectItems($sDir)
MsgBox(($MB_ICONINFORMATION + $MB_SYSTEMMODAL), '', 'Press OK to set localized name for "' & _WinAPI_PathStripPath($sDir) & '".')
_WinAPI_ShellSetLocalizedName($sDir, $sDll, 6000)
MsgBox(($MB_ICONINFORMATION + $MB_SYSTEMMODAL), '', 'Press OK to remove localized name.')
_WinAPI_ShellRemoveLocalizedName($sDir)
MsgBox(($MB_ICONINFORMATION + $MB_SYSTEMMODAL), '', 'Press OK to exit.')

DirRemove($sDir, $DIR_REMOVE)
