#include <Array.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()

	; Create 1D array to display
	Local $aArray_1D[5] = ["Item 0", "Item 1", "A longer Item 2 to show column expansion", "Item 3", "Item 4"]

	_ArrayDisplay($aArray_1D, "1D display")

	; Create 2D array to display
	Local $aArray_2D[20][15]
	For $i = 0 To UBound($aArray_2D) - 1
		For $j = 0 To UBound($aArray_2D, 2) - 1
			$aArray_2D[$i][$j] = "Item " & StringFormat("%02i", $i) & StringFormat("%02i", $j)
		Next
	Next

	_ArrayDisplay($aArray_2D, "2D display")
	_ArrayDisplay($aArray_2D, "2D display transposed", Default, 1)

	ReDim $aArray_2D[20][10]
	$aArray_2D[5][5] = "A longer item to show column expansion"
	_ArrayDisplay($aArray_2D, "Expanded column - custom titles - no row/column", Default, 64, Default, "AA|BB|CC|DD|EE|FF|GG|HH|II|JJ")

	$aArray_2D[5][5] = "Column alignment set to right"
	_ArrayDisplay($aArray_2D, "Range set - right align", "3:7|4:9", 2, Default, "AA|BB|CC|DD|EE|FF")

	$aArray_2D[5][5] = "Column alignment set to left"
	Opt("GUIDataSeparatorChar", "!")
	_ArrayDisplay($aArray_2D, "! Header separator", "3:7|4:9", Default, Default, "AA!BB!CC!DD!EE!FF")

	; Create non-array variable to force error - MsgBox displayed as $iFlags set
	Local $vVar = 0, $iRet, $iError
	$iRet = _ArrayDisplay($vVar, "No MsgBox on Error")
	$iError = @error
	MsgBox(0, "_ArrayDisplay() Error", "return without internal Msgbox $iret =" & $iRet & " @error=" & $iError)

	$iRet = _ArrayDisplay($vVar, "MsgBox on Error", Default, 8)
	$iError = @error
	MsgBox(0, "_ArrayDisplay() Error", "return internal Msgbox with no force Exit $iret =" & $iRet & " @error=" & $iError)

EndFunc    ;==>Example
