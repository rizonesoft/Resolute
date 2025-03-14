#include <Array.au3>
#include <Debug.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	Local $aArrayFromText = _ArrayFromString("  1|2  ") ;               by default, LEADING and TRAILING
	_DebugArrayDisplay($aArrayFromText, UBound($aArrayFromText, $UBOUND_DIMENSIONS) & "D") ; spaces are removed.

	$aArrayFromText = _ArrayFromString("1|2", Default, Default, True) ; force 2D array
	_DebugArrayDisplay($aArrayFromText, UBound($aArrayFromText, $UBOUND_DIMENSIONS) & "D")

	$aArrayFromText = _ArrayFromString("1|2" & @CRLF & "3|4")
	_DebugArrayDisplay($aArrayFromText, UBound($aArrayFromText, $UBOUND_DIMENSIONS) & "D")

EndFunc   ;==>Example
