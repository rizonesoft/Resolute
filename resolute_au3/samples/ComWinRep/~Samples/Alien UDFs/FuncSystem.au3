#include-once


Func _RestoreWindowsShell()

	Local Const $ix = 0
	Local Const $ico = 425
	Local Const $sShellKey = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"

	_BeginProcess($ICON_SYSTEM1[$ix], $CHK_SYSTEM1[$ix])
	_StartLogging("Restoring default time format.")
		Sleep(100)
	_DrawSystemPage1Progress($ix, 10)
		Sleep(100)
	_DrawSystemPage1Progress($ix, 50)

	Local $sCurrShell = RegRead($sShellKey, "Shell")

	If $sCurrShell <> "explorer.exe" Then
		_EditLoggingWrite("Windows Shell set to " & Chr(34)  & $sCurrShell & Chr(34) & ".")
		Sleep(100)
		_EditLoggingWrite("We will now continue to restore the default Windows shell.")
		Sleep(100)
		RegWrite($sShellKey, "Shell", "REG_SZ", "explorer.exe")
		If @error Then
			_EditLoggingWrite("Could not restore the default Windows shell.", 1, 1)
			_SwitchRegistryError(@error)
		EndIf
	EndIf

	_DrawSystemPage1Progress($ix, 100)
		Sleep(100)
	_EndLogging()
	_DrawSystemPage1Progress($ix, 0)
	_EndProcess($ICON_SYSTEM1[$ix], $CHK_SYSTEM1[$ix], $ico)

EndFunc


Func _CheckRebuildWMI()

	Local Const $ix = 6
	Local Const $ico = 431

	_BeginProcess($ICON_SYSTEM1[$ix], $CHK_SYSTEM1[$ix])
	_StartLogging("Checking and Rebuilding the WMI repository.")
		Sleep(100)
	_DrawSystemPage1Progress($ix, 10)

	_RunCommand("sc config winmgmt start= disabled")
	_DrawSystemPage1Progress($ix, 20)
	_RunCommand("net stop iphlpsvc")
	_DrawSystemPage1Progress($ix, 30)
	_RunCommand("net stop wscsvc")
	_DrawSystemPage1Progress($ix, 40)
	_RunCommand("net stop winmgmt")
	_DrawSystemPage1Progress($ix, 50)
	_RunCommand("winmgmt /salvagerepository %windir%\System32\wbem")
	_DrawSystemPage1Progress($ix, 60)
	_RunCommand("winmgmt /resetrepository %windir%\System32\wbem")
	_DrawSystemPage1Progress($ix, 70)
	_RunCommand("sc config winmgmt start= auto")
	_DrawSystemPage1Progress($ix, 80)
	_RunCommand("net start iphlpsvc")
	_DrawSystemPage1Progress($ix, 90)
	_RunCommand("net start wscsvc")
	_DrawSystemPage1Progress($ix, 95)
	_RunCommand("net start winmgmt /Y")

	_DrawSystemPage1Progress($ix, 100)
		Sleep(100)
	_EndLogging()
	_DrawSystemPage1Progress($ix, 0)
	_EndProcess($ICON_SYSTEM1[$ix], $CHK_SYSTEM1[$ix], $ico)

EndFunc


Func _RepairWindowsInstaller()

	Local Const $ix = 7
	Local Const $ico = 432

	_BeginProcess($ICON_SYSTEM1[$ix], $CHK_SYSTEM1[$ix])
	_StartLogging("Repairing Windows Installer.")
		Sleep(100)
	_DrawSystemPage1Progress($ix, 10)

	_RunCommand("net start msiserver")
	_DrawSystemPage1Progress($ix, 20)
	_RunCommand("sc config msiserver start= demand")
	_DrawSystemPage1Progress($ix, 30)
	_EditLoggingWrite("Unregistering Installer Service.", 1, 1)
	_RunCommand("msiexec /unreg")
	_DrawSystemPage1Progress($ix, 40)
	_EditLoggingWrite("Registering Windows Installer DLLs", 1, 1)
	_ReregisterDLL("msi.dll")
	_DrawSystemPage1Progress($ix, 50)
	_EditLoggingWrite("Registering Installer Service.", 1, 1)
	_RunCommand("msiexec /regserver")
	_DrawSystemPage1Progress($ix, 60)
	_RunCommand("net stop msiserver")
	_DrawSystemPage1Progress($ix, 70)
	_EditLoggingWrite("Updating Per-User System Parameters.", 1, 1)
	DllCall("user32.dll", "int", "UpdatePerUserSystemParameters", "int", 1, "bool", True)

	_DrawSystemPage1Progress($ix, 100)
		Sleep(100)
	_EndLogging()
	_DrawSystemPage1Progress($ix, 0)
	_EndProcess($ICON_SYSTEM1[$ix], $CHK_SYSTEM1[$ix], $ico)

EndFunc


Func _RepairWindowsTime()

	Local Const $ix = 8
	Local Const $ico = 433

	_BeginProcess($ICON_SYSTEM1[$ix], $CHK_SYSTEM1[$ix])
	_StartLogging("Repairing Windows Time")
		Sleep(100)
	_DrawSystemPage1Progress($ix, 10)

	_DrawSystemPage1Progress($ix, 20)
	_EditLoggingWrite("Stopping the Windows Time Service.", 1, 1)
	_RunCommand("net stop W32Time")

	_DrawSystemPage1Progress($ix, 30)
	_EditLoggingWrite("Configuring the Windows Time Service.", 1, 1)
	_RunCommand("sc config W32Time start= auto")

	_DrawSystemPage1Progress($ix, 40)
	_EditLoggingWrite("Unregistering then Windows Time Service.", 1, 1)
	_RunCommand("w32tm.exe /unregister")
	_DrawSystemPage1Progress($ix, 50)
	_EditLoggingWrite("Registering then Windows Time Service.", 1, 1)
	_RunCommand("w32tm.exe /register")

	_DrawSystemPage1Progress($ix, 60)
	_EditLoggingWrite("Restarting the Windows Time Service.", 1, 1)
	_RunCommand("net start W32Time")

	_EditLoggingWrite("Syncing Windows Time.")
	_RunCommand("w32tm /resync")

	_DrawSystemPage1Progress($ix, 100)
		Sleep(100)
	_EndLogging()
	_DrawSystemPage1Progress($ix, 0)
	_EndProcess($ICON_SYSTEM1[$ix], $CHK_SYSTEM1[$ix], $ico)

EndFunc


Func _RestoreDefaultTimeFormat()

	Local Const $ix = 9
	Local Const $ico = 434

	_BeginProcess($ICON_SYSTEM1[$ix], $CHK_SYSTEM1[$ix])
	_StartLogging("Restoring Default Windows Time Format.")
		Sleep(100)
	_DrawSystemPage1Progress($ix, 10)

	Switch @OSVersion

		Case "WIN_8", "WIN_81"

			_RegistryWrite("HKEY_CURRENT_USER\Control Panel\International", "sLongDate", "REG_SZ", "dd MMMM yyyy")
			_RegistryWrite("HKEY_CURRENT_USER\Control Panel\International", "sShortDate", "REG_SZ", "dd/MM/yyyy")
			_RegistryWrite("HKEY_CURRENT_USER\Control Panel\International", "sShortTime", "REG_SZ", "hh:mm tt")
			_RegistryWrite("HKEY_CURRENT_USER\Control Panel\International", "sTime", "REG_SZ", ":")
			_RegistryWrite("HKEY_CURRENT_USER\Control Panel\International", "sTimeFormat", "REG_SZ", "HH:mm:ss")
			_RegistryWrite("HKEY_CURRENT_USER\Control Panel\International", "sYearMonth", "REG_SZ", "MMMM yyyy")

		Case "WIN_10"

			_RegistryWrite("HKEY_CURRENT_USER\Control Panel\International", "sLongDate", "REG_SZ", "dddd, dd MMMM yyyy")
			_RegistryWrite("HKEY_CURRENT_USER\Control Panel\International", "sShortDate", "REG_SZ", "yyyy/MM/dd")
			_RegistryWrite("HKEY_CURRENT_USER\Control Panel\International", "sShortTime", "REG_SZ", "h:mm tt")
			_RegistryWrite("HKEY_CURRENT_USER\Control Panel\International", "sTime", "REG_SZ", ":")
			_RegistryWrite("HKEY_CURRENT_USER\Control Panel\International", "sTimeFormat", "REG_SZ", "h:mm:ss tt")
			_RegistryWrite("HKEY_CURRENT_USER\Control Panel\International", "sYearMonth", "REG_SZ", "MMMM/yyyy")

	EndSwitch

	_DrawSystemPage1Progress($ix, 100)
		Sleep(100)
	_EndLogging()
	_DrawSystemPage1Progress($ix, 0)
	_EndProcess($ICON_SYSTEM1[$ix], $CHK_SYSTEM1[$ix], $ico)

EndFunc


Func _RepairFontRegistrations()

	Local Const $ix = 10
	Local Const $ico = 435

	_BeginProcess($ICON_SYSTEM1[$ix], $CHK_SYSTEM1[$ix])
	_StartLogging("Repairing Font Registrations.")
		Sleep(100)
	_DrawSystemPage1Progress($ix, 50)
	_RunCommand(Chr(34) & $EXE_FONTREG & Chr(34))
	_DrawSystemPage1Progress($ix, 100)
		Sleep(100)
	_EndLogging()
	_DrawSystemPage1Progress($ix, 0)
	_EndProcess($ICON_SYSTEM1[$ix], $CHK_SYSTEM1[$ix], $ico)

EndFunc


Func _RepairWindowsShutdown()

	Local Const $ix = 15
	Local Const $ico = 440
	Local $iMsgBoxReturn

	_BeginProcess($ICON_SYSTEM1[$ix], $CHK_SYSTEM1[$ix])
	_StartLogging("Repairing Windows Shutdown.")
		Sleep(100)
	_DrawSystemPage1Progress($ix, 10)

	$iMsgBoxReturn = MsgBox($MB_YESNOCANCEL + $MB_ICONWARNING + $MB_APPLMODAL + $MB_TOPMOST, _
		"Are you sure?", "When running this repair option, Windows shutdown will automatically terminate all processes. " & _
		"You will no longer be able to save unsaved work while shutting down. We will continue with repair operation " & _
		"after " & $CONF_MSGTIMEOUT & " seconds. Answer Yes to continue and Cancel to do nothing.", $CONF_MSGTIMEOUT, $GUI_CORE)

	If $iMsgBoxReturn = $IDYES Then

		_EditLoggingWrite("Reducing Shutdown Kill Delays", 1, 1)
		_DrawSystemPage1Progress($ix, 20)
		_RegistryWrite("HKEY_CURRENT_USER\Control Panel\Desktop", "AutoEndTasks", "REG_SZ", 1)
		_DrawSystemPage1Progress($ix, 30)
		_RegistryWrite("HKEY_CURRENT_USER\Control Panel\Desktop", "WaitToKillAppTimeout", "REG_SZ", 1500)
		_DrawSystemPage1Progress($ix, 40)
		_RegistryWrite("HKEY_CURRENT_USER\Control Panel\Desktop", "HungAppTimeout", "REG_SZ", 1500)
		_DrawSystemPage1Progress($ix, 50)
		_RegistryWrite("HKEY_USERS\.DEFAULT\Control Panel\Desktop", "AutoEndTasks", "REG_SZ", 1)
		_DrawSystemPage1Progress($ix, 60)
		_RegistryWrite("HKEY_USERS\.DEFAULT\Control Panel\Desktop", "WaitToKillAppTimeout", "REG_SZ", 1500)
		_DrawSystemPage1Progress($ix, 70)
		_RegistryWrite("HKEY_USERS\.DEFAULT\Control Panel\Desktop", "HungAppTimeout", "REG_SZ", 1500)
		_DrawSystemPage1Progress($ix, 80)
		_RegistryWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control", "WaitToKillServiceTimeout", "REG_SZ", 1500)
		_DrawSystemPage1Progress($ix, 90)

	ElseIf $iMsgBoxReturn = $IDCANCEL Then

		_EditLoggingWrite("You cancelled Windows shutdown repair.", 1, 1)

	EndIf

	_EditLoggingWrite("Do not clear Page File at Shutdown.", 1, 1)
	_RegistryWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management", "ClearPageFileAtShutdown", "REG_DWORD", 0)

	_DrawSystemPage1Progress($ix, 100)
		Sleep(100)
	_EndLogging()
	_DrawSystemPage1Progress($ix, 0)
	_EndProcess($ICON_SYSTEM1[$ix], $CHK_SYSTEM1[$ix], $ico)

EndFunc


Func _DrawSystemPage1Progress($iIndex, $iPerc)

	_DrawStatusSizeFromPercentage($PROGRESS_SYSTEM1[$iIndex], $iPerc, 365, $PRGTOP_SYSTEM1[$iIndex], 310, 1)

EndFunc
