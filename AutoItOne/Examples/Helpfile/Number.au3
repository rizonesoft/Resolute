#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>

Local $dNumber1 = Number(1 + 2 + 10) ; Returns 13.
Local $dNumber2 = Number("3.14") ; Returns 3.14.
Local $dNumber3 = Number("24/7") ; Returns 24.
Local $dNumber4 = Number("tmp3") ; Returns 0 as this is a string.
Local $dNumber5 = Number("1,000,000") ; Returns 1 as it strips everything after (and including) the first comma.
Local $dNumber6 = Number("24autoit") ; Returns 24
Local $dNumber7 = Number("1.2e3sa") ; Returns 1200
Local $dNumber8 = Number("0xcade") ; Returns 51934
Local $dNumber9 = Number(Ptr(5)) ; Returns 5
Local $dNumber10 = Number(Binary("abc")) ; Returns decimal value of 0x616263 = 6513249
Local $dNumber11 = Number(ObjCreate("Scripting.Dictionary")) ; Returns 0
Local $dNumber12 = Number(1 > 3 Or 5 <= 15) ; Returns 1
Local $dNumber13 = Number("-30") ; Returns 30

MsgBox($MB_SYSTEMMODAL, "", "The following values were converted to a numeric value:" & @CRLF & _
		"$dNumber1 = " & $dNumber1 & @CRLF & _
		"$dNumber2 = " & $dNumber2 & @CRLF & _
		"$dNumber3 = " & $dNumber3 & @CRLF & _
		"$dNumber4 = " & $dNumber4 & @CRLF & _
		"$dNumber5 = " & $dNumber5 & @CRLF & _
		"$dNumber6 = " & $dNumber6 & @CRLF & _
		"$dNumber7 = " & $dNumber7 & @CRLF & _
		"$dNumber8 = " & $dNumber8 & @CRLF & _
		"$dNumber9 = " & $dNumber9 & @CRLF & _
		"$dNumber10 = " & $dNumber10 & @CRLF & _
		"$dNumber11 = " & $dNumber11 & @CRLF & _
		"$dNumber12 = " & $dNumber12 & @CRLF & _
		"$dNumber13 = " & $dNumber13 & @CRLF)
