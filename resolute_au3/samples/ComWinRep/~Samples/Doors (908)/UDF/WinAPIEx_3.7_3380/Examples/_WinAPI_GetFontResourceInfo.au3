#Include <APIConstants.au3>
#Include <Array.au3>
#Include <File.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $FileList = _FileListToArray(_WinAPI_ShellGetSpecialFolderPath($CSIDL_FONTS), '*.ttf', 1)
Global $FontList[UBound($FileList) - 1][2]

For $i = 1 To $FileList[0]
	$FontList[$i - 1][0] = $FileList[$i]
	$FontList[$i - 1][1] = _WinAPI_GetFontResourceInfo($FileList[$i], 1)
Next

_ArrayDisplay($FontList, '_WinAPI_GetFontResourceInfo')
