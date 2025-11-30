#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hFile, $aInfo

$hFile = _WinAPI_CreateFile(@ScriptFullPath, 2, 0, 6)
If @error Then
	Exit
EndIf

$aInfo = _WinAPI_GetObjectInfoByHandle($hFile)
If IsArray($aInfo) Then
	ConsoleWrite('Handle:     ' & $hFile & @CR)
	ConsoleWrite('Attributes: 0x' & Hex($aInfo[0]) & @CR)
	ConsoleWrite('Access:     0x' & Hex($aInfo[1]) & @CR)
	ConsoleWrite('Handles:    ' & $aInfo[2] & @CR)
	ConsoleWrite('Pointers:   ' & $aInfo[3] & @CR)
EndIf

_WinAPI_CloseHandle($hFile)
