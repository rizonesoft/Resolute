#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $sFile = @ScriptFullPath

Global $aAdjust, $aPrivileges[2] = [$SE_BACKUP_NAME, $SE_RESTORE_NAME]
Global $Bytes = 4096 + FileGetSize($sFile)
Global $hFile, $pBuffer, $pContext

; Enable "SeBackupPrivilege" and "SeRestorePrivilege" privileges to perform backup and restore operation
$hToken = _WinAPI_OpenProcessToken(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
_WinAPI_AdjustTokenPrivileges($hToken, $aPrivileges, $SE_PRIVILEGE_ENABLED, $aAdjust)
If @error Or @extended Then
	MsgBox(16, 'Error', 'You do not have the required privileges.')
	Exit
EndIf

; Create a memory buffer where to store the backup data
$pBuffer = _WinAPI_CreateBuffer($Bytes)

; Back up a file, including the security information
$pContext = 0
$hFile = _WinAPI_CreateFileEx($sFile, $OPEN_EXISTING, $GENERIC_READ)
_WinAPI_BackupRead($hFile, $pBuffer, $Bytes, $Bytes, $pContext, 1)
If @error Then
	MsgBox(16, 'Error', 'Unable to back up a file.')
	Exit
EndIf
_WinAPI_BackupReadAbort($pContext)
_WinAPI_CloseHandle($hFile)

; Restore a file (.bak) and the ACL data
$pContext = 0
$hFile = _WinAPI_CreateFileEx(_WinAPI_PathRenameExtension($sFile, '.bak'), $CREATE_ALWAYS, BitOR($GENERIC_WRITE, $WRITE_DAC, $WRITE_OWNER))
_WinAPI_BackupWrite($hFile, $pBuffer, $Bytes, $Bytes, $pContext, 1)
If @error Then
	MsgBox(16, 'Error', 'Unable to restore a file.')
	Exit
EndIf
_WinAPI_BackupWriteAbort($pContext)
_WinAPI_CloseHandle($hFile)

; Free the used memory
_WinAPI_FreeMemory($pBuffer)

; Restore "SeBackupPrivilege" and "SeRestorePrivilege" privileges by default
_WinAPI_AdjustTokenPrivileges($hToken, $aAdjust, 0, $aAdjust)
_WinAPI_CloseHandle($hToken)
