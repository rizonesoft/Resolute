#Region Header

#cs

	Title:          Memory Management UDF Library for AutoIt3
    Filename:       MemManage.au3.au3
    Description:    Memory Management
    Author:         Derick Payne (Rizone Technologies)
    Version:        3.3 / 3.3.6.1

Available functions:

    _WinAPI_AdjustTokenPrivileges
	_WinAPI_EmptyWorkingSet
	_WinAPI_LookupPrivilegeValue
	_WinAPI_OpenProcessToken

#ce

#include-once

#Include <WinAPI.au3>

#EndRegion Header


Global Const $tagLUID = 'dword LowPart;long HighPart;'


; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AdjustTokenPrivileges
; Description....: Enables or disables privileges in the specified access token.
; Syntax.........: _WinAPI_AdjustTokenPrivileges ( $hToken, $aPrivileges, $iState )
; Parameters.....: $hToken      - Handle to the access token that contains the privileges to be modified. The handle must have
;                                 $TOKEN_ADJUST_PRIVILEGES and $TOKEN_QUERY accesses to the token.
;                  $aPrivileges - The variable that specifies a privileges. If this parameter is (-1), the function disables of the token's
;                                 privileges and ignores the $iState parameter. $aPrivileges can be one of the following types.
;
;                                 Single privileges constants ($SE_*).
;                                 1D array of $SE_* constants.
;                                 2D array of $SE_* constants and their attributes (see $iState).
;
;                                 [0][0] - Privilege
;                                 [0][1] - Attribute
;                                 [n][0] - Privilege
;                                 [n][1] - Attribute
;
;                  $iState      - The privilege attribute. If $aPrivileges parameter is 1D array, $iState applied to the entire
;                                 array. If $aPrivileges parameter is (-1) or 2D array, the function ignores this parameter and will
;                                 use the attributes specified in the array. This parameter can be one of the following values.
;
;                                 0 - The privilege is disabled.
;                                 1 - The privilege is enabled.
;                                 2 - The privilege is enabled by default.
;
; Return values..: Success      - If $aPrivileges is a single $SE_* constant, returns a previous privilege attribute (0 or 1),
;                                 otherwise always returns 1. To determine whether the function adjusted all of the specified privileges,
;                                 check @extended flag, which returns one of the following values when the function succeeds:
;
;                                 0 - The function adjusted all specified privileges.
;                                 1 - The token does not have one or more of the privileges specified in the $aPrivileges parameter.
;
;                  Failure      - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function cannot add new privileges to the access token. It can only enable or disable the token's
;                  existing privileges.
; Related........:
; Link...........: @@MsdnLink@@ AdjustTokenPrivileges
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_AdjustTokenPrivileges($hToken, $aPrivileges, $iState)

	Switch $iState
		Case 0

		Case 1
			$iState = 2
		Case 2
			$iState = 1
		Case Else
			Return SetError(1, 0, 0)
	EndSwitch

	Local $tLUID, $tPrivileges = 0, $tPrev = 0, $iPrivileges = $aPrivileges, $Disable = 0, $Error, $Result = 1
	Local $Struct = 'dword;dword;long;dword'

	If $aPrivileges = -1 Then
		$Disable = 1
	Else
		If Not IsArray($aPrivileges) Then
			Dim $aPrivileges[1][2] = [[$iPrivileges, $iState]]
			$tPrev = DllStructCreate($Struct)
			If @error Then
				Return SetError(1, 0, 0)
			EndIf
		Else
			If Not UBound($aPrivileges, 2) Then
				Dim $aPrivileges[UBound($iPrivileges)][2]
				For $i = 0 To UBound($iPrivileges) - 1
					$aPrivileges[$i][0] = $iPrivileges[$i]
					$aPrivileges[$i][1] = $iState
				Next
			EndIf
		EndIf
		For $i = 1 To UBound($aPrivileges) - 1
			$Struct &= ';dword;long;dword'
		Next
		$tPrivileges = DllStructCreate($Struct)
		If @error Then
			Return SetError(1, 0, 0)
		EndIf
		DllStructSetData($tPrivileges, 1, UBound($aPrivileges))
		For $i = 0 To UBound($aPrivileges) - 1
			$tLUID = _WinAPI_LookupPrivilegeValue($aPrivileges[$i][0])
			If @error Then
				Return SetError(1, 0, 0)
			EndIf
			DllStructSetData($tPrivileges, 3 * $i + 2, DllStructGetData($tLUID, 1))
			DllStructSetData($tPrivileges, 3 * $i + 3, DllStructGetData($tLUID, 2))
			DllStructSetData($tPrivileges, 3 * $i + 4, $aPrivileges[$i][1])
		Next
	EndIf

	Local $Ret = DllCall('advapi32.dll', 'int', 'AdjustTokenPrivileges', 'ptr', $hToken, 'int', $Disable, 'ptr', DllStructGetPtr($tPrivileges), 'dword', DllStructGetSize($tPrev), 'ptr', DllStructGetPtr($tPrev), 'dword*', 0)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	If IsDllStruct($tPrev) Then
		$Result = DllStructGetData($tPrev, 4)
	EndIf
	Switch _WinAPI_GetLastError()
		Case 1300 ; ERROR_NOT_ALL_ASSIGNED
			$Error = 1
		Case Else
			$Error = 0
	EndSwitch
	Return SetError(0, $Error, $Result)
EndFunc   ;==>_WinAPI_AdjustTokenPrivileges


; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EmptyWorkingSet
; Description....: Removes as many pages as possible from the working set of the specified process.
; Syntax.........: _WinAPI_EmptyWorkingSet ( [$PID] )
; Parameters.....: $PID    - The PID of the process. Default (0) is the current process.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; ===============================================================================================================================

Func _WinAPI_EmptyWorkingSet($PID = 0)

	If Not $PID Then
		$PID = _WinAPI_GetCurrentProcessID()
		If Not $PID Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf

	Local $hProcess = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'dword', 0x001F0FFF, 'int', 0, 'dword', $PID)

	If (@error) Or (Not $hProcess[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Ret = DllCall(@SystemDir & '\psapi.dll', 'int', 'EmptyWorkingSet', 'ptr', $hProcess[0])

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hProcess[0])
	If Not IsArray($Ret) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1

EndFunc   ;==>_WinAPI_EmptyWorkingSet


; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LookupPrivilegeValue
; Description....: Retrieves the locally unique identifier (LUID) to locally represent the specified privilege name.
; Syntax.........: _WinAPI_LookupPrivilegeValue ( $sPrivilege )
; Parameters.....: $sPrivilege - The string that specifies the name of the privilege ($SE_*).
; Return values..: Success     - $tagLUID structure that contains the LUID.
;                  Failure     - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ LookupPrivilegeValue
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LookupPrivilegeValue($sPrivilege)

	Local $tLUID = DllStructCreate($tagLUID)
	Local $Ret = DllCall('advapi32.dll', 'int', 'LookupPrivilegeValueW', 'ptr', 0, 'wstr', $sPrivilege, 'ptr', DllStructGetPtr($tLUID))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tLUID
EndFunc   ;==>_WinAPI_LookupPrivilegeValue


; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_OpenProcessToken
; Description....: Opens the access token associated with a process.
; Syntax.........: _WinAPI_OpenProcessToken ( $iAccess [, $hProcess] )
; Parameters.....: $iAccess  - Access mask that specifies the requested types of access to the access token. This parameter can be
;                              one or more of the following values.
;
;                              $TOKEN_ADJUST_DEFAULT
;                              $TOKEN_ADJUST_GROUPS
;                              $TOKEN_ADJUST_PRIVILEGES
;                              $TOKEN_ADJUST_SESSIONID
;                              $TOKEN_ASSIGN_PRIMARY
;                              $TOKEN_DUPLICATE
;                              $TOKEN_EXECUTE
;                              $TOKEN_IMPERSONATE
;                              $TOKEN_QUERY
;                              $TOKEN_QUERY_SOURCE
;                              $TOKEN_READ
;                              $TOKEN_WRITE
;                              $TOKEN_ALL_ACCESS
;
;                  $hProcess - Handle to the process whose access token is opened. The process must have the
;                              $PROCESS_QUERY_INFORMATION access permission. If this parameter is 0, will use the current process.
; Return values..: Success   - Handle that identifies the newly opened access token.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Close the access token handle returned through this function by calling _WinAPI_CloseHandle().
; Related........:
; Link...........: @@MsdnLink@@ OpenProcessToken
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_OpenProcessToken($iAccess, $hProcess = 0)

	If Not $hProcess Then
		$hProcess = _WinAPI_GetCurrentProcess()
	EndIf

	Local $Ret = DllCall('advapi32.dll', 'int', 'OpenProcessToken', 'ptr', $hProcess, 'dword', $iAccess, 'ptr*', 0)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[3]
EndFunc   ;==>_WinAPI_OpenProcessToken