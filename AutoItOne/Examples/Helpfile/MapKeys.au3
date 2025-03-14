#include <MsgBoxConstants.au3>

Example()

Func Example()
	; Declare a map and assign with various keys value pairs.
	Local $mMap[]
	$mMap[1] = "Integer One" ; Integer value as a key.
	$mMap["2"] = "String Two" ; String value representing an integer as a key. This is a string not an integer.
	MapAppend($mMap, "Integer Two") ; Append a value using the next available integer, which is 2 in this case.

	; Retrieve the keys contained in the map. A zero-based one-dimensional array is returned.
	Local $aMapKeys = MapKeys($mMap)
	For $vKey In $aMapKeys ; Or a For loop can be used as well.
		MsgBox($MB_SYSTEMMODAL, "", "Key: " & $vKey & @CRLF & _ ; The key.
				"Value: " & $mMap[$vKey] & @CRLF & _ ; Use the array value of MapKeys() to display the value of the key.
				"Variable Type: " & VarGetType($vKey) & @CRLF) ; Display the variable type of the key i.e. integer or string.
	Next
EndFunc   ;==>Example
