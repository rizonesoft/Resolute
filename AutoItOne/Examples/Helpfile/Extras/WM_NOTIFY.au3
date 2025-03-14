#include-once

#include <WindowsConstants.au3>

; #INDEX# =======================================================================================================================
; Title .........: GUI Ctrl Extended UDF Library for AutoIt3
; AutoIt Version : 3.3.15.1
; Description ...: Functions that assist display of Registered Events.
; Author(s) .....: jpm
; ===============================================================================================================================

#Region Global Variables and Constants

; #VARIABLES# ===================================================================================================================
Global $__g_idWM_NOTIFY_Memo = 0
; ===============================================================================================================================

#EndRegion Global Variables and Constants

#Region Functions list

; #NO_DOC_FUNCTION# =============================================================================================================
;
; _WM_NOTIFY_Register
; _WM_NOTIFY_DebugEvent
; _WM_NOTIFY_DebugInfo
; ===============================================================================================================================

#EndRegion Functions list

; #NO_DOC_FUNCTION# =============================================================================================================
; Name ..........: _WM_NOTIFY_Register
; Description ...: Register GUI Msg
; Syntax.........:  _WM_NOTIFY_Register($idMemo = 0, $sFunc = "WM_NOTIFY")
; Parameters ....: $idMemo       - Control ID of the Edit control to be used to display event info
;                  $sFunc        - func name of the func to be registered
; Return values .: None
; Author ........: Jpm
; Modified ......:
; Remarks .......: $idMemo = 0 ConsoleWrite instead of the Edit Control
; Related .......: _WM_NOTIFY_DebugEvent
; ===============================================================================================================================
Func _WM_NOTIFY_Register($idMemo = 0, $sFunc = "WM_NOTIFY")
	$__g_idWM_NOTIFY_Memo = $idMemo
	GUIRegisterMsg($WM_NOTIFY, $sFunc)
EndFunc   ;==>_WM_NOTIFY_Register

; #NO_DOC_FUNCTION# =============================================================================================================
; Name ..........: _WM_NOTIFY_DebugEvent
; Description ...: Display DllStruct info
; Syntax.........: _WM_NOTIFY_DebugEvent($sCode, $sTag, $lParam, $sFields = "", $sExtraFields = "", $iScriptLineNumber = @ScriptLineNumber)
; Parameters ....: $sCode             - String corresponding to the Code event
;                  $sTag              - String to create a DllStruct
;                  $lParam            - Ptr to base the DllStruct
;                  $sFields           - Field comma separated to be displayed
;                  $sExtraFields      - Extra string to be displayed
;                  $iScriptLineNumber - calling line number
; Return values .: none.
; Author ........: Jpm
; Modified ......:
; Remarks .......: 2 consecutive commas generate a new line
; Related .......: _WM_NOTIFY_Register
; ===============================================================================================================================
Func _WM_NOTIFY_DebugEvent($sCode, $sTag, $lParam, $sFields = "", $sExtraFields = "", $iScriptLineNumber = @ScriptLineNumber)
	Local $tInfo = DllStructCreate($sTag, $lParam)
	Local $sMessage = "@@ Debug(" & $iScriptLineNumber & ") : " & $sCode
	Local $sField, $aFields = StringSplit($sFields, ",")
	If $sFields Then
		For $i = 1 To $aFields[0]
			$sField = $aFields[$i]
			If $sField Then
				If StringLeft($sField, 1) = "*" Then
					$sField = StringTrimLeft($sField, 1)
					Local $pText = DllStructGetData($tInfo, $sField)
					If $pText Then
						Local $tText = DllStructCreate("char[260]", $pText)
						If DllStructGetData($tText, 1, 2) = 0 Then _
								$tText = DllStructCreate("wchar[260]", $pText) ; to handle UNICODE string
						$sMessage &= ' ' & $sField & '="' & DllStructGetData($tText, 1) & '"'
					Else
						$sMessage &= ' ' & $sField & '=' ; no string pointed
					EndIf
				Else
					$sMessage &= " " & $sField & "=" & DllStructGetData($tInfo, $sField)
				EndIf
			Else
				$sMessage &= @CRLF & "    "
			EndIf
		Next
	EndIf
	If $sExtraFields Then $sMessage &= " " & $sExtraFields

	If $__g_idWM_NOTIFY_Memo Then
		GUICtrlSetData($__g_idWM_NOTIFY_Memo, $sMessage & @CRLF, 1)
	Else
		ConsoleWrite($sMessage & @CRLF)
	EndIf
EndFunc   ;==>_WM_NOTIFY_DebugEvent

; #NO_DOC_FUNCTION# =============================================================================================================
; Name ..........: _WM_NOTIFY_DebugInfo
; Description ...: Display String Message
; Syntax.........: _WM_NOTIFY_DebugInfo($sString, $sFields, $sFieldi, $iScriptLineNumber = @ScriptLineNumber)
; Parameters ....: $sString            - String to be displayed
;                  $sFields          - FieldName comma separated to be displayed
;                  $sFieldi          - Field  i Value
;                                      ...
;                  $iScriptLineNumber - calling line number
; Return values .: none.
; Author ........: Jpm
; Modified ......:
; Remarks .......:
; Related .......: _WM_NOTIFY_Register
; ===============================================================================================================================
Func _WM_NOTIFY_DebugInfo($sString, $sFields = "", $sField1 = "", $sField2 = "", $sField3 = "", $sField4 = "", $iScriptLineNumber = @ScriptLineNumber)
	#forceref $sField1, $sField2, $sField3, $sField4

	Local $sMessage = "@@ Debug(" & $iScriptLineNumber & ") : " & $sString

	If @NumParams = 2 Then
		$sMessage &= " " & $sFields
	Else
		Local $sField, $aFields = StringSplit($sFields, ",")
		If $sFields Then
			Local $j = 0
			For $i = 1 To $aFields[0]
				$sField = $aFields[$i]
				If $sField Then
					$j += 1
					If $j <= @NumParams - 2 Then $sMessage &= " " & $sField & "=" & Eval("sField" & $j)
				Else
					$sMessage &= @CRLF & "    "
				EndIf
			Next
		EndIf
	EndIf

	If $__g_idWM_NOTIFY_Memo Then
		GUICtrlSetData($__g_idWM_NOTIFY_Memo, $sMessage & @CRLF, 1)
	Else
		ConsoleWrite($sMessage & @CRLF)
	EndIf
EndFunc   ;==>_WM_NOTIFY_DebugInfo
