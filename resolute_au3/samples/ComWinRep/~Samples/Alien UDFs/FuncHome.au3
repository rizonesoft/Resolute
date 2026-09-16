#include-once


Func _StartSystemFileCheck()
	ShellExecute("SFC", "/scannow", @SystemDir, "", @SW_SHOW)
EndFunc


Func _OpenSystemRestore()
	ShellExecute("systempropertiesprotection")
EndFunc