#include <Debug.au3>

_DebugSetup(Default, True)

Example()

Func Example()
	Local $sABC = ""
	#forceref $sABC

	_Assert('$sABC > ""')
	_Assert('$sABC > ""')
EndFunc
