#include <Debug.au3>
#include <MsgBoxConstants.au3>

_DebugSetup(Default, True, 1, Default, True) ; 1 = Write messages with timestamps to the Report Log Window

Example()

; Example
; Provoke a COM error and let _DebugCOMError display the error messages in the Report Log Window
Func Example()
	; Create application object for the Microsoft Internet Explorer
	Local $oIE = ObjCreate("InternetExplorer.Application")
	If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "_DebugCOMError UDF", "Error creating a new IE application object." & _
			@CRLF & "@error = " & @error & ", @extended = " & @extended)
	; Set up the COM error handler to write error messages to the Report Log Window
	_DebugCOMError(1)
	; Provoke a COM error. Function is unknown
	$oIE.xyz()
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "_DebugCOMError UDF", "Error occurred and handled." & _
			@CRLF & "@error = " & @error)
	; Close the IE
	$oIE.Quit()
	$oIE = 0
EndFunc   ;==>Example
