#include <Array.au3>
#include <ProcessConstants.au3>
#include <WinAPIHObj.au3>
#include <WinAPIProc.au3>

Global Const $PID = @AutoItPID

Local $hSource, $hTarget, $hObject

Local $aData = _WinAPI_EnumProcessHandles($PID)

If IsArray($aData) Then
	$hTarget = _WinAPI_GetCurrentProcess()
	$hSource = _WinAPI_OpenProcess($PROCESS_DUP_HANDLE, 0, $PID)
	If $hSource Then
		For $i = 1 To $aData[0][0]
			$hObject = _WinAPI_DuplicateHandle($hSource, $aData[$i][0], $hTarget, 0, False, $DUPLICATE_SAME_ACCESS)
			If Not @error Then
				$aData[$i][1] = _WinAPI_GetObjectNameByHandle($hObject)
				_WinAPI_CloseHandle($hObject)
			EndIf
		Next
	EndIf
EndIf

_ArrayDisplay($aData, '_WinAPI_EnumProcessHandles', '', Default, Default, 'Handle|Type|Attributes|Access')
