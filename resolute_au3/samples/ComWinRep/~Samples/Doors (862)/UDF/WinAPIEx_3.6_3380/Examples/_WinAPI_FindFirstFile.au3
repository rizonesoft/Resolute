#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tData, $pData, $hSearch, $File

Dim $List[101][2] = [[0]]

$tData = DllStructCreate($tagWIN32_FIND_DATA)
$pData = DllStructGetPtr($tData)

$hSearch = _WinAPI_FindFirstFile(@ScriptDir & '\*', $pData)
While Not @error
	$File = DllStructGetData($tData, 'cFileName')
	Switch $File
		Case '.', '..'

		Case Else
			If Not BitAND(DllStructGetData($tData, 'dwFileAttributes'), $FILE_ATTRIBUTE_DIRECTORY) Then
				$List[0][0] += 1
				If $List[0][0] > UBound($List) - 1 Then
					ReDim $List[UBound($List) + 100][2]
				EndIf
				$List[$List[0][0]][0] = $File
				$List[$List[0][0]][1] = _WinAPI_MakeQWord(DllStructGetData($tData, 'nFileSizeLow'), DllStructGetData($tData, 'nFileSizeHigh'))
			EndIf
	EndSwitch
	_WinAPI_FindNextFile($hSearch, $pData)
WEnd

Switch @extended
	Case 18 ; ERROR_NO_MORE_FILES

	Case Else
		MsgBox(16, @extended, _WinAPI_GetErrorMessage(@extended))
		Exit
EndSwitch

_WinAPI_FindClose($hSearch)

_ArrayDisplay($List, '_WinAPI_Find...', $List[0][0])
