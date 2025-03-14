#include-once

#include "ArrayDisplayInternals.au3"
#include "AutoItConstants.au3"
#include "MsgBoxConstants.au3"
#include "SendMessage.au3"
#include "StringConstants.au3"
#include "WinAPIError.au3"

; #INDEX# =======================================================================================================================
; Title .........: Debug
; AutoIt Version : 3.3.16.1
; Language ......: English
; Description ...: Functions to help script debugging.
; Author(s) .....: Nutster, Jpm, Valik, guinness, water
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__g_sReportWindowText_Debug = "Debug Window hidden text"
Global Const $__g_sReportCallBack_DebugReport_Debug = _DebugReport
; ===============================================================================================================================

; #VARIABLE# ====================================================================================================================
Global $__g_sReportTitle_Debug = "AutoIt Debug Report"
Global $__g_iReportType_Debug = 0
Global $__g_bReportWindowWaitClose_Debug = True, $__g_bReportWindowClosed_Debug = True
Global $__g_hReportEdit_Debug = 0
Global $__g_hReportNotepadEdit_Debug = 0
Global $__g_sReportCallBack_Debug
Global $__g_bReportTimeStamp_Debug = False
Global $__g_bComErrorExit_Debug = False, $__g_oComError_Debug = Null
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _Assert
; _DebugArrayDisplay
; _DebugBugReportEnv
; _DebugCOMError
; _DebugOut
; _DebugReport
; _DebugReportEx
; _DebugReportVar
; _DebugSetup
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; __Debug_COMErrorHandler
; __Debug_DataFormat
; __Debug_DataType
; __Debug_ReportClose
; __Debug_ReportWrite
; __Debug_ReportWindowCreate
; __Debug_ReportWindowWrite
; __Debug_ReportWindowWaitClose
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Author ........: Valik
; Modified.......: jpm
; ===============================================================================================================================
Func _Assert($sCondition, $bExit = True, $iCode = 0x7FFFFFFF, $sLine = @ScriptLineNumber, Const $_iCallerError = @error, Const $_iCallerExtended = @extended)
	Local $bCondition = Execute($sCondition)
	If Not $bCondition Then
		Local $sOutput = "Assertion Failed (Line " & $sLine & "): " & @CRLF & @CRLF & $sCondition
		If _DebugOut(StringReplace($sOutput, @CRLF, "")) = 0 Then ; _DebugSetup() as not been called.
			MsgBox($MB_SYSTEMMODAL, "AutoIt Assert", $sOutput)
		Else
			$bExit = False
		EndIf
		If $bExit Then Exit $iCode
	EndIf
	Return SetError($_iCallerError, $_iCallerExtended, $bCondition)
EndFunc   ;==>_Assert

; #FUNCTION# ====================================================================================================================
; Author ........: Melba23
; Modified.......: jpm
; ===============================================================================================================================
Func _DebugArrayDisplay(Const ByRef $aArray, $sTitle = Default, $sArrayRange = Default, $iFlags = Default, $vUser_Separator = Default, $sHeader = Default, $iDesired_Colwidth = Default, $hUser_Function = Default, Const $_iCallerScriptLineNumber = @ScriptLineNumber, Const $_iCallerError = @error, Const $_iCallerExtended = @extended)
	Local $iRet = -1
	While $iRet = -1 ; to retry in case UserFunction was used
		$iRet = __ArrayDisplay_Share($aArray, $sTitle, $sArrayRange, $iFlags, $vUser_Separator, $sHeader, $iDesired_Colwidth, $hUser_Function, True, $_iCallerScriptLineNumber, $_iCallerError, $_iCallerExtended)
	WEnd
	Return SetError(@error, @extended, $iRet)
EndFunc   ;==>_DebugArrayDisplay

; #FUNCTION# ====================================================================================================================
; Author ........: jpm
; Modified.......:
; ===============================================================================================================================
Func _DebugBugReportEnv(Const $_iCallerError = @error, Const $_iCallerExtended = @extended)
	Local $sAutoItX64, $sAdminMode, $sCompiled, $sOsServicePack, $sMUIlang, $sKBLayout, $sCPUArch
	If @AutoItX64 Then $sAutoItX64 = "/X64"
	If IsAdmin() Then $sAdminMode = ", AdminMode"
	If @Compiled Then $sCompiled = ", Compiled"
	If @OSServicePack Then $sOsServicePack = "/" & StringReplace(@OSServicePack, "Service Pack ", "SP")
	If @OSLang <> @MUILang Then $sMUIlang = ", MUILang: " & @MUILang
	If @OSLang <> StringRight(@KBLayout, 4) Then $sKBLayout = ", Keyboard: " & @KBLayout
	If @OSArch <> @CPUArch Then $sCPUArch = ", CPUArch: " & @CPUArch
	Return SetError($_iCallerError, $_iCallerExtended, "AutoIt: " & @AutoItVersion & $sAutoItX64 & $sAdminMode & $sCompiled & _
			", OS: " & @OSVersion & $sOsServicePack & "/" & @OSArch & _
			", OSLang: " & @OSLang & $sMUIlang & $sKBLayout & $sCPUArch & @CRLF & _
			"  Script: " & @ScriptFullPath)
EndFunc   ;==>_DebugBugReportEnv

; #FUNCTION# ====================================================================================================================
; Author ........: water
; Modified ......: jpm
; ===============================================================================================================================
Func _DebugCOMError($iComDebug = Default, $bExit = False)
	If $__g_iReportType_Debug <= 0 Or $__g_iReportType_Debug > 6 Then Return SetError(3, 0, 0)
	If $iComDebug = Default Then $iComDebug = 1
	If Not IsInt($iComDebug) Or $iComDebug < -1 Or $iComDebug > 1 Then Return SetError(1, 0, 0)
	Switch $iComDebug
		Case -1
			Return SetError(IsObj($__g_oComError_Debug), $__g_bComErrorExit_Debug, 1)
		Case 0
			If $__g_oComError_Debug = Null Then SetError(0, 3, 1) ; COM error handler already disabled
			$__g_oComError_Debug = Null
			$__g_bComErrorExit_Debug = False
			Return 1
		Case Else
			; A COM error handler will be initialized only if one does not exist
			$__g_bComErrorExit_Debug = $bExit
			Local $vComErrorChecking = ObjEvent("AutoIt.Error")
			If $vComErrorChecking = "" Then
				$__g_oComError_Debug = ObjEvent("AutoIt.Error", __Debug_COMErrorHandler) ; Creates a custom error handler
				If @error Then Return SetError(4, @error, 0)
				Return SetError(0, 1, 1)
			ElseIf FuncName($vComErrorChecking) = FuncName(__Debug_COMErrorHandler) Then
				Return SetError(0, 2, 1) ; COM error handler already set by a previous call to this function
			Else
				Return SetError(2, 0, 0) ; COM error handler already set to another function - not by this UDF
			EndIf
	EndSwitch
EndFunc   ;==>_DebugCOMError

; #FUNCTION# ====================================================================================================================
; Author ........: Nutster
; Modified.......: jpm
; ===============================================================================================================================
Func _DebugOut(Const $sOutput, Const $_iCallerError = @error, Const $_iCallerExtended = @extended)
	If $__g_iReportType_Debug <= 0 Or $__g_iReportType_Debug > 6 Then Return SetError(3, 0, 0) ; _DebugSetup() as not been called.
	If IsNumber($sOutput) = 0 And IsString($sOutput) = 0 And IsBool($sOutput) = 0 Then Return SetError(1, 0, 0) ; $sOutput can not be printed

	__Debug_ReportWrite($sOutput & @CRLF)

	Return SetError($_iCallerError, $_iCallerExtended, 1) ; Return @error and @extended as before calling _DebugOut()
EndFunc   ;==>_DebugOut

; #FUNCTION# ====================================================================================================================
; Author ........: jpm
; Modified.......: guinness
; ===============================================================================================================================
Func _DebugSetup(Const $sTitle = Default, $bBugReportInfos = Default, $vReportType = Default, $sLogFile = Default, $bTimeStamp = False, Const $_iCallerError = @error, $_iCallerExtended = @extended)
	If $__g_iReportType_Debug Then Return SetError($_iCallerError + 1000, $_iCallerExtended, $__g_iReportType_Debug) ; already registered
	If $bBugReportInfos = Default Then $bBugReportInfos = False
	If $vReportType = Default Then $vReportType = 1
	If $sLogFile = Default Then $sLogFile = ""
	Switch $vReportType
		Case 1
			; Report Log window
			#forceref __Debug_ReportWindowWrite
			$__g_sReportCallBack_Debug = "__Debug_ReportWindowWrite("
		Case 2
			; ConsoleWrite
			$__g_sReportCallBack_Debug = "ConsoleWrite("
		Case 3
			; Message box
			$__g_sReportCallBack_Debug = "MsgBox(4096, '" & $__g_sReportTitle_Debug & "',"
		Case 4
			; Log file
			$__g_sReportCallBack_Debug = "FileWrite('" & $sLogFile & "',"
		Case 5
			; Report notepad window
			#forceref __Debug_ReportNotepadWrite
			$__g_sReportCallBack_Debug = "__Debug_ReportNotepadWrite("
		Case Else
			If Not IsString($vReportType) Then Return SetError(2, 0, 0) ; invalid Report type
			; private callback
			If $vReportType = "" Then Return SetError(3, 0, 0) ; invalid callback function
			$__g_sReportCallBack_Debug = $vReportType & "("
			$vReportType = 6
	EndSwitch

	If Not ($sTitle = Default) Then $__g_sReportTitle_Debug = $sTitle
	$__g_iReportType_Debug = $vReportType
	$__g_bReportTimeStamp_Debug = $bTimeStamp

	OnAutoItExitRegister("__Debug_ReportClose")

	If $bBugReportInfos Then _DebugReport(_DebugBugReportEnv() & @CRLF & @CRLF)

	Return SetError($_iCallerError, $_iCallerExtended, $__g_iReportType_Debug)
EndFunc   ;==>_DebugSetup

; #FUNCTION# ====================================================================================================================
; Author ........: jpm
; Modified.......:
; ===============================================================================================================================
Func _DebugReport($sData, $bLastError = False, $bExit = False, Const $_iCallerError = @error, $_iCallerExtended = @extended)
	If $__g_iReportType_Debug <= 0 Or $__g_iReportType_Debug > 6 Then Return SetError($_iCallerError, $_iCallerExtended, 0)

	Local $iLastError = _WinAPI_GetLastError()
	__Debug_ReportWrite($sData, $bLastError, $iLastError)

	If $bExit Then Exit

	_WinAPI_SetLastError($iLastError)
	If $bLastError Then $_iCallerExtended = $iLastError

	Return SetError($_iCallerError, $_iCallerExtended, 1)
EndFunc   ;==>_DebugReport

; #FUNCTION# ====================================================================================================================
; Author ........: jpm
; Modified.......:
; ===============================================================================================================================
Func _DebugReportEx($sData, $bLastError = False, $bExit = False, Const $_iCallerError = @error, $_iCallerExtended = @extended)
	If $__g_iReportType_Debug <= 0 Or $__g_iReportType_Debug > 6 Then Return SetError($_iCallerError, $_iCallerExtended, 0)

	Local $iLastError = _WinAPI_GetLastError()
	If IsInt($_iCallerError) Then
		Local $sTemp = StringSplit($sData, "|", $STR_ENTIRESPLIT + $STR_NOCOUNT)
		If UBound($sTemp) > 1 Then
			If $bExit Then
				$sData = "<<< "
			Else
				$sData = ">>> "
			EndIf

			Switch $_iCallerError
				Case 0
					$sData &= "Bad return from " & $sTemp[1] & " in " & $sTemp[0] & ".dll"
				Case 1
					$sData &= "Unable to open " & $sTemp[0] & ".dll"
				Case 3
					$sData &= "Unable to find " & $sTemp[1] & " in " & $sTemp[0] & ".dll"
			EndSwitch
			If Not $bLastError Then $sData &= @CRLF
		EndIf
	EndIf

	__Debug_ReportWrite($sData, $bLastError, $iLastError)

	If $bExit Then Exit

	_WinAPI_SetLastError($iLastError)
	If $bLastError Then $_iCallerExtended = $iLastError

	Return SetError($_iCallerError, $_iCallerExtended, 1)
EndFunc   ;==>_DebugReportEx

; #FUNCTION# ====================================================================================================================
; Author ........: jpm
; Modified.......:
; ===============================================================================================================================
Func _DebugReportVar($sVarName, $vVar, $bErrExt = False, Const $iDebugLineNumber = @ScriptLineNumber, Const $_iCallerError = @error, Const $_iCallerExtended = @extended)
	If $__g_iReportType_Debug <= 0 Or $__g_iReportType_Debug > 6 Then Return SetError($_iCallerError, $_iCallerExtended, 0)

	Local $iLastError = _WinAPI_GetLastError()
	If IsBool($vVar) And IsInt($bErrExt) Then
		; to kept some compatibility with 3.3.1.3 if really needed for non breaking
		If StringLeft($sVarName, 1) = "$" Then $sVarName = StringTrimLeft($sVarName, 1)
		$vVar = Eval($sVarName)
		$sVarName = "???"
	EndIf

	Local $sData = "@@ Debug(" & $iDebugLineNumber & ") : " & __Debug_DataType($vVar) & " -> " & $sVarName

	If IsArray($vVar) Then
		Local $nDims = UBound($vVar, $UBOUND_DIMENSIONS)
		Local $nRows = UBound($vVar, $UBOUND_ROWS)
		Local $nCols = UBound($vVar, $UBOUND_COLUMNS)
		For $d = 1 To $nDims
			$sData &= "[" & UBound($vVar, $d) & "]"
		Next

		If $nDims <= 3 Then
			For $r = 0 To $nRows - 1
				$sData &= @CRLF & @TAB & "[" & $r & "] "
				If $nDims = 1 Then
					$sData &= __Debug_DataFormat($vVar[$r]) & @TAB
				ElseIf $nDims = 2 Then
					For $c = 0 To $nCols - 1
						$sData &= __Debug_DataFormat($vVar[$r][$c]) & @TAB
					Next
				Else
					For $c = 0 To $nCols - 1
;~ 						$sData &= @CRLF & @TAB & "[" & $r & "] " & "[" & $c & "] "
						$sData &= @CRLF & @TAB & "    " & "[" & $c & "] "
						For $k = 0 To UBound($vVar, 3) - 1
							$sData &= __Debug_DataFormat($vVar[$r][$c][$k]) & @TAB
						Next
					Next
				EndIf
			Next
		EndIf
	ElseIf IsDllStruct($vVar) Then
		Local $aArray[2], $sStruct = ""
		Local $i = -1
		While 1
			$i += 1
			If $i = UBound($aArray) Then ReDim $aArray[$i + UBound($aArray)]
			$aArray[$i] = DllStructGetData($vVar, $i + 1)
			If @error Then ExitLoop
			$sStruct &= VarGetType($aArray[$i]) & "; "
		WEnd
		ReDim $aArray[$i]
		$sData &= ' ("' & StringTrimRight($sStruct, 2) & '")'
		For $r = 0 To UBound($aArray) - 1
			$sData &= @CRLF & @TAB & "#" & $r + 1 & " "
			$sData &= __Debug_DataFormat($aArray[$r])
		Next
	ElseIf IsObj($vVar) Then
	Else
		$sData &= ' = ' & __Debug_DataFormat($vVar)
	EndIf

	If $bErrExt Then $sData &= @CRLF & @TAB & "@error=" & $_iCallerError & " @extended=0x" & Hex($_iCallerExtended)

	__Debug_ReportWrite($sData & @CRLF)

	_WinAPI_SetLastError($iLastError)
	Return SetError($_iCallerError, $_iCallerExtended)
EndFunc   ;==>_DebugReportVar

; #INTERNAL_USE_ONLY#============================================================================================================
; Name ..........: __Debug_COMErrorHandler
; Description ...: Called when a COM error occurs and writes the error message with _DebugOut().
; Syntax.........: __Debug_COMErrorHandler ( $oCOMError )
; Parameters ....: $oCOMError - Error object
; Return values .: None
; Author ........: water
; Modified ......: jpm
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Debug_COMErrorHandler($oCOMError)
	_DebugReport(__COMErrorFormating($oCOMError), False, $__g_bComErrorExit_Debug)
EndFunc   ;==>__Debug_COMErrorHandler

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Debug_DataFormat
; Description ...: Returns a formatted data
; Syntax.........: __Debug_DataFormat ( $vData )
; Parameters ....: $vData - a data to be formatted
; Return values .: the data truncated if needed or the Datatype for not editable as Dllstruct, Obj or Array
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Debug_DataFormat($vData)
	Local $nLenMax = 25 ; to truncate String, Binary
	Local $sTruncated = ""
	If IsString($vData) Then
		If StringLen($vData) > $nLenMax Then
			$vData = StringLeft($vData, $nLenMax)
			$sTruncated = " ..."
		EndIf
		Return '"' & $vData & '"' & $sTruncated
	ElseIf IsBinary($vData) Then
		If BinaryLen($vData) > $nLenMax Then
			$vData = BinaryMid($vData, 1, $nLenMax)
			$sTruncated = " ..."
		EndIf
		Return $vData & $sTruncated
	ElseIf IsDllStruct($vData) Or IsArray($vData) Or IsMap($vData) Or IsObj($vData) Then
		Return __Debug_DataType($vData)
	Else
		Return $vData
	EndIf
EndFunc   ;==>__Debug_DataFormat

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Debug_DataType
; Description ...: Truncate a data
; Syntax.........: __Debug_DataType ( $vData )
; Parameters ....: $vData - a data
; Return values .: the data truncated if needed
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Debug_DataType($vData)
	Local $sType = VarGetType($vData)
	Switch $sType
		Case "DllStruct"
			$sType &= ":" & DllStructGetSize($vData)
		Case "Array"
			$sType &= " " & UBound($vData, $UBOUND_DIMENSIONS) & "D"
		Case "Map"
			Local $aMapKeys = MapKeys($vData)
			$sType &= ":" & UBound($aMapKeys)
		Case "String"
			$sType &= ":" & StringLen($vData)
		Case "Binary"
			$sType &= ":" & BinaryLen($vData)
		Case "Ptr"
			If IsHWnd($vData) Then $sType = "Hwnd"
	EndSwitch
	Return "{" & $sType & "}"
EndFunc   ;==>__Debug_DataType

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Debug_ReportClose
; Description ...: Close the debug session
; Syntax.........: __Debug_ReportClose ( )
; Parameters ....:
; Return values .:
; Author ........: jpm
; Modified.......: guinness
; Remarks .......: If a specific reporting function has been registered then it is called without parameter.
; Related .......: _DebugSetup
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Debug_ReportClose()
	If $__g_iReportType_Debug = 1 Then
		If Not $__g_bReportWindowClosed_Debug Then
			WinSetOnTop($__g_sReportTitle_Debug, "", 1)
			_DebugReport(@CRLF & '>>>>>> Please close the "Report Log Window" to exit <<<<<<<' & @CRLF)
			__Debug_ReportWindowWaitClose()
		EndIf
	ElseIf $__g_iReportType_Debug = 6 Then
		Execute($__g_sReportCallBack_Debug & ")")
	EndIf

	$__g_iReportType_Debug = 0
EndFunc   ;==>__Debug_ReportClose

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Debug_ReportWindowCreate
; Description ...: Create an report log window
; Syntax.........: __Debug_ReportWindowCreate ( )
; Parameters ....:
; Return values .: 0 if already created
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Debug_ReportWindowCreate()
	Local $nOld = Opt("WinDetectHiddenText", $OPT_MATCHSTART)
	Local $bExists = WinExists($__g_sReportTitle_Debug, $__g_sReportWindowText_Debug)

	If $bExists Then
		If $__g_hReportEdit_Debug = 0 Then
			; first time we try to access an open window in the running script,
			; get the control handle needed for writing in
			$__g_hReportEdit_Debug = ControlGetHandle($__g_sReportTitle_Debug, $__g_sReportWindowText_Debug, "Edit1")
			; force no closing no waiting on report closing
			$__g_bReportWindowWaitClose_Debug = False
		EndIf
	EndIf

	Opt("WinDetectHiddenText", $nOld)

	; change the state of the report Window as it is already opened or will be
	$__g_bReportWindowClosed_Debug = False
	If Not $__g_bReportWindowWaitClose_Debug Then Return 0 ; use of the already opened window

	Local Const $WS_OVERLAPPEDWINDOW = 0x00CF0000
	Local Const $WS_HSCROLL = 0x00100000
	Local Const $WS_VSCROLL = 0x00200000
	Local Const $ES_READONLY = 2048
	Local Const $EM_LIMITTEXT = 0xC5
	Local Const $GUI_HIDE = 32

	; Variables used to control different aspects of the GUI.
	Local $w = 580, $h = 380

	GUICreate($__g_sReportTitle_Debug, $w, $h, -1, -1, $WS_OVERLAPPEDWINDOW)
	; We use a hidden label with unique test so we can reliably identify the window.
	Local $idLabelHidden = GUICtrlCreateLabel($__g_sReportWindowText_Debug, 0, 0, 1, 1)
	GUICtrlSetState($idLabelHidden, $GUI_HIDE)
	Local $idEdit = GUICtrlCreateEdit("", 4, 4, $w - 8, $h - 8, BitOR($WS_HSCROLL, $WS_VSCROLL, $ES_READONLY))
	$__g_hReportEdit_Debug = GUICtrlGetHandle($idEdit)
	GUICtrlSetBkColor($idEdit, 0xFFFFFF)
	GUICtrlSendMsg($idEdit, $EM_LIMITTEXT, 0, 0) ; Max the size of the edit control.

	GUISetState()

	; by default report closing will wait closing by user
	$__g_bReportWindowWaitClose_Debug = True
	Return 1
EndFunc   ;==>__Debug_ReportWindowCreate

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Debug_ReportWindowWrite
; Description ...: Append text to the report log window
; Syntax.........: __Debug_ReportWindowWrite ( $sData )
; Parameters ....: $sData text to be append to the window
; Return values .:
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
#Au3Stripper_Ignore_Funcs=__Debug_ReportWindowWrite
Func __Debug_ReportWindowWrite($sData)
	If $__g_bReportWindowClosed_Debug Then __Debug_ReportWindowCreate()

	Local Const $WM_GETTEXTLENGTH = 0x000E
	Local Const $EM_SETSEL = 0xB1
	Local Const $EM_REPLACESEL = 0xC2

	Local $nLen = _SendMessage($__g_hReportEdit_Debug, $WM_GETTEXTLENGTH, 0, 0, 0, "int", "int")
	_SendMessage($__g_hReportEdit_Debug, $EM_SETSEL, $nLen, $nLen, 0, "int", "int")
	_SendMessage($__g_hReportEdit_Debug, $EM_REPLACESEL, True, $sData, 0, "int", "wstr")
EndFunc   ;==>__Debug_ReportWindowWrite

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Debug_ReportWindowWaitClose
; Description ...: Wait the closing of the report log window
; Syntax.........: __Debug_ReportWindowWaitClose ( )
; Parameters ....:
; Return values .:
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Debug_ReportWindowWaitClose()
	If Not $__g_bReportWindowWaitClose_Debug Then Return 0 ; use of the already opened window so no need to wait
	Local $nOld = Opt("WinDetectHiddenText", $OPT_MATCHSTART)
	Local $hWndReportWindow = WinGetHandle($__g_sReportTitle_Debug, $__g_sReportWindowText_Debug)
	Opt("WinDetectHiddenText", $nOld)

	$nOld = Opt('GUIOnEventMode', 0) ; save event mode in case user script was using event mode
	Local Const $GUI_EVENT_CLOSE = -3
	Local $aMsg
	While WinExists(HWnd($hWndReportWindow))
		$aMsg = GUIGetMsg(1)
		If $aMsg[1] = $hWndReportWindow And $aMsg[0] = $GUI_EVENT_CLOSE Then GUIDelete($hWndReportWindow)
	WEnd
	Opt('GUIOnEventMode', $nOld) ; restore event mode

	$__g_hReportEdit_Debug = 0
	$__g_bReportWindowWaitClose_Debug = True
	$__g_bReportWindowClosed_Debug = True
EndFunc   ;==>__Debug_ReportWindowWaitClose

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Debug_ReportNotepadCreate
; Description ...: Create an report log window
; Syntax.........: __Debug_ReportNotepadCreate ( )
; Parameters ....:
; Return values .: 0 if already created
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Debug_ReportNotepadCreate()
	Local $bExists = WinExists($__g_sReportTitle_Debug)

	If $bExists Then
		If $__g_hReportEdit_Debug = 0 Then
			; first time we try to access an open window in the running script,
			; get the control handle needed for writing in
			$__g_hReportEdit_Debug = WinGetHandle($__g_sReportTitle_Debug)
			Return 0 ; use of the already opened window
		EndIf
	EndIf

	Local $pNotepad = Run("Notepad.exe") ; process ID of the Notepad started by this function
	$__g_hReportEdit_Debug = WinWait("[CLASS:Notepad]")
	If $pNotepad <> WinGetProcess($__g_hReportEdit_Debug) Then
		Return SetError(3, 0, 0)
	EndIf

	WinActivate($__g_hReportEdit_Debug)
	WinSetTitle($__g_hReportEdit_Debug, "", String($__g_sReportTitle_Debug))

	Return 1
EndFunc   ;==>__Debug_ReportNotepadCreate

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Debug_ReportNotepadWrite
; Description ...: Append text to the report notepad window
; Syntax.........: __Debug_ReportNotepadWrite ( $sData )
; Parameters ....: $sData text to be append to the window
; Return values .:
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
#Au3Stripper_Ignore_Funcs=__Debug_ReportNotepadWrite
Func __Debug_ReportNotepadWrite($sData)
	If $__g_hReportEdit_Debug = 0 Then __Debug_ReportNotepadCreate()

	ControlCommand($__g_hReportEdit_Debug, "", "Edit1", "EditPaste", String($sData))
EndFunc   ;==>__Debug_ReportNotepadWrite

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Debug_ReportWrite
; Description ...: Write on Report
; Syntax.........: __Debug_ReportWrite ( $sData [, $bLastError = False [, $iLastError = 0]] )
; Parameters ....:
; Return values .:
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Debug_ReportWrite($sData, $bLastError = False, $iLastError = 0)
	Local $sError = ""
	If $__g_bReportTimeStamp_Debug And ($sData <> "") Then $sData = @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " " & $sData
	If $bLastError Then
		$sError = " LastError = " & $iLastError & " : (" & _WinAPI_GetLastErrorMessage() & ")" & @CRLF
	EndIf

	$sData &= $sError

;~ 	Local $bBlock = BlockInput(1)
;~ 	BlockInput(0) ; force enable state so user can move mouse if needed

	$sData = StringReplace($sData, "'", "''") ; in case the data contains '

	; Make "Error code:" more visible
	Local Static $sERROR_CODE = ">Error code:"
	If StringInStr($sData, $sERROR_CODE) Then
		$sData = StringReplace($sData, $sERROR_CODE, @TAB & $sERROR_CODE)
		If (StringInStr($sData, $sERROR_CODE & " 0") = 0) Then
			; Make "Error code:" different from 0 even more visible
			$sData = StringReplace($sData, $sERROR_CODE, $sERROR_CODE & @TAB & @TAB & @TAB & @TAB)
		EndIf
	EndIf

	Execute($__g_sReportCallBack_Debug & "'" & $sData & "')")

;~ 	If Not $bBlock Then BlockInput(1) ; restore disable state

	Return
EndFunc   ;==>__Debug_ReportWrite
