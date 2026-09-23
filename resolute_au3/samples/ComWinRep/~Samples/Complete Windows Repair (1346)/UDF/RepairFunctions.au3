#include-once


#region :: System Repair Functions
; ===============================================================================================================================
; System Repair Functions
; ===============================================================================================================================
Func _InitializeRegistryQuestion()

	If Not IsDeclared("iMsgBoxAnswer") Then Local $iMsgBoxAnswer

	If $CONFIG_SILENT = True Then
		$iMsgBoxAnswer = 6
	ElseIf $CONFIG_SILENT = False Then
		$iMsgBoxAnswer = MsgBox(262196, "Reinitialize Essential Registry Keys", "Reinitializing Registry keys will overwrite all permissions and give Windows, Administrators, " & _
										"Power Users and " & Chr(34) & "Everyone" & Chr(34) & " full permission to create, modify and read specified keys. Never " & _
										"run this option if you do not have Registry Permission (Access) related issues! " & @CRLF & @CRLF & _
										"Are you sure you would like to run this repair option?", $CONFIG_MSGBTO)

	EndIf

	Select
		Case $iMsgBoxAnswer = 6 ;~ Yes
			_InitializeRegistry()
		Case $iMsgBoxAnswer = 7 ;~ No, Timeout
			_MemoLoggingWrite("You answered NO.")
			_MemoLoggingWrite("Skipping " & Chr(34) & "Reinitializing Essential Registry Keys" & Chr(34) & ".")
		Case $iMsgBoxAnswer = -1 ;~ Timeout
			_MemoLoggingWrite("Complete Windows Repair is configured to automatically answer " & $CONFIG_MSGBYN & " after " & $CONFIG_MSGBTO & " seconds.")
			If $CONFIG_MSGBYN = "NO" Then
				_MemoLoggingWrite("Skipping " & Chr(34) & "Reinitializing Essential Registry Keys" & Chr(34) & ".")
			ElseIf $CONFIG_MSGBYN = "YES" Then
				_InitializeRegistry()
			EndIf
	EndSelect

EndFunc


Func _InitializeRegistry()

	Local $ReginiScript = @ScriptDir & "\Bin\regini.adm"

	_MemoLoggingWrite("Loading and processing the Registry Initialization Script.")
	If FileExists($ReginiScript) Then
		Local $ReginiReturn = ShellExecuteWait(@SystemDir & "\regini.exe ", Chr(34) & $ReginiScript & Chr(34), @SystemDir, "", @SW_HIDE)
		If $ReginiReturn = 0 Then
			_MemoLoggingWrite("Successfully reinitialized essential registry keys.", 1)
		ElseIf $ReginiReturn = 1 Then
			_MemoLoggingWrite("Could not reinitialize some registry keys.", 2)
		EndIf
	Else
		_MemoLoggingWrite("Registry initialization script could not be found @ [ " & $ReginiScript & " ], aborting all operations.", 2)
	EndIf

EndFunc


;~ Restore Registry Permissions
Func _RestoreRegistryPermissions($CurrIndex)

	_DrawSystemProgress($CurrIndex, 10)

	If _InitiateSubInACL($SYSP_ICON[$CurrIndex], $SYSP_CHKB[$CurrIndex], $SYSP_PROGRESS[$CurrIndex], $SYSP_PROGTOP[$CurrIndex]) Then
		If FileExists($EXE_SUBINACL) Then
			_DrawSystemProgress($CurrIndex, 20)
			_MemoLoggingWrite("Restoring Permissions for HKEY_LOCAL_MACHINE")
			ShellExecuteWait($EXE_SUBINACL, "/subkeyreg HKEY_LOCAL_MACHINE /grant=administrators=f /grant=system=f", $LOGGING_DIRECTORY)
			_DrawSystemProgress($CurrIndex, 30)
			_MemoLoggingWrite("Restoring Permissions for HKEY_CURRENT_USER")
			ShellExecuteWait($EXE_SUBINACL, "/subkeyreg HKEY_CURRENT_USER /grant=administrators=f /grant=system=f", $LOGGING_DIRECTORY)
			_DrawSystemProgress($CurrIndex, 40)
			_MemoLoggingWrite("Restoring Permissions for HKEY_CLASSES_ROOT")
			ShellExecuteWait($EXE_SUBINACL, "/subkeyreg HKEY_CLASSES_ROOT /grant=administrators=f /grant=system=f", $LOGGING_DIRECTORY)
			_DrawSystemProgress($CurrIndex, 50)
		Else
			_MemoLoggingWrite("Something went wrong and the SubInACL tool could not be located.", 2)
			_MemoLoggingWrite("Aborting all SubInACL manoeuvres.")
		EndIf
	EndIf

	_DrawSystemProgress($CurrIndex, 60)
	_InitializeRegistry()

	_DrawSystemProgress($CurrIndex, 70)
	_DrawSystemProgress($CurrIndex, 100)
	_DrawSystemProgress($CurrIndex, 0)

	_EndLogging()

EndFunc


;~ Restore Access to the Registry (Error: "Registry editing has been disabled by your administrator")
Func _RestoreRegistryAccess()

	_MemoLoggingWrite("Restoring access to the Registry.")
	_RemoveReg("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System", "DisableRegistryTools")
	_BroadcastChange()

EndFunc


Func _InitiateSubInACL($CtrlIcon, $CtrlCheckBox, $CtrlProgress, $ProgressTop)

	Local $SIAInstallPath

	If @OSArch = "X64" Then
		$SIAInstallPath = @HomeDrive & "\Program Files (x86)\Windows Resource Kits\Tools\subinacl.exe"
	ElseIf @OSArch = "X86" Then
		$SIAInstallPath = @ProgramFilesDir & "\Windows Resource Kits\Tools\subinacl.exe"
	EndIf

	If Not FileExists($EXE_SUBINACL) Then

		_MemoLoggingWrite("Could not find [subinacl.exe] on your computer")
		_MemoLoggingWrite("Downloading [subinacl.msi]")

		GuiCtrlSetImage($CtrlIcon, $THEME_PROCDOWN)
		Local $PreCaption = GUICtrlRead($CtrlCheckBox, 1)
		GUICtrlSetData($CtrlCheckBox, "0 MB / 0 MB (0%)")

		Local $inetHandle = InetGet("http://download.microsoft.com/download/1/7/d/17d82b72-bc6a-4dc8-bfaa-98b37b22b367/subinacl.msi", @ScriptDir & "\Installations\subinacl.msi", 1, 1)
		Local $downBegin = TimerInit(), $downPerc


		While Not InetGetInfo($inetHandle, 2)
			$downPerc = 100 * InetGetInfo($inetHandle, 0) / InetGetInfo($inetHandle, 1)
			If $downPerc > 1 Then _DrawStatusSizeFromPercentage($CtrlProgress, $downPerc, 240, $ProgressTop, 310, 1)
			If $downPerc > 0 Then GUICtrlSetData($CtrlCheckBox, Round(InetGetInfo($InetHandle, 0) / (1024 ^ 2), 1) & " MB / " & _
															Round(InetGetInfo($InetHandle, 1)  / (1024 ^ 2), 1) & " MB (" & Round($downPerc, 1) & "%)")
			Sleep(100)
		WEnd

		Sleep(1000)
		InetClose($inetHandle)
		GuiCtrlSetData($CtrlCheckBox, $PreCaption)

		If TimerDiff($downBegin) < 200 Then
			_MemoLoggingWrite("Something went wrong!", 2)
			Return False
		Else
			If FileExists(@ScriptDir & "\Installations\subinacl.msi") Then
				GuiCtrlSetImage($CtrlIcon, $THEME_PROCANI)
				_MemoLoggingWrite("Download complete", 1)
				_MemoLoggingWrite("Installing subinacl.exe")
				ShellExecuteWait("msiexec.exe", "/i " & Chr(34) & @ScriptDir & "\Installations\subinacl.msi" & Chr(34) & " /quiet /norestart", @ScriptDir)
				Sleep(500)
				If FileExists($SIAInstallPath) Then
					_MemoLoggingWrite("subinacl.exe Installation successful.", 1)
					_SetSubInACLPath()
					Return True
				Else
				_MemoLoggingWrite("subinacl.exe could not be installed!", 2)
				Return False
				EndIf
			Else
				_MemoLoggingWrite("Something went wrong and SubInACL could not be downloaded.", 2)
				_MemoLoggingWrite("Please check your internet connection.")
			EndIf
		EndIf
	Else
		Return True
	EndIf

EndFunc


Func _SetSubInACLPath()

	If FileExists(@ScriptDir & "\Bin\subinacl.exe") Then
		$EXE_SUBINACL = @ScriptDir & "\Bin\subinacl.exe"
	ElseIf FileExists(@ProgramFilesDir & "\Windows Resource Kits\Tools\subinacl.exe") Then
		$EXE_SUBINACL = @ProgramFilesDir & "\Windows Resource Kits\Tools\subinacl.exe"
	ElseIf FileExists(@HomeDrive & "\Program Files (x86)\Windows Resource Kits\Tools\subinacl.exe") Then
		$EXE_SUBINACL = @HomeDrive & "\Program Files (x86)\Windows Resource Kits\Tools\subinacl.exe"
	EndIf

EndFunc
; ===============================================================================================================================
#endregion :: System Repair Functions




Func _RepairWinmgmtParameters()

	Local $Ret01, $Ret02

	_MemoLoggingWrite("Restoring Winmgmt\Parameters")
	$Ret01 = _WriteToReg("HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Winmgmt\Parameters", "ServiceDll", "REG_EXPAND_SZ", "%SystemRoot%\system32\wbem\WMIsvc.dll")
	$Ret02 = _WriteToReg("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Winmgmt\Parameters", "ServiceDll", "REG_EXPAND_SZ", "%SystemRoot%\system32\wbem\WMIsvc.dll")
	If $Ret01 = 1 And $Ret02 = 1 Then
		_MemoLoggingWrite("All attempted repair functions seem successful.", 1)
	EndIf

EndFunc




Func _RepairShellOpenCommands()
EndFunc


;~ Based on Symantec’s UnHookExec.inf
;~ Description: http://www.symantec.com/security_response/writeup.jsp?docid=2004-050614-0532-99
;~ http://securityresponse.symantec.com/avcenter/UnHookExec.inf
;~ Repair Shell Open Commands
Func _ResetShellOpenCommandReg()
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\batfile\shell\open\command", "", "REG_SZ", Chr(34) & "%2" & Chr(34) & " %*")
EndFunc




Func _RepairWMIRepository()

;~ 	Local $WMIRepository = @HomeDrive & "\Windows\System32\wbem\Repository"
;~ 	Local $BadWMIRepository = @HomeDrive & "\Windows\System32\wbem\Repository_Bad"
;~ 	Local $WMIReturn

;~ 	_StartLogging("Repairing WMI and Rebuilding the WMI Repository, Please wait...")

;~ 	_ServiceStop("winmgmt", "Windows Management Instrumentation")
;~ 	If @OSVersion = "WIN_VISTA" Then
;~ 		If FileExists($WMIRepository) Then
;~ 			_MemoLoggingWrite("WMI Repository located @ [" & $WMIRepository & "]")
;~ 			_MemoLoggingWrite("Moving WMI Repository to [" & $BadWMIRepository & "]")
;~ 			DirMove($WMIRepository, $BadWMIRepository, 1)
;~ 		Else
;~ 			_MemoLoggingWrite("Could not locate WMI Repository @ [" & $WMIRepository & "]", 3)
;~ 			If FileExists($BadWMIRepository) Then
;~ 				_MemoLoggingWrite("Looks like it already moved to [" & $BadWMIRepository & "]", 3)
;~ 				_MemoLoggingWrite("Please reboot your computer for the settings to take effect.", 3)
;~ 			EndIf
;~ 		EndIf
;~ 		$WMIReturn = ShellExecuteWait("winmgmt", "/salvagerepository")
;~ 		If $CONFIG_DEBUG Then _MemoLoggingWrite("Return Code: " & Binary($WMIReturn))
;~ 	ElseIf @OSVersion = "WIN_7" Then
;~ 		$WMIReturn = ShellExecuteWait("winmgmt", "/standalonehost")
;~ 		If $CONFIG_DEBUG Then _MemoLoggingWrite("Return Code: " & Binary($WMIReturn))
;~ 		$WMIReturn = ShellExecuteWait("winmgmt", "/resetrepository")
;~ 		If $CONFIG_DEBUG Then _MemoLoggingWrite("Return Code: " & Binary($WMIReturn))
;~ 	EndIf
;~ 	_StartService("winmgmt", "Windows Management Instrumentation")

EndFunc


Func _RepairDriveDefective()

;~ 	_StartLogging("Repairing missing or defective CD/DVD drive, please wait...")
;~ 	_StopConfigureService("stisvc", "Windows Image Acquisition (WIA)", "Automatic", False)
;~ 	_StopConfigureService("stisvc", "Windows Image Acquisition (WIA)", "Automatic", False)
;~ 	_RestartService("stisvc", "Windows Image Acquisition (WIA)")
;~ 	_RestartService("stisvc", "Windows Image Acquisition (WIA)")

;~ 	RegWrite("HKEY_LOCAL_MACHINE64\System\CurrentControlSet\Services\CDRom", "AutoRun", "REG_DWORD", 1)

EndFunc
