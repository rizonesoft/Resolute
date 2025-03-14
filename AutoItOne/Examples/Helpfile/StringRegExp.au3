; == Option 1, using offset parameter

#include <MsgBoxConstants.au3>
#include <StringConstants.au3>

Local $aArray = 0, _
		$iOffset = 1, $iOffsetStart
While 1
	$iOffsetStart = $iOffset
	$aArray = StringRegExp('<test>a</test> <test>b</test> <test>c</Test>', '(?i)<test>(.*?)</test>', $STR_REGEXPARRAYMATCH, $iOffset)
	If @error Then ExitLoop
	$iOffset = @extended
	For $i = 0 To UBound($aArray) - 1
		MsgBox($MB_SYSTEMMODAL, "Opt 1 at " & $iOffsetStart, $aArray[$i])
	Next
WEnd
