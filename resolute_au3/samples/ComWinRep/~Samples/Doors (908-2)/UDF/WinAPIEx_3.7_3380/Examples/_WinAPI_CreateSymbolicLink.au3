#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.0' Then
	MsgBox(16, 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

Global $hToken, $aAdjust

; Enable "SeCreateSymbolicLinkPrivilege" privilege to create a symbolic links
$hToken = _WinAPI_OpenProcessToken(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
_WinAPI_AdjustTokenPrivileges($hToken, $SE_CREATE_SYMBOLIC_LINK_NAME, $SE_PRIVILEGE_ENABLED, $aAdjust)
If @error Or @extended Then
	MsgBox(16, 'Error', 'You do not have the required privileges.')
	Exit
EndIf

; Create symbolic link to the directory where this file is located with prefix "@" on your Desktop
_WinAPI_CreateSymbolicLink(@DesktopDir & '\' & StringRegExpReplace(@ScriptDir, '^.*\\', '@'), @ScriptDir, 1)
If @error Then
	_WinAPI_ShowLastError()
EndIf

; Restore "SeCreateSymbolicLinkPrivilege" privilege by default
_WinAPI_AdjustTokenPrivileges($hToken, $aAdjust, 0, $aAdjust)
_WinAPI_CloseHandle($hToken)
