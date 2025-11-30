#include-once


Func _GetExecVersioning($sExecPath, $iFlag = 6)

	If FileExists($sExecPath) Then
		Local $verReturn = FileGetVersion($sExecPath)
		Local $splReturn = StringSplit($verReturn, ".")

		If $splReturn[0] >= 4 Then
			If $iFlag = 1 Then
				Return $splReturn[1]
			ElseIf $iFlag = 2 Then
				Return $splReturn[2]
			ElseIf $iFlag = 3 Then
				Return $splReturn[3]
			ElseIf $iFlag = 4 Then
				Return $splReturn[4]
			ElseIf $iFlag = 5 Then
				Return $splReturn[1] & " : Build " & $splReturn[4]
			ElseIf $iFlag = 6 Then
				Return $verReturn
			EndIf
		EndIf
	Else
		Return "0000001" ;ERROR CODE: DOORS VERSIONING: PATH TO EXECUTABLE NOT FOUND
	EndIf
EndFunc ;==>_GetDoorsVersion