#Include <File.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $sPath = RegRead('HKLM\SOFTWARE\AutoIt v3\AutoIt', 'InstallDir')
Global $aList = _FileListToArray($sPath, '*.exe', 1)

If IsArray($aList) Then
	_WinAPI_ShellOpenFolderAndSelectItems($sPath, $aList, 1)
EndIf
