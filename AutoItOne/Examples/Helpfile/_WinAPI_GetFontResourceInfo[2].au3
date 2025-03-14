#include <Array.au3>
#include <File.au3>
#include <WinAPIGdi.au3>
#include <WinAPIShellEx.au3>

Example()

Func Example()
	Local $aFileList = _FileListToArray(_WinAPI_ShellGetSpecialFolderPath($CSIDL_FONTS), '*.ttf', 1)
	Local $aFontList[UBound($aFileList) - 1][2]

	For $i = 1 To $aFileList[0]
		$aFontList[$i - 1][0] = $aFileList[$i]
		$aFontList[$i - 1][1] = _WinAPI_GetFontResourceInfo($aFileList[$i], Default, 1)
	Next

	_ArrayDisplay($aFontList, '_WinAPI_GetFontResourceInfo (Font Family name)')

EndFunc   ;==>Example
