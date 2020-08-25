#include-once


#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y										;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y								;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section


#include "Localization.au3"


; #INDEX# =======================================================================================================================
; Title .........: Messages
; AutoIt Version : 3.3.15.0
; Language ......: English
; Description ...: Message Functions.
; Author(s) .....:
; Dll ...........:
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_Errors_ReturnConnectionMsg
; ===============================================================================================================================


Func _Message_ReturnConnectionError($iError)

	_Localization_Messages()

	Switch $iError
		Case 1
			Return $g_aLangMessages[17]
		Case 2
			Return $g_aLangMessages[18]
		Case 3
			Return $g_aLangMessages[19]
		Case 4
			Return $g_aLangMessages[20]
	EndSwitch

EndFunc   ;==>_Errors_ReturnConnectionMsg
