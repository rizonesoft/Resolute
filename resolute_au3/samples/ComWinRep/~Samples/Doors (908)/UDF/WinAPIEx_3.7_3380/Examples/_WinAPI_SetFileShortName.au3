#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $sTemp = @TempDir & '\Temporary File.txt'

Global $hToken, $hFile, $aAdjust

; Check NTFS file system
If StringCompare(DriveGetFileSystem(_WinAPI_PathStripToRoot($sTemp)), 'NTFS') Then
	MsgBox(16, 'Error', 'The file must be on an NTFS file system volume.')
	Exit
EndIf

; Enable "SeRestorePrivilege" privilege to perform renaming operation
$hToken = _WinAPI_OpenProcessToken(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
_WinAPI_AdjustTokenPrivileges($hToken, $SE_RESTORE_NAME, $SE_PRIVILEGE_ENABLED, $aAdjust)
If @error Or @extended Then
	MsgBox(16, 'Error', 'You do not have the required privileges.')
	Exit
EndIf

; Create temporary file
FileWrite($sTemp, '')

ConsoleWrite('Old short name: ' & _WinAPI_PathStripPath(FileGetShortName($sTemp)) & @CR)

; Set "TEMP.TXT" short name for the file
$hFile = _WinAPI_CreateFileEx($sTemp, $OPEN_EXISTING, BitOR($GENERIC_WRITE, $DELETE), 0, $FILE_FLAG_BACKUP_SEMANTICS)
_WinAPI_SetFileShortName($hFile, 'TEMP.TXT')
_WinAPI_CloseHandle($hFile)

ConsoleWrite('New short name: ' & _WinAPI_PathStripPath(FileGetShortName($sTemp)) & @CR)

; Delete temporary file
FileDelete($sTemp)

; Restore "SeRestorePrivilege" privilege by default
_WinAPI_AdjustTokenPrivileges($hToken, $aAdjust, 0, $aAdjust)
_WinAPI_CloseHandle($hToken)
