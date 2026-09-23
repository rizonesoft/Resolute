#Include <APIConstants.au3>
#Include <String.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hBitmap = _WinAPI_LoadImage(0, @ScriptDir & '\Extras\Authentication.bmp', $IMAGE_BITMAP, 0, 0, $LR_LOADFROMFILE)
Global $Data[3] = ['', '', 0]

While 1
	$Data = _WinAPI_ShellUserAuthenticationDlg('Authentication', 'To continue, type a login and password, and then click OK.', $Data[0], $Data[1], 'MyScript', BitOR($CREDUI_FLAGS_ALWAYS_SHOW_UI, $CREDUI_FLAGS_EXPECT_CONFIRMATION, $CREDUI_FLAGS_GENERIC_CREDENTIALS, $CREDUI_FLAGS_SHOW_SAVE_CHECK_BOX), 0, $Data[2], $hBitmap)
	If @error Then
		Exit
	EndIf
	If (StringCompare($Data[0], 'AutoIt')) Or (StringCompare($Data[1], _StringEncrypt(0, 'DC7E430A1C88', '123'))) Then
		If $Data[2] Then
			_WinAPI_ConfirmCredentials('MyScript', 0)
		EndIf
		MsgBox(16, 'Error', 'You have typed an incorrect login or password, it should be "AutoIt" and "123".')
	Else
		If $Data[2] Then
			_WinAPI_ConfirmCredentials('MyScript', 1)
		EndIf
		ExitLoop
	EndIf
WEnd
