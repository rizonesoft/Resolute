#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tStruct1, $tStruct2, $tStruct3, $Size

$tStruct1 = DllStructCreate('byte[6]')
For $i = 1 To 6
	DllStructSetData($tStruct1, 1, $i, $i)
Next

$tStruct2 = DllStructCreate('byte[2]')
For $i = 1 To 2
	DllStructSetData($tStruct2, 1, $i + 6, $i)
Next

$tStruct3 = _WinAPI_UnionStruct($tStruct1, $tStruct2)

$Size = DllStructGetSize($tStruct3)
For $i = 1 To $Size
	ConsoleWrite(DllStructGetData($tStruct3, 1, $i) & @CR)
Next
