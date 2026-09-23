Global Const $GWinsRepExe = @ScriptDir & "\WinsRepair.exe"

Func _OpenWinsockRepair()
	If Not FileExists($GWinsRepExe) Then
		MsgBox(16, "Power Suite", "Could not find [" & $GWinsRepExe & "]")
	Else
		ShellExecute($GWinsRepExe)
	EndIf
EndFunc