#include <MsgBoxConstants.au3>
#include <String.au3>

Example()

Func Example()
	; Variable to store the output
	Local $sOutput = ""

	; Inserts three "moving" underscores and prints them to the console.
	For $i = -20 To 20
		$sOutput &= $i & @TAB & _StringInsert("Supercalifragilistic", "___", $i) & @CRLF
	Next

	; Display the output
	MsgBox($MB_SYSTEMMODAL, "", $sOutput)
EndFunc   ;==>Example
