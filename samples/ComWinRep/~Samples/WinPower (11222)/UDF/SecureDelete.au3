

Func _IsDir($File)
	Return StringInStr(FileGetAttrib($File), "D", 2)
EndFunc

Func _GetDir($File)
	Return StringLeft($File, StringInStr($File, "\", 2, -1) - 1)
EndFunc