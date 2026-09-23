#include-once

#include <WinAPILocale.au3>


; #INDEX# =======================================================================================================================
; Title .........: ReBar Numbers
; AutoIt Version : 3.3.15.0
; Description ...: Mathematical Functions,
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================

#Region Global Variables and Constants

; #VARIABLES# ===================================================================================================================
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; ===============================================================================================================================
#EndRegion Global Variables and Constants


#Region Functions list
; #CURRENT# =====================================================================================================================
; _ReBarNumbers_FormatThousands
; ==============================================================================================================================
#EndRegion Functions list


; #FUNCTION# ====================================================================================================================
; Author(s) .....: Derick Payne (Rizonesoft)
; Modified ......:
; ===============================================================================================================================
Func _ReBarNumbers_FormatThousands($iNumber, $iNumDigits = 0, $sThousandSep = " ", $iNoRounding = 1)

	Local $iReturn, $iTemp, $iPos, $iDigits

	If $iNoRounding > 0 Then
		$iTemp = $iNumDigits + 1
	EndIf

	$iReturn = _WinAPI_GetNumberFormat(0, $iNumber, _WinAPI_CreateNumberFormatInfo($iTemp, 0, 3, ".", $sThousandSep, 1))
	$iPos = StringInStr($iReturn, ".")
	$iDigits = StringTrimLeft(StringTrimRight($iReturn, 1), $iPos)

	If $iDigits <> "" Then
		$iReturn = StringLeft($iReturn, $iPos - 1) & "." & $iDigits
	Else
		$iReturn = StringLeft($iReturn, $iPos - 1)
	EndIf

	Return $iReturn

EndFunc   ;==>_ReBarIcons_SetIcon

