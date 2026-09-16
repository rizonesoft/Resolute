#include-once


#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y										;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y								;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section


#include <File.au3>
#include <FileConstants.au3>
#include <StringConstants.au3>


; #INDEX# =======================================================================================================================
; Title .........: AutoIt3 Script
; AutoIt Version : 3.3.15.0
; Description ...: AutoIt3 Script Functions
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _AutoIt3Script_GetDirectiveValue
; _AutoIt3Script_GetFilename
; _AutoIt3Script_GetVersion
; ==============================================================================================================================


Func _AutoIt3Script_GetArchitecture()

	If @AutoItX64 Then
		Return 64
	Else
		Return 32
	EndIf

EndFunc   ;==>_AutoIt3Script_GetArchitecture


; #FUNCTION# ====================================================================================================================
; Author(s) .....: Derick Payne (Rizonesoft)
; Modified ......:
; ===============================================================================================================================
Func _AutoIt3Script_GetDirectiveValue($sAu3Script_In, $sParam, $sResField = "")

	Local $aScript_In
	Local $iCurrLine
	Local $iCurrLine_Param
	Local $iCurrLine_Value
	Local $sReturn_Value

	Local $hFileOpen = FileOpen($sAu3Script_In, $FO_FULLFILE_DETECT)
	If $hFileOpen = -1 Then Return SetError(1, 0, 0) ; Unable to open the file
	Local $sFileRead = FileRead($hFileOpen)
	FileClose($hFileOpen)

	; Build Array
	If StringInStr($sFileRead, @LF) Then
		$aScript_In = StringSplit(StringStripCR($sFileRead), @LF)
	ElseIf StringInStr($sFileRead, @CR) Then ; @LF does not exist so split on the @CR
		$aScript_In = StringSplit($sFileRead, @CR)
	Else ; Unable to split the file
		If StringLen($sFileRead) Then
			$sFileRead &= @LF
			$aScript_In = StringSplit(StringStripCR($sFileRead), @LF)
		Else
			Return SetError(2, 0, 0)
		EndIf
	EndIf

	Local $IsCommentBlock = False
	Local $IsRunBlock

	For $iLine = 1 To $aScript_In[0]

		$iCurrLine = $aScript_In[$iLine]
		$iCurrLine = StringStripWS($iCurrLine, 1)

		; Ignore Comment Blocks
		If StringLeft($iCurrLine, 3) = "#CS" Or StringLeft($iCurrLine, 13) = "Comment_Start" Then $IsCommentBlock = True
		If StringLeft($iCurrLine, 3) = "#CE" Or StringLeft($iCurrLine, 11) = "Comment_End" Then $IsCommentBlock = False
		If $IsCommentBlock Then ContinueLoop

		; Ignore Commented lines
		If StringLeft($iCurrLine, 1) = ";" Then ContinueLoop

		; Ignore "Run" Block
		If StringInStr($iCurrLine, "#AutoIt3Wrapper_If_Run") Then $IsRunBlock = True
		If StringInStr($iCurrLine, "#Autoit3Wrapper_If_Compile") Then $IsRunBlock = False
		If $IsRunBlock Then ContinueLoop

		If StringLeft($iCurrLine, 16) <> "#AutoIt3Wrapper_" _
				And StringLeft($iCurrLine, 5) <> "#Run_" _
				And StringLeft($iCurrLine, 6) <> "#Tidy_" _
				And StringLeft($iCurrLine, 12) <> "#Obfuscator_" _
				And StringLeft($iCurrLine, 13) <> "#Au3Stripper_" Then
			ContinueLoop
		EndIf

		If StringInStr($iCurrLine, ";") Then
			$iCurrLine = StringLeft($iCurrLine, StringInStr($iCurrLine, ";") - 1)
		EndIf

		$iCurrLine = StringStripWS($iCurrLine, 3)
		$iCurrLine_Param = StringLeft($iCurrLine, StringInStr($iCurrLine & "=", "=") - 1)
		$iCurrLine_Param = StringStripWS($iCurrLine_Param, 3)
		$iCurrLine_Value = StringTrimLeft($iCurrLine, StringInStr($iCurrLine, "="))
		$iCurrLine_Value = StringStripWS($iCurrLine_Value, 3)
		$iCurrLine_Value = StringReplace($iCurrLine_Value, Chr(34), "")

		If $iCurrLine_Param = "#AutoIt3Wrapper_Res_Field" And StringLen($sResField) > 0 Then
			Local $aResFieldSplt = StringSplit($iCurrLine_Value, "|")
			If $aResFieldSplt[0] == 2 Then
				If $aResFieldSplt[1] = $sResField Then
					$sReturn_Value = $aResFieldSplt[2]
					ExitLoop
				EndIf
			EndIf
		ElseIf $sParam = $iCurrLine_Param Then
			$sReturn_Value = $iCurrLine_Value
			ExitLoop
		EndIf

	Next

	Return $sReturn_Value

EndFunc   ;==>_AutoIt3Script_GetDirectiveValue


Func _AutoIt3Script_GetFilename($sScriptFullPath)

	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($sScriptFullPath, $sDrive, $sDir, $sFileName, $sExtension)
	Return StringReplace($sFileName, "_X64", "")

EndFunc   ;==>_AutoIt3Script_GetFilename


; #FUNCTION# ====================================================================================================================
; Author(s) .....: Derick Payne (Rizonesoft)
; Modified ......:
; ===============================================================================================================================
Func _AutoIt3Script_GetVersion($sAu3ScriptIn, $index = 0)

	Local $sReturn = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_Res_Fileversion")
	Local $sAutoIncrement = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_Res_FileVersion_AutoIncrement")
	Local $sFirstIncrement = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_Res_FileVersion_First_Increment")

	If $sAutoIncrement == "Y" Then
		If $sFirstIncrement == "Y" Then
			; Return Unchanged version from Script.
			Return __GetVersionFromString($sReturn, $index, 0)
		Else
			; Return Compiled version from Script.
			Return __GetVersionFromString($sReturn, $index, 1)
		EndIf
	Else
		; Return Unchanged version from Script.
		Return __GetVersionFromString($sReturn, $index, 0)
	EndIf

EndFunc   ;==>_AutoIt3Script_GetVersion


Func __DisplayNullString($string)

	If StringStripWS($string, 8) == "" Then
		Return 0
	Else
		Return $string
	EndIf

EndFunc   ;==>__DisplayNullString


Func __GetVersionFromString($sVersion, $index = 0, $Increment = 0)

	Local $sReturn = ""
	Local $sPltReturn = StringSplit($sVersion, ".")

	If IsArray($sPltReturn) Then

		If StringIsInt($sPltReturn[$sPltReturn[0]]) Then
			$sPltReturn[$sPltReturn[0]] = $sPltReturn[$sPltReturn[0]] - $Increment
		EndIf

		If $index <= $sPltReturn[0] And $index > 0 Then
			$sReturn = __DisplayNullString($sPltReturn[$index])
		Else

			For $x = 1 To $sPltReturn[0] ; Loop through the array returned by StringSplit to display the individual values.
				If $x = 1 Then
					$sReturn &= __DisplayNullString($sPltReturn[$x])
				Else
					$sReturn &= "." & __DisplayNullString($sPltReturn[$x])
				EndIf
			Next

		EndIf

	EndIf

	Return $sReturn

EndFunc   ;==>__GetVersionFromString
