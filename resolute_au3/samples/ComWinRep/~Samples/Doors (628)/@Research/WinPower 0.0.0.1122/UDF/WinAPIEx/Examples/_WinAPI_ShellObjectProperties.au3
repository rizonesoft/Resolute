#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)
Opt('WinTitleMatchMode', 4)

Global $hWnd

_WinAPI_ShellObjectProperties(@ScriptFullPath)
If @error Then
	Exit
EndIf

$hWnd = WinWaitActive(@ScriptName, '', 3)
If Not $hWnd Then
	Exit
EndIf

While WinExists($hWnd)
	Sleep(100)
WEnd
