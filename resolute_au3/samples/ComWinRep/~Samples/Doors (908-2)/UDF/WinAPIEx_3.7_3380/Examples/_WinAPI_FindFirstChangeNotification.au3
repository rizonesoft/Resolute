#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)
Opt('TrayAutoPause', 0)

Global Const $sPath = @ScriptDir & '\~TEST~'

Global $hObj[2], $tObj, $pObj, $ID

DirCreate($sPath)
If Not FileExists($sPath) Then
	MsgBox(16, 'Error', 'Unable to create folder.')
	Exit
EndIf

OnAutoItExitRegister('OnAutoItExit')

$hObj[0] = _WinAPI_FindFirstChangeNotification($sPath, $FILE_NOTIFY_CHANGE_FILE_NAME)
$hObj[1] = _WinAPI_FindFirstChangeNotification($sPath, $FILE_NOTIFY_CHANGE_DIR_NAME)

If (Not $hObj[0]) Or (Not $hObj[1]) Then
	MsgBox(16, 'Error', 'Unable to create change notification.')
	Exit
EndIf

$tObj = DllStructCreate('ptr;ptr')
$pObj = DllStructGetPtr($tObj)
For $i = 0 To 1
	DllStructSetData($tObj, $i + 1, $hObj[$i])
Next

While 1
	Sleep(100)
	$ID = _WinAPI_WaitForMultipleObjects(2, $pObj, 0, 0)
	Switch $ID
		Case 0 ; WAIT_OBJECT_0
			ConsoleWrite('A file was created, renamed, or deleted in the directory.' & @CR)
		Case 1 ; WAIT_OBJECT_0 + 1
			ConsoleWrite('A directory was created, renamed, or deleted.' & @CR)
		Case Else
			ContinueLoop
	EndSwitch
	If Not _WinAPI_FindNextChangeNotification($hObj[$ID]) Then
		MsgBox(16, 'Error', 'Unexpected error.')
		Exit
	EndIf
WEnd

Func OnAutoItExit()
	For $i = 0 To 1
		If $hObj[$i] Then
			_WinAPI_FindCloseChangeNotification($hObj[$i])
		EndIf
	Next
;	DirRemove($sPath)
EndFunc   ;==>OnAutoItExit
