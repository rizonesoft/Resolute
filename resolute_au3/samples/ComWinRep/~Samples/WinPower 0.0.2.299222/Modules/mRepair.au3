Func _ClearPrintSpooler()
	_DisableControls()
	_MemoLogWrite("Stopping the Print Spooler Service.....")
	ShellExecuteWait("net", "stop spooler", "", "", @SW_HIDE)
	_MemoLogWrite("Print Spooler Service Stopped.", 1)
	_MemoLogWrite("Clearing the Print Spooler.....")
	FileDelete(@SystemDir & "\spool\printers\*.*")
	_MemoLogWrite("Print Spooler Cleared.", 1)
	_MemoLogWrite("Restarting the Print Spooler Service.....")
	ShellExecuteWait("net", "start spooler", "", "", @SW_HIDE)
	_MemoLogWrite("Print Spooler Service restarted.", 1)
	_EnableControls()
EndFunc

Func _StartDeadPixelRepair()
	ShellExecute(@ScriptDir & "\PixRepair.exe")
EndFunc

Func _RepairWUAUClicked()
	_DisableControls()
	_RepairWUAU()
	_EnableControls()
EndFunc

Func _RepairSHCClicked()
	_DisableControls()
	_RepairSHC()
	_EnableControls()
EndFunc

Func _RepairWUAU()
	Local $FDataStore = @WindowsDir & "\SoftwareDistribution\DataStore\"
	Local $FDataStoreLogs = @WindowsDir & "\SoftwareDistribution\DataStore\Logs\"
	Local $FDownload = @WindowsDir & "\SoftwareDistribution\Download\"

	_MemoLogWrite("Configuring the Event Log Service.....")
	ShellExecuteWait("sc", "config eventlog start= auto obj= LocalSystem", "", "", @SW_HIDE)
	_MemoLogWrite("Event Log Service Configured.", 1)
	_MemoLogWrite("Starting the Event Log Service.....")
	If ShellExecuteWait("net", "start eventlog", "", "", @SW_HIDE) = 0 Then
		_MemoLogWrite("Event Log Service Started Successfully.", 1)
	Else
		_MemoLogWrite("The Event Log Service could not be started or is already started.", 3)
	EndIf
	_MemoLogWrite("Stopping the BITS Service.....")
	If ShellExecuteWait("net", "stop bits", "", "", @SW_HIDE) = 0 Then
		_MemoLogWrite("BITS Stopped Successfully.", 1)
	Else
		_MemoLogWrite("BITS was not started in the first place.", 3)
	EndIf
	_MemoLogWrite("Stopping the Automatic Updates (wuauserv) Service.....")
	If ShellExecuteWait("net", "stop wuauserv", "", "", @SW_HIDE) = 0 Then
		_MemoLogWrite("Automatic Updates (wuauserv) Service Stopped Successfully.", 1)
	Else
		_MemoLogWrite("Automatic Updates (wuauserv) Service was not started in the first place.", 3)
	EndIf
	$iMsgBoxAnswer = MsgBox(67, "Important Info!","Would you like to preserve Windows Update History? " & _
	                            "If you answer Yes, " & $FDataStore & "\DataStore.edb will not be deleted. " & _
							    "If you answer No, the " & $FDataStore & " and the " & _
							    $FDownload & " will be deleted. " & _
							    "If you Cancel, nothing will be deleted.", 50)
	Select
		Case $iMsgBoxAnswer = 6 ;Yes
			_MemoLogWrite("Clearing " & $FDataStoreLogs & ".....")
			DirRemove($FDataStoreLogs, 1)
			_MemoLogWrite($FDataStoreLogs & " Cleared.", 1)
			_MemoLogWrite("Clearing " & $FDownload & ".....")
			DirRemove($FDownload, 1)
			_MemoLogWrite($FDownload & " Cleared.", 1)
		Case $iMsgBoxAnswer = 7  Or $iMsgBoxAnswer = -1
			_MemoLogWrite("Clearing " & $FDataStore & ".....")
			DirRemove($FDataStore, 1)
			_MemoLogWrite($FDataStore & " Cleared.", 1)
			_MemoLogWrite("Clearing " & $FDownload & ".....")
			DirRemove($FDownload, 1)
			_MemoLogWrite($FDownload & " Cleared.", 1)
	EndSelect
	;FileDelete("\Programdata\Microsoft\network\downloader\qmgr*.dat")
	_MemoLogWrite("Clearing " & $FCatRoot & ".....")
	DirRemove($FCatRoot, 1)
	_MemoLogWrite($FCatRoot & " Cleared.", 1)
	_MemoLogWrite("Setting BITS Security Descriptor.....")
	ShellExecuteWait("sc", "sdset bits ""D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)""", "", "", @SW_HIDE)
	_MemoLogWrite("BITS Security Descriptor Set.", 1)
	_MemoLogWrite("Setting Automatic Updates (wuauserv) Service Security Descriptor.....")
	ShellExecuteWait("sc", "sdset wuauserv ""D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)""", "", "", @SW_HIDE)
	_MemoLogWrite("Automatic Updates (wuauserv) Security Descriptor Set.", 1)
	_MemoLogWrite("Configuring the Automatic Updates (wuauserv) Service.....")
	ShellExecuteWait("sc", "config wuauserv start= auto obj= LocalSystem", "", "", @SW_HIDE)
	_MemoLogWrite("Automatic Updates (wuauserv) Service Configured.", 1)
	_MemoLogWrite("Configuring BITS.....")
	ShellExecuteWait("sc", "config bits start= auto obj= LocalSystem", "", "", @SW_HIDE)
	_MemoLogWrite("BITS Configured.", 1)
	_ReregisterDLL("atl.dll")
	_ReregisterDLL("urlmon.dll")
	_ReregisterDLL("mshtml.dll")
	_ReregisterDLL("shdocvw.dll")
	_ReregisterDLL("browseui.dll")
	_ReregisterDLL("jscript.dll")
	_ReregisterDLL("vbscript.dll")
	_ReregisterDLL("scrrun.dll")
	_ReregisterDLL("msxml.dll")
	_ReregisterDLL("msxml2.dll")
	_ReregisterDLL("msxml3.dll")
	_ReregisterDLL("msxml4.dll")
	_ReregisterDLL("msxml6.dll")
	_ReregisterDLL("actxprxy.dll")
	_ReregisterDLL("softpub.dll")
	_ReregisterDLL("wintrust.dll")
	_ReregisterDLL("dssenh.dll")
	_ReregisterDLL("rsaenh.dll")
	_ReregisterDLL("gpkcsp.dll")
	_ReregisterDLL("sccbase.dll")
	_ReregisterDLL("slbcsp.dll")
	_ReregisterDLL("cryptdlg.dll")
	_ReregisterDLL("oleaut32.dll")
	_ReregisterDLL("ole32.dll")
	_ReregisterDLL("shell32.dll")
	_ReregisterDLL("initpki.dll")
	_ReregisterDLL("wuaueng.dll")
	_ReregisterDLL("wuaueng1.dll")
	_ReregisterDLL("wucltui.dll")
	_ReregisterDLL("wups.dll")
	_ReregisterDLL("wups2.dll")
	_ReregisterDLL("wuweb.dll")
	_ReregisterDLL("qmgr.dll")
	_ReregisterDLL("qmgrprxy.dll")
	_ReregisterDLL("wucltux.dll")
	_ReregisterDLL("muweb.dll")
	_ReregisterDLL("wuwebv.dll")
	_ReregisterDLL("winhttp.dll")
	_ReregisterDLL("wuapi.dll")
	_ReregisterDLL("wucltui.dll")
	_ReregisterDLL("corpol.dll")
	_ReregisterDLL("dispex.dll")
	_ReregisterDLL("scrobj.dll")
	_ReregisterDLL("wshext.dll")
	_MemoLogWrite("WUAU DLLs Reregistered.", 1)
    _MemoLogWrite("Resetting Winsock...")
	ShellExecuteWait("netsh", "reset winsock", "", "", @SW_HIDE)
	_MemoLogWrite("Winsock Reset Successfull.", 1)
	_MemoLogWrite("Setting proxy to direct access.....")
	ShellExecuteWait("proxycfg.exe", "-d", "", "", @SW_HIDE)
	_MemoLogWrite("Proxy set to direct access.", 1)
	_MemoLogWrite("Restarting the Automatic Updates (wuauserv) Service.....")
	If ShellExecuteWait("net", "start wuauserv", "", "", @SW_HIDE) = 0 Then
		_MemoLogWrite("Automatic Updates (wuauserv) Service Restarted.", 1)
	Else
		_MemoLogWrite("The wuauserv Service could not be started or is already started.", 3)
	EndIf
	_MemoLogWrite("Restarting the BITS Service.....")
	If ShellExecuteWait("net", "start bits", "", "", @SW_HIDE) = 0 Then
		_MemoLogWrite("BITS Service Restarted.", 1)
	Else
		_MemoLogWrite("The BITS Service could not be started or is already started.", 3)
	EndIf
	If @OSVersion = "WIN_VISTA" Or @OSVersion = "WIN_2008" Then
		_MemoLogWrite("Clearing the BITS queue.....")
		ShellExecuteWait("bitsadmin.exe", "/reset /allusers", "", "", @SW_HIDE)
		_MemoLogWrite("BITS queue cleared.", 1)
	EndIf
	_RepairSHC()
	_MemoLogWrite("Finished repairing Windows Update / Automatic Updates.", 1)

EndFunc

Func _RepairSHC()
	_MemoLogWrite("Configuring the Cryptographic Service.....")
	ShellExecuteWait("sc", "config cryptsvc start= auto", "", "", @SW_HIDE)
	_MemoLogWrite("Cryptographic Service Configured.", 1)
	_MemoLogWrite("Stopping the Cryptographic Service.....")
	If ShellExecuteWait("net", "stop cryptsvc", "", "", @SW_HIDE) = 0 Then
		_MemoLogWrite("Cryptographic service Stopped.", 1)
	Else
		_MemoLogWrite("The Cryptographic service could not be stopped or was not started in the first place.", 3)
	EndIf
	_MemoLogWrite("Clearing " & $FCatRoot & "...")
	DirRemove($FCatRoot, 1)
	_MemoLogWrite($FCatRoot & " Cleared.")
	_ReregisterDLL("softpub.dll")
	_ReregisterDLL("wintrust.dll")
	_ReregisterDLL("initpki.dll")
	_ReregisterDLL("dssenh.dll")
	_ReregisterDLL("gpkcsp.dll")
	_ReregisterDLL("rsaenh.dll")
	_ReregisterDLL("sccbase.dll")
	_ReregisterDLL("slbcsp.dll")
	_ReregisterDLL("cryptdlg.dll")
	_ReregisterDLL("cryptui.dll")
	_ReregisterDLL("cryptext.dll")
	_ReregisterDLL("licdll.dll")
	_ReregisterDLL("mssign32.dll")
	_ReregisterDLL("mssip32.dll")
	_ReregisterDLL("scardssp.dll")
	_ReregisterDLL("scecli.dll")
	_ReregisterDLL("softpub.dll")
	_ReregisterDLL("slbcsp.dll")
	_ReregisterDLL("regwizc.dll")
	_ReregisterDLL("winhttp.dll")
	_MemoLogWrite("SSL / HTTPS / Cryptography DLLs Reregistered.", 1)
	_MemoLogWrite("Restarting the Cryptographic Service.....")
	If ShellExecuteWait("net", "start cryptsvc", "", "", @SW_HIDE) = 0 Then
		_MemoLogWrite("Cryptographic Service restarted.", 1)
	Else
		_MemoLogWrite("The Cryptographic Service could not be started or is already started.", 3)
	EndIf
	_MemoLogWrite("Finished repairing SSL / HTTPS / Cryptography.", 1)
EndFunc

Func _ResetInternetExplorer()
	_DisableControls()
	_MemoLogWrite("Resetting Internet Explorer .....")
	ShellExecuteWait("rundll32.exe", " setupapi,InstallHinfSection DefaultInstall 132 C:\WINDOWS\inf\iereset.inf", "", "", @SW_HIDE)
	_MemoLogWrite("Internet Explorer reset successfull.", 1)
	_EnableControls()
EndFunc

Func _SetGoogleAsHomePage()
	_MemoLogWrite("Setting Google.com as the default Internet Explorer Home Page.....")
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main", "Start Page", "REG_SZ", "http://www.google.com")
	_MemoLogWrite("Internet Explorer Home Page set to 'http://www.google.com'.", 1)
EndFunc

Func _SetGoogleAsDefaultSearch()
	_MemoLogWrite("Setting Google.com as the default Search Engine in Internet Explorer.....")
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main", "Use Search Asst", "REG_SZ", "no")
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main", "Search Page", "REG_SZ", "http://www.google.com")
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main", "Search Bar", "REG_SZ", "http://www.google.com/ie_rsearch.html")
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\SearchURL", "", "REG_SZ", "http://www.google.com/keyword/%s")
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\SearchURL", "provider", "REG_SZ", "gogl")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Search", "SearchAssistant", "REG_SZ", "http://www.google.com/ie_rsearch.html")
	_MemoLogWrite("Google.com is now the default Search Engine in Internet Explorer.", 1)
EndFunc

Func _ShowWinsockLSPs()
	_DisableControls()
	_MemoLogWrite("Generating List of Installed Winsock LSPs.....")
	RunWait(@ComSpec & ' /c netsh winsock show catalog >"' & $GLogDir & '\WinsLSP.log"', "", @SW_HIDE)
	_MemoLogWrite("Winsock LSPs List Saved to " & $GLogDir & "\WinsLSP.log", 1)
	_OpenTextFile($GLogDir & "\WinsLSP.log")
	_EnableControls()
EndFunc

Func _ResetTCPIP()
	Local Const $ResTCPIPLog = $GLogDir & "\Interface-Reset.log"

	_DisableControls()
	_MemoLogWrite("Resetting TCP/IP Stack.....")
	$EXCode = ShellExecuteWait("netsh", "interface ip reset """ & $ResTCPIPLog & """", "", "", @SW_HIDE)
	If $EXCode = 0 Then
		_MemoLogWrite("TCP/IP Stack reset successful.", 1)
		_MemoLogWrite("TCP/IP Reset log located @ " & $ResTCPIPLog, 1)
		;$MSGANS = MsgBox(68, "Open TCP/IP Reset log?", "A TCP/IP Reset log has been generated " & _
		;											   "and is located @ " & $ResTCPIPLog & ". " & _
		;											   "Would you like to view the log file now?")
		;If $MSGANS = 6 Then
		;	_OpenTextFile($ResTCPIPLog)
		;EndIf
	Else
		_MemoLogWrite("TCP/IP reset failed or no user specific settings found.", 2)
	EndIf
	_EnableControls()
EndFunc

Func _ResetTCPIPAll()
	_DisableControls()
	_MemoLogWrite("Resetting all TCP/IP Interfaces.....")
	$EXCode = ShellExecuteWait("netsh", "interface reset all", "", "", @SW_HIDE)
	If $EXCode = 0 Then
		_MemoLogWrite("TCP/IP interfaces reset successful.", 1)
	Else
		_MemoLogWrite("TCP/IP interfaces reset failed or no user specific settings found.", 2)
	EndIf
	_EnableControls()
EndFunc

Func _RepairWinsock()
	_DisableControls()
	_MemoLogWrite("Attempting to reset winsock catalog.....")
	If @OSVersion = "WIN_XP" Then
		If @OSServicePack = "Service Pack 1" Then
			_MemoLogWrite("It is recommended that you install Service Pack 2 or later.", 3)
			RegDelete("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Winsock")
			RegDelete("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Winsock2")
		Else
			$EXCode = ShellExecuteWait("netsh", "winsock reset catalog", "", "", @SW_HIDE)
			If $EXCode = 0 Then
				_MemoLogWrite("Successfully reset the Winsock Catalog.", 1)
				_BootMessage()
			Else
				_MemoLogWrite("Could not reset the Winsock Catalog.", 2)
			EndIf
		EndIf
	Else
		$EXCode = ShellExecuteWait("netsh", "winsock reset catalog", "", "", @SW_HIDE)
		If $EXCode = 0 Then
			_MemoLogWrite("Successfully reset the Winsock Catalog.", 1)
			_BootMessage()
		Else
			_MemoLogWrite(" Could not reset the Winsock Catalog.", 2)
		EndIf
	EndIf
	_EnableControls()
EndFunc

Func _RelRenewTCPIP()
	_DisableControls()
	_MemoLogWrite("Releasing TCP/IP connections.....")
	ShellExecuteWait("ipconfig", "/release", "", "", @SW_HIDE)
	_MemoLogWrite("Successfully released TCP/IP connections.", 1)
	_MemoLogWrite("Renewing TCP/IP adapters.....")
	ShellExecuteWait("ipconfig", "/renew", "", "", @SW_HIDE)
	_MemoLogWrite("Successfully renewed TCP/IP adapters.", 1)
	_EnableControls()
EndFunc

Func _FlushReregisterDNS()
	_DisableControls()
	_MemoLogWrite("Flushing DNS Resolver Cache.....")
	ShellExecuteWait("ipconfig", "/flushdns", "", "", @SW_HIDE)
	_MemoLogWrite("Success: Successfully flushed DNS Resolver Cache.", 1)
	_MemoLogWrite("Refreshing all DHCP leases and re-registering DNS names.....")
	ShellExecuteWait("ipconfig", "/registerdns", "", "", @SW_HIDE)
	_MemoLogWrite("Registration of the DNS resource records has been initiated.", 1)
	_MemoLogWrite("Any errors will be reported in the 'Event Viewer' in 15 minutes.", 3)
	_MemoLogWrite("Click on 'Administration' and then 'Event Viewer' to open the 'Event Viewer'.")
	_EnableControls()
EndFunc

Func _ResetFirewall()
	_DisableControls()
	_ResetFirewall2()
	_EnableControls()
EndFunc

Func _ResetFirewall2()
	_MemoLogWrite("Resetting Windows Firewall configuraton.....")
	If @OSVersion = "WIN_VISTA" Then
		$EXCode = ShellExecuteWait("netsh", "advfirewall reset", "", "", @SW_HIDE)
	Else
		$EXCode = ShellExecuteWait("netsh", "firewall reset", "", "", @SW_HIDE)
    EndIf
	If $EXCode = 0 Then
		_MemoLogWrite("Windows Firewall configuration reset successful.", 1)
	Else
		_MemoLogWrite("Could not reset Windows Firewall configuration.", 2)
	EndIf
EndFunc

Func _RebuildIconCacheOption()
	_MemoLogWrite("Rebuilding Icon Cache.....")
	_RebuildIconCache()
	If @error Then
		_MemoLogWrite("Something went wrong: Could not Rebuild Icon Cache.", 2)
	Else
		_MemoLogWrite("Finished Rebuilding Icon Cache.", 1)
	EndIf
EndFunc

Func _RebuildIconCache()
	Local Const $sKeyName = "HKCU\Control Panel\Desktop\WindowMetrics"
	Local Const $sValue = "Shell Icon Size"

	$sDataRet = RegRead($sKeyName, $sValue)
	If @error Then Return SetError(1)
	RegWrite($sKeyName, $sValue, "REG_SZ", $sDataRet + 1)
	If @error Then Return SetError(1)
	$bcA = _BroadcastChange()
	RegWrite($sKeyName, $sValue, "REG_SZ", $sDataRet)
	$bcB = _BroadcastChange()
	If $bcA = 0 Or $bcB = 0 Then Return SetError(1)
	Return
EndFunc ; ==> _RebuildShellIconCache

Func _BroadcastChange()
	Local Const $HWND_BROADCAST = 0xffff
	Local Const $WM_SETTINGCHANGE = 0x1a
	Local Const $SPI_SETNONCLIENTMETRICS = 0x2a
	Local Const $SMTO_ABORTIFHUNG = 0x2

	$bcResult = DllCall("user32.dll", "lresult", "SendMessageTimeout", _
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

Func _QuickEnableAll()
	_EnableRegistryEditor()
	_EnableTaskManager()
EndFunc

Func _EnableRegistryEditor()
	If RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System", "DisableRegistryTools") = 1 Then
		_MemoLogWrite("Enabling Registry Editor.....")
		$ErrCode = RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System", _
							"DisableRegistryTools", "REG_DWORD", 0)
		If $ErrCode = 1 Then
			_MemoLogWrite("Registry Editor Enabled.", 1)
		Else
			_MemoLogWrite("Could Not Enable Registry Editor.", 2)
		EndIf
	Else
		_MemoLogWrite("Registry Editor already enabled.", 1)
	EndIf
EndFunc

Func _EnableTaskManager()
	If RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System", "DisableTaskMgr") = 1 Then
		_MemoLogWrite("Enabling Task Manager.....")
		$ErrCode = RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System", _
							"DisableTaskMgr", "REG_DWORD", 0)
		If $ErrCode = 1 Then
			_MemoLogWrite("Task Manager Enabled.", 1)
		Else
			_MemoLogWrite("Could Not Enable Task Manager.", 2)
		EndIf
	Else
		_MemoLogWrite("Task Manager already enabled.", 1)
	EndIf
EndFunc

Func _ReinstallFirewall()
	_DisableControls()
	_MemoLogWrite("Reinstalling Windows Firewall.....")
	ShellExecuteWait("rundll32.exe", "setupapi.dll,InstallHinfSection Ndi-Steelhead 132 " & @WindowsDir & "\inf\netrass.inf", "", "", @SW_HIDE)
	_MemoLogWrite("Windows Firewall reinstalled successfully.", 1)
	_ResetFirewall2()
	_EnableControls()
EndFunc

Func _RepairFontRegistrations()
	_DisableControls()
	_MemoLogWrite("Removing any stale font registrations in the registry.....")
	_MemoLogWrite("Repairing any missing font registrations.....")
	Local $EXCode = ShellExecuteWait($GFontRegEXE)
	If @error Then
		_MemoLogWrite("Could nor repair font registrations.", 2)
	Else
		If $EXCode <> 0 Then
			_MemoLogWrite("Could nor repair font registrations.", 2)
		Else
			_MemoLogWrite("Font registrations repaired successfully.", 1)
		EndIf
	EndIf
	_EnableControls()
EndFunc

Func _ResetSecSettings()
	_DisableControls()
	If Not IsDeclared("EXCode") Then Local $EXCode
	_MemoLogWrite("Resetting security settings.....")
	If @OSVersion = "WIN_VISTA" Or @OSVersion = "WIN_2008" Then
		$EXCode = ShellExecuteWait("secedit", "/configure /cfg " & @WindowsDir & "\inf\defltbase.inf /db defltbase.sdb /verbose", _
		"", "", @SW_HIDE)
	Else
		If Not FileExists(@SystemDir & "\secedit.exe") Then
			$EXCode = ShellExecuteWait($GBinDir & "\secedit.exe", "/configure /cfg " & @WindowsDir & "\repair\secsetup.inf /db secsetup.sdb /verbose", "", "", @SW_HIDE)
		Else
			$EXCode = ShellExecuteWait("secedit", "/configure /cfg " & @WindowsDir & "\repair\secsetup.inf /db secsetup.sdb /verbose", "", "", @SW_HIDE)
		EndIf
	EndIf
	Switch $EXCode
		Case 3
			_MemoLogWrite("Security settings reset successful.", 1)
		Case 2
			_MemoLogWrite("Oops... Something went wrong!.", 2)
		Case -1073741510
			_MemoLogWrite("You canceled and broke it.", 3)
	EndSwitch
	_EnableControls()
EndFunc
