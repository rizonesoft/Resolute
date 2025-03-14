; == Option 4, global return, php/preg_match_all() style

#include <Array.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>

Local $aArray = StringRegExp('F1oF2oF3o', '(F.o)*?', $STR_REGEXPARRAYGLOBALFULLMATCH)
#cs
	1st Capturing Group (F.o)*?
	*? matches the previous token between zero and unlimited times, as few times as possible, expanding as needed (lazy)
#ce
_ArrayDisplay($aArray,"Opt - 4 Results")
Local $aMatch = 0
For $i = 0 To UBound($aArray) - 1
	$aMatch = $aArray[$i]
	If UBound($aMatch) > 1 Then
		_ArrayDisplay($aMatch, "Array #" & $i)
	Else
		MsgBox($MB_SYSTEMMODAL, "Array #" & $i, "'" & $aMatch[0] & "' StringLen = " & StringLen(StringLen))
	EndIf
Next
