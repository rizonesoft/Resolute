#NoTrayIcon

#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)
Opt('WinWaitDelay', 0)

Global Const $Title = '_WinAPI_MapViewOfFile' & ChrW(160)

If Not $CmdLine[0] Then
	If WinExists($Title) Then
		Exit
	EndIf
	For $i = 1 To 2
		If Not @compiled Then
			Run(@AutoItExe & ' "' & @ScriptFullPath & '" /' & $i)
		Else
			Run(@AutoItExe & ' /' & $i)
		EndIf
		Sleep(500)
	Next
	Exit
EndIf

Opt('TrayIconHide', 0)

Switch $CmdLine[1]
	Case '/1'
		_Sender()
	Case '/2'
		_Receiver()
	Case Else
		Exit
EndSwitch

Func _Receiver()

	Local $hMapping, $pAddress, $tData, $Text

	$hMapping = _WinAPI_OpenFileMapping('MyFileMapping')
	If @error Then
		Return
	EndIf

	$pAddress = _WinAPI_MapViewOfFile($hMapping)
	$tData = DllStructCreate('wchar[1024]', $pAddress)
	While WinWait($Title, '', 1)
		Sleep(200)
		$Text = DllStructGetData($tData, 1)
		DllStructSetData($tData, 1, '')
		If $Text Then
			MsgBox(64, $Title, $Text)
		EndIf
	WEnd
	_WinAPI_UnmapViewOfFile($pAddress)
	_WinAPI_CloseHandle($hMapping)
EndFunc   ;==>_Receiver

Func _Sender()

	Local $hMapping, $pAddress, $tData, $Text

	$hMapping = _WinAPI_CreateFileMapping(-1, 2048, 'MyFileMapping')
	If (@error) Or (@extended) Then
		MsgBox(16, 'Error', 'Unable to create file mapping.')
		Return
	EndIf

	$pAddress = _WinAPI_MapViewOfFile($hMapping)
	$tData = DllStructCreate('wchar[1024]', $pAddress)
	While WinWaitClose($Title)
		$Text = StringStripWS(InputBox($Title, 'Type some text message.', '', '', -1, 171), 3)
		If Not $Text Then
			ExitLoop
		EndIf
		DllStructSetData($tData, 1, $Text)
		If Not WinWait($Title, '', 1) Then
			ExitLoop
		EndIf
	WEnd
	_WinAPI_UnmapViewOfFile($pAddress)
	_WinAPI_CloseHandle($hMapping)
EndFunc   ;==>_Sender
