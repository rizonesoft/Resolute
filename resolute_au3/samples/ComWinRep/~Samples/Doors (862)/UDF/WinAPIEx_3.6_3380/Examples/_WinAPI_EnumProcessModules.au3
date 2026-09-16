#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If (_WinAPI_GetVersion() < '6.0') And (@AutoItX64) Then
	MsgBox(16, 'Error', 'This example works from a 64-bit system only in Windows Vista or later.')
	Exit
EndIf

Global $Data = _WinAPI_EnumProcessModules()

_ArrayDisplay($Data, '_WinAPI_EnumProcessModules')
