#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hEmf, $Data

$hEmf = _WinAPI_GetEnhMetaFile(@ScriptDir & '\Extras\Flag.emf')
$Data = _WinAPI_GetEnhMetaFileDescription($hEmf)
_WinAPI_DeleteEnhMetaFile($hEmf)

ConsoleWrite('Application: ' & $Data[0] & @CR)
ConsoleWrite('Picture:     ' & $Data[1] & @CR)
