#include <MsgBoxConstants.au3>

_Example()
Func _Example()
	For $o = 1 To 3 ; "outer loop"
		For $i = 1 To 10 ; "inner loop"
			If $i = 1 Then ConsoleWrite(@CRLF)

			If $o = 1 And $i = 3 Then ContinueLoop 2 ; if "outer loop" is in first step and "inner loop" is in 3 step, skip "outer loop" to next step
			If $o = 2 And $i = 5 Then ContinueLoop 2 ; if "outer loop" is in second step and "inner loop" is in 5 step, skip "outer loop" to next step
			If $i = 7 Then ContinueLoop ; if "inner loop" is in 7 step, skip "inner loop" to next step
			ConsoleWrite(" The value of $o=" & $o & "  $i=" & $i & @CRLF)
		Next
	Next
EndFunc   ;==>_Example
