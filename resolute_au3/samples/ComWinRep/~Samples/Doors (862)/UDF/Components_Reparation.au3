#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------


#include-once

#include <Constants.au3>

#include <CoreDoors.au3>


Func _RestoreWindowsShell()

	_MemoLoggingWrite("Checking the status of your Windows shell, please wait...", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
	Local $currShell = RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "Shell")
	_MemoLoggingWrite("Windows Explorer Shell is set to " & Chr(34) & $currShell & Chr(34) & ".", 1)
	If $currShell <> "explorer.exe" Then
		;MsgBox features: Title=Yes, Text=Yes, Buttons=Yes and No, Icon=Question, Timeout=60 ss
		If Not IsDeclared("iMsgB") Then Local $iMsgB
		$iMsgB = MsgBox(36, "Restore Shell", "Would you like to restore the default Windows Explorer Shell?", 30)
		Select
			Case $iMsgB = 6 ;Yes
				_WriteRegistryData("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "Shell", "REG_SZ", "explorer.exe")
			Case $iMsgB = 7 ;No
				_MemoLoggingWrite("Nothing to do here.")
			Case $iMsgB = -1 ;Timeout
				_MemoLoggingWrite("The operation timed out.", 3)
		EndSelect
	EndIf
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _RepairMissingCDIcon()

	_MemoLoggingWrite("Repairing missing CD icon, please wait...", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
	_ConsoleRun("net stop ShellHWDetection")
	_ConsoleRun("sc config ShellHWDetection start= auto obj= LocalSystem")
	_ConsoleRun("net start ShellHWDetection")

	_DeleteRegistryData("HKLM\SYSTEM\CurrentControlSet\Control\Class\{4D36E965-E325-11CE-BFC1-08002BE10318}", "UpperFilters")
	_DeleteRegistryData("HKLM\SYSTEM\CurrentControlSet\Control\Class\{4D36E965-E325-11CE-BFC1-08002BE10318}", "LowerFilters")

	_MemoLoggingWrite("The CD icon should be back; if not, at least we tried.")
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _ResetAutorunSettings()

	_MemoLoggingWrite("Restoring Autorun settings, please wait...", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
	_WriteRegistryData("HKLM\System\CurrentControlSet\Services\CDRom", "AutoRun", "REG_DWORD", 1)
	_DeleteRegistryData("HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "DontSetAutoplayCheckbox")
	_DeleteRegistryData("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "DontSetAutoplayCheckbox")
	_DeleteRegistryData("HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveAutoRun")
	_DeleteRegistryData("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveAutoRun")
	_DeleteRegistryData("HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoAutorun")
	_DeleteRegistryData("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoAutorun")
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _UpdateCDDriveFirmware()
	_OpenInternetBrowser("http://www.firmwarehq.com")
EndFunc