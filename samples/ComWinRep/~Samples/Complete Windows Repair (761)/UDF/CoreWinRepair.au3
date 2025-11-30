#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------


#include-once

#include <Constants.au3>
#include <Services.au3>
#include <GuiEdit.au3>
#include <Date.au3>


Global Const $DIR_RECORDING = @ScriptDir & "\Recording"
Global Const $DIR_DATASTORE = @WindowsDir & "\SoftwareDistribution\DataStore"
Global Const $DIR_SDOWNLOAD = @WindowsDir & "\SoftwareDistribution\Download"
Global Const $DIR_CATROOT = @SystemDir & "\CatRoot2"

Global Const $LOGGING_WINREPAIR = $DIR_RECORDING & "\WinRepair.log"
Global Const $LOGGING_CIRRESET = $DIR_RECORDING & "\CIRReset.log"

Global $CancelRepair = False
Global $RESETWINSOCK = False
Global $CLEARWINUPDATE = False
Global $EVENTLOG_CONFIGURED = False


Func _GetIntExplorerVersion($ieRet = "FULL")

	If FileExists(@ProgramFilesDir & "\Internet Explorer\iexplore.exe") Then

		Local $splString =  StringSplit(FileGetVersion(@ProgramFilesDir & "\Internet Explorer\iexplore.exe"), ".")

		If $ieRet = "FULL" Then
			Return $splString[1] & "." & $splString[2] & "." & $splString[3]
		ElseIf $ieRet = "MAIN" Then
			Return $splString[1]
		ElseIf $ieRet = "MINOR" Then
			Return $splString[2]
		ElseIf $ieRet = "BUILD" Then
			Return $splString[3]
		Else
			Return 0
		EndIf
	EndIf

EndFunc


Func _BroadcastChange()

	_MemoLoggingWrite("Broadcasting changes made to Windows. However, you might still need to restart your computer.")

	Local Const $HWND_BROADCAST = 0xFFFF
	Local Const $WM_SETTINGCHANGE = 0x1A
	Local Const $SPI_SETNONCLIENTMETRICS = 0x2A
	Local Const $SMTO_ABORTIFHUNG = 0x2

	Local $bcResult = DllCall("user32.dll", "lresult", "SendMessageTimeout", _
			"hwnd", $HWND_BROADCAST, _
			"uint", $WM_SETTINGCHANGE, _
			"wparam", $SPI_SETNONCLIENTMETRICS, _
			"lparam", 0, _
			"uint", $SMTO_ABORTIFHUNG, _
			"uint", 10000, _
			"dword*", "success")
	If @error Then Return 0
	Return $bcResult[0]
EndFunc   ; ==> _BroadcastChange


Func _RestartShellMessage()

	;MsgBox features: Title=Yes, Text=Yes, Buttons=Yes, No, and Cancel, Icon=Question, Timeout=25 ss, Miscellaneous=Top-most attribute
	If Not IsDeclared("iMsgBoxAns") Then Local $iMsgBoxAns
	$iMsgBoxAns = MsgBox(262179, 	"Restart Windows Shell?", "Would you like to restart the Windows Shell?" & @CRLF & _
									"Sometimes this is necessary for settings to take effect." & @CRLF & _
									"This is a safe operation and will not harm your computer.",25)
	;6 = Yes : 7 = No : 2 = Cancel : -1 = Timeout
	Switch $iMsgBoxAns
		Case 6 ;
			_RestartShell()
		Case 7, 2, -1
			Return
	EndSwitch

EndFunc


Func _RestartShell()

	_ConsoleRun("taskkill /IM explorer.exe /F")
	ShellExecute("explorer.exe")

EndFunc


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


Func _LaunchFixedLocation($sPath)
	If FileExists($sPath) Then ShellExecute($sPath)
EndFunc


Func _ConsoleRun($sCommand, $workingDir = @SystemDir)

	Local $processID, $stdLine, $stdErrLine, $iSuccess = 0

	$ProcessID = Run(@ComSpec & " /c " & $sCommand, $workingDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)

	While 1
		$stdLine = StdoutRead($processID)
		If @error Then ExitLoop
		If $stdLine And $stdLine <> "." And Not StringIsSpace($stdLine) Then
			If StringInStr($stdLine, "success", 2) Or StringInStr($stdLine, "sucess", 2) _
			Or StringInStr($stdLine, "OK", 2) Then $iSuccess = 1
			_MemoLoggingWrite($stdLine, $iSuccess)
			$iSuccess = 0
		EndIf
	Wend

	While 1
		$stdErrLine = StderrRead($processID)
		If @error Then ExitLoop
		If $stdErrLine And $stdErrLine <> "." And Not StringIsSpace($stdErrLine) Then
			_MemoLoggingWrite($stdErrLine, 2)
		EndIf
	WEnd

	StdioClose($processID)

EndFunc


Func _ReregisterDLL($filePath, $Param = "/s")

	Local $regSvr32Return
	If Not $CancelRepair Then
		;~ _MemoLogWrite("RegSvr32.exe: Registering '" & $FilePath & "'.....")
		$regSvr32Return = ShellExecuteWait("regsvr32.exe", " " & $Param & " " & $filePath, "")
		Switch $regSvr32Return
			Case 0
				_MemoLoggingWrite("RegSvr32.exe: '" & $filePath & "' registration succeeded.", 1)
			Case 1
				_MemoLoggingWrite("RegSvr32.exe: '" & $filePath & "' To register a module, you must provide a binary name.", 2)
			Case 3
				_MemoLoggingWrite("RegSvr32.exe: '" & $filePath & "' Specified module not found", 2)
			Case 4
				_MemoLoggingWrite("RegSvr32.exe: '" & $filePath & "' Module loaded but entry-point DllRegisterServer was not found.")
			Case 5
				_MemoLoggingWrite("RegSvr32.exe: '" & $filePath & "' Error number: 0x80070005", 2)
		EndSwitch
	EndIf
	If $regSvr32Return >= 1 Then
		Return 0
	Else
		Return 1
	EndIf

EndFunc   ;==>_ReregisterDLL


;~ Func _RegistryWriter($keyName, $valueName, $regType, $regValue)

;~ 	_MemoLogWrite("Writing to [" & $keyName & "] " & Chr(34) & $valueName & Chr(34) & " => " & Chr(34) & $regValue & Chr(34))
;~ 	Local $regID = RegWrite($keyName, $valueName, $regType, $regValue)
;~ 	_ReturnRegistryAccessInfo($regID, @Error)

;~ EndFunc

;~ Func _RegistryDelete($keyName, $valueName)

;~ 	_MemoLogWrite("Deleting [" & $keyName & "] " & Chr(34) & $valueName & Chr(34))
;~ 	Local $regID = RegDelete($keyName, $valueName)
;~ 	_ReturnRegistryAccessInfo($regID, @Error)

;~ EndFunc


Func _ReturnRegistryAccessInfo($RetID, $ErrID)

;~ 	Select
;~ 		Case $RetID = 1
;~ 			_MemoLogWrite("Registry Success", 1)
;~ 		Case $RetID = 0
;~ 			_MemoLogWrite("Nothing to do here.", 1)
;~ 		Case $RetID = 2
;~ 			Select
;~ 				Case $ErrID = 1
;~ 					_MemoLogWrite("Unable to open requested key.", 2)
;~ 				Case $ErrID = 2
;~ 					_MemoLogWrite("Unable to open requested main key.", 2)
;~ 				Case $ErrID = 3
;~ 					_MemoLogWrite("Unable to remote connect to the registry.", 2)
;~ 				Case $ErrID = -1
;~ 					_MemoLogWrite("Unable to delete requested value.", 2)
;~ 				Case $ErrID = -2
;~ 					_MemoLogWrite("Unable to delete requested key or value.", 2)
;~ 			EndSelect
;~ 	EndSelect

EndFunc


Func _ConfigureEventLog()

	_MemoLoggingWrite("Configuring the Windows Event Log Service, please wait...", 0, False)
	_LoggingWrite("-----------------------------------------------------------------------------------------", False)
	_SvcSetStartMode("eventlog","Automatic")
	_MemoLoggingWrite("Windows Event Log Service Configured.", 1)
	_MemoLoggingWrite("Starting the Windows Event Log Service.")
	If Not _SvcStart("eventlog") Then
		_MemoLoggingWrite("The Windows Event Log Service could not be started.", 2)
		_MemoLoggingWrite("Attempting to repair the Windows Event Log Service.")
		Switch @OSVersion
			Case "WIN_XP", "WIN_2003"
				RegWrite(	"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog", "Description", "REG_SZ", "Enables event log messages " & _
							"issued by Windows-based programs and components to be viewed in Event Viewer. This service cannot be stopped.")
				RegWrite(	"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog", "DisplayName", "REG_SZ", "Event Log")
				RegWrite(	"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog", "ErrorControl", "REG_DWORD", 0x00000001)
				RegWrite(	"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog", "Group", "REG_SZ", "Event log")
				RegWrite(	"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog", "ImagePath", "REG_EXPAND_SZ", _
							"%SystemRoot%\system32\services.exe")
				RegWrite(	"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog", "ObjectName", "REG_SZ", "LocalSystem")
				RegWrite(	"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog", "PlugPlayServiceType", "REG_DWORD", 0x00000003)
				RegWrite(	"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog", "Start", "REG_DWORD", 0x00000002)
				RegWrite(	"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog", "Type", "REG_DWORD", 0x00000020)
			Case "WIN_VISTA", "WIN_2008", "WIN_7", "WIN_2008R2"
				_MemoLoggingWrite("Repairing the Windows Event Log Service.....")
				RegWrite(	"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog", _
							"ObjectName", "REG_SZ", "NT AUTHORITY\LocalService")
				Sleep(250)
				If Not _SvcStart("eventlog") Then
					_MemoLoggingWrite("The Windows Event Log Service could not be repaired and started.", 2)
				Else
					_MemoLoggingWrite("Windows Event Log Service repaired Successfully.", 1)
				EndIf
		EndSwitch
	Else
		_MemoLoggingWrite("Windows Event Log Service Started Successfully.", 1)
	EndIf
	_LoggingWrite("", False)
	_LoggingWrite("-----------------------------------------------------------------------------------------", False)
	$EVENTLOG_CONFIGURED = True

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

	;If $logEnabled = 1 Then

		$openLog = FileOpen($LOGGING_WINREPAIR, 1)
		If $openLog = -1 Then
		EndIf

		If $timeStamp Then $sTimeStamp = 	"[" & @MDAY & "/" & @MON & "/" & @YEAR & _
										" " & @HOUR & ":" & @MIN & ":" & @SEC & "] "
		FileWrite($openLog, $sTimeStamp & $Message & @CRLF)
		FileClose($openLog)

	;EndIf

EndFunc