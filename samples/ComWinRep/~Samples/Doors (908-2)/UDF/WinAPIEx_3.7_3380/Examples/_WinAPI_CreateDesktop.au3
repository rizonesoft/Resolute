#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hDesktop, $hPrev, $pText, $tProcess, $tStartup

; Retrieve a handle to the current desktop and create a new desktop named "MyDesktop"
$hPrev = _WinAPI_GetThreadDesktop(_WinAPI_GetCurrentThreadID())
$hDesktop = _WinAPI_CreateDesktop('MyDesktop', BitOR($DESKTOP_CREATEWINDOW, $DESKTOP_SWITCHDESKTOP))
If Not $hDesktop Then
	MsgBox(16, 'Error', 'Unable to create desktop.')
	Exit
EndIf

; Switch to the newly created desktop
_WinAPI_SwitchDesktop($hDesktop)

; Run "calc.exe" on "MyDesktop" and wait until a process will not be closed by user
$pText = _WinAPI_CreateString('MyDesktop')
$tProcess = DllStructCreate($tagPROCESS_INFORMATION)
$tStartup = DllStructCreate($tagSTARTUPINFO)
DllStructSetData($tStartup, 'Size', DllStructGetSize($tStartup))
DllStructSetData($tStartup, 'Desktop', $pText)
If _WinAPI_CreateProcess('', @SystemDir & '\calc.exe', 0, 0, 0, $CREATE_NEW_PROCESS_GROUP, 0, 0, DllStructGetPtr($tStartup), DllStructGetPtr($tProcess)) Then
	ProcessWaitClose(DllStructGetData($tProcess, 'ProcessID'))
EndIf

; Switch to previous desktop and close "MyDesktop"
_WinAPI_SwitchDesktop($hPrev)
_WinAPI_CloseDesktop($hDesktop)

; Free memory allocated for a string
_WinAPI_FreeMemory($pText)
