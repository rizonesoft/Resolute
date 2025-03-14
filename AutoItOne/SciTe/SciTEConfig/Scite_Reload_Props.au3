#include-once

Func _SciTE_ReloadProps($hMain_GUI)

	Local $hSciTE_Dir = WinGetHandle("DirectorExtension")
	; Create command line using dec GUI handle (return message destination)
	Local $sCmd = ":" & Dec(StringTrimLeft($hMain_GUI, 2)) & ":reloadproperties:"
	Local $tCmdStruct = DllStructCreate("Char[" & StringLen($sCmd) + 1 & "]")
	DllStructSetData($tCmdStruct, 1, $sCmd)
	Local $tCOPYDATA = DllStructCreate("Ptr;DWord;Ptr")
	DllStructSetData($tCOPYDATA, 1, 1)
	DllStructSetData($tCOPYDATA, 2, StringLen($sCmd) + 1)
	DllStructSetData($tCOPYDATA, 3, DllStructGetPtr($tCmdStruct))
	DllCall("User32.dll", "None", "SendMessage", "HWnd", $hSciTE_Dir, _
			"Int", $WM_COPYDATA, "HWnd", $hMain_GUI, _
			"Ptr", DllStructGetPtr($tCOPYDATA))

EndFunc   ;==>_SciTE_ReloadProps
