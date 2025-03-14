#include <APIRegConstants.au3>
#include <Debug.au3>
#include <WinAPIError.au3>
#include <WinAPIHObj.au3>
#include <WinAPIProc.au3>
#include <WinAPIReg.au3>

#RequireAdmin

_DebugSetup(Default, True)

Example()

Func Example()
	Local $aPrivileges[2] = [$SE_BACKUP_NAME, $SE_RESTORE_NAME]

	; Enable "SeBackupPrivilege" and "SeRestorePrivilege" privileges to save and restore registry hive
	Local $hToken = _WinAPI_OpenProcessToken(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
	Local $aAdjust
	_WinAPI_AdjustTokenPrivileges($hToken, $aPrivileges, $SE_PRIVILEGE_ENABLED, $aAdjust)
	If @error Or @extended Then
		_DebugReport('Error' & @TAB & 'You do not have the required privileges.' & @CRLF)
		Exit
	EndIf

	; Save "HKEY_CURRENT_USER\Software\AutoIt v3" to reg.dat
	Local $hKey = _WinAPI_RegOpenKey($HKEY_CURRENT_USER, 'Software\AutoIt v3', $KEY_READ)
	If _WinAPI_RegSaveKey($hKey, @TempDir & '\reg.dat', 1) Then
		_DebugReport('- "HKEY_CURRENT_USER\Software\AutoIt v3" has been saved to reg.dat.' & @CRLF)
	Else
		_DebugReport("! RegSaveKey @error =" & @error & @TAB & _WinAPI_GetErrorMessage(@extended) & @CRLF)
	EndIf
	_WinAPI_RegCloseKey($hKey)

	; Restore "HKEY_CURRENT_USER\Software\AutoIt v3" to "HKEY_CURRENT_USER\Software\AutoIt v3 (Duplicate)"
	$hKey = _WinAPI_RegCreateKey($HKEY_CURRENT_USER, 'Software\AutoIt v3 (Duplicate)', $KEY_WRITE)
	If _WinAPI_RegRestoreKey($hKey, @TempDir & '\reg.dat') Then
		_DebugReport('- "HKEY_CURRENT_USER\Software\AutoIt v3" has been restored to "HKEY_CURRENT_USER\Software\AutoIt v3 (Duplicate)".' & @CRLF)
	Else
		_DebugReport("! RegRestoreKey @error =" & @error & @TAB & _WinAPI_GetErrorMessage(@extended) & @CRLF)
	EndIf
	_WinAPI_RegCloseKey($hKey)

	; Restore "SeBackupPrivilege" and "SeRestorePrivilege" privileges by default
	_WinAPI_AdjustTokenPrivileges($hToken, $aAdjust, 0, $aAdjust)
	_WinAPI_CloseHandle($hToken)

	FileDelete(@TempDir & '\reg.dat')

EndFunc   ;==>Example
