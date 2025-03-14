#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>

_Example()
Func _Example()
	Local $iDec = Dec("FFF", $NUMBER_AUTO)
	MsgBox($MB_SYSTEMMODAL, "", $iDec) ; Displays the number 4095.
EndFunc
