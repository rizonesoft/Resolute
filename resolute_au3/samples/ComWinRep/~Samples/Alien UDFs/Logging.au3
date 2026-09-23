#include-once

#include <FileConstants.au3>
#include <GuiListBox.au3>
#include <Date.au3>

#include "CoreConstants.au3"
#include "CoreFunctions.au3"


; #INDEX# =======================================================================================================================
; Title .........: Logging
; AutoIt Version : 3.3.12.0
; Language ......: English
; Description ...: Rizonesoft Logging System.
; Author(s) .....: Derick Payne
; Dll(s) ........:
; ===============================================================================================================================


; #CURRENT# =====================================================================================================================
; _LoggingInitialize
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Author ........: Derick Payne
; Modified.......:
; ===============================================================================================================================
Func _LoggingInitialize()

	If Not IsDeclared("CONF_LOGENABLED") Then Global $CONF_LOGENABLED = 0

	; When run from a CD, we cannot perform logging.
	If DriveGetType(StringLeft(@ScriptFullPath, 3)) = "CDROM" Then
		$CONF_LOGENABLED = 0
	Else
		If BitAND(__LoggingDirCreate(), __LoggingFileReset()) Then

			; Log file and directory seems valid. Enable logging.
			$CONF_LOGENABLED = 1

			_LoggingWrite("", False)
			_LoggingWrite("", False)
			_LoggingWrite("                                            ./", False)
			_LoggingWrite("                                          (o o)", False)
			_LoggingWrite("--------------------------------------oOOo-(-)-oOOo--------------------------------------", False)
			_LoggingWrite("", False)
			_LoggingGetSystemInfo()

		Else

			; Log file could not be created. Disable logging.
			$CONF_LOGENABLED = 0

		EndIf
	EndIf

EndFunc


Func _StartLogging($sMessage)

	_ClearLogging()
	_EditLoggingWrite($sMessage, 1, 1)
	_LoggingWrite("------------------------------------------------------------------------------------------", False)

EndFunc


Func _EndLogging($sMessage = "")

	If Not IsDeclared("LBL_STATUS") Then Local $LBL_STATUS
	Local $sStatusMessage = ""

	If $sMessage <> "" Then
		$sStatusMessage = $sMessage
	Else
		$sStatusMessage = "Done :)"
	EndIf

	_EditLoggingWrite($sStatusMessage)
	_LoggingWrite("------------------------------------------------------------------------------------------", False)
	_GUICtrlFFLabel_SetData($LBL_STATUS, $sMessage)

EndFunc


Func _ClearLogging()

	If Not IsDeclared("LST_STATUS") Then Local $LST_STATUS

	_GUICtrlListBox_BeginUpdate($LST_STATUS)
	_GUICtrlListBox_ResetContent($LST_STATUS)
	_GUICtrlListBox_EndUpdate($LST_STATUS)

EndFunc


Func _EditLoggingWrite($sMessage = "", $bTimePrex = True, $bSetLabel = False)

	Local $sTimeStamp = "", $aSentences

	If Not IsDeclared("LST_STATUS") Then Local $LST_STATUS
	If Not IsDeclared("EDIT_INFO") Then Local $EDIT_INFO
	If Not IsDeclared("LBL_STATUS") Then Local $LBL_STATUS

	GUICtrlSetState($LST_STATUS, $GUI_SHOW)
	GUICtrlSetState($EDIT_INFO, $GUI_HIDE)

	If $bTimePrex Then
		$sTimeStamp = "[" & @HOUR & ":" & @MIN & ":" & @SEC & ":" & @MSEC & "] "
	EndIf

	_GUICtrlListBox_BeginUpdate($LST_STATUS)

	If StringInStr($sMessage, @CRLF) Then
		$aSentences = StringSplit($sMessage, @CRLF)
	ElseIf StringInStr($sMessage, @LF) Then
		$aSentences = StringSplit($sMessage, @LF)
	EndIf

	If IsArray($aSentences) Then
		For $x = 1 To $aSentences[0] ; Loop through the array returned by StringSplit to display the individual values.
			If __IsMessage($aSentences[$x]) Then
				_GUICtrlListBox_AddString($LST_STATUS, $sTimeStamp & $aSentences[$x])
				__SetStatusIcon($aSentences[$x])
			EndIf
		Next
	Else
		If __IsMessage($sMessage) Then
			_GUICtrlListBox_AddString($LST_STATUS, $sTimeStamp & $sMessage)
			If $bSetLabel Then _GUICtrlFFLabel_SetData($LBL_STATUS, $sMessage)
			__SetStatusIcon($sMessage)
		EndIf
	EndIf

	_GUICtrlListBox_UpdateHScroll($LST_STATUS)
	_GUICtrlListBox_SetCurSel($LST_STATUS, _GUICtrlListBox_GetCount($LST_STATUS) - 1)
	_GUICtrlListBox_EndUpdate($LST_STATUS)
	_LoggingWrite($sMessage, $bTimePrex)

		Sleep(85) ;~ We need to slow things down a little

EndFunc


Func __SetStatusIcon($sMessage)

	If Not IsDeclared("ICO_STATUSGREEN") Then Local $ICO_STATUSGREEN
	If Not IsDeclared("ICO_STATUSRED") Then Local $ICO_STATUSRED
	If Not IsDeclared("ICO_STATUSWARNING") Then Local $ICO_STATUSWARNING

	If StringRegExp($sMessage, "(?i)sucessfully|Successfully|ok|no proxy server|registration succeeded", $STR_REGEXPMATCH) Then
		GUICtrlSetImage($ICO_STATUSGREEN, @ScriptFullPath, 227)
		AdlibRegister("__ResetStatusGreenIcon", 1500)
	EndIf

	If StringRegExp($sMessage, "(?i)access is denied|failed|[:space:]error[:space:]|unsuccessful|0x80070005", $STR_REGEXPMATCH) Then
		GUICtrlSetImage($ICO_STATUSRED, @ScriptFullPath, 228)
		AdlibRegister("__ResetStatusRedIcon", 1500)
	EndIf

	If StringRegExp($sMessage, 	"(?i)no user specified settings|restart the computer|no operation can be performed|" & _
								"Specified module not found", $STR_REGEXPMATCH) Then
		GUICtrlSetImage($ICO_STATUSWARNING, @ScriptFullPath, 229)
		AdlibRegister("__ResetStatusWarningIcon", 1500)
	EndIf

EndFunc


Func __ResetStatusGreenIcon()

	If Not IsDeclared("ICO_STATUSGREEN") Then Local $ICO_STATUSGREEN
	GUICtrlSetImage($ICO_STATUSGREEN, @ScriptFullPath, 226)
	AdlibUnRegister("__ResetStatusGreenIcon")

EndFunc

Func __ResetStatusRedIcon()

	If Not IsDeclared("ICO_STATUSRED") Then Local $ICO_STATUSRED
	GUICtrlSetImage($ICO_STATUSRED, @ScriptFullPath, 226)
	AdlibUnRegister("__ResetStatusRedIcon")

EndFunc

Func __ResetStatusWarningIcon()

	If Not IsDeclared("ICO_STATUSWARNING") Then Local $ICO_STATUSWARNING
	GUICtrlSetImage($ICO_STATUSWARNING, @ScriptFullPath, 226)
	AdlibUnRegister("__ResetStatusWarningIcon")

EndFunc


Func __IsMessage($sMessage)

	If StringStripWS($sMessage, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES) <> "" Then
		Return True
	Else
		Return False
	EndIf
EndFunc


Func _LoggingWrite($sData = "", $bTimePrex = True)

	If BitAND(__LoggingFileReset(), $CONF_LOGENABLED) Then

		Local $hLogOpen = FileOpen($FILE_LOGGING, $FO_APPEND)
		If $hLogOpen = -1 Then
			; Log file could not be opened. Disable logging.
			$CONF_LOGENABLED = 0
			Return 0
		EndIf

		Local $sTimePrex= ""
		If $bTimePrex Then $sTimePrex = __GenerateTimePrefix(0) & Chr(32)

		FileWriteLine($hLogOpen, $sTimePrex & $sData & @CRLF)
		FileClose($hLogOpen)

	EndIf

	$CONF_LOGENABLED = 1
	Return 1

EndFunc


Func _LoggingGetSystemInfo()

	Local $aRAMStats = MemGetStats()

	_LoggingWrite(StringFormat(	"DATE:              %s", __GenerateTimePrefix(0, False)))
	_LoggingWrite(StringFormat(	"PROGRAM:           %s", $PROG_NAME & Chr(32) & FileGetVersion(@ScriptFullPath)))
	_LoggingWrite(StringFormat( "PROGRAM PATH:      %s", "[" & @ScriptFullPath & "]"))
	_LoggingWrite(StringFormat( "COMPILED:          %s", __StringFromBoolean(@Compiled)))
	If Not @Compiled Then
		_LoggingWrite(StringFormat( "AUTOIT VERSION:    %s", @AutoItVersion))
		_LoggingWrite(StringFormat( "AUTOIT 64-BIT:     %s", __StringFromBoolean(@AutoItX64)))
	EndIf
	_LoggingWrite(StringFormat(	"WINDOWS VERSION:   %s", _GetWindowsVersion(@OSVersion) & " " & @OSServicePack))
	_LoggingWrite(StringFormat(	"SYSTEM TYPE:       %s", StringReplace(@OSArch, "X", "") & "-Bit Operating System"))
	_LoggingWrite(StringFormat(	"MEMORY (RAM):      %s", Round(($aRAMStats[1] /1024), 2) & " MB"))
	_LoggingWrite(StringFormat(	"PROGRAM FILES:     %s", @ProgramFilesDir))
	_LoggingWrite(StringFormat(	"WINDOWS DIRECTORY: %s", @WindowsDir))
	_LoggingWrite("-----------------------------------------------------------------------------------------", False)
	_LoggingWrite("", False)

EndFunc


Func __StringFromBoolean($bBoolean)

	If $bBoolean = 1 Then
		Return "YES"
	ElseIf $bBoolean = 0 Then
		Return "NO"
	EndIf

EndFunc


Func __GenerateTimePrefix($iFlag = 0, $bFormat = 1)

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

EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: __LoggingFileCreate
; Return values .: Success: 1
;                  Failure: 0
; Author ........: Derick Payne
; ===============================================================================================================================
Func __LoggingFileCreate()

		If FileExists($FILE_LOGGING) Then
			Return 1
		Else
			If FileWrite($FILE_LOGGING, "=========================================================================================" & @CRLF & _
										" " & StringUpper($LOGSYS_NAME) & " VERSION " & $LOGSYS_VERSION & @CRLF & _
										"=========================================================================================" & @CRLF & _
										"") Then
				Return 1
			EndIf
		EndIf

		Return 0

EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: __LoggingFileReset
; Return values .: Success: 1
;                  Failure: 0
; Author ........: Derick Payne
; ===============================================================================================================================
Func __LoggingFileReset()

	If FileExists($FILE_LOGGING) Then
		If FileGetSize($FILE_LOGGING) >= $CONF_LOGGINGSTORAGE Then
			If FileDelete($FILE_LOGGING) Then Return 1
		Else
			If FileSetAttrib($FILE_LOGGING, "-RSH") Then Return 1
		EndIf
	Else
		If __LoggingFileCreate() Then Return 1
	EndIf

	Return 0

EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: __LoggingDirCreate
; Return values .: Success: 1
;                  Failure: 0
; Author ........: Derick Payne
; ===============================================================================================================================
Func __LoggingDirCreate()

	If FileExists($DIR_LOGGING) Then
		Return 1
	Else
		If DirCreate($DIR_LOGGING) Then Return 1
	EndIf

	Return 0

EndFunc


Func _ShowDescription($sDescription = "")

	If Not IsDeclared("LST_STATUS") Then Local $LST_STATUS
	If Not IsDeclared("EDIT_INFO") Then Local $EDIT_INFO

	GUICtrlSetState($LST_STATUS, $GUI_HIDE)
	GUICtrlSetState($EDIT_INFO, $GUI_SHOW)

	GUICtrlSetData($EDIT_INFO, $sDescription)

EndFunc