#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

#include-once


#include <CoreWinRepair.au3>
#include <Services.au3>


Func _ResetTCPIP()

	_MemoLoggingWrite("Resetting all TCP/IP interfaces, please wait...", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

	Switch @OSVersion
		Case "WIN_XP", "WIN_2003"
			_ConsoleRun("netsh interface ip reset """ & $LOGGING_CIRRESET & """")
			_MemoLoggingWrite("TCP/IP Reset log located @ [" & $LOGGING_CIRRESET & "]", 1)
			_ConsoleRun("netsh interface reset all")
			_ConsoleRun("netsh interface ipv6 reset all")
		Case "WIN_VISTA", "WIN_2008", "WIN_2008R2", "WIN_7"
			_ConsoleRun("netsh interface ipv4 reset all")
			_ConsoleRun("netsh interface ipv6 reset all")
	EndSwitch
	;_MemoLoggingWrite("You may need to restart your computer for the settings to take effect.")
	_MemoLoggingWrite("Finished resetting the Internet Protocol (TCP/IP).")
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _RepairWinsock()

	$RESETWINSOCK = True
	_MemoLoggingWrite("Attempting to reset Winsock catalog, please wait...", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

	Switch @OSVersion
		Case "WIN_XP"
			Switch @OSServicePack
				Case "Service Pack 1"
					_MemoLoggingWrite("It is recommended that you install Windows XP Service Pack 2 or later.", 3)
					RegDelete("HKLM\System\CurrentControlSet\Services\Winsock")
					RegDelete("HKLM\System\CurrentControlSet\Services\Winsock2")
				Case Else
					_ResetWinsock()
			EndSwitch
		Case "WIN_2003", "WIN_VISTA", "WIN_2008", "WIN_2008R2", "WIN_7"
			_ResetWinsock()
	EndSwitch
	_MemoLoggingWrite("Finished repairing Winsock")
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _ResetWinsock()
	_ConsoleRun("netsh winsock reset catalog")
	_ConsoleRun("netsh winsock reset")
EndFunc


Func _ReleaseRenewIP()

	_MemoLoggingWrite("Releasing TCP/IP connections, please wait...", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
	_ConsoleRun("ipconfig /release")
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
	_MemoLoggingWrite("Renewing TCP/IP connections, please wait...", False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
	_ConsoleRun("ipconfig /renew")
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _FlushRegisterDNS()

	If Not $EVENTLOG_CONFIGURED Then _ConfigureEventLog()
	_MemoLoggingWrite("Flushing DNS Resolver Cache, please wait...", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
	_ConsoleRun("ipconfig /flushdns")
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
	_MemoLoggingWrite("Refreshing all DHCP leases and re-registering DNS names, please wait...")
	_ConsoleRun("ipconfig /registerdns")
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _RepairIE()

	_StartLogging("Repairing Internet Explorer " & _GetIntExplorerVersion() & ", please wait...")
	If ProcessExists("iexplore.exe") Then
		MsgBox(48, "Internet Explorer", "Closing Internet Explorer.  Save your work before you press OK")
		ProcessClose("iexplore.exe")
	EndIf

	;~ Symptom: open in new tab/window not working
	_ReregisterDLL("actxprxy.dll")
	_ReregisterDLL("asctrls.ocx")
	_ReregisterDLL("browseui.dll", "/s /i")
	;~ regsvr32 /s /i browseui.dll,NI (unnecessary)
	_ReregisterDLL("cdfview.dll")
	_ReregisterDLL("comcat.dll")
	_ReregisterDLL("comctl32.dll", "/s /i /n")
	_ReregisterDLL("corpol.dll")
	_ReregisterDLL("cryptdlg.dll")
	_ReregisterDLL("""" & @ProgramFilesDir & "\Internet Explorer\custsat.dll""")
	_ReregisterDLL("digest.dll", "/s /i /n")
	_ReregisterDLL("dispex.dll")
	_ReregisterDLL("dxtmsft.dll")
	_ReregisterDLL("dxtrans.dll")
	;~ Symptom: Add-Ons-Manager menu entry is present but nothing happens
	_ReregisterDLL("extmgr.dll")
	;~ Simple HTML Mail API
	_ReregisterDLL("""" & @ProgramFilesDir & "\Internet Explorer\hmmapi.dll""")
	_ReregisterDLL("hlink.dll")
	;~ Group policy snap-in
	_ReregisterDLL("ieaksie.dll")
	;~ Smart Screen
	_ReregisterDLL("ieapfltr.dll")
	;~ IEAK Branding
	_ReregisterDLL("iedkcs32.dll")
	;~ Dev Tools
	_ReregisterDLL("""" & @ProgramFilesDir & "\Internet Explorer\iedvtool.dll""")
	_ReregisterDLL("iedvtool.dll")
	;~ IE7 tabbed browser
	_ReregisterDLL("ieframe.dll", "/s /i /n")
	;~ _ReregisterDLL("ieframe.dll", "/s /i")
	_ReregisterDLL("iepeers.dll")
	;~ Symptom: IE8 closes immediately on launch, missing from IE7
	_ReregisterDLL("""" & @ProgramFilesDir & "\Internet Explorer\ieproxy.dll""")
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
	_ReregisterDLL("licmgr10.dll")
	_ReregisterDLL("mlang.dll")
	_ReregisterDLL("mobsync.dll")
	_ReregisterDLL("msapsspc.dll")
	;~ Symptom: Javascript links don't work (Robin Walker) .NET hub file
	_ReregisterDLL("mscoree.dll")
	_ReregisterDLL("mscorier.dll")
	_ReregisterDLL("mscories.dll")
	;~ VS Debugger
	_ReregisterDLL("msdbg2.dll")
	_ReregisterDLL("mshta.exe")

	; ===============================================================================================================================
	; Print Preview displays html code instead of displaying the page preview
	; ===============================================================================================================================
	; When you choose Print Preview from Internet Explorer File menu, the Preview dialog appears correctly, but may show the raw html
	; code instead of displaying the preview..
	_ReregisterDLL("mshtml.dll", "/s /i")
	_ReregisterDLL("shdocvw.dll", "/s /i")

	_ReregisterDLL("mshtmled.dll")
	_ReregisterDLL("msident.dll")
	_ReregisterDLL("msieftp.dll", "/s /i")
	_ReregisterDLL("msnsspc.dll")
	_ReregisterDLL("msr2c.dll")
	_ReregisterDLL("msrating.dll")
	_ReregisterDLL("mstime.dll")
	_ReregisterDLL("msxml.dll")
	;~ Symptom: Printing problems, open in new window
	_ReregisterDLL("ole32.dll")
	;~ Symptom: Find on this page is blank
	_ReregisterDLL("oleacc.dll")
	_ReregisterDLL("occache.dll", "/s /i")
	_ReregisterDLL("oleaut32.dll")
	;~ Process debug manager
	_ReregisterDLL("""" & @ProgramFilesDir & "\Internet Explorer\pdm.dll""")
	_ReregisterDLL("plugin.ocx")
	_ReregisterDLL("pngfilt.dll")
	_ReregisterDLL("proctexe.ocx")
	_ReregisterDLL("scrobj.dll", "/s /i")
	_ReregisterDLL("sendmail.dll")
	_ReregisterDLL("setupwbv.dll", "/s /i")

	;~ regsvr32 /s /i shdocvw.dll,NI
	_ReregisterDLL("tdc.ocx")
	_ReregisterDLL("url.dll")
	_ReregisterDLL("urlmon.dll", "/s /i")
	;~ regsvr32 /s /i urlmon.dll,NI,HKLM
	_ReregisterDLL("urlmon.dll,NI,HKLM", "/s /i")
	_ReregisterDLL("vbscript.dll")
	;~ VML Renderer
	_ReregisterDLL("""" & @ProgramFilesDir & "\microsoft shared\vgx\vgx.dll""")
	_ReregisterDLL("webcheck.dll", "/s /i")
	;_ReregisterDLL("wininet.dll", "/s /i /n")
	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_2003" Then
		;~ Symptom: new tabs page cannot display content because it cannot access the controls (added 27. 3.2009)
		;~ This is a result of a bug in shdocvw.dll (see above), probably only on Windows XP
		_MemoLoggingWrite("Fixing 'New tabs page cannot display content because it cannot access the controls'.")
		_MemoLoggingWrite("This is a result of a bug in shdocvw.dll.")
		RegWrite("HKEY_CLASSES_ROOT\TypeLib\{EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}\1.1\0\win32", "", "REG_SZ", "%SystemRoot%\system32\ieframe.dll")
		_MemoLoggingWrite("Registering Outlook Express files.....")
		_ReregisterDLL("""" & @ProgramFilesDir & "\Outlook Express\msoe.dll""")
		_ReregisterDLL("""" & @ProgramFilesDir & "\Outlook Express\oeimport.dll""")
		_ReregisterDLL("""" & @ProgramFilesDir & "\Outlook Express\oemiglib.dll""")
		_ReregisterDLL("""" & @ProgramFilesDir & "\Outlook Express\wabfind.dll""")
		_ReregisterDLL("""" & @ProgramFilesDir & "\Outlook Express\wabimp.dll""")
		;~ _MemoLogWrite("Registering Connection Wizard files.....")
		;~ _ReregisterDLL("""" & @ProgramFilesDir & "\Internet Explorer\Connection Wizard\icwconn.dll""")
		;~ _ReregisterDLL("""" & @ProgramFilesDir & "\Internet Explorer\Connection Wizard\icwdl.dll""")
		;~ _ReregisterDLL("""" & @ProgramFilesDir & "\Internet Explorer\Connection Wizard\icwutil.dll""")
		;~ _ReregisterDLL("""" & @ProgramFilesDir & "\Internet Explorer\Connection Wizard\trialoc.dll""")
	EndIf

	; ===============================================================================================================================
	; Windows Explorer and Internet Explorer taskbar buttons are grouped together in Windows XP
	; ===============================================================================================================================
	; In some systems, the Windows Explorer and Internet Explorer taskbar icons may be grouped together even though they both
	; have different executable names.
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\BrowseNewProcess", "BrowseNewProcess", "REG_SZ", "yes")

	; ===============================================================================================================================
	; Error 'Internet Explorer could not install this search provider' when adding a Search provider
	; ===============================================================================================================================
	_ReregisterDLL("msxml2.dll")
	_ReregisterDLL("msxml3.dll")
	_ReregisterDLL("msxml6.dll")

	If _GetIntExplorerVersion("MAIN") = 7 Then
		RegWrite("HKEY_CLASSES_ROOT\CLSID\{528d46b3-3a4b-4b13-bf74-d9cbd7306e07}", "", "REG_SZ", "XML Feed Document")
		RegWrite("HKEY_CLASSES_ROOT\CLSID\{528d46b3-3a4b-4b13-bf74-d9cbd7306e07}\BrowseInPlace")
		RegWrite("HKEY_CLASSES_ROOT\CLSID\{528d46b3-3a4b-4b13-bf74-d9cbd7306e07}\InProcServer32", "", "REG_SZ", "C:\\WINDOWS\\system32\\ieframe.dll")
		RegWrite("HKEY_CLASSES_ROOT\CLSID\{528d46b3-3a4b-4b13-bf74-d9cbd7306e07}\InProcServer32", "ThreadingModel", "REG_SZ", "Apartment")
		RegWrite("HKEY_CLASSES_ROOT\CLSID\{528d46b3-3a4b-4b13-bf74-d9cbd7306e07}\ProgID", "", "REG_SZ", "xmlfile")
		RegWrite("HKEY_CLASSES_ROOT\MIME\Database\Content Type\application/rss+xml", "CLSID", "REG_SZ", "{528d46b3-3a4b-4b13-bf74-d9cbd7306e07}")
		RegWrite("HKEY_CLASSES_ROOT\TypeLib\{EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}\1.1\0\win32", "", "REG_EXPAND_SZ", "%systemroot%\system32\ieframe.dll")
	EndIf

	_MemoLoggingWrite("Finished repairing Internet Explorer " & _GetIntExplorerVersion(), 1)
	_EndLogging()

EndFunc


Func _RepairPNGFiles()

	_StartLogging("Repairing when PNG images are not displayed correctly in Internet Explorer, please wait...")
	_MemoLoggingWrite("Restoring default configurations.")
	Switch @OSVersion

		Case "WIN_7"

			RegWrite("HKEY_CLASSES_ROOT\.png", "Content Type", "REG_SZ", "image/png")
			RegWrite("HKEY_CLASSES_ROOT\.png", "", "REG_SZ", "pngfile")
			RegWrite("HKEY_CLASSES_ROOT\.png", "PerceivedType", "REG_SZ", "image")
			RegWrite("HKEY_CLASSES_ROOT\.png\PersistentHandler", "", "REG_SZ", "{098f2470-bae0-11cd-b579-08002b30bfeb}")
			RegWrite("HKEY_CLASSES_ROOT\pngfile", "", "REG_SZ", "PNG Image")
			RegWrite("HKEY_CLASSES_ROOT\pngfile", "EditFlags", "REG_DWORD", "0x00010000")
			RegWrite("HKEY_CLASSES_ROOT\pngfile", "FriendlyTypeName", "REG_EXPAND_SZ", "@%SystemRoot%\System32\shell32.dll,-30598")
			RegWrite("HKEY_CLASSES_ROOT\pngfile", "ImageOptionFlags", "REG_DWORD", "0x00000001")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\CLSID", "", "REG_SZ", "{25336920-03F9-11cf-8FD0-00AA00686F13}")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\DefaultIcon", "", "REG_EXPAND_SZ", "%SystemRoot%\System32\imageres.dll,-83")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\shell\open", "MuiVerb", "REG_EXPAND_SZ", "@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\shell\open\command", "", "REG_EXPAND_SZ", "%SystemRoot%\System32\rundll32.exe ""%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll"", ImageView_Fullscreen %1")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\shell\open\DropTarget", "Clsid", "REG_SZ", "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\shell\printto\command", "", "REG_EXPAND_SZ", """%SystemRoot%\System32\rundll32.exe"" ""%SystemRoot%\System32\shimgvw.dll"",ImageView_PrintTo /pt ""%1"" ""%2"" ""%3"" ""%4""")
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\MIME\Database\Content Type\image/x-png", "Extension", "REG_SZ", ".png")
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\MIME\Database\Content Type\image/x-png", "Image Filter CLSID", "REG_SZ", "{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}")
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\MIME\Database\Content Type\image/x-png\Bits", "0", "REG_BINARY", "0x08000000ffffffffffffffff89504e470d0a1a0a")
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\MIME\Database\Content Type\image/png", "Extension", "REG_SZ", ".png")
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\MIME\Database\Content Type\image/png", "Image Filter CLSID", "REG_SZ", "{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}")
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\MIME\Database\Content Type\image/png\Bits", "0", "REG_BINARY", "0x08000000ffffffffffffffff89504e470d0a1a0a")
			;RegWrite("HKEY_CLASSES_ROOT\MIME\Database\Content Type\image/x-png", "Extension", "REG_SZ", ".png")
			;RegWrite("HKEY_CLASSES_ROOT\MIME\Database\Content Type\image/x-png", "Image Filter CLSID", "REG_SZ", "{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}")
			;RegWrite("HKEY_CLASSES_ROOT\MIME\Database\Content Type\image/x-png\Bits", "0", "REG_BINARY", "0x08000000ffffffffffffffff89504e470d0a1a0a")
			;RegWrite("HKEY_CLASSES_ROOT\MIME\Database\Content Type\image/png", "Extension", "REG_SZ", ".png")
			;RegWrite("HKEY_CLASSES_ROOT\MIME\Database\Content Type\image/png", "Image Filter CLSID", "REG_SZ", "{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}")
			;RegWrite("HKEY_CLASSES_ROOT\MIME\Database\Content Type\image/png\Bits", "0", "REG_BINARY", "0x08000000ffffffffffffffff89504e470d0a1a0a")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}", "", "REG_SZ", "CoPNGFilter Class")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}\InProcServer32", "", "REG_SZ", "C:\\Windows\\System32\\pngfilt.dll")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}\InProcServer32", "ThreadingModel", "REG_SZ", "Both")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}\ProgID", "", "REG_SZ", "PNGFilter.CoPNGFilter.1")
			RegWrite("HKEY_CLASSES_ROOT\PNGFilter.CoPNGFilter", "", "REG_SZ", "CoPNGFilter Class")
			RegWrite("HKEY_CLASSES_ROOT\PNGFilter.CoPNGFilter\CLSID", "", "REG_SZ", "{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}")
			RegWrite("HKEY_CLASSES_ROOT\PNGFilter.CoPNGFilter.1", "", "REG_SZ", "CoPNGFilter Class")
			RegWrite("HKEY_CLASSES_ROOT\PNGFilter.CoPNGFilter.1\CLSID", "", "REG_SZ", "{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}")

		Case "WIN_VISTA"

			RegWrite("HKEY_CLASSES_ROOT\.png", "", "REG_SZ", "pngfile")
			RegWrite("HKEY_CLASSES_ROOT\.png", "Content Type", "REG_SZ", "image/png")
			RegWrite("HKEY_CLASSES_ROOT\.png", "PerceivedType", "REG_SZ", "image")
			RegWrite("HKEY_CLASSES_ROOT\.png\PersistentHandler", "", "REG_SZ", "{098f2470-bae0-11cd-b579-08002b30bfeb}")
			RegWrite("HKEY_CLASSES_ROOT\pngfile", "", "REG_SZ", "PNG Image")
			RegWrite("HKEY_CLASSES_ROOT\pngfile", "EditFlags", "REG_DWORD", "0x00010000")
			RegWrite("HKEY_CLASSES_ROOT\pngfile", "FriendlyTypeName", "REG_EXPAND_SZ", "@%SystemRoot%\System32\shell32.dll,-30598")
			RegWrite("HKEY_CLASSES_ROOT\pngfile", "ImageOptionFlags", "REG_DWORD", "0x00000003")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\CLSID", "", "REG_SZ", "{25336920-03F9-11cf-8FD0-00AA00686F13}")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\DefaultIcon", "", "REG_EXPAND_SZ", "%SystemRoot%\System32\imageres.dll,-83")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\shell\open", "MuiVerb", "REG_EXPAND_SZ", "@%ProgramFiles%\Windows Photo Gallery\photoviewer.dll,-3043")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\shell\open\command", "", "REG_EXPAND_SZ", "%SystemRoot%\System32\rundll32.exe ""%ProgramFiles%\Windows Photo Gallery\PhotoViewer.dll"", ImageView_Fullscreen %1")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\shell\open\DropTarget", "Clsid", "REG_SZ", "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\shell\printto\command", "", "REG_EXPAND_SZ", """%SystemRoot%\System32\rundll32.exe"" ""%SystemRoot%\System32\shimgvw.dll"",ImageView_PrintTo /pt ""%1"" ""%2"" ""%3"" ""%4""")
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\MIME\Database\Content Type\image/x-png", "Extension", "REG_SZ", ".png")
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\MIME\Database\Content Type\image/x-png", "Image Filter CLSID", "REG_SZ", "{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}")
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\MIME\Database\Content Type\image/x-png\Bits", "0", "REG_BINARY", "0x08000000ffffffffffffffff89504e470d0a1a0a")
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\MIME\Database\Content Type\image/png", "Extension", "REG_SZ", ".png")
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\MIME\Database\Content Type\image/png", "Image Filter CLSID", "REG_SZ", "{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}")
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\MIME\Database\Content Type\image/png\Bits", "0", "REG_BINARY", "0x08000000ffffffffffffffff89504e470d0a1a0a")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}", "", "REG_SZ", "CoPNGFilter Class")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}\InprocServer32", "", "REG_SZ", "C:\\Windows\\system32\\pngfilt.dll")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}\InprocServer32", "ThreadingModel", "REG_SZ", "Both")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}\ProgID", "", "REG_SZ", "PNGFilter.CoPNGFilter.1")
			RegWrite("HKEY_CLASSES_ROOT\PNGFilter.CoPNGFilter.1", "", "REG_SZ", "CoPNGFilter Class")
			RegWrite("HKEY_CLASSES_ROOT\PNGFilter.CoPNGFilter.1\CLSID", "", "REG_SZ", "{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}")
			RegWrite("HKEY_CLASSES_ROOT\PNGFilter.CoPNGFilter", "", "REG_SZ", "CoPNGFilter Class")
			RegWrite("HKEY_CLASSES_ROOT\PNGFilter.CoPNGFilter\CLSID", "", "REG_SZ", "{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}")


		Case "WIN_XP"

			RegWrite("HKEY_CLASSES_ROOT\.PNG", "PerceivedType", "REG_SZ", "image")
			RegWrite("HKEY_CLASSES_ROOT\.PNG", "", "REG_SZ", "pngfile")
			RegWrite("HKEY_CLASSES_ROOT\.PNG", "Content Type", "REG_SZ", "image/png")
			RegWrite("HKEY_CLASSES_ROOT\.PNG\PersistentHandler", "", "REG_SZ", "{098f2470-bae0-11cd-b579-08002b30bfeb}")
			RegWrite("HKEY_CLASSES_ROOT\pngfile", "", "REG_SZ", "PNG Image")
			RegWrite("HKEY_CLASSES_ROOT\pngfile", "EditFlags", "REG_DWORD", "0x00010000")
			RegWrite("HKEY_CLASSES_ROOT\pngfile", "FriendlyTypeName", "REG_EXPAND_SZ", "@%SystemRoot%\system32\shimgvw.dll,-305")
			RegWrite("HKEY_CLASSES_ROOT\pngfile", "ImageOptionFlags", "REG_DWORD", "0x00000003")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\CLSID", "", "REG_SZ", "{25336920-03F9-11cf-8FD0-00AA00686F13}")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\DefaultIcon", "", "REG_SZ", "shimgvw.dll,2")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\shell", "", "REG_SZ", "open")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\shell\open", "MuiVerb", "REG_SZ", "@shimgvw.dll,-550")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\shell\open\command", "", "REG_SZ", "rundll32.exe C:\\WINDOWS\\system32\\shimgvw.dll,ImageView_Fullscreen %1")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\shell\open\DropTarget", "Clsid", "REG_SZ", "{E84FDA7C-1D6A-45F6-B725-CB260C236066}")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\shell\printto\command", "", "REG_SZ", "rundll32.exe C:\\WINDOWS\\system32\\shimgvw.dll,ImageView_PrintTo /pt ""%1"" ""%2"" ""%3"" ""%4""")
			RegWrite("HKEY_CLASSES_ROOT\SystemFileAssociations\.PNG", "ImageOptionFlags", "REG_DWORD", "0x00000003")
			RegWrite("HKEY_CLASSES_ROOT\Mime\Database\Content Type\image/x-png", "Extension", "REG_SZ", ".png")
			RegWrite("HKEY_CLASSES_ROOT\Mime\Database\Content Type\image/x-png", "Image Filter CLSID", "REG_SZ", "{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}")
			RegWrite("HKEY_CLASSES_ROOT\Mime\Database\Content Type\image/x-png\Bits", "0", "REG_BINARY", "0x08000000ffffffffffffffff89504e470d0a1a0a")
			RegWrite("HKEY_CLASSES_ROOT\Mime\Database\Content Type\image/png", "Extension", "REG_SZ", ".png")
			RegWrite("HKEY_CLASSES_ROOT\Mime\Database\Content Type\image/png", "Image Filter CLSID", "REG_SZ", "{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}")
			RegWrite("HKEY_CLASSES_ROOT\Mime\Database\Content Type\image/png\Bits", "0", "REG_BINARY", "0x08000000ffffffffffffffff89504e470d0a1a0a")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}", "", "REG_SZ", "CoPNGFilter Class")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}\InProcServer32", "", "REG_SZ", "C:\\WINDOWS\\system32\\pngfilt.dll")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}\InProcServer32", "ThreadingModel", "REG_SZ", "Both")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}\ProgID", "", "REG_SZ", "PNGFilter.CoPNGFilter.1")
			RegWrite("HKEY_CLASSES_ROOT\PNGFilter.CoPNGFilter", "", "REG_SZ", "CoPNGFilter Class")
			RegWrite("HKEY_CLASSES_ROOT\PNGFilter.CoPNGFilter\CLSID", "", "REG_SZ", "{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}")
			RegWrite("HKEY_CLASSES_ROOT\PNGFilter.CoPNGFilter.1", "", "REG_SZ", "CoPNGFilter Class")
			RegWrite("HKEY_CLASSES_ROOT\PNGFilter.CoPNGFilter.1\CLSID", "", "REG_SZ", "{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}")

		Case "WIN_2000"

			RegWrite("HKEY_CLASSES_ROOT\.png", "", "REG_SZ", "pngfile")
			RegWrite("HKEY_CLASSES_ROOT\.png", "Content Type", "REG_SZ", "image/png")
			RegWrite("HKEY_CLASSES_ROOT\pngfile", "", "REG_SZ", "PNG Image")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\CLSID", "", "REG_SZ", "{25336920-03F9-11cf-8FD0-00AA00686F13}")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\DefaultIcon", "", "REG_SZ", "C:\\Program Files\\Internet Explorer\\iexplore.exe,9")
			RegWrite("HKEY_CLASSES_ROOT\pngfile\shell\open\command", "", "REG_SZ", """C:\\Program Files\\Internet Explorer\\iexplore.exe"" -nohome")
			;RegWrite("HKEY_CLASSES_ROOT\pngfile\shell\open\ddeexec", "", "REG_SZ", """file:%1"",,-1,,,,,")
			;RegWrite("HKEY_CLASSES_ROOT\pngfile\shell\open\ddeexec\Application", "", "REG_SZ", "IExplore")
			;RegWrite("HKEY_CLASSES_ROOT\pngfile\shell\open\ddeexec\Topic", "", "REG_SZ", "WWW_OpenURL")
			RegWrite("HKEY_CLASSES_ROOT\MIME\Database\Content Type\image/x-png", "Extension", "REG_SZ", ".png")
			RegWrite("HKEY_CLASSES_ROOT\MIME\Database\Content Type\image/x-png", "Image Filter CLSID", "REG_SZ", "{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}")
			RegWrite("HKEY_CLASSES_ROOT\MIME\Database\Content Type\image/x-png\Bits", "0", "REG_BINARY", "0x08000000ffffffffffffffff89504e470d0a1a0a")
			RegWrite("HKEY_CLASSES_ROOT\MIME\Database\Content Type\image/png", "Extension", "REG_SZ", ".png")
			RegWrite("HKEY_CLASSES_ROOT\MIME\Database\Content Type\image/png", "Image Filter CLSID", "REG_SZ", "{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}")
			RegWrite("HKEY_CLASSES_ROOT\MIME\Database\Content Type\image/png\Bits", "0", "REG_BINARY", "0x08000000ffffffffffffffff89504e470d0a1a0a")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}", "", "REG_SZ", "CoPNGFilter Class")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}\InProcServer32", "", "REG_EXPAND_SZ", "%SystemRoot%\System32\pngfilt.dll")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}\InProcServer32", "ThreadingModel", "REG_SZ", "Both")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}\ProgID", "", "REG_SZ", "PNGFilter.CoPNGFilter.1")
			RegWrite("HKEY_CLASSES_ROOT\PNGFilter.CoPNGFilter", "", "REG_SZ", "CoPNGFilter Class")
			RegWrite("HKEY_CLASSES_ROOT\PNGFilter.CoPNGFilter\CLSID", "", "REG_SZ", "{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}")
			RegWrite("HKEY_CLASSES_ROOT\PNGFilter.CoPNGFilter.1", "", "REG_SZ", "CoPNGFilter Class")
			RegWrite("HKEY_CLASSES_ROOT\PNGFilter.CoPNGFilter.1\CLSID", "", "REG_SZ", "{A3CCEDF7-2DE2-11D0-86F4-00A0C913F750}")


		Case Else
			_MemoLoggingWrite("Unsupported Operating System", 3)
			_EndLogging()
			Return

	EndSwitch

	_MemoLoggingWrite("PNG images should display correctly in Internet Explorer now.", 1)
	_EndLogging()

EndFunc


Func _ClearUpdateHistory()

	_MemoLoggingWrite("Clearing File Stores (Update History), please wait...", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
	FileDelete(@AppDataCommonDir & "\Microsoft\Network\Downloader\qmgr*.dat")
	_MemoLoggingWrite("Clearing [" & $DIR_SDOWNLOAD & "], please wait...")
	If DirRemove($DIR_SDOWNLOAD, 1) Then
		_MemoLoggingWrite("[" & $DIR_SDOWNLOAD & "] Cleared.", 1)
	EndIf
	_MemoLoggingWrite("Clearing [" & $DIR_DATASTORE & "], please wait...")
	If DirRemove($DIR_DATASTORE, 1) Then
		_MemoLoggingWrite("[" & $DIR_DATASTORE & "] Cleared.", 1)
	EndIf
	_MemoLoggingWrite("Clearing [" & $DIR_CATROOT & "], please wait...")
	DirRemove($DIR_CATROOT, 1)
	_MemoLoggingWrite("[" & $DIR_CATROOT & "] Cleared.", 1)
	$CLEARWINUPDATE = False
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _RepairWinAutoUpdate()

	If Not $EVENTLOG_CONFIGURED Then _ConfigureEventLog()
	_MemoLoggingWrite("Repairing Windows Update / Automatic Updates, please wait...", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
	_MemoLoggingWrite("Stopping the BITS Service.")
	If Not _SvcStop("bits") Then
		_MemoLoggingWrite("BITS was not started in the first place.", 3)
	Else
		_MemoLoggingWrite("BITS Stopped Successfully.", 1)
	EndIf
	_MemoLoggingWrite("Stopping the Automatic Updates (wuauserv) Service.")
	If Not _SvcStop("wuauserv") Then
		_MemoLoggingWrite("Automatic Updates (wuauserv) Service was not started in the first place.", 3)
	Else
		_MemoLoggingWrite("Automatic Updates (wuauserv) Service Stopped Successfully.", 1)
	EndIf
	If $CLEARWINUPDATE Then
		_MemoLoggingWrite("", 0, False)
		_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
		_ClearUpdateHistory()
	EndIf
	_MemoLoggingWrite("Setting BITS Security Descriptor.")
	_ConsoleRun("sc sdset bits " & Chr(34) & "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" & Chr(34))
	_MemoLoggingWrite("Setting Automatic Updates (wuauserv) Service Security Descriptor.")
	_ConsoleRun("sc sdset wuauserv " & Chr(34) & "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" & Chr(34))
	_MemoLoggingWrite("Configuring the Automatic Updates (wuauserv) Service.")
	_SvcSetStartMode("wuauserv", "Automatic")
	_MemoLoggingWrite("Automatic Updates (wuauserv) Service Configured.", 1)
	_MemoLoggingWrite("Configuring BITS.")
	_SvcSetStartMode("bits", "Automatic")
	_MemoLoggingWrite("BITS Configured.", 1)
	_MemoLoggingWrite("Registering WUAU DLLs.")
	_ReregisterDLL("actxprxy.dll")
	_ReregisterDLL("atl.dll")
	_ReregisterDLL("browseui.dll")
	_ReregisterDLL("corpol.dll")
	_ReregisterDLL("cryptdlg.dll")
	_ReregisterDLL("dispex.dll")
	_ReregisterDLL("dssenh.dll")
	_ReregisterDLL("gpkcsp.dll")
	_ReregisterDLL("initpki.dll")
	_ReregisterDLL("jscript.dll")
	_ReregisterDLL("mshtml.dll")
	_ReregisterDLL("msscript.ocx")
	_ReregisterDLL("msxml.dll")
	_ReregisterDLL("msxml2.dll")
	_ReregisterDLL("msxml3.dll")
	_ReregisterDLL("msxml4.dll")
	_ReregisterDLL("msxml6.dll")
	_ReregisterDLL("muweb.dll")
	_ReregisterDLL("ole.dll")
	_ReregisterDLL("ole32.dll")
	_ReregisterDLL("oleaut.dll")
	_ReregisterDLL("oleaut32.dll")
	_ReregisterDLL("qmgr.dll")
	_ReregisterDLL("qmgrprxy.dll")
	_ReregisterDLL("gpkcsp.dll")
	_ReregisterDLL("rsaenh.dll")
	_ReregisterDLL("sccbase.dll")
	_ReregisterDLL("scrobj.dll")
	_ReregisterDLL("scrrun.dll")
	_ReregisterDLL("shdocvw.dll")
	_ReregisterDLL("shell.dll")
	_ReregisterDLL("shell32.dll")
	_ReregisterDLL("slbcsp.dll")
	_ReregisterDLL("softpub.dll")
	_ReregisterDLL("urlmon.dll")
	_ReregisterDLL("vbscript.dll")
	_ReregisterDLL("winhttp.dll")
	_ReregisterDLL("wintrust.dll")
	_ReregisterDLL("wshext.dll")
	_ReregisterDLL("wuapi.dll")
	_ReregisterDLL("wuaueng.dll")
	_ReregisterDLL("wuaueng1.dll")
	_ReregisterDLL("wucltui.dll")
	_ReregisterDLL("wucltux.dll")
	_ReregisterDLL("wups.dll")
	_ReregisterDLL("wups2.dll")
	_ReregisterDLL("wuweb.dll")
	_ReregisterDLL("wuwebv.dll")
	_MemoLoggingWrite("WUAU DLLs Reregistered.", 1)
;~ 	If Not $ResetWinsock Then _RepairWinsock()
	Switch @OSVersion
		Case "WIN_2000", "WIN_XP", "WIN_XPe", "WIN_2003"
			_MemoLoggingWrite("Setting proxy to direct access.")
			_ConsoleRun("proxycfg.exe -d")
		Case "WIN_VISTA", "WIN_2008", "WIN_7", "WIN_2008R2"
			_MemoLoggingWrite("Resetting proxy settings.")
			_ConsoleRun("netsh winhttp reset proxy")
	EndSwitch
	_MemoLoggingWrite("Restarting the Automatic Updates (wuauserv) Service.")
	If Not _SvcStart("wuauserv") Then
		_MemoLoggingWrite("The wuauserv Service could not be started.", 2)
	Else
		_MemoLoggingWrite("Automatic Updates (wuauserv) Service Restarted.", 1)
	EndIf
	_MemoLoggingWrite("Restarting the BITS Service.")
	If Not _SvcStart("bits") Then
		_MemoLoggingWrite("The BITS Service could not be started.", 2)
	Else
		_MemoLoggingWrite("BITS Service Restarted.", 1)
	EndIf
	_ConsoleRun("fsutil resource setautoreset true " & @HomeDrive & ":\")
	If @OSVersion = "WIN_VISTA" Or @OSVersion = "WIN_2008" Or @OSVersion = "WIN_2008R2" Or @OSVersion = "WIN_7" Then
		_MemoLoggingWrite("Clearing the BITS queue.")
		_ConsoleRun("bitsadmin.exe /reset /allusers")
	EndIf
	RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Group Policy Objects\LocalUser\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate\DisableWindowsUpdateAccess")
	RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoWindowsUpdate")
	RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDevMgrUpdate")
	RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate", "DisableWindowsUpdateAccess")
	RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate")
	RegDelete("HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoWindowsUpdate")
	RegDelete("HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "NoAutoUpdate")
	RegDelete("HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "AUOptions")
	RegDelete("HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "ScheduledInstallDay")
	RegDelete("HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "ScheduledInstallTime")
	RegDelete("HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "NoAutoRebootWithLoggedOnUsers")
	RegDelete("HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate")
	RegDelete("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "LastWaitTimeout")
	RegDelete("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "DetectionStartTime")
	RegDelete("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "NextDetectionTime")
	RegDelete("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "ScheduledInstallDate")
	RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "NoAutoUpdate", "REG_DWORD", 0)
	RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "AUOptions", "REG_DWORD", 4)
	RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "ScheduledInstallDay", "REG_DWORD", 0)
	RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "ScheduledInstallTime", "REG_DWORD", 3)
	RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "NoAutoRebootWithLoggedOnUsers", "REG_DWORD", 1)
	RegWrite("HKCU\Software\Microsoft\Internet Explorer\Main", "NoUpdateCheck", "REG_DWORD", 0)
	_MemoLoggingWrite("Initiating Windows Updates detection right away.")
	_ConsoleRun("wuauclt /detectnow")
	_MemoLoggingWrite("Finished repairing Windows Update / Automatic Updates.")
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _RepairSHC()

	If Not $EVENTLOG_CONFIGURED Then _ConfigureEventLog()
	_MemoLoggingWrite("Repairing SSL / HTTPS / Cryptography service, please wait...", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
	_MemoLoggingWrite("Configuring the Cryptographic Service.....")
	_SvcSetStartMode("CryptSvc","Automatic")
	_MemoLoggingWrite("Cryptographic Service Configured.")
	_MemoLoggingWrite("Stopping the Cryptographic Service.")
	If Not _SvcStop("CryptSvc") Then
		_MemoLoggingWrite("Cryptographic service was not started in the first place.", 3)
	Else
		_MemoLoggingWrite("Cryptographic service Stopped Successfully.", 1)
	EndIf
	_MemoLoggingWrite("Clearing [" & @WindowsDir & "\system32\CatRoot].", 1)
	;DirRemove(@WindowsDir&"\system32\CatRoot, 1)
	FileDelete(@WindowsDir & "\system32\CatRoot\{F750E6C3-38EE-11D1-85E5-00C04FC295EE}\tmp*.CAT")
	FileDelete(@WindowsDir & "\system32\CatRoot\{127D0A1D-4EF2-11D1-8608-00C04FC295EE}\tmp*.CAT")
	FileDelete(@WindowsDir & "\system32\CatRoot\{F750E6C3-38EE-11D1-85E5-00C04FC295EE}\KB*.CAT")
	FileDelete(@WindowsDir & "\system32\CatRoot\{127D0A1D-4EF2-11D1-8608-00C04FC295EE}\KB*.CAT")
	FileDelete(@WindowsDir & "\inf\oem*.*")
	_MemoLoggingWrite("[" & @WindowsDir & "\system32\CatRoot] cleared." , 1)
	_MemoLoggingWrite("Re-registering SSL / HTTPS / Cryptography DLLs.")
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
	_MemoLoggingWrite("SSL / HTTPS / Cryptography DLLs re-registered.")
	FileSetAttrib(@WindowsDir, "-RSH")
	FileSetAttrib(@SystemDir, "-RSH")
	FileSetAttrib(@WindowsDir & "\system32\CatRoot", "-RSH", 1)
	_MemoLoggingWrite("Restarting the Cryptographic Service.")
	If Not _SvcStart("CryptSvc") Then
		_MemoLoggingWrite("The Cryptographic Service could not be started.", 2)
	Else
		_MemoLoggingWrite("Cryptographic Service restarted.", 1)
	EndIf
	_MemoLoggingWrite("Finished repairing SSL / HTTPS / Cryptography service.")
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _ResetFirewall()

	_MemoLoggingWrite("Resetting the Windows Firewall configuraton, please wait...", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
	Switch @OSVersion
		Case "WIN_2000", "WIN_XP", "WIN_XPe", "WIN_2003"
			_ConsoleRun("netsh firewall reset")
		Case "WIN_VISTA", "WIN_2008", "WIN_7", "WIN_2008R2"
			_ConsoleRun("netsh advfirewall reset")
	EndSwitch
	_MemoLoggingWrite("Finished resetting the Windows Firewall configuraton.")
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _RestoreHostsAccess()

	_MemoLoggingWrite("Restoring access (permissions) to the HOSTS file, please wait...", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
	ShellExecute("cacls", Chr(34) & @WindowsDir & "\system32\drivers\etc\hosts" & Chr(34) & " /G everyone:f", "", "", @SW_HIDE)
	Sleep(200)
	Send("Y")
	Send("{ENTER}")
	If Not FileSetAttrib(@WindowsDir & "\system32\drivers\etc\hosts", "-RASHNOT", 1) Then
		_MemoLoggingWrite("Problem setting HOSTS file attributes", 2)
	EndIf
	_MemoLoggingWrite("You should be able to edit the HOSTS file now.")
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _RestoreHosts()

	_MemoLoggingWrite("Restoring the default Windows HOSTS file, please wait...", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
	Local $localHosts = @WindowsDir & "\System32\drivers\etc\hosts"

	FileSetAttrib($localHosts, "-RASHNOT")
	FileMove($localHosts, @SystemDir & "\drivers\etc\hosts.bak")
	FileDelete($localHosts)

	Local $openHosts = FileOpen($localHosts, 1)
	If $localHosts = -1 Then
	EndIf
	_MemoLoggingWrite("Writing data to the HOSTS file.")
	FileWrite($openHosts, "# Copyright (c) 1993-1999 Microsoft Corp." & @CRLF)
	FileWrite($openHosts, "#" & @CRLF)
	FileWrite($openHosts, "# This is a sample HOSTS file used by Microsoft TCP/IP for Windows." & @CRLF)
	FileWrite($openHosts, "#" & @CRLF)
	FileWrite($openHosts, "# This file contains the mappings of IP addresses to host names. Each" & @CRLF)
	FileWrite($openHosts, "# entry should be kept on an individual line. The IP address should" & @CRLF)
	FileWrite($openHosts, "# be placed in the first column followed by the corresponding host name." & @CRLF)
	FileWrite($openHosts, "# The IP address and the host name should be separated by at least one" & @CRLF)
	FileWrite($openHosts, "# space." & @CRLF)
	FileWrite($openHosts, "#" & @CRLF)
	FileWrite($openHosts, "# Additionally, comments (such as these) may be inserted on individual" & @CRLF)
	FileWrite($openHosts, "# lines or following the machine name denoted by a '#' symbol." & @CRLF)
	FileWrite($openHosts, "#" & @CRLF)
	FileWrite($openHosts, "# For example:" & @CRLF)
	FileWrite($openHosts, "#" & @CRLF)
	FileWrite($openHosts, "#      102.54.94.97     rhino.acme.com          # source server" & @CRLF)
	FileWrite($openHosts, "#       38.25.63.10     x.acme.com              # x client host" & @CRLF)
	FileWrite($openHosts, "" & @CRLF)
	Switch @OSVersion
		Case "WIN_XP", "WIN_2003"
			FileWrite($openHosts, "127.0.0.1       localhost" & @CRLF)
		Case "WIN_VISTA", "WIN_2008"
			FileWrite($openHosts, "127.0.0.1       localhost" & @CRLF)
			FileWrite($openHosts, "::1             localhost" & @CRLF)
		Case "WIN_7", "WIN_2008R2"
			FileWrite($openHosts, "# localhost name resolution is handle within DNS itself." & @CRLF)
			FileWrite($openHosts, "#       127.0.0.1       localhost" & @CRLF)
			FileWrite($openHosts, "#       ::1             localhost" & @CRLF)
	EndSwitch
	FileClose($openHosts)
	_MemoLoggingWrite("Default HOSTS file created successfully.")
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _RepairWorkGroups()

	_MemoLoggingWrite("Repairing Workgroup Computers view, please wait...", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
	RegDelete("HKLM\System\CurrentControlSet\Services\NetBt\Parameters","NodeType")
	RegDelete("HKLM\System\CurrentControlSet\Services\NetBt\Parameters","DhcpNodeType")
	_MemoLoggingWrite("Finished repairing Workgroup Computers view.")
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc