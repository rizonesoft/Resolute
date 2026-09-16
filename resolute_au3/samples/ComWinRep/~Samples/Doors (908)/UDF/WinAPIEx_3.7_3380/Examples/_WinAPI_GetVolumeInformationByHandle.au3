#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.0' Then
	MsgBox(16, 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

Global $hFile, $aInfo

$hFile = _WinAPI_CreateFile(@ScriptFullPath, 2, 0, 6)
$aInfo = _WinAPI_GetVolumeInformationByHandle($hFile)
_WinAPI_CloseHandle($hFile)

ConsoleWrite('Volume name: ' & $aInfo[0] & @CR)
ConsoleWrite('File system: ' & $aInfo[4] & @CR)
ConsoleWrite('Serial number: ' & $aInfo[1] & @CR)
ConsoleWrite('File name length: ' & $aInfo[2] & @CR)
ConsoleWrite('Flags: 0x' & Hex($aInfo[3]) & @CR)
