#include <MsgBoxConstants.au3>

Example()

Func Example()
	; Declare a map and assign with various keys value pairs.
	Local $mMap[]
	$mMap["Jasper"] = "Jasper value"
	$mMap["Beethoven"] = "Beethoven value"
	$mMap["Pinky"] = "Pinky value"

	; Display whether the key exists or not.
	MsgBox($MB_SYSTEMMODAL, "", "Jasper: " & MapExists($mMap, "Jasper")) ; Returns 1.
	MsgBox($MB_SYSTEMMODAL, "", "Fidget: " & MapExists($mMap, "Fidget")) ; Returns 0.

	; Clear a key by setting it to Null. The key will still exist in the map. Use MapRemove to remove the key entirely.
	$mMap["Jasper"] = Null

	MsgBox($MB_SYSTEMMODAL, "", "Jasper: " & MapExists($mMap, "Jasper")) ; Returns 1.
EndFunc   ;==>Example
