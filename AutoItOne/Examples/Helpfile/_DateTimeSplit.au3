#include <Date.au3>
#include <MsgBoxConstants.au3>

Local $aMyDate, $aMyTime
_DateTimeSplit("2005/01/01 14:30", $aMyDate, $aMyTime)
If @error Then
	MsgBox($MB_SYSTEMMODAL + $MB_ICONERROR, "Result", "Error")
Else
	Local $sMsg = "Year = " & @TAB & $aMyDate[1] & @CRLF
	$sMsg &= "Month = " & $aMyDate[2] & @CRLF
	$sMsg &= "Day = " & @TAB & $aMyDate[3] & @CRLF
	$sMsg &= "Hour = " & @TAB & $aMyTime[1] & @CRLF
	$sMsg &= "Min = " & @TAB & $aMyTime[2] & @CRLF
	If $aMyTime[0] = 3 Then $sMsg &= "Sec = " & @TAB & $aMyTime[3] & @CRLF
	MsgBox($MB_SYSTEMMODAL, "Results", $sMsg)
EndIf
