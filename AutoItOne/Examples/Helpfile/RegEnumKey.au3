#include <MsgBoxConstants.au3>

Example()

Func Example()
	Local $sSubKey = "", $sEnumKey = "under HKLM\SOFTWARE:" & @CRLF & @CRLF

	; Loop from 1 to 10 times, displaying registry keys at the particular instance value.
	For $i = 1 To 10
		$sSubKey = RegEnumKey("HKEY_LOCAL_MACHINE\SOFTWARE", $i)
		If @error Then ExitLoop
		$sEnumKey &= "#" & $i & @TAB & $sSubKey & @CRLF
	Next

	MsgBox($MB_SYSTEMMODAL, "RegEnumKey Example", $sEnumKey)
EndFunc   ;==>Example
