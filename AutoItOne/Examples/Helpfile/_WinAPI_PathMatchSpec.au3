#include <Array.au3>
#include <File.au3>
#include <WinAPIShPath.au3>

_Example()
Func _Example()
	Local $aFileList = _FileListToArray(@SystemDir, '*.dll', 1)
	Local $aSortList[UBound($aFileList) - 1]
	Local $iCount = 0

	For $i = 1 To $aFileList[0]
		If _WinAPI_PathMatchSpec($aFileList[$i], 'net*.dll') Then
			$aSortList[$iCount] = $aFileList[$i]
			$iCount += 1
		EndIf
	Next
	If $iCount Then
		ReDim $aSortList[$iCount]
	Else
		Exit
	EndIf

	_ArrayDisplay($aSortList, '_WinAPI_PathMatchSpec')

EndFunc   ;==>_Example
