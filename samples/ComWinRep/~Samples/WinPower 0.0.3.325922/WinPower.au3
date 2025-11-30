#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.2.0
 Author:         Rizone Technologies

 Script Function:
	Rizone Utility Suite.

#ce ----------------------------------------------------------------------------






;#include <WindowsConstants.au3>
;~ $Group2 = GUICtrlCreateGroup("Group2", 392, 8, 321, 121)
;~ GUICtrlCreateGroup("", -99, -99, 1, 1)
;~ $Group3 = GUICtrlCreateGroup("Group3", 392, 136, 321, 121)
;~ GUICtrlCreateGroup("", -99, -99, 1, 1)
;~ GUICtrlSetData(-1, "Edit2")
;~ $Group4 = GUICtrlCreateGroup("Group4", 392, 264, 321, 89)
;~ GUICtrlCreateGroup("", -99, -99, 1, 1)
;~
;~ $Button2 = GUICtrlCreateButton("Button2", 632, 448, 83, 33, $WS_GROUP)
;~ $StatusBar1 = _GUICtrlStatusBar_Create($Form1)


Global Const $LogDir = @ScriptDir & "\Logging"
Global Const $BinDir = @ScriptDir & "\Bin"
Global Const $GFontRegExe = $BinDir & "\FontReg.exe"
Global Const $GPowerLog = $LogDir & "\WinPower.log"

Global Const $GProccRes = $ResDir & "\Process.ani"

Global $GPowLogSize = IniRead($GPowerSettings, "Logging", "Size", 2)

Global $ComList


#include <Modules\mAdministration.au3>
#include <Modules\mControlPanel.au3>


If _Singleton(@ScriptName, 1) = 0 Then

	MsgBox(262192, "Warning", "An occurence of " & $PowerTitle & " is already running.", 30)
	Exit

Else

	If @ScriptName <> "WinPower.exe" Then
		FileMove(@ScriptFullPath, @ScriptDir & "\WinPower.exe", 0)
		MsgBox(48, "Tamper Warning", "It looks like you renamed WinPower.exe to " & @ScriptName & ". It is not polite to tamper with other people's hard work. " &  _
								 "No worries, we renamed it back to WinPower.exe. All you need to do is start it again.")
		Exit
	EndIf

	If Not FileExists($LogDir) Then DirCreate($LogDir)

	If FileExists($GPowerLog) Then
		If Not FileSetAttrib($GPowerLog, "-RASHOT") Then
			MsgBox(4096, "Error", "Problem setting attributes.")
		EndIf
	Else
		If FileGetSize($GPowerLog) > ($GPowLogSize * 1024) * 1024 Then
			FileDelete($GPowerLog)
		EndIf
	EndIf

	_Main()

EndIf




	Local $FileMenu, $FiClose, $RepairMenu, $AdminMenu, $AdHardMenu, $HmBiometric
	Local $ControlMenu, $ConPanel, $ConActCenter, $CAActCenter, $ConBackRest
	Local $BtnComGo

	If Not FileExists($ResDir) Then DirCreate($ResDir)
	If Not FileExists($BinDir) Then DirCreate($BinDir)

	If @Compiled Then
		FileInstall("Resources\WinPower.ico", $PowerIcoRes, 0)
		FileInstall("Resources\Process.ani", $GProccRes, 0)
	EndIf



	$FileMenu = GUICtrlCreateMenu("&File")
	$FiClose = GUICtrlCreateMenuItem("&Close", $FileMenu)

	GUICtrlSetOnEvent($FiClose, "_CLosedClicked")

	$RepairMenu = GUICtrlCreateMenu("&Repair")

	; ===============================================================================================================================
	; Administration Menu
	; ===============================================================================================================================

	$AdminMenu = GUICtrlCreateMenu("&Administration")


	GUICtrlSetOnEvent($HmBiometric, "_StartBiometricDevices")

	$ControlMenu = GUICtrlCreateMenu("&Control Panel")




	GUICtrlSetOnEvent($ConPanel, "_StartControlPanelgodMode")
	GUICtrlSetOnEvent($CAActCenter, "_StartActionCenter")
	GUICtrlSetOnEvent($ConBackRest, "_StartBackupAndRestore")

	GUICtrlCreateGroup("Windows Repair", 10, 10, 380, 370)
	;$ComList = GUICtrlCreateList("", 20, 40, 360, 175, BitOr($LBS_STANDARD, $LBS_SORT))
	;GuiCtrlSetData($ComList, "Repair Font Registrations")

	$ComList = GUICtrlCreateList("", 20, 40, 360, 175, $LBS_SORT)
	GUICtrlSetData($ComList, "Repair Font Registrations|Repair 'Show hidden files and folders' function")
;~ 	$itRepFont = GUICtrlCreateTreeViewItem("", $tComList)
;~ 	$itRepHidden = GUICtrlCreateTreeViewItem("", $tComList)
;~ 	$itResTCPIP = GUICtrlCreateTreeViewItem("Resetting all TCP/IP Interfaces", $tComList)
;~ 	$itRepWinsock = GUICtrlCreateTreeViewItem("Repair Winsock (Reset Catalog)", $tComList)
;~ 	$itRelRenConn = GUICtrlCreateTreeViewItem("Release and Renew TCP/IP Connections", $tComList)
;~ 	$itFlushDNS = GUICtrlCreateTreeViewItem("Flush and Re-Register DNS", $tComList)
;~ 	$itRebWMI = GUICtrlCreateTreeViewItem("Rebuild the WMI Repository", $tComList)

	GUICtrlSetOnEvent($ComList, "_SetSelectedCommandDescription")
;~ 	GUICtrlSetOnEvent($itRepHidden, "_SetSelectedCommandDescription")
;~ 	GUICtrlSetOnEvent($itResTCPIP, "_SetSelectedCommandDescription")
;~ 	GUICtrlSetOnEvent($itRepWinsock, "_SetSelectedCommandDescription")
;~ 	GUICtrlSetOnEvent($itRelRenConn, "_SetSelectedCommandDescription")
;~ 	GUICtrlSetOnEvent($itFlushDNS, "_SetSelectedCommandDescription")
;~ 	GUICtrlSetOnEvent($itRebWMI, "_SetSelectedCommandDescription")

	$eComDesc = GUICtrlCreateEdit("", 20, 220, 360, 90, BitOR($WS_VSCROLL, $ES_READONLY, $ES_AUTOVSCROLL))
	GUICtrlSetBkColor($eComDesc, 0xFFFFFF)
	$BtnComGo = GUICtrlCreateButton("Go!", 210, 320, 170, 50, $BS_DEFPUSHBUTTON)
	GuiCtrlSetState($BtnComGo, $GUI_NOFOCUS)
	GUICtrlSetFont($BtnComGo, 12, 400, 0, "Verdana")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	GUICtrlSetOnEvent($BtnComGo, "_RepairGO")



	If Not FileExists(@ScriptDir & "\WinsRepair.exe") Then
		GUICtrlSetImage($clpIcon[0], $ResDir & "\WinsRepairG48.ico", -1)
		GUICtrlSetTip($clpIcon[0], 	"WinsRepair.exe could not be found!", "Oops!", 3, 1)
	Else
		GUICtrlSetImage($clpIcon[0], $ResDir & "\WinsRepair48.ico", -1)
	EndIf






EndFunc



Func _SetSelectedCommandDescription()

	Switch GUICtrlRead($ComList)

		Case "Repair Font Registrations"
			GUICtrlSetData($eComDesc, 	"Ensure the consistency of the Windows font registry. Register fonts that are not properly registered and remove leftover " & _
										"stale registrations for fonts that are no longer present on the system.")
		Case "Repair 'Show hidden files and folders' function"
			GUICtrlSetData($eComDesc, 	"Repair the 'Show hidden files and folders' function in Windows. A common Autorun virus disables this " & _
										"function to stop you from unhiding your files and folders.")
		Case "Resetting all TCP/IP Interfaces"
			GUICtrlSetData($eComDesc, 	"This option rewrites important registry keys that are used by the Internet Protocol (TCP/IP) stack. This has the same " & _
										"result as removing and reinstalling the protocol.")
		Case "Repair Winsock (Reset Catalog)"

		Case "Release and Renew TCP/IP Connections"

		Case "Flush and Re-Register DNS"


	EndSwitch

EndFunc



Func _RepairGO()

	Switch GUICtrlRead($ComList)

		Case "Repair Font Registrations"
			_RepairFontRegistrations()

	EndSwitch

;~ 	_DisableControls()
;~ 	If _GUICtrlTreeView_GetChecked($tComList, $itRepFont) Then
;~ 		GUICtrlSetState($itRepFont, BitOr($GUI_UNCHECKED, $GUI_DEFBUTTON))
;~
;~ 		GUICtrlSetState($itRepFont, 0)
;~ 	EndIf
;~ 	If _GUICtrlTreeView_GetChecked($tComList, $itRepHidden) Then
;~ 		GUICtrlSetState($itRepHidden, BitOr($GUI_UNCHECKED, $GUI_DEFBUTTON))
;~ 	EndIf
;~ 	If _GUICtrlTreeView_GetChecked($tComList, $itResTCPIP) Then
;~ 		GUICtrlSetState($itResTCPIP, BitOr($GUI_UNCHECKED, $GUI_DEFBUTTON))
;~ 		_ResetTcpipAll()
;~ 		GUICtrlSetState($itResTCPIP, 0)
;~ 	EndIf
;~ 	If _GUICtrlTreeView_GetChecked($tComList, $itRebWMI) Then
;~ 		GUICtrlSetState($itRebWMI, BitOr($GUI_UNCHECKED, $GUI_DEFBUTTON))
;~ 		_RebuildWMI()
;~ 		GUICtrlSetState($itRebWMI, 0)
;~ 	EndIf
;~ 	 _EnableControls()

EndFunc

; Ensure the consistency of the Windows font registry.
Func _RepairFontRegistrations()

	If FileExists($GFontRegExe) Then
		_MemoLogWrite("Repairing Font Registrations.....")
		ShellExecuteWait($GFontRegExe)
	Else
		MsgBox(16, "Ooops! Something went wrong.", 	"'" & $GFontRegExe & "' could not be found. You can't repair Font Registrations without it. " & _
													" You could try to re-download Power Suite.")
	EndIf

EndFunc


Func _ResetTcpipAll()

	Local $ExitCode

	_MemoLogWrite("Resetting all TCP/IP Interfaces .....")
	Local $ExitCode = ShellExecuteWait("netsh", "interface reset all", "", "", @SW_HIDE)
	If $ExitCode = 0 Then
		_MemoLogWrite("TCP/IP interfaces reset successful.", 1)
	Else
		_MemoLogWrite("TCP/IP interfaces reset failed or no user specific settings found.", 2)
	EndIf

EndFunc


; Rebuild the WMI Repository
Func _RebuildWMI()

	Local $Search, $WMIFile

	ShellExecuteWait("net", "stop wscsvc")
	ShellExecuteWait("net", "stop iphlpsvc")
	ShellExecuteWait("net", "stop winmgmt")

	DirRemove(@SystemDir & "\wbem\Repository")

	; Shows the filenames of all files in the current directory.
	; $Search = FileFindFirstFile(@SystemDir & "\wbem\*.*")

	; Check if the search was successful
	; If $search = -1 Then
		; MsgBox(0, "Error", "No files/directories matched the search pattern")
	; EndIf

	; While 1
		; $WMIFile = FileFindNextFile($Search)
		; If @error Then ExitLoop

		; MsgBox(4096, "File:", $WMIFile)
	; WEnd

	; Close the search handle
	; FileClose($Search)

	ShellExecuteWait("net", "start wscsvc")
	ShellExecuteWait("net", "start iphlpsvc")
	ShellExecuteWait("net", "start winmgmt")

EndFunc





Func _DisableControls()
	GUICtrlDelete($PowerIcon)
	GUISwitch($PowerForm)
	$GPowAni = GUICtrlCreateIcon($GProccRes, -1, 647, 382, 50, 50)
;~ 	GUICtrlSetState($tComList, $GUI_DISABLE)

EndFunc


Func _EnableControls()
	GUICtrlDelete($GPowAni)
	GUISwitch($PowerForm)
	$PowerIcon = GUICtrlCreateIcon($PowerIcoRes, -1, 640, 375, 64, 64, $SS_NOTIFY)
;~ 	GUICtrlSetState($tComList, $GUI_ENABLE)
EndFunc


Func _MemoLogWrite($Message = "", $iWarning = 0, $iTimeStamp = 1, $iToMemo = 1, $iToFile = 1)

	Local $sPrefix = "", $sTStamp = "", $OpenLog

	If $iTimeStamp = 1  Then $sTStamp = "[" & @YEAR & "-" & @MON & "-" & @MDAY & "  " & @HOUR & ":" & @MIN & "] "
	If $iToMemo = 1 Then
		Select
			Case $iWarning = 1 ; Success
				GUICtrlSetBkColor($eStatus, 0xC1DCfC)
			Case $iWarning = 2 ; Error
				GUICtrlSetBkColor($eStatus, 0xEFD6E1)
				$sPrefix = "ERROR: "
			Case $iWarning = 3 ; Warning
				GUICtrlSetBkColor($eStatus, 0xF4FFD4)
		EndSelect
		Sleep(10)

		_GUICtrlEdit_AppendText($eStatus, $Message & @CRLF)
	EndIf


	If $iToFile = 1 Then
		$OpenLog = FileOpen($GPowerLog, 1)

		If $OpenLog = -1 Then
			;_GUICtrlEdit_AppendText($eStatus, "The status could not be written to the log file, make sure the " & _
											;$GPowerLog & " directory is not write protected." & @CRLF)
			;GUICtrlSetBkColor($eStatus, 0xEFD6E1)
		EndIf

		FileWrite($OpenLog, $sTStamp & $sPrefix & $Message & @CRLF)
		FileClose($OpenLog)

	EndIf

EndFunc

