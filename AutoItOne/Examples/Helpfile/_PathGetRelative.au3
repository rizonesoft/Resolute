#include <File.au3>

Example()

Func Example()
	Local $sFrom, $sTo, $sPath

	$sFrom = @ScriptDir
	ConsoleWrite("Source Path: " & $sFrom & @CRLF)
	$sTo = @ScriptDir & "\.."
	ConsoleWrite("Dest Path: " & $sTo & @CRLF)
	$sPath = _PathGetRelative($sFrom, $sTo)

	If @error Then
		ConsoleWrite("Error: " & @error & @CRLF)
		ConsoleWrite("Path: " & $sPath & @CRLF)
	Else
		ConsoleWrite("Relative Path: " & $sPath & @CRLF)
		ConsoleWrite("Resolved Path: " & _PathFull($sFrom & "\" & $sPath) & @CRLF)
	EndIf
EndFunc   ;==>Example
