#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tSIZE, $hIcon

$hIcon = _WinAPI_ShellExtractIcon(@SystemDir & '\shell32.dll', 130, 48, 48)
$tSIZE = _WinAPI_GetIconDimension($hIcon)
_WinAPI_DestroyIcon($hIcon)

ConsoleWrite(DllStructGetData($tSIZE, 'X') & ' x ' & DllStructGetData($tSIZE, 'Y') & @CR)
