#include  <MsgBoxConstants.au3>

Example()

Func Example()
	; Declare a map and assign with various keys value pairs.
	Local $mMap[]
	$mMap["Jasper"] = "Jasper value"
	$mMap["Beethoven"] = "Beethoven value"
	$mMap["Pinky"] = "Pinky value"

	; Read keys
	Local $aKeys = MapKeys($mMap)
	Local $sData = ""
	; Read values
	For $i = 0 To UBound($aKeys) - 1
		$sData &= $aKeys[$i] & ": " & $mMap[$aKeys[$i]] & @CRLF
	Next
	; Display result
	MsgBox($MB_SYSTEMMODAL, "", $sData & @CRLF & _
			'Beethoven exists: ' & MapExists($mMap, "Beethoven") & @CRLF & 'Beethoven equals Null: ' & ($mMap["Beethoven"] == Null))

	; Clear a key by setting it to Null. The key will still exist in the map.
	$mMap["Beethoven"] = Null

	; Re-read keys and values
	$aKeys = MapKeys($mMap)
	$sData = ""
	For $i = 0 To UBound($aKeys) - 1
		$sData &= $aKeys[$i] & ": " & $mMap[$aKeys[$i]] & @CRLF
	Next
	; Display the values of the map keys. Notice how the "Beethoven" key now contains an empty value (Null).
	MsgBox($MB_SYSTEMMODAL, "", $sData & @CRLF & _
			'Beethoven exists: ' & MapExists($mMap, "Beethoven") & @CRLF & 'Beethoven equals Null: ' & ($mMap["Beethoven"] == Null))

	; Remove the "Beethoven" key entirely.
	MapRemove($mMap, "Beethoven")

	; Re-read keys and values
	$aKeys = MapKeys($mMap)
	$sData = ""
	For $i = 0 To UBound($aKeys) - 1
		$sData &= $aKeys[$i] & ": " & $mMap[$aKeys[$i]] & @CRLF
	Next
	; Display the values of the map keys. Notice how the "Beethoven" key is no longer exists.
	MsgBox($MB_SYSTEMMODAL, "", $sData & @CRLF & _
			'Beethoven exists: ' & MapExists($mMap, "Beethoven") & @CRLF & 'Beethoven equals Null: ' & ($mMap["Beethoven"] == Null))

EndFunc   ;==>Example
