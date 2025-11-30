#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hObj[2] = [_WinAPI_GetProcessWindowStation(), _WinAPI_GetThreadDesktop(_WinAPI_GetCurrentThreadID())]

For $i = 0 To 1
	If Not $i Then
		ConsoleWrite('-------------------------------' & @CR)
	EndIf
	ConsoleWrite('Handle: ' & $hObj[$i] & @CR)
	ConsoleWrite('Type:   ' & _WinAPI_GetUserObjectInformation($hObj[$i], $UOI_TYPE) & @CR)
	ConsoleWrite('Name:   ' & _WinAPI_GetUserObjectInformation($hObj[$i], $UOI_NAME) & @CR)
	ConsoleWrite('-------------------------------' & @CR)
Next
