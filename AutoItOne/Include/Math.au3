#include-once

#include "MathConstants.au3"

; #INDEX# =======================================================================================================================
; Title .........: Mathematical calculations
; AutoIt Version : 3.3.16.1
; Language ......: English
; Description ...: Functions that assist with mathematical calculations.
; Author(s) .....: Valik, Gary Frost, guinness ...
; ===============================================================================================================================

; #NO_DOC_FUNCTION# =============================================================================================================
;
; _MathCheckDiv
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _Degree
; _Max
; _Min
; _Radian
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Author ........: Erifash <erifash at gmail dot com>
; ===============================================================================================================================
Func _Degree($iRadians)
	Return IsNumber($iRadians) ? $iRadians * $MATH_DEGREES : SetError(1, 0, 0)
EndFunc   ;==>_Degree

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _MathCheckDiv
; Description ...: Checks if first number is divisible by the second number.
; Syntax.........: _MathCheckDiv ( $iNum1, $iNum2 = 2 )
; Parameters ....: $iNum1 - Integer value to check
;                  $iNum2 - [optional] Integer value to divide by (default = 2)
; Return values .: Success - $MATH_ISNOTDIVISIBLE (1) for not divisible.
;                            $MATH_ISDIVISIBLE (2) for divisible.
;                  Failure - -1 and sets the @error flag to non-zero if non-integers are entered.
; Author ........: Wes Wolfe-Wolvereness <Weswolf at aol dot com>
; Modified ......: czardas - rewritten for compatibility with Int64
; Remarks .......: This function by default checks if the first number is either odd or even, as the second value is default to 2.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _MathCheckDiv($iNum1, $iNum2 = 2)
	If Not (IsInt($iNum1) And IsInt($iNum2)) Then
		Return SetError(1, 0, -1)
	EndIf
	Return (Mod($iNum1, $iNum2) = 0) ? $MATH_ISDIVISIBLE : $MATH_ISNOTDIVISIBLE
EndFunc   ;==>_MathCheckDiv

; #FUNCTION# ====================================================================================================================
; Author ........: Jeremy Landes <jlandes at landeserve dot com>
; Modified ......: guinness - Added ternary operator.
; ===============================================================================================================================
Func _Max($iNum1, $iNum2)
	; Check to see if the parameters are numbers
	If Not IsNumber($iNum1) Then Return SetError(1, 0, 0)
	If Not IsNumber($iNum2) Then Return SetError(2, 0, 0)
	Return ($iNum1 > $iNum2) ? $iNum1 : $iNum2
EndFunc   ;==>_Max

; #FUNCTION# ====================================================================================================================
; Author ........: Jeremy Landes <jlandes at landeserve dot com>
; Modified ......: guinness - Added ternary operator.
; ===============================================================================================================================
Func _Min($iNum1, $iNum2)
	; Check to see if the parameters are numbers
	If Not IsNumber($iNum1) Then Return SetError(1, 0, 0)
	If Not IsNumber($iNum2) Then Return SetError(2, 0, 0)
	Return ($iNum1 > $iNum2) ? $iNum2 : $iNum1
EndFunc   ;==>_Min

; #FUNCTION# ====================================================================================================================
; Author ........: Erifash <erifash at gmail dot com>
; ===============================================================================================================================
Func _Radian($iDegrees)
	Return Number($iDegrees) ? $iDegrees / $MATH_DEGREES : SetError(1, 0, 0)
EndFunc   ;==>_Radian
