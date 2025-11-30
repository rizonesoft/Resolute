#Include <APIConstants.au3>
#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $PID = @AutoItPID

Global $Data, $hSource, $hTarget, $hObject

$Data = _WinAPI_EnumProcessHandles($PID)

If IsArray($Data) Then
	$hTarget = _WinAPI_GetCurrentProcess()
	$hSource = _WinAPI_OpenProcess($PROCESS_DUP_HANDLE, 0, $PID)
	If $hSource Then
		For $i = 1 To $Data[0][0]
			$hObject = _WinAPI_DuplicateHandle($hSource, $Data[$i][0], $hTarget)
			If Not @error Then
				$Data[$i][1] = _WinAPI_GetObjectNameByHandle($hObject)
				_WinAPI_CloseHandle($hObject)
			EndIf
		Next
	EndIf
EndIf

_ArrayDisplay($Data, '_WinAPI_EnumProcessHandles')
