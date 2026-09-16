#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.0' Then
	MsgBox(16, 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

Global $tGUID, $sFile, $hFile

; Create temporary file
$sFile = _WinAPI_GetTempFileName(@TempDir)

; Create unique object ID for a file
$tGUID = _WinAPI_CreateObjectID($sFile)

ConsoleWrite('GUID: ' & _WinAPI_StringFromGUID(DllStructGetPtr($tGUID)) & @CR)

; Open file by object ID and retrieve its full path
$hFile = _WinAPI_OpenFileById(_WinAPI_PathStripToRoot(@TempDir), $tGUID, 0, BitOR($FILE_SHARE_DELETE, $FILE_SHARE_READ, $FILE_SHARE_WRITE))
$sFile = _WinAPI_GetFinalPathNameByHandle($hFile)
_WinAPI_CloseHandle($hFile)

ConsoleWrite('Path: ' & StringReplace($sFile, '\\?\', '', 1) & @CR)

; Delete file
FileDelete($sFile)
