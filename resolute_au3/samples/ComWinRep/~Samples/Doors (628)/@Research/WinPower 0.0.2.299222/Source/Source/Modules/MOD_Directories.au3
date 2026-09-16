Func _CreateLoggingDirectory()
	If Not FileExists($GLogDir) Then
		If DirCreate($GLogDir) = 0 Then
			MsgBox(16, "Error!", "The [" & $GLogDir & "] directory could not be created. Make sure that the drive you are running Power Tools from are not write " & _
								 "protected. Note that Power Tools can not be run from a CD or DVD.")
		EndIf
	EndIf
EndFunc
