#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.0' Then
	MsgBox(16, 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

ConsoleWrite(_WinAPI_ShellGetKnownFolderPath($FOLDERID_SendTo, 0, -1) & @CR)
ConsoleWrite(_WinAPI_ShellGetKnownFolderPath($FOLDERID_SendTo) & @CR)
