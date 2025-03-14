; == Option 3, global return, old AutoIt style

#include <Array.au3>
#include <StringConstants.au3>

Local $aArray = StringRegExp('<test>a</test> <test>b</test> <test>c</Test>', '(?i)<test>(.*?)</test>', $STR_REGEXPARRAYGLOBALMATCH)
#cs
	1st Capturing Group (.*?)
	. matches any character (except for line terminators)
	*? matches the previous token between zero and unlimited times, as few times as possible,
	expanding as needed (lazy)
#ce
_ArrayDisplay($aArray, "Option 3 Results")
