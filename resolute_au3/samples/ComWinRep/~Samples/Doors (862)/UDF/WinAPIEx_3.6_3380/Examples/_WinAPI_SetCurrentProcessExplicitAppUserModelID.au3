#NoTrayIcon

#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.1' Then
	MsgBox(16, 'Error', 'Require Windows 7 or later.')
	Exit
EndIf

Global Const $sAppID = 'Yashied.WinAPIEx.UDF'

Global $Param

If Not $CmdLine[0] Then
	For $i = 1 To 5
		Switch $i
			Case 1 To 2
				$Param = $sAppID & '.' & $i
			Case Else
				$Param = $sAppID & '.3'
		EndSwitch
		If Not @compiled Then
			Run(@AutoItExe & ' "' & @ScriptFullPath & '" ' & $Param)
		Else
			Run(@AutoItExe & ' ' & $Param)
		EndIf
		Sleep(100)
	Next
	Exit
EndIf

_WinAPI_SetCurrentProcessExplicitAppUserModelID($CmdLine[1])

GUICreate($CmdLine[1], 400, 400)
GUISetState(@SW_SHOWMINIMIZED)

Do
Until GUIGetMsg() = -3
