#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Icon[3] = [48, 32, 16]

For $i = 0 To UBound($Icon) - 1
	$Icon[$i] = _WinAPI_Create32BitHICON(_WinAPI_ShellExtractIcon(@SystemDir & '\shell32.dll', 32, $Icon[$i], $Icon[$i]), 1)
Next
_WinAPI_SaveHICONToFile(@ScriptDir & '\MyIcon.ico', $Icon)
For $i = 0 To UBound($Icon) - 1
	_WinAPI_DestroyIcon($Icon[$i])
Next
