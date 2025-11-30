#include-once


; #INDEX# =======================================================================================================================
; Title .........: Registry
; AutoIt Version : 3.3.15.0
; Description ...: Registry Functions
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================


#include "ReBar_Logging.au3"


#Region Global Variables and Constants

; #VARIABLES# ===================================================================================================================
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; ===============================================================================================================================
#EndRegion Global Variables and Constants


#Region Functions list
; #CURRENT# =====================================================================================================================
; _ReregisterDLL
; _RegistryDelete
; _RegistryWrite
; ==============================================================================================================================
#EndRegion Functions list


; 0 = Boot, 1 = System, 2 = Automatic, 3 = Manual, 4 = Disabled
Func _ConfigureWindowsService($sServiceName, $iConfig = 2)

	Local $sRegService = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\" & $sServiceName
	RegRead($sRegService, "Start")
	If Not @error Then
		_RegistryWrite($sRegService, "Start", "REG_DWORD", $iConfig)
	Else
		Return SetError(1, 0, "")
	EndIf

EndFunc


Func _GetServiceConfiguration($sServiceName)

	Local $sRegService = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\" & $sServiceName
	Local $iReturn = RegRead($sRegService, "Start")
	If Not @error Then
		Return $iReturn
	Else
		Return SetError(1)
	EndIf

EndFunc


Func _ReregisterDLL($sFileName, $Param = "/s")

	Local $sCleanFileName = StringReplace($sFileName, Chr(34), "", 0, $STR_NOCASESENSE)

	Local $eRegSvr32

	$eRegSvr32 = ShellExecuteWait("regsvr32.exe", " " & $Param & " " & $sFileName, "")

	Switch $eRegSvr32
		Case 0
			_EditLoggingWrite("RegSvr32.exe: [" & $sCleanFileName & "] registration succeeded.")
		Case 1
			_EditLoggingWrite("RegSvr32.exe: [" & $sCleanFileName & "] To register a module, you must provide a binary name.")
		Case 3
			_EditLoggingWrite("RegSvr32.exe: [" & $sCleanFileName & "] Specified module not found")
		Case 4
			_EditLoggingWrite("RegSvr32.exe: [" & $sCleanFileName & "] Module loaded but entry-point DllRegisterServer was not found.")
		Case 5
			_EditLoggingWrite("RegSvr32.exe: [" & $sCleanFileName & "] Error number: 0x80070005")
	EndSwitch

	If $eRegSvr32 >= 1 Then
		Return 0
	Else
		Return 1
	EndIf

EndFunc   ;==>_ReregisterDLL


Func _RegistryDelete($hKey, $hValue = "REG_NONE")

	If $hValue = "REG_NONE" Then
		RegDelete($hKey)
	Else
		RegDelete($hKey, $hValue)
	EndIf

	Local $nError = @error
	If $nError Then
		If $hValue = "REG_NONE" Then
			; _EditLoggingWrite("Error: Could not remove branch [" & $hKey & "]")
		Else
			; _EditLoggingWrite("Error: Could not remove " & Chr(34) & $hValue & Chr(34) & " in branch [" & $hKey & "]")
		EndIf
		__ReturnRegistryError($nError, "delete")
	EndIf

EndFunc


Func _RegistryWrite($hKey, $hValueName = "REG_NONE", $hRegType = "REG_SZ", $hValue = "")

	If $hValueName = "REG_NONE" Then
		RegWrite($hKey)
	Else
		RegWrite($hKey, $hValueName, $hRegType, $hValue)
	EndIf

	Local $nError = @error
	If $nError Then
		If $hValueName = "REG_NONE" Then
			_EditLoggingWrite("Error: Could not write to [" & $hKey & "]")
		Else
			_EditLoggingWrite("Error: Could not write to [" & $hKey & " --> " & $hValueName & " --> " & $hRegType & " --> " & $hValue & "]")
		EndIf
		__ReturnRegistryError($nError, "write")
	Else
		Return True
	EndIf

	Return False

EndFunc


Func __ReturnRegistryError($nError, $sIO = "write")

	If $sIO == "write" Then
		Switch $nError
			Case 1
				_EditLoggingWrite("Unable to open requested key!")
			Case 2
				_EditLoggingWrite("Unable to open requested main key!")
			Case -1
				_EditLoggingWrite("Unable to open requested value!")
			Case -2
				_EditLoggingWrite("Value type not supported!")
		EndSwitch
	ElseIf $sIO == "delete" Then
		Switch $nError
			Case -1
				_EditLoggingWrite("Unable to delete requested value!")
			Case -2
				_EditLoggingWrite("Unable to delete requested key/value!")
		EndSwitch
	EndIf



EndFunc