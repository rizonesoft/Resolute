#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tStruct1, $tStruct2

$tStruct1 = _WinAPI_GetMousePos()
Sleep(2000)
$tStruct2 = _WinAPI_GetMousePos()

ConsoleWrite('Mouse moved: ' & (Not _WinAPI_EqualStruct($tStruct1, $tStruct2)) & @CR)
