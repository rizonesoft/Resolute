#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.0' Then
	MsgBox(16, 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

If _WinAPI_IsInternetConnected() Then
	ConsoleWrite('Internet is already connected.' & @CR)
	Exit
EndIf

; Launch the Get Connected wizard within the calling application to enable Internet connectivity
_WinAPI_GetConnectedDlg(1, 1 + 4)
