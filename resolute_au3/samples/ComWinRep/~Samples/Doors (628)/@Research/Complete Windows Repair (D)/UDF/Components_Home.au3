#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------


#include-once

#include <CoreWinRepair.au3>


Func _RunSystemFileScanner()

	_ClearLoggingMemo()
	_MemoLoggingWrite("Scanning your system files, please do not close the openned window...", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
	_MemoLoggingWrite("SFC /scannow")
	ShellExecute("SFC", "/scannow", @SystemDir, "", @SW_SHOW)
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _CreateSystemRestorePoint()
	ShellExecute(@ScriptDir & "\restore.exe")
EndFunc