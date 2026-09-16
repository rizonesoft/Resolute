#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------


#include-once

#include <GuiEdit.au3>


Global Const $DIR_RECORDING = @ScriptDir & "\Recording"
Global Const $LOGGING_WINREPAIR = $DIR_RECORDING & "\WinRepair.log"


Func _InitializeLogFile($logFile, $maxSize)

	$maxSize = $maxSize / 1048576

	If Not FileExists($DIR_RECORDING) Then DirCreate($DIR_RECORDING)

	If FileExists($logFile) Then
		FileSetAttrib($logFile, "-A-S-R-H")
		If Round(FileGetSize($logFile) / 1048576) > $maxSize Then
			If FileExists($logFile) Then
				FileDelete($logFile)
			EndIf
		EndIf
	Else
	EndIf

EndFunc


Func _StartLogging($Message)

	_ClearLoggingMemo()
	_MemoLoggingWrite($Message, 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _EndLogging()

	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _ClearLoggingMemo()
	If not IsDeclared("eStatus") Then Local $eStatus
	GuicTrlSetData($eStatus, "")
EndFunc


Func _MemoLoggingWrite($Message = "", $iSuccess = 0, $timeStamp = True)


	If not IsDeclared("eStatus") Then Local $eStatus
	Local $strPrefix = ""

	Select
		Case $iSuccess = 1
			GuiCtrlSetColor($eStatus, 0x066186)
		Case $iSuccess = 2
			GuiCtrlSetColor($eStatus, 0xB20000)
		Case $iSuccess = 3
			GuiCtrlSetColor($eStatus, 0xE6791A)
	EndSelect
	Sleep(10)

	_GUICtrlEdit_AppendText($eStatus, $strPrefix & $Message & @CRLF)
	_LoggingWrite($strPrefix & $Message, $timeStamp)

EndFunc


Func _LoggingWrite($Message = "", $timeStamp = True)

	Local $openLog, $sTimeStamp = ""

	$openLog = FileOpen($LOGGING_WINREPAIR, 1)
	If $openLog = -1 Then
	EndIf

	If $timeStamp Then $sTimeStamp = 	"[" & @MDAY & "/" & @MON & "/" & @YEAR & _
										" " & @HOUR & ":" & @MIN & ":" & @SEC & "] "
	FileWrite($openLog, $sTimeStamp & $Message & @CRLF)
	FileClose($openLog)

EndFunc