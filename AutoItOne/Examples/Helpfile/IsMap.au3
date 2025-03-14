#include <MsgBoxConstants.au3>

Local $mMap[] ; Declare a map.
If IsMap($mMap) Then
	MsgBox($MB_SYSTEMMODAL, "", "The variable is a map")
Else
	MsgBox($MB_SYSTEMMODAL, "", "The variable is not a map")
EndIf
