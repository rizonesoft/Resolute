#include-once


#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y										;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y								;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section


#include <ListviewConstants.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <FileConstants.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <GuiListBox.au3>
#include <GuiEdit.au3>
#include <Date.au3>

#include <WinAPITheme.au3>

#include "Localization.au3"
#include "StringEx.au3"
#include "Versioning.au3"


; #INDEX# =======================================================================================================================
; Title .........: Logging
; AutoIt Version : 3.3.12.0
; Language ......: English
; Description ...: Rizonesoft Logging System.
; Author(s) .....: Derick Payne
; Dll(s) ........:
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $LOG_SYSTEMNAME = "Rizonesoft Logging"
Global Const $LOG_VERSION = "2.0"
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $g_aLangLogging[$LNG_COUNTLOGGING]

If Not IsDeclared("g_iLoggingErrors") Then Global $g_iLoggingErrors = 0
If Not IsDeclared("g_iLoggingEnabled") Then Global $g_iLoggingEnabled = 1
If Not IsDeclared("g_WriteToLogFile") Then Global $g_WriteToLogFile = 1
If Not IsDeclared("g_ShowInterface") Then Global $g_ShowInterface = 1
If Not IsDeclared("g_sLoggingPath") Then Global $g_sLoggingPath = ""
If Not IsDeclared("g_sLoggingRoot") Then Global $g_sLoggingRoot = ""
If Not IsDeclared("g_iLoggingStorage") Then Global $g_iLoggingStorage = 5242880
If Not IsDeclared("g_hListStatus") Then Global $g_hListStatus = ""
If Not IsDeclared("g_hEditInfo") Then Global $g_hEditInfo
If Not IsDeclared("g_hImgStatus") Then Global $g_hImgStatus = ""
If Not IsDeclared("g_hTabLogging") Then Global $g_hTabLogging
If Not IsDeclared("g_hMenuFileLog") Then Global $g_hMenuFileLog
If Not IsDeclared("g_hSubHeading") Then Global $g_hSubHeading
If Not IsDeclared("g_iUpdateSubStatus") Then Global $g_iUpdateSubStatus = True
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _Logging_EditWrite
; _Logging_End
; _Logging_Initialize
; _Logging_OpenDirectory
; _Logging_OpenFile
; _Logging_SetLevel
; _Logging_Start
; _Logging_Write
; ===============================================================================================================================


Func _Logging_EditWrite($sMessage = "", $bTimePrex = True)

	Local $sTimeStamp = ""

	GUICtrlSetState($g_hListStatus, $GUI_SHOW)
	GUICtrlSetState($g_hEditInfo, $GUI_HIDE)
	GUICtrlSetState($g_hTabLogging, $GUI_SHOW)

	If $bTimePrex Then
		$sTimeStamp = "[" & @HOUR & ":" & @MIN & ":" & @SEC & ":" & @MSEC & "] "
	EndIf

	If $g_ShowInterface Then

		; 0 = Information
		; 1 = Complete
		; 2 = Error
		; 3 = Warning

		Local $iImage = 0
		Local $iErrorLen = StringLen($g_aLangLogging[32])
		Local $iWarningLen = StringLen($g_aLangLogging[33])
		Local $iSuccessLen = StringLen($g_aLangLogging[34])
		Local $iFinalLen = StringLen($g_aLangLogging[0])

		If StringLeft($sMessage, $iErrorLen) = $g_aLangLogging[32] Or _
				StringLeft($sMessage, 6) = "Error:" Or _
				__Logging_ValidateError($sMessage) Then
			$iImage = 2
			$g_iLoggingErrors += 1
		ElseIf StringLeft($sMessage, $iSuccessLen) = $g_aLangLogging[34] Or _
				StringLeft($sMessage, 8) = "Success:" Or _
				__Logging_ValidateSuccess($sMessage) Then
			$iImage = 1
		ElseIf StringLeft($sMessage, $iFinalLen) = $g_aLangLogging[0] Or _
				StringLeft($sMessage, 8) = "Finished" Then
			Switch @MON
				Case 10
					$iImage = 5
				Case 12
					$iImage = 6
				Case Else
					$iImage = 4
			EndSwitch
		ElseIf StringLeft($sMessage, $iWarningLen) = $g_aLangLogging[33] Or _
				StringLeft($sMessage, 8) = "Warning:" Or _
				StringLeft($sMessage, 1) = "^" Or _
				__Logging_ValidateWarning($sMessage) Then
			$iImage = 3
		ElseIf StringStripWS($sMessage, 8) = "" Then
			$iImage = 7
		EndIf

		_GUICtrlListView_AddItem($g_hListStatus, Chr(32) & $sMessage, $iImage)
		_GUICtrlListView_SetItemFocused($g_hListStatus, _GUICtrlListView_GetItemCount($g_hListStatus) - 1)
		_GUICtrlListView_EnsureVisible($g_hListStatus, _GUICtrlListView_GetItemCount($g_hListStatus) - 1)

	EndIf

	_Logging_Write($sMessage, $bTimePrex)

EndFunc   ;==>_Logging_EditWrite


Func _Logging_End($WriteToInterface = True, $sFinalMsg = $g_aLangLogging[0] & "!")

	GUICtrlSetState($g_hMenuFileLog, $GUI_ENABLE)
	If $g_ShowInterface Then
		_Logging_EditWrite($sFinalMsg)
	Else
		_Logging_Write($sFinalMsg)
	EndIf

	_Logging_Write("------------------------------------------------------------------------------------------", False)

EndFunc   ;==>_Logging_End


Func _Logging_FinalMessage($sMessage = $g_aLangMessages[24])

	Local $sFinalMessage = ""

	If $g_iLoggingErrors > 0 Then
		$sFinalMessage = StringFormat($g_aLangMessages[21], $g_iLoggingErrors, _
						_StringEx_ReturnPlural($g_iLoggingErrors, $g_aLangMessages[22], $g_aLangMessages[23]))
		_Logging_End(Default, _Logging_SetLevel($sFinalMessage, "ERROR"))
		GUICtrlSetColor($g_hSubHeading, 0xC80B0B)
	Else
		$sFinalMessage = $sMessage
		_Logging_End(Default, _Logging_SetLevel($sMessage, "FINISHED"))
		GUICtrlSetColor($g_hSubHeading, 0x008000)
	EndIf

	If $g_iUpdateSubStatus Then
		GUICtrlSetData($g_hSubHeading, $sFinalMessage)
	EndIf

EndFunc


; #FUNCTION# ====================================================================================================================
; Author ........: Derick Payne
; Modified.......:
; ===============================================================================================================================
Func _Logging_Initialize($sProgLogName = "")

	If $g_iLoggingEnabled == 1 Then

		_Localization_Logging()
		; MsgBox(0, "", $g_aLangLogging[0])

		; When run from a CD, we cannot perform logging.
		If DriveGetType(StringLeft(@ScriptFullPath, 3)) = "CDROM" Then
			$g_WriteToLogFile = 0
		Else

			If BitAND(__Logging_CreateRoot(), __Logging_ResetFile()) Then

				; Log file and directory seems valid. Enable logging.
				$g_WriteToLogFile = 1

				_Logging_Write("", False)
				_Logging_Write("", False)
				_Logging_Write("                                            ./", False)
				_Logging_Write("                                          (o o)", False)
				_Logging_Write("--------------------------------------oOOo-(-)-oOOo--------------------------------------", False)
				_Logging_Write("", False)
				__Logging_GetSystemInfo($sProgLogName)

			Else
				; Log file could not be created. Disable logging.
				$g_WriteToLogFile = 0
			EndIf

		EndIf

	EndIf

EndFunc   ;==>_Logging_Initialize


Func _Logging_OpenDirectory()

	_Logging_Start($g_aLangLogging[16] & ".")
	If FileExists($g_sLoggingPath) Then
		Local $iLPID = ShellExecute($g_sLoggingRoot)
		If @error Then
			_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangLogging[14], String($iLPID)), 1))
		Else
			_Logging_EditWrite(_StringEx_FirstLetterUpper($g_aLangLogging[1]) & _
					": " & StringFormat(_StringEx_FullStop($g_aLangLogging[18]), $g_sLoggingPath))

		EndIf
	Else
		_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangLogging[17], $g_sLoggingPath), 1))
	EndIf
	_Logging_FinalMessage()

EndFunc   ;==>_Logging_OpenDirectory


Func _Logging_OpenFile()

	_Logging_Start(_StringEx_FullStop($g_aLangLogging[15]))
	If FileExists($g_sLoggingPath) Then
		Local $iLPID = ShellExecute($g_sLoggingPath)
		If @error Then
			_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangLogging[14], String($iLPID)), "ERROR"))
		Else
			_Logging_EditWrite(_Logging_SetLevel(StringFormat(_StringEx_FullStop($g_aLangLogging[13]), $g_sLoggingPath), "SUCCESS"))

		EndIf
	Else
		_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangLogging[12], $g_sLoggingPath), "ERROR"))
	EndIf
	_Logging_FinalMessage()

EndFunc   ;==>_Logging_OpenFile


Func _Logging_SetLevel($sMessage, $sLevel = "")

	Switch $sLevel
		Case ""
			Return $sMessage
		Case "ERROR"
			Return $g_aLangLogging[32] & Chr(32) & $sMessage
		Case "WARNING"
			Return $g_aLangLogging[33] & Chr(32) & $sMessage
		Case "SUCCESS"
			Return $g_aLangLogging[34] & Chr(32) & $sMessage
		Case "FINISHED"
			Return $g_aLangLogging[35] & Chr(32) & $sMessage
	EndSwitch

EndFunc   ;==>_Logging_SetLevel


Func _Logging_Start($sMessage)

	If $g_iUpdateSubStatus = True Then
		GUICtrlSetData($g_hSubHeading, $sMessage)
		GUICtrlSetColor($g_hSubHeading, 0x353535)
	EndIf

	$g_iLoggingErrors = 0
	GUICtrlSetState($g_hMenuFileLog, $GUI_DISABLE)
	__Logging_Clear()
	If $g_ShowInterface Then
		_Logging_EditWrite($sMessage)
	Else
		_Logging_Write($sMessage)
	EndIf
	_Logging_Write("------------------------------------------------------------------------------------------", False)

EndFunc   ;==>_Logging_Start


Func _Logging_Write($sData = "", $bTimePrex = True)

	If $g_iLoggingEnabled = 1 Then

		If __Logging_ResetFile() And $g_WriteToLogFile = 1 Then

			Local $hLogOpen = FileOpen($g_sLoggingPath, $FO_APPEND)
			If $hLogOpen = -1 Then
				; Log file could not be opened. Disable logging.
				$g_WriteToLogFile = 0
				Return 0
			EndIf

			Local $sTimePrex = ""
			If $bTimePrex Then $sTimePrex = __Logging_GenerateTimePrefix(0) & Chr(32)

			FileWriteLine($hLogOpen, $sTimePrex & $sData & @CRLF)
			FileClose($hLogOpen)

		EndIf

		$g_WriteToLogFile = 1
		Return 1

	EndIf

EndFunc   ;==>_Logging_Write


Func __Logging_Clear()

	_GUICtrlListView_BeginUpdate($g_hListStatus)
	_GUICtrlListView_DeleteAllItems($g_hListStatus)
	_GUICtrlListView_EndUpdate($g_hListStatus)

EndFunc   ;==>__Logging_Clear


; #FUNCTION# ====================================================================================================================
; Name...........: __Logging_CreateFile
; Return values .: Success: 1
;                  Failure: 0
; Author ........: Derick Payne
; ===============================================================================================================================
Func __Logging_CreateFile()

	If $g_iLoggingEnabled = 1 Then

		If FileExists($g_sLoggingPath) Then
			Return 1
		Else
			If FileWrite($g_sLoggingPath, "=========================================================================================" & @CRLF & _
					" " & StringUpper($LOG_SYSTEMNAME) & Chr(32) & $g_aLangLogging[11] & Chr(32) & $LOG_VERSION & @CRLF & _
					"=========================================================================================" & @CRLF & _
					"") Then
				Return 1
			EndIf
		EndIf

		Return 0

	EndIf

EndFunc   ;==>__Logging_CreateFile


; #FUNCTION# ====================================================================================================================
; Name...........: __Logging_CreateRoot
; Return values .: Success: 1
;                  Failure: 0
; Author ........: Derick Payne
; ===============================================================================================================================
Func __Logging_CreateRoot()

	If FileExists($g_sLoggingRoot) Then
		Return 1
	Else
		If DirCreate($g_sLoggingRoot) Then Return 1
	EndIf

	SetError(1, 0, 0)

EndFunc   ;==>__Logging_CreateRoot


Func __Logging_GenerateTimePrefix($iFlag = 0, $bFormat = 1)

	Local $sReturn = ""

	Switch $iFlag
		Case 0
			$sReturn = _NowDate() & " " & _NowTime(5)
		Case 1
			$sReturn = _NowDate()
		Case 2
			$sReturn = _NowTime(5)
		Case 3
			$sReturn = _NowTime(5) & ":" & @MSEC
	EndSwitch

	If $bFormat Then
		Return StringFormat("[ %s ]", $sReturn)
	Else
		Return $sReturn
	EndIf

EndFunc   ;==>__Logging_GenerateTimePrefix


Func __Logging_GetSystemInfo($sProgLogName = "")

	Local $aRAMStats = MemGetStats()

	_Logging_Write(StringFormat(StringUpper($g_aLangLogging[21]) & _StringEx_CalcTab($g_aLangLogging[21]) & " %s", __Logging_GenerateTimePrefix(0, False)))
	_Logging_Write(StringFormat(StringUpper($g_aLangLogging[22]) & _StringEx_CalcTab($g_aLangLogging[22]) & " %s", $sProgLogName & Chr(32) & _GetProgramVersion(0)))
	_Logging_Write(StringFormat(StringUpper($g_aLangLogging[23]) & _StringEx_CalcTab($g_aLangLogging[23]) & " %s", "[" & @ScriptFullPath & "]"))
	_Logging_Write(StringFormat(StringUpper($g_aLangLogging[24]) & _StringEx_CalcTab($g_aLangLogging[24]) & " %s", StringUpper(__Logging_StringFromBoolean(@Compiled))))
	If Not @Compiled Then
		_Logging_Write(StringFormat(StringUpper($g_aLangLogging[25]) & _StringEx_CalcTab($g_aLangLogging[25]) & " %s", @AutoItVersion))
		_Logging_Write(StringFormat(StringUpper($g_aLangLogging[26]) & _StringEx_CalcTab($g_aLangLogging[26]) & " %s", StringUpper(__Logging_StringFromBoolean(@AutoItX64))))
	EndIf
	_Logging_Write(StringFormat(StringUpper($g_aLangLogging[27]) & _StringEx_CalcTab($g_aLangLogging[27]) & " %s", _GetWindowsVersion() & " " & @OSServicePack))
	_Logging_Write(StringFormat(StringUpper($g_aLangLogging[28]) & _StringEx_CalcTab($g_aLangLogging[28]) & " %s", StringReplace(@OSArch, "X", "") & "-Bit Operating System"))
	_Logging_Write(StringFormat(StringUpper($g_aLangLogging[29]) & _StringEx_CalcTab($g_aLangLogging[29]) & " %s", Round(($aRAMStats[1] / 1024), 2) & " MB"))
	_Logging_Write(StringFormat(StringUpper($g_aLangLogging[30]) & _StringEx_CalcTab($g_aLangLogging[30]) & " %s", @ProgramFilesDir))
	_Logging_Write(StringFormat(StringUpper($g_aLangLogging[31]) & _StringEx_CalcTab($g_aLangLogging[31]) & " %s", @WindowsDir))
	_Logging_Write("-----------------------------------------------------------------------------------------", False)
	_Logging_Write("", False)

EndFunc   ;==>__Logging_GetSystemInfo


; #FUNCTION# ====================================================================================================================
; Name...........: __Logging_ResetFile
; Return values .: Success: 1
;                  Failure: 0
; Author ........: Derick Payne
; ===============================================================================================================================
Func __Logging_ResetFile()

	If FileExists($g_sLoggingPath) Then
		If FileGetSize($g_sLoggingPath) >= $g_iLoggingStorage Then
			If FileDelete($g_sLoggingPath) Then Return 1
		Else
			If FileSetAttrib($g_sLoggingPath, "-RSH") Then Return 1
		EndIf
	Else
		If __Logging_CreateFile() Then Return 1
	EndIf

	Return 0

EndFunc   ;==>__Logging_ResetFile


Func __Logging_StringFromBoolean($bBoolean)

	If $bBoolean = 1 Then
		Return $g_aLangLogging[19]
	ElseIf $bBoolean = 0 Then
		Return $g_aLangLogging[20]
	EndIf

EndFunc   ;==>__Logging_StringFromBoolean


Func __Logging_ValidateError($sMessage)

	Local $sErrorStrings = "error |failed|1 error|" & _
			$g_aLangLogging[7] & " |" & $g_aLangLogging[8] & "|1 " & $g_aLangLogging[7]

	Local $aErrorStrings = StringSplit($sErrorStrings, "|")

	For $s = 1 To $aErrorStrings[0]
		If StringInStr($sMessage, $aErrorStrings[$s]) Then
			Return True
		EndIf
	Next

EndFunc   ;==>__Logging_ValidateError


Func __Logging_ValidateRegistry($sMessage)

	Local $sRegistryStrings = "RegSvr32.exe: ["
	Local $aRegistryStrings = StringSplit($sRegistryStrings, "|")

	For $s = 1 To $aRegistryStrings[0]
		If StringInStr($sMessage, $aRegistryStrings[$s]) Then
			Return True
		EndIf
	Next

EndFunc   ;==>__Logging_ValidateRegistry


Func __Logging_ValidateSuccess($sMessage)

	Local $sSuccessStrings = "success|Response Received|Successfully|OK!|Registration succeeded|Initiated|" & _
			$g_aLangLogging[1] & "|" & $g_aLangLogging[2] & "|" & $g_aLangLogging[3] & "|" & _
			$g_aLangLogging[4] & "!|" & $g_aLangLogging[5] & "|" & $g_aLangLogging[6]
	Local $aSuccessStrings = StringSplit($sSuccessStrings, "|")

	For $s = 1 To $aSuccessStrings[0]
		If StringInStr($sMessage, $aSuccessStrings[$s]) Then
			Return True
		EndIf
	Next

EndFunc   ;==>__Logging_ValidateSuccess


Func __Logging_ValidateWarning($sMessage)

	Local $sWarningStrings = "Access is denied|No operation can be performed|" & _
			$g_aLangLogging[9] & "|" & $g_aLangLogging[10]

	Local $aWarningStrings = StringSplit($sWarningStrings, "|")

	For $s = 1 To $aWarningStrings[0]
		If StringInStr($sMessage, $aWarningStrings[$s]) Then
			Return True
		EndIf
	Next

EndFunc   ;==>__Logging_ValidateWarning
