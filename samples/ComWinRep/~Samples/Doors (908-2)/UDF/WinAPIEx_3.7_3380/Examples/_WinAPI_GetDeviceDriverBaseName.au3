#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Info, $Data = _WinAPI_EnumDeviceDrivers()

If IsArray($Data) Then
	Dim $Info[$Data[0]][3]
	For $i = 1 To $Data[0]
		$Info[$i - 1][0] = $Data[$i]
		$Info[$i - 1][1] = _WinAPI_GetDeviceDriverBaseName($Data[$i])
		$Info[$i - 1][2] = _WinAPI_GetDeviceDriverFileName($Data[$i])
	Next
EndIf

_ArrayDisplay($Info, '_WinAPI_EnumDeviceDrivers')
