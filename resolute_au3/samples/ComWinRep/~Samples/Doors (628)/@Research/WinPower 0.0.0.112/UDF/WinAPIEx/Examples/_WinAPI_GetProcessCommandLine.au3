#RequireAdmin

#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hToken, $aList = 0

; Enable SeDebugPrivilege privilege for obtain full access rights to another processes
$hToken = _WinAPI_OpenProcessToken(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
_WinAPI_AdjustTokenPrivileges($hToken, $SE_DEBUG_NAME, 1)

; Retrieve command-line arguments for all processes the system
If Not (@error Or @extended) Then
	$aList = ProcessList()
	For $i = 1 To $aList[0][0]
		$aList[$i][1] = _WinAPI_GetProcessCommandLine($aList[$i][1])
	Next
EndIf

; Enable SeDebugPrivilege privilege by default
_WinAPI_AdjustTokenPrivileges($hToken, $SE_DEBUG_NAME, 2)
_WinAPI_CloseHandle($hToken)

If IsArray($aList) Then
	_ArrayDisplay($aList, '_WinAPI_GetProcessCommandLine')
EndIf
