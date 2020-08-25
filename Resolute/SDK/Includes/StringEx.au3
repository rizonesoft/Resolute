#include-once

#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y										 ;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y								 ;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section


; #INDEX# =======================================================================================================================
; Title .........: StringEx
; AutoIt Version : 3.3.15.0
; Language ......: English
; Description ...: Extended String Functions.
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; ===============================================================================================================================


Func _StringEx_FirstLetterUpper($sText)
	Return StringReplace($sText, StringLeft($sText, 1), StringUpper(StringLeft($sText, 1)), 1)
EndFunc   ;==>_StringEx_FirstLetterUpper


Func _StringEx_FullStop($sText, $iFlag = 0)

	If $iFlag = 0 Then
		If StringRight($sText, 1) = "." Then
			Return $sText
		Else
			Return $sText & "."
		EndIf
	Else

		If StringRight($sText, 1) = "." Then
			Return StringLeft($sText, StringLen($sText) - 1)
		Else
			Return $sText
		EndIf

	EndIf

EndFunc   ;==>_StringEx_FullStop


Func _StringEx_ReturnPlural($iCount, $sReturn1, $sReturn2)

	If $iCount = 1 Then
		Return $sReturn1
	Else
		Return $sReturn2
	EndIf

EndFunc


Func _StringEx_CalcTab($sText, $iTabLen = 28)

	Local $iStringLen = StringLen($sText)
	Local $iTabs = $iTabLen - $iStringLen
	Local $sTabs

	ConsoleWrite("+> _StringEx_CalcTab Function Called" & @CRLF)
	ConsoleWrite("+> --------------------------------------------------" & @CRLF)
	ConsoleWrite(">  String Length: " & String($iStringLen) & @CRLF)
	ConsoleWrite(">  String Tab Length:	" & String($iTabs) & @CRLF)

	For $x = 1 To $iTabs
		$sTabs &= Chr(32)
	Next

	Return $sTabs

EndFunc   ;==>_StringEx_CalcTab