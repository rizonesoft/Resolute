#include-once


#include <CoreDoors.au3>


Func _RepairFontRegistrations()

	_InitializeLogging()
	_MemoLoggingWrite("Removing stale font registrations and repairing missing font registration, please wait...")
	If @OSArch = "X64" Then
		ShellExecute($DIR_CONSOLE & "\64Bit\FontReg.exe")
		;~ _ShellExecuteEx($DIR_CONSOLE & "\64Bit\FontReg.exe")
	Else
		ShellExecute($DIR_CONSOLE & "\FontReg.exe")
		;~ _ShellExecuteEx($DIR_CONSOLE & "\FontReg.exe")
	EndIf
	If Not @error Then _MemoLoggingWrite("Font registrations repaired, I hope.", 1)

EndFunc