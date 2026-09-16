#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------


#include-once

#include <CoreWinRepair.au3>


Func _ResetRegistryPermissions()

	Local $subinaclExe = @ProgramFilesDir & "\Windows Resource Kits\Tools\subinacl.exe"

	If FileExists($subinaclExe) Then

		_MemoLoggingWrite("Setting Registry permissions for the current user.")
		_ConsoleRun(Chr(34) & $subinaclExe & Chr(34) &"/subkeyreg HKEY_CURRENT_USER " & _
			"/grant=administrators=f /grant=system=f /grant=restricted=r /grant=" & @UserName & "=f /setowner=administrators > %temp%\SubInACL-Out.log")
		_ConsoleRun(Chr(34) & $subinaclExe & Chr(34) &"/keyreg HKEY_CURRENT_USER " & _
			"/grant=administrators=f /grant=system=f /grant=restricted=r /grant=" & @UserName & "=f /setowner=administrators >> %temp%\SubInACL-Out.log")
		_ConsoleRun(Chr(34) & $subinaclExe & Chr(34) &"/subkeyreg HKEY_LOCAL_MACHINE " & _
			"/grant=administrators=f /grant=system=f /grant=users=r /grant=everyone=r /grant=restricted=r /setowner=administrators >> %temp%\SubInACL-Out.log")
		_ConsoleRun(Chr(34) & $subinaclExe & Chr(34) &"/keyreg HKEY_LOCAL_MACHINE " & _
			"/grant=administrators=f /grant=system=f /grant=users=r /grant=everyone=r /grant=restricted=r /setowner=administrators >> %temp%\SubInACL-Out.log")
		_ConsoleRun(Chr(34) & $subinaclExe & Chr(34) &"/subkeyreg HKEY_CLASSES_ROOT " & _
			"/grant=administrators=f /grant=system=f /grant=users=r /setowner=administrators >> %temp%\SubInACL-Out.txt")
		_ConsoleRun(Chr(34) & $subinaclExe & Chr(34) &"/keyreg HKEY_CLASSES_ROOT " & _
			"/grant=administrators=f /grant=system=f /grant=users=r /setowner=administrators >> %temp%\SubInACL-Out.log")

	Else

		If Not IsDeclared("iMsgBoxAnswer") Then Local $iMsgBoxAns
		$iMsgBoxAns = MsgBox(262192,"SubInACL required","Before you can restore any Registry permissions you will need to download and install the SubInACL (SubInACL.exe) utility from Microsoft. The SubInACL download page will open automatically when you press Ok. Simply click on the Download button and to return to this repair option after installation.",30)
		Select
			Case $iMsgBoxAns = -1 ;Timeout
			Case Else ;OK
				ShellExecute("http://www.microsoft.com/downloads/details.aspx?FamilyId=E8BA3E56-D8FE-4A91-93CF-ED6985E3927B&displaylang=en")
		EndSelect
	EndIf


EndFunc


Func _RegisterSystemFiles()

	_StartLogging("Registering Windows System files, please wait...")
	_ReregisterDLL("asctrls.ocx")
	_ReregisterDLL("ccrpprg6.ocx")
	_ReregisterDLL("certmap.ocx")
	_ReregisterDLL("certwiz.ocx")
	_ReregisterDLL("cnfgprts.ocx")
	_ReregisterDLL("ComCt232.ocx")
	_ReregisterDLL("ComCt332.ocx")
	_ReregisterDLL("comctl32.ocx")
	_ReregisterDLL("ComDlg32.ocx")
	_ReregisterDLL("CS ToolBar.ocx")
	_ReregisterDLL("CSControlBlend.ocx")
	_ReregisterDLL("CSMDITaskBar.ocx")
	_ReregisterDLL("daxctle.ocx")
	_ReregisterDLL("dbgrid32.ocx")
	_ReregisterDLL("dblist32.ocx")
	_ReregisterDLL("dhtmled.ocx")
	_ReregisterDLL("dmview.ocx")
	_ReregisterDLL("Flash10t.ocx")
	_ReregisterDLL("hhctrl.ocx")
	_ReregisterDLL("logui.ocx")
	_ReregisterDLL("mci32.ocx")
	_ReregisterDLL("MSAdoDc.ocx")
	_ReregisterDLL("MSCAL.ocx")
	_ReregisterDLL("MSChrt20.ocx")
	_ReregisterDLL("mscomct2.ocx")
	_ReregisterDLL("mscomctl.ocx")
	_ReregisterDLL("MSComm32.ocx")
	_ReregisterDLL("MSDatGrd.ocx")
	_ReregisterDLL("MSDatLst.ocx")
	_ReregisterDLL("MSDatRep.ocx")
	_ReregisterDLL("msdxm.ocx")
	_ReregisterDLL("MSFlxGrd.ocx")
	_ReregisterDLL("MShflxgd.ocx")
	_ReregisterDLL("MSINET.ocx")
	_ReregisterDLL("msmapi32.ocx")
	_ReregisterDLL("msmask32.ocx")
	_ReregisterDLL("msrdc20.ocx")
	_ReregisterDLL("msscript.ocx")
	_ReregisterDLL("MSWINSCK.ocx")
	_ReregisterDLL("pcwintech_tabs.ocx")
	_ReregisterDLL("PicClp32.ocx")
	_ReregisterDLL("proctexe.ocx")
	_ReregisterDLL("PropPages.ocx")
	_ReregisterDLL("richtx32.ocx")
	_ReregisterDLL("SPR32X30.ocx")
	_ReregisterDLL("sysinfo.ocx")
	_ReregisterDLL("sysmon.ocx")
	_ReregisterDLL("TabCtl32.ocx")
	_ReregisterDLL("tdc.ocx")
	_ReregisterDLL("THREED32.ocx")
	_ReregisterDLL("wmp.ocx")
	_ReregisterDLL("wshom.ocx")
	_ReregisterDLL("actxprxy.dll")
	_ReregisterDLL("atl.dll")
	_ReregisterDLL("browseui.dll")
	_ReregisterDLL("cryptdlg.dll")
	_ReregisterDLL("dispex.dll")
	_ReregisterDLL("dssenh.dll")
	_ReregisterDLL("filemgmt.dll")
	_ReregisterDLL("gpkcsp.dll")
	_ReregisterDLL("hnetcfg.dll")
	_ReregisterDLL("initpki.dll")
	_ReregisterDLL("iuengine.dll")
	_ReregisterDLL("jscript.dll")
	_ReregisterDLL("mmcndmgr.dll")
	_ReregisterDLL("mshtml.dll")
	_ReregisterDLL("msi.dll")
	_ReregisterDLL("msihnd.dll")
	_ReregisterDLL("msjava.dll")
	_ReregisterDLL("msscript.dll")
	_ReregisterDLL("mssip32.dll")
	_ReregisterDLL("msvcrt.dll")
	_ReregisterDLL("msxml.dll")
	_ReregisterDLL("msxml2.dll")
	_ReregisterDLL("msxml3.dll")
	_ReregisterDLL("msxml6.dll")
	_ReregisterDLL("muweb.dll")
	_ReregisterDLL("netcfgx.dll")
	_ReregisterDLL("netman.dll")
	_ReregisterDLL("netshell.dll")
	_ReregisterDLL("ole32.dll")
	_ReregisterDLL("oleaut32.dll")
	_ReregisterDLL("oledlg.dll")
	_ReregisterDLL("qmgr.dll")
	_ReregisterDLL("qmgrprxy.dll")
	_ReregisterDLL("rsaenh.dll")
	_ReregisterDLL("sccbase.dll")
	_ReregisterDLL("scrobj.dll")
	_ReregisterDLL("scrrun.dll")
	_ReregisterDLL("shdocvw.dll")
	_ReregisterDLL("shell32.dll")
	_ReregisterDLL("slbcsp.dll")
	_ReregisterDLL("softpub.dll")
	_ReregisterDLL("urlmon.dll")
	_ReregisterDLL("vbscript.dll")
	_ReregisterDLL("wintrust.dll")
	_ReregisterDLL("wmnetmgr.dll")
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
	_MemoLoggingWrite("We really hope it worked", 1)
	_EndLogging()

EndFunc


Func _RepairWindowsScript()

	_StartLogging("Repairing Windows Script, please wait...")
	_ReregisterDLL("vbscript.dll")
	_ReregisterDLL("wshom.ocx")
    _ReregisterDLL("scrrun.dll")
	_MemoLoggingWrite("Maybe Windows Script works now.", 1)
	_EndLogging()

EndFunc