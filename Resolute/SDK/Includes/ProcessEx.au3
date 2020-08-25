#include-once


#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y										;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y								;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section


#include "Logging.au3"


; #INDEX# =======================================================================================================================
; Title .........: ProcessEx
; AutoIt Version : 3.3.15.0
; Language ......: English
; Description ...: Functions that assist with Process management.
; Author(s) .....:
; Dll ...........: Kernel32.dll
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _ProcessEx_CloseHandle
; _ProcessEx_ExitCode
; _ProcessEx_RunCommand
; ===============================================================================================================================


Func _ProcessEx_CloseHandle($h_Process)
	; Close the process handle of a PID
	DllCall('kernel32.dll', 'ptr', 'CloseHandle', 'ptr', $h_Process)
	If Not @error Then Return 1
	Return 0
EndFunc   ;==>_ProcessEx_CloseHandle


;===============================================================================
;
; Function Name:    _ProcessEx_ExitCode()
; Description:      Returns a handle/exitcode from use of Run().
; Parameter(s):     $iPID         - ProcessID returned from a Run() execution
;                   $hProcess     - Process handle
; Requirement(s):   None
; Return Value(s):  On Success - Returns Process handle while Run() is executing
;                                (use above directly after Run() line with only PID parameter)
;                              - Returns Process Exitcode when Process does not exist
;                                (use above with PID and Process Handle parameter returned from first UDF call)
;                   On Failure - 0
; Author(s):        MHz (Thanks to DaveF for posting these DllCalls in Support Forum)
;
;===============================================================================
Func _ProcessEx_ExitCode($iPID, $hProcess = 0)

	; 0 = Return Process Handle of PID else use Handle to Return Exitcode of a PID
	Local $vPlaceholder

	If Not IsArray($hProcess) Then
		; Return the process handle of a PID
		$hProcess = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'int', 0x400, 'int', 0, 'int', $iPID)
		If Not @error Then Return $hProcess
	Else
		; Return Process Exitcode of PID
		$hProcess = DllCall('kernel32.dll', 'ptr', 'GetExitCodeProcess', 'ptr', $hProcess[0], 'int*', $vPlaceholder)
		If Not @error Then Return $hProcess[2]
	EndIf

	Return 0

EndFunc   ;==>_ProcessEx_ExitCode


Func _ProcessEx_RunCommand($sCommand, $sWorkingDir = "")

	Local $iCMD = Run(@ComSpec & " /c " & $sCommand, $sWorkingDir, @SW_HIDE, $STDERR_MERGED)
	Local $sOutput, $sSuccess = ""

	While 1
		$sOutput = StdoutRead($iCMD)
		If @error Then
			ExitLoop
		EndIf

		Local $aOutput = StringSplit($sOutput, @CRLF)
		For $x = 1 To $aOutput[0]
			If __HasOutput($aOutput[$x]) Then
				_Logging_EditWrite(StringStripWS(__FormatRunOutput($aOutput[$x]), $STR_STRIPLEADING + $STR_STRIPTRAILING))
				Sleep(50)
			EndIf
		Next


	WEnd

EndFunc   ;==>_ProcessEx_RunCommand


Func __HasOutput($sOutput)

	$sOutput = StringStripWS($sOutput, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

	Switch $sOutput
		Case "", ".", ".."
			Return False
		Case Else
			Return True
	EndSwitch

EndFunc   ;==>__HasOutput


Func __FormatRunOutput($sOutput)

	Local $sReturn = $sOutput
	Local $sBadStrings = "Resetting , failed.|Sucessfully"
	Local $sGoodStrings = "Resetting, failed.|Successfully"
	Local $aBadStrings = StringSplit($sBadStrings, "|")
	Local $aGoodStrings = StringSplit($sGoodStrings, "|")


	If $aBadStrings[0] = $aGoodStrings[0] Then
		For $x = 1 To $aBadStrings[0]
			$sReturn = StringReplace($sReturn, $aBadStrings[$x], $aGoodStrings[$x])
		Next
	EndIf

	Return $sReturn

EndFunc   ;==>__FormatRunOutput
