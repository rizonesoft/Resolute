#include <MsgBoxConstants.au3>

; Register Example() and SomeFunc() to be called when AutoIt starts.

#OnAutoItStartRegister "Example"
#OnAutoItStartRegister "SomeFunc"

Sleep(1000)

Func Example()
	MsgBox($MB_SYSTEMMODAL, "", "Function 'Example' is called first.")
EndFunc   ;==>Example

Func SomeFunc()
	MsgBox($MB_SYSTEMMODAL, "", "Function 'SomeFunc' is called second.")
EndFunc   ;==>SomeFunc
