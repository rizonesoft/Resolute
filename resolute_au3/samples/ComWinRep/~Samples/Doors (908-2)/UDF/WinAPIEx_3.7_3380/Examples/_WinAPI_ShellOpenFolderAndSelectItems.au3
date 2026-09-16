#Include <File.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Path, $List

If @AutoItX64 Then
	$Path = RegRead('HKLM\SOFTWARE\Wow6432Node\AutoIt v3\AutoIt', 'InstallDir')
Else
	$Path = RegRead('HKLM\SOFTWARE\AutoIt v3\AutoIt', 'InstallDir')
EndIf

$List = _FileListToArray($Path, '*.exe', 1)

If IsArray($List) Then
	_WinAPI_ShellOpenFolderAndSelectItems($Path, $List, 1)
EndIf
