#include-once

#include "CoreConstants.au3"

Global $EXE_BIOSCODES = $DIR_HIVE & "\BIOSCodes.exe"
Global $EXE_QUICKERASE = $DIR_HIVE & "\QuickErase.exe"
Global $EXE_INDICATORS = $DIR_HIVE & "\Indicators.exe"
Global $EXE32_FONTREG = $DIR_CONSOLE & "\FontReg.exe"
Global $EXE64_FONTREG = $DIR_CONSOLE & "\FontReg64.exe"

Global $EXE_FONTREG


Func _ExeOSSwitch()

	If @OSArch = "X86" Then
		$EXE_FONTREG = $EXE32_FONTREG
	ElseIf @OSArch = "X64" Then
		$EXE_FONTREG = $EXE64_FONTREG
	EndIf

EndFunc