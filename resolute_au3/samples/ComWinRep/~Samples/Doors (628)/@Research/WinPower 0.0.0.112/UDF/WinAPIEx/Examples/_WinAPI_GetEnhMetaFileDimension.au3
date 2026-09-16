#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tSIZE, $hEmf

$hEmf = _WinAPI_GetEnhMetaFile(@ScriptDir & '\Extras\Flag.emf')
$tSIZE = _WinAPI_GetEnhMetaFileDimension($hEmf)
_WinAPI_DeleteEnhMetaFile($hEmf)

ConsoleWrite(DllStructGetData($tSIZE, 'X') & ' x ' & DllStructGetData($tSIZE, 'Y') & @CR)
