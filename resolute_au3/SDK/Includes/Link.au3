#include-once

#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y										 ;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y								 ;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section


; #INDEX# =======================================================================================================================
; Title .........: Link
; AutoIt Version : 3.3.15.0
; Language ......: English
; Description ...: Link Functions.
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================

; ===============================================================================================================================


Func _Link_Split($sLink, $iFlag = 1)

	Local $aLink = StringSplit($sLink, "|")
	If $iFlag <= $aLink[0] And $iFlag > 0 Then
		If $aLink[0] = 1 Then
			Return $aLink[1]
		Else
			Return $aLink[$iFlag]
		EndIf
	EndIf

EndFunc   ;==>_Link_Split
