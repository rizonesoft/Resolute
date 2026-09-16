#NoTrayIcon

Global $0 = "ICU_v_5"
Global $1, $2, $3
If Not FileExists(@ScriptDir & "\ICU") Then DirCreate(@ScriptDir & "\ICU")
Global $4 = @ScriptDir & "\ICU"
Global $5 = 0
If IniRead(@ScriptDir & "\ICU\ICU.ini", "Settings", "Version", "") <> $0 Then
$5 = 1
IniWrite(@ScriptDir & "\ICU\ICU.ini", "Settings", "Version", $0)
EndIf
If @OSArch = "X86" Then
$1 = $4 & "\ICU_32bit.exe"
If FileGetVersion(@ScriptName) <> FileGetVersion($1) Then FileDelete($1)
FileInstall("ICU_32bit.exe", $1, $5)
Else
$1 = $4 & "\ICU_64bit.exe"
If FileGetVersion(@ScriptName) <> FileGetVersion($1) Then FileDelete($1)
FileInstall("ICU_64bit.exe", $1, $5)
EndIf
If Not FileExists($1) Then _3("Could not extract OSArch file to" & @CRLF & @CRLF & $1)
RunWait(FileGetShortName($1) & " " & $CmdLineRaw, $4)
Func _3($6 = "")
If $6 Then MsgBox(16 + 262144, "ICU Install Error", $6)
Exit
EndFunc
