#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.0' Then
	MsgBox(16, 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

Global $hFile

$hFile = _WinAPI_CreateFile(@ScriptFullPath, 2, 0, 6)

ConsoleWrite(_WinAPI_GetFinalPathNameByHandleEx($hFile) & @CR)
ConsoleWrite(_WinAPI_GetFinalPathNameByHandleEx($hFile, $VOLUME_NAME_GUID) & @CR)
ConsoleWrite(_WinAPI_GetFinalPathNameByHandleEx($hFile, $VOLUME_NAME_NT) & @CR)
ConsoleWrite(_WinAPI_GetFinalPathNameByHandleEx($hFile, $VOLUME_NAME_NONE) & @CR)

_WinAPI_CloseHandle($hFile)
