#include-once

#include "APIRegConstants.au3"
#include "StringConstants.au3"
#include "StructureConstants.au3"
#include "WinAPICom.au3"
#include "WinAPIError.au3"
#include "WinAPIMem.au3"

; #INDEX# =======================================================================================================================
; Title .........: WinAPI Extended UDF Library for AutoIt3
; AutoIt Version : 3.3.16.1
; Description ...: Additional variables, constants and functions for the WinAPIReg.au3
; Author(s) .....: Yashied, jpm
; ===============================================================================================================================

#Region Global Variables and Constants

; #VARIABLES# ===================================================================================================================
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $REG_ERROR_MORE_DATA = 234 ; More data is available.
; ===============================================================================================================================
#EndRegion Global Variables and Constants

#Region Functions list

; #CURRENT# =====================================================================================================================
; _WinAPI_AddMRUString
; _WinAPI_AssocGetPerceivedType
; _WinAPI_AssocQueryString
; _WinAPI_CreateMRUList
; _WinAPI_DllInstall
; _WinAPI_DllUninstall
; _WinAPI_EnumMRUList
; _WinAPI_FreeMRUList
; _WinAPI_GetRegKeyNameByHandle
; _WinAPI_RegCloseKey
; _WinAPI_RegConnectRegistry
; _WinAPI_RegCopyTree
; _WinAPI_RegCopyTreeEx
; _WinAPI_RegCreateKey
; _WinAPI_RegDeleteEmptyKey
; _WinAPI_RegDeleteKey
; _WinAPI_RegDeleteKeyValue
; _WinAPI_RegDeleteTree
; _WinAPI_RegDeleteTreeEx
; _WinAPI_RegDeleteValue
; _WinAPI_RegDisableReflectionKey
; _WinAPI_RegDuplicateHKey
; _WinAPI_RegEnableReflectionKey
; _WinAPI_RegEnumKey
; _WinAPI_RegEnumValue
; _WinAPI_RegFlushKey
; _WinAPI_RegLoadMUIString
; _WinAPI_RegNotifyChangeKeyValue
; _WinAPI_RegOpenKey
; _WinAPI_RegQueryInfoKey
; _WinAPI_RegQueryLastWriteTime
; _WinAPI_RegQueryMultipleValues
; _WinAPI_RegQueryReflectionKey
; _WinAPI_RegQueryValue
; _WinAPI_RegRestoreKey
; _WinAPI_RegSaveKey
; _WinAPI_RegSetValue
; _WinAPI_SfcIsKeyProtected
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; __WinAPI_RegConvHKey
; ===============================================================================================================================
#EndRegion Functions list

#Region Public Functions

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: JPM
; ===============================================================================================================================
Func _WinAPI_AddMRUString($hMRU, $sStr)
	Local $aCall = DllCall('comctl32.dll', 'int', 'AddMRUStringW', 'handle', $hMRU, 'wstr', $sStr)
	If @error Then Return SetError(@error, @extended, -1)
	; If $aCall[0] = -1 Then Return SetError(1000, 0, 0)

	Return $aCall[0]
EndFunc   ;==>_WinAPI_AddMRUString

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_AssocGetPerceivedType($sExt)
	Local $aCall = DllCall('shlwapi.dll', 'long', 'AssocGetPerceivedType', 'wstr', $sExt, 'int*', 0, 'dword*', 0, 'ptr*', 0)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Local $aRet[3]
	$aRet[0] = $aCall[2]
	$aRet[1] = $aCall[3]
	$aRet[2] = _WinAPI_GetString($aCall[4])
	_WinAPI_CoTaskMemFree($aCall[4])
	Return $aRet
EndFunc   ;==>_WinAPI_AssocGetPerceivedType

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_AssocQueryString($sAssoc, $iType, $iFlags = 0, $sExtra = '')
	If Not StringStripWS($sExtra, $STR_STRIPLEADING + $STR_STRIPTRAILING) Then $sExtra = Null

	Local $aCall = DllCall('shlwapi.dll', 'long', 'AssocQueryStringW', 'dword', $iFlags, 'dword', $iType, 'wstr', $sAssoc, _
			'wstr', $sExtra, 'wstr', '', 'dword*', 4096)
	If @error Then Return SetError(@error, @extended, '')
	If $aCall[0] Then Return SetError(10, $aCall[0], '')

	Return $aCall[5]
EndFunc   ;==>_WinAPI_AssocQueryString

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: Jpm
; ===============================================================================================================================
Func _WinAPI_CreateMRUList($hKey, $sSubKey, $iMax = 26)
	Local Const $tagMRUINFO = 'dword Size;uint Max;uint Flags;handle hKey;ptr szSubKey;ptr fnCompare'
	Local $tMRUINFO = DllStructCreate($tagMRUINFO & ';wchar[' & (StringLen($sSubKey) + 1) & ']')
	DllStructSetData($tMRUINFO, 1, DllStructGetPtr($tMRUINFO, 7) - DllStructGetPtr($tMRUINFO))
	DllStructSetData($tMRUINFO, 2, $iMax)
	DllStructSetData($tMRUINFO, 3, 0)
	DllStructSetData($tMRUINFO, 4, $hKey)
	DllStructSetData($tMRUINFO, 5, DllStructGetPtr($tMRUINFO, 7))
	DllStructSetData($tMRUINFO, 6, 0)
	DllStructSetData($tMRUINFO, 7, $sSubKey)

	Local $aCall = DllCall('comctl32.dll', 'HANDLE', 'CreateMRUListW', 'struct*', $tMRUINFO)
	If @error Then Return SetError(@error, @extended, 0)
	; If Not $aCall[0] Then Return SetError(1000, 0, 0)

	Return $aCall[0]
EndFunc   ;==>_WinAPI_CreateMRUList

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: Jpm
; ===============================================================================================================================
Func _WinAPI_DllInstall($sFilePath)
	Local $iRet = RunWait(@SystemDir & '\regsvr32.exe /s ' & $sFilePath)
	If @error Or $iRet Then Return SetError(@error + ($iRet + 100), @extended, 0)

	Return 1
EndFunc   ;==>_WinAPI_DllInstall

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: Jpm
; ===============================================================================================================================
Func _WinAPI_DllUninstall($sFilePath)
	Local $iRet = RunWait(@SystemDir & '\regsvr32.exe /s /u ' & $sFilePath)
	If @error Or $iRet Then Return SetError(@error + ($iRet + 100), @extended, 0)

	Return 1
EndFunc   ;==>_WinAPI_DllUninstall

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_EnumMRUList($hMRU, $iItem)
	Local $aCall = DllCall('comctl32.dll', 'int', 'EnumMRUListW', 'handle', $hMRU, 'int', $iItem, 'wstr', '', 'uint', 4096)
	If @error Or ($aCall[0] = -1) Then Return SetError(@error + 10, @extended, 0)

	If $iItem < 0 Then
		Return $aCall[0]
	Else
		If Not $aCall[0] Then Return SetError(1, 0, 0)
	EndIf

	Return $aCall[3]
EndFunc   ;==>_WinAPI_EnumMRUList

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: Jpm
; ===============================================================================================================================
Func _WinAPI_FreeMRUList($hMRU)
	Local $aCall = DllCall('comctl32.dll', 'int', 'FreeMRUList', 'handle', $hMRU)
	If @error Then Return SetError(@error, @extended, False)
	; If $aCall[0] = -1 Then Return SetError(1000, 0, 0)

	Return ($aCall[0] <> -1)
EndFunc   ;==>_WinAPI_FreeMRUList

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_GetRegKeyNameByHandle($hKey)
	Local $tagKEY_NAME_INFORMATION = 'ulong NameLength;wchar Name[4096]'
	Local $tKNI = DllStructCreate($tagKEY_NAME_INFORMATION)
	Local $aCall = DllCall('ntdll.dll', 'long', 'ZwQueryKey', 'handle', $hKey, 'uint', 3, 'struct*', $tKNI, _
			'ulong', DllStructGetSize($tKNI), 'ulong*', 0)
	If @error Then Return SetError(@error, @extended, '')
	If $aCall[0] Then Return SetError(10, $aCall[0], '')
	Local $iLength = DllStructGetData($tKNI, 1)
	If Not $iLength Then Return SetError(12, 0, '')

	Return DllStructGetData(DllStructCreate('wchar[' & ($iLength / 2) & ']', DllStructGetPtr($tKNI, 2)), 1)
EndFunc   ;==>_WinAPI_GetRegKeyNameByHandle

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegCloseKey($hKey, $bFlush = False)
	If $bFlush Then
		If Not _WinAPI_RegFlushKey($hKey) Then
			Return SetError(@error + 10, @extended, 0)
		EndIf
	EndIf

	Local $aCall = DllCall('advapi32.dll', 'long', 'RegCloseKey', 'handle', $hKey)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return 1
EndFunc   ;==>_WinAPI_RegCloseKey

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegConnectRegistry($sComputer, $hKey)
	Local $aCall = DllCall('advapi32.dll', 'long', 'RegConnectRegistryW', 'wstr', $sComputer, 'handle', $hKey, 'handle*', 0)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return $aCall[3]
EndFunc   ;==>_WinAPI_RegConnectRegistry

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegCopyTree($hSrcKey, $sSrcSubKey, $hDestKey)
	Local $aCall = DllCall('shlwapi.dll', 'long', 'SHCopyKeyW', 'handle', $hSrcKey, 'wstr', $sSrcSubKey, 'ulong_ptr', $hDestKey, _
			'dword', 0)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return 1
EndFunc   ;==>_WinAPI_RegCopyTree

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegCopyTreeEx($hSrcKey, $sSrcSubKey, $hDestKey)
	Local $aCall = DllCall('advapi32.dll', 'long', 'RegCopyTreeW', 'handle', $hSrcKey, 'wstr', $sSrcSubKey, 'ulong_ptr', $hDestKey)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return 1
EndFunc   ;==>_WinAPI_RegCopyTreeEx

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegCreateKey($vKey, $sSubKey = '', $iAccess = $KEY_ALL_ACCESS, $iOptions = 0, $tSecurity = 0)
	$vKey = __WinAPI_RegConvHKey($vKey, $sSubKey)
	If @error Then Return SetError(@error + 10, @extended, 0)

	Local $aCall = DllCall('advapi32.dll', 'long', 'RegCreateKeyExW', 'handle', $vKey, 'wstr', $sSubKey, 'dword', 0, 'ptr', 0, _
			'dword', $iOptions, 'dword', $iAccess, 'struct*', $tSecurity, 'ulong_ptr*', 0, 'dword*', 0)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return SetExtended(Number($aCall[9] = 1), $aCall[8])
EndFunc   ;==>_WinAPI_RegCreateKey

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegDeleteEmptyKey($hKey, $sSubKey = '')
	Local $aCall = DllCall('shlwapi.dll', 'long', 'SHDeleteEmptyKeyW', 'handle', $hKey, 'wstr', $sSubKey)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return 1
EndFunc   ;==>_WinAPI_RegDeleteEmptyKey

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegDeleteKey($vKey, $sSubKey = '', $iSamDesired = Default)
	If $iSamDesired = Default Then
		If @AutoItX64 Then
			$iSamDesired = $KEY_WOW64_64KEY
		Else
			$iSamDesired = $KEY_WOW64_32KEY
		EndIf
	EndIf

	$vKey = __WinAPI_RegConvHKey($vKey, $sSubKey)
	If @error Then Return SetError(@error + 10, @extended, 0)

	Local $aCall = DllCall('advapi32.dll', 'long', 'RegDeleteKeyExW', 'handle', $vKey, 'wstr', $sSubKey, 'dword', $iSamDesired, 'dword', 0)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], _WinAPI_GetLastError())

	Return 1
EndFunc   ;==>_WinAPI_RegDeleteKey

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegDeleteKeyValue($hKey, $sSubKey, $sValueName)
	Local $aCall = DllCall('advapi32.dll', 'long', 'RegDeleteKeyValueW', 'handle', $hKey, 'wstr', $sSubKey, 'wstr', $sValueName)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return 1
EndFunc   ;==>_WinAPI_RegDeleteKeyValue

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegDeleteTree($hKey, $sSubKey = '')
	Local $aCall = DllCall('shlwapi.dll', 'long', 'SHDeleteKeyW', 'ulong_ptr', $hKey, 'wstr', $sSubKey)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return 1
EndFunc   ;==>_WinAPI_RegDeleteTree

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: JPM
; ===============================================================================================================================
Func _WinAPI_RegDeleteTreeEx($hKey, $sSubKey = 0)
	Local $sSubKeyType = 'wstr'
	If Not IsString($sSubKey) Then $sSubKeyType = 'ptr'

	Local $aCall = DllCall('advapi32.dll', 'long', 'RegDeleteTreeW', 'handle', $hKey, $sSubKeyType, $sSubKey)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return 1
EndFunc   ;==>_WinAPI_RegDeleteTreeEx

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegDeleteValue($hKey, $sValueName)
	Local $aCall = DllCall('advapi32.dll', 'long', 'RegDeleteValueW', 'handle', $hKey, 'wstr', $sValueName)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return 1
EndFunc   ;==>_WinAPI_RegDeleteValue

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegDisableReflectionKey($hKey)
	Local $aCall = DllCall('advapi32.dll', 'long', 'RegDisableReflectionKey', 'handle', $hKey)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return 1
EndFunc   ;==>_WinAPI_RegDisableReflectionKey

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegDuplicateHKey($hKey)
	Local $aCall = DllCall('shlwapi.dll', 'handle', 'SHRegDuplicateHKey', 'handle', $hKey)
	If @error Then Return SetError(@error, @extended, 0)

	Return $aCall[0]
EndFunc   ;==>_WinAPI_RegDuplicateHKey

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegEnableReflectionKey($hKey)
	Local $aCall = DllCall('advapi32.dll', 'long', 'RegEnableReflectionKey', 'handle', $hKey)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return 1
EndFunc   ;==>_WinAPI_RegEnableReflectionKey

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegEnumKey($hKey, $iIndex)
	Local $tLastWriteTime = DllStructCreate($tagFILETIME)
	Local $aCall = DllCall('advapi32.dll', 'long', 'RegEnumKeyExW', 'ulong_ptr', $hKey, 'dword', $iIndex, 'wstr', '', _
			'dword*', 256, 'dword', 0, 'ptr', 0, 'ptr', 0, 'ptr', DllStructGetPtr($tLastWriteTime))
	If @error Then Return SetError(@error, @extended, '')
	If $aCall[0] Then Return SetError(10, $aCall[0], '')

	Return SetExtended($aCall[8], $aCall[3])
EndFunc   ;==>_WinAPI_RegEnumKey

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegEnumValue($hKey, $iIndex)
	Local $aCall = DllCall('advapi32.dll', 'long', 'RegEnumValueW', 'handle', $hKey, 'dword', $iIndex, 'wstr', '', _
			'dword*', 16384, 'dword', 0, 'dword*', 0, 'ptr', 0, 'ptr', 0)
	If @error Then Return SetError(@error, @extended, '')
	If $aCall[0] Then Return SetError(10, $aCall[0], '')

	Return SetExtended($aCall[6], $aCall[3])
EndFunc   ;==>_WinAPI_RegEnumValue

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegFlushKey($hKey)
	Local $aCall = DllCall('advapi32.dll', 'long', 'RegFlushKey', 'handle', $hKey)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return 1
EndFunc   ;==>_WinAPI_RegFlushKey

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegLoadMUIString($hKey, $sValueName, $sDirectory = '')
	If Not StringStripWS($sDirectory, $STR_STRIPLEADING + $STR_STRIPTRAILING) Then $sDirectory = Null

	Local $aCall = DllCall('advapi32.dll', 'long', 'RegLoadMUIStringW', 'handle', $hKey, 'wstr', $sValueName, 'wstr', '', _
			'dword', 16384, 'dword*', 0, 'dword', 0, 'wstr', $sDirectory)
	If @error Then Return SetError(@error, @extended, '')
	If $aCall[0] Then Return SetError(10, $aCall[0], '')

	Return $aCall[3]
EndFunc   ;==>_WinAPI_RegLoadMUIString

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegNotifyChangeKeyValue($hKey, $iFilter, $bSubtree = False, $bAsync = False, $hEvent = 0)
	Local $aCall = DllCall('advapi32.dll', 'long', 'RegNotifyChangeKeyValue', 'handle', $hKey, 'bool', $bSubtree, _
			'dword', $iFilter, 'handle', $hEvent, 'bool', $bAsync)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return 1
EndFunc   ;==>_WinAPI_RegNotifyChangeKeyValue

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegOpenKey($vKey, $sSubKey = '', $iAccess = $KEY_ALL_ACCESS)
	$vKey = __WinAPI_RegConvHKey($vKey, $sSubKey)
	If @error Then Return SetError(@error + 10, @extended, 0)

	Local $sSubKeyType = 'wstr'
	If Not IsString($sSubKey) Then $sSubKeyType = 'ptr'

	Local $aCall = DllCall('advapi32.dll', 'long', 'RegOpenKeyExW', 'handle', $vKey, $sSubKeyType, $sSubKey, 'dword', 0, _
			'dword', $iAccess, 'ulong_ptr*', 0)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return $aCall[5]
EndFunc   ;==>_WinAPI_RegOpenKey

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __WinAPI_RegConvHKey
; Description ...: Frees the memory that network management functions return
; Syntax.........: __WinAPI_RegConvHKey( $vKey, ByRef $sSubKey )
; Parameters ....: $vKey     - If String will return as hRootKey
;                  $sSubKey  - If String will return as SubKey defined in $vKey
; Return values .: Success      - Handle hRootKey
;                  Failure      - False
; Author ........: Jpm
; Modified.......:
; Remarks .......: This function is used internally by the _WinAPI_RegOpenKey or  module to free network management buffers
; ===============================================================================================================================
Func __WinAPI_RegConvHKey($vKey, ByRef $sSubKey)
	Local $hRootKey = $vKey, $sSubKeyTemp = ""
	If IsString($vKey) Then
		Local $sRoot = $vKey
		Local $n = StringInStr($vKey, "\")
		If $n Then
			$sRoot = StringLeft($vKey, $n - 1)
			$sSubKeyTemp = StringTrimLeft($vKey, $n)
		EndIf

		; Update $sRoot if X64 requested
		$sRoot = StringReplace($sRoot, "64", "")

		Switch $sRoot
			Case "HKCR", "HKEY_CLASSES_ROOT"
				$hRootKey = $HKEY_CLASSES_ROOT ; 0x80000000
			Case "HKLM", "HKEY_LOCAL_MACHINE"
				$hRootKey = $HKEY_LOCAL_MACHINE ; 0x80000002
			Case "HKCU", "HKEY_CURRENT_USER"
				$hRootKey = $HKEY_CURRENT_USER ; 0x80000001
			Case "HKU", "HKEY_USERS"
				$hRootKey = $HKEY_USERS ; 0x80000003
			Case "HKCC", "HKEY_CURRENT_CONFIG"
				$hRootKey = $HKEY_CURRENT_CONFIG ; 0x80000005
			Case "HKEY_PERFORMANCE_DATA"
				$hRootKey = $HKEY_PERFORMANCE_DATA ; 0x80000004
			Case "HKEY_PERFORMANCE_NLSTEXT"
				$hRootKey = $HKEY_PERFORMANCE_NLSTEXT ; 0x80000060
			Case "HKEY_PERFORMANCE_TEXT"
				$hRootKey = $HKEY_PERFORMANCE_TEXT ; 0x80000050
			Case Else
				Return SetError(1, 0, 0) ; bad $sRoot in $sKey
		EndSwitch

	EndIf

	If IsString($sSubKey) Then
		If $sSubKey <> "" Then
			If $sSubKeyTemp <> "" Then Return SetError(2, 0, 0) ; $sRoot contains subkey and $sSubKey already defined
		Else
			$sSubKey = $sSubKeyTemp
		EndIf
	EndIf

	Return $hRootKey
EndFunc   ;==>__WinAPI_RegConvHKey

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegQueryInfoKey($hKey)
	Local $aCall = DllCall('advapi32.dll', 'long', 'RegQueryInfoKeyW', 'handle', $hKey, 'ptr', 0, 'ptr', 0, 'ptr', 0, _
			'dword*', 0, 'dword*', 0, 'ptr', 0, 'dword*', 0, 'dword*', 0, 'dword*', 0, 'ptr', 0, 'ptr', 0)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Local $aRet[5]
	$aRet[0] = $aCall[5]
	$aRet[1] = $aCall[6]
	$aRet[2] = $aCall[8]
	$aRet[3] = $aCall[9]
	$aRet[4] = $aCall[10]
	Return $aRet
EndFunc   ;==>_WinAPI_RegQueryInfoKey

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegQueryLastWriteTime($hKey)
	Local $tFILETIME = DllStructCreate($tagFILETIME)
	Local $aCall = DllCall('advapi32.dll', 'long', 'RegQueryInfoKeyW', 'handle', $hKey, 'ptr', 0, 'ptr', 0, 'ptr', 0, 'ptr', 0, _
			'ptr', 0, 'ptr', 0, 'ptr', 0, 'ptr', 0, 'ptr', 0, 'ptr', 0, 'struct*', $tFILETIME)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return $tFILETIME
EndFunc   ;==>_WinAPI_RegQueryLastWriteTime

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegQueryMultipleValues($hKey, ByRef $aValent, ByRef $pBuffer, $iStart = 0, $iEnd = -1)
	$pBuffer = 0
	If __CheckErrorArrayBounds($aValent, $iStart, $iEnd, 2) Then Return SetError(@error + 10, @extended, 0)
	If UBound($aValent, $UBOUND_COLUMNS) < 4 Then Return SetError(13, 0, 0)

	Local $iValues = $iEnd - $iStart + 1
	Local $tagStruct = ''
	For $i = 1 To $iValues
		$tagStruct &= 'ptr;dword;ptr;dword;'
	Next
	Local $tValent = DllStructCreate($tagStruct)

	Local $aItem[$iValues], $iCount = 0
	For $i = $iStart To $iEnd
		$aItem[$iCount] = DllStructCreate('wchar[' & (StringLen($aValent[$i][0]) + 1) & ']')
		DllStructSetData($tValent, 4 * $iCount + 1, DllStructGetPtr($aItem[$iCount]))
		DllStructSetData($aItem[$iCount], 1, $aValent[$i][0])
		$iCount += 1
	Next
	Local $aCall = DllCall('advapi32.dll', 'long', 'RegQueryMultipleValuesW', 'handle', $hKey, 'struct*', $tValent, 'dword', $iValues, _
			'ptr', 0, 'dword*', 0)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] <> $REG_ERROR_MORE_DATA Then Return SetError(10, $aCall[0], 0)
	$pBuffer = __HeapAlloc($aCall[5])
	If @error Then Return SetError(@error + 100, @extended, 0)
	$aCall = DllCall('advapi32.dll', 'long', 'RegQueryMultipleValuesW', 'handle', $hKey, 'struct*', $tValent, 'dword', $iValues, _
			'ptr', $pBuffer, 'dword*', $aCall[5])
	If @error Or $aCall[0] Then
		Local $iError = @error
		__HeapFree($pBuffer)
		If IsArray($aCall) Then
			Return SetError(20, $aCall[0], 0)
		Else
			Return SetError($iError + 20, @extended, 0) ; should not occur as previously called
		EndIf
	EndIf

	$iCount = 0
	For $i = $iStart To $iEnd
		For $j = 1 To 3
			$aValent[$i][$j] = DllStructGetData($tValent, 4 * $iCount + $j + 1)
		Next
		$iCount += 1
	Next
	Return $aCall[5]
EndFunc   ;==>_WinAPI_RegQueryMultipleValues

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegQueryReflectionKey($hKey)
	Local $aCall = DllCall('advapi32.dll', 'long', 'RegQueryReflectionKey', 'handle', $hKey, 'bool*', 0)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return $aCall[2]
EndFunc   ;==>_WinAPI_RegQueryReflectionKey

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegQueryValue($hKey, $sValueName, ByRef $tValueData)
	Local $aCall = DllCall('advapi32.dll', 'long', 'RegQueryValueExW', 'handle', $hKey, 'wstr', $sValueName, 'dword', 0, _
			'dword*', 0, 'struct*', $tValueData, 'dword*', DllStructGetSize($tValueData))
	If @error Then Return SetError(@error, @extended, 0)
	If ($aCall[0] <> 0) And ($aCall[0] <> $REG_ERROR_MORE_DATA) Then Return SetError(10, $aCall[0], 0)

	Return SetError($aCall[0], $aCall[4], $aCall[6])
EndFunc   ;==>_WinAPI_RegQueryValue

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegRestoreKey($hKey, $sFilePath)
	Local $aCall = DllCall('advapi32.dll', 'long', 'RegRestoreKeyW', 'handle', $hKey, 'wstr', $sFilePath, 'dword', 8)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return 1
EndFunc   ;==>_WinAPI_RegRestoreKey

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegSaveKey($hKey, $sFilePath, $bReplace = False, $tSecurity = 0)
	Local $aCall
	While 1
		$aCall = DllCall('advapi32.dll', 'long', 'RegSaveKeyW', 'handle', $hKey, 'wstr', $sFilePath, 'struct*', $tSecurity)
		If @error Then Return SetError(@error, @extended, 0)
		Switch $aCall[0]
			Case 0
				ExitLoop
			Case 183 ; ERROR_ALREADY_EXISTS
				If $bReplace Then
					; If Not _WinAPI_DeleteFile($sFilePath) Then
					If Not FileDelete($sFilePath) Then
						Return SetError(20, _WinAPI_GetLastError(), 0)
					Else
						ContinueLoop
					EndIf
				Else
					ContinueCase
				EndIf
			Case Else
				Return SetError(10, $aCall[0], 0)
		EndSwitch
	WEnd

	Return 1
EndFunc   ;==>_WinAPI_RegSaveKey

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: jpm
; ===============================================================================================================================
Func _WinAPI_RegSetValue($hKey, $sValueName, $iType, $tValueData, $iBytes)
	Local $aCall = DllCall('advapi32.dll', 'long', 'RegSetValueExW', 'handle', $hKey, 'wstr', $sValueName, 'dword', 0, _
			'dword', $iType, 'struct*', $tValueData, 'dword', $iBytes)
	If @error Then Return SetError(@error, @extended, 0)
	If $aCall[0] Then Return SetError(10, $aCall[0], 0)

	Return 1
EndFunc   ;==>_WinAPI_RegSetValue

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: JPM
; ===============================================================================================================================
Func _WinAPI_SfcIsKeyProtected($hKey, $sSubKey = Default, $iFlag = 0)
	If Not __DLL('sfc.dll') Then Return SetError(103, 0, False)

	If Not IsString($sSubKey) Then $sSubKey = Null

	Local $aCall = DllCall('sfc.dll', 'int', 'SfcIsKeyProtected', 'handle', $hKey, 'wstr', $sSubKey, 'dword', $iFlag)
	If @error Then Return SetError(@error, @extended, False)

	Return $aCall[0]
EndFunc   ;==>_WinAPI_SfcIsKeyProtected

#EndRegion Public Functions
