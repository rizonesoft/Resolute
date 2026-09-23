#Include <APIConstants.au3>
#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $sFile = @DesktopDir & '\' & StringRegExpReplace(_WinAPI_PathFindFileName(@ScriptName), '\A_+', '@')

Global $aData

; Create hard link to the current file with prefix "@" on your Desktop
_WinAPI_CreateHardLink($sFile, @ScriptFullPath)
If @error Then
	MsgBox(16, 'Error', 'Unable to create hard link.')
	Exit
EndIf

; Enumerate all hard links to the file
$aData = _WinAPI_EnumHardLinks($sFile)

_ArrayDisplay($aData, '_WinAPI_EnumHardLinks')

FileDelete($sFile)
