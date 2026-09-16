#include-once


; Doors Settings
;~ Global Const $SETTINGS_DOORS = @ScriptDir & "\Structure\Doors.ini"
;~ Global $SET_DEFMODE = IniRead($SETTINGS_DOORS, "Development", "DoorsDevMode", 0)


#include <Constants.au3>
#include <GuiEdit.au3>
#include <Date.au3>
#include <File.au3>


Global Const $DIR_DOORS = @ScriptDir & "\Doors"
Global Const $DIR_CONSOLE = @ScriptDir & "\Console"
Global Const $DIR_LOGGING = @ScriptDir & "\Structure\Logging"
Global Const $DIR_MODULES = @ScriptDir & "\Doors\Bin"

Global Const $LOGGFILE_DOORS = $DIR_LOGGING & "\Doors.log"


;~ Func _InitializeLogFile($maxSize)

;~ 	$maxSize = $maxSize / 1048576

;~ 	If Not FileExists($DIR_LOGGING) Then DirCreate($DIR_LOGGING)

;~ 	If FileExists($LOGGFILE_DOORS) Then
;~ 		FileSetAttrib($LOGGFILE_DOORS, "-A-S-R-H")
;~ 		If Round(FileGetSize($LOGGFILE_DOORS) / 1048576) > $maxSize Then
;~ 			If FileExists($LOGGFILE_DOORS) Then
;~ 				FileDelete($LOGGFILE_DOORS)
;~ 			EndIf
;~ 		EndIf
;~ 	Else
;~ 	EndIf

;~ EndFunc


;~ Func _InitializeLogging()
;~ 	If not IsDeclared("eStatus") Then Local $eStatus
;~ 	GUICtrlSetData($eStatus, "")
;~ EndFunc


;~ Func _MemoLoggingWrite($Message = "", $iSuccess = 0, $timeStamp = True)

;~ 	If not IsDeclared("eStatus") Then Local $eStatus
;~ 	Local $strPrefix = ""

;~ 	Select
;~ 		Case $iSuccess = 1
;~ 			GuiCtrlSetColor($eStatus, 0x066186)
;~ 		Case $iSuccess = 2
;~ 			GuiCtrlSetColor($eStatus, 0xB20000)
;~ 		Case $iSuccess = 3
;~ 			GuiCtrlSetColor($eStatus, 0xE6791A)
;~ 	EndSelect
;~ 	Sleep(10)

;~ 	_GUICtrlEdit_AppendText($eStatus, $strPrefix & $Message & @CRLF)
;~ 	_LoggingWrite($strPrefix & StringReplace($Message, ", please wait...", ":", 0, 2), $timeStamp)

;~ EndFunc


;~ Func _LoggingWrite($Message = "", $timeStamp = True)

;~ 	Local $openLog, $sTimeStamp = ""

;~ 	;If $logEnabled = 1 Then

;~ 		$openLog = FileOpen($LOGGFILE_DOORS, 1)
;~ 		If $openLog = -1 Then
;~ 		EndIf

;~ 		If $timeStamp Then $sTimeStamp = 	"[" & @MDAY & "/" & @MON & "/" & @YEAR & _
;~ 										" " & @HOUR & ":" & @MIN & ":" & @SEC & "] "
;~ 		FileWrite($openLog, $sTimeStamp & $Message & @CRLF)
;~ 		FileClose($openLog)

;~ 	;EndIf

;~ EndFunc


Func _LaunchDoorsHiveModule($sExecFile, $sHiveName, $sHFullName, $dMode = False)

	Local $sExecPath = $DIR_MODULES & "\" & $sExecFile
	Local $sHAPath = $DIR_MODULES & "\" &  $sHiveName & ".7z"
	Local $sHCPath = $DIR_MODULES & "\" &  $sHiveName & ".cmd"

	_InitializeLogging()
	If FileExists($sExecPath) And Not FileExists($sHAPath) Then

		;~ _MemoLoggingWrite("Seems like " & $sHFullName & " is configured", 1)
		_LaunchFixedLocation($sExecPath, $sHFullName)

	Else

		_MemoLoggingWrite("Configuring " & $sHFullName & " for first-time-use (FTU), please wait...", 1)
		If FileExists($sHAPath) Then

			_MemoLoggingWrite("Found [" & $sHiveName & ".7z] hive module, continuing with configuration.", 1)
			If Not FileExists($sHCPath) Then

				_MemoLoggingWrite("Could not find the [" & $sHiveName & ".cmd] file, will attempting to create it, please wait...", 3)
				Local $oCFile = FileOpen($sHCPath, 1)
				;~ Check if file opened for writing OK
				If $oCFile = -1 Then
					_MemoLoggingWrite("Could not create the [" & $sHCPath & "] file.", 2)
					Return SetError(1, 0, 0)
				EndIf

				FileWrite($oCFile, "@ECHO OFF" & @CRLF)
				FileWrite($oCFile, "SET ArchiveName=" & $sHiveName & ".7z" & @CRLF)
				FileWrite($oCFile, "SET DoorsApp=" & $sExecFile & @CRLF)
				FileWrite($oCFile, "SET DoorsAppName=" & $sHFullName & @CRLF)
				FileWrite($oCFile, "ECHO." & @CRLF)
				FileWrite($oCFile, "ECHO Testing archive" & @CRLF)
				FileWrite($oCFile, "ECHO." & @CRLF)
				FileWrite($oCFile, "..\Console\7za.exe t %ArchiveName%" & @CRLF)
				FileWrite($oCFile, "IF %ERRORLEVEL% == 0 ( GOTO EXTRACT ) ELSE ( GOTO ERROR )" & @CRLF)
				FileWrite($oCFile, ":EXTRACT" & @CRLF)
				FileWrite($oCFile, "ECHO." & @CRLF)
				FileWrite($oCFile, "ECHO Extracting %DoorsAppName% and preparing for first time usage." & @CRLF)
				FileWrite($oCFile, "ECHO." & @CRLF)
				FileWrite($oCFile, "..\Console\7za.exe x %ArchiveName% -aoa" & @CRLF)
				FileWrite($oCFile, "ECHO." & @CRLF)
				FileWrite($oCFile, "ECHO Removing %DoorsAppName% archive" & @CRLF)
				FileWrite($oCFile, "ECHO." & @CRLF)
				If $dMode = 0 Then FileWrite($oCFile, "DEL %ArchiveName%" & @CRLF)
				FileWrite($oCFile, "ECHO." & @CRLF)
				FileWrite($oCFile, "START %DoorsApp%" & @CRLF)
				FileWrite($oCFile, "GOTO END" & @CRLF)
				FileWrite($oCFile, ":ERROR" & @CRLF)
				FileWrite($oCFile, "ECHO." & @CRLF)
				FileWrite($oCFile, "ECHO Error: %ERRORLEVEL%" & @CRLF)
				FileWrite($oCFile, "ECHO." & @CRLF)
				FileWrite($oCFile, ":END" & @CRLF)

				FileClose($oCFile)
				Sleep(250)

				_MemoLoggingWrite($sHFullName & " configuration file created @ " & "[" & $sHCPath & "]", 1)
				_RunOnceConfiguration($sHCPath)

			Else
				_RunOnceConfiguration($sHCPath)

			EndIf

		EndIf

	EndIf

EndFunc


Func _RunOnceConfiguration($shHiveConf)

	If FileExists($shHiveConf) Then
		_MemoLoggingWrite("Completing the RunOnce hive configuration, please wait...")
		ShellExecute($shHiveConf, "", $DIR_MODULES, "", @SW_SHOW)
	EndIf

EndFunc


Func _LaunchFixedLocation($sPath, $sName, $sParam = "", $sWorking = "", $sVerb = "", $showFlag = @SW_SHOW)

	If FileExists($sPath) Then
		_MemoLoggingWrite("Launching " & $sName)
		ShellExecute($sPath, $sParam, $sWorking, $sVerb, $showFlag)
	Else
		_MemoLoggingWrite("Doors cannot find [" & $sPath & "]", 2)
		MsgBox(262160, $sPath, "Doors cannot find '" & $sPath & "'. Although the Doors hive can function without it, " & _
		"the specific function will not be available.", 60)
	EndIf

EndFunc


Func _OpenFolder($sPath)

	_InitializeLogging()
	_MemoLoggingWrite("Opening [" & $sPath & "]")
	ShellExecute($sPath)
	If @error Then _MemoLoggingWrite("Could not open [" & $sPath & "]", 2)

EndFunc


Func _OpenTextFile($sTextFile)

	_InitializeLogging()
	_MemoLoggingWrite("Opening [" & $sTextFile & "]")
	If FileExists(@ScriptDir & "\Doors\Bin\Notepad2\Notepad2.exe") Then
		ShellExecute(@ScriptDir & "\Doors\Bin\Notepad2\Notepad2.exe", $sTextFile)
	Else
		ShellExecute($sTextFile)
	EndIf

EndFunc


;~ Func _GetDoorsVersion($iFlag)

;~ 	Local $verReturn = FileGetVersion(@ScriptFullPath)
;~ 	Local $splReturn = StringSplit($verReturn, ".")

;~ 	If $splReturn[0] >= 4 Then
;~ 		If $iFlag = 1 Then
;~ 			Return $splReturn[1]
;~ 		ElseIf $iFlag = 2 Then
;~ 			Return $splReturn[2]
;~ 		ElseIf $iFlag = 3 Then
;~ 			Return $splReturn[3]
;~ 		ElseIf $iFlag = 4 Then
;~ 			Return $splReturn[4]
;~ 		ElseIf $iFlag = 5 Then
;~ 			Return $splReturn[1] & "." & $splReturn[2]
;~ 		ElseIf $iFlag = 6 Then
;~ 			Return $verReturn
;~ 		EndIf
;~ 	EndIf

;~ EndFunc



Func _DrawStatusSizeFromPercentage($FrBar, $Perc, $BcLeft, $BcTop, $BcWidth, $BcHeight)

	If $Perc > -1 Then
		If $Perc > 100 Then $Perc = 100
		If $Perc = 0 Then
			GUICtrlSetState($FrBar, $GUI_HIDE)
		Else

			If BitAND(GUICtrlGetState($FrBar), $GUI_HIDE) = $GUI_HIDE Then
				GUICtrlSetState($FrBar, $GUI_SHOW)
			EndIf
			GUICtrlSetPos($FrBar, $BcLeft + 1, $BcTop + 1, (($BcWidth - 2) * $Perc) / 100, $BcHeight - 2)
		EndIf
	EndIf

EndFunc
