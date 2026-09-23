#include-once


#include <CoreDoors.au3>


Global Const $PE_CONSOLE = @ScriptDir & "\Console\Console.exe"
Global Const $PE_COMMAND = @ScriptDir & "\Console\Command.exe"
Global Const $INI_COMMAND = @ScriptDir & "\Console\Command.ini"


Func _LaunchRevoUninstaller()
;~ 	_LanchDoorsHiveModule("revouninstaller\Revouninstaller.exe", _
;~ 				"revouninstaller", "Revo Uninstaller", $SET_DEFMODE)

	_MemoLoggingWrite("Launching Revo Uninstaller")
	ShellExecute(@ScriptDir & "\Doors\Bin\revouninstaller\Revouninstaller.exe", "", @ScriptDir, "", @SW_SHOW)
	If @error Then ShellExecute(@ScriptDir & "\Doors\Bin\revouninstaller.txt", "", @ScriptDir, "", @SW_SHOW)

EndFunc


Func _LaunchDefragmentation()

	Local $ausDefrExe = $DIR_MODULES & "\ausdiskdefrag\DiskDefrag.exe"

	If FileExists($ausDefrExe) Or FileExists($DIR_MODULES & "\ausdiskdefrag.7z") Then
		_LaunchDoorsHiveModule("ausdiskdefrag\DiskDefrag.exe", _
				"ausdiskdefrag", "Auslogics Disk Defrag", $SET_DEFMODE)
	Else
		Switch @OSVersion
			Case "WIN_XP", "WIN_XPe", "WIN_2003"
				_LaunchFixedLocation(@SystemDir & "\dfrg.msc", "Windows 2000 Defrag")
			Case "WIN_VISTA", "WIN_7", "WIN_2008", "WIN_2008R2", "WIN_8"
				_LaunchFixedLocation(@SystemDir & "\dfrgui.exe", "Windows Defrag")
		EndSwitch
	EndIf

EndFunc


Func _LaunchOwnership()
	_LaunchFixedLocation($DIR_DOORS & "\Ownership.exe", "Rizonesoft Ownership")
EndFunc


Func _LaunchIndicators()
	_LaunchFixedLocation($DIR_DOORS & "\Indicators.exe", "Rizonesoft Notebook Indicators")
EndFunc

Func _LaunchQuickErase()
	;_LaunchFixedLocation($DIR_DOORS & "\QuickErase.exe", "Rizonesoft Quick Erase")
	ShellExecute($DIR_DOORS & "\QuickErase.exe", "", $DIR_DOORS, "open", @SW_SHOW)
	;Run($DIR_DOORS & "\QuickErase.exe", $DIR_DOORS)
EndFunc

;$SETTINGS_DOORS
Func _LaunchCommandPrompt()

	_InitializeLogging()

	_MemoLoggingWrite("Launching the Doors Command Prompt, please wait...")
	If IniRead($INI_COMMAND, "Command", "RepairCommandOnStart", 1) = 1 Then
		_MemoLoggingWrite("Automatic Command Prompt repair enabled (Command.ini)")
	EndIf
	If IniRead($INI_COMMAND, "Command", "SetCommandEnhancements", 1) = 1 Then
		_MemoLoggingWrite("Command Prompt Enhancements enabled (Command.ini)")
		If IniRead($INI_COMMAND, "Command", "RemoveEnancementsOnClose", 0) = 1 Then
			_MemoLoggingWrite("Command Prompt Enhancements will be removed when you close the Command Prompt (Command.ini)")
		EndIf
	EndIF

	ShellExecute($PE_COMMAND)

EndFunc


Func _StartCommandPromptRepair()

	If _RepairCommandPrompt() > 0 Then
		_MemoLoggingWrite("The Command Prompt should work now", 1)
	Else
		_MemoLoggingWrite("Nothing seems to be broken here.", 1)
	EndIf

EndFunc


Func _RepairCommandPrompt()

	Local $errorCount = 0

	_InitializeLogging()
	_MemoLoggingWrite("Searching for Command Prompt errors, please wait...")

	If RegRead("HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System", "DisableCMD") <> 0 Or _
		RegRead("HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\System", "DisableCMD") <> 0 Then

		$errorCount =+ 1
		_MemoLoggingWrite("The command prompt has been disabled by your administrator.", 2)
		_MemoLoggingWrite("Restoring access to the Command Prompt, please wait...")

		RegDelete("HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System", "DisableCMD")
		RegDelete("HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\System", "DisableCMD")

	EndIf

	If EnvGet("ComSpec") = "" Then
		_MemoLoggingWrite("The ComSpec environment variable is missing.", 2)
		_MemoLoggingWrite("Restoring the ComSpec environment variable to [%SystemRoot%\system32\cmd.exe], please wait...")
		EnvSet("ComSpec", "%SystemRoot%\system32\cmd.exe")
		$errorCount =+ 1
	EndIf

	Return $errorCount

EndFunc


Func _LaunchConsole()
	_LaunchFixedLocation($PE_CONSOLE, "Console", "", $DIR_CONSOLE)
EndFunc