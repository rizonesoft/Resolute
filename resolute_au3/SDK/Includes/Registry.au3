#include-once

#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y										 ;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y								 ;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section


#include "Localization.au3"
#include "Logging.au3"


; #INDEX# =======================================================================================================================
; Title .........: RegistryEx
; AutoIt Version : 3.3.15.0
; Language ......: English
; Description ...: Extended Registry Functions.
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; ===============================================================================================================================


Func _Dll_Register($sFileName, $Param = "/s")

	Local $sCleanFileName = StringReplace($sFileName, Chr(34), "", 0, $STR_NOCASESENSE)
	Local $eRegSvr32, $sErrorMessage = ""

	$eRegSvr32 = ShellExecuteWait("regsvr32.exe", " " & $Param & " " & $sFileName, "")

	Switch $eRegSvr32
		Case 0
			$sErrorMessage = _Logging_SetLevel($g_aLangMessages[27], "SUCCESS")
		Case 1
			$sErrorMessage = _Logging_SetLevel($g_aLangMessages[28], "ERROR")
		Case 3
			$sErrorMessage = $g_aLangMessages[29]
		Case 4
			$sErrorMessage = _Logging_SetLevel($g_aLangMessages[30], "WARNING")
		Case 5
			$sErrorMessage = _Logging_SetLevel($g_aLangMessages[31], "ERROR")
	EndSwitch

	_Logging_EditWrite(StringFormat($sErrorMessage, $sCleanFileName))

	If $eRegSvr32 >= 1 Then
		Return 0
	Else
		Return 1
	EndIf

EndFunc   ;==>_Dll_Register


Func _Registry_Delete($hKey, $hValue = "REG_NONE")

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
		__Registry_ReturnError($nError, "delete")
	EndIf

EndFunc   ;==>_Registry_Delete


Func _Registry_Write($hKey, $hValueName = "REG_NONE", $hRegType = "REG_SZ", $hValue = "")

	If $hValueName = "REG_NONE" Then
		RegWrite($hKey)
	Else
		RegWrite($hKey, $hValueName, $hRegType, $hValue)
	EndIf

	Local $nError = @error
	If $nError Then
		If $hValueName = "REG_NONE" Then
			_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangMessages[32], $hKey), "ERROR"))
		Else
			_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangMessages[32], $hKey & " --> " & $hValueName & " --> " & $hRegType & " --> " & $hValue), "ERROR"))
		EndIf
		__Registry_ReturnError($nError, "write")
	EndIf

	Return SetError($nError, 0, $nError)

EndFunc   ;==>_Registry_Write


; 0 = Boot, 1 = System, 2 = Automatic, 3 = Manual, 4 = Disabled
Func _Service_Configure($sServiceName, $iConfig = 2)

	Local $sRegService = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\" & $sServiceName
	RegRead($sRegService, "Start")
	If Not @error Then
		_Registry_Write($sRegService, "Start", "REG_DWORD", $iConfig)
	Else
		Return SetError(1, 0, "")
	EndIf

EndFunc   ;==>_Service_Configure


Func _Service_GetConfig($sServiceName)

	Local $sRegService = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\" & $sServiceName
	Local $iReturn = RegRead($sRegService, "Start")
	If Not @error Then
		Return $iReturn
	Else
		Return SetError(1)
	EndIf

EndFunc   ;==>_Service_GetConfig


Func __Registry_ReturnError($nError, $sIO = "write")

	Local $sErrorMessage

	If $sIO == "write" Then
		Switch $nError
			Case 1
				_Logging_EditWrite("^ " & $g_aLangMessages[33])
			Case 2
				_Logging_EditWrite("^ " & $g_aLangMessages[34])
			Case -1
				_Logging_EditWrite("^ " & $g_aLangMessages[35])
			Case -2
				_Logging_EditWrite("^ " & $g_aLangMessages[36])
		EndSwitch
	ElseIf $sIO == "delete" Then
		Switch $nError
			Case -1
				_Logging_EditWrite("^ " & $g_aLangMessages[37])
			Case -2
				_Logging_EditWrite("^ " & $g_aLangMessages[38])
		EndSwitch
	EndIf



EndFunc   ;==>__Registry_ReturnError
