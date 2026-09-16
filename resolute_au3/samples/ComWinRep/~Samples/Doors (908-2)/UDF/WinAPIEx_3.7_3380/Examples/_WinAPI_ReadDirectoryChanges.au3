#Include <APIConstants.au3>
#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $sPath = @DesktopDir & '\~TEST~'

Global $hDirectory, $pBuffer, $aData

DirCreate($sPath)
If Not FileExists($sPath) Then
	MsgBox(16, 'Error', 'Unable to create folder.')
	Exit
EndIf

$hDirectory = _WinAPI_CreateFileEx($sPath, $OPEN_EXISTING, $FILE_LIST_DIRECTORY, BitOR($FILE_SHARE_READ, $FILE_SHARE_WRITE), $FILE_FLAG_BACKUP_SEMANTICS)
If @error Then
	_WinAPI_ShowLastError('', 1)
EndIf

$pBuffer = _WinAPI_CreateBuffer(8388608)

While 1
	$aData = _WinAPI_ReadDirectoryChanges($hDirectory, BitOR($FILE_NOTIFY_CHANGE_FILE_NAME, $FILE_NOTIFY_CHANGE_DIR_NAME), $pBuffer, 8388608, 1)
	If Not @error Then
		_ArrayDisplay($aData, '_WinAPI_ReadDirectoryChanges')
	Else
		_WinAPI_ShowLastError('', 1)
	EndIf
WEnd
