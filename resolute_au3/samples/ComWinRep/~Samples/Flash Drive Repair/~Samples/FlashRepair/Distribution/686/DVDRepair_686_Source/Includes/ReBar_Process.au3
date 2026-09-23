#include-once


; #INDEX# =======================================================================================================================
; Title .........: Process
; AutoIt Version : 3.3.15.0
; Description ...: Run and Processing Functions
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================


#include "ReBar_Logging.au3"


#Region Functions list
; #CURRENT# =====================================================================================================================
; _ProcessCloseHandle
; _ProcessExitCode
; _RunCommand
; ==============================================================================================================================
#EndRegion Functions list


Func _ProcessCloseHandle($h_Process)
	; Close the process handle of a PID
	DllCall('kernel32.dll', 'ptr', 'CloseHandle', 'ptr', $h_Process)
	If Not @error Then Return 1
	Return 0
EndFunc   ;==>_ProcessCloseHandle


;===============================================================================
;
; Function Name:    _ProcessExitCode()
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
;
Func _ProcessExitCode($iPID, $hProcess = 0)

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

EndFunc   ;==>_ProcessExitCode


Func _RunCommand($sCommand)

	Local $iCMD = Run(@ComSpec & " /c " & $sCommand, @SystemDir, @SW_HIDE, $STDERR_MERGED)
	Local $sOutput, $sSuccess = ""

	While 1
		$sOutput = StdoutRead($iCMD)
		If @error Then
			ExitLoop
		EndIf

		Local $aOutput = StringSplit($sOutput, @CRLF)
		For $x = 1 To $aOutput[0]
			If __HasOutput($aOutput[$x]) Then
				_EditLoggingWrite(StringStripWS(__FormatRunOutput($aOutput[$x]), $STR_STRIPLEADING + $STR_STRIPTRAILING))
				Sleep(50)
			EndIf
		Next


	WEnd

EndFunc


Func __HasOutput($sOutput)

	$sOutput = StringStripWS($sOutput, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

	Switch $sOutput
		Case "", ".", ".."
			Return False
		Case Else
			Return True
	EndSwitch

EndFunc


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

EndFunc