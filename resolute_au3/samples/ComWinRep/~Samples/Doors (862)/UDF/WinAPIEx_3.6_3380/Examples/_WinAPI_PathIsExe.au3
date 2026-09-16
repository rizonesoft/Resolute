#Include <Array.au3>
#Include <File.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $FileList = _FileListToArray(@SystemDir, '*.*', 1)
Global $SortList[UBound($FileList) - 1]
Global $Count = 0

For $i = 1 To $FileList[0]
	If _WinAPI_PathIsExe($FileList[$i]) Then
		$SortList[$Count] = $FileList[$i]
		$Count += 1
	EndIf
Next
If $Count Then
	ReDim $SortList[$Count]
Else
	Exit
EndIf

_ArrayDisplay($SortList, '_WinAPI_PathIsContentType')
