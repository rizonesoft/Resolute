#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.0' Then
	MsgBox(16, 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

Global $hModule, $Data

$Data = _WinAPI_ShellGetLocalizedName(@MyDocumentsDir)
If Not IsArray($Data) Then
	Exit
EndIf

$hModule = _WinAPI_LoadLibraryEx($Data[0], $LOAD_LIBRARY_AS_DATAFILE)
ConsoleWrite('Path: ' & $Data[0] & @CR)
ConsoleWrite('ID:   ' & $Data[1] & @CR)
ConsoleWrite('Name: ' & _WinAPI_LoadString($hModule, $Data[1]) & @CR)
_WinAPI_FreeLibrary($hModule)
