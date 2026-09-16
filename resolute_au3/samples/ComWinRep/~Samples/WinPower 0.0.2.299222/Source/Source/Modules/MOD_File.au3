Func _OpenPowerLog()
	_OpenTextFile($GPowerLog)
EndFunc

Func _OpenLoggingFolder()
	ShellExecute($GLogDir)
	If @error Then
		_MemoLogWrite("Could not open the [" & $GLogDir & "] directory.", 2)
	EndIf
EndFunc
