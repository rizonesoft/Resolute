#include <MsgBoxConstants.au3>
#include <WinAPIMem.au3>
#include <WinAPIProc.au3>
#include <WinAPISys.au3>

Local $tProcess = DllStructCreate($tagPROCESS_INFORMATION)
Local $tStartup = DllStructCreate($tagSTARTUPINFO)
If _WinAPI_CreateProcess('', @SystemDir & '\notepad.exe', 0, 0, 0, $CREATE_NEW_PROCESS_GROUP, 0, 0, $tStartup, $tProcess) Then
	ToolTip("Waiting notepad Closing")
	ProcessWaitClose(DllStructGetData($tProcess, 'ProcessID'))
Else
	_WinAPI_ShowLastError()
EndIf
