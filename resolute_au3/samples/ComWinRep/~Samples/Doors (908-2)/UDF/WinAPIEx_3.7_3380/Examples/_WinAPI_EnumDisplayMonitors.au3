#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Pos, $Data = _WinAPI_EnumDisplayMonitors()

If IsArray($Data) Then
	ReDim $Data[$Data[0][0] + 1][5]
	For $i = 1 To $Data[0][0]
		$Pos = _WinAPI_GetPosFromRect($Data[$i][1])
		For $j = 0 To 3
			$Data[$i][$j + 1] = $Pos[$j]
		Next
	Next
EndIf

_ArrayDisplay($Data, '_WinAPI_EnumDisplayMonitors')
