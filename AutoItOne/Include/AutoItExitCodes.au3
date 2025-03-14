#include-once

#include "AutoItConstants.au3"
#include "AutoItFatalExitConstants.au3"

; #INDEX# =======================================================================================================================
; Title .........: AutoIt3 Exit Codes
; AutoIt Version : 3.3.16.1
; Language ......: English
; Description ...: lib to format @exitCode
; Author(s) .....: Jpm
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================

Global Const $EXITCODES[5][2] = [ _
		[$EXITCLOSE_NORMAL, "Natural closing."], _
		[$EXITCLOSE_BYEXIT, "close by Exit function."], _
		[$EXITCLOSE_BYCLICK, "close by clicking on exit of the systray."], _
		[$EXITCLOSE_BYLOGOFF, "close by user logoff."], _
		[$EXITCLOSE_BYSHUTDOWN, "close by Windows shutdown."] _
		]
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;
; Doc in Misc
; _FormatAutoItExitCode
;
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Author ........: Jpm
; Modified.......:
; ===============================================================================================================================
Func _FormatAutoItExitCode()
	For $i = 0 To UBound($EXITFATALCODES) - 1
		If @exitCode = $EXITFATALCODES[$i][0] Then Return $EXITFATALCODES[$i][1]
	Next

	Return "0x" & Hex(@exitCode)
EndFunc   ;==>_FormatAutoItExitCode

; #FUNCTION# ====================================================================================================================
; Author ........: Jpm
; Modified.......:
; ===============================================================================================================================
Func _FormatAutoItExitMethod()
	For $i = 0 To UBound($EXITCODES) - 1
		If @exitMethod = $EXITCODES[$i][0] Then Return $EXITCODES[$i][1]
	Next

	Return "0x" & Hex(@exitCode)
EndFunc   ;==>_FormatAutoItExitCode
