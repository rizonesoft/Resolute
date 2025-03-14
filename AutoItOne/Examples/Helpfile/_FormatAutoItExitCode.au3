#AutoIt3Wrapper_Run_Au3Check=N
#include <AutoItExitCodes.au3>

Opt("SetExitCode", 1)

OnAutoItExitRegister('_My_Exit')

_UngracefulExit()

Exit 100 ; executed if _UngracefulExit() commented

Func _UngracefulExit()
	Local $a[1]
	MsgBox(0, 0, $a[3])
EndFunc   ;==>_UngracefulExit

Func _My_Exit()
	MsgBox(0, '_my_Exit()', '@exitCode: "' & _FormatAutoItExitCode() & '"' & @CRLF  & @CRLF & '@exitMethod: ' & _FormatAutoItExitMethod())
EndFunc   ;==>_My_Exit
