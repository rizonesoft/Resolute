#include-once

; Start Administrative Tools
Func _StartAdminTools()
	ShellExecute("control", "admintools")
	If @error Then
		_MemoLogWrite("Could not start Administrative Tools.", 2)
	EndIf
EndFunc

; Start Computer Management
Func _StartComputerManagement()
	ShellExecute("compmgmt.msc", "/s")
	If @error Then
		_MemoLogWrite("Could not start Computer Management.", 2)
	EndIf
EndFunc

; Open Briefcase Introduction (Welcome)
Func _OpenBriefcaseIntroduction()
	ShellExecute("rundll32", "syncui.dll,Briefcase_Intro")
EndFunc

Func _CreateBriefcase()
	_MemoLogWrite("Creating Briefcase.....")
	ShellExecute("rundll32", "syncui.dll,Briefcase_Create")
	_MemoLogWrite("Briefcase created and is located @ [" & @DesktopDir & "\My Briefcase].", 1)
EndFunc

Func _RemoveBriefcase()
	_DisableControls()
	_MemoLogWrite("Removing Briefcase.....")
	$Search = FileFindFirstFile($GSendToDir & "\My Briefcas*.*")
	If $Search = -1 Then
		_MemoLogWrite("No Briefcase files found.", 3)
	EndIf
	While 1
		$File = FileFindNextFile($Search)
		If @error Then ExitLoop
		FileSetAttrib($GSendToDir & "\" & $File, "-RASHOT")
		If FileRecycle($GSendToDir & "\" & $File) = 1 Then
			_MemoLogWrite("[" & $GSendToDir & "\" & $File & "] Recycled.", 1)
		Else
			_MemoLogWrite("Could not remove [" & @HomeDrive & @HomePath & "\SendTo\" & $File & "].", 2)
		EndIf
	WEnd
	FileClose($Search)
	FileSetAttrib(@DesktopDir & "\My Briefcase", "-RASHOT")
	If FileRecycle(@DesktopDir & "\My Briefcase") Then
		_MemoLogWrite("[" & @DesktopDir & "\My Briefcase] Recycled.", 1)
	Else
		_MemoLogWrite("[" & @DesktopDir & "\My Briefcase] does not seem to exist.", 3)
	EndIf
	_EnableControls()
EndFunc

; Open Briefcase
Func _OpenBriefcase()
	If Not IsDeclared("MBOX") Then Local $MBox
	If FileExists(@DesktopDir & "\My Briefcase") Then
		ShellExecute(@DesktopDir & "\My Briefcase")
	Else
		$MBox = MsgBox(52, "Rizone's Power Tools", "The Briefcase was not found on your computer. You will need to create a Briefcase " & _
						   "first. Would you like us to create a Briefcase for you automatically? Click Yes to create a Briefcase on " & _
						   "your Desktop or No to proceed without creating a Briefcase. A Briefcase will automatically be created " & _
						   "after 30 seconds.", 30)
		If $MBox = 6 Or $MBox = -1 Then
			_CreateBriefcase()
		EndIf
	EndIf
EndFunc

; Start Certificate Manager
Func _StartCertificateManager()
	ShellExecute("mmc.exe", "certmgr.msc", @SystemDir)
	If @error Then
		_MemoLogWrite("Could not start Certificate Manager.", 2)
	EndIf
EndFunc

Func _ClearClipboard()
	_MemoLogWrite("Clearing the Windows Clipboard.....")
	If Not _ClipBoard_Open (@GUI_WinHandle) Then _WinAPI_ShowError ("_ClipBoard_Open failed")
	If Not _ClipBoard_Empty () Then _WinAPI_ShowError ("_ClipBoard_Empty failed")
	_ClipBoard_Close ()
	_MemoLogWrite("Windows Clipboard cleared.", 1)
EndFunc

; Start ClipBook Viewer
Func _StartClipBookViewer()
	ShellExecute("clipbrd.exe", "", @SystemDir)
	If @error Then
		_MemoLogWrite("Could not start ClipBook Viewer.", 2)
	EndIf
EndFunc

; Start Component Services
Func _StartComponentServices()
	ShellExecute("dcomcnfg")
	If @error Then
		_MemoLogWrite("Could not start Component Services.", 2)
	EndIf
EndFunc

; Start Event Viewer
Func _StartEventViewer()
	ShellExecute("eventvwr")
	If @error Then
		_MemoLogWrite("Could not start the Event Viewer.", 2)
	EndIf
EndFunc

; Start File Signature Verification
Func _StartFileSigVerification()
	ShellExecute("sigverif")
	If @error Then
		_MemoLogWrite("Could not start File Signature Verification.", 2)
	EndIf
EndFunc

; Start Files and Settings Transfer Wizard
Func _StartFilesSettingsTransferWiz()
	ShellExecute("migwiz")
	If @error Then
		_MemoLogWrite("Could not start the Files and Settings Transfer Wizard.", 2)
	EndIf
EndFunc

Func _StartAddHardwareWizard()
	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_2003" Then
		ShellExecute("control", "hdwwiz.cpl")
		_ControlPanelErrorHandler(@error)
	Else
		ShellExecute("hdwwiz", "", @SystemDir)
		_ControlPanelErrorHandler(@error)
	EndIf
EndFunc

; Start Device Manager
Func _StartDeviceManager()
	ShellExecute("devmgmt.msc")
	If @error Then
		_MemoLogWrite("Could not start Device Manager.", 2)
	EndIf
EndFunc

; Start Driver Verifier
Func _StartDriverVerifier()
	ShellExecute("verifier")
	If @error Then
		_MemoLogWrite("Could not start Driver Verifier.", 2)
	EndIf
EndFunc

; Start Indexing Service
Func _StartIndexingService()
	ShellExecute("ciadv.msc")
	If @error Then
		_MemoLogWrite("Could not start Indexing Service.", 2)
	EndIf
EndFunc

; Open Network Connections
Func _OpenNetworkConnections()
	ShellExecute("control", "ncpa.cpl")
	If @error Then
		_MemoLogWrite("Could not open Network Connections.", 2)
	EndIf
EndFunc

; Start Hyper Terminal
Func _StartHyperTerminal()
	ShellExecute("hypertrm", "", @ProgramFilesDir & "\Windows NT")
	If @error Then
		_MemoLogWrite("Could not start Hyper Terminal.", 2)
	EndIf
EndFunc

; Start Phone Dialer
Func _StartPhoneDialer()
	ShellExecute("dialer")
	If @error Then
		_MemoLogWrite("Could not start Phone Dialer.", 2)
	EndIf
EndFunc

; Start Remote Desktop Connection
Func _StartRemoteDesktopConn()
	ShellExecute("mstsc")
	If @error Then
		_MemoLogWrite("Could not start Remote Desktop Connection.", 2)
	EndIf
EndFunc

; Start Remote Desktop Connection
Func _StartRemoteAccessConnMan()
	ShellExecute("rasphone")
	If @error Then
		_MemoLogWrite("Could not start Remote Access Connection Manager.", 2)
	EndIf
EndFunc

; Start Telnet Client
Func _StartTelnetClient()
	ShellExecute("telnet.exe", "", @SystemDir)
	If @error Then
		_MemoLogWrite("Could not start Telnet Client.", 2)
	EndIf
EndFunc

Func _InstallIPv6()
	_DisableControls()
	_MemoLogWrite("Installing IPv6.....")
	$EXCode = ShellExecuteWait("netsh", "int ipv6 install", "", "", @SW_HIDE)
	If @error Then
		_MemoLogWrite("IPv6 could not be installed.", 2)
	Else
		If $EXCode = 0 Then
			_MemoLogWrite("IPv6 Installation successful or it's already installed.", 1)
		Else
			_BootMessage()
		EndIf
	EndIf
	_EnableControls()
EndFunc

Func _UnInstallIPv6()
	_DisableControls()
	_MemoLogWrite("Uninstalling IPv6.....")
	$EXCode = ShellExecuteWait("netsh", "int ipv6 uninstall", "", "", @SW_HIDE)
	If @error Then
		_MemoLogWrite("IPv6 could not be uninstalled.", 2)
	Else
		If $EXCode = 0 Then
			_MemoLogWrite("IPv6 uninstalled successfully or was not installed in the first place.", 1)
		Else
			_BootMessage()
		EndIf
	EndIf
	_EnableControls()
EndFunc

Func _ResetIPv6()
	_DisableControls()
	_MemoLogWrite("Resetting IPv6 configuration.....")
	$EXCode = ShellExecuteWait("netsh", "int ipv6 reset", "", "", @SW_HIDE)
	If $EXCode = 0 Then
		_MemoLogWrite("IPv6 Configuration reset successful.", 1)
	Else
		_MemoLogWrite("IPv6 does not seem to be installed on your computer or no user specific settings found.", 2)
	EndIf
	_EnableControls()
EndFunc

; Start ODBC Data Source Administration
Func _StartODBCDataSourceAdmin()
	ShellExecute("odbcad32.exe", "", @SystemDir)
	If @error Then
		_MemoLogWrite("Could not start ODBC Data Source Administration.", 2)
	EndIf
EndFunc

; Start Performance Monitor
Func _StartPerformanceMonitor()
	ShellExecute("perfmon.msc")
	If @error Then
		_MemoLogWrite("Could not start Performance Monitor.", 2)
	EndIf
EndFunc

; Start Resource Monitor
Func _StartResourceMonitor()
	Run("resmon")
	If @error Then
		_MemoLogWrite("Could not start Resource Monitor.", 2)
	EndIf
EndFunc

; Start Windows Management Infrastructure
Func _StartWinManInfrastructure()
	ShellExecute("wmimgmt.msc")
	If @error Then
		_MemoLogWrite("Could not start Windows Management Infrastructure.", 2)
	EndIf
EndFunc

; Start User Accounts Editor
Func _StartUserAccountsEditor()
	ShellExecute("control", "userpasswords")
	If @error Then
		_MemoLogWrite("Could not start User Accounts Editor.", 2)
	EndIf
EndFunc

; Start User Account Access Restrictions
Func _StartUserAccountAccess()
	ShellExecute("control", "userpasswords2")
	If @error Then
		_MemoLogWrite("Could not start User Account Access Restrictions.", 2)
	EndIf
EndFunc

; Start Shared Folder Manager
Func _StartSharedFolderManager()
	ShellExecute("fsmgmt.msc")
	If @error Then
		_MemoLogWrite("Could not start Shared Folder Manager.", 2)
	EndIf
EndFunc
