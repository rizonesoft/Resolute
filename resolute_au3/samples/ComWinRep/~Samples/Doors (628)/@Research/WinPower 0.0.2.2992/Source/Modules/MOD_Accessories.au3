Func _StartCalculator()
	If FileExists(@SystemDir & "\calc.exe") Then
		ShellExecute("calc")
		If @error Then
			_MemoLogWrite("Microsoft Calculator could not be started.", 2)
		EndIf
	Else
		_MemoLogWrite("[" & @SystemDir & "\calc.exe" & "] could not be found.", 2)
	EndIf
EndFunc
