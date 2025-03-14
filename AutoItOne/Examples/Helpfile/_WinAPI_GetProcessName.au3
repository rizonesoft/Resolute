#include <Array.au3>
#include <WinAPIProc.au3>

_ArrayDisplay(_GetParentProcessTree(), "_GetParentProcessTree", "", 0, Default, "PID|Name|CommandLine")

Func _GetParentProcessTree($iPID = @AutoItPID)
	Local $n, $iParentPID = $iPID, $aList[100][3]
	$aList[0][0] = $iPID
	$aList[0][1] = _WinAPI_GetProcessName($iPID)
	$aList[0][2] = _WinAPI_GetProcessCommandLine($iPID)
	For $n = 1 To 99
		$iParentPID = _WinAPI_GetParentProcess($iParentPID)
		If $iParentPID = 0 Then ExitLoop
		$aList[$n][0] = $iParentPID
		$aList[$n][1] = _WinAPI_GetProcessName($iParentPID)
		$aList[$n][2] = _WinAPI_GetProcessCommandLine($iParentPID)
	Next
	ReDim $aList[$n][3]
	Return $aList
EndFunc   ;==>_GetParentProcessTree
