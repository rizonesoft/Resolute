; == Option 4, global return, php/preg_match_all() style

#include <Array.au3>

_Example()

Func _Example()
	Local $sHTML = _
			'<select id="OptionToChoose">' & @CRLF & _
			'	<option value="" selected="selected">Choose option</option>' & @CRLF & _
			'	<option value="1">Sun</option>' & @CRLF & _
			'	<option value="2">Earth</option>' & @CRLF & _
			'	<option value="3">Moon</option>' & @CRLF & _
			'</select>' & @CRLF & _
			''

	Local $aOuter = StringRegExp($sHTML, '(?is)(<option value="(.*?)"( selected="selected"|.*?)>(.*?)</option>)', $STR_REGEXPARRAYGLOBALFULLMATCH)
	_ArrayDisplay($aOuter, '$aOuter')

	Local $aInner
	For $IDX_Out = 0 To UBound($aOuter) - 1
		$aInner = $aOuter[$IDX_Out]
		_ArrayDisplay($aInner, '$aInner = $aOuter[$IDX_Out] ... $IDX_Out = ' & $IDX_Out)
	Next

EndFunc   ;==>_Example
