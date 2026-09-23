#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $sFile = @ScriptDir & '\Test.txt'

Global $hFile, $hSearch, $tFSD, $pFSD, $pData, $sName, $iSize, $Bytes

; Check NTFS file system
If StringCompare(DriveGetFileSystem(_WinAPI_PathStripToRoot($sFile)), 'NTFS') Then
	MsgBox(16, 'Error', 'The file must be on an NTFS file system volume.')
	Exit
EndIf

; Create text file with three alternative streams named AS1, AS2, and AS3 respectively
For $i = 0 To 3
	If $i Then
		$pData = _WinAPI_CreateString('Alternative stream ' & $i)
		$sName = ':AS' & $i
	Else
		$pData = _WinAPI_CreateString('Main stream')
		$sName = ''
	EndIf
	$hFile = _WinAPI_CreateFile($sFile & $sName, 1, 4)
	_WinAPI_WriteFile($hFile, $pData, _WinAPI_GetMemorySize($pData) - 2, $Bytes)
	_WinAPI_CloseHandle($hFile)
	_WinAPI_FreeMemory($pData)
Next

; Enumerate all existing streams in the file and read text data from each stream
$pData = _WinAPI_CreateBuffer(1024)

$tFSD = DllStructCreate($tagWIN32_FIND_STREAM_DATA)
$pFSD = DllStructGetPtr($tFSD)

$hSearch = _WinAPI_FindFirstStream($sFile, $pFSD)
While Not @error
	$sName = DllStructGetData($tFSD, 'StreamName')
	$iSize = DllStructGetData($tFSD, 'StreamSize')
	$hFile = _WinAPI_CreateFile($sFile & $sName, 2, 2, 6)
	_WinAPI_ReadFile($hFile, $pData, $iSize, $Bytes)
	_WinAPI_CloseHandle($hFile)
	ConsoleWrite(StringFormat('%10s (%s bytes) - %s', $sName, $iSize, _WinAPI_GetString($pData)) & @CR)
	_WinAPI_FindNextStream($hSearch, $pFSD)
WEnd

Switch @extended
	Case 38 ; ERROR_HANDLE_EOF

	Case Else
		MsgBox(16, @extended, _WinAPI_GetErrorMessage(@extended))
EndSwitch

_WinAPI_FindClose($hSearch)

_WinAPI_FreeMemory($pData)

FileDelete($sFile)
