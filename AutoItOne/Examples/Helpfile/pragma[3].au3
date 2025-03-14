#pragma compile(Out, pragma[3].exe)
; use AutoItExecuteAllowed option to allow running au3 or a3x file using this compiled EXE as an interpreter
#pragma compile(AutoItExecuteAllowed, true)

#REMARK before you use this example you must firstly compile pragma[2].au3
#include <MsgBoxConstants.au3>

_Example()

Func _Example()
	Local $iPID_au3 = Run(@ScriptFullPath & ' /AutoIt3ExecuteScript "' & @ScriptDir & '\pragma[2].au3"')
	While ProcessExists($iPID_au3)
		Sleep(10)
	WEnd
	MsgBox($MB_ICONINFORMATION, 'Check 1', 'After running pragma[2].au3')

	Local $iPID_a3x = Run(@ScriptFullPath & ' /AutoIt3ExecuteScript "' & @ScriptDir & '\pragma[2].a3x"')
	While ProcessExists($iPID_a3x)
		Sleep(10)
	WEnd
	MsgBox($MB_ICONINFORMATION, 'Check 2', 'After running pragma[2].a3x')

EndFunc   ;==>_Example
