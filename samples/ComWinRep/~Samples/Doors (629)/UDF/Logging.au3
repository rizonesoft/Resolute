#include-once

#include <FileConstants.au3>
#include <GuiListBox.au3>
#include <Date.au3>

#include "CoreFunctions.au3"
#include "CoreConstants.au3"


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
	_EditLoggingWrite($sMessage)
	_LoggingWrite("------------------------------------------------------------------------------------------", False)

EndFunc


Func _EndLogging()

	_EditLoggingWrite("Done :)")
	_LoggingWrite("------------------------------------------------------------------------------------------", False)

EndFunc


Func _ClearLogging()

	If Not IsDeclared("LST_STATUS") Then Local $LST_STATUS

	_GUICtrlListBox_BeginUpdate($LST_STATUS)
	_GUICtrlListBox_ResetContent($LST_STATUS)
	_GUICtrlListBox_EndUpdate($LST_STATUS)

EndFunc


Func _EditLoggingWrite($sMessage = "", $bTimePrex = True)

	Local $sTimeStamp = ""
	Local $sCleanMessage = StringReplace($sMessage, @CRLF, " ")

	If Not IsDeclared("LST_STATUS") Then Local $LST_STATUS
	If Not IsDeclared("EDIT_INFO") Then Local $EDIT_INFO

	GUICtrlSetState($LST_STATUS, $GUI_SHOW)
	GUICtrlSetState($EDIT_INFO, $GUI_HIDE)

	If $bTimePrex Then
		$sTimeStamp = "[" & @HOUR & ":" & @MIN & ":" & @SEC & ":" & @MSEC & "] "
	EndIf

	_GUICtrlListBox_BeginUpdate($LST_STATUS)
	_GUICtrlListBox_AddString($LST_STATUS, $sTimeStamp & StringReplace($sCleanMessage, Chr(32), " "))
	_GUICtrlListBox_UpdateHScroll($LST_STATUS)
	_GUICtrlListBox_SetCurSel($LST_STATUS, _GUICtrlListBox_GetCount($LST_STATUS) - 1)
	_GUICtrlListBox_EndUpdate($LST_STATUS)
	_LoggingWrite($sMessage, $bTimePrex)

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