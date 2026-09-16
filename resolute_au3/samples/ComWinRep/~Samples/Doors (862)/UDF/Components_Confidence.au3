#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------


#include-once

#include <CoreDoors.au3>


Func _SetAutorunProtectionStatus()

	If RegRead("HKLM\Software\Policies\Microsoft\Windows\Explorer", "NoAutoplayfornonVolume") = "1" Or _
		RegRead("HKCU\Software\Policies\Microsoft\Windows\Explorer", "NoAutoplayfornonVolume") = "1" Or _
		RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun") = "4" Or _
		RegRead("HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun") = "4" Or _
		RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\IniFileMapping\Autorun.inf", "") = "@SYS:DoesNotExist" Then

		$AUTORUN_PROTECTION = True
		Return "Remove &Autorun Protection"

	Else

		$AUTORUN_PROTECTION = False
		Return "Protect against &Autorun parasites"

	EndIf

EndFunc


Func _AutorunProtection()

	_MemoLoggingWrite("Setting Autorun protection, please wait...", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
	If Not $AUTORUN_PROTECTION Then
		If _IsWindowsAboveSeven() Then
			_WriteRegistryData("HKLM\Software\Policies\Microsoft\Windows\Explorer", "NoAutoplayfornonVolume", "REG_DWORD", 1)
			_WriteRegistryData("HKCU\Software\Policies\Microsoft\Windows\Explorer", "NoAutoplayfornonVolume", "REG_DWORD", 1)
		Else
			_WriteRegistryData("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\IniFileMapping\Autorun.inf", "", "REG_SZ", "@SYS:DoesNotExist")
			_WriteRegistryData("HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun", "REG_DWORD", 4)
			_WriteRegistryData("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun", "REG_DWORD", 4)
		EndIf
	Else
		_DeleteRegistryData("HKLM\Software\Policies\Microsoft\Windows\Explorer", "NoAutoplayfornonVolume")
		_DeleteRegistryData("HKCU\Software\Policies\Microsoft\Windows\Explorer", "NoAutoplayfornonVolume")
		_DeleteRegistryData("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\IniFileMapping\Autorun.inf", "")
		_DeleteRegistryData("HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun")
		_DeleteRegistryData("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun")
	EndIf
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc