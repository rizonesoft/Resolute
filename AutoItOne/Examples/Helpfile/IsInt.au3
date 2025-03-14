#include <MsgBoxConstants.au3>

Example()

Func Example()
	Local $bIsInt1 = IsInt(-12345) ; Returns 1
	Local $bIsInt2 = IsInt(3.0000) ; Returns 1
	Local $bIsInt3 = IsInt(7.5 - 4.5) ; Returns 1 since it evaluates to integer 3
	Local $bIsInt4 = IsInt(4.5) ; Returns 0 as the value is a Number but not Integer.
	Local $bIsInt5 = IsInt("5432") ; Returns 0 as the value is a string.

	MsgBox($MB_SYSTEMMODAL, "", "IsInt: " & @CRLF & _
			$bIsInt1 & @CRLF & $bIsInt2 & @CRLF & $bIsInt3 & @CRLF & $bIsInt4& @CRLF & $bIsInt5)
EndFunc   ;==>Example
