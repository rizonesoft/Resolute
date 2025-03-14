#include-once
#include <Constants.au3>
#include <SendMessage.au3>
#include <WindowsConstants.au3>

Func _SciTE_Send_Command($hWnd, $hSciTE, $sMsg)
	If StringStripWS($sMsg, $STR_STRIPALL) = '' Then
		Return SetError(2, 0, 0) ; String is blank.
	EndIf

	$sMsg = ':' & Dec(StringTrimLeft($hWnd, 2)) & ':' & $sMsg
	Local Const $tBuffer = DllStructCreate('char cdata[' & StringLen($sMsg) + 1 & ']')
	DllStructSetData($tBuffer, 'cdata', $sMsg)
	Local Const $tagCOPYDATASTRUCT = 'ptr dwData;dword cbData;ptr lpData' ; 'ulong_ptr dwData;dword cbData;ptr lpData'
	Local Const $tCOPYDATASTRUCT = DllStructCreate($tagCOPYDATASTRUCT)
	DllStructSetData($tCOPYDATASTRUCT, 'dwData', 0)
	DllStructSetData($tCOPYDATASTRUCT, 'cbData', DllStructGetSize($tBuffer))
	DllStructSetData($tCOPYDATASTRUCT, 'lpData', DllStructGetPtr($tBuffer))
	_SendMessage($hSciTE, $WM_COPYDATA, $hWnd, DllStructGetPtr($tCOPYDATASTRUCT))
	Return Number(Not @error)
EndFunc   ;==>_SciTE_Send_Command
