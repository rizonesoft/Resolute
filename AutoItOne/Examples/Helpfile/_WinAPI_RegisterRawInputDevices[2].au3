#include <GUIConstants.au3>
#include <GuiEdit.au3>
#include <WinAPISys.au3>

Global $g_idEdit
test()

Func test()
	; Create GUI
	Local $hGui = GUICreate('', 400, 400, -1, -1, -1, $WS_EX_TOPMOST)
	$g_idEdit = GUICtrlCreateEdit('', 10, 10, 380, 380)

	Local $tRAWINPUTDEVICEs = DllStructCreate($tagRAWINPUTDEVICE & _
			';struct;ushort UsagePage2;ushort Usage2;dword Flags2;hwnd hTarget2;endstruct')
	DllStructSetData($tRAWINPUTDEVICEs, 'UsagePage', 0x01)
	DllStructSetData($tRAWINPUTDEVICEs, 'Usage', 0x02) ; mouse
	DllStructSetData($tRAWINPUTDEVICEs, 'Flags', $RIDEV_INPUTSINK)
	DllStructSetData($tRAWINPUTDEVICEs, 'hTarget', $hGui)

	DllStructSetData($tRAWINPUTDEVICEs, 'UsagePage2', 0x01)
	DllStructSetData($tRAWINPUTDEVICEs, 'Usage2', 0x06) ; keyboard
	DllStructSetData($tRAWINPUTDEVICEs, 'Flags2', $RIDEV_INPUTSINK)
	DllStructSetData($tRAWINPUTDEVICEs, 'hTarget2', $hGui)

	; Register HID input to obtain row input from mice and keyboard
	_WinAPI_RegisterRawInputDevices($tRAWINPUTDEVICEs, 2)

	; Register WM_INPUT message
	GUIRegisterMsg($WM_INPUT, WM_INPUT)

	GUISetState()

	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE

EndFunc   ;==>test

Func WM_INPUT($hGui, $iMsg, $wParam, $lParam)
	#forceref $hGui, $iMsg, $wParam, $lParam
	Local $tRAWINPUTHEADER = DllStructCreate($tagRAWINPUTHEADER)
	_WinAPI_GetRawInputData($lParam, $tRAWINPUTHEADER, DllStructGetSize($tRAWINPUTHEADER), $RID_HEADER)
	Switch DllStructGetData($tRAWINPUTHEADER, 'Type')
		Case $RIM_TYPEMOUSE
			Local $tRAWINPUTMOUSE = DllStructCreate($tagRAWINPUTMOUSE)
			_WinAPI_GetRawInputData($lParam, $tRAWINPUTMOUSE, DllStructGetSize($tRAWINPUTMOUSE), $RID_INPUT)
			Local $iButtonFlags = DllStructGetData($tRAWINPUTMOUSE, 'ButtonFlags')
			If $iButtonFlags Then
				Local $sTypeMouse = "Up"
				If $iButtonFlags = 1 Then $sTypeMouse = "Down"
				_GUICtrlEdit_AppendText($g_idEdit, 'RIM_TYPEMOUSE ' & $sTypeMouse & @CRLF)
			EndIf
		Case $RIM_TYPEKEYBOARD
			_GUICtrlEdit_AppendText($g_idEdit, 'RIM_TYPEKEYBOARD' & @CRLF)
	EndSwitch
EndFunc   ;==>WM_INPUT
