#include-once


#include <StringConstants.au3>


Func _ResetTCPIP()

	Local Const $ix = 0
	Local Const $ico = 605

	_BeginProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix])
	_StartLogging("Resetting all IP configurations.")
	_DrawInternetPage1Progress($ix, 50)

	If @OSVersion = "WIN_XP" Then
		_RunCommand("netsh interface ip reset " & Chr(34) & $LOG_IPRESET & Chr(34))
		_EditLoggingWrite("TCP/IP Reset log located @ [" & $LOG_IPRESET & "]")
		_EditLoggingWrite("Resetting IP version 4 configurations.", 1, 1)
		_RunCommand("netsh interface reset all")
	Else
		_EditLoggingWrite("Resetting IP version 4 configurations.", 1, 1)
		_RunCommand("netsh interface ipv4 reset all")
	EndIf

	_EditLoggingWrite("Resetting IP version 6 configurations.", 1, 1)
	_RunCommand("netsh interface ipv6 reset all")

	_DrawInternetPage1Progress($ix, 100)
	;~ _EditLoggingWrite("You may need to restart your computer for the settings to take effect.")
	_EndLogging()
	_DrawInternetPage1Progress($ix, 0)
	_EndProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix], $ico)

EndFunc


Func _RepairWinsock($IsInnerProcess = False)

	If Not IsDeclared("RESETWINSOCK") Then Local $RESETWINSOCK
	If Not IsDeclared("RESETFIREWALL") Then Local $RESETFIREWALL

	Local Const $ix = 1
	Local Const $ico = 606

	If Not $IsInnerProcess Then
		_BeginProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix])
		_StartLogging("Attempting to reset Winsock catalog.")
		_DrawInternetPage1Progress($ix, 50)
	EndIf

	If @OSVersion = "WIN_XP" Then
		If @OSServicePack = "Service Pack 1" Then
			_EditLoggingWrite("It is recommended that you install Windows XP Service Pack 2 or later.")
			RegDelete("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Winsock")
			RegDelete("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Winsock2")
		Else
			_ResetWinsock()
		EndIf
	Else
		_ResetWinsock()
	EndIf

	If Not $IsInnerProcess Then
		_DrawInternetPage1Progress($ix, 100)
			Sleep(100)
		_EndLogging()
		_DrawInternetPage1Progress($ix, 0)
		_EndProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix], $ico)
	EndIf

	$RESETWINSOCK = False

EndFunc


Func _ResetWinsock()
	_EditLoggingWrite("Resetting Winsock using Method 1.", 1, 1)
	_RunCommand("netsh winsock reset catalog")
	_EditLoggingWrite("Resetting Winsock using Method 2.", 1, 1)
	_RunCommand("netsh winsock reset")
EndFunc


Func _ReleaseRenewIP()

	If Not IsDeclared("RESETWINSOCK") Then Local $RESETWINSOCK

	Local Const $ix = 2
	Local Const $ico = 607

	_BeginProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix])

	_StartLogging("Releasing and Renewing TCP/IP connections.")
		Sleep(100)
	_EditLoggingWrite("Releasing TCP/IP connections.", 1, 1)
	_DrawInternetPage1Progress($ix, 25)
	_RunCommand("ipconfig /release")
	_DrawInternetPage1Progress($ix, 50)
	_EditLoggingWrite("Renewing TCP/IP connections.", 1, 1)
	_DrawInternetPage1Progress($ix, 75)
	_RunCommand("ipconfig /renew")

	If $RESETWINSOCK Then _RepairWinsock(True)

	_DrawInternetPage1Progress($ix, 100)
		Sleep(100)
	_EndLogging()

	_DrawInternetPage1Progress($ix, 0)
	_EndProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix], $ico)

EndFunc


Func _FlushReDNS()

	Local Const $ix = 3
	Local Const $ico = 608

	_BeginProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix])

	;~ If Not $EVNTLOG_CONFIGURED Then _ConfigureEventLog()
	_StartLogging("Flushing DNS Resolver Cache.")
		Sleep(100)
	_DrawInternetPage1Progress($ix, 30)
	_RunCommand("ipconfig /flushdns")
	_DrawInternetPage1Progress($ix, 60)
	_RunCommand("ipconfig /registerdns")

	_DrawInternetPage1Progress($ix, 100)
		Sleep(100)
	_EndLogging()

	_DrawInternetPage1Progress($ix, 0)
	_EndProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix], $ico)

EndFunc


Func _ResetProxyServer($IsInnerProcess = False)

	If Not IsDeclared("RESETPROXY") Then Local $RESETPROXY

	Local Const $ix = 4
	Local Const $ico = 609

	If Not $IsInnerProcess Then

		_BeginProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix])
		_StartLogging("Resetting proxy settings.")
			Sleep(100)
		_DrawInternetPage1Progress($ix, 1)

	Else
		_EditLoggingWrite("Resetting proxy settings.", 1, 1)
	EndIf

	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2003" Then
		_EditLoggingWrite("Setting proxy to direct access.", 1, 1)
		_RunCommand("proxycfg.exe -d")
	Else
		_RunCommand("netsh winhttp reset proxy")
	EndIf

	If Not $IsInnerProcess Then

		_DrawInternetPage1Progress($ix, 100)
			Sleep(100)
		_EndLogging()
		_DrawInternetPage1Progress($ix, 0)
		_EndProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix], $ico)

	EndIf

	$RESETPROXY = False

EndFunc


Func _ResetFirewall($IsInnerProcess = False)

	If Not IsDeclared("RESETFIREWALL") Then Local $RESETFIREWALL

	Local Const $ix = 5
	Local Const $ico = 610

	If Not $IsInnerProcess Then

		_BeginProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix])
		_StartLogging("Resetting the Windows Firewall configuraton.")
			Sleep(100)
		_DrawInternetPage1Progress($ix, 50)

	Else
		_EditLoggingWrite("Resetting the Windows Firewall configuraton.", 1, 1)
	EndIf

	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2003" Then
		_RunCommand("netsh firewall reset")
	Else
		_RunCommand("netsh advfirewall reset")
	EndIf

	If Not $IsInnerProcess Then

		_DrawInternetPage1Progress($ix, 100)
			Sleep(100)
		_EndLogging()
		_DrawInternetPage1Progress($ix, 0)
		_EndProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix], $ico)

	EndIf

	$RESETFIREWALL = False

EndFunc


Func _RestoreWindowsHosts()

	Local Const $ix = 6
	Local Const $ico = 611
	Local Const $lHOSTS = @WindowsDir & "\System32\drivers\etc\hosts"

	_BeginProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix])
	_StartLogging("Restoring the default Windows HOSTS file.")
		Sleep(100)
	_DrawInternetPage1Progress($ix, 10)

	FileSetAttrib($lHOSTS, "-RASHNOT")
	_DrawInternetPage1Progress($ix, 20)
	FileCopy($lHOSTS, @SystemDir & "\drivers\etc\hosts.bak")
	_DrawInternetPage1Progress($ix, 30)
	FileDelete($lHOSTS)
	_DrawInternetPage1Progress($ix, 40)

	Local $oHOSTS = FileOpen($lHOSTS, 1)

	If $lHOSTS = -1 Then
		_EditLoggingWrite("An error occurred whilst writing the hosts file.", 1, 1)
	Else

		_EditLoggingWrite("Writing data to the HOSTS file.", 1, 1)

		FileWrite($oHOSTS, "# Copyright (c) 1993-2009 Microsoft Corp." & @CRLF)
		FileWrite($oHOSTS, "#" & @CRLF)
		FileWrite($oHOSTS, "# This is a sample HOSTS file used by Microsoft TCP/IP for Windows." & @CRLF)
		FileWrite($oHOSTS, "#" & @CRLF)
		FileWrite($oHOSTS, "# This file contains the mappings of IP addresses to host names. Each" & @CRLF)
		FileWrite($oHOSTS, "# entry should be kept on an individual line. The IP address should" & @CRLF)
		FileWrite($oHOSTS, "# be placed in the first column followed by the corresponding host name." & @CRLF)
		FileWrite($oHOSTS, "# The IP address and the host name should be separated by at least one" & @CRLF)
		FileWrite($oHOSTS, "# space." & @CRLF)
		FileWrite($oHOSTS, "#" & @CRLF)
		FileWrite($oHOSTS, "# Additionally, comments (such as these) may be inserted on individual" & @CRLF)
		FileWrite($oHOSTS, "# lines or following the machine name denoted by a '#' symbol." & @CRLF)
		FileWrite($oHOSTS, "#" & @CRLF)
		FileWrite($oHOSTS, "# For example:" & @CRLF)
		FileWrite($oHOSTS, "#" & @CRLF)
		FileWrite($oHOSTS, "#      102.54.94.97     rhino.acme.com          # source server" & @CRLF)
		FileWrite($oHOSTS, "#       38.25.63.10     x.acme.com              # x client host" & @CRLF)
		FileWrite($oHOSTS, "" & @CRLF)

		Switch @OSVersion
			Case "WIN_XP", "WIN_2003"
				FileWrite($oHOSTS, "127.0.0.1       localhost" & @CRLF)
			Case "WIN_VISTA", "WIN_2008"
				FileWrite($oHOSTS, "127.0.0.1       localhost" & @CRLF)
				FileWrite($oHOSTS, "::1             localhost" & @CRLF)
			Case Else
				FileWrite($oHOSTS, "# localhost name resolution is handled within DNS itself." & @CRLF)
				FileWrite($oHOSTS, "#       127.0.0.1       localhost" & @CRLF)
				FileWrite($oHOSTS, "#       ::1             localhost" & @CRLF)
		EndSwitch

		FileClose($oHOSTS)

		_EditLoggingWrite("HOSTS file created successfully.", 1, 1)

	EndIf

	_DrawInternetPage1Progress($ix, 100)
		Sleep(100)
	_EndLogging()
	_DrawInternetPage1Progress($ix, 0)
	_EndProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix], $ico)

EndFunc


Func _RepairInternetExplorer()

	Local Const $ix = 7
	Local Const $ico = 612

	_BeginProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix])
	_StartLogging("Repairing Internet Explorer " & $STR_IEVERSION & ".")
		Sleep(100)
	_DrawInternetPage1Progress($ix, 1)
	If ProcessExists("iexplore.exe") Then
		MsgBox(48, "Internet Explorer", "Closing Internet Explorer.  Save your work before you press OK")
		ProcessClose("iexplore.exe")
	EndIf

	Local $sIEDlls = 	"custsat.dll|D3DCompiler_47.dll|DiagnosticsHub_is.dll|DiagnosticsTap.dll|F12.dll|F12Tools.dll|hmmapi.dll|iedvtool.dll|" & _
						"ieproxy.dll|IEShims.dll|jsdbgui.dll|jsdebuggeride.dll|JSProfilerCore.dll|jsprofilerui.dll|IEShims.dll|" & _
						"msdbg2.dll|networkinspection.dll|pdm.dll|pdmproxy100.dll|perf_nt.dll|perfcore.dll|sqmapi.dll|Timeline_is.dll"

	Local $aIEDlls = StringSplit($sIEDlls, "|")
	Local $iDllDefCount = $aIEDlls[0]
	Local $sProcTemp, $iDllKillCount = 0, $iDllKillPerc = 0, $iPercChange = 0

	For $x = 1 To $iDllDefCount

		_SwithRegDll64Bit($aIEDlls[$x])

		$iDllKillCount = $iDllKillCount + 1
		$iDllKillPerc = Int($iDllKillCount / $iDllDefCount * 30)

		If $iDllKillPerc <> $iPercChange Then
				_DrawInternetPage1Progress($ix, Round($iDllKillPerc))
				$iPercChange = $iDllKillPerc
		EndIf

		_GUICtrlFFLabel_SetData($LBL_STATUS, "Registering IE Dlls ( " & $iDllKillCount & " / " & $iDllDefCount & " )")

	Next

	;~ Symptom: open in new tab/window not working
	_DrawInternetPage1Progress($ix, 33)
	_EditLoggingWrite("Repairing: open in new tab/window not working.", 1, 1)
	_ReregisterDLL("actxprxy.dll")
	_ReregisterDLL("asctrls.ocx")
	_ReregisterDLL("browseui.dll", "/s /i")
	;~ regsvr32 /s /i browseui.dll,NI (unnecessary)
	_ReregisterDLL("cdfview.dll")
	_ReregisterDLL("comcat.dll")
	_ReregisterDLL("comctl32.dll", "/s /i /n")
	_ReregisterDLL("corpol.dll")
	_ReregisterDLL("cryptdlg.dll")
	_ReregisterDLL("digest.dll", "/s /i /n")
	_ReregisterDLL("dispex.dll")
	_ReregisterDLL("dxtmsft.dll")
	_ReregisterDLL("dxtrans.dll")

	;~ Symptom: Add-Ons-Manager menu entry is present but nothing happens
	_DrawInternetPage1Progress($ix, 36)
	_EditLoggingWrite("Repairing: Add-Ons-Manager menu entry is present but nothing happens.", 1, 1)
	_ReregisterDLL("extmgr.dll")


	;~ Simple HTML Mail API
	_DrawInternetPage1Progress($ix, 39)
	_EditLoggingWrite("Repairing: Simple HTML Mail API.", 1, 1)
	_ReregisterDLL("hlink.dll")

	;~ Group policy snap-in
	_DrawInternetPage1Progress($ix, 42)
	_EditLoggingWrite("Repairing: Group policy snap-in.", 1, 1)
	_ReregisterDLL("ieaksie.dll")

	;~ Smart Screen
	_DrawInternetPage1Progress($ix, 45)
	_EditLoggingWrite("Repairing: Smart Screen.", 1, 1)
	_ReregisterDLL("ieapfltr.dll")

	;~ IEAK Branding
	_DrawInternetPage1Progress($ix, 48)
	_EditLoggingWrite("Repairing: IEAK Branding.", 1, 1)
	_ReregisterDLL("iedkcs32.dll")

	;~ Dev Tools
	_DrawInternetPage1Progress($ix, 51)
	_EditLoggingWrite("Repairing: Dev Tools.", 1, 1)
	_ReregisterDLL("iedvtool.dll")

	;~ IE7 tabbed browser
	_DrawInternetPage1Progress($ix, 54)
	_ReregisterDLL("ieframe.dll", "/s /i /n")
	;~ _ReregisterDLL("ieframe.dll", "/s /i")
	_ReregisterDLL("iepeers.dll")

	;~ Symptom: IE8 closes immediately on launch, missing from IE7
	_DrawInternetPage1Progress($ix, 57)
	_EditLoggingWrite("Repairing: IE8 closes immediately on launch.", 1, 1)
	_ReregisterDLL("ieproxy.dll")
	;~ iesetup.dll has DllINstall for WinXP,NT4Only,NTx86
	_ReregisterDLL("iesetup.dll", "/s /i")
	_ReregisterDLL("imgutil.dll")
	_ReregisterDLL("inetcpl.cpl", "/s /i")
	_ReregisterDLL("inetcpl.cpl", "/s /i /n")
	_ReregisterDLL("initpki.dll", "/s /i:A")
	_ReregisterDLL("inseng.dll", "/s /i")
	_ReregisterDLL("jscript.dll")

	;~ License Manager
	_DrawInternetPage1Progress($ix, 60)
	_EditLoggingWrite("Repairing: License Manager.", 1, 1)
	_ReregisterDLL("licmgr10.dll")
	_ReregisterDLL("mlang.dll")
	_ReregisterDLL("mobsync.dll")
	_ReregisterDLL("msapsspc.dll")

	;~ Symptom: Javascript links don't work (Robin Walker) .NET hub file
	_DrawInternetPage1Progress($ix, 63)
	_EditLoggingWrite("Repairing: Javascript links don't work (Robin Walker) .NET hub file.", 1, 1)
	_ReregisterDLL("mscoree.dll")
	_ReregisterDLL("mscorier.dll")
	_ReregisterDLL("mscories.dll")

	;~ VS Debugger
	_DrawInternetPage1Progress($ix, 66)
	_EditLoggingWrite("Repairing: VS Debugger.", 1, 1)
	_ReregisterDLL("msdbg2.dll")
	_ReregisterDLL("mshta.exe")
	_ReregisterDLL("mshtml.dll", "/s /i")
	_ReregisterDLL("mshtmled.dll")
	_ReregisterDLL("msident.dll")
	_ReregisterDLL("msieftp.dll", "/s /i")
	_ReregisterDLL("msnsspc.dll")
	_ReregisterDLL("msr2c.dll")
	_ReregisterDLL("msrating.dll")
	_ReregisterDLL("mstime.dll")
	_ReregisterDLL("msxml.dll")

	;~ Symptom: Printing problems, open in new window
	_DrawInternetPage1Progress($ix, 69)
	_EditLoggingWrite("Repairing: Printing problems, open in new window.", 1, 1)
	_ReregisterDLL("ole32.dll")

	;~ Symptom: Find on this page is blank
	_DrawInternetPage1Progress($ix, 72)
	_EditLoggingWrite("Repairing: Find on this page is blank.", 1, 1)
	_ReregisterDLL("oleacc.dll")
	_ReregisterDLL("occache.dll", "/s /i")
	_ReregisterDLL("oleaut32.dll")

	;~ Process debug manager
	_DrawInternetPage1Progress($ix, 75)
	_EditLoggingWrite("Repairing: Process debug manager.", 1, 1)
	_ReregisterDLL("plugin.ocx")
	_ReregisterDLL("pngfilt.dll")
	_ReregisterDLL("proctexe.ocx")
	_ReregisterDLL("scrobj.dll", "/s /i")
	_ReregisterDLL("sendmail.dll")
	_ReregisterDLL("setupwbv.dll", "/s /i")
	_ReregisterDLL("shdocvw.dll", "/s /i")
	;~ regsvr32 /s /i shdocvw.dll,NI
	_ReregisterDLL("tdc.ocx")
	_ReregisterDLL("url.dll")
	_ReregisterDLL("urlmon.dll", "/s /i")
	;~ regsvr32 /s /i urlmon.dll,NI,HKLM
	_ReregisterDLL("urlmon.dll,NI,HKLM", "/s /i")
	_ReregisterDLL("vbscript.dll")

	;~ VML Renderer
	_DrawInternetPage1Progress($ix, 78)
	_EditLoggingWrite("Repairing: VML Renderer.", 1, 1)
	_ReregisterDLL(Chr(34) & @ProgramFilesDir & "\microsoft shared\vgx\vgx.dll" & Chr(34))
	_ReregisterDLL("webcheck.dll", "/s /i")
	;_ReregisterDLL("wininet.dll", "/s /i /n")

	If @OSVersion = "WIN_XP" Then

		;~ Symptom: new tabs page cannot display content because it cannot access the controls (added 27. 3.2009)
		;~ This is a result of a bug in shdocvw.dll (see above), probably only on Windows XP
		_EditLoggingWrite("Fixing 'New tabs page cannot display content because it cannot access the controls'.")
		_EditLoggingWrite("This is a result of a bug in shdocvw.dll.")
		RegWrite("HKEY_CLASSES_ROOT\TypeLib\{EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}\1.1\0\win32", "", "REG_SZ", "%SystemRoot%\system32\ieframe.dll")
		_ReturnRegistryError(@error)

		_EditLoggingWrite("Repairing Outlook Express.")
		_ReregisterDLL(Chr(34) & @ProgramFilesDir & "\Outlook Express\msoe.dll" & Chr(34))
		_ReregisterDLL(Chr(34) & @ProgramFilesDir & "\Outlook Express\oeimport.dll" & Chr(34))
		_ReregisterDLL(Chr(34) & @ProgramFilesDir & "\Outlook Express\oemiglib.dll" & Chr(34))
		_ReregisterDLL(Chr(34) & @ProgramFilesDir & "\Outlook Express\wabfind.dll" & Chr(34))
		_ReregisterDLL(Chr(34) &  @ProgramFilesDir & "\Outlook Express\wabimp.dll" & Chr(34))

		;~ _MemoLogWrite("Registering Connection Wizard files.....")
		;~ _ReregisterDLL("""" & @ProgramFilesDir & "\Internet Explorer\Connection Wizard\icwconn.dll""")
		;~ _ReregisterDLL("""" & @ProgramFilesDir & "\Internet Explorer\Connection Wizard\icwdl.dll""")
		;~ _ReregisterDLL("""" & @ProgramFilesDir & "\Internet Explorer\Connection Wizard\icwutil.dll""")
		;~ _ReregisterDLL("""" & @ProgramFilesDir & "\Internet Explorer\Connection Wizard\trialoc.dll""")

	EndIf

	_DrawInternetPage1Progress($ix, 100)
		Sleep(100)
	_EndLogging()

	_DrawInternetPage1Progress($ix, 0)
	_EndProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix], $ico)


EndFunc


Func _SwithRegDll64Bit($sDllName)

	Local $sProgFiles86 = StringReplace(@ProgramFilesDir, "Program Files", "Program Files (x86)", 1, $STR_NOCASESENSE)
	_ReregisterDLL(Chr(34) & @ProgramFilesDir & "\Internet Explorer\" & $sDllName & Chr(34))

	If @OSArch = "X64" Then
		_ReregisterDLL(Chr(34) & $sProgFiles86 & "\Internet Explorer\" & $sDllName & Chr(34))
	EndIf

EndFunc


Func _RepairWindowsUpdate()

	If Not IsDeclared("CLEARWINUPDATE") Then Local $CLEARWINUPDATE
	If Not IsDeclared("RESETWINSOCK") Then Local $RESETWINSOCK
	If Not IsDeclared("RESETPROXY") Then Local $RESETPROXY

	;~ If Not $EVNTLOG_CONFIGURED Then _ConfigureEventLog()

	Local Const $ix = 10
	Local Const $ico = 615

	_BeginProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix])
	_StartLogging("Repairing Windows Update / Automatic Updates.")
		Sleep(100)

	_DrawInternetPage1Progress($ix, 3)
	If _ProgramFileExists(@ProgramFilesDir & "\Nero\Update\NASvc.exe") Then
		_EditLoggingWrite("Stopping the Nero Update Service.")
		_RunCommand("net stop NAUpdate")
	EndIf

	_DrawInternetPage1Progress($ix, 6)
	_EditLoggingWrite("Stopping the BITS Service.")
	_RunCommand("net stop bits")

	_DrawInternetPage1Progress($ix, 9)
	_EditLoggingWrite("Stopping the Automatic Updates Service.")
	_RunCommand("net stop wuauserv")

	_DrawInternetPage1Progress($ix, 12)
	If $CLEARWINUPDATE Then _ClearUpdateHistory(True)

	_DrawInternetPage1Progress($ix, 15)
	_EditLoggingWrite("Setting BITS Security Descriptor.")
	_RunCommand("sc sdset bits " & Chr(34) & "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" & Chr(34))

	_DrawInternetPage1Progress($ix, 18)
	_EditLoggingWrite("Setting Automatic Updates Service Security Descriptor.")
	_RunCommand("sc sdset wuauserv " & Chr(34) & "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" & Chr(34))

	_DrawInternetPage1Progress($ix, 21)
	_EditLoggingWrite("Configuring the Automatic Updates Service.")
	_RunCommand("sc config wuauserv start= auto")

	_DrawInternetPage1Progress($ix, 24)
	_EditLoggingWrite("Configuring BITS.")
	_RunCommand("sc config bits start= auto")

	_DrawInternetPage1Progress($ix, 27)
	_EditLoggingWrite("Registering Windows Updates Dlls.")

	Local $sWADlls = 	"actxprxy.dll|atl.dll|browseui.dll|corpol.dll|cryptdlg.dll|dispex.dll|dssenh.dll|gpkcsp.dll|initpki.dll|" & _
						"jscript.dll|mshtml.dll|msscript.ocx|msxml.dll|msxml2.dll|msxml3.dll|msxml4.dll|msxml6.dll|muweb.dll|" & _
						"ole.dll|ole32.dll|oleaut.dll|oleaut32.dll|qmgr.dll|qmgrprxy.dll|gpkcsp.dll|rsaenh.dll|sccbase.dll|scrobj.dll|" & _
						"scrrun.dll|shdocvw.dll|shell.dll|shell32.dll|slbcsp.dll|softpub.dll|urlmon.dll|vbscript.dll|winhttp.dll|" & _
						"wintrust.dll|wshext.dll|wuapi.dll|wuaueng.dll|wuaueng1.dll|wucltui.dll|wucltux.dll|wups.dll|wups2.dll|wuweb.dll|" & _
						"wuwebv.dll"

	Local $aWADlls = StringSplit($sWADlls, "|")
	Local $iDllDefCount = $aWADlls[0]
	Local $sProcTemp, $iDllKillCount = 0, $iDllKillPerc = 0, $iPercChange = 0

	For $x = 1 To $iDllDefCount

		$iDllKillCount = $iDllKillCount + 1
		$iDllKillPerc = Int($iDllKillCount / $iDllDefCount * 33)

		If $iDllKillPerc <> $iPercChange Then
			_DrawInternetPage1Progress($ix, Round($iDllKillPerc) + 27)
			$iPercChange = $iDllKillPerc
		EndIf

		_ReregisterDLL($aWADlls[$x])
		_GUICtrlFFLabel_SetData($LBL_STATUS, "Registering Update Dlls ( " & $iDllKillCount & " / " & $iDllDefCount & " )")

	Next

	If $RESETWINSOCK Then _RepairWinsock(True)

	_DrawInternetPage1Progress($ix, 63)
	If $RESETPROXY Then _ResetProxyServer(True)

	_DrawInternetPage1Progress($ix, 66)
	_EditLoggingWrite("Restarting the Automatic Updates Service.", 1, 1)
	_RunCommand("net start wuauserv")

	_DrawInternetPage1Progress($ix, 69)
	_EditLoggingWrite("Restarting the BITS Service.", 1, 1)
	_RunCommand("net start bits")

	_DrawInternetPage1Progress($ix, 72)
	If _ProgramFileExists(@ProgramFilesDir & "\Nero\Update\NASvc.exe") Then
		_EditLoggingWrite("Restarting the Nero Update Service.")
		_RunCommand("net start NAUpdate")
	EndIf

	_DrawInternetPage1Progress($ix, 75)
	_EditLoggingWrite("Clean transactional metadata on next Transactional Resource Manager mount.", 1, 1)
	_RunCommand("fsutil resource setautoreset true " & @HomeDrive & ":\")

	If @OSVersion <> "WIN_XP" Then

		_EditLoggingWrite("Clearing the BITS queue.", 1, 1)
		_RunCommand("bitsadmin.exe /reset /allusers")

	EndIf

	_DrawInternetPage1Progress($ix, 78)
	RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Group Policy Objects\LocalUser\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate\DisableWindowsUpdateAccess")
	RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoWindowsUpdate")
	RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDevMgrUpdate")
	RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate", "DisableWindowsUpdateAccess")
	RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate")

	_DrawInternetPage1Progress($ix, 81)
	RegDelete("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoWindowsUpdate")
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "NoAutoUpdate")
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "AUOptions")
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "ScheduledInstallDay")
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "ScheduledInstallTime")
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "NoAutoRebootWithLoggedOnUsers")
	RegDelete("HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WindowsUpdate")
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "LastWaitTimeout")
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "DetectionStartTime")
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "NextDetectionTime")
	RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "ScheduledInstallDate")

	_DrawInternetPage1Progress($ix, 84)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "NoAutoUpdate", "REG_DWORD", 0)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "AUOptions", "REG_DWORD", 4)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "ScheduledInstallDay", "REG_DWORD", 0)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "ScheduledInstallTime", "REG_DWORD", 3)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "NoAutoRebootWithLoggedOnUsers", "REG_DWORD", 1)

	_DrawInternetPage1Progress($ix, 87)
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main", "NoUpdateCheck", "REG_DWORD", 0)

	_DrawInternetPage1Progress($ix, 90)
	_EditLoggingWrite("Initiating Windows Updates detection right away.", 1, 1)
	_RunCommand("wuauclt /detectnow")

	_DrawInternetPage1Progress($ix, 100)
		Sleep(100)
	_EndLogging()

	_DrawInternetPage1Progress($ix, 0)
	_EndProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix], $ico)

EndFunc


Func _ClearUpdateHistory($IsInnerProcess = False)

	Local Const $ix = 11
	Local Const $ico = 616

	If $IsInnerProcess = False Then

		_BeginProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix])
		_StartLogging("Clearing File Stores (Update History).")
			Sleep(100)
		_DrawInternetPage1Progress($ix, 25)

	Else
		_EditLoggingWrite("Clearing File Stores (Update History).")
	EndIf

	FileDelete(@AppDataCommonDir & "\Microsoft\Network\Downloader\qmgr*.dat")

	_RemoveDirectory($DIR_SDDOWNLOAD, $DIR_SDDOWNLOADOLD)
	If $IsInnerProcess = False Then _DrawInternetPage1Progress($ix, 50)
	_RemoveDirectory($DIR_SDDATASTORE, $DIR_SDDATASTOREOLD)
	If $IsInnerProcess = False Then _DrawInternetPage1Progress($ix, 75)
	_RemoveDirectory($DIR_CATROOT2, $DIR_CATROOT2OLD)

	If $IsInnerProcess = False Then

		_DrawInternetPage1Progress($ix, 100)
			Sleep(100)
		_EndLogging()
		_DrawInternetPage1Progress($ix, 0)
		_EndProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix], $ico)

	EndIf

	$CLEARWINUPDATE = False

EndFunc


Func _RepairCryptography()

	;~ If Not $EVNTLOG_CONFIGURED Then _ConfigureEventLog()

	Local Const $ix = 12
	Local Const $ico = 617

	_BeginProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix])
	_StartLogging("Repairing SSL / HTTPS / Cryptography service.")
		Sleep(100)
	_DrawInternetPage1Progress($ix, 1)

	_DrawInternetPage1Progress($ix, 5)
	_EditLoggingWrite("Stopping the Cryptographic Service.")
	_RunCommand("net stop CryptSvc")
	_DrawInternetPage1Progress($ix, 10)
	_EditLoggingWrite("Configuring the Cryptographic Service.")
	_RunCommand("sc config CryptSvc start= auto")

	_EditLoggingWrite("Clearing [" & $DIR_CATROOT2 & "].", 1, 1)
	_RemoveDirectory($DIR_CATROOT2, $DIR_CATROOT2OLD)

	_EditLoggingWrite("Clearing [" & @WindowsDir & "\system32\CatRoot].", 1, 1)
	_DrawInternetPage1Progress($ix, 15)
	FileDelete(@WindowsDir & "\system32\CatRoot\{F750E6C3-38EE-11D1-85E5-00C04FC295EE}\tmp*.CAT")
	_DrawInternetPage1Progress($ix, 20)
	FileDelete(@WindowsDir & "\system32\CatRoot\{127D0A1D-4EF2-11D1-8608-00C04FC295EE}\tmp*.CAT")
	_DrawInternetPage1Progress($ix, 25)
	FileDelete(@WindowsDir & "\system32\CatRoot\{F750E6C3-38EE-11D1-85E5-00C04FC295EE}\KB*.CAT")
	_DrawInternetPage1Progress($ix, 30)
	FileDelete(@WindowsDir & "\system32\CatRoot\{127D0A1D-4EF2-11D1-8608-00C04FC295EE}\KB*.CAT")
	_DrawInternetPage1Progress($ix, 35)
	FileDelete(@WindowsDir & "\inf\oem*.*")
	_EditLoggingWrite("[" & @WindowsDir & "\system32\CatRoot] cleared." , 1, 1)

	_EditLoggingWrite("Registering SSL / HTTPS / Cryptography DLLs.", 1, 1)
	_ReregisterDLL("cryptdlg.dll")
	_ReregisterDLL("cryptext.dll")
	_ReregisterDLL("cryptui.dll")
	_ReregisterDLL("dssenh.dll")
	_ReregisterDLL("gpkcsp.dll")
	_ReregisterDLL("initpki.dll")
	_ReregisterDLL("licdll.dll")
	_ReregisterDLL("mssign32.dll")
	_ReregisterDLL("mssip32.dll")
	_ReregisterDLL("regwizc.dll")
	_ReregisterDLL("rsaenh.dll")
	_ReregisterDLL("scardssp.dll")
	_ReregisterDLL("sccbase.dll")
	_ReregisterDLL("scecli.dll")
	_ReregisterDLL("slbcsp.dll")
	_ReregisterDLL("softpub.dll")
	_ReregisterDLL("winhttp.dll")
	_ReregisterDLL("wintrust.dll")
	_EditLoggingWrite("SSL / HTTPS / Cryptography DLLs Registered.", 1, 1)
	_DrawInternetPage1Progress($ix, 40)

	FileSetAttrib(@WindowsDir, "-RSH")
	_DrawInternetPage1Progress($ix, 45)
	FileSetAttrib(@WindowsDir & "\System32", "-RSH")
	_DrawInternetPage1Progress($ix, 50)
	FileSetAttrib($DIR_CATROOT2, "-RSH", 1)

	_DrawInternetPage1Progress($ix, 55)
	_EditLoggingWrite("Restarting the Cryptographic Service.", 1, 1)
	_RunCommand("net start CryptSvc")

	_DrawInternetPage1Progress($ix, 100)
		Sleep(100)
	_EndLogging()
	_DrawInternetPage1Progress($ix, 0)
	_EndProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix], $ico)

EndFunc


Func _RepairNeroUpdate()


	Local Const $ix = 14
	Local Const $ico = 619

	_BeginProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix])
	_StartLogging("Repairing Nero Update.")
		Sleep(100)
	_DrawInternetPage1Progress($ix, 5)


	If _ProgramFileExists(@ProgramFilesDir & "\Nero\Update\NASvc.exe") Then

		_DrawInternetPage1Progress($ix, 10)
		_EditLoggingWrite("Stopping the Nero Update Service.")
		_RunCommand("Echo Y|net stop NAUpdate")

		_DrawInternetPage1Progress($ix, 15)
		_EditLoggingWrite("Configuring the Nero Update Service.")
		_RunCommand("sc config NAUpdate start= delayed-auto")

		_DrawInternetPage1Progress($ix, 20)
		_EditLoggingWrite("Registering Nero Update DLLs.", 1, 1)
		_ReregisterDLL(@ProgramFilesDir & "\Nero\Update\NASvcPS.dll")
		_DrawInternetPage1Progress($ix, 25)
		_ReregisterDLL(@ProgramFilesDir & "\Nero\Update\SolutionExplorer.dll")

		_EditLoggingWrite("Use global Nero Update Server to check for updates.")
		_RegistryDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Nero\Agent", "UpdateRepository")
		_EditLoggingWrite("Removing fixed update check interval.")
		_RegistryDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Nero\Agent", "CheckInterval")
		_EditLoggingWrite("Removing all other Nero update restrictions.")
		_RegistryDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Nero\Agent", "DenyCheck")
		_RegistryDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Nero\Agent", "DenyDownload")
		_RegistryDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Nero\Agent", "DenyInstall")
		_RegistryDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Nero\Agent", "DenyUI")
		_RegistryDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Nero\Agent", "NoLocalCache")

		_DrawInternetPage1Progress($ix, 95)
		_EditLoggingWrite("Restarting the Nero Update Service.")
		_RunCommand("net start NAUpdate")

	Else
		_EditLoggingWrite("It looks like Nero is not installed.", 1, 1)
	EndIf

	_DrawInternetPage1Progress($ix, 100)
			Sleep(100)
	_EndLogging()
	_DrawInternetPage1Progress($ix, 0)
	_EndProcess($ICON_INTERNET1[$ix], $CHK_INTERNET1[$ix], $ico)

EndFunc


Func _DrawInternetPage1Progress($iIndex, $iPerc)
	_DrawStatusSizeFromPercentage($PROGRESS_INTERNET1[$iIndex], $iPerc, 365, $PRGTOP_INTERNET1[$iIndex], 310, 1)
EndFunc