#include-once


Func _GetExecVersioning($sExecPath, $iFlag = 5)

	If @Compiled Then

		If FileExists($sExecPath) Then
			Local $verReturn = FileGetVersion($sExecPath)
			Local $splReturn = StringSplit($verReturn, ".")

			If $splReturn[0] >= 4 Then
				If $iFlag = 1 Then ;~ Return Major Version Number
					Return $splReturn[1]
				ElseIf $iFlag = 2 Then ;~ Return Minor Version Number
					Return $splReturn[2]
				ElseIf $iFlag = 3 Then ;~ Return Patch Version Number
					Return $splReturn[3]
				ElseIf $iFlag = 4 Then ;~ Return Build Number
					Return $splReturn[4]
				ElseIf $iFlag = 5 Then ;~ Return Doors Version Number
					Return $splReturn[1] & " : Build " & $splReturn[4]
				ElseIf $iFlag = 6 Then ;~ Return Complete Version Number
					Return $verReturn
				EndIf
			EndIf
		Else
			Return 0
		EndIf

	Else
		Return @AutoItVersion
	EndIf

EndFunc ;==>_GetDoorsVersion