#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.0' Then
	MsgBox(16, 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

Global $hInstance, $hIcon, $aInfo

$hInstance = _WinAPI_LoadLibraryEx(@AutoItExe, $LOAD_LIBRARY_AS_DATAFILE)
$hIcon = _WinAPI_LoadImage($hInstance, 99, $IMAGE_ICON, 0, 0, $LR_DEFAULTSIZE)
$aInfo = _WinAPI_GetIconInfoEx($hIcon)
If IsArray($aInfo) Then
	ConsoleWrite('Handle: ' & $hIcon & @CR)
	ConsoleWrite('Path:   ' & $aInfo[6] & @CR)
	ConsoleWrite('ID:     ' & $aInfo[5] & @CR)
	For $i = 3 To 4
		_WinAPI_DestroyIcon($aInfo[$i])
	Next
EndIf
_WinAPI_FreeLibrary($hInstance)
_WinAPI_DestroyIcon($hIcon)
