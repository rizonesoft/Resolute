#include-once

Func _SetError($nError)

	Switch $nError
		Case 1
			_ShowErrorMessage("Error!", "Please select a repair option first.")
	EndSwitch

EndFunc

Func _ShowErrorMessage($sErrorTitle = "Error!", $sErrorMsg = "Unknown error!")
	MsgBox(0, "Error!", "Please select a repair option first.")
EndFunc