#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Resources\Processor.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Fileversion=0.0.0.33
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


#Include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <GUIConstants.au3>


Opt("GUIOnEventMode", 1)
Opt("MustDeclareVars", 1)

Global Const $MOVEFILE_DELAY_UNTIL_REBOOT = 0x04
Global Const $DEFAULT_SLEEP = 1000

Global $gRepForm, $RepIcon, $lHead, $RepProgess, $eRep, $BtnGo, $BtnStop
Global $Cancel = 0


_LoadMainGUI()


Func _LoadMainGUI()

	$gRepForm = GUICreate("", 470, 400, -1, -1)
	GUISetFont(8.5, 400, 0, "Verdana")
	GUISetBkColor(0xEBEBEB)

	$RepIcon = GUICtrlCreateIcon(@ScriptFullPath, 99, 10, 10, 64, 64)
	$lHead = GUICtrlCreateLabel("Welcome", 100, 10, 400, 30)
	GUICtrlSetFont($lHead, 12)

	$RepProgess = GUICtrlCreateProgress(10, 90, 450, 30)
	$eRep = GUICtrlCreateEdit("", 10, 125, 450, 50, $ES_READONLY)
	GUICtrlSetCursor($eRep, 2)

	$BtnGo = GUICtrlCreateButton("&Go!", 10, 290, 100, 40, 0)
	$BtnStop = GUICtrlCreateButton("&Stop", 115, 290, 100, 40, 0)
	GuiCtrlSetState($BtnStop, $GUI_DISABLE)

	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseProcessor")
	GUICtrlSetOnEvent($BtnGo, "_Go")

	GUIRegisterMsg($WM_COMMAND, "MY_WM_COMMAND")
	GUISetState(@SW_SHOW, $gRepForm)

	While 1
		Sleep(25)
	WEnd

EndFunc


Func MY_WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)

    Switch BitAND($wParam, 0xFFFF) ;LoWord = IDFrom
        Case $BtnStop
            Switch BitShift($wParam, 16) ;HiWord = Code
				Case $BN_CLICKED
						$Cancel = 1
				EndSwitch
	EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc;==>WM_COMMAND


Func _CloseProcessor()

	GUIDelete($gRepForm)
	Local $PID = ProcessExists(@ScriptName) ; Will return the PID or 0 if the process isn't found.
	If $PID Then ProcessClose(@ScriptName)

	Exit

EndFunc


Func _FileDeleteUnlock($Source)

	If FileExists($Source) Then

		ProgressOn("Removing Unwanted File", "Removing Unwanted File", "Removing Unwanted File", -1, -1, 18)
		If Not FileDelete($Source) Then
			_KillProcess(_SearchProcess($Source))
			Sleep(1000)
			ProgressSet(20, "Killing File Process")
			If Not FileDelete($Source) Then
				FileSetAttrib($Source, "-RASHNOT")
				Sleep(1000)
				ProgressSet(40, "Removing File Attributes")
				If Not FileDelete($Source) Then
					_FileDeleteOnReboot($Source)
					Sleep(1000)
					ProgressSet(60, "Reboot Required!")
					If Not FileDelete($Source) Then
						Sleep(1000)
						ProgressSet(80)
						Return False
					EndIf
				EndIf
			EndIf
		EndIf

		ProgressSet(100 , "Done", "Complete")
		Sleep(1000)
		ProgressOff()

	Else
		Return True
	EndIf

EndFunc


Func _SearchProcess($sSource)

	Local $sProcess

	$sProcess = StringSplit($sSource, "\")
	Return $sProcess[$sProcess[0]]

EndFunc



Func _KillProcess($sProc)

	Local Const $sProcExe = @ScriptDir & "\Bin\Process.exe"

	Local $Plist = ProcessList($sProc)
	For $i = 1 To $Plist[0][0]
		If ProcessExists($Plist[$i][0]) Then
			If _KillSingleProcess($Plist[$i][1]) = False Then
				If FileExists($sProcExe) Then
					ShellExecute($sProcExe, "-k " & $Plist[$i][0], "", "", @SW_HIDE)
				Else
					ProcessClose($Plist[$i][0])
				EndIf
			EndIf
		EndIf
	Next

EndFunc


Func _KillSingleProcess($PID)

	If ProcessClose($PID) Then
		;$PID & " Process Closed."
		Return True
	Else
		Switch @error
			Case 1
				;"(OpenProcess failed)"
			Case 2
				;"(AdjustTokenPrivileges Failed)"
			Case 3
				;"(TerminateProcess Failed)"
			Case 4
				;"(Cannot verify if process exists)"
		EndSwitch
		Return False
	EndIf

EndFunc


Func _FileDeleteOnReboot($sSource)

	Local $Return
    $Return = DllCall('kernel32.dll', 'int', 'MoveFileExW', 'wstr', $sSource, 'ptr', 0, 'dword', $MOVEFILE_DELAY_UNTIL_REBOOT)
    Return $Return[0]

EndFunc


Func _SetProgress($Message, $Value)
	GuiCtrlSetData($RepProgess, $Value)
	GuiCtrlSetData($eRep, $Message)
EndFunc


Func _ResetProgress()
	GuiCtrlSetData($RepProgess, 0)
	GuiCtrlSetData($eRep, "")
	If $Cancel = 1 Then
		GuiCtrlSetState($BtnGo, $GUI_ENABLE)
		GuiCtrlSetState($BtnStop, $GUI_DISABLE)
	EndIf
EndFunc


Func _Go()

	GuiCtrlSetState($BtnGo, $GUI_DISABLE)
	GuiCtrlSetState($BtnStop, $GUI_ENABLE)
	_CloseViruProcesses()
	_ResetProgress()
	_SpecificVirusRemoval()
	_ResetProgress()
	_DeleteViruFiles()
	_ResetProgress()
	_ViruSettingsRepair()
	_ResetProgress()
	_Maintenance()
	_ResetProgress()

EndFunc


Func _CloseViruProcesses()

	If $Cancel = 0 Then
		_SetProgress("Closing [bar311.exe]", 1)
		_KillProcess("bar311.exe")
		_SetProgress("Closing [password_viewer.exe]", 2)
		_KillProcess("password_viewer.exe")
		_SetProgress("Closing [photos.zip.exe]", 3)
		_KillProcess("photos.zip.exe")
	EndIf

EndFunc


Func _SpecificVirusRemoval()

	_SetProgress("Removing ThinkPoint", 1)
	; ====================================================================================================
	; ThinkPoint
	; ====================================================================================================
	_KillProcess("hotfix.exe")
	_KillProcess("thinkpoint.exe")
	_FileDeleteUnlock(@AppDataDir & "\hotfix.exe")
	_FileDeleteUnlock(@DesktopDir & "\ThinkPoint.lnk")

EndFunc


Func _DeleteViruFiles()

	_FileDeleteUnlock(@HomeDrive & "\bar311.exe")
	_FileDeleteUnlock(@HomeDrive & "\password_viewer.exe")
	_FileDeleteUnlock(@HomeDrive & "\photos.zip.exe")
	_FileDeleteUnlock(@HomeDrive & "\pc-off.bat")
	_FileDeleteUnlock(@WindowsDir & "\bar311.exe")
	_FileDeleteUnlock(@WindowsDir & "\password_viewer.exe")
	_FileDeleteUnlock(@WindowsDir & "\photos.zip.exe")
	_FileDeleteUnlock(@WindowsDir & "\pc-off.bat")

EndFunc


Func _ViruSettingsRepair()

;~ 	If IniRead($gSettings, "Repair", "RepairHidden", 1) = 1 Then
;~ 		GuiCtrlSetData($RepProgess, 1)
;~ 		GuiCtrlSetData($eRep, "Repairing Hidden Files / Folders")
;~ 		RegDelete("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\Current Version\Explorer\Advanced\Folder\Hidden\SHOWALL", "CheckedValue")
;~ 		RegWrite("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\Current Version\Explorer\Advanced\Folder\Hidden\SHOWALL", "CheckedValue", "REG_DWORD", 1)
;~ 		Sleep($gSleep)
;~ 	EndIf

EndFunc


Func _Maintenance()

	; ====================================================================================================
	; Check Disk - Scheduling Boot-Time Scan
	; ====================================================================================================
;~ 	If IniRead($gSettings, "Maintenance", "ScheduleCheckDiskBootScan", 1) = 1 Then
;~ 		GuiCtrlSetData($RepProgess, 1)
;~ 		GuiCtrlSetData($eRep, "Check Disk - Scheduling Boot-Time Scan")
;~ 		Local $sChkTemp = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager","BootExecute")
;~ 		$sChkTemp = StringReplace($sChkTemp, @LF & "autocheck autochk /r \??\" & @HomeDrive, "")
;~ 		RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager", "BootExecute", "REG_MULTI_SZ", $sChkTemp & @LF & "autocheck autochk /r \??\" & @HomeDrive)
;~ 		Sleep($gSleep)
;~ 	EndIf

EndFunc




#region Logging Functions
; ===============================================================================================================================
; Logging Functions
; ===============================================================================================================================
Func _InitializeLogFile($logFile, $maxSize)

	If Not FileExists($DIR_WINRLOGGING) Then DirCreate($DIR_WINRLOGGING)

	If FileExists($logFile) Then
		FileSetAttrib($logFile, "-A-S-R-H")
		If Round(FileGetSize($logFile) / 1048576) > $maxSize Then
			If FileExists($logFile) Then
				FileDelete($logFile)
			EndIf
		EndIf
	Else
	EndIf

	_LoggingWrite("", False)
	_LoggingWrite("", False)
	_LoggingWrite("                                            ./", False)
	_LoggingWrite("                                          (o o)", False)
	_LoggingWrite("--------------------------------------oOOo-(_)-oOOo--------------------------------------", False)

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
	If not IsDeclared("EDIT_STATUS") Then Local $EDIT_STATUS
	GuicTrlSetData($EDIT_STATUS, "")
EndFunc


Func _MemoLoggingWrite($Message = "", $iSuccess = 0, $timeStamp = True)

	If not IsDeclared("EDIT_STATUS") Then Local $EDIT_STATUS
	Local $strPrefix = ""

	Select
		Case $iSuccess = 1
			GuiCtrlSetColor($EDIT_STATUS, 0x066186)
		Case $iSuccess = 2
			GuiCtrlSetColor($EDIT_STATUS, 0xB20000)
		Case $iSuccess = 3
			GuiCtrlSetColor($EDIT_STATUS, 0xE6791A)
	EndSelect
	Sleep(10)

	_GUICtrlEdit_AppendText($EDIT_STATUS, $strPrefix & $Message & @CRLF)
	_LoggingWrite($strPrefix & $Message, $timeStamp)

EndFunc


Func _LoggingWrite($Message = "", $timeStamp = True)

	Local $openLog, $sTimeStamp = ""

	;If $logEnabled = 1 Then
		$openLog = FileOpen($LOG_WINREPAIR, 1)
		If $openLog = -1 Then
		EndIf

		If $timeStamp Then $sTimeStamp = 	"[" & @MDAY & "/" & @MON & "/" & @YEAR & _
										" " & @HOUR & ":" & @MIN & ":" & @SEC & "] "
		FileWrite($openLog, $sTimeStamp & $Message & @CRLF)
		FileClose($openLog)

	;EndIf
EndFunc
; ===============================================================================================================================