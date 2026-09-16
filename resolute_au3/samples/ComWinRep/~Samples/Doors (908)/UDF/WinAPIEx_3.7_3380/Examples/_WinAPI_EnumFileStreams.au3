#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $sFile = @ScriptDir & '\Test.txt'

Global $hFile, $aData, $pData, $sName, $Bytes

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

; Enumerate all existing streams in the file
$aData = _WinAPI_EnumFileStreams($sFile)

_ArrayDisplay($aData, '_WinAPI_EnumFileStreams')

; Read text data from each stream
$pData = _WinAPI_CreateBuffer(1024)
For $i = 1 To $aData[0][0]
	$hFile = _WinAPI_CreateFile($sFile & $aData[$i][0], 2, 2, 6)
	_WinAPI_ReadFile($hFile, $pData, $aData[$i][1], $Bytes)
	_WinAPI_CloseHandle($hFile)
	$aData[$i][1] = _WinAPI_GetString($pData)
Next
_WinAPI_FreeMemory($pData)

_ArrayDisplay($aData, '_WinAPI_EnumFileStreams')

FileDelete($sFile)
