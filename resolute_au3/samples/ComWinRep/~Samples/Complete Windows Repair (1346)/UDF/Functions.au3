#include-once


Func _RemoveReg($sRegKey, $sRegValue = "")

	Local $RegReturn = 0, $sRecognizedRegKey

	If $sRegValue <> "" Then
		Local $sDeValue
		If $sRegValue == "@" Then
			$sDeValue = "Default"
		Else
			$sDeValue = $sRegValue
		EndIf
		$RegReturn = RegDelete($sRegKey, $sRegValue)
		If $RegReturn = 1 Then
			_MemoLoggingWrite("Offending data found @ [" & $sRegKey & " --> " & $sDeValue & "] and removed.", 3)
		EndIf
	Else
		$RegReturn = RegDelete($sRegKey)
		If $RegReturn = 1 Then
			_MemoLoggingWrite("Offending data found @ [" & $sRegKey & "] and removed.", 3)
		EndIf
	EndIf

	If $RegReturn = 2 Then
		_ReturnRegistryErrorCode(@error)
	EndIf

EndFunc


Func _WriteToReg($sRegKey, $sRegValueName = "", $sRegType = "", $sRegValue = "")

	Local $RegReturn

	If $sRegValueName <> "" Then
		$RegReturn = RegWrite($sRegKey, $sRegValueName, $sRegType, $sRegValue)
		_LoggingWrite("Writing Registry Data: [" & $sRegKey & " --> " & $sRegValueName & " --> " & $sRegType & " --> " & $sRegValue & "]")
	Else
		_LoggingWrite("Writing Registry Data: [" & $sRegKey & "]")
		$RegReturn = RegWrite($sRegKey)
	EndIf

	If $RegReturn = 0 Then
		_MemoLoggingWrite(_ReturnRegistryErrorCode(@error))
	EndIf

	Return $RegReturn

EndFunc


Func _ReturnRegistryErrorCode($ErrorCode)

	Select
		Case $ErrorCode = 0
			Return
		Case $ErrorCode = 1
			_MemoLoggingWrite("Unable to open requested key", 2)
		Case $ErrorCode = 2
			_MemoLoggingWrite("Unable to open requested main key", 2)
		Case $ErrorCode = 3
			_MemoLoggingWrite("Unable to remote connect to the registry", 2)
		Case $ErrorCode = -1
			_MemoLoggingWrite("Unable to open requested value", 2)
		Case $ErrorCode = -2
			_MemoLoggingWrite("Value type not supported", 2)
	EndSelect
	_MemoLoggingWrite("you may not have permission to access the Registry.", 2)
	_MemoLoggingWrite("You could try the Restore Registry Permissions option.", 2)

EndFunc


Func _RegKeyExport($sKey, $sRegFile)

	$sRegFile =   "(" & @HOUR & @MIN & @SEC & ") "  & $sRegFile
	_MemoLoggingWrite("Backing things up for in case something goes wrong.")

    Local $sFolder = @ScriptDir & "\Restore\" & @YEAR & "\" & @MON & "\" & @MDAY
    If Not FileExists($sFolder) Then
        If Not DirCreate($sFolder) Then
            Return MsgBox(8240, "RegKeyExport", "Could Not Create Folder:" & @CRLF & $sFolder)
			_MemoLoggingWrite("Could Not Create Folder Restore folder @ [" & @CRLF & $sFolder & "]", 2)
			_MemoLoggingWrite("Warning: No Backup will be made!", 3)
        EndIf
        Sleep(500)
	EndIf

	Local $sRegFilePath = $sFolder & "\" & $sRegFile
;~ 	Local $oRegFile = FileOpen($sRegFilePath, 1)

	; Check if file opened for writing OK
;~ 	If $oRegFile = -1 Then
;~ 		_LoggingWrite("Could not open [" & $sRegFilePath & "] for writing")
;~ 	EndIf

;~ 	FileWriteLine($oRegFile, "Windows Registry Editor Version 5.00" & @CRLF & @CRLF)
;~ 	FileWriteLine($oRegFile, "[" & $sKey & "]" & @CRLF)
;~ 	FileWriteLine($oRegFile, Chr(34) & $sValueName & Chr(34) & "=" & Chr(34) & $sValue & Chr(34))

;~ 	FileClose($oRegFile)

	Local $regExportCom = "regedit.exe /e " & Chr(34) & $sRegFilePath & Chr(34) & Chr(32) & Chr(34) & $sKey & Chr(34)
	_LoggingWrite("[" & $regExportCom & "]")
	RunWait($regExportCom, @WindowsDir)
	Sleep(500)

	If FileExists($sRegFilePath) Then
		_MemoLoggingWrite("[" & $sKey & "] successfully exported.", 1)
		_MemoLoggingWrite("To restore previous settings, use [" & $sRegFilePath & "]")
	ElseIf Not FileExists($sRegFilePath) Then
		_MemoLoggingWrite("Could not backup [" & $sKey & "]", 2)
		_MemoLoggingWrite("You will not be able to restore previous settings!", 2)
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


Func _StartService($ServiceName, $DisplayName)

;~ 	_MemoLoggingWrite("Starting the " & $DisplayName & " Service.")
;~ 	Local $ServReturn = ShellExecuteWait("net", "start " & $ServiceName, "", "", @SW_HIDE)
;~ 	If $ServReturn = 0 Then
;~ 		_MemoLoggingWrite($DisplayName & " Service Started Successfully.", 1)
;~ 	ElseIf $ServReturn = 2 Then
;~ 		_MemoLoggingWrite($DisplayName & " Service could not be started.", 3)
;~ 	EndIf
;~ 	;If $CONFIG_DEBUG Then _MemoLoggingWrite("Return Code: " & Binary($ServReturn))

EndFunc


Func _RestartService($ServiceName, $DisplayName)

;~ 	_MemoLoggingWrite("Restarting the " & $DisplayName & " Service, please wait...")
;~ 	;If Not _SvcStart($ServiceName) Then
;~ 		_MemoLoggingWrite($DisplayName & " Service could not be started.", 2)
;~ 	;Else
;~ 		_MemoLoggingWrite($DisplayName & " Service restarted.", 1)
;~ 	;EndIf

EndFunc