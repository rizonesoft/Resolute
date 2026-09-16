#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.0' Then
	MsgBox(16, 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

Global $Data, $User

$Data = _WinAPI_ShellUserAuthenticationDlgEx('Authentication', 'To continue, type a login and password, and then click OK.', '', '', BitOR($CREDUIWIN_ENUMERATE_CURRENT_USER, $CREDUIWIN_CHECKBOX))
If @error Then
	Exit
EndIf

$User = _WinAPI_ParseUserName($Data[0])
If @error Then
	Exit
EndIf

ConsoleWrite('Domain:   ' & $User[0] & @CR)
ConsoleWrite('User:     ' & $User[1] & @CR)
ConsoleWrite('Password: ' & $Data[1] & @CR)
ConsoleWrite('Save:     ' & $Data[2] & @CR)
ConsoleWrite('Package:  ' & $Data[3] & @CR)
